/****************************************************************************************
Name            : AH_Finance_Req_to_SIN_LI_Trigger_Handler Class 
Author          : Stuart Emery
Created Date    : 9/12/2018
Last Mod Date   : 11/1/2018
Last Mod By     : Stuart Emery
NICC Reference  : NICC-030091
Description     : Class that handles all trigger code for the 
                : AH_Finance_Request_to_SIN_Line_Item__c Object
				:
******************************************************************************************/
public class AH_Finance_Req_to_SIN_LI_Trigger_Handler 
{
    
    //VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    
    public AH_Finance_Req_to_SIN_LI_Trigger_Handler()
    {
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }
    
    //================================================================================    
    public void OnBeforeInsert(List<AH_Finance_Request_to_SIN_Line_Item__c> newTrigger)
    {   
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_AH_Finance_ReqToSIN_LineItem__c)
        {
            
            System.debug(' *** ENTERING AH_Finance_Req_to_SIN_LI_Trigger_Handler.OnBeforeInsert()');   
            
            //CALL THE SetCurrency METHOD 
            SetCurrency(newTrigger);            
        }
    }
    
    //==============================================================================================================    
    public void OnAfterInsert(List<AH_Finance_Request_to_SIN_Line_Item__c> newTrigger)
    {   
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_AH_Finance_ReqToSIN_LineItem__c)
        {
            
            System.debug(' *** ENTERING AH_Finance_Req_to_SIN_LI_Trigger_Handler.OnAfterInsert()');
            Set<Id> setIds = new Set<Id>();
            
            List<AH_Finance_Request__c> lstFrToUpdate = new List<AH_Finance_Request__c>();
            for (AH_Finance_Request_to_SIN_Line_Item__c frToSinLI : newTrigger)
            {
                setIds.add(frToSinLI.Finance_Request__c);   
            }
            
            lstFrToUpdate = ([SELECT Id 
                              FROM AH_Finance_Request__c
                              WHERE Id IN: setIds]);
            
            //CALL THE FUNCTION TO ROLLUP THE CREDIT AMOUNT  
            AH_Finance_Request_Statics.rollupFinanceRequestNetCreditAmount(lstFrToUpdate);              
        }  
    }
    
    //===================================================================================================================================================   
    public void OnAfterUpdate(List<AH_Finance_Request_to_SIN_Line_Item__c> newTrigger, Map<Id, AH_Finance_Request_to_SIN_Line_Item__c> oldMapTrigger)
    {   
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_AH_Finance_ReqToSIN_LineItem__c)
        {
            
            System.debug(' *** ENTERING AH_Finance_Req_to_SIN_LI_Trigger_Handler.OnAfterUpdate()');
            Set<Id> setIds = new Set<Id>();
            List<AH_Finance_Request__c> lstFrToUpdate = new List<AH_Finance_Request__c>();
            
            for (AH_Finance_Request_to_SIN_Line_Item__c frToSinLI : newTrigger)
            {
                AH_Finance_Request_to_SIN_Line_Item__c oldFrToSinLI = oldMapTrigger.get(frToSinLI.Id);
                if ((frToSinLI.Requested_Credit_Amount__c != oldFrToSinLI.Requested_Credit_Amount__c) || (frToSinLI.Requested_Credit_Amount__c == null))
                {
                    setIds.add(frToSinLI.Finance_Request__c);
                }
            }         
            lstFrToUpdate = ([SELECT Id 
                              FROM AH_Finance_Request__c
                              WHERE Id IN: setIds]);
            
            //CALL THE FUNCTION TO ROLLUP THE CREDIT AMOUNT 
            AH_Finance_Request_Statics.rollupFinanceRequestNetCreditAmount(lstFrToUpdate);           
        }
    }
    
    //=============================================================================================================================================    
    public void OnAfterDelete(List<AH_Finance_Request_to_SIN_Line_Item__c> oldTrigger) 
    { 
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_AH_Finance_ReqToSIN_LineItem__c)
        {   
            
            System.debug(' *** ENTERING AH_Finance_Req_to_SIN_LI_Trigger_Handler.OnAfterDelete()');         
            Set<Id> setIds = new Set<Id>();
            
            List<AH_Finance_Request__c> lstFrToUpdate = new List<AH_Finance_Request__c>();
            for (AH_Finance_Request_to_SIN_Line_Item__c frToSinLI : oldTrigger)
            {
                setIds.add(frToSinLI.Finance_Request__c);   
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
    public void SetCurrency(List<AH_Finance_Request_to_SIN_Line_Item__c> newTrigger)    
    { 
        
        System.debug(' *** ENTERING AH_Finance_Req_to_SIN_LI_Trigger_Handler.SetCurrency()');
        
        Set<Id> setFrIds = new Set<Id>();
        
        for (AH_Finance_Request_to_SIN_Line_Item__c fli : newTrigger)
        {
            setFrIds.add(fli.Finance_Request__c);   
        }
        
        Map<Id,AH_Finance_Request__c> mapFr = new Map<Id,AH_Finance_Request__c>([SELECT Id, Name, CurrencyIsoCode 
                                                                                 FROM AH_Finance_Request__c
                                                                                 WHERE Id IN: setFrIds]);
        
        for (AH_Finance_Request_to_SIN_Line_Item__c fli2 : newTrigger)
        {
            fli2.CurrencyIsoCode = mapFr.get(fli2.Finance_Request__c).CurrencyIsoCode;  
            System.debug('FINANCE REQUEST CURRENCY ISO CODE: ' + mapFr.get(fli2.Finance_Request__c).CurrencyIsoCode);  
        }
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Class: AH_Finance_Req_to_SIN_LI_Trigger_Handler.SetCurrency');
        
    }
    
}