/************************************************************************************************
Name            : AH_ChangeRequest_TriggerHandler Class
Author          : BHuleshwar Deshpande
Created Date    : 09/10/2018
Last Mod Date   : 09/28/2018
Last Mod By     : Stuart Emery
NICC Reference  :
Description     : Class that handles all trigger code for the SFDC_CSP_Development_Request__c Object
                : 
                :
*************************************************************************************************/
public class AH_ChangeRequest_TriggerHandler 
{
    //VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    public AH_ChangeRequest_TriggerHandler()
    {
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }
    
    
    //BEFORE INSERT LOGIC HERE.
    public void OnBeforeInsert(List <SFDC_CSP_Development_Request__c> newTrigger)
    {
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_ChangeRequest__c)
        {
            
            System.debug(' *** ENTERING AH_ChangeRequest_TriggerHandler.OnBeforeInsert()');
            
            if (!newTrigger.isEmpty())
            {
                setPublicStatusDescription(newTrigger);
            }
        }
    }   
    //BEFORE UPDATE LOGIC HERE
    public void OnBeforeUpdate(List <SFDC_CSP_Development_Request__c> newTrigger)
    {
        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_ChangeRequest__c)
        {
            
            System.debug(' *** ENTERING AH_ChangeRequest_TriggerHandler.OnBeforeUpdate()');
            
            if (!newTrigger.isEmpty())
            {
                setPublicStatusDescription(newTrigger);
            }
        }
    }   
    // =============================================================================
    //  		TRIGGER FUNCTIONS
    // =============================================================================
    
    private void setPublicStatusDescription(List<SFDC_CSP_Development_Request__c> newTrigger)
    {
        Map<String,String> crCustomMetadataMap = new Map<String,String>();
        List<CR_Status_to_Description__mdt> crCustomMetadataLst = ([SELECT Status__c, Description__c FROM CR_Status_to_Description__mdt]);
        
        // LOOP TO PUT MAP DATA
        for (CR_Status_to_Description__mdt CRlst :crCustomMetadataLst)
        { 
            crCustomMetadataMap.put(CRlst.Status__c, CRlst.Description__c);   
        }
        
        // LOOP TO ITERATE ON CR LIST AND COMPARE MAP KEY VALUES.
        for (SFDC_CSP_Development_Request__c CR : newTrigger)
        {
            if (crCustomMetadataMap.containsKey(CR.Public_Status__c))
            {
                CR.Public_Status_Description__c = crCustomMetadataMap.get(CR.Public_Status__c); 
            }
        }
    }
    
}