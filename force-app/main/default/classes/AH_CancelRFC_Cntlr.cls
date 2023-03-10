/****************************************************************************************
Name            : AH_CancelRFC_Cntlr Class 
Author          : Shashikant Nikam
Created Date    : 08/21/2019
Last Mod Date   : 10/13/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for CancelRFC Lightning component
				: 10/13/2020 added "without sharing" for critical update release.
				:  
******************************************************************************************/
public without sharing class AH_CancelRFC_Cntlr 
{
    @AuraEnabled
    public static void updateRecord(string recordId)
    {
        try 
        {
            NI_Change_Control__c record = [SELECT Id, Change_Status__c FROM NI_Change_Control__c WHERE Id =: recordId];
            record.Change_Status__c = 'Cancelled';
            Database.update(record);
        }
        catch(Exception e)
        {
            system.debug('Exception found : ' + e);
        }
    }
}