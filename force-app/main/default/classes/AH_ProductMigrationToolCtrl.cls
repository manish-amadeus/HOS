/************************************************************************************************
Name            : AH_ProductMigrationToolCtrl Class
Author          : Sean Harris
Created Date    : 04/16/2019
Last Mod Date   : 08/20/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-034281
Description     : Controller class for AH_ProductMigrationTool VF Page
                : 
*************************************************************************************************/
public with sharing class AH_ProductMigrationToolCtrl 
{
    
    // PUBLIC VARIABLES ======================================
    
    // OBJECTS 
    public Account a {get; set;} 
    public Opportunity o {get; set;} 
	public Id selectedProductId {get; set;} 
    
    // COLLECTIONS
    public List<productMigration> lstPMs {get; set;} 
    public List<cutOffDate> lstCutOffDates {get; set;}     
    public List<lineItem> lstLineItems {get; set;} 
	public Map<Id, List<SelectOption>> mapAcctId2PickLists {get; set;} 

    // STRINGS
    public String saveMsg {get; set;}
    public String saveMsgStyle {get; set;}
    public String toastMsg {get; set;}
    public String selectedAccount {get; set;} 
    public String toProduct {get; set;} 
    public String strMasterCutOffDate {get; set;} 
    
    // NUMERICS
//    public Integer iInsertAfter {get; set;} 
    public Integer iRemoveLine {get; set;} 
    public Integer iSelectedElement {get; set;} 
    
	// BOOLEANS 
    public boolean displayConfirmation {get; set;}
    public boolean showProductSelector {get; set;}
    public boolean saveShow {get; set;}   
    public Boolean isSuccess {get; set;}
    public Boolean showRedMsg {get; set;}
    public Boolean bIsFullScreen {get; set;} 
    public Boolean bShowSidebar {get; set;} 
    public Boolean bShowHeader {get; set;} 
    public Boolean isPendingCommit {get; set;}
    public Boolean isCutoffDateMode {get; set;}
    public Boolean checkAll {get; set;}    
    
	// PRIVATE VARIABLES ====================================
    

    
    public AH_ProductMigrationToolCtrl()
    {
        
        system.debug(' *** ENTERING AH_ProductMigrationToolCtrl() - CONSTRUCTOR');        
        
        // VARIABLE INITIALIZATIONS
		initVariables();
        
        // IF THE PAGE HAS AN OPPORTUNITY ID IN URL PARAM        
        if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
        {  

            if (ApexPages.CurrentPage().getParameters().containsKey('cod')) 
            {              
                isCutoffDateMode = true;
            }
            
            // QUERY FOR OPPORTUNITY
            o = [SELECT Id, Name, Opportunity_Number__c, AccountId, pse__Primary_Project__c, Project_Name__c FROM Opportunity WHERE Id =: ApexPages.CurrentPage().getParameters().get('id')];
            
            // QUERY FOR ACCOUNT
            a = [SELECT Id, Name, AccountNumber FROM Account WHERE Id =: o.AccountId];
                     
            if (isCutoffDateMode)
            {
                loadProductMigrations();
            }
            else
            {
                loadProducts();
            }

        }
        
        system.debug(' *** EXITING AH_ProductMigrationToolCtrl() - CONSTRUCTOR');        
        
    }
    
    // ================================================================================================================================
	//  FUNCTIONS & METHODS ===========================================================================================================    
    // ================================================================================================================================

    private void initVariables()
    {
        
        // STRINGS	
        saveMsg = '';	
        saveMsgStyle = 'color:green;'; 
        toastMsg = 'Multiple From Products mapped';	
        selectedAccount = '';	
        toProduct = '';	   
    	strMasterCutOffDate = system.date.today().format();
        
        // NUMERICS
        iRemoveLine = 0;
        iSelectedElement = 0;
        
        // BOOLEANS 
        displayConfirmation = false;
        showProductSelector = false;
        saveShow = false; 
        isSuccess = false;
        showRedMsg = false;
        bIsFullScreen = false; 
        bShowSidebar = true; 
        bShowHeader = true; 
		isPendingCommit = false;
        isCutoffDateMode = false;
  
    }

    
    // MAPPING GRID METHODS
    private void loadProducts()
    {
        
        // CREATE FRESH INSTANCE OF MAIN LIST
        lstPMs = new List<productMigration>();
        
        // FILL A MAP OF AH_Product_Migration__c RECORDS WITH A KEY MADE UP OF AccountId + '-' + Product2Id
        Map<String, AH_Product_Migration__c> mapA2PIds = new Map<String, AH_Product_Migration__c>(); 
        List<AH_Product_Migration__c> lstPrdMs = new List<AH_Product_Migration__c>([SELECT Id, Opportunity__c, CreatedDate, Cut_Off_Date__c, 
                                                                                    Account__c, Account__r.Name, Account__r.AccountNumber, 
                                                                                    From_Product__c, From_Product__r.ProductCode, From_Product__r.Name, 
                                                                                    To_Product__c, To_Product__r.ProductCode, To_Product__r.Name 
                                                                                    FROM AH_Product_Migration__c 
                                                                                    WHERE Opportunity__c =: o.Id
                                                                                   	ORDER BY Account__r.Name, To_Product__r.ProductCode]); 
        for (AH_Product_Migration__c apm : lstPrdMs)
        {
            mapA2PIds.put(apm.Account__c + '-' + apm.To_Product__c, apm);
        }
        
        // GET A LIST OF ALL "NON-SERVICES" OPPORTUNITY LINE ITEM RECORDS 
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>([SELECT Id, Product2Id, Product2.Name, ProductCode, Product2.Solution_Domain_Global__c 
                                                                           FROM OpportunityLineItem 
                                                                           WHERE OpportunityId =: o.Id 
                                                                           AND Product2.Revenue_Category__c != 'Services'
                                                                           ORDER BY ProductCode]); 
        
        // GET A LIST OF ALL "NON-SERVICES" AH_Account_Product__c ITEM RECORDS 
        List<AH_Account_Product__c> lstAPs = new List<AH_Account_Product__c>([SELECT Id, Account__c, Account__r.Name, Product__c, Product__r.Name, Product__r.ProductCode, 
                                                                              Product__r.Solution_Domain_Global__c, Quantity__c 
                                                                              FROM AH_Account_Product__c 
                                                                              WHERE Opportunity__c =: o.Id 
                                                                              AND Product__r.Revenue_Category__c != 'Services'
                                                                              ORDER BY Account__r.Name, Product__r.ProductCode]);
        
        // FILL LIST OF DISTINCT RELATED ACCOUNT IDS 
        Map<Id, Id> mapAccountIds = new Map<Id, Id>();
		mapAccountIds.put(a.Id, a.Id);
        for (AH_Account_Product__c ap : lstAPs)   
        {
            mapAccountIds.put(ap.Account__c, ap.Account__c);
        }

        // FILL A LIST OF ACTIVE "NON-SERVICE" DEPLOYMENT INSTANCES
        List<Asset> lstAssets = new List<Asset>([SELECT Id, Product2Id, Product2.ProductCode, Product2.Name, AccountId, Account.Name, Account.AccountNumber 
                                                 FROM Asset 
                                                 WHERE Status != 'Inactive' 
                                                 AND Product2.Revenue_Category__c != 'Services' 
                                                 AND AccountId IN : mapAccountIds.keySet()
                                                 ORDER BY Product2.ProductCode]);
        
        // FILL A LIST OF "NON-SERVICE" ACTIVITY LINE ITEMS
        List<Activity_Line_Item__c> lstALIs = new List<Activity_Line_Item__c>([SELECT Id, Name, Product__c, Product__r.ProductCode, Product__r.Name, Account__c, Account__r.Name, 
                                                                               Account__r.AccountNumber, Billing_Contract__r.Account__c  
                                                                               FROM Activity_Line_Item__c 
                                                                               WHERE Product__r.Revenue_Category__c != 'Services' 
                                                                               AND Billing_Contract__r.Account__c IN : mapAccountIds.keySet()
                                                                               ORDER BY Product__r.ProductCode]);
        
        // LOOP THROUGH ALL GATHERED ACCOUNT IDS AND FILL A MAP WITH List<SelectOption> COLLECTIONS USING THE ACCOUNT ID MAP KEY
        // END RESULT IS TO HAVE A DISTINCT SELECTION OF ACTIVE DEPLOYMENT INSTANCES & ACTIVITY LINE ITEMS PER ACCOUNT
        // List<SelectOption> COLLECTION: Product2.Id (Value), Product2.ProductCode + ': ' + Product2.Name (Label)
        mapAcctId2PickLists = new Map<Id, List<SelectOption>>();
		
        for (Id a : mapAccountIds.keySet())
        {
            
            List<SelectOption> lstSelOpt = new List<SelectOption>();
            lstSelOpt.add(new SelectOption('aEP0d000000FUCT', 'NOT MAPPED')); 
            
            for (Asset di : lstAssets)
            {
                if (di.AccountId == a)
                {
                    lstSelOpt.add(new SelectOption(di.Product2Id, di.Product2.ProductCode + ': ' + di.Product2.Name)); 
                }
            }
            
            for (Activity_Line_Item__c ali : lstALIs)
            {
                if (ali.Billing_Contract__r.Account__c == a)
                {
                    SelectOption so = new SelectOption(ali.Product__c, ali.Product__r.ProductCode + ': ' + ali.Product__r.Name);
                    if (!lstSelOpt.contains(so))
                    {
                        lstSelOpt.add(so); 
                    }                    
                }
            }
            
            mapAcctId2PickLists.put(mapAccountIds.get(a), lstSelOpt);
            
        }

        // LOOP THROUGH LIST OF "NON-SERVICES" OPPORTUNITY LINE ITEM RECORDS CREATING AND FILLING A LIST OF productMigration WRAPPER CLASS ITEMS
        for (OpportunityLineItem oli : lstOLIs)
        {
            
            productMigration pm = new productMigration(0, a.Id, a.Name, oli.Product2Id, oli.ProductCode, oli.Product2.Name, oli.Product2.Solution_Domain_Global__c, null, true, false, mapAcctId2PickLists.get(a.Id));

            if (mapA2PIds.containsKey(pm.AccountId + '-' + pm.toProductId))
            {
                pm.ProductMigrationId = mapA2PIds.get(pm.AccountId + '-' + pm.toProductId).Id;
                pm.fromProductId = mapA2PIds.get(pm.AccountId + '-' + pm.toProductId).From_Product__c;                
            }
            
            lstPMs.add(pm); 

        }        

        // LOOP THROUGH LIST OF "NON-SERVICES" AH_Account_Product__c RECORDS CREATING AND ADDING TO A LIST OF productMigration WRAPPER CLASS ITEMS
        for (AH_Account_Product__c ap : lstAPs)   
        {
            
            productMigration pm = new productMigration(0, ap.Account__c, ap.Account__r.Name, ap.Product__c, ap.Product__r.ProductCode, ap.Product__r.Name, ap.Product__r.Solution_Domain_Global__c, null, true, false, mapAcctId2PickLists.get(ap.Account__c));
            
            if (mapA2PIds.containsKey(pm.AccountId + '-' + pm.toProductId))
            {
                pm.ProductMigrationId = mapA2PIds.get(pm.AccountId + '-' + pm.toProductId).Id;
                pm.fromProductId = mapA2PIds.get(pm.AccountId + '-' + pm.toProductId).From_Product__c;                   
            }       
            
            lstPMs.add(pm); 

        }

        // CREATE A "FINAL" LIST COLLECTION OF productMigration WRAPPER CLASS ITEMS
        List<productMigration> lstNewPMs = new List<productMigration>();
        
        // USED TO INCREMENT SortKey FIELD IN productMigration WRAPPER CLASS ITEMS
        Integer j = 0;
        
        // FILTERS ITEMS TO ADD TO "FINAL" LIST COLLECTION OF productMigration WRAPPER CLASS ITEMS
        for (productMigration pm : lstPMs)
        {
            pm.iSortKey = j;
            lstNewPMs.add(pm);
            j++;
            for (AH_Product_Migration__c ahpm : lstPrdMs)
            {
                if ((pm.AccountId == ahpm.Account__c) && (pm.toSKU == ahpm.To_Product__r.ProductCode) && (pm.fromProductId != ahpm.From_Product__c))
                {
                    productMigration prdmg = new productMigration(j, pm.AccountId, pm.AccountName, pm.toProductId, pm.toSKU, pm.toProductName, pm.toProductDomain, pm.CreatedDate, false, false, mapAcctId2PickLists.get(pm.AccountId));
                    prdmg.ProductMigrationId = ahpm.Id;
                    prdmg.fromProductId = ahpm.From_Product__c;
                    lstNewPMs.add(prdmg);  
                    j++; 
                }
            }
        }
                
        lstPMs.clear();
        lstPMs = lstNewPMs;

    }
    
    private void loadProductMigrations()
    {

        lstCutOffDates = new List<cutOffDate>();
        
        for (AH_Product_Migration__c pm : [SELECT Id, Name, Opportunity__c, CreatedDate, Cut_Off_Date__c, 
                                           Account__c, Account__r.Name, Account__r.AccountNumber, BypassCaseAndAsset__c, 
                                           From_Product__c, From_Product__r.ProductCode, From_Product__r.Name, 
                                           To_Product__c, To_Product__r.ProductCode, To_Product__r.Name 
                                           FROM AH_Product_Migration__c 
                                           WHERE Opportunity__c =: o.Id
                                           ORDER BY Account__r.Name, To_Product__r.ProductCode])
        {
            
            String strCOD = '';
            if (pm.Cut_Off_Date__c != null)
            {
                strCOD = pm.Cut_Off_Date__c.format();
            }
            
            cutOffDate cod = new cutOffDate(pm, strCOD);
            lstCutOffDates.add(cod); 
            
        }
        
    }

    public void removeLine() 
    {
        List<productMigration> lstNewPMs = new List<productMigration>();

        Integer j = 0;
  
        for (productMigration pm : lstPMs)
        {
  
            if (pm.iSortKey != iRemoveLine)
            {           
            	pm.iSortKey = j;
                lstNewPMs.add(pm);
                j++;
            }
            
        }
        
        lstPMs.clear();
        lstPMs = lstNewPMs;
        isPendingCommit = true;
    }    

    public void loadProductSelector()
    {

        productMigration pm = lstPMs[iSelectedElement];
        lstLineItems = new List<lineItem>();
	
        for (SelectOption x : pm.lstFromProducts)
        {        
            if ((x.getLabel() != 'NOT MAPPED') && (x.getValue() != lstPMs[iSelectedElement].fromProductId))
            {
                Boolean bExists = false; 
                for (productMigration lst : lstPMs)
                { 
                    if (x.getValue() == lst.fromProductId)
                    { 
                        bExists = true; 
                    } 
                } 
                if (bExists == false) 
                { 
                    lineItem li = new lineItem(x.getValue(), x.getLabel()); 
                    lstLineItems.add(li); 
                } 
            }
        }

    }
    
    public void addProductSelections() 
    {
        
        List<productMigration> lstNewPMs = new List<productMigration>();
        
        Integer j = 0;

        for (productMigration pm : lstPMs)
        {
         
            pm.iSortKey = j; 
            lstNewPMs.add(pm);
       
            if (j == iSelectedElement)
            {                
                for (lineItem li : lstLineItems)
                {
                    if (li.isSelected)
                    {                
                        if (pm.fromProductId == 'aEP0d000000FUCT')
                        {
                            pm.iSortKey = j; 
                            pm.fromProductId = li.idLineItem; 
                            //j++;
                        }
                        else
                        {
                            j++;
                            productMigration prdmg = new productMigration(j, pm.AccountId, pm.AccountName, pm.toProductId, pm.toSKU, pm.toProductName, pm.toProductDomain, pm.CreatedDate, false, true, mapAcctId2PickLists.get(pm.AccountId));
                            prdmg.fromProductId = li.idLineItem;
                            lstNewPMs.add(prdmg); 
                        }                      
                    }
                } 
            }
            
            j++;
         
        }
        
        lstPMs.clear();
        lstPMs = lstNewPMs;
        
        showProductSelector = false;   
        isSuccess = true;
        isPendingCommit = true;
 
    }     

    public void applyMasterCutOffDate()
    { 
        for (cutOffDate cod : lstCutOffDates)
        {  
            cod.strCutOffDate = strMasterCutOffDate;
        }
        isPendingCommit = true;
    }
        
    public void saveMappings()
    {
        
        system.debug(' *** ENTERING AH_ProductMigrationToolCtrl.saveMappings() ');  
        
        saveMsg = 'Save was successful!';	
        saveMsgStyle = 'color:green;';
        
        List<AH_Product_Migration__c> lstPMUpserts = new List<AH_Product_Migration__c>();
        List<AH_Product_Migration__c> lstPMDeletes = new List<AH_Product_Migration__c>();
        
        Set<Id> setAcctIds = new Set<Id>();       
        Set<Id> setPrd2Ids = new Set<Id>();  

        try
        {
            // LOOP THROUGH ALL PRODUCTS TO COLLECT MAPPINGS AND CREATE/REMOVE AH_Product_Migration__c RECORDS
            for (productMigration pmWrap : lstPMs)
            { 

                AH_Product_Migration__c pm = new AH_Product_Migration__c();
                pm.Id = pmWrap.ProductMigrationId;
                pm.Opportunity__c = o.Id; 
                pm.Account__c = pmWrap.AccountId; 
                pm.To_Product__c = pmWrap.toProductId;
                  
                if (pmWrap.fromProductId == 'aEP0d000000FUCT')
                {
                    if (pmWrap.ProductMigrationId != null)
                    {
                        lstPMDeletes.add(pm);
                    }
                }
                else
                {
                    pm.From_Product__c = pmWrap.fromProductId;
                    lstPMUpserts.add(pm);                
                    setAcctIds.add(pmWrap.AccountId);
                    setPrd2Ids.add(pmWrap.fromProductId);
                }
                
            }
         
            if (!lstPMDeletes.isEmpty())
            {
                database.delete(lstPMDeletes); 
            }
          
            if (!lstPMUpserts.isEmpty())
            {
                database.upsert(lstPMUpserts); 
            }           
            
            // REBUILD AH_Product_Migration_Line_Item__c 
            List<AH_Product_Migration_Line_Item__c> lstPMLIDels = new List<AH_Product_Migration_Line_Item__c>(
                [SELECT Id 
                 FROM AH_Product_Migration_Line_Item__c 
                 WHERE Product_Migration__c IN (SELECT Id FROM AH_Product_Migration__c WHERE Opportunity__c =: o.Id)]);
            
            database.delete(lstPMLIDels);

            // NEED TO REQUERY THE RELATED AH_Product_Migration__c TO GET CREATED DATE
            List<AH_Product_Migration__c> lstPMSelects = new List<AH_Product_Migration__c>(
                [SELECT Id, CreatedDate, Account__c, From_Product__c, BypassCaseAndAsset__c  
                 FROM AH_Product_Migration__c 
                 WHERE Id IN : lstPMUpserts]);

            // CREATE NEW LIST OF AH_Product_Migration_Line_Item__c FOR INSERT
            List<AH_Product_Migration_Line_Item__c> lstPMLIs = new List<AH_Product_Migration_Line_Item__c>();
            
            // GET ALL VALID DEPLOYMENT INSTANCE RECORDS TO CREATE AH_Product_Migration_Line_Item__c FROM
            for (Asset di : [SELECT Id, AccountId, Product2Id 
                             FROM Asset 
                             WHERE Product2Id IN : setPrd2Ids 
                             AND AccountId IN : setAcctIds]) 
            {
                for (AH_Product_Migration__c pmx : lstPMSelects)
                {
                    if ((di.AccountId == pmx.Account__c) && (di.Product2Id == pmx.From_Product__c))
                    {
                        AH_Product_Migration_Line_Item__c pmlDI = new AH_Product_Migration_Line_Item__c();
                        pmlDI.Product_Migration__c = pmx.Id;
                        pmlDI.Asset__c = di.Id; 
                        pmlDI.RecordTypeId = Schema.SObjectType.AH_Product_Migration_Line_Item__c.getRecordTypeInfosByName().get('Deployment Instance').getRecordTypeId();
                        lstPMLIs.add(pmlDI); 
                    }
                }
            }

            // GET ALL VALID ACTIVITY LINE ITEMS RECORDS TO CREATE AH_Product_Migration_Line_Item__c FROM.
            // NOTE: IT IS POSSIBLE THAT Contract_Start_Date__c OR Contract_End_Date__c CAN BE NULL
            for (Activity_Line_Item__c ali : [SELECT Id, Account__c, Product__c, Contract_Start_Date__c, Contract_End_Date__c, Billing_Contract__r.Account__c 
                                              FROM Activity_Line_Item__c 
                                              WHERE Product__c IN : setPrd2Ids 
                                              AND Billing_Contract__r.Account__c IN : setAcctIds])
            {
                for (AH_Product_Migration__c pmx2 : lstPMSelects)
                {
                    if ((ali.Billing_Contract__r.Account__c == pmx2.Account__c) && (ali.Product__c == pmx2.From_Product__c))
                    {
                        // DATE FIELD NULL CHECKING. 
                        // IF NULL DEFAULT Contract_Start_Date__c & Contract_End_Date__c VARIABLES TO AH_Product_Migration__c.CreatedDate
                        // SO THAT THESE GET INCLUDED 
                        Datetime dtCreatedDateTime = pmx2.CreatedDate;
                        Date dtCreatedDate = dtCreatedDateTime.Date();
                        Date dtContractStart = dtCreatedDate;
                        Date dtContractEnd = dtCreatedDate;
                        if (ali.Contract_Start_Date__c != null)
                        {
                            dtContractStart = ali.Contract_Start_Date__c;
                        }
                        if (ali.Contract_End_Date__c != null)
                        {
                            dtContractEnd = ali.Contract_End_Date__c;
                        }
                      
                        if ((dtContractStart >= dtCreatedDate) || (dtContractEnd >= dtCreatedDate)) 
                        {                            
                            AH_Product_Migration_Line_Item__c pmlDI2 = new AH_Product_Migration_Line_Item__c();
                            pmlDI2.Product_Migration__c = pmx2.Id;
                            pmlDI2.Activity_Line_Item__c = ali.Id; 
                            pmlDI2.RecordTypeId = Schema.SObjectType.AH_Product_Migration_Line_Item__c.getRecordTypeInfosByName().get('Activity Line Item').getRecordTypeId();
                            lstPMLIs.add(pmlDI2); 
                        }
                    }
                } 
            }            
            
            database.insert(lstPMLIs);
            
            saveShow = true; 
            isPendingCommit = false;
            
            loadProducts();
            
        }
        catch (Exception ex) 
        {
            saveMsgStyle = 'color:red;';
            string message = 'An error occurred during Save: ' + ex.getMessage();
            saveMsg = message;
            system.debug(' *** ERROR OCCURED: Line# ' + ex.getLineNumber() + ' - ' + ex.getMessage());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
            ApexPages.addMessage(myMsg); 
        }

        system.debug(' *** EXITING AH_ProductMigrationToolCtrl.saveMappings() ');  
                
    }
	
    public void saveCutOffDates()
    {
        system.debug(' *** ENTERING AH_ProductMigrationToolCtrl.saveCutOffDates() ');  
        
        saveMsg = 'Save was successful!';	
        saveMsgStyle = 'color:green;';
        
        List<AH_Product_Migration__c> lstPMUpdates = new List<AH_Product_Migration__c>();

        try
        {
            // LOOP THROUGH ALL PRODUCTS TO COLLECT MAPPINGS AND CREATE/REMOVE AH_Product_Migration__c RECORDS
            for (cutOffDate cod : lstCutOffDates)
            {  
                AH_Product_Migration__c updatePM = new AH_Product_Migration__c();
                updatePM.Id = cod.PrdMg.Id;
				updatePM.Cut_Off_Date__c = null;                
                if (cod.strCutOffDate != null && cod.strCutOffDate != '')
                {  
                    updatePM.Cut_Off_Date__c = Date.parse(cod.strCutOffDate);                       
                }
                updatePM.BypassCaseAndAsset__c = cod.PrdMg.BypassCaseAndAsset__c;
                lstPMUpdates.add(updatePM); 
            }
            
            database.update(lstPMUpdates);
            
            saveShow = true; 
            isPendingCommit = false;            
            
            loadProductMigrations();
            
        }
        catch (Exception ex) 
        {
            saveMsgStyle = 'color:red;';
            string message = 'An error occurred during Save: ' + ex.getMessage();
            saveMsg = message;
            system.debug(' *** ERROR OCCURED: Line# ' + ex.getLineNumber() + ' - ' + ex.getMessage());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
            ApexPages.addMessage(myMsg); 
        }

        system.debug(' *** EXITING AH_ProductMigrationToolCtrl.saveCutOffDates() ');  
          
    }
    
    public void doChecks() 
    {
        if (lstCutOffDates.size() > 0)
        {
            for (cutOffDate cod : lstCutOffDates)
            {
                cod.PrdMg.BypassCaseAndAsset__c = checkAll;
            }
        }
    }    
    
    // POPUP DIALOG METHODS 
    public void showCancelConfirm() 
    {
        saveShow = false; 
        displayConfirmation = true;         
    }  
    
    public void hideCancelConfirm() 
    {      
        saveShow = false; 
        showProductSelector = false; 
        displayConfirmation = false;  
    }   
    
    public void showProductSelectorDialog() 
    {  
        loadProductSelector();
        saveShow = false; 
        showProductSelector = true; 
        displayConfirmation = false;         
    }

    public void hideProductSelectorDialog() 
    {  
        saveShow = false; 
        showProductSelector = false; 
        displayConfirmation = false;          
    }

    // PAGE METHODS    
    public PageReference closeTool()
    {
        PageReference pr = new PageReference('/' + o.Id);
        return pr;
    }
        
    public pageReference breakIn() 
    { 
        PageReference pr = ApexPages.currentPage(); 
        bIsFullScreen = false; 
        bShowSidebar = true; 
    	bShowHeader = true; 
        return pr; 
    } 
    
    public pageReference breakOut()
    {
        PageReference pr = ApexPages.currentPage(); 
        bIsFullScreen = true; 
        bShowSidebar = false; 
    	bShowHeader = false; 
        return pr; 
    }      
    
    
    // WRAPPER CLASSES =================================    
    public class productMigration
    {
        
        public Integer iSortKey {get; set;}
        public Id AccountId {get; set;}
        public String AccountName {get; set;}
        public String toProductId {get; set;}
        public String toSKU {get; set;}
        public String toProductName {get; set;} 
        public String toProductDomain {get; set;} 
        public Datetime CreatedDate {get; set;} 
        public Boolean showAddBtn {get; set;} 
        public Boolean showRemoveBtn {get; set;} 
		public List<SelectOption> lstFromProducts {get; set;}
        public String fromProductId {get; set;}
        public Id ProductMigrationId {get; set;} 
        
  
        public productMigration (
            Integer iSortKey, 
            Id AccountId,  
            String AccountName,  
            String toProductId,  
            String toSKU,  
            String toProductName,  
            String toProductDomain, 
            Datetime CreatedDate, 
            Boolean showAddBtn, 
            Boolean showRemoveBtn, 
            List<SelectOption> lstFromProducts)
        {
            this.iSortKey = iSortKey;
            this.AccountId = AccountId; 
            this.AccountName = AccountName; 
            this.toProductId = toProductId; 
            this.toSKU = toSKU; 
            this.toProductName = toProductName; 
            this.toProductDomain = toProductDomain; 
            this.CreatedDate = CreatedDate;
            this.showAddBtn = showAddBtn; 
            this.showRemoveBtn = showRemoveBtn; 
            this.lstFromProducts = lstFromProducts; 
        }
        
    }    
    
    public class lineItem 
    {
        public Boolean isSelected {get; set;}
        public Id idLineItem {get; set;}
        public String strLineItem {get; set;}
        
        public lineItem(Id idLineItem, String strLineItem) 
        {
            this.idLineItem = idLineItem;
            this.strLineItem = strLineItem; 
        }
    }    

    public class cutOffDate 
    {
        public AH_Product_Migration__c PrdMg {get; set;}
        public String strCutOffDate {get; set;}
        
        public cutOffDate(AH_Product_Migration__c PrdMg, String strCutOffDate) 
        {
            this.PrdMg = PrdMg;
            this.strCutOffDate = strCutOffDate; 
        }
    }     
    
}