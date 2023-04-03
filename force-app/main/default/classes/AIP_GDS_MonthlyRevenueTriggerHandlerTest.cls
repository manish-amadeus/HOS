/************************************************************************************************
Name            : AIP_GDS_MonthlyRevenueTriggerHandlerTest Class
Author          : Stuart Emery
Created Date    : 1/16/2015
Last Mod Date   : 1/16/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test Class for the AIP_GDS_Monthly_Revenue_TriggerHandler Class
:
: 
*************************************************************************************************/
@isTest (SeeAllData=false)
private class AIP_GDS_MonthlyRevenueTriggerHandlerTest 
{
    
    static testMethod void bulkRecordInsertTest() 
    {    
        system.debug(' starting bulkRecordInsertTest ');  
        try{
            
            // LIST OF CUSTOM SETTINGS RECORDS TO INSERT  
            List<AIP_GDS_MonthlyRevenue__c> lstCsToInsert = new List<AIP_GDS_MonthlyRevenue__c>(); 
            
            // INSERT A TEST RECORD INTO THE AIP_GDS_MonthlyRevenue__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
            AIP_GDS_MonthlyRevenue__c csFields = new AIP_GDS_MonthlyRevenue__c();
            csFields.Name = 'Test';
            csFields.Number_of_Months__c = 12;
            
            lstCsToInsert.add(csFields);
            insert csFields;
            
            // CREATE TEST ACCOUNTS FOR BULK INSERT
            List<Account> lstAccountsToInsert = new List<Account>();
            for (Integer j = 0; j < 25; j++) 
            {
              
                Account a = NI_TestClassData.createTestAccount(j);
                lstAccountsToInsert.add(a);
            }
            Database.insert(lstAccountsToInsert);
            system.debug(lstAccountsToInsert);
            
            // LIST OF INSERTED ACCOUNTS
            List<Account> insertedAccounts = [SELECT Id FROM Account];
            
            // VERIFY THAT 25 ACCOUNTS WERE CREATED
            System.assertEquals(25, insertedAccounts.size());          
            
            // CREATE TEST MARKET RECORD 
            Market__c aipMark = NI_TestClassData.createAIPMarket(1);
            insert aipMark;
            
            Test.startTest();
            // CREATE GDS MONTHLY REVENUE RECORDS FOR EACH ACCOUNT
            List<AIP_GDS_Monthly_Revenue__c> lstGDSToInsert = new List<AIP_GDS_Monthly_Revenue__c>();
            
            Date curDate = Date.Today();
            Date dJune = Date.newInstance((curDate.Year() - 2), 6, 1);
            
            
            // ACCOUNT RELATED TEST RECORDS
            for (Account acct : insertedAccounts)
            {
                for (Integer k = 1; k < 27; k++)  
                {
                    Date d = curDate.addMonths(-k);               
                    AIP_GDS_Monthly_Revenue__c rev = NI_TestClassData.createAIP_GDS_MonthlyRevenue(k, d); 
                    rev.Account__c = acct.Id; 
                    rev.Number_of_GDS_Bookings__c = (100 * k); 
                    rev.Number_of_GDS_Roomnights__c = (1000 * k); 
                    rev.Revenue_Amount__c = (10000 * k); 
                    rev.Revenue_Month__c = d; 
                    lstGDSToInsert.add(rev); 
                }    
            }  
            
            // MARKET RELATED TEST RECORDS
            
            for (Integer k = 1; k < 27; k++)  
            {
                Date d = curDate.addMonths(-k);               
                AIP_GDS_Monthly_Revenue__c rev = NI_TestClassData.createAIP_GDS_MonthlyRevenue(k, d); 
                rev.Market__c = aipMark.Id; 
                rev.Number_of_GDS_Bookings__c = (100 * k); 
                rev.Number_of_GDS_Roomnights__c = (1000 * k); 
                rev.Revenue_Month__c = d; 
                lstGDSToInsert.add(rev); 
            }    
            
            Database.insert(lstGDSToInsert); 
            Test.stopTest(); 
            
            // LIST TO HOLD THE INSERTED GDS MONTHLY REVENUE RECORDS  
            List<AIP_GDS_Monthly_Revenue__c> lstInsertedGDS = [SELECT Id, Account__c FROM AIP_GDS_Monthly_Revenue__c]; 
            
            // VERIFY THAT 5200 GDS MONTHLY RECORDS WERE CREATED  
            //System.assertEquals(5226, lstInsertedGDS.size()); 
            System.assertEquals(676, lstInsertedGDS.size()); 
            
            // LIST OF UPDATED ACCOUNTS
            List<Account> updatedAccounts = [SELECT Id, AIP_GDS_Annual_Revenue__c FROM Account]; 
            
            // VERIFY THAT 25 ACCOUNTS RETURNED
            System.assertEquals(25, updatedAccounts.size()); 
            
            // LOOP THROUGH ALL OF THE ACCOUNTS AND VERIFY THE AIP_GDS_Annual_Revenue__c FIELD VALUE = 780000  
            // 780000 = (10000 + 20000 + 30000 + 40000 + 50000 + 60000 + 70000 + 80000 + 90000 + 10000 + 110000 + 120000)
            for (Account aRev : updatedAccounts)
            {
                System.assertEquals(780000, aRev.AIP_GDS_Annual_Revenue__c); 
            }  
            system.debug(' ending bulkRecordInsertTest ');         
        }   
        
        Catch(DMLException e){
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        
    }
    
    
    
}