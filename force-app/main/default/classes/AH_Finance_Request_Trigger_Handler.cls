/****************************************************************************************
Name            : AH_Finance_Request_Trigger_Handler Class 
Author          : Stuart Emery
Created Date    : 9/17/2018
Last Mod Date   : 9/18/2018 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-030091
Description     : Class that handles all trigger code for the 
                : AH_Finance_Request__c Object
				:
******************************************************************************************/
public class AH_Finance_Request_Trigger_Handler 
{
    
    //VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    public AH_Finance_Request_Trigger_Handler()
    {
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }
    
    //================================================================================    
    public void OnBeforeInsert(List<AH_Finance_Request__c> newTrigger)
    {   
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_AH_Finance_Request__c)
        {
            
            System.debug(' *** ENTERING AH_Finance_Request_Trigger_Handler.OnAfterInsert()');
            
            //CALL THE METHOD TO POPULATE THE NET CREDIT AMOUNT
            Update_NetCreditAmountFromTaxAmount(newTrigger);            
        }
    }   
    
    //===================================================================================================================================================   
    public void OnAfterUpdate(List<AH_Finance_Request__c> newTrigger, Map<Id, AH_Finance_Request__c> oldMapTrigger)
    {   
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_AH_Finance_Request__c)
        {
            System.debug(' *** ENTERING AH_Finance_Request_Trigger_Handler.OnAfterUpdate()');
            Set<Id> setIds = new Set<Id>();
            List<AH_Finance_Request__c> lstFrToUpdate = new  List<AH_Finance_Request__c>();
            
            for(AH_Finance_Request__c fr : newTrigger)
            {
                AH_Finance_Request__c oldFr = oldMapTrigger.get(fr.Id);
                if((fr.Tax_Amount__c != oldFr.Tax_Amount__c) && (fr.Tax_Amount__c != null))
                {
                    lstFrToUpdate.add(fr);
                }
            }         
            
            
            //CALL THE FUNCTION TO ROLLUP THE CREDIT AMOUNT    
            AH_Finance_Request_Statics.rollupFinanceRequestNetCreditAmount(lstFrToUpdate); 
        }
        
    }
 //=================================================================================================================   
    public void Update_NetCreditAmountFromTaxAmount(List<AH_Finance_Request__c> newTrigger)
    {
        system.debug('*** ENTERING AH_Finance_Request_Trigger_Handler.Update_NetAmountFromTaxAmount()'); 
        
        
        
        //UPDATE THE NET CREDIT AMOUNT FIELD
        for (AH_Finance_Request__c fr : newTrigger)
        {
            if(fr.Tax_Amount__c != null)
            {
                fr.Net_Credit_Amount__c = fr.Tax_Amount__c;  
            }
            
        }
        
    }
    
}