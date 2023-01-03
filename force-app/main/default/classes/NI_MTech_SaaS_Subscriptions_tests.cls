/************************************************************************************************
Name            : NI_MTech_SaaS_Subscriptions_tests Class
Author          : Stuart Emery
Created Date    : 10/21/2016
Last Mod Date   : 10/21/2016
Last Mod By     : Stuart Emery
NICC Reference  : NICC-019882
Description     : Test Class for the MTech_Saas_Subscription__c Object Triggers
                :
*************************************************************************************************/
@isTest
public class NI_MTech_SaaS_Subscriptions_tests {
        
        
    static testMethod void AfterUpdate_trigger_test(){
            
            // add account
            //List<Account> accounts = new List<Account>{};
            //    Account a = new Account(Name = 'Test Account',Region__c = 'NORTHAMER');
            //accounts.add(a);
            //insert accounts;
            
            // CREATE TEST ACCOUNT RECORD 
            Account a = NI_TestClassData.createTestAccount(1);
            a.Name = 'APEX TESTER ACCOUNT';
            a.Region__c = 'NORTHAMER';
            insert a;
            
            // CREATE TEST PRODUCT GROUP RECORD
            Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
            insert pgp;
            
             // CREATE TEST DI INDEX RECORD
            NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');
            insert diIdx1;
            
            // CREATE TEST PRODUCT RECORDS 
            Product2 p = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Support');
            p.DI_Index__c = diIdx1.Id;
            insert p;
            
            // add product
            //List<Product2> products = new List<Product2>{};
            //    Product2 p = new Product2(Name = 'Test Product');
            //products.add(p);
            //insert products;
            
            // add subscription
            List<MTech_SaaS_Subscription__c> subscriptions = new List<MTech_SaaS_Subscription__c>{};
                MTech_SaaS_Subscription__c s = new MTech_SaaS_Subscription__c(
                    product__c = p.ID,
                    account__c = a.ID,
                    quantity__c = 1,
                    unit_price__c = 2.22,
                    price_expiration_date__c = Date.newInstance(2015, 1, 1 ));        
            subscriptions.add(s);
            insert subscriptions;
        
        //GET THE INSERTED SUBSCRIPTION    
        MTech_SaaS_Subscription__c insertedSubscription = [SELECT Id,is_deleted__c FROM MTech_SaaS_Subscription__c LIMIT 1];
        
            //ISSUE AN UPDATE TO INVOKE UPDATE LOGIC IN THE NI_LogChange TRIGGER.  NO ACTUAL CHANGES ARE BEING MADE
            insertedSubscription.Modification_Reason__c = 'Lost Account';  
            update insertedSubscription;
            
            test.startTest();
            // ATTEMPT TO CHANGE THE is_deleted__c FIELD TO INVOKE THE UPDATE LOGIC IN THE NI_LogChange TRIGGER     
            try {
                
                insertedSubscription.is_deleted__c = TRUE;
                update insertedSubscription;
            } catch(DmlException e) {
                System.debug('Update operation as expected: ' + e.getMessage());
            }
            test.stopTest();
            
        }
    
    static testMethod void NoDelete_trigger_test(){
            
            // add account
            //List<Account> accounts = new List<Account>{};
            //    Account a = new Account(Name = 'Test Account',Region__c = 'NORTHAMER');
            //accounts.add(a);
            //insert accounts;
            
            // CREATE TEST ACCOUNT RECORD 
            Account a = NI_TestClassData.createTestAccount(1);
            a.Name = 'APEX TESTER ACCOUNT';
            a.Region__c = 'NORTHAMER';
            insert a;
            
            // CREATE TEST PRODUCT GROUP RECORD
            Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
            insert pgp;
            
             // CREATE TEST DI INDEX RECORD
            NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');
            insert diIdx1;
            
            // CREATE TEST PRODUCT RECORDS 
            Product2 p = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Support');
            p.DI_Index__c = diIdx1.Id;
            insert p;
            
            // add product
            //List<Product2> products = new List<Product2>{};
            //    Product2 p = new Product2(Name = 'Test Product');
            //products.add(p);
            //insert products;
            
            // add subscription
            List<MTech_SaaS_Subscription__c> subscriptions = new List<MTech_SaaS_Subscription__c>{};
                MTech_SaaS_Subscription__c s = new MTech_SaaS_Subscription__c(
                    product__c = p.ID,
                    account__c = a.ID,
                    quantity__c = 1,
                    unit_price__c = 2.22,
                    price_expiration_date__c = Date.newInstance(2015, 1, 1 ));        
            subscriptions.add(s);
            insert subscriptions;
            
            test.startTest();
            // attempt to delete subscription
            try {
                delete subscriptions;
            } catch(DmlException e) {
                System.debug('Delete operation failed as expected: ' + e.getMessage());
            }
            test.stopTest();
            
        }
        
