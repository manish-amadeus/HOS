/****************************************************************************************
Name            : AH_Diagnose_Cntlr
Author          : Bhuleshwar Deshpande   
Created Date    : 09/20/2019
Last Mod Date   : 10/13/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class for AH_DiagnoseCase_Cntrl
				: 10/13/2020 added "without sharing" for critical update release.
				:  
******************************************************************************************/
public without sharing class AH_Diagnose_Cntlr 
{
    
    @AuraEnabled
    Public Static boolean diagnoseCase (string recordId)
    {
        // BOOLEAN VARIABLE TO PASS JSCONTROLLER TO SHOW TOAST MESSAGE.
        boolean isDiagnoseNull = false;
        
        try
        {
            Case DiagnoseRecord = [SELECT Id, Diagnosed_Date_and_Time__c, Status FROM Case WHERE Id =: recordId];
            if (DiagnoseRecord.Diagnosed_Date_and_Time__c == null)
            {
                DiagnoseRecord.Status = 'Recovered'; 
                DiagnoseRecord.Diagnosed_Date_and_Time__c = system.today();
                Database.update(DiagnoseRecord);
                isDiagnoseNull = true;
            }
        }
        catch(Exception e)
        {
            system.debug('Exception found : ' + e);
        }
        return isDiagnoseNull;
    }
    
}