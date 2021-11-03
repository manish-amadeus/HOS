/************************************************************************************************
                                !!! INTEGRATION CLASS - DO NOT ALTER !!!
*************************************************************************************************
Name            : INTGR_PublishSFCaseController
Author          : Princy Jain
Created Date    : 04/23/2018
Last Mod Date   : 01/14/2019
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Class which will interact with Integration layer to create incident in customer system.
                :
************************************************************************************************/
public class INTGR_PublishSFCaseController
{
	// PUBLIC VARIABLES
	public Case c {get; set;}
	// COLECTIONS
	public List<csComment> lstComments {get; set;}
	public List<contentVers> lstFiles {get; set;}
	public List<csComment> lstCommentsSelected {get; set;}
	public List<contentVers> lstFilesSelected {get; set;}
	// STRINGS
	public string customerName {get; set;}
	public string extIntegrationName {get; set;}
	public string extIntegrationSysName {get; set;}
	public string strSubmitMsg {get; set;}
	public String toastMsg {get; set;}
	// BOOLEANS
	public boolean hasCustomerData {get; set;}
	public boolean isLegacy {get; set;}
	public Boolean checkAllComments {get; set;}
	public Boolean checkAllFiles {get; set;}
	public Boolean isSuccess {get; set;}
	public Boolean displayDialog1 {get; set;}
	public Boolean displayDialog2 {get; set;}
	// NUMERICS
	public integer iSelCCmtCount {get; set;}
	public integer iSelFileCount {get; set;}

	// PRIVATE VARIABLES
	private Id AccountId;
	private string caseId;
	private Map<Id, Case> idVsCaseObjMap;


	public INTGR_PublishSFCaseController()
	{
		system.debug(' *** ENTERING INTGR_PublishSFCaseController - CONTROLLER - QUERIES ISSUED = ' + Limits.getQueries());

		try
		{
			if (ApexPages.CurrentPage().getParameters().containsKey('id'))
			{              
				initVariables();
				if (!caseIsValid())
				{
					// hasCustomerData = false;
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'This case is integrated with the customer\'s system already.'));
				}
			}
			else
			{                 
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Case Id not found in URL parameter.'));
			}
		}
		catch(system.Exception ex)
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getLineNumber() + ': ' + ex.getMessage()));
		}

		system.debug(' *** EXITING INTGR_PublishSFCaseController - CONTROLLER - QUERIES ISSUED = ' + Limits.getQueries());
	}

	// ================================================================================================================================
	//  FUNCTIONS & METHODS
	// ================================================================================================================================
	private boolean caseIsValid()
	{
		boolean bIsValid = true;

		// DO OUTBOUND BASED ON INTEGRATION CONTEXT
		if (isLegacy)
		{
			string strId = '';
			string strNumber = '';

			if (c.INTGR_Customer_Ticket_System_Id__c != null)
			{
				strId = c.INTGR_Customer_Ticket_System_Id__c;
			}

			if (c.Customer_Ticket_Number__c != null)
			{
				strNumber = c.Customer_Ticket_Number__c;
			}

			if (strId != '' || strNumber != '')
			{
				bIsValid = false;
			}
		}
		else
		{
			List<INTGR_Case__c> lstIntgrCase = new List<INTGR_Case__c>([SELECT Id FROM INTGR_Case__c WHERE Case__c = : c.Id]);
			if (lstIntgrCase.size() > 0)
			{
				bIsValid = false;
			}
		}

		return bIsValid;
	}

	private void initVariables()
	{
		isSuccess = false;
		displayDialog2 = false;
		displayDialog2 = false;
		hasCustomerData = false;
		isLegacy = false;
		AccountId = null;
		caseId = apexpages.currentpage().getparameters().get('id');
		iSelCCmtCount = 0;
		iSelFileCount = 0;
		lstComments = new List<csComment>();
		lstFiles = new List<contentVers>();

		// GET CASE RECORD
		c = [SELECT Id, CaseNumber, Subject, AccountId, Owner.Name, Customer_Ticket_Number__c, INTGR_Customer_Ticket_System_Id__c FROM Case WHERE Id =: caseId];

		// GET ALL CASE COMMENTS FOR CASE
		for (CaseComment csc : [SELECT Id, CreatedDate, CreatedBy.Name, CommentBody
		                        FROM CaseComment
		                        WHERE ParentId = : caseId
		                                         ORDER BY CreatedDate ASC])
		{
			csComment nwCC = new csComment(csc, false);
			lstComments.add(nwCC);
		}

		// GET ALL FILES FOR CASE
		Set<Id> setDocIds = new Set<Id>();
		for (ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : caseId])
		{
			setDocIds.add(cdl.ContentDocumentId);
		}

        for (ContentVersion cvr : [SELECT Id, ContentDocumentId, FileType, Description, ContentSize, Title, CreatedDate, LastModifiedDate,
                                   CreatedBy.Name
                                   FROM ContentVersion
                                   WHERE IsLatest = true
                                   AND ContentDocumentId IN : setDocIds
                                   ORDER BY LastModifiedDate DESC])
        {
            contentVers nwCV = new contentVers(cvr, false);
            lstFiles.add(nwCV);
        }

		// SERVICE NOW CUSTOM SETTING
		ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default');

		if (SNSettings != null && SNSettings.AccountId__c != null)
		{
			AccountId = (Id)SNSettings.AccountId__c;
		}

		idVsCaseObjMap = INTGR_Case_SOQLDataProvider.getSCdetailsToInsertIC(caseId);

		// TO DISPLAY INTGR ACCOUNT DETAILS ON VF PAGE
		if ((Id)idVsCaseObjMap.get(CaseId).AccountId == AccountId)
		{
			customerName = idVsCaseObjMap.get(CaseId).Account_Name__c;
			extIntegrationName = 'IHG';
			extIntegrationSysName = 'ServiceNow';
			hasCustomerData = true;
			isLegacy = true;
			// ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.AH_IntegrationAccountExist));
		}
		else
		{
			populateIntegrationFields();
		}
	}

	public void populateIntegrationFields()
	{
		// Author: Princy Jain
		// Date: 04/23/2018
		// Description: Populates customer information to be displayed on UI

		system.debug(' *** ENTERING INTGR_PublishSFCaseController.populateIntegrationFields() - QUERIES ISSUED = ' + Limits.getQueries());

		List<INTGR_Account__c> integrationAccList = new List<INTGR_Account__c>();

		if (idVsCaseObjMap.size() > 0)
		{
			integrationAccList = INTGR_Case_SOQLDataProvider.getAccountConnectionDetails(idVsCaseObjMap.get(CaseId).AccountId);
		}

		// FOR ERROR MSG ON CASE PUBLISH VF PAGE
		if (integrationAccList.isEmpty())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.AH_IntegrationAccountNotExist));
		}
		else
		{
			// FOR CUSTOMER DETAILS AND WARNING MSG ON CASE PUBLISH VF PAGE
			for (INTGR_Account__c accObj : integrationAccList)
			{
				hasCustomerData = true;
				if (accObj.Name != null)
				{
					customerName = accObj.Name;
				}
				if (accObj.External_Integration_Name__c != null)
				{
					extIntegrationName = accObj.External_Integration_Name__c;
				}
				if (accObj.External_Integration_System_Name__c != null)
				{
					extIntegrationSysName = accObj.External_Integration_System_Name__c;
				}
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.AH_IntegrationAccountExist));
			}
		}

		system.debug(' *** EXITING INTGR_PublishSFCaseController.populateIntegrationFields() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	// ================================================================================================================================
	//  BUTTON METHODS
	// ================================================================================================================================
	public void doSubmit()
	{
		displayDialog1 = true;
		iSelCCmtCount = 0;
		iSelFileCount = 0;
		lstCommentsSelected = new List<csComment>();
		lstFilesSelected = new List<contentVers>();

		if (lstComments.size() > 0)
		{
			for (csComment c : lstComments)
			{
				if (c.bIsChecked)
				{
					iSelCCmtCount += 1;
					lstCommentsSelected.add(c);
				}
			}
		}

		if (lstFiles.size() > 0)
		{
			for (contentVers f : lstFiles)
			{
				if (f.bIsChecked)
				{
					iSelFileCount += 1;
					lstFilesSelected.add(f);
				}
			}
		}
	}

	public PageReference doCancel()
	{
		PageReference pageRef = new PageReference('/' + caseId);
		return pageRef;
	}

	public void doCheckComments()
	{
		if (lstComments.size() > 0)
		{
			for (csComment c : lstComments)
			{
				c.bIsChecked = checkAllComments;
			}
		}
		countSelected();
	}

	public void doCheckFiles()
	{
		if (lstFiles.size() > 0)
		{
			for (contentVers f : lstFiles)
			{
				f.bIsChecked = checkAllFiles;
			}
		}
		countSelected();
	}

	public void countSelected()
	{
		iSelCCmtCount = 0;
		iSelFileCount = 0;

		if (lstComments.size() > 0)
		{
			for (csComment c : lstComments)
			{
				if (c.bIsChecked)
				{
					iSelCCmtCount += 1;
				}
			}
		}

		if (lstFiles.size() > 0)
		{
			for (contentVers f : lstFiles)
			{
				if (f.bIsChecked)
				{
					iSelFileCount += 1;
				}
			}
		}
	}

	// ================================================================================================================================
	//  DIALOG METHODS
	// ================================================================================================================================
//	public void showDialog1()
//	{
//		isSuccess = false;
//
//		displayDialog1 = true;
//	}

	public void hideDialog1()
	{
		displayDialog1 = false;
		isSuccess = false;
		toastMsg = '';
	}

	public PageReference hideDialog2()
	{
		PageReference pageRef = new PageReference('/' + caseId);
		return pageRef;
	}

	public void submitDialog1()
	{
		displayDialog1 = false;
		displayDialog2 = true;
		toastMsg = '';
		strSubmitMsg = '';

		// GATHER SELECTED COMMENTS
		Set<Id> setCCIds = new Set<Id>();
		for (csComment ccWrp : lstComments)
		{
			if (ccWrp.bIsChecked)
			{
				setCCIds.add(ccWrp.cc.Id);
			}
		}

		// GATHER SELECTED FILES
		Set<Id> setCVIds = new Set<Id>();
		for (contentVers cvWrp : lstFiles)
		{
			if (cvWrp.bIsChecked)
			{
				setCVIds.add(cvWrp.cv.Id);
			}
		}

		// DO OUTBOUND BASED ON INTEGRATION CONTEXT
		try
		{
			if (isLegacy)
			{
				system.debug(' *^* USING OLD INTEGRATION ... ');
				// CALL FUTURE METHOD PASSING IN CASE ID, LIST OF SELECTED COMMENT IDs AND LIST OF SELECTED FILE IDs
				NI_ServicenowIntegration.createIHGIncident(c.Id, setCCIds, setCVIds);
			}
			else
			{
				system.debug(' *^* USING NEW INTEGRATION ... ');
				// CALL FUTURE METHOD PASSING IN CASE ID, LIST OF SELECTED COMMENT IDs AND LIST OF SELECTED FILE IDs
				INTGR_IntegrationHelper.createCustomerIncident(c.Id, setCCIds, setCVIds);
			}
			strSubmitMsg = 'Your request has been queued and may take a few minutes to complete. Please check the Integration Log related list on this case for results.';
			// isSuccess = true;
		}
		catch(Exception ex)
		{
			strSubmitMsg = ex.getMessage();
		}
	}

	public void hideSuccess()
	{
		isSuccess = false;
		toastMsg = '';
	}

	// ================================================================================================================================
	// WRAPPER CLASSES
	// ================================================================================================================================

	public class csComment
	{
		public CaseComment cc {get; set;}
		public boolean bIsChecked {get; set;}

		public csComment(CaseComment cc, boolean bIsChecked)
		{
			this.cc = cc;
			this.bIsChecked = bIsChecked;
		}
	}

	public class contentVers
	{
		public ContentVersion cv {get; set;}
		public boolean bIsChecked {get; set;}

		public contentVers(ContentVersion cv, boolean bIsChecked)
		{
			this.cv = cv;
			this.bIsChecked = bIsChecked;
		}
	}
}