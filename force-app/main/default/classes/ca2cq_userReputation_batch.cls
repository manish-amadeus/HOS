/**
 * @author Altimetrik
 * @description :
 *		  reputation update based on migration of Q&A statistics
 *	 started on 01/08/2018
 *
 **/
global class ca2cq_userReputation_batch implements Database.Batchable<sObject>, Database.Stateful {

	global Map<Id, Map<Id, Map<String, Integer>>> pointsToMigrate;

	global ca2cq_log__c currentLog;
	global Integer  executingLevel;

	global Map<Id, Map<String, Integer>> repRules;
	global Map<Id, Map<Id, Double>> comPoints;
	global List<Id> listCommunities = new List<Id>();
	global List<Id> listMembers = new List<Id>();

	String query;

	global ca2cq_userReputation_batch(Map<Id, Map<Id, Map<String, Integer>>> mp ) {
		System.debug('-----Initialize reputation batch-----');
		// Get stats
		pointsToMigrate = mp;
		// Get rules per community
		repRules = ca2cq_util.getCommunitiesPointRules();
		// Get users points per community
		comPoints = ca2cq_util.getUserPointsPerCommunity();

		listCommunities = new List<Id>();
		listMembers = new List<Id>();
		system.debug('THE FINAL POINTS TO MIGRATE IS: ' + pointsToMigrate);
		// For each community and user that generated stats
    	for (Id comKey : pointsToMigrate.keySet()) {
			// Add community Id to the list
			listCommunities.add(comKey);
        	Map<Id, Map<String, Integer>> userMap = pointsToMigrate.get(comKey);

			for (Id memKey : userMap.keySet()) {
				// Add user Id to the list
				listMembers.add(memKey);
			}
    	}

		currentLog = ca2cq_logs.getCurrentLog();
		ca2cq_logs.logIt(' ca2cq_userReputation_batch create ['+executingLevel+']');
		ca2cq_util.updateExecutingLevel(3);

		query = 'SELECT Id, MemberId, NetworkId FROM NetworkMember WHERE MemberId IN: listMembers  AND NetworkId IN: listCommunities';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		ca2cq_logs.logIt(' ca2cq_userReputation_batch start ['+executingLevel+']');
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<NetworkMember> scope) {
		ca2cq_logs.logIt(' ca2cq_userReputation_batch execute ['+executingLevel+']');
		// For each networkmember in the list create a map of community Id and user Id to process the reputation.
		Map<String, NetworkMember> membersToMigrate = new Map<String, NetworkMember>();

		for (NetworkMember auxNm : scope) {
			membersToMigrate.put(auxNm.NetworkId + '-' + auxNm.MemberId, auxNm);
		}

		// Migrate reputation points.
		try {
			ca2cq_feedsHandler.currentLog = currentLog;
			ca2cq_feedsHandler.updateReputationPoints(pointsToMigrate, repRules, comPoints, membersToMigrate);
		} catch (Exception e) {
			ca2cq_logs.newLogDetail(currentLog.Id,'Exception on Reputation Migration ', currentLog.Id, 'Reputation Migration error ', e + ' Line: ' + e.getLineNumber(), true );
		}
	}

	global void finish(Database.BatchableContext BC) {
		List<String> dbL = reputationToCsv(pointsToMigrate);
		if (!System.Test.isRunningTest()){
			Id nLogId = ca2cq_logs.newLogDetail(currentLog.Id,'Reputation Migration', currentLog.Id, 'Reputation Migration  array ', 'See Attachment for full list details' , false );
			ca2cq_logs.convertListToCsv(nLogId, 'ReputationMigration', dbL);

			Id batchInstanceId = Database.executeBatch(new ca2cq_contentMigration(),100);
			ca2cq_logs.logIt(' ca2cq_userReputation_batch finish ['+executingLevel+'] next is '+batchInstanceId);
		}
	}

	private static List<String> reputationToCsv (Map<Id, Map<Id, Map<String, Integer>>> pt ){
		List<String> result  = new List<String>();

		List<Id> comIds = new List<Id>();
		for(Id netId : pt.keySet()){
			comIds.add(netId);
		}

		Map<Id, Network> nws = new Map<Id, Network>([SELECT Id, Name FROM NETWORK WHERE Id IN: comIds]);

		String csvTitle = 'NetworkName,NetworkId,AuthorId';

		String csvStartRow = '';
		String csvRow = '';
		List<String> csvRows = new List<String>();
		Boolean titleDone = false;
		for(Id netId : pt.keySet()){
			Network thisNW = nws.get(netId);
			Map<Id, Map<String, Integer>> thisNet = pt.get(netId);

			if (thisNw != null) {
				csvStartRow = '\n'+thisNW.Name+','+thisNW.Id;
			} else {
				csvStartRow = '\nInternal,'+netId;
			}

			for(Id authorId : thisNet.keySet()){
				csvRow = csvStartRow +','+authorId;
				Map<String, Integer> thisAuthor = thisNet.get(authorId);
				for(String key : thisAuthor.keySet()){
					if (!titleDone) csvTitle +=','+key;
					csvRow += ','+thisAuthor.get(key);
				}
				csvRows.add(csvRow);
				titleDone = true;
			}
		}
		result.add(csvTitle);
		result.addAll(csvRows);
		return result;
	}
}