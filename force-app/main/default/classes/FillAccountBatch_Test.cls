@IsTest
public class FillAccountBatch_Test {

    @IsTest
    public static void testFake() {
        FillAccountBatch fab = new FillAccountBatch(new String[0]);
        NI_Org_Details__c[] accounts = new NI_Org_Details__c[1]; 
        
        fab.isTest = true;
        accounts[0] = new NI_Org_Details__c();
        fab.start(null);
        fab.execute(null, accounts);
        fab.finish(null);
    }
}