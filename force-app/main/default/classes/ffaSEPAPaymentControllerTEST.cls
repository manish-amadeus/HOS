/*******************************************************************************************
Name            : ffaSEPAPaymentControllerTEST
Author          : CLD Partners
Created Date    : Feb 11, 2016
Description     : Provides tests for SEPA Payment Controller
*******************************************************************************************/

@isTest(seealldata = true)
public class ffaSEPAPaymentControllerTEST {
	public static c2g__codaPayment__c testPayment;

	private static void setupTestData()
	{
		testPayment = [SELECT Id FROM c2g__codaPayment__c WHERE c2g__Status__c = 'Matched' LIMIT 1];
	}
	@isTest static void testSEPAPayment()
	{
		setupTestData();
		ApexPages.StandardController sc = new ApexPages.StandardController(testPayment);
		ffaSEPAPaymentController sepaController = new ffaSEPAPaymentController(sc);
	}

}