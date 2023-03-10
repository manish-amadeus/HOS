/**********************************************************************************************************
Name            : NI_FUNCTIONS Class
Author          : Sean Harris
Created Date    : 09/16/2013
Last Mod Date   : 02/07/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Class that contains common reusable custom functions
                :    public static boolean hasAccessByPublicGroup(Id usersId, String publicGroupName)
                :    public static void findSubGroupsAndRoles(Id grpId, Set<Id> setGroupId)
                :    public static Map<Id, Id> getLatestDIHistoryIDMap(Set<Id> setDIs)
                :    public static boolean bypassTriggerCode(string strObjectName)
                :    Updated on 9/6/2017 per NICC-023777
                :    Updated on 9/12/2017 per NICC-023837
                :
***********************************************************************************************************/
public class NI_FUNCTIONS
{
    
    // FUNCTION THAT EXCEPTS (USER ID, PUBLIC GROUP NAME STRING) AND RETURNS TRUE OR FALSE IF IT FINDS A RELATION MATCH
    public static boolean hasAccessByPublicGroup(Id usersId, String publicGroupName)
    {
        
        // LIST TO HOLD PUBLIC GROUP TO BE EVALUATED (USED LIST TO UTILIZE SIZE() FUNCTION)
        List<Group> lstPublicGroup = new List<Group>([SELECT Id FROM Group WHERE Name =: publicGroupName LIMIT 1]);
        
        // IF NO GROUP FOUND RETURN FALSE
        if (lstPublicGroup.Size() < 1)
        {
            System.debug('!!! =========== NI_FUNCTIONS.hasAccessByPublicGroup : CANNOT FIND PUBLIC GROUP NAMED ' + publicGroupName + ' =========== !!!');
            return false;
        }
        
        // SET TO HOLD IDS OF PUBLIC GROUPS & USER ROLE USER BELONGS TO 
        Set<Id> setMemberOf = new Set<Id>();
        
        // GET USER RECORD WITH USER ROLE ID
        User u = [SELECT Id, UserRoleId FROM User WHERE Id = : usersId LIMIT 1];
        // ADD USER ROLE ID TO "MEMBER OF" SET
        setMemberOf.Add(u.UserRoleId);
        
        // FILL SET WILL ALL GROUP IDs THAT THE USER BELONGS TO 
        for (GroupMember m : [SELECT Id, GroupId, UserOrGroupId 
                              FROM GroupMember 
                              WHERE Group.Type = 'Regular' 
                              AND UserOrGroupId = : usersId]) 
        {
            setMemberOf.Add(m.GroupId); 
        }
        
        // LOOP THROUGH "MEMBER OF" LIST TO SEE IF VISITOR BELONGS TO THE GROUP PASSED IN DIRECTLY
        for (Id i : setMemberOf)
        {
            if (lstPublicGroup[0].Id == i)
            {
                // MATCH FOUND RETURN TRUE
                return true;
            }
        }
        
        // SETS TO HOLD ALL PUBLIC GROUP AND ROLE IDS FOUND IN RECURSION
        Set<Id> setSubGroupsAndRoles = new Set<Id>();
        Set<Id> setSubGroupsAndRolesTEMP = new Set<Id>();
        
        // USED TO LIMIT THE RECURSION ITERATIONS
        integer iLevelsDeep = 5;
        
        // START PROCESS BY FINDING ANY PUBLIC GROUPS OF ROLES ON THE GROUP PASSED IN
        findSubGroupsAndRoles(lstPublicGroup[0].Id, setSubGroupsAndRolesTEMP); 
        
        // LOOP THOUGH NESTED GROUPS
        for (integer j = 0; (j < iLevelsDeep); j++)
        {
            // TEMP WORKING SET FOR EACH LOOP ITERATION
            Set<Id> setTmp = new Set<Id>();
            
            // TRANSFER ALL IDS IN REUSABLE TEMP SET TO RUNNING SET
            for (Id tmp1 : setSubGroupsAndRolesTEMP)
            {
                setSubGroupsAndRoles.Add(tmp1);
                findSubGroupsAndRoles(tmp1, setTmp); 
            } 
            // THEN CLEAR TEMP SET FOR NEXT RUN
            setSubGroupsAndRolesTEMP.Clear();
            
            // IF SIZE IS ZERO IT IS THE END OF NEST, EXIT LOOP
            if (setTmp.Size() == 0)
            {
                break;
            }
            
            // REFILL TEMP SET FOR NEXT LOOP ITERATION
            for (Id tmp2 : setTmp)
            {
                setSubGroupsAndRolesTEMP.Add(tmp2);
            }         
            
        }
        
        // LOOP THROUGH "MEMBER OF" AND RUNNING SET TO FIND ANY MATCHES
        for (Id i2 : setMemberOf)
        {
            for (Id i3 : setSubGroupsAndRoles)
            {        
                if (i2 == i3)
                {
                    // MATCH FOUND RETURN TRUE
                    return true;
                }
            }
        }
        
        // RETURN DEFAULT FALSE IF NOTHIN ABOVE RETURNED TRUE
        return false;
        
    }
    