        static testMethod void NoLogDelete_trigger_test(){
            
            // add account
            //List<Account> accounts = new List<Account>{};
            //    Account a = new Account(Name = 'Test Account',Region__c = 'NORTHAMER');
            //accounts.add(a);
            //insert accounts;
            
            // add product
            //List<Product2> products = new List<Product2>{};
            //    Product2 p = new Product2(Name = 'Test Product');
            //products.add(p);
            //insert products;
            
            // CREATE TEST ACCOUNT RECORD 
            Account a = NI_TestClassData.createTestAccount(1);
            a.Name = 'APEX TESTER ACCOUNT';
            a.Region__c = 'NORTHAMER';
            insert a;
            
            // CREATE TEST PRODUCT GROUP RECORD
            Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
            insert pgp;
            
             // CREATE TEST DI INDEX RECORD
            NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');
            insert diIdx1;
            
            // CREATE TEST PRODUCT RECORDS 
            Product2 p = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Support');
            p.DI_Index__c = diIdx1.Id;
            insert p;
            
            // add subscription
            List<MTech_SaaS_Subscription__c> subscriptions = new List<MTech_SaaS_Subscription__c>{};
                MTech_SaaS_Subscription__c s = new MTech_SaaS_Subscription__c(
                    product__c = p.ID,
                    account__c = a.ID,
                    quantity__c = 1,
                    unit_price__c = 2.22,
                    price_expiration_date__c = Date.newInstance(2015, 1, 1 ));        
            subscriptions.add(s);
            insert subscriptions;
            
            // add subscription log entry
            List<MTech_SaaS_Log__c> log = new List<MTech_SaaS_Log__c>{};
                MTech_SaaS_Log__c l = new MTech_SaaS_log__c(
                    MTech_saas_subscription__c = s.ID,
                    account__c = a.ID,
                    reason__c = 'Subscription Added',
                    Net_ABR_Change__c = 0);        
            log.add(l);
            insert log;
            test.startTest();
            
            // attempt to delete subscription
            try {
                delete log;
            } catch(DmlException e) {
                System.debug('Delete operation failed as expected: ' + e.getMessage());
            }
            test.stopTest();
            
        }       
        
        static testMethod void NoLogEdit_trigger_test(){
            
            // add account
            //List<Account> accounts = new List<Account>{};
            //    Account a = new Account(Name = 'Test Account',Region__c = 'NORTHAMER');
            //accounts.add(a);
            //insert accounts;
            
            // add product
            //List<Product2> products = new List<Product2>{};
            //    Product2 p = new Product2(Name = 'Test Product');
            //products.add(p);
            //insert products;
            
            // CREATE TEST ACCOUNT RECORD 
            Account a = NI_TestClassData.createTestAccount(1);
            a.Name = 'APEX TESTER ACCOUNT';
            a.Region__c = 'NORTHAMER';
            insert a;
            
            // CREATE TEST PRODUCT GROUP RECORD
            Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
            insert pgp;
            
             // CREATE TEST DI INDEX RECORD
            NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');
            insert diIdx1;
            
            // CREATE TEST PRODUCT RECORDS 
            Product2 p = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Support');
            p.DI_Index__c = diIdx1.Id;
            insert p;
            
            // add subscription
            List<MTech_SaaS_Subscription__c> subscriptions = new List<MTech_SaaS_Subscription__c>{};
                MTech_SaaS_Subscription__c s = new MTech_SaaS_Subscription__c(
                    product__c = p.ID,
                    account__c = a.ID,
                    quantity__c = 1,
                    unit_price__c = 2.22,
                    price_expiration_date__c = Date.newInstance(2015, 1, 1 ));        
            subscriptions.add(s);
            insert subscriptions;
            
            // add subscription log entry
            //List<MTech_SaaS_Log__c> log = new List<MTech_SaaS_Log__c>{};
                MTech_SaaS_Log__c l = new MTech_SaaS_log__c(
                    MTech_saas_subscription__c = s.ID,
                    account__c = a.ID,
                    reason__c = 'Subscription Added',
                    Net_ABR_Change__c = 0);        
            //log.add(l);
            //insert log;
            insert l;
            test.startTest();
            
            // attempt to edit Log
            try {
                l.reason__c = 'New Account';
                update l;
            } catch(DmlException e) {
                System.debug('Update operation failed as expected: ' + e.getMessage());
            }
            test.stopTest();
            
        }
        
        static testMethod void LogChange_trigger_test(){
            
            // add account
            //List<Account> accounts = new List<Account>{};
            //    Account a = new Account(Name = 'Test Account',Region__c = 'NORTHAMER');
            //accounts.add(a);
            //insert accounts;
            
            // add product
            //List<Product2> products = new List<Product2>{};
            //    Product2 p = new Product2(Name = 'Test Product');
            //products.add(p);
            //insert products;
            
            // CREATE TEST ACCOUNT RECORD 
            Account a = NI_TestClassData.createTestAccount(1);
            a.Name = 'APEX TESTER ACCOUNT';
            a.Region__c = 'NORTHAMER';
            insert a;
            
            // CREATE TEST PRODUCT GROUP RECORD
            Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
            insert pgp;
            
             // CREATE TEST DI INDEX RECORD
            NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');
            insert diIdx1;
            
            // CREATE TEST PRODUCT RECORDS 
            Product2 p = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Support');
            p.DI_Index__c = diIdx1.Id;
            insert p;
            
            // add subscription
            List<MTech_SaaS_Subscription__c> subscriptions = new List<MTech_SaaS_Subscription__c>{};
                MTech_SaaS_Subscription__c s = new MTech_SaaS_Subscription__c(
                    product__c = p.ID,
                    account__c = a.ID,
                    quantity__c = 111,
                    unit_price__c = 2.22,
                    price_expiration_date__c = Date.newInstance(2015, 1, 1 ));        
            subscriptions.add(s);
            insert subscriptions;
            
            test.startTest();
            // validate added subscription was logged
            List<MTech_SaaS_Log__c> l = 
                [SELECT new_qty__c FROM MTech_SaaS_Log__c WHERE New_Price__c = 2.22];
            if (l.isEmpty()){
                System.debug('Test failed: added subscription was not logged');
            }
            else{
                System.debug('Test passed: added subscription was logged as expected');        
            }
            test.stopTest();
            
        }
        
    }