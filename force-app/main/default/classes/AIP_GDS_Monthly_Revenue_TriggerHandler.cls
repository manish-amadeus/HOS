/************************************************************************************************
Name            : AIP_GDS_Monthly_Revenue_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 1/16/2015
Last Mod Date   : 1/16/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Class that handles all trigger code for the AIP_GDS_Monthly_Revenue__c Object
				:
				: 
*************************************************************************************************/
public class AIP_GDS_Monthly_Revenue_TriggerHandler 
{
    
    // NUMBER OF MONTHS  
    public Decimal dMonths;
    
    //========================================================================================================================
    public void OnAfterInsert(List<AIP_GDS_Monthly_Revenue__c> newTrigger)
    {

        // CREATE A LIST TO HOLD ALL OF THE AIP_GDS_Monthly_Revenue__c RECORDS THAT ARE RELATED TO ACCOUNTS
        List<AIP_GDS_Monthly_Revenue__c> lstGDSRecordsWithAccounts = new List<AIP_GDS_Monthly_Revenue__c>();
        List<AIP_GDS_Monthly_Revenue__c> lstGDSRecordsWithMarkets = new List<AIP_GDS_Monthly_Revenue__c>();
        
        // POPULATE LISTS BASED ON PRESENTS OF ACCOUNT ID / MARKET ID
        for (AIP_GDS_Monthly_Revenue__c rev : newTrigger) 
        {  
            if (rev.Account__c != null)
            {
                lstGDSRecordsWithAccounts.add(rev);
            }
            if (rev.Market__c != null)
            {
                lstGDSRecordsWithMarkets.add(rev);
            }
        }
        
        // IF ACCOUNT IDS WERE FOUND
        if (lstGDSRecordsWithAccounts.size() > 0)
        {
            // CALL THE METHOD TO UPDATE THE AIP_GDS_Annual_Revenue__c FIELD ON THE ACCOUNT 
            updateAccountObject(lstGDSRecordsWithAccounts); 
        }
        
        // IF MARKET IDS WERE FOUND
		if (lstGDSRecordsWithMarkets.size() > 0)
        {
            updateMarketObject(lstGDSRecordsWithMarkets); 
        }        

    } 
    
