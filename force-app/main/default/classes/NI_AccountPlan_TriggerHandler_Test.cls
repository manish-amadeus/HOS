/****************************************************************************************
Name            : NI_AccountPlan_TriggerHandler_Test Class
Author          : Sean Harris
Created Date    : 11/17/2014
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-012182
Description     : 
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_AccountPlan_TriggerHandler_Test
{

    public static testMethod void testTrigHandler() 
    {
        
      	NI_AccountPlan_TriggerHandler handler = new NI_AccountPlan_TriggerHandler(true); 
        boolean IsTriggerContext = handler.IsTriggerContext; 

        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        SFDC_Acct_Plan__c mstapln = NI_TestClassData.createAccountPlan(2, a.Id);
        mstapln.Invoke_Rollups__c = false;
        insert mstapln;
        
        SFDC_Acct_Plan__c apln = NI_TestClassData.createAccountPlan(1, a.Id);
        apln.Invoke_Rollups__c = true;
        apln.Master_Account_Plan__c = mstapln.Id;
        insert apln;

        List<SFDC_Acct_Plan__c> lstAPlan = new List<SFDC_Acct_Plan__c>([SELECT Id, Invoke_Rollups__c, Master_Account_Plan__c FROM SFDC_Acct_Plan__c]); 

        Map<Id, SFDC_Acct_Plan__c> mapAcctPlan = new Map<Id, SFDC_Acct_Plan__c>([SELECT Id, Invoke_Rollups__c, Master_Account_Plan__c FROM SFDC_Acct_Plan__c WHERE Id =: apln.Id]);
        
        Test.StartTest();

        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnBeforeInsert(lstAPlan);
        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnBeforeUpdate(lstAPlan);
        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnBeforeDelete(lstAPlan);
        
        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnAfterInsert(lstAPlan);
        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnAfterUpdate(lstAPlan, mapAcctPlan);
        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnAfterDelete(lstAPlan);
        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnAfterUndelete(lstAPlan);         
       
        Test.StopTest();        
        
    }

}