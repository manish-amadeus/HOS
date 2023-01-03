@isTest(SeeAllData=true)
private class ca2cq_contentMigration_Test{

	public static Community vcommunity;
	public static String dcGroupName;
	public static String dcName;
	public static NetworkMember nMember;
	public static User qAuthor;
	public static String sampleTitle = 'test questions ';


	static Boolean populateTestEnvironment(){

		Question q; QuestionDataCategorySelection qDC;
		Boolean success = true;

		try{
			//As our app needs this three items in order to run test methods, we will add a more "user friendly" exception if we can't reach this objects
			q = [Select Id,CreatedById, CommunityId from Question where Origin = 'Chatter Answers' and CreatedById !=: UserInfo.getuserid() and  CreatedBy.IsActive = true limit 1];
			qDC = [Select DataCategoryName,DataCategoryGroupName from QuestionDataCategorySelection where ParentId = :q.Id];

			dcGroupName = qDC.DataCategoryGroupName;
			dcName		= qDC.DataCategoryName;
			vcommunity	= [Select Id,Name from Community where Id = :q.CommunityId];
            List<NetworkMember> nMembers = [SELECT Id, MemberId, NetworkId FROM NetworkMember LIMIT 1];

            if (nMembers.size() > 0) {
            	nMember = nMembers.get(0);
            } else {
                return false;
            }

			qAuthor		= [select id from User where id =: nMember.MemberId and  IsActive = true ];

			// create configs
			ca2cq_config__c obj = ca2cq_util.getAppSettings();
			obj.Notification_email__c = 'SOMe@test.org';
			upsert obj;

			Map<Id,Community> comm =  ca2cq_util.allCommunities();
			list<ca2cq_Zone_community__c> lista =  ca2cq_util.getAppCommunityMappings();
			for(ca2cq_Zone_community__c c : lista){
				c.Active_for_Migration__c = true;
				ID tmp = c.zoneId__c;
				if (comm.containsKey(tmp)){
					c.Community_Id__c = comm.get(tmp).NetworkId;
					if (!String.isNotBlank(c.Community_Id__c)){
						c.Community_Id__c = 'null';
					}
				}
			}
			upsert lista;

		}catch(Exception e){
			system.debug('Service Cloud Mobile App  Test Methods: In order to run the App test methods you must have Chatter Answers properly set up and at least one public Question in the Database');
			success = false;
		}
		return success;
	}


	static testmethod void testbatch() {

		if (!populateTestEnvironment()) return;

		System.runAs(qAuthor) {
			Question q = new Question(
						   Title= sampleTitle,
						   Origin = 'Chatter Answers',
						   Body= 'here: <img alt="gif 2kb" src="https://c.na17.content.force.com/servlet/rtaImage?eid=906o0000000AJhW&amp;feoid=Body&amp;refid=0EMo0000000Tz6K"></img>',
						   CommunityId = vcommunity.Id);
			insert q;

			QuestionDataCategorySelection qcd =
				new QuestionDataCategorySelection(
									DataCategoryGroupName = dcGroupName,
									DataCategoryName = dcName,
									ParentId = q.Id);

			Reply r = new Reply ( QuestionId = q.Id, Body = 'body and content');

			insert qcd;
			insert r;

			//create corresponding Feed elements
			FeedItem fi = new FeedItem(
					Body = 'here: _img_ alt="gif 2kb" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003Lww&amp;feoid=Body&amp;refid=0EMB0000000EoNF"_/_img_' ,
					Title = sampleTitle,
					Type='QuestionPost',
					CreatedById = q.CreatedById,
					CreatedDate = q.CreatedDate,
					IsRichText = true,
					ParentId = qAuthor.Id,
					NetworkScope = nMember.NetworkId
			);
			insert fi;
			List<Content_Migration__c> cnt = ca2cq_feedsHandler.retrieveContent(fi.Body,fi.Id,null, q.Id);
			insert cnt;

		}
		// The query used by the batch job.

		ca2cq_logs.newLog();
		System.Test.startTest();
		ID batchprocessid = Database.executeBatch(new ca2cq_contentMigration(),1);
		System.Test.stopTest();

		ca2cq_log__c l = ca2cq_logs.getLastLog(false);

		List<Question> lq = [Select Id, Title,Body, CreatedDate from Question where Title =:sampleTitle];
		List<FeedItem> lf = [Select Id, Title,Body,CreatedDate from FeedItem where Title =:sampleTitle];

		System.assert(lf.isEmpty(), 'List should be empty, we do not have the level of access necessary to perform the operation you requested.');


	}
}