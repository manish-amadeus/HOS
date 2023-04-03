/*******************************************************************************************
Name            : NI_PurchaseOrderExtensionTEST
Author          : CLD Partners
Created Date    : Apr 13, 2016
Description     : Provides tests for the purchase order extension class
*******************************************************************************************/

@isTest (seealldata=true)
public class NI_PurchaseOrderExtensionTEST {
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
		testRequisition = scmTestUtilities.createRequisition(testWarehouse.id, testSupplierSite.id);
		testPurchaseOrder = scmTestUtilities.createPurchaseOrder(testWarehouse.id, testSupplierSite.id, testRequisition.id);
	}
	@isTest static void testPOExtension(){
		setupTestData();
		SCMC.PurchaseOrderController scmCont = new SCMC.PurchaseOrderController();
		ApexPages.standardController stdCont = new ApexPages.standardController(testPurchaseOrder);
		NI_PurchaseOrderExtension poExt1 = new NI_PurchaseOrderExtension(stdCont);
		NI_PurchaseOrderExtension poExt2 = new NI_PurchaseOrderExtension(scmCont);
		//poExt.extendPOId = testPurchaseOrder.id;
		poExt2.getMorePOFields(testPurchaseOrder.id);
	}
}