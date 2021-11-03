/****************************************************************************************
Name            : NI_Pager_Bonus__c Before Insert Trigger
Author          : Stuart Emery
Created Date    : 5/14/2014
Last Mod Date   : 5/23/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-010344
Description     : Before Insert Trigger for the NI Pager Bonus Object
                : 
                : 
******************************************************************************************/
trigger NI_Pager_Bonus_BeforeInsert on NI_Pager_Bonus__c (before insert) 
{

    //ONLY CALL THE TRIGGER IF THE BYPASS SWITCH IS NOT CHECKED  
      if (!NI_FUNCTIONS.bypassTriggerCode('PAGER BONUS'))
         {
            NI_Pager_Bonus_TriggerHandler handler = new NI_Pager_Bonus_TriggerHandler();
            handler.OnBeforeInsert(Trigger.new);
         }   
    
}