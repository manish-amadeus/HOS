/************************************************************************************************
Name            : AH_SandboxInit_Test
Author          : Bhuleshwar Deshpande
Created Date    : 04/06/2020
Last Mod Date   : 04/16/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-042469
Description     : Test class for AH_SandboxInit, AH_SandboxInit_BatchJobReq & AH_SandboxInit_BatchPerfEval Classes
				: 
************************************************************************************************/
@isTest
public class AH_SandboxInit_Test 
{
    
    // =======================================================================================================================================
    // = CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup 
    static void createTestData() 
    {

        // CREATE A TEST NI DEPARTMENT RECORD  
        NI_Departments__c d = NI_TestClassData.createTestNI_Department(1); 
        insert d; 
        
        // CREATE A TEST NI LOCATION RECORD 
        NI_Location__c l = NI_TestClassData.createTestNI_Location(1); 
        insert l; 
                
        // CREATE A TEST USER
        User u = NI_TestClassData.createTestUser(1, 'System Administrator'); 
        u.DepartmentCode__c = d.Name; 
        u.NI_Location__c = l.Name; 
        insert u; 

        // CREATE TEST MANAGER USER 
        User Manager = NI_TestClassData.createTestUser(2, 'System Administrator'); 
        insert Manager; 
        
        // CREATE 10 TEST JOB REQUISITION RECORDS
        Id rt1 = Schema.SObjectType.NI_Job_Requisition__c.getRecordTypeInfosByName().get('MTech Contractor - Closed').getRecordTypeId(); 
        
        List<NI_Job_Requisition__c> lstJobReqs = new List<NI_Job_Requisition__c>(); 
        
        for (integer j = 1; j < 11; j++) 
        {
            NI_Job_Requisition__c jr = NI_TestClassData.createTestNI_Job_Requisition(j, u.Id, rt1); 
            jr.Job_Type__c = 'Add'; 
            jr.Role__c = 'Dev'; 
            jr.Job_Title__c = 'Apex Tester ' + String.valueOf(j); 
            lstJobReqs.add(jr); 
        } 

        Database.insert(lstJobReqs); 
        
        List<NI_Job_Requisition__c> lstJobReqAsserts = new List<NI_Job_Requisition__c>([SELECT Id FROM NI_Job_Requisition__c]); 
        system.assertEquals(10, lstJobReqAsserts.size());         
        
        // CREATE 10 TEST EMPLOYEE PERFORMANCE EVALUATION RECORDS
        List<NI_Employee_Performance_Evaluation__c> lstPerfEvals = new List<NI_Employee_Performance_Evaluation__c>(); 
        
        for (integer p = 1; p < 11; p++) 
        {
            NI_Employee_Performance_Evaluation__c epe = NI_TestClassData.createEmployee_Performance_Evaluation(Manager.Id, null); 
            epe.OwnerId = u.Id;
            epe.Employee_Name__c = u.Id;
            epe.Status__c = 'Employee Draft'; 
            epe.Time_in_Position__c = '300';           
            lstPerfEvals.add(epe); 
        }

        Database.insert(lstPerfEvals); 
        
        List<NI_Employee_Performance_Evaluation__c> lstPerfEvalAsserts = new List<NI_Employee_Performance_Evaluation__c>([SELECT Id FROM NI_Employee_Performance_Evaluation__c]); 
        system.assertEquals(10, lstPerfEvals.size()); 
        
    } 
    
    // =======================================================================================================================================
    // = TEST METHOD 1: INVOKE SANDBOX POST COPY SCRIPT METHOD
    // =======================================================================================================================================    
    @isTest 
    static void test1() 
    {
        
        // ASSERT TEST JOB REQUISITION RECORDS EXIST
        List<NI_Job_Requisition__c> lstJobReqAsserts1 = new List<NI_Job_Requisition__c>([SELECT Id FROM NI_Job_Requisition__c]); 
        system.assertEquals(10, lstJobReqAsserts1.size()); 

        // ASSERT TEST EMPLOYEE PERFORMANCE EVALUATION RECORDS EXIST
        List<NI_Employee_Performance_Evaluation__c> lstPerfEvalAsserts1 = new List<NI_Employee_Performance_Evaluation__c>([SELECT Id FROM NI_Employee_Performance_Evaluation__c]); 
        system.assertEquals(10, lstPerfEvalAsserts1.size());         
        
        NI_TestClassData.createTestWinaproachServiceNowSettings(); 
        
        Test.startTest(); 
        
        Test.testSandboxPostCopyScript(new AH_SandboxInit(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName()); 
        
        Test.stopTest(); 
        
        // ASSERT SERVICENOW CUSTOM SETTINGS 
        ServiceNowIncidentSettings__c csSN = ServiceNowIncidentSettings__c.getValues('Default');         
        system.assertEquals('XXXXX', csSN.ServiceNow_Password__c); 
        system.assertEquals('XXXXX', csSN.SerrviceNow_Username__c); 
        system.assertEquals('XXXXXihg_servicenow@newmarketinc.com.XXXXX', csSN.Integration_Username__c); 
        system.assertEquals('XXXXX CRS Incident', csSN.ServiceNow_Incident_Case_Record_Type__c); 
        system.assertEquals('https://XXXXXihgsndev.service-now.com/api/now/table/incident', csSN.Incident_Endpoint__c); 
        system.assertEquals('https://XXXXXihgsndev.service-now.com/api/now/import/u_integ_amadeus_incidents', csSN.ImportSet_Endpoint__c); 
        system.assertEquals('https://XXXXXihgsndev.service-now.com/api/now/attachment', csSN.Attachment_Endpoint__c); 

        // ASSERT WINAPROACH CUSTOM SETTINGS 
        WinaproachIncidentSettings__c csWin = WinaproachIncidentSettings__c.getValues('Default'); 
        system.assertEquals('XXXXX', csWin.Username__c); 
        system.assertEquals('XXXXX', csWin.Password__c); 
        system.assertEquals('XXXXX Amadeus Parallel Investigation', csWin.Task_Record_Type__c); 
        system.assertEquals('https://XXXXXaproach.amadeus.net/aproach/webserviceDEV/services/AproachWebServices', csWin.Endpoint__c); 
        system.assertEquals('XXXXX.XXXXX@newmarketinc.com.XXXXX', csWin.Integration_Username__c); 
        
        // ASSERT ALL JOB REQUISITION RECORDS WERE DELETED
        List<NI_Job_Requisition__c> lstJobReqAsserts2 = new List<NI_Job_Requisition__c>([SELECT Id FROM NI_Job_Requisition__c]); 
        system.assertEquals(0, lstJobReqAsserts2.size()); 

        // ASSERT ALL EMPLOYEE PERFORMANCE EVALUATION RECORDS WERE DELETED
        List<NI_Employee_Performance_Evaluation__c> lstPerfEvalAsserts2 = new List<NI_Employee_Performance_Evaluation__c>([SELECT Id FROM NI_Employee_Performance_Evaluation__c]); 
        system.assertEquals(0, lstPerfEvalAsserts2.size()); 

    }
    
}