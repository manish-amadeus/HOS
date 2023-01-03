/****************************************************************************************
Name            : AH_PartnerForm2Acct_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 10/13/2017
Last Mod Date   : 10/13/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_PartnerForm2Acct_BeforeInsert on Partners_Form_Template_to_Account__c (before insert) 
{
    
    AH_PartnerForm2Acct_TriggerHandler handler = new AH_PartnerForm2Acct_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
 
}