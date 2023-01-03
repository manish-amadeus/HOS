/****************************************************************************************
Name            : NI_HRM_ConfigurationTest Class
Author          : Snezhana Shevchenko (sshevchenko@newmarketinc.com) 
Created Date    : 10/20/2015
Last Mod Date   : 4/2/2016 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-017304
Description     : Test Class for the NI_HRM_Configuration Class
                : 
******************************************************************************************/
@isTest
private class NI_HRM_ConfigurationTest{
    
    static testMethod void checkNoRecords(){
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        test.setCurrentPage(pageRef);
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            system.assertEquals(cls.reqId, null);
            system.assertEquals(cls.editId, null);
            system.assertEquals(cls.noRecords, true);
            system.assertEquals(cls.isEditRequirement, false);
            
            for(String tab : cls.tabs.keySet()){
                Id tabId = cls.tabs.get(tab);
                NI_HRM_Configuration.TabContent tc = cls.tab_content.get(tab);
                system.assertEquals(tc.totalPages, 1);
                system.assertEquals(tc.currentPage, 1);
                system.assertEquals(tc.sortIds.size(), 1);
                system.assertEquals(tc.sortIds[0], 'new'+tabId);
                system.assertEquals(tc.items.size(), 1);
                map<String,HRM_Configuration__c> testConfigs = new map<String,HRM_Configuration__c>{
                    'new'+tabId => NI_HRM_Configuration.getEmptyConfig(tabId, null)
                }; 
                compareConfigs(tc.items, testConfigs);
            }                   
        test.stopTest();
    }
    
    static testMethod void checkIncorrectReqIdAndDocId(){
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        pageRef.getParameters().put('reqId','incorrectParam');
        pageRef.getParameters().put('docId','incorrectParam');
        test.setCurrentPage(pageRef);
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            system.assertEquals(cls.reqId, null);
            system.assertEquals(cls.editId, null);
            system.assertEquals(cls.noRecords, true);
            system.assertEquals(cls.isEditRequirement, false);
            
            for(String tab : cls.tabs.keySet()){
                Id tabId = cls.tabs.get(tab);
                NI_HRM_Configuration.TabContent tc = cls.tab_content.get(tab);
                system.assertEquals(tc.totalPages, 1);
                system.assertEquals(tc.currentPage, 1);
                system.assertEquals(tc.sortIds.size(), 1);
                system.assertEquals(tc.sortIds[0], 'new'+tabId);
                system.assertEquals(tc.items.size(), 1);
                map<String,HRM_Configuration__c> testConfigs = new map<String,HRM_Configuration__c>{
                    'new'+tabId => NI_HRM_Configuration.getEmptyConfig(tabId, null)
                }; 
                compareConfigs(tc.items, testConfigs);
            }                   
        test.stopTest();
    }
    
    static testMethod void checkCreateRequirement_Error(){
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        test.setCurrentPage(pageRef);
        
        NI_Documentation__c doc = createDocumentation('Doc1');
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            cls.addReq();
            system.assertNotEquals(ApexPages.getMessages().size(), 0);
            system.assert(String.valueOf(ApexPages.getMessages()).contains('REQUIRED_FIELD_MISSING'), String.valueOf(ApexPages.getMessages()));
            system.assertEquals(cls.reqId, null);
        test.stopTest();
    }
    
    static testMethod void checkCreateRequirement_Success(){
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        test.setCurrentPage(pageRef);
        
        NI_Documentation__c doc = createDocumentation('Doc1');
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            cls.requirement.HRM_Configuration_Document__c = doc.Id;
            cls.addReq();
            system.assert(ApexPages.getMessages().size() == 0, ApexPages.getMessages());
            system.assertNotEquals(cls.reqId, null);                    
        test.stopTest();
    }
    
    static testMethod void checkRequirement_editReq(){
        HRM_Requirement__c req = createRequirement('TestReq');
        
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        pageRef.getParameters().put('reqId',req.Id);
        test.setCurrentPage(pageRef);
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            cls.editReq();
            system.assertEquals(cls.isEditRequirement, true);
            system.assertEquals(cls.editId, null);                  
        test.stopTest();
    }
    
    static testMethod void checkRequirement_cancelReq(){
        HRM_Requirement__c req = createRequirement('TestReq');
        
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        pageRef.getParameters().put('reqId',req.Id);
        test.setCurrentPage(pageRef);
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            cls.requirement.Purpose__c = 'Some text';
            cls.cancelReq();
            system.assertEquals(cls.requirement.Purpose__c, null);
            system.assertEquals(cls.isEditRequirement, false);
            system.assertEquals(cls.editId, null);                  
        test.stopTest();
    }
    
