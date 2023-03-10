/****************************************************************************************
Name            : AH_ProjBacklogWorkstream_TriggerHandler Class 
Author          : Stuart Emery
Created Date    : 11/22/2020
Last Mod Date   : 12/06/2021 
Last Mod By     : Sean Harris
NICC Reference  : NICC-047197
Description     : Class that handles all trigger code for the 
                : AH_Project_Backlog_Workstreams__c Object
				:
******************************************************************************************/
public class AH_ProjBacklogWorkstream_TriggerHandler 
{
    
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    
    public AH_ProjBacklogWorkstream_TriggerHandler()
    {
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();   
    }
    
    public void OnBeforeInsert(List<AH_Project_Backlog_Workstreams__c> newTrigger)
    {   
        if (!bpSwitch.Bypass_AH_Project_Backlog_Workstreams_c__c)
        {
            // CALL THE METHOD TO POPULATE THE HOURLY COST
            Update_HourlyCost(newTrigger);            
        }
    }
    
    public void OnBeforeUpdate(List<AH_Project_Backlog_Workstreams__c> newTrigger, Map<Id, AH_Project_Backlog_Workstreams__c> oldMapTrigger)
    {   
        if (!bpSwitch.Bypass_AH_Project_Backlog_Workstreams_c__c)
        {
            
            List<AH_Project_Backlog_Workstreams__c> lstWsToUpdate = new List<AH_Project_Backlog_Workstreams__c>();
            
            for (AH_Project_Backlog_Workstreams__c ws : newTrigger)
            {
                AH_Project_Backlog_Workstreams__c oldWs = oldMapTrigger.get(ws.Id);
                if ((ws.Workstream_Name__c != oldWs.Workstream_Name__c) && (ws.Workstream_Name__c != null))
                {
                    lstWsToUpdate.add(ws);
                }
            }         
            
            //CALL THE METHOD TO POPULATE THE HOURLY COST    
            Update_HourlyCost(lstWsToUpdate); 
            
        }  
    }

    // =================================================================================================================  
    //  FUNCTIONS ======================================================================================================   
    // =================================================================================================================
    private void Update_HourlyCost(List<AH_Project_Backlog_Workstreams__c> newTrigger)
    {
        
        Map<String, AH_Workstream__c> mapWS = new Map<String, AH_Workstream__c>();
        
        for (AH_Workstream__c ahws : [SELECT Id, Name, Hourly_Cost__c FROM AH_Workstream__c WHERE Active__c = true])
        {
            mapWS.put(ahws.Name, ahws);
        } 
        
        // LOOP THROUGH THE INSERTED PROJECT BACKLOG WORKSTREAM RECORDS AND POPULATE THE HOURLY COST FIELD
        for (AH_Project_Backlog_Workstreams__c ws : newTrigger)
        {
            // SEE IF THE PROJECT BACKLOG WORKSTREAM RECORD HAS A MATCHING AH WORKSTREAM RECORD.
            if (mapWS.containsKey(ws.Workstream_Name__c))
            {
                // IF A MATCHING RECORD IS FOUND, UPDATE THE HOURLY COST TO MATCH THE AH WORKSTREAM RECORD
                if (mapWS.get(ws.Workstream_Name__c).Hourly_Cost__c != null)
                {
                    ws.Hourly_Cost__c = mapWS.get(ws.Workstream_Name__c).Hourly_Cost__c;
                }
            }
        }
        
    }
    
}