/****************************************************************************************
Name            : AH_Survey_ResponseData_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 9/21/2017
Last Mod Date   : 10/9/2017
Last Mod By     : Stuart Emery
NICC Reference  : NICC-024092
Description     : Before Insert Trigger that calls the OnAfterInsert methods in the 
                : AH_Survey_ResponseData_BeforeInsert Class
                : 
******************************************************************************************/
trigger AH_Survey_ResponseData_BeforeInsert on Confirmit_Survey_Response_Data__c (before insert) 
{
    // ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('SURVEY RESPONSE DATA'))
    {
        AH_SurveyResponseDataTriggerHandler handler = new AH_SurveyResponseDataTriggerHandler();
        handler.onBeforeInsert(Trigger.new);
    }
}