    public void updateAccountObject(List<AIP_GDS_Monthly_Revenue__c> newTrigger)
    { 

        // INIT VARIABLES 
        Date curDate = Date.Today();
        
        Integer iCurrentYear = curDate.Year();
        Integer iLastYear = (iCurrentYear - 1);
        
        Decimal dAIP_LY_Bookings = 0; 
        Decimal dAIP_CY_Bookings = 0; 
        
        Decimal dAIP_LY_Room_Nights = 0; 
        Decimal dAIP_CY_Room_Nights = 0; 
        
        Decimal dAIP_LY_Revenues = 0; 
        Decimal dAIP_CY_Revenues = 0; 
        
        Decimal dRevenue = 0; 				// VARIABLE TO HOLD THE REVENUE RUNNING TOTAL
        Integer iCount = 0; 				// VARIABLE TO KEEP TRACK OF THE NUMBER OF GDS MONTHLY REVENUE RECORDS
        
        // LIST TO HOLD THE VALUES FROM THE AIP_GDS_MonthlyRevenue CUSTOM SETTING  
        List<AIP_GDS_MonthlyRevenue__c> lstCS = AIP_GDS_MonthlyRevenue__c.getAll().values();
        
        if (lstCS.size() > 0)
        { 
            
            // LOOP THROUGH THE lstCS AND GET THE NUMBER OF MONTHS VALUE 
            for (AIP_GDS_MonthlyRevenue__c r : lstCS)
            {
                // System.debug('NUMBER OF MONTHS: ' + r.Number_of_Months__c); 
                dMonths = r.Number_of_Months__c; 
            }
            
            // CREATE A SET TO HOLD THE ACCOUNT IDs OF THE INSERTED RECORDS
            Set<Id> setAccountIds = new Set<Id>();
            
            for (AIP_GDS_Monthly_Revenue__c r : newTrigger) 
            {   
                // FIND THE ACCOUNT RECORDS  
                if (r.Account__c != null)
                { 
                    setAccountIds.add(r.Account__c);
                }
            }
            
            // LIST OF ALL ACCOUNTS REFERENCED BY THE INSERTED RECORDS
            List<Account> lstAllAccounts = new List<Account>();
            
            lstAllAccounts = ([SELECT Id, AIP_GDS_Annual_Revenue__c, 
                               AIP_LY_Bookings__c, AIP_CY_Bookings__c, 
                               AIP_LY_Room_Nights__c, AIP_CY_Room_Nights__c, 
                               AIP_LY_Revenues__c, AIP_CY_Revenues__c 
                               FROM Account 
                               WHERE Id IN :setAccountIds]);

            // System.Debug('# ACCOUNTS REFERENCED BY INSERTED GDS MONTHLY REVENUE RECORDS: ' + lstAllAccounts.size());
            
            // CREATE A LIST TO HOLD ALL OF THE AIP_GDS_Monthly_Revenue__c RECORDS RELATED TO THE ACCOUNTS IN THE setAccountIds
            List<AIP_GDS_Monthly_Revenue__c> lstAllGDSRecords = new List<AIP_GDS_Monthly_Revenue__c>();
            
            // QUERY ALL REVENUE RECORD FOR LAST YEAR AND THIS YEAR FOR THE ACCOUNTS FOUND
            lstAllGDSRecords = [SELECT Id, Account__c, Revenue_Month__c, 
                                Revenue_Amount__c, Number_of_GDS_Bookings__c, Number_of_GDS_Roomnights__c 
                                FROM AIP_GDS_Monthly_Revenue__c
                                WHERE Account__c IN: setAccountIds
                                AND (Revenue_Month__c = THIS_YEAR OR Revenue_Month__c = LAST_YEAR)
                                ORDER BY Account__c ASC, Revenue_Month__c DESC];
            
            // System.Debug('TOTAL GDS MONTHLY REVENUE RECORDS: ' + lstAllGDSRecords.size());
            
            Integer iCurrentMonth = getMaxMonth(lstAllGDSRecords);
            
            // CREATE A LIST TO HOLD THE ACCOUNT RECORDS TO UPDATE
            List<Account> lstAccountsToUpdate = new List<Account>();
            
            // LOOP THROUGH EACH ACCOUNT  
            for (Account a : lstAllAccounts)
            {

                Integer iMonths = dMonths.intValue(); 	// CONVERT THE DECIMAL TO AN INTEGER 
                
                dAIP_LY_Bookings = 0; 
                dAIP_CY_Bookings = 0; 
                
                dAIP_LY_Room_Nights = 0; 
                dAIP_CY_Room_Nights = 0; 
                
                dAIP_LY_Revenues = 0; 
                dAIP_CY_Revenues = 0; 

                dRevenue = 0; 							// SET THE VARIABLE TO 0 FOR EACH NEW ACCOUNT
                iCount = 0; 							// SET THE VARIABLE TO 0 FOR EACH NEW ACCOUNT
                
                // LOOP THROUGH THE GDS MONTHLY REVENUE RECORDS FOR EACH ACCOUNT 
                for (AIP_GDS_Monthly_Revenue__c mRev : lstAllGDSRecords)
                {

                    if (a.Id == mRev.Account__c)
                    {
						
                        Date d = mRev.Revenue_Month__c;
                        
                        if ((d.month() <= iCurrentMonth) && (d.Year() == iCurrentYear))
                        {
                            
                            if (mRev.Number_of_GDS_Bookings__c != null)
                            {
                                dAIP_CY_Bookings = (dAIP_CY_Bookings + mRev.Number_of_GDS_Bookings__c); 
                            }
                            
                            if (mRev.Number_of_GDS_Roomnights__c != null)
                            {
                                dAIP_CY_Room_Nights = (dAIP_CY_Room_Nights + mRev.Number_of_GDS_Roomnights__c); 
                            }                        
                            
                            if (mRev.Revenue_Amount__c != null)
                            {
                                dAIP_CY_Revenues = (dAIP_CY_Revenues + mRev.Revenue_Amount__c); 
                            }
                            
                        }
                        
                        if ((d.month() <= iCurrentMonth) && (d.Year() == iLastYear))
                        {
                            
                            if (mRev.Number_of_GDS_Bookings__c != null)
                            {
                                dAIP_LY_Bookings = (dAIP_LY_Bookings + mRev.Number_of_GDS_Bookings__c); 
                            }
                            
                            if (mRev.Number_of_GDS_Roomnights__c != null)
                            {
                                dAIP_LY_Room_Nights = (dAIP_LY_Room_Nights + mRev.Number_of_GDS_Roomnights__c); 
                            }
                            
                            if (mRev.Revenue_Amount__c != null)
                            {
                                dAIP_LY_Revenues = (dAIP_LY_Revenues + mRev.Revenue_Amount__c); 
                            }
                            
                        }

                        // if (iCount < iMonths)
                        if (((d.month() > iCurrentMonth) && (d.Year() == iLastYear)) || ((d.month() <= iCurrentMonth) && (d.Year() == iCurrentYear)))
                        {
                            if (mRev.Revenue_Amount__c != null)
                            {
                            	dRevenue = (dRevenue + mRev.Revenue_Amount__c); 
                            }
                        }                        
                        
                        iCount++; 

                    }
                    
                } 

                a.AIP_CY_Bookings__c = dAIP_CY_Bookings; 
                a.AIP_CY_Room_Nights__c = dAIP_CY_Room_Nights;
                a.AIP_CY_Revenues__c = dAIP_CY_Revenues; 
                
                a.AIP_LY_Bookings__c = dAIP_LY_Bookings; 
                a.AIP_LY_Room_Nights__c = dAIP_LY_Room_Nights;
                a.AIP_LY_Revenues__c = dAIP_LY_Revenues; 

                a.AIP_GDS_Annual_Revenue__c = dRevenue;
                
                lstAccountsToUpdate.add(a); 
                
            }         
            
            // System.Debug('TOTAL #ACCOUNTS TO UPDATE: ' + lstAccountsToUpdate.size());
            
            // PERFORM BATCH UPDATE OF ACCOUNTS
            if (lstAccountsToUpdate.size() > 0)    
            {
                Database.SaveResult[] results = Database.update(lstAccountsToUpdate);
                for (Database.SaveResult sr: results)
                {
                    if (!sr.isSuccess())
                    {
                        Database.Error err = sr.getErrors()[0];
                        System.debug(err.getMessage());
                    }
                }
            }       
        }
        
    }      
    
