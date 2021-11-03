/****************************************************************************************
Name            : AH_APT_AgreementLineItem_AfterInsert Trigger
Author          : Apttus
Created Date    : 11/18/2013
Last Mod Date   : 06/06/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_APT_AgreementLineItem_AfterInsert on Apttus__AgreementLineItem__c (after insert) 
{
    AH_APT_AgreementLI_TriggerHandler handler = new AH_APT_AgreementLI_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);
}