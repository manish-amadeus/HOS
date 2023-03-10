/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_REST_JSONGenerator_Test
Author          : Princy Jain
Created Date    : 06/06/2018
Last Mod Date   : 01/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : test class for INTGR_REST_JSONGenerator
				:
****************************************************************************************/
@isTest
public class INTGR_REST_JSONGenerator_Test
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================        
    @testSetup static void setupData() 
    {
        
        User cUser = NI_TestClassData.createTestUser(111, 'System Administrator');
        cUser.Email = 'testuserZzzzzz' + 111 + '@salesforce.com';
        cUser.Alias = '111user';
        insert cUser ; 
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        insert a1;
        
        INTGR_Account__c acc = NI_TestClassData.createTestINTGR_Account(1, a1.Id, cUser.Id);
        acc.Active__c = true;
        insert acc;
       
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        
        Case cs = NI_TestClassData.createTestCaseIntegration(1, a1.Id);
        cs.Integration_Account__c = acc.Id;
        insert cs;
        
        INTGR_Case__c caseObj1 = NI_TestClassData.createTestINTGR_Case(1, acc.Id, cs.Id);
        insert caseObj1;        
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1:
    // =======================================================================================================================================     
    static testmethod void coverJsonStringCreate() 
    {
        
        Test.startTest();
        
        INTGR_Case__c obj = [SELECT Id, Severity__c, Status__c, Subject__c, Customer_Ticket_System_Id__c FROM INTGR_Case__c LIMIT 1][0];
        
        Id accId = [SELECT Id from INTGR_Account__c LIMIT 1][0].Id;
        
        Map<String, String> srcTargetFieldMap = new Map<String, String>();
        List<INTGR_Field_Mapping__c> fMappingList = NI_TestClassData.createTestINTGR_AccountMapping(7, accId);
        insert fMappingList;
        
        if (fMappingList.size() > 0) 
        {
            
            fMappingList[1].Source_Field__c = 'Severity__c';
            fMappingList[1].Target_Field__c = 'severity';
            srcTargetFieldMap.put('Severity__c', 'severity');
            
            fMappingList[2].Source_Field__c = 'Status__c';
            fMappingList[2].Target_Field__c = 'incident_state';
            srcTargetFieldMap.put('Status__c', 'incident_state');
            
            fMappingList[3].Source_Field__c = 'Subject__c';
            fMappingList[3].Target_Field__c = 'short_description';
            srcTargetFieldMap.put('Subject__c', 'short_description');
            
           
            fMappingList[4].Source_Field__c = 'Customer_Ticket_System_Id__c';
            fMappingList[4].Target_Field__c = 'sys_id';
            srcTargetFieldMap.put('Customer_Ticket_System_Id__c', 'sys_id');
            
            fMappingList[5].Source_Field__c = 'Customer_Ticket_System_Id__c';
            fMappingList[5].Target_Field__c = 'sys_id';
            fMappingList[5].Source_Object_API_Name__c = 'INTGR_Case_Comment__c';
            srcTargetFieldMap.put('Customer_Ticket_System_Id__c', 'sys_id');
            
            fMappingList[6].Source_Field__c = 'CommentBody__c';
            fMappingList[6].Target_Field__c = 'work_notes';
            fMappingList[6].Source_Object_API_Name__c = 'INTGR_Case_Comment__c';
            srcTargetFieldMap.put('CommentBody__c', 'work_notes');
            
        }
        
        update fMappingList;
        
        String reqBody = INTGR_REST_JSONGenerator.generateJSONRequestString(obj, srcTargetFieldMap);
        
        Test.stopTest();
        
    }
    
}