    public void updateMarketObject(List<AIP_GDS_Monthly_Revenue__c> newTrigger)
    { 

        Date curDate = Date.Today();
        
        Integer iCurrentYear = curDate.Year();
        Integer iLastYear = (iCurrentYear - 1);
        
        Decimal dAIP_LY_Bookings = 0; 
        Decimal dAIP_CY_Bookings = 0; 
        
        Decimal dAIP_LY_Room_Nights = 0; 
        Decimal dAIP_CY_Room_Nights = 0; 
        
        Decimal dAIP_LY_Revenues = 0; 
        Decimal dAIP_CY_Revenues = 0; 

        // CREATE A SET TO HOLD THE MARKET IDs OF THE INSERTED RECORDS
        Set<Id> setMarketIds = new Set<Id>();
        
        for (AIP_GDS_Monthly_Revenue__c r : newTrigger) 
        {   
            // FIND THE MARKET RECORDS  
            if (r.Market__c != null)
            { 
                setMarketIds.add(r.Market__c);
            }
        }
        
        // LIST OF ALL ACCOUNTS REFERENCED BY THE INSERTED RECORDS
        List<Market__c> lstAllMarkets = new List<Market__c>();
        
        lstAllMarkets = ([SELECT Id, 
                          AIP_LY_Bookings__c, AIP_CY_Bookings__c, 
                          AIP_LY_Room_Nights__c, AIP_CY_Room_Nights__c, 
                          AIP_LY_Revenues__c, AIP_CY_Revenues__c 
                          FROM Market__c 
                          WHERE Id IN :setMarketIds]);
        
        //
        List<AIP_GDS_Monthly_Revenue__c> lstAllGDSRecords = new List<AIP_GDS_Monthly_Revenue__c>();
        
        lstAllGDSRecords = [SELECT Id, Market__c, Revenue_Month__c, 
                            Revenue_Amount__c, Number_of_GDS_Bookings__c, Number_of_GDS_Roomnights__c 
                            FROM AIP_GDS_Monthly_Revenue__c
                            WHERE Market__c IN: setMarketIds
                            AND (Revenue_Month__c = THIS_YEAR OR Revenue_Month__c = LAST_YEAR)
                            ORDER BY Market__c ASC, Revenue_Month__c DESC];
        
        Integer iCurrentMonth = getMaxMonth(lstAllGDSRecords);
        
        // CREATE A LIST TO HOLD THE ACCOUNT RECORDS TO UPDATE
        List<Market__c> lstMarketsToUpdate = new List<Market__c>();
        
        // LOOP THROUGH EACH ACCOUNT  
        for (Market__c m : lstAllMarkets)
        {
            
            dAIP_LY_Bookings = 0; 
            dAIP_CY_Bookings = 0; 
            
            dAIP_LY_Room_Nights = 0; 
            dAIP_CY_Room_Nights = 0; 
            
            dAIP_LY_Revenues = 0; 
            dAIP_CY_Revenues = 0; 
            
            // LOOP THROUGH THE GDS MONTHLY REVENUE RECORDS FOR EACH ACCOUNT 
            for (AIP_GDS_Monthly_Revenue__c mRev : lstAllGDSRecords)
            {
                
                if (m.Id == mRev.Market__c)
                {
                    
                    Date d = mRev.Revenue_Month__c;
                    
                    if ((d.month() <= iCurrentMonth) && (d.Year() == iCurrentYear))
                        {
                            
                            if (mRev.Number_of_GDS_Bookings__c != null)
                            {
                                dAIP_CY_Bookings = (dAIP_CY_Bookings + mRev.Number_of_GDS_Bookings__c); 
                            }
                            
                            if (mRev.Number_of_GDS_Roomnights__c != null)
                            {
                                dAIP_CY_Room_Nights = (dAIP_CY_Room_Nights + mRev.Number_of_GDS_Roomnights__c); 
                            }                        
                            
                            if (mRev.Revenue_Amount__c != null)
                            {
                                dAIP_CY_Revenues = (dAIP_CY_Revenues + mRev.Revenue_Amount__c); 
                            }
                            
                        }
                        
                        // if ((d.month() <= iCurrentMonth) && (d.Year() == iLastYear))
                        if (d.Year() == iLastYear)
                        {
                            
                            if (mRev.Number_of_GDS_Bookings__c != null)
                            {
                                dAIP_LY_Bookings = (dAIP_LY_Bookings + mRev.Number_of_GDS_Bookings__c); 
                            }
                            
                            if (mRev.Number_of_GDS_Roomnights__c != null)
                            {
                                dAIP_LY_Room_Nights = (dAIP_LY_Room_Nights + mRev.Number_of_GDS_Roomnights__c); 
                            }
                            
                            if (mRev.Revenue_Amount__c != null)
                            {
                                dAIP_LY_Revenues = (dAIP_LY_Revenues + mRev.Revenue_Amount__c); 
                            }
                            
                        }
                    
                }
                
            } 
            
            m.AIP_CY_Bookings__c = dAIP_CY_Bookings; 
            m.AIP_CY_Room_Nights__c = dAIP_CY_Room_Nights;
            m.AIP_CY_Revenues__c = dAIP_CY_Revenues; 
            
            m.AIP_LY_Bookings__c = dAIP_LY_Bookings; 
            m.AIP_LY_Room_Nights__c = dAIP_LY_Room_Nights;
            m.AIP_LY_Revenues__c = dAIP_LY_Revenues; 
            
            lstMarketsToUpdate.add(m); 
            
        }         
        
        // PERFORM BATCH UPDATE OF ACCOUNTS
        if (lstMarketsToUpdate.size() > 0)    
        {
            Database.SaveResult[] results = Database.update(lstMarketsToUpdate);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }
        }       
        
    }      
    
    // RETURNS THE GREATEST MONTH NUMBER IS LIST (FOR CURRENT YEAR)
    private Integer getMaxMonth(List<AIP_GDS_Monthly_Revenue__c> lst)
    {
        
        Integer i = 0;
        Date curDate = Date.Today();
        
        for (AIP_GDS_Monthly_Revenue__c mRev : lst)
        { 
            Date d = mRev.Revenue_Month__c;
            if (d.year() == curDate.year())
            {
                if (i < d.month())
                {
                    i = d.month();
                }
            }
        }
        
        return i;
        
    }
    
    
}