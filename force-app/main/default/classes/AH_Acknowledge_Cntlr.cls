/****************************************************************************************
Name            : AH_Acknowledge_Cntlr
Author          : Bhuleshwar Deshpande
Created Date    : 09/20/2019
Last Mod Date   : 10/13/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class for AH_acknowledge_Cntlr  
				: 10/13/2020 added "without sharing" for critical update release.
				: 
******************************************************************************************/
public without sharing class AH_Acknowledge_Cntlr 
{
       
    @AuraEnabled
    Public Static boolean acknowledgeCase (string recordId)
    {
        
        // BOOLEAN VARIABLE TO PASS JSCONTROLLER TO SHOW TOAST MESSAGE.
        boolean isAckndgNull = false;
        try
        {
            Case AcknCaseRecord = [SELECT Id, Acknowledged__c, Status FROM Case WHERE Id =: recordId];
            if (AcknCaseRecord.Acknowledged__c == null)
            {
                AcknCaseRecord.Status = 'Acknowledged'; 
                AcknCaseRecord.Acknowledged__c = system.today();
                Database.update(AcknCaseRecord);
                isAckndgNull = true;
            }
        }
        catch(Exception e)
        {            
            system.debug('Exception found : ' + e);
        }
        
        return isAckndgNull;
    }

}