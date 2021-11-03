/**
 * @author Altimetrik
 * @description :
 *		  logic for content migration, this scrip processes records of Content_Migration__c :
 *			Content_Reference_Url__c is the original Question/Reply src of the inline image
 *			Feed_Record_Id__c is Id of the migrated element FeedItem if the origin was a Question
 *										FeedComment if it was a Reply
 *			Original_QA_record_Id__c the original Id of the Question or Reply
 *			logic will create a ContentDocument and return the ContentDocumentId of the corresponding
 *									ContentVersion
 *	 started on 01/08/2016
 *
 **/
global class ca2cq_contentMigration implements Database.Batchable<sObject>, Database.Stateful ,Database.AllowsCallouts {

	String query;
	global ca2cq_log__c currentLog;
	global Integer  executingLevel;
	List<Content_Migration__c> contentToMigrate = new List<Content_Migration__c>();

	global ca2cq_contentMigration() {

		currentLog = ca2cq_logs.getCurrentLog ();
		query ='SELECT Content_Reference_Url__c,CreatedById,CreatedDate,Feed_Record_Id__c,Id, '+
				' Network_Scope__c,Original_QA_record_Id__c '+
				' FROM Content_Migration__c';
		if (System.Test.isRunningTest())
			query += ' Limit 10 ';
		ca2cq_util.updateExecutingLevel(4);
		executingLevel = ca2cq_util.getExecutingLevel();
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		List<Content_Migration__c> l = database.query(query);
					ca2cq_logs.logIt(' ca2cq_contentMigration start ['+executingLevel+'] == '+l.size());
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {

		try{
			ca2cq_util.processContent((List<Content_Migration__c>) scope);
			contentToMigrate.addAll((List<Content_Migration__c>) scope);
		}catch (System.Exception e){
			String errorStr = '\n getTypeName : '+e.getTypeName()+
							'\n getCause : '+e.getCause()+
							'\n getMessage : '+e.getCause()+
							'\n getLineNumber : '+e.getLineNumber()+
							'\n getStackTraceString : '+e.getStackTraceString()+
							'\n getTypeName : '+e.getTypeName();
			ca2cq_logs.newLogDetail(currentLog.Id,'Batch', currentLog.Id, 'EXCEPTION ', errorStr , true);
		}
	}

	global void finish(Database.BatchableContext BC) {
		// delete all content
		delete contentToMigrate;
		ca2cq_util.updateExecutingLevel(5);
		ca2cq_logs.closeLog();
		// send notification email
		boolean email = ca2cq_logs.sendNotification();
	}

}