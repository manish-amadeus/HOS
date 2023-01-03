/****************************************************************************************
Name            : NI_Customer_Agreement_TriggerHandlerTest Test Class
Author          : Stuart Emery
Created Date    : 10/18/2015
Last Mod Date   : 1/31/2016
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : test Class for NI_Customer_Agreement_TriggerHandler Class
                : 
                : 
******************************************************************************************/
@isTest 
private class NI_Customer_Agreement_TriggerHandlerTest 
{
    
    
    // ======================================================================================================================================= //
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        test.startTest();  
        system.debug(' *** NI_Customer_Agreement_TriggerHandlerTest.createTestData() - START ***'); 
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtLargeDealId = OpportunityRecordTypeInfo.get('Large Deal Opportunity').getRecordTypeId();
        Id rtSalesOrderId = OpportunityRecordTypeInfo.get('Sales Order').getRecordTypeId(); 
        
        // CREATE A TEST USER WITH THE NI ADMINISTRATOR PROFILE TO USE AS THE RUNAS USER
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        u.FirstName = 'Apex';
        u.LastName = 'Testuser';
        insert u;    
        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TESTER ACCOUNT'; 
        insert a;
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c; 
        
        // CREATE TEST PRODUCT GROUP RECORD
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;        
        
        // CREATE TEST PRODUCT RECORDS 
        List<Product2> lstProds = new List<Product2>();
        
        Product2 p2_2 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Services');
        lstProds.add(p2_2);
        
        Database.Insert(lstProds);        
        
        // CREATE TEST PRICEBOOK ENTRY RECORDS
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        
        Id pbkId = Test.getStandardPricebookId(); 
        
