/****************************************************************************************
Name            : AH_BatchTodaysStartEndTimeHandlerTest Class
Author          : Shashikant Nikam
Created Date    : 02/09/2018
Last Mod Date   : Shashikant Nikam
Last Mod By     : 04/18/2018
NICC Reference  : NICC-026092
Description     : This test class cover the code of AH_BatchCaseTodaysStartEndTimeHandler Class
                : 
                : 
******************************************************************************************/
@isTest
public class AH_BatchTodaysStartEndTimeHandlerTest 
{
    
    @testSetup static void createTestData() 
    {
        
		test.startTest();

        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        // CREATE CUSTOM SETTINGS
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        caseFlagSetting.Organisation_Wide__c = true;
        upsert caseFlagSetting;
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case New').getRecordTypeId();

		// INSERT AH Case Flags Store Types 
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes.Name = 'Default';
        flagRecTypes.Enabled_Case_Type__c = String.valueof(rtCaseId);
        flagRecTypes.Enabled_Activity_Types__c = 'Email,Call';
        flagRecTypes.Clear_Case_Origins__c = 'Phone';
        insert flagRecTypes;

		List<AH_Case_Flags_Store_Types__c> flg = [SELECT Id, name, Enabled_Case_Type__c, Enabled_Activity_Types__c, Clear_Case_Origins__c 
                                                  FROM AH_Case_Flags_Store_Types__c 
                                                  WHERE id =: flagRecTypes.id];        
//system.debug('flagRecTypes :'+flg);
        system.assertEquals(flg[0].Enabled_Case_Type__c, String.valueof(rtCaseId));
        system.assertEquals(flg[0].Enabled_Activity_Types__c, 'Email,Call');
        system.assertEquals(flg[0].Clear_Case_Origins__c, 'Phone');

        // CREATE AN ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'NI_Case_TriggerHandlerTest ACCOUNT';
        a.ShippingPostalCode = '';
        a.ShippingCountry = '';
        a.ShippingState = '';
        a.ShippingStreet = '';
        a.ShippingCity = '';
        insert a;

        // CREATE CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jack';
        cnt.LastName = 'King';
        insert cnt;
        
        List<Account> acc = [SELECT Id, Name, (SELECT Id, Name FROM Contacts WHERE Name = 'Jack King') FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        system.assertEquals(acc[0].id, a.id);
        system.assertEquals(acc[0].Contacts[0].id, cnt.id);

        // CREATE 10 CASES
        List<Case> lstCases = new List<Case>();
        for (integer j = 0; j < 10; j++)
        {
            Case cs = NI_TestClassData.createTestCase(j, a.Id);
            cs.ContactId = cnt.Id;
            cs.Subject = 'NI_Case_TriggerHandlerTest CHILD CASE #' + String.valueOf(j);
            cs.Description = 'NI_Case_TriggerHandlerTest CHILD CASE DESCRIPTION #' + String.valueOf(j); 
            cs.Status = 'Working';
            cs.AH_Case_Flagged_Date__c = system.now();
            cs.RecordTypeId = rtCaseId;            
            cs.Origin = 'Internal';
            lstCases.Add(cs);             
        }           
        
        // INSERT 10 CASES 
        Database.Insert(lstCases);  
        
        List<Case> lstAssertCases = new List<Case>([SELECT Id, CaseNumber, BusinessHoursId FROM Case]); 
        
        system.assertEquals(10, lstAssertCases.Size());
        
        for (Case cs : lstAssertCases)
        {
system.debug(' **^** INSERT - cs.CaseNumber = ' + cs.CaseNumber + ' - cs.BusinessHoursId = ' + cs.BusinessHoursId);            
        }
        
//system.debug('END NI_Case_TriggerHandlerTest.createTestData() - NUMBER OF QUERIES = ' + limits.getQueries());
        
        test.stopTest();

        User u = NI_TestClassData.createTestUser(8, 'NI Support CSR'); 
        u.Alias = 'USER8TST'; 
        insert u;   
       
    }
    
    @isTest public static void test_1()
    {
        
        test.startTest();
        
        User u = [SELECT Id FROM User WHERE Alias = 'USER8TST'];
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        List<Case> cases = [SELECT Id FROM Case WHERE Subject LIKE 'NI_Case_TriggerHandlerTest CHILD CASE %' LIMIT 10];
        List<BusinessHours> B_TEST = [SELECT Id, Name FROM BusinessHours WHERE Name LIKE 'TEST %'];
system.debug(' **** B_TEST.size() = ' + B_TEST.size());
        
        List<Case> update_cases = new List<Case>();
        
        Set<Id> caseIds = new Set<Id>();
        
        for (Integer i = 0; i < B_TEST.size(); i++)
        {
system.debug(' **** B_TEST[i].Name = ' + B_TEST[i].Name);            
            Case c = new Case (id = cases[i].id);
            c.BusinessHoursId = B_TEST[i].id;
system.debug(' **** c.BusinessHoursId = ' + c.BusinessHoursId);      
            c.AH_Case_Flagged_Date__c = system.now();
            update_cases.add(c);
            caseIds.add(c.id);
        }

        update update_cases;

        List<Case> case_list = [SELECT Id, CaseNumber, AH_Case_Flagged_Date__c, BusinessHoursId FROM Case WHERE Id IN : caseIds];

        for (Case cs : case_list)
        {
system.debug(' **^** UPDATE - cs.CaseNumber = ' + cs.CaseNumber + ' - cs.BusinessHoursId = ' + cs.BusinessHoursId);            
        }        
        
        Integer cnt = 0;
        
        for (Case c : case_List)
        {
            if (String.valueOf(c.AH_Case_Flagged_Date__c) != null)
            {
                cnt++;
            }
        }
        system.assertEquals(cnt, 8);
        
        test.stopTest();
        
    }

    
    @isTest public static void test_2()
    {
        
        test.startTest();
        
		// Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        List<Case> cases = [SELECT Id FROM Case WHERE Subject LIKE 'NI_Case_TriggerHandlerTest CHILD CASE %' LIMIT 10];
        
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
		caseFlagSetting.Hours__c = '24';
        caseFlagSetting.Organisation_Wide__c = true;
        upsert caseFlagSetting;

		BusinessHours B_TEST1 = [SELECT Id, Name, 
                                 MondayStartTime, MondayEndTime, 
                                 TuesdayStartTime, TuesdayEndTime, 
                                 WednesdayStartTime, WednesdayEndTime,
                                 ThursdayStartTime, ThursdayEndTime,
                                 FridayStartTime,FridayEndTime,
                                 SaturdayStartTime, SaturdayEndTime,
                                 SundayStartTime, SundayEndTime 
                                 FROM BusinessHours 
                                 WHERE Name = 'Default'];
        
        List<Case> update_cases = new List<Case>(); 
        
        Case c8 = new Case (id = cases[0].id);
        c8.BusinessHoursId = B_TEST1.id;
        c8.AH_Case_Flagged_Date__c = system.now();
        update c8;
        
        List<Case> case_list = [SELECT Id, CaseNumber, AH_Case_Flagged_Date__c FROM Case WHERE Id =: c8.Id];
        Boolean isPassed = False;
        if (case_list[0].AH_Case_Flagged_Date__c != null)
        {
            isPassed = True;
        }
        system.assertEquals(isPassed, True);

        Case c1 = new Case (id = cases[0].id);
        c1.BusinessHoursId = B_TEST1.id;
        c1.AH_Case_Flagged_Date__c = system.now();
        update c1;

        List<Case> case_list1 = [SELECT Id, CaseNumber, AH_Case_Flagged_Date__c FROM Case WHERE Id =: c1.Id];
        Boolean isPassed1 = False;
        if (case_list1[0].AH_Case_Flagged_Date__c != null)
        {
            isPassed1 = True;
        }
        system.assertEquals(isPassed1, true);
        
        test.stopTest();
        
    }

    
}