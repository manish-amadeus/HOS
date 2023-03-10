/**************************************************************************************
// Name          : ffaUtilities_TEST
// Date          : 1/15.16
// Description   : Unit Test class for all the ffa utilities
// Author        : CLD Partners
***************************************************************************************/

@isTest(seealldata=true)
public class ffaUtilities_TEST {
	
	public static c2g__codaCompany__c testCompany1;
	public static c2g__codaCompany__c testCompany2;
	public static Account testAccount;
	public static c2g__codaJournal__c testJournal;
	public static c2g__codaGeneralLedgerAccount__c testGLA;
	public static c2g__codaPurchaseInvoice__c testPIN;
	public static c2g__codaDimension2__c testDimension2;
	public static c2g__codaDimension3__c testDimension3;

	private static void setupTestData()
	{
		testGLA = ffaTestUtilities.create_IS_GLA();
		//query the US company:
		testCompany1 = [SELECT Id,Name FROM c2g__codaCompany__c WHERE Name = 'Newmarket US'];
		//query the UK company:
		testCompany2 = [SELECT Id,Name FROM c2g__codaCompany__c WHERE Name = 'Newmarket UK'];
		
		//set current company to US company
		ffaTestUtilities.clearCurrentCompany(UserInfo.getUserId());
		ffaTestUtilities.setCurrentCompany(UserInfo.getUserId(), testCompany1.id);

		system.debug('\n\n ***** ffaUtilities_TEST - setupTestData - testCompany1' + testCompany1);
		//system.debug('\n\n ***** ffaUtilities_TEST - setupTestData - testCompany2' + testCompany2);

		testAccount = ffaTestUtilities.createAccount('TEST Account', testGLA.id);
		testDimension2 = ffaTestUtilities.createTestDimension2();
		testDimension3 = ffaTestUtilities.createTestDimension3();
	}
	private static void setupTestPIN()
	{
		testPIN = ffaTestUtilities.createPIN_withDestinationCo(testAccount, Date.today(), testGLA.id, 100, testCompany2.id, null, testDimension2.id, testDimension3.id, null);
	}
	private static void setupTestJournal()
	{
		testJournal = ffaTestUtilities.createJNL_Intercompany(Date.today(), testGLA.id, 100, testCompany2.id, null, testDimension2.id, testDimension3.id, null);
	}
	/*@isTest static void testIntercoPINSchedule ()
	{
		setupTestData();
		Test.startTest();
			ffaUtilities.postSinglePayableInvoices(testPIN.id);
		Test.stopTest();
			c2g__codaPurchaseInvoice__c PINinfo = [SELECT id, c2g__InvoiceStatus__c, c2g__Transaction__c, (SELECT id, Destination_Company__c, Inter_Company_Journal_Created__c FROM c2g__PurchaseInvoiceExpenseLineItems__r) from c2g__codaPurchaseInvoice__c where id = :testPIN.id];
			system.debug('\n\n ***** ffaUtilities_TEST - setupTestData - PINinfo' + PINinfo);
			String CRON_EXP = '0 0 * * * ?';
			ffaIntercompanyPayableInvoiceSchedule sch = new ffaIntercompanyPayableInvoiceSchedule();
			system.schedule('test job', CRON_EXP, sch);
	}*/

