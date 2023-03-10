/****************************************************************************************
Name            : AH_OppSendEmailExt_Test
Author          : Ria Chawla
Created Date    : 12/12/2017
Last Mod Date   : 12/14/2017
Last Mod By     : 
NICC Reference  : 
Description     : Test class for AH_OppSendEmailExt
******************************************************************************************/
@isTest
public class AH_OppSendEmailExt_Test 
{
    

    static testMethod void testCaseToOpportunity() 
    {
        
        Account a = NI_TestClassData.createTestAccount(1); 
        insert a;  
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();         
        Id rtLargeDealId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id);
        //opp1.StageName = 'Closed Won';
        opp1.RecordTypeId = rtLargeDealId;
        opp1.Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1';
        //opp1.Strategy__c = stgy.Id;
        insert opp1;
        
        User usr = [SELECT id, Email FROM User WHERE Id =: UserInfo.getUserId()];	
        
        Contact cn = NI_TestClassData.createTestContact(1,a.id);
        cn.Email = usr.Email;
        insert cn;
        
        Case c = NI_TestClassData.createTestCase(1, a.id); 
        c.ContactId = cn.id;
        insert c;
        
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator') ;
        insert u;
        
        EmailTemplate et = new EmailTemplate(developerName = 'test', TemplateType = 'Text', Name = 'Sales to Support Supervisors', isActive = true, FolderId = UserInfo.getUserId()); 
        
        system.RunAs(usr)
        {
            insert et;
        }
        
        AH_Case_Solution__c cs = new AH_Case_Solution__c(Solution__c ='Test');

        //PAGE REFERENCE
        PageReference pageRef = Page.AH_OppSendEmail;
        Test.setCurrentPage(pageRef);
        
        // Put Id into the current page Parameters
        //ApexPages.currentPage().getParameters().put('caseid',c.Id);
        
        //INSTANTIATE CONTROLLER
        ApexPages.StandardController ctrl = new ApexPages.standardController(opp1); 
        AH_OppSendEmailExt casectrl = new AH_OppSendEmailExt(ctrl);
        casectrl.sendEmail();
        casectrl.closeAndReturn();
        
        List<Task> taskList = [SELECT Id FROM Task];
        system.assertEquals(1, taskList.size());
        
    }
    
}