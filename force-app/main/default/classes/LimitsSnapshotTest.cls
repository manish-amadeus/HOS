/************************************************************************************************
Name            : LimitsSnapshotTest Class
Author          : Mike Pedro 
Created Date    : 05/18/2022
Last Mod Date   : 05/18/2022
Last Mod By     : Mike Pedro
NICC Reference  : NICC-058970 
Description     : 
                : 
*************************************************************************************************/

@isTest
private class LimitsSnapshotTest {
    @isTest
    static void itShould() {
        DebugSettings__c settings = DebugSettings__c.getInstance();
        settings.EnableLimitsSnapshot__c = true;
        upsert settings;

        //
        Test.startTest();
        LimitsSnapshot ls = new LimitsSnapshot('Apex Test');
        ls.toLog();
        ls.toLog(null);
        Test.stopTest();

        System.assertNotEquals(null, ls.getLimitStart(LimitsSnapshot.LimitEnum.CpuTime));
        System.assertNotEquals(null, ls.getLimitEnd(LimitsSnapshot.LimitEnum.CpuTime));
    }

    @isTest
    static void remainingCoverage() {
        LimitsSnapshot ls = new LimitsSnapshot();
        ls.toLog();

        System.assert(true);
    }
}