/****************************************************************************************
Name            : AH_cloneRFC_Test Class
Author          : Shashikant Nikam
Created Date    : 09/19/2019
Last Mod Date   : 09/20/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_cloneRFC_Cntlr class
				: 
******************************************************************************************/
@isTest  
public class AH_cloneRFC_Test {

    @testSetup 
    static void createTestData()
    {
        NI_Change_Control__c nicc = NI_TestClassData.createNIChangeControl(1, 'Test Record');
        nicc.Salesforce_Application__c = 'Salesforce';
        nicc.Change_Reason__c = 'Additional Functionality';
        nicc.Priority__c = 'Medium';
        nicc.Date_Required__c = Date.today().addDays(7);
        nicc.Approval_Status__c = 'Not Submitted';
        nicc.Change_Status__c = 'Open';
        nicc.Request_Summary__c = 'Test summmary.';
        nicc.Request_Details__c = 'Test request details.';
        nicc.Change_Type__c = 'Add Field History Tracking';
		nicc.Functional_Area__c = 'Sales';
        insert nicc;
        
    }
    
    @isTest
    static void testMethod1()
    {
        List<NI_Change_Control__c> niccList = new List<NI_Change_Control__c>([SELECT ID FROM NI_Change_Control__c]);
        
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
        
        Test.setMock(HttpCalloutMock.class, new AH_cloneRFC_Mock());

        Test.startTest();
        
        PageReference pageRef = Page.AH_cloneRFC;
        ApexPages.currentPage().getParameters().put('id', niccList[0].id);
        ApexPages.currentPage().getParameters().put('flagOfRt', 'false');
        ApexPages.currentPage().getParameters().put('rt', recTypeId);
        
		ApexPages.StandardController sc = new ApexPages.StandardController(niccList[0]);
        AH_cloneRFC_Cntlr cntlr = new AH_cloneRFC_Cntlr(sc);       

        Test.setCurrentPage(pageRef);

        cntlr.strLayoutFields = '[{"Header":"Requester Details","Columns":"2","Fields":[{"Field":"RecordTypeId","isUpdatable":"false","isRequired":"false"},{"Field":"Name","isUpdatable":"false","isRequired":"false"},{"Field":"OwnerId","isUpdatable":"false","isRequired":"false"},{"Field":"Change_Status__c","isUpdatable":"true","isRequired":"false"},{"Field":"Requester__c","isUpdatable":"false","isRequired":"false"},{"Field":"Requesting_on_Behalf_of__c","isUpdatable":"true","isRequired":"false"},{"Field":"Priority__c","isUpdatable":"true","isRequired":"false"},{"Field":"Date_Required__c","isUpdatable":"true","isRequired":"true"},{"Field":"Deployment_Group__c","isUpdatable":"true","isRequired":"false"},{"Field":"Developer_Compiler__c","isUpdatable":"true","isRequired":"false"},{"Field":"Request_for_Standard_Change__c","isUpdatable":"true","isRequired":"false"},{"Field":"Standard_Change__c","isUpdatable":"true","isRequired":"false"},{"Field":"Project__c","isUpdatable":"true","isRequired":"false"},{"Field":"Milestone__c","isUpdatable":"true","isRequired":"false"},{"Field":"Risk_Level_Indicator__c","isUpdatable":"false","isRequired":"false"}]},{"Header":"Custom Links","Columns":"3","Fields":[{"Field":"Calculate_Risk_Hosted","isUpdatable":"false","isRequired":"false"}]},{"Header":"Risk Calculation","Columns":"1","Fields":[{"Field":"Risk_Level__c","isUpdatable":"true","isRequired":"false"},{"Field":"AdditionalRisks__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Description","Columns":"1","Fields":[{"Field":"Request_Summary__c","isUpdatable":"true","isRequired":"true"},{"Field":"Request_Details__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Compiler Details","Columns":"2","Fields":[{"Field":"Change_Type__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"Data_Change__c","isUpdatable":"true","isRequired":"false"},{"Field":"Outage_Required__c","isUpdatable":"true","isRequired":"false"},{"Field":"Custom_Script__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"Developer_Approved__c","isUpdatable":"true","isRequired":"false"},{"Field":"New_Custom_Script__c","isUpdatable":"true","isRequired":"false"},{"Field":"Peer_Reviewer__c","isUpdatable":"true","isRequired":"false"},{"Field":"Peer_Reviewer_Approved__c","isUpdatable":"true","isRequired":"false"},{"Field":"Related_Hosted_RFC__c","isUpdatable":"true","isRequired":"false"},{"Field":"Developer_Reviewer__c","isUpdatable":"true","isRequired":"false"},{"Field":"Environment_s_Affected__c","isUpdatable":"true","isRequired":"true"},{"Field":"Related_Servers__c","isUpdatable":"true","isRequired":"false"},{"Field":"Product_Name__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Deployment Owner Details","Columns":"2","Fields":[{"Field":"NI_Change_Owner__c","isUpdatable":"true","isRequired":"false"},{"Field":"Deployment_Owner_Manager__c","isUpdatable":"false","isRequired":"false"},{"Field":"Date_Scheduled__c","isUpdatable":"true","isRequired":"true"},{"Field":"Date_Changed__c","isUpdatable":"true","isRequired":"false"},{"Field":"Assigned_Production_End_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"Implementation_Status__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Approval & Status Details","Columns":"2","Fields":[{"Field":"Manager_Reviewer__c","isUpdatable":"true","isRequired":"false"},{"Field":"CRB_Approval_Status__c","isUpdatable":"true","isRequired":"false"},{"Field":"Manager_Reviewer_Status__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Hidden Fields","Columns":"2","Fields":[{"Field":"Case_Id__c","isUpdatable":"true","isRequired":"false"},{"Field":"HasAllArtifacts__c","isUpdatable":"true","isRequired":"false"},{"Field":"Related_Account_Summary__c","isUpdatable":"false","isRequired":"false"},{"Field":"Ready_for_Manager_Reviewer_Approval__c","isUpdatable":"true","isRequired":"false"},{"Field":"Cloned__c","isUpdatable":"true","isRequired":"false"},{"Field":"Cloned_From__c","isUpdatable":"true","isRequired":"false"},{"Field":"Cloned_w_Artifacts__c","isUpdatable":"true","isRequired":"false"},{"Field":"Re_submit_for_Approval__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Information","Columns":"2","Fields":[{"Field":null,"isUpdatable":"false","isRequired":"false"}]},{"Header":"System Information","Columns":"2","Fields":[{"Field":"Days_Open__c","isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"CreatedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"CreatedDate","isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedDate","isUpdatable":"false","isRequired":"false"}]}]';
        cntlr.showSelectedRecord();
        cntlr.create_NI_Change_Control();
        
		system.assertNotEquals(NULL, cntlr.niccObjNew.id, 'Record ID is null.');
        
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2()
    {
        List<NI_Change_Control__c> niccList = new List<NI_Change_Control__c>([SELECT ID FROM NI_Change_Control__c]);
        
        // GET RECORD TYPE IDS AND STORE IN A MAP
        Map<Id, String> rtMap = new Map<Id, String>();
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.NI_Change_Control__c.getRecordTypeInfosByName();
        
        system.debug('recordTypesMap : '+recordTypesMap);
        String recTypeId = '';
        if (!recordTypesMap.isEmpty()) 
        {
            if (recordTypesMap.containsKey('Hosted RFC')) 
            {
                Schema.RecordTypeInfo rr = recordTypesMap.get('Hosted RFC');
                recTypeId = rr.getRecordTypeId();
                system.debug('recTypeId : '+recTypeId);
            }
        }
        
        Test.setMock(HttpCalloutMock.class, new AH_cloneRFC_Mock());

        Test.startTest();
        
        PageReference pageRef = Page.AH_cloneRFC;
        ApexPages.currentPage().getParameters().put('id', niccList[0].id);
        ApexPages.currentPage().getParameters().put('flagOfRt', 'false');
        ApexPages.currentPage().getParameters().put('rt', recTypeId);
        
		ApexPages.StandardController sc = new ApexPages.StandardController(niccList[0]);
        AH_cloneRFC_Cntlr cntlr = new AH_cloneRFC_Cntlr(sc);       

        Test.setCurrentPage(pageRef);

        cntlr.strLayoutFields = '[{"Header":"Requester Details","Columns":"2","Fields":[{"Field":"RecordTypeId","isUpdatable":"false","isRequired":"false"},{"Field":"Name","isUpdatable":"false","isRequired":"false"},{"Field":"OwnerId","isUpdatable":"false","isRequired":"false"},{"Field":"Change_Status__c","isUpdatable":"true","isRequired":"false"},{"Field":"Requester__c","isUpdatable":"false","isRequired":"false"},{"Field":"Requesting_on_Behalf_of__c","isUpdatable":"true","isRequired":"false"},{"Field":"Priority__c","isUpdatable":"true","isRequired":"false"},{"Field":"Date_Required__c","isUpdatable":"true","isRequired":"true"},{"Field":"Deployment_Group__c","isUpdatable":"true","isRequired":"false"},{"Field":"Developer_Compiler__c","isUpdatable":"true","isRequired":"false"},{"Field":"Request_for_Standard_Change__c","isUpdatable":"true","isRequired":"false"},{"Field":"Standard_Change__c","isUpdatable":"true","isRequired":"false"},{"Field":"Project__c","isUpdatable":"true","isRequired":"false"},{"Field":"Milestone__c","isUpdatable":"true","isRequired":"false"},{"Field":"Risk_Level_Indicator__c","isUpdatable":"false","isRequired":"false"}]},{"Header":"Custom Links","Columns":"3","Fields":[{"Field":"Calculate_Risk_Hosted","isUpdatable":"false","isRequired":"false"}]},{"Header":"Risk Calculation","Columns":"1","Fields":[{"Field":"Risk_Level__c","isUpdatable":"true","isRequired":"false"},{"Field":"AdditionalRisks__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Description","Columns":"1","Fields":[{"Field":"Request_Summary__c","isUpdatable":"true","isRequired":"true"},{"Field":"Request_Details__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Compiler Details","Columns":"2","Fields":[{"Field":"Change_Type__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"Data_Change__c","isUpdatable":"true","isRequired":"false"},{"Field":"Outage_Required__c","isUpdatable":"true","isRequired":"false"},{"Field":"Custom_Script__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"Developer_Approved__c","isUpdatable":"true","isRequired":"false"},{"Field":"New_Custom_Script__c","isUpdatable":"true","isRequired":"false"},{"Field":"Peer_Reviewer__c","isUpdatable":"true","isRequired":"false"},{"Field":"Peer_Reviewer_Approved__c","isUpdatable":"true","isRequired":"false"},{"Field":"Related_Hosted_RFC__c","isUpdatable":"true","isRequired":"false"},{"Field":"Developer_Reviewer__c","isUpdatable":"true","isRequired":"false"},{"Field":"Environment_s_Affected__c","isUpdatable":"true","isRequired":"true"},{"Field":"Related_Servers__c","isUpdatable":"true","isRequired":"false"},{"Field":"Product_Name__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Deployment Owner Details","Columns":"2","Fields":[{"Field":"NI_Change_Owner__c","isUpdatable":"true","isRequired":"false"},{"Field":"Deployment_Owner_Manager__c","isUpdatable":"false","isRequired":"false"},{"Field":"Date_Scheduled__c","isUpdatable":"true","isRequired":"true"},{"Field":"Date_Changed__c","isUpdatable":"true","isRequired":"false"},{"Field":"Assigned_Production_End_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"Implementation_Status__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Approval & Status Details","Columns":"2","Fields":[{"Field":"Manager_Reviewer__c","isUpdatable":"true","isRequired":"false"},{"Field":"CRB_Approval_Status__c","isUpdatable":"true","isRequired":"false"},{"Field":"Manager_Reviewer_Status__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Hidden Fields","Columns":"2","Fields":[{"Field":"Case_Id__c","isUpdatable":"true","isRequired":"false"},{"Field":"HasAllArtifacts__c","isUpdatable":"true","isRequired":"false"},{"Field":"Related_Account_Summary__c","isUpdatable":"false","isRequired":"false"},{"Field":"Ready_for_Manager_Reviewer_Approval__c","isUpdatable":"true","isRequired":"false"},{"Field":"Cloned__c","isUpdatable":"true","isRequired":"false"},{"Field":"Cloned_From__c","isUpdatable":"true","isRequired":"false"},{"Field":"Cloned_w_Artifacts__c","isUpdatable":"true","isRequired":"false"},{"Field":"Re_submit_for_Approval__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Information","Columns":"2","Fields":[{"Field":null,"isUpdatable":"false","isRequired":"false"}]},{"Header":"System Information","Columns":"2","Fields":[{"Field":"Days_Open__c","isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"CreatedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"CreatedDate","isUpdatable":"false","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedDate","isUpdatable":"false","isRequired":"false"}]}]';
        cntlr.showSelectedRecord();
        cntlr.cancelSave();
        
        Test.stopTest();
    }
}