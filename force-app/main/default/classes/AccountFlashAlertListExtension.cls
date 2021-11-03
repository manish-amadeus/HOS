/****************************************************************************************
Name            : AccountFlashAlertListExtension 
Author          : Black Iron Group
Created Date    : 07/18/2010 
Last Mod Date   : 04/25/2017 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : This class is an extention controller for a VF Page called AccountFlashAlerts
                :
****************************************************************************************/
public with sharing class AccountFlashAlertListExtension 
{

    Account a;
    public SFDC_CSP_Flash_Message__c[] messages {get; set;}

    public AccountFlashAlertListExtension(ApexPages.StandardController stdController)
    {
        
        this.a = (Account)stdController.getRecord();
        messages = new SFDC_CSP_Flash_Message__c[0];
        String accountId;
        
        // GET THE FLASHMESSAGES FOR THE ACCOUNT
        if (this.a != null) 
        {
            
            accountId = this.a.Id;
            
            for (SFDC_CSP_Flash_Message__c[] mess : [SELECT Id, Account__c, Name, Message__c, Priority__c, Solution__c, Viewable_to_All_Children__c, CreatedDate 
                                                     FROM SFDC_CSP_Flash_Message__c 
                                                     WHERE Account__c =: accountId]) 
            {
                messages.addAll(mess);
            }
            
            // GET THE PARENTS
            Boolean done = false;
            while (!done) 
            {
                
                accountId = [SELECT ParentId FROM Account WHERE Id =: accountId].ParentId;
                
                // IF THE ACCOUNT HAS A PARENT ADD THE MESSAGES THE CHILDREN CAN SEE
                if (accountId != null && accountId != '') 
                {
                    for (SFDC_CSP_Flash_Message__c[] mess : [SELECT Id, Account__c, Name, Message__c, Priority__c, Solution__c, Viewable_to_All_Children__c, CreatedDate 
                                                             FROM SFDC_CSP_Flash_Message__c 
                                                             WHERE Account__c =: accountId 
                                                             AND HideFlashFromChildren__c = false]) 
                    {
                        messages.addAll(mess);
                    }
                }
                // OTHERWISE WE'RE DONE
                else 
                {
                    done = true;
                }
            }
            
        }

    }
        
}