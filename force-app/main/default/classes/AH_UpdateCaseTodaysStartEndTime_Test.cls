/****************************************************************************************
Name            : AH_UpdateCaseTodaysStartEndTime_Test Class
Author          : Shashikant Nikam
Created Date    : 04/06/2018
Last Mod By     : 08/13/2019
Last Mod Date   : Shashikant Nikam
NICC Reference  : NICC-026092
Description     : This test class cover the code of AH_BatchUpdateCaseTodaysStartEndTime Class
                : 
                : 
******************************************************************************************/
@isTest
public class AH_UpdateCaseTodaysStartEndTime_Test 
{
    
    @testSetup static void createTestData() 
    {
        
		test.startTest();

        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        // CREATE CUSTOM SETTING
		AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        caseFlagSetting.Organisation_Wide__c = true;
        upsert caseFlagSetting;
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();

		// INSERT AH Case Flags Store Types 
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes.Name = 'Default';
        flagRecTypes.Enabled_Case_Type__c = String.valueof(rtCaseId);
        flagRecTypes.Enabled_Activity_Types__c = 'Email,Call';
        flagRecTypes.Clear_Case_Origins__c = 'Phone';
        insert flagRecTypes;

		List<AH_Case_Flags_Store_Types__c> flg = [select id, name, Enabled_Case_Type__c, Enabled_Activity_Types__c, 
                                                  Clear_Case_Origins__c from AH_Case_Flags_Store_Types__c where id =: flagRecTypes.id];        
        System.debug('flagRecTypes :'+flg);
        System.assertEquals(flg[0].Enabled_Case_Type__c,String.valueof(rtCaseId));
        System.assertEquals(flg[0].Enabled_Activity_Types__c,'Email,Call');
        System.assertEquals(flg[0].Clear_Case_Origins__c,'Phone');

        // CREATE AN ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'NI_Case_TriggerHandlerTest ACCOUNT';
        insert a;

        // CREATE CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jack';
        cnt.LastName = 'King';
        insert cnt;
        
        List<Account> acc = [select id, name, (select id, name from Contacts where name = 'Jack King') from Account where name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        System.assertEquals(acc[0].id,a.id);
        System.assertEquals(acc[0].Contacts[0].id,cnt.id);

        // CREATE 10 CASEs
        List<Case> lstCases = new List<Case>();
        for (integer j = 0; j < 10; j++)
        {
            Case cs = NI_TestClassData.createTestCase(j, a.Id);
            cs.ContactId = cnt.Id;
            cs.Subject = 'NI_Case_TriggerHandlerTest CHILD CASE #' + String.valueOf(j);
            cs.Description = 'NI_Case_TriggerHandlerTest CHILD CASE DESCRIPTION #' + String.valueOf(j); 
            cs.Status = 'Working';
            cs.AH_Case_Flagged_Date__c = System.now();
            cs.RecordTypeId = rtCaseId;            
            lstCases.Add(cs);             
        }           
        
        // INSERT 10 CASES 
        Database.Insert(lstCases);  
        System.assertEquals(10, lstCases.Size());
        system.debug('END NI_Case_TriggerHandlerTest.createTestData() - NUMBER OF QUERIES = ' + limits.getQueries());
        
        test.stopTest();
    }
    
    // METHOD TO TEST SCHEDULABLE CLASS 
	@isTest
    public static void testSchedule(){
        Test.startTest();
        AH_UpdateCaseTodaysStartEndTime batch1 = new AH_UpdateCaseTodaysStartEndTime();
        String sch = '0 0 0 1 1 ? 2050';
        String jobId = system.schedule('Test Territory Check', sch, batch1);
        
        // VERIFY THE NEXT TIME THE JOB WILL RUN
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals('2050-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}