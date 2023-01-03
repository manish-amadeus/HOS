/****************************************************************************************
Name            : AH_LinkAccountWithProduct_Ext Class 
Author          : Ria Chawla
Created Date    : 04/02/2018
Last Mod Date   : 11/14/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Controller for 'AH_LinkAccountWithProduct' VF page 
                : Updated per NICC-039872
                : 
******************************************************************************************/
public class AH_LinkAccountWithProduct_Ext 
{

    public Transient List<AH_Opportunity_Related_Account__c> oppAccList; 
    public List<OpportunityLineItem> oppProductList {get; set;}
    public List<AH_Account_Product__c> accProdList {get; set;}
    public List<AccProdWrapper> accProdWrapList {get; set;}
    public List<List<AccProdWrapper>> listOfListAccPrd; 
    public List<SelectOption> selectedProdFamily {get; set;}
    public List<SelectOption> remProdFamily {get; set;}   
    private List<Opportunity> lstOppVerifyRoles = new List<Opportunity>();
    
    public Map<String, AH_Account_Product__c> accProdMapId;
    public Map<String, AccProdWrapper> selectedMap = new Map<String, AccProdWrapper>();
    private Map<Integer, List<String>> pageNumToORAIDMap;
    
    public Id opportunityId {get; set;}
        
    public String recordTypeId {get; set;}
    public String retURL {get; set;}
    public String globalQuanVal {get; set;}
    
    public Integer paginationSize {get; set;}
    public Integer listNumber {get; set;}
    public Integer totalPages {get; set;}
    public Integer limitForORA{get; set;}
    
    public Boolean disableSaveBtn {get; set;}
    public Boolean disableRefreshBtn {get; set;}
    public Boolean enableSynacProBtn {get; set;}
    public Boolean hidesyn {get; set;}
    public Boolean CheckAll {get; set;}
    public Boolean CheckAllPassProp {get; set;}
    public Boolean validValuesFlag;
    
    
    // CONSTRUCTOR
    public AH_LinkAccountWithProduct_Ext(ApexPages.StandardSetController stdCtrl)
    {
        validValuesFlag = true;
        CheckAll = false;
        listNumber = 0;
        PageReference pr = System.currentPageReference();
        
        // GET RETURN URL
        try
        {
            retURL = ApexPages.currentPage().getParameters().get('retURL');
        }
        catch (Exception e){}
        
        // STORE IN A STRING RETURN URL
        if (retURL != null)
        {
            opportunityId = retURL.substringAfter('/').substring(0, 15);
        }
        else
        {
            opportunityId = ApexPages.CurrentPage().getparameters().get('id');
        }
        
        selectedProdFamily = new List<SelectOption>();
        selectedProdFamily.add(new SelectOption('Subscription', 'Subscription')); 
        remProdFamily = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry p : ple)
        {
            if (p.getValue() != 'Subscription')
            {
                remProdFamily.add(new SelectOption(p.getValue(), p.getValue())); 
            }
            hidesyn = true;
        }
        
        Set<String> prodFamilySet = new Set<String>();
        
        for (SelectOption so : selectedProdFamily)
        {
            prodFamilySet.add(so.getValue());
        }
        
        paginationSize = 150;
        
        refreshList(opportunityId, 'Init');
        
        system.debug('accProdWrapList size : '+accProdWrapList.size());
        
