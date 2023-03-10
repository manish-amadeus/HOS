/*******************************************************************************************
Name            : ffaRequisitionHandlerTEST
Author          : CLD Partners
Created Date    : Apr 11, 2016
Description     : Provides tests for the requisition and purchase order handlers
*******************************************************************************************/
@isTest (seealldata=true)
public class ffaRequisitionHandlerTEST 
{
    
	static SCMC__ICP__c testICP;
	static SCMC__Warehouse__c testWarehouse;
	static Account testVendor;
	static SCMC__Supplier_Site__c testSupplierSite;
	static SCMC__Requisition__c testRequisition;
	static SCMC__Purchase_Order__c testPurchaseOrder;

	private static void setupTestData()
    {
		try{createSCMCurrency();}
		catch(Exception e){}
		testICP = createICP('test ICP');
		testWarehouse = createWarehouse('test Warehouse', testICP.id);
		testVendor = ffaTestUtilities.createAccount('test vendor', null);
		testSupplierSite = createSupplierSite('test Site', testVendor.id);
	}
    
	@isTest static void testRequisitionInsert()
    {
		setupTestData();
		testRequisition = createRequisition(testWarehouse.id, testSupplierSite.id);
		testPurchaseOrder = createPurchaseOrder(testWarehouse.id, testSupplierSite.id, testRequisition.id);
	}

	private static void createSCMCurrency() 
    {
		SCMC__Currency_Master__c curr = new SCMC__Currency_Master__c(
			SCMC__Active__c = true,
			Name = 'USD',
			SCMC__Number_of_decimals__c = 2,
			SCMC__Corporate_Currency__c = true);
		insert curr;
	}

	private static SCMC__ICP__c createICP(String icpName) 
    {
		SCMC__ICP__c icp = new SCMC__ICP__c(
			Name = icpName);
		insert icp;
		return icp;
	}

	private static SCMC__Warehouse__c createWarehouse(String warehouseName, Id icpId) 
    {
		SCMC__Warehouse__c warehouse = new SCMC__Warehouse__c(
			SCMC__ICP__c = icpId,
			Name = warehouseName);
		insert warehouse;
		return warehouse;
	}

	private static SCMC__Supplier_Site__c createSupplierSite(String supplierSiteName, Id accountId) 
    {
		SCMC__Supplier_Site__c supplierSite = new SCMC__Supplier_Site__c(
			SCMC__Account__c = accountId,
			Name = supplierSiteName,
			SCMC__E_Mail__c = 'test@test.com',
			SCMC__Active__c = true);
		insert supplierSite;
		return supplierSite;
	}

	private static SCMC__Requisition__c createRequisition(Id warehouseId, Id supplierSiteId) 
    {
		SCMC__Requisition__c req = new SCMC__Requisition__c(
			SCMC__Warehouse__c = warehouseId,
			SCMC__Supplier_Site__c = supplierSiteId,
			SCMC__Buyer__c = UserInfo.getUserId(),
			Company__c = 'Newmarket US',
			Line_of_Business_Dimension_2__c = 'Newmarket Traditional');
		insert req;
		createRequisitionLines_Description(warehouseId, supplierSiteId, req.id);
		return req;
	}
	
	private static void createRequisitionLines_Description(Id warehouseId, Id supplierSiteId, Id reqid) 
    {
		Id reqlinetypeid = [Select id from recordtype where sobjecttype = 'SCMC__Requisition_Line_Item__c' and name = 'Description'].id;
		SCMC__Requisition_Line_Item__c reqline = new SCMC__Requisition_Line_Item__c(
			Recordtypeid = reqlinetypeid,
			SCMC__Warehouse__c = warehouseId,
			SCMC__Quantity__c = 2,
			SCMC__Requisition__c = reqid,
			SCMC__Budget__c = 100,
			Unit_Cost__c = 100,
			SCMC__Suggested_Supplier__c = supplierSiteId,
			General_Ledger_Account_list__c = '60701201 - JOY GANG EXPENSES',
			Line_of_Business_Dimension_2__c = 'Newmarket Traditional',
			Department_Dimension_3__c = '110 - HUMAN RESOURCES');
		insert reqline;
	}

	private static SCMC__Purchase_Order__c createPurchaseOrder(Id warehouseId, Id supplierSiteId, Id reqId) 
    {
		SCMC__Purchase_Order__c po = new SCMC__Purchase_Order__c(
			SCMC__Ship_To_Warehouse__c = warehouseId,
			SCMC__Status__c = 'Approved',
			SCMC__Supplier_Site__c = supplierSiteId,
			SCMC__Buyer_User__c = UserInfo.getUserId());
		insert po;
		List<SCMC__Requisition_Line_Item__c> reqLines = [SELECT Id FROM SCMC__Requisition_Line_Item__c WHERE SCMC__Requisition__c =: reqId];
		createPurchaseOrderLineItems(warehouseId, po.id, reqLines);
		return po;
	}

	private static void createPurchaseOrderLineItems(Id warehouseId, Id poId, List<SCMC__Requisition_Line_Item__c> reqLines) 
    {
		Id poLineTypeId = [Select id from recordtype where sobjecttype = 'SCMC__Purchase_Order_Line_Item__c' and name = 'Description'].id;
		List<SCMC__Purchase_Order_Line_Item__c> insertList = new List<SCMC__Purchase_Order_Line_Item__c>();
		for (SCMC__Requisition_Line_Item__c reqLine: reqLines)
        {
			SCMC__Purchase_Order_Line_Item__c poLine = new SCMC__Purchase_Order_Line_Item__c(
			Recordtypeid = poLineTypeId,
			SCMC__Warehouse__c = warehouseId,
			SCMC__Quantity__c = 2,
			SCMC__Unit_Cost__c = 100,
			SCMC__Requisition_Line_Item__c = reqLine.id,
			SCMC__Purchase_Order__c = poId
			);
			insertList.add(poLine);
		}		
		insert insertList;
	}
    
}