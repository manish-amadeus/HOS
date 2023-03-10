public class ffaBulkPrintController {

	public List<c2g__codaInvoice__c> invoices {get; set;}
	public List<c2g__codaInvoice__c> tmpList;
	public ffaBulkPrintController(ApexPages.StandardSetController controller) {
		invoices = (List<c2g__codaInvoice__c>)controller.getSelected();
		tmpList = [select id, c2g__PrintStatus__c,c2g__InvoiceStatus__c from c2g__codaInvoice__c where id in: invoices];
	}
	public void updatePrintStatus(){
		List<c2g__codaInvoice__c> updateList = new List<c2g__codaInvoice__c>();
		//Commenting out due to FFA validation
		for(c2g__codaInvoice__c inv : tmpList){
			if(inv.c2g__InvoiceStatus__c == 'Complete' && inv.c2g__PrintStatus__c != 'Printed' ){
				inv.c2g__PrintStatus__c = 'Printed';	
				updateList.add(inv);
			}
		}

		update updateList;
	}
}