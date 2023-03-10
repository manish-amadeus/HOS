/****************************************************************************************
Name            : AH_Acknowledge_Test
Author          : Bhuleshwar Deshpande
Created Date    : 09/20/2019
Last Mod Date   : 09/20/2019    
Last Mod By     : Bhuleshwar Deshpande  
NICC Reference  : 
Description     : Test class for AH_Acknowledge_Cntlr
				:            
******************************************************************************************/
@isTest
public class AH_Acknowledge_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        Test.startTest();
        // CREATE TEST ACCOUNT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'TEST CASE ACCOUNT 1';
        a1.RecordTypeId = rtPropertyAccountId;
        insert a1;
        
        // CREATE TEST CONTACT
        Contact c1 = NI_TestClassData.createTestContact(1, a1.Id);
        c1.FirstName = 'TESCON';
        c1.LastName = 'TESTERA';
        c1.Email = 'TESTA@TESTER.COM';
        insert c1;
        
        // CREATE TEST CASE
        
        Case case1=NI_TestClassData.createTestCase(1,a1.Id);
        case1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        case1.Status = 'New';
        case1.Acknowledged__c = null;
        case1.ContactId=c1.Id;
        case1.Origin = 'Phone';
        case1.Status = 'New';
        case1.Has_No_DI__c = true;
        case1.Subject = 'APEX TEST CASE FOR AH_DiagnoseCase_Cntlr_Test';
        insert case1;
        
        Test.stopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        Case c = [SELECT Id,Acknowledged__c,Status FROM Case WHERE Subject = 'APEX TEST CASE FOR AH_DiagnoseCase_Cntlr_Test'];
        system.debug('QUERY RESULT FOR CASE RECORD' + c);
        
        Account a1 = [SELECT Id, Name FROM Account WHERE Name = 'TEST CASE ACCOUNT 1'];
        
        test.startTest();
        
        AH_Acknowledge_Cntlr cntrl = new AH_Acknowledge_Cntlr();
        AH_Acknowledge_Cntlr.acknowledgeCase(c.Id);
        
        Case c2 = [SELECT Id,Acknowledged__c,Status FROM Case WHERE Id =:c.Id];
        system.debug('QUERY RESULT FOR CASE RECORD' + c2);
        system.assertEquals('Acknowledged',c2.Status);
        test.stopTest();     
    }
}