/************************************************************************************************
Name            : NI_User_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 03/12/2015
Last Mod Date   : 04/18/2020 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all trigger code for the User Object
				:






				MOVED TO AH_User_TriggerHandler









*************************************************************************************************/
public class NI_User_TriggerHandler 
{

    //private NI_TriggerBypassSwitches__c bpSwitch {get; set;}

    public NI_User_TriggerHandler()
    { 

        //system.debug(' *** ENTERING NI_User_TriggerHandler - CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        //bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();  
        
        //system.debug(' *** EXITING NI_User_TriggerHandler - CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
/*    
    // ======================================================================================
    //  TRIGGER HANDLER ENTRY METHODS
    // ======================================================================================    
    public void OnBeforeInsert(List<User> newTrigger)
    {   
        
        system.debug(' *** ENTERING NI_User_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.Bypass_User_ON__c)
        {
            validateUserProfiles(newTrigger);
            CostControlUpdate(newTrigger);
        }
        
        system.debug(' *** EXITING NI_User_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

    public void OnAfterInsert(List<User> newTrigger)
    {     
        
        system.debug(' *** ENTERING NI_User_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.Bypass_User_ON__c)
        {
            managePartnerUserFields(newTrigger);
        }
        
        system.debug(' *** EXITING NI_User_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }    

    public void OnBeforeUpdate(List<User> newTrigger, Map<Id,User> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING NI_User_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
		
        if (!bpSwitch.Bypass_User_ON__c)
        {
            
            validateUserProfiles(newTrigger);
            
            List<User> validUsers = new List<User>();
            
            for (User usr: newTrigger)
            {
                User oldUser = oldMapTrigger.get(usr.Id);
                if (usr.FFA_Company__c != oldUser.FFA_Company__c ||
                    usr.FFA_Dimension_2__c != oldUser.FFA_Dimension_2__c ||
                    usr.FFA_Dimension_3__c != oldUser.FFA_Dimension_3__c)
                {
                    validUsers.add(usr);
                }
            }
            
            if (!validUsers.isEmpty())
            {
                CostControlUpdate(validUsers);       
            }
            
        }
        
        system.debug(' *** EXITING NI_User_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
    
    public void OnAfterUpdate(List<User> newTrigger, Map<Id,User> oldMapTrigger)
    {  
        
        system.debug(' *** ENTERING NI_User_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
		
        if (!bpSwitch.Bypass_User_ON__c)
        {
            
            // CREATE A LIST TO HOLD ALL USER RECORDS THAT NEED TO BE FROZEN
            List<User> lstUsersToFreeze = new List<User>();
            
            // CREATE A LIST TO HOLD ALL USER RECORDS WHOSE MANAGER HAS CHANGED
            List<User> lstManagerChange = new List<User>();
            
            // CREATE A LIST TO HOLD ALL USER RECORDS WHOSE EMAIL HAS CHANGED (FOR COMMUNITY USERS ONLY)
            List<User> lstEmailChange = new List<User>();
            
            for (User u : newTrigger) 
            {
                
                User oldUsr = oldMapTrigger.get(u.Id);
                
                // IF THE USER'S FREEZE USER GOT CHECKED, ADD THEM TO LIST
                if (u.Freeze_User__c == true && u.Freeze_User__c != oldUsr.Freeze_User__c)
                {
                    lstUsersToFreeze.add(u);
                }
                
                // IF THE USER'S MANAGER HAS CHANGED, ADD THEM TO LIST
                if (u.ManagerId != oldUsr.ManagerId)
                {
                    lstManagerChange.add(u);
                }
                
                // IF THE USER'S EMAIL HAS CHANGED, ADD THEM TO LIST
                if (u.Email != oldUsr.Email && u.ContactId != null)
                {
                    lstEmailChange.add(u);
                }
                
            }      
            
            // CALL THE FREEZE USER METHOD
            if (lstUsersToFreeze.size() > 0)
            {  
                freezeUser(lstUsersToFreeze);
            }
            
            // CALL THE CHANGE MANAGER SHARE METHOD
            if (lstManagerChange.size() > 0)
            {  
                Change_Manager_PerformanceEval_Share(lstManagerChange);
            }
            
            // UPDATE CONTACT INFO WHEN EXTERNAL USER UPDATES THEIR USER RECORD
            if (NI_TriggerManager.isFirstTime == true)
            {
                // ENSURES THIS ONLY FIRES ONCE
                NI_TriggerManager.isFirstTime = false;
                // IF THE FIRST RECORD IN THE TRIGGER BELONGS TO RUNNING USER
                if (newTrigger[0].Id == userinfo.getUserId())
                {                
                    // GET PROFILE TO CHECK IF THE RUNNING USER IS A COMMUNITY USER
                    Profile targetUserProfile = [SELECT Id, Name, UserType FROM Profile WHERE Id =: userinfo.getProfileId() LIMIT 1]; 
                    if ((targetUserProfile.UserType == 'PowerCustomerSuccess') || 
                        (targetUserProfile.UserType == 'PowerPartner') || 
                        (targetUserProfile.UserType == 'CustomerSuccess') ||
                        (targetUserProfile.UserType == 'CSPLitePortal') 
                       )
                    {
                        updateContactFields(userinfo.getUserId());
                    }
                }
                
                system.debug(' **** lstEmailChange.size() = ' + lstEmailChange.size()); 
                system.debug(' **** FIRST USER IN EMAIL CHANGE LIST = ' + newTrigger[0].Username); 
                
                if (!lstEmailChange.isEmpty()) 
                {                     
                    syncContactEmails(lstEmailChange); 
                }
                
            }
            
        }
        
        system.debug(' *** EXITING NI_User_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

        
    // ======================================================================================
    //  TRIGGER HANDLER FUNCTIONS
    // ======================================================================================    
    private void freezeUser(List<User> newTrigger)
    {
        
        system.debug(' *** ENTERING NI_User_TriggerHandler.freezeUser() - QUERIES ISSUED = ' + Limits.getQueries());
		
        //LIST OF USERLOGIN RECORDS TO FREEZE
        List<UserLogin> lstUserLoginToUpdate = new List<UserLogin>();
        
        //CREATE A SET TO HOLD ALL OF THE UNIQUE USER IDs
        Set<Id> setUsersToDisable = new Set<Id>();
        
        for (User u : newTrigger) 
        {
            setUsersToDisable.add(u.Id);                
        }
        
        //LIST OF ALL USERS IN THE SET
        List<UserLogin> lstUserLogin = [SELECT Id, UserId, IsFrozen 
                                        FROM UserLogin 
                                        WHERE IsFrozen = false
                                        AND UserId IN : setUsersToDisable];
        
        for (UserLogin ul : lstUserLogin)
        {
            ul.IsFrozen = true;
            lstUserLoginToUpdate.add(ul);
        }
        
        //USE DATABASE DML METHOD TO UPDATE THE USER RECORDS
        
        //SET TO HOLD THE IDs OF THE USERS THAT WERE SUCCESSFULLY FROZEN
        Set<Id> setSuccess = new Set<Id>();
        
        if (lstUserLoginToUpdate.size() > 0)
        {
            Database.SaveResult[] results = Database.update(lstUserLoginToUpdate,true);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    system.debug(err.getMessage());
                }
                else
                {
                    setSuccess.add(sr.getId());
                    system.debug('SUCCESSFULLY FROZE USER ID: ' + sr.getId());   
                } 
            }
        } 
        
        system.debug(' *** EXITING NI_User_TriggerHandler.freezeUser() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
    
    private void Change_Manager_PerformanceEval_Share(List<User> newTrigger)
    {   
        
        // NI EMPLOYEE PERFORMANCE EVALUATIONS CHANGE MANAGER SHARE
		
        system.debug(' *** ENTERING NI_User_TriggerHandler.Change_Manager_PerformanceEval_Share() - QUERIES ISSUED = ' + Limits.getQueries());
		
        List<User> lstUsers = [SELECT Id, ManagerId, Manager.ManagerId
                               FROM User
                               WHERE Id IN: newTrigger];
        
        Set<Id> setPerfEvalId = new Set<Id>();
        
        List<NI_Employee_Performance_Evaluation__c> lstUserPerfEvals = [SELECT Id,Employee_Name__c 
                                                                        FROM NI_Employee_Performance_Evaluation__c
                                                                        WHERE Employee_Name__c IN: newTrigger];
        
        // LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Employee_Performance_Evaluation__Share> lstSharesToRemove = new List<NI_Employee_Performance_Evaluation__Share>([
            SELECT Id
            FROM NI_Employee_Performance_Evaluation__Share
            WHERE ParentId IN : lstUserPerfEvals 
            AND RowCause = 'Manager_Change__c']); 
        
        // BULK REMOVE SHARE RECORDS
        if (lstSharesToRemove.size() > 0)
        {
            Database.DeleteResult[] drList = Database.delete(lstSharesToRemove, false);
            for (Database.DeleteResult dr : drList) 
            {
                if (dr.isSuccess()) 
                {
                    System.debug('**SUCCESSFULLY DELETED SHARE RECORD ID: ' + dr.getId());
                }
                else 
                {
                    Database.Error err = dr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }        
        }
        
        //LIST OF SHARES THAT NEED TO BE ADDED   
        List<NI_Employee_Performance_Evaluation__Share> lstSharesToInsert = new List<NI_Employee_Performance_Evaluation__Share>();
        
        for (User u : lstUsers)
        {
            for (NI_Employee_Performance_Evaluation__c pe : lstUserPerfEvals)
            {
                if (u.Id == pe.Employee_Name__c)
                {
                    NI_Employee_Performance_Evaluation__Share peManagerShare = new NI_Employee_Performance_Evaluation__Share();
                    peManagerShare.ParentId = pe.Id;
                    peManagerShare.UserOrGroupId = u.ManagerId;
                    peManagerShare.AccessLevel = 'Read';
                    peManagerShare.RowCause = Schema.NI_Employee_Performance_Evaluation__Share.RowCause.Manager_Change__c;
                    lstSharesToInsert.add(peManagerShare);
                }
            }
        }
        
        //USE DATABASE DML METHOD TO ADD THE SHARES
        if (lstSharesToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstSharesToInsert,true);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }
        } 
        
        system.debug(' *** EXITING NI_User_TriggerHandler.Change_Manager_PerformanceEval_Share() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
       
    private void CostControlUpdate(List<User> newTrigger)
    { 
        
        // AH User Cost Control information from Amadeus Mapping 
        // Sprint-00077 
		
        system.debug(' *** ENTERING NI_User_TriggerHandler.CostControlUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
		
        // Hold new user information 
        Set<String> companySet = new Set<String>();
        Set<String> dimension2Set = new Set<String>();
        Set<String> dimension3Set = new Set<String>();

        for (User u : newTrigger)
        {
            if (u.FFA_Company__c != null && u.FFA_Company__c != '')
            {
                companySet.add(u.FFA_Company__c);
            }
            if (u.FFA_Dimension_2__c != null && u.FFA_Dimension_2__c != '')
            {
                dimension2Set.add(u.FFA_Dimension_2__c);
            } 
            if (u.FFA_Dimension_3__c != null && u.FFA_Dimension_3__c != '')
            {
                dimension3Set.add(u.FFA_Dimension_3__c);   
            }
        }
        
        List <Amadeus_Mapping_Table__c> amtList = new list <Amadeus_Mapping_Table__c>(); 
        
        // Check user information is matched with Amadeus mapping
        if (companySet.size() > 0 || 
            dimension2Set.size() > 0 || 
            dimension3Set.size() > 0)
        {
            amtList = [SELECT Id, FFA_Company__r.Name, Cost_Center_Dim_3__r.name, Business_Line_Dim_2__r.Name, Output__c 
                       FROM Amadeus_Mapping_Table__c 
                       WHERE Mapping_Type__c = 'BPC COST CENTER' 
                       OR FFA_Company__r.Name IN : companySet 
                       OR Cost_Center_Dim_3__r.Name IN : dimension3Set OR Business_Line_Dim_2__r.Name IN : dimension2Set];
        }

        for (User usr: newTrigger)
        {
            for (Amadeus_Mapping_Table__c amtData : amtList)
            {   
                if ((usr.FFA_Company__c == amtData.FFA_Company__r.Name) && 
                    (usr.FFA_Dimension_3__c == amtData.Cost_Center_Dim_3__r.name) && 
                    (usr.FFA_Dimension_2__c == amtData.Business_Line_Dim_2__r.Name))
                {
                    if (amtData.Output__c != null)           
                    {
                        usr.Cost_Ctr__c = amtData.Output__c;
                        usr.Controlling_Verified__c =False;
                        
                    }
                    else
                    {
                        usr.Cost_Ctr__c = '';
                        usr.Controlling_Verified__c = false;
                    }                    
                    break;
                }
                else
                {
                    usr.Cost_Ctr__c = '';
                    usr.Controlling_Verified__c =False;
                }
                
            }
            
        }
        
        system.debug(' *** EXITING NI_User_TriggerHandler.CostControlUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
    
    private void managePartnerUserFields(List<User> newTrigger)
    {
        
        // INTENTIONALLY NOT BULKIFIED
        
        system.debug(' *** ENTERING NI_User_TriggerHandler.managePartnerUserFields() - QUERIES ISSUED = ' + Limits.getQueries());
		
        // IF AccountId EXISTS THEN IT IS A NON-INTERNAL USER
        if (newTrigger[0].get('AccountId') != null)
        {
            
            Id accId = (Id)newTrigger[0].get('AccountId');
            
            Set<Id> setUserIds = new Set<Id>(); 
            for (User u : [SELECT Id, ProfileId FROM User WHERE Profile.UserType = 'PowerPartner' AND AccountId =: accId])
            {
                setUserIds.add(u.Id);
            } 
            
            if (NI_FUNCTIONS.allFormsAccepted(accId))
            {                
                NI_FUNCTIONS.bulkChangePartnerFieldsOnUser(accId, setUserIds, 'True', null); 
            }
            else
            {                
                NI_FUNCTIONS.bulkChangePartnerFieldsOnUser(accId, setUserIds, 'False', null); 
            }
            
        }
        
        system.debug(' *** EXITING NI_User_TriggerHandler.managePartnerUserFields() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

    private void validateUserProfiles(List<User> newTrigger)
    {
		
        system.debug(' *** ENTERING NI_User_TriggerHandler.validateUserProfiles() - QUERIES ISSUED = ' + Limits.getQueries());
		
        if (newTrigger.size() == 1)
        {
            
            // ONLY VALIDATE PARTNER & SUPPORT COMMUNITY USER  
            
            Profile targetUserProfile = [SELECT Id, Name, UserType FROM Profile WHERE Id =: newTrigger[0].ProfileId LIMIT 1]; 
            
            if ((targetUserProfile.UserType == 'PowerCustomerSuccess') || 
                (targetUserProfile.UserType == 'PowerPartner') || 
                (targetUserProfile.UserType == 'CustomerSuccess') ||
                (targetUserProfile.UserType == 'CSPLitePortal') 
               )
            {
                    
                Profile runningUserProfile = [SELECT Id, Name FROM Profile WHERE Id =: userinfo.getProfileId() LIMIT 1];
    
                // SYS ADMIN OVERRIDE. ADDED EXCEPTION SO THAT EXTERNAL USERS CAN CHANGE THEIR OWN USER RECORD INFO
                if (runningUserProfile.Name != 'System Administrator' && newTrigger[0].Id != userinfo.getUserId())
                {
    
                    List<Create_External_User_Setting__mdt> cs = new List<Create_External_User_Setting__mdt>(
                        [SELECT Allowed_External_Users_Profiles__c 
                         FROM Create_External_User_Setting__mdt
                         WHERE Running_Users_Profile__c =: runningUserProfile.Name 
                         LIMIT 1]);
                    
                    if (cs.size() > 0)
                    {
                        
//                        Profile targetUserProfile = [SELECT Id, Name FROM Profile WHERE Id =: newTrigger[0].ProfileId LIMIT 1];
                        string strAllowedExternalUsersProfileNames = cs[0].Allowed_External_Users_Profiles__c;
                        
                        if (!strAllowedExternalUsersProfileNames.contains(targetUserProfile.Name))
                        {
                            string strError = 'You do not have permission to create or save a user with the profile of ' + targetUserProfile.Name + '. ';
                            strError += 'You can only select the following profiles: ' + strAllowedExternalUsersProfileNames;
                            newTrigger[0].addError(strError);
                        }                  
                    }
                    else
                    {
                        string strError = 'Your profile "' + runningUserProfile.Name + '" does not have permission to create or save user records. ';
                        strError += 'Please place a ticket with IT to have a Salesforce Administrator to update the Custom Metadata Type called ';
                        strError += '"Create External User Setting". ';
                        newTrigger[0].addError(strError);
                    }
                    
                }
                
            }
            
        } 
        
        system.debug(' *** EXITING NI_User_TriggerHandler.validateUserProfiles() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

	private void updateContactFields(String userId)
    {
        
        // A FUNCTION THAT UPDATES SPECIFIC FIELDS ON RELATED CONTACT RECORD WHEN A COMMUNITY USER UPDATES THEIR PERSONAL INFO IN THE COMMUNITY
        
        system.debug(' *** ENTERING NI_User_TriggerHandler.updateContactFields() - QUERIES ISSUED = ' + Limits.getQueries());
		
        User u;
        Contact c;
        
        try
        {
            
            u = [SELECT ContactId, Email, FirstName, LastName, Title, Street, State, City, PostalCode, Country, Phone, MobilePhone, Fax 
                 FROM User 
                 WHERE IsActive = true AND Id =: userId];
            
            if (u != null && u.ContactId != null) 
            {
                
                c = [SELECT Id, FirstName, LastName, Email, Title, MailingStreet, MailingState, MailingCity, MailingPostalCode, MailingCountry, Phone, MobilePhone, Fax 
                     FROM Contact 
                     WHERE Id =: u.ContactId];
                
                if (c.FirstName != u.FirstName)
                {
                    c.FirstName = u.FirstName;
                }
                if (c.LastName != u.LastName)
                {
                    c.LastName = u.LastName;
                }
                if (c.Email != u.Email)
                {
                    c.Email = u.Email;
                }
                if (c.Title != u.Title)
                {
                    c.Title = u.Title;
                }
                if (c.MailingStreet != u.Street)
                {
                    c.MailingStreet = u.Street;
                }
                if (c.MailingCity != u.City)
                {
                    c.MailingCity = u.City;
                }                
                if (c.MailingState != u.State)
                {
                    c.MailingState = u.State;
                }
                if (c.MailingPostalCode != u.PostalCode)
                {
                    c.MailingPostalCode = u.PostalCode;
                }
                //if (c.MailingCountry != u.Country)
                //{
                //    c.MailingCountry = u.Country;
                //}
                if (c.Phone != u.Phone)
                {
                    c.Phone = u.Phone;
                }
                if (c.MobilePhone != u.MobilePhone)
                {
                    c.MobilePhone = u.MobilePhone;
                }
                if (c.Fax != u.Fax)
                {
                    c.Fax = u.Fax;
                }

                update c; 
            }            
        }
		catch (Exception e) 
        { 
            String sErrMsg = ' **** ERROR OCCURRED: Line ' + e.getLineNumber() + ' - ' + e.getMessage();
            system.debug(sErrMsg); 
			postToChatterGroup(u.Id, sErrMsg, c.Id);   
        }
        
        system.debug(' *** EXITING NI_User_TriggerHandler.updateContactFields() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
	
    @testVisible
    private void postToChatterGroup(Id userId, String strMsg, Id contactId)
    {
        // A FUNCTION FOR POSTING TO CHATTER GROUP WHEN A COMMUNITY USER UPDATES THEIR USER INFO BUT FAILS TO UPDATE THE SPECIFIED RELATED CONTACT FIELDS
        // THIS CAN HAPPEN BECAUSE OF A VALIATION RULE. ALERTS MEMBERS OF CHATTER GROUP TO MANUALLY UPDATE CONTACT RECORD
        // CHATTER GROUP ID IS STORED IN CUSTOM LABEL
        
        system.debug(' *** ENTERING NI_User_TriggerHandler.postToChatterGroup() - QUERIES ISSUED = ' + Limits.getQueries());
		
        FeedItem post = new FeedItem();
        
        string sBaseURL = system.Url.getSalesforceBaseUrl().toExternalForm();
        string sInstName = sBaseURL.substring(sBaseURL.IndexOf('amadeus-community.') + 18);
		sInstName = sInstName.substring(0, sInstName.IndexOf('.'));
        string sURL = 'https://' + sInstName + '.salesforce.com/';
        
        post.ParentId = Label.Community_User_Update_Error_Chatter_Group;
        String strBody = 'An error occurred when a contact record sync attempt was made after a community user updated their user information in the community.\n'; 
        strBody += 'Please manually sync the new personal information on contact record to the user record.\n\n';
        strBody += 'Community User: ' + sURL + userId + '\n'; 
        strBody += 'Contact Record: ' + sURL + contactId + '\n\n'; 
        strBody += strMsg + '\n\n'; 
        post.Body = strBody; 
        
        insert post;
        
        system.debug(' *** EXITING NI_User_TriggerHandler.postToChatterGroup() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

    @testVisible
   	private void syncContactEmails(List<User> lstUsrs)
    {
        
        // A FUNCTION TO UPDATE THE CONTACT EMAIL ADDRESS AFTER A COMMUNITY USER AUTHORIZES THE EMAIL CHANGE ON USER RECORD VIA THE EMAILED LINK
        
        system.debug(' *** ENTERING NI_User_TriggerHandler.syncContactEmails() - QUERIES ISSUED = ' + Limits.getQueries());
		
        try
        {
            Set<Id> setIds = new Set<Id>(); 
            for (User u : lstUsrs)
            {
                setIds.add(u.ContactId); 
            }
            
            List<Contact> lstContactUpdates = new List<Contact>(); 
            
            for (Contact cnt : [SELECT Id, Email FROM Contact WHERE Id IN : setIds])
            {
                for (User usr : lstUsrs)
                {
                    if (cnt.Id == usr.ContactId)
                    {
                        Contact c = new Contact();
                        c.Id = cnt.Id;
                        c.Email = usr.Email;
                        lstContactUpdates.add(c);
                    }
                }
            } 
          
            database.update(lstContactUpdates);
            
        }
		catch (exception e)
        {

        }        
        
        system.debug(' *** EXITING NI_User_TriggerHandler.syncContactEmails() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
*/
    
}