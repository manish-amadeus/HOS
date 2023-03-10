/****************************************************************************************
Name            : FillAccountSchedule_NI_Test Class
Author          : Sean Harris
Created Date    : 7/25/2013
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
@isTest
public class FillAccountBatch_Test {
    @isTest
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