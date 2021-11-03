@isTest(SeeAllData=true)
private class  ca2cq_batch_Test {

	public static Community vcommunity;
	public static String dcGroupName;
	public static String dcName;
	public static User qAuthor;
	public static String sampleTitle = 'test questions ';


	static Boolean populateTestEnvironment(){

		Question q; QuestionDataCategorySelection qDC;
		Boolean sucess = true;

		try{
			List<Community> extCommunities = [SELECT Id FROM Community WHERE NetworkId != NULL];
			//As our app needs this three items in order to run test methods, we will add a more "user friendly" exception if we can't reach this objects
			q = [Select Id,CreatedById, CommunityId from Question where Origin = 'Chatter Answers' and CreatedById !=: UserInfo.getuserid() and CommunityId IN : extCommunities AND CreatedBy.IsActive = true limit 1];
			qDC = [Select DataCategoryName,DataCategoryGroupName from QuestionDataCategorySelection where ParentId = :q.Id];

			dcGroupName = qDC.DataCategoryGroupName;
			dcName		= qDC.DataCategoryName;
			vcommunity	= [Select Id,Name from Community where Id = :q.CommunityId];
			qAuthor		= [select id from User where id =: q.CreatedById];


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
			sucess = false;
		}

		return sucess;
	}

	static void populateQuestions (List<String> bodyList,List<String> commentBodyList){

        Id currentUserId = Userinfo.getUserId();
		System.runAs(qAuthor) {

			List<Network> allNetworks = [SELECT Id FROM Network];

			Question[] ql = new List<Question>();
			Integer j = 0;
			for (String cB : bodyList) {
				Question q = new Question(
						   Title= sampleTitle + j,
						   Origin = 'Chatter Answers',
						   Body= cB,
						   CommunityId = vcommunity.Id);
				ql.add(q);
				j++;
			}
			insert ql;
			list<QuestionDataCategorySelection> qd = new list<QuestionDataCategorySelection>();
			list<Reply > le = new list<Reply >();
			for (Question q : ql) {
				qd.add(new QuestionDataCategorySelection(
							DataCategoryGroupName = dcGroupName,
							DataCategoryName = dcName,
							ParentId = q.Id)
					);
				for (String rB : commentBodyList){
					le.add(new Reply ( QuestionId = q.Id, Body = rB  ));
				}

			}



			insert qd;
			insert le;

			//set best answer
			Question q = [SELECT id, numreplies, BestReplyId,
					(SELECT Id, Body, UpVotes, CreatedById, CreatedDate FROM Replies)
					FROM Question WHERE CreatedById =: Userinfo.getUserId() and numreplies > 0
					limit 1];
			if (q.Replies.isEmpty())  {
				Reply r = q.Replies.get(0);
				q.BestReplyId = r.Id;
				update q;
			}

			Vote qV = new Vote(ParentId = ql.get(0).Id,CreatedById = currentUserId, type ='Up');
			insert qV;
            Vote rV = new Vote(ParentId = le.get(0).Id,CreatedById = currentUserId, type ='Up');
			insert rV;

			QuestionReportAbuse qrA = new QuestionReportAbuse(QuestionId = ql.get(0).Id, Reason = 'Inappropriate');
			insert qrA;

			ReplyReportAbuse rrA = new ReplyReportAbuse(ReplyId = le.get(0).Id, Reason = 'Inappropriate');
			insert rrA;
		}
	}

	static testmethod void testbatch() {

		if (!populateTestEnvironment()) return;
		populateQuestions (new List<String> {'this is body'},new List<String> {'plain reply'});

		Integer oldTotalFeedElements = [SELECT COUNT() FROM NetworkModeration];
		// The query used by the batch job.

		String query =  ' Select Id, CommunityId, Title,Body, CreatedDate,  CreatedById ,NumReplies, UpVotes, BestReplyId, migrated_to_cq__c '+
						' from Question where Title like \''+String.escapeSingleQuotes(sampleTitle+'%')+'\' LIMIT 500';

		ca2cq_logs.newLog();
		System.Test.startTest();
		ca2cq_batch c = new ca2cq_batch(query);
		ID batchprocessid = Database.executeBatch(c);
		System.Test.stopTest();

		Integer i = [SELECT COUNT() FROM Question where Title like: sampleTitle+'%'];
		Integer newTotalFeedElements = [SELECT COUNT() FROM NetworkModeration];

		ca2cq_log__c l = ca2cq_logs.getLastLog(false);

		List<Question> lq = Database.query(query);
		String queryChatter =  	' Select Id, Title,Body,CreatedDate,CreatedById,ParentId,NetworkScope'+
								' from FeedItem where Title like \''+String.escapeSingleQuotes(sampleTitle+'%')+'\' LIMIT 500';
		List<FeedItem> lf = Database.query(queryChatter);

		System.assert(i == l.Questions_Migrated__c);
		System.assert(!lq.isEmpty() );
		System.assertEquals(lf.size(),lq.size());

		Question theQ = lq.get(0);
		FeedItem theF = lf.get(0);

		System.assertEquals(true, theQ.migrated_to_cq__c);
		System.assertEquals(theQ.Title,theF.Title);
		System.assertEquals(theQ.CreatedDate,theF.CreatedDate);
		System.assertEquals(theQ.CreatedById,theF.CreatedById);
		System.assertEquals(theQ.CreatedById,theF.ParentId);
		System.assertNotEquals(newTotalFeedElements, oldTotalFeedElements);
	}

