/****************************************************************************************
Name            : AH_WriteEventLogFutureMethod_Test
Author          : Stuart Emery
Created Date    : 08/01/2021
Last Mod Date   : 08/01/2021
Last Mod By     : Stuart Emery
NICC Reference  : NICC-052490
Description     : Test class for the AH_WriteEventLogFutureMethod Apex Class
******************************************************************************************/
@isTest
public class AH_WriteEventLogFutureMethod_Test {
    
    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {

        // CREATE TEST USERS
        List<User> lstUserInsert = new List<User>();
        
        User u1 = NI_TestClassData.createTestUser(1, 'AH Business Systems');
        u1.Alias = 'APEXMGR'; 
        lstUserInsert.Add(u1);   
        
        User u2 = NI_TestClassData.createTestUser(2, 'AH Business Systems');
        u2.Alias = 'APEXSPTU'; 
        lstUserInsert.Add(u2);
                
        Database.insert(lstUserInsert);           
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================    
    @isTest static void test1() 
    {

        User u = [SELECT Id FROM User WHERE Alias = 'APEXMGR'];
        User u2 = [SELECT Id, Name, Email FROM User WHERE Alias = 'APEXSPTU'];
        String strSummary = 'Test';
        Id runningUser = u2.Id;
        
        //CALL THE METHOD TO INSERT THE EVENT LOG RECOR
        Test.startTest();
        
        AH_WriteEventLogFutureMethod.writeEventLog(strSummary, (String)u.Id, runningUser);
        
        Test.stopTest();
        
        List<AH_Event_Log__c> lstEventLog = [SELECT Id FROM AH_Event_Log__c 
                                             WHERE ParentId__c =: u.Id
                                             AND Running_User__c =: runningUser LIMIT 1];
        
        system.assertEquals(1,lstEventLog.size());
        
    }

}