/****************************************************************************************
Name            : ffaExchangeRateSyncController
Author          : CLD Partners
Created Date    : 1/28/16
Description     : Controller Class for the Exchange Rate Sync functionality
Revision History: 1/28/16 - Created
****************************************************************************************/

public class ffaExchangeRateSyncController {

	/******************************************************************************/
    /** Variable Init       **/
    /******************************************************************************/
	private string companyId;
	public Boolean hasError {get;set;}
	public c2g__codaCompany__c company {get;set;}
	public Date effectiveDate {get;set;}
	public c2g__codaAccountingCurrency__c homeCurrency {get;set;}
	public List<ffaRateModel> exchangeRateList {get;set;}
	public List<c2g__codaAccountingCurrency__c> acctCurrencies;
	public c2g__codaCompany__c currentCompany {get;set;}
	
	/******************************************************************************/
    /** Constructor Method       **/
    /******************************************************************************/
	public ffaExchangeRateSyncController() {
		hasError = false;
		validateCompanySelection();
		if(hasError == false)
		{
			loadFFARates();	
		}
	}

	/******************************************************************************/
    /** Validated a single company is selected        **/
    /******************************************************************************/
	public void validateCompanySelection() {
		List<c2g__codaCompany__c> currentCompanies = ffaUtilities.gerCurrentCompanies();
		system.debug('\n\n ***** ffaExchangeRateSyncController - validateCompanySelection - currentCompanies = '+ currentCompanies);
		if(currentCompanies.size() == 0)
		{
			hasError= true;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'No Current Company Selected, please select a single company and try again.'));     
			return;
		}
		if(currentCompanies.size() > 1)
		{
			hasError= true;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'This page cannot be used in multi-company mode, please select a single company and try again.'));     
			return;
		}
		if(currentCompanies.size() == 1)
		{
			currentCompany = currentCompanies[0];
			loadCompany();
		}
	}

	/******************************************************************************/
    /** Save Exchange Rates        **/
    /******************************************************************************/
	public void saveRates() {
		List<c2g__codaExchangeRate__c> rateUpsertList = new List<c2g__codaExchangeRate__c>();
		effectiveDate = company.Exchange_Rate_Effective_Date__c;
		if(effectiveDate == null)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'ERROR: The Effective Date Cannot be blank.'));
			return;     
		}
		Map<String, Id> existingExchangeRateMap = new Map<String, Id>(); //key is AccountingCurrency Id + Start Date formatted.
		for(c2g__codaExchangeRate__c er : [SELECT Id, c2g__ExchangeRateCurrency__c, c2g__StartDate__c
			FROM c2g__codaExchangeRate__c
			WHERE c2g__StartDate__c = :effectiveDate])
		{
			String key = er.c2g__ExchangeRateCurrency__c + '|' + er.c2g__StartDate__c.format();
			existingExchangeRateMap.put(key, er.id);
		}
		for(ffaRateModel model : exchangeRateList)
		{
			if(model.check == true)
			{
				String key = model.ffaRate_object.c2g__ExchangeRateCurrency__c + '|' + effectiveDate.format();

				if(existingExchangeRateMap.containsKey(key))
				{
					model.ffaRate_object.id = existingExchangeRateMap.get(key);
				}
				model.ffaRate_object.c2g__StartDate__c = effectiveDate;
				rateUpsertList.add(model.ffaRate_object);
			}
		}
		if(rateUpsertList.size()>0)
		{
			try{
			upsert rateUpsertList;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Saved Successfully!'));
			}
			catch(Exception e){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'ERROR: ' + e.getMessage() + '\n Line: '+ e.getLineNumber()));
			}
		}
		else{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'You must select at least 1 line before saving.'));
		}
		
	}

	/******************************************************************************/
    /** Load Accounting Currencies and Rates        **/
    /******************************************************************************/
	public void loadFFARates()
	{
		exchangeRateList = new List<ffaRateModel>();
		List<c2g__codaAccountingCurrency__c> targetCurrencies = ffaExchangeRateHandler.getOtherCurrencies(currentCompany.id);
		homeCurrency = ffaExchangeRateHandler.getHomeCurrency(currentCompany.id);
		for(c2g__codaAccountingCurrency__c c : targetCurrencies)
		{
			ffaRateModel model = new ffaRateModel();
			model.isoCode = c.Name;
			model.ffaRate_object = new c2g__codaExchangeRate__c(
				c2g__OwnerCompany__c = currentCompany.id,
				c2g__ExchangeRateCurrency__c = c.id,
				c2g__Rate__c = 0);
			exchangeRateList.add(model);
		}
	}

	/******************************************************************************/
    /** Sync the FFA rates with the SFDC Rates        **/
    /******************************************************************************/
	public void syncFFARates()
	{
		effectiveDate = company.Exchange_Rate_Effective_Date__c;
		if(effectiveDate == null)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'ERROR: The Effective Date Cannot be blank.'));
			return;     
		}
		Map<String, Decimal> ffaExchangeRateMap = ffaExchangeRateHandler.calculateFFAExchangeRate(currentCompany.id, effectiveDate);
		for(ffaRateModel model : exchangeRateList)
		{
			if(model.check == true)
			{
				if(ffaExchangeRateMap.containsKey(model.isoCode))
				{
					model.ffaRate_object.c2g__Rate__c = ffaExchangeRateMap.get(model.isoCode);
				}	
			}
		}
	}

	/******************************************************************************/
    /** Load Accounting Currencies and Rates        **/
    /******************************************************************************/
	public void loadCompany()
	{
		company = [SELECT Id, Name, Exchange_Rate_Effective_Date__c FROM c2g__codaCompany__c WHERE Id = :currentCompany.id];
	}

	/******************************************************************************/
    /** Cancel and Go back to Home Page       **/
    /******************************************************************************/
    public PageReference backToHome(){
        PageReference ref = new PageReference('/home/home.jsp'); 
        return ref; 
    }

    /******************************************************************************/
    /** Wrapper Class Definition      **/
    /******************************************************************************/
    public class ffaRateModel{
        public c2g__codaExchangeRate__c ffaRate_object {get;set;}
        public boolean check {get;set;}
        public string isoCode {get;set;}
        public ffaRateModel(){
            ffaRate_object = new c2g__codaExchangeRate__c();
            check = true;
        }
    }

}