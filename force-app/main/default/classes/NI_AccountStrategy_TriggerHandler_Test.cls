/****************************************************************************************
Name            : NI_AccountStrategy_TriggerHandler_Test Class
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
public class NI_AccountStrategy_TriggerHandler_Test
{

    public static testMethod void testTrigHandler() 
    {
      
        // CREATE TEST CUSTOM SETTINGS DATA FOR NI_ZZZ_HRM_Product__c ============================================================================================
        List<NI_ZZZ_HRM_Product__c> lstCustomSettings = new List<NI_ZZZ_HRM_Product__c>();        
        lstCustomSettings.Add(new NI_ZZZ_HRM_Product__c(Name='ZZZ-HRM-001', Product2Id__c ='01t60000004Hq15AAC', DI_DefaultStatus__c ='Purchased'));
        
      	NI_AccountStrategy_TriggerHandler handler = new NI_AccountStrategy_TriggerHandler(true); 
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

		SFDC_Strategy__c stgy = NI_TestClassData.createStrategy(1, a.Id, apln.Id);
        stgy.Invoke_Rollups__c = true;
        insert stgy;

        Id rtInit = NI_TestClassData.getRecordTypeId('Opportunity', 'Small Deal Opportunity');
        
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.RecordTypeId = rtInit;
        opp1.Strategy__c = stgy.Id;
        lstOppInserts.Add(opp1);
        
        Opportunity opp2 = NI_TestClassData.createTestOpportunity(2, a.Id); 
        opp2.RecordTypeId = rtInit;
        opp2.Strategy__c = stgy.Id;
        opp2.StageName = 'Closed Won';        
        lstOppInserts.Add(opp2);
        
        Opportunity opp3 = NI_TestClassData.createTestOpportunity(3, a.Id); 
        opp3.RecordTypeId = rtInit;
        opp3.Strategy__c = stgy.Id;
        opp3.StageName = 'Closed Lost'; 
        opp3.Win_Loss_Reason__c = 'Price';
        opp3.Win_Loss_Notes__c = 'Too pricey!';
        lstOppInserts.Add(opp3);
        
        Database.Insert(lstOppInserts);
        
        List<SFDC_Strategy__c> lstStrategy = new List<SFDC_Strategy__c>([SELECT Id, Invoke_Rollups__c, SFDC_Acct_Plan__c FROM SFDC_Strategy__c]); 

        Map<Id, SFDC_Strategy__c> mapStrategy = new Map<Id, SFDC_Strategy__c>([SELECT Id, Invoke_Rollups__c, SFDC_Acct_Plan__c FROM SFDC_Strategy__c WHERE Id =: stgy.Id]);
        
        Test.StartTest();

        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnBeforeInsert(lstStrategy);
        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnBeforeUpdate(lstStrategy);
//        NI_TriggerManager.isBypassOppUdate = true;
//        handler.OnBeforeDelete(lstStrategy);
        
        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnAfterInsert(lstStrategy);
        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnAfterUpdate(lstStrategy, mapStrategy);
//        NI_TriggerManager.isBypassOppUdate = true;
//        handler.OnAfterDelete(lstStrategy);
        NI_TriggerManager.isBypassOppUdate = true;
        handler.OnAfterUndelete(lstStrategy);         
       
        Test.StopTest();   
        
        delete stgy;
        delete apln;        
        
    }

}