/**************************************************************************************************************
Name            : AH_Finance_Request_Statics Class
Author          : Stuart Emery
Created Date    : 09/19/2018
Last Mod Date   : 09/19/2018
Last Mod By     : Stuart Emery
NICC Reference  : NICC-030091
Description     : Public Methods called by the AH_Finance_Request_Trigger_Handler,
                : AH_Manual_Credit_Lines_TriggerHandler and AH_Finance_Req_to_SIN_LI_Trigger_Handler Classes
				: RUN THE FOLLOWING TEST CLASSES:
                : AH_Finance_Request_Trigger_Handler_Test, AH_Finance_Req_to_SIN_LI_TrigHandlerTest,
                : AH_Manual_Cred_Lines_TriggerHandlerTest
***************************************************************************************************************/
public class AH_Finance_Request_Statics 
{
    
    //====================================================================================================================================================    
    //   METHOD TO CALCULATE THE REQUESTED CREDIT AMOUNT FIELD ON THE FINANCE REQUEST OBJECT.  ADDED PER NICC-030091
    //====================================================================================================================================================
    public static void rollupFinanceRequestNetCreditAmount(List<AH_Finance_Request__c> newTrigger)
    {  
        
        List<AH_Finance_Request__c> lstFr = [SELECT Id,Tax_Amount__c
                                             FROM AH_Finance_Request__c
                                             WHERE Id IN : newTrigger];
        decimal dCreditAmount = 0;
        decimal dTaxAmount = 0;
        Set<Id> setFrIds = new Set<Id>(); 
        List<AH_Finance_Request_to_SIN_Line_Item__c> lstSINtoLineItem = new List<AH_Finance_Request_to_SIN_Line_Item__c>();
        List<AH_Manual_Credit_Lines__c> lstManualCreditLines = new List<AH_Manual_Credit_Lines__c>();	
        List<AH_Finance_Request__c> lstFRtoUpdate = new List<AH_Finance_Request__c>();
        
        lstSINtoLineItem = ([SELECT Id, Finance_Request__c, Requested_Credit_Amount__c
                             FROM AH_Finance_Request_to_SIN_Line_Item__c
                             WHERE Finance_Request__c IN : newTrigger]);
        
        lstManualCreditLines = ([SELECT Id, Finance_Request__c, Requested_Credit_Amount__c
                                 FROM AH_Manual_Credit_Lines__c
                                 WHERE Finance_Request__c IN : newTrigger]);
        
        for (AH_Finance_Request__c fr : lstFr)
        {
            dCreditAmount = 0;
            if (fr.Tax_Amount__c == null)
            {
                dTaxAmount = 0;  
            }
            else
            {
                dTaxAmount = fr.Tax_Amount__c;  
            }
            
            if (lstSINtoLineItem.size() > 0)  
            {
                for (AH_Finance_Request_to_SIN_Line_Item__c frToSinLI : lstSINtoLineItem)
                {
                    dCreditAmount += frToSinLI.Requested_Credit_Amount__c;
                }
            }
            
            if (lstManualCreditLines.size() > 0)
            {
                for (AH_Manual_Credit_Lines__c frToManCredLines : lstManualCreditLines)
                {
                    dCreditAmount += frToManCredLines.Requested_Credit_Amount__c;
                }
            }
            fr.Net_Credit_Amount__c = dCreditAmount + dTaxAmount;
            lstFRtoUpdate.add(fr);
        }
        
        if (lstFRtoUpdate.size() > 0)
        {
            database.update(lstFRtoUpdate);  
        }
        
    }
    
}