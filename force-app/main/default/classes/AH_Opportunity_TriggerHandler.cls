/****************************************************************************************
Name            : AH_Opportunity_TriggerHandler Class
Author          : Sean Harris
Created Date    : 10/31/2012
Last Mod Date   : 06/12/2019 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all trigger code for the Opportunity Object
                : 
******************************************************************************************/
public class AH_Opportunity_TriggerHandler 
{
    
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}

    public AH_Opportunity_TriggerHandler()
    {
        
        system.debug(' *** ENTERING AH_Opportunity_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();  
                
        system.debug(' *** EXITING AH_Opportunity_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    // ============================================================================================================================================
    //  PUBLIC ENTRY METHODS
    // ============================================================================================================================================    
    public void OnAfterInsert(List<Opportunity> newTrigger)
    {
		
        system.debug(' *** ENTERING AH_Opportunity_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassOpportunity_ON__c)
        {        
            // CALL THE METHOD TO CHECK FOR MQL Opportunties
            MQL_Opportunity(newTrigger);        
        }
        
        system.debug(' *** EXITING AH_Opportunity_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public void OnBeforeUpdate(List<Opportunity> newTrigger, Map<Id, Opportunity> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING AH_Opportunity_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

        if (!bpSwitch.BypassOpportunity_ON__c)
        {     
            
            //Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
            //Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();         
            
            List<Opportunity> lstClosedWonAndSalesOrders = new List<Opportunity>();
            List<Opportunity> oliToProcessList = new List<Opportunity>();
            //Id partnerRecordId = OpportunityRecordTypeInfo.get('Partner').getRecordTypeId();
            Id partnerRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            Set<Id> newOppIds = new Set<Id>(); 	// Shashikant Nikam (NICC-033453)
            
            // Loop through the newTrigger List of Opportunities
            for (Opportunity o : newTrigger) 
            {
                
                newOppIds.add(o.Id);			// Shashikant Nikam (NICC-033453)
                Opportunity oldOpp = oldMapTrigger.get(o.Id);
                
                
//                if (
//                    (o.StageName == 'Closed Won' && o.StageName != oldOpp.StageName) ||
//                    ((o.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId()) && (o.RecordTypeId != oldOpp.RecordTypeId))
//                ) 
//                {
//                    lstClosedWonAndSalesOrders.add(o);
//                }
                
                // GET VALID OPPORTUNITIES FOR PASSING INTO CONTACT ROLE VALIDATION
                if (o.RecordTypeId != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('S&EM Limited Service Opportunity').getRecordTypeId())
                {
                    // IF OPPORTUNITY WAS CHANGED TO 'Closed Won' OR CHANGED TO A 'Sales Order'
                    if ((o.StageName == 'Closed Won' && o.StageName != oldOpp.StageName) || (o.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId()) && (o.RecordTypeId != oldOpp.RecordTypeId))
                    {
                        lstClosedWonAndSalesOrders.add(o);
                    }
                }
                else
                {
                    // IF 'S&EM Limited Service Opportunity' OPPORTUNITY WITH SPECIFIED Provision_Type__c WAS CHANGED TO 'Closed Won'
                    if ((o.StageName == 'Closed Won' && o.StageName != oldOpp.StageName) || (o.RecordTypeId != oldOpp.RecordTypeId))
                    {
                        if (o.StageName == 'Closed Won')
                        {
                            if (o.Provision_Type__c != null)
                            {
                                lstClosedWonAndSalesOrders.add(o);
                            }  
                            else
                            {
                                o.addError(' The Provision Type on an "S&EM Limited Service Opportunity" may not be blank when stage is "Closed Won". Please select an option from that drop down box and save again.');
                            }
                        }
                    }
                }
                    
                
                if (
                    (o.StageName == 'Closed Won' && o.StageName != oldOpp.StageName && o.Order_Status__c == 'Integrated') || 
                    (o.Order_Status__c == 'Integrated' && o.Order_Status__c != oldOpp.Order_Status__c && o.StageName == 'Closed Won') || 
                    (o.RecordTypeId == partnerRecordId && o.StageName == 'Sold' && o.Order_Status__c != oldOpp.Order_Status__c && o.Order_Status__c == 'Complete')
                )
                {
                    oliToProcessList.add(o);
                }
                
            }  
            
            PopulateVSOEAppliesCheckbox(newTrigger);
            
            addorUpdateCompany(newTrigger, oldMapTrigger, newOppIds);	// Shashikant Nikam (NICC-033453)
            
            if (!bpSwitch.BypassOpportunityContactRoleChecks__c)
            {              
                if (lstClosedWonAndSalesOrders.size() > 0)
                {
                    verifyContactRoles(lstClosedWonAndSalesOrders);
                    billToShipToCount(lstClosedWonAndSalesOrders);  
                }
            }
            
            if (!oliToProcessList.isEmpty())
            {
                AH_Opportunity_FUNCTIONS.createUpdateDIForOLI_New(oliToProcessList, true);
            }
            
        }
        
        system.debug(' *** EXITING AH_Opportunity_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterUpdate(List<Opportunity> newTrigger, Map<Id, Opportunity> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING AH_Opportunity_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());      

        if (!bpSwitch.BypassOpportunity_ON__c)
        {     
            
            if (!bpSwitch.BypassOpportunityHRMProductCreate__c)
            {            
                createDelphiFDC_DIs(newTrigger, oldMapTrigger);
            } 
            
            if (!bpSwitch.BypassOpportunityReleaseDateUpdate__c)
            {
                
                List<Opportunity> lstReleaseDates = new List<Opportunity>();   
                
                // Loop through the newTrigger List of Opportunities
                for (Opportunity oRelDates : newTrigger) 
                {
                    
                    Opportunity oldOpp = oldMapTrigger.get(oRelDates.Id);            
                    
                    if (((oRelDates.Order_Status__c == 'Integrated') && (oRelDates.Order_Status__c != oldOpp.Order_Status__c)) || 
                        ((oRelDates.Order_Status__c == 'Integrated') && (oRelDates.CloseDate != oldOpp.CloseDate)))    
                    {
                        lstReleaseDates.add(oRelDates);
                    }
                    
                    if (lstReleaseDates.size() > 0)
                    {
                        releaseDate(newTrigger);
                    }
                    
                }
                
            } 
            
            // LOOP THROUGH TO FIND CHANGES TO Rollup_Amount_Adjustment__c
            Set<Id> setOpptyIds = new Set<Id>();
            for (Opportunity oppRAA : newTrigger) 
            {        
                Opportunity oldOppty = oldMapTrigger.get(oppRAA.Id);  
                if (oppRAA.Rollup_Amount_Adjustment__c != oldOppty.Rollup_Amount_Adjustment__c)
                {
                    setOpptyIds.Add(oppRAA.Id);
                }
            }
            
            List<OpportunityLineItem> lstOLIRollupInvokes = new List<OpportunityLineItem>(
                [SELECT Id, OpportunityId, TotalPrice, Product2Id, Product2.Family, Product2.Revenue_Category__c, 
                 Opportunity.CurrencyIsoCode, Opportunity.CloseDate, Opportunity.RecordType.Name     
                 FROM OpportunityLineItem 
                 WHERE OpportunityId IN : setOpptyIds]);
            
            setProjectStage(newTrigger, oldMapTrigger);
            
            // CALL GLOBAL ROLLUP FUNCTION ONLY IF THERE IS A CHANGE FOUND TO Rollup_Amount_Adjustment__c
            if (lstOLIRollupInvokes.size() > 0)
            {
                AH_Opportunity_FUNCTIONS.rollupCustomAmount(lstOLIRollupInvokes, null);    
            }
            
        }
        
        system.debug(' *** EXITING AH_Opportunity_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());      

    }


    // ============================================================================================================================================
    //  FUNCTIONS
    // ============================================================================================================================================ 
    private void PopulateVSOEAppliesCheckbox(List<Opportunity> newTrigger)
    {
        
        Set<Id> setOppIds = new Set<Id>();
        for (Opportunity o : newTrigger)
        {
            setOppIds.add(o.Id);
        }      
        
        // GET LIST OF OPPORTUNITY LIME ITEMS NEEDED
        List<OpportunityLineItem> opplines = [SELECT Id, OpportunityId, Product2.Apttus_Revenue_Category__c
                                              FROM OpportunityLineItem 
                                              WHERE Product2.Apttus_Revenue_Category__c != null 
                                              AND OpportunityId IN : setOppIds];
        
        //Loop through opp lines and store count of unique Apttus rev categories. Create map of values
        Map<Id, Set<String>> revCatMap = new Map<Id, Set<String>>();
        
        //populate map
        for (OpportunityLineItem oLI : opplines)
        {
            Set<String> mapString; 
            String key = oLI.OpportunityId;
            
            if (revCatMap.containsKey(key) == false) 
            {
                mapString = new set<String>();
                mapString.add(oLI.Product2.Apttus_Revenue_Category__c);
                //Any field you query can be used to with the variable in your for loop
                revCatMap.put(key, mapString);
            }
            else
            {
                mapString = revCatMap.get(key);
                //every time we get a non-void value we need to set that return to something
                mapString.add(oLI.Product2.Apttus_Revenue_Category__c);
                //re-put map with updated set                
                revCatMap.put(key, mapString);
            }
            
        }
        
        for (Opportunity revCatCount : newTrigger) 
        {
            if (revCatMap.containsKey(revCatCount.Id) == true) 
            {
                if (revCatMap.get(revCatCount.Id).size() > 1) //make the VSOE checkbox true
                {
                    revCatCount.VSOE_Applies__c = true;
                }
                if (revCatMap.get(revCatCount.Id).size() <= 1) //make VSOE checkbox false
                {
                    revCatCount.VSOE_Applies__c = false;
                }
            }	
        }
        
    }
    
    private void setProjectStage(List<Opportunity> newTrigger, Map<Id, Opportunity> oldMapTrigger) 
    {    
        
        // Name            : psaOpportunityAu_SetProjectStage
        // Author          : CLD
        // Created Date    : October 28, 2011
        // Description     : When an Opportunity's Order Status is updated to "Definite" and the Opportunity's 
        //                 : Stage is "Closed Won", this finds any PSA Projects associated with the Opportunity
        //                 : and if their status is "Draft at Risk", updates it to "Draft"   

        Set<Id> setOppIds = new Set<Id>();
        for (Opportunity o : newTrigger)
        {
            setOppIds.add(o.Id);
        }

        // Look up associated projects that currently have Draft at Risk stage
        List<pse__Proj__c> lstProjects = new List<pse__Proj__c>([SELECT Name, pse__Stage__c, pse__Opportunity__c 
                                                                 FROM pse__Proj__c 
                                                                 WHERE pse__Opportunity__c IN : setOppIds
                                                                 AND pse__Stage__c = 'Draft at Risk']);
        
        if (!lstProjects.isEmpty())
        {
            
            List<pse__Proj__c> projectsToUpdate = new List<pse__Proj__c>();
            
            for (Opportunity op : newTrigger) 
            {
                try
                {

                    String oldOrderStatus = oldMapTrigger.get(op.Id).Order_Status__c;
                    
                    // Opportunity stage must be 'Closed Won' and Opportunity Order Status must be 'Definite'
                    // and the Opportunity's prior order status must be something other than 'Definite' 
                    if (op.StageName == 'Closed Won' && 
                        op.Order_Status__c != null && 
                        op.Order_Status__c == 'Definite' && 
                        (oldOrderStatus == null || oldOrderStatus != 'Definite')) 
                    {
                        
                        for (pse__Proj__c prj : lstProjects)
                        {
                            if (op.Id == prj.pse__Opportunity__c)
                            {
                                prj.pse__Stage__c = 'Draft';
                                projectsToUpdate.add(prj);
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    op.addError('Error setting project stage from opportunity info: ' + e.getMessage());
                }
            }
            
            // Update any projects that need it
            if (!projectsToUpdate.isEmpty())
            {
                Database.SaveResult[] results = Database.update(projectsToUpdate);
                for (Database.SaveResult sr: results)
                {
                    if (!sr.isSuccess())
                    {
                        Database.Error err = sr.getErrors()[0];
                        system.debug(err.getMessage());
                    }
                }
            }            
        }
        
    }    
    
    private void MQL_Opportunity(List<Opportunity> newTrigger)
    {
        
        // IF THIS OPPORTUNITY WAS CREATED FROM A MARKETINC QUALIFIED LEAD (MQL), UPDATE THE MQL STATUS FIELD TO 'Opportunity'
        
        // Author          : Stuart Emery
        // Created Date    : 8/2/2013
        // Last Mod Date   : 8/2/2013 
        // Last Mod By     : Stuart Emery
        // NICC Reference  : NICC-007566
        // Description     : If the Marketing Qualified Lead field is filled in when a new Opportunity
        // 				   : is created, this Method will set the Status for 
        // 				   : the corresponding Marketing Qualified Lead to “Opportunity.”     
        
        system.debug(' *** ENTERING AH_Opportunity_TriggerHandler.MQL_Opportunity() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // CREATE A SET TO STORE THE MQLs THAT ARE LINKED TO OPPORTUNITES  
        Set<Id> MQLIDs = new Set<Id>();
        
        for (Opportunity o : newTrigger)
        {
            if (o.Marketing_Qualified_Lead__c != null)
            {  
                MQLIDs.Add(o.Marketing_Qualified_Lead__c);
            }
        }           
        
        if (MQLIDs.Size() == 0)
        {
            return;
        }
        
        // CREATE A LIST OF MARKETING QUALIFIED LEADS FOUND IN MQLIDs
        List<Marketing_Qualified_Lead__c> lstMQLs = [SELECT Id, Status__c 
                                                     FROM Marketing_Qualified_Lead__c 
                                                     WHERE Id IN : MQLIDs];
        
        // CREATE THE LIST OF MARKETING QUALIFIED LEADS TO UPDATE
        List<Marketing_Qualified_Lead__c> lstMQLsToUpdate = new List<Marketing_Qualified_Lead__c>();
        
        for (Marketing_Qualified_Lead__c mql : lstMQLs)
        {
            mql.Status__c = 'Opportunity'; //SET THE STATUS FIELD ON THE MQL TO 'Opportunity'            
            lstMQLsToUpdate.Add(mql);
        }
        
        //USE DATABASE DML METHOD TO UPDATE ALL OF THE MARKETING QUALIFIED LEADS
        if (lstMQLsToUpdate.size() > 0)
        {
            Database.SaveResult[] results = Database.update(lstMQLsToUpdate,false);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    system.debug(err.getMessage());
                }
            }
        }
        
        system.debug(' *** EXITING AH_Opportunity_TriggerHandler.MQL_Opportunity() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public void addorUpdateCompany(List<Opportunity> newTrigger, Map<Id, Opportunity> oldMapTrigger, Set<Id> OppIds)
    {
        
        // Shashikant Nikam (NICC-033453)
        
        // QUERY ON COMPANY TO GET THE ALL THE COMPANIES
        Map<String, c2g__codaCompany__c> ffaCompanymap = new Map<String, c2g__codaCompany__c>();
        List<c2g__codaCompany__c> compList = new List<c2g__codaCompany__c>([SELECT Id, Legal_Entity_Name__c, Remittance_Info__c, Physical_Countries__c FROM c2g__codaCompany__c]);
        
        // CREATE AMP OF LEGAL ENTITY TO COMPANY
        for (c2g__codaCompany__c company : compList)
        {
            ffaCompanymap.put(company.Legal_Entity_Name__c, company);
        }

        Map<Id, Opportunity> mapOfOpps = new Map<Id, Opportunity>([SELECT Id, Account.ShippingCountry, Amadeus_Legal_Entity__c FROM Opportunity WHERE ID IN: OppIds]);

        // IF AGREEMENT RECORD EXISTS 
        for (Opportunity opp : newTrigger) 
        {           

            Opportunity oldOpp = oldMapTrigger.get(opp.Id);

            // SET THE COMPANY ON OPPORTUNITY REFERENCING COMPANY
            if (opp.Amadeus_Legal_Entity__c != null && opp.Amadeus_Legal_Entity__c != oldOpp.Amadeus_Legal_Entity__c)
            {
                opp.Company__c = null;
                if (ffaCompanymap.containsKey(opp.Amadeus_Legal_Entity__c))
                {
                    opp.Company__c = ffaCompanymap.get(opp.Amadeus_Legal_Entity__c).Id;
                }
            }
            
            if (opp.Amadeus_Legal_Entity__c != null) 
            {
                
                // LOOP THOUGH ALL COMPANIES WHERE Physical_Countries__c IS FILLED IN 
                for (c2g__codaCompany__c company : compList) 
                { 
                    // IF AGREEMENT LEGAL NAME MATCHES LEGAL NAME ON COMPANY 
                    if (company.Legal_Entity_Name__c == opp.Amadeus_Legal_Entity__c && company.Physical_Countries__c == null) 
                    {
                        opp.Company__c = company.Id; 
                    }

                    // IF COUNTRY ON AGREEMENT IS CONTAINED IN Billing_Countries__c ON COMPANY 
                    if (company.Legal_Entity_Name__c == opp.Amadeus_Legal_Entity__c && 
                        company.Physical_Countries__c != null && 
                        company.Physical_Countries__c.contains(mapOfOpps.get(opp.Id).Account.ShippingCountry) 
                       )
                    {
                        opp.Company__c = company.Id;
                        break;
                    }
                }
            }
        }
    }    
    
    private void createDelphiFDC_DIs(List<Opportunity> newTrigger, Map<Id, Opportunity> oldMapTrigger)    
    { 
        // When 
        //   Opportunity.StageName = "Closed Won" 
        //   Opportunity.Order_Status__c = "Integrated" 
        //   Opportunity Product WHERE Product_Group__c.name = "Salesforce" and Line__c = "License" and 
        //   DI With Delphi.fdc index does not exist
        //   Create DI
        
        system.debug(' *** ENTERING AH_Opportunity_TriggerHandler.createDelphiFDC_DIs() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // A SET FOR ALL QUALFIED OPPORTUNITY  
        Set<Id> setOpptyIds = new Set<Id>();
        for (Opportunity o : newTrigger)
        {
            // commmented by kasim === execute only if stage or status is changed to meet condition
            //if ((o.StageName == 'Closed Won') && (o.Order_Status__c == 'Integrated'))
            Opportunity oldOpp = oldMapTrigger.get(o.Id);
            if((o.StageName == 'Closed Won' && o.StageName != oldOpp.StageName && o.Order_Status__c == 'Integrated')
               || (o.Order_Status__c == 'Integrated' && o.Order_Status__c != oldOpp.Order_Status__c && o.StageName == 'Closed Won'))
            {
                setOpptyIds.Add(o.Id);
            }
        }
        
        // if no opportunity updated.
        if (setOpptyIds.isempty())
        {
            return;
        }
        
        Set<Id> setAccountIds = new Set<Id>(); 
        Set<String> setAccountId_DIIndexIDs = new Set<String>();
        List<Asset> lstDI_Insert = new List<Asset>(); 
        
        Map<Id, Id> mapProd2Id2DIIndxId = new Map<Id, Id>();
        
        for (Product2 p2 : [SELECT Id, DI_Index__c 
                            FROM Product2 
                            WHERE (Product_Group__r.Name = 'Salesforce' AND Line__c = 'License') OR 
                            (ProductCode = 'ZZZ-HRM-001')])
        {
            mapProd2Id2DIIndxId.put(p2.Id, p2.DI_Index__c);
        }       
        
        // Product2 pd2 = [SELECT Id, DI_DefaultStatus__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-001' LIMIT 1];
        
        Id pd2Id;
        String strDefaultStatus;
        // LIST TO HOLD THE VALUES IN THE NI_ZZZ_HRM_Product__c CUSTOM SETTING
        List<NI_ZZZ_HRM_Product__c> lstCS = NI_ZZZ_HRM_Product__c.getall().values();
        
        // IF THE lstCS LIST CONTAINS RECORDS, CONTINUE WITH THE REST OF THE CODE  
        if (lstCS.size() > 0)
        {
            // LOOP THROUGH THE lstCS LIST.  
            for (NI_ZZZ_HRM_Product__c cs : lstCS)
            {
                if (cs.Name == 'ZZZ-HRM-001') 
                {   
                    pd2Id = Id.valueOf(cs.Product2Id__c);
                    strDefaultStatus = cs.DI_DefaultStatus__c;
                }
            }
        }
        
        // CREATE SALESFORCE LICENSE DIs
        for (OpportunityLineItem i : [SELECT Id, Opportunity.AccountId, PricebookEntry.Product2.Id, PricebookEntry.Product2.DI_DefaultStatus__c, 
                                      PricebookEntry.Product2.Name, PricebookEntry.Product2.Line__c, PricebookEntry.Product2.DI_Index__c  
                                      FROM OpportunityLineItem 
                                      WHERE PricebookEntry.Product2.Product_Group__r.Name = 'Salesforce' 
                                      AND PricebookEntry.Product2.Line__c = 'License' 
                                      AND Opportunity.StageName = 'Closed Won'  
                                      AND Opportunity.Order_Status__c = 'Integrated' 
                                      AND OpportunityId IN : setOpptyIds]) 
        {
            
            // VALIDATE THERE ARE NO DUPED LICENSE ITEMS
            if (!setAccountId_DIIndexIDs.contains(String.valueOf(i.Opportunity.AccountId) + String.valueOf(i.PricebookEntry.Product2.DI_Index__c)))
            {
                setAccountId_DIIndexIDs.Add(String.valueOf(i.Opportunity.AccountId) + String.valueOf(i.PricebookEntry.Product2.DI_Index__c));
                // Set Collection for Junction object creation.
                
                Asset d1 = new Asset(); 
                d1.AccountId = i.Opportunity.AccountId; 
                d1.Product2Id = i.PricebookEntry.Product2.Id; 
                d1.Status = i.PricebookEntry.Product2.DI_DefaultStatus__c; 
                d1.Enterprise_Agreement__c = false; 
                d1.Integration_User_Source__c = 'DI Automation: Salesforce License Opportunity'; 
                d1.IsHostedDI__c = false; 
                d1.Market_Vision__c = false; 
                d1.Product_Line__c = 'Delphi.fdc'; 
                d1.Purchase_Date__c = system.Date.Today(); 
                d1.Status_Change_Date__c = system.Date.Today(); 
                d1.Name = 'Delphi.fdc License'; 
                d1.Opportunity__c = i.OpportunityId; 
                lstDI_Insert.add(d1); 
                
                // CREATE ZZZ-HRM-001 DIs
                if (!setAccountIds.contains(i.Opportunity.AccountId))
                {
                    setAccountIds.Add(i.Opportunity.AccountId);
                    
                    Asset d2 = new Asset(); 
                    d2.AccountId = i.Opportunity.AccountId; 
                    d2.Product2Id = pd2Id; 
                    d2.Status = strDefaultStatus; 
                    d2.Enterprise_Agreement__c = false; 
                    d2.Integration_User_Source__c = 'DI Automation: Salesforce License Opportunity'; 
                    d2.IsHostedDI__c = false; 
                    d2.Market_Vision__c = false; 
                    d2.Product_Line__c = 'Delphi.fdc'; 
                    d2.Purchase_Date__c = system.Date.Today(); 
                    d2.Status_Change_Date__c = system.Date.Today(); 
                    d2.Name = 'Delphi.fdc'; 
                    d2.Opportunity__c = i.OpportunityId; 
                    lstDI_Insert.add(d2); 
                    
                }
            }
        }
        
        // LOOP THROUGH AND REMOVE DIS FROM INSERT LIST IF THEY EXIST ALREADY 
        for (Asset lstExistingAssets : [SELECT Id, AccountId_DIIndexID__c, AccountId, Product2Id FROM Asset WHERE AccountId IN : setAccountIds])
        {                    
            for (Integer j = 0; j < lstDI_Insert.size(); j++)
            {
                //if ((lstExistingAssets.AccountId == lstDI_Insert.get(j).AccountId) && (lstExistingAssets.Product2Id == lstDI_Insert.get(j).Product2Id))
                if (lstExistingAssets.AccountId_DIIndexID__c == (String.valueOf(lstDI_Insert.get(j).AccountId) + String.valueOf(mapProd2Id2DIIndxId.get(lstDI_Insert.get(j).Product2Id))))
                {
                    lstDI_Insert.remove(j);
                    j--;
                }
            }            
        }      
        
        Database.insert(lstDI_Insert, false);      
        
        system.debug(' *** EXITING AH_Opportunity_TriggerHandler.createDelphiFDC_DIs() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    private void verifyContactRoles(List<Opportunity> newTrigger)    
    { 
        // Name : NI_Opportunity_ClosedWon_Verify_ContactRole
        // Author : Stuart Emery
        // Created Date : 1/4/2013
        // Last Mod By: Stuart Emery
        // Last Mod Date: 1/4/2013
        // Salesforce.com Change Request:  NICC-005529
        // Description : An Opportunity cannot be set to 'Closed Won' unless there is an Active 
        // Bill To, Ship To and Customer Project Contact associated with the Opportunity
        
        system.debug(' *** ENTERING AH_Opportunity_TriggerHandler.verifyContactRoles() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // Create a List of all of the Contact Role records for the Opportunities where the Contact Status is "Active"
        List<OpportunityContactRole> cRoles = [SELECT Role, Contact.Id, OpportunityId 
                                               FROM OpportunityContactRole 
                                               WHERE OpportunityId IN : newTrigger 
                                               AND Contact.Status__c = 'Active'];
        
        // Loop through the newTrigger List of Opportunities
        for (Opportunity o : newTrigger) 
        {
            
            // LOOP THROUGH ALL ROLES AND FIND ROLES THAT RELATE TO CURRENT OPPORTUNITY
            List<OpportunityContactRole> lstCRoles = new List<OpportunityContactRole>();
            
            for (OpportunityContactRole crs : cRoles)
            {
                if (crs.OpportunityId == o.Id)
                {
                    lstCRoles.Add(crs);
                }
            }
            
            // IF THERE IS MORE THAN 2 CONTACT ROLES THEN CONTINUE WITH VALIDATION ELSE RAISE ERROR
            if (lstCRoles.size() > 2)
            {
                
                // Create a List of Bill To Contacts
                List<OpportunityContactRole> billTo = New List<OpportunityContactRole>();
                
                // Create a List of Ship To Contacts
                List<OpportunityContactRole> shipTo = New List<OpportunityContactRole>(); 
                
                // Create a List of Customer Project Contacts
                List<OpportunityContactRole> projContact = New List<OpportunityContactRole>();
                
                // ADDED PER SALESFORCE CHANGE REQUEST: NICC-006921
                // Create a List of Decision Maker Contacts
                List<OpportunityContactRole> decisionMaker = New List<OpportunityContactRole>();
                
                // ADDED BY STUART EMERY 06/03/2018
                // Create a List of Sponsor Contacts
                List<OpportunityContactRole> sponsor = New List<OpportunityContactRole>();
                
                // Create a List of License (Admin) Contacts
                List<OpportunityContactRole> lstLicenseContacts = New List<OpportunityContactRole>();
                
                // LOOP THOUGH ALL ROLES RELATED TO CURRENT OPPORTUNITY AND POPULATE EACH OF THE LISTS BASED ON THE ROLE VALUE
                for (OpportunityContactRole ocr : lstCRoles)
                {
                    if (ocr.Role == 'Bill To')
                    {
                        billTo.add(ocr);
                    }
                    if (ocr.Role == 'Ship To')
                    {
                        shipTo.add(ocr);
                    }
                    if (ocr.Role == 'Customer Project Contact')
                    {
                        projContact.add(ocr);
                    }
                    if (ocr.Role == 'Decision Maker')
                    {
                        decisionMaker.add(ocr);
                    }
                    if (ocr.Role == 'Sponsor')
                    {
                        sponsor.add(ocr);
                    }
                    if (ocr.Role == 'License (Admin) Contact')
                    {
                        lstLicenseContacts.add(ocr);
                    }

                }
                
                if (o.RecordTypeId != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('S&EM Limited Service Opportunity').getRecordTypeId())
                {                
                    // IF ANY OF THE LIST SIZES ARE ZERO RAISE ERROR
                    if ((billTo.size() == 0) || (shipTo.size() == 0) || (projContact.size() == 0) || (decisionMaker.size() == 0) || (sponsor.size() == 0))
                    {
                        o.addError(' There must be an active Bill To, Ship To, Customer Project Contact, Decision Maker and Sponsor associated with the Opportunity before the Stage can be set to "Closed Won" and before the Opportunity Record Type can be set to "Sales Order"');
                    }   
                }
                else
                {
                    // IF ANY OF THE LIST SIZES ARE ZERO RAISE ERROR
                    if ((billTo.size() == 0) || (shipTo.size() == 0) || (projContact.size() == 0) || (decisionMaker.size() == 0) || (sponsor.size() == 0) || (lstLicenseContacts.size() == 0))
                    {
                        o.addError(' There must be an active "Bill To", "Ship To", "Customer Project Contact", "Decision Maker", "Sponsor" & "License (Admin) Contact" opportunity contact roles associated with an "S&EM Limited Service Opportunity" Opportunity before the Stage can be set to "Closed Won".');
                    }                       
                }
                
            }
            // LESS THAN 3 CONTACT ROLES. DOES NOT MEET VALIDATION
            else 
            {
                if (o.RecordTypeId != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('S&EM Limited Service Opportunity').getRecordTypeId())
                {   
                    o.addError(' There must be an active Bill To, Ship To, Customer Project Contact, Decision Maker and Sponsor associated with the Opportunity before the Stage can be set to "Closed Won" and before the Opportunity Record Type can be set to "Sales Order"');
                }
                else
                {
                    o.addError(' There must be an active "Bill To", "Ship To", "Customer Project Contact", "Decision Maker", "Sponsor" & "License (Admin) Contact" opportunity contact roles associated with an "S&EM Limited Service Opportunity" before the Stage can be set to "Closed Won".');
                }
            }
            
        }
        
        system.debug(' *** EXITING AH_Opportunity_TriggerHandler.verifyContactRoles() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
  
    private void billToShipToCount(List<Opportunity> newTrigger)
    {
        // Name : billToShipToCount
        // Author : Stuart Emery
        // Created Date : 5/10/2013
        // Last Mod By: Stuart Emery
        // Last Mod Date: 5/10/2013
        // Salesforce.com Change Request:  NICC-007066
        // Description : An Opportunity cannot be set to 'Closed Won' if there is more than one 
        // Bill To or Ship To Contact associated with the Opportunity  
        
        system.debug(' *** ENTERING AH_Opportunity_TriggerHandler.billToShipToCount() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // Create a List of all of the Contact Role records for the Opportunities where the Contact Status is "Active"
        List<OpportunityContactRole> cRoles = [SELECT Role, Contact.Id, OpportunityId 
                                               FROM OpportunityContactRole 
                                               WHERE Role IN ('Bill To', 'Ship To') AND
                                               OpportunityId IN : newTrigger];
        
        // Loop through the newTrigger List of Opportunities
        for (Opportunity o : newTrigger) 
        {
            
            // LOOP THROUGH ALL ROLES AND FIND ROLES THAT RELATE TO CURRENT OPPORTUNITY
            List<OpportunityContactRole> lstCRoles = new List<OpportunityContactRole>();
            
            for (OpportunityContactRole crs : cRoles)
            {
                if (crs.OpportunityId == o.Id)
                {
                    lstCRoles.Add(crs);
                }
            }
            
            // IF THERE IS MORE THAN 2 CONTACT ROLES THEN CONTINUE WITH VALIDATION ELSE RAISE ERROR
            if (lstCRoles.size() > 2)
            {
                
                // Create a List of Bill To Contacts
                List<OpportunityContactRole> billTo = New List<OpportunityContactRole>();
                
                // Create a List of Ship To Contacts
                List<OpportunityContactRole> shipTo = New List<OpportunityContactRole>(); 
                
                // LOOP THOUGH ALL ROLES RELATED TO CURRENT OPPORTUNITY AND POPULATE EACH OF THE LISTS BASED ON THE ROLE VALUE
                for (OpportunityContactRole ocr : lstCRoles)
                {
                    if (ocr.Role == 'Bill To')
                    {
                        billTo.add(ocr);
                    }
                    if (ocr.Role == 'Ship To')
                    {
                        shipTo.add(ocr);
                    }                    
                }
                
                // IF ANY OF THE LIST SIZES ARE ZERO RAISE ERROR
                if ((billTo.size() > 1) || (shipTo.size() > 1))
                {
                    // system.debug('There can only be one Bill To and one Ship To Contact on an Opportunity in order to set the Opportunity Stage to Closed Won and before the Opportunity Record Type can be set to "Sales Order"');
                    o.addError('There can only be one Bill To and one Ship To Contact on an Opportunity in order to set the Opportunity Stage to Closed Won and before the Opportunity Record Type can be set to "Sales Order"');
                }                
                
            }
            
        }
        
        system.debug(' *** ENTERING AH_Opportunity_TriggerHandler.billToShipToCount() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    

    private void releaseDate(List<Opportunity> newTrigger)
    {
        
        // Author : Stuart Emery
        // Created Date : 1/21/2013
        // Last Mod By: Stuart Emery
        // Last Mod Date: 1/28/2013
        // Salesforce.com Change Request:  NICC-006223
        // Description : When an Opportunity is Set to 'Closed Won' loop through all of the 
        // Opportunity Products and set the Release Date to the Closed Date on the Opportunity 
        // for those Opportunity Products where the Deferred check box is un-checked. 
        // All Opportunity Products with the Deferred check box checked will be ignored by this trigger.
        // 		Last Updated on 1/28/2014 Per Salesforce.com Change Request: NICC-009171        
        
        system.debug(' *** ENTERING AH_Opportunity_TriggerHandler.releaseDate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // CREATE A LIST OF ALL OF THE OPPORTUNITY LINE ITEMS WHERE THE DEFERRED CHECKBOX IS UN-CHECKED
        List<OpportunityLineItem> oppLineItem = [SELECT Id, Release_Date__c, OpportunityId, Deferred__c 
                                                 FROM OpportunityLineItem 
                                                 WHERE Opportunity.StageName = 'Closed Won' 
                                                 AND Deferred__c = false AND OpportunityId IN : newTrigger];   
        
        // LIST OF OPPORTUNITY LINE ITEMS TO UPDATE
        List<OpportunityLineItem> lstOppLnItemsToUpdate = new List<OpportunityLineItem>();
        
        // LOOP THROUGH THE newTrigger LIST OF OPPORTUNITIES
        for (Opportunity o : newTrigger) 
        {     
            // LOOP THROUGH ALL OPPORTUNITY LINE ITEMS AND SET THE RELEASE DATE            
            for (OpportunityLineItem oli : oppLineItem)
            {
                if (oli.OpportunityId == o.Id)
                {
                    oli.Release_Date__c = o.CloseDate;
                    
                    // ADD THE OPPORTUNITY LINE ITEM TO THE lstOppLnItemsToUpdate LIST   
                    lstOppLnItemsToUpdate.Add(oli);
                }
            }                                                 
        }
        
        //USE DATABASE DML METHOD TO UPDATE ALL OF THE OPPORTUNITY LINE ITEMS
        if (lstOppLnItemsToUpdate.size() > 0)
        {
            Database.SaveResult[] results = Database.update(lstOppLnItemsToUpdate, false);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    system.debug(err.getMessage());
                }
            }
        } 
        
        system.debug(' *** EXITING AH_Opportunity_TriggerHandler.releaseDate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }         

}