        PricebookEntry pbe2 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_2.Id, 1000);
        lstPBEs.add(pbe2);          
        
        Database.Insert(lstPBEs);   
        
        // CREATE TEST OPPORTUNITY RECORDS
        List<Opportunity> lstOpptys = new List<Opportunity>();
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.RecordTypeId = rtLargeDealId; 
        opp1.Name = 'APEX TEST - LARGE DEAL OPPORTUNITY 1';
        lstOpptys.add(opp1);
        
        Database.Insert(lstOpptys);
        
        Opportunity opp2 = [SELECT Id, Opportunity_Number__c, AccountId 
                           FROM Opportunity];
        
        // CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS ==================================================================================
        List<OpportunityContactRole> lstOppContcRole = new List<OpportunityContactRole>();
        
        // Bill To contact
        OpportunityContactRole ocr1 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr1);
        // Ship To contact
        OpportunityContactRole ocr2 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Ship To');
        lstOppContcRole.add(ocr2);         
        // Customer Project Contact 
        OpportunityContactRole ocr3 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr3);        
        // Decision Maker Contact 
        OpportunityContactRole ocr4 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Decision Maker');
        lstOppContcRole.add(ocr4);        
        
        Database.Insert(lstOppContcRole); 
        
        // CREATE TEST OPPORTUNITY LINE ITEM RECORDS  ===================================================================================== 
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        
        // Subscription Product
        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe2.Id, 1);
        oli01.TotalPrice = 1200;
        lstOLIs.add(oli01);
        
        Database.Insert(lstOLIs);
        
        OpportunityLineItem oli02 = [SELECT Id, PricebookEntry.Product2Id
                                     FROM OpportunityLineItem];
        
        //CREATE A TEST VENDOR AGREEMENT RECORD
        NI_Vendor_Agreement__c va  = NI_TestClassData.createTestVendorAgreement(1);
        va.Royalty_Distribution_Trigger__c = 'Installed';
        insert va;
        
        p2_2.Vendor_Agreement_Rule__c = va.Id;
        update p2_2;
        
        //CREATE A TEST CUSTOM VENDOR AGREEMENT RECORD
        NI_Vendor_Agreement__c cva  = NI_TestClassData.createTestVendorAgreement(2);
        cva.Vendor_Agreement__c = va.Id;
        cva.Franchisor__c = 'Apex Text';
        insert cva;
        
        //CREATE A TEST CUSTOMER AGREEMENT RECORD
        NI_Customer_Agreement__c ca  = NI_TestClassData.createTestCustomerAgreement(opp1.Id,p2_2.Id,a.Id,va.Id);
        ca.Royalty_Distribution_Trigger__c = 'Installed';
        ca.Discount__c = 20;
        insert ca;
        
         //CREATE A TEST NI INVOICE RECORD
        NI_Invoice__c inv  = NI_TestClassData.createTestNI_Invoice(opp2.Opportunity_Number__c,opp2.AccountId,1);
        inv.Invoice_Number__c = 1;
        insert inv;
        
        NI_Invoice__c inv2 = [SELECT Id, Opportunity__c
                              FROM NI_Invoice__c];
        
        System.debug('TEST INVOICE OPPORTUNITY ID: ' + inv2.Opportunity__c);
        
        //CREATE A TEST NI INVOICE DETAIL RECORD
        NI_Invoice_Detail__c invDet  = NI_TestClassData.createTestNI_InvoiceDetail(inv.Id,oli02.PricebookEntry.Product2Id);
        insert invDet;
        
        System.debug('INSERTED CUSTOMER AGREEMENT ID: ' + ca.Id);
        System.debug('Royalty_Distribution_Trigger__c: ' + ca.Royalty_Distribution_Trigger__c);
        System.debug('Install_Date__c: ' + ca.Install_Date__c);
        System.debug('Amortization_Term__c: ' + ca.Amortization_Term__c);
        System.debug('Royalty_Percentage__c: ' + ca.Royalty_Percentage__c);
        System.debug('Royalty_Base_Amount__c: ' + ca.Royalty_Base_Amount__c);
        System.debug('Sale_Price__c: ' + ca.Sale_Price__c);
        
        
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: NI_Customer_Agreement_TriggerHandlerTest.createTestData');  
        system.debug(' *** NI_Customer_Agreement_TriggerHandlerTest.createTestData() - END ***'); 
        test.stopTest();  
        
    }
    
    
    // ======================================================================================================================================= //
    // = TEST METHOD 1: 
    // ======================================================================================================================================= //
    @isTest static void CustAgreementTrigTest1() 
    {    
        
        //test.startTest();  
        system.debug(' *** NI_Customer_Agreement_TriggerHandlerTest.CustAgreementTrigTest1() - START ***'); 
        
        
        NI_Customer_Agreement__c c = [SELECT Id, Install_Date__c, Amortization_Term__c, Royalty_Percentage__c, Royalty_Base_Amount__c, Sale_Price__c,
                                      Royalty_Distribution_Trigger__c, Status__c
                                      FROM NI_Customer_Agreement__c 
                                     ];
        
        
        System.debug('QUERIED CUSTOMER AGREEMENT ID: ' + c.Id);
        System.debug('Royalty_Distribution_Trigger__c: ' + c.Royalty_Distribution_Trigger__c);
        System.debug('Install_Date__c: ' + c.Install_Date__c);
        System.debug('Amortization_Term__c: ' + c.Amortization_Term__c);
        System.debug('Royalty_Percentage__c: ' + c.Royalty_Percentage__c);
        System.debug('Royalty_Base_Amount__c: ' + c.Royalty_Base_Amount__c);
        System.debug('Sale_Price__c: ' + c.Sale_Price__c);
        
        //=====================================================================================================================================================        
        //SET THE INSTALL DATE TO INVOKE THE METHOD TO CREATE DISTRIBUTION RECORDS
        c.Install_Date__c = date.today();
        update c;
        
        System.debug('CUSTOMER AGREEMENT STATUS: ' + c.Status__c);
        
        Decimal dAmount = (c.Royalty_Base_Amount__c + (c.Sale_Price__c - c.Royalty_Base_Amount__c) * (c.Royalty_Percentage__c * .01))/c.Amortization_Term__c ; 
        
        //VERIFY THAT THE AMORTIZATION DISTRIBUTION RECORDS WERE SUCCESSFULLY CREATED WITH THE CORRECT AMOUNT
        List<NI_Distribution__c> lstAmortizationDistributions = [SELECT Id, Amount__c, Distribution_Date__c 
                                                                 FROM NI_Distribution__c 
                                                                 WHERE RecordType.Name = 'Amortization' 
                                                                 AND Amount__c =: dAmount];
        
        for(NI_Distribution__c d : lstAmortizationDistributions)
        {
            System.debug('TEST: INITIAL INSTALL DATE AMORTIZATION DISTRIBUTION AMOUNT: ' + d.Amount__c); 
        }
        
        System.assertEquals(12, lstAmortizationDistributions.size());
        
        
        //VERIFY THAT THE ROYALTY DISTRIBUTION RECORDS WERE SUCCESSFULLY CREATED
        List<NI_Distribution__c> lstRoyaltyDistributions = [SELECT Id, Amount__c, Distribution_Date__c 
                                                            FROM NI_Distribution__c 
                                                            WHERE RecordType.Name = 'Royalty'];
        
        System.assertEquals(1, lstRoyaltyDistributions.size());
 
 //=======================================================================================================================================================       
        //CHANGE THE INSTALL DATE TO A DIFFERENT DATE TO INVOKE THE LOGIC FOR INSTALL DATE CHANGES
        NI_TriggerManager.isFirstTimeCustAgreement = true; //Set the value to true so the trigger logic fires
        c.Install_Date__c = date.today().addMonths(-1);
        c.Status__c = 'Active'; //The Status needs to be "Active" in order for the triggers to fire
        update c;
        
        Date startDate = date.today().addMonths(-1);
        
        //VERIFY THAT NEW DISTRIBUTION RECORDS WERE SUCCESSFULLY CREATED AFTER UPDATING THE INSTALL DATE ON THE CUSTOMER AGREEMENT
        List<NI_Distribution__c> lstNewAmortizationDistributions = [SELECT Id, Amount__c, Distribution_Date__c 
                                                                    FROM NI_Distribution__c 
                                                                    WHERE RecordType.Name = 'Amortization'
                                                                    //AND Distribution_Date__c >=: startDate
                                                                    //AND Amount__c =: dAmount
                                                                   ];
        
        System.Debug('TEST INSTALL DATE CHANGE PREV MONTH NUM AMORTIZATION RECORDS CREATED: ' + lstNewAmortizationDistributions.size());
        System.assertEquals(11, lstNewAmortizationDistributions.size());
        
        //VERIFY THAT THE ROYALTY DISTRIBUTION RECORDS WERE SUCCESSFULLY CREATED
        List<NI_Distribution__c> lstNewRoyaltyDistributions = [SELECT Id, Amount__c, Distribution_Date__c 
                                                               FROM NI_Distribution__c 
                                                               WHERE RecordType.Name = 'Royalty'
                                                               AND Distribution_Date__c >=: startDate];
        
        System.assertEquals(1, lstNewRoyaltyDistributions.size());
        
        //=======================================================================================================================================================       
        //CHANGE THE INSTALL DATE TO A DIFFERENT DATE TO INVOKE THE LOGIC FOR INSTALL DATE CHANGES
        NI_TriggerManager.isFirstTimeCustAgreement = true; //Set the value to true so the trigger logic fires
        c.Install_Date__c = date.today().addMonths(1);
        c.Status__c = 'Active'; //The Status needs to be "Active" in order for the triggers to fire
        update c;
        
        Date dToday = date.today();
        
        //VERIFY THAT NEW DISTRIBUTION RECORDS WERE SUCCESSFULLY CREATED AFTER UPDATING THE INSTALL DATE ON THE CUSTOMER AGREEMENT
        List<NI_Distribution__c> lstNewAmortizationDistributions2 = [SELECT Id, Amount__c, Distribution_Date__c 
                                                                    FROM NI_Distribution__c 
                                                                    WHERE RecordType.Name = 'Amortization'
                                                                    AND Distribution_Date__c >: dToday
                                                                    AND Amount__c =: dAmount];
        
        System.Debug('TEST INSTALL DATE CHANGE NEXT MONTH NUM AMORTIZATION RECORDS CREATED: ' + lstNewAmortizationDistributions2.size());
        System.assertEquals(12, lstNewAmortizationDistributions2.size());
        
        
        
        for(NI_Distribution__c d2 : lstNewAmortizationDistributions2)
        {
            System.debug('TEST TEST INSTALL DATE CHANGE NEXT MONTH NEW AMORTIZATION DISTRIBUTION DATE: ' + d2.Distribution_Date__c); 
        }
        
        //VERIFY THAT THE ROYALTY DISTRIBUTION RECORDS WERE SUCCESSFULLY CREATED
        List<NI_Distribution__c> lstNewRoyaltyDistributions2 = [SELECT Id, Amount__c, Distribution_Date__c 
                                                               FROM NI_Distribution__c 
                                                               WHERE RecordType.Name = 'Royalty'
                                                               AND Distribution_Date__c >: dToday];
        
        System.assertEquals(1, lstNewRoyaltyDistributions2.size());
        
        //========================================================================================================================================================
        
        List<NI_Distribution__c> lstNewDistributions = [SELECT Id, Amount__c, Distribution_Date__c, RecordType.Name 
                                                        FROM NI_Distribution__c ];
        
        List<NI_Distribution__c> lstDistributionsToUpdate = new List<NI_Distribution__c>();
        
        for(NI_Distribution__c d : lstNewDistributions)
        {
            if(d.Distribution_Date__c == date.today().addMonths(12))
            {
                d.Distribution_Date__c = date.today().addMonths(-1);
                d.Status__c = 'Closed';  
                System.debug('TEST DISTRIBUTION DATE: ' + d.Distribution_Date__c);  
                lstDistributionsToUpdate.add(d);  
            }
            if(d.RecordType.Name == 'Royalty')
            {
                d.Distribution_Date__c = date.today().addMonths(-1);
                d.Status__c = 'Closed';  
                System.debug('DISTRIBUTION DATE: ' + d.Distribution_Date__c);  
                lstDistributionsToUpdate.add(d);  
            }
        }
        System.debug('NUMBER OF DISTRIBTION RECORDS TO UPDATE: ' + lstDistributionsToUpdate.size());
        Database.Update(lstDistributionsToUpdate);
        
        //CHANGE THE INSTALL DATE TO INVOKE THE METHOD TO CREATE DISTRIBUTION RECORDS
        NI_TriggerManager.isFirstTimeCustAgreement = true; //Set the value to true so the trigger logic fires
        c.Install_Date__c = date.today();
        update c;
        
        //VERIFY THAT THE DISTRIBUTION RECORDS WERE SUCCESSFULLY CREATED WITH THE CORRECT AMOUNT
        List<NI_Distribution__c> lstDistributions2 = [SELECT Id, Amount__c, Status__c, Distribution_Date__c FROM NI_Distribution__c];
        //System.assertEquals(12, lstDistributions2.size());
        for(NI_Distribution__c dist : lstDistributions2)
        {
            System.debug('TEST DISTRIBUTION DATE: ' + dist.Distribution_Date__c + ',' + 'DISTRIBUTION AMOUNT: ' + dist.Amount__C + 'DISTRIBUTION STATUS: ' + dist.Status__c);   
        }
        
        //NUMBER OF CLOSED AMORTIZATION DISTRIBUTION RECORDS
        List<NI_Distribution__c> lstClosedAmortizationDistributions = [SELECT Id, Amount__c, Status__c, Distribution_Date__c 
                                                                 FROM NI_Distribution__c 
                                                                 WHERE RecordType.Name = 'Amortization' 
                                                                 AND Amount__c =: dAmount
                                                                 AND Status__c = 'Closed'];
        
         System.debug('TEST NUMBER OF CLOSED AMORTIZATION RECORDS: ' + lstClosedAmortizationDistributions.size());        
        
        //========================================================================================================================================================        
        //CHANGE THE INSTALL DATE TO NULL TO INVOKE THE NULL INSTALL DATE LOGIC
        NI_TriggerManager.isFirstTimeCustAgreement = true; //Set the value to true so the trigger logic fires
        c.Install_Date__c = null;
        c.Status__c = 'Active'; //The Status needs to be "Active" in order for the triggers to fire
        update c;
        
        
        //VERIFY THAT THERE IS 1 AMORTIZATION DISTRIBUTION RECORD
        List<NI_Distribution__c> lstNullDistributions = [SELECT Id, Amount__c, Distribution_Date__c 
                                                         FROM NI_Distribution__c 
                                                         WHERE RecordType.Name = 'Amortization' 
                                                         AND Amount__c =: dAmount];
        
        System.Debug('TEST INSTALL DATE CHANGE TO NULL NUM AMORTIZATION RECORDS CREATED: ' + lstNullDistributions.size());
        //System.assertEquals(1, lstNullDistributions.size());
        
        //VERIFY THAT THERE ARE 2 ROYALTY DISTRIBUTION RECORDS
        List<NI_Distribution__c> lstNullRoyaltyDistributions = [SELECT Id, Amount__c, Distribution_Date__c 
                                                                FROM NI_Distribution__c 
                                                                WHERE RecordType.Name = 'Royalty'];
        
        System.assertEquals(2, lstNullRoyaltyDistributions.size());
    }     
    //========================================================================================================================================================
    
    // ======================================================================================================================================= //
    // = TEST METHOD 2: 
    // ======================================================================================================================================= //
    @isTest static void CustAgreementTrigTest2() 
    {    
        
        test.startTest();  
        system.debug(' *** NI_Customer_Agreement_TriggerHandlerTest.CustAgreementTrigTest2 - START ***'); 
        
        
        NI_Customer_Agreement__c c = [SELECT Id, Install_Date__c, Amortization_Term__c, Royalty_Percentage__c, Royalty_Base_Amount__c, Sale_Price__c,
                                      Royalty_Distribution_Trigger__c, Status__c
                                      FROM NI_Customer_Agreement__c 
                                     ];
        
        
        System.debug('QUERIED CUSTOMER AGREEMENT ID: ' + c.Id);
        System.debug('Royalty_Distribution_Trigger__c: ' + c.Royalty_Distribution_Trigger__c);
        System.debug('Install_Date__c: ' + c.Install_Date__c);
        System.debug('Amortization_Term__c: ' + c.Amortization_Term__c);
        System.debug('Royalty_Percentage__c: ' + c.Royalty_Percentage__c);
        System.debug('Royalty_Base_Amount__c: ' + c.Royalty_Base_Amount__c);
        System.debug('Sale_Price__c: ' + c.Sale_Price__c);
        
        //=====================================================================================================================================================        
        //SET THE INSTALL DATE TO INVOKE THE METHOD TO CREATE DISTRIBUTION RECORDS
        c.Royalty_Distribution_Trigger__c = 'Receipt of Payment';
        c.Status__c = 'Active';
        update c;
        
        /*
        //BUILD A LIST OF ALL ROYALTY DISTRIBUTION RECORDS TO DELETE
        List<NI_Distribution__c> lstRoyaltyDistributionsToDelete = [SELECT Id 
                                                                 FROM NI_Distribution__c 
                                                                 WHERE RecordType.Name = 'Royalty'];
        
        //DELETE EXISTING ROYALTY DISTRIBUTION RECORDS
        Database.Delete(lstRoyaltyDistributionsToDelete);
        
        //VERIFY THAT THE ROYALTY DISTRIBUTION RECORDS WERE SUCCESSFULLY CREATED
        List<NI_Distribution__c> lstRoyaltyDistributions = [SELECT Id, Amount__c, Distribution_Date__c 
                                                            FROM NI_Distribution__c 
                                                            WHERE RecordType.Name = 'Royalty'];
        
        System.assertEquals(0, lstRoyaltyDistributions.size());
*/

 //========================================================================================================================================       
        //UPDATE THE AMOUNT RECEIVED TO INVOKE THE LOGIC FOR AMOUNT RECEIVED GREATER THAN OR EQUAL TO TOTAL PRICE
        //USED FOR ROYALTY DISTRIBUTION RECORD CREATION
        NI_TriggerManager.isFirstTimeCustAgreement = true; //Set the value to true so the trigger logic fires
        
        NI_Invoice__c inv = [SELECT Id, Opportunity__c, Order_Number__c
                              FROM NI_Invoice__c];
        
        System.debug('INVOICE Id: ' + inv.Id);
        System.debug('INVOICE Order_Number__c: ' + inv.Order_Number__c);
        System.debug('INVOICE Opportunity__c: ' + inv.Opportunity__c);
        
        NI_Invoice_Detail__c invDet = [SELECT Id, NI_Invoice__c, Customer_Agreement__c, Applied_Amount__c
                                              FROM NI_Invoice_Detail__c
                                              WHERE NI_Invoice__c =: inv.Id];
        
        System.debug('INVOICE DETAIL Customer_Agreement__c: ' + invDet.Customer_Agreement__c);
        System.debug('INVOICE DETAIL Applied_Amount__c: ' + invDet.Applied_Amount__c);
        
        
        //TEST THE LOGIC FOR THE Update_CustomerAgrAmountReceived METHOD OF THE NI_Invoice_TriggerHandler
        inv.Paid_Amount__c = 1200;
        inv.Paid_Date__c = date.today();
        update inv;
        
        NI_Customer_Agreement__c c2 = [SELECT Id, Install_Date__c, Amortization_Term__c, Royalty_Percentage__c, Royalty_Base_Amount__c, Sale_Price__c,
                                      Royalty_Distribution_Trigger__c, Status__c, Amount_Received__c
                                      FROM NI_Customer_Agreement__c 
                                     ];

        System.debug('QUERIED CUSTOMER AGREEMENT ID: ' + c2.Id);
        System.debug('Royalty_Distribution_Trigger__c: ' + c2.Royalty_Distribution_Trigger__c);
        System.debug('Install_Date__c: ' + c2.Install_Date__c);
        System.debug('Sale_Price__c: ' + c2.Sale_Price__c);
        System.debug('Amount_Received__c: ' + c2.Amount_Received__c);
        System.debug('Status__c: ' + c2.Status__c);
        
        test.stoptest();
    }
    
