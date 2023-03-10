/****************************************************************************************
Name            : PushSolutions_Test Class
Author          : Sean Harris
Created Date    : 7/11/2014
Last Mod Date   : 7/11/2014
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Created because test class failed after deleting Product_Group__c
                : on Case Object. Pulled this test code out into its own class.
                : 
******************************************************************************************/
@isTest
private class PushSolutions_Test 
{

    static testMethod void testPushSolutionsExtension()
    {
    
        User u = NI_TestClassData.createTestUser(1, 'NI Support CSR'); 
        insert u;
        
        System.RunAs(u)
        {
        
            // CREATE PARENT RECORDS =============================================================================
        
            Account parentAccount = NI_TestClassData.createTestAccount(1);
            insert parentAccount;

            Product_Group__c pgp1 = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
            insert pgp1;
    
            Product2 prd1 = NI_TestClassData.createProduct2(1, pgp1.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
            insert prd1;

            Asset d1 = NI_TestClassData.createTestAsset(1, parentAccount.Id, prd1.Id);
            d1.Product_Group__c = pgp1.Id;
            insert d1;
            
            Case parentCase = NI_TestClassData.createTestCase(1, parentAccount.Id);
            parentCase.AssetId = d1.Id;
            parentCase.Resolution_Type__c = 'Training';
            insert parentCase;
            
            
            // CREATE CHILD RECORDS ==============================================================================                       
                
            Account childAccount = NI_TestClassData.createTestAccount(2);
            childAccount.ParentId = parentAccount.Id;
            insert childAccount; 
            
            Product_Group__c pgp2 = NI_TestClassData.createProductGroup(2, 'Apex Test Group');
            insert pgp2;
    
            Product2 prd2 = NI_TestClassData.createProduct2(2, pgp2.Id, 'ZZZFULFILL-APEX-002', 'Subscription');
            insert prd2;
    
            Asset d2 = NI_TestClassData.createTestAsset(2, childAccount.Id, prd2.Id);
            d2.Product_Group__c = pgp2.Id;
            insert d2;
    
            Case childCase = NI_TestClassData.createTestCase(2, childAccount.Id);
            childCase.AssetId = d2.Id;
            childCase.Resolution_Type__c = 'Training';
            childCase.ParentId = parentCase.Id;
            insert childCase;

            // CREATE SOLUTION RECORDS AND REFERENCES ===========================================================

            Id rtId = NI_TestClassData.getRecordTypeId('Solution', 'Child Solution');

            List<Solution> lstSols = new List<Solution>();
            List<CaseSolution> lstCaseSols = new List<CaseSolution>();

            Solution s1 = NI_TestClassData.createSolution(1); 
            s1.RecordTypeId = rtId;         
            lstSols.Add(s1);           
            
            Solution s2 = NI_TestClassData.createSolution(2); 
            s2.RecordTypeId = rtId;         
            lstSols.Add(s2);       
            
            Solution s3 = NI_TestClassData.createSolution(3); 
            s3.RecordTypeId = rtId;    
            s3.Origin_Case__c = childCase.Id;
            lstSols.Add(s3); 
            
            Database.Insert(lstSols);
    
            CaseSolution cs1 = NI_TestClassData.createCaseSolution(parentCase.Id, s1.Id);
            lstCaseSols.Add(cs1);  
            
            CaseSolution cs2 = NI_TestClassData.createCaseSolution(parentCase.Id, s2.Id);
            lstCaseSols.Add(cs2); 
             
            CaseSolution cs3 = NI_TestClassData.createCaseSolution(parentCase.Id, s3.Id);
            lstCaseSols.Add(cs3);  

            Database.Insert(lstCaseSols);

            // TEST PAGE ========================================================================================

            PageReference pr = Page.PushSolutions;
            pr.getParameters().put('retURL', 'returnURL');
            Test.setCurrentPage(pr); 
            
            ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(new Case[] { childCase });
            stdCon.setSelected(new Case[] { childCase });
            PushSolutions ext = new PushSolutions(stdCon);
            ext.load();
            
        }

    }
    
}