        if (!accProdWrapList.isEmpty())
        {
            recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId();
            
            List<Opportunity> oppredtype = new List<Opportunity>([SELECT ID, RecordType.Id FROM Opportunity WHERE Id =: ApexPages.CurrentPage().getparameters().get('id')]);
            
            if (oppredtype.size() > 0 && oppredtype[0].RecordType.Id == recordTypeId)
            { 
                enableSynacProBtn = false;
            }  
            else
            {
                enableSynacProBtn = true;
            }
        }
    }
    
    
    public void checkPassiveProperties()
    {
        if (CheckAllPassProp)
        {
            for (AccProdWrapper acPrd : accProdWrapList)
            {
                // IF CHECKBOX IS SELECTED, PUT IN A MAP TO STORE PRODUCT WITH ITS QUANTITY
                if (acPrd.isSelected == true)
                {
                    acPrd.passiveProp = true;
                }
                else
                {
                    acPrd.passiveProp = false;
                }
            }
        }
    }
    
    public void applyToAllProp()
    {
        
        for (AccProdWrapper acPrd : accProdWrapList)
        {
            system.debug('acPrd.passiveProp : '+acPrd.passiveProp);
            // IF CHECKBOX IS SELECTED, PUT IN A MAP TO STORE PRODUCT WITH ITS QUANTITY
            if (acPrd.isSelected == true && acPrd.passiveProp == false)
            {
                acPrd.prodQuan = Integer.valueOf(globalQuanVal);
            }
        }
        calculateAvailableQuantity();
        globalQuanVal = null;
    }
    
    public void refreshList(Id opportunityId, String pageType)
    {
        listNumber = 0;
        globalQuanVal = null;
        
        //INITIALIZE VARIABLES
        accProdList = new List<AH_Account_Product__c>();
        accProdWrapList = new List<AccProdWrapper>();
        List<AH_Account_Product__c> ahAccProdList = new List<AH_Account_Product__c>();
        Map<String, Decimal> accProdMap = new Map<String, Decimal>();
        Map<String, Decimal> accProdMapQuan = new Map<String, Decimal>();
        accProdMapId = new Map<String, AH_Account_Product__c>();
        List<AggregateResult> sumOfQuantities = new List<AggregateResult>();
        Set<String> prodFamilySet = new Set<String>();
        oppProductList = new List<OpportunityLineItem>();
        listOfListAccPrd = new List<List<AccProdWrapper>>();
        
        // MAP OF PAGE NO TO BC IDS
        pageNumToORAIDMap = new Map<Integer, List<String>>();
        Integer totalRecords = 0;
        
        for (SelectOption so : selectedProdFamily)
        {
            prodFamilySet.add(so.getValue());
        }
        
        ApexPages.CurrentPage().getParameters().put('oppId', opportunityId);
        
        //GET ALL THE ACCOUNTS RELATED TO THAT OPPORTUNITY
        Integer cnt1 = [SELECT count() 
                        FROM AH_Opportunity_Related_Account__c
                        WHERE Opportunity__c =: opportunityId ];
        
        //GET ALL THE PRODUCTS PRESENT ON OPPORTUNITY
        Integer cnt2 = [SELECT count() 
                        FROM OpportunityLineItem
                        WHERE Opportunity.Id =: opportunityId
                        AND (Order_of_Delivery__c <= 1 OR Order_of_Delivery__c = null)
                        AND Product2.Family IN :prodFamilySet ];
        
        if(cnt2 == NULL || cnt2 == 0)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Either product is not addded on Opportunity OR Products don\'t satisfy the criteria '));
            return;
        }
        
        totalRecords = cnt1 * cnt2;
        totalPages = Integer.valueOf(totalRecords / paginationSize);
        Integer remainder = math.mod(totalRecords, paginationSize);
        
        if (remainder != 0)
        {
            totalPages = totalPages + 1;
        }
        
        system.debug(' **** totalRecords = ' + totalRecords);
        system.debug(' **** Total no of pages = ' + totalPages);
        
        List<String> ORAIDList  = new List<String>();
        for (Integer i = 0; i < totalPages; i++)
        {
            pageNumToORAIDMap.put(i, ORAIDList);
        }
        
        limitForORA = paginationSize / cnt2;
        system.debug('limitForORA : '+limitForORA);
        
        
        //GET ALL THE ACCOUNTS RELATED TO THAT OPPORTUNITY
        oppAccList = [SELECT ID, Account__r.Name 
                      FROM AH_Opportunity_Related_Account__c
                      //WHERE Opportunity__c =: opportunityId ORDER BY  Account__r.Name ASC LIMIT: limitForORA ];
                      WHERE Opportunity__c =: opportunityId ORDER BY  ID ASC LIMIT: limitForORA ];
        
        //GET ALL THE PRODUCTS PRESENT ON OPPORTUNITY
        oppProductList = [SELECT DeploymentInstance__c,Product2.Id, Product2.Name, Quantity, Product2.Family, Product2.Unit__c,
                          Product2.License_Type__c, Opportunity.Order_Status__c, Opportunity.Name 
                          FROM OpportunityLineItem
                          WHERE Opportunity.Id =: opportunityId
                          AND (Order_of_Delivery__c <= 1 OR Order_of_Delivery__c = null)
                          AND Product2.Family IN :prodFamilySet ORDER BY  Product2.Name  ASC ];
        
        
        //IF QUANTITY HAS ALREADY BEEN ASSIGNED, GET PREVIOUSLY ASSIGNED QUANTITY
        ahAccProdList = [SELECT Id, Account__c, Product__c, Opportunity__c, Quantity__c, Deployment_Instance__c
                         FROM AH_Account_Product__c  
                         WHERE Opportunity__c =: opportunityId 
                         ORDER BY Account__c ASC];
        
        //CREATE MAP TO HOLD PREVIOUSLY ASSIGNED QUANTITY
        //CREATE MAP TO UPDATE THE NEWLY ASSIGNED QUANTITY TO EXISTING RECORD
        for (AH_Account_Product__c accProd : ahAccProdList)
        {
            accProdMap.put(accProd.Account__c + '' + accProd.Product__c, accProd.Quantity__c);
            accProdMapId.put(accProd.Account__c + '' + accProd.Product__c + '' + accProd.Opportunity__c + '' + accProd.Deployment_Instance__c, accProd);
        }
        
        //GET PREVIOUSLY ASSIGNED QUANTITIES
        sumOfQuantities = [SELECT SUM(Quantity__c) sumQuan, Product__c, Opportunity__c
                           FROM AH_Account_Product__c
                           GROUP BY Product__c, Opportunity__c];
        
        //PUT IN A MAP PREVIOUSLY ASSIGNED QUANTITIES
        for (AggregateResult aggr : sumOfQuantities)
        {
            accProdMapQuan.put((Id)aggr.get('Opportunity__c') + '' + (Id)aggr.get('Product__c'), (Decimal)aggr.get('sumQuan'));
        }
        
        //ITERATE OVER RELATED ACCOUNTS AND PRODUCTS AND CREATE A WRAPPER LIST TO HOLD ACCOUNTS WITH PRODUCTS IN OREDER TO ASSIGN QUANTITIES
        for (AH_Opportunity_Related_Account__c relAcc : oppAccList)
        {
            for (OpportunityLineItem oli : oppProductList)
            {
                AccProdWrapper accProdWrap = new AccProdWrapper();
                accProdWrap.ORAId = relAcc.ID;
                accProdWrap.accId = relAcc.Account__c;
                accProdWrap.accName = relAcc.Account__r.Name;  
                accProdWrap.oppId = oli.OpportunityId;
                accProdWrap.passiveProp = false;
                accProdWrap.prodId  = oli.Product2.Id;
                accProdWrap.prodName = oli.Product2.Name;
                accProdWrap.oppName = oli.Opportunity.Name;
                accProdWrap.dipId = oli.DeploymentInstance__c;
                accProdWrap.isSelected = false;
                
                system.debug('oli.id : '+oli.id);
                system.debug('oli.Quantity : '+oli.Quantity);
                
                //if(accProdWrap.oppId == '0066C0000062oKrQAI'  && oli.id == '00k6C000003uVJH')
                //{
                
                if (!accProdMapQuan.isEmpty() && accProdMapQuan.containsKey(accProdWrap.oppId + '' + accProdWrap.prodId))
                {
                    system.debug('accProdMapQuan.get(accProdWrap.oppId - accProdWrap.prodId) : '+accProdMapQuan.get(accProdWrap.oppId + '' + accProdWrap.prodId));
                    accProdWrap.availableQuan = oli.Quantity - (accProdMapQuan.get(accProdWrap.oppId + '' + accProdWrap.prodId));
                    system.debug('accProdWrap.availableQuan : '+accProdWrap.availableQuan);
                    accProdWrap.totalAvailableQuan = oli.Quantity - (accProdMapQuan.get(accProdWrap.oppId + '' + accProdWrap.prodId));
                    system.debug('accProdWrap.totalAvailableQuan : '+accProdWrap.totalAvailableQuan);
                }
                else 
                {
                    system.debug('in else');
                    if (!accProdMapQuan.containsKey(accProdWrap.oppId + '' + accProdWrap.prodId))
                    {
                        accProdWrap.availableQuan = oli.Quantity;
                        accProdWrap.totalAvailableQuan = oli.Quantity;
                    }
                }
                
                if (!accProdMap.isEmpty() && accProdMap.containsKey(accProdWrap.accId + '' + accProdWrap.prodId))
                {
                    accProdWrap.prodQuan = 0.0;
                    accProdWrap.existingAssignedQuan = accProdMap.get(accProdWrap.accId + '' + accProdWrap.prodId);
                }
                else
                {
                    accProdWrap.prodQuan = 0.0;
                }
                
                accProdWrapList.add(accProdWrap);
                //}
            }
        }
        
        system.debug('accProdWrapList size : '+accProdWrapList.size());
        
        if (!accProdWrapList.isEmpty())
        {
            List<String> idList = new List<String>();
            idList.add(accProdWrapList[0].ORAId);
            idList.add(accProdWrapList[accProdWrapList.size()-1].ORAId);
            pageNumToORAIDMap.put(listNumber, idList);
            //system.debug(' **** pageNumTobcliIDMap = ' + pageNumToORAIDMap);
        }
    }
    
    
    public void nextRefreshList(Id opportunityId, String pageType)
    {
        CheckAll = false;
        CheckAllPassProp = false;
        globalQuanVal = null;
        
        //INITIALIZE VARIABLES
        accProdList = new List<AH_Account_Product__c>();
        accProdWrapList = new List<AccProdWrapper>();
        List<AH_Account_Product__c> ahAccProdList = new List<AH_Account_Product__c>();
        Map<String, Decimal> accProdMap = new Map<String, Decimal>();
        Map<String, Decimal> accProdMapQuan = new Map<String, Decimal>();
        accProdMapId = new Map<String, AH_Account_Product__c>();
        List<AggregateResult> sumOfQuantities = new List<AggregateResult>();
        Set<String> prodFamilySet = new Set<String>();
        oppProductList = new List<OpportunityLineItem>();
        listOfListAccPrd = new List<List<AccProdWrapper>>();
        
        for (SelectOption so : selectedProdFamily)
        {
            prodFamilySet.add(so.getValue());
        }
        
        ApexPages.CurrentPage().getParameters().put('oppId', opportunityId);
        
        List<String> ORAIDList1 = new List<String>();
        if (!pageNumToORAIDMap.isEmpty())
        {
            if (pageType == 'Next')
            {
                ORAIDList1 = pageNumToORAIDMap.get(listNumber - 1);
            }
            else 
            {
                if (pageType == 'Previous') 
                {
                    ORAIDList1 = pageNumToORAIDMap.get(listNumber);
                }
            }
        }
        
        system.debug(' **** pageNumTobcliIDMap = ' + pageNumToORAIDMap);
        
        Id firstID = ORAIDList1[0];
        Id lastID = ORAIDList1[ORAIDList1.size() - 1];
        
        
        //GET ALL THE ACCOUNTS RELATED TO THAT OPPORTUNITY
        String query = 'SELECT ID, Account__r.Name '+
            ' FROM AH_Opportunity_Related_Account__c '+
            ' WHERE Opportunity__c =: opportunityId ';
        
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
        
        //query += ' ORDER BY Account__r.Name ASC LIMIT: limitForORA ';
        query += ' ORDER BY ID ASC LIMIT: limitForORA ';
        
        oppAccList = Database.query(query);
        
        //GET ALL THE PRODUCTS PRESENT ON OPPORTUNITY
        oppProductList = [SELECT DeploymentInstance__c,Product2.Id, Product2.Name, Quantity, Product2.Family, Product2.Unit__c,
                          Product2.License_Type__c, Opportunity.Order_Status__c, Opportunity.Name 
                          FROM OpportunityLineItem
                          WHERE Opportunity.Id =: opportunityId
                          AND (Order_of_Delivery__c <= 1 OR Order_of_Delivery__c = null)
                          AND Product2.Family IN :prodFamilySet ORDER BY  Product2.Name  ASC ];
        
        
        //IF QUANTITY HAS ALREADY BEEN ASSIGNED, GET PREVIOUSLY ASSIGNED QUANTITY
        ahAccProdList = [SELECT Id, Account__c, Product__c, Opportunity__c, Quantity__c, Deployment_Instance__c
                         FROM AH_Account_Product__c  
                         WHERE Opportunity__c =: opportunityId 
                         ORDER BY Account__c ASC];
        
        //CREATE MAP TO HOLD PREVIOUSLY ASSIGNED QUANTITY
        //CREATE MAP TO UPDATE THE NEWLY ASSIGNED QUANTITY TO EXISTING RECORD
        for (AH_Account_Product__c accProd : ahAccProdList)
        {
            accProdMap.put(accProd.Account__c + '' + accProd.Product__c, accProd.Quantity__c);
            accProdMapId.put(accProd.Account__c + '' + accProd.Product__c + '' + accProd.Opportunity__c + '' + accProd.Deployment_Instance__c, accProd);
        }
        
        //GET PREVIOUSLY ASSIGNED QUANTITIES
        sumOfQuantities = [SELECT SUM(Quantity__c) sumQuan, Product__c, Opportunity__c
                           FROM AH_Account_Product__c
                           GROUP BY Product__c, Opportunity__c];
        
        //PUT IN A MAP PREVIOUSLY ASSIGNED QUANTITIES
        for (AggregateResult aggr : sumOfQuantities)
        {
            accProdMapQuan.put((Id)aggr.get('Opportunity__c') + '' + (Id)aggr.get('Product__c'), (Decimal)aggr.get('sumQuan'));
        }
        
        //ITERATE OVER RELATED ACCOUNTS AND PRODUCTS AND CREATE A WRAPPER LIST TO HOLD ACCOUNTS WITH PRODUCTS IN OREDER TO ASSIGN QUANTITIES
        for (AH_Opportunity_Related_Account__c relAcc : oppAccList)
        {
            for (OpportunityLineItem oli : oppProductList)
            {
                AccProdWrapper accProdWrap = new AccProdWrapper();
                accProdWrap.ORAId = relAcc.ID;
                accProdWrap.accId = relAcc.Account__c;
                accProdWrap.accName = relAcc.Account__r.Name;  
                accProdWrap.oppId = oli.OpportunityId;
                accProdWrap.prodId  = oli.Product2.Id;
                accProdWrap.prodName = oli.Product2.Name;
                accProdWrap.oppName = oli.Opportunity.Name;
                accProdWrap.dipId = oli.DeploymentInstance__c;
                accProdWrap.isSelected = false;
                
                if (!accProdMapQuan.isEmpty() && accProdMapQuan.containsKey(accProdWrap.oppId + '' + accProdWrap.prodId))
                {
                    accProdWrap.availableQuan = oli.Quantity - (accProdMapQuan.get(accProdWrap.oppId + '' + accProdWrap.prodId));
                    accProdWrap.totalAvailableQuan = oli.Quantity - (accProdMapQuan.get(accProdWrap.oppId + '' + accProdWrap.prodId));
                }
                else 
                {
                    if (!accProdMapQuan.containsKey(accProdWrap.oppId + '' + accProdWrap.prodId))
                    {
                        accProdWrap.availableQuan = oli.Quantity;
                        accProdWrap.totalAvailableQuan = oli.Quantity;
                    }
                }
                
                if (!accProdMap.isEmpty() && accProdMap.containsKey(accProdWrap.accId + '' + accProdWrap.prodId))
                {
                    //accProdWrap.prodQuan = 1.0;
                    accProdWrap.prodQuan = 0.0;
                    accProdWrap.existingAssignedQuan = accProdMap.get(accProdWrap.accId + '' + accProdWrap.prodId);
                }
                else
                {
                    //accProdWrap.prodQuan = 1.0;
                    accProdWrap.prodQuan = 0.0;
                }
                
                accProdWrapList.add(accProdWrap);
            }
        }
        
        system.debug('accProdWrapList size : '+accProdWrapList.size());
        
        if (!accProdWrapList.isEmpty())
        {
            List<String> idList = new List<String>();
            idList.add(accProdWrapList[0].ORAId);
            idList.add(accProdWrapList[accProdWrapList.size()-1].ORAId);
            pageNumToORAIDMap.put(listNumber, idList);
            //system.debug(' **** pageNumTobcliIDMap = ' + pageNumToORAIDMap);
        }
        
        if (pageNumToORAIDMap.get(listNumber).isEmpty())
        {
            List<String> idList = new List<String>();
            idList.add(accProdWrapList[0].ORAId);
            idList.add(accProdWrapList[accProdWrapList.size()-1].ORAId);
            pageNumToORAIDMap.put(listNumber, idList);
        }
        
    }
    
    
    public void syncAccountProducts()
    {
        
        // SYNC ACCOUNT & PRODUCTS WHEN ADDED AFTER OPP CLOSED WON & RECORD TYPE CHNAGED TO SALES ORDER
        
        system.debug(' *** ENTERING AH_LinkAccountWithProduct_Ext.syncAccountProducts() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<Opportunity> existingoppLst = new List<Opportunity>();
        
        existingoppLst = [SELECT Id, AccountId, Account.Name, CreatedDate,  StageName, CloseDate
                          FROM Opportunity 
                          WHERE StageName = 'Closed Won' 
                          AND RecordType.Name = 'Sales Order' 
                          AND Id =: opportunityId];
        
        if (!existingoppLst.isEmpty())
        {
            try
            {
                AH_Opportunity_FUNCTIONS.createUpdateDIForOLI_New(existingoppLst,true);
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Account to Product synchronization has been done successfully. Please click Return button to get back to Opportunity Record Detail Page.'));
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + '\n Line: ' + e.getLineNumber() + '\n Cause:' + e.getCause())); 
            }
        }
        else 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No records selected for synchronization. '));
        } 
        
        system.debug(' *** EXITING AH_LinkAccountWithProduct_Ext.syncAccountProducts() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void calculateAvailableQuantity()
    {
        system.debug('in calculateAvailableQuantity method...'+accProdWrapList.size());
        
        // FUNCTION: TO CALCULATE AVAILABLE QUANTITY WHEN USER ENTERS QUNATITY IN TEXT BOX
        
        // METHOD VARIABLES
        Map<Id, Decimal> prdIdQuanMap = new Map<Id, Decimal>();
        Map<Id, Decimal> prdIdQuanMapSub = new Map<Id, Decimal>();
        
        // ITEARTE OVER WRAPPER LIST
        for (AccProdWrapper acPrd : accProdWrapList)
        {
            // IF CHECKBOX IS SELECTED, PUT IN A MAP TO STORE PRODUCT WITH ITS QUANTITY
            if (acPrd.isSelected == true && acPrd.passiveProp == false)
            {
                system.debug('acPrd.prodQuan : '+acPrd.prodQuan);
                selectedMap.put(acPrd.accId + '' + acPrd.prodId, acPrd);
                //IF MAP ALREADY CONTAINS PRODUCT ID, ADD PREVIOUS QUANTITY TO THE NEW QUANITY
                if (prdIdQuanMap.containsKey(acPrd.prodId))
                {
                    Decimal quan = prdIdQuanMap.get(acPrd.prodId);
                    if (acPrd.prodQuan != null)
                    {
                        quan += acPrd.prodQuan;
                        prdIdQuanMap.put(acPrd.prodId, quan);
                    }
                }
                else // ELSE PUT THE QUANTITY
                {
                    prdIdQuanMap.put(acPrd.prodId, acPrd.prodQuan);
                }
            }
            else //IF CHECKBOX IS UNCHECKED, REMOVE THE ASSIGNED QUANTITY
            {
                if (!prdIdQuanMap.containsKey(acPrd.prodId))
                {
                    prdIdQuanMapSub.put(acPrd.prodId, acPrd.prodQuan);
                }
                acPrd.prodQuan = 0.0;
            }
        }
        
        system.debug('prdIdQuanMap : ' + prdIdQuanMap);
        
        // ITERATE OVER WRAPPER LIST TO ADD/SUBTRACT ASSIGNED QUANTITIES
        for (AccProdWrapper acPrdWrap : accProdWrapList)
        {
            if (prdIdQuanMap.containsKey(acPrdWrap.prodId))
            {
                Decimal quan = prdIdQuanMap.get(acPrdWrap.prodId);
                system.debug('Entered Quantity : '+quan);
                system.debug('acPrdWrap.totalAvailableQuan : '+acPrdWrap.totalAvailableQuan);
                
                if (acPrdWrap.totalAvailableQuan >= quan )
                {
                    acPrdWrap.availableQuan = acPrdWrap.totalAvailableQuan - quan;
                    system.debug('in if..'+acPrdWrap.availableQuan);
                    validValuesFlag = true;
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Entered quantity is not valid'));
                    system.debug('in inner else..');
                    validValuesFlag = false;
                }
            }
            else 
            {
                system.debug('in outer else');
                if (prdIdQuanMapSub.containsKey(acPrdWrap.prodId))
                {
                    Decimal quan2 = prdIdQuanMapSub.get(acPrdWrap.prodId);
                    if (quan2 != null)
                    {
                        if (acPrdWrap.availableQuan < acPrdWrap.totalAvailableQuan)
                        {
                            acPrdWrap.availableQuan = acPrdWrap.availableQuan + quan2;
                        }
                    }
                }
            }
        }
    }
    
    // FUNCTION: TO STORE ACCOUNT, OPPORTUNITY, PRODUCT ALONG WITH QUANTITIES, TO REFERENCE THIS OBJECT ON DI CREATION
    public PageReference doSave()
    {
        
        // METHOD VARIABLES
        List<AH_Account_Product__c> accProductToInsert = new List<AH_Account_Product__c>();
        List<AH_Account_Product__c> accProductToDelete = new List<AH_Account_Product__c>();
        String message = '';
        disableRefreshBtn = true;
        
        system.debug('In doSave => validValuesFlag : '+validValuesFlag);
        
        if(validValuesFlag)
        {
            
            //ITERATE OVER WRAPPER LIST TO STORE QUANTITY VALUES
            for (AccProdWrapper accProdWrap : accProdWrapList)
            {
                
                AH_Account_Product__c accProdWObj;
                
                //IF CHECKBOX IS SELECTED, CHECK IF QUANTITY WAS PREVIOUSLY ASSIGNED OR TO CREATE A NEW OBJECT
                if (accProdWrap.isSelected == true)
                {
                    
                    if (!accProdMapId.isEmpty() && accProdMapId.containsKey(accProdWrap.accId + '' + accProdWrap.prodId + '' + accProdWrap.oppId))
                    {
                        accProdWObj = accProdMapId.get(accProdWrap.accId + '' + accProdWrap.prodId + '' + accProdWrap.oppId);
                    }
                    else
                    {
                        accProdWObj = new AH_Account_Product__c();
                    }
                    
                    accProdWObj.Account__c = accProdWrap.accId;
                    accProdWObj.Product__c = accProdWrap.prodId;
                    
                    if (accProdWObj.Quantity__c != null && accProdWrap.totalAvailableQuan >= accProdWrap.prodQuan)
                    {
                        accProdWObj.Quantity__c = accProdWObj.Quantity__c + accProdWrap.prodQuan;
                        accProdWrap.totalAvailableQuan = accProdWrap.totalAvailableQuan - accProdWrap.prodQuan;
                    }
                    else
                    {
                        if (accProdWrap.totalAvailableQuan >= accProdWrap.prodQuan)
                        {
                            accProdWObj.Quantity__c = accProdWrap.prodQuan;
                            accProdWrap.totalAvailableQuan = accProdWrap.totalAvailableQuan - accProdWrap.prodQuan;
                        }
                        else
                        {
                            message = 'Please enter valid quantity.';  
                            system.debug('message : '+message);
                            disableSaveBtn = true;
                        }
                    }
                    
                    accProdWObj.Opportunity__c = accProdWrap.oppId;
                    
                    if (accProdWObj.Quantity__c != 0.0 ||  accProdWrap.passiveProp == true) 
                    {
                        accProductToInsert.add(accProdWObj);
                    }
                    
                }
                
            }
            
            
            //IF LIST IS NOT EMPTY, INSERT
            if (!accProductToInsert.isEmpty())
            {
                try
                {
                    Database.upsert(accProductToInsert);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Saved successfully. Please click Refresh button to get updated quantities.'));
                    disableSaveBtn = false;
                    disableRefreshBtn = false;
                }
                catch (Exception e)
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + '\n Line: ' + e.getLineNumber() + '\n Cause:' + e.getCause())); 
                }
            } 
            else // ELSE SHOW MESSAGE TO SELECT RECORDS TO SAVE
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No records selected to save.'));
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Entered quantity is not valid.'));
        }
        
        return null;
        
    }
    
    public PageReference doRefresh()
    {
        CheckAllPassProp = false;
        CheckAll = false;
        globalQuanVal = null;
        //FUNCTION: TO REFRESH TO CHECK AVAILABLE QUANTITY
        
        for (AccProdWrapper accProdWrap : accProdWrapList)
        {
            accProdWrap.isSelected = false;
        }
        
        refreshList(opportunityId, '');
        
        return null;
        
    }
    
    public PageReference returnBack()
    {
        // FUNCTION: METHOD TO RETURN BACK TO THE OPPORTUNITY DETAIL PAGE
        PageReference pr = new PageReference('/'+opportunityId);
        return pr;
    }
    
    //FUNCTION: METHOD TO CLEAR VALUES
    public PageReference refreshPage()
    {
        CheckAllPassProp = false;
        CheckAll = false;
        globalQuanVal = null;
        
        refreshList(opportunityId, '');
        PageReference pr = System.currentPageReference();
        
        pr.setRedirect(false);
        disableRefreshBtn = true;
        
        return pr;
        
    }
    
    public PageReference refreshProducts()
    {
        CheckAllPassProp = false;
        CheckAll = false;
        globalQuanVal = null;
        
        //FUNCTION: METHOD TO CLEAR VALUES
        
        Set<String> prodFamilySet = new Set<String>();
        hidesyn = false;
        
        for (SelectOption so : selectedProdFamily)
        {
            prodFamilySet.add(so.getValue());
        }
        
        refreshList(opportunityId, '');
        PageReference pr = System.currentPageReference();
        pr.setRedirect(false);
        
        return pr;
    }
    
    
    public PageReference deleteProductLinking()
    {
        
        //	REMOVE AC_PRODUCTS AND DI TO ALI LINKING
        
        List<Id> dipIDlst = new List<Id>();
        set<String> accIdSet = new set<String>();
        set<String> oppIdSet = new set<String>();
        set<String> prodIdSet = new set<String>();
        
        system.debug('in deleteProductLinking .. accProdWrapList size : '+accProdWrapList.size());
        
        // ITERATE OVER WRAPPER LIST TO  DELETE ACCOUNT TO PRODUCT LINKING.
        for (AccProdWrapper accProdWrap : accProdWrapList)
        {
            if (accProdWrap.isSelected)
            {
                accIdSet.add(accProdWrap.accId);
                oppIdSet.add(accProdWrap.oppId);
                prodIdSet.add(accProdWrap.prodId);
            }
        }
        
        List<AH_Account_Product__c> acprodlst = new List<AH_Account_Product__c>();
        
        acprodlst = [SELECT Id, Deployment_Instance__c 
                     FROM AH_Account_Product__c 
                     WHERE Account__c IN : accIdSet 
                     AND Opportunity__c IN : oppIdSet 
                     AND Product__c IN : prodIdSet];
        
        if (!acprodlst.isEmpty() && acprodlst != null)
        {
            
            for (AH_Account_Product__c acp : acprodlst)
            {
                if (acp.Deployment_Instance__c != null)
                {
                    dipIDlst.add(acp.Deployment_Instance__c);
                }
            }               
            
            try 
            {
                
                boolean isDeleted1 = false;
                boolean isDeleted2 = false;
                
                if (!acprodlst.isEmpty())
                {
                    Database.Delete(acprodlst);
                    isDeleted1 = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Assigned Quantity and DI to ALI Linking has been Removed successfully.'));
                }
                
                if (!dipIDlst.isEmpty())
                {
                    Database.Delete(dipIDlst);
                    isDeleted2 = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Assigned Quantity and DI to ALI Linking has been Removed successfully. Please click Refresh button to get updated Record List.'));
                }
                
                if (isDeleted1 == true && isDeleted2 == true)
                {
                    // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'DI on Account has been Manually Removed . Please click Remove button to get updated Record List.'));
                    disableSaveBtn = False;
                }  
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + '\n Line: ' + e.getLineNumber() + '\n Cause:' + e.getCause())); 
            }
            
        } 
        else // ELSE SHOW MESSAGE TO SELECT RECORDS TO SAVE
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No records selected to Remove.'));
        }
        
        disableRefreshBtn = false;
        
        return null;
        
    }    
    
    // PAGINATION CODE 
    public void next()																
    {
        if (pageNumToORAIDMap.Size()-1 > listNumber)
        {
            ++listNumber;
            nextRefreshList(opportunityId, 'Next');
        }
    }
    
    public void previous()
    {
        if (0 < listNumber)
        {
            --listNumber;
            nextRefreshList(opportunityId, 'Previous');
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
    
    // WRAPPER CLASS 
    public class AccProdWrapper
    {
        public Id ORAId {get; set;}
        public Boolean passiveProp {get; set;}
        public Boolean isSelected {get; set;}
        public Id accId {get; set;}
        public Id prodId {get; set;}
        public Id oppId {get; set;}
        public ID dipId {get;set;}
        public String oppName {get; set;}
        public String accName {get; set;}
        public String prodName {get; set;}
        public Decimal prodQuan {get; set;}
        public Decimal availableQuan {get; set;}
        public Decimal totalAvailableQuan {get; set;}
        public Decimal existingAssignedQuan {get; set;}
    }
    
}