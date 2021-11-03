@isTest
public class FillAccountBatch_Test 
{
 
    public static testmethod void testFake() 
    {
        String [] ids = new String [1];
		ids[0] = 'a4O32000000CjaD';
        
        FillAccountBatch fab = new FillAccountBatch(ids);
        NI_Org_Details__c[] accounts = new NI_Org_Details__c[1]; 
        
        fab.isTest = true;
        accounts[0] = new NI_Org_Details__c();
        fab.start(null);
        fab.execute(null, accounts);
        fab.finish(null);
    }
    
}