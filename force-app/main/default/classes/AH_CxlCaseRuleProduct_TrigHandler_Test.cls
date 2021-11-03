/****************************************************************************************
Name            : AH_CxlCaseRuleProduct_TrigHandler_Test 
Author          : Sean Harris
Created Date    : 04/25/2017
Last Mod Date   : 04/25/2017 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                :
****************************************************************************************/
@isTest
public class AH_CxlCaseRuleProduct_TrigHandler_Test 
{

    static testMethod void testCxlCaseRuleProduct1() 
    {
        
        // CREATE TEST PRODUCT GROUP
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;
        
        // CREATE TEST PRODUCT
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');        
        insert prd;  
        
        // CREATE TEST CXL CASE RULE 
        Cancellation_Case_Rule__c ccr = new Cancellation_Case_Rule__c();
        ccr.Case_Subject__c = 'Decommission Request: <<DI Name>>';
        ccr.Case_Description__c = 'Please cancel <<DI Name>>';
        ccr.Assignment_Queue__c = 'Q-ODO';
		ccr.Cancellation_Status__c = 'Cancelled';
        insert ccr;
            
        // CREATE TEST CXL CASE RULE PRODUCT
        Cancellation_Case_Rule_Product__c ccrp1 = new Cancellation_Case_Rule_Product__c();
        ccrp1.Cancellation_Case_Rule__c = ccr.Id;
        ccrp1.Product__c = prd.Id;
        insert ccrp1;
        
        // TEST THAT WHEN UPDATING THE CXL CASE RULE PRODUCT THAT
        // NO ERROR IS THROWN
        update ccrp1;
     
        // BUILD EXPECTED ERROR MESSAGE STRING
        string strErr = 'This product is already associated with a Cancellation Case Rule \n';
        strErr += '(Product) ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + String.valueOf(prd.Id);
        strErr += ' (Rule) ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + String.valueOf(ccr.Id) + '\n';       
        
        // TRY INSERTING A CXL CASE RULE PRODUCT RECORD WITH A PRODUCT ID BELONING TO ANOTHER RULE
        try
        {
            Cancellation_Case_Rule_Product__c ccrp2 = new Cancellation_Case_Rule_Product__c();
            ccrp2.Cancellation_Case_Rule__c = ccr.Id;
            ccrp2.Product__c = prd.Id;
            insert ccrp2;
        }
        catch (Exception e)
        {
            // ASSERT EXPECTED ERROR
            Boolean expectedExceptionThrown = e.getMessage().contains(strErr);
            system.AssertEquals(true, expectedExceptionThrown, e.getMessage());            
        }
        
    }
    
}