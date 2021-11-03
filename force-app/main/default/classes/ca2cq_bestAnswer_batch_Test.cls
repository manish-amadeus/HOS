@isTest(SeeAllData=True)
private class  ca2cq_bestAnswer_batch_Test {

	static void populateTestEnvironment(){

		ca2cq_config__c obj = ca2cq_util.getAppSettings();
		obj.Notification_email__c = 'SOMe@test.org';
		upsert obj;

		FeedItem fItem = new FeedItem(
			Body = 'the text that goes in the body',
			Title = 'the title text' ,
			Type='QuestionPost',
			ParentId = UserInfo.getUserId()
		);
		insert fItem;

		Map<String, FeedComment> bestAnswersMap = new Map<String, FeedComment>();

		FeedComment fc = new FeedComment(FeedItemId = fItem.Id,
							CommentBody = 'the comment text',
							CreatedById = UserInfo.getUserId());
		insert fc;

		bestAnswersMap.put(fItem.Id+ ':&:null:&:' + UserInfo.getUserId(), fc);
		ca2cq_util.insertQuestionsToMigrate(bestAnswersMap);

	}

	static testmethod void testbatch() {
		populateTestEnvironment();
		ca2cq_logs.newLog();
		System.Test.startTest();
		ca2cq_bestAnswer_batch c = new ca2cq_bestAnswer_batch();
		Database.executeBatch(c);
		System.Test.stopTest();

		// Verify best answers where migrated
		Integer i = [SELECT COUNT() FROM ca2cq_best_answer_to_migrate__c];
		System.assertEquals(i, 0);

	}

	static testmethod void testbatch_constructor() {
		populateTestEnvironment();
		ca2cq_logs.newLog();
		System.Test.startTest();
		Map<Id, Map<Id, Map<String, Integer>>> mp = new Map<Id, Map<Id, Map<String, Integer>>> ();
		ca2cq_bestAnswer_batch c = new ca2cq_bestAnswer_batch(mp);
		Database.executeBatch(c);
		System.Test.stopTest();

		// Verify best answers where migrated
		Integer i = [SELECT COUNT() FROM ca2cq_best_answer_to_migrate__c];
		System.assertEquals(i, 0);

	}

}