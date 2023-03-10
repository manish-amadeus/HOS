/****************************************************************************************
Name            : NI_Scheduled_DINames_Test Class
Author          : Sean Harris
Created Date    : 7/16/2014
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-010771 
Description     : 
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_Scheduled_DINames_Test
{ 

    public static testMethod void testDINameSchedule() 
    {         
        
        // CREATE TEST DATA START =======================================================================================================
        // 
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;

        List<Account> lstAccAsserts = new List<Account>([SELECT Id FROM Account]); 
		System.assertEquals(lstAccAsserts.Size(), 1);
        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        pgp.Update_Related_DI_Names__c = true;
        insert pgp;
        
        List<Product_Group__c> lstPGAsserts = new List<Product_Group__c>([SELECT Id FROM Product_Group__c WHERE Update_Related_DI_Names__c = true]); 
		System.assertEquals(lstPGAsserts.Size(), 1);
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        prd.Update_Related_DI_Names__c = true;
        insert prd;
        
        List<Product2> lstPrd2Asserts = new List<Product2>([SELECT Id FROM Product2 WHERE Update_Related_DI_Names__c = true]); 
		System.assertEquals(lstPrd2Asserts.Size(), 1);

        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd.Id);
        di.Product_Group__c = pgp.Id;
        insert di;  

        List<Asset> lstAssetAsserts = new List<Asset>([SELECT Id FROM Asset]); 
		System.assertEquals(lstAssetAsserts.Size(), 1);   

        // CREATE TEST DATA END   =======================================================================================================
        
        
        // LIST TO RESTORE Product_Group__c.Update_Related_DI_Names__c THAT ARE true TO false
        List<Product_Group__c> lstProductGroupRestore = new List<Product_Group__c>();
        
        // SET TO HOLD PRODUCT GROUP IDS OF CHECKED RECORDS
        Set<Id> setProductGroupIds = new Set<Id>();
        
        // FILL SET WITH PRODUCT GROUP IDS OF CHECKED RECORDS AND A LIST TO BE UPDATED
        for (Product_Group__c g : [SELECT Id, Update_Related_DI_Names__c FROM Product_Group__c WHERE Update_Related_DI_Names__c = true])
        {
            setProductGroupIds.Add(g.Id); 
            g.Update_Related_DI_Names__c = false; 
            lstProductGroupRestore.Add(g);            
        }

		System.assertEquals(lstProductGroupRestore.Size(), 1); 
        
        // LIST TO UPDATE Product2.Update_Related_DI_Names__c FIELD VALUE TO true
        List<Product2> lstProductUpdates = new List<Product2>();
        
        // FILL LIST TO UPDATE Product2.pdate_Related_DI_Names__c FIELD VALUE TO true
        for (Product2 pUps : [SELECT Id, Update_Related_DI_Names__c FROM Product2 WHERE Product_Group__c IN : setProductGroupIds])
        {
            pUps.Update_Related_DI_Names__c = true;
            lstProductUpdates.Add(pUps);
        } 
        
        System.assertEquals(lstProductUpdates.Size(), 1);
        
        // UPDATE RELATED PRODUCT'S Update_Related_DI_Names__c FIELD TO true
        Database.Update(lstProductUpdates, false);

        // LIST TO RESTORE Product2.Update_Related_DI_Names__c THAT ARE true TO false
        List<Product2> lstProductRestore = new List<Product2>();
        
        // SET TO HOLD PRODUCT IDS OF CHECKED RECORDS
        // SET THAT IS PASSED TO BATCH METHOD
        Set<Id> setProductIds = new Set<Id>();
        
        // FILL LIST TO UPDATE Product2.Update_Related_DI_Names__c FIELD VALUE TO false
        for (Product2 p : [SELECT Id, Update_Related_DI_Names__c FROM Product2 WHERE Update_Related_DI_Names__c = true])
        {
            setProductIds.Add(p.Id);
            p.Update_Related_DI_Names__c = false;
            lstProductRestore.Add(p);
        }         
        
        System.assertEquals(setProductIds.Size(), 1);             
        
        Test.startTest();
        String jobId = System.schedule('Test NI_Scheduled_DINames', '0 0 23 * * ?', new NI_Scheduled_DINames());
        Test.stopTest();
        
        NI_Scheduled_DINames.scheduleIt('0 0 * * * ?');
        
    }   

}