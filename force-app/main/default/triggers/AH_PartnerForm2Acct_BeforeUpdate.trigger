/****************************************************************************************
Name            : AH_PartnerForm2Acct_BeforeUpdate Trigger
Author          : Sean Harris
Created Date    : 10/13/2017
Last Mod Date   : 10/13/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_PartnerForm2Acct_BeforeUpdate on Partners_Form_Template_to_Account__c (before update) 
{
    
    AH_PartnerForm2Acct_TriggerHandler handler = new AH_PartnerForm2Acct_TriggerHandler();
    handler.OnBeforeUpdate(Trigger.new);
 
}