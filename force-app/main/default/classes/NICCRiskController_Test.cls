/****************************************************************************************
Name            : NICCRiskController_Test Class
Author          : Sean Harris
Created Date    : 12/13/13
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-009015
Description     : 
                : 
                : 
******************************************************************************************/
@isTest
private class NICCRiskController_Test 
{

    static testMethod void testRiskSetup() 
    {
        
        NICC_Risk_Setup__c niccRiskSetup;
        List<NICC_Risk_Setup__c> lstRSU = new List<NICC_Risk_Setup__c>();
        
        for (integer j = 1; j < 11; j++)
        {
            
            NICC_Risk_Setup__c su = new NICC_Risk_Setup__c();

            su.Description__c = 'HRM Risk Description ' + ' ' + String.valueOf(j); 
            su.Level1Desc__c = 'level 1'; 
            su.Level2Desc__c = 'level 2';
            su.Level3Desc__c = 'level 3'; 
            su.Level4Desc__c = 'level 4'; 
            su.Level1Weight__c = 1; 
            su.Level2Weight__c = 2; 
            su.Level3Weight__c = 3;
            su.Level4Weight__c = 4;
            su.Type__c = 'HRM';
            su.SortOrder__c = j;   
            
            lstRSU.add(su);         
            niccRiskSetup = su;
            
        }
        
        for (integer j = 1; j < 11; j++)
        {
            
            NICC_Risk_Setup__c su = new NICC_Risk_Setup__c();

            su.Description__c = 'Hosted Risk Description ' + ' ' + String.valueOf(j); 
            su.Level1Desc__c = 'level 1'; 
            su.Level2Desc__c = 'level 2';
            su.Level3Desc__c = 'level 3'; 
            su.Level4Desc__c = 'level 4'; 
            su.Level1Weight__c = 1; 
            su.Level2Weight__c = 2; 
            su.Level3Weight__c = 3;
            su.Level4Weight__c = 4;
            su.Type__c = 'Hosted';
            su.SortOrder__c = j;            
            
            lstRSU.add(su);  
            
        }
        
// DML        
        Database.Insert(lstRSU); 

        // PAGE REFERENCES ==================================================================
        PageReference pr = Page.NICCRiskSetup; 
        ApexPages.StandardController RskSU = new ApexPages.StandardController(niccRiskSetup); 
        NICCRiskController ctrlRskSU = new NICCRiskController(RskSU); 
        Test.setCurrentPage(pr); 
        
        ctrlRskSU.RiskType = 'HRM'; 
//        ctrlRskSU.bIsInReadMode = true; 
//        ctrlRskSU.bIsInEditMode = true; 

        ctrlRskSU.SelectRec(); 
        ctrlRskSU.EditRec(); 
        ctrlRskSU.CancelRec(); 

        pageReference prSILC = ctrlRskSU.SaveInlineChanges(); 
              
    }
    
    
    static testMethod void testRiskInit() 
    {

        NICC_Risk__c niccRisk;

// DML
        NI_Change_Control__c nicc1 = NI_TestClassData.createNIChangeControl(1, 'APEX TEST HRM');
        insert nicc1;
// DML      
        NI_Change_Control__c nicc2 = NI_TestClassData.createNIChangeControl(2, 'APEX TEST HOSTED');
        insert nicc2;
        
                
        List<NICC_Risk__c> lstRsk = new List<NICC_Risk__c>();

/*        
        for (integer j = 1; j < 11; j++)
        {
            
            NICC_Risk__c su = new NICC_Risk__c();

            su.Description__c = 'HRM Risk Description ' + ' ' + String.valueOf(j); 
            su.Level1Desc__c = 'level 1'; 
            su.Level1Value__c = true;
            su.Level2Desc__c = 'level 2'; 
            su.Level2Value__c = false;
            su.Level3Desc__c = 'level 3'; 
            su.Level3Value__c = false;
            su.Level4Desc__c = 'level 4'; 
            su.Level4Value__c = false; 
            su.SortOrder__c = j;
            su.NICC_ID__c = nicc1.Id;
            su.Type__c = 'HRM';
            
            lstRsk.add(su);         
            niccRisk = su;
            
        }
*/
        
        for (integer j = 1; j < 11; j++)
        {
            
            NICC_Risk__c su = new NICC_Risk__c();

            su.Description__c = 'Hosted Risk Description ' + ' ' + String.valueOf(j); 
            su.Level1Desc__c = 'level 1'; 
            su.Level1Value__c = true;
            su.Level2Desc__c = 'level 2'; 
            su.Level2Value__c = false;
            su.Level3Desc__c = 'level 3'; 
            su.Level3Value__c = false;
            su.Level4Desc__c = 'level 4'; 
            su.Level4Value__c = false; 
            su.SortOrder__c = j;
            su.NICC_ID__c = nicc2.Id;
            su.Type__c = 'Hosted';          
            
            lstRsk.add(su);  
            
        }
        
// DML        
        Database.Insert(lstRsk);    
        niccRisk = lstRsk[0];
        
        // PAGE REFERENCES ==================================================================
        PageReference pr = Page.NICCRiskInit; 
        ApexPages.StandardController RskInit = new ApexPages.StandardController(niccRisk); 
        NICCRiskController ctrlRskInit = new NICCRiskController(RskInit); 
        pr.getParameters().put('nicc', nicc2.Id);
        pr.getParameters().put('type', 'Hosted');         
        Test.setCurrentPage(pr); 
        
        ctrlRskInit.RiskType = 'HRM'; 
//        ctrlRskInit.bIsInReadMode = true; 
//        ctrlRskInit.bIsInEditMode = true; 
        
        pageReference prInit = ctrlRskInit.initRisk();
            
    }
            


    
    
