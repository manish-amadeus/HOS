/****************************************************************************************
Name            : AH_Rally_Credentials_Test 
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Test class for AH_Rally_Credentials
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_Credentials_Test 
{
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

        // CREATE TEST RALLY SETUP RECORD
		AH_Rally_Setup__c rsm = new AH_Rally_Setup__c(); 
		//rsm.API_Version__c = 1.43;
		rsm.Exception_Notification_Email__c = 'abc@abc.com';
		rsm.password__c = '12345';
		rsm.rallyUrl__c = 'https://rally1.rallydev.com';
		rsm.username__c = 'travelclick';
		rsm.workspace__c = 'jira';
		rsm.Schedular_Last_Run__c = DATETIME.now();
		rsm.Story_Field_Map__c = '{"Description":{"fldValue":"None","literalValue":""},"KanbanState":{"custom":1,"fldValue":"None","literalValue":""},"L3KanbanStage":{"custom":1,"fldValue":"Default","literalValue":"Advance Investigation"},"Moscow":{"custom":1,"fldValue":"None","literalValue":""},"Name":{"fldValue":"Subject","literalValue":""},"Owner":{"fldValue":"None","literalValue":""},"Package":{"fldValue":"None","literalValue":""},"Rank":{"fldValue":"None","literalValue":""},"ReadyDeprecated":{"custom":1,"fldValue":"None","literalValue":""},"SalesforcePriority":{"custom":1,"fldValue":"Priority","literalValue":""},"StoryType":{"custom":1,"fldValue":"Default","literalValue":"L3/Salesforce"}}';
        insert rsm;  

    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1: testUserStory
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {

        Test.startTest();
        
        String s1 = AH_Rally_Credentials.userName;
        String s2 = AH_Rally_Credentials.pwd;
        String s3 = AH_Rally_Credentials.workspace_name;
        String s4 = AH_Rally_Credentials.Defect_Field;
        String s5 = AH_Rally_Credentials.endPoint;
        String s6 = AH_Rally_Credentials.emailaddress;
        String d1 = 'v2.0';//AH_Rally_Credentials.versionNumber;		
        DateTime dt1 = AH_Rally_Credentials.dateFilterValue;
		Date dSchedularLastRun = dt1.date();
		Date d = DateTime.now().date();
        
        system.assertEquals('travelclick', s1);
		system.assertEquals('12345', s2);
        system.assertEquals('jira', s3);
        system.assertEquals('{"Description":{"fldValue":"None","literalValue":""},"KanbanState":{"custom":1,"fldValue":"None","literalValue":""},"L3KanbanStage":{"custom":1,"fldValue":"Default","literalValue":"Advance Investigation"},"Moscow":{"custom":1,"fldValue":"None","literalValue":""},"Name":{"fldValue":"Subject","literalValue":""},"Owner":{"fldValue":"None","literalValue":""},"Package":{"fldValue":"None","literalValue":""},"Rank":{"fldValue":"None","literalValue":""},"ReadyDeprecated":{"custom":1,"fldValue":"None","literalValue":""},"SalesforcePriority":{"custom":1,"fldValue":"Priority","literalValue":""},"StoryType":{"custom":1,"fldValue":"Default","literalValue":"L3/Salesforce"}}', s4);
        system.assertEquals('https://rally1.rallydev.com', s5);
        system.assertEquals('abc@abc.com', s6);
        system.assertEquals('v2.0', d1);
        system.assertEquals(d, dSchedularLastRun);
        
        Test.stopTest();
          
    }
    
}