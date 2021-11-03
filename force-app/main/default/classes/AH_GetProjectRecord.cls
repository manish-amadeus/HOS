/****************************************************************************************
Name            : AH_GetProjectRecord Class 
Author          : Shashikant Nikam
Created Date    : 10/23/2020
Last Mod Date   : 10/28/2020 
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     :  
                : 
                : 
******************************************************************************************/

global class AH_GetProjectRecord {

    @AuraEnabled(cacheable=true)
    public static pse__Proj__c returnProjectRecordDetails(String recordId){

        system.debug('recordId : '+recordId);
        pse__Proj__c projRecord = [select id, Name, pse__Account__c, pse__Opportunity__c, pse__Project_Manager__c from pse__Proj__c where id =: recordId];

        return projRecord;
    }
}