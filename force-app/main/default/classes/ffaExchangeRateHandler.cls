/****************************************************************************************
Name            : ffaExchangeRateHandler
Author          : CLD Partners
Created Date    : 2/28/15
Description     : Main Handler class for syncing SF exchange rates with FFA Accounting Currencies
Revision History: 2/28/15 - Created
****************************************************************************************/

public class ffaExchangeRateHandler {

	/******************************************************************************/
    /** Method to query and return the necessary SF Exchange Rates
    /******************************************************************************/
    public static Map<String, Decimal> getSFExchangeRates (Set<String> requestedCurrencies, Date effective_date)
    {
    	Map<String, Decimal> sfExchangeRateMap = new Map<String, Decimal>();
    	for(DatedConversionRate rate: [
    		SELECT ConversionRate, IsoCode, NextStartDate, StartDate 
    		FROM DatedConversionRate
    		WHERE StartDate <= :effective_date
    		AND NextStartDate > :effective_date
    		AND IsoCode in :requestedCurrencies])
    	{
    		sfExchangeRateMap.put(rate.IsoCode, rate.ConversionRate);
    	}
    	system.debug('\n\n ***** ffaExchangeRateHandler - getSFExchangeRates - sfExchangeRateMap = '+ sfExchangeRateMap);
    	return sfExchangeRateMap;
    }

    /******************************************************************************/
    /** Method to for calculating and converting the appropriate FFA exchange rate, return is a map of the iso code and rate.
    /******************************************************************************/
    public static Map<String, Decimal> calculateFFAExchangeRate (Id companyId, Date effective_date)
    {
    	//Step 1: Retrieve all needed data
    	Set<String> necessaryExchangeRates = new Set<String>();
    	Map<String, Decimal> sfExchangeRateMap = new Map<String, Decimal>();
    	Map<String, Decimal> ffaExchangeRateMap = new Map<String, Decimal>();

    	String corpCurrency = getSFCorpCurrency();
    	system.debug('\n\n ***** ffaExchangeRateHandler - calculateFFAExchangeRate - corpCurrency = '+ corpCurrency);

    	c2g__codaAccountingCurrency__c homeCurrency = getHomeCurrency(companyId);
    	necessaryExchangeRates.add(homeCurrency.Name);
    	system.debug('\n\n ***** ffaExchangeRateHandler - calculateFFAExchangeRate - homeCurrency = '+ homeCurrency);

    	List<c2g__codaAccountingCurrency__c> otherCurrencyList = getOtherCurrencies(companyId);
    	for(c2g__codaAccountingCurrency__c curr : otherCurrencyList)
    	{
    		necessaryExchangeRates.add(curr.Name);
    	}
    	sfExchangeRateMap = getSFExchangeRates(necessaryExchangeRates, effective_date);

    	//Step 2: Loop through all the non-home currencies and calculate what the exchange rate should be and store this in the map
    	for(c2g__codaAccountingCurrency__c curr : otherCurrencyList)
    	{
    		if(homeCurrency.Name == corpCurrency)//if the home is the same as corp, than the exchange rates are the same
    		{
    			if(sfExchangeRateMap.containsKey(curr.Name))
    			{
    				ffaExchangeRateMap.put(curr.Name, sfExchangeRateMap.get(curr.Name));
    				system.debug('\n\n ***** ffaExchangeRateHandler - calculateFFAExchangeRate - CURRENCIES MATCH');
    			}
    			
    		}
    		if(homeCurrency.Name != corpCurrency) //if the home is not the same as corp
    		{
    			Decimal homeToCorp;
    			Decimal targetToCorp;
    			Decimal ffaRate;
    			if(sfExchangeRateMap.containsKey(homeCurrency.Name))
    			{
    				homeToCorp = sfExchangeRateMap.get(homeCurrency.Name);
    			}
    			system.assert(homeToCorp != null, 'ERROR: Could not find the home currency rate');

    			if(curr.Name == corpCurrency)// if the corp is the same as the currency being converted than target to corp currency is 1
    			{
    				targetToCorp = 1;
    			}
    			else
    			{
    				if(sfExchangeRateMap.containsKey(curr.Name))
    				{
    					targetToCorp = sfExchangeRateMap.get(curr.Name);
    				}
    			}
    			system.assert(targetToCorp != null, 'ERROR: Could not find the target currency rate');
    			ffaRate = targetToCorp / homeToCorp;
    			ffaExchangeRateMap.put(curr.Name, ffaRate);
    			system.debug('\n\n ***** ffaExchangeRateHandler - calculateFFAExchangeRate - CURRENCIES DO NOT MATCH');
    			system.debug('\n\n ***** ffaExchangeRateHandler - calculateFFAExchangeRate - homeToCorp' + homeToCorp);
    			system.debug('\n\n ***** ffaExchangeRateHandler - calculateFFAExchangeRate - targetToCorp' + targetToCorp);
    			system.debug('\n\n ***** ffaExchangeRateHandler - calculateFFAExchangeRate - ffaRate' + ffaRate);
    		}
    	}
    	//Step 3: Debug and return
    	system.debug('\n\n ***** ffaExchangeRateHandler - calculateFFAExchangeRate - ffaExchangeRateMap' + ffaExchangeRateMap);
    	return ffaExchangeRateMap;
    }


	/******************************************************************************/
    /** Method to return the orgs corporate Currency - this is how the exchange rates will be stored in SFDC
    /******************************************************************************/
    public static String getSFCorpCurrency()
    {
    	String corpCurrency = [SELECT ISOCode FROM CurrencyType WHERE IsActive=TRUE and IsCorporate=TRUE LIMIT 1].ISOCode;
    	return corpCurrency;
    }


	/******************************************************************************/
    /** Method to return a list of all the none Home Accounting Currencies for a single company
    /******************************************************************************/	
    public static List<c2g__codaAccountingCurrency__c> getOtherCurrencies(Id companyId)
    {
    	List<c2g__codaAccountingCurrency__c> otherCurrencies = [SELECT Id, Name, c2g__ownerCompany__c
    	FROM c2g__codaAccountingCurrency__c 
    	WHERE c2g__Home__c = FALSE 
    	AND c2g__ownerCompany__c = :companyID];
    	return otherCurrencies;
    }

    /******************************************************************************/
    /** Method to return the Home currency for a Single Company
    /******************************************************************************/	
    public static c2g__codaAccountingCurrency__c getHomeCurrency(Id companyId)
    {
    	c2g__codaAccountingCurrency__c homeCurrency = [
    	SELECT Id, Name 
    	FROM c2g__codaAccountingCurrency__c 
    	WHERE c2g__Home__c = TRUE 
    	AND c2g__ownerCompany__c = :companyID];
    	return homeCurrency;
    }
}