/**************************************************************************************
// Name          : ffaUtilities_TEST
// Date          : 1/15.16
// Description   : Unit Test class for all the ffa utilities
// Author        : CLD Partners
***************************************************************************************/

@isTest
public class ffaExchangeRateHandler_TEST {
	
	public static c2g__codaCompany__c testCompany1;
	public static c2g__codaAccountingCurrency__c otherCurrency1;


	private static void setupTestData(String homeCurrIso)
	{
		testCompany1 = ffaTestUtilities.createFFACompany('MY TEST COMPANY', true, homeCurrIso);
		testCompany1.Exchange_Rate_Effective_Date__c = Date.today();
		update testCompany1;
		otherCurrency1 = ffaTestUtilities.createFFACurrency('EUR', false, false);
	}

	@isTest static void testExchangeRateController_USD ()
	{
		setupTestData('USD');
		Test.startTest();
			ffaExchangeRateSyncController testController = new ffaExchangeRateSyncController();
			testController.syncFFARates();
			testController.saveRates();
            testController.backToHome();
		Test.stopTest();
	}
	@isTest static void testExchangeRateController_GBP ()
	{
		setupTestData('GBP');
		Test.startTest();
			ffaExchangeRateSyncController testController = new ffaExchangeRateSyncController();
			testController.syncFFARates();
			testController.saveRates();
         testController.backToHome();
		Test.stopTest();
	}
}