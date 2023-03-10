/****************************************************************************************
Name            : ffaSEPAPaymentController
Author          : CLD Partners
Created Date    : 3/21/2016
Description     : Controller for creating SEPA xml payments.
******************************************************************************************/

public class ffaSEPAPaymentController {
	public Boolean sepaEligible {get; set;}
	public c2g__codaPayment__c payment {get; set;}
	public String xmlDeclaration {get; set;}
	public String messageId {get; set;}
	public String createdDateTime {get; set;}
	public Integer numberofTransactions {get; set;}
	public List<c2g__codaPaymentMediaSummary__c> paymentMediaSummaryList {get; set;}
	public String paymentDate {get; set;}

	public ffaSEPAPaymentController(ApexPages.StandardController controller) {
		c2g__codaPayment__c tmpPayment = (c2g__codaPayment__c)controller.getRecord(); 
		payment = queryPayment(tmpPayment.id);
		paymentMediaSummaryList = queryPaymentMediaSummaries(tmpPayment.id);
		xmlDeclaration = '<?xml version="1.0" encoding="utf-8"?>';	
		createdDateTime = payment.CreatedDate.format('yyyy-MM-dd HH:mm:ss');
		createdDateTime = createdDateTime.substring(0, 10) +'T'+createdDateTime.substring(11, 19);
		messageId = paymentMediaSummaryList.size() + '-' + createdDateTime; 
		datetime pmtDateTime = datetime.newInstance(payment.c2g__PaymentDate__c.Year(),payment.c2g__PaymentDate__c.Month(),payment.c2g__PaymentDate__c.Day());
		paymentDate = pmtDateTime.format('yyyy-MM-dd HH:mm:ss').substring(0, 10);
		numberofTransactions = paymentMediaSummaryList.size();
		sepaEligible = payment.SEPA_Eligible__c;
		if(sepaEligible == false){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Note: Only payments that are SEPA Eligible can have a SEPA file generated. Please ensure all the vendor accounts being paid are within the EU.')); 
		}
	}

	public c2g__codaPayment__c queryPayment(Id paymentId)
	{
		c2g__codaPayment__c returnPayment = [SELECT 
			Id, 
			CreatedDate,
			c2g__BankAccount__r.Name,
			c2g__BankAccount__r.c2g__AccountNumber__c,
			c2g__BankAccount__r.c2g__IBANNumber__c,
			c2g__BankAccount__r.c2g__SWIFTNumber__c,
			Positive_Payment_Value__c,
			c2g__OwnerCompany__r.Name,
			Name,
			SEPA_Eligible__c,
			Payment_Currency_Code__c,
			c2g__PaymentDate__c
		FROM c2g__codaPayment__c
		WHERE id = :paymentId];
		return returnPayment;
	}
	public List<c2g__codaPaymentMediaSummary__c> queryPaymentMediaSummaries(Id paymentId)
	{
		List<c2g__codaPaymentMediaSummary__c> returnList = [SELECT 
			c2g__Account__c,
			Positive_Payment_Value__c,
			c2g__BankAccountNumber__c,
			c2g__BankAccountReference__c,
			c2g__BankCity__c,
			c2g__BankCountry__c,
			c2g__BankIbanNumber__c,
			c2g__BankName__c,
			c2g__BankSortCode__c,
			c2g__BankStateProvince__c,
			c2g__BankStreet__c,
			c2g__BankSwiftNumber__c,
			c2g__BankZipPostalCode__c,
			c2g__BillingCity__c,
			c2g__BillingCountry__c,
			c2g__BillingStateProvince__c,
			c2g__BillingStreet__c,
			c2g__BillingZipPostCode__c,
			c2g__DiscountValue__c,
			c2g__DiscountValueTotal__c,
			c2g__ExternalId__c,
			c2g__GrossValue__c,
			c2g__GrossValueTotal__c,
			c2g__Indicator__c,
			c2g__LineNumber__c,
			c2g__OwnerCompany__c,
			c2g__PayeeName__c,
			c2g__PaymentControlCurrency__c,
			c2g__PaymentMediaControl__c,
			c2g__PaymentReference__c,
			c2g__PaymentValue__c,
			c2g__PaymentValueTotal__c,
			c2g__ReasonCode__c,
			c2g__ReportingCode__c,
			c2g__UnitOfWork__c,
			CreatedById,
			CreatedDate,
			CurrencyIsoCode,
			ffbf__AccountBankAccountNumber__c,
			ffbf__AccountBankCity__c,
			ffbf__AccountBankIBANNumber__c,
			ffbf__AccountBankName__c,
			ffbf__AccountBankSortCode__c,
			ffbf__AccountBankStreet__c,
			ffbf__AccountBankZipPostalCode__c,
			ffbf__AccountBillingAddress__c,
			ffbf__AccountBillingState__c,
			ffbf__AccountFax__c,
			ffbf__AccountInvoiceEmail__c,
			ffbf__AccountName__c,
			ffbf__AccountParticulars__c,
			ffbf__BankBIC__c,
			ffbf__DestinationBankAccountNumberFormula__c,
			ffbf__PaymentCode__c,
			ffbf__PaymentCountryISO__c,
			ffbf__PaymentId__c,
			ffbf__PaymentPriority__c,
			ffbf__PaymentRoutingMethod__c,
			ffdcpf_VendorNameOnCheck__c,
			c2g__PaymentMediaControl__r.c2g__Payment__r.Name,
			Id,
			Name
		FROM c2g__codaPaymentMediaSummary__c 
		WHERE c2g__PaymentMediaControl__r.c2g__Payment__c = :paymentId];
		return returnList;
	}

	/******************************************************************************/
    /** Wrapper Class Definition      **/
    /******************************************************************************/
    /*public class paymentWrapper{
        public c2g__codaPaymentMediaSummary__c pmsObject {get;set;}
       	public String 
        public paymentWrapper(){
            pmsObject = new c2g__codaPaymentMediaSummary__c();
            check = false;
        }
    }*/

}