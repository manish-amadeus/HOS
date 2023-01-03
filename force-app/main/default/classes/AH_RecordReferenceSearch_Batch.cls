/****************************************************************************************************************************
Name            : AH_RecordReferenceSearch_Batch Class
Author          : Shashikant Nikam
Created Date    : 06/26/2019
Last Mod Date   : 07/10/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-037096
Description     : Batch class to search for the record's reference in other records & mailing the CSV to running user
                :
 ******************************************************************************************************************************/
global class AH_RecordReferenceSearch_Batch implements Database.Batchable<String>, Database.Stateful
{
	List<sObject> finalList;
	Map<Integer, List<String> > mapp = new Map<Integer, List<String> >();
	public ID inputID;
	public String timeStamp;

	// CONSTRUCTOR
	public AH_RecordReferenceSearch_Batch (Id SFID, Map<Integer, List<String> > objectToField, String timeString)
	{
		finalList = new List<sObject>();
		inputID = SFID;
		timeStamp = timeString;
		mapp  = objectToField;
	}

	// =========================== START METHOD ================================
	global Iterable<String> start(Database.BatchableContext BC)
	{
		List<String> lst = new List<String>();

		if (!mapp.isEmpty())
		{
			for (Integer cnt : mapp.keySet())
			{
				List<String> ll = mapp.get(cnt);

				String s = ll[0] + '=>' + ll[1];

				if (Test.isRunningTest() && (ll[0] == 'pse__Milestone__c' || ll[0] == 'Case'))
				{
					lst.add(s);
					break;
				}
				else if (!Test.isRunningTest())
				{
					lst.add(s);
				}
			}
		}

		return lst;
	}

	// ========================= EXECUTE METHOD ===============================
	global void execute(Database.BatchableContext BC, List<String> scope)
	{
		List<String> parts = scope[0].split('=>');

		String dbQuery = 'SELECT Id, Name FROM ' + parts[0] + ' WHERE ' + parts[1] + ' = \'' + inputID + '\'';
		List<sObject> sObjList = new List<sObject>();

		try
		{
			sObjList = Database.query(dbQuery);
		}
		catch(Exception e)
		{
			system.debug('Found exception : ' + e);

			if (e.getMessage().contains('No such column \'Name\' on entity'))
			{
				String dbQuery1 = 'SELECT ID FROM ' + parts[0] + ' WHERE ' + parts[1] + ' = \'' + inputID + '\'';
				sObjList = Database.query(dbQuery1);
			}
			else
			{
				AH_RecordReferenceSearch_Cntlr errLog = new AH_RecordReferenceSearch_Cntlr();
				errLog.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', timeStamp, 'AH_RecordReferenceSearch_Batch.execute', 'SELECT');
			}
		}

		if (!sObjList.isEmpty())
		{
			finalList.addAll(sObjList);
		}
	}

	// ========================= FINISH METHOD ===============================
	global void finish(Database.BatchableContext BC)
	{
		system.debug('In finish method..' + finalList);

		String finalstr = 'Object Name, Record Id, Record Name \n';

		try
		{
			if (!finalList.isEmpty())
			{
				// COLLECT ALL RELATED SBJECTS IN ONE LIST
				for (sObject s : finalList)
				{
					Map<String, Object> fieldsToValue = s.getPopulatedFieldsAsMap();
					String recordString = '';

					if (fieldsToValue.containsKey('Name'))
					{
						recordString = '"' + s.getSObjectType() + '","' + s.id + '","' + s.get('Name') + '"\n';
					}
					else
					{
						recordString = '"' + s.getSObjectType() + '","' + s.id + '","' + ' ' + '"\n';
					}

					if (recordString != '')
					{
						finalstr = finalstr + recordString;
					}
                    
				}

				// SEND MAIL TO RUNNING USER
				Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
				blob csvBlob = Blob.valueOf(finalstr);
				String csvname = inputID + '.csv';
				csvAttc.setFileName(csvname);
				csvAttc.setBody(csvBlob);
				String userEmailID = Userinfo.getUserEmail();
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				String[] toAddresses = new String[] {userEmailID};
				String subject = 'Records associated with ' + inputID;
				email.setSubject(subject);
				email.setToAddresses(toAddresses);
				email.setPlainTextBody('Please find the attached CSV for associated records.');
				email.setFileAttachments(new Messaging.EmailFileAttachment[] {csvAttc});
				Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
			}
			else
			{
				system.debug('There are no records to mail...');
			}

			Job_Run_History__c runHist = new Job_Run_History__c();
			runHist.Apex_Class__c = 'AH_RecordReferenceSearch_Batch';
			runHist.Status__c = 'Run';
			runHist.No_of_Items_Processed__c = finalList.size();
			runHist.Target_Object__c = '';
			runHist.User__c = UserInfo.getUserName();
			runHist.Created_Date__c = Datetime.now();
			runHist.Unique_Timestamp__c = timeStamp;
			runHist.Status_Detail__c = 'Success';

			insert runHist;
		}
		catch(Exception ex)
		{
			system.debug('Exception found in AH_RecordReferenceSearch_Batch : ' + ex + ' at line no. : ' + ex.getLineNumber());

			Job_Run_History__c runHist = new Job_Run_History__c();
			runHist.Apex_Class__c = 'AH_RecordReferenceSearch_Batch';
			runHist.Status__c = 'Run';
			runHist.Target_Object__c = '';
			runHist.User__c = UserInfo.getUserName();
			runHist.Created_Date__c = Datetime.now();
			runHist.Unique_Timestamp__c = timeStamp;
			runHist.Status_Detail__c = 'Failed';
		}
	}
}