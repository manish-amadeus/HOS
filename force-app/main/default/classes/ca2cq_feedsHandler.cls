/**
 * @author Altimetrik
 * @description
 *    started on 10/08/2014
 *    Static class with method for hanlding Chatter FeedItem object
 **/
public with sharing class ca2cq_feedsHandler {

	// Constants
	public static Integer TOTAL_IMAGES_ENABLED = 10;
	public static String CONTENT_KEYWORD = 'rtaImage?eid';
	public static String CONTENT_KEYWORD_TEST = 'rte_broken_image.png';
	public static Integer FI_TitleMaxLength = FeedItem.Title.getDescribe().getLength();
	public static Integer FI_BodyMaxLength = FeedItem.Body.getDescribe().getLength();
	public static Integer FC_BodyMaxLength = FeedComment.CommentBody.getDescribe().getLength();
	public static map<Id,Community> mapCom = new map<Id,Community>([Select Name from Community limit 100]);
	public static map<Id,Network> mapNet = new map<Id,Network>([SELECT Id,Name,Status FROM Network limit 100]);
	public static set<String> networkMembers = ca2cq_util.getUsersPerCommunity();

	public static String TOTAL_QUESTIONS		= 'total_questions';
	public static String TOTAL_REPLIES_MADE		= 'total_replies_made';
	public static String TOTAL_REPLIES_RECEIVED = 'total_replies_received';
	public static String TOTAL_LIKES_MADE		= 'total_likes_made';
	public static String TOTAL_LIKES_RECEIVED	= 'total_likes_received';
	public static String TOTAL_BA_AUTHOR		= 'total_bestA_author';
	public static String TOTAL_BA_SELECTOR		= 'total_bestA_selector';
	//************************************************************************
	public static Integer Questions_Selected;
	public static Integer Questions_Errors;
	public static Integer Answers_Selected;
	public static Integer Answers_Errors;
	public static Integer Topics_Errors;

	public static ca2cq_log__c currentLog;
	public static Map<Id,list<Question>> questionsByCommunity = new Map<Id,list<Question>>();
	public static Map<Id, FeedComment> mapReplyVotes = new Map<Id, FeedComment>();
	public static Set<Id> setMigratedReplies = new Set<Id>();
	public static Set<String> dataCategoriesNames = new Set<String>();
	public static List<Topic> newTopics = new List<Topic>();
	public static Map<String, Id> mapAllTopics = new Map<String, Id>();
	public static Map<Id, Question> questionsMap = new Map<Id, Question>();
	public static Map<String, FeedComment> bestAnswersMap = new Map<String, FeedComment>();
	public static Map<Id, Map<Id, Map<String, Integer>>> pointsToMigrate;
  	public static Map<Id, Network> reputationLivePerCommunity;
	public static Map<Id,List<String>> skippedQuestionsPerCommunity = new Map<Id,List<String>>();

	public static String CSV_LOG_TITLE = 'recordId,reason';
	public static List<String> skippedQuestions = new List<String>();
	public static List<String> skippedReplies = new List<String>();
	public static Map<Id, Map<String, Integer>> getRepRules = ca2cq_util.getCommunitiesPointRules();

	/*
      params : Id of FeedItem, Question, List of Replies and NetworkId
      return List<FeedComment>:
        Converts a list of replies into FeedComments.
    */
	public static List<FeedComment> convertAnswerToCommentsList(Id fItem, Question qu, List<Reply> reps, String netId) {
		List<FeedComment> result = new List<FeedComment>();
		String body;
		FeedComment fc;

		for (Reply r : reps) {
			// If there are more than TOTAL_IMAGES_ENABLED skip this reply
			if (String.isNotBlank(r.Body) &&
				((! System.Test.isRunningTest()  &&
					r.Body.countMatches(CONTENT_KEYWORD) > TOTAL_IMAGES_ENABLED)
				|| (System.Test.isRunningTest() &&
					r.Body.countMatches(CONTENT_KEYWORD_TEST) > TOTAL_IMAGES_ENABLED)
				)
				) {
				skippedReplies.add('\n'+r.Id+', Reply contained more than ' + TOTAL_IMAGES_ENABLED+' images');
				continue;
			}

			if (String.isNotBlank(r.Body) &&  r.Body.length() > FC_BodyMaxLength) {
				skippedReplies.add('\n' + r.Id + ', Original reply contains more than ' + FC_BodyMaxLength + ' characters and cannot be migrated (HTML tags may not be visible). Total characters: ' + r.Body.length());
				continue;
			}

			String keyToCheck = netId + '-' + r.CreatedById;
			// Check if the question's community has reputation enabled
			if (getRepRules.containsKey(netId)) {
				// If the author of the reply has no network member record  skip this reply
				if (String.isNotBlank(netId) && !networkMembers.contains(keyToCheck)  && ! System.Test.isRunningTest()) {
					skippedReplies.add('\n'+r.Id+', Reply author has no record on NetworkMember ');

					continue;
				}
			}

			setMigratedReplies.add(r.Id);
			List<String> logString = new List<String>();
			try {
				body = ca2cq_util.convertBody(r.Body,netId);

				if (String.isNotBlank(body) &&  body.length() > FC_BodyMaxLength) {
					skippedReplies.add('\n' + r.Id + ', Converted reply has more than ' + FC_BodyMaxLength + ' characters and cannot be migrated (HTML tags may not be visible). Total characters: ' + body.length());
					continue;
				}
			} catch(Exception e) {
				logString.add('Id: ' + r.Id + ' \nException: ' + e );
				ca2cq_logs.newLogDetail(currentLog.Id, 'Reply tag conversion: ', currentLog.Id, 'Exception on reply tag conversion ', String.join(logString,'\n'),true );
				return new List<FeedComment>();
			}

			if (String.isNotBlank(body)) {
				fc = new FeedComment(FeedItemId = fItem,
									 CommentBody = body,
									 IsRichText = true ,
									 CreatedDate = r.CreatedDate,
									 CreatedById = r.CreatedById);
				result.add(fc);

				if (r.upVotes > 0) {
					mapReplyVotes.put(r.id,fc);
				}
				if (qu.BestReplyId == r.Id) {
					bestAnswersMap.put(fItem + ':&:' + netId + ':&:' + qu.BestReplySelectedById, fc);
				}
			}
		}
		return  result;
	}

	/*
      params : Id of FeedItem, Question,
      return List<FeedLike>:
        Converts the votes of a question into Chatter Likes
    */
	public static List<FeedLike> convertVotesToLikes(Id fItem, Question q, List<Vote> lv) {
		List<FeedLike> result = new List<FeedLike>();
		Question qu = questionsMap.get(q.Id);

		for(Vote v : lv){
			result.add(new FeedLike(FeedEntityId = fItem ,FeedItemId = fItem, CreatedById = v.CreatedById , CreatedDate = v.CreatedDate ));
		}

		return result;
	}

	/*
      params : Id of FeedItem, Question, NetworkId, List of DataCategorySelection
      return List<TopicAssignment>:
        Converts DataCategories into Chatter Topics
    */
	public static List<TopicAssignment> convertDataCategoriesToTopics(Id fItem, Question q, String netId, List<QuestionDataCategorySelection> qdcs) {
		List<TopicAssignment> result = new List<TopicAssignment>();
		Map<String, String> dataCategoryMap =  ca2cq_util.getDCToToppicsMap();
		Question qu = questionsMap.get(q.Id);
		String key;
		Integer counter = 0;
		for (QuestionDataCategorySelection qdc : qdcs) {
			if (qdc.ParentId == qu.Id) {
				if (dataCategoryMap.containsKey(qdc.DataCategoryName)) {
					key = dataCategoryMap.get(qdc.DataCategoryName) + ':&:' + netId;
				} else {
					key = qdc.DataCategoryName + ':&:' + netId;
				}

				Id topicId = mapAllTopics.get(key);

				if (topicId != null) {
					result.add(new TopicAssignment(EntityId = fItem, TopicId = topicId, NetworkId = netId));
				}

				counter++;
			}
		}

		// Prevent undesired duplicates
		Set<TopicAssignment> myset = new Set<TopicAssignment>();
		List<TopicAssignment> finalResult = new List<TopicAssignment>();
		myset.addAll(result);
		finalResult.addAll(myset);

		return finalResult;
	}

	/*
      params : NetworkId, Question
      return FeedItem
        Converts a Question into a FeedItem
    */
	public static FeedItem convertQuestionToFeedItem(String nId, Question q){
		// Question Title mapping
		String title = q.Title;
		if (title.length() > FI_TitleMaxLength ){
			title = title.substring(0,FI_TitleMaxLength);
		}

		// Question Body mapping
		String rawBody = q.Body;
		String body = '';

		list<String> logString = new list<String>();

		if (String.isNotBlank(rawBody)){
			try{
				body = ca2cq_util.convertBody(rawBody,nId);
			}  catch(Exception e) {
				system.debug('exception :  ' + e);
				logString.add('Id: ' + q.Id + ' \n Exception: '+ e );
				ca2cq_logs.newLogDetail(currentLog.Id,'Question tag conversion: ', currentLog.Id, 'Exception on question tag conversion ', String.join(logString,'\n'),true );
				return null;
			}
		}

		return new FeedItem(
						Body = body,
						Title = title ,
						Type='QuestionPost',
						CreatedById = q.CreatedById,
						CreatedDate = q.CreatedDate,
						IsRichText = true,
						ParentId = q.CreatedById,
						NetworkScope = nId
					);
	}


	/*
      params : None
      return List<String>
        Creates topics from the selected dataCategories and returns a log.
    */
	public static List<String> dataCategoriesToTopics() {
		Map<String, String> dataCategoryMap = ca2cq_util.getDCToToppicsMap();
		mapAllTopics = ca2cq_util.allTopics();
		Set<String> processed2 = mapAllTopics.keySet();
		Set<String> processed = new Set<String>();
        List<Topic> topicsToInsert = new List<Topic>();

		processed.addAll(processed2);
		String topicLabel;

		for (String dcn : dataCategoriesNames) {
			List<String> parts = dcn.split(':&:');
			// Use the label indicated in the setups
			topicLabel = parts[0];
			if (dataCategoryMap.containsKey(topicLabel)) {
				topicLabel = dataCategoryMap.get(topicLabel);
			} else {
				topicLabel = topicLabel.replaceAll('_', ' ');
			}

			String tmpKey = topicLabel + ':&:' + parts[1];

			if (!processed.contains(tmpKey)) {
				if (String.isNotBlank(parts[1]) &&  parts[1] != 'null') {
					topicsToInsert.add(new Topic(Name = topicLabel, NetworkId = parts[1]));
				} else {
					topicsToInsert.add(new Topic(Name = topicLabel));
				}

				processed.add(dcn);
			} else {
				system.debug('\n===  DIDNT ADD ' + topicLabel + ' /key : ' + tmpKey + ' - ' + processed.contains(tmpKey));
			}
		}
		// Insert new Topics topicsToInsert;
		Database.UpsertResult[] topicResults =  Database.upsert(topicsToInsert, false);
		List<String> logString = new List<String>();
		Set<Id> insertResults = new Set<Id>();

        Integer g = 0;

		for (Database.UpsertResult res : topicResults) {
            Topic t = topicsToInsert.get(g);

			if (res.isSuccess()) {
				if (res.isCreated()) {
                    // Add succesful topic to list
                    newTopics.add(t);
					insertResults.add(res.getId());
					logString.add(' TOPIC OK : ' + res.getId());
				}
			} else {
				Topics_Errors++;
				if (res.getErrors().size() > 0) {
					logString.add(' TOPIC NOT OK : '+ res.getId()+ ' : '+res.getErrors()[0].getMessage() );
				}
			}
            g++;
		}
		logString.add(' TOPICS MIGRATION : ' + insertResults.size() + '/' + insertResults.size());

		return logString;
	}

	/*
      params : CommunityId, NetworkId, List of FeedItems, List of Questions, List of Replies, List of DataCategoriesSelection, Log, Batch Step
      return none
        Creates FeedItems from Questions and Replies, with its Votes and Flags
    */
	private static void migrateQuestionsForCommunity(String commId, String netId ,List<FeedItem> feedElements, List<Question> questions, List<Reply> rpls, List<QuestionDataCategorySelection> qdcs, Map<Id,List<Vote>> mapVote, String logId, String step){
		Integer logTitle_MAXLENGTH = Schema.SObjectType.ca2cq_log_detail__c.fields.Name.getLength();
		mapReplyVotes = new Map<Id, FeedComment>();
		List<Reply> allReplies = new List<Reply>();
		List<FeedComment> allComments = new List<FeedComment>();
		List<FeedLike> allLikes = new List<FeedLike>();
		List<TopicAssignment> allTopicAssignments = new List<TopicAssignment>();
		List<Content_Migration__c> allContentToMigrate  = new List<Content_Migration__c>();
		Map<Id,Id> authorByFeedId = new Map<Id,Id>();
		// Error tracking and loggin
		List<String> logString = new List<String>();
		List<Id> okResults = new List<Id>();

		Integer j = 0;
		Question qTmp ;

		logString.add(' ====================================================================================');
		if (mapCom.containsKey(commId))
			logString.add('Migration logs for:'+ mapCom.get(commId).Name +' Id: '+commId);
		else
			logString.add('Migration logs for:'+commId);
		/* ************************************************************************************************************
			QUESTION TO FEED ITEM
		************************************************************************************************************ */

		//insert feedElements;
		Questions_Selected += feedElements.size();
		Database.UpsertResult[] results =  Database.upsert(feedElements, false);
		Integer g=0;
		FeedItem fi;
		List<Question> successfulQuestions = new List<Question>();
		List<FeedItem> successfulFeedItems = new List<FeedItem>();
		Map<Id, FeedItem> questionToFeedItem = new Map<Id, FeedItem>();
		List<Question> questionsMigratedIds = new List<Question>();
		List<String> qFailed = new List<String>();
		List<String> qSucess = new List<String>();
		List<ca2cq_Question_To_FeedItem__c> questionsToFeedItemList = new List<ca2cq_Question_To_FeedItem__c>();

		for (Database.UpsertResult res : results) {
			qTmp = questions.get(g);
			fi = feedElements.get(g);
			Question qu = questionsMap.get(qTmp.Id);

			if (res.isSuccess()) {
				if (res.isCreated()) {
					Boolean removeActualQuestion = false;
					if(fI.netWorkScope != null){
						ca2cq_Question_To_FeedItem__c actualQuestionTFI = new ca2cq_Question_To_FeedItem__c(
								Name = qTmp.Id+'' ,
								networkId__c = fI.netWorkScope,
								feedItemId__c = fi.Id,
								questionId__c = qTmp.Id
							);
						questionsToFeedItemList.add(actualQuestionTFI);
					}

					questionsMigratedIds.add(qTmp);
					okResults.add(res.getId() );

					qSucess.add('\n'+qTmp.Id+','+res.getId());//

					List<Reply> repliesForQuestion = new List<Reply>();

					for (Reply auxRep: rpls) {
							if (qu.Id == auxRep.QuestionId)
									repliesForQuestion.add(auxRep);
					}

					allComments.addAll(convertAnswerToCommentsList(fi.Id, qu, repliesForQuestion, netId));

					for (Reply r : rpls) {
							if (r.QuestionId == qTmp.Id)
									allReplies.add(r);
					}

					if(mapVote.containsKey(qTmp.Id))
					{
						allLikes.addAll(convertVotesToLikes(fi.Id, qTmp, mapVote.get(qTmp.Id)));
					}



				    allTopicAssignments.addAll(convertDataCategoriesToTopics(fi.Id, qTmp, netId, qdcs));

					//update stats for user  questions
					updateStats(netId,fi.CreatedById, 1,0,0,0,0,0,0);
					authorByFeedId.put(fi.Id,fi.CreatedById);
					/* CREATE CONTENT Migration OBJECT */
					allContentToMigrate.addAll(
						retrieveContent(fi.Body,fi.Id,fI.netWorkScope, qTmp.Id)
					);
					successfulQuestions.add(qTmp);
					successfulFeedItems.add(fi);
					questionToFeedItem.put(qTmp.Id, fi);
				}
			}else {

				if (res.getErrors().size() > 0) {
					qFailed.add('\n'+qTmp.id+','+res.getErrors().get(0).getMessage());
				}
			}
			g++;
		}



		//List<ca2cq_Question_To_FeedItem__c> questionsToFeedItemToRemove = new List<ca2cq_Question_To_FeedItem__c>([SELECT Name FROM ca2cq_Question_To_FeedItem__c WHERE Name IN :questionsToFeedItemList]);
		//questionsToFeedItemList.removeAll(questionsToFeedItemToRemove);
	    upsert questionsToFeedItemList Name;

		questionsToFeedItemList.clear();

		if (skippedQuestionsPerCommunity.containsKey(commId))
				skippedQuestions = skippedQuestionsPerCommunity.get(commId);

		Integer totalQuestions = feedElements.size() + skippedQuestions.size();

		// Log migrated questions
		if (!qSucess.isEmpty()) {
				logString.add('Questions migrated: '+ qSucess.size() + '/' + totalQuestions);
		}

		// Log skipped questions
		if ( (skippedQuestions != null && !skippedQuestions.isEmpty() ) || !qFailed.isEmpty()){
				Questions_Selected += skippedQuestions.size();
				Questions_Errors  += skippedQuestions.size() + qFailed.size();
				logString.add('Questions not migrated: '+ qFailed.size()+ '/' + totalQuestions);

				logString.add('Questions not processed: '+ skippedQuestions.size() + '/' + totalQuestions);
		}

		/* ************************************************************************************************************
			REPLY TO FEED COMMENT
		************************************************************************************************************ */
		Answers_Selected += allComments.size();
		Database.UpsertResult[] commentResults =  Database.upsert(allComments, false);
		List<Reply> successfulReplies = new List<Reply>();
		Map<Id, FeedComment> replyToFeedComment = new Map<Id, FeedComment>();
		List<String> insertedReplies = new List<String>();
		List<String> failedReplies = new List<String>();
		g = 0;
		FeedComment feedc;
		Reply r;
		for (Database.UpsertResult res : commentResults) {
			if (g < allComments.size() ){
				feedc = allComments.get(g);
			}else{
				feedc = null;
			}
			if (g < allReplies.size() ){
				r = allReplies.get(g);
			}else{
				r = null;
			}

			if (res.isSuccess()) {
				if (res.isCreated()) {
					insertedReplies.add( '\n'+r.Id+','+res.getId() );//

					if (feedc != null ){
						//update stats for user replies made
						updateStats(netId,feedc.CreatedById, 0,0,1,0,0,0,0);
						if ( r != null){
							/* CREATE CONTENT Migration OBJECT */
							allContentToMigrate.addAll(
								retrieveContent(feedC.CommentBody,feedC.Id,netId, r.Id)
							);
							//update stats for user replies received
							updateStats(netId,r.Question.CreatedById, 0, 1,0,0,0,0,0);
						}
					}
					authorByFeedId.put(feedc.Id,feedc.CreatedById);

					successfulReplies.add(r);
					replyToFeedComment.put(r.Id, feedc);
				}
			}else{
				if (res.getErrors().size() > 0) {
					if ( r != null)
						failedReplies.add('\n'+r.Id+','+res.getErrors().get(0).getMessage());
				}
			}
			g++;
		}

		Integer totalReplies = insertedReplies.size() + skippedReplies.size();

		// Log migrated replies
		if (!insertedReplies.isEmpty()) {
				logString.add('Replies migrated:' + insertedReplies.size() + '/' + totalReplies);
		}

		// Log skipped replies
		if (!skippedReplies.isEmpty() || !failedReplies.isEmpty()){
				Answers_Errors += skippedReplies.size() + failedReplies.size();
				Answers_Selected += skippedReplies.size() ;
				logString.add('Replies not migrated: ' + failedReplies.size() + '/' + totalReplies);

				logString.add('Replies not processed: ' + skippedReplies.size() + '/' + totalReplies);
		}

		/*
			CREATE CONTENT Migration OBJECT
		*/
		if (!allContentToMigrate.isEmpty()){
			insert allContentToMigrate;
		}
		logString.add('Images to be processed :'+ allContentToMigrate.size());

		/* ************************************************************************************************************
			MIGRATE FLAGGED FEEDITEMS
		************************************************************************************************************ */
		List<NetworkModeration> flaggedFI = new List<NetworkModeration>();
		Map<Id, QuestionReportAbuse> reportedQuestions = new Map<Id, QuestionReportAbuse>();
		if (successfulQuestions.size() > 0) {
			reportedQuestions = ca2cq_util.getFlaggedQuestions(successfulQuestions);

			if (reportedQuestions.size() > 0) {
				flaggedFI = ca2cq_util.setFlaggedFeedItems(questionToFeedItem, reportedQuestions);
			}
		}

		if (flaggedFI.size() > 0) {
			Database.UpsertResult[] insertedFlaggedFI =  Database.upsert(flaggedFI, false);

			Integer flagSuccess = 0;
			Integer flagFailures = 0;

			for (Database.UpsertResult res : insertedFlaggedFI) {
				if (!res.isSuccess()) {
					if (res.getErrors().size() > 0) {
						flagFailures++;
					}
				} else {
					flagSuccess++;
				}
			}

			logString.add('Flagged feedItems success :' + flagSuccess + '/' + reportedQuestions.size());
			logString.add('Flagged feedItems failures :' + flagFailures + '/' + reportedQuestions.size() );
		}

		/* ************************************************************************************************************
			MIGRATE FLAGGED FEEDCOMMENTS
		************************************************************************************************************ */
		List<NetworkModeration> flaggedFC = new List<NetworkModeration>();
		Map<Id, ReplyReportAbuse> reportedReplies = new Map<Id, ReplyReportAbuse>();
		if (successfulReplies.size() > 0) {
			reportedReplies = ca2cq_util.getFlaggedReplies(successfulReplies);

			if (reportedReplies.size() > 0) {
				flaggedFC = ca2cq_util.setFlaggedFeedComments(replyToFeedComment, reportedReplies, successfulFeedItems);
			}
		}

		if (flaggedFC.size() > 0) {
			Database.UpsertResult[] insertedFlaggedFC =  Database.upsert(flaggedFC, false);

			Integer flagSuccess = 0;
			Integer flagFailures = 0;

			for (Database.UpsertResult res : insertedFlaggedFC) {
				if (!res.isSuccess()) {
					if (res.getErrors().size() > 0) {
						flagFailures++;
					}
				} else {
					flagSuccess++;
				}
			}

			logString.add('Flagged feedComments success :' + flagSuccess + '/' + reportedReplies.size());
			logString.add('Flagged feedComments failures :' + flagFailures + '/' + reportedReplies.size() );
		}

		/* ************************************************************************************************************
			DATA CATEGORIES TO TOPIC
		************************************************************************************************************ */
		//insert allTopicAssignments;
		Database.UpsertResult[] topicInsertResult =  Database.upsert(allTopicAssignments, false);

		okResults = new List<Id>();
		Integer totalSuccess = 0;
		Integer totalFailures = 0;
		for (Database.UpsertResult res : topicInsertResult) {
			if (!res.isSuccess()) {
				if (res.getErrors().size() > 0) {
					totalFailures++;
				}
			}else{
				totalSuccess++;
			}
		}
		logString.add('Topic assignment success :'+ totalSuccess+ '/'+allTopicAssignments.size());
		logString.add('Topic assignment failures :'+  totalFailures+ '/'+allTopicAssignments.size() );

		/* ************************************************************************************************************
			REPLIES VOTE TO  FEED COMMENT LIKE
		************************************************************************************************************ */
		list<Vote> lv = [   SELECT id, ParentId, CreatedById, CreatedDate
							FROM vote
							WHERE
								parent.type = 'Reply' AND type = 'Up'
							AND parentId in: setMigratedReplies];

		List<FeedLike> replylikes = new List<FeedLike>();
		for(Vote v : lv){
			FeedComment fc = mapReplyVotes.get(v.parentId);
			if(fc != null){
				FeedLike fl = new FeedLike(FeedEntityId = fc.Id , CreatedById = v.CreatedById , CreatedDate = v.CreatedDate  );
				allLikes.add(fl);
			}
		}

		/* ************************************************************************************************************
				QUESTIONS AND REPLIES VOTES TO  FEEDLIKE
		************************************************************************************************************ */
		Database.UpsertResult[] likesInsertResult =  Database.upsert(allLikes, false);
		okResults = new List<Id>();
		g=0;
		for (Database.UpsertResult res : likesInsertResult) {
			FeedLike fl = allLikes.get(g);
			if (!res.isSuccess()) {

			}else{
				okResults.add(res.getId());
				if (authorByFeedId.containsKey(fl.FeedEntityId)){
					//update stats for user likes received
					updateStats(netId,authorByFeedId.get(fl.FeedEntityId), 0, 0,0,1,0,0,0);
					//update stats for user likes made
					updateStats(netId,fl.CreatedById, 0, 0,0,0,1,0,0);
				}
			}
			g++;
		}
		logString.add('Migrated Likes on Feeds : '+ okResults.size()+ '/'+allLikes.size());


		String logTitle =  step;
		if (mapCom.containsKey(commId)){
			map<String,String> zone2Community = ca2cq_util.chatterZoneToNetwork();
			String netName = ' - ';
			if (zone2Community.containsKey(commId)){
				netId = zone2Community.get(commId);
				if (netId != null){
					if (mapNet.containsKey(netId))
						netName = mapNet.get(netId).Name;
				}else{
					netName = 'Internal Community';
				}
			}
			logTitle += mapCom.get(commId).Name+'['+commId+'] to '+netName+' ['+netId+']';


			if (logTitle.length() > logTitle_MAXLENGTH)
				logTitle = logTitle.substring(0,logTitle_MAXLENGTH);
		}
		Id nLogId;
		if(skippedQuestions.size() > 0 || qFailed.size() > 0|| skippedReplies.size() > 0)
		{
			nLogId = ca2cq_logs.newLogDetail(logId,step, logId, logTitle, String.join(logString,'\n'), true );
		}
		else
		{
			nLogId = ca2cq_logs.newLogDetail(logId,step, logId, logTitle, String.join(logString,'\n'), false );
		}



		List<String> tmpList;
		if (qSucess.size() > 0){
			tmpList = new List<String>{'OriginalId,MigratedId'};
			tmpList.addAll(qSucess);
			ca2cq_logs.convertListToCsv(nLogId, 'Questions_migrated', tmpList);
		}

		if (qFailed.size() > 0){
			tmpList = new List<String>{CSV_LOG_TITLE};
			tmpList.addAll(qFailed);
			ca2cq_logs.convertListToCsv(nLogId, 'Questions_not_migrated', tmpList);
		}

		if (skippedQuestions.size() > 0){
			tmpList = new List<String>{CSV_LOG_TITLE};
			tmpList.addAll(skippedQuestions);
			ca2cq_logs.convertListToCsv(nLogId, 'Questions_not_processed', tmpList);
		}

		if (insertedReplies.size() > 0){
			tmpList = new List<String>{'OriginalId,MigratedId'};
			tmpList.addAll(insertedReplies);
			ca2cq_logs.convertListToCsv(nLogId, 'Replies_migrated', tmpList);
		}

		if (failedReplies.size() > 0){
			tmpList = new List<String>{CSV_LOG_TITLE};
			tmpList.addAll(failedReplies);
			ca2cq_logs.convertListToCsv(nLogId, 'Replies_not_migrated', tmpList);
		}

		if (skippedReplies.size() > 0){
			tmpList = new List<String>{CSV_LOG_TITLE};
			tmpList.addAll(skippedReplies);
			ca2cq_logs.convertListToCsv(nLogId, 'Replies_not_processed', tmpList);
		}

		//updated question migrated flag for ids in questionsMigratedIds : migrated_to_cq__c
		for ( Question c : questionsMigratedIds)
		{
			c.migrated_to_cq__c = true;
		}
		upsert questionsMigratedIds;

		qSucess.clear();
		skippedQuestions.clear();
		qFailed.clear();
		insertedReplies.clear();
		failedReplies.clear();
		skippedReplies.clear();

	}

	/*
      params : Batch Step, List of Questions, List of Replies, List of DataCategoriesSelection
      return none
        Migrates questions and logs its success/errors
    */
	public static void migrateQuestions (String step, List<Question> lq, List<Reply> rpls, List<QuestionDataCategorySelection> qdcs, Map<Id,List<Vote>> mapVote ){
		List<Question> questions;
		List<FeedItem> feedElements;
		List<FeedItem> allFeedElements = new List<FeedItem>();

		Map<Id, List<FeedItem> > listBatchs = new Map<Id, List<FeedItem> >();

		Questions_Selected = 0;
		Questions_Errors = 0;
		Answers_Selected = 0;
		Answers_Errors = 0;
		Topics_Errors = 0;

		Id netId;
		Integer j ,qE ;

		map<String,String> zone2Community = ca2cq_util.chatterZoneToNetwork();
		questionsMap = new Map<Id, Question>(lq);

		/**  TRANSACTION START **/
		Savepoint sp = Database.setSavepoint();

		try{
			// GROUP  questions by community
			Integer indx = 0;
			for(Question q : lq) {

				netId = zone2Community.get(q.communityId);
				Question qu = questionsMap.get(q.Id);

				if (listBatchs.containsKey(q.communityId)) {
					feedElements = listBatchs.get(q.communityId);
				} else {
					feedElements = new List<FeedItem>();
 				}

				// If there are more than TOTAL_IMAGES_ENABLED skip this question
				if (String.isNotBlank(q.Body) &&
					( 	(! System.Test.isRunningTest()  &&
							q.Body.countMatches(CONTENT_KEYWORD) >TOTAL_IMAGES_ENABLED)
					|| (System.Test.isRunningTest() &&
							q.Body.countMatches(CONTENT_KEYWORD_TEST) >TOTAL_IMAGES_ENABLED)
					)
					){
					//skippedQuestions.add(q.Id);
					if (!skippedQuestionsPerCommunity.containsKey(q.communityId)){
						skippedQuestionsPerCommunity.put(q.communityId, new List<String>());
	 				}
					skippedQuestionsPerCommunity.get(q.communityId).add('\n'+q.Id+', Question has more than '+TOTAL_IMAGES_ENABLED+' images ');

					continue;
				}

				if (String.isNotBlank(q.Body) && q.Body.length() > FI_BodyMaxLength) {

					if (!skippedQuestionsPerCommunity.containsKey(q.communityId)){
						skippedQuestionsPerCommunity.put(q.communityId, new List<String>());
	 				}

					skippedQuestionsPerCommunity.get(q.communityId).add('\n'+q.Id+', Original question contains more than '+ FI_BodyMaxLength + ' characters and cannot be migrated (HTML tags may not be visible) Total characters: ' + q.Body.length());
					continue;

				}

				/* CONVERSION from Question to FeedItem*/
				FeedItem tmpFeed = convertQuestionToFeedItem(netId, q);
				if (tmpFeed == null) {
					if (!skippedQuestionsPerCommunity.containsKey(q.communityId)){
						skippedQuestionsPerCommunity.put(q.communityId, new List<String>());
					}
					skippedQuestionsPerCommunity.get(q.communityId).add('\n'+q.Id+', Question conversion failed ');
					continue;
				}

				if (String.isNotBlank(tmpFeed.Body) && tmpFeed.Body.length() > FI_BodyMaxLength ) {
					if (!skippedQuestionsPerCommunity.containsKey(q.communityId)){
						skippedQuestionsPerCommunity.put(q.communityId, new List<String>());
					}

					System.debug('Converted question has more than ' + FI_BodyMaxLength + ' characters and cannot be migrated.');
					skippedQuestionsPerCommunity.get(q.communityId).add('\n'+q.Id+', Converted question has more than ' + FI_BodyMaxLength + ' characters and cannot be migrated (HTML tags may not be visible).');
					continue;
				}

				String keyToCheck = netId +'-'+q.CreatedById;

				// Check if the question's community has reputation enabled
				if (getRepRules.containsKey(netId)) {
					//check if this user has a record on NetworkMember
					if (String.isNotBlank(netId) && !networkMembers.contains(keyToCheck)
						&& ! System.Test.isRunningTest()){
						if (!skippedQuestionsPerCommunity.containsKey(q.communityId)){
							skippedQuestionsPerCommunity.put(q.communityId, new List<String>());
						}
						skippedQuestionsPerCommunity.get(q.communityId).add('\n'+q.Id+', Question author has no record on NetworkMember ');
						continue;
					}
				}

				allFeedElements.add(tmpFeed);
				indx++;
				feedElements.add(tmpFeed);
				listBatchs.put(q.communityId,feedElements);
				//also add original question to map
				if (questionsByCommunity .containsKey(q.communityId)){
					questions= questionsByCommunity .get(q.communityId);
				}else{
					questions= new List<Question>();
				}
				questions.add(q);
				questionsByCommunity.put(q.communityId,questions);

				for(QuestionDataCategorySelection qdc : qdcs){
						if (qdc.ParentId == q.Id){
							dataCategoriesNames.add(qdc.DataCategoryName + ':&:' + netId);
						}
				}
			}
			List<String> logString = new List<String>();
			 if (listBatchs.isEmpty()){
				//log skipped questions
				if (!skippedQuestionsPerCommunity.isEmpty()){

					for(Id i : skippedQuestionsPerCommunity.keySet()){
						logString.add(' QUESTIONS NOT PROCESSED on '+i+' : '+ skippedQuestionsPerCommunity.get(i).size());
						logString.add(String.join(skippedQuestionsPerCommunity.get(i),','));
						Questions_Selected += skippedQuestionsPerCommunity.get(i).size();
						Questions_Errors  += skippedQuestionsPerCommunity.get(i).size();

					}
					Id nLogId;
					if(Questions_Errors > 0 )
					{
						nLogId = ca2cq_logs.newLogDetail(currentLog.Id,'No Questions processed', currentLog.Id, 'No Questions processed ', 'See Attachment for full list details' , true);
					}
					else
					{
						nLogId = ca2cq_logs.newLogDetail(currentLog.Id,'No Questions processed', currentLog.Id, 'No Questions processed ', 'See Attachment for full list details', false );
					}

					if (logString.size() > 0){
						ca2cq_logs.convertListToTxt(nLogId, 'QuestionsNotProcessedIds', logString);
					}
				}
			}else{
				//insert new topics
				logString = dataCategoriesToTopics();
				ca2cq_logs.newLogDetail(currentLog.Id,' Topics Migration', currentLog.Id, step+' DataCategories To Topics', String.join(logString,'\n') , false);
				mapAllTopics = ca2cq_util.allTopics();

				// for each community
				for (Id commId : listBatchs.keySet()){

					feedElements = listBatchs.get(commId);
					if (zone2Community.containsKey(commId)) {
						netId = zone2Community.get(commId);
					}
					if (questionsByCommunity.containsKey(commId)) {
						questions = questionsByCommunity.get(commId);
					} else {
						questions = null;
					}
					migrateQuestionsForCommunity(commId, netId, feedElements, questions, rpls, qdcs, mapVote, currentLog.Id, step);
				}
			}
		}catch (System.DmlException e){
			// An exception was caught. We need to revert back to our Savepoint
			// This will rollback all successful changes. So, if opps saved successfully
			// and then quotes failed, the opps will be rolled back as well
			system.debug('error catch: ' + e.getCause());
			Database.rollback(sp);
			String errorStr = '\n getTypeName : '+e.getTypeName()+
			'\n getCause : '+e.getCause()+
			'\n getMessage : '+e.getCause()+
			'\n getLineNumber : '+e.getLineNumber()+
			'\n getStackTraceString : '+e.getStackTraceString()+
			'\n getTypeName : '+e.getTypeName()+
			'\n getDmlMessage : '+e.getDmlMessage(0)+
			'\n getErrorMessage : '+e.getDmlType(0)+
			'\n getDmlFieldNames : '+e.getDmlFieldNames(0);
			system.debug('\n======currentLog ['+currentLog.Id+'] NOT OK'+  errorStr);
			ca2cq_logs.newLogDetail(currentLog.Id,'Batch', currentLog.Id, 'EXCEPTION ', errorStr ,true);
			newTopics.clear();
		}
		ca2cq_logs.updateLog(Questions_Selected,Answers_Selected, (Questions_Selected-Questions_Errors),(Answers_Selected-Answers_Errors), Questions_Errors,Answers_Errors);

		ca2cq_util.insertQuestionsToMigrate(bestAnswersMap);
	}

	/*
      params : none
      return list of Topics
        Returns successfully created topics
    */
	public static list<Topic> getNewTopics(){
		return newTopics;
	}


	/*
		+ (total points for questions)
		+ (total points for replies received)
		+ (total points for replies made)
		+ (total points for likes over questions/replies)
		+ (total points on selected bestAnswers as author)
		+ (total points on selected bestAnswers as selector)
		params : NetworkId, UserId, Number of questions stats
        return none
          Updates stats for reputation migration for each user
	*/
	public static void updateStats(Id netId, Id authorId, Integer tp, Integer trr, Integer trm, Integer tlr, Integer tlm, Integer tbra, Integer tbrs) {
		Map<Id,Map<String,Integer>> currentNet;
		Map<String,Integer> currentUser;

	    // Check if this community has reputation Up and running
	    Boolean reputationIsEnabled = false;

		if (reputationLivePerCommunity != null && reputationLivePerCommunity.containsKey(netId)) {
	     	Network ntk = reputationLivePerCommunity.get(netId);
	        reputationIsEnabled = ntk.OptionsReputationEnabled;
	    }

		if (!reputationIsEnabled)
            return;

		// Check for network entry
		if (pointsToMigrate.containsKey(netId)) {
			currentNet = pointsToMigrate.get(netId);
		} else {
			currentNet = new Map<Id,Map<String,Integer>>();
		}

		// Check for currentUser
		if (currentNet.containsKey(authorId)) {
			currentUser = currentNet.get(authorId);
		} else {
			currentUser = new Map<String,Integer> {
				TOTAL_QUESTIONS => 0,
				TOTAL_REPLIES_MADE => 0,
				TOTAL_REPLIES_RECEIVED => 0,
				TOTAL_LIKES_MADE => 0,
				TOTAL_LIKES_RECEIVED => 0,
				TOTAL_BA_AUTHOR => 0,
				TOTAL_BA_SELECTOR => 0
			};
		}

		// Update current user stats for given Network
		// Total questions
		Integer tmp = 0;
		tmp = currentUser.get(TOTAL_QUESTIONS);
		currentUser.put(TOTAL_QUESTIONS, tmp + tp);

		// Total replies made
		tmp = 0;
		tmp = currentUser.get(TOTAL_REPLIES_MADE);
		currentUser.put(TOTAL_REPLIES_MADE, tmp + trm);

		// Total replies received
		tmp = 0;
		tmp = currentUser.get(TOTAL_REPLIES_RECEIVED);
		currentUser.put(TOTAL_REPLIES_RECEIVED, tmp + trr);

		// Total likes made
		tmp = 0;
		tmp = currentUser.get(TOTAL_LIKES_MADE);
		currentUser.put(TOTAL_LIKES_MADE, tmp + tlm);

		// Total likes received
		tmp = 0;
		tmp = currentUser.get(TOTAL_LIKES_RECEIVED);
		currentUser.put(TOTAL_LIKES_RECEIVED, tmp + tlr);

		// Total best answers author
		tmp = 0;
		tmp = currentUser.get(TOTAL_BA_AUTHOR);
		currentUser.put(TOTAL_BA_AUTHOR, tmp + tbra);

		// Total best answers selector
		tmp = 0;
		tmp = currentUser.get(TOTAL_BA_SELECTOR);
		currentUser.put(TOTAL_BA_SELECTOR, tmp + tbrs);

		currentNet.put(authorId,currentUser);
		pointsToMigrate.put(netId,currentNet);
	}

	/*
      params : Map of user stats, reputation rules, community points, current members of the community
      return none
        Migrates questions and logs its success/errors
    */
	public static void updateReputationPoints(Map<Id, Map<Id, Map<String, Integer>>> migStats, Map<Id, Map<String, Integer>> repRules, Map<Id, Map<Id, Double>> comPoints, Map<String, NetworkMember> currentMembers) {
		if (repRules.size() == 0) {
			System.debug('No community with reputation points enabled');
			return;
		}

		// Null list to store final points
		List<NetworkMember> updatePoints = new List<NetworkMember>();

		try {
			//For each community
			for (Id comKey : repRules.keySet()) {
				// If the community has reputation enabled
				if (migStats.containsKey(comKey)) {
					// Get the stats of points to migrate
					Map<Id, Map<String, Integer>> pointsPerUser = migStats.get(comKey);

					//Get the latest user reputation points for the current community
					Map<Id, Double> thisCommunityPoints = comPoints.get(comKey);

					// For each user
					for (Id userKey : pointsPerUser.keySet()) {
						// Get current user points.
						if (thisCommunityPoints.get(userKey) != null && currentMembers.containsKey(comkey+'-'+userKey)) {
							Double currentPoints = thisCommunityPoints.get(userKey);
							Double finalPoints = 0;

							// Get specific user total stats
							Map<String, Integer> userPoints = pointsPerUser.get(userKey);
							// Get reputation rules for the communitiy
							Map<String, Integer> repRule = repRules.get(comkey);

							// Add the product of each type of element with its designed points
							finalPoints += repRule.get('FeedItemPostQuestion') * userPoints.get(TOTAL_QUESTIONS);
							finalPoints += repRule.get('FeedItemAnswerAQuestion') * userPoints.get(TOTAL_REPLIES_MADE);
							finalPoints += repRule.get('FeedItemReceiveAnAnswer') * userPoints.get(TOTAL_REPLIES_RECEIVED);
							finalPoints += repRule.get('FeedItemLikeSomething') * userPoints.get(TOTAL_LIKES_MADE);
							finalPoints += repRule.get('FeedItemReceiveALike') * userPoints.get(TOTAL_LIKES_RECEIVED);
							finalPoints += repRule.get('FeedItemYourAnswerMarkedBest') * userPoints.get(TOTAL_BA_AUTHOR);
							finalPoints += repRule.get('FeedItemMarkAnswerAsBest') * userPoints.get(TOTAL_BA_SELECTOR);

							// Finally add the calculated points with the current user points
							finalPoints += currentPoints;

							// Get user from community members Map
							NetworkMember nwM = currentMembers.get(comkey + '-' + userKey);
							// Update the user's points
							nwM.ReputationPoints =  finalPoints;
							// Update the map
							currentMembers.put(comkey+'-'+userKey, nwM);

						} else {
							System.debug('user with id: ' + userKey + ' is not part of networkMember.');
						}
					}
				}
			}
		} catch(Exception e) {
			System.debug('Exception: ' + e);
			ca2cq_logs.newLogDetail(currentLog.Id, 'Exception on reputation: ', currentLog.Id, ' - Error while trying to migrate reputation points: ', e + '\n',true);
		}

		// Add users to the networkmembers list
		for (String comKey : currentMembers.keySet()) {
			updatePoints.add(currentMembers.get(comKey));
		}

		if (updatePoints.size() > 0) {
			update updatePoints;
		}
	}

	/*
	  params : String of question, Id of feedItem, NetworkId, QuestionId
	  return List<Content_Migration__c>
		Returns the content of a tag img
	*/
	public static List<Content_Migration__c> retrieveContent(String body, Id fId, Id netId, Id qId) {
		List<Content_Migration__c> result = new List<Content_Migration__c>();
		if (String.isNotBlank(body) && body.contains('_img_')) {
	        Integer occurrences = body.countMatches('src=&quot;');
	        Integer counter = 0;

			while (counter < occurrences) {
				String attr = body.substringBetween('src=&quot;', '&quot;');

				if (!String.isEmpty(attr) && String.isNotBlank(attr)) {
					body = body.replace('src=&quot;' + attr + '&quot;', '"' + attr + '"');
				}
				counter++;
			}

			List<String> parts = body.split('_img_');
			for(String s : parts) {
				if (String.isNotBlank(s)) {
					String url = s.substringBetween('src="','"');
					system.debug('url:' + url);
					if (String.isNotBlank(url) && !url.contains('base64')) {
					 	result.add(new Content_Migration__c(Content_Reference_Url__c = url,
													        Feed_Record_Id__c = fId,
													        Network_Scope__c = netId,
													        Original_QA_record_Id__c = qId
						    )
						);
					}
				}
			}
		}

		return result;
	}
}