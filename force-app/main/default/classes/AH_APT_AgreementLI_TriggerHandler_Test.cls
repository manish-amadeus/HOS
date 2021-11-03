/****************************************************************************************
Name            : AH_APT_AgreementLI_TriggerHandler_Test
Author          : Apttus
Created Date    : 11/18/2013
Last Mod Date   : 02/14/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_APT_AgreementLI_TriggerHandler
				: 
******************************************************************************************/
@isTest
public class AH_APT_AgreementLI_TriggerHandler_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' *^* START AH_APT_AgreementLI_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Test.startTest();  
        
        // CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_APT_AgreementLI_TriggerHandler_Test Account';
        insert a;
        
        // CREATE TEST PRODUCT GROUPS
        Product_Group__c pgpHRM = NI_TestClassData.createProductGroup(1, 'HRM');
        insert pgpHRM;

        Product_Group__c pgpMI = NI_TestClassData.createProductGroup(1, 'Meeting Intelligence');
        insert pgpMI;
        
        Product_Group__c pgpDefault = NI_TestClassData.createProductGroup(1, 'Default');
        insert pgpDefault;
        
        // CREATE TEST APTTUS AGREEMENT
        Apttus__APTS_Agreement__c agree = NI_TestClassData.createTestApttusAgreement(1, a.Id, null, null); 
        agree.Name = 'Test Agreement';
        agree.CurrencyIsoCode = 'USD';
        agree.APTS_Legal_Entity__c = 'Newmarket International, Ltd.';
        insert agree;
        
        // CREATE TEST PRODUCTS
        List<Product2> lstProduct2s = new List<Product2>();
    
        Product2 p1 = NI_TestClassData.createProduct2(1, pgpHRM.Id, 'HRM-DFDCQS-01', 'Subscription');    
        p1.Name = 'Test Product 0';
        p1.Product_Line_Global__c = 'Delphi';
        p1.Revenue_Category__c = 'Software - Perpetual';
        p1.Corporate_Product_Group__c = 'Newmarket';
        p1.OM_Template_Keyword__c = 'Test Keyword';
        lstProduct2s.add(p1);        
        
        Product2 p2 = NI_TestClassData.createProduct2(2, pgpMI.Id, 'DB-SUB-01', 'Subscription');    
        p2.Name = 'Test Product 1';
        p2.Product_Line_Global__c = 'AIP';
        p2.Revenue_Category__c = 'Software - Perpetual';
        p2.Corporate_Product_Group__c = 'Newmarket';
        p2.OM_Template_Keyword__c = 'Test Keyword';
        lstProduct2s.add(p2);  
      
        Product2 p3 = NI_TestClassData.createProduct2(1, pgpDefault.Id, 'HRM-EMB-20-3', 'Subscription'); 
        p3.Name = 'Test Product 2';
        p3.Product_Line_Global__c = 'MeetingBroker';
        p3.Corporate_Product_Group__c = 'Newmarket';
        p3.Revenue_Category__c = 'Services';
        p3.OM_Template_Keyword__c = 'Test Keyword';
        lstProduct2s.add(p3); 
       
        Product2 p4 = NI_TestClassData.createProduct2(1, pgpDefault.Id, 'APEX-TEST-04', 'Subscription'); 
        p4.Name = 'Test Product 3';
        p4.Product_Line_Global__c = 'CC Safeguard';
        p4.Corporate_Product_Group__c = 'Newmarket';
        p4.Revenue_Category__c = 'Services';
        p4.OM_Template_Keyword__c = 'Test Keyword';
        lstProduct2s.add(p4); 
        
        Product2 p5 = NI_TestClassData.createProduct2(1, pgpDefault.Id, 'APEX-TEST-05', 'Subscription'); 
        p5.Name = 'Test Product 4';
        p5.Product_Line_Global__c = 'MeetingMatrix';
        p5.Corporate_Product_Group__c = 'Newmarket';
        p5.Revenue_Category__c = 'Services';
        p5.OM_Template_Keyword__c = 'Test Keyword';
        lstProduct2s.add(p5); 

        database.insert(lstProduct2s);
        
        Test.stopTest(); 
        
        system.debug(' *^* END AH_APT_AgreementLI_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }


    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        system.debug(' *^* START AH_APT_AgreementLI_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());

        Apttus__APTS_Agreement__c agr = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement']; 
		List<Product2> lstProducts = new List<Product2>([SELECT Id FROM Product2 WHERE Name LIKE 'Test Product%' ORDER BY Name ASC]);
        system.assertEquals(5, lstProducts.size());

        
		Test.startTest(); 

        system.debug(' *^* NUMBER OF QUERIES = ' + Limits.getQueries());
        
        List<Apttus__AgreementLineItem__c> lstAgreements = new List<Apttus__AgreementLineItem__c>();
        
        Apttus__AgreementLineItem__c ali1 = NI_TestClassData.createTestAgreementLineItem('ALI 01', 1, 1, agr.Id, lstProducts[0].Id);        
        lstAgreements.add(ali1);
        
        Apttus__AgreementLineItem__c ali2 = NI_TestClassData.createTestAgreementLineItem('ALI 02', 1, 1, agr.Id, lstProducts[0].Id);
        ali2.Apttus_CMConfig__OptionId__c = lstProducts[0].Id;
        lstAgreements.add(ali2);

        Apttus__AgreementLineItem__c ali3 = NI_TestClassData.createTestAgreementLineItem('ALI 03', 1, 1, agr.Id, lstProducts[1].Id);
        lstAgreements.add(ali3);
        
        Apttus__AgreementLineItem__c ali4 = NI_TestClassData.createTestAgreementLineItem('ALI 04', 1, 1, agr.Id, lstProducts[1].Id);
        ali4.Apttus_CMConfig__OptionId__c = lstProducts[1].Id;
        lstAgreements.add(ali4);

        Apttus__AgreementLineItem__c ali5 = NI_TestClassData.createTestAgreementLineItem('ALI 05', 1, 1, agr.Id, lstProducts[2].Id);
        lstAgreements.add(ali5);
        
        Apttus__AgreementLineItem__c ali6 = NI_TestClassData.createTestAgreementLineItem('ALI 06', 1, 1, agr.Id, lstProducts[2].Id);
        ali6.Apttus_CMConfig__OptionId__c = lstProducts[2].Id;
        lstAgreements.add(ali6);

        Apttus__AgreementLineItem__c ali7 = NI_TestClassData.createTestAgreementLineItem('ALI 07', 1, 1, agr.Id, lstProducts[3].Id);
        lstAgreements.add(ali7);
        
        Apttus__AgreementLineItem__c ali8 = NI_TestClassData.createTestAgreementLineItem('ALI 08', 1, 1, agr.Id, lstProducts[3].Id);
        ali8.Apttus_CMConfig__OptionId__c = lstProducts[3].Id;
        lstAgreements.add(ali8);

        Apttus__AgreementLineItem__c ali9 = NI_TestClassData.createTestAgreementLineItem('ALI 09', 1, 1, agr.Id, lstProducts[4].Id);
        lstAgreements.add(ali9);
        
        Apttus__AgreementLineItem__c ali10 = NI_TestClassData.createTestAgreementLineItem('ALI 10', 1, 1, agr.Id, lstProducts[4].Id);
        ali10.Apttus_CMConfig__OptionId__c = lstProducts[4].Id;
        lstAgreements.add(ali10);        

        system.debug(' *^* NUMBER OF QUERIES = ' + Limits.getQueries());
                
        database.insert(lstAgreements);

        system.debug(' *^* NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Test.stopTest(); 

        system.debug(' *^* NUMBER OF QUERIES = ' + Limits.getQueries());
                
		Apttus__AgreementLineItem__c aliDel = [SELECT Id FROM Apttus__AgreementLineItem__c WHERE Apttus__Description__c = 'ALI 10'];
        delete aliDel;
        
        system.debug(' *^* END AH_APT_AgreementLI_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }        
        

}