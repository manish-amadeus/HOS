/*******************************************************************************************
Name            : NI_PurchaseOrderExtension
Author          : CLD Partners
Created Date    : Apr 13, 2016
Description     : 
*******************************************************************************************/
public class NI_PurchaseOrderExtension 
{

	public SCMC__Purchase_Order__c poExtended {get; set;}
	public Boolean sendToContact {get; set;}
	public List<SCMC__Purchase_Order_Line_Item__c> poLinesExtended {get; set;}
	private SCMC.PurchaseOrderController poRequest = null;
	public ApexPages.standardController stdController;
	private Id poId {get; set;}
	String recordId;

	public string extendPOId { get;
		set {
			extendPOId = value;
			this.getMorePOFields(extendPOId);
		}
	}

    public NI_PurchaseOrderExtension(SCMC.PurchaseOrderController controller)
    {
		this.poRequest = controller;		
		poId = Apexpages.currentpage().getparameters().get('id');
	}  

    public NI_PurchaseOrderExtension(ApexPages.standardController controller) 
    {
		this.stdController = controller;
		this.poId = stdController.getId();
	}

    public void getMorePOFields(string filterId)
    {
        
        poExtended = [SELECT Id, SCMC__Ship_to_Warehouse__r.Delivery_Instructions__c, Shipping_To__c, Ship_to_Contact__c, Contact_Shipping_Address__c, SCMFFA__Company__r.Legal_Entity_Name__c, Quote_Number__c 
                      FROM SCMC__Purchase_Order__c
                      WHERE Id =: filterId];
        
        sendToContact = poExtended.Shipping_To__c == 'Ship to Contact' ? true : false;
        
        poLinesExtended = [SELECT Id, SCMC__Line_Number__c, SCMC__Quantity__c, SCMC__Unit_Cost__c, SCMC__Total_Cost__c,
                           SCMC__Requested_Date__c, SCMC__Requisition_Line_Item__r.Item_Part_Number__c, SCMC__Requisition_Line_Item__r.SCMC__Description__c, SCMC__Requisition_Line_Item__r.SCMC__Requested_Date__c
                           FROM SCMC__Purchase_Order_Line_Item__c
                           WHERE SCMC__Purchase_Order__c =: filterId];
    }
    
}