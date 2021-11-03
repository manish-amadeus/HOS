/****************************************************************************************
Name            : NI_FrozenUsers_ListView_Test Test Class
Author          : Stuart Emery
Created Date    : 5/28/2014
Last Mod Date   : 5/28/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-010421
Description     : Test Class for NI_FrozenUsers_ListView Class
                : 
                : 
******************************************************************************************/
@isTest (SeeAllData=false)
private class NI_FrozenUsers_ListView_Test 
{

    static testMethod void singleRecordFrozenUserTest() 
    {            
       
      //PAGE REFERENCE
        PageReference pageRef = Page.nifrozenusers;
        Test.setCurrentPage(pageRef);                 
      
      //CREATE A TEST USER  
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator'); 
        insert u;
        
      //GET THE USER LOGIN RECORD FOR THE USER WE CREATED
        UserLogin ul = [SELECT Id, UserId, IsFrozen FROM UserLogin WHERE UserId =: u.Id LIMIT 1];
        ul.IsFrozen = true;
        update ul;  
        
      //LIST OF INSERTED USERS
        List<User> lstInsertedUsers = [SELECT Id, Name 
                                       FROM User
                                       WHERE Id IN (SELECT UserId FROM UserLogin WHERE IsFrozen = true)];
                                       
      //VERIFY WE HAVE AT LEAST 1 USER RECORD THAT IS FROZEN  
        System.assert(lstInsertedUsers.size() >0);                                     
        
      //INSTANTIATE CONTROLLER
        NI_FrozenUsers_ListView ctrl = new NI_FrozenUsers_ListView(new ApexPages.StandardSetController(lstInsertedUsers));
        
        ctrl.getNI_FrozenUsers_ListView();
        
   }
   
//================================================================================================================================================

static testMethod void singleRecordNoFrozenUserTest() 
    {            
       
      //PAGE REFERENCE
        PageReference pageRef = Page.nifrozenusers;
        Test.setCurrentPage(pageRef);                 
        
      //GET THE CURRENT USER LOGIN RECORDS THAT ARE FROZEN
        List<UserLogin> lstUserLogin = [SELECT Id, UserId, IsFrozen FROM UserLogin WHERE IsFrozen = true];
        
      //LIST TO HOLD THE USER LOGIN RECORDS THAT WE ARE GOING TO UPDATE TO SET THE ISFROZEN FIELD TO FALSE  
        List<UserLogin> lstUsrLoginToUpdate = new List<UserLogin>();
        
      //LOOP THROUGH THE LIST OF USER LOGIN RECORDS AND SET THE ISFROZEN FIELD TO FALSE AND ADD THEM TO OUR LIST TO UPDATE  
        for(UserLogin ul : lstUserLogin)
           {
             ul.IsFrozen = false;
             lstUsrLoginToUpdate.add(ul);
           }
        Database.update(lstUsrLoginToUpdate);     
                
      //GET THE LIST OF USERS WHO ARE FROZEN
        List<User> lstInsertedUsers = [SELECT Id, Name 
                                       FROM User
                                       WHERE Id IN (SELECT UserId FROM UserLogin WHERE IsFrozen = true)];                                 
                                       
      //VERIFY THERE ARE NO FROZEN USERS  
        System.assertEquals(0,lstInsertedUsers.size());                                        
        
      //INSTANTIATE CONTROLLER
        NI_FrozenUsers_ListView ctrl = new NI_FrozenUsers_ListView(new ApexPages.StandardSetController(lstInsertedUsers));
        
        ctrl.getNI_FrozenUsers_ListView();
        
        
   }   
    
}