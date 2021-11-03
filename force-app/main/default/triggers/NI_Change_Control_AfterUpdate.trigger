/****************************************************************************************
Name            : NI_Change_Control_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 2/15/2013
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Change_Control_AfterUpdate on NI_Change_Control__c (after update) 
{

    NI_Change_Control_TriggerHandler handler = new NI_Change_Control_TriggerHandler(true);

    // TRIGGER BYPASS CHECK ===========================
    if (NI_TriggerManager.bypass_NICC_Updates == false)
    {  
        handler.addCustomerSignOffArtifact(Trigger.new);
        handler.Change_Owner_Share(Trigger.new);
        handler.OnAfterUpdate(Trigger.new,Trigger.oldMap);
        
        // SHARING METHODS =============================
        handler.NICCpeerReviewerShare(Trigger.new);
        handler.NICCdevReviewerShare(Trigger.new);
        handler.NICCMRShare(Trigger.new);
        handler.NICCCompShare(Trigger.new);
    }
    
}