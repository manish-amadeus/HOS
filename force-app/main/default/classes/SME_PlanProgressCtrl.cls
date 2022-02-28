/**
 * Author	:	Nagendra
 * Desc		:	Controller class for LEX component SME_PlanProgress.
 * 			:	
 * */
public with sharing class SME_PlanProgressCtrl{

    //Method to generate SOQL query from given field set
    public static String generateSOQL(String ObjectName,String fieldSetName){
        
        map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Set<String> fields = new Set<String>{'Id'};
        String query = 'Select Id';
        //Describe the provided sObject
        Schema.DescribeSObjectResult res= globalDescribe.get(ObjectName).getDescribe();
        //Get the field set map
         Map<String,Schema.FieldSet> fieldSetMap =res.fieldsets.getMap();
        try{
         Schema.FieldSet fs = fieldSetMap.get(fieldSetName);
         for(Schema.FieldSetMember fsm :fs.getFields()){
             if(!fields.contains(fsm.getFieldPath())){
                 if(fsm.getFieldPath() == 'OwnerId'){
                    query = query+','+'Owner.Name'; 
                 }
                 fields.add(fsm.getFieldPath());
                 query = query+','+fsm.getFieldPath();
             } 
         }
         }catch(Exception e){
         	SME_GlobalExceptionHandlerCtrl.processException('SME_PlanProgressCtrl', 'generateSOQL', e);
            return null;
        }
        return query +' From '+ ObjectName;
    }
    //Method to return list of opportunities 
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunityList(String accountPlanId){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        try{
        String query = SME_PlanProgressCtrl.generateSOQL('Opportunity','OpportunityList');
        lstOpportunity = Database.query(query + ' where Account_Plan__c =\''+accountPlanId+'\'');
        }catch(Exception e){
         	SME_GlobalExceptionHandlerCtrl.processException('SME_PlanProgressCtrl', 'getOpportunityList', e);
            return null;
        }
        return lstOpportunity;
    }
  }