// ======================================================================================================================================= //
    // = TEST METHOD 3: 
    // ======================================================================================================================================= //
    @isTest static void CustAgreementTrigTest3() 
    {    
        
        test.startTest();  
        system.debug(' *** NI_Customer_Agreement_TriggerHandlerTest.CustAgreementTrigTest3 - START ***'); 
        
        
        NI_Customer_Agreement__c c = [SELECT Id, Install_Date__c, Amortization_Term__c, Royalty_Percentage__c, Royalty_Base_Amount__c, Sale_Price__c,
                                      Royalty_Distribution_Trigger__c, Status__c
                                      FROM NI_Customer_Agreement__c 
                                     ];
        
        
        System.debug('QUERIED CUSTOMER AGREEMENT ID: ' + c.Id);
        System.debug('Royalty_Distribution_Trigger__c: ' + c.Royalty_Distribution_Trigger__c);
        System.debug('Install_Date__c: ' + c.Install_Date__c);
        System.debug('Amortization_Term__c: ' + c.Amortization_Term__c);
        System.debug('Royalty_Percentage__c: ' + c.Royalty_Percentage__c);
        System.debug('Royalty_Base_Amount__c: ' + c.Royalty_Base_Amount__c);
        System.debug('Sale_Price__c: ' + c.Sale_Price__c);
        
        //=====================================================================================================================================================        
        //SET THE INSTALL DATE TO INVOKE THE METHOD TO CREATE DISTRIBUTION RECORDS
        c.Royalty_Distribution_Trigger__c = 'Installed OR Receipt of Payment';
        c.Install_Date__c = date.Today();
        c.Status__c = 'Active';
        update c;
     
 //========================================================================================================================================       
        //UPDATE THE AMOUNT RECEIVED TO INVOKE THE LOGIC FOR AMOUNT RECEIVED GREATER THAN OR EQUAL TO TOTAL PRICE
        //USED FOR ROYALTY DISTRIBUTION RECORD CREATION
        NI_TriggerManager.isFirstTimeCustAgreement = true; //Set the value to true so the trigger logic fires
        
        NI_Invoice__c inv = [SELECT Id, Opportunity__c, Order_Number__c
                              FROM NI_Invoice__c];
        
        System.debug('INVOICE Id: ' + inv.Id);
        System.debug('INVOICE Order_Number__c: ' + inv.Order_Number__c);
        System.debug('INVOICE Opportunity__c: ' + inv.Opportunity__c);
        
        NI_Invoice_Detail__c invDet = [SELECT Id, NI_Invoice__c, Customer_Agreement__c, Applied_Amount__c
                                              FROM NI_Invoice_Detail__c
                                              WHERE NI_Invoice__c =: inv.Id];
        
        System.debug('INVOICE DETAIL Customer_Agreement__c: ' + invDet.Customer_Agreement__c);
        System.debug('INVOICE DETAIL Applied_Amount__c: ' + invDet.Applied_Amount__c);
        
        
        //TEST THE LOGIC FOR THE Update_CustomerAgrAmountReceived METHOD OF THE NI_Invoice_TriggerHandler
        inv.Paid_Amount__c = 1201;
        inv.Paid_Date__c = date.today();
        update inv;
        
        NI_Customer_Agreement__c c2 = [SELECT Id, Install_Date__c, Amortization_Term__c, Royalty_Percentage__c, Royalty_Base_Amount__c, Sale_Price__c,
                                      Royalty_Distribution_Trigger__c, Status__c, Amount_Received__c
                                      FROM NI_Customer_Agreement__c 
                                     ];

        System.debug('QUERIED CUSTOMER AGREEMENT ID: ' + c2.Id);
        System.debug('Royalty_Distribution_Trigger__c: ' + c2.Royalty_Distribution_Trigger__c);
        System.debug('Install_Date__c: ' + c2.Install_Date__c);
        System.debug('Sale_Price__c: ' + c2.Sale_Price__c);
        System.debug('Amount_Received__c: ' + c2.Amount_Received__c);
        System.debug('Status__c: ' + c2.Status__c);
        
        test.stoptest();
    }
    
