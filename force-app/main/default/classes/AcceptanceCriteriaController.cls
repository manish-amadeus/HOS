/**********************************************************************************************************
Name            : AcceptanceCriteriaController Class
Author          : Nidhi Singh
Created Date    : 09/30/2016
Last Mod Date   : 05/18/2017
Last Mod By     : Ria Chawla
NICC Reference  :
Description     : Class used Associate Acceptance criteria of any object for Project Backlog
***********************************************************************************************************/

public class AcceptanceCriteriaController {

    public id projBacklogId=system.currentpagereference().getparameters().get('NI_Project_Backlog__c');
    public String selectedObject {get;set;}
    public NI_Project_Backlog__c projectInfo {get;set;}
    public Set<ID> insertedRecords{get;set;}
    public Set<ID> recordsToInsert{get;set;}
    public Set<ID> recordsToDelete{get;set;}    
    public List<WrapperCriteria> criteriaWrapper{get;set;}
    public String validationWarning {get; set;}
    
    public String displayOutputLabel {get; set;}
    public Boolean displayOption {get; set;}
        
    NI_Project_Backlog__c backlogRecords;
    WrapperCriteria aw;
    public boolean displayAccCriteria{get{
        if(displayAccCriteria ==null)
            return false;
        else
            return displayAccCriteria;
    }set;}
    
    public AcceptanceCriteriaController(ApexPages.StandardController controller) {
        //displayAccCriteria = false;
        projectInfo = [select Id, name from NI_Project_Backlog__c where id = :projBacklogId];
        backlogRecords = [SELECT Affected_Objects__c FROM NI_Project_Backlog__c WHERE Id = : projBacklogId];
    }
    
    public void onchangeView() {
        displayAccCriteria = true;
       
    }
    public void displayAffectedObject() {
         if(backlogRecords.Affected_Objects__c != null) {
             displayOutputLabel = 'Select Affected object :';
             displayOption = true;
         } else {
             displayOutputLabel = 'No Affected Object is selected for this Project ';
             displayOption = false;
         }
        
     }
    
