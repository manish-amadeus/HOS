/****************************************************************************************
Name            : CaseFlashAlertExtension 
Author          : Black Iron Group
Created Date    : 07/18/2010 
Last Mod Date   : 04/17/2017 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : This class is an extention controller for a VF Page called CaseFlashAlertPopup
                : 
				: 
****************************************************************************************/
public with sharing class CaseFlashAlertExtension 
{

    Case c; 
    public Integer numberOfMessages {get; set;} 
    public Boolean showMessages {get; set;} 
    private Boolean updateFirstTime = false; 

    public CaseFlashAlertExtension(ApexPages.StandardController stdController) 
    {
        
        numberOfMessages = 0;   
        this.c = (Case)stdController.getRecord();
        
        if (c.First_Time_Flash_Message_Count__c <= 0) 
        {
            showMessages = true;
            updateFirstTime = true;
        }
        
        string accountId;
        
        // GET THE FLASHMESSAGES FOR THE CASE'S ACCOUNT
        if (this.c.AccountId != null) 
        {
        
            accountId = this.c.AccountId;
            numberOfMessages += [SELECT COUNT() FROM SFDC_CSP_Flash_Message__c WHERE Account__c =: accountId];
            
            // GET THE PARENTS
            boolean done = false;
            
            while (!done) 
            {               
                accountId = [SELECT ParentId FROM Account WHERE Id =: accountId].ParentId;
                // IF THE ACCOUNT HAS A PARENT ADD THE CASES THE CHILDREN CAN SEE
                if (accountId != null) 
                {
                    numberOfMessages += [SELECT COUNT() FROM SFDC_CSP_Flash_Message__c WHERE Account__c =: accountId AND Viewable_to_All_Children__c = true];
                }
                // OTHERWISE WE'RE DONE
                else 
                {
                    done = true;
                }
            }
        }
    }

    public PageReference updateCase() 
    {
        
        Solution_Count__c sc;
        
        if (updateFirstTime) 
        {
            try 
            { 
                sc = [SELECT Id FROM Solution_Count__c WHERE Case__c =: c.Id];
                sc.First_Time_Flash_Message__c = 1;
                update sc;
            }
            catch (Exception ex) 
            {
                try 
                {
                    sc = new Solution_Count__c(Case__c = c.Id, First_Time_Flash_Message__c = 1);
                    insert sc;
                }
                catch (Exception ex2){}
            }
        }
        return null;
    }

}