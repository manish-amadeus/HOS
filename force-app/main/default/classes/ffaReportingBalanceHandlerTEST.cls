/************************************************************************************************
Name            : ffaReportingBalanceHandlerTEST Class
Author          : CLD Partners
Created Date    : 03/31/2016
Last Mod Date   : 06/28/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for ffaReportingBalanceHandler
                : 
                : 
*************************************************************************************************/
@isTest (seealldata = true)
public class ffaReportingBalanceHandlerTEST 
{

    static testMethod void test1() 
    {
                
        // GET RUNNING USER RECORD
        User ru = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        // CREATE TEST COMPANY
        c2g__codaCompany__c co = NI_TestClassData.createFFACompany('APEX ACME COMP', ru, true);
        insert co;
        
        // ADD USER RUNNING TEST TO THE TEST COMPANY
        c2g__codaUserCompany__c uCo = NI_TestClassData.createFFAUserCompany(co.Id, ru.Id);
        insert uCo;        
        
        List<c2g__ReportingBalance__c> reportingBalanceList = new List<c2g__ReportingBalance__c>(
            [SELECT BPC_Cost_Center__c, c2g__Dimension2__c, c2g__Dimension3__c, c2g__DualValue__c, 
             c2g__GeneralLedgerAccount__c, c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c, c2g__GeneralLedgerAccount__r.c2g__TrialBalance2__c,
             c2g__GeneralLedgerAccount__r.c2g__TrialBalance3__c, c2g__OwnerCompany__c, c2g__Period__r.Name,
             c2g__Period__r.c2g__StartDate__c, c2g__Period__r.c2g__EndDate__c, c2g__Type__c, Financial_Statement_Grouping__c 
             FROM c2g__ReportingBalance__c
             WHERE c2g__DualValue__c != 0 
             AND c2g__Dimension2__c != null
             AND c2g__Dimension3__c != null 
             LIMIT 200]);
        
        List<Amadeus_Mapping_Table__c> amtList = new List<Amadeus_Mapping_Table__c>();
        
        for (c2g__ReportingBalance__c rb : reportingBalanceList)
        {
            
            Amadeus_Mapping_Table__c amt1 = new Amadeus_Mapping_Table__c(
                Output__c = 'TEST',
                Mapping_Type__c = 'BPC Cost Center',
                General_Ledger_Account__c = rb.c2g__GeneralLedgerAccount__c,
                Trial_Balance_2__c = rb.c2g__GeneralLedgerAccount__r.c2g__TrialBalance2__c,
                FFA_Company__c = rb.c2g__OwnerCompany__c,
                Cost_Center_Dim_3__c = rb.c2g__Dimension3__c,
                Business_Line_Dim_2__c = rb.c2g__Dimension2__c);
            amtList.add(amt1);
            
            Amadeus_Mapping_Table__c amt2 = new Amadeus_Mapping_Table__c(
                Output__c = 'TEST',
                Mapping_Type__c = 'Amadeus FS Reporting',
                General_Ledger_Account__c = rb.c2g__GeneralLedgerAccount__c,
                Trial_Balance_2__c = rb.c2g__GeneralLedgerAccount__r.c2g__TrialBalance2__c,
                FFA_Company__c = rb.c2g__OwnerCompany__c,
                Cost_Center_Dim_3__c = rb.c2g__Dimension3__c,
                Business_Line_Dim_2__c = rb.c2g__Dimension2__c,
                Order_of_Evaluation__c = 1);
            amtList.add(amt2);
            
            Amadeus_Mapping_Table__c amt3 = new Amadeus_Mapping_Table__c(
                Output__c = 'TEST',
                Mapping_Type__c = 'Amadeus FS Reporting',
                General_Ledger_Account__c = rb.c2g__GeneralLedgerAccount__c,
                Trial_Balance_2__c = rb.c2g__GeneralLedgerAccount__r.c2g__TrialBalance2__c,
                FFA_Company__c = rb.c2g__OwnerCompany__c,
                Cost_Center_Dim_3__c = rb.c2g__Dimension3__c,
                Business_Line_Dim_2__c = rb.c2g__Dimension2__c,
                Order_of_Evaluation__c = 2);
            amtList.add(amt3);
            
            Amadeus_Mapping_Table__c amt4 = new Amadeus_Mapping_Table__c(
                Output__c = 'TEST',
                Mapping_Type__c = 'Amadeus FS Reporting',
                General_Ledger_Account__c = rb.c2g__GeneralLedgerAccount__c,
                Trial_Balance_2__c = rb.c2g__GeneralLedgerAccount__r.c2g__TrialBalance2__c,
                FFA_Company__c = rb.c2g__OwnerCompany__c,
                Cost_Center_Dim_3__c = rb.c2g__Dimension3__c,
                Business_Line_Dim_2__c = rb.c2g__Dimension2__c,
                Order_of_Evaluation__c = 3);
            amtList.add(amt4);
            
        }
        
        insert amtList;
        
        update reportingBalanceList;
        
    }
    
}