/**
 * Company     : PwC Sales & Marketing Excellence Solution.
 * Description : 
 * 
 * ****************************************************************************************
 * History     : 
 * [03.APR.2019] Peeyush Tripathi - Created this class.
 * 27 APR 2020   Nagendra Singh         As per discussion with Vijay, decided to comment OSIS CPQ flow.
 */
public class SME_OpportunityTriggerHandlerCtrl extends TriggerHandler_Helper{
    
    public SME_OpportunityServiceCtrl opportunityRollUpService;
    
    // Id expressOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Express Opportunity').getRecordTypeId();
    // Id standardOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId();
    
    SME_Disable_Flows_Process_Triggers__c triggerRunSettings = SME_Disable_Flows_Process_Triggers__c.getInstance(userInfo.getUserId());
    
    // Description: Handle after update trigger operation
    public override void afterUpdate() {
        List<Opportunity> listOpp = (List<Opportunity>) Trigger.new;
        Opportunity opp = listOpp[0];
        if(!triggerRunSettings.SME_Skip_All_objects__c && !triggerRunSettings.SME_Skip_Opportunity__c ){
            SME_OpportunityServiceCtrl.rollUpSummary(trigger.newMap.keyset());
        }
        // if((opp.recordTypeId != expressOppRecordTypeId && opp.recordTypeId != standardOppRecordTypeId) ) {
        //     opportunityRollUpService = new SME_OpportunityServiceCtrl();
        //     SME_OpportunityServiceCtrl.addAddress((List<Opportunity>) Trigger.new);
        // }
        else {
            if(!triggerRunSettings.SME_Skip_All_objects__c && !triggerRunSettings.SME_Skip_Opportunity__c ){
                /*27 APR 2020 -  Nagendra Singh         As per discussion with Vijay, decided to comment OSIS CPQ flow.*/
                
            	//SME_OpportunityTriggerHelperCtrl.updateOrder((List<Opportunity>) Trigger.new,(Map<Id,Opportunity>) trigger.oldmap); 
                // SME_OpportunityTriggerHelperCtrl.checkownerChange((List<Opportunity>) Trigger.new,(Map<Id,Opportunity>) trigger.oldmap);
                // if(Test.isRunningTest()) {
                //     SME_OpportunityTriggerHelperCtrl.checkStage((List<Opportunity>) Trigger.new,(Map<Id,Opportunity>) trigger.oldmap);
                // }
                // if(SME_OpportunityTriggerHelperCtrl.runTrigger){
                //     /*27 APR 2020 -  Nagendra Singh         As per discussion with Vijay, decided to comment OSIS CPQ flow.*/
                //     //SME_OpportunityTriggerHelperCtrl.createRenewalOpportunity((List<Opportunity>) Trigger.new,(Map<Id,Opportunity>) trigger.oldmap);
                // 	SME_OpportunityTriggerHelperCtrl.runTrigger = false;  
                // }
                /*27 APR 2020 -  Nagendra Singh         As per discussion with Vijay, decided to comment OSIS CPQ flow.*/
                //SME_OpportunityTriggerHelperCtrl.createRenewalQuote((List<Opportunity>) Trigger.new,(Map<Id,Opportunity>) trigger.oldmap);
                opportunityRollUpService = new SME_OpportunityServiceCtrl();
                // SME_OpportunityServiceCtrl.addAddress((List<Opportunity>) Trigger.new);
            }
        }
    }
    // Description: Handle after insert trigger operation
    public override void afterInsert() {
        List<Opportunity> listOpp = (List<Opportunity>) Trigger.new;
        Opportunity opp = listOpp[0];
         if(!triggerRunSettings.SME_Skip_All_objects__c && !triggerRunSettings.SME_Skip_Opportunity__c ){
            SME_OpportunityServiceCtrl.rollUpSummary(trigger.newMap.keyset());
        }
        // if((opp.recordTypeId != expressOppRecordTypeId && opp.recordTypeId != standardOppRecordTypeId) ) {
        // 	opportunityRollUpService = new SME_OpportunityServiceCtrl();
        	
        //     SME_OpportunityServiceCtrl.addAddress((List<Opportunity>) Trigger.new);
        // }
        // else {
        //     if(!triggerRunSettings.SME_Skip_All_objects__c && !triggerRunSettings.SME_Skip_Opportunity__c ){
        //     	SME_OpportunityTriggerHelperCtrl.createRenewalQuote((List<Opportunity>) Trigger.new,(Map<Id,Opportunity>) trigger.oldmap);
        //         opportunityRollUpService = new SME_OpportunityServiceCtrl();
        		
        //         SME_OpportunityServiceCtrl.addAddress((List<Opportunity>) Trigger.new);
        //     }
        // }
    }
    
    // Description: Handle after delete trigger operation
    public override void afterDelete() {
         if(!triggerRunSettings.SME_Skip_All_objects__c && !triggerRunSettings.SME_Skip_Opportunity__c ){
            SME_OpportunityServiceCtrl.rollUpSummary(trigger.oldMap.keyset());
        }
       
    }
    
    public override void beforeUpdate() {
    	List<Opportunity> listOpp = (List<Opportunity>) Trigger.new;
        Opportunity opp = listOpp[0];
        
        // if((opp.recordTypeId != expressOppRecordTypeId && opp.recordTypeId != standardOppRecordTypeId) ) {
        // }
        // else {
        //     if(!triggerRunSettings.SME_Skip_All_objects__c && !triggerRunSettings.SME_Skip_Opportunity__c ){
        //     	SME_OpportunityTriggerHelperCtrl.CheckTypeAndApprovalStatus((List<Opportunity>) Trigger.new,(Map<Id,Opportunity>) trigger.oldmap);
        //     }
        // }
        // if(!triggerRunSettings.SME_Skip_All_objects__c && !triggerRunSettings.SME_Skip_Opportunity__c ){
        // 	SME_OpportunityTriggerHelperCtrl.validateBasicOppStageChange((Map<Id,Opportunity>)Trigger.newMap, (Map<Id,Opportunity>) Trigger.oldMap);
        // }
    }  
}