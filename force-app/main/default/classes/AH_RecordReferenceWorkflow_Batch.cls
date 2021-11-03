/****************************************************************************************************************************
Name            : AH_RecordReferenceWorkflow_Batch Class
Author          : Shashikant Nikam
Created Date    : 07/18/2019
Last Mod Date   : 08/09/2019
Last Mod By     : Shashikant Nikam
NICC Reference  :
Description     : Batch class to search for the matching object, field & keyword occurance in all workflows of the ORG
                :
 ******************************************************************************************************************************/

global class AH_RecordReferenceWorkflow_Batch implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts
{
	Map<String, String> finalMap;
	Map<String, String> MapOfWorflows;      // REMOVE LATER
	public List<String> flowIdNameList;
	public List<String> IdNameList = new List<String>();
	public String objectName;
	public String fieldName;
	public String keyword;
	public String crossRefFieldName;
	public Map<String, String> mapOfValidationRule;
	public String timeStamp;

	// ========================= CONSTRUCTOR =========================
	public AH_RecordReferenceWorkflow_Batch(List<String> lst, String obj, String field, String word, Map<String, String> validationMap, String timeString)
	{
		system.debug('In AH_RecordReferenceWorkflow_Batch constructor...');

		finalMap = new Map<String, String>();
		MapOfWorflows = new Map<String, String>();

		for (String s : lst)
		{
			IdNameList.add(s);
		}

		objectName = obj;
		fieldName = field;
		keyword = word;
		timeStamp = timeString;
		mapOfValidationRule = new Map<String, String>(validationMap);
		crossRefFieldName = fieldName.replace('__c', '__r');

	}

	// ========================= START METHOD =========================
	global Iterable<String> start(Database.BatchableContext BC)
	{
		return IdNameList;
	}

	// ========================= EXECUTE METHOD =========================
	global void execute(Database.BatchableContext BC, List<String> scope)
	{

		try
		{
			List<String> parts = scope[0].split('=>');
			String workflowId = parts[0];
			HttpResponse res = getHttpResponse('tooling/sobjects/workflowRule/' + workflowId);
			String responseBody = res.getBody();
			Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

			for (String ss : resultMap.keyset())
			{

				if (ss == 'Metadata')
				{
					Map<String, Object> ss1Map = (Map<String, Object>)resultMap.get(ss);
					String crossRefObjName = objectName.replace('__c', '__r');

					for (String ss1 : ss1Map.keyset())
					{
						String sss = '';

						// IF LOOP TO CHECK THE FORMULA IN WORKFLOW ONLY OBJECT NAME & FIELD NAME WILL BE CHECKED IN FORMULA
						if (ss1 == 'formula' && ss1Map.get(ss1) != null)
						{

							sss = String.valueOf(ss1Map.get(ss1));

							MapOfWorflows.put(scope[0],sss);

							if (sss.containsIgnoreCase(crossRefFieldName) || sss.containsIgnoreCase(fieldName))
							{
								sss = sss.replace(',', '');
								finalMap.put(scope[0],sss);
							}
						}
						// THIS LOOP CHECKS CRITERIA ITEMS IN WORKFLOW BJECT NAME & FIELD NAME ALONG WITH VALUE WILL BE CHECKED IN CRITERIA ITEMS
						else if (ss1 == 'criteriaItems')
						{

							List<Object> criteriaList = (List<Object>)ss1Map.get(ss1);
							sss = string.join(criteriaList,'**');
							MapOfWorflows.put(scope[0],sss);
							Boolean matchFound = false;

							for (Object criteria : criteriaList)
							{
								Map<String, Object> criteriaMap = (Map<String, Object>)criteria;

								String fName = String.valueOf(criteriaMap.get('field'));
								String val = String.valueOf(criteriaMap.get('value'));

								if (fName.containsIgnoreCase(objectName + '.' + fieldName) && val.containsIgnoreCase(keyword))
								{
									matchFound = true;
								}
							}

							if (matchFound)
							{
								sss = sss.replace(',', '');
								finalMap.put(scope[0],sss);
							}
						}
					}
				}
			}
		}
		catch(Exception e)
		{
			system.debug('Found exception AH_RecordReferenceWorkflow_Batch : ' + e + '... at line : ' + e.getLineNumber());
			AH_RecordReferenceSearch_Cntlr errLog = new AH_RecordReferenceSearch_Cntlr();
			errLog.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', timeStamp, 'Workflow Batch execute method', 'Tooling API Callout');
		}
	}

	// ========================= FINISH METHOD ==============================
	global void finish(Database.BatchableContext BC)
	{
		// CREATE CSV FILE STRING FOR VALIDATION RULES
		String vRecordString = '';

		if (!mapOfValidationRule.isEmpty())
		{
			for(String v : mapOfValidationRule.keySet())
			{
				List<String> vList = v.split('=>');
				vRecordString = '"' + vList[0] + '","' + vList[1] + '","' + 'Validation Rule' + '"\n';
			}
		}

		try
		{
			String finalstr = '';

			if (!finalMap.isEmpty())
			{

				// COLLECT ALL RELATED SOBJECTS IN ONE LIST
				for (String s : finalMap.keySet())
				{
					String value = finalMap.get(s);
					List<String> valueList = s.split('=>');
					String recordString = '"' + valueList[0] + '","' + valueList[1] + '","' + 'Workflow' + '"\n';

					if (recordString != '')
					{
						finalstr = finalstr + recordString;
					}
				}

				if (vRecordString != '')
				{
					finalstr = finalstr + vRecordString;
				}
			}
			else
			{
				system.debug('No records to export.');
			}


			// CODE TO ITERATE OVE RPROCESS BUILDER
			String queryURL = 'tooling/query?q=Select+ID+from+Flow';
			HttpResponse res = getHttpResponse(queryURL);
			String responseBody = res.getBody();
			Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
			flowIdNameList = new List<String>();

			for (String s : resultMap.keyset())
			{

				if (s == 'records')
				{
					Integer cnt = 0;
					List<Object> records = (List<Object>)resultMap.get(s);

					for (Object s1 : records)
					{
						Map<String, Object> s1Map = (Map<String, Object>)s1;
						flowIdNameList.add(String.valueOf(s1Map.get('Id')));
						cnt++;
					}
				}
			}

			if (!Test.isRunningTest())
			{
				AH_RecordReferenceProcessBldr_Batch btch = new AH_RecordReferenceProcessBldr_Batch(finalstr, flowIdNameList, objectName, fieldName, keyword, timeStamp);
				Database.executeBatch(btch,1);
			}
		}
		catch(Exception e)
		{
			system.debug('Found exception AH_RecordReferenceWorkflow_Batch : ' + e + '... at line : ' + e.getLineNumber());
			AH_RecordReferenceSearch_Cntlr errLog = new AH_RecordReferenceSearch_Cntlr();
			errLog.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', timeStamp, 'Workflow Batch finish method', '');
		}
	}

	// SEND HTTP REQUEST
	private HttpResponse getHttpResponse(String URL)
	{
		String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
		String queryURL = salesforceHost + '/services/data/v45.0/' + URL;
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setEndpoint(queryURL);
		req.setHeader('Content-type', 'application/json');
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		Http http = new Http();
		HTTPResponse resp = http.send(req);

		return resp;
	}
}