    public List<selectOption> getAffectedObject() {
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('', '- None -'));
        if(backlogRecords.Affected_Objects__c != null) {           
            List<String> affectedRecords = (backlogRecords.Affected_Objects__c).split(';');
            for (String affectedObject: affectedRecords)
            {               
              options.add(new SelectOption(affectedObject, affectedObject));
            }
            
        } 
        return options;

     }
    public List<WrapperCriteria> getAcceptanceCriteria() {
        insertedRecords = new Set<ID>();
        List<NI_Global_Acceptance_Criterion__c> criteriaList = [Select Name, Id, Then__c, Given__c, When__c,
                                                                (select NI_Global_Acceptance_Criterion__c, 
                                                                 NI_Project_Backlog__c from Project_Acceptance_Criteria__r)  from NI_Global_Acceptance_Criterion__c where Applicable_Object__c = :selectedObject];
        system.debug('criteriaList'+criteriaList);
        criteriaWrapper = new List<WrapperCriteria>();
                
        for(NI_Global_Acceptance_Criterion__c a : criteriaList) {
           
            aw = new WrapperCriteria();
            aw.optionLabel = a.Name;
            aw.acceptanceId = a.Id;
            aw.optionWhen = a.When__c;
            aw.optionThen = a.Then__c;
            aw.optionGiven = a.Given__c;
            
             for(NI_Project_Acceptance_Criterion__c accepCriteria: a.Project_Acceptance_Criteria__r) {
                if((a.id == accepCriteria.NI_Global_Acceptance_Criterion__c) && 
                  (projectInfo.Id == accepCriteria.NI_Project_Backlog__c)) {
                    insertedRecords.add(a.Id);
                    aw.optionSelected = true;
                }
                system.debug(accepCriteria.NI_Global_Acceptance_Criterion__c);
            }
            criteriaWrapper.add(aw);
            system.debug('criteriaWrapper'+criteriaWrapper);
        }
        if(criteriaWrapper.size()<=0) {
            displayAccCriteria = false;
        }
            
        return criteriaWrapper ;
    }    
    
    public with sharing class WrapperCriteria {
        public String   optionLabel    { get;set; }
        public String   optionWhen     { get;set; }
        public String   optionThen     { get;set; }
        public String   optionGiven    { get;set; }
        public Id   acceptanceId     { get;set; }
        public Boolean  optionSelected  { get;set; }

        public WrapperCriteria() {
            optionSelected = false;
        }
    }
    
     public PageReference actionCancel(){
        string url;
        url= '/'+projBacklogId;
        PageReference pageRef = new PageReference(url);        
        pageRef.setRedirect(true);
        return pageRef;   
        
    }
    
    public PageReference saveRecord() {
         system.debug('recordsToInsert->' + recordsToInsert);
        if(recordsToInsert.size() > 0){
            List<NI_Project_Acceptance_Criterion__c> listCriteriaToInsert = new List<NI_Project_Acceptance_Criterion__c>();
           
            for(NI_Global_Acceptance_Criterion__c insertAcceptance : [SELECT Id,Name,Applicable_Object__c,Given__c, When__c, Then__c FROM NI_Global_Acceptance_Criterion__c Where ID IN : recordsToInsert]) {
                NI_Project_Acceptance_Criterion__c projAccp = new NI_Project_Acceptance_Criterion__c();
                projAccp.Name__c = insertAcceptance.Name;
                projAccp.NI_Project_Backlog__c = projBacklogId;
                projAccp.NI_Global_Acceptance_Criterion__c = insertAcceptance.Id;
                projAccp.Applicable_Object__c = insertAcceptance.Applicable_Object__c; 
                projAccp.Given__c = insertAcceptance.Given__c;
                projAccp.When__c = insertAcceptance.When__c;
                projAccp.Then__c = insertAcceptance.Then__c;
                listCriteriaToInsert.add(projAccp);
            }
            system.debug('listCriteriaToInsert-->' + listCriteriaToInsert);
            insert listCriteriaToInsert;
        }
        system.debug('recordsToDelete-->' + recordsToDelete);
        if(recordsToDelete.size() > 0){
            List<NI_Project_Acceptance_Criterion__c> listCriteriaToDelete = new List<NI_Project_Acceptance_Criterion__c>();
            for(NI_Project_Acceptance_Criterion__c deleteAcceptance : [select id from NI_Project_Acceptance_Criterion__c where NI_Global_Acceptance_Criterion__c IN : recordsToDelete]) {
                listCriteriaToDelete.add(deleteAcceptance);
            }
            system.debug('listCriteriaToDelete-->' + listCriteriaToDelete);
            delete listCriteriaToDelete;
        }
       
        string url;
        url= '/apex/AssociateAcceptanceCriteria?NI_Project_Backlog__c='+projBacklogId;
        PageReference pageRef = new PageReference(url);   
        system.debug('url'+url);
        pageRef.setRedirect(true);
        return pageRef;
       // return null;
    }
    
    public PageReference actionSave(){
        recordsToInsert = new set<ID>();
        recordsToDelete = new set<ID>();
        
        for(WrapperCriteria checkedCriteria : criteriaWrapper) {
            system.debug('checkedCriteria-->' + checkedCriteria);
            if(checkedCriteria.optionSelected){
            	recordsToInsert.add(checkedCriteria.acceptanceId);
                system.debug('recordsToInsert-->'+recordsToInsert);
           }
        }
         system.debug('recordsToInsert-->'+recordsToInsert);
        for(Id existRecord : insertedRecords) {
            if(recordsToInsert.contains(existRecord)) {
                recordsToInsert.remove(existRecord);
            } else {
                recordsToDelete.add(existRecord);
            }
        }
          system.debug('recordsToInsert->'+recordsToInsert);
         if(recordsToDelete.size() > 0){
             validationWarning = 'Unchecked Records will be deleted, click Ok if you\'re sure you want to proceed.';
             return null;
         } else {
             validationWarning = '';
             system.debug('recordsToInsert'+recordsToInsert);
             
             return saveRecord();
         }
      
     }
    
    public void clearvalidationWarning(){
       validationWarning = '';
    }    
   
}