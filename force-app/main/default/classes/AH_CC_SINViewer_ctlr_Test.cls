/****************************************************************************************
Name            : AH_CC_SINViewer_ctlr_Test
Author          : Sean Harris
Created Date    : 03/11/2020
Last Mod Date   : 03/11/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for controller class AH_CC_SINViewer_ctlr
                :            
******************************************************************************************/
@isTest
public class AH_CC_SINViewer_ctlr_Test 
{

    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {
        User u1 = NI_TestClassData.createTestUser(2, 'System Administrator');
        u1.Alias = 'APEXSYSU';
        u1.UserRoleId = [SELECT Id FROM UserRole WHERE Name LIKE 'CEO%' LIMIT 1].Id;
        insert u1; 
        
        system.runAs(u1)
        {
        
            system.debug(' *** START AH_CC_SINViewer_ctlr_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());
    
            Date dt = system.date.today();
            
            Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
            insert pgp;
    
            Product2 p2 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');        
            insert p2;      
            
            // CREATE TEST ACCOUNT
            Account a = NI_TestClassData.createTestAccount(1);
            a.Name = 'AH_CC_SINViewer_ctlr_Test';
            insert a;
    
            // CREATE TEST  CONTACT
            Contact cntct = NI_TestClassData.createTestContact(1, a.Id);
            cntct.FirstName = 'Timothy';
            cntct.LastName = 'Watts';
            cntct.Email = 'twatts@somedomain.com';
            insert cntct;        
            
            // CREATE TEST COMMUNITY USER
            User pu = NI_TestClassData.createTestUser(1, 'AH Customer Community Plus User');
            pu.Email = 'twatts@somedomain.com';
            pu.Username = 'twatts@somedomain.com.ahcc';
            pu.ContactId = cntct.Id;
            insert pu;
            
            // UPDATE ACCOUNT WITH REQUIRED FFA FIELDS      
            a.c2g__CODAAccountTradingCurrency__c = 'USD'; 
            a.c2g__CODATaxCalculationMethod__c = 'Gross';
            update a;
            
            // GET RUNNING USER RECORD
            User ru = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
    
            // CREATE TEST COMPANY
            c2g__codaCompany__c co = NI_TestClassData.createFFACompany('APEX ACME COMP', ru, true);
            insert co;
            
            // ADD USER RUNNING TEST TO THE TEST COMPANY
            c2g__codaUserCompany__c uCo = NI_TestClassData.createFFAUserCompany(co.Id, ru.Id);
            insert uCo;  
                  
    //        system.assertEquals('APEX ACME CO', c2g.CODAAPICompany_2_0.GetCurrentCompanies(null)[0]);
            
            Group q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'APEX ACME COMP' LIMIT 1];
            c2g__codaYear__c yr = NI_TestClassData.createFFAYear(String.valueOf(Date.today().year()), co.Id, q.Id);
            insert yr;
            c2g.CODAYearWebService.calculatePeriods(yr.Id);
            
            c2g__codaPeriod__c prd = NI_TestClassData.createFFAPeriod('APEX_TEST', co.Id, yr.Id);
            
            c2g__codaAccountingCurrency__c ac = NI_TestClassData.createFFAAccountingCurrency('USD', co.Id, q.Id);
            insert ac;        
            
            c2g__codaExchangeRate__c exrt = NI_TestClassData.createFFAcodaExchangeRate(co.Id, ac.Id);
            
            ffrr__RecognitionYear__c ry = NI_TestClassData.createRecognitionYear(Date.Today());
            insert ry;
        
            ffrr__RecognitionPeriod__c rp = NI_TestClassData.createRecognitionPeriod(Date.Today(), ry.Id);
            
            Remittance_Info__c rmi = NI_TestClassData.createRemittanceInfo('Test Remittance Info');
            
            Test.StartTest();
                    
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
            
            c2g__codaInvoice__c sin = NI_TestClassData.createSalesInvoice(a.Id, dt, 100, dim1.Id, dim2.Id, dim3.Id, dim4.Id);
            insert sin;
            
            c2g__codaInvoiceLineItem__c sinli = NI_TestClassData.createSalesInvoiceLineItem(p2.Id, 100, sin.Id, dim1.Id, dim2.Id, dim3.Id, dim4.Id);
            insert sinli;
    
            c2g__codaInvoice__c sin2 = NI_TestClassData.createSalesInvoice(a.Id, dt, 100, dim1.Id, dim2.Id, dim3.Id, dim4.Id);
            insert sin2;
            
            // SHARE SIN TO COMMUNITY USER
            c2g__codaInvoice__Share sinShare = new c2g__codaInvoice__Share();
            sinShare.ParentId = sin.Id;
            sinShare.UserOrGroupId = pu.Id;
            sinShare.AccessLevel = 'Read';
            sinShare.RowCause = 'Manual';
            insert sinShare;
    
            system.debug(' *** END AH_CC_SINViewer_ctlr_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());
        }
    }
   
    // =======================================================================================================================================
    // = TEST METHOD 1: TEST AS INTERNAL USER  
    // =======================================================================================================================================    
    @isTest static void test1() 
    {
        
        system.debug(' *** START AH_CC_SINViewer_ctlr_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());
        
        
        // SET THE CURRENT VF PAGE
        PageReference pr = Page.AH_CC_SINViewer;
        Test.setCurrentPage(pr);
        AH_CC_SINViewer_Ctlr ctrl = new AH_CC_SINViewer_Ctlr();     
        
        system.assertEquals(2, ctrl.lstSearchResults.size());
        
        // TEST SORT
        ctrl.doSort();
        
        ctrl.doSort();
        
        ctrl.exportResults();
        
        system.debug(' *** END AH_CC_SINViewer_ctlr_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    // =======================================================================================================================================
    // = TEST METHOD 2: TEST AS EXTERNAL USER
    // =======================================================================================================================================    
    @isTest static void test2() 
    {
   
        system.debug(' *** START AH_CC_SINViewer_ctlr_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());
        
        User u = [SELECT Id FROM User WHERE Email = 'twatts@somedomain.com'];

        system.runAs(u)
        {
            
            // SET THE CURRENT VF PAGE
            PageReference pr = Page.AH_CC_SINViewer;
            Test.setCurrentPage(pr);
            AH_CC_SINViewer_Ctlr ctrl = new AH_CC_SINViewer_Ctlr();     
            
            system.assertEquals(1, ctrl.lstSearchResults.size());
            
            // TEST SORT
            ctrl.doSort();
            
            ctrl.doSort();

        }

        system.debug(' *** END AH_CC_SINViewer_ctlr_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());

    }
    
}