	static testmethod void testbatch_questions_rtf() {

		if (!populateTestEnvironment()) return;

		String link1_sample = '<a href="http://www.linkSample1.org" target="_blank">a link sample 1</a>';
		String link2_sample = 'other link (<a href="http://www.linkSample2.org" target="_blank"> sample 2 </a>)';

		populateQuestions (new List<String> {	'<b> bold </b>',
												'<i> italics </i>',
												'<u> underline </u>',
												'<strike> strike </strike>',
												'<pre class="ckeditor_codeblock"> code snippet </pre>',
												'<div style="margin-left: 10px;"> divtest </div>',
												'<ol><li>a i in ol</li></ol>',
												'<ul><li>a i in ul</li></ul>',
												link1_sample,
												link2_sample,
												'<div style="text-align: left;">left left</div>'},
							new List<String> {'plain reply'});

		// The query used by the batch job.

		String query =  ' Select Id, CommunityId, Title,Body, CreatedDate,  CreatedById ,NumReplies, UpVotes, BestReplyId '+
						' from Question where Title like \''+String.escapeSingleQuotes(sampleTitle+'%')+'\'';

		ca2cq_logs.newLog();
		System.Test.startTest();

		ca2cq_batch c = new ca2cq_batch(query);
		ID batchprocessid = Database.executeBatch(c);
		System.Test.stopTest();

		Integer i = [SELECT COUNT() FROM Question where Title like: sampleTitle+'%'];

		ca2cq_log__c l = ca2cq_logs.getLastLog(false);

		List<Question> lq = Database.query(query);
		String queryChatter =  	' Select Id, Title,Body,CreatedDate,CreatedById,ParentId,NetworkScope'+
								' from FeedItem where Title like \''+String.escapeSingleQuotes(sampleTitle+'%')+'\'';
		List<FeedItem> lf = Database.query(queryChatter);

		Map<String,FeedItem> mapFeed = new Map<String,FeedItem>();
		for(FeedItem f : lf){
			mapFeed.put(f.Title,f);
		}

		System.assert(i == l.Questions_Migrated__c);

		System.assertEquals(lf.size(),lq.size());
		FeedItem theF ;
		for(Question theQ : lq){
			theF = mapFeed.get(theQ.Title);

			System.assertEquals(theF.Title,theQ.Title,'Title has to be equal');
			System.assertEquals(theF.CreatedDate,theQ.CreatedDate,'Created date has to be equal');
			System.assertEquals(theF.CreatedById,theQ.CreatedById,'Created by Id has to be equal');
			System.assertEquals(theF.ParentId,theQ.CreatedById,'FeedItem parent should be author');
			if (theQ.Body.contains('<strike>')){
				System.assert(!theF.Body.contains('<strike>'),' New Feed does not have <strike> tag');
				System.assert(theF.Body.contains('<s>'),'New Feed has now an s tag');
			}else
			if (theQ.Body.contains(link1_sample)){
				System.assert(!theF.Body.contains(link1_sample),'New Feed does not have a href tag');
				System.assert(theF.Body.contains('http://www.linkSample1.org'),'New Feed has text inside the a tag only');
			}else
			if (theQ.Body.contains(link2_sample)){
				System.assert(!theF.Body.contains(link2_sample),'New Feed does not have an href with ( ) brakets');
				System.assert(theF.Body.contains('other link (http://www.linkSample2.org)'),'New Feed has the text inside the href');
			}else
			if (theQ.Body.contains('<pre class="ckeditor_codeblock">')){
				System.assert(!theF.Body.contains('<pre class="ckeditor_codeblock">'),'New Feed item does not have a pre tag');
				System.assert(theF.Body.contains('<code>'),'New Feed item has a code tag');
			}else
			if (theQ.Body.contains('<div style="margin-left: 10px;"> divtest </div>')){
				System.assert(!theF.Body.contains('<div style="margin-left: 10px;"> divtest </div>'),'New Feed does not have style attribute');
				System.assert(theF.Body.contains('divtest'),'New Feed only has content');
			}else
			if (theQ.Body.contains('<div style="text-align: left;">left left</div>')){
				System.assert(!theF.Body.contains('<div style="text-align: left;">left left</div>'),'New Feed does not have style attribute');
				System.assert(theF.Body.contains('left left'),'New Feed only has content');
			}else
				System.assertEquals(theF.Body,theQ.Body,'New Feed body should match question body');
		}
	}

