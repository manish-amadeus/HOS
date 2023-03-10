/****************************************************************************************
Name            : AH_Manual_Credit_Lines_TriggerHandler Class 
Author          : Stuart Emery
Created Date    : 9/13/2018
Last Mod Date   : 11/1/2018 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-030091
Description     : Class that handles all trigger code for the 
                : AH_Manual_Credit_Lines__c Object
				:
******************************************************************************************/
public class AH_Manual_Credit_Lines_TriggerHandler 
{
    
    //VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    public AH_Manual_Credit_Lines_TriggerHandler()
    {
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }
    
    //================================================================================    
    public void OnBeforeInsert(List<AH_Manual_Credit_Lines__c> newTrigger)
    {   
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_AH_Manual_Credit_Lines__c)
        {
            
            System.debug(' *** ENTERING AH_Manual_Credit_Lines_TriggerHandler.OnBeforeInsert()');   
            
            //CALL THE SetCurrency METHOD 
            SetCurrency(newTrigger);            
        }
    }
    
    //==============================================================================================================   
    
    public void OnAfterInsert(List<AH_Manual_Credit_Lines__c> newTrigger)
    {   
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_AH_Manual_Credit_Lines__c)
        {
            
            System.debug(' *** ENTERING AH_Manual_Credit_Lines_TriggerHandler.OnAfterInsert()');
            Set<Id> setIds = new Set<Id>();
            
            List<AH_Finance_Request__c> lstFrToUpdate = new  List<AH_Finance_Request__c>();
            for (AH_Manual_Credit_Lines__c mCreditLines : newTrigger)
            {
                setIds.add(mCreditLines.Finance_Request__c);   
            }
            
            lstFrToUpdate = ([SELECT Id 
                              FROM AH_Finance_Request__c
                              WHERE Id IN: setIds]);
            
            //CALL THE FUNCTION TO ROLLUP THE CREDIT AMOUNT 
            AH_Finance_Request_Statics.rollupFinanceRequestNetCreditAmount(lstFrToUpdate);   
        }            
    }
    
    //===================================================================================================================================================   
    public void OnAfterUpdate(List<AH_Manual_Credit_Lines__c> newTrigger, Map<Id, AH_Manual_Credit_Lines__c> oldMapTrigger)
    {   
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_AH_Manual_Credit_Lines__c)
        {
            
            System.debug(' *** ENTERING AH_Manual_Credit_Lines_TriggerHandler.OnAfterUpdate()');
            Set<Id> setIds = new Set<Id>();
            List<AH_Finance_Request__c> lstFrToUpdate = new  List<AH_Finance_Request__c>();
            
            for (AH_Manual_Credit_Lines__c mCreditLines : newTrigger)
            {
                AH_Manual_Credit_Lines__c oldmCreditLines = oldMapTrigger.get(mCreditLines.Id);
                if ((mCreditLines.Requested_Credit_Amount__c != oldmCreditLines.Requested_Credit_Amount__c) || (mCreditLines.Requested_Credit_Amount__c == null))
                {
                    setIds.add(mCreditLines.Finance_Request__c);
                }
            } 
            
            lstFrToUpdate = ([SELECT Id 
                              FROM AH_Finance_Request__c
                              WHERE Id IN : setIds]);            
            
            //CALL THE FUNCTION TO ROLLUP THE CREDIT AMOUNT 
            AH_Finance_Request_Statics.rollupFinanceRequestNetCreditAmount(lstFrToUpdate);             
        } 
    }
    
    //=============================================================================================================================================    
    public void OnAfterDelete(List<AH_Manual_Credit_Lines__c> oldTrigger) 
    { 
        
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_AH_Manual_Credit_Lines__c)
        {
            
            System.debug(' *** ENTERING AH_Manual_Credit_Lines_TriggerHandler.OnAfterDelete()');         
            Set<Id> setIds = new Set<Id>();
            
            List<AH_Finance_Request__c> lstFrToUpdate = new List<AH_Finance_Request__c>();
            for (AH_Manual_Credit_Lines__c mCreditLines : oldTrigger)
            {
                setIds.add(mCreditLines.Finance_Request__c);   
            }
            
            lstFrToUpdate = ([SELECT Id 
                              FROM AH_Finance_Request__c
                              WHERE Id IN : setIds]);        
            
            //CALL THE FUNCTION TO ROLLUP THE CREDIT AMOUNT 
            AH_Finance_Request_Statics.rollupFinanceRequestNetCreditAmount(lstFrToUpdate);   
        }
    }
    
    //================================================================================ 
    // UPDATE THE CURRENCY FIELD
    //================================================================================    
    public void SetCurrency(List<AH_Manual_Credit_Lines__c> newTrigger)    
    { 
        
        System.debug(' *** ENTERING AH_Manual_Credit_Lines_TriggerHandler.SetCurrency()');
        
        Set<Id> setFrIds = new Set<Id>();
        
        for (AH_Manual_Credit_Lines__c mli : newTrigger)
        {
            setFrIds.add(mli.Finance_Request__c);   
        }
        
        Map<Id,AH_Finance_Request__c> mapFr = new Map<Id,AH_Finance_Request__c>([SELECT Id, Name, CurrencyIsoCode 
                                                                                 FROM AH_Finance_Request__c
                                                                                 WHERE Id IN: setFrIds]);
        
        for (AH_Manual_Credit_Lines__c mli2 : newTrigger)
        {
            mli2.CurrencyIsoCode = mapFr.get(mli2.Finance_Request__c).CurrencyIsoCode;  
            System.debug('FINANCE REQUEST CURRENCY ISO CODE: ' + mapFr.get(mli2.Finance_Request__c).CurrencyIsoCode);  
        }
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Class: AH_Manual_Credit_Lines_TriggerHandler.SetCurrency');
        
    }
    
}