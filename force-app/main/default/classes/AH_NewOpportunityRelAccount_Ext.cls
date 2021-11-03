/****************************************************************************************
Name            : AH_NewOpportunityRelAccount_Ext
Author          : Ria Chawla
Created Date    : 04/19/2018
Last Mod Date   : 11/08/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Controller for AH_NewOpportunityRelAccount VF Page.
				: Updated per NICC-039872
				: 
******************************************************************************************/
public class AH_NewOpportunityRelAccount_Ext 
{
    
    //CLASS VARIABLES
    //private ApexPages.StandardController stdCtrl {get; set;}
    public AH_Opportunity_Related_Account__c oppAccObj {get; set;}
    public List<Account> relatedAccList {get; set;}
    public List<AccountWrapper> relatedAccWrapperList {get; set;}
    public Map<Id, AccountWrapper> relatedAccWrapperMap {get; set;}
    public Boolean fromOpportunity {get; set;}
    Map<Id, AH_Opportunity_Related_Account__c> mapExistingRelatedAcc;
    
    public Id oppId;
    
    public Integer paginationSize;
    public Integer listNumber {get; set;}
    public Integer totalPages {get; set;}
    private Integer totalRecordsCount {get; set;}
    private Map<Integer, List<String>> pageNumToORAIDMap;
    public Id opportunityId {get; set;}
    
    
    //CONSTRUCTOR
    public AH_NewOpportunityRelAccount_Ext(ApexPages.StandardController stdCtrl)
    {
        if(Test.isRunningTest())
        {
            paginationSize = 25;
        }
        else {
        	paginationSize = 200;
        }
        
        listNumber = 0;
        totalPages = 0;
        totalRecordsCount = 0;
        
        oppAccObj = new AH_Opportunity_Related_Account__c();
        
        //GET RETURN URL
        String retURL = '';
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        //STORE IN A STRING RETURN URL
        String opporId = '';
        opporId = retURL.substringAfter('/').substring(0, 15); // ADDED .substring(0, 15) 2019-06-11 TO TRIM OFF ANY PARAMS FROM RELATED POS
        opportunityId = opporId;
        
        //METHOD VARIABLES
        List<AH_Opportunity_Related_Account__c> oppRelAccList = new List<AH_Opportunity_Related_Account__c>();
        mapExistingRelatedAcc = new Map<Id, AH_Opportunity_Related_Account__c>();
        Id primaryAccId;
        relatedAccWrapperList = new List<AccountWrapper>();
        relatedAccWrapperMap = new Map<Id, AccountWrapper>();
        
        //IF RETURN URL ASTARTS WITH 006 I.E. PAGE IS OPENED FROM OPPPORTUNITY DETAIL PAGE
        if (opporId.startsWith('006'))
        {
            
            //SET BOOLEAN VALUE TO SHOW PAGE COMPONENTS(fromOpportunity VARIABLE IS USED ON VF PAGE) 
            fromOpportunity = true;
            oppId = opporId;
            
            system.debug('m here 1...');
            
            //GET THE LIST OF PREVIOUSLY LINKED ACCOUNTS WITH OPPORTUNITY ID
            oppRelAccList = [SELECT Account__c, Opportunity__c
                             FROM AH_Opportunity_Related_Account__c
                             WHERE Opportunity__c =: oppId];
            
            //CREATE A MAP TO HOLD OPPORTUNITY RELATED ACCOUNT
            for (AH_Opportunity_Related_Account__c relAcc : oppRelAccList)
            {
                mapExistingRelatedAcc.put(relAcc.Account__c, relAcc);
            }
            
            //GET PRIMARY ACCOUNT OF OPPORTUNITY
            primaryAccId = [SELECT AccountId FROM Opportunity WHERE Id =: oppId].AccountId;
            
            //IF NOT NULL, GET ALL CHILD ACCOUNTS OF PRIMARY ACCOUNT
            if (primaryAccId != null)
            {
                
                totalRecordsCount = [SELECT count() FROM Account 
                                  WHERE Parent.Id =: primaryAccId 
                                  OR Id =: primaryAccId 
                                  OR Id IN : mapExistingRelatedAcc.keySet()];
                
                
                system.debug('m here 2...'+totalRecordsCount);
                
                totalPages = Integer.valueOf(totalRecordsCount / paginationSize);
                Integer remainder = math.mod(totalRecordsCount, paginationSize);

                if (remainder != 0)
                {
                    totalPages = totalPages + 1;
                }

                system.debug(' **** Total no of pages = ' + totalPages);
                
                // MAP OF PAGE NO TO BC IDS
                pageNumToORAIDMap = new Map<Integer, List<String>>();
                List<String> bcIDList  = new List<String>();
                for (Integer i = 0; i < totalPages; i++)
                {
                    pageNumToORAIDMap.put(i, bcIDList);
                }
                
                
                
                //GET ACCOUNT INFORMATION OF OPPORTUNITY'S PRIMARY ACCOUNT, CHILD ACCOUNTS OF PRIMARY OPPORTUNITY ACCOUNT AND OPPORTUNITY'S EXISTING RELATED ACCOUNTS  
                relatedAccList = [SELECT Id, Name, AccountNumber, BillingAddress,
                                  BillingStreet, BillingCity, BillingState, BillingCountry, Phone
                                  FROM Account
                                  WHERE Parent.Id =: primaryAccId 
                                  //OR Id =: primaryAccId		// COMMENTED BY SHASHIAKNT ON - 11/08/2019 TO AVOID DISPLAYING SAME ACCOUNT WHEN RELATING WITH OPPORTUNITY
                                  OR Id IN : mapExistingRelatedAcc.keySet() ORDER BY Id 
                                  Limit : paginationSize];
                
                //ITERATE OVER ACCOUNT'S LIST AND CREATE A WRAPPER LIST TO DISPLAY ON VF PAGE
                for (Account acc : relatedAccList)
                {
                    
                    AccountWrapper accWrapperObj = new AccountWrapper();
                    accWrapperObj.accId = acc.Id;
                    accWrapperObj.accName = acc.Name;
                    accWrapperObj.accountObj = acc; 
                    
                    if (mapExistingRelatedAcc.containsKey(acc.Id))
                    {
                        accWrapperObj.isSelected = true;
                    }
                    else
                    {
                        accWrapperObj.isSelected = false;
                    }
                    
                    relatedAccWrapperList.add(accWrapperObj);
                    relatedAccWrapperMap.put(acc.Id, accWrapperObj);
                    
                }
                
                if (!relatedAccWrapperList.isEmpty())
                {
                    List<String> idList = new List<String>();
                    idList.add(relatedAccWrapperList[0].accId);
                    idList.add(relatedAccWrapperList[relatedAccWrapperList.size()-1].accId);
                    pageNumToORAIDMap.put(listNumber, idList);
                    
                    system.debug(' **** pageNumToORAIDMap = ' + pageNumToORAIDMap);
                    system.debug(' **** totalPages = ' + totalPages);
                }
                
            }
        }
        system.debug('m here 3...');
        
    }
    
