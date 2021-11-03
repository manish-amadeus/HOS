/***********************************************************************************************
Name            : AH_Account_Product_TriggerHandler
Author          : Ria Chawla
Created Date    : 04/16/2018
Last Mod Date   : 11/22/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Class that handles all trigger code for the AH_Account_Product__c(RELATED OPPORTUNITY LINE ITEM) Object
				: Updated per NICC-039872
				:
************************************************************************************************/
public class AH_Account_Product_TriggerHandler 
{
    
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    public AH_Account_Product_TriggerHandler()
    {
        
        system.debug(' *** ENTERING AH_Account_Product_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();  
        
        system.debug(' *** EXITING AH_Account_Product_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }     
    
    // ======================================================================================================================== 
    //  PUBLIC ENTRY METHODS 
    // ========================================================================================================================  
    public void onAfterInsert(List<AH_Account_Product__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_Account_Product_TriggerHandler.onAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.Bypass_AH_Account_Product__c)
        {        
            calculateRollUpSummary(newTrigger);
        }
        
        system.debug(' *** EXITING AH_Account_Product_TriggerHandler.onAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());        
        
    }
    
    public void onAfterUpdate(List<AH_Account_Product__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_Account_Product_TriggerHandler.onAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.Bypass_AH_Account_Product__c)
        {        
            calculateRollUpSummary(newTrigger);
        }
        
        system.debug(' *** EXITING AH_Account_Product_TriggerHandler.onAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());        
        
    }
    
    public void onAfterDelete(List<AH_Account_Product__c> oldTrigger)
    {
        
        system.debug(' *** ENTERING AH_Account_Product_TriggerHandler.onAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.Bypass_AH_Account_Product__c)
        {        
            calculateRollUpSummary(oldTrigger);
        }
        
        system.debug(' *** EXITING AH_Account_Product_TriggerHandler.onAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());        
        
    }
    
    
    // ======================================================================================================================== 
    //  PRIVATE HANDLER METHODS/FUNCTIONS 
    // ======================================================================================================================== 
    public void calculateRollUpSummary(List<AH_Account_Product__c> newTrigger)
    {
        
        // SET TO HOLD DEPLOYMENT INSTANCE ID
        Set<Id> setDIIds = new Set<Id>();
        
        // ITERATE OVER NEW TRIGGER TO PROCESS QUANTITIES
        for (AH_Account_Product__c accPrd : newTrigger)
        {
            if (accPrd.Deployment_Instance__c != null)
            {
                setDIIds.add(accPrd.Deployment_Instance__c);
            }   
        }
        
        // IF SET IS NOT EMPTY, CALL METHOD TO UPDATE QUANTITY ON DEPLOYMENT INSTANCE
        if (!setDIIds.isEmpty())
        {
            if (system.isBatch() || system.isFuture())
            {
                NI_FUNCTIONS.updateDIRollupSummaryFields1(setDIIds);
            }
            else
            {
                NI_FUNCTIONS.updateDIRollupSummaryFields(setDIIds);
            }
        }  
        
    }
    
}