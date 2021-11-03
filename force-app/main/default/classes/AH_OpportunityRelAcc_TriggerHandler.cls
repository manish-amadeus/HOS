/****************************************************************************************
Name            : AH_OpportunityRelAcc_TriggerHandler
Author          : Ria Chawla
Created Date    : 04/23/2018
Last Mod Date   : 04/23/2018
Last Mod By     : Ria Chawla
NICC Reference  : 
Description     : Controller for AH_NewOpportunityRelAccount VF Page.
				:
******************************************************************************************/
public class AH_OpportunityRelAcc_TriggerHandler {
    
    //AFTER DELETE METHOD
    public void onAfterDelete(List<AH_Opportunity_Related_Account__c> oldTrigger){
        updateQuantitiesOfProduct(oldTrigger);
        
    }
    
    /************FUNCTIONS****************/
    private void updateQuantitiesOfProduct(List<AH_Opportunity_Related_Account__c> oldTrigger){
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        List<AH_Account_Product__c> accProductList = new List<AH_Account_Product__c>();
        
        //ITERATE OVER AH_Opportunity_Related_Account__c RECORDS TO GET OPPORTUNITY AND ACCOUNT ID
        for(AH_Opportunity_Related_Account__c oppRelAcc : oldTrigger){
            if(oppRelAcc.Opportunity__c != null){
                oppIdSet.add(oppRelAcc.Opportunity__c);
            }
            if(oppRelAcc.Account__c != null){
                accIdSet.add(oppRelAcc.Account__c);
            }
        }
        
        //GET THE LIST OF ALL RELATED OPPORTUNITY LINE ITEM RECORDS TO DELETE THEM
        if((!oppIdSet.isEmpty()) && (!accIdSet.isEmpty())){
            accProductList = [SELECT Id  FROM AH_Account_Product__c
                              WHERE Account__c IN :accIdSet
                              AND Opportunity__c IN :oppIdSet];
        }
        
        //IF LIST IS NOT EMPTY, DELETE IT TO REMOVE ANY ASSIGNED QUANTITY TO THEM
        if(!accProductList.isEmpty()){
            delete accProductList;
        }
    }

}