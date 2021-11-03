/****************************************************************************************
Name            : AH_New_NI_Change_Control_Request_Test Class
Author          : Shashikant Nikam
Created Date    : 09/19/2019
Last Mod Date   : 09/19/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_New_NI_Change_Control_Request_Cntlr class
				: 
******************************************************************************************/
@isTest  
public class AH_New_NI_Change_Control_Request_Test {

    @isTest
    static void testMethod1()
    {
        // GET RECORD TYPE IDS AND STORE IN A MAP
        Map<Id, String> rtMap = new Map<Id, String>();
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.NI_Change_Control__c.getRecordTypeInfosByName();
        
        system.debug('recordTypesMap : '+recordTypesMap);
        String recTypeId = '';
        if (!recordTypesMap.isEmpty()) 
        {
            if (recordTypesMap.containsKey('Salesforce.com Change Request')) 
            {
                Schema.RecordTypeInfo rr = recordTypesMap.get('Salesforce.com Change Request');
                recTypeId = rr.getRecordTypeId();
                system.debug('recTypeId : '+recTypeId);
            }
        }
        
        NI_Change_Control__c nicc = new NI_Change_Control__c();
        
        PageReference pageRef = Page.AH_New_NI_Change_Control_Request;
        ApexPages.currentPage().getParameters().put('flagOfRt','false');
        ApexPages.currentPage().getParameters().put('rt',recTypeId);
        
		ApexPages.StandardController sc = new ApexPages.StandardController(nicc);
        AH_New_NI_Change_Control_Request_Cntlr cntlr = new AH_New_NI_Change_Control_Request_Cntlr(sc);       

        Test.setCurrentPage(pageRef);
        
        cntlr.strLayoutFields = '[{"Header":"Change Request","Columns":"2","Fields":[{"Field":"RecordTypeId","isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"Name","isUpdatable":"false","isRequired":"false"},{"Field":"OwnerId","isUpdatable":"false","isRequired":"false"},{"Field":"Salesforce_Application__c","isUpdatable":"true","isRequired":"false"},{"Field":"Priority__c","isUpdatable":"true","isRequired":"true"},{"Field":"Change_Reason__c","isUpdatable":"true","isRequired":"true"},{"Field":"Customer_Impacting__c","isUpdatable":"true","isRequired":"false"},{"Field":"Functional_Area__c","isUpdatable":"true","isRequired":"true"},{"Field":"NI_Change_Owner__c","isUpdatable":"true","isRequired":"false"},{"Field":"Change_Type__c","isUpdatable":"true","isRequired":"true"},{"Field":"Date_Required__c","isUpdatable":"true","isRequired":"true"},{"Field":"Environment_s_Affected__c","isUpdatable":"true","isRequired":"false"},{"Field":"Days_Open__c","isUpdatable":"false","isRequired":"false"},{"Field":"Related_Change_Request__c","isUpdatable":"true","isRequired":"false"},{"Field":"Manager_Reviewer__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Change Request Detail","Columns":"1","Fields":[{"Field":"Request_Summary__c","isUpdatable":"true","isRequired":"true"},{"Field":"Request_Details__c","isUpdatable":"true","isRequired":"true"}]},{"Header":"Deployment Information","Columns":"1","Fields":[{"Field":"Change_Steps__c","isUpdatable":"true","isRequired":"false"},{"Field":"Rollback_Plan__c","isUpdatable":"true","isRequired":"false"},{"Field":"Test_Plan__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Project Backlog Information","Columns":"2","Fields":[{"Field":"NI_Project_Backlog__c","isUpdatable":"true","isRequired":"false"},{"Field":"NI_Project_Backlog_Task__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Approval Information","Columns":"1","Fields":[{"Field":"Approval_Status__c","isUpdatable":"true","isRequired":"true"},{"Field":"Date_Approved__c","isUpdatable":"true","isRequired":"false"},{"Field":"Days_Since_Approved__c","isUpdatable":"false","isRequired":"false"}]},{"Header":"Implementation Information","Columns":"1","Fields":[{"Field":"Change_Status__c","isUpdatable":"true","isRequired":"false"},{"Field":"Date_Scheduled__c","isUpdatable":"true","isRequired":"false"},{"Field":"Date_Changed__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Sandbox Implementation","Columns":"1","Fields":[{"Field":"Sandbox_Implementation_Status__c","isUpdatable":"true","isRequired":"false"},{"Field":"Sandbox_Implementation_Comments__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Information","Columns":"2","Fields":[{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"}]},{"Header":"System Information","Columns":"2","Fields":[{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"CreatedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"CreatedDate","isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedDate","isUpdatable":"false","isRequired":"false"}]}]';
        
        cntlr.showSelectedRecord();
        cntlr.niccObjNew.Request_Summary__c = 'Test summmary.';
        cntlr.niccObjNew.Request_Details__c = 'Test request details.';
        cntlr.niccObjNew.NI_Change_Owner__c = null;

        cntlr.create_NI_Change_Control();
        
        system.debug('cntlr.niccObjNew : '+cntlr.niccObjNew.id);
        system.assertNotEquals(NULL, cntlr.niccObjNew.id, 'Record ID is null.');
    }
    
    
    @isTest
    static void testMethod2()
    {
        // GET RECORD TYPE IDS AND STORE IN A MAP
        Map<Id, String> rtMap = new Map<Id, String>();
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.NI_Change_Control__c.getRecordTypeInfosByName();
        
        system.debug('recordTypesMap : '+recordTypesMap);
        String recTypeId = '';
        if (!recordTypesMap.isEmpty()) 
        {
            if (recordTypesMap.containsKey('Salesforce.com Change Request')) 
            {
                Schema.RecordTypeInfo rr = recordTypesMap.get('Salesforce.com Change Request');
                recTypeId = rr.getRecordTypeId();
                system.debug('recTypeId : '+recTypeId);
            }
        }
        
        NI_Change_Control__c nicc = new NI_Change_Control__c();
        
        PageReference pageRef = Page.AH_New_NI_Change_Control_Request;
        ApexPages.currentPage().getParameters().put('flagOfRt','false');
        ApexPages.currentPage().getParameters().put('rt',recTypeId);
        
		ApexPages.StandardController sc = new ApexPages.StandardController(nicc);
        AH_New_NI_Change_Control_Request_Cntlr cntlr = new AH_New_NI_Change_Control_Request_Cntlr(sc);       

        Test.setCurrentPage(pageRef);
        
        cntlr.strLayoutFields = '[{"Header":"Change Request","Columns":"2","Fields":[{"Field":"RecordTypeId","isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"Name","isUpdatable":"false","isRequired":"false"},{"Field":"OwnerId","isUpdatable":"false","isRequired":"false"},{"Field":"Salesforce_Application__c","isUpdatable":"true","isRequired":"false"},{"Field":"Priority__c","isUpdatable":"true","isRequired":"true"},{"Field":"Change_Reason__c","isUpdatable":"true","isRequired":"true"},{"Field":"Customer_Impacting__c","isUpdatable":"true","isRequired":"false"},{"Field":"Functional_Area__c","isUpdatable":"true","isRequired":"true"},{"Field":"NI_Change_Owner__c","isUpdatable":"true","isRequired":"false"},{"Field":"Change_Type__c","isUpdatable":"true","isRequired":"true"},{"Field":"Date_Required__c","isUpdatable":"true","isRequired":"true"},{"Field":"Environment_s_Affected__c","isUpdatable":"true","isRequired":"false"},{"Field":"Days_Open__c","isUpdatable":"false","isRequired":"false"},{"Field":"Related_Change_Request__c","isUpdatable":"true","isRequired":"false"},{"Field":"Manager_Reviewer__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Change Request Detail","Columns":"1","Fields":[{"Field":"Request_Summary__c","isUpdatable":"true","isRequired":"true"},{"Field":"Request_Details__c","isUpdatable":"true","isRequired":"true"}]},{"Header":"Deployment Information","Columns":"1","Fields":[{"Field":"Change_Steps__c","isUpdatable":"true","isRequired":"false"},{"Field":"Rollback_Plan__c","isUpdatable":"true","isRequired":"false"},{"Field":"Test_Plan__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Project Backlog Information","Columns":"2","Fields":[{"Field":"NI_Project_Backlog__c","isUpdatable":"true","isRequired":"false"},{"Field":"NI_Project_Backlog_Task__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Approval Information","Columns":"1","Fields":[{"Field":"Approval_Status__c","isUpdatable":"true","isRequired":"true"},{"Field":"Date_Approved__c","isUpdatable":"true","isRequired":"false"},{"Field":"Days_Since_Approved__c","isUpdatable":"false","isRequired":"false"}]},{"Header":"Implementation Information","Columns":"1","Fields":[{"Field":"Change_Status__c","isUpdatable":"true","isRequired":"false"},{"Field":"Date_Scheduled__c","isUpdatable":"true","isRequired":"false"},{"Field":"Date_Changed__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Sandbox Implementation","Columns":"1","Fields":[{"Field":"Sandbox_Implementation_Status__c","isUpdatable":"true","isRequired":"false"},{"Field":"Sandbox_Implementation_Comments__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Information","Columns":"2","Fields":[{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"}]},{"Header":"System Information","Columns":"2","Fields":[{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"CreatedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"CreatedDate","isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedDate","isUpdatable":"false","isRequired":"false"}]}]';
        
        cntlr.cancelSave();
        
    }
}