    static testMethod void addNewConfig_Error(){
        HRM_Requirement__c req = createRequirement('TestNIDoc');
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>{
            createConfig('TestConf1', req.Id)
        };
        insert confs;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        pageRef.getParameters().put('reqId', req.Id);
        test.setCurrentPage(pageRef);
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            String tab = 'General Configuration';
            Id tabId = cls.tabs.get(tab);
            cls.editId = 'new'+tabId;
            HRM_Configuration__c existConf = cls.tab_content.get(tab).items.get('new'+tabId);
            existConf.Configuration_Name__c = 'TestConf2';
            cls.saveConf();
            system.assertNotEquals(ApexPages.getMessages().size(), 0);
            system.assert(String.valueOf(ApexPages.getMessages()).contains('The Configuration Details or Type need to be filled in'), String.valueOf(ApexPages.getMessages()));                 
        test.stopTest();
    }
    
    static testMethod void addNewConfig_Success(){
        HRM_Requirement__c req = createRequirement('TestNIDoc');
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>{
            createConfig('TestConf1', req.Id)
        };
        insert confs;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        pageRef.getParameters().put('reqId', req.Id);
        test.setCurrentPage(pageRef);
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            String tab = 'General Configuration';
            Id tabId = cls.tabs.get(tab);
            cls.editId = 'new'+tabId;
            HRM_Configuration__c existConf = cls.tab_content.get(tab).items.get('new'+tabId);
            existConf.Configuration_Name__c = 'TestConf2';
            existConf.Configuration_Type__c = 'View';
            cls.saveConf();
            system.assertEquals(ApexPages.getMessages().size(), 0);
        test.stopTest();
    }
    
    static testMethod void addConfig_Cancel(){
        HRM_Requirement__c req = createRequirement('TestNIDoc');
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>{
            createConfig('TestConf1', req.Id)
        };
        insert confs;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        pageRef.getParameters().put('reqId', req.Id);
        test.setCurrentPage(pageRef);
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            String tab = 'General Configuration';
            Id tabId = cls.tabs.get(tab);
            cls.editId = confs[0].Id;
            HRM_Configuration__c existConf = cls.tab_content.get(tab).items.get(confs[0].Id);
            existConf.Configuration_Name__c = 'TestConf2';
            cls.cancelConf();
            system.assertEquals(ApexPages.getMessages().size(), 0);
            system.assertEquals(cls.editId, null);
        test.stopTest();
        
        list<HRM_Configuration__c> existConfs = getExistConfigs();
        system.assertEquals(existConfs.size(),1);
        system.assertEquals(existConfs[0].Configuration_Name__c, 'TestConf1');
    }
    
    static testMethod void addConfig_Delete(){
        HRM_Requirement__c req = createRequirement('TestNIDoc');
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>{
            createConfig('TestConf1', req.Id)
        };
        insert confs;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        pageRef.getParameters().put('reqId', req.Id);
        test.setCurrentPage(pageRef);
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            String tab = 'General Configuration';
            Id tabId = cls.tabs.get(tab);
            cls.editId = confs[0].Id;
            cls.deleteConf();
            system.assertEquals(ApexPages.getMessages().size(), 0);
            system.assertEquals(cls.editId, null);
        test.stopTest();
        
        list<HRM_Configuration__c> existConfs = getExistConfigs();
        system.assertEquals(existConfs.size(),0);
    }
    
    static testMethod void checkPagination(){
        HRM_Requirement__c req = createRequirement('TestNIDoc');
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>();
        for(Integer i=0; i<(2*200+5); i++)
            confs.add(createConfig('TestConf'+i, req.Id));
        insert confs;
        map<String,HRM_Configuration__c> confsMap = new map<String,HRM_Configuration__c>();
        for(HRM_Configuration__c c : confs)
            confsMap.put(c.Id, c);
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        pageRef.getParameters().put('reqId', req.Id);
        test.setCurrentPage(pageRef);
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            String tab = 'General Configuration';
            Id tabId = cls.tabs.get(tab);
            NI_HRM_Configuration.TabContent tc = cls.tab_content.get(tab);
            system.assertEquals(tc.totalPages, 3);
            system.assertEquals(tc.currentPage, 1);
            system.assertEquals(tc.sortIds.size(), 201);
            system.assertEquals(tc.items.size(), 201);
            
            confsMap.put('new'+tabId, NI_HRM_Configuration.getEmptyConfig(tabId, null));
            map<String,HRM_Configuration__c> testConfigs = new map<String,HRM_Configuration__c>();
            for(String cId : tc.items.keySet())
                testConfigs.put(cId, confsMap.get(cId));
            compareConfigs(tc.items, testConfigs);
            
            cls.next();
            tc = cls.tab_content.get(tab);
            system.assertEquals(tc.currentPage, 2);
            cls.next();
            tc = cls.tab_content.get(tab);
            system.assertEquals(tc.currentPage, 3);
            cls.previous();
            tc = cls.tab_content.get(tab);
            system.assertEquals(tc.currentPage, 2);
            cls.last();
            tc = cls.tab_content.get(tab);
            system.assertEquals(tc.currentPage, 3);
            cls.first();
            tc = cls.tab_content.get(tab);
            system.assertEquals(tc.currentPage, 1);
        test.stopTest();
    }
    
