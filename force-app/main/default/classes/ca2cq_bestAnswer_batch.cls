/**
 * @author Altimetrik
 * @description :
 *		  logic for chatter questions and answers migration
 *	 started on 10/09/2014
 *
 **/
global class ca2cq_bestAnswer_batch implements Database.Batchable<sObject>, Database.Stateful {

	List<ca2cq_best_answer_to_migrate__c> answersToMigrate = new List<ca2cq_best_answer_to_migrate__c>();
	global Map<Id, Map<Id, Map<String, Integer>>> pointsToMigrate;
	global ca2cq_log__c currentLog;
	global Integer  executingLevel;

	list<String> ls_succes = new list<String>();
	list<String> ls_error = new list<String>();

	global Map<Id, Network> reputationLivePerCommunity;

	Integer sizeOfAnswers = 0;
	global ca2cq_bestAnswer_batch() {
		currentLog = ca2cq_logs.getCurrentLog ();

		pointsToMigrate = new Map<Id, Map<Id, Map<String, Integer>>>();
		ca2cq_util.updateExecutingLevel(2);
		executingLevel = ca2cq_util.getExecutingLevel();

		// Keep track of communities and if they track user reputation
	    // Get map of communities' OptionsReputationEnabled field
	    reputationLivePerCommunity = new Map<Id, Network>([SELECT OptionsReputationEnabled FROM Network WHERE Status ='Live']);
	 }


	global ca2cq_bestAnswer_batch(Map<Id, Map<Id, Map<String, Integer>>> mp ) {
		currentLog = ca2cq_logs.getCurrentLog ();
		pointsToMigrate = mp;
		ca2cq_feedsHandler.pointsToMigrate = pointsToMigrate;
		ca2cq_util.updateExecutingLevel(2);
		executingLevel = ca2cq_util.getExecutingLevel();

		// Keep track of communities and if they track user reputation
	    // Get map of communities' OptionsReputationEnabled field
	    reputationLivePerCommunity = new Map<Id, Network>([SELECT OptionsReputationEnabled FROM Network WHERE Status ='Live']);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 	' SELECT Id, Feed_Item_Id__c, Feed_Comment_Id__c, Network_Id__c,'+
						' Feed_Comment_CreatedById__c, Feed_Comment_SelectedById__c'+
						' FROM ca2cq_best_answer_to_migrate__c LIMIT 10';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<ca2cq_best_answer_to_migrate__c> scope) {
		List<Id> repliesIds = new List<Id>();
		ConnectApi.QuestionAndAnswersCapabilityInput qaInput;
		ConnectApi.QuestionAndAnswersCapability qa;
		Id netId;

		ca2cq_feedsHandler.pointsToMigrate = pointsToMigrate;
		ca2cq_feedsHandler.reputationLivePerCommunity = reputationLivePerCommunity;

		answersToMigrate.addAll(scope);

		for (ca2cq_best_answer_to_migrate__c bam : scope) {
			qaInput = new ConnectApi.QuestionAndAnswersCapabilityInput();
			qaInput.bestAnswerId = bam.Feed_Comment_Id__c;
			repliesIds.add(bam.Feed_Comment_Id__c);
			netId = (bam.Network_Id__c != 'null') ? bam.Network_Id__c : null;
			try {
				qa = ConnectApi.QuestionAndAnswers.updateQuestionAndAnswers(netId, bam.Feed_Item_Id__c, qaInput);
				//update stats for user and questions
				ca2cq_feedsHandler.updateStats(netId,bam.Feed_Comment_CreatedById__c, 0,0,0,0,0,1,0);
				// update User Who Selectes BestAnswer
				ca2cq_feedsHandler.updateStats(netId,bam.Feed_Comment_SelectedById__c, 0,0,0,0,0,0,1);
				ls_succes.add(bam.Feed_Item_Id__c );
			} catch (ConnectApi.NotFoundException cnF) {
				system.debug('ConnectApi.NotFoundException: ');
				system.debug( cnF);
				ls_error.add(bam.Feed_Item_Id__c);
			} catch (Exception e) {
				system.debug('Exception ');
				system.debug(e);
				String errorStr = '\n getTypeName : '+e.getTypeName()+
								  '\n getCause : '+e.getCause()+
								  '\n getMessage : '+e.getCause()+
								  '\n getLineNumber : '+e.getLineNumber();
				system.debug(errorStr);

				ls_error.add(bam.Feed_Item_Id__c);
			}
		}

		pointsToMigrate = ca2cq_feedsHandler.pointsToMigrate;
		sizeOfAnswers += answersToMigrate.size();
		delete answersToMigrate;
		answersToMigrate.clear();
	}

	global void finish(Database.BatchableContext BC) {
		String result = ' Total Success : '+ ls_succes.size()+ ' of '+ sizeOfAnswers;
		if (ls_error.isEmpty())
			result +=  '\nNo errors processing \n';

		ID nLogId;
		if (ls_error.isEmpty())
		{
			nLogId = ca2cq_logs.newLogDetail(currentLog.Id, 'Best Answer selection', currentLog.Id, 'Best Answer selection', result, false);
		}
		else
		{
			nLogId = ca2cq_logs.newLogDetail(currentLog.Id, 'Best Answer selection', currentLog.Id, 'Best Answer selection', result, true);
		}
		ca2cq_logs.convertListToTxt(nLogId, 'BestAnswersUpdatedOk', ls_succes);
		ca2cq_logs.convertListToTxt(nLogId, 'BestAnswersNotUpdated', ls_error);

		Integer bSize  =  ca2cq_util.getBatchSize();
		if (!System.Test.isRunningTest()) {
			Id batchInstanceId = Database.executeBatch(new ca2cq_userReputation_batch(pointsToMigrate),bSize);
		}
	}
}