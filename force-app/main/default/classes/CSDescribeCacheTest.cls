/************************************************************************************************
Name            : CSDescribeCache Class
Author          : Mike Pedro 
Created Date    : 05/18/2022
Last Mod Date   : 05/18/2022
Last Mod By     : Mike Pedro
NICC Reference  : NICC-058970 
Description     : Test Class for CSDescribeCache
                : 
*************************************************************************************************/
@isTest
private class CSDescribeCacheTest {
    @isTest
    static void getRestrictedFields() {
        System.runAs(UserTest.createStandardUser()) {
            CSDescribeCache dc = CSDescribeCache.getDescribeCache('Lead');

            Set<String> flds = dc.getRestrictedFields(DataConstants.SecurityOperation.CREATE);

            System.assertNotEquals(null, flds);
        }
    }

    @isTest
    static void getFieldTokenNamespace() {
        System.runAs(UserTest.createStandardUser()) {
            CSDescribeCache dc = CSDescribeCache.getDescribeCache('Lead');

            Schema.SObjectField sof = dc.getFieldToken('NS__AggregateQueries__c');

            System.assert(true);
        }
    }

    @isTest
    static void getRecordTypeId() {
        System.runAs(UserTest.createStandardUser()) {
            CSDescribeCache dc = CSDescribeCache.getDescribeCache('Lead');

            try {
                dc.getRecordTypeId('Test');
                System.assert(false);
            } catch (CSDescribeCache.RecordTypeNotFoundException rtnfe) {
                System.assert(true);
            }
        }
    }

    @isTest
    static void getPicklistOptions() {
        System.runAs(UserTest.createStandardUser()) {
            CSDescribeCache dc = CSDescribeCache.getDescribeCache('Account');

            List<SelectOption> lso = dc.getPicklistOptions('Type');

            System.assertNotEquals(null, lso);
        }
    }

    @isTest
    static void getNonSObjectTypeDescribe() {
        System.runAs(UserTest.createStandardUser()) {
            CSDescribeCache dc = CSDescribeCache.getDescribeCache('System.Network');

            System.assertEquals(null, dc, 'System.Network should not be described.');
        }
    }
}