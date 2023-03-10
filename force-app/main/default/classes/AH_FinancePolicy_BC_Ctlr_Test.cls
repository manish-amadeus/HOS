/************************************************************************************************
Name            : AH_FinancePolicy_BC_Ctlr_Test Class
Author          : Sean Harris
Created Date    : 07/17/2020
Last Mod Date   : 07/17/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller class for AH_FinancePolicy_BC_Ctlr VF Page 
                : 
                : 
*************************************************************************************************/
@isTest
public class AH_FinancePolicy_BC_Ctlr_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.startTest();
        
        // CREATE TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX Test Account - AH_FinancePolicy_BC_Ctlr';
        insert a;

        // CREATE A TEST BILLING RECORDS
        List<Billing_Contract__c> lstBCs = new List<Billing_Contract__c>();

        Billing_Contract__c blgCnrct1 = NI_TestClassData.createBillingContract(1);
        blgCnrct1.Name = 'APEX BC TEST #1';
        blgCnrct1.Account__c = a.Id;
        lstBCs.add(blgCnrct1);

        Billing_Contract__c blgCnrct2 = NI_TestClassData.createBillingContract(2);
        blgCnrct2.Name = 'APEX BC TEST #2';
        blgCnrct2.Account__c = a.Id;
      
        lstBCs.add(blgCnrct2);
        
        database.insert(lstBCs);        
 
        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX Test Account - AH_FinancePolicy_BC_Ctlr'];
        Billing_Contract__c bc1 = [SELECT Id FROM Billing_Contract__c WHERE Name = 'APEX BC TEST #1' AND Account__c =: a.Id];
		Billing_Contract__c bc2 = [SELECT Id FROM Billing_Contract__c WHERE Name = 'APEX BC TEST #2' AND Account__c =: a.Id];
        
        Test.startTest();
        
        Date dToday = Date.today();
        
        AH_Account_Finance_Policy__c afp = new AH_Account_Finance_Policy__c();
        afp.Account__c = a.Id; 
        afp.Start_Date__c = dToday.addDays(-365);
        afp.End_Date__c = dToday.addDays(365); 
        afp.Notes__c = 'test note';
        afp.Reason__c = 'COVID-19'; 
        afp.Solution_Domain__c = 'Sales & Catering';
        afp.IsActive__c = true;
        insert afp;

        // INSTANTIATE PAGE REFERENCE
        PageReference pr = Page.AH_FinancePolicy_BC;
        Test.setCurrentPage(pr);             
        
        // ADD URL PARAMS
        pr.getParameters().put('id', afp.Id);
        
        // INSTANTIATE PAGE CONTROLLER 
        AH_FinancePolicy_BC_Ctlr ctrl = new AH_FinancePolicy_BC_Ctlr();    
        
        // TEST CANCEL BUTTON
        ctrl.doCancel();
        
        system.assertEquals(2, ctrl.lstBCs.size());
        system.assertEquals(false, ctrl.lstBCs[0].isSelected);
        system.assertEquals(false, ctrl.lstBCs[1].isSelected);
        
        ctrl.lstBCs[0].isSelected = true;
        ctrl.lstBCs[1].isSelected = true;
        
        ctrl.doSubmit();
        
        AH_Account_Finance_Policy__c assertAFP1 = [SELECT Id, Billing_Contracts__c FROM AH_Account_Finance_Policy__c];
        system.assertEquals(bc1.Id + ',' + bc2.Id, assertAFP1.Billing_Contracts__c);
        
        // INSTANTIATE SECOND PAGE REFERENCE
        PageReference pr2 = Page.AH_FinancePolicy_BC;
        Test.setCurrentPage(pr2);             
        
        // ADD URL PARAMS
        pr2.getParameters().put('id', afp.Id);
        
        // INSTANTIATE PAGE CONTROLLER 
        AH_FinancePolicy_BC_Ctlr ctrl2 = new AH_FinancePolicy_BC_Ctlr();           
        
        system.assertEquals(2, ctrl2.lstBCs.size());
        system.assertEquals(true, ctrl2.lstBCs[0].isSelected);
        system.assertEquals(true, ctrl2.lstBCs[1].isSelected);
        
        Test.stopTest();
        
	}
    
}