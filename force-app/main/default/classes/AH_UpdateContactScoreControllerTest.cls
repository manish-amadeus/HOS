/****************************************************************************************
Name            : AH_UpdateContactScoreControllerTest Test Class
Author          : Ria Chawla
Created Date    : 9/27/2017
Last Mod Date   : 9/27/2017
Last Mod By     : Stuart Emery
NICC Reference  : NICC-024092
Description     : test Class for AH_UpdateContactScoreController Class
                : 
******************************************************************************************/
@isTest
public class AH_UpdateContactScoreControllerTest 
{
    
    public static testMethod void testUpdateConScoreController()
    {
        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(539);
        a.Name = 'APEX TESTER ACCOUNT'; 
        insert a;
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(6, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuseryu'; 
        insert c; 
        
        List<Confirmit_Survey_Response_Data__c> dataList = new List<Confirmit_Survey_Response_Data__c>();
        Confirmit_Survey_Response_Data__c sData1 = new Confirmit_Survey_Response_Data__c();
        sData1.Contact__c = c.Id;
        sData1.NPS__c = 5;
        sData1.OSAT__c = 5;
        sData1.Confirmit_CompositeKey__c = 'abcd';
        dataList.add(sData1);
        
        Confirmit_Survey_Response_Data__c sData2 = new Confirmit_Survey_Response_Data__c();
        sData2.Contact__c = c.Id;
        sData2.NPS__c = 9;
        sData2.OSAT__c = 10;
        sData2.Confirmit_CompositeKey__c = 'efgh';
        dataList.add(sData2);
        
        Confirmit_Survey_Response_Data__c sData3 = new Confirmit_Survey_Response_Data__c();
        sData3.Contact__c = c.Id;
        sData3.NPS__c = 10;
        sData3.OSAT__c = 7;
        sData3.Confirmit_CompositeKey__c = 'ijkl';
        dataList.add(sData3);      
        
        Confirmit_Survey_Response_Data__c sData4 = new Confirmit_Survey_Response_Data__c();
        sData4.Contact__c = c.Id;
        sData4.NPS__c = 4;
        sData4.OSAT__c =10;
        sData4.Confirmit_CompositeKey__c = 'mnop';
        dataList.add(sData4);
        insert dataList;
        
        //Contact conList = new Contact();
        //conList = [SELECT Id, Name, Net_Promoter_Score_NPS__c, Overall_Satisfaction__c
        //           FROM Contact WHERE FirstName = 'Apex' LIMIT 1];
        // System.assertEquals(0.0, conList.Net_Promoter_Score_NPS__c);
        //System.assertEquals(8.00, conList.Overall_Satisfaction__c);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(dataList);
        AH_UpdateContactScoreController controller = new AH_UpdateContactScoreController(sc);
        
        Test.startTest();
        controller.doSubmit();
        controller.refreshPage();
        Test.stopTest();
        AsyncApexJob asyncJob = new AsyncApexJob();
        asyncJob = [SELECT ApexClassId, CompletedDate, CreatedById, CreatedDate, Id, NumberOfErrors, Status
                    FROM AsyncApexJob
                    WHERE Status = 'Completed'
                    AND ApexClassId IN (Select Id from ApexClass where Name = 'AH_BatchSurveyResponseData')
                    ORDER BY CompletedDate DESC LIMIT 1];
        
        controller.refreshPage();
        AH_Batch_Apex_Result__c batchApexResult = new AH_Batch_Apex_Result__c();
        batchApexResult = [SELECT Id, Name, Batch_Job_Id__c,Failed_Records__c, Success_Records__c, Total_Survey_Records_Processed__c
                           FROM AH_Batch_Apex_Result__c];
        system.assertEquals(4, batchApexResult.Total_Survey_Records_Processed__c);
        system.assertEquals(1, batchApexResult.Success_Records__c);
        
    }
    
    public static testMethod void testScheduleMethod2()
    {
        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(539);
        a.Name = 'APEX TESTER ACCOUNT'; 
        insert a;
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(6, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuseryu'; 
        insert c; 
        
        List<Confirmit_Survey_Response_Data__c> dataList = new List<Confirmit_Survey_Response_Data__c>();
        Confirmit_Survey_Response_Data__c sData1 = new Confirmit_Survey_Response_Data__c();
        sData1.Contact__c = c.Id;
        sData1.NPS__c = 5;
        sData1.OSAT__c = 5;
        sData1.Confirmit_CompositeKey__c = 'abcd';
        dataList.add(sData1);
        
        Confirmit_Survey_Response_Data__c sData2 = new Confirmit_Survey_Response_Data__c();
        sData2.Contact__c = c.Id;
        sData2.NPS__c = 9;
        sData2.OSAT__c = 10;
        sData2.Confirmit_CompositeKey__c = 'efgh';
        dataList.add(sData2);
        
        Confirmit_Survey_Response_Data__c sData3 = new Confirmit_Survey_Response_Data__c();
        sData3.Contact__c = c.Id;
        sData3.NPS__c = 10;
        sData3.OSAT__c = 7;
        sData3.Confirmit_CompositeKey__c = 'ijkl';
        dataList.add(sData3);      
        
        Confirmit_Survey_Response_Data__c sData4 = new Confirmit_Survey_Response_Data__c();
        sData4.Contact__c = c.Id;
        sData4.NPS__c = 4;
        sData4.OSAT__c =10;
        sData4.Confirmit_CompositeKey__c = 'mnop';
        dataList.add(sData4);
        insert dataList;
        
        //Contact conList = new Contact();
        //conList = [SELECT Id, Name, Net_Promoter_Score_NPS__c, Overall_Satisfaction__c
        //           FROM Contact WHERE FirstName = 'Apex' LIMIT 1];
        //System.assertEquals(0.0, conList.Net_Promoter_Score_NPS__c);
        //System.assertEquals(8.00, conList.Overall_Satisfaction__c);
        
        AH_BatchSurveyResponseData batchClass = new AH_BatchSurveyResponseData(Date.today(), Date.today().addDays(1));
        Database.executeBatch(batchClass);
        
        Datetime n = Datetime.now();                                                                                                                                                                                   
        //Integer i = Test.isRunningTest() ? 2 : 1;
        n = n.addMinutes(5);                                                                                      
        String CRON_EXP = '0 ' + n.format('m') + ' ' + n.format('H') + ' ' + n.format('d') + ' ' + n.format('M') + ' ? '+ n.format('yyyy');                                                                                                                        
        AH_ScheduleBatchSurveyResData scheduleClass = new AH_ScheduleBatchSurveyResData();
        Test.startTest();
        system.schedule('Test', CRON_EXP, scheduleClass);
        Test.stopTest();
        List<AsyncApexJob> asyncJob = new List<AsyncApexJob>();
        asyncJob = [SELECT ApexClassId, CompletedDate, CreatedById, CreatedDate, Id, NumberOfErrors, Status
                    FROM AsyncApexJob
                    WHERE Status = 'Completed'
                    AND ApexClassId IN (Select Id from ApexClass where Name = 'AH_BatchSurveyResponseData')
                    ORDER BY CompletedDate DESC];
        
        SYSTEM.debug('asyncJob'+asyncJob);
        
    }
    
    public static testMethod void testErrorLogInBatch()
    {
        
        //CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(539);
        a.Name = 'APEX TESTER ACCOUNT'; 
        insert a;
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(6, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuseryu'; 
        insert c; 
        
        List<Confirmit_Survey_Response_Data__c> dataList = new List<Confirmit_Survey_Response_Data__c>();
        Confirmit_Survey_Response_Data__c sData1 = new Confirmit_Survey_Response_Data__c();
        sData1.Contact__c = c.Id;
        sData1.NPS__c = 5;
        sData1.OSAT__c = 5;
        sData1.Confirmit_CompositeKey__c = 'abcd';
        dataList.add(sData1);
        insert dataList;
        Test.startTest();
        AH_BatchSurveyResponseData batchClass = new AH_BatchSurveyResponseData(Date.today(), Date.today().addDays(1));
        batchClass.testIsRunning = true;
        Database.executeBatch(batchClass);
        Test.stopTest();
        List<NI_Admin_Error_Log__c> errorLog = new List<NI_Admin_Error_Log__c>();
        errorLog = [SELECT Id, Name FROM NI_Admin_Error_Log__c];
        system.assertEquals(1, errorLog.size());
        
    }
    
    public static testMethod void testCatchBlock()
    {
        
        //CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(539);
        a.Name = 'APEX TESTER ACCOUNT'; 
        insert a;
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(6, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuseryu'; 
        insert c; 
        
        List<Confirmit_Survey_Response_Data__c> dataList = new List<Confirmit_Survey_Response_Data__c>();
        Confirmit_Survey_Response_Data__c sData1 = new Confirmit_Survey_Response_Data__c();
        sData1.Contact__c = c.Id;
        sData1.NPS__c = 5;
        sData1.OSAT__c = 5;
        sData1.Confirmit_CompositeKey__c = 'abcd';
        dataList.add(sData1);
        insert dataList;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(dataList);
        AH_UpdateContactScoreController controller = new AH_UpdateContactScoreController(sc);
        controller.refreshPage();
        
    }
    
    public static testMethod void testUpdateCSCtrl()
    {
        
        //CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(539);
        a.Name = 'APEX TESTER ACCOUNT'; 
        insert a;
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(6, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuseryu'; 
        insert c; 
            
        List<Confirmit_Survey_Response_Data__c> dataList = new List<Confirmit_Survey_Response_Data__c>();
        Confirmit_Survey_Response_Data__c sData1 = new Confirmit_Survey_Response_Data__c();
        sData1.Contact__c = c.Id;
        sData1.NPS__c = 5;
        sData1.OSAT__c = 5;
        sData1.Confirmit_CompositeKey__c = 'abcd';
        dataList.add(sData1);
        insert dataList;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(dataList);
        AH_UpdateContactScoreController controller = new AH_UpdateContactScoreController(sc);
          
        Test.startTest();
        AH_BatchSurveyResponseData batchSurveyRecords = new AH_BatchSurveyResponseData(Date.today().addDays(-10), Date.today());
        controller.batchJobId = Database.executeBatch(batchSurveyRecords, 25); 
        Test.stopTest();
        AH_Batch_Apex_Result__c batchApexResult = new AH_Batch_Apex_Result__c();
        batchApexResult = [SELECT Id, Name, Batch_Job_Id__c,Failed_Records__c, Success_Records__c, Total_Survey_Records_Processed__c
                           FROM AH_Batch_Apex_Result__c WHERE Batch_Job_Id__c = :controller.batchJobId];
        batchApexResult.Failed_Contact_Records__c = '{'+c.Id+'}';
        update batchApexResult;
         
        controller.refreshPage();
        
    }
    
    public static testMethod void testUpdateCSCtrlExcep()
    {
        
        //CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(539);
        a.Name = 'APEX TESTER ACCOUNT'; 
        insert a;
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(6, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuseryu'; 
        insert c; 
        
        List<Confirmit_Survey_Response_Data__c> dataList = new List<Confirmit_Survey_Response_Data__c>();
        Confirmit_Survey_Response_Data__c sData1 = new Confirmit_Survey_Response_Data__c();
        sData1.Contact__c = c.Id;
        sData1.NPS__c = 5;
        sData1.OSAT__c = 5;
        sData1.Confirmit_CompositeKey__c = 'abcd';
        dataList.add(sData1);
        insert dataList;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(dataList);
        AH_UpdateContactScoreController controller = new AH_UpdateContactScoreController(sc);
          
        Test.startTest();
        AH_BatchSurveyResponseData batchSurveyRecords = new AH_BatchSurveyResponseData(Date.today().addDays(-10), Date.today());
        controller.batchJobId = Database.executeBatch(batchSurveyRecords, 25); 
        Test.stopTest();
        AH_Batch_Apex_Result__c batchApexResult = new AH_Batch_Apex_Result__c();
        batchApexResult = [SELECT Id, Name, Batch_Job_Id__c,Failed_Records__c, Success_Records__c, Total_Survey_Records_Processed__c
                           FROM AH_Batch_Apex_Result__c 
                           WHERE Batch_Job_Id__c = :controller.batchJobId];
        delete batchApexResult;
         
        controller.refreshPage();
        
    }
    
}