    static testMethod void changeItemsOnPage(){
        HRM_Requirement__c req = createRequirement('TestNIDoc');
        list<HRM_Configuration__c> confs = new list<HRM_Configuration__c>();
        for(Integer i=0; i<(3*200+5); i++)
            confs.add(createConfig('TestConf'+i, req.Id));
        insert confs;
        map<String,HRM_Configuration__c> confsMap = new map<String,HRM_Configuration__c>();
        for(HRM_Configuration__c c : confs)
            confsMap.put(c.Id, c);
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(confs);
        PageReference pageRef = Page.HRMConfiguration;
        pageRef.getParameters().put('reqId', req.Id);
        test.setCurrentPage(pageRef);
        
        test.startTest();
            NI_HRM_Configuration cls = new NI_HRM_Configuration();
            String tab = 'General Configuration';
            Id tabId = cls.tabs.get(tab);
            NI_HRM_Configuration.TabContent tc = cls.tab_content.get(tab);
            system.assertEquals(tc.totalPages, 4);
            system.assertEquals(tc.currentPage, 1);
            system.assertEquals(tc.sortIds.size(), 201);
            system.assertEquals(tc.items.size(), 201);
            cls.last();
            tc = cls.tab_content.get(tab);
            system.assertEquals(tc.currentPage, 4);
            system.assertEquals(tc.itemsOnPage, 200);
            cls.getItemsOnPageOptions();
            tc.itemsOnPage = 100;
            cls.changeItemsOnPage();
            tc = cls.tab_content.get(tab);
            system.assertEquals(tc.currentPage, 1);
            system.assertEquals(tc.itemsOnPage, 100);
        test.stopTest();
    }
    
    //HELP METHODS
    
    private static final set<String> compareConfFields = new set<String>{'Configuration_Name__c', 'Configuration_Action__c', 'Configuration_Type__c', 'Field_Type__c', 'Status__c', 'Time_to_Complete__c', 'Business_Reason__c', 'Configuration_Details__c', 'RecordTypeId'};
    private static Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'General Configuration' limit 1].Id;
    
    private static NI_Documentation__c createDocumentation(String name){
        NI_Documentation__c doc = new NI_Documentation__c(
            Document_Name__c = name,
            Document_Type__c = 'Agenda',
            Stage__c = 'Draft'
        );
        insert doc;
        return doc;
    }
    
    private static list<HRM_Configuration__c> getExistConfigs(){
        return [SELECT Id, Name, Configuration_Name__c, Configuration_Action__c, Configuration_Type__c, Configuration_Details__c, 
                    Field_Type__c, Business_Reason__c, Status__c, Time_to_Complete__c, HRM_Requirement__c, 
                    RecordType.Name, RecordTypeId 
                FROM HRM_Configuration__c 
                order by Name asc];
    }
    
    private static HRM_Requirement__c createRequirement(String name){
        NI_Documentation__c doc = createDocumentation(name);
        
        HRM_Requirement__c req = new HRM_Requirement__c(
            HRM_Configuration_Document__c = doc.Id
        );
        insert req;
        return req;
    }
    
    private static HRM_Configuration__c createConfig(String name, Id reqId){
        return new HRM_Configuration__c(
            HRM_Requirement__c = reqId,
            Configuration_Name__c = name,
            Configuration_Action__c = 'Edit',
            Configuration_Type__c = 'Field',
            Field_Type__c = 'Formula',
            Status__c = 'Client to Complete',
            Time_to_Complete__c = 10,
            Business_Reason__c = 'Test Business Reason',
            Configuration_Details__c = 'Test Config Details',
            RecordTypeId = recordTypeId
        );
    }
    
    private static void compareConfigs(map<String,HRM_Configuration__c> conf1, map<String,HRM_Configuration__c> conf2){
        system.assertEquals(conf1.size(), conf2.size());
        for(String key : conf1.keySet())
            system.assert(compareObjects(conf1.get(key), conf2.get(key), compareConfFields));
    }
    
    private static void compareConfigs(HRM_Configuration__c conf1, HRM_Configuration__c conf2){
        system.assert(compareObjects(conf1, conf2, compareConfFields), 'CONF1: '+conf1+'   CONF2: '+conf2);
    }
    
    private static Boolean compareObjects(sObject obj1, sObject obj2, set<String> compareFields){
        for(String field : compareFields){
            if(obj1.get(field) != obj2.get(field))
                return false;
        }
        return true;
    }
}