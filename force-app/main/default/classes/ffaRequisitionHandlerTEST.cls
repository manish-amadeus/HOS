/*******************************************************************************************
Name            : ffaRequisitionHandlerTEST
Author          : CLD Partners
Created Date    : Apr 11, 2016
Description     : Provides tests for the requisition and purchase order handlers
*******************************************************************************************/

@isTest (seealldata=true)
public class ffaRequisitionHandlerTEST {
	static SCMC__ICP__c testICP;
	static SCMC__Warehouse__c testWarehouse;
	static Account testVendor;
	static SCMC__Supplier_Site__c testSupplierSite;
	static SCMC__Requisition__c testRequisition;
	static SCMC__Purchase_Order__c testPurchaseOrder;

	private static void setupTestData(){
		try{scmTestUtilities.createSCMCurrency();}
		catch(Exception e){}
		testICP = scmTestUtilities.createICP('test ICP');
		testWarehouse = scmTestUtilities.createWarehouse('test Warehouse', testICP.id);
		testVendor = ffaTestUtilities.createAccount('test vendor', null);
		testSupplierSite = scmTestUtilities.createSupplierSite('test Site', testVendor.id);
	}
	@isTest static void testRequisitionInsert(){
		setupTestData();
		testRequisition = scmTestUtilities.createRequisition(testWarehouse.id, testSupplierSite.id);
		testPurchaseOrder = scmTestUtilities.createPurchaseOrder(testWarehouse.id, testSupplierSite.id, testRequisition.id);
	}
}