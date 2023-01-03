@isTest
private class  ca2cq_logs_Test {
	static void populateSettings(){

		ca2cq_config__c appSettings =  ca2cq_util.getAppSettings();
		insert appSettings;

		ca2cq_config__c obj = ca2cq_util.getAppSettings();
		obj.Notification_email__c = 'SOMe@test.org';
		upsert obj;
	}

	//boolean boolean newLog()
	static testMethod void test_newLog(){
		populateSettings();

		Integer origSize = [ 	SELECT count()
							FROM ca2cq_log__c ];

		System.Test.startTest();

		System.assertEquals(null, ca2cq_logs.getCurrentLog ());
		ca2cq_logs.newLog();

		Integer newCount = [ 	SELECT count()
							FROM ca2cq_log__c
							WHERE End_Date__c = null ];
		System.assertEquals(1, newCount );

		System.assertNotEquals(null, ca2cq_logs.getCurrentLog ());
		ca2cq_log__c cLOG = ca2cq_logs.getCurrentLog ();

		Id lId =  cLOG.Id;
		ca2cq_logs.newLogDetail(lId,'test', 'test00001', 'for test','for test' ,false);
		ca2cq_logs.updateLog(10,10,2,2,5,5);
		System.assertNotEquals(null, ca2cq_logs.getLastLog(false));
		ca2cq_logs.closeLog();

		System.Test.stopTest();

		Integer finalSize = [ 	SELECT count()
								FROM ca2cq_log__c ];

		System.assertEquals(origSize, ( finalSize-1) );

		ca2cq_logs.sendNotification();

	}
}