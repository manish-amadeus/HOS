/****************************************************************************************
Name            : NI_Pager_Bonus__c After Update Trigger
Author          : Stuart Emery
Created Date    : 5/14/2014
Last Mod Date   : 5/23/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-010344
Description     : After Update Trigger for the NI Pager Bonus Object
                : 
                : 
******************************************************************************************/
trigger NI_Pager_Bonus_AfterUpdate on NI_Pager_Bonus__c (after update) 
{

    //ONLY CALL THE TRIGGER IF THE BYPASS SWITCH IS NOT CHECKED  
      if (!NI_FUNCTIONS.bypassTriggerCode('PAGER BONUS'))
         {
            NI_Pager_Bonus_TriggerHandler handler = new NI_Pager_Bonus_TriggerHandler();
            handler.OnAfterUpdate(Trigger.new,Trigger.oldMap);
         }    
    
}