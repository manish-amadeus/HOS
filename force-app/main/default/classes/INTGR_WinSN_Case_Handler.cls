/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!
*************************************************************************************************
Name            : INTGR_WinSN_Case_Handler Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 02/03/2016
Last Mod Date   : 03/26/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : Updated Per NICC-023347
Description     : Updated 9/13/2017 Per NICC-023825
				: Updated 10/5/2017 Per NICC-024188
                : Updated 4/23/2018 Per NICC-027116
                : Updated 5/3/2018 Per NICC-027324
                : Updated per NICC-030216
                : Updated 12/6/2019 per NICC-039247
*************************************************************************************************/
public class INTGR_WinSN_Case_Handler
{

    private String strProfileName = [SELECT Profile.Name FROM User WHERE Id =: UserInfo.getUserId()][0].Profile.Name;
    // CONTEXT USER SWITCHES
    private boolean isUser_INTERNAL = false;
    private boolean isUser_WINAPROACH = false;
    private boolean isUser_CUSTOMER_IHG = false; 
    private boolean isUser_CUSTOMER = false;
    // TRIGGER HANDLER SWITCH
	private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    // FLAG VARIABLES
	public static Integer rec_flag = 0;
	public static Integer open_flag = 0;
	public static Integer PCP_flag = 0;


    public INTGR_WinSN_Case_Handler()
    {
        if (strProfileName == 'Case Integration Customers')
        {
            isUser_CUSTOMER = true;
        }
        else if (strProfileName == 'IHG Integration Only - Standard')
        {
            isUser_CUSTOMER_IHG = true;
        } 
        else if (strProfileName == 'Winaproach Integration Only - Standard')
        {
            isUser_WINAPROACH = true;
        } 
        else
        {
            isUser_INTERNAL = true;
        }
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }

	public void OnBeforeInsert(List<Case> newTrigger)
	{
		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());

		List<Case> lstValidCases = new List<Case>();
		lstValidCases = lstValidCasesToProcess(newTrigger);
		if (lstValidCases.Size() > 0)
		{
			// IF USER DOES NOT HAVE 'Case Integration Customers' PROFILE AND NOT CALLED AS A RESULT OF AN INTGR_Case__c INSERT (LEGACY CONTEXT)
			//if (!INTGR_IntegrationHelper.isICFlow && !INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
			//if (!INTGR_IntegrationHelper.isICFlow && !isUser_CUSTOMER)
            if (isUser_CUSTOMER_IHG)	// NICC-039247
			{
				processBeforeInsert(lstValidCases);
			}

			// IF USER HAS 'Case Integration Customers' PROFILE
			//if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
			if (isUser_CUSTOMER)
            {
				INTGR_IntegrationHelper.populateIntegrationAccountOnCase(lstValidCases);
			}
		}

