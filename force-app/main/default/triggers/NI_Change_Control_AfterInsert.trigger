/****************************************************************************************
Name            : NI_Change_Control_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 2/15/2013
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Change_Control_AfterInsert on NI_Change_Control__c (after insert) 
{

    NI_Change_Control_TriggerHandler handler = new NI_Change_Control_TriggerHandler(true);


    handler.OnAfterInsert(Trigger.new); 

    handler.addArtifactTemplates(Trigger.new);
    handler.HRFCcompilerBlank(Trigger.new);
    handler.AddCase_To_NICCRequestCaseJunction(Trigger.new);
            
       
    // SHARING METHODS =============================
    handler.Change_Owner_Share(Trigger.new);          
    handler.NICCpeerReviewerShare(Trigger.new);
    handler.NICCdevReviewerShare(Trigger.new);
    handler.NICCMRShare(Trigger.new);
    handler.NICCCompShare(Trigger.new);       
        
}