    static testMethod void testRiskFunction() 
    {

// CREATE TEST SETUP DATA
        NICC_Risk_Setup__c niccRiskSetup;
        List<NICC_Risk_Setup__c> lstRSU = new List<NICC_Risk_Setup__c>();
        
        for (integer j = 1; j < 11; j++)
        {
            
            NICC_Risk_Setup__c su = new NICC_Risk_Setup__c();

            su.Description__c = 'HRM Risk Description ' + ' ' + String.valueOf(j); 
            su.Level1Desc__c = 'level 1'; 
            su.Level2Desc__c = 'level 2';
            su.Level3Desc__c = 'level 3'; 
            su.Level4Desc__c = 'level 4'; 
            su.Level1Weight__c = 1; 
            su.Level2Weight__c = 2; 
            su.Level3Weight__c = 3;
            su.Level4Weight__c = 4;
            su.Type__c = 'HRM';
            su.SortOrder__c = j;   
            
            lstRSU.add(su);         
            niccRiskSetup = su;
            
        }
        
        for (integer j = 1; j < 11; j++)
        {
            
            NICC_Risk_Setup__c su = new NICC_Risk_Setup__c();

            su.Description__c = 'Hosted Risk Description ' + ' ' + String.valueOf(j); 
            su.Level1Desc__c = 'level 1'; 
            su.Level2Desc__c = 'level 2';
            su.Level3Desc__c = 'level 3'; 
            su.Level4Desc__c = 'level 4'; 
            su.Level1Weight__c = 1; 
            su.Level2Weight__c = 2; 
            su.Level3Weight__c = 3;
            su.Level4Weight__c = 4;
            su.Type__c = 'Hosted';
            su.SortOrder__c = j;            
            
            lstRSU.add(su);  
            
        }
        
// DML        
        Database.Insert(lstRSU); 


        



        
        NICC_Risk__c niccRisk;
        
        Id idRecTypeHRM = NI_TestClassData.getRecordTypeId('NI_Change_Control__c', 'HRM RFC');        
        Id idRecTypeHosted = NI_TestClassData.getRecordTypeId('NI_Change_Control__c', 'Hosted RFC');
        
        System.Assert(idRecTypeHosted != null, 'Record Type: \'Hosted RFC\' Was NOT Found.'); 
        System.Assert(idRecTypeHRM != null, 'Record Type: \'HRM RFC\' Was NOT Found.'); 

// DML
        NI_Change_Control__c nicc1 = NI_TestClassData.createNIChangeControl(1, 'APEX TEST HRM');
        nicc1.RecordTypeId = idRecTypeHRM;
        insert nicc1;
        
        System.Assert(nicc1.Id != null, 'Failed to create NI_Change_Control__c Test record.'); 
        
// DML      
        NI_Change_Control__c nicc2 = NI_TestClassData.createNIChangeControl(2, 'APEX TEST HOSTED');
        nicc2.RecordTypeId = idRecTypeHosted;
        insert nicc2;
        
        System.Assert(nicc2.Id != null, 'Failed to create NI_Change_Control__c Test record.'); 
                        
        List<NICC_Risk__c> lstRsk = new List<NICC_Risk__c>();
        
        for (integer j = 1; j < 11; j++)
        {
            
            NICC_Risk__c su = new NICC_Risk__c();

            su.Description__c = 'HRM Risk Description ' + ' ' + String.valueOf(j); 
            su.Level1Desc__c = 'level 1'; 
            su.Level1Value__c = true;
            su.Level2Desc__c = 'level 2'; 
            su.Level2Value__c = false;
            su.Level3Desc__c = 'level 3'; 
            su.Level3Value__c = false;
            su.Level4Desc__c = 'level 4'; 
            su.Level4Value__c = false; 
            su.SortOrder__c = j;
            su.NICC_ID__c = nicc1.Id;
            su.Type__c = 'HRM';
            
            lstRsk.add(su);         
            //niccRisk = su;
            
        }
        
        for (integer j = 1; j < 11; j++)
        {
            
            NICC_Risk__c su = new NICC_Risk__c();

            su.Description__c = 'Hosted Risk Description ' + ' ' + String.valueOf(j); 
            su.Level1Desc__c = 'level 1'; 
            su.Level1Value__c = true;
            su.Level2Desc__c = 'level 2'; 
            su.Level2Value__c = false;
            su.Level3Desc__c = 'level 3'; 
            su.Level3Value__c = false;
            su.Level4Desc__c = 'level 4'; 
            su.Level4Value__c = false; 
            su.SortOrder__c = j;
            su.NICC_ID__c = nicc2.Id;
            su.Type__c = 'Hosted';          
            
            lstRsk.add(su);  
            
        }

        System.Assert(lstRsk.Size() == 20, 'Failed to create all 20 NICC_Risk__c Test Records'); 
        
// DML        
        Database.Insert(lstRsk);    
        niccRisk = lstRsk[0];
        
        // PAGE REFERENCES ==================================================================
        PageReference pr = Page.NICCRisk; 
        pr.getParameters().put('nicc', nicc2.Id); 
        pr.getParameters().put('type', 'Hosted'); 
        ApexPages.StandardController Rsk = new ApexPages.StandardController(niccRiskSetup); 
        NICCRiskController ctrlRsk = new NICCRiskController(Rsk); 
        Test.setCurrentPage(pr); 
                                        
        boolean b1 = ctrlRsk.inEditMode; 
        boolean b2 = ctrlRsk.inReadMode; 
        
        ctrlRsk.NICC_ID = nicc1.Id; 
        ctrlRsk.RiskType = 'HRM'; 
        ctrlRsk.CreateRisks(); 

        Test.StartTest();
        ctrlRsk.getRiskRecord(); 
        ctrlRsk.QuickSaveRiskChanges(); 
        ctrlRsk.SaveRiskChanges();         
        ctrlRsk.CancelRiskChanges(); 
        
        niccRisk.Level1Value__c = false; 
        niccRisk.Level2Value__c = true; 
        niccRisk.Level3Value__c = false; 
        niccRisk.Level4Value__c = false; 
        update niccRisk;
        ctrlRsk.SaveRiskChanges();
        
        niccRisk.Level1Value__c = false; 
        niccRisk.Level2Value__c = false; 
        niccRisk.Level3Value__c = true; 
        niccRisk.Level4Value__c = false; 
        update niccRisk;
        ctrlRsk.SaveRiskChanges();
        
        niccRisk.Level1Value__c = false; 
        niccRisk.Level2Value__c = false; 
        niccRisk.Level3Value__c = false; 
        niccRisk.Level4Value__c = true; 
        update niccRisk;       
        ctrlRsk.SaveRiskChanges();         
        
        ctrlRsk.SavePartialRiskChanges();
        ctrlRsk.QuickSavePartialRiskChanges();
                
        ctrlRsk.closePopup();
        ctrlRsk.showPopup();
        
        ctrlRsk.recreateRisks();
        
        Test.StopTest();
        
    }

}