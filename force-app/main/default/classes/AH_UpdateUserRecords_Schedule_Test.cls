/****************************************************************************************
Name            : AH_UpdateUserRecords_Schedule_Test
Author          : Bhuleshwar Deshpande
Created Date    : 01/03/2020
Last Mod Date   : 04/28/2020
Last Mod By     : Stuart Emery
NICC Reference  : NICC-039914
Description     : Test class for AH_UpdateUserRecords_Batch & AH_UpdateUserRecords_Schedule
				: UPDATED 04/28/2020 PER NICC-042785
******************************************************************************************/
@isTest
public class AH_UpdateUserRecords_Schedule_Test   
{
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {        
        
        // CREATE A TEST USER TO USE AS A MANAGER
        User mgr = NI_TestClassData.createTestUser(1, 'NI Administrator');
        mgr.FirstName = 'Apex Manager User';
        mgr.LastName = 'Testuser';
               
        insert mgr;
        
        System.debug('Manager Id: ' + mgr.Id);
        
        // CREATE A TEST USER WITH THE NI ADMINISTRATOR PROFILE TO USE AS THE RUNAS USER
        User u = NI_TestClassData.createTestUser(2, 'NI Administrator');
        u.FirstName = 'Apex CustomLast Login User';
        u.LastName = 'Testuser';
        u.ManagerId = mgr.Id;
        
        insert u; 
    }
    
    // ======================================================================================================================================= 
    // = TEST METHODS 1 FOR SCHEDULABLE CLASS 
    // ==========================================================================================================================
    @isTest static void testSchedulableClass()
    {
        
        Test.startTest();
        
        AH_UpdateUserRecords_Schedule testsche = new AH_UpdateUserRecords_Schedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        
        Test.StopTest();
        
         // ASSERT THAT JOB WAS SCHEDULED
        List<CronJobDetail> lstJobs = new List<CronJobDetail>([SELECT Id FROM CronJobDetail WHERE Name = 'Test status Check']);
        System.assertEquals(1, lstJobs.size());
        
    }
    
    // ==========================================================================================================================
    // = TEST METHOD 2 - TEST BATCHABLE CLASS 
    // ==========================================================================================================================
    @isTest static void test2()
    {
        
        Test.startTest();
      
        AH_UpdateUserRecords_Batch batchable = new AH_UpdateUserRecords_Batch();
        Database.executeBatch(batchable, 10); 

        Test.StopTest();
        
        List <User> quser =[SELECT Id, FIrstName, LastLoginDate, Last_Login_Date_Custom__c, AH_Manager_Email__c, Manager.Email
                            FROM User 
                            WHERE IsActive = true 
                            AND FirstName = 'Apex CustomLast Login User'];
        
        system.debug('Query Size  :' + quser.size());
        system.debug('USER FIRST NAME  :' + quser[0].FirstName);
        system.debug('USER ULM LAST LOGIN DATE  : ' + quser[0].Last_Login_Date_Custom__c);
        system.debug('MANGER EMAIL  : ' + quser[0].Manager.Email);
        system.debug('USER ULM MANAGER EMAIL  : ' + quser[0].AH_Manager_Email__c);
        system.debug('QUERY RESULT  :' + quser );
        
        //VERIFY THAT THE USER RECORDS ARE SUCCESSFULLY UPDATED
        System.assertEquals('Apex CustomLast Login User', quser[0].FirstName );
        System.assertequals(quser[0].LastLoginDate, quser[0].Last_Login_Date_Custom__c);
        System.assertequals(quser[0].Manager.Email, quser[0].AH_Manager_Email__c);

    }
    
}