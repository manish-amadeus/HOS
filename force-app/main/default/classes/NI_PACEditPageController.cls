/************************************************************************************************
Name            : NI_PACEditPageController  Class
Author          : Supriya Galinde
Created Date    : 4/3/2017
Last Mod Date   : 4/6/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : Class that handles code for the Edit button on Project Acceptance Criterion Visualforce page.
:
*************************************************************************************************/
public class NI_PACEditPageController {
    Id ProjectId;    
    public NI_Project_Acceptance_Criterion__c pacObject{get; set;}
    public NI_Global_Acceptance_Criterion__c objGlobal{get; set;}
    public NI_Global_Acceptance_Criterion__c objGlobalOnSave{get; set;}
    public Boolean executeJS{get; set;}
    //List<NI_Global_Acceptance_Criterion__c> gacList = new List<NI_Global_Acceptance_Criterion__c>();        
    private ApexPages.StandardController controller;
    
    /*public NI_PACEditPageController(){
        
    }*/
    
    //Below constructor will get the record id of a controller. 
    public NI_PACEditPageController(ApexPages.StandardController controller){
        this.controller = controller; 
        projectId = controller.getRecord().id;
        
        pacObject = new NI_Project_Acceptance_Criterion__c();
        pacObject = [SELECT Id, Name, Name__c, NI_Global_Acceptance_Criterion__c, NI_Project_Backlog__c, Given__c, 
                     When__c, Then__c, Applicable_Object__c, Production_Org_Status__c, 
                     UAT_Org_Status__c, Developer_Org_Status__c,QA_Org_Status__c, Comments__c 
                     FROM NI_Project_Acceptance_Criterion__c WHERE Id =: projectId]; 
        
        objGlobal = new NI_Global_Acceptance_Criterion__c();        
        
        if(pacObject.NI_Global_Acceptance_Criterion__c != null){
            system.debug('in if1');
            objGlobal = [SELECT Id,Name, Given__c, When__c, Then__c FROM NI_Global_Acceptance_Criterion__c 
                         WHERE Id =: pacObject.NI_Global_Acceptance_Criterion__c];
            system.debug('objGlobal'+objGlobal);            
        }
    }
    
    //For cancel button. When user edits the name field and click on cancel button without saving the record the user gets a popup to save the record 
    //with the matching name of GAC.
    public PageReference DoCancel(){
        executeJS = true;
        try{
            system.debug('Pac Name======>'+pacObject.Name__c);
            system.debug('Pac Name======>'+pacObject.NI_Global_Acceptance_Criterion__c);
            if(pacObject.Name__c == null || pacObject.Name__c != objGlobal.Name){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Save the record with matching Name of Global Acceptance Criterion.');
                ApexPages.addMessage(myMsg);
                return null;             
            }
            else{
                PageReference orderPage = new PageReference('/'+pacObject.id);
                orderPage.setRedirect(true);
                return orderPage;
            }   
        }
        Catch(Exception e){
            system.debug('Exception due to ----->'+e.getMessage()+e.getLineNumber());
            return null;
        }       
    } 
    
    //for save button click. It will check if name is same and then will save the record and will 
    //update the remaining fields in PAC else it will display an error message.
    public Pagereference DoSave(){
        executeJS = false;
        system.debug('pacObject.Name__c'+pacObject.Name__c);
        system.debug('pacObject.NI_Global_Acceptance_Criterion__c'+pacObject.NI_Global_Acceptance_Criterion__c);
        if(pacObject.NI_Global_Acceptance_Criterion__c != null){
            objGlobalOnSave = [SELECT Id, Name FROM NI_Global_Acceptance_Criterion__c 
                         WHERE Id =: pacObject.NI_Global_Acceptance_Criterion__c];
        }
        try{
            if(objGlobalOnSave != null && pacObject.Name__c == objGlobalOnSave.Name){
                update pacObject;
                PageReference orderPage = new PageReference('/'+pacObject.id);
                orderPage.setRedirect(true);
                return orderPage;          
            }  
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Save the record with matching Name of GAC.');
                ApexPages.addMessage(myMsg);
                return null;
            }  
        }
        Catch(Exception e){
            system.debug('Exception due to ----->'+e.getMessage()+e.getLineNumber());
            return null;
        }       
    }
    
    //Save & New will save a record and redirect to a new page. While saving it will check if the name of PAC and GAC is same if not then
    //receive a error message which will say to save a record with matching name. 
    public PageReference DoSaveNew() {
        executeJS = false;
        Id id = controller.getId();
        Boolean saveAndNew = false;
         if(pacObject.NI_Global_Acceptance_Criterion__c != null){
            objGlobalOnSave = [SELECT Id, Name FROM NI_Global_Acceptance_Criterion__c 
                         WHERE Id =: pacObject.NI_Global_Acceptance_Criterion__c];
        }
        system.debug('id'+id);
        //if name is equal then update PAC.
        if(objGlobalOnSave != null && pacObject.Name__c == objGlobalOnSave.Name)
        {
            system.debug('match names');
            update pacObject;
            saveAndNew = true;          
        }
        //name dosesn't match then show error message.
        else
        {
            system.debug('in else err');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Save the record with matching Name of GAC.');
            ApexPages.addMessage(myMsg);
            return null;
        } 
        //redirect to new page.
        if(saveAndNew){
            Apexpages.currentPage().setRedirect(true);
            return new PageReference('/'+controller.getRecord().getSObjectType().getDescribe().getKeyPrefix()+'/e?retURL='+pacObject.Id);
        }
        else
            return null;
    }
}