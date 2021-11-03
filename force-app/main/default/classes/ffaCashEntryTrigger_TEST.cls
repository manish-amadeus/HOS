/*******************************************************************************************
Name            : ffaCashEntryTrigger_TEST
Author          : CLD Partners
Created Date    : Feb 11, 2016
Description     : Provides tests for Cash Entry Trigger Handler
*******************************************************************************************/

@isTest(seealldata = true)
public class ffaCashEntryTrigger_TEST {
    public static c2g__codaCompany__c testCompany1;
    public static c2g__codaCompany__c testCompany2;
    public static Account testAccount;
    public static c2g__codaJournal__c testJournal;
    public static c2g__codaGeneralLedgerAccount__c testGLA;
    public static c2g__codaBankAccount__c testBankAccount;
    public static c2g__codaCashEntry__c testCashEntry;
    public static c2g__codaDimension2__c testDimension2;
    public static c2g__codaDimension3__c testDimension3;
    
    private static void setupTestData()
    {
        try
        {
            testGLA = ffaTestUtilities.create_IS_GLA();
            //query the US company:
            testCompany1 = ffaTestUtilities.createFFACompany('TEST COMPANY', true, 'USD');
            //query the UK company:
            //testCompany2 = [SELECT Id,Name FROM c2g__codaCompany__c WHERE Name = 'Newmarket UK'];
            //testBankAccount = [SELECT Id from c2g__codabankaccount__c where c2g__ownerCompany__r.name = 'Newmarket US' limit 1];
            c2g__codaAccountingCurrency__c testcurr = [SELECT id from c2g__codaAccountingCurrency__c where c2g__ownerCompany__c = :testCompany1.id limit 1];
            
            testBankAccount = new c2g__codaBankAccount__c (
                Name = 'Test bank account',
                c2g__reportingcode__c = '10029304930',
                c2g__bankname__c = 'Testing Bank',
                c2g__accountname__c = 'TESTing account',
                c2g__accountnumber__c = '1920384903',
                c2g__GeneralLedgerAccount__c = testGLA.id,
                c2g__ownerCompany__c = testCompany1.id,
                c2g__BankAccountCurrency__c = testcurr.id
            );
            insert testBankAccount;
            
            //set current company to US company
            //ffaTestUtilities.clearCurrentCompany(UserInfo.getUserId());
            //ffaTestUtilities.setCurrentCompany(UserInfo.getUserId(), testCompany1.id);
            
            system.debug('\n\n ***** ffaUtilities_TEST - setupTestData - testCompany1' + testCompany1);
            //system.debug('\n\n ***** ffaUtilities_TEST - setupTestData - testCompany2' + testCompany2);
            
            testAccount = ffaTestUtilities.createAccount('TEST Account', testGLA.id);
            testDimension2 = ffaTestUtilities.createTestDimension2();
            testDimension3 = ffaTestUtilities.createTestDimension3();
        }
        Catch(Exception e){
            System.debug('An unexpected error has occurred: ' + e.getMessage());            
            
        }
    }
    
    @isTest static void testCSHInsert()
    {
        try{
        setupTestData();
        
            testCashEntry = ffaTestUtilities.createCSHreceipt(testAccount, testBankAccount.id, 1000);
        }
        Catch(DMLException e){
            System.debug('An unexpected error has occurred: ' + e.getMessage());            
            
        }
    }
    @isTest static void testCSHTriggerHandlerSync()
    {
        List<c2g__codaCashEntryLineItem__c> testCashEntryLine = [SELECT Id, c2g__CashEntry__c, c2g__AccountDimension2__c, c2g__AccountDimension3__c, 
                                                                 ffcash__DeriveAccountDimensions__c 
                                                                 FROM c2g__codaCashEntryLineItem__c 
                                                                 WHERE c2g__CashEntry__r.c2g__PaymentNumber__c != null Limit 1];
        ffaCashEntryLineItemTriggerHandler.syncCSHandPINDimensions(testCashEntryLine);
    }
    @isTest static void testAnalysisSync()
    {
        List<c2g__codaCashEntryLineItem__c> testCashEntryLine = [SELECT Id, c2g__CashEntry__c, c2g__AccountDimension2__c, c2g__AccountDimension3__c, 
                                                                 ffcash__DeriveAccountDimensions__c 
                                                                 FROM c2g__codaCashEntryLineItem__c 
                                                                 WHERE c2g__CashEntry__r.c2g__PaymentNumber__c != null Limit 1];
        ffaCashEntryLineItemTriggerHandler.syncAnalysisFields(testCashEntryLine);
    }
    @isTest static void testScheduleCash()
    {
        String CRON_EXP = '0 0 * * * ?'; 
        ffaIntercompanyCashEntrySchedule sch = new ffaIntercompanyCashEntrySchedule(); 
        system.schedule('test job', CRON_EXP, sch);
    }
    @isTest static void testIntercoCashBatch()
    {
        try{
            //testCSHInsert();
            setupTestData();
            testCashEntry = ffaTestUtilities.createCSHreceipt(testAccount, testBankAccount.id, 1000);
            List<c2g__codaCashEntryLineItem__c> testCashEntryLine = [SELECT Id, c2g__CashEntry__c, c2g__AccountDimension2__c, c2g__AccountDimension3__c, 
                                                                     ffcash__DeriveAccountDimensions__c 
                                                                     FROM c2g__codaCashEntryLineItem__c 
                                                                     WHERE c2g__CashEntry__c = :testCashEntry.id Limit 1];
            for(c2g__codaCashEntryLineItem__c line : testCashEntryLine){
                line.Destination_Company__c = testCompany1.id;
                line.Reversing_Journal_Created__c = true;
            }
            update testCashEntryLine;
            
            
            c2g.CODAAPICommon_7_0.Context companyWrapper = new c2g.CODAAPICommon_7_0.Context();
            companyWrapper.CompanyName = testCompany1.Name;
            c2g.CODAAPICommon.Reference cashEntryWrapper = new c2g.CODAAPICommon.Reference();
            cashEntryWrapper.id = testCashEntry.id;
            c2g.CODAAPICashEntry_7_0.PostCashEntry(companyWrapper, cashEntryWrapper);
            
            ffaIntercompanyCashEntryBatch batchClass = new ffaIntercompanyCashEntryBatch();
            Id batchID = database.executebatch(batchClass, 1);
        }
        Catch(DMLException e){
            System.debug('An unexpected error has occurred: ' + e.getMessage());            
            
        }
    }
}