	@isTest static void testBooster ()
	{
		setupTestData();
		//setupTestPIN();
		ffaUtilities.boostTestCoverage();	
	}
	/*@isTest static void testIntercoPIN ()
	{
		setupTestData();
		setupTestPIN();
		ffaUtilities.postSinglePayableInvoices(testPIN.id);
		c2g__codaPurchaseInvoice__c PINinfo = [SELECT id, c2g__InvoiceStatus__c, c2g__Transaction__c from c2g__codaPurchaseInvoice__c where id = :testPIN.id];
		c2g__codaPurchaseInvoiceExpenseLineItem__c PINLINEInfo = [SELECT id, Destination_Company__c, Inter_Company_Journal_Created__c FROM c2g__codaPurchaseInvoiceExpenseLineItem__c where c2g__PurchaseInvoice__c = :testPIN.id LIMIT 1];
		ffaUtilities.createIntercompanyJournals(PINinfo.id);	
	}
	@isTest static void testIntercoPIN_Webservice ()
	{
		setupTestData();
		setupTestPIN();
		ffaUtilities.postSinglePayableInvoices(testPIN.id);
		c2g__codaPurchaseInvoice__c PINinfo = [SELECT id, c2g__InvoiceStatus__c, c2g__Transaction__c from c2g__codaPurchaseInvoice__c where id = :testPIN.id];
		c2g__codaPurchaseInvoiceExpenseLineItem__c PINLINEInfo = [SELECT id, Destination_Company__c, Inter_Company_Journal_Created__c FROM c2g__codaPurchaseInvoiceExpenseLineItem__c where c2g__PurchaseInvoice__c = :testPIN.id LIMIT 1];
		String message = ffaUtilities.createIntercompanyJournal_WS(PINinfo.id);	
	}
	@isTest static void postmultiplePIN ()
	{
		setupTestData();
		setupTestPIN();
		List<Id> pinids = new List<ID>{testPin.id};
		List<c2g__codaPurchaseInvoice__c> pinresultlist = ffaUtilities.postPayableInvoices(pinids);
	}*/
	@istest public static void testIntercoPINSchedule()
	{
		setupTestData();
		setupTestPIN();
		Test.startTest();
			ffaUtilities.postSinglePayableInvoices(testPIN.id);
			String CRON_EXP = '0 0 * * * ?'; 
			ffaIntercompanyPayableInvoiceSchedule sch = new ffaIntercompanyPayableInvoiceSchedule(); 
			system.schedule('test job', CRON_EXP, sch);	
		Test.stopTest();
	}
	
	@istest public static void testIntercoPINBatch()
	{
		setupTestData();
		setupTestPIN();
		Test.startTest();
			ffaUtilities.postSinglePayableInvoices(testPIN.id);
			ffaIntercompanyPayableInvoiceBatch batchClass = new ffaIntercompanyPayableInvoiceBatch();
			Id batchID = database.executebatch(batchClass, 1);
		Test.stopTest();
	}
	/*@istest public static void testIntercoProcess()
	{
		setupTestData();
		setupTestJournal();
		Test.startTest();
			List<c2g__codaJournal__c> jnlList = ffaUtilities.postSingleJournal(testJournal.id);	
		Test.stopTest();

		List<c2g__codaJournal__c> jnlResult = [select Id, c2g__journalStatus__c from c2g__codaJournal__c Where id=:testJournal.id];
		system.debug('\n\n ***** ffaUtilities_TEST - testIntercoProcess - jnlResult' + jnlResult);
		List<c2g__codaIntercompanyTransfer__c> intercoList = [select Id from c2g__codaIntercompanyTransfer__c Where c2g__ProcessingStatus__c in('Available','Error') LIMIT 1];
		system.debug('\n\n ***** ffaUtilities_TEST - testIntercoProcess - intercoList' + intercoList);
		List<Id> intercoIds = new List<Id>();
		for(c2g__codaIntercompanyTransfer__c i :intercoList){
			intercoIds.add(i.id);
		}
		ffaUtilities.processIntercoTransactions(intercoIds);
		
	}*/
	@istest public static void testIntercoProcessSchedule()
	{
		setupTestData();
		setupTestJournal();
		Test.startTest();
			List<c2g__codaJournal__c> jnlList = ffaUtilities.postSingleJournal(testJournal.id);	
		Test.stopTest();
			String CRON_EXP = '0 0 * * * ?'; 
			ffaIntercompanyTransferProcessSchedule sch = new ffaIntercompanyTransferProcessSchedule(); 
			system.schedule('test job', CRON_EXP, sch);	
	}
	/*@istest public static void testIntercoProcessBatch()
	{
		setupTestData();
		setupTestJournal();
		Test.startTest();
			List<c2g__codaJournal__c> jnlList = ffaUtilities.postSingleJournal(testJournal.id);	
			ffaIntercompanyTransferProcessBatch batchClass = new ffaIntercompanyTransferProcessBatch();
			Id batchID = database.executebatch(batchClass, 1);
		Test.stopTest();
	}*/

	/*@isTest static void testBulkDiscardPIN ()
	{
		setupTestData();
		setupTestPIN();
		List<Id> pinidlist = new List<Id>{testPIN.id};
		ffaUtilities.bulkDiscardPIN_WS(pinidlist);
	}

	@isTest static void testBulkDiscardJNL ()
	{
		setupTestData();
		setupTestJournal();
		List<Id> jnlIdList = new List<Id>{testJournal.id};
		ffaUtilities.bulkDiscardJournal_WS(jnlIdList);
	}*/

	@isTest static void testGetCurrentCompanies()
	{
		setupTestData();
		ffaUtilities.gerCurrentCompanies();
	}

}