    public void nextRefreshList(String pageType)
    {
        system.debug(' **** listNumber = ' + listNumber);
        system.debug(' **** pageNumToORAIDMap = ' + pageNumToORAIDMap);

        relatedAccList = new List<Account>();
        relatedAccWrapperList = new List<AccountWrapper>();
        relatedAccWrapperMap = new Map<Id, AccountWrapper>();
        
        //GET PRIMARY ACCOUNT OF OPPORTUNITY
        Id primaryAccId = [SELECT AccountId FROM Opportunity WHERE Id =: opportunityId].AccountId;
        
        List<String> IDList1 = new List<String>();
        
        if (!pageNumToORAIDMap.isEmpty())
        {
            if (pageType == 'Next')
            {
                IDList1 = pageNumToORAIDMap.get(listNumber - 1);
            }
            else 
            {
                if (pageType == 'Previous') 
                {
                    IDList1 = pageNumToORAIDMap.get(listNumber);
                }
            }
        }
        
        system.debug(' **** pageNumToORAIDMap = ' + pageNumToORAIDMap);
        
        Id firstID = IDList1[0];
        Id lastID = IDList1[IDList1.size() - 1];
        system.debug('firstID : '+firstID);
        system.debug('lastID : '+lastID);
        
        Set<Id> idSet = mapExistingRelatedAcc.keySet();
        
        String query = 'SELECT Id, Name, AccountNumber, BillingAddress, '+
                                  ' BillingStreet, BillingCity, BillingState, BillingCountry, Phone '+
                                  ' FROM Account '+
                                  ' WHERE (Parent.Id =: primaryAccId '+
                                  //' OR Id =: primaryAccId '+						// COMMENTED BY SHASHIAKNT ON - 11/08/2019 TO AVOID DISPLAYING SAME ACCOUNT WHEN RELATING WITH OPPORTUNITY
                                  ' OR Id IN : idSet ) ';
                                  
        
        if (lastID != null && pageType == 'Next')
        {
            query += ' AND Id >: lastID ';
        }
        else 
        {
            if (firstID != null && lastID != null && pageType == 'Previous')
            {
                if (paginationSize == 1)
                {
                    query += ' AND Id <: lastID ';
                }
                else 
                {
                    query += ' AND Id >=: firstID AND Id <=: lastID ';
                }
            }
        }
        
        query += ' ORDER BY Id LIMIT : paginationSize ';
        
        system.debug('next page query : '+query);
        
        relatedAccList = Database.query(query);
        
        //ITERATE OVER ACCOUNT'S LIST AND CREATE A WRAPPER LIST TO DISPLAY ON VF PAGE
        for (Account acc : relatedAccList)
        {
            
            AccountWrapper accWrapperObj = new AccountWrapper();
            accWrapperObj.accId = acc.Id;
            accWrapperObj.accName = acc.Name;
            accWrapperObj.accountObj = acc; 
            
            if (mapExistingRelatedAcc.containsKey(acc.Id))
            {
                accWrapperObj.isSelected = true;
            }
            else
            {
                accWrapperObj.isSelected = false;
            }
            
            relatedAccWrapperList.add(accWrapperObj);
            relatedAccWrapperMap.put(acc.Id, accWrapperObj);
            
        }

        if (!relatedAccWrapperList.isEmpty())
        {
            if (pageNumToORAIDMap.get(listNumber).isEmpty())
            {
                List<String> idList = new List<String>();
                idList.add(relatedAccWrapperList[0].accId);
                idList.add(relatedAccWrapperList[relatedAccWrapperList.size()-1].accId);

                pageNumToORAIDMap.put(listNumber, idList);
            }
            
            system.debug(' **** pageNumTobcliIDMap = ' + pageNumToORAIDMap);
        }
        
    }
    
    
    //FUNCTION: USED TO ADD ACCOUNT FROM LOOK-UP FIELD PRESENT ON VF PAGE, TO THE WRAPPER LIST IN ORDER TO SELECT TO RELATE TO OPPORTUNITY
    public void addAccount()
    {
        //IF LOOK-UP FIELD IS NOT NULL
        if (oppAccObj.Account__c != null)
        {
            Account ac = new Account();
            //WRAPPER LIST DOES NOT CONTAIN THIS ACCOUNT
            if (!relatedAccWrapperMap.containsKey(oppAccObj.Account__c))
            {
                //GET ACCOUNT INFORMATION AND ADD IT TO THE WRAPPER LIST AND MAP
                ac = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingCountry, Phone
                      FROM Account 
                      WHERE Id =: oppAccObj.Account__c];
                AccountWrapper accWrapperObj = new AccountWrapper();
                accWrapperObj.accName = ac.Name;
                accWrapperObj.accId = ac.Id;
                accWrapperObj.isSelected = false;
                accWrapperObj.accountObj = ac;
                relatedAccWrapperList.add(accWrapperObj);
                relatedAccWrapperMap.put(ac.Id, accWrapperObj);
            }
        }
    }
    
    //FUNCTION: TO RELATE SELECTED ACCOUNT TO OPPORTUNITY AND UN-RELATE DE-SELECTED ACCOUNTS TO OPPORTUNITY
    public PageReference relateToOpportunity()
    {
        
        //CREATE LISTS TO UPSERT/DELETE RELATED ACCOUNTS
        List<AH_Opportunity_Related_Account__c> oppAccListToUpsert = new List<AH_Opportunity_Related_Account__c>();
        List<AH_Opportunity_Related_Account__c> oppAccListToDelete = new List<AH_Opportunity_Related_Account__c>();
        
        //ITERATE OVER THE ACCOUNT WRAPPER LIST
        for (AccountWrapper accWrap : relatedAccWrapperList)
        {
            //IF MAP DOES NOT CONTAIN SELECTED ACCOUNT, THEN ONLY ADD TO UPSERT
            if (!mapExistingRelatedAcc.containsKey(accWrap.accId))
            {
                //IF ACCOUNT IS SELECTED
                if (accWrap.isSelected == true)
                {
                    //CREATE A NEW AH_Opportunity_Related_Account__c OBJECT TO BE INSERTED
                    AH_Opportunity_Related_Account__c oppRelAccObj = new AH_Opportunity_Related_Account__c();
                    oppRelAccObj.Account__c = accWrap.accId;
                    oppRelAccObj.Opportunity__c = oppId;
                    oppAccListToUpsert.add(oppRelAccObj);
                    mapExistingRelatedAcc.put(accWrap.accId, oppRelAccObj);
                }
            }
            else
            {
                //IF ACCOUNTS WAS PREVIOUSLY LINKED AND NOW DE-SELECTED
                if (mapExistingRelatedAcc.containsKey(accWrap.accId))
                {
                    AH_Opportunity_Related_Account__c relAccObj = new AH_Opportunity_Related_Account__c();
                    if (accWrap.isSelected == false)
                    {
                        relAccObj = mapExistingRelatedAcc.get(accWrap.accId); 
                        oppAccListToDelete.add(relAccObj);
                        mapExistingRelatedAcc.remove(accWrap.accId);
                    }
                }
            }
        }
        
        if (!oppAccListToUpsert.isEmpty())
        {
            Database.upsert(oppAccListToUpsert);
        }
        
        if (!oppAccListToDelete.isEmpty())
        {
            Database.delete(oppAccListToDelete);
        }
        
        //RETURN TO THE SAME PAGE
        PageReference pr = System.currentPageReference();
        pr.getParameters().put('oppId', oppId);
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Accounts successfully linked to opportunity.'));
        return pr;
        
    }
    
    //FUNCTION: TO RETURN TO OPPORTUNITY DETAIL PAGE
    public PageReference returnBack()
    {
        PageReference pr = new PageReference('/'+oppId);
        return pr;
    }
    
    //FUNCTION: TO STORE NEW AH_Opportunity_Related_Account__c RECORD FROM TAB/NEW BUTTON(NOT FROM OPPPORTUNITY'S DETAIL PAGE)
    public PageReference doSave()
    {
        PageReference pr = null;
        if (oppAccObj != null && oppAccObj.Account__c != null && oppAccObj.Opportunity__c != null)
        {
            insert oppAccObj;
            pr = new PageReference('/' + oppAccObj.Id);
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter values.'));
        }
        return pr;
    }
    
    
    //WRAPPER CLASS TO HOLD ACCOUNT INFORMATION
    public class AccountWrapper
    {
        public Boolean isSelected{get; set;}
        public String accName {get; set;}
        public Id accId {get; set;}
        public Account accountObj{get; set;}
    }
    
    
    // PAGINATION CODE ======================================================================
    public void next()																
    {
        //if (listOfListAccPrd.Size()-1 > listNumber)
        if (pageNumToORAIDMap.Size()-1 > listNumber)
        {
            ++listNumber;
            nextRefreshList('Next');
        }
    }
    
    public void previous()
    {
        if (0 < listNumber)
        {
            --listNumber; 
            nextRefreshList('Previous');
        }
    }
    
    public boolean gethasPrevious()
    {
        
        if (listNumber > 0)
        {
            return true; 
        } 
        
        return false;
        
    }
    
    public boolean gethasNext()
    {
        
        if (listNumber < pageNumToORAIDMap.Size() -1)
        {
            return true; 
        }
        
        return false;
        
    }
    
}