	static testmethod void testbatch_replies_rtf() {

		if (!populateTestEnvironment()) return;

		String link1_sample = '<a href="http://www.linkSample1.org" target="_blank">a link sample 1</a>';
		String link2_sample = 'other link (<a href="http://www.linkSample2.org" target="_blank"> sample 2 </a>)';

		populateQuestions (new List<String> {	'simple q'},
							new List<String> {	'<b> bold </b>',
												'<i> italics </i>',
												'<u> underline </u>',
												'<strike> strike </strike>',
												'<pre class="ckeditor_codeblock"> code snippet </pre>',
												'<div style="margin-left:15px;"> divtest </div>',
												'<ol><li>a i in ol</li></ol>',
												'<ul><li>a i in ul</li></ul>',
												link1_sample,
												link2_sample,
												'<div style="text-align: left;">left left</div>'});

		// The query used by the batch job.

		String query =  ' Select Id, CommunityId, Title,Body, CreatedDate,  CreatedById ,NumReplies, UpVotes, BestReplyId, '+
						' (Select Id, Body, UpVotes, CreatedById, CreatedDate,Question.CreatedById from Replies) '+
						' from Question where Title like \''+String.escapeSingleQuotes(sampleTitle+'%')+'\'';

		ca2cq_logs.newLog();
		System.Test.startTest();

		ca2cq_batch c = new ca2cq_batch(query);
		ID batchprocessid = Database.executeBatch(c);
		System.Test.stopTest();

		//query Questions that were processed
		List<Question> lq = Database.query(query);
		Question sourceQuestion = lq.get(0);

		Integer totalQuestions = lq.size();
		Integer totalReplies = sourceQuestion.Replies.size();

		ca2cq_log__c l = ca2cq_logs.getLastLog(false);

		String queryChatter = 	' Select Id, Title,Body,CreatedDate,CreatedById,ParentId,NetworkScope, '+
								' (Select Id, CommentBody,CreatedDate,CreatedById,ParentId from FeedComments) '+
								' from FeedItem where Title like \''+String.escapeSingleQuotes(sampleTitle+'%')+'\'';
		List<FeedItem> lf = Database.query(queryChatter);
		FeedItem migratedFeed = lf.get(0);


		Map<String,FeedComment> mapFeed = new Map<String,FeedComment>();
		for(FeedComment f : migratedFeed.FeedComments){
			mapFeed.put(f.CommentBody,f);
		}

		System.assert(totalQuestions == l.Questions_Migrated__c,'Not all questions were migrated');

		System.assert(totalReplies == l.Answers_Migrated__c,'Not all replies were migrated');

		System.assertEquals(lf.size(),lq.size());
		FeedComment mig_R ;
		for(Reply aReply : sourceQuestion.Replies){


			if (!mapFeed.containsKey(aReply.Body))
				continue;
			mig_R = mapFeed.get(aReply.Body);

			System.assertEquals(mig_R.CreatedDate,aReply.CreatedDate,'Created date has to be equal');
			System.assertEquals(mig_R.CreatedById,aReply.CreatedById,'Created by Id has to be equal');
			System.assertEquals(mig_R.ParentId,aReply.CreatedById,'FeedItem parent should be author');

			if (aReply.Body.contains('<strike>')){
				System.assert(!mig_R.CommentBody.contains('<strike>'),' New Feed does not have <strike> tag');
				System.assert(mig_R.CommentBody.contains('<s>'),'New Feed has now an s tag');
			}else
			if (aReply.Body.contains(link1_sample)){
				System.assert(!mig_R.CommentBody.contains(link1_sample),'New Feed does not have a href tag');
				System.assert(mig_R.CommentBody.contains('http://www.linkSample1.org'),'New Feed has text inside the a tag only');
			}else
			if (aReply.Body.contains(link2_sample)){
				System.assert(!mig_R.CommentBody.contains(link2_sample),'New Feed does not have an href with ( ) brakets');
				System.assert(mig_R.CommentBody.contains('other link (http://www.linkSample2.org)'),'New Feed has the text inside the href');
			}else
			if (aReply.Body.contains('<pre class="ckeditor_codeblock">')){
				System.assert(!mig_R.CommentBody.contains('<pre class="ckeditor_codeblock">'),'New Feed item does not have a pre tag');
				System.assert(mig_R.CommentBody.contains('<code>'),'New Feed item has a code tag');
			}else
			if (aReply.Body.contains('<div style="text-align: left;">left left</div>')){
				System.assert(!mig_R.CommentBody.contains('<div style="text-align: left;">left left</div>'),'New Feed does not have style text-align attribute');
				System.assert(mig_R.CommentBody.contains('left left'),'New Feed only has content');
			}else
			if (aReply.Body.contains('<div style="margin-left:15px;"> divtest </div>')){
				System.assert(!mig_R.CommentBody.contains('<div style="margin-left:15px;"> divtest </div>'),'New Feed does not have style margin-left attribute');
				System.assert(mig_R.CommentBody.contains('divtest'),'New Feed only has content');
			}else
				System.assertEquals(mig_R.CommentBody,aReply.Body,'New Feed body should match question body');

		}
	}

