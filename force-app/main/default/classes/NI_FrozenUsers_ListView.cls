/**************************************************************************************************************************
Name            : NI_FrozenUsers Class
Author          : Stuart Emery
Created Date    : 5/28/2014
Last Mod Date   : 5/28/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-010421
Description     : Controller for the NI_FrozenUsers Visualforce pages 
                : Display the Active Users that are Frozen  
                              
/**************************************************************************************************************************/

public with sharing class NI_FrozenUsers_ListView 
{
    private final User usr;  

    public NI_FrozenUsers_ListView(ApexPages.StandardSetController controller) {
        this.usr = (User)controller.getRecord(); 
    }    
    
    public ApexPages.StandardSetController UserRecords {
        get {
            if(UserRecords == null) {
                UserRecords = new ApexPages.StandardSetController(
                    Database.getQueryLocator([SELECT Id, Name, UserName, LastLoginDate, Profile.Name, UserType, Xactly_User__c, IsActive 
                                              FROM User
                                              WHERE Id IN (SELECT UserId FROM UserLogin WHERE IsFrozen = true)
                                              ORDER BY Name ASC]));
                                              
            }
            return UserRecords;
         }   
            
        private set;
    }
    public List<User> getNI_FrozenUsers_ListView() {
    
        if (UserRecords.getResultSize()<1)
               {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'There Are No Frozen Users'));
               }
             else
               {    
                 return (List<User>) UserRecords.getRecords();
               }  
    
         return null;
         
    }  
}