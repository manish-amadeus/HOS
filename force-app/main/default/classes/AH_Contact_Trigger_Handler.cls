/***********************************************************************************************
Name            : AH_Contact_Trigger_Handler
Author          : Shashikant Nikam
Created Date    : 04/04/2018
Last Mod Date   : 04/26/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-027123
Description     : This class handles all the trigger code for the Contact object
                :
                :
************************************************************************************************/
public class AH_Contact_Trigger_Handler 
{
    
    //VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    
    public AH_Contact_Trigger_Handler()
    {
        
        system.debug(' *** ENTERING AH_Contact_Trigger_Handler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries()); 
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();          
        
        system.debug(' *** EXITING AH_Contact_Trigger_Handler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries()); 
        
    }
    
    
    // ========================================================================================================================
    //  ENTRY METHODS 
    // ========================================================================================================================       
    public void OnBeforeInsert(List<Contact> newTrigger) 
    {
        
        system.debug(' *** ENTERING AH_Contact_Trigger_Handler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

        system.debug(' *** EXITING AH_Contact_Trigger_Handler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnBeforeUpdate(List<Contact> newTrigger, Map<Id, Contact> oldMapTrigger) 
    {
        
        system.debug(' *** ENTERING AH_Contact_Trigger_Handler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

        system.debug(' *** EXITING AH_Contact_Trigger_Handler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterInsert(List<Contact> newTrigger) 
    {
        
        system.debug(' *** ENTERING AH_Contact_Trigger_Handler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());

        if (!bpSwitch.Bypass_Contact__c)
        {
            
            // CANCELLATION USERS
            List<Contact> lstValidCxlUserContacts = new List<Contact>();
            for (Contact cnt : newTrigger)
            {
                // IF Cancellation User CHECKBOX IS CHECKED
                if (cnt.Cancellation_User__c == true)
                {
                    lstValidCxlUserContacts.add(cnt);
                }
            }
            if (!lstValidCxlUserContacts.isEmpty())
            {
                createCommunityUsers(lstValidCxlUserContacts);
            }
            
            
            // SUNSET CONTACT CODE 
            if (!bpSwitch.BypassContactSunsetContact__c)
            {
                
                Set<Id> accountList = new Set<Id>();
                
                // CHECK IF Sunset_Contact__c = "TRUE" ON CONTACT. IF YES, CREATE LIST OF ACCOUNTS TO BE PROCESSED
                for (Contact c : newTrigger) 
                {
                    if (c.Sunset_Contact__c == true) 
                    {
                        accountList.add(c.AccountId);
                    }
                }
                
                // CALL METHOD TO SET Has_Sunset_Contact__c FLAG ON ACCOUNTS
                if (!accountList.isEmpty()) 
                {
                    updateAccForHasSunset(accountList);
                }  
                
            }  
            
        }
        
        system.debug(' *** EXITING AH_Contact_Trigger_Handler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterUpdate(List<Contact> newTrigger, Map<Id, Contact> oldMapTrigger) 
    {
        
        system.debug(' *** ENTERING AH_Contact_Trigger_Handler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.Bypass_Contact__c)
        {   
            
            // CANCELLATION USERS
            List<Contact> lstValidCxlUserContacts = new List<Contact>();
            for (Contact cnt : newTrigger)
            {
                Contact oldCnt = oldMapTrigger.get(cnt.Id);
                // IF Cancellation User CHECKBOX WAS CHANGED FROM UNCHECKED TO CHECKED
                if (cnt.Cancellation_User__c != oldCnt.Cancellation_User__c)
                {
                    lstValidCxlUserContacts.add(cnt);
                }
            }
            if (!lstValidCxlUserContacts.isEmpty())
            {
                createCommunityUsers(lstValidCxlUserContacts);
            }
            
            // SUNSET CONTACT CODE 
            if (!bpSwitch.BypassContactSunsetContact__c)
            {
                
                Set<Id> accountListToSet = new Set<Id>();
                
                // CREATE LIST OF ACCOUNTS TO BE PROCESSED
                for (Contact c : newTrigger) 
                {
                    if (c.Sunset_Contact__c != oldMapTrigger.get(c.Id).Sunset_Contact__c) 
                    {
                        accountListToSet.add(c.AccountId);
                    }
                }
                
                if (!accountListToSet.isEmpty()) 
                {
                    updateAccForHasSunset(accountListToSet);
                }
                
            }
            
        }
        
        system.debug(' *** EXITING AH_Contact_Trigger_Handler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterDelete(List<Contact> oldTrigger) 
    {
        
        system.debug(' *** ENTERING AH_Contact_Trigger_Handler.OnAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.Bypass_Contact__c)
        {   
            
            // SUNSET CONTACT CODE 
            if (!bpSwitch.BypassContactSunsetContact__c)
            {
                
                Set<Id> accountList = new Set<Id>();
                
                // CREATE LIST OF ACCOUNTS TO BE PROCESSED
                for (Contact c : oldTrigger) 
                {
                    if (c.Sunset_Contact__c == true) 
                    {
                        accountList.add(c.AccountId);
                    }
                }
                
                // CALL METHOD TO UPDATE ACCOUNTS
                if (!accountList.isEmpty() && !NI_FUNCTIONS.bypassTriggerCode('SUNSET CONTACT')) 
                {
                    updateAccForHasSunset(accountList);
                }
                
            }
            
        }
        
        system.debug(' *** EXITING AH_Contact_Trigger_Handler.OnAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterUnDelete(List<Contact> newTrigger) 
    {
        
        system.debug(' *** ENTERING AH_Contact_Trigger_Handler.OnAfterUnDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.Bypass_Contact__c)
        {   
            
            // SUNSET CONTACT CODE 
            if (!bpSwitch.BypassContactSunsetContact__c)
            {
                
                Set<Id> accountList = new Set<Id>();
                
                // CREATE LIST OF ACCOUNTS TO BE PROCESSED
                for (Contact c : newTrigger) 
                {
                    if (c.Sunset_Contact__c == true) 
                    {
                        accountList.add(c.AccountId);
                    }
                }
                
                // CALL METHOD TO UPDATE ACCOUNTS
                if (!accountList.isEmpty() && !NI_FUNCTIONS.bypassTriggerCode('SUNSET CONTACT')) 
                {
                    updateAccForHasSunset(accountList);
                }
                
            }
            
        }
        
        system.debug(' *** EXITING AH_Contact_Trigger_Handler.OnAfterUnDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    
    // ========================================================================================================================
    //  HANDLER METHODS/FUNCTIONS 
    // ========================================================================================================================  
    public void updateAccForHasSunset (Set<Id> ActList)
    {
        
        system.debug(' *** ENTERING AH_Contact_Trigger_Handler.updateAccForHasSunset() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<Account> actListToUpdate = new List<Account>();
        
        if (ActList != null)
        {
            // ITERATE OVER ACCOUNT FOR Has_Sunset_Contact__c FIELD UPDATION
            List<Account> act_list = [SELECT Id, Name, Has_Sunset_Contact__c, 
                                      (SELECT Id, Sunset_Contact__c FROM Contacts WHERE AccountId IN : ActList AND Sunset_Contact__c = true)
                                      FROM Account 
                                      WHERE Id IN : ActList];
            
            for (Account act : act_list) 
            {
                if (act.Contacts.size() == 0) 
                {
                    if (act.Has_Sunset_Contact__c == true)
                    {
                        act.Has_Sunset_Contact__c = false;
                        actListToUpdate.add(act);
                    }
                }
                else
                {
                    if (act.Contacts.size() > 0) 
                    {
                        if (act.Has_Sunset_Contact__c == false)
                        {
                            act.Has_Sunset_Contact__c = true;
                            actListToUpdate.add(act);
                        }
                    }                   
                }
            }
        }
        
        // UPDATE LIST OF Accounts DML OPERATION
        if (!actListToUpdate.isEmpty())
        {
            update actListToUpdate;
        }
        
        system.debug(' *** EXITING AH_Contact_Trigger_Handler.updateAccForHasSunset() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void createCommunityUsers(List<Contact> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_Contact_Trigger_Handler.createCommunityUsers() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // QUERY FOR DEFAULT "CANCELLATION" USER PROFILE THAT IS DEFINED IN A CUSTOM LABEL
        Profile prf = [SELECT Id FROM Profile WHERE Name =: Label.Community_User_From_Contact_Default_Profile];
        
        // GET A LIST OF ACTIVE USERS HAVING THE DEFAULT "CANCELLATION" USER PROFILE
        List<User> lstUsers = new List<User>([SELECT Id, ContactId 
                                              FROM User 
                                              WHERE AccountId != null AND IsActive = true AND ContactId IN : newTrigger]); // AND ProfileId = : prf.Id]);
        
        // SET TO CONTAIN CONTACT IDS FOUND IN lstUsers LIST
        Set<Id> setContactWithUserAcctIds = new Set<Id>();
        
        // MAP TO CONTAIN USER RECORDS (WITH CONTACT ID AS KEY) FOUND IN lstUsers LIST
        Map<Id, Id> mapContact2UserIds = new Map<Id, Id>();
        
        for (User u : lstUsers)
        {
            setContactWithUserAcctIds.add(u.ContactId);
            mapContact2UserIds.put(u.ContactId, u.Id);
        }

        // LIST OF USERS FOR FINAL UPSERT
        List<User> lstUserUpserts = new List<User>();
        
        // LOOP THROUGH ALL CONTACTS IN THE TRIGGER
        for (Contact cnt : newTrigger)
        {
            
            String strCancellationUser = 'False';
            if (cnt.Cancellation_User__c == true)
            {
                strCancellationUser = 'True';
            }
            
            // IF CONTACT DOES NOT HAVE A COMMUNITY USER ACCOUNT
            if (!setContactWithUserAcctIds.contains(cnt.Id))
            {
                
				system.debug(' **** NO USER ACCOUNT FOUND. CREATE ONE **** '); 

                User newUsr = new User(); 
                
                newUsr.ProfileId = prf.Id; 
                newUsr.ContactId = cnt.Id; 
                newUsr.FirstName = cnt.FirstName; 
                newUsr.LastName = cnt.LastName; 
                newUsr.Email = cnt.Email; 
                newUsr.Username = cnt.Email + '.ahcc'; 
                newUsr.Cancellation_User__c = strCancellationUser; 
                
                string sFN = cnt.FirstName; 
                string sLN = cnt.LastName; 
                
                // ALIAS BUILDER - IF LAST NAME IS UNDER 4 CHARS, PAD IT WITH DIGITS
                if (sLN.length() < 4) 
                {
                    sLN += '12345'; 
                }
                
                // CREATES ALIAS BY TAKING 1st CHAR IN FIRST NAME AND FIRST 4 CHARS OF LAST NAME
                string sAlias = sFN.toLowerCase().substring(0, 1) + sLN.toLowerCase().substring(0, 4); 
                newUsr.Alias = sAlias; 
                
                newUsr.TimeZoneSidKey = 'America/New_York'; 
                newUsr.LocaleSidKey = 'en_US'; 
                newUsr.EmailEncodingKey = 'UTF-8'; 
                newUsr.LanguageLocaleKey = 'en_US'; 
                
                lstUserUpserts.add(newUsr); 
                
            }
            else
            {
                
                system.debug(' **** USER ACCOUNT FOUND - JUST UPDATE Cancellation_User__c PICKLIST ON USER RECORD **** ');                       
                
                User exUsr = new User();
                
                exUsr.Id = mapContact2UserIds.get(cnt.Id);
                exUsr.Cancellation_User__c = strCancellationUser;
                
                lstUserUpserts.add(exUsr);
                
            }
            
        }

        if (!lstUserUpserts.isEmpty())
        {
            database.upsert(lstUserUpserts);
        }
        
        system.debug(' *** EXITING AH_Contact_Trigger_Handler.createCommunityUsers() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

}