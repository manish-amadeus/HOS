/**************************************************************************************
// Name          : ffaActivityLineItemClone_TEST
// Date          : 3/9/17
// Author        : CLD Partners
***************************************************************************************/

@isTest
public class ffaActivityLineItemClone_TEST {

	public static Account testAccount1;
  	public static Contact testContact1;
  	public static Opportunity testOpp1;
  	public static Product_Group__c testProductGroup_Delphi;
  	public static Product_Group__c testProductGroup_Salesforce;
  	public static Product2 testServiceProduct;
  	public static Payment_Terms__c testPmtTerms_EqualSplit;
  	public static Billing_Contract__c testBC;
  	public static Activity_Line_Item__c testALI;

 	public static void setupTestData(){
 		testAccount1 = ffaTestUtilities.createAccount('Test Account 1', null);
 		testContact1 = ffaTestUtilities.createTestContact('TEST', 'test@test.com');
 		testProductGroup_Salesforce = NI_TestClassData.createProductGroup(1, 'Salesforce');
   	 	insert testProductGroup_Salesforce;
 		List<Product2> productList = new List<Product2>();
    	testServiceProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.id, 'TEST-TST-BK1', 'Services', 'Services',12);
    	testServiceProduct.pse__IsServicesProduct__c = true;
    	update testServiceProduct;
    	testPmtTerms_EqualSplit = ffaTestUtilities.createTestPmtTerms(2, 'test2', 'Activation Date', 'Equal', 1, 'Years', false);
    	testBC = createTestBillingContract();
    	testALI = createTestALI();
 	}

 	@isTest static void testALICloneController(){
 		setupTestData();
 		Test.startTest();
	 		ApexPages.StandardController stdController = new ApexPages.StandardController(testALI);
	 		ffaActivityLineItemCloneController cloneController = new ffaActivityLineItemCloneController(stdController);
	 		cloneController.processClone();
	 		cloneController.backToBC();
      cloneController.goToNewALI();
 		Test.stopTest();
 	}

 	private static Billing_Contract__c createTestBillingContract(){
 		Billing_Contract__c bc = new Billing_Contract__c(
 			Account__c = testAccount1.id,
 			Name = 'BCTEST!');
 		insert bc;
 		return bc;
 	}
 	private static Activity_Line_Item__c createTestALI(){
 		Activity_Line_Item__c ali = new Activity_Line_Item__c(
 			Billing_Contract__c = testBC.id,
 			Product__c = testServiceProduct.id,
 			Payment_Terms__c = testPmtTerms_EqualSplit.id,
 			Units__c = 1,
 			Contract_Amount__c = 1000,
 			Activation_Date__c = Date.today(),
 			Contract_Start_Date__c = Date.today(),
 			Contract_End_Date__c = Date.today());
 		insert ali;
 		return ali;
 	}

	

}