/**
* @author Altimetrik
* @description
*	started on 10/08/2014
*	reposible for creation, deletion and update of logs
**/
public with sharing class ca2cq_logs {
	/*
	* @description
	*	Created new log to detail execution
	* @return boolean
	*/
	public static boolean newLog(String n){
		ca2cq_log__c l = new ca2cq_log__c();
		l.Name = 'for year '+n;
		l.Questions_Selected__c = 0;
		l.Questions_Migrated__c = 0;
		l.Errors_on_Questions__c = 0;

		l.Answers_Selected__c = 0;
		l.Answers_Migrated__c = 0;
		l.Errors_on_Answers__c = 0;

		l.Start_Date__c = System.now();

		try{
			insert l;
		}catch(Exception e){
			return false;
		}

		return true;
	}
	public static boolean newLog(){
		ca2cq_log__c l = new ca2cq_log__c();

		l.Questions_Selected__c = 0;
		l.Questions_Migrated__c = 0;
		l.Errors_on_Questions__c = 0;

		l.Answers_Selected__c = 0;
		l.Answers_Migrated__c = 0;
		l.Errors_on_Answers__c = 0;

		l.Start_Date__c = System.now();

		try{
			insert l;
		}catch(Exception e){
			return false;
		}

		return true;
	}


	/*
	* @description
	*	Return last open log record or an instance if there's none
	* @return ca2cq_log__c
	*/
	public static ca2cq_log__c getLastLog (Boolean closed){

		ca2cq_log__c result;
		String dqQuery = 'SELECT  Id ,Questions_Migrated__c , Answers_Migrated__c ,Questions_Selected__c, ' +
						' Answers_Selected__c,Start_Date__c, End_Date__c,' +
						' Errors_on_Questions__c,Errors_on_Answers__c' +
						' FROM ca2cq_log__c ' ;
				dqQuery += (closed) ? '  WHERE End_Date__c != null '  : '  WHERE End_Date__c = null ' ;
				dqQuery += ' ORDER By createdDate DESC ' +
						' limit 1' ;

		list<ca2cq_log__c> lLogs = database.query(dqQuery);
		if (lLogs.isEmpty()){
			ca2cq_log__c l = new ca2cq_log__c();
				l.Questions_Selected__c = 0;
				l.Questions_Migrated__c = 0;
				l.Errors_on_Questions__c = 0;
				l.Answers_Selected__c = 0;
				l.Answers_Migrated__c = 0;
				l.Errors_on_Answers__c = 0;

			result = l;
		}
		else
			result = lLogs[0];

		return result;
	}

	/*
	* @description
	*	Return Current open log record or null if there's none
	* @return ca2cq_log__c
	*/
	public static ca2cq_log__c getCurrentLog (){
		ca2cq_log__c  result  = getLastLog(false);

		if (result.Id == null)
			return null;
		else
			return result;
	}

	/*
	* @description
	*	Updates current log with stats
	* @return boolean
	*/
	public static boolean updateLog(Integer qS, Integer ab, Integer qM, Integer aM, Integer qE,Integer aE ){
		boolean result = true ;
		ca2cq_log__c  lLogs = getCurrentLog();

		if ( lLogs != null ){
			lLogs.Questions_Selected__c  = qS + lLogs.Questions_Selected__c;
			lLogs.Questions_Migrated__c = qM + lLogs.Questions_Migrated__c;
			lLogs.Errors_on_Questions__c = qE + lLogs.Errors_on_Questions__c;
			lLogs.Answers_Selected__c	= ab + lLogs.Answers_Selected__c;
			lLogs.Answers_Migrated__c	= aM + lLogs.Answers_Migrated__c;
			lLogs.Errors_on_Answers__c   = aE + lLogs.Errors_on_Answers__c;

			try{
				update lLogs;
			}catch(Exception e){
				result = false;
			}
		}
		return result;
	}

	/*
	* @description
	*	Creates a new log detail for a community and relate's it to the current log record
	* @return Id
	*/
	public static ID newLogDetail(Id logId,String objType, String objId, String errType, String message, Boolean withErrors ){

		Integer logBody_MAXLENGTH = Schema.SObjectType.ca2cq_log_detail__c.fields.Error_Message__c.getLength();

		ca2cq_log_detail__c ld = new ca2cq_log_detail__c();
		//Double percentage = (Limits.getHeapSize() * 100) / Limits.getLimitHeapSize(); '[HEAP:'+ percentage + ' %]\n'+
		String logBody = message;

		list<ca2cq_log__c> lLogs = [	SELECT  Id
										FROM ca2cq_log__c
										WHERE Id =: logId
										ORDER By createdDate DESC
										limit 1];
		if (!lLogs.isEmpty()){


			ld.migration_log__c = lLogs[0].Id;
			ld.name = errType;
			ld.With_Errors__c = withErrors;
			ld.Error_Type_Name__c = errType;
			if (logBody.length() < logBody_MAXLENGTH)
				ld.Error_Message__c = logBody;
			else
				ld.Error_Message__c = 'Body exceeded maximum lenght of : '+logBody_MAXLENGTH+' see attachment list for full details.';

			ld.Parent_Id__c = objId;
			ld.Object_Type__c = objType;

			insert ld;
		}

		if (logBody.length() >= logBody_MAXLENGTH){
			// body on attachment
			Id nAttId = ca2cq_logs.convertListToTxt(ld.Id, 'Execution Log Body'+ld.Id,new List<String> {message});
		}

		return ld.Id;

	}

	/*
	* @description
	*	Updates the end date of the current log record
	* @return Id
	*/
	public static boolean closeLog( ){
		Boolean result = true;
		try{

			ca2cq_log__c  currentLog = getCurrentLog();
			if ( currentLog.Id != null ){
				currentLog.End_Date__c = System.now();
				update currentLog;
			}

			//update setting
			ca2cq_config__c setting = ca2cq_config__c.getInstance(ca2cq_util.CONFIG_NAME);

			if (String.isNotBlank(setting.Last_Batch_Id__c )){

				List<AsyncApexJob> currentJ =   [   SELECT CompletedDate
													FROM AsyncApexJob
													WHERE Id =: setting.Last_Batch_Id__c
												];
				if (!currentJ.isEmpty()){
					setting.Last_processed_date__c = currentJ[0].CompletedDate;
					update setting;
				}
			}
		}catch(Exception e){
			result = false;
		}

		return result;
	}

	/*
	* @description
	*	Send email with information from last log record
	* @return boolean
	*/
	public static boolean sendNotification(){
		Boolean result = true;
		ca2cq_config__c obj = ca2cq_util.getAppSettings();

		list<ca2cq_log__c> lLogs = [	SELECT Id , Questions_Selected__c, Answers_Selected__c ,
													Questions_Migrated__c, Answers_Migrated__c,
													Errors_on_Questions__c, Errors_on_Answers__c,
													Start_Date__c, End_Date__c
					FROM ca2cq_log__c
					ORDER By createdDate DESC limit 1];

		if (lLogs.isEmpty() || !String.isNotBlank(obj.Notification_email__c))
						return false;

		try{
			String mailSubject = ' Migration Log : ' + lLogs[0].Id;
			String mailBody = 'NL******************NL'+
				'NL Start_Date__c :'+lLogs[0].Start_Date__c+
				'NL End_Date__c :'+lLogs[0].End_Date__c+
				'NL Questions_Selected__c :'+lLogs[0].Questions_Selected__c+
				'NL Questions_Migrated__c :'+lLogs[0].Questions_Migrated__c+
				'NL Errors_on_Questions__c :'+lLogs[0].Errors_on_Questions__c+
				'NL Answers_Selected__c :'+lLogs[0].Answers_Selected__c+
				'NL Answers_Migrated__c :'+lLogs[0].Answers_Migrated__c+
				'NL Errors_on_Answers__c :'+lLogs[0].Errors_on_Answers__c+
				'NLNL ******************'+
				'NL log details : '+URL.getSalesforceBaseUrl().toExternalForm() + '/' + lLogs[0].Id+
				'NL******************NL';
			//write email
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			// Strings to hold the email addresses to which you are sending the email.
			String[] toAddresses = new String[] {obj.Notification_email__c};
			// Assign the addresses for the To and CC lists to the mail object.
			mail.setToAddresses(toAddresses);
			// Specify the address used when the recipients reply to the email.
			mail.setReplyTo(obj.Notification_email__c);
			// Specify the name used as the display name.
			mail.setSenderDisplayName('Migration tool notifier');
			// Specify the subject line for your email address.
			mail.setSubject(mailSubject);
			// Set to True if you want to BCC yourself on the email.
			mail.setBccSender(false);
			// Optionally append the salesforce.com email signature to the email.
			// The email address of the user executing the Apex Code will be used.
			mail.setUseSignature(false);
			// Specify the text content of the email.
			mail.setPlainTextBody(mailBody.replaceAll('NL','\'\\n'));
			mail.setHtmlBody(mailBody.replaceAll('NL','<br>'));

			// Send the email you have created.
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}catch( EmailException eEx){
			result = false;
		}

		return result;

	}


	public static void logIt (String content){
		system.debug('\n\n LOG CONTENT ===== : '+content);
	}


	public static Id convertListToTxt(Id parentId, String attName, List<String> items){

		Id result;
		if (!items.isEmpty()){
			result = createAttachment(parentId, attName + '.txt',String.join(items, ','), 'text/plain');
		}
		return result;
	}

	public static Id convertListToCsv(Id parentId, String attName, List<String> items){

		Id result;

		if (!items.isEmpty()){
			result = createAttachment(parentId, attName + '.csv',String.join(items, ','), 'text/csv');
		}
		return result;
	}

	public static Id createAttachment(Id parentId, String attName, String body, String contentType){

		Id result;
		try {
			/*ContentVersion v = new ContentVersion(
					Title = attName,
					VersionData = Blob.valueOf(body),
					Description = attName,
					PathOnClient = '/'+attName
			);
			insert v;

			ContentDocumentLink cdl = new ContentDocumentLink(
					ContentDocumentId = v.ContentDocumentId,
					LinkedEntityId = parentId
			);
			insert cdl;
			return cdl.Id;*/


			//-----------------------------------------------------
			Attachment newAttach;
			Blob csvBlob = Blob.valueOf(body);
			newAttach = new Attachment(Body = csvBlob,
										Name = attName,
										parentId = parentId,
										ContentType = contentType);
			insert newAttach;
			result = newAttach.Id;
		}catch (Exception e ){
		}

		return result;
	}
}