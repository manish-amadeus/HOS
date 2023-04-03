/************************************************************************************************
Name            : AH_ProductMigrationToolCtrl_Test Class
Author          : Sean Harris
Created Date    : 04/16/2019
Last Mod Date   : 08/20/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-034281
Description     : Class that tests AH_ProductMigrationToolCtrl 
                : 
                : 
*************************************************************************************************/
@isTest
public class AH_ProductMigrationToolCtrl_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** START  - AH_ProductMigrationToolCtrl_Test.createTestData()');

        Test.StartTest();    


        // CREATE TEST ACCOUNT RECORDS
        List<Account> lstAccInserts = new List<Account>();
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'APEX TEST ACCOUNT AH_ProductMigrationToolCtrl #1';
        lstAccInserts.add(a1); 
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'APEX TEST ACCOUNT AH_ProductMigrationToolCtrl #2';
        lstAccInserts.add(a2);      
        Account a3 = NI_TestClassData.createTestAccount(3);
        a3.Name = 'APEX TEST ACCOUNT AH_ProductMigrationToolCtrl #3';
        lstAccInserts.add(a3); 
        Account a4 = NI_TestClassData.createTestAccount(4);
        a4.Name = 'APEX TEST ACCOUNT AH_ProductMigrationToolCtrl #4';
        lstAccInserts.add(a4);
        Account a5 = NI_TestClassData.createTestAccount(5);
        a5.Name = 'APEX TEST ACCOUNT AH_ProductMigrationToolCtrl #5';
        lstAccInserts.add(a5);  
        database.insert(lstAccInserts);
        
        // CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;         

        // CREATE A TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX 1'); 
        insert idx1; 

        NI_DeploymentInstanceIndex__c idx2 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX 2'); 
        insert idx2; 

        // CREATE A TEST PRODUCT RECORDS
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-CXL-01-TEST', 'Subscription');
        prd01.Name = 'APEX TEST PRODUCT #1';
        prd01.DI_Index__c = idx1.Id; 
        prd01.Product_Line_Global__c = 'Delphi.fdc'; 
        prd01.Solution_Domain_Global__c = 'Sales & Catering';
        prd01.Revenue_Category__c = 'Subscription';
        insert prd01; 

        Product2 prd02 = NI_TestClassData.createProduct2(2, pgp.Id, 'HRM-CXL-02-TEST', 'Subscription');
        prd02.Name = 'APEX TEST PRODUCT #2';
        prd02.DI_Index__c = idx2.Id;  
        prd02.Product_Line_Global__c = 'HotSOS'; 
        prd02.Solution_Domain_Global__c = 'Service Optimization';
        prd02.Revenue_Category__c = 'Subscription';
        insert prd02; 

		// CREATE TEST DI RECORDS
        List<Asset> lstAssetInserts = new List<Asset>();
        
        for (integer j = 0; j < 5; j++)
        {
            Asset di1 = NI_TestClassData.createTestAsset(1, lstAccInserts[j].Id, prd01.Id);
            di1.Product_Group__c = pgp.Id;
            lstAssetInserts.add(di1);        
            Asset di2 = NI_TestClassData.createTestAsset(2, lstAccInserts[j].Id, prd02.Id);
            di2.Product_Group__c = pgp.Id;
            lstAssetInserts.add(di2);            
        }

		database.insert(lstAssetInserts);        

        // CREATE TEST PRICEBOOK ENTRY RECORDS
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        
        Id pbkId = Test.getStandardPricebookId(); 
        
        PricebookEntry pbe1 = NI_TestClassData.createTestPricebookEntry(pbkId, prd01.Id, 1000);
        lstPBEs.add(pbe1);         
        PricebookEntry pbe2 = NI_TestClassData.createTestPricebookEntry(pbkId, prd02.Id, 1000);
        lstPBEs.add(pbe2);     
        
        Database.Insert(lstPBEs);           
        
        // GET OPPORTUNITY RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rt = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();

        // CREATE A TEST OPPORTUNITY RECORD
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, lstAccInserts[0].Id); 
        opp1.Name = 'AH_ProductMigrationToolCtrl Test Opp#1';
        opp1.RecordTypeId = rt;
        insert opp1;          
        
        // CREATE TEST OPPORTUNITY LINE ITEM RECORDS  ===================================================================================== 
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();

        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe1.Id, 1);
        lstOLIs.add(oli01);
        OpportunityLineItem oli02 = NI_TestClassData.createTestOpportunityLineItem(2, opp1.Id, pbe2.Id, 1);
        lstOLIs.add(oli02);        
        
        Database.Insert(lstOLIs);

        // CREATE A BILLING CONTACT RECORD FOR FOLLOWING ALI RECORD CREATION
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
        blgCnrct.Account__c = lstAccInserts[0].Id;
		insert blgCnrct;

		// CREATE "OPPORTUNITY RELATED ACCOUNT", "ACTIVITY LINE ITEM" & "ACCOUNT PRODUCT" RECORDS
   		List<Activity_Line_Item__c> lstALIs = new List<Activity_Line_Item__c>();
        List<AH_Opportunity_Related_Account__c> lstRelAccs = new List<AH_Opportunity_Related_Account__c>();
        List<AH_Account_Product__c> lstAccountProducts = new List<AH_Account_Product__c>();

        // 1st ELEMENT IS ACCOUNT ON OPPORTUNITY SO DO NOT INCLUDE WHEN CREATING OPPORTUNITY RELATED ACCOUNTS
        for (integer j = 1; j < 5; j++) 
        {
            
            Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
            actLI.Account__c = lstAccInserts[j].Id;
            actLI.Product__c = prd01.Id; 
            actLI.Renewal_Date__c = system.date.today().addDays(-20);
            actLI.Auto_Renewal__c = true;
            lstALIs.add(actLI);
            
            AH_Opportunity_Related_Account__c oppRelAcc = new AH_Opportunity_Related_Account__c();
            oppRelAcc.Opportunity__c = opp1.Id;
            oppRelAcc.Account__c = lstAccInserts[j].Id;
            lstRelAccs.add(oppRelAcc);                

            AH_Account_Product__c accPrd1 = new AH_Account_Product__c(); 
            accPrd1.Account__c = lstAccInserts[j].Id; 
            accPrd1.Product__c = prd01.Id; 
            accPrd1.Quantity__c = 1; 
            accPrd1.Opportunity__c = opp1.Id; 
            lstAccountProducts.add(accPrd1); 

            AH_Account_Product__c accPrd2 = new AH_Account_Product__c(); 
            accPrd2.Account__c = lstAccInserts[j].Id; 
            accPrd2.Product__c = prd02.Id; 
            accPrd2.Quantity__c = 1; 
            accPrd2.Opportunity__c = opp1.Id; 
            lstAccountProducts.add(accPrd2); 
            
        }
        
        Database.Insert(lstALIs); 
        Database.Insert(lstRelAccs); 
        Database.Insert(lstAccountProducts); 
        
        Test.stopTest(); 
        
        // ASSERTIONS
   		List<Account> lstAccount_Asserts = new List<Account>([SELECT Id FROM Account]);
        system.assertEquals(5, lstAccount_Asserts.size());
        
        List<Asset> lstAsset_Asserts = new List<Asset>([SELECT Id FROM Asset]);
        system.assertEquals(10, lstAsset_Asserts.size());
        
   		List<Activity_Line_Item__c> lstALI_Asserts = new List<Activity_Line_Item__c>([SELECT Id FROM Activity_Line_Item__c]);
        system.assertEquals(4, lstALI_Asserts.size());
        
        List<AH_Opportunity_Related_Account__c> lstRelAcc_Asserts = new List<AH_Opportunity_Related_Account__c>([SELECT Id FROM AH_Opportunity_Related_Account__c]);        
        system.assertEquals(4, lstRelAcc_Asserts.size());        
        
        system.debug(' ***  END  - AH_ProductMigrationToolCtrl_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST MAPPING MODE
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {  
        
        system.debug(' *** START - AH_ProductMigrationToolCtrl_Test.TestClassData1() - NUMBER OF QUERIES = ' + Limits.getQueries()); 
        
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = 'AH_ProductMigrationToolCtrl Test Opp#1']; 
		Account a = [SELECT Id, Name FROM Account WHERE Name = 'APEX TEST ACCOUNT AH_ProductMigrationToolCtrl #1'];
       	Product2 p = [SELECT Id, Name FROM Product2 WHERE Name = 'APEX TEST PRODUCT #1'];
        List<Activity_Line_Item__c> lstALIs = new List<Activity_Line_Item__c>(
            [SELECT Id, Product_Migration_Date__c, Renewal_Date__c, Auto_Renewal__c FROM Activity_Line_Item__c]);  
        
Map<Id, String> mapDebugPrdNames = new Map<Id, String>();
for (Product2 p2 : [SELECT Id, Name FROM Product2])
{
    mapDebugPrdNames.put(p2.Id, p2.Name);
}    

        Test.StartTest(); 
        
        // =============================================================================================================
        // 		VISUALFORCE PAGE TESTING
        // =============================================================================================================
                
        // PAGE REFERENCE 
        PageReference pr1 = Page.AH_ProductMigrationTool; 

        // ADD URL PARAM 
        pr1.getParameters().put('id', o.Id); 
        
        // SET TEST PAGE 
		Test.setCurrentPage(pr1); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER 
        AH_ProductMigrationToolCtrl ctrl = new AH_ProductMigrationToolCtrl(); 
        
for (Integer i = 0; i < ctrl.lstPMs.size(); i++)
{
    string sFromProd = 'NOT MAPPED';
    if (ctrl.lstPMs[i].fromProductId != null)
    {
        sFromProd = mapDebugPrdNames.get(ctrl.lstPMs[i].fromProductId);
    }
    system.debug(' *@*      ' + ctrl.lstPMs[i].AccountName + ': ' + sFromProd + ' --> ' + ctrl.lstPMs[i].toProductName);
}            
system.debug(' *@* Initial Load Mappings - ctrl.lstPMs.size() = ' + ctrl.lstPMs.size());
        
        // ASSERT INITIAL VARIABLE VALUES
        system.assertEquals(10, ctrl.lstPMs.size());
        system.assertEquals('', ctrl.saveMsg);
        system.assertEquals('color:green;', ctrl.saveMsgStyle);
        system.assertEquals('Multiple From Products mapped', ctrl.toastMsg);
        system.assertEquals('', ctrl.selectedAccount);
        system.assertEquals('', ctrl.toProduct);
        system.assertEquals(system.date.today().format(), ctrl.strMasterCutOffDate);
        system.assertEquals(0, ctrl.iRemoveLine);
        system.assertEquals(0, ctrl.iSelectedElement);
        system.assertEquals(false, ctrl.displayConfirmation);
        system.assertEquals(false, ctrl.showProductSelector);
        system.assertEquals(false, ctrl.saveShow);
        system.assertEquals(false, ctrl.isSuccess);
        system.assertEquals(false, ctrl.showRedMsg);
        system.assertEquals(false, ctrl.bIsFullScreen);
        system.assertEquals(false, ctrl.isPendingCommit);
        system.assertEquals(false, ctrl.isCutoffDateMode);
        system.assertEquals(true, ctrl.bShowSidebar);
        system.assertEquals(true, ctrl.bShowHeader);
        
        // HAD TO ADD THIS LOOP TO SET THE DEFAULT fromProductId VALUES. 
        // TEST IS NOT ACTING LIKE RUNTIME
        // NORMALLY GET FROM DEFAULT PICKLIST VALUES AUTOMATICALLY
        for (Integer i = 0; (i < ctrl.lstPMs.size()); i++)
        {
            if (ctrl.lstPMs[i].fromProductId == null)
            {
                ctrl.lstPMs[i].fromProductId = 'aEP0d000000FUCT';
            }
        }    

        // TEST MAIN CANCEL BUTTON
        ctrl.showCancelConfirm();
        system.assertEquals(true, ctrl.displayConfirmation);    
        ctrl.hideCancelConfirm();
        system.assertEquals(false, ctrl.displayConfirmation);  

        // EMULATE USER CLICKING GREEN ADD BUTTON
        ctrl.iSelectedElement = 1;
        ctrl.selectedAccount = a.Name;
        ctrl.toProduct = p.Name;
        ctrl.selectedProductId = null;
        ctrl.showProductSelectorDialog();
        system.assertEquals(false, ctrl.saveShow);
        system.assertEquals(true, ctrl.showProductSelector);
        system.assertEquals(false, ctrl.displayConfirmation);  
        
		// TEST CANCELLING DIALOG 
        ctrl.hideProductSelectorDialog();
        system.assertEquals(false, ctrl.saveShow);
        system.assertEquals(false, ctrl.showProductSelector);
        system.assertEquals(false, ctrl.displayConfirmation);          
  
        // REOPEN DIALOG
        ctrl.iSelectedElement = 1;
        ctrl.selectedAccount = a.Name;
        ctrl.toProduct = p.Name;
        ctrl.selectedProductId = null;        
        ctrl.showProductSelectorDialog();
		system.assertEquals(2, ctrl.lstLineItems.size());
        
        ctrl.lstLineItems[0].isSelected = true;
        ctrl.lstLineItems[1].isSelected = true;

        // EMULATE USER CLICKING GREEN ADD BUTTON
        ctrl.addProductSelections();

for (Integer i = 0; i < ctrl.lstPMs.size(); i++)
{
    string sFromProd = 'NOT MAPPED';
    if (ctrl.lstPMs[i].fromProductId != null)
    {
        sFromProd = mapDebugPrdNames.get(ctrl.lstPMs[i].fromProductId);
    }
    system.debug(' *@*      ' + ctrl.lstPMs[i].AccountName + ': ' + sFromProd + ' --> ' + ctrl.lstPMs[i].toProductName);
}            
system.debug(' *@* After Adding Mappings - ctrl.lstPMs.size() = ' + ctrl.lstPMs.size());
        
        system.assertEquals(11, ctrl.lstPMs.size());     
        system.assertEquals(true, ctrl.isSuccess);
        system.assertEquals(false, ctrl.showProductSelector);
        system.assertEquals(true, ctrl.isPendingCommit);
        
       
        // EMULATE USER CLICKING RED REMOVE BUTTON
        ctrl.iRemoveLine = 2;
        ctrl.removeLine();       

for (Integer i = 0; i < ctrl.lstPMs.size(); i++)
{
    string sFromProd = 'NOT MAPPED';
    if (ctrl.lstPMs[i].fromProductId != null)
    {
        sFromProd = mapDebugPrdNames.get(ctrl.lstPMs[i].fromProductId);
    }
    system.debug(' *@*      ' + ctrl.lstPMs[i].AccountName + ': ' + sFromProd + ' --> ' + ctrl.lstPMs[i].toProductName);
}            
system.debug(' *@* After Removing Mapping - ctrl.lstPMs.size() = ' + ctrl.lstPMs.size());
        
        // SHOULD HAVE 10        
        system.assertEquals(10, ctrl.lstPMs.size());

		// ASSERT CLEAN SLATE BEFORE SAVE        
        List<AH_Product_Migration__c> lstPMAssert1 = new List<AH_Product_Migration__c>([SELECT Id FROM AH_Product_Migration__c]);
        system.assertEquals(0, lstPMAssert1.size());
        List<AH_Product_Migration_Line_Item__c> lstPMLineAssert1 = new List<AH_Product_Migration_Line_Item__c>([SELECT Id FROM AH_Product_Migration_Line_Item__c]);
        system.assertEquals(0, lstPMLineAssert1.size());        

        // SAVE MAPPINGS
        ctrl.saveMappings();

for (Integer i = 0; i < ctrl.lstPMs.size(); i++)
{
    string sFromProd = 'NOT MAPPED';
    if (ctrl.lstPMs[i].fromProductId != null)
    {
        sFromProd = mapDebugPrdNames.get(ctrl.lstPMs[i].fromProductId);
    }
    system.debug(' *@*      ' + ctrl.lstPMs[i].AccountName + ': ' + sFromProd + ' --> ' + ctrl.lstPMs[i].toProductName);
}            
system.debug(' *@* After Saving Mappings - ctrl.lstPMs.size() = ' + ctrl.lstPMs.size());
        
        system.assertEquals(10, ctrl.lstPMs.size());
        system.assertEquals(true, ctrl.saveShow);
        system.assertEquals(false, ctrl.isPendingCommit); 

        
        
        
        // RELOAD PAGE AND ASSERT THAT IT LOADS WITH NEWLY SAVED PM RECORDS =======================================
        // PAGE REFERENCE 
        PageReference pr2 = Page.AH_ProductMigrationTool; 

        // ADD URL PARAM 
        pr2.getParameters().put('id', o.Id); 
        
        // SET TEST PAGE 
		Test.setCurrentPage(pr2); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER 
        AH_ProductMigrationToolCtrl ctrl2 = new AH_ProductMigrationToolCtrl(); 
       
        system.assertEquals(10, ctrl2.lstPMs.size());
            
        List<AH_Product_Migration__c> lstPMAsserts = new List<AH_Product_Migration__c>(
            [SELECT Id, Name, Opportunity__c, CreatedDate, Cut_Off_Date__c, 
             Account__c, Account__r.Name, Account__r.AccountNumber, 
             From_Product__c, From_Product__r.ProductCode, From_Product__r.Name, 
             To_Product__c, To_Product__r.ProductCode, To_Product__r.Name 
             FROM AH_Product_Migration__c]);
        
        system.assertEquals(1, lstPMAsserts.size());
        
        List<AH_Product_Migration_Line_Item__c> lstPMLinesAsserts = new List<AH_Product_Migration_Line_Item__c>(
            [SELECT Id FROM AH_Product_Migration_Line_Item__c WHERE Product_Migration__c IN : lstPMAsserts]);
        
        system.assertEquals(1, lstPMAsserts.size());

        
        
        
        // TEST SET CUT-OFF DATE MODE ================================================================================
        
        // PAGE REFERENCE 
        PageReference pr3 = Page.AH_ProductMigrationTool; 

        // ADD URL PARAM 
        pr3.getParameters().put('id', o.Id); 
        pr3.getParameters().put('cod', '1'); 
        
        // SET TEST PAGE 
		Test.setCurrentPage(pr3); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER 
        AH_ProductMigrationToolCtrl ctrl3 = new AH_ProductMigrationToolCtrl(); 

        system.assertEquals(false, ctrl.isPendingCommit);
        system.assertEquals(true, ctrl3.isCutoffDateMode);     
        system.assertEquals(1, ctrl3.lstCutOffDates.size());  
       
        ctrl3.lstCutOffDates[0].strCutOffDate = system.Date.today().format();
        ctrl3.strMasterCutOffDate = system.Date.today().format();
        ctrl3.applyMasterCutOffDate(); 
        ctrl3.checkAll = true;
        ctrl3.doChecks(); 
        ctrl3.checkAll = false;
        ctrl3.doChecks(); 
        
        system.assertEquals(true, ctrl3.isPendingCommit);
        ctrl3.saveCutOffDates();
        system.assertEquals(true, ctrl3.isCutoffDateMode); 
        
        // ASSERT THAT ACTIVITY LINES WERE UPDATED CORRECTLY
        for (AH_Product_Migration_Line_Item__c pmli : [SELECT Id, Product_Migration_Cut_off_Date__c, Activity_Line_Item__c, 
                                                       Activity_Line_Item__r.Renewal_Date__c, Activity_Line_Item__r.Product_Migration_Date__c, Activity_Line_Item__r.Auto_Renewal__c 
                                                       FROM AH_Product_Migration_Line_Item__c 
                                                       WHERE Activity_Line_Item__c IN : lstALIs   
                                                       AND RecordTypeId =: Schema.SObjectType.AH_Product_Migration_Line_Item__c.getRecordTypeInfosByName().get('Activity Line Item').getRecordTypeId()])
        {
            if (pmli.Product_Migration_Cut_off_Date__c != null)
            {
                system.assertEquals(pmli.Activity_Line_Item__r.Product_Migration_Date__c, pmli.Product_Migration_Cut_off_Date__c); 
                if (pmli.Product_Migration_Cut_off_Date__c < pmli.Activity_Line_Item__r.Renewal_Date__c)
                {
                    system.assertEquals(false, pmli.Activity_Line_Item__r.Auto_Renewal__c); 
                }                  
            }               
        }
        
        
		// TEST NON-DML PAGE METHODS
        ctrl3.breakOut();
        ctrl3.breakIn();
        ctrl3.closeTool();        

for (Integer i = 0; i<25; i++)    
{
    system.debug(' *@*      ' + i);
}          
        system.debug(' ***  END stopTest - AH_ProductMigrationToolCtrl_Test.TestClassData1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Test.stopTest(); 
        
        system.debug(' ***  END  - AH_ProductMigrationToolCtrl_Test.TestClassData1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }
/*    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: TEST SET CUT-OFF MODE MODE
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {  
        
        system.debug(' *** START - AH_ProductMigrationToolCtrl_Test.TestClassData1() - NUMBER OF QUERIES = ' + Limits.getQueries()); 
        
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = 'AH_ProductMigrationToolCtrl Test Opp#1']; 
		
        Test.StartTest(); 
        
        // =============================================================================================================
        // 		VISUALFORCE PAGE TESTING
        // =============================================================================================================
                
        // PAGE REFERENCE 
        PageReference pr1 = Page.AH_ProductMigrationTool; 

        // ADD URL PARAM 
        pr1.getParameters().put('id', o.Id); 
        pr1.getParameters().put('cod', '1'); 
        
        // SET TEST PAGE 
		Test.setCurrentPage(pr1); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER 
        AH_ProductMigrationToolCtrl ctrl = new AH_ProductMigrationToolCtrl(); 
        system.assertEquals(0, ctrl.lstCutOffDates.size());
//system.debug(' *** ctrl.lstCutOffDates.size() = ' + ctrl.lstCutOffDates.size());
  

        ctrl.strMasterCutOffDate = system.Date.today().format();
        ctrl.applyMasterCutOffDate();  


		// TEST NON-DML PAGE METHODS
        ctrl.breakOut();
        ctrl.breakIn();
        ctrl.closeTool();
        
        Test.stopTest(); 
        
        system.debug(' ***  END  - AH_ProductMigrationToolCtrl_Test.TestClassData1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }
*/
    
}