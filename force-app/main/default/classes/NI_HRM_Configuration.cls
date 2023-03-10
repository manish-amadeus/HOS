/****************************************************************************************
Name            : NI_HRM_Configuration Class
Author          : Snezhana Shevchenko (sshevchenko@newmarketinc.com) 
Created Date    : 10/20/2015
Last Mod Date   : 4/2/2016 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-017304
Description     : Controller for the HRMConfiguration Visualforce Page
                : 
******************************************************************************************/
public with sharing class NI_HRM_Configuration{
    public Id reqId {get;set;}
    public String editId {get;set;}
    public Boolean noRecords {get;set;}
    public String selectedTab {get;set;}
    public map<String,Id> tabs {get;set;}
    public Boolean isEditRequirement {get;set;}
    public HRM_Requirement__c requirement {get;set;}
    public map<String,TabContent> tab_content {get;set;}
    
    public map<String,list<String>> tab_confSortIds = new map<String,list<String>>();
    public map<String,map<String,HRM_Configuration__c>> tab_configurations = new map<String,map<String,HRM_Configuration__c>>();
    
    public NI_HRM_Configuration(){
        init();
    }
    
    public void init(){
        isEditRequirement = false;
        
        //Get Requirement Id from url
        if(reqId == null){
            try{
                reqId = (ApexPages.currentPage().getParameters().containsKey('reqId') ? (Id)ApexPages.currentPage().getParameters().get('reqId') : null);
            }
            catch(Exception e){}
        }
        
        //Get NI Documentation Id from url
        Id docId;
        if(docId == null){
            try{
                docId = (ApexPages.currentPage().getParameters().containsKey('docId') ? (Id)ApexPages.currentPage().getParameters().get('docId') : null);
            }
            catch(Exception e){}
        }
        
        //Get Requirement (new or existing)
        requirement = new HRM_Requirement__c(
            HRM_Configuration_Document__c = docId,
            Object_or_Function__c = null,
            Purpose__c = null,
            Assumptions__c = null,
            Out_of_Scope__c = null
        );
        if(reqId != null){
            try{
                requirement = [SELECT Id, Name, HRM_Configuration_Document__c, Object_or_Function__c, Purpose__c, Assumptions__c, Out_of_Scope__c FROM HRM_Requirement__c WHERE Id = :reqId limit 1];
            }
            catch(Exception e){
                reqId = null;
            }
        }
        
        noRecords = true;
        list<String> confSortIds;
        map<String,HRM_Configuration__c> configurations;
        
        tabs = new map<String,Id>();
        map<String,Schema.RecordTypeInfo> srt = Schema.SObjectType.HRM_Configuration__c.getRecordTypeInfosByName();
        for(String label : srt.keySet()){
            if(srt.get(label).isAvailable() && new set<String>{'General Configuration','Security','Workflow'}.contains(label)){
                if(selectedTab == null && srt.get(label).isDefaultRecordTypeMapping())
                    selectedTab = label;
                tabs.put(label, srt.get(label).getRecordTypeId());
            }
        }
        
        //Prepopulate tab maps
        for(String tab : tabs.keySet()){
            tab_confSortIds.put(tab, new list<String>());
            tab_configurations.put(tab, new map<String,HRM_Configuration__c>());
        }

        //Populate tab maps
        for(HRM_Configuration__c conf : getAllRecords()){
            if(noRecords) noRecords = false;
            
            confSortIds = (tab_confSortIds.containsKey(conf.RecordType.Name)) ?
                tab_confSortIds.get(conf.RecordType.Name) : new list<String>();
            confSortIds.add(conf.Id);
            tab_confSortIds.put(conf.RecordType.Name, confSortIds);
            
            configurations = (tab_configurations.containsKey(conf.RecordType.Name)) ? 
                tab_configurations.get(conf.RecordType.Name) : new map<String,HRM_Configuration__c>();
            configurations.put(conf.Id, conf);
            tab_configurations.put(conf.RecordType.Name, configurations);
        }
        
        setPagination();

        system.debug('Tab_Check 1:' + tab_configurations.get('General Configuration'));
        system.debug('Tab_Check 2:' + tab_configurations.get('Security'));
        system.debug('Tab_Check 3:' + tab_configurations.get('Workflow'));
    }
    
    private void setPagination(){
        if(tab_content == null)
            tab_content = new map<String,TabContent>();
        
        TabContent tabContent;
        for(String tab : tabs.keySet()){
            tabContent = new TabContent();
            if(tab_content.containsKey(tab)){
                tabContent.currentPage = tab_content.get(tab).currentPage;
                tabContent.itemsOnPage = tab_content.get(tab).itemsOnPage;
            }
            tabContent.calcPagination(reqId, tabs.get(tab), tab_confSortIds.get(tab), tab_configurations.get(tab));
            tab_content.put(tab, tabContent);
        }
    }
    
    public class TabContent{
        public Integer totalPages {get;set;}
        public Integer currentPage {get;set;}
        public Integer itemsOnPage {get;set;}
        public list<String> sortIds {get;set;}
        public map<String,HRM_Configuration__c> items {get;set;}
        
        public TabContent(){}
        
        private void calcPagination(Id reqId, Id tabId, list<String> sortIds, map<String,HRM_Configuration__c> items){
            if(currentPage == null) currentPage = 1;
            if(itemsOnPage == null) itemsOnPage = 200;
            
            Integer min = (currentPage - 1) * itemsOnPage;
            Integer max = min + itemsOnPage;
            if(max > items.size())
                max = items.size();
            
            Decimal dTotalPages = (items.size() / itemsOnPage);
            dTotalPages = Math.floor(dtotalPages) + ((Math.mod(items.size(), itemsOnPage)>0) ? 1 : 0);
            totalPages = Integer.valueOf(dtotalPages);
            if(totalPages == 0) totalPages = 1;
            
            this.items = new map<String,HRM_Configuration__c>();
            this.sortIds = new list<String>();
            for(Integer i=min; i<max; i++){
                this.sortIds.add(sortIds[i]);
                this.items.put(sortIds[i], items.get(sortIds[i]));
            }
            this.sortIds.add('new'+tabId);
            this.items.put('new'+tabId, getEmptyConfig(tabId, reqId));
        }
    }
    
    private list<HRM_Configuration__c> getAllRecords(){
        return [SELECT Id, Name, Configuration_Name__c, Configuration_Action__c, Configuration_Type__c, Configuration_Details__c, 
                Field_Type__c, Business_Reason__c, Status__c, Time_to_Complete__c, Reason_For_Hold__c, Level_Of_Access__c, 
                Rule_Type__c, Records_Owned_By__c, Owned_By_Role_Name__c, Share_With__c, Shared_to_Role_Name__c,  
                Workflow_Evaluation_Criteria__c, Workflow_Action_Time_Trigger__c, Out_of_Scope_Reason__c, 
                RecordType.Name, RecordTypeId 
            FROM HRM_Configuration__c 
            WHERE HRM_Requirement__c = :reqId 
            order by RecordType.Name asc, Name asc
            limit :limits.getLimitQueryRows()
        ];
    }
       
    public void addReq(){
        try{
            upsert requirement;
            reqId = requirement.Id;
            system.debug('### INSERT reqId = '+reqId);
            init();
        }
        catch(Exception e){
            system.debug('### Exception e = '+e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }
    
    public void editReq(){
        init();
        isEditRequirement = true;
        editId = null;
    }
    
    public void cancelReq(){
        init();
        isEditRequirement = false;
    }
    
    public void saveConf(){
        isEditRequirement = false;
        if(editId != null && tabs.containsKey(selectedTab) && tab_content.containsKey(selectedTab) && tab_content.get(selectedTab).items.containsKey(editId)){
            if(!editId.startsWith('new') || (editId.startsWith('new') && getEmptyConfig(tabs.get(selectedTab), reqId) != tab_content.get(selectedTab).items.get('new'))){
                system.debug('### SAVE '+tab_content.get(selectedTab).items.get(editId));
                try{
                    upsert tab_content.get(selectedTab).items.get(editId);
                    if(editId.startsWith('new')){
                        tab_content.get(selectedTab).currentPage = null;
                        init();
                    }
                    else setPagination();
                    editId = null;
                }
                catch(Exception e){
                    system.debug('### Exception e = '+e);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                }
            }
        }
    }

    public void saveAndNewConf(){
        Boolean exceptionOnSave = false;
        saveConf();  
        for(ApexPages.Message m:ApexPages.getMessages()){
            if(m.getSeverity() == ApexPages.severity.ERROR){
                exceptionOnSave = true;
                break;
            }    
        }
        if(!exceptionOnSave){
            editId = 'new'+tabs.get(selectedTab);
            isEditRequirement = false;  
        }  
    }
    
    public void deleteConf(){
        isEditRequirement = false;
        if(editId != null && tabs.containsKey(selectedTab) && tab_content.containsKey(selectedTab) && tab_content.get(selectedTab).items.containsKey(editId)){
            try{
                delete tab_content.get(selectedTab).items.get(editId);
                tab_content.get(selectedTab).currentPage = null;
                init();
                editId = null;
            }
            catch(Exception e){
                system.debug('### Exception e = '+e);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            }
        }
    }
    
    public void cancelConf(){
        init();
        editId = null;
    }
        
    public void changeItemsOnPage(){
        isEditRequirement = false;
        if(tab_content.containsKey(selectedTab)){
            tab_content.get(selectedTab).currentPage = 1;
            init();
        }
        editId = null;
    }
        
    public static HRM_Configuration__c getEmptyConfig(Id recordTypeId, Id reqId){
        return new HRM_Configuration__c(
            HRM_Requirement__c = reqId,
            Configuration_Name__c = null,
            Configuration_Action__c = null,
            Configuration_Type__c = null,
            Field_Type__c = null,
            Status__c = null,
            Time_to_Complete__c = null,
            Business_Reason__c = null,
            Configuration_Details__c = null,
            Reason_For_Hold__c = null,
            Out_of_Scope_Reason__c = null,
            RecordTypeId = recordTypeId,
            Rule_Type__c = null,
            Level_Of_Access__c = null,
            Records_Owned_By__c = null, 
            Owned_By_Role_Name__c = null, 
            Share_With__c = null, 
            Shared_to_Role_Name__c = null,  
            Workflow_Evaluation_Criteria__c = null, 
            Workflow_Action_Time_Trigger__c = null
        );
    }
    
    public list<SelectOption> getItemsOnPageOptions(){
        return new list<SelectOption>{
            new SelectOption('10','10'),
            new SelectOption('25','25'),
            new SelectOption('50','50'),
            new SelectOption('100','100'),
            new SelectOption('200','200')
        };
    }
    
    public void first(){
        isEditRequirement = false;
        if(tab_content.containsKey(selectedTab)){
            tab_content.get(selectedTab).currentPage = 1;
            setPagination();
        }
        editId = null;
    }

    public void last(){
        isEditRequirement = false;
        if(tab_content.containsKey(selectedTab)){
            tab_content.get(selectedTab).currentPage = tab_content.get(selectedTab).totalPages;
            setPagination();
        }
        editId = null;
    }

    public void previous(){
        isEditRequirement = false;
        if(tab_content.containsKey(selectedTab)){
            tab_content.get(selectedTab).currentPage -= 1;
            setPagination();
        }
        editId = null;
    }

    public void next(){
        isEditRequirement = false;
        if(tab_content.containsKey(selectedTab)){
            tab_content.get(selectedTab).currentPage += 1;
            setPagination();
        }
        editId = null;
    }
}