// ======================================================================================================================================= //
    // = TEST METHOD 4: 
    // ======================================================================================================================================= //
    @isTest static void CustAgreementTrigTest4() 
    {    
        
        test.startTest();  
        system.debug(' *** NI_Customer_Agreement_TriggerHandlerTest.CustAgreementTrigTest4 - START ***'); 
        
        
        NI_Customer_Agreement__c c = [SELECT Id, Install_Date__c, Amortization_Term__c, Royalty_Percentage__c, Royalty_Base_Amount__c, Sale_Price__c,
                                      Royalty_Distribution_Trigger__c, Status__c
                                      FROM NI_Customer_Agreement__c 
                                     ];
               
        //=====================================================================================================================================================        
        //SET THE INSTALL DATE TO INVOKE THE METHOD TO CREATE DISTRIBUTION RECORDS
        NI_TriggerManager.isFirstTimeCustAgreement = true; //Set the value to true so the trigger logic fires
        //c.Royalty_Distribution_Trigger__c = 'Installed OR Receipt of Payment';
        //c.Install_Date__c = date.Today();
        c.Install_Date__c = date.Today();
        c.Product_Family__c = 'Services';
        update c;
        
        c.Status__c = 'Renewal';
        update c;
        
        NI_Customer_Agreement__c c2 = [SELECT Id, Install_Date__c, Amortization_Term__c, Royalty_Percentage__c, Royalty_Base_Amount__c, Sale_Price__c,
                                      Royalty_Distribution_Trigger__c, Status__c, Product_Family__c
                                      FROM NI_Customer_Agreement__c 
                                     ];
        
        System.debug('CUSTOMER AGREEMENT STATUS: ' + c2.Status__c);
        System.debug('CUSTOMER AGREEMENT PRODUCCT FAMILY: ' + c2.Product_Family__c);
     
        Opportunity opp2 = [SELECT Id, Opportunity_Number__c, AccountId 
                           FROM Opportunity];
        
        OpportunityLineItem oli02 = [SELECT Id, PricebookEntry.Product2Id
                                     FROM OpportunityLineItem];
        
        NI_Invoice__c inv = [SELECT Id, Opportunity__c, Paid_Amount__c, Paid_Date__c
                              FROM NI_Invoice__c];
        
        //CREATE A TEST NI INVOICE DETAIL RECORD TO INVOKE THE "Create_Amortization_Distribution_Records" METHOD IN THE 
        //NI_Invoice_Detail_TriggerHandler CLASS
        NI_TriggerManager.isFirstTimeCustAgreement = true; //Set the value to true so the trigger logic fires
        NI_Invoice_Detail__c invDet  = NI_TestClassData.createTestNI_InvoiceDetail(inv.Id,oli02.PricebookEntry.Product2Id);
        invDet.Billing_Start_Date__c = date.Today();
        insert invDet;
        
        NI_TriggerManager.isFirstTimeCustAgreement = true; //Set the value to true so the trigger logic fires
        c2.Cancellation_Date__c = date.Today();
        update c2;
         
        test.stoptest();
    }
    