	static testmethod void testbatch_questions_skip_10_images() {

		if (!populateTestEnvironment()) return;

		String imgCnt = '<img alt="User-added image" src="https://c.gus.content.force.com/servlet/rte_broken_image.png" style="height: 500px; width: 500px;"></img>';
		String testBody = imgCnt.repeat(11);
		populateQuestions (new List<String> {'10 pics'+testBody},
							new List<String> {'plain reply'});

		// The query used by the batch job.

		String query =  ' Select Id, CommunityId, Title,Body, CreatedDate,  CreatedById ,NumReplies, UpVotes, BestReplyId '+
						' from Question where Title like \''+String.escapeSingleQuotes(sampleTitle+'%')+'\'';

		ca2cq_logs.newLog();
		System.Test.startTest();

		ca2cq_batch c = new ca2cq_batch(query);
		ID batchprocessid = Database.executeBatch(c);
		System.Test.stopTest();

		Integer i = [SELECT COUNT() FROM Question where Title like: sampleTitle+'%'];

		ca2cq_log__c l = ca2cq_logs.getLastLog(false);

		List<Question> lq = Database.query(query);
		String queryChatter =  	' Select Id, Title,Body,CreatedDate,CreatedById,ParentId,NetworkScope'+
								' from FeedItem where Title like \''+String.escapeSingleQuotes(sampleTitle+'%')+'\'';
		List<FeedItem> lf = Database.query(queryChatter);

		System.assert(0 == l.Questions_Migrated__c);
		System.assert(1 == l.Questions_Selected__c);
		System.assert(1 == l.Errors_on_Questions__c);


	}


	static testmethod void testbatch_replies_skip_10_images() {

		if (!populateTestEnvironment()) return;

		String imgCnt = '<img alt="User-added image" src="https://c.gus.content.force.com/servlet/rte_broken_image.png" style="height: 500px; width: 500px;"></img>';
		String testBody = imgCnt.repeat(11);

		populateQuestions (new List<String> {	'simple q'},
							new List<String> {	'simple comment',
												testBody});

		// The query used by the batch job.

		String query =  ' Select Id, CommunityId, Title,Body, CreatedDate,  CreatedById ,NumReplies, UpVotes, BestReplyId, '+
						' (Select Id, Body, UpVotes, CreatedById, CreatedDate,Question.CreatedById from Replies) '+
						' from Question where Title like \''+String.escapeSingleQuotes(sampleTitle+'%')+'\'';

		ca2cq_logs.newLog();
		System.Test.startTest();

		ca2cq_batch c = new ca2cq_batch(query);
		ID batchprocessid = Database.executeBatch(c);
		System.Test.stopTest();

		ca2cq_log__c l = ca2cq_logs.getLastLog(false);

		String queryChatter = 	' Select Id, Title,Body,CreatedDate,CreatedById,ParentId,NetworkScope, '+
								' (Select Id, CommentBody,CreatedDate,CreatedById,ParentId from FeedComments) '+
								' from FeedItem where Title like \''+String.escapeSingleQuotes(sampleTitle+'%')+'\'';
		List<FeedItem> lf = Database.query(queryChatter);
		FeedItem migratedFeed = lf.get(0);

		System.assert(1 == l.Questions_Migrated__c);
		System.assert(1 == l.Questions_Selected__c);
		System.assert(0 == l.Errors_on_Questions__c);

		System.assertEquals(1, l.Answers_Migrated__c);
		System.assert(2 == l.Answers_Selected__c);
		System.assert(1 == l.Errors_on_Answers__c);

	}


}