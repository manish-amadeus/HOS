/****************************************************************************************
Name            : NI_SandboxData Class
Author          : Sean Harris
Created Date    : 5/9/2012
Last Mod Date   : 2/14/2014
Last Mod By     : Sean Harris
NICC Reference  : NICC-007105: Creation of class to populate new dev sandboxes
Description     : Intended use: After creation or refresh of a Sandbox run the following  
                : code to create some test data: 
                SYNCS PRODUCTS TO PRODUCTION
                    NI_SandboxData s = new NI_SandboxData(1);
                CREATES ACCOUNTS CONTACTS & CASES
                    NI_SandboxData s = new NI_SandboxData(2);
                INITIALIZES FFA
					NI_SandboxData.createFFAQueue();
                    NI_SandboxData s = new NI_SandboxData(3);
******************************************************************************************/
public class NI_SandboxData 
{
   
    public NI_SandboxData()
    {    
    
    }
    
/*    
    
    
    public static HttpRequest hReq; 
    public static String LOGIN_DOMAIN;
    public static String SERVER_URL;
    public static String SESSION_ID;           
    public static String pwd {get; set;}
    public static String userName {get; set;}
    public static List<idMaps> lstDIIndexIdMaps;
    public static List<NI_DeploymentInstanceIndex__c> lstNI_DeploymentInstanceIndexes; 
    public static List<NI_DeploymentInstanceIndex__c> lstNI_DeploymentInstanceIndexes_INSERTS = new List<NI_DeploymentInstanceIndex__c>();
    public static List<Product_Group__c> lstProductGroups; 
    public static List<Product_Group__c> lstProduct_Group_INSERTS = new List<Product_Group__c>();
  	
 
    public NI_SandboxData(integer iMode)
    {
        if (iMode == 1)
        {
            getProdData();
        }
        if (iMode == 2)
        {
            CreateData();
        }
        if (iMode == 3)
        {
            createFFAData();
        }  
    }

    
    @Future(callout=true)
    public static void getProdData()
    {    
        // PREVENT THIS FROM EXECUTION AGAINST AN ORG THAT IS NOT A SANDBOX 
//        if (URL.getSalesforceBaseUrl().toExternalForm().substring(0,10) != 'https://cs')
//        {
//            return;
//        }

        // RETRIEVE CREDENTIALS FROM CUSTOM SETTINGS
        NI_Sandbox_Data_Refresh__c SandboxDataRefresh = NI_Sandbox_Data_Refresh__c.getValues('Sandbox Data User Creds'); 
        system.debug('SandboxDataRefresh===='+SandboxDataRefresh);
        
        // ASSIGN CUSTOM SETTINGS TO LOGIN VARIABLES
        LOGIN_DOMAIN = SandboxDataRefresh.SF_Server_Instance_Name__c; 
        userName = SandboxDataRefresh.User_Name__c; 
        pwd = SandboxDataRefresh.Password__c + SandboxDataRefresh.Security_Token__c; 
        
        // IF LOGIN IS SUCCESSFUL
        if (doLogin() || Test.isRunningTest())
        {
            
            system.debug('doLogin() was successful. ');
            
            // QUERY ALL DEPLOYMENT INDEXES FROM PRODUCTION 
            getDIIndexes(); 
            
            // QUERY ALL PRODUCT GROUPS FROM PRODUCTION 
            getProductGroups();             

            // BYPASS ALL TRIGGERS
            NI_TriggerBypassSwitches__c ts = NI_TriggerBypassSwitches__c.getValues('Bypass Control Panel'); 
            ts.MasterSwitch_ON__c = true;
            Database.update(ts);            
            
            // INSTANTIATE LIST OF INNER CLASS OBJECTS FOR ID MAPPINGS 
            lstDIIndexIdMaps = new List<idMaps>();
            
            // LOOP THROUGH ALL QUERIED DEPLOYMENT INDEXES FROM PRODUCTION CREATING NEW DEPLOYMENT INDEX RECORDS AND ADDING 
            // NEWLY CREATED RECORD IDS TO LIST OF INNER CLASS OBJECTS 
            NI_DeploymentInstanceIndex__c newDIIndxDummy = new NI_DeploymentInstanceIndex__c();
            newDIIndxDummy.Name = 'APEX TEST GENERATED';
            insert newDIIndxDummy;
            lstNI_DeploymentInstanceIndexes.Add(newDIIndxDummy);  
            
            for (NI_DeploymentInstanceIndex__c lstDIIs : lstNI_DeploymentInstanceIndexes)
            { 
                NI_DeploymentInstanceIndex__c newDIIndx = new NI_DeploymentInstanceIndex__c();
                newDIIndx.Name = lstDIIs.Name;
                lstNI_DeploymentInstanceIndexes_INSERTS.Add(newDIIndx);  
                lstDIIndexIdMaps.Add(new idMaps('NI_DeploymentInstanceIndex__c', lstDIIs.Name, lstDIIs.Id, null)); 
            }
            
            // INSERT NEW DEPLOYMENT INDEX RECORDS, ALL OR NOTHING
            Database.Insert(lstNI_DeploymentInstanceIndexes_INSERTS, true);
            
system.debug('di index inserted===='+lstNI_DeploymentInstanceIndexes_INSERTS.size());
system.debug('lstDIIndexIdMaps===='+lstDIIndexIdMaps.size());
            
            // CREATE A DEPLOYMENT INDEX to ID MAP AND FILL IT WITH NEW IDS
            Map<string, string> diNameIdMap = new map<string, string>();
            
            for (NI_DeploymentInstanceIndex__c di : lstNI_DeploymentInstanceIndexes_INSERTS)
            {
                diNameIdMap.put(di.Name, di.id);
            }
            
            
            List<idMaps> testimapupdate = new list<idMaps>();
            
            for (idMaps m : lstDIIndexIdMaps)
            {
                if (m.ObjectName == 'NI_DeploymentInstanceIndex__c')
                {
                    if (diNameIdMap.containskey(m.Name))
                    {
                        m.NewId = diNameIdMap.get(m.Name);
                        testimapupdate.add(m);
                    }
                }
            }

            Product_Group__c newPGDummy = new Product_Group__c();
            newPGDummy.Name = 'APEX TEST GENERATED';
            insert newPGDummy;
            lstProductGroups.add(newPGDummy);
                
            for (Product_Group__c lstPGs : lstProductGroups)
            {
                Product_Group__c newPG = new Product_Group__c();
                newPG.Name = lstPGs.Name;
                lstProduct_Group_INSERTS.Add(newPG);
                lstDIIndexIdMaps.Add(new idMaps('Product_Group__c', lstPGs.Name, lstPGs.Id, null));
            }            
            
            Database.Insert(lstProduct_Group_INSERTS, true);

            Map<string, string> pgIDNameMap = new map<string, string>();
            
            for (Product_Group__c pg : lstProduct_Group_INSERTS)
            {
                pgIDNameMap.put(pg.Name,pg.id);
            }
            
            for (idMaps m : lstDIIndexIdMaps)
            {
                if (m.ObjectName == 'Product_Group__c')
                {
                    if (pgIDNameMap.containskey(m.Name))
                    {
                        m.NewId = pgIDNameMap.get(m.Name);
                    }
                }
            }
            
            Map<Id, Id> mapOldIds2NewIds = new Map<Id, Id>();           
            
            for (idMaps m : lstDIIndexIdMaps)
            {
                mapOldIds2NewIds.Put(m.OldId, m.NewId);
            }            
            

            List<Product2> allProduct2Update = new List<Product2>();

            for (List<Product2> lstProduct2Update : [SELECT Id, Product_Group__c, DI_Index__c,  
                                                     Vendor_Agreement_Rule__c,
                                                     c2g__CODASalesRevenueAccount__c,                      
                                                     c2g__CODAPurchaseAnalysisAccount__c,                      
                                                     c2g__CODATaxCode__c,
                                                     c2g__CODAInputTaxCode__c,
                                                     c2g__CODAIncomeSchedule__c,
                                                     ffrr_exa__RevenueRecognitionAccount__c,
                                                     Partner_Product_Catalog__c,
                                                     Partner_Name__c,
                                                     Apttus_Config2__HasOptions__c, 
                                                     Revenue_Category__c 
                                                     FROM Product2 
                                                     WHERE (DI_Index__c != null OR Product_Group__c != null)])
            {
                for (Product2 pd : lstProduct2Update)
                {
                    //allProduct2Update = new List<Product2>();
                    if (mapOldIds2NewIds.containsKey(pd.DI_Index__c))
                    {
                        pd.DI_Index__c = mapOldIds2NewIds.get(pd.DI_Index__c);
                    }
                    if (mapOldIds2NewIds.containsKey(pd.Product_Group__c))
                    {
                        pd.Product_Group__c = mapOldIds2NewIds.get(pd.Product_Group__c);
                    }
                    
                    // PREVENTS VALIDATION RULE 
                    // Revenue Category has to be blank when "Has Options" field is checked: [Revenue_Category__c]
                    if (pd.Apttus_Config2__HasOptions__c)
                    {
                        pd.Revenue_Category__c = 'Services';
                    }
                    
                    
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------                    
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------                    
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------                    
// ADD EXCEPTION FIELDS HERE SETTING VALUE TO NULL. REASON: FUTURE LOOKUPS WILL COME OVER WITH PRODUCTION IDS CAUSING UPDATES ON PRODUCT GROUP & DI INDEX TO FAIL!                    
                    pd.Vendor_Agreement_Rule__c = null;
                    pd.c2g__CODASalesRevenueAccount__c = null;                        
                    pd.c2g__CODAPurchaseAnalysisAccount__c = null;                        
                    pd.c2g__CODATaxCode__c = null;
                    pd.c2g__CODAInputTaxCode__c = null;
                    pd.c2g__CODAIncomeSchedule__c = null;
                    pd.ffrr_exa__RevenueRecognitionAccount__c = null;
                    pd.Partner_Product_Catalog__c = null;
                    pd.Partner_Name__c = null;
                    
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------                    
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------                    
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------                      
                    
                    allProduct2Update.add(pd);
                }
//                if (allProduct2Update.size() > 0)
//                {
//                    Database.Update(allProduct2Update);
//                }
            }

            system.debug('allProduct2Update.Size() = ' + allProduct2Update.Size());
            
            if (allProduct2Update.size() > 0)
            {
                Database.Update(allProduct2Update);
            }
            
            system.debug('DI INDEX LIST SIZE==='+lstNI_DeploymentInstanceIndexes.size());
            system.debug('LIST PROD GROUP==='+lstProductGroups.size());
            
            system.debug('testimapupdate==='+testimapupdate);
            system.debug('lstProduct_Group_INSERTS=='+lstProduct_Group_INSERTS.size());

            ts.MasterSwitch_ON__c = false;
            Database.update(ts);     
            
        }         
        
        //CreateData();
        
    }
    
    public static boolean doLogin()
    {
        
        system.debug('... Entering NI_SandboxData.doLogin()');
        boolean bIsSuccessful = true;       
        
        try
        {
            
            hReq = new HttpRequest();
            hReq.setEndpoint('https://' + LOGIN_DOMAIN + '.salesforce.com/services/Soap/u/22.0');
            hReq.setMethod('POST');
            hReq.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            hReq.setHeader('SOAPAction', '""');
            hReq.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + userName + '</username><password>' + pwd + '</password></login></Body></Envelope>');
            
            system.debug('hReq = ' + hReq);    
            Dom.XmlNode resultElmt = (new Http()).send(hReq).getBodyDocument().getRootElement()
                .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
                .getChildElement('result', 'urn:partner.soap.sforce.com');  
            system.debug('resultElmt = ' + resultElmt);  
            
            SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com').getText().split('/services')[0];
            SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com').getText();            
            
        }
        catch (Exception e)
        {
            system.debug('Error in NI_SandboxData.doLogin()! Line: ' + e.getLineNumber() + ' - ' + e.getMessage());
            bIsSuccessful = false;
        }
        
        return bIsSuccessful;
        
    }
    
    public static void getDIIndexes()
    {
        
        system.debug('... Entering NI_SandboxData.getDIIndexes()');
        
        try
        {        
            
            lstNI_DeploymentInstanceIndexes = new List<NI_DeploymentInstanceIndex__c>();
            
            PageReference theUrl = new PageReference(SERVER_URL + '/services/data/v22.0/query/');
            theUrl.getParameters().put('q', 'SELECT Id, Name FROM NI_DeploymentInstanceIndex__c');
            
            hReq = new HttpRequest(); 
            hReq.setTimeout(20000);
            hReq.setEndpoint(theUrl.getUrl());
            hReq.setMethod('GET');
            hReq.setHeader('Authorization', 'OAuth ' + SESSION_ID);
            
            String body = (new Http()).send(hReq).getBody();
            system.debug('******body  **********');
            system.debug(body);
            
            JSONParser parser = JSON.createParser(body);
            
            while (parser.nextToken() != null) 
            {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) 
                {
                    while (parser.nextToken() != null) 
                    {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            NI_DeploymentInstanceIndex__c dii = (NI_DeploymentInstanceIndex__c)parser.readValueAs(NI_DeploymentInstanceIndex__c.class);
                            lstNI_DeploymentInstanceIndexes.add(dii);
                        }
                    }
                }
            } 
        }
        catch (Exception e)
        {
            system.debug('Error in NI_SandboxData.getDIIndexes(): ' + e.getMessage());
        }        
        
    }
    
    public static void getProductGroups()
    {
        
        system.debug('... Entering NI_SandboxData.getProductGroups()');
        
        try
        {        
            
            lstProductGroups = new List<Product_Group__c>();
            
            PageReference theUrl = new PageReference(SERVER_URL + '/services/data/v22.0/query/');
            theUrl.getParameters().put('q', 'SELECT Id, Name FROM Product_Group__c');
            
            hReq = new HttpRequest(); 
            hReq.setEndpoint(theUrl.getUrl());
            hReq.setMethod('GET');
            hReq.setHeader('Authorization', 'OAuth ' + SESSION_ID);
            
            String body = (new Http()).send(hReq).getBody();
            system.debug('******body  **********');
            system.debug(body);
            
            JSONParser parser = JSON.createParser(body);
            
            while (parser.nextToken() != null) 
            {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) 
                {
                    while (parser.nextToken() != null) 
                    {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            Product_Group__c pg = (Product_Group__c)parser.readValueAs(Product_Group__c.class);
                            lstProductGroups.add(pg);
                        }
                    }
                }
            } 
        }
        catch (Exception e)
        {
            system.debug('Error in NI_SandboxData.getProductGroups(): ' + e.getMessage());
        }        
        
    }    

    public class idMaps 
    {
        public String ObjectName {get; set;}
        public String Name {get; set;}
        public Id OldId {get; set;}
        public Id NewId {get; set;}
        
        public idMaps (
            String ObjectName, 
            String Name,
            Id OldId, 
            Id NewId)
        {
            this.ObjectName = ObjectName;
            this.Name = Name;
            this.OldId = OldId;
            this.NewId = NewId;
        } 
    }      

 
    
    
    @future
    public static void CreateData()
    {
        
        List<Account> lstAllAccounts = new List<Account>(); 
        CreateChildAccounts();
        List<Contact> lstAllContacts = new List<Contact>();
        List<Case> lstAllCases = new List<Case>(); 
        List<Opportunity> lstAllOpportunities = new List<Opportunity>(); 
        List<Asset> lstAllAssets = new List<Asset>(); 
        
        lstAllAccounts = CreateAccounts();
        lstAllContacts = CreateContacts(lstAllAccounts);
        lstAllCases = CreateCases(lstAllContacts);
        lstAllOpportunities = CreateOpportunities(lstAllAccounts);
        //lstAllAssets = CreateAssets(lstAllAccounts);
        
    }
    
    private static List<Account> CreateAccounts()
    {
        
        // ============================================================
        // CREATE ACCOUNTS (5)
        // ============================================================
        List<Account> lstNewAccounts = new List<Account>();
        List<Account> lstAccInsert = new List<Account>();
        List<String> accNames = new List<String> {'Newmarket Hotels & Resorts, Customer, 75 New Hampshire Ave, Portsmouth, NH, 03801, US', 'Newmarket Suites - Boston, Customer, 99 Boyleston St., Boston, MA, 02199, US', 'Newmarket Suites - Orlando, Customer, 105 Ocean Ave, Orlando, FL, 32819, US', 'Newmarket Suites - San Francisco, Customer, 8935 Tenderloin Way, San Francisco, CA, 94102, US', 'Newmarket Suites - Denver, Customer, 1 International Drive, Denver, CO, 80207, US'};
            
        for (integer i = 0; i < accNames.Size(); i++)
        {
            string[] accAttributes = accNames[i].split(',');
            Account a = NI_TestClassData.createTestAccount(i);
            
            a.Name = accAttributes[0].trim();
            a.Type = accAttributes[1].trim();
            a.BillingStreet = accAttributes[2].trim();
            a.BillingCity= accAttributes[3].trim(); 
            a.BillingState = accAttributes[4].trim();          
            a.BillingPostalCode = accAttributes[5].trim(); 
            a.BillingCountry = accAttributes[6].trim();
            a.Phone = '(603)430-6738'; 
            a.AccountNumber = 'NI00' + String.ValueOf(i);
            
            lstAccInsert.add(a);
        }
        
        Database.insert(lstAccInsert);
        
        lstNewAccounts = [SELECT Id, Name 
                          FROM Account 
                          WHERE Name LIKE 'Newmarket%' 
                          AND Phone = '(603)430-6738'
                          AND AccountNumber LIKE 'NI00%'
                          LIMIT 10];
        
        return lstNewAccounts;
        
    }
    
    private static void CreateChildAccounts()
    {
        
        List<Account> accParent = [SELECT Id FROM Account WHERE Name = 'Newmarket Hotels & Resorts' LIMIT 1];
        List<Account> lstAccUpdate = new List<Account>();
        
        for (Account acc : [SELECT Id FROM Account WHERE Name LIKE 'Newmarket Suites%'])
        {
            acc.ParentId = accParent[0].Id;
            lstAccUpdate.add(acc);
        }
        
        Database.update(lstAccUpdate);
        
    }
    
    private static List<Contact> CreateContacts(List<Account> accs)
    {
        
        // ============================================================
        // CREATE CONTACTS (15)
        // ============================================================
        List<Contact> lstNewContacts = new List<Contact>();
        List<Contact> lstContactInsert = new List<Contact>();
        List<String> contactNames = new List<String> 
        { 
            'Erika, Tate, sharris@newmarketinc.com, (603)430-6738, 75 New Hampshire Ave, Portsmouth, NH, 03801, US',  
                'Jillian, Tanner, semery@newmarketinc.com, (603)427-5885, 75 New Hampshire Ave, Portsmouth, NH, 03801, US',  
                'Felicia, Gump, pdixon@newmarketinc.com, (603)427-5890, 75 New Hampshire Ave, Portsmouth, NH, 03801, US',  
                
                'Frederick, Stover, sharris@newmarketinc.com, (603)430-6738, 99 Boyleston St., Boston, MA, 02199, US', 
                'Gerik, Koen, semery@newmarketinc.com, (603)430-6738, 99 Boyleston St., Boston, MA, 02199, US', 
                'Theresa, Moulaine, pdixon@newmarketinc.com, (603)427-5890, 99 Boyleston St., Boston, MA, 02199, US', 
                
                'Gunther, Weller, sharris@newmarketinc.com, (603)430-6738, 105 Ocean Ave, Orlando, FL, 32819, US', 
                'Jalane, Ayrole, semery@newmarketinc.com, (603)427-5885, 105 Ocean Ave, Orlando, FL, 32819, US', 
                'Lara, Moore, pdixon@newmarketinc.com, (603)427-5890, 105 Ocean Ave, Orlando, FL, 32819, US', 
                
                'Jessara, Cordell, sharris@newmarketinc.com, (603)430-6738, 8935 Tenderloin Way, San Francisco, CA, 94102, US',
                'Evan, Larson, semery@newmarketinc.com, (603)427-5885, 8935 Tenderloin Way, San Francisco, CA, 94102, US',
                'Joachim, Brenlow, pdixon@newmarketinc.com, (603)427-5890, 8935 Tenderloin Way, San Francisco, CA, 94102, US',
                
                'Julia, Gallina, sharris@newmarketinc.com, (603)430-6738, 1 International Drive, Denver, CO, 80207, US',
                'Rebecca, Laughlin, semery@newmarketinc.com, (603)427-5885, 1 International Drive, Denver, CO, 80207, US',
                'Keldric, Boucher, pdixon@newmarketinc.com, (603)427-5890, 1 International Drive, Denver, CO, 80207, US'
                
                };
                    
        integer iCounter = 1;
        integer iAccountIndex = 0;
        
        for (integer i = 0; i < contactNames.Size(); i++)
        {
            string[] accAttributes = contactNames[i].split(',');
            Contact c = NI_TestClassData.createTestContact(i, accs[iAccountIndex].Id);
            
            c.FirstName = accAttributes[0].trim();
            c.LastName = accAttributes[1].trim();
            c.email = accAttributes[2].trim();   
            c.phone = accAttributes[3].trim();         
            c.MailingStreet = accAttributes[4].trim();  
            c.MailingCity = accAttributes[5].trim();    
            c.MailingState = accAttributes[6].trim();   
            c.MailingPostalCode = accAttributes[7].trim();  
            c.MailingCountry = accAttributes[8].trim(); 
            
            lstContactInsert.add(c);
            
            if (iCounter == 3)
            {
                iCounter = 1;
                iAccountIndex += 1;
            }
            else
            {
                iCounter += 1;
            }
            
        }
        
        Database.insert(lstContactInsert);
        
        lstNewContacts = [SELECT Id, AccountId FROM Contact LIMIT 30];
        
        return lstNewContacts;
        
    }       
    
    private static List<Case> CreateCases(List<Contact> cntcts)
    {
        
        // ============================================================
        // CREATE CASES (45)
        // ============================================================
        List<Case> lstNewCases = new List<Case>();
        List<Case> lstCaseInsert = new List<Case>();
        
        for (integer i = 0; i < cntcts.Size(); i++)
        {           
            for (integer j = 0; j < 3; j++)
            {               
                
                Case c = NI_TestClassData.createTestCase(j, cntcts[i].AccountId);
                
                c.ContactId = cntcts[i].Id; 
                c.Subject = 'Test Case #' + String.ValueOf(j);      
                c.Description = 'Details here...';
                c.Status = 'Working';
                
                lstCaseInsert.add(c);           
            }           
        }
        
        Database.insert(lstCaseInsert);
        
        lstNewCases = [SELECT Id FROM Case LIMIT 60];
        
        return lstNewCases;
        
    }   
    
    private static List<Opportunity> CreateOpportunities(List<Account> accs)
    {
        
        // ============================================================
        // CREATE OPPORTUNITIES (15)
        // ============================================================
        List<Opportunity> lstNewOpportunities = new List<Opportunity>();
        List<Opportunity> lstOpportunityInsert = new List<Opportunity>();
        
        for (integer i = 0; i < accs.Size(); i++)
        {           
            for (integer j = 0; j < 3; j++)
            {               
                
                Opportunity o = NI_TestClassData.createTestOpportunity(j, accs[i].Id);
                
                o.Name = accs[i].Name + ' Opportunity #' + String.ValueOf(accs[i].Name);
                o.StageName = 'Prospecting';
                o.Order_Status__c = 'Prospect';
                o.Amount = 25000 * j;
                o.CloseDate = Date.Today().addMonths(6);
                o.Effective_Date__c = Date.Today().addMonths(6);
                
                lstOpportunityInsert.add(o);
                
            }           
        }
        
        Database.insert(lstOpportunityInsert);
        
        lstNewOpportunities = [SELECT Id FROM Opportunity LIMIT 60];
        
        return lstNewOpportunities;
        
    }
   
    private static List<Asset> CreateAssets(List<Account> accs)
    {
        
        // ============================================================
        // CREATE ASSETS (15)
        // ============================================================
        List<Asset> lstNewAssets = new List<Asset>();
        List<Asset> lstAssetInsert = new List<Asset>();
        
        List<Product_Group__c> lstPGInsert = new List<Product_Group__c>();
        List<SFDC_CSP_Version__c> lstVersionInsert = new List<SFDC_CSP_Version__c>();
        
        Product_Group__c pg1 = new Product_Group__c(Name = 'Delphi Multi Property', IsCoreProduct__c = true, TFS_Collection__c = 'http://vas066:8080/tfs/newmarket');
        Product_Group__c pg2 = new Product_Group__c(Name = 'Meetingbroker', IsCoreProduct__c = true, TFS_Collection__c = 'http://vas066:8080/tfs/newmarket');
        Product_Group__c pg3 = new Product_Group__c(Name = 'Cendyn', IsCoreProduct__c = false, TFS_Collection__c = 'http://vas066:8080/tfs/newmarket');
        
        insert pg1;
        insert pg2;
        insert pg3;         
        
        SFDC_CSP_Version__c v1 = new SFDC_CSP_Version__c(Name = 'Delphi v9.5.3 AP5', Inactive__c = false, Product_Group__c = pg1.Id);
        SFDC_CSP_Version__c v2 = new SFDC_CSP_Version__c(Name = 'MeetingBroker v3.0', Inactive__c = false, Product_Group__c = pg2.Id);
        //SFDC_CSP_Version__c v3 = new SFDC_CSP_Version__c(Name = 'Delphi v9.5.3 AP5', Inactive__c = false, Product_Group__c = pg3.Id);
        
        insert v1;
        insert v2;
        
        //CREATE A TEST PRODUCT GROUP FOR THE TEST PRODUCT RECORD
        //        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        //        insert pgp;
        
        List<Product2> lstProds = new List<Product2>();
        
        //CREATE TEST PRODUCTS TO BE USED WHEN CREATING A TEST DEPLOYMENT INSTANCE
        //UPDATED ON 2/14/2014 BASED ON CONTRAINT RULE THAT MAKES DEPLOYMENT INSTANCES UNIQUE FOR EACH ACCOUNT
        Product2 prd01 = NI_TestClassData.createProduct2(1, pg1.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        lstProds.add(prd01);
        
        Product2 prd02 = NI_TestClassData.createProduct2(2, pg2.Id, 'HRM-DFDCQS-01-TEST2', 'Subscription');
        lstProds.add(prd02);
        
        Product2 prd03 = NI_TestClassData.createProduct2(3, pg3.Id, 'HRM-DFDCQS-01-TEST3', 'Subscription');
        lstProds.add(prd03);
        
        Database.Insert(lstProds);
        
        for (integer i = 0; i < accs.Size(); i++)
        {
            
            Asset a1 = NI_TestClassData.createTestasset(1, accs[i].Id, prd01.Id);
            a1.Name = 'Delphi Multi Property 9.5.3';
            a1.Product_Group__c = pg1.Id;
            a1.Version__c = v1.Id;
            a1.Product2Id = prd01.Id;
            a1.Status = 'Installed';
            lstAssetInsert.add(a1);
            
            Asset a2 = NI_TestClassData.createTestasset(2, accs[i].Id, prd02.Id);
            a2.Name = 'MeetingBroker';
            a2.Product_Group__c = pg2.Id;
            a2.Version__c = v2.Id;
            a2.Product2Id = prd02.Id;
            a2.Status = 'Installed';  
            lstAssetInsert.add(a2);
            
            Asset a3 = NI_TestClassData.createTestasset(3, accs[i].Id, prd03.Id);
            a3.Name = 'Cendyn';
            a3.Product_Group__c = pg3.Id;
            a3.Product2Id = prd03.Id;
            //a3.Version__c = v3.Id;            
            a3.Status = 'Installed';
            lstAssetInsert.add(a3);                     
            
        }
        
        Database.insert(lstAssetInsert);
        
        lstNewAssets = [SELECT Id FROM Asset LIMIT 60];
        
        return lstNewAssets;
        
    }

    
    
    
    
    public static void createFFAQueue()
    {
        
        // FILL A LIST OF A QUEUE "SUPPORTED OBJECTS" API NAMES
        List<String> lstObjAPINames = new List<String>();
        lstObjAPINames.add('c2g__AsOfAging__c');
        lstObjAPINames.add('c2g__CancelPayment__c');
        lstObjAPINames.add('c2g__ReportingBalance__c');
        lstObjAPINames.add('c2g__codaAccountingCurrency__c');
        lstObjAPINames.add('c2g__codaBankAccount__c');
        lstObjAPINames.add('c2g__codaBankReconciliation__c');
        lstObjAPINames.add('c2g__codaBankStatement__c');
        lstObjAPINames.add('c2g__codaBudget__c');
        lstObjAPINames.add('c2g__codaCashEntry__c');
        lstObjAPINames.add('c2g__codaCashMatchingHistory__c');
        lstObjAPINames.add('c2g__codaCompany__c');
        lstObjAPINames.add('c2g__codaCreditNote__c');
        lstObjAPINames.add('c2g__codaCurrencyRevaluationGroup__c');
        lstObjAPINames.add('c2g__codaCurrencyRevaluation__c');
        lstObjAPINames.add('c2g__codaGroupingReference__c');
        lstObjAPINames.add('c2g__codaIntercompanyDefinition__c');
        lstObjAPINames.add('c2g__codaIntercompanyTransfer__c');
        lstObjAPINames.add('c2g__codaInvoice__c');
        lstObjAPINames.add('c2g__codaJournal__c');
        lstObjAPINames.add('c2g__codaMatchingReference__c');
        lstObjAPINames.add('c2g__codaPaymentMediaControl__c');
        lstObjAPINames.add('c2g__codaPaymentMediaSummary__c');
        lstObjAPINames.add('c2g__codaPaymentTemplate__c');
        lstObjAPINames.add('c2g__codaPayment__c');
        lstObjAPINames.add('c2g__codaPurchaseCreditNote__c');
        lstObjAPINames.add('c2g__codaPurchaseInvoice__c');
        lstObjAPINames.add('c2g__codaTextDefinition__c');
        lstObjAPINames.add('c2g__codaTransaction__c');
        lstObjAPINames.add('c2g__codaYear__c');

        // CREATE TEST COMPANY QUEUE 
        Group qg = new Group();
        qg.Type = 'Queue'; 
        qg.Name = 'APEX ACME CO';
        insert qg;
        
        List<QueueSObject> lstQueueObjects = new List<QueueSObject>();
        for (String o : lstObjAPINames)
        {
            QueueSObject qo = new QueueSObject();
            qo.SobjectType = o;
            qo.QueueId = qg.Id;
            lstQueueObjects.add(qo);
        }
        
        database.insert(lstQueueObjects);
        
    }
    
    
    @future
    public static void createFFAData()
    {
        Account a = [SELECT Id FROM Account WHERE Name = 'Newmarket Hotels & Resorts'];
        Product2 p2 = [SELECT Id, ProductCode FROM Product2 WHERE Name LIKE '%delphi%' AND Family = 'Subscription' AND IsActive = true LIMIT 1];   
//    	Contact c = [SELECT Id FROM Contact WHERE FirstName = 'APEXTESTUSER' AND LastName = 'APEXTESTUSER'];
 		Date dt = system.date.today();        

        // UPDATE ACCOUNT WITH REQUIRED FFA FIELDS      
        a.c2g__CODAAccountTradingCurrency__c = 'USD'; 
        a.c2g__CODATaxCalculationMethod__c = 'Gross';
        update a;
        
        // GET RUNNING USER RECORD
        User ru = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        // CREATE TEST COMPANY
        c2g__codaCompany__c co = new c2g__codaCompany__c();
        
		Group q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'APEX ACME CO'];
        
        // ADD contextUser AS A MEMBER OF THE TEST QUEUE
//        GroupMember gm = new GroupMember();
//        gm.GroupId = q.Id; 
//        gm.UserOrGroupId = ru.Id;
 //       insert gm;

        // CREATE TEST COMPANY
        co.Name = 'APEX ACME CO'; 
        co.OwnerId = q.Id;
        co.RecordTypeId = Schema.SObjectType.c2g__codaCompany__c.RecordTypeInfosByName.get('VAT').RecordTypeId;
        insert co;
        
        // ADD USER RUNNING TEST TO THE TEST COMPANY
        c2g__codaUserCompany__c uCo = NI_TestClassData.createFFAUserCompany(co.Id, ru.Id);
        insert uCo;  

        
        c2g__codaYear__c yr = NI_TestClassData.createFFAYear(String.valueOf(Date.today().year()), co.Id, q.Id);
        insert yr;
        c2g.CODAYearWebService.calculatePeriods(yr.Id);
        
        c2g__codaPeriod__c prd = NI_TestClassData.createFFAPeriod('APEX_TEST', co.Id, yr.Id);
        insert prd;
        
        c2g__codaAccountingCurrency__c ac = NI_TestClassData.createFFAAccountingCurrency('USD', co.Id, q.Id);
        insert ac;        
        
        c2g__codaExchangeRate__c exrt = NI_TestClassData.createFFAcodaExchangeRate(co.Id, ac.Id);
        insert exrt;
        
        ffrr__Settings__c ffrrS = NI_TestClassData.createSettings();
        insert ffrrS;
        
        ffrr__Template__c ffrrT = NI_TestClassData.createffrrTemplate(ffrrS.Id);
        insert ffrrT;
        
        ffrr__ForecastScheduleDefinition__c fsd = NI_TestClassData.createForecastScheduleDefinition();
        insert fsd;
        
        ffrr__FieldMappingDefinition__c fmd = NI_TestClassData.createFieldMappingDefinition();
        insert fmd;
        
        ffrr__FieldMapping__c fmp = NI_TestClassData.createFieldMapping(fmd.Id);
        insert fmp;
        
        // THIS TEST CAUSES FOLLOWING ERROR:
        // FIELD_CUSTOM_VALIDATION_EXCEPTION, Object validation has failed. Integration Rule: Object validation has failed. 
        // You cannot specify target or source master objects without creating at least one field mapping line.: []
//        c2g__codaIntegrationRule__c irl = NI_TestClassData.createIntegrationRule(); 
//        insert irl;
        
//        c2g__codaIntegrationRuleLineItem__c irli = NI_TestClassData.createIntegrationRuleLineItem(irl.Id, 1);
//        insert irli;
        
        // INSERT TEST DIMENSIONS
        c2g__codaDimension1__c dim1 = NI_TestClassData.createTestDimension1();
        insert dim1;
        
        c2g__codaDimension2__c dim2 = NI_TestClassData.createTestDimension2();
        insert dim2;
        
        c2g__codaDimension3__c dim3 = NI_TestClassData.createTestDimension3();
        insert dim3;
        
        c2g__codaDimension4__c dim4 = NI_TestClassData.createTestDimension4();
        insert dim4;
        
        c2g__codaGeneralLedgerAccount__c gla = NI_TestClassData.createGeneralLedgerAccount('GLA NAME');
        insert gla;
        
        
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
		insert blgCnrct;

		Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        insert actLI;
        
        Billing_Contract_Line_Item__c bcli = NI_TestClassData.createBillingContract(blgCnrct.Id, actLI.Id);        
        insert bcli;
        
        c2g__codaInvoice__c sin = NI_TestClassData.createSalesInvoice(a.Id, dt, 100, dim1.Id, dim2.Id, dim3.Id, dim4.Id);
        insert sin;
        
        c2g__codaInvoiceLineItem__c sinli = NI_TestClassData.createSalesInvoiceLineItem(p2.Id, 100, sin.Id, dim1.Id, dim2.Id, dim3.Id, dim4.Id);
		insert sinli;        
        
        
    }
    
*/
    
}