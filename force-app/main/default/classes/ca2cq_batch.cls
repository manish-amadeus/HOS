/**
 * @author Altimetrik
 * @description :
 *		  logic for chatter questions and answers migration
 *	 started on 10/09/2014
 *
 **/
global class ca2cq_batch implements Database.Batchable<sObject>,Database.Stateful {

	global final String query;
	global ca2cq_log__c currentLog;
	global Integer  executingLevel;
	list<Topic> newTopics = new list<Topic>();
	global Map<Id, Map<Id, Map<String, Integer>>> pointsToMigrate;
	global Map<Id, Network> reputationLivePerCommunity;

	global ca2cq_batch() {
		currentLog = ca2cq_logs.getCurrentLog();
		query = ca2cq_util.resolveQuestionMigrationQuery('');
		pointsToMigrate = new Map<Id, Map<Id, Map<String, Integer>>>();
		ca2cq_util.updateExecutingLevel(1);
		executingLevel = ca2cq_util.getExecutingLevel();
	    // keep track of communities and if they track user reputation
	    // Get map of communities' OptionsReputationEnabled field
	    reputationLivePerCommunity = new Map<Id, Network>([SELECT OptionsReputationEnabled FROM Network WHERE Status ='Live']);
	}
	global ca2cq_batch(Integer n) {
		//Legacy Constructor
	}
	global ca2cq_batch(Integer n, String listOfCsvList) {
		currentLog = ca2cq_logs.getCurrentLog();
		query = ca2cq_util.resolveQuestionMigrationQuery(listOfCsvList);
		pointsToMigrate = new Map<Id, Map<Id, Map<String, Integer>>>();
		ca2cq_util.updateExecutingLevel(1);
		executingLevel = ca2cq_util.getExecutingLevel();
	    // keep track of communities and if they track user reputation
	    // Get map of communities' OptionsReputationEnabled field
	    reputationLivePerCommunity = new Map<Id, Network>([SELECT OptionsReputationEnabled FROM Network WHERE Status ='Live']);
	}

	global ca2cq_batch(String q ) {
		currentLog = ca2cq_logs.getCurrentLog();
		query = q;
		pointsToMigrate = new Map<Id, Map<Id, Map<String, Integer>>>();
		ca2cq_util.updateExecutingLevel(1);
		executingLevel = ca2cq_util.getExecutingLevel();
	    // keep track of communities and if they track user reputation
	    // Get map of communities' OptionsReputationEnabled field
	    reputationLivePerCommunity = new Map<Id, Network>([SELECT OptionsReputationEnabled FROM Network WHERE Status ='Live']);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		// Prevent previous content from intervening with current migration
		delete [SELECT Id FROM Content_Migration__c LIMIT 10000];
		Database.QueryLocator ql = Database.getQueryLocator(query);

		return ql;
	}

	global void execute(Database.BatchableContext BC, List<Question> scope) {
		if (currentLog != NULL) {
			List<Id> questionIds = new List<Id>();
			Map<ID, List<Vote>> mapVotesByParentId = new Map<ID, List<Vote>>();
			for (Question q : scope) {
				questionIds.add(q.Id);
			}
			List<Vote> listOfVote = [   SELECT id, ParentId, CreatedById, CreatedDate
						  FROM vote
						  WHERE
							  parent.type = 'Question' AND type = 'Up'
						  AND parentId in: questionIds];
		  for(Vote v : listOfVote) {
			  if(mapVotesByParentId.containsKey(v.ParentId))
			  {
				  mapVotesByParentId.get(v.ParentId).add(v);
			  }
			  else
			  {
				  List<Vote> tmpListVotes = new List<Vote>();
				  tmpListVotes.add(v);
				  mapVotesByParentId.put(v.ParentId,tmpListVotes);
			  }
		  }
			List<Reply> rpls = [SELECT Id, Body, UpVotes, CreatedById, CreatedDate, Question.CreatedById, QuestionId
								FROM Reply
								WHERE QuestionId IN: questionIds];
			List<QuestionDataCategorySelection> qdcs = [SELECT Id, DataCategoryName, ParentId
														FROM QuestionDataCategorySelection
														WHERE ParentId IN: questionIds];
			// Process records returned in query
			ca2cq_feedsHandler.pointsToMigrate = pointsToMigrate;
			ca2cq_feedsHandler.currentLog = currentLog;
			ca2cq_feedsHandler.reputationLivePerCommunity = reputationLivePerCommunity;
			ca2cq_feedsHandler.migrateQuestions(ca2cq_util.getJobStep(BC.getJobId()), scope, rpls, qdcs,mapVotesByParentId);
			newTopics = ca2cq_feedsHandler.getNewTopics();

			pointsToMigrate = ca2cq_feedsHandler.pointsToMigrate;
		}
	}

	global void finish(Database.BatchableContext BC) {
		if (currentLog != NULL) {
			ca2cq_util.createNavigationalTopics(newTopics);

			// Batch to migrate best answers
			ca2cq_bestAnswer_batch BA_batch = new ca2cq_bestAnswer_batch(pointsToMigrate);
			if (!System.Test.isRunningTest()){
				Id batchInstanceId = Database.executeBatch(BA_batch,100);
			}
		} else {
			// There was no created log. Check storage limit. Set execution level to 6 (ERROR)
			ca2cq_util.updateExecutingLevel(6);
		}
	}
}