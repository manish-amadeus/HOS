/****************************************************************************************
Name            : AH_RealizedProjBnfit_TriggerHandler Class 
Author          : Sean Harris
Created Date    : 12/06/2021
Last Mod Date   : 12/06/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Trigger handler class for AH_RealizedProjectBenefit__c object
                : 
                :
                :
******************************************************************************************/
public class AH_RealizedProjBnfit_TriggerHandler 
{
    
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    
    public AH_RealizedProjBnfit_TriggerHandler()
    {
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();   
    }
    
    public void OnBeforeInsert(List<AH_Realized_Project_Benefits__c> newTrigger)
    { 
        if (!bpSwitch.RealizedProjectBenefits_ON__c)
        {
            Update_HourlyCost(newTrigger);
        }
    }
    
    public void OnBeforeUpdate(List<AH_Realized_Project_Benefits__c> newTrigger, Map<Id, AH_Realized_Project_Benefits__c> oldMapTrigger)
    { 
        if (!bpSwitch.RealizedProjectBenefits_ON__c)
        {
            Update_HourlyCost(newTrigger);
        }
    }
    
    
    // =================================================================================================================  
    //  FUNCTIONS ======================================================================================================   
    // =================================================================================================================
    private void Update_HourlyCost(List<AH_Realized_Project_Benefits__c> newTrigger)
    {

        Map<String, AH_Workstream__c> mapWS = new Map<String, AH_Workstream__c>();
        
        for (AH_Workstream__c ahws : [SELECT Id, Name, Hourly_Cost__c FROM AH_Workstream__c WHERE Active__c = true])
        {
            mapWS.put(ahws.Name, ahws);
        } 
    
        // LOOP THROUGH THE INSERTED PROJECT BACKLOG WORKSTREAM RECORDS AND POPULATE THE HOURLY COST FIELD
        for (AH_Realized_Project_Benefits__c rpb : newTrigger)
        {
            // SEE IF THE PROJECT BACKLOG WORKSTREAM RECORD HAS A MATCHING AH WORKSTREAM RECORD.
            if (mapWS.containsKey(rpb.Workstream_Name__c))
            {
                // IF A MATCHING RECORD IS FOUND, UPDATE THE HOURLY COST TO MATCH THE AH WORKSTREAM RECORD
                if (mapWS.get(rpb.Workstream_Name__c).Hourly_Cost__c != null)
                {
                    rpb.Hourly_Cost__c = mapWS.get(rpb.Workstream_Name__c).Hourly_Cost__c;
                }
            }
        }
        
    }
    
}