		system.debug(' *** EXITING INTGR_WinSN_Case_Handler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	public void OnAfterInsert(List<Case> newTrigger)
	{
		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());

		List<Case> lstValidCases = new List<Case>();
		lstValidCases = lstValidCasesToProcess(newTrigger);
		if (lstValidCases.Size() > 0)
		{
			processAfterInsert(lstValidCases);
		}

		system.debug(' *** EXITING INTGR_WinSN_Case_Handler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	public void OnBeforeUpdate(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
	{
		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

		List<Case> lstValidCases = new List<Case>();
		lstValidCases = lstValidCasesToProcess(newTrigger);
		if (lstValidCases.Size() > 0)
		{        
			// IF USER DOES NOT HAVE 'Case Integration Customers' PROFILE AND NOT CALLED AS A RESULT OF AN INTGR_Case__c UPDATE (LEGACY CONTEXT)
			// if (!INTGR_IntegrationHelper.isICFlow && !INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
			// if (!INTGR_IntegrationHelper.isICFlow && !isUser_CUSTOMER)
			if (isUser_CUSTOMER_IHG)		// NICC-039247
			{
				setClosedCaseCheckboxes(newTrigger, oldMapTrigger);
			}
			processBeforeUpdate(lstValidCases, oldMapTrigger);
		}

		system.debug(' *** EXITING INTGR_WinSN_Case_Handler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	public void OnAfterUpdate(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
	{
		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

		List<Case> lstValidCases = new List<Case>();
		lstValidCases = lstValidCasesToProcess(newTrigger);

		if (lstValidCases.Size() > 0)
		{
			processAfterUpdate(lstValidCases, oldMapTrigger);

			// IF USER DOES NOT HAVE 'Case Integration Customers' PROFILE AND IS NOT UPDATE TO FLAGS AND IS NOT CASE COMMENT FROM STANDARD CASE FLAGGED OPERATION
			if (!isUser_CUSTOMER && !INTGR_IntegrationHelper.isUpdateOncaseFlags && !INTGR_IntegrationHelper.isCCFromSC) // !INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
			{
				processICAfterSCUpdate(lstValidCases, oldMapTrigger);
			}
			else
			{
				List<Case> lstCaseUpdates = new List<Case>();

				for (Case c : lstValidCases)
				{
                    // IF USER HAS 'Case Integration Customers' PROFILE AND WAS LAST TO MODIFY CASE
					// if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME) && c.LastModifiedById == UserInfo.getUserId())
                    if (isUser_CUSTOMER && c.LastModifiedById == UserInfo.getUserId())
                    {
						lstCaseUpdates.add(c);
					}
				}

				if (lstCaseUpdates.size() > 0 && !INTGR_IntegrationHelper.isUpdateOncaseFlags)
				{
					processICAfterSCUpdate(lstCaseUpdates, oldMapTrigger);
				}
			}
		}

		system.debug(' *** EXITING INTGR_WinSN_Case_Handler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	// =========================================================================
	//  FUNCTIONS ==============================================================
	// =========================================================================
	private List<Case> lstValidCasesToProcess(List<Case> newTrigger)
	{
		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.lstValidCasesToProcess() - QUERIES ISSUED = ' + Limits.getQueries());

		// LIST OF VALID CASES TO BE RETURNED
		List<Case> retLst = new List<Case>();

		// GET ALL VALID CASE RECORD TYPE NAMES FROM CUSTOM SETTING
		Winaproach_Incident_Case_Record_Type__c wcsRecordTypes = Winaproach_Incident_Case_Record_Type__c.getValues('Default');

		// NICC-027116 4/23/2018- ADDED BY RIA TO CONSIDER 'CRS WORK ORDER' CASE RECORD TYPES
		Winaproach_Work_Order_Case_Record_Type__c strWorkOrderRecType = Winaproach_Work_Order_Case_Record_Type__c.getValues('Default');

		// IF NO RECORD TYPE NAMES FROM CUSTOM SETTING FOUND RETURN 0 SIZED CASE LIST
		if (wcsRecordTypes == null  && strWorkOrderRecType == null)
		{
			return retLst;
		}

		// PARSE RECORD TYPE NAMES FROM CUSTOM SETTING INTO LIST
		List<String> lstRecordTypes = String.valueOf(wcsRecordTypes.record_type__c).split(',');

		// SET TO HOLD CASE RECORD TYPE IDS
		Set<Id> setRecordTypeIds = new Set<Id>();

		// NICC-027116 4/23/2018- ADDED BY RIA TO CONSIDER 'CRS WORK ORDER CASE' RECORD TYPES ALSO
		// LOOK FOR RECORD TYPE OF CRS WORK ORDERS
		if (strWorkOrderRecType != null)
		{
			lstRecordTypes.add(String.valueOf(strWorkOrderRecType.Record_Type__c));
		}

		// NICC-027324 (START)
		// LOOP THROUGH CASE RECORD TYPES TO ASSIGN IDS TO SET
		Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.Case.getRecordTypeInfosByName();

		for (String recType : lstRecordTypes)
		{
			if (recordTypesMap.containsKey(recType))
			{
				Schema.RecordTypeInfo rr = recordTypesMap.get(recType);
				setRecordTypeIds.Add(rr.getRecordTypeId());
			}
		}
		// NICC-027324 (END)

		for (Case c : newTrigger)
		{
			// IF CASE IS OF A WIN@PROACH / SERVICE NOW INTEGRATION RECORD TYPE
			if (setRecordTypeIds.contains(c.RecordTypeId))
			{
				retLst.Add(c);
			}
		}

		system.debug(' *** EXITING INTGR_WinSN_Case_Handler.lstValidCasesToProcess() - QUERIES ISSUED = ' + Limits.getQueries());

		return retLst;
	}

	private void processBeforeInsert(List<Case> newTrigger)
	{
		// THIS METHOD CONDITIONALLY SETS Customer_Severity__c, Priority, Status, INTGR_Recovery_Plan__c & INTGR_Recovery_Plan_Date_Time__c ON LEGACY INTEGRATION CASES
		// USES CUSTOM SETTINGS IN THIS LOGIC:
		// 		"Winaproach Incident Case Record Type", "Winaproach Work Order Case Record Type", "Winaproach Incident Urgency Mapping", "Case Record Type Status"

		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.processBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());

		Winaproach_Incident_Case_Record_Type__c csRecType = Winaproach_Incident_Case_Record_Type__c.getValues('Default');
		List<String> lstRecordTypes = String.valueOf(csRecType.Record_Type__c).split(',');
		Map<String, String> mapCaseRecTypeDefStatus = new Map<String, String>();
		String strWorkOrderRecType = '';

		// LOOK FOR RECORD TYPE OF WORK ORDERS
		if (Winaproach_Work_Order_Case_Record_Type__c.getValues('Default') != null && Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c != null)
		{
			strWorkOrderRecType = Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c;
		}

		Set<String> setRecordTypes = new Set<String>(lstRecordTypes);
		String sText;

		// ADDED BY RIA - 10/24/18 TO FETCH RECORD TYPE WITH DEFAULT STATUS TO BE SET ON CREATION OF NEW CASE
		List<Case_Record_Type_Status__c> recTypeStatus = new List<Case_Record_Type_Status__c>();

		for (Case_Record_Type_Status__c caserecType : [SELECT Id, Name, Status__c FROM Case_Record_Type_Status__c])
		{
			if (caserecType.Status__c != null)
			{
				mapCaseRecTypeDefStatus.put(caserecType.Name, caserecType.Status__c);
			}
		}

		for (Case cs : newTrigger)
		{
			String strRecordTypeOfCase = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByID().get(cs.RecordTypeId).getName();

			if ((setRecordTypes.contains(strRecordTypeOfCase) || strWorkOrderRecType == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByID().get(cs.RecordTypeId).getName()) &&
			    cs.Customer_Severity__c != null)
			{
				// ASSIGNING SEVERITY VALUE FROM CUSTOM SETTING
				sText = cs.Customer_Severity__c;
				sText = sText.replaceAll('\\s+', '_');
				sText = 'X' + sText + '__c';

				try
				{
					// URGENCY
					if (WinaproachIncidentUrgencyMapping__c.getValues('Default').get(sText) != null)
					{
						// ASSIGNING URGENCY VALUE FROM CUSTOM SETTING
						cs.Priority = String.valueOf(WinaproachIncidentUrgencyMapping__c.getValues('Default').get(sText));
					}
				}
				catch(Exception e)
				{
					cs.Priority = 'N';
				}
			}

			// ADDED BY RIA - 10/24 CHECK RECORD TYPE FROM CUSTOM SETTING AND SET STATUS OF NEW CASE
			if (mapCaseRecTypeDefStatus.containsKey(strRecordTypeOfCase))
			{
				if (mapCaseRecTypeDefStatus.get(strRecordTypeOfCase) != null)
				{
					cs.Status = mapCaseRecTypeDefStatus.get(strRecordTypeOfCase);
				}
			}

			if (cs.INTGR_Assigned_Recovery_Plan__c != null)
			{
				cs.INTGR_Recovery_Plan__c = true;
				cs.INTGR_Recovery_Plan_Date_Time__c = Datetime.now();
			}
		}

		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.processBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	private void processAfterInsert(List<Case> newTrigger)
	{
		// THIS METHOD MAKES THE OUTBOUND CALLS TO WINAPROACH AND IHG SERVICENOW

		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.processAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());

		List<Case> lstServiceNowCaseInserts = new List<Case>();
		WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
		ServiceNowIncidentSettings__c snSettings = ServiceNowIncidentSettings__c.getValues('Default');

		if (winSettings != null)
		{
			if (winSettings.Integration_Username__c != null && winSettings.Integration_Username__c != UserInfo.getUserName())
			{
				// CALLING EXTERNAL Win@proach WEB SERVICE
				NI_WinaproachService niWin = new NI_WinaproachService('Create', newTrigger);
			}
		}

		if (snSettings != null)
		{
			// IF USER DOES NOT HAVE 'Case Integration Customers' PROFILE AND NOT CALLED AS A RESULT OF AN INTGR_Case__c INSERT (LEGACY CONTEXT)
			// if (!INTGR_IntegrationHelper.isICFlow && !INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
			if (!INTGR_IntegrationHelper.isICFlow && !isUser_CUSTOMER) 
			{
				for (Case cs : newTrigger)
				{
					// IF LEGACY SN CREDENTIALS EXIST IN CUSTOM SETTING &
					// CASE IS A CRS INCIDENT &
					// THERE ARE NO REFERENCES TO AN EXISTING IHG SERVICENOW TICKET &
					// THE "ACTION: Create Ticket in Customer System" CHECKBOX IS CHECKED
					if (snSettings.Integration_Username__c != null &&
					    snSettings.ServiceNow_Password__c != null &&
					    snSettings.ServiceNow_Incident_Case_Record_Type__c == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByID().get(cs.RecordTypeId).getName() &&
					    cs.INTGR_Create_Ticket_in_Customer_System__c == true &&
					    (cs.INTGR_Customer_Ticket_System_Id__c == null || cs.INTGR_Customer_Ticket_System_Id__c == '') &&
					    (cs.Customer_Ticket_Number__c == null || cs.Customer_Ticket_Number__c == ''))
					{
						lstServiceNowCaseInserts.add(cs);
					}
				}
			}
		}

		if (!lstServiceNowCaseInserts.isEmpty())
		{
			// CALLING EXTERNAL ServiceNow WEB SERVICE
			NI_ServicenowIntegration.updateIncidents(lstServiceNowCaseInserts, null);
		}

		system.debug(' *** EXITING INTGR_WinSN_Case_Handler.processAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	private void processBeforeUpdate(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
	{
		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.processBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

		Winaproach_Incident_Case_Record_Type__c csRecType = Winaproach_Incident_Case_Record_Type__c.getValues('Default');
		WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
		ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default');
		List<string> lstRecordTypes = String.valueOf(csRecType.Record_Type__c).split(',');
		Set<String> setRecordTypes = new Set<String>(lstRecordTypes);
		String strWorkOrderRecType = '';
		String sText;

		// LOOK FOR RECORD TYPE OF WORK ORDERS
		if (Winaproach_Work_Order_Case_Record_Type__c.getValues('Default') != null && Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c != null)
		{
			strWorkOrderRecType = Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c;
		}

		for (Case cs : newTrigger)
		{
         
			// NEW! IF CUSTOMER CHANGES THE CASE STATUS TO 'Acknowledged' OR ASSIGNMENT GROUP TO 'VN-GLBL-GRS Amadeus Level 3', UNCHECK Work Around Available CHECKBOX
			if (isUser_CUSTOMER || isUser_CUSTOMER_IHG)
			{
				if ((cs.Status == 'Acknowledged' && (cs.Status != oldMapTrigger.get(cs.Id).Status)) || 
                    (cs.Assignment_Group__c == 'VN-GLBL-GRS Amadeus Level 3' && (cs.Assignment_Group__c != oldMapTrigger.get(cs.Id).Assignment_Group__c)))
				{
					if (cs.Work_Around_Available__c)
					{
						cs.Work_Around_Available__c = false;
						cs.Workaround_Rejected_Date__c = system.now();	
					}
				}
			}				
            
			// NEW! IF Work_Around_Available__c GETS CHECKED THEN UPDATE Workaround_Provided_Date__c WITH NOW
            if (cs.Work_Around_Available__c && !oldMapTrigger.get(cs.Id).Work_Around_Available__c)
            {
                cs.Workaround_Provided_Date__c = system.now();
            }
            
			// NEW!
			if ((cs.Status == 'Returned to Customer' && cs.Rejected_Date__c == null) && (cs.Status != oldMapTrigger.get(cs.Id).Status))
			{
				cs.Rejected_Date__c = system.now();
			}
            
// NEW!
if ((cs.Status == 'Recovered Workaround' && cs.Work_Around_Available__c == false) && (cs.Status != oldMapTrigger.get(cs.Id).Status))
{
	cs.Work_Around_Available__c = true;
}            
            
			// PREVENTS REMOVAL OF "Customer Ticket Number" VALUE
			if (cs.Customer_Ticket_Number__c == null || cs.Customer_Ticket_Number__c == '')
			{
				cs.Customer_Ticket_Number__c = oldMapTrigger.get(cs.Id).Customer_Ticket_Number__c;
			}

			// PREVENTS REMOVAL OF "Customer Ticket System Id" VALUE
			if (cs.INTGR_Customer_Ticket_System_Id__c == null || cs.INTGR_Customer_Ticket_System_Id__c == '')
			{
				cs.INTGR_Customer_Ticket_System_Id__c = oldMapTrigger.get(cs.Id).INTGR_Customer_Ticket_System_Id__c;
			}

			if (cs.Amadeus_External_System_Id__c != null &&
			    winSettings != null &&
			    winSettings.Integration_Username__c != null &&
			    winSettings.Integration_Username__c == UserInfo.getUserName())
			{
				// SET DEFAULT CASE STATUS
				if (setRecordTypes.contains(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByID().get(cs.RecordTypeId).getName()))
				{
					if (cs.status == 'AE')
					{
						cs.Status = 'Pending Problem Resolution';
					}
				}
			}

			if (SNSettings != null)
			{
				if ((setRecordTypes.contains(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByID().get(cs.RecordTypeId).getName()) ||
				     strWorkOrderRecType == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByID().get(cs.RecordTypeId).getName()))
				{
					// IF "W@ Ticket Number" OR "Customer Ticket System Id" HAS A VALUE
					if (cs.Amadeus_External_System_Id__c != null || cs.INTGR_Customer_Ticket_System_Id__c != null)
					{
						if (cs.Status == 'Acknowledged' &&
						    cs.Status != oldMapTrigger.get(cs.Id).Status &&
						    oldMapTrigger.get(cs.Id).Acknowledged__c != null &&                             
                            (SNSettings.Integration_Username__c == UserInfo.getUserName() || isUser_CUSTOMER) && 
                            oldMapTrigger.get(cs.Id).Rejected_Case__c == true)
						    //(SNSettings.Integration_Username__c == UserInfo.getUserName() || (INTGR_IntegrationHelper.uProfileName != null && INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))) &&
						{
							cs.Status = 'Acknowledged';
							cs.Rejected_Case__c = false;
							cs.Reject_Reason_Code__c = '';
						}

						// ADDED BY SHASHIKANT ON 12-04-2017
						// WHEN STATUS CHANGED TO RECOVERED, AND 'REJECTED CASE FLAG' IS 'TRUE' ALREADY, THEN DON'T CHANGE STATUS
						if (cs.Status == 'Recovered' &&
						    cs.Status != oldMapTrigger.get(cs.Id).Status &&
						    oldMapTrigger.get(cs.Id).Rejected_Case__c == true &&
						    (SNSettings.Integration_Username__c == UserInfo.getUserName() || isUser_CUSTOMER))						     
                             //(INTGR_IntegrationHelper.uProfileName != null && INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME)))
						{
							cs.Status = oldMapTrigger.get(cs.Id).Status;
							cs.Resolution_Code__c = oldMapTrigger.get(cs.Id).Resolution_Code__c;
							rec_flag = 1;
							// BYPASS INBOUND CALLS FROM INTEGRATION CASE COMMENTS
							INTGR_IntegrationHelper.isCCFromSC = true;
						}
						else
						{
							if (cs.Status == 'Recovered' &&
							    oldMapTrigger.get(cs.Id).Status == 'Open' &&
							    (SNSettings.Integration_Username__c == UserInfo.getUserName() || isUser_CUSTOMER))	
							     //(INTGR_IntegrationHelper.uProfileName != null && INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME)))
							{
								cs.Status = oldMapTrigger.get(cs.Id).Status;
								cs.Withdrawn_Case__c = True;
								cs.Resolution_Code__c = oldMapTrigger.get(cs.Id).Resolution_Code__c;
								open_flag = 1;
								// BYPASS INBOUND CALLS FROM INTEGRATION CASE COMMENTS
								INTGR_IntegrationHelper.isCCFromSC = true;
							}
							else
							{
								if (cs.Status == 'Recovered' &&
								    cs.Status != oldMapTrigger.get(cs.Id).Status &&
								    oldMapTrigger.get(cs.Id).Acknowledged__c == null  &&
								    (SNSettings.Integration_Username__c == UserInfo.getUserName() || isUser_CUSTOMER))	
								     //(INTGR_IntegrationHelper.uProfileName != null && INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME)))
								{
									cs.Status = oldMapTrigger.get(cs.Id).Status;
									cs.Resolution_Code__c = oldMapTrigger.get(cs.Id).Resolution_Code__c;
									// BYPASS INBOUND CALLS FROM INTEGRATION CASE COMMENTS
									INTGR_IntegrationHelper.isCCFromSC = true;
								}
							}
						}

						// ADDED BY SHASHIKANT ON 12-04-2017
						// WHEN STATUS IS SET MANUALLY, TO 'RETURNED TO CUSTOMER'/'CLOSED AS REJECTED', SET REJECTED CASE FLAG TO TRUE
						if (cs.Rejected_Case__c == false && cs.Status != oldMapTrigger.get(cs.Id).Status &&
						    (cs.Status == 'Returned to Customer' || cs.Status == 'Closed as rejected') &&
						    (SNSettings.Integration_Username__c != UserInfo.getUserName() || isUser_CUSTOMER)) 
                             // (INTGR_IntegrationHelper.uProfileName != null && INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))))
						{
							cs.Rejected_Case__c = true;
							// BYPASS INBOUND CALLS FROM INTEGRATION CASE COMMENTS
							INTGR_IntegrationHelper.isCCFromSC = true;
						}

						// ADDED BY SHASHIKANT ON - 11-30-2017
						// STATUS SHOULD NOT CHNAGE TO 'ACKNOWLEDGED' IF REQUEST COMES FROM SERVICENOW AT FIRST TIME ONLY
						if (cs.Status != oldMapTrigger.get(cs.Id).Status &&
						    oldMapTrigger.get(cs.Id).Acknowledged__c == null &&
						    (SNSettings.Integration_Username__c == UserInfo.getUserName() || isUser_CUSTOMER))	
                             //(INTGR_IntegrationHelper.uProfileName != null && INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))))
						{
							cs.Status = oldMapTrigger.get(cs.Id).Status;
							// BYPASS INBOUND CALLS FROM INTEGRATION CASE COMMENTS
							INTGR_IntegrationHelper.isCCFromSC = true;
						}

						if (cs.Status == 'Acknowledged' &&
						    cs.Status != oldMapTrigger.get(cs.Id).Status &&
						    cs.Acknowledged__c == null)
						{
							cs.Acknowledged__c = Datetime.now();
						}

						if (cs.Status == 'Recovered' && cs.Status != oldMapTrigger.get(cs.Id).Status)
						{
							cs.Resolved_Date_and_Time__c = Datetime.now();
							cs.Diagnosed_Date_and_Time__c = Datetime.now();
						}

						// WHEN THE IHG INTEGRATION USER SENDS A CLOSED STATUS ON A CRS INCIDENT CASE
                        if (cs.Status == 'Closed' &&
                            cs.Status != oldMapTrigger.get(cs.Id).Status &&
                            (SNSettings.Integration_Username__c == UserInfo.getUserName() || isUser_CUSTOMER) && 
                            oldMapTrigger.get(cs.Id).Acknowledged__c != null)
                            //(INTGR_IntegrationHelper.uProfileName != null && INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))) &&
                            
                        {
                            // AND THE REJECT FLAG IS SET TO TRUE, CHANGE THE STATUS TO "Closed as Rejected"
                            if (oldMapTrigger.get(cs.Id).Rejected_Case__c == true)
                            {
                                cs.Status = 'Closed as rejected';
                            }

							// IF THE WITHDRAWN FLAG IS SET TO TRUE, CHANGE THE STATUS TO "Closed as withdrawn"
							if (oldMapTrigger.get(cs.Id).Withdrawn_Case__c == true)
							{
								cs.Status = 'Closed as withdrawn';
							}

							// IF NEITHER THE REJECTED OR WITHDRAWN FLAGS ARE SET TO TRUE AND THE RECOVERED DATE/TIME FIELD IS NOT NULL SET THE CASE STATUS TO "Closed as recovered".
							if (oldMapTrigger.get(cs.Id).Rejected_Case__c == false &&
							    oldMapTrigger.get(cs.Id).Withdrawn_Case__c == false &&
							    oldMapTrigger.get(cs.Id).Resolved_Date_and_Time__c != null)
							{
								cs.Status = 'Closed as recovered';
							}
							// BYPASS INBOUND CALLS FROM INTEGRATION CASE COMMENTS
							INTGR_IntegrationHelper.isCCFromSC = true;
						}

						if (cs.Status == 'Rejected PCP' && cs.Status != oldMapTrigger.get(cs.Id).Status)
						{
							cs.Rejected_Case__c = true;
							cs.Reject_Reason_Code__c = 'Working as Designed';
							PCP_flag = 1;
						}
					}

					if (cs.INTGR_Recovery_Plan__c != oldMapTrigger.get(cs.Id).INTGR_Recovery_Plan__c &&
					    oldMapTrigger.get(cs.Id).INTGR_Recovery_Plan__c == true)
					{
						cs.INTGR_Recovery_Plan__c.addError('Field can not be updated.');
					}

					if (cs.INTGR_Assigned_Recovery_Plan__c != oldMapTrigger.get(cs.Id).INTGR_Assigned_Recovery_Plan__c &&
					    oldMapTrigger.get(cs.Id).INTGR_Assigned_Recovery_Plan__c != null)
					{
						cs.INTGR_Assigned_Recovery_Plan__c.addError('Field can not be updated.');
					}

					if (cs.INTGR_Recovery_Plan_Date_Time__c != oldMapTrigger.get(cs.Id).INTGR_Recovery_Plan_Date_Time__c &&
					    oldMapTrigger.get(cs.Id).INTGR_Recovery_Plan_Date_Time__c != null)
					{
						cs.INTGR_Recovery_Plan_Date_Time__c.addError('Field can not be updated.');
					}

					if (cs.INTGR_Assigned_Recovery_Plan__c != null &&
					    cs.INTGR_Assigned_Recovery_Plan__c != oldMapTrigger.get(cs.Id).INTGR_Assigned_Recovery_Plan__c &&
					    oldMapTrigger.get(cs.Id).INTGR_Assigned_Recovery_Plan__c == null)
					{
						cs.INTGR_Recovery_Plan__c = true;
						cs.INTGR_Recovery_Plan_Date_Time__c = Datetime.now();
					}
				}

				// CHANGE THE PRIORITY VALUE BASED ON CUSTOM SETTING FOR URGENCY
				if ((setRecordTypes.contains(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cs.RecordTypeId).getName()) ||
				     strWorkOrderRecType == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cs.RecordTypeId).getName()) &&
				    cs.Customer_Severity__c != oldMapTrigger.get(cs.Id).Customer_Severity__c)
				{
					// ASSIGNING SEVERITY VALUE FROM CUSTOM SETTING
					sText = cs.Customer_Severity__c;
					sText = sText.replaceAll('\\s+', '_');
					sText = 'X' + sText + '__c';

					try
					{
						// URGENCY
						if (WinaproachIncidentUrgencyMapping__c.getValues('Default').get(sText) != null)
						{
							// ASSIGNING URGENCY VALUE FROM CUSTOM SETTING
							cs.Priority = String.valueOf(WinaproachIncidentUrgencyMapping__c.getValues('Default').get(sText));
						}
					}
					catch(Exception e)
					{
						cs.Priority = 'N';
					}
				}

				// VERIFYING FOR THE CASETEMPLATEFLAG, IT WILL BE TRUE ONLY WHEN CASE TEMPLATE IS CREATED AND DESCRIPTION NEED TO BE UPDATED
				if (NI_WinaproachService.caseTemplateFlag && strWorkOrderRecType == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByID().get(cs.RecordTypeId).getName())
				{
					// APPENDING THE NEW DESCRIPTION ALONG WITH OLD DESCRIPTION
					if (oldMapTrigger.get(cs.Id).Description != null)
					{
						cs.Description = oldMapTrigger.get(cs.Id).Description + '\n--------------------------\n' + cs.Description;
					}

					NI_WinaproachService.caseTemplateFlag = false;
				}
			}
		}

		system.debug(' *** EXITING INTGR_WinSN_Case_Handler.processBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	private void processAfterUpdate(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
	{
		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.processAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

		String strWorkOrderRecType = '';
		Set<Id> snCaseIdSet = new Set<Id>();
		Set<String> setUpdatedFields = new Set<String>();

		List<Case> lstCaseRecordTypes = new List<Case>();
		List<Case> lstCaseIds = new List<Case>();
		List<Case> lstServiceNowCaseIds = new List<Case>();
		List<Case> lstServiceNowCaseInserts = new List<Case>();
		List<CaseComment> lstCaseComments = new List<CaseComment>();
		List<CaseComment> caseComtList = new List<CaseComment>();
		List<CaseComment> lstCaseCommentInserts = new List<CaseComment>();

		Winaproach_Incident_Case_Record_Type__c csRecType = Winaproach_Incident_Case_Record_Type__c.getValues('Default');
		WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
		ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default');
		List<String> lstRecordTypes = String.valueOf(csRecType.Record_Type__c).split(',');
		Set<String> setRecordtypes = new Set<String>(lstRecordTypes);

		// Look for Record type of Work orders
		if (Winaproach_Work_Order_Case_Record_Type__c.getValues('Default') != null && Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c != null)
		{
			strWorkOrderRecType = Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c;
		}

		// LOOP THOUGH ALL CASES IN TRIGGER
		for (Case cs : newTrigger)
		{
			// =====================================================================================================================
			//  CASE COMMENTS
			// =====================================================================================================================

			// IF RECORDTYPE IS CHANGED TO CRS CONSIDER RECORD FOR SENDING REQUEST TO WIN@PROACH
			if (cs.RecordTypeId != oldMapTrigger.get(cs.Id).RecordTypeId)
			{
				if (cs.Amadeus_External_System_Id__c == null &&
				    (setRecordtypes.contains(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cs.RecordTypeId).getName()) ||
				     strWorkOrderRecType == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cs.RecordTypeId).getName()))
				{
					lstCaseRecordTypes.add(cs);
				}
			}

			if (rec_flag == 1)
			{
				CaseComment com = new CaseComment();
				com.commentBody = 'Rejected IR was Recovered by Customer';
				lstCaseComments.add(com);
				com.ParentId = cs.Id;
				lstCaseIds.add(cs);
				setUpdatedFields.add('Reject_Reason_Code__c');
			}

			if (open_flag == 1)
			{
				CaseComment com = new CaseComment();
				com.commentBody = 'Open IR was Recovered by Customer';
				com.ParentId = cs.Id;
				lstCaseComments.add(com);
				lstCaseIds.add(cs);
			}

			if (PCP_flag == 1)
			{
				CaseComment com = new CaseComment();
				com.commentBody = 'This ticket is a PCP for Design Change';
				com.ParentId = cs.Id;
				lstCaseComments.add(com);
				lstCaseIds.add(cs);
			}

			// =====================================================================================================================
			//  CONDITIONALLY BUILD CASE COMMENT BODY
			// =====================================================================================================================
			if (cs.Amadeus_External_System_Id__c != null &&
			    ((cs.Status != oldMapTrigger.get(cs.Id).Status) ||
			     (cs.Customer_Severity__c != oldMapTrigger.get(cs.Id).Customer_Severity__c) ||
			     (cs.Amadeus_ExternalSystemAssigneeGroup__c != oldMapTrigger.get(cs.Id).Amadeus_ExternalSystemAssigneeGroup__c)) ||
				 (cs.Work_Around_Available__c != oldMapTrigger.get(cs.Id).Work_Around_Available__c) ||
				 (cs.Workaround_Provided_Date__c != oldMapTrigger.get(cs.Id).Workaround_Provided_Date__c) || 
				 (cs.Workaround_Rejected_Date__c != oldMapTrigger.get(cs.Id).Workaround_Rejected_Date__c) || 
				 (cs.IsOperationalIssue__c != oldMapTrigger.get(cs.Id).IsOperationalIssue__c))
			{
				if (setRecordtypes.contains(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByID().get(cs.RecordTypeId).getName()))
				{
					CaseComment com = new CaseComment();
					String commentBody = '';
					com.ParentId = cs.Id;

					if (cs.Status != oldMapTrigger.get(cs.Id).Status)
					{
						commentBody += 'Changed Case Status from ' + oldMapTrigger.get(cs.Id).Status + ' to ' + cs.Status + '. \n';
						if (cs.Status != 'Rejected PCP')
						{
							setUpdatedFields.add('status');
						}
					}

					if (cs.Customer_Severity__c != oldMapTrigger.get(cs.Id).Customer_Severity__c)
					{
						commentBody += 'Changed Case Severity from ' + oldMapTrigger.get(cs.Id).Customer_Severity__c + ' to ' + cs.Customer_Severity__c + '. \n';
					}

                    // NEW! 
                    if (cs.Work_Around_Available__c != oldMapTrigger.get(cs.Id).Work_Around_Available__c)
                    {

						if (cs.Work_Around_Available__c)
						{
							commentBody += 'Changed Work Around Available to True \n';
						}
						else 
						{
							commentBody += 'Changed Work Around Available to False \n';
						}

						setUpdatedFields.add('Work_Around_Available__c');

                    }                      

					// NEW! 
					if (cs.Workaround_Provided_Date__c != oldMapTrigger.get(cs.Id).Workaround_Provided_Date__c)
					{
						
						Datetime dtOld1 = oldMapTrigger.get(cs.Id).Workaround_Provided_Date__c;
						Datetime dtNew1 = cs.Workaround_Provided_Date__c;
												
						String sDispOld1 = 'null';
						String sDispNew1 = 'null';
						
						if (dtOld1 != null)
						{
							sDispOld1 = dtOld1.format('M/dd/yyyy h:mm a');
						} 

						if (dtNew1 != null)
						{
							sDispNew1 = dtNew1.format('M/dd/yyyy h:mm a');
						}
						
						commentBody += 'Changed Work Around Provided Date from ' + sDispOld1 + ' to ' + sDispNew1 + ' \n';

					}

					// NEW! 
					if (cs.Workaround_Rejected_Date__c != oldMapTrigger.get(cs.Id).Workaround_Rejected_Date__c)
					{
						
						Datetime dtOld2 = oldMapTrigger.get(cs.Id).Workaround_Rejected_Date__c;
						Datetime dtNew2 = cs.Workaround_Rejected_Date__c;

						String sDispOld2 = 'null';
						String sDispNew2 = 'null';
						
						if (dtOld2 != null)
						{
							sDispOld2 = dtOld2.format('M/dd/yyyy h:mm a');
						} 
						
						if (dtNew2 != null)
						{
							sDispNew2 = dtNew2.format('M/dd/yyyy h:mm a');
						}

						commentBody += 'Changed Work Around Rejected Date from ' + sDispOld2 + ' to ' + sDispNew2 + ' \n';

					}     

					// NEW!
					if (cs.IsOperationalIssue__c != oldMapTrigger.get(cs.Id).IsOperationalIssue__c)
                    {

						if (cs.IsOperationalIssue__c)
						{
							commentBody += 'Changed Operational Issue to True \n';
						}
						else 
						{
							commentBody += 'Changed Operational Issue to False \n';
						}

						setUpdatedFields.add('IsOperationalIssue__c');

                    }                    

					// NICC-030216 (START)
					// Added by Princy for comment logging for Assignment Group Change
					if (cs.Amadeus_ExternalSystemAssigneeGroup__c != oldMapTrigger.get(cs.Id).Amadeus_ExternalSystemAssigneeGroup__c)
					{
						commentBody += 'Changed Case Assignment Group from ' + oldMapTrigger.get(cs.Id).Amadeus_ExternalSystemAssigneeGroup__c + ' to ' + cs.Amadeus_ExternalSystemAssigneeGroup__c + '. \n';
					}
					// NICC-030216 (END)

					if (UserInfo.getUserId() == cs.LastModifiedById)
					{
						commentBody += 'Modified By ' + userInfo.getName() + ' (' + String.valueOfGmt(Datetime.now()) + ' GMT ) \n';
					}

					com.CommentBody = commentBody;
					lstCaseComments.add(com);

					if (cs.Acknowledged__c != oldMapTrigger.get(cs.Id).Acknowledged__c)
					{
						setUpdatedFields.add('Acknowledged__c');
					}

					system.debug(' **** commentBody = ' + commentBody);
				}
			}

			// =====================================================================================================================
			//  WIN@PROACH CALLOUT
			// =====================================================================================================================

			// FOR CRS INCIDENT RECORD TYPE AND SENDING UPDATE TO WinaproachService
			if (NI_WinaproachService.taskFlag == false && (cs.Amadeus_External_System_Id__c != null && (
									       (cs.Amadeus_ExternalSystemAssigneeGroup__c != oldMapTrigger.get(cs.Id).Amadeus_ExternalSystemAssigneeGroup__c) || 
									       (cs.Winaproach_Logger__c != oldMapTrigger.get(cs.Id).Winaproach_Logger__c) || 
									       (cs.Description != oldMapTrigger.get(cs.Id).Description) || 
									       (cs.AssetId != oldMapTrigger.get(cs.Id).AssetId) || 
									       (cs.Cause_Id_Code__c != oldMapTrigger.get(cs.Id).Cause_Id_Code__c) || 
									       (cs.Resolution_Code__c != oldMapTrigger.get(cs.Id).Resolution_Code__c) || 
									       (cs.Reject_Reason_Code__c != oldMapTrigger.get(cs.Id).Reject_Reason_Code__c) || 
									       (cs.Winaproach_Logger_Phone_Number__c != oldMapTrigger.get(cs.Id).Winaproach_Logger_Phone_Number__c) || 
									       (cs.Acknowledged__c != oldMapTrigger.get(cs.Id).Acknowledged__c && cs.Status == oldMapTrigger.get(cs.Id).Status) || 
									       (cs.Winaproach_Owner_Group__c != oldMapTrigger.get(cs.Id).Winaproach_Owner_Group__c) || 
									       (cs.Incident_Start_Date_Time__c != oldMapTrigger.get(cs.Id).Incident_Start_Date_Time__c) || 
									       (cs.Resolved_Date_and_Time__c != oldMapTrigger.get(cs.Id).Resolved_Date_and_Time__c) || 
									       (cs.Diagnosed_Date_and_Time__c != oldMapTrigger.get(cs.Id).Diagnosed_Date_and_Time__c) || 
									       (cs.Amadeus_ExternalSystemLoggerGroup__c != oldMapTrigger.get(cs.Id).Amadeus_ExternalSystemLoggerGroup__c) || 
									       (cs.ParentId != oldMapTrigger.get(cs.Id).ParentId) || 
									       (cs.OwnerId != oldMapTrigger.get(cs.Id).OwnerId) || 
									       (cs.System_Affected__c != oldMapTrigger.get(cs.Id).System_Affected__c) || 
									       (cs.Hotel_Code__c != oldMapTrigger.get(cs.Id).Hotel_Code__c) || 
										   (cs.Work_Around_Available__c != oldMapTrigger.get(cs.Id).Work_Around_Available__c) || 
										   (cs.IsOperationalIssue__c != oldMapTrigger.get(cs.Id).IsOperationalIssue__c) || 
										   (cs.Rejected_Date__c != oldMapTrigger.get(cs.Id).Rejected_Date__c) || 
									       (cs.INTGR_Recovery_Plan_Date_Time__c != oldMapTrigger.get(cs.Id).INTGR_Recovery_Plan_Date_Time__c))))
			{
				if (setRecordtypes.contains(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByID().get(cs.RecordTypeId).getName()))
				{
					if (cs.Amadeus_ExternalSystemAssigneeGroup__c != oldMapTrigger.get(cs.Id).Amadeus_ExternalSystemAssigneeGroup__c)
					{
						setUpdatedFields.add('Amadeus_ExternalSystemAssigneeGroup__c');
					}

					if (cs.Winaproach_Logger__c != oldMapTrigger.get(cs.Id).Winaproach_Logger__c)
					{
						setUpdatedFields.add('Winaproach_Logger__c');
					}

					if (cs.Description != oldMapTrigger.get(cs.Id).Description)
					{
						setUpdatedFields.add('Description');
					}

					if (cs.AssetId != oldMapTrigger.get(cs.Id).AssetId)
					{
						setUpdatedFields.add('AssetId');
					}

					if (cs.Cause_Id_Code__c != oldMapTrigger.get(cs.Id).Cause_Id_Code__c)
					{
						setUpdatedFields.add('Cause_Id_Code__c');
					}

					if (cs.Resolution_Code__c != oldMapTrigger.get(cs.Id).Resolution_Code__c)
					{
						setUpdatedFields.add('Resolution_Code__c');
					}

					if (cs.Reject_Reason_Code__c != oldMapTrigger.get(cs.Id).Reject_Reason_Code__c)
					{
						setUpdatedFields.add('Reject_Reason_Code__c');
					}

					if (cs.Winaproach_Logger_Phone_Number__c != oldMapTrigger.get(cs.Id).Winaproach_Logger_Phone_Number__c)
					{
						setUpdatedFields.add('Winaproach_Logger_Phone_Number__c');
					}

					if (cs.Acknowledged__c != oldMapTrigger.get(cs.Id).Acknowledged__c)
					{
						setUpdatedFields.add('Acknowledged__c');
					}

					if (cs.Winaproach_Owner_Group__c != oldMapTrigger.get(cs.Id).Winaproach_Owner_Group__c)
					{
						Map<String, Winaproach_Owner_Group__c> mapOwnerGrp = Winaproach_Owner_Group__c.getAll();
						if (mapOwnerGrp.containsKey(cs.Winaproach_Owner_Group__c))
						{
							setUpdatedFields.add('Winaproach_Owner_Group__c');
						}
					}

					if (cs.Incident_Start_Date_Time__c != oldMapTrigger.get(cs.Id).Incident_Start_Date_Time__c)
					{
						setUpdatedFields.add('Incident_Start_Date_Time__c');
					}

					// Adding resolved date and time
					if (cs.Resolved_Date_and_Time__c != oldMapTrigger.get(cs.Id).Resolved_Date_and_Time__c)
					{
						setUpdatedFields.add('Resolved_Date_and_Time__c');
					}

					if (cs.Diagnosed_Date_and_Time__c != oldMapTrigger.get(cs.Id).Diagnosed_Date_and_Time__c)
					{
						setUpdatedFields.add('Diagnosed_Date_and_Time__c');
					}

					if (cs.Amadeus_ExternalSystemLoggerGroup__c != oldMapTrigger.get(cs.Id).Amadeus_ExternalSystemLoggerGroup__c)
					{
						setUpdatedFields.add('Amadeus_ExternalSystemLoggerGroup__c');
					}

					if (cs.OwnerId != oldMapTrigger.get(cs.Id).OwnerId)
					{
						setUpdatedFields.add('OwnerId');
					}

					if (cs.ParentId != oldMapTrigger.get(cs.Id).ParentId)
					{
						setUpdatedFields.add('master_record_number');
					}

					if (cs.System_Affected__c != oldMapTrigger.get(cs.Id).System_Affected__c)
					{
						setUpdatedFields.add('System_Affected__c');
					}

					if (cs.Hotel_Code__c != oldMapTrigger.get(cs.Id).Hotel_Code__c) //ADDED 10/5/2017 PER NICC-024188
					{
						setUpdatedFields.add('Hotel_Code__c');
					}

					if (cs.INTGR_Recovery_Plan_Date_Time__c != oldMapTrigger.get(cs.Id).INTGR_Recovery_Plan_Date_Time__c &&
					    cs.INTGR_Recovery_Plan_Date_Time__c != null)
					{
						setUpdatedFields.add('INTGR_Recovery_Plan_Date_Time__c');
					}

                    // NEW! 
                    if (cs.Work_Around_Available__c != oldMapTrigger.get(cs.Id).Work_Around_Available__c)
                    {
                        setUpdatedFields.add('Work_Around_Available__c');
                    }   

					// NEW!
					if (cs.IsOperationalIssue__c != oldMapTrigger.get(cs.Id).IsOperationalIssue__c)
                    {
                        setUpdatedFields.add('IsOperationalIssue__c');
                    } 

					// NEW!
					if (cs.Rejected_Date__c != null && (cs.Rejected_Date__c != oldMapTrigger.get(cs.Id).Rejected_Date__c))
                    {
                        setUpdatedFields.add('Rejected_Date__c');
                    } 

					Case csobj = new Case();
					csobj.Id = cs.Id;

					if (setUpdatedFields.size() > 0)
					{
						lstCaseIds.add(csobj);
					}
				}
			}

			// For CRS Work order record type
			if (NI_WinaproachService.taskFlag == false &&
			    (cs.Amadeus_External_System_Id__c != null) &&
			    (strWorkOrderRecType != '') &&
			    (strWorkOrderRecType == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cs.RecordTypeId).getName()) &&
			    (cs.Description != oldMapTrigger.get(cs.Id).Description || cs.Status != oldMapTrigger.get(cs.Id).Status || cs.Acknowledged__c != oldMapTrigger.get(cs.Id).Acknowledged__c))
			{
				if (cs.Description != oldMapTrigger.get(cs.Id).Description)
				{
					setUpdatedFields.add('Description');
				}

				if (cs.Status != oldMapTrigger.get(cs.Id).Status)
				{
					setUpdatedFields.add('Status');
				}

				Case csobj = new Case();
				csobj.Id = cs.Id;
				lstCaseIds.add(csobj);
			}

			// =====================================================================================================================
			//  IHG SERVICE NOW CALLOUT
			// =====================================================================================================================
			String SNRecordType = '';

			if (SNSettings != null)
			{
				//FILTER SERVICENOW RECORDS FOR INTEGRATION
				SNRecordType = SNSettings.ServiceNow_Incident_Case_Record_Type__c;

				// IF CASE IS CREATED BY SERVICENOW USER OR Integration_Sync_Status__c == TRUE THEN CREATE LIST TO SEND REQUEST TO SERVICENOW
				if (SNSettings.Integration_UserId__c != null &&
				    (cs.CreatedById == SNSettings.Integration_UserId__c || cs.Integration_Sync_Status__c == true) &&
				    cs.Customer_Ticket_Number__c != null &&
				    cs.Integration_Sync_Status__c == true &&
				    SNRecordType == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByID().get(cs.RecordTypeId).getName())
				{
					if (ServiceNow_Incident_Status_Mapping__c.getValues(cs.Status) != null &&
					    cs.Status != oldMapTrigger.get(cs.Id).Status &&
					    cs.Status != 'Rejected PCP')
					{
						setUpdatedFields.add('status');
                        
					}

					if (cs.Assignment_Group__c != oldMapTrigger.get(cs.Id).Assignment_Group__c)
					{
						setUpdatedFields.add('Assignment_Group__c');
					}

					if (cs.Customer_Severity__c != oldMapTrigger.get(cs.Id).Customer_Severity__c)
					{
						setUpdatedFields.add('Customer_Severity__c');
					}

					if (cs.subject != oldMapTrigger.get(cs.Id).subject)
					{
						setUpdatedFields.add('subject');
					}

					if (cs.Description != oldMapTrigger.get(cs.Id).Description)
					{
						setUpdatedFields.add('description');
					}

					if (cs.INTGR_Recovery_Plan_Date_Time__c != oldMapTrigger.get(cs.Id).INTGR_Recovery_Plan_Date_Time__c)
					{
						setUpdatedFields.add('INTGR_Recovery_Plan_Date_Time__c');
					}

                    // NEW! 
                    if (cs.Work_Around_Available__c != oldMapTrigger.get(cs.Id).Work_Around_Available__c)
                    {
                        setUpdatedFields.add('Work_Around_Available__c');
                    }   

					// NEW!
					if (cs.IsOperationalIssue__c != oldMapTrigger.get(cs.Id).IsOperationalIssue__c)
                    {
                        setUpdatedFields.add('IsOperationalIssue__c');
                    } 

					// Add case into list
					if (!setUpdatedFields.isEmpty())
					{
						lstServiceNowCaseIds.add(cs);
					}
				}
			}

			system.debug('*^* SNRecordType=' + SNRecordType + ', INTGR_Create_Ticket_in_Customer_System__c=' + cs.INTGR_Create_Ticket_in_Customer_System__c + ', INTGR_Customer_Ticket_System_Id__c=' + cs.INTGR_Customer_Ticket_System_Id__c + ', Customer_Ticket_Number__c=' + cs.Customer_Ticket_Number__c);

			if (SNRecordType != null &&
			    SNRecordType != '' &&
			    SNRecordType == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByID().get(cs.RecordTypeId).getName() &&
			    oldMapTrigger.get(cs.Id).INTGR_Create_Ticket_in_Customer_System__c != cs.INTGR_Create_Ticket_in_Customer_System__c &&
			    cs.INTGR_Create_Ticket_in_Customer_System__c == true &&
			    (cs.INTGR_Customer_Ticket_System_Id__c == null || cs.INTGR_Customer_Ticket_System_Id__c == '') &&
			    (cs.Customer_Ticket_Number__c == null || cs.Customer_Ticket_Number__c == ''))
			{
				lstServiceNowCaseInserts.add(cs);
			}

			if (NI_ServicenowIntegration.updateAttCaseCmtSN == true &&
			    cs.Customer_Ticket_Number__c != null &&
			    cs.INTGR_Customer_Ticket_System_Id__c != null)
			{
				snCaseIdSet.add(cs.Id);
				NI_ServicenowIntegration.updateAttCaseCmtSN = false;
			}

			// ADDED BY RIA - 10/20 - TO CREATE CASECOMMENT ON CASE PER PROJECT BACKLOG: CRS Case Support - Recovery Plan Sev 3/4
			if (cs.INTGR_Assigned_Recovery_Plan__c != null &&
			    cs.INTGR_Assigned_Recovery_Plan__c != oldMapTrigger.get(cs.Id).INTGR_Assigned_Recovery_Plan__c)
			{
				CaseComment cc = new CaseComment();
				cc.ParentId = cs.Id;
				String ccBody = '';

				if (cs.INTGR_Assigned_Recovery_Plan__c.contains('Functional'))
				{
					ccBody = Label.SEVERITY_FUNCTIONAL;
					cc.CommentBody = ccBody;
				}

				if (cs.INTGR_Assigned_Recovery_Plan__c.contains('Technical'))
				{
					ccBody = Label.SEVERITY_TECHNICAL;
					cc.CommentBody = ccBody;
				}

				lstCaseCommentInserts.add(cc);
			}
		}

		system.debug('*^* winSettings = ' + winSettings);
		system.debug('*^* lstCaseRecordTypes.size() = ' + lstCaseRecordTypes.size());

		if (winSettings != null)
		{
			if (winSettings.Integration_Username__c != null &&
			    winSettings.Integration_Username__c != UserInfo.getUserName() &&
			    lstCaseRecordTypes.size() > 0)
			{
				system.debug('*^* Calling External Win@proach web service ');
				NI_WinaproachService niWin = new NI_WinaproachService('Create', lstCaseRecordTypes);
			}

			if (winSettings.Integration_Username__c != null &&
			    winSettings.Integration_Username__c != UserInfo.getUserName() &&
			    lstCaseIds.size() > 0 &&
			    (!NI_WinaproachService.crsCaseIncidentFlag))
			{
				system.debug('*^* Call Win@proach Update Request using future callout and also benefit of higher limit instead of trigger context ');
				// Call Win@proach Update Request using future callout and also benefit of higher limit instead of trigger context
				// NI_WinaproachService.sendUpdateRequestToWinaproach(lstCaseIds, 'Case');
				NI_WinaproachService.crsCaseIncidentFlag = true;
				NI_WinaproachService.createActionLogOrAttachment(lstCaseIds, setUpdatedFields);
			}
		}

		system.debug('*^* lstServiceNowCaseInserts = ' + lstServiceNowCaseInserts);

		if (!lstServiceNowCaseInserts.isEmpty())
		{
			NI_ServicenowIntegration.updateIncidents(lstServiceNowCaseInserts, setUpdatedFields);
		}

		if (!snCaseIdSet.isEmpty())
		{
			Id jobId = System.enqueueJob(new AH_QueuableServiceNowClass(snCaseIdSet));
		}

		if (!lstServiceNowCaseIds.isEmpty())
		{
			// Call to Servicenow Integration function
			NI_ServicenowIntegration.updateIncidents(lstServiceNowCaseIds, setUpdatedFields);
		}

		system.debug(' **** NI_WinaproachService.caseCommentFlag = ' + NI_WinaproachService.caseCommentFlag);
		system.debug(' **** NI_WinaproachService.caseFieldsForComments = ' + NI_WinaproachService.caseFieldsForComments);
		system.debug(' **** INTGR_IntegrationHelper.isCCFromSC = ' + INTGR_IntegrationHelper.isCCFromSC);

		if (!NI_WinaproachService.caseCommentFlag)
		{
			if (lstCaseComments.size() > 0)
			{
				NI_WinaproachService.caseCommentFlag = true;
				NI_WinaproachService.caseFieldsForComments = new List<String>(setUpdatedFields);
				// TO BYPASS INBOUND CALLS FROM INTEGRATION CASE COMMENTS
				//if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
				if (isUser_CUSTOMER)
                {
					INTGR_IntegrationHelper.isCCFromSC = true;
				}
				insert lstCaseComments;
			}
		}

		if (!lstCaseCommentInserts.isEmpty())
		{
			// TO BYPASS INBOUND CALLS FROM INTEGRATION CASE COMMENTS
			//if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
			if (isUser_CUSTOMER)
            {
				INTGR_IntegrationHelper.isCCFromSC = true;
			}
			insert lstCaseCommentInserts;
		}

		system.debug(' *** EXITING INTGR_WinSN_Case_Handler.processAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	private void processICAfterSCUpdate(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
	{
		// NICC-030216 NEXT PROJECT PROCESS INTEGRATION CASE AFTER STANDARD CASE UPDATE

		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.processICAfterSCUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

		// changes for SF to SN Integration
		Map<Id, Case> caseObListTobeProcessedMap = new Map<Id, Case>();
//		Set<String> fieldsChangedSet = new set<String>();

		for (Case caseObj : newTrigger)
		{
			// TO PUT A CHECK ON Integration_Sync_Status__c FOR OUTBOUND CALLS
			if (caseObj.Update_External_System__c != null && caseObj.Update_External_System__c == true)
			{
				// TO CHECK IF NONE OF SC FIELDS ARE CHANGED THEN NO NEED TO TRIGGER UPDATE
				caseObListTobeProcessedMap.put(caseObj.Id, caseObj);
			}
		}

		if (caseObListTobeProcessedMap.size() > 0 && !bpSwitch.ByPassServiceNowIntegration_ON__c && !INTGR_IntegrationHelper.isICFlow)
		{
			INTGR_IntegrationHelper.upsertIntegrationCase(caseObListTobeProcessedMap, false, true, oldMapTrigger);
		}

		//if (caseObListTobeProcessedMap.size() > 0 && INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
		if (caseObListTobeProcessedMap.size() > 0 && isUser_CUSTOMER)
		{
			INTGR_IntegrationHelper.upsertIntegrationCase(caseObListTobeProcessedMap, false, true, oldMapTrigger);
		}

		system.debug(' *** EXITING INTGR_WinSN_Case_Handler.processICAfterSCUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	private void setClosedCaseCheckboxes(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
	{
		// Rejected Case:
		//  1) When a user manually sets a CRS incident to rejected, set the rejected case flag to true. (Rejected_Case__c)
		//  2) Add a validation rule that will not allow the user to save the change without a rejected reason code. (Reject_Reason_Code__c)
		//  3) Send the rejected reason code to Win@prch (Reject_Reason_Code__c)
		//
		// Rejected Case:
		//  1) When an inbound RECOVERED STATUS update from ServiceNow (IHG Integration User) is received, AND the reject case flag is set to true:
		//     A) Insert a case comment "Rejected IR was Recovered by Customer"
		//     B) DO NOT update the case status in Salesforce
		//     C) Send the Rejected Reason Code (Reject_Reason_Code__c) value to Win@prch
		//  2) When ServiceNow (IHG Integration User) updates status to Acknowledged and Reject Case Flag = true.
		//     A) Change status to "Acknowledged"
		//     B) Set the Reject Case flag to false
		//     C) Set the Reject Reason Code (Reject_Reason_Code__c) Value to NULL / blank
		//     D) Send the null reason code value to Win@prchOpen
		//
		// Cases:
		//  1) When Salesforce Status = "OPEN" and ServiceNow (IHG Integration User) sends a "Recovered" status update.
		//     A) Insert a case comment: "Open IR was Recovered by Customer"
		//     B) DO NOT update the case in Salesforce
		//     C) Set the Withdrawn Case Flag = True (Withdrawn_Case__c)

		// set Case Object Flags when status comes as Closed as Rejected or Closed as withdrawn

		system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.setClosedCaseCheckboxes() - QUERIES ISSUED = ' + Limits.getQueries());

		for (Case obj : newTrigger)
		{
			if (obj.Status.equalsIgnoreCase('Closed as rejected'))
			{
				obj.Rejected_Case__c = true;
			}

//			if (obj.Status.equalsIgnoreCase('Recovered') && oldMapTrigger.get(obj.Id).Status.equalsIgnoreCase('Open')) // || oldMapTrigger.get(obj.Id).Status.equalsIgnoreCase ('Acknowledged'))
//			{
//				obj.Rejected_Case__c = true;
//			}

			if (obj.Status.equalsIgnoreCase('Closed as withdrawn'))
			{
				obj.Withdrawn_Case__c = true;
			}

			// ONLY EXECUTE WHEN USER IS AN INTEGRATION USER
			//if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME) &&
			//    UserInfo.getProfileId() == '00e320000016C5YAAU') // ID FOR "IHG Integration Only - Standard" PROFILE
			if (!isUser_INTERNAL)
            {
				// CASE WITHDRAWN AND REJECTED FLAG SETTINGS
				if (oldMapTrigger.get(obj.Id).Status.equalsIgnoreCase('Acknowledged') && obj.Status.equalsIgnoreCase('Open'))
				{
					obj.Withdrawn_Case__c = true;
				}

				if (oldMapTrigger.get(obj.Id).Status.equalsIgnoreCase('Acknowledged') && obj.Status.equalsIgnoreCase('Recovered'))
				{
					obj.Rejected_Case__c = true;
				}
			}
		}

		system.debug(' *** EXITING INTGR_WinSN_Case_Handler.setClosedCaseCheckboxes() - QUERIES ISSUED = ' + Limits.getQueries());
	}
    
}