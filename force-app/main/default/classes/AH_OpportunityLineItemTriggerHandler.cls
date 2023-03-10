/************************************************************************************************
Name            : AH_OpportunityLineItemTriggerHandler Class
Author          : Stuart Emery
Created Date    : 11/14/2013
Last Mod Date   : 11/22/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Formerly named NI_OpportunityProduct_TriggerHandler
                : Class that handles all trigger code for the OpportunityLineItem Object 
				: Updated per NICC-039872
				: 
*************************************************************************************************/
public class AH_OpportunityLineItemTriggerHandler
{

    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    
    public AH_OpportunityLineItemTriggerHandler()
    {
        
        system.debug(' *** ENTERING AH_OpportunityLineItemTriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();  
        
        system.debug(' *** EXITING AH_OpportunityLineItemTriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================== 
    //  PUBLIC ENTRY METHODS 
    // ========================================================================================================================  
    public void OnBeforeInsert(List<OpportunityLineItem> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_OpportunityLineItemTriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassOpportunityProduct_ON__c)
        {
            setProductFamily(newTrigger);
            syncOrderOfDelivery(newTrigger);
        }
        
        system.debug(' *** EXITING AH_OpportunityLineItemTriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());        
        
    }
    
    public void OnBeforeUpdate(List<OpportunityLineItem> newTrigger, Map<Id, OpportunityLineItem> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING AH_OBJECT_NAME_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassOpportunityProduct_ON__c)
        {
            persistDecimalPlaces(newTrigger, oldMapTrigger);
            syncOrderOfDelivery(newTrigger);
        }
        
        system.debug(' *** EXITING AH_OBJECT_NAME_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());        
        
    }
    
    public void OnAfterInsert(List<OpportunityLineItem> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_OpportunityLineItemTriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassOpportunityProduct_ON__c)
        {            
            
            // CREATE A LIST OF ALL OF THE OPPORTUNITY LINE ITEMS THAT WHERE INSERTED FROM THE APTTUS AGREEMENT
            List<OpportunityLineItem> lstOppLineItemsWithOptions = (
                [SELECT li.Id, li.PriceBookEntryId, li.PriceBookEntry.Pricebook2Id, li.PricebookEntry.Product2Id, li.OptionId__c, li.OpportunityId, 
                 li.UnitPrice, li.Quantity, li.LineType__c, li.Agreement_Line_Item__c, li.Order_of_Delivery__c, li.Description, li.CurrencyIsoCode  
                 FROM OpportunityLineItem li
                 WHERE li.LineType__c = 'Option'
                 AND li.OptionId__c != null 
                 AND li.Id IN : newTrigger
                 ORDER BY li.PricebookEntry.Product2Id, li.Order_of_Delivery__c]
            );
            
            List<OpportunityLineItem> lstBundleOppLineItemsToDelete = (
                [SELECT li.Id, li.OptionId__c, li.LineType__c, li.PricebookEntry.Product2.Apttus_Config2__ConfigurationType__c, li.PricebookEntry.Product2.Revenue_Category__c
                 FROM OpportunityLineItem li
                 WHERE li.PricebookEntry.Product2.Apttus_Config2__ConfigurationType__c = 'Bundle'
                 AND li.PricebookEntry.Product2.Revenue_Category__c = null 
                 //li.LineType__c = 'Product/Service'
                 //AND li.OptionId__c = null
                 AND li.Id IN : newTrigger]
            );        
            
            // CALL THE METHOD TO DELETE THE OPPORTUNITY LINE ITEMS  
            ApttusBundle_DeleteOppLineItems(lstBundleOppLineItemsToDelete);                                                                                                                        
            
            // CALL THE METHOD TO INSERT NEW OPPORTUNITY LINE ITEMS  
            ApttusBundle_InsertNewOppLineItem(lstOppLineItemsWithOptions);               
            
            
            // ROLLUP TO Opportunity.Amount__c      
            if (!bpSwitch.BypassOpportunityRollupAmount__c)
            { 
                AH_Opportunity_FUNCTIONS.rollupCustomAmount(newTrigger, null);   
            }         
            
            Set<Id> setDIIds = new Set<Id>();
            for (OpportunityLineItem oli : newTrigger)
            {
                if (oli.DeploymentInstance__c != null)
                {
                    setDIIds.add(oli.DeploymentInstance__c);
                }
            }
            
            if (!setDIIds.isEmpty())
            {
                //NI_FUNCTIONS.updateDIRollupSummaryFields(setDIIds);
                if(system.isBatch() || system.isFuture())
                {
                    system.debug('OPPORTUNITY TRIGGERHANDLER INSIDE IF CALLING updateDIRollupSummaryFields1 METHOD');
                    NI_FUNCTIONS.updateDIRollupSummaryFields1(setDIIds);
                    
                }
                else
                {
                    system.debug('OPPORTUNITY TRIGGERHANDLER INSIDE ELSE CALLING updateDIRollupSummaryFields METHOD');
                    NI_FUNCTIONS.updateDIRollupSummaryFields(setDIIds);
                }
            } 
            
        }
        
        system.debug(' *** EXITING AH_OpportunityLineItemTriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());        
        
    }
    
    public void OnAfterUpdate(List<OpportunityLineItem> newTrigger, Map<Id, OpportunityLineItem> oldMapTrigger)
    {      
        
        system.debug(' *** ENTERING AH_OpportunityLineItemTriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        //TEST START        
        OpportunityLineItem newo = newTrigger[0];
        OpportunityLineItem oldo = oldMapTrigger.get(newo.Id);
        system.debug(' *^* values old: Quantity = ' + oldo.Quantity + ', List Price = ' + oldo.ListPrice + ', Sales Price = ' + oldo.UnitPrice + ', Total Price = ' + oldo.TotalPrice);
        system.debug(' *^* values new: Quantity = ' + newo.Quantity + ', List Price = ' + newo.ListPrice + ', Sales Price = ' + newo.UnitPrice + ', Total Price = ' + newo.TotalPrice);   
        //TEST END
        if (!bpSwitch.BypassOpportunityProduct_ON__c)
        {
            
            // ROLLUP TO Opportunity.Amount__c      
            if (!bpSwitch.BypassOpportunityRollupAmount__c)
            { 
                AH_Opportunity_FUNCTIONS.rollupCustomAmount(newTrigger, oldMapTrigger);   
            } 
            
            Set<Id> setDIIds = new Set<Id>();
            
            for (OpportunityLineItem oli : newTrigger)
            {
                
                OpportunityLineItem oldOLI = oldMapTrigger.get(oli.Id);
                
                // IF QUANTITY OR DI CHANGES ON OPPORTUNITY LINE ITEM, ADD TO SET FOR ROLLUP SUMMARY
                if ((oli.Quantity != oldOLI.Quantity) || 
                    (oli.DeploymentInstance__c != null && (oli.DeploymentInstance__c != oldOLI.DeploymentInstance__c)))
                {
                    setDIIds.add(oli.DeploymentInstance__c);
                }
                
                if (oldOLI.DeploymentInstance__c != null && (oli.DeploymentInstance__c != oldOLI.DeploymentInstance__c))
                {
                    setDIIds.add(oldOLI.DeploymentInstance__c);
                }
                
            }
            
            if (!setDIIds.isEmpty())
            {
               // NI_FUNCTIONS.updateDIRollupSummaryFields(setDIIds);
               
                 
                if(system.isBatch() || system.isFuture() )
                {
                    system.debug('OPPORTUNITY LINEITEM INSIDE IF CALLING updateDIRollupSummaryFields1 METHOD');
                    NI_FUNCTIONS.updateDIRollupSummaryFields1(setDIIds);
                    
                }
                else
                {
                    system.debug('OPPORTUNITY LINEITEM INSIDE ELSE CALLING updateDIRollupSummaryFields METHOD');
                    NI_FUNCTIONS.updateDIRollupSummaryFields(setDIIds);
                }
            }
            
        }
        
        system.debug(' *** EXITING AH_OpportunityLineItemTriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());        
        
    }
    
    public void OnAfterDelete(List<OpportunityLineItem> oldTrigger)
    {
        
        system.debug(' *** ENTERING AH_OpportunityLineItemTriggerHandler.OnAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassOpportunityProduct_ON__c)
        {
            
            // ROLLUP TO Opportunity.Amount__c      
            if (!bpSwitch.BypassOpportunityRollupAmount__c)
            {           
                AH_Opportunity_FUNCTIONS.rollupCustomAmount(oldTrigger, null);    
            } 
            
            Set<Id> setDIIds = new Set<Id>();
            
            for (OpportunityLineItem oli : oldTrigger)
            {
                setDIIds.add(oli.DeploymentInstance__c);
            }
            
            if (!setDIIds.isEmpty())
            {
                NI_FUNCTIONS.updateDIRollupSummaryFields(setDIIds);
            } 
            
        }
        
        system.debug(' *** EXITING AH_OpportunityLineItemTriggerHandler.OnAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());        
        
    }
    
    
    // ======================================================================================================================== 
    //  PRIVATE HANDLER METHODS/FUNCTIONS 
    // ========================================================================================================================      
    private void setProductFamily(List<OpportunityLineItem> newTrigger)
    {
        
        Set<Id> setPBEIds = new Set<Id>();
        for (OpportunityLineItem oli : newTrigger) 
        {
            setPBEIds.add(oli.PricebookEntryId);
        }
        
        Map<Id, PricebookEntry> mapPBE = new Map<Id, PricebookEntry>([SELECT Id, Product2.Family FROM PricebookEntry WHERE Id IN : setPBEIds]);
        
        for (OpportunityLineItem oli : newTrigger)
        {
            Product2 product = mapPBE.get(oli.PricebookEntryId).Product2;
            oli.Family__c = product.Family;
        } 
        
    }
    
    // THIS METHOD INSERTS NEW OPPORTUNITY LINE ITEMS BASED ON THE APTTUS BUNDLE OPPORTUNITY LINE ITEMS
    public void ApttusBundle_InsertNewOppLineItem(List<OpportunityLineItem> newTrigger)
    {
        
        List<OpportunityLineItem> lstOppLineItemsToInsert = New List<OpportunityLineItem>();
        
        List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>(); //LIST TO HOLD THE PRICEBOOKENTRY RECORDS
        Set<Id> setPriceBookIds = new Set<Id>(); //SET TO HOLD THE UNIQUE PRICE BOOOK IDs OF THE INSERTED OPPORTUNITY LINE ITEMS
        Set<Id> setProductIds = new Set<Id>(); //SET TO HOLD THE UNIQUE PRODUCT IDs OF THE INSERTED OPPORTUNITY LINE ITEMS
        List<OpportunityLineItem> lstOppLineItemsToDelete = new List<OpportunityLineItem>(); //LIST TO HOLD THE OPPORTUNITY LINE ITEMS TO DELETE
        Set<Id> setSuccessfullInsertsIds = new Set<Id>();  //SET TO HOLD THE IDs OF THE OPPORTUNITY LINE ITEMS THAT WERE SUCCESSFULLY INSERTED
        List<OpportunityLineItem> lstOppLineItemsSuccess = new List<OpportunityLineItem>(); //LIST TO HOLD THE OPPORTUNITY LINE ITEMS THAT WERE SUCCESSFULLY INSERTED
        
        // POPULATE THE setPriceBookIds SET WITH ALL OF THE UNIQUE PRICEBOOK IDs FOR THE OPPORTUNITY LINE ITEMS INSERTED FROM APTTUS
        for (OpportunityLineItem oli : newTrigger) 
        {
            setPriceBookIds.add(oli.PriceBookEntry.Pricebook2Id);
        }
        
        // POPULATE THE setProductIds SET WITH ALL OF THE UNIQUE PRODUCTS FOR THE PRICEBOOKS OF THE OPPORTUNITY LINE ITEMS INSERTED FROM APTTUS
        for (OpportunityLineItem oli : newTrigger) 
        {
            setProductIds.add(oli.OptionId__c);
        }    
        
        // POPULATE THE lstPriceBookEntry LIST WITH ALL OF THE PRICEBOOKENTRY RECORDS WHERE THE PRICEBOOK IS IN THE setPriceBookIds SET AND THE PRODUCTS
        // ARE IN THE setProductIds SET    
        lstPriceBookEntry = ([SELECT Id, Pricebook2Id, Product2Id, CurrencyIsoCode FROM PriceBookEntry 
                              WHERE Pricebook2Id IN : setPriceBookIds
                              AND Product2Id IN : setProductIds]);
        
        // LOOP THROUGH THE BUNDLE OPPORTUNITY LINE ITEMS INSERTED FROM APTTUS AND BUILD THE NEW OPPORTUNITY LINE ITEMS TO BE INSERTED.  
        
        for (OpportunityLineItem li : newTrigger) 
        {  
            system.debug(li);            
            if (li.PricebookEntry.Product2Id != li.OptionId__c) //ONLY LOOK FOR OPPORTUNITY LINE ITEMS WHERE THE PRODUCT DOES NOT MATCH THE APTTUS OPTION FIELD
            {
                for (PriceBookEntry pbe : lstPriceBookEntry)
                {                    
                    if (li.PricebookEntry.Pricebook2Id == pbe.Pricebook2Id)
                    {                
                        if ((li.OptionId__c == pbe.Product2Id) && (li.CurrencyIsoCode == pbe.CurrencyIsoCode))
                        {                            
                            OpportunityLineItem nli = new OpportunityLineItem();
                            nli.OpportunityId = li.OpportunityId;
                            nli.Quantity = li.Quantity;
                            nli.PricebookEntryId = pbe.Id;
                            nli.UnitPrice = li.UnitPrice;
                            nli.OptionId__c = li.OptionId__c;
                            nli.LineType__c = li.LineType__c;
                            nli.Agreement_Line_Item__c = li.Agreement_Line_Item__c;
                            nli.Order_of_Delivery__c = li.Order_of_Delivery__c;
                            nli.Description = li.Description;
                            system.debug(nli);
                            lstOppLineItemsToInsert.Add(nli);
                        }
                    }      
                }
            }
        } 
        
        Id idProd2 = null;
        integer iOrderNum = 0; 
        
        // CONDITIONAL RENUMBERING
        for (integer i = 0; i < lstOppLineItemsToInsert.size(); i++)
        { 
            system.debug(' ################### Order_of_Delivery__c = ' + lstOppLineItemsToInsert.get(i).Order_of_Delivery__c + ' - ' + lstOppLineItemsToInsert.get(i).OptionId__c + ' - iOrderNum = ' + iOrderNum);             
            if (lstOppLineItemsToInsert.get(i).LineType__c == 'Option')
            {            
                if (idProd2 == null)
                {                 
                    iOrderNum++;
                    idProd2 = lstOppLineItemsToInsert.get(i).OptionId__c;
                    lstOppLineItemsToInsert.get(i).Order_of_Delivery__c = iOrderNum;
                }
                else 
                {
                    if (idProd2 == lstOppLineItemsToInsert.get(i).OptionId__c)
                    {                   
                        iOrderNum++;
                        idProd2 = lstOppLineItemsToInsert.get(i).OptionId__c;
                        lstOppLineItemsToInsert.get(i).Order_of_Delivery__c = iOrderNum;                        
                    }
                    else
                    {                        
                        iOrderNum = 1;
                        idProd2 = lstOppLineItemsToInsert.get(i).OptionId__c;
                        lstOppLineItemsToInsert.get(i).Order_of_Delivery__c = iOrderNum;                          
                    }
                }                
            } 
        }
        
        // INSERT NEW OPPORTUNITY LINE ITEMS  
        Database.SaveResult[] results = Database.insert(lstOppLineItemsToInsert,false);
        for (Database.SaveResult sr: results)
        {
            if (!sr.isSuccess())
            {
                Database.Error err = sr.getErrors()[0];
                System.debug(err.getMessage());
            }
            else 
            { 
                setSuccessfullInsertsIds.Add(sr.getId()); // GET THE IDs OF THE SUCCESSFULLY INSERTED OPPORTUNTIY LINE ITEMS 
            }     
        }
        
        lstOppLineItemsSuccess = ([SELECT Id, PriceBookEntryId, PriceBookEntry.Pricebook2Id, PricebookEntry.Product2Id, 
                                   OptionId__c, OpportunityId 
                                   FROM OpportunityLineItem 
                                   WHERE Id IN : setSuccessfullInsertsIds]);
        
        
        for (OpportunityLineItem nl : newTrigger) 
        {
            if (nl.PricebookEntry.Product2Id != nl.OptionId__c)
            {
                for (OpportunityLineItem l : lstOppLineItemsSuccess)
                {                    
                    if (l.OpportunityId == nl.OpportunityId)
                    { 
                        if (l.PricebookEntry.Pricebook2Id == nl.PricebookEntry.Pricebook2Id)
                        {
                            if (l.PricebookEntry.Product2Id == nl.OptionId__c)
                            {
                                lstOppLineItemsToDelete.Add(nl);
                            }   
                        }
                    } 
                }
            }
        }
        
        // USE A SET TO DEDUPE OLI LIST (ADDED 2/18/2017)
        Set<OpportunityLineItem> setUniqueOLIs = new Set<OpportunityLineItem>();
        List<OpportunityLineItem> lstUniqueOLIs = new List<OpportunityLineItem>();
        setUniqueOLIs.addAll(lstOppLineItemsToDelete);
        lstUniqueOLIs.addAll(setUniqueOLIs);    
        
        // CALL THE METHOD TO DELETE THE OPPORTUNITY LINE ITEMS       
        ApttusBundle_DeleteOppLineItems(lstUniqueOLIs);
        
    }
    
    // THIS METHOD DELETES THE APTTUS BUNDLE-RELATED OPPORTUNITY LINE ITEMS
    public void ApttusBundle_DeleteOppLineItems(List<OpportunityLineItem> newTrigger)
    {
        
        Database.DeleteResult[] drList = Database.delete(newTrigger, false);
        for (Database.DeleteResult dr : drList) 
        {
            if (dr.isSuccess()) 
            {
                // system.debug(' *** NI_OpportunityProduct_TriggerHandler.ApttusBundle_DeleteOppLineItems - SUCCESSFULLY DELETED OPPORTUNITY LINE ITEM ID: ' + dr.getId());
            }
            else 
            {
                Database.Error err = dr.getErrors()[0];
                System.debug(err.getMessage());
            }
        }
        
    }    
    
    private void syncOrderOfDelivery(List<OpportunityLineItem> newTrigger)
    {
        
        // FILL A SET WILL OPPORTUNITY IDS FOR Apttus__AgreementLineItem__c QUERY
        Set<Id> oppIds = new Set<Id>();        
        for (OpportunityLineItem oli : newTrigger)
        {
            oppIds.add(oli.OpportunityId);
        }
        
        // LOOP THROUGH ALL RELATED Apttus__AgreementLineItem__c GATHERING THE DATA IN AN INNER CLASS LIST 
        List<agreementLineItem> lstALIs = new List<agreementLineItem>();
        DateTime dtMax = Datetime.newInstance(2010, 1, 1);
        
        for (Apttus__AgreementLineItem__c ali : 
             [SELECT Id, Apttus__AgreementId__r.Apttus__Related_Opportunity__c, Apttus__NetPrice__c, Apttus__ProductId__c, Apttus__Quantity__c, 
              Apttus_CMConfig__ItemSequence__c, Apttus__AgreementId__r.Synchronized_with_Opportunity_DateTime__c, Apttus_CMConfig__DerivedFromId__r.Apttus_Config2__ProductId__c 
              FROM Apttus__AgreementLineItem__c
              WHERE Apttus__AgreementId__r.Apttus__Related_Opportunity__c IN : oppIds 
              AND Apttus_CMConfig__ItemSequence__c != null])
        {
            
            agreementLineItem objALI = new agreementLineItem (
                ali.Apttus__AgreementId__r.Apttus__Related_Opportunity__c,				// Opportunity Id
                null, 																	// Opportunity Line Item Id  
                ali.Id, 																// Agreement Line Item Id 
                //                ali.Apttus_CMConfig__DerivedFromId__r.Apttus_Config2__ProductId__c,	// Product2 Id 
                ali.Apttus__ProductId__c,												// Product2 Id 
                ali.Apttus__Quantity__c, 												// Quantity
                ali.Apttus__NetPrice__c,  												// Price 
                ali.Apttus_CMConfig__ItemSequence__c, 									// Order of Delivery 
                ali.Apttus__AgreementId__r.Synchronized_with_Opportunity_DateTime__c,	// Date When Synced With Opportunity  
                false
            );
            
            lstALIs.Add(objALI);
            
            if (dtMax < ali.Apttus__AgreementId__r.Synchronized_with_Opportunity_DateTime__c)
            {
                dtMax = ali.Apttus__AgreementId__r.Synchronized_with_Opportunity_DateTime__c;
            }
            
        }
        
        // REMOVE ALL AGREEMENT LINE ITEMS FROM NON-RELATED AGREEMENT RECORDS (BASED ON DATE OF SYNC)
        Integer j = 0;
        
        while (j < lstALIs.size())
        {
            if (lstALIs.get(j).dSynced != dtMax)
            {
                lstALIs.remove(j);
            }
            else
            {
                j++;
            }
        }
        
        // LOOP THROUGH ALL OF THE INNER CLASS RECORDS TO ASSIGN Agreement_Line_Item__c LOOKUP ID VALUES
        for (OpportunityLineItem o : newTrigger)
        {
            for (agreementLineItem a : lstALIs)
            {             
                if (!a.bAssigned) 	// IF THIS IS NULL THEN IT HAS NOT BEEN USED TO ISSUE A Agreement_Line_Item__c LOOKUP ID VALUE
                {
                    if ((o.OpportunityId == a.oppId) && 
                        (o.Product2Id == a.prdId) && 
                        (o.Quantity.setScale(2) == a.dQty.setScale(2)) && 
                        (o.TotalPrice.setScale(2) == a.dPrice.setScale(2)))
                    {
                        if (o.Agreement_Line_Item__c == null)
                        {
                            o.Agreement_Line_Item__c = a.aliId;
                            o.Order_of_Delivery__c = a.iOrder;
                            a.bAssigned = true;
                            break;
                        }                        
                    }
                }
            }
            
        }
        
    } 
    
    private void persistDecimalPlaces(List<OpportunityLineItem> newTrigger, Map<Id, OpportunityLineItem> oldMapTrigger)
    {
        
        for (OpportunityLineItem oli : newTrigger)
        {
            if (oldMapTrigger.containsKey(oli.Id))
            {
                OpportunityLineItem oldOLI = oldMapTrigger.get(oli.Id);
                if (oldOLI.UnitPrice != null)
                {
                    //system.debug('*^* dRemainder = (' + oldOLI.UnitPrice + ' - ' + oli.UnitPrice + ')');                         
                    Decimal dRemainder = Math.abs(oldOLI.UnitPrice - oli.UnitPrice);
                    //system.debug('*^* dRemainder = ' + dRemainder);
                    // IF UnitPrice HAS CHANGED (dRemainder != 0) AND DECIMALS MISSING AFTER THE HUNDREDTH PLACE (dRemainder < .01)
                    if (dRemainder != 0 && dRemainder < .01)
                    {
                        // RESTORE NEW UnitPrice FROM OLD UnitPrice 
                        oli.UnitPrice = oldOLI.UnitPrice;
                        //oli.TotalPrice = (oli.Quantity * oldOLI.TotalPrice);
                    }              
                }
            }
        }
        
    }
    
    public class agreementLineItem
    {
        
        public Id oppId { get; set; }  			// Opportunity Id
        public Id oliId { get; set; }  			// Opportunity Line Item Id  
        public Id aliId { get; set; }  			// Agreement Line Item Id 
        public Id prdId { get; set; }  			// Product2 Id 
        public Decimal dQty { get; set; }		// Quantity
        public Decimal dPrice { get; set; }		// Price 
        public Decimal iOrder { get; set; }		// Order of Delivery 
        public DateTime dSynced { get; set; }	// Date When Synced With Opportunity  
        public boolean bAssigned { get; set; }	// A flag used in code
        
        public agreementLineItem (Id oppId, Id oliId, Id aliId, Id prdId, Decimal dQty, Decimal dPrice, Decimal iOrder, DateTime dSynced, boolean bAssigned)
        {
            this.oppId = oppId;
            this.oliId = oliId;
            this.aliId = aliId;
            this.prdId = prdId;
            this.dQty = dQty;
            this.dPrice = dPrice; 
            this.iOrder = iOrder; 
            this.dSynced = dSynced;
            this.bAssigned = bAssigned;
        }
        
    } 
    
}