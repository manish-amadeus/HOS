/****************************************************************************************
Name            : AH_PartnerForm2Acct_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 10/13/2017
Last Mod Date   : 10/13/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_PartnerForm2Acct_AfterUpdate on Partners_Form_Template_to_Account__c (After update) 
{
    
    AH_PartnerForm2Acct_TriggerHandler handler = new AH_PartnerForm2Acct_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
 
}