// ======================================================================================================================================= //
    // = TEST METHOD 5: CANCELLATIONS - LOGIC FOR UPDATING THE CANCELLATION DATE FIELD FROM A NULL TO A NON-NULL VALUE.
    // ======================================================================================================================================= //
    @isTest static void CustAgreementTrigTest5()    {    
  
        test.startTest();  
        system.debug(' *** NI_Customer_Agreement_TriggerHandlerTest.CustAgreementTrigTest5 - START ***'); 
        
        
        NI_Customer_Agreement__c c = [SELECT Id, Install_Date__c, Amortization_Term__c, Royalty_Percentage__c, Royalty_Base_Amount__c, Sale_Price__c,
                                      Royalty_Distribution_Trigger__c, Status__c, Cancellation_Date__c
                                      FROM NI_Customer_Agreement__c 
                                     ];
        
        
        System.debug('QUERIED CUSTOMER AGREEMENT ID: ' + c.Id);
        System.debug('Sale_Price__c: ' + c.Cancellation_Date__c);
        System.debug('Royalty_Distribution_Trigger__c: ' + c.Royalty_Distribution_Trigger__c);
        System.debug('Install_Date__c: ' + c.Install_Date__c);
        System.debug('Amortization_Term__c: ' + c.Amortization_Term__c);
        System.debug('Royalty_Percentage__c: ' + c.Royalty_Percentage__c);
        System.debug('Royalty_Base_Amount__c: ' + c.Royalty_Base_Amount__c);
        System.debug('Sale_Price__c: ' + c.Sale_Price__c);
        
        //LIST OF ALL ROYALTY DISTRIBUTION RECORDS
        List<NI_Distribution__c> lstRoyaltyDistributions = [SELECT Id 
                                                                 FROM NI_Distribution__c 
                                                                 WHERE RecordType.Name = 'Royalty'];
        
        System.debug('NUMBER OF ROYALTY DISTRIBTUTION RECORDS: ' + lstRoyaltyDistributions.size());
        
        //LIST OF ALL AMORTIZATION DISTRIBUTION RECORDS
        List<NI_Distribution__c> lstAmortizationDistributions = [SELECT Id 
                                                                 FROM NI_Distribution__c 
                                                                 WHERE RecordType.Name = 'Amortization'];
        
        System.debug('NUMBER OF AMORTIZATION DISTRIBTUTION RECORDS: ' + lstAmortizationDistributions.size());
        
//=====================================================================================================================================================        
       
        //SET THE CANCELLATION DATE TO INVOKE THE NI_Customer_Agreement_TriggerHandler.Amortization_Distribution_Cancellations 
        //AND NI_Customer_Agreement_TriggerHandler.Royalty_Distribution_Cancellations METHODS
        c.Cancellation_Date__c = date.Today();
        update c;
               
        test.stoptest();
    }
}