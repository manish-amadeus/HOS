/****************************************************************************************
Name            : AH_Case_TakeOwnership 
Author          : Sean Harris
Created Date    : 11/02/2022
Last Mod Date   : 11/02/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
				: 
****************************************************************************************/
@isTest
public class AH_Case_TakeOwnership_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_Case_TakeOwnership_Test ACCOUNT';
        insert a;
        
        User u = [SELECT Id FROM User WHERE Name = 'Integration User' AND IsActive = true LIMIT 1];
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.OwnerId = u.Id;
        c.Subject = 'AH_Case_TakeOwnership_Test CASE';
        insert c;   
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {

        User u = [SELECT Id FROM User WHERE Name = 'Integration User' AND IsActive = true LIMIT 1];
        Case c = [SELECT Id, OwnerId FROM Case WHERE Subject = 'AH_Case_TakeOwnership_Test CASE'];
        
        // ASSERT THE CASE OWNER IS Integration User
        system.assertEquals(u.Id, c.OwnerId);
        
        List<Case> lstCase = AH_Case_TakeOwnership.getCases(string.valueOf(c.Id));
        
        // ASSERT THE CASE OWNER WAS CHANGED TO RUNNING USER'S
        system.assertEquals(UserInfo.getUserId(), lstCase[0].OwnerId);
        
    }
    
}