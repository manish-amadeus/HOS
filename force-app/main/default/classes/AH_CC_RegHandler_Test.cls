/****************************************************************************************
Name            : AH_CC_RegHandler_Test
Author          : Sean Harris
Created Date    : 10/29/2019
Last Mod Date   : 10/29/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Customized Registration Handler class used in mapping community users to 
                : Salesforce provider authenticated ones.
******************************************************************************************/
@isTest
public class AH_CC_RegHandler_Test 
{
    
    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
        
       // CREATE TEST PARENT ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        // CREATE A TEST CONTACT TO BE CREATED AS A PORTAL USER 
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jack';
        cnt.LastName = 'Tors';
        cnt.Email = 'jack.tors@somecustomer.org';
        insert cnt;
        
        // CREATE TEST CUSTOMER PORTAL USER 
        User u = NI_TestClassData.createTestUser(2, 'AH Customer Community Plus User'); 
        u.ContactId = cnt.Id;
        u.FirstName = 'Jack';
        u.LastName = 'Tors';
        u.Alias = 'jtors11';
        u.Email = 'jack.tors@somecustomer.org';
        //u.Username = 'jtors@somecustomer.org.amp';
        u.Username = 'jsmith@someemail.com.ahcc';
        u.CommunityNickname = 'jtors11'; 
        insert u;        
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: UNIT TESTING FOR SOCIAL SIGN-ON USER MATCHING - SUCCESS
    // =======================================================================================================================================
    @isTest static void test1() 
    {
        
        AH_CC_RegHandler handler = new AH_CC_RegHandler();
        
        Auth.UserData sampleData = new Auth.UserData('ID00000001', 					// identifier
                                                     'Jack', 						// firstName
                                                     'Tors',						// lastName
                                                     'Jack Tors', 					// fullName
                                                     'jack.tors@somecustomer.org',	// email
                                                     null, 							// link
                                                     'jtors@somecustomer.org', 		// userName
                                                     'en_US', 						// locale
                                                     'Salesforce',					// provider
                                                     null, 							// siteLoginUrl
                                                     new Map<String, String>{});	// attributeMap 
          
        User u = handler.createUser(null, sampleData);
        
        handler.updateUser(u.Id, null, sampleData);
        
        User usrAsserts = [SELECT Id, External_Salesforce_Username__c FROM User WHERE Id =: u.Id];
        system.assertEquals('jtors@somecustomer.org', usrAsserts.External_Salesforce_Username__c);
        
    }        
    
    // =======================================================================================================================================
    // = TEST METHOD 2: UNIT TESTING FOR SOCIAL SIGN-ON USER MATCHING - FAILURE
    // =======================================================================================================================================
    @isTest static void test2() 
    {
        
        AH_CC_RegHandler handler = new AH_CC_RegHandler();
        
        Auth.UserData sampleData = new Auth.UserData('ID00000001', 					// identifier
                                                     'Jack', 						// firstName
                                                     'Tors',						// lastName
                                                     'Jack Tors', 					// fullName
                                                     'jack.tors@INVALIDMAIL.org',	// email
                                                     null, 							// link
                                                     'jtors@somecustomer.org', 		// userName
                                                     'en_US', 						// locale
                                                     'Salesforce',					// provider
                                                     null, 							// siteLoginUrl
                                                     new Map<String, String>{});	// attributeMap 
        
        User u = handler.createUser(null, sampleData);
        
        handler.updateUser(null, null, sampleData);
        
        List<NI_Admin_Error_Log__c> lstAsserts = new List<NI_Admin_Error_Log__c>([SELECT Id FROM NI_Admin_Error_Log__c]);
        system.assertEquals(2, lstAsserts.size());
        
    }     
    
}