    // FINDS GROUPS AND ROLES BELONGING TO A PUBLIC GROUP AND ADDS THE IDS OF THEM TO A PASSED IN SET
    public static void findSubGroupsAndRoles(Id grpId, Set<Id> setGroupId)
    {   
        for (Group grp : [SELECT g.Id, g.DeveloperName, g.RelatedId, g.Type
                          FROM Group g
                          WHERE g.Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId = : grpId)])    
        {     
            if (grp.Type == 'Regular')
            {
                // PUBLIC GROUP FOUND
                setGroupId.Add(grp.Id);
            }
            else
            {
                // ROLE OR ROLE & SUBORDINATES
                setGroupId.Add(grp.RelatedId);   
            }      
        }    
    } 
    
    // RETURN MAP OF ASSOCIATED DI ID AND LATEST DI HISTORY
    public static Map<Id, Id> getLatestDIHistoryIDMap(Set<Id> setDIs)
    {
        
        Id idDI = null;             // HOLDS LAST ID FOR CHANGE DETECTION
        boolean bFirstRun = true;
        
        // MAP TO BE RETURNED BY FUNCTION
        
        Map<Id, Id> mapDHI = new Map<Id, Id>();
        
        for (NI_Deployment_Instance_History__c lstDIH : [
            SELECT Id, Related_Deployment_Instance__c
            FROM NI_Deployment_Instance_History__c 
            WHERE Related_Deployment_Instance__c != null AND //THIS LINE ADDED BY STUART EMERY ON 7/25/2016 PER NICC-018732
            Related_Deployment_Instance__c IN : setDIs 
            ORDER BY Related_Deployment_Instance__c, CreatedDate DESC])
        {
            if (bFirstRun)
            {
                bFirstRun = false;  
                idDI = lstDIH.Related_Deployment_Instance__c;
                mapDHI.put(idDI, lstDIH.Id);                               
            }
            else
            {
                if (idDI != lstDIH.Related_Deployment_Instance__c)
                {
                    idDI = lstDIH.Related_Deployment_Instance__c;
                    mapDHI.put(idDI, lstDIH.Id);                    
                }
            }            
        }
        
        return mapDHI;
        
    }    
    
    // A METHOD THAT LOOKS AT A CUSTOM SETTING TO BYPASS ALL TRIGGER HANDLING FUNCTIONS
    public static boolean bypassTriggerCode(string strObjectName)
    {
        
        // RETURN VALUE VARIABLE
        boolean bIsTrue = false;
        
        // CHANGE OBJECT NAME PARAM VALUE TO UPPERCASE FOR CONSISTENCY
        string sObjName = strObjectName.toUpperCase();
        
        // LIST TO HOLD THE VALUES IN THE NI_TriggerBypassSwitches__c CUSTOM SETTING
        List<NI_TriggerBypassSwitches__c> lstCS = NI_TriggerBypassSwitches__c.getall().values();
        
        // IF THE lstCS LIST CONTAINS RECORDS, CONTINUE WITH THE REST OF THE CODE  
        if (lstCS.size() > 0)
        {
            // LOOP THROUGH THE lstCS LIST.  
            for (NI_TriggerBypassSwitches__c cs : lstCS)
            {
                if (cs.Name == 'Bypass Control Panel') 
                {             
                    if (cs.MasterSwitch_ON__c == true)
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'ACCOUNT') && (cs.BypassAccount_ON__c == true))
                    {                     
                        bIsTrue = true;
                    }
                    if ((sObjName == 'APTTUS AGREEMENT') && (cs.BypassApttusAgreement_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'ASSET') && (cs.BypassAsset_ON__c == true))
                    { 
                        bIsTrue = true;
                    }                
                    if ((sObjName == 'CASE') && (cs.BypassCase_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'GDS MONTHLY REVENUE') && (cs.Bypass_AIP_GDS_Monthly_Revenue__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'IT HARDWARE ASSET') && (cs.Bypass_IT_Hardware_Asset_ON__c == true))
                    { 
                        bIsTrue = true;
                    } 
                    if ((sObjName == 'NI CANCELLATION') && (cs.BypassNICancellation_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI CHANGE CONTROL') && (cs.BypassNIChangeControl_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI CR ENGAGEMENT') && (cs.BypassNICREngagement_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI CUSTOMIZATION') && (cs.BypassNICustomizationDetail_ON__c == true))
                    { 
                        bIsTrue = true;
                    } 
                    if ((sObjName == 'NI CUSTOMIZATION SERVICE') && (cs.BypassNICustomizationService_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'PERFORMANCE EVALUATION') && (cs.BypassNIEmployeePerfEval_ON__c == true))
                    { 
                        bIsTrue = true;
                    } 

                    if ((sObjName == 'NI ICE PROPERTY') && (cs.BypassNIICEProperty_ON__c == true))
                    { 
                        bIsTrue = true;
                    } 
                    if ((sObjName == 'NI ICE SUBSCRIPTION') && (cs.BypassNIICESubscription_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI JOB REQUISITION') && (cs.Bypass_NI_Job_Requisition__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI LICENSE AUDIT') && (cs.Bypass_NI_License_Audit_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI MILESTONE FORECAST') && (cs.BypassNIMilestoneForecast_ON__c == true))
                    { 
                        bIsTrue = true;
                    } 
                    if ((sObjName == 'NI ORG DETAILS') && (cs.BypassNIOrgDetails_ON__c == true))
                    { 
                        bIsTrue = true;
                    } 
                    if ((sObjName == 'NI PRAIRIEFYRE AGENT EVENTS') && (cs.BypassNIPFyreAgentEvents_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI PROJECT BACKLOG') && (cs.Bypass_NI_Project_Backlog_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI PROJECT BACKLOG TASK') && (cs.Bypass_NI_Project_Backlog_Task_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI SALES EXPENSE REPORT') && (cs.BypassNISalesExpenseReport_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI SERVICE ORDER') && (cs.BypassNIServiceOrder_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NICC ARTIFACT') && (cs.BypassNICCArtifact_ON__c == true))
                    { 
                        bIsTrue = true;
                    }                
                    if ((sObjName == 'OPPORTUNITY') && (cs.BypassOpportunity_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'OPPORTUNITY PRODUCT') && (cs.BypassOpportunityProduct_ON__c == true))
                    { 
                        bIsTrue = true;
                    } 
                    if ((sObjName == 'TOPIC ASSIGNMENT') && (cs.Bypass_TopicAssignment_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'PAGER BONUS') && (cs.Bypass_NI_Pager_Bonus_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'PSA MILESTONE') && (cs.Bypass_PSA_Milestone__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'SOFTRAX ASSET') && (cs.Bypass_Softrax_Asset__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'USER') && (cs.Bypass_User_ON__c == true))
                    { 
                        bIsTrue = true;
                    }                   
                    if ((sObjName == 'PRODUCT2') && (cs.BypassProduct2_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'Bypass Opportunity - Acct Plans & Strats') && (cs.BypassOpportunityAcctPlansStrats__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'Bypass Opportunity - Contact Role Checks') && (cs.BypassOpportunityContactRoleChecks__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'Bypass Opportunity - Release Date Update') && (cs.BypassOpportunityReleaseDateUpdate__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'Bypass Opportunity - Rollup Amount') && (cs.BypassOpportunityRollupAmount__c == true))
                    { 
                        bIsTrue = true;
                    }
					if ((sObjName == 'Bypass Opportunity - HRM Product Create') && (cs.BypassOpportunityHRMProductCreate__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NWS Location') && (cs.BypassNWSLocation_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NWS IServer') && (cs.BypassNWSIServer_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI CUSTOMER AGREEMENT') && (cs.Bypass_NI_Customer_Agreement__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI INVOICE') && (cs.Bypass_NI_Invoice__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'NI INVOICE DETAIL') && (cs.Bypass_NI_Invoice_Detail__c == true))
                    { 
                        bIsTrue = true;
                    }
            		if ((sObjName == 'PRODUCT RELEASE') && (cs.BypassProductRelease_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'REQUISITION LINE ITEM') && (cs.Bypass_ffaRequisitionLineItemTrigger__c == true))
                    { 
                        bIsTrue = true;
                    }
					if ((sObjName == 'TASK') && (cs.Bypass_Task_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'ATTACHMENT') && (cs.BypassAttachment_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'CASECOMMENT') && (cs.BypassCaseComment_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'CASE RESHARE') && (cs.BypassCaseReshare_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'WIN@PROACH') && (cs.Bypass_Winaproach_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'MTECH SaaS') && (cs.BypassMTechSaaS_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'EMAILMESSAGE') && (cs.BypassEmailMessage_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'SUPPLYREQRENEWAL') && (cs.BypassSupplyReqMonthlyRenewal_ON__c == true))
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'SUBSCRIPTION ACTIVATION') && (cs.Bypass_Subscription_Activation__c == true)) //ADDED PER NICC-023777
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'SUBSCRIPTION ACTIVATION TRANSACTION') && (cs.Bypass_SubscriptionActivationTransaction__c == true)) //ADDED PER
                    { 
                        bIsTrue = true;
                    }
                    if ((sObjName == 'SURVEY RESPONSE DATA') && (cs.Bypass_Survey_Response_Data__c == true)) //ADDED PER NICC-023837
                    { 
                        bIsTrue = true;
                    }  
                    if ((sObjName == 'CANCELLATION ROLLUP') && (cs.Bypass_Cancellation_Rollup__c == true)) //ADDED PER NICC-025668
                    {
                        bIsTrue = true;
                    }
					if ((sObjName == 'CASE FLAGS') && (cs.BypassCaseFlags_ON__c == true)) 					//ADDED PER NICC-026092
                    {
                        bIsTrue = true;
                    }
                    if ((sObjName == 'CONTACT') && (cs.Bypass_Contact__c == true)) 							//ADDED PER NICC-027123
                    {                     
                        bIsTrue = true;
                    }
                    if ((sObjName == 'SUNSET CONTACT') && (cs.BypassContactSunsetContact__c == true)) 		//ADDED PER NICC-027123
                    {
                        bIsTrue = true;
                    }
                    if ((sObjName == 'AH ACCOUNT PRODUCT') && (cs.Bypass_AH_Account_Product__c == true))
                    {
                        bIsTrue = true;
                    }
                    if ((sObjName == 'AH OPPORTUNITY RELATED ACCOUNT') && (cs.Bypass_AH_Opportunity_Related_Account__c == true))
                    {
                        bIsTrue = true;
                    }
                    if ((sObjName == 'OUTAGE NOTIFICATION') && (cs.Bypass_NITrustOutageNotifications__c == true))
                    {
                        bIsTrue = true;
                    }       
                    
                    // ADD NEW ONES ABOVE HERE...
                    
                    // USE THIS BLOCK AS TEMPLATE FOR NEW TRIGGER HANDLERS:
                    // if ((strObjectName == 'OBJECTNAME') && (cs.FIELDNAME == true))
                    // { 
                    //    bIsTrue = true;
                    // }
                    
                }
                
            }
            
        }        
        
        return bIsTrue;
        
    }    
    
    // RETURN THE EXEC MEMBER BASED ON THE LOCATION AND DEPARTMENT
    public static Id getExecMember(Id idLocation, Id idDepartment)
    {
        
        Id idExecMember = null;
        
        if ((idLocation != null) && (idDepartment != null))
        {  
            //SET TO HOLD THE DEPARTMENT TO LOCATION IDs 
            List<NI_Department_to_Location__c> lstDepToLocation = [SELECT Id, Employee__c, NI_Departments__c, Location__c, Role__c
                                                                   FROM NI_Department_to_Location__c 
                                                                   WHERE NI_Departments__c =: idDepartment 
                                                                   AND Location__c =: idLocation 
                                                                   AND Role__c = 'Exec Member'];  
            if (lstDepToLocation.size() > 0)
            {   
                idExecMember = lstDepToLocation[0].Employee__c;                  
            }
        }
        
        return idExecMember;
        
    }
   
    public static Id getRoleId(String sRoleName)
    {
        UserRole objRole = [SELECT Id FROM UserRole WHERE Name =: sRoleName LIMIT 1];
        return objRole.Id;
    } 
    
    public static Id getProfileId(String sProfileName)
    {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: sProfileName LIMIT 1];
        return objProfile.Id;
    } 

    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix)
    {

        String objectName = '';
        
        if ((recordIdOrPrefix == null) || (recordIdOrPrefix == null) || (recordIdOrPrefix.length() < 3))
        {
            return objectName;
        }

        try 
        {
            
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0, 3);
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();  
            Set<String> keyPrefixSet = gd.keySet(); 
            
            for (String sObj : keyPrefixSet)
            {
                if (!sObj.contains('__'))	// SKIPS OVER MANAGED OBJECTS
                {           
                    Schema.DescribeSObjectResult r = gd.get(sObj).getDescribe(); 
                    
                    if (r.getKeyPrefix() == myIdPrefix)
                    {
                        objectName = r.getName();
                        break;
                    }
                }
            }
            
        } 
        catch (Exception e) {System.debug(e);}
        
        return objectName;
        
    }    

    public static List<SelectOption> getPicklistValues(SObject obj, String fld)
    {
        
        List<SelectOption> options = new List<SelectOption>();
        
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();   
        
        // Get a map of fields for the SObject
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        
        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values)
        { 
            options.add(new SelectOption(a.getLabel(), a.getValue())); 
        }
        
        return options;
        
    }
     

    // ============================================================================================================================================    
    //  PARTNER CENTRAL RELATED FUNCTIONS   
    // ============================================================================================================================================      
    
    public static boolean allFormsAccepted(Id AccountId)
    {
		// THIS FUNCTION RETURNS TRUE WHEN ALL PARTNER FORMS HAVE BEEN ACCEPTED
		boolean bRetVal = true;
        
        List<Partners_Form_Template_to_Account__c> lstPFTs = new List<Partners_Form_Template_to_Account__c>(
            [SELECT Id 
             FROM Partners_Form_Template_to_Account__c 
             WHERE Account__c =: AccountId 
             AND Accepted_Terms__c = false]);          
        
		if (lstPFTs.size() > 0)
        {
            bRetVal = false;
        }
        
        return bRetVal;
        
    } 

    @future 
    public static void bulkChangePartnerFieldsOnUser(Id AccountId, set<Id> setUserId, String strTermsAccepted, String strPermission)
    {
        
        List<User> lstUserUpdate = new List<User>();
        
        for (User u : [SELECT Id, Partner_Permissions__c, Partner_Terms_Accepted__c 
                       FROM User 
                       WHERE Id IN : setUserId 
                       AND Partner_Terms_Accepted__c !=: strTermsAccepted])
        {
            if (strPermission != null)
            {
                u.Partner_Permissions__c = strPermission;
            }
            u.Partner_Terms_Accepted__c = strTermsAccepted;
            lstUserUpdate.add(u);
        }
      
        database.update(lstUserUpdate);            
        createPartnerShares(AccountId, setUserId); 
        
    }  

    public static void createPartnerShares(Id AccountId, Set<Id> setUserId)
    {
        
        List<Partners_Form_Template_to_Account__Share> lstShares1 = new List<Partners_Form_Template_to_Account__Share>();
        List<Partners_Form_Template__Share> lstShares2 = new List<Partners_Form_Template__Share>();
        List<User> lstUsers = new List<User>([SELECT Id, AccountId FROM User WHERE Id IN : setUserId]);

        for (Partners_Form_Template__c pft : [SELECT Id  
                                              FROM Partners_Form_Template__c 
                                              WHERE Id IN (SELECT Partners_Form_Template__c 
                                                           FROM Partners_Form_Template_to_Account__c 
                                                           WHERE Account__c =: AccountId)])
        {
            for (User pUser : lstUsers)
            {               
                
                Partners_Form_Template__Share s2 = new Partners_Form_Template__Share();
                s2.ParentId = pft.Id;
                s2.UserOrGroupId = pUser.Id;
                s2.AccessLevel = 'Read';
                s2.RowCause = Schema.Partners_Form_Template__Share.RowCause.Shared_to_Partner__c;
                lstShares2.add(s2);                
            } 
        }     
        
        database.insert(lstShares2, false);
        
        for (Partners_Form_Template_to_Account__c pft2a : [SELECT Id, Account__c FROM Partners_Form_Template_to_Account__c WHERE Account__c =: AccountId])
        {
            for (User pUser : lstUsers)
            {               
                if (pft2a.Account__c == pUser.AccountId)
                {
                    Partners_Form_Template_to_Account__Share s1 = new Partners_Form_Template_to_Account__Share();
                    s1.ParentId = pft2a.Id;
                    s1.UserOrGroupId = pUser.Id;
                    s1.AccessLevel = 'Read';
                    s1.RowCause = Schema.Partners_Form_Template_to_Account__Share.RowCause.Shared_to_Partner__c;
                    lstShares1.add(s1);
                } 
            } 
        }
		
   		database.insert(lstShares1, false);
        
    }
    
    public static Set<Id> getAllChildAccIdsInHierarchy(Id topAccountId, Integer iLevelsDeep)
    {

        Set<Id> setAllAccountIds = new Set<Id>();
        setAllAccountIds.add(topAccountId);
        Set<Id> setTempAccountIds = new Set<Id>();
        setTempAccountIds.add(topAccountId);
        
        List<Account> lst = new List<Account>();
        
        for (integer i = 0; i < iLevelsDeep; i++)
        {
            lst = [SELECT Id FROM Account WHERE ParentId IN : setTempAccountIds];
            setTempAccountIds.clear();
            
            if (lst.size() == 0)
            {
                break;
            }
    
            for (Account a : lst)
            {
                setTempAccountIds.add(a.Id);
                setAllAccountIds.add(a.Id);
            } 
            
            lst.clear();            
        }
        
        system.debug('  Limits.getQueries() = ' + Limits.getQueries());
        
        return setAllAccountIds;

    }
    
    public static Map<String, Account> getAccountHierarchy(Id topAccountId, Integer iLevelsDeep)
    {

        Integer iNode = 0;
        Integer iRecord = 0;
        String sNodePadding = 'N000000';
        String sRecordPadding = 'R000000';
        String sortKey = sNodePadding + '-' + sRecordPadding;
        
        Map<String, Account> mapHierarchy = new Map<String, Account>();
        Account aTop = [SELECT Id, Name, AccountNumber, Type, Industry, BillingCity, BillingState, Owner.Name 
                        FROM Account 
                        WHERE Id =: topAccountId
                        ORDER BY Name ASC];
        mapHierarchy.put(sortKey, aTop);
        
        Set<Id> setTempAccountIds = new Set<Id>();
        setTempAccountIds.add(topAccountId);
        
        List<Account> lst = new List<Account>();
        
        for (integer i = 0; i < iLevelsDeep; i++)
        {
            
            iNode += 1;
            
            lst = [SELECT Id, Name, AccountNumber, Type, Industry, BillingCity, BillingState, Owner.Name 
                   FROM Account 
                   WHERE ParentId IN : setTempAccountIds
                   ORDER BY Name ASC];
            
            setTempAccountIds.clear();
            
            if (lst.size() == 0)
            {
                break;
            }    

            iRecord = 1;            

            for (Account a : lst)
            {
                setTempAccountIds.add(a.Id); 
                iRecord += 1;
                sortKey = sNodePadding.substring(0, 7 - String.valueOf(iNode).Length()) + String.valueOf(iNode) + '-' + sRecordPadding.substring(0, 7 - String.valueOf(iRecord).Length()) + String.valueOf(iRecord);              
                mapHierarchy.put(sortKey, a);
            } 
            
            lst.clear();            
        }
        
        system.debug('  Limits.getQueries() = ' + Limits.getQueries());
        
        return mapHierarchy;

    }    
    

    @future
    public static void updateDIRollupSummaryFields(Set<Id> setDeploymentInstanceIds)
    {
        
        Map<String, String> productFamilyUnitMap = new Map<String, String>();
        List<String> unitList = new List<String>();
        Map<String, Decimal> countMap = new Map<String, Decimal>();
        List<Asset> assetToUpdate = new List<Asset>();
        
        // ROUTINE TO REMOVE ANY NULLS FROM SET OF DI IDS PASSED IN
        Set<Id> setDIIds = new Set<Id>();
        for (Id i : setDeploymentInstanceIds)   
        {
            if (i != null)
            {
                setDIIds.add(i);
            }
        }
        
        if (setDIIds.isEmpty())
        {
            return;
        } 
        
        // FETCH PRODUCT FAMILY AND UNIT FROM CUSTOM SETTING
        for (AH_Products_Family_Unit__c prodFamily : [SELECT Id, Name, Product_Unit__c FROM AH_Products_Family_Unit__c])
        {
            productFamilyUnitMap.put(prodFamily.Name, prodFamily.Product_Unit__c);
        }
        
        
        //GET ALL THE OLI RECORDS RELATED TO DI
        List<OpportunityLineItem> oliList = [SELECT DeploymentInstance__c, Quantity, Product2.Family, Product2.Unit__c, Product2.License_Type__c, Opportunity.Order_Status__c 
                                             FROM OpportunityLineItem 
                                             WHERE (Opportunity.StageName = 'Closed Won' OR Opportunity.StageName = 'Sold')
                                             AND (Product2.DI_Index__c != null OR Product2.DI_Index__r.Name != 'N/A') 
                                             AND DeploymentInstance__c IN : setDIIds];
system.debug('*^* oliList = ' + oliList.size());        
        //ITERATE OVER THE OLI RECORDS
        for (OpportunityLineItem oliObj : oliList)
        {
            
            Set<String> unitSet = new Set<String>();
            Set<String> familySet = new Set<String>();
            
            if (!productFamilyUnitMap.isEmpty())
            {
                if (productFamilyUnitMap.containsKey(oliObj.Product2.Family))
                {
                    String prodFamUnit = productFamilyUnitMap.get(oliObj.Product2.Family);
                    familySet.add(oliObj.Product2.Family);
                    if (prodFamUnit != null)
                    {
                        unitList = prodFamUnit.split(',');
                        unitSet.addAll(unitList);
                    }
                }
            }
            else
            {
                familySet.add('None');
            }
            
            Boolean quantOrdered = false;
            
            //CHECK FOR SOFTWARE LICENSE
            Boolean softLicense = (oliObj.Product2.Family == 'Software' && unitSet.contains(oliObj.Product2.Unit__c)) ? true : false;
            
            //CHECK FOR FULL LICENSE
            Boolean fullLicense = (familySet.contains(oliObj.Product2.Family) && oliObj.Product2.License_Type__c == 'Full') ? true : false;
            
            //CHECK FOR LIMITED LICENSE
            Boolean limtdLicense = (familySet.contains(oliObj.Product2.Family) && oliObj.Product2.License_Type__c == 'Limited') ? true : false;
            
            //CHECK FOR QUANTITY ORDERED
            if (!unitSet.isEmpty())
            {
                quantOrdered = (familySet.contains(oliObj.Product2.Family) && unitSet.contains(oliObj.Product2.Unit__c));
            }
            else
            {
                quantOrdered = familySet.contains(oliObj.Product2.Family);
            }
            
            // ONLY TALLY QUANTITIES WHEN Opportunity.Order_Status__c IS Integrated, Shipped or Definite OR Complete(Sertifi)
            if (oliObj.Opportunity.Order_Status__c == 'Integrated' || 
                oliObj.Opportunity.Order_Status__c == 'Shipped' || 
                oliObj.Opportunity.Order_Status__c == 'Definite' || 
                oliObj.Opportunity.Order_Status__c == 'Complete')            
            {           
                
                //VARIABLE TO HOLD QUANTITY OF SOFT LICENSE, FULL LICENSE, LIMITED LICENSE AND QUANTITY ORDERED RELATED TO DI RECORD
                if (softLicense)
                {
                    if (countMap.get(oliObj.DeploymentInstance__c + 'softLicense') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'softLicense', countMap.get(oliObj.DeploymentInstance__c + 'softLicense') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'softLicense', oliObj.Quantity);
                    }
                }
                
                if (fullLicense)
                {
                    if (countMap.get(oliObj.DeploymentInstance__c + 'fullLicense') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'fullLicense', countMap.get(oliObj.DeploymentInstance__c + 'fullLicense') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'fullLicense', oliObj.Quantity);
                    }
                }
                
                if (limtdLicense)
                {
                    if (countMap.get(oliObj.DeploymentInstance__c + 'limtdLicense') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'limtdLicense', countMap.get(oliObj.DeploymentInstance__c + 'limtdLicense') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'limtdLicense', oliObj.Quantity);
                    }
                }
                
                if (quantOrdered || softLicense)
                {
                    if (countMap.get(oliObj.DeploymentInstance__c + 'quantOrdered') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'quantOrdered', countMap.get(oliObj.DeploymentInstance__c + 'quantOrdered') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'quantOrdered', oliObj.Quantity);
                    }
                }
            }    
        }
        
        List<AH_Account_Product__c> accProductList = [SELECT Deployment_Instance__c, Quantity__c,
                                                      Product__r.Family, Product__r.Unit__c, Product__r.License_Type__c,
                                                      Opportunity__r.Order_Status__c 
                                                      FROM AH_Account_Product__c 
                                                      WHERE (Opportunity__r.StageName = 'Closed Won' OR Opportunity__r.StageName = 'Sold')
                                                      AND (Product__r.DI_Index__c != null OR Product__r.DI_Index__r.Name != 'N/A') 
                                                      AND Deployment_Instance__c IN : setDIIds];
system.debug('*^* accProductList = ' + accProductList.size());         
        for (AH_Account_Product__c accPrdObj: accProductList)
        {
            
            Set<String> unitSet = new Set<String>();
            Set<String> familySet = new Set<String>();
            
            if (!productFamilyUnitMap.isEmpty())
            {
                if (productFamilyUnitMap.containsKey(accPrdObj.Product__r.Family))
                {
                    String prodFamUnit = productFamilyUnitMap.get(accPrdObj.Product__r.Family);
                    familySet.add(accPrdObj.Product__r.Family);
                    if (prodFamUnit != null)
                    {
                        unitList = prodFamUnit.split(',');
                        unitSet.addAll(unitList);
                    }
                }
                
            }
            else
            {
                familySet.add('None');
            }
            
            Boolean quantOrdered = false;
            
            //CHECK FOR SOFTWARE LICENSE
            Boolean softLicense = false;
            
            if ((accPrdObj.Product__r.Family == 'Software' && unitSet.contains(accPrdObj.Product__r.Unit__c)))
            {
                softLicense = true;
            }
            else
            {
                softLicense = false;
            }
            
            //CHECK FOR FULL LICENSE
            Boolean fullLicense = false;
            
            if ((familySet.contains(accPrdObj.Product__r.Family) && accPrdObj.Product__r.License_Type__c == 'Full'))
            {
                fullLicense = true;
            }
            else
            {
                fullLicense = false;
            }
            
            //CHECK FOR LIMITED LICENSE
            Boolean limtdLicense = false;
            if ((familySet.contains(accPrdObj.Product__r.Family) && accPrdObj.Product__r.License_Type__c == 'Limited'))
            {
                limtdLicense = true;
            }
            else
            {
                limtdLicense = false;
            }
            
            //CHECK FOR QUANTITY ORDERED
            if (!unitSet.isEmpty())
            {
                quantOrdered = (familySet.contains(accPrdObj.Product__r.Family) && unitSet.contains(accPrdObj.Product__r.Unit__c));
            }
            else
            {
                quantOrdered = familySet.contains(accPrdObj.Product__r.Family);
            }            
            
            // ONLY TALLY QUANTITIES WHEN Opportunity.Order_Status__c IS Integrated, Shipped or Definite OR Complete(Sertifi)
            if (accPrdObj.Opportunity__r.Order_Status__c == 'Integrated' || 
                accPrdObj.Opportunity__r.Order_Status__c == 'Shipped' || 
                accPrdObj.Opportunity__r.Order_Status__c == 'Definite' || 
                accPrdObj.Opportunity__r.Order_Status__c == 'Complete')            
            {           
                
                if (softLicense)
                {
                    if (countMap.get(accPrdObj.Deployment_Instance__c + 'softLicense') != null)
                    {
                        countMap.put(accPrdObj.Deployment_Instance__c + 'softLicense', countMap.get(accPrdObj.Deployment_Instance__c + 'softLicense') + accPrdObj.Quantity__c);
                    }
                    else
                    {
                        countMap.put(accPrdObj.Deployment_Instance__c + 'softLicense', accPrdObj.Quantity__c);
                    }
                }
                
                if (fullLicense)
                {
                    if (countMap.get(accPrdObj.Deployment_Instance__c + 'fullLicense') != null)
                    {
                        countMap.put(accPrdObj.Deployment_Instance__c + 'fullLicense', countMap.get(accPrdObj.Deployment_Instance__c + 'fullLicense') + accPrdObj.Quantity__c);
                    }
                    else
                    {
                        countMap.put(accPrdObj.Deployment_Instance__c + 'fullLicense', accPrdObj.Quantity__c);
                    }
                }
                
                if (limtdLicense)
                {
                    if (countMap.get(accPrdObj.Deployment_Instance__c + 'limtdLicense') != null)
                    {
                        countMap.put(accPrdObj.Deployment_Instance__c + 'limtdLicense', countMap.get(accPrdObj.Deployment_Instance__c + 'limtdLicense') + accPrdObj.Quantity__c);
                    }
                    else
                    {
                        countMap.put(accPrdObj.Deployment_Instance__c + 'limtdLicense', accPrdObj.Quantity__c);
                    }
                }
                
                if (quantOrdered || softLicense)
                {
                    if (countMap.get(accPrdObj.Deployment_Instance__c + 'quantOrdered') != null)
                    {
                        countMap.put(accPrdObj.Deployment_Instance__c + 'quantOrdered', countMap.get(accPrdObj.Deployment_Instance__c + 'quantOrdered') + accPrdObj.Quantity__c);
                    }
                    else
                    {
                        countMap.put(accPrdObj.Deployment_Instance__c + 'quantOrdered', accPrdObj.Quantity__c);
                    }
                }
            }    
        }
        
        //ITERATE OVER ALL THE DI RECORDS RELATED TO OLI
        for (Asset diObj: [SELECT Id, Quantity_Ordered__c, Status, Software_Licenses__c, Subscription_Licenses_Full__c, Subscription_Licenses_Limited__c
                           FROM Asset WHERE Id IN: setDIIds])
        {
            
            // INITIALIZE QUANTITY FIELDS                              
            diObj.Software_Licenses__c = 0;                              
            diObj.Subscription_Licenses_Full__c = 0;                             
            diObj.Subscription_Licenses_Limited__c = 0;
            diObj.Quantity_Ordered__c = 0;
            
            //UPDATE SOFTWARE LICENSE QUANTITY
            if (countMap.get(diObj.Id + 'softLicense') != null)
            {
                diObj.Software_Licenses__c = countMap.get(diObj.Id + 'softLicense');
            }
            
            //UPDATE FULL LICENSE QUANTITY
            if (countMap.get(diObj.Id + 'fullLicense') != null)
            {
                diObj.Subscription_Licenses_Full__c = countMap.get(diObj.Id + 'fullLicense');
            }
            
            //UPDATE LIMITED LICENSE QUANTITY
            if (countMap.get(diObj.Id + 'limtdLicense') != null)
            {
                diObj.Subscription_Licenses_Limited__c = countMap.get(diObj.Id + 'limtdLicense');
            }
            
            //UPDATE QUANTITY ORDERED
            if (countMap.get(diObj.Id + 'quantOrdered') != null)
            {
                diObj.Quantity_Ordered__c = countMap.get(diObj.Id + 'quantOrdered');
            }
            
            //ADD DI RECORD TO UPDATE LIST
            assetToUpdate.add(diObj);
            
        }
        
        if (!assetToUpdate.isEmpty())
        {
            update assetToUpdate;
        }
        
    }
    
    
    public static void updateDIRollupSummaryFields1(Set<Id> setDeploymentInstanceIds)
    {
        
        Map<String, String> productFamilyUnitMap = new Map<String, String>();
        List<String> unitList = new List<String>();
        Map<String, Decimal> countMap = new Map<String, Decimal>();
        List<Asset> assetToUpdate = new List<Asset>();
        
        // ROUTINE TO REMOVE ANY NULLS FROM SET OF DI IDS PASSED IN
        Set<Id> setDIIds = new Set<Id>();
        for (Id i : setDeploymentInstanceIds)   
        {
            if (i != null)
            {
                setDIIds.add(i);
            }
        }
        
        if (setDIIds.isEmpty())
        {
            return;
        } 
        
        // FETCH PRODUCT FAMILY AND UNIT FROM CUSTOM SETTING
        for (AH_Products_Family_Unit__c prodFamily : [SELECT Id, Name, Product_Unit__c FROM AH_Products_Family_Unit__c])
        {
            productFamilyUnitMap.put(prodFamily.Name, prodFamily.Product_Unit__c);
        }
        
        
        //GET ALL THE OLI RECORDS RELATED TO DI
        List<OpportunityLineItem> oliList = [SELECT DeploymentInstance__c, Quantity, Product2.Family, Product2.Unit__c, Product2.License_Type__c, Opportunity.Order_Status__c 
                                             FROM OpportunityLineItem 
                                             WHERE (Opportunity.StageName = 'Closed Won' OR Opportunity.StageName = 'Sold')
                                             AND (Product2.DI_Index__c != null OR Product2.DI_Index__r.Name != 'N/A') 
                                             AND DeploymentInstance__c IN : setDIIds];
system.debug('*^* setDIIds = ' + setDIIds);        
        
        system.debug('setDIIds size : '+setDIIds.size());
        system.debug('oliList size : '+oliList.size());
        
        //ITERATE OVER THE OLI RECORDS
        for (OpportunityLineItem oliObj : oliList)
        {
            
            Set<String> unitSet = new Set<String>();
            Set<String> familySet = new Set<String>();
            
            if (!productFamilyUnitMap.isEmpty())
            {
                if (productFamilyUnitMap.containsKey(oliObj.Product2.Family))
                {
                    String prodFamUnit = productFamilyUnitMap.get(oliObj.Product2.Family);
                    familySet.add(oliObj.Product2.Family);
                    if (prodFamUnit != null)
                    {
                        unitList = prodFamUnit.split(',');
                        unitSet.addAll(unitList);
                    }
                }
            }
            else
            {
                familySet.add('None');
            }
            
            Boolean quantOrdered = false;
            
            //CHECK FOR SOFTWARE LICENSE
            Boolean softLicense = (oliObj.Product2.Family == 'Software' && unitSet.contains(oliObj.Product2.Unit__c)) ? true : false;
            
            //CHECK FOR FULL LICENSE
            Boolean fullLicense = (familySet.contains(oliObj.Product2.Family) && oliObj.Product2.License_Type__c == 'Full') ? true : false;
            
            //CHECK FOR LIMITED LICENSE
            Boolean limtdLicense = (familySet.contains(oliObj.Product2.Family) && oliObj.Product2.License_Type__c == 'Limited') ? true : false;
            
            //CHECK FOR QUANTITY ORDERED
            if (!unitSet.isEmpty())
            {
                quantOrdered = (familySet.contains(oliObj.Product2.Family) && unitSet.contains(oliObj.Product2.Unit__c));
            }
            else
            {
                quantOrdered = familySet.contains(oliObj.Product2.Family);
            }
            
            // ONLY TALLY QUANTITIES WHEN Opportunity.Order_Status__c IS Integrated, Shipped or Definite OR Complete(Sertifi)
            if (oliObj.Opportunity.Order_Status__c == 'Integrated' || 
                oliObj.Opportunity.Order_Status__c == 'Shipped' || 
                oliObj.Opportunity.Order_Status__c == 'Definite' || 
                oliObj.Opportunity.Order_Status__c == 'Complete')            
            {  
                system.debug('oliObj.Quantity : '+oliObj.Quantity);
                
                //VARIABLE TO HOLD QUANTITY OF SOFT LICENSE, FULL LICENSE, LIMITED LICENSE AND QUANTITY ORDERED RELATED TO DI RECORD
                if (softLicense)
                {
                    if (countMap.get(oliObj.DeploymentInstance__c + 'softLicense') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'softLicense', countMap.get(oliObj.DeploymentInstance__c + 'softLicense') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'softLicense', oliObj.Quantity);
                    }
                }
                
                if (fullLicense)
                {
                    if (countMap.get(oliObj.DeploymentInstance__c + 'fullLicense') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'fullLicense', countMap.get(oliObj.DeploymentInstance__c + 'fullLicense') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'fullLicense', oliObj.Quantity);
                    }
                }
                
                if (limtdLicense)
                {
                    if (countMap.get(oliObj.DeploymentInstance__c + 'limtdLicense') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'limtdLicense', countMap.get(oliObj.DeploymentInstance__c + 'limtdLicense') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'limtdLicense', oliObj.Quantity);
                    }
                }
                
                if (quantOrdered || softLicense)
                {
                    if (countMap.get(oliObj.DeploymentInstance__c + 'quantOrdered') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'quantOrdered', countMap.get(oliObj.DeploymentInstance__c + 'quantOrdered') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'quantOrdered', oliObj.Quantity);
                    }
                }
            }    
        }
        
        List<AH_Account_Product__c> accProductList = [SELECT ID, Name, Deployment_Instance__c, Quantity__c,
                                                      Product__r.Family, Product__r.Unit__c, Product__r.License_Type__c,
                                                      Opportunity__r.Order_Status__c 
                                                      FROM AH_Account_Product__c 
                                                      WHERE (Opportunity__r.StageName = 'Closed Won' OR Opportunity__r.StageName = 'Sold')
                                                      AND (Product__r.DI_Index__c != null OR Product__r.DI_Index__r.Name != 'N/A') 
                                                      AND Deployment_Instance__c IN : setDIIds];
        
        system.debug('setDIIds : '+setDIIds);
        system.debug('accProductList size : '+accProductList.size());
        
        
        for (AH_Account_Product__c accPrdObj: accProductList)
        {
            
            Set<String> unitSet = new Set<String>();
            Set<String> familySet = new Set<String>();
            
            if (!productFamilyUnitMap.isEmpty())
            {
                if (productFamilyUnitMap.containsKey(accPrdObj.Product__r.Family))
                {
                    String prodFamUnit = productFamilyUnitMap.get(accPrdObj.Product__r.Family);
                    familySet.add(accPrdObj.Product__r.Family);
                    if (prodFamUnit != null)
                    {
                        unitList = prodFamUnit.split(',');
                        unitSet.addAll(unitList);
                    }
                }
                
            }
            else
            {
                familySet.add('None');
            }
            
            Boolean quantOrdered = false;
            
            //CHECK FOR SOFTWARE LICENSE
            Boolean softLicense = false;
            
            if ((accPrdObj.Product__r.Family == 'Software' && unitSet.contains(accPrdObj.Product__r.Unit__c)))
            {
                softLicense = true;
            }
            else
            {
                softLicense = false;
            }
            
            //CHECK FOR FULL LICENSE
            Boolean fullLicense = false;
            
            if ((familySet.contains(accPrdObj.Product__r.Family) && accPrdObj.Product__r.License_Type__c == 'Full'))
            {
                fullLicense = true;
            }
            else
            {
                fullLicense = false;
            }
            
            //CHECK FOR LIMITED LICENSE
            Boolean limtdLicense = false;
            if ((familySet.contains(accPrdObj.Product__r.Family) && accPrdObj.Product__r.License_Type__c == 'Limited'))
            {
                limtdLicense = true;
            }
            else
            {
                limtdLicense = false;
            }
            
            //CHECK FOR QUANTITY ORDERED
            if (!unitSet.isEmpty())
            {
                quantOrdered = (familySet.contains(accPrdObj.Product__r.Family) && unitSet.contains(accPrdObj.Product__r.Unit__c));
            }
            else
            {
                quantOrdered = familySet.contains(accPrdObj.Product__r.Family);
            }            
            
            // ONLY TALLY QUANTITIES WHEN Opportunity.Order_Status__c IS Integrated, Shipped or Definite OR Complete(Sertifi)
            if (accPrdObj.Opportunity__r.Order_Status__c == 'Integrated' || 
                accPrdObj.Opportunity__r.Order_Status__c == 'Shipped' || 
                accPrdObj.Opportunity__r.Order_Status__c == 'Definite' || 
                accPrdObj.Opportunity__r.Order_Status__c == 'Complete')            
            {           
                
                system.debug('accPrdObj.Name : '+accPrdObj.Name);
                system.debug('accPrdObj.Deployment_Instance__c : '+accPrdObj.Deployment_Instance__c);
                system.debug('accPrdObj.Quantity__c : '+accPrdObj.Quantity__c);
                
                Decimal quan;
                if(accPrdObj.Quantity__c == NULL)
                {
                    quan = 0.0;
                }
                else
                {
                 	quan = accPrdObj.Quantity__c;
                }
                
                if (softLicense)
                {
                    if (countMap.get(accPrdObj.Deployment_Instance__c + 'softLicense') != null)
                    {
                        //countMap.put(accPrdObj.Deployment_Instance__c + 'softLicense', countMap.get(accPrdObj.Deployment_Instance__c + 'softLicense') + accPrdObj.Quantity__c);
                        countMap.put(accPrdObj.Deployment_Instance__c + 'softLicense', countMap.get(accPrdObj.Deployment_Instance__c + 'softLicense') + quan);
                    }
                    else
                    {
                        //countMap.put(accPrdObj.Deployment_Instance__c + 'softLicense', accPrdObj.Quantity__c);
                        countMap.put(accPrdObj.Deployment_Instance__c + 'softLicense', quan);
                    }
                }
                
                if (fullLicense)
                {
                    if (countMap.get(accPrdObj.Deployment_Instance__c + 'fullLicense') != null)
                    {
                        //countMap.put(accPrdObj.Deployment_Instance__c + 'fullLicense', countMap.get(accPrdObj.Deployment_Instance__c + 'fullLicense') + accPrdObj.Quantity__c);
                        countMap.put(accPrdObj.Deployment_Instance__c + 'fullLicense', countMap.get(accPrdObj.Deployment_Instance__c + 'fullLicense') + quan);
                    }
                    else
                    {
                        //countMap.put(accPrdObj.Deployment_Instance__c + 'fullLicense', accPrdObj.Quantity__c);
                        countMap.put(accPrdObj.Deployment_Instance__c + 'fullLicense', quan);
                    }
                }
                
                if (limtdLicense)
                {
                    if (countMap.get(accPrdObj.Deployment_Instance__c + 'limtdLicense') != null)
                    {
                        //countMap.put(accPrdObj.Deployment_Instance__c + 'limtdLicense', countMap.get(accPrdObj.Deployment_Instance__c + 'limtdLicense') + accPrdObj.Quantity__c);
                        countMap.put(accPrdObj.Deployment_Instance__c + 'limtdLicense', countMap.get(accPrdObj.Deployment_Instance__c + 'limtdLicense') + quan);
                    }
                    else
                    {
                        //countMap.put(accPrdObj.Deployment_Instance__c + 'limtdLicense', accPrdObj.Quantity__c);
                        countMap.put(accPrdObj.Deployment_Instance__c + 'limtdLicense', quan);
                    }
                }

                if (quantOrdered || softLicense)
                {
                    if (countMap.get(accPrdObj.Deployment_Instance__c + 'quantOrdered') != null)
                    {
                        //countMap.put(accPrdObj.Deployment_Instance__c + 'quantOrdered', countMap.get(accPrdObj.Deployment_Instance__c + 'quantOrdered') + accPrdObj.Quantity__c);
                        countMap.put(accPrdObj.Deployment_Instance__c + 'quantOrdered', countMap.get(accPrdObj.Deployment_Instance__c + 'quantOrdered') + quan);
                    }
                    else
                    {
                        //countMap.put(accPrdObj.Deployment_Instance__c + 'quantOrdered', accPrdObj.Quantity__c);
                        countMap.put(accPrdObj.Deployment_Instance__c + 'quantOrdered', quan);
                    }
                }
            }
        }
        
        //ITERATE OVER ALL THE DI RECORDS RELATED TO OLI
        for (Asset diObj: [SELECT Id, Quantity_Ordered__c, Status, Software_Licenses__c, Subscription_Licenses_Full__c, Subscription_Licenses_Limited__c
                           FROM Asset WHERE Id IN: setDIIds])
        {
            
            // INITIALIZE QUANTITY FIELDS                              
            diObj.Software_Licenses__c = 0;                              
            diObj.Subscription_Licenses_Full__c = 0;                             
            diObj.Subscription_Licenses_Limited__c = 0;
            diObj.Quantity_Ordered__c = 0;
            
            //UPDATE SOFTWARE LICENSE QUANTITY
            if (countMap.get(diObj.Id + 'softLicense') != null)
            {
                diObj.Software_Licenses__c = countMap.get(diObj.Id + 'softLicense');
            }
            
            //UPDATE FULL LICENSE QUANTITY
            if (countMap.get(diObj.Id + 'fullLicense') != null)
            {
                diObj.Subscription_Licenses_Full__c = countMap.get(diObj.Id + 'fullLicense');
            }
            
            //UPDATE LIMITED LICENSE QUANTITY
            if (countMap.get(diObj.Id + 'limtdLicense') != null)
            {
                diObj.Subscription_Licenses_Limited__c = countMap.get(diObj.Id + 'limtdLicense');
            }
            
            //UPDATE QUANTITY ORDERED
            if (countMap.get(diObj.Id + 'quantOrdered') != null)
            {
                diObj.Quantity_Ordered__c = countMap.get(diObj.Id + 'quantOrdered');
            }
            
            //ADD DI RECORD TO UPDATE LIST
            assetToUpdate.add(diObj);
            
        }
        
        if (!assetToUpdate.isEmpty())
        {
            update assetToUpdate;
        }
        
    }
    
    
    public static String FileSizeToString(Long Value)
    {
        
        // string representation if a file's size, such as 2 KB, 4.1 MB, etc
        
        if (Value < 1024)
        {
            return string.valueOf(Value) + ' Bytes';
        }           
        else if (Value >= 1024 && Value < (1024 * 1024))
        {
            // KB
            Decimal kb = Decimal.valueOf(Value);
            kb = kb.divide(1024, 2);
            return string.valueOf(kb) + ' KB';
        }
        else if (Value >= (1024 * 1024) && Value < (1024 * 1024 * 1024))
        {
            // MB
            Decimal mb = Decimal.valueOf(Value);
            mb = mb.divide((1024 * 1024), 2);
            return string.valueOf(mb) + ' MB';
        }
        else
        {
            // GB
            Decimal gb = Decimal.valueOf(Value);
            gb = gb.divide((1024 * 1024 * 1024), 2);
            return string.valueOf(gb) + ' GB';
        }  
        
    }
    
    // ============================================================================================================================================    
    // INNER CLASS CONSTRUCTS    
    // ============================================================================================================================================    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
/*
 
    // Map<String,List<String>> GetDependentOptions (String pObjName, String pControllingFieldName, String pDependentFieldName)
    // Returns: Map of "pControllingFieldName" picklist values and their corresponding "pDependentFieldName" dependent option values.

    // Converts a base64 string into a list of integers representing the encoded bytes
    public static List<Integer> B64ToBytes (String sIn) 
    {
        
        Map<Integer,Integer> base64 = new Map<Integer,Integer>{65=>0,66=>1,67=>2,68=>3,69=>4,70=>5,71=>6,72=>7,73=>8,74=>9,75=>10,76=>11,77=>12,78=>13,79=>14,80=>15,81=>16,82=>17,83=>18,84=>19,85=>20,86=>21,87=>22,88=>23,89=>24,90=>25
            ,97=>26,98=>27,99=>28,100=>29,101=>30,102=>31,103=>32,104=>33,105=>34,106=>35,107=>36,108=>37,109=>38,110=>39,111=>40,112=>41,113=>42,114=>43,115=>44,116=>45,117=>46,118=>47,119=>48,120=>49,121=>50,122=>51
            ,48=>52,49=>53,50=>54,51=>55,52=>56,53=>57,54=>58,55=>59,56=>60,57=>61,43=>62,47=>63};
                
        List<Integer> lstOut = new List<Integer>();
        if (sIn == null || sIn == '') return lstOut;
        
        sIn += '='.repeat( 4 - Math.mod( sIn.length(), 4) );
        
        for ( Integer idx=0; idx < sIn.length(); idx += 4 ) {
            if ( base64.get(sIn.charAt(idx+1)) != null ) lstOut.add( (base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx+1)) >>> 4) );
            if ( base64.get(sIn.charAt(idx+2)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+1)) & 15)<<4) | (base64.get(sIn.charAt(idx+2)) >>> 2) );
            if ( base64.get(sIn.charAt(idx+3)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+2)) & 3)<<6) | base64.get(sIn.charAt(idx+3)) );
        }

        return lstOut;
        
    }
    
//    public static List<Integer> BlobToBytes (Blob input) 
//    {
//        return B64ToBytes(EncodingUtil.base64Encode(input));
//    }
    
    // Converts a base64 string into a list of integers indicating at which position the bits are on
    public static List<Integer> cnvBits (String b64Str) 
    {
        
        List<Integer> lstOut = new List<Integer>();
        
        if (b64Str == null || b64Str == '') 
        {
            return lstOut;
        }

        List<Integer> lstBytes = B64ToBytes(b64Str);
        
        Integer i, b, v;
        for (i = 0; i < lstBytes.size(); i++) 
        {
            v = lstBytes[i];
            for (b = 1; b <= 8; b++) 
            {
                if ((v & 128) == 128) lstOut.add((i * 8) + b);
                v <<= 1;
            }
        }

        return lstOut;
        
    }

    public static Map<String, List<String>> GetDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName) 
    {
        
        Map<String,List<String>> mapResults = new Map<String,List<String>>();
        
        //verify/get object schema
        Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
        if (pType == null) 
        {
            return mapResults;
        }
            
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        
        //verify field names
        if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) 
        {
            return mapResults;  
        }

        //get the control & dependent values   
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
        
        //clear heap
        objFieldMap = null;
        
        //initialize results mapping
        for (Integer pControllingIndex = 0; pControllingIndex < ctrl_ple.size(); pControllingIndex++)
        {           
            mapResults.put(ctrl_ple[pControllingIndex].getLabel(), new List<String>());
        }
        
        //cater for null and empty
        mapResults.put('', new List<String>());
        mapResults.put(null, new List<String>());
        
        //serialize dep entries        
        List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();
        objDS_Entries = (List<TPicklistEntry>)JSON.deserialize(JSON.serialize(dep_ple), List<TPicklistEntry>.class);
        
        List<Integer> validIndexes;
        for (TPicklistEntry objDepPLE : objDS_Entries)
        {
            
            validIndexes = cnvBits(objDepPLE.validFor);

            for (Integer validIndex : validIndexes)
            {                
                mapResults.get(ctrl_ple[validIndex-1].getLabel()).add(objDepPLE.label);
            }
            
        }
        
        //clear heap
        objDS_Entries = null;
        
        return mapResults;
        
    }    
    
    
    // Entity to represent a json version of a picklist entry so that the validFor property becomes exposed
    public class TPicklistEntry
    {
        public string active {get; set;}
        public string defaultValue {get; set;}
        public string label {get; set;}
        public string value {get; set;}
        public string validFor {get; set;}
        
        public TPicklistEntry()
        {
            
        }
        
    }
*/
    
}