/****************************************************************************************
Name            : AH_RecordReferenceSearch_Cntlr Class
Author          : Shashikant Nikam
Created Date    : 06/26/2019
Last Mod Date   : 12/12/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-037096
Description     : Controller for AH_searchRecordReference VF page
                :
******************************************************************************************/
public class AH_RecordReferenceSearch_Cntlr
{
	public ID inputSFId {get; set;}
	public ID replacementSFId {get; set;}
	public String sObjectName {get; set;}
	public List<Schema.SObjectType> objectNamesList {get; set;}
	public Map<Integer, List<String>> objectToField {get; set;}
	public Set<String> stdObjects;
	public ID searchBatchID {get; set;}
	public ID replaceBatchID {get; set;}
	public ID setupSearchBatchID {get; set;}
	public AsyncApexJob searchBatchJob {get; set;}
	public AsyncApexJob replaceBatchJob {get; set;}
	public AsyncApexJob setupSearchBatchJob {get; set;}
	public String uniqueString;
	public String uniqueString1;
	public String uniqueString2;
	public List<runHistory> runHistoryList {get; set;}
	public Boolean showResult {get; set;}
	public Boolean showReplaceResult {get; set;}
	public List<NI_Admin_Error_Log__c> errorLogsList {get; set;}
	public List<errorLogWrapper> errorWrapList {get; set;}
	public List<String> workFlowIdNameList;

	// ============================================================================== //
	public String inputObjName {get; set;}
	public String inputKeyword {get; set;}
	public String sObjectName1;

	public Map <String, Schema.SObjectType> schemaMap {get; set;}
	public String selectedField {get; set;}
	public List<String> matchedObjList {get; set;}
	public List<String> fieldsList = new List<String>();
	public List<SelectOption> fieldsOptionsList {get; set;}

	public Map<String, String> mapOfValidationRule = new Map<String, String>();
	public String crossRefFieldName;
	// ============================================================================== //

    public AsyncApexJob updateBatchJob {get; set;}
    public Map<Integer, List<String>> queryResult {get; set;}
	//public List<List<String>> queryAndResult {get; set;}
    private Map<String, Integer> initialRecordsCount;
    private Boolean initRecCountFlag;
    //public Static Integer totalCount {get; set;}
    
	// CONSTRUCTOR
	public AH_RecordReferenceSearch_Cntlr()
	{
		system.debug('In constructor..' + sObjectName);
		//inputSFId = 'a2K0q000000V2fK';	// REMOVE LATER

		stdObjects = new Set<String>();
		stdObjects.add('ActivityHistory');
		stdObjects.add('AttachedContentDocument');
		stdObjects.add('CollaborationGroupRecord');
		stdObjects.add('CombinedAttachment');
		stdObjects.add('ContactRequest');
		stdObjects.add('ContentDistribution');
		stdObjects.add('ContentDocumentLink');
		stdObjects.add('ContentVersion');
		stdObjects.add('DuplicateRecordItem');
		stdObjects.add('EntitySubscription');
		stdObjects.add('EventChangeEvent');
		stdObjects.add('EventRelationChangeEvent');
		stdObjects.add('FeedComment');
		stdObjects.add('FeedItem');
		stdObjects.add('FlowRecordRelation');
		stdObjects.add('NI_Project_Backlog__c_hd');
		stdObjects.add('NetworkActivityAudit');
		stdObjects.add('NetworkUserHistoryRecent');
        stdObjects.add('NoteAndAttachment');
		stdObjects.add('OpenActivity');
		stdObjects.add('Opportunity__hd');
		stdObjects.add('ProcessInstance');
		stdObjects.add('ProcessInstanceHistory');
		stdObjects.add('RecordActionHistory');
		stdObjects.add('TaskChangeEvent');
		stdObjects.add('TopicAssignment');
		stdObjects.add('OutgoingEmail');

        //stdObjects.add('RecordAction');
		//stdObjects.add('Note');
		//stdObjects.add('Attachment');
		//stdObjects.add('Event');
        //stdObjects.add('Task');
		

		schemaMap = Schema.getGlobalDescribe();
		fieldsOptionsList = new List<SelectOption>();
		fieldsOptionsList.add(new SelectOption('--Select--','--Select--'));
		
        initialRecordsCount = new Map<String, Integer>();
        initRecCountFlag = false;
	}

	// METHOD TO FIDN THE RECORD'S REFERENCES
	public void findReferences()
	{
		system.debug('In findReference..' + sObjectName);

		if (inputSFId != null)
		{
			system.debug('inputSFId : ' + inputSFId);

			sObjectName = inputSFId.getSObjectType().getDescribe().getName();
			system.debug('sObjectName : ' + sObjectName);

			String objName = sObjectName.replace('__c', '__');

			stdObjects.add(objName + 'Feed');
			stdObjects.add(objName + 'Tag');
			stdObjects.add(objName + 'History');
			stdObjects.add(objName + 'Share');
			stdObjects.add(objName + 'feed');
			stdObjects.add(objName + 'tag');
			stdObjects.add(objName + 'history');
			stdObjects.add(objName + 'share');
			stdObjects.add(objName + 'changeevent');
			stdObjects.add(objName + 'ChangeEvent');

			for (String s : stdObjects)
			{
				//system.debug('SSSS : ' + s);
			}

			objectNamesList = new List<Schema.SObjectType>();
			Schema.SObjectType sobjectType =  inputSFId.getSObjectType();
			Schema.DescribeSObjectResult describe = sobjectType.getDescribe();

			objectToField = new Map<Integer,List<String> >();

			Integer cnt = 1;
			for (Schema.ChildRelationship child : describe.getChildRelationships())
			{
				objectNamesList.add(child.getChildSObject());

				Pattern MyPattern = Pattern.compile('(.*?)(tag|history|feed|changeevent|Tag|History|Feed|Changeevent|ChangeEvent|share|Share)$');
				Matcher MyMatcher = MyPattern.matcher(String.valueOf(child.getChildSObject()));

				if (!MyMatcher.matches())
				{
					List<String> lst = new List<String>();
					if (!stdObjects.contains(String.valueOf(child.getChildSObject())))
					{
						lst.add(String.valueOf(child.getChildSObject()));
						lst.add(String.valueOf(child.getField()));
						objectToField.put(cnt, lst);
						system.debug(child.getChildSObject() + '.' + child.getField() + ' - ' + child.getRelationshipName());
					}
					cnt++;
				}
			}

			//system.debug('objectToField Map : ' + objectToField);
		}
        //getExportRecordResult();
	}

	// METHOD TO CALL THE BATCH - "AH_RecordReferenceSearch_Batch"
	public void exportRecords()
	{
		//system.debug('in export records objectToField Map :' + objectToField);

		if (inputSFId != null && objectToField != null && !objectToField.isEmpty())
		{
			// GERNERATE UNIQUE TIMESTAMP TO TRACK BATCH JOB EXECUTION RESULT
			DateTime myDateTime1 = DateTime.now();
			String s = myDateTime1.format();
			Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(s));
			uniqueString = EncodingUtil.convertToHex(hash).substring(0,30);

            // CALL BATCH TO EXPORT THE REFERENCE RECORDS TO CSV & MAIL TO RUNNING USER
			AH_RecordReferenceSearch_Batch batch = new AH_RecordReferenceSearch_Batch(inputSFId, objectToField, uniqueString);
			searchBatchID = Database.executeBatch(batch, 1);
			system.debug('searchBatchID : ' + searchBatchID);

			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info,  'Batch Job to export the referenced records has been started. \nPlease use Refresh button to check the Status.'));

			// FLAG TO SHOW EXPORTED RECORDS RESULT
			showResult = true;
		}
		else
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,  'Either Input SF ID is missing OR user has not submitted the query'));
		}
	}

    
	// METHOD TO CALL THE BATCH - "AH_RecordReferenceReplace_Batch"
	public void replaceReferences()
	{
		system.debug('replacementSFId : ==' + replacementSFId + '==');
		if ( inputSFId != null && replacementSFId != null && objectToField != null && !objectToField.isEmpty() )
		{
			// GERNERATE UNIQUE TIMESTAMP TO TRACK BATCH JOB EXECUTION RESULT
			DateTime myDateTime1 = DateTime.now();
			String s = myDateTime1.format();
			Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(s));
			uniqueString1 = EncodingUtil.convertToHex(hash).substring(0,30);

            system.debug('objectToField size : '+objectToField.size());
            for(Integer k: objectToField.keySet())
            {
                //system.debug(k +' => '+objectToField.get(k));
            }
            
			// BATCH TO REPLACE THE SF ID
			AH_RecordReferenceReplace_Batch batch = new AH_RecordReferenceReplace_Batch(inputSFId, replacementSFId, objectToField, uniqueString1);
			replaceBatchID = Database.executeBatch(batch, 1);
			system.debug('replaceBatchID : ' + replaceBatchID);

			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info,  'Batch Job to replace the SF ID has been started. \nPlease use Refresh button to check the Status.'));

			// FLAG TO SHOW REPLACE RECORDS REFERENCE RESULT
			showReplaceResult = true;
		}
		else
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,  'Either Input SF ID OR Replacement SF ID is missing OR user has not submitted the query'));
		}
	}

	// METHOD TO GET THE RESULT OF BATCH JOBS
	public void getExportRecordResult()
	{
        queryResult = new Map<Integer, List<String>>();
        //queryAndResult = new List<List<String>>();
		String dbQuery2 = '';
        Integer i = 1;
        for(Integer k: objectToField.keySet())
        {
            try {
                system.debug(k +' => '+objectToField.get(k));
                List<String> parts = objectToField.get(k);
                String dbQuery1 = 'SELECT count() FROM '+parts[0]+' WHERE '+parts[1]+' = \''+ inputSFId +'\'';
                Integer earlierCount = 0;
                earlierCount = Database.countQuery(dbQuery1);
                system.debug('sObjList1 size : '+earlierCount);
                
                if(!initRecCountFlag)
                {
                    initialRecordsCount.put(parts[0]+'__'+parts[1], earlierCount);
                }
                
                List<sObject> sObjList2 = new List<sObject>();
                dbQuery2 = '';
                Integer laterCount = 0;
                
                dbQuery2 = 'SELECT count() FROM '+parts[0]+' WHERE '+parts[1]+' = \''+ replacementSFId +'\'';
                laterCount = Database.countQuery(dbQuery2);
                system.debug('sObjList2 size : '+laterCount);

                List<String> details = new List<String>();
                details.add(parts[0]);
                details.add(parts[1]);
                details.add(String.valueOf(initialRecordsCount.get(parts[0]+'__'+parts[1])));
                details.add(String.valueOf(earlierCount));
                details.add(String.valueOf(laterCount));
                
                queryResult.put(i,details);
                i++;
            }
            catch(Exception e)
            {
                system.debug('Exception found : '+e);
                system.debug('Found exception : ' + e.getLineNumber());
                system.debug('dbQuery2   :'+dbQuery2);
            }
        }
        
        initRecCountFlag = true;
        
		runHistoryList = new List<runHistory>();

		if (searchBatchID != null)
		{
			searchBatchJob = [SELECT Status, NumberOfErrors FROM AsyncApexJob WHERE Id =: searchBatchID];
			system.debug('searchBatchJob : ' + searchBatchJob);
			system.debug('uniqueString in refresh : ' + uniqueString);

			try
			{
				for (Job_Run_History__c r : [SELECT ID, Apex_Class__c, Created_Date__c, Status__c,
				                             Target_Object__c, CreatedBy.Name, Status_Detail__c, No_of_Items_Processed__c
				                             FROM Job_Run_History__c
				                             WHERE Unique_Timestamp__c = : uniqueString])
				{
					runHistory ap = new runHistory();
					ap.Apex_Class = r.Apex_Class__c;
					ap.user = r.CreatedBy.Name;
					ap.Status = r.Status__c;
					ap.Status_Detail = r.Status_Detail__c;
					ap.No_of_Items_Processed = Integer.valueOf(r.No_of_Items_Processed__c);

					Datetime dt = r.Created_Date__c;
					ap.CreatedDate = dt.format('M/dd/yyyy h:mm a');
					ap.Target_Object = r.Target_Object__c;

					runHistoryList.add(ap);
				}
			}
			catch(Exception e)
			{
				system.debug('Found exception : ' + e);
			}
		}

		if (uniqueString1 != null && replaceBatchID != null)
		{
			replaceBatchJob = [SELECT Id, ApexClassId,ApexClass.Name, CreatedById,CreatedDate,Status, NumberOfErrors, JobItemsProcessed,TotalJobItems 
                               FROM AsyncApexJob WHERE Id =: replaceBatchID];
			system.debug('replaceBatchJob : ' + replaceBatchJob);
            
            Id userId = UserInfo.getUserId();
            
            if(!Test.isRunningTest())
            {
                updateBatchJob = [SELECT Id, ApexClassId,ApexClass.Name, CreatedById,CreatedDate,Status,NumberOfErrors,JobItemsProcessed,TotalJobItems 
                                  FROM AsyncApexJob WHERE ApexClass.Name = 'AH_RecordReferenceUpdate_Batch' 
                                  AND CreatedById =: userId ORDER BY CreatedDate DESC LIMIT 1];
                system.debug('updateBatchJob : ' + updateBatchJob);
            }
			try
			{
				for (Job_Run_History__c r : [SELECT ID, Apex_Class__c, Created_Date__c, Status__c,
				                             Target_Object__c, CreatedBy.Name, Status_Detail__c, No_of_Items_Processed__c
				                             FROM Job_Run_History__c
				                             WHERE Unique_Timestamp__c =: uniqueString1])
				{
					runHistory ap = new runHistory();
					ap.Apex_Class = r.Apex_Class__c;
					ap.user = r.CreatedBy.Name;
					ap.Status = r.Status__c;
					ap.Status_Detail = r.Status_Detail__c;
					ap.No_of_Items_Processed = Integer.valueOf(r.No_of_Items_Processed__c);

					Datetime dt = r.Created_Date__c;
					ap.CreatedDate = dt.format('M/dd/yyyy h:mm a');
					ap.Target_Object = r.Target_Object__c;

					runHistoryList.add(ap);
				}
			}
			catch (Exception e)
			{
				system.debug('Found exception : ' + e);
			}
		}

		if (uniqueString2 != null && setupSearchBatchID != null)
		{
			setupSearchBatchJob = [SELECT Status, NumberOfErrors FROM AsyncApexJob WHERE Id =: setupSearchBatchID];
			system.debug('setupSearchBatchJob : ' + setupSearchBatchJob);

			try
			{
				for (Job_Run_History__c r : [SELECT Id, Apex_Class__c, Created_Date__c, Status__c,
				                             Target_Object__c, CreatedBy.Name, Status_Detail__c, No_of_Items_Processed__c
				                             FROM Job_Run_History__c
				                             WHERE Unique_Timestamp__c = : uniqueString2])
				{
					runHistory ap = new runHistory();
					ap.Apex_Class = r.Apex_Class__c;
					ap.user = r.CreatedBy.Name;
					ap.Status = r.Status__c;
					ap.Status_Detail = r.Status_Detail__c;
					ap.No_of_Items_Processed = Integer.valueOf(r.No_of_Items_Processed__c);

					Datetime dt = r.Created_Date__c;
					ap.CreatedDate = dt.format('M/dd/yyyy h:mm a');
					ap.Target_Object = r.Target_Object__c;

					runHistoryList.add(ap);
				}
			}
			catch(Exception e)
			{
				system.debug('Found exception : ' + e);
			}
		}

		system.debug('runHistoryList size : ' + runHistoryList.size());

		getErrorLogsList();
		system.debug('errorWrapList size : ' + errorWrapList.size());
	}

	// METHOD TO CREATE THE ERROR LOGS
	public void WriteToLog(String error, String obj, String className, String dml)
	{
		Id RecordTypeId = Schema.SObjectType.NI_Admin_Error_Log__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
		NI_Error_Logger.WriteToLog(error, obj, className, dml, UserInfo.getUserId(), RecordTypeId);
		getErrorLogsList();
	}

	private void getErrorLogsList()
	{
		system.debug(' *** ENTERING getErrorLogsList() - QUERIES ISSUED = ' + Limits.getQueries());

		errorLogsList = new List<NI_Admin_Error_Log__c>();

		List<String> objectNames = new List<String> {
			uniqueString,
			uniqueString1,
			uniqueString2
		};

		//Date dCreatedDate = system.today().addDays(-2);

		try
		{
			errorLogsList = [SELECT Id,
			                 Name,
			                 Apex_Class_Name__c,
			                 DML_Type__c,
			                 Message__c,
			                 Object_Name__c,
			                 CreatedBy.Name,
			                 CreatedDate
			                 FROM NI_Admin_Error_Log__c
			                 WHERE Object_Name__c IN : objectNames
			                 //AND CreatedDate > : dCreatedDate
			                 AND Object_Name__c != null
			                 ORDER BY createdDate DESC
			];

			errorWrapList = new List<errorLogWrapper>();

			if (!errorLogsList.isEmpty())
			{
				for (NI_Admin_Error_Log__c err : errorLogsList)
				{
					errorLogWrapper e = new errorLogWrapper();
					e.errorId = err.id;
					e.Name = err.Name;
					e.Object_Name = err.Object_Name__c;
					e.Apex_Class_Name = err.Apex_Class_Name__c;
					e.DML_Type = err.DML_Type__c;
					e.Message = err.Message__c;
					e.CreatedByName = err.CreatedBy.Name;

					Datetime dt = err.CreatedDate;
					e.CreatedDate = dt.format('M/dd/yyyy h:mm a');
					errorWrapList.add(e);
				}
			}
		}
		catch(Exception e)
		{
			system.debug(' **** Error Occurred: ' + e.getMessage());
			WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'NI_Admin_Error_Log__c', 'AH_RecordReferenceSearch_Cntlr.getErrorLogsList', 'SELECT');
		}

		system.debug(' **** errorWrapList = ' + errorWrapList);
		system.debug(' *** EXITING getErrorLogsList() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	// SEARCH OBJECT NAME
	public void SearchObject()
	{
		fieldsOptionsList = new List<SelectOption>();
		fieldsOptionsList.add(new SelectOption('--Select--','--Select--'));
		fieldsList = new List<String>();

		String queryURL = 'sobjects';

		system.debug('inputObjName : ' + inputObjName);
		system.debug(schemaMap.size());

		if(inputObjName != null && inputObjName != '')
		{
			Set<String> keys = schemaMap.keySet();
			system.debug('Keyt set size : ' + keys.size());

			matchedObjList = new List<String>();

			for(String objName : keys)
			{
				Pattern MyPattern = Pattern.compile('(.*?)(tag|history|feed|changeevent|Tag|History|Feed|Changeevent|ChangeEvent|share|Share)$');
				Matcher MyMatcher = MyPattern.matcher(objName);

				if(!MyMatcher.matches() && objName.containsIgnoreCase(inputObjName))
				{
					matchedObjList.add(objName);
				}
			}

			system.debug('matchedObjList size : ' + matchedObjList.size());
			system.debug('matchedObjList : ' + matchedObjList);
		}
		else
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,  'Please enter some value & then click \'Search Object\' button.'));
		}
	}

	// METHOD TO RETRIEVE FIELDS FROM SELECTED OBJECT
	public void retrieveAllFields()
	{
		fieldsOptionsList = new List<SelectOption>();
		fieldsOptionsList.add(new SelectOption('--Select--','--Select--'));
		fieldsList = new List<String>();
		sObjectName1 = ApexPages.currentPage().getParameters().get('id');
		system.debug('Selected Value : ' + ApexPages.currentPage().getParameters().get('id'));

		// RETRIEVE USING METADATA API CALL
		String queryURL = 'sobjects/' + sObjectName1 + '/describe';
		HttpResponse res = getHttpResponse(queryURL);
		String responseBody = res.getBody();
		system.debug('Object Describe responseBody : ' + responseBody);
		Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
		system.debug('resultMap size : ' + resultMap.size());
		for(String s : resultMap.keyset())
		{
			if (s == 'fields')
			{
				List<Object> fieldsList1 = (List<Object>)resultMap.get(s);

				system.debug('Field List size : ' + fieldsList1.size());

				for(Object s1 : fieldsList1)
				{
					Map<String, Object> s1Map = (Map<String, Object>)s1;
					for(String s2 : s1Map.keyset())
					{
						if (s2 == 'name')
						{
							system.debug('s1Map Field Name: ' + s1Map.get(s2));
							fieldsList.add(String.valueOf(s1Map.get(s2)));
						}
					}
				}
			}
		}

		system.debug('fieldsList size from Metadata API call : ' + fieldsList);
		createFieldList();
	}

	// CREATE LIST OF FIELDS OF SELECTED OBJECT TO BE FILLED IN DROPDOWN LIST ON VF PAGE
	public void createFieldList()
	{
		Integer cnt = 1;
		for (String name : fieldsList)
		{
			// IF FIELDS COUNT EXCEEDS 1000, DON'T ADD IN DROPDOWN
			if (cnt >= 1000)
			{
				system.debug('Fields count is crossing the limit of 1000.');
				break;
			}
			cnt++;
			fieldsOptionsList.add(new SelectOption(name,name));
		}
		fieldsOptionsList.sort();
	}

	// METHOD CALLED FROM Search and Export Results BUTTON OF VF PAGE
	public void searchReferences()
	{
		try
		{
			system.debug('in search ref sObjectName1 : ' + sObjectName1);
			system.debug('in search ref inputKeyword : ' + inputKeyword);
		}
		catch(Exception e)
		{
			system.debug('Message : ' + e);
		}

		if( (sObjectName1 != null && sObjectName1 != '') || (inputKeyword != null && inputKeyword != '') )
		{
			findReferencesInValidationRule(sObjectName1, selectedField, inputKeyword);
			findReferencesInWorkflow(sObjectName1, selectedField, inputKeyword);
			//findReferencesInProcessBuilder(sObjectName1, selectedField, inputKeyword);
		}
		else
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,  'Please select the Object OR enter the Keyword.'));
		}
	}

	// METHOD TO FIND REFERENCE IN ALL VALIDATION RULES
	public void findReferencesInValidationRule(String vObjectName, String VFieldName, String vKeyword)
	{
		String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();

		String url =  salesforceHost + '/services/data/v30.0/tooling/query/?q=Select+fullname+,metadata+from+ValidationRule';

		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setEndpoint(url);
		req.setHeader('Content-type', 'application/json');
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		Http http = new Http();

		HTTPResponse res = http.send(req);
		System.debug(res.getBody());
		String responseBody = res.getBody();
		system.debug('Validation rule responseBody : ' + responseBody);
		Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
		system.debug('resultMap size : ' + resultMap.size());

		crossRefFieldName = VFieldName.replace('__c', '__r');

		system.debug('crossRefFieldName : ' + crossRefFieldName);
		system.debug('VFieldName : ' + VFieldName);

		Integer cnt = 1;
		for (String s : resultMap.keyset())
		{

			if (s == 'records')
			{
				List<Object> records = (List<Object>)resultMap.get(s);
				for(Object s1 : records)
				{
					Map<String, Object> s1Map = (Map<String, Object>)s1;
					Map<String, Object> attribMap = (Map<String, Object>)s1Map.get('attributes');
					String recordURL = String.valueOf(attribMap.get('url'));
					List<String> urlParts = recordURL.split('/');

					Map<String, Object> s2Map = (Map<String, Object>)s1Map.get('Metadata');
					String fullName = String.valueOf(s1Map.get('FullName'));

					for (String s2 : s2Map.keyset())
					{
						if (s2 == 'active' && String.valueOf(s2Map.get(s2)) == 'true')
						{

							cnt++;

							String formula = String.valueOf(s2Map.get('errorConditionFormula'));

							if (formula.containsIgnoreCase(crossRefFieldName) || formula.containsIgnoreCase(VFieldName))
							{
								formula = formula.replace(',', '');
								mapOfValidationRule.put(urlParts.get(urlParts.size() - 1) + '=>' + fullName, formula);
							}
						}
					}
				}
			}
		}

		system.debug('Active validation rules count : ' + cnt);

		for (String sss : mapOfValidationRule.keySet())
		{
			system.debug(sss + ' => ' + mapOfValidationRule.get(sss));
		}

		system.debug('Final map count : ' + mapOfValidationRule.size());
	}

	// METHOD TO FIND REFERENCE IN ALL WORKFLOW RULES
	public void findReferencesInWorkflow(String objectName, String fieldName, String keyword)
	{
		system.debug('In findReferencesInWorkflow method.....');

		String queryURL = 'tooling/query?q=Select+Id,Name,TableEnumOrId+From+WorkflowRule';
		HttpResponse res = getHttpResponse(queryURL);
		String responseBody = res.getBody();
		system.debug('in findReferencesInWorkflow responseBody : ' + responseBody);
		Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
		system.debug('resultMap size : ' + resultMap.size());

		Boolean brkFlag1 = false;
		Boolean brkFlag2 = false;

		workFlowIdNameList = new List<String>();

		for (String s : resultMap.keyset())
		{
			system.debug(s + ' => ' + resultMap.get(s));
			if (s == 'records')
			{
				Integer cnt = 0;
				List<Object> records = (List<Object>)resultMap.get(s);

				system.debug('Total no of records size : ' + records.size());

				for(Object s1 : records)
				{
					Map<String, Object> s1Map = (Map<String, Object>)s1;
					//system.debug('Workflow Name => '+ s1Map.get('Name'));
					for (String innerMapKey : s1Map.keySet())
					{
						// ============ THIS LOOP IS ADDED FOR TESTING ON SMALL SCALE DATA ============
						if (cnt == 2 )
						{
							brkFlag1 = true;
							//break;
						}
						// ============================================================================
						if (innerMapKey == 'Id')
						{
							String workflowId = String.valueOf(s1Map.get(innerMapKey));
							workFlowIdNameList.add(workflowId + '=>' + s1Map.get('Name'));

							system.debug(cnt + ' => ' + workflowId + ' => ' + s1Map.get('Name'));
							cnt++;
						}
					}

					// ============ THIS LOOP IS ADDED FOR TESTING ON SMALL SCALE DATA ============
					if (brkFlag1)
					{
						//break;
					}
					// ============================================================================
				}
			}
		}

		// GERNERATE UNIQUE TIMESTAMP TO TRACK BATCH JOB EXECUTION RESULT
		DateTime myDateTime1 = DateTime.now();
		String s = myDateTime1.format();
		Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(s));
		uniqueString2 = EncodingUtil.convertToHex(hash).substring(0,30);

		system.debug('workFlowIdNameList : ' + workFlowIdNameList.size());

		if (!Test.isRunningTest())
		{
			AH_RecordReferenceWorkflow_Batch btch = new AH_RecordReferenceWorkflow_Batch(workFlowIdNameList, objectName, fieldName, keyword, mapOfValidationRule,uniqueString2);
			setupSearchBatchID = Database.executeBatch(btch,1);
			system.debug('setupSearchBatchID : ' + setupSearchBatchID);

			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info,  'Batch Job to search setup records has been started. \nPlease use Refresh button to check the Status.'));
		}
	}

	// SEND HTTP REQUEST
	private HttpResponse getHttpResponse(String URL)
	{
		String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
		system.debug('salesforceHost : ' + salesforceHost);

		String queryURL = salesforceHost + '/services/data/v45.0/' + URL;
		system.debug('queryURL : ' + queryURL);

		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setEndpoint(queryURL);
		req.setHeader('Content-type', 'application/json');
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		Http http = new Http();
		HTTPResponse resp = http.send(req);

		return resp;
	}


	// =============================================================================================================================
	// WRAPPER CLASSES
	// =============================================================================================================================  
	public class errorLogWrapper
	{
		public ID errorId {get; set;}
		public String Name {get; set;}
		public String Object_Name {get; set;}
		public String Apex_Class_Name {get; set;}
		public String DML_Type {get; set;}
		public String Message {get; set;}
		public String CreatedByName {get; set;}
		public String CreatedDate {get; set;}

		public errorLogWrapper()
		{
			this.Name = '';
			this.Object_Name = '';
			this.Apex_Class_Name = '';
			this.DML_Type = '';
			this.Message = '';
			this.CreatedByName = '';
		}
	}

	// WRAPPER CLASS TO HOLD THE HISTORY RESULT
	public class runHistory
	{
		public String Apex_Class {get; set;}
		public String user {get; set;}
		public String Status {get; set;}
		public String CreatedDate {get; set;}
		public String Target_Object {get; set;}
		public String Status_Detail {get; set;}
		public Integer No_of_Items_Processed {get; set;}

		public runHistory()
		{
			this.Apex_Class = '';
			this.Status = '';
			this.Target_Object = '';
		}
	}

}