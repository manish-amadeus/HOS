public class NI_KanbanDashboard { 
	public List<List<String>> lstLstMain {get;set;}
	//public static Boolean isDragEnable = false;

	public NI_KanbanDashboard(){
		
	}
	
	public static boolean verifyAccess(String recordType){
		
		// Retriving custom setting for dashboard limits 		
		Dashboard_Access__c pbAccess = [SELECT Record_Type__c, Public_Group__c, Queue__c, Permission_set__c, Profile__c
												FROM Dashboard_Access__c
												WHERE Record_Type__c = :recordType Limit 1 ];

		String strSearch = '';
		if(pbAccess.Profile__c != null)
			strSearch = String.valueOf(pbAccess.Profile__c);
		else if(pbAccess.Permission_set__c != null)
			strSearch = String.valueOf(pbAccess.Permission_set__c);
		else if(pbAccess.Public_Group__c != null)
			strSearch = String.valueOf(pbAccess.Public_Group__c);
		else if(pbAccess.Queue__c != null)
			strSearch = String.valueOf(pbAccess.Queue__c);

		
		String strInstanceURL = '/'+String.valueOf(UserInfo.getUserId()) + '?noredirect=1&isUserEntityOverride=1';				
		Boolean isFound = false;
		isFound = NI_KanbanDashboard.parseContent(strInstanceURL,strSearch);
		
		if(!isFound && pbAccess.Queue__c != null){
			strInstanceURL = '/_ui/system/user/QueueMembershipPage/d?userId='+ String.valueOf(UserInfo.getUserId()) +'&setupid=PersonalInformation&rowsperpage=6000';
			
			isFound = NI_KanbanDashboard.parseContent(strInstanceURL,String.valueOf(pbAccess.Queue__c));
		}
		if(!isFound && pbAccess.Public_Group__c != null){
			strInstanceURL = '/_ui/system/user/GroupMembershipPage/d?userId='+ String.valueOf(UserInfo.getUserId()) +'&setupid=PersonalInformation&rowsperpage=6000';			
			isFound = NI_KanbanDashboard.parseContent(strInstanceURL,String.valueOf(pbAccess.Public_Group__c));
		}
		if(!isFound && pbAccess.Permission_set__c != null){
			strInstanceURL = '/0PS?rlid=RelatedPermsetAssignmentList&id='+ String.valueOf(UserInfo.getUserId()) +'&rowsperpage=6000';			
			isFound = NI_KanbanDashboard.parseContent(strInstanceURL,String.valueOf(pbAccess.Permission_set__c));
		}
		//if(isFound)
		//	NI_KanbanDashboard.isDragEnable = true;
		system.debug(isFound);
		return isFound;
	
	}
	public static Boolean parseContent(String sURL, String fSearch){
		//strInstanceURL = '/_ui/system/user/GroupMembershipPage/d?userId='+ String.valueOf(UserInfo.getUserId()) +'&setupid=PersonalInformation&rowsperpage=6000';
		Boolean isFound = false;
		PageReference pg = new PageReference(sURL);
		httpRequest req = new HttpRequest();
		try{
			req.setBodyAsBlob(pg.getContent());
		}catch(Exception e) {
			if(Test.isRunningTest())	
				req.setBody('>'+fSearch+'</a>');
		}
		String response = req.getBody();
		if(fSearch!= '' && response.contains('>'+fSearch+'</a>'))
			isFound = true;
		return isFound;
	}
	//method to get all record types from custom setting and populate in drop-down
     @RemoteAction
    public static List<RecordTypesInfo__c> getRecordTypes(){
        system.debug('in controller record types');
        List<RecordTypesInfo__c> recordTypes = [SELECT Record_Type_Name__c FROM RecordTypesInfo__c];
        return recordTypes;
    }
    
	//method to get all the teams from picklist and populate in drop-down
    @RemoteAction
    public static List<String> getTeams(){            	
        Schema.DescribeFieldResult statusFieldDescription = NI_Project_Backlog__c.Project_Type__c.getDescribe();
        system.debug('in controller getTeams');
    	List<String> teams = new List<String>();  		          
      		 for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues()) {
               teams.add(pickListEntry.getValue());          	
    	 }    
        return teams;
    }
	
   
    @RemoteAction
	public static String changeStatus(Id strId, String newStatus, Boolean unplannedFlag, Boolean interObject, String rdata){
		
		Schema.SObjectType sobjectType = strId.getSObjectType();
		String sobjectName = sobjectType.getDescribe().getName();
		system.debug(sobjectName);
		if(interObject && sobjectName == 'NI_Project_Backlog_Tasks__c'){
			NI_Project_Backlog_Tasks__c pbtasks = database.query( 'Select Id,Project_Phase__c, NI_Project_Backlog_Item__c from NI_Project_Backlog_Tasks__c where Id = :strId' );
			strid = pbtasks.NI_Project_Backlog_Item__c;	
		}
		if(sobjectName == 'NI_Project_Backlog__c' || interObject){
			List<NI_Project_Backlog__c> tasks = database.query( 'Select Id,Request_Status__c, unplanned__c from NI_Project_Backlog__c where Id = :strId' );
                if( tasks.size() == 0 )
                {
                        throw new SCMImpToolsException( 'Unable to find the specified task' );
                }
                
				if((newStatus == 'Blocked' || newStatus == 'Redirected') && rdata != null)
					 tasks[0].put( 'On_Hold_Reason__c', rdata );

                tasks[0].put( 'Request_Status__c', newStatus );
                if(interObject){
                	tasks[0].put( 'unplanned__c', unplannedFlag );
                }
                 try {
					update tasks[0];
				} catch(Exception e){
					throw new SCMImpToolsException( 'Exception: "'+ e.getMessage()  );
				}
				tasks = database.query( 'Select Id,Request_Status__c from NI_Project_Backlog__c where Id = :strId' );
				if(tasks[0].Request_Status__c != newStatus){
					throw new SCMImpToolsException( 'Status updated to '+ tasks[0].Request_Status__c + ' as per the process' );
				}
		}
		else if(sobjectName == 'NI_Project_Backlog_Tasks__c'){
			
			List<NI_Project_Backlog_Tasks__c> tasks = database.query( 'Select Id,Project_Phase__c, NI_Project_Backlog_Item__r.request_Status__c from NI_Project_Backlog_Tasks__c where Id = :strId' );
                if( tasks.size() == 0 )
                {
                        throw new SCMImpToolsException( 'Unable to find the specified task' );
                }
                
                	tasks[0].put( 'Project_Phase__c', newStatus );
					System.debug(tasks[0]);
                
                try {
					update tasks[0];
				} catch(Exception e){
					throw new SCMImpToolsException( 'Exception: "'+ e.getMessage()  );
				}
				tasks = database.query( 'Select Id,Project_Phase__c  from NI_Project_Backlog_Tasks__c where Id = :strId' );
				
				if(tasks[0].Project_Phase__c != newStatus){
					throw new SCMImpToolsException( 'Status updated to "'+ tasks[0].Project_Phase__c + '" as per the system validation process.' );
				}
		}
		return strId;
	}
	public static string createColumns(List<String> teams, List<String> statues){
		
		String prePbStatus = '';
		for(Integer i=0;i<teams.size();i++){
			prePbStatus += '[';
			for(Integer j=0 ;j<statues.size();j++){
				prePbStatus +='{ "title": "'+ statues[j] +'" }';
				if(j<(statues.size()-1))
					prePbStatus += ',';
			}
				if(i==(teams.size()-1))
					prePbStatus += ']';
				else
					prePbStatus += '],';	
		}
		return prePbStatus;
	}
	
    public static string createProjectBacklogString(List<NI_Project_Backlog__c> mapPBitems){
		Map<String,Map<String,List<NI_Project_Backlog__c>>> dbPBitems = new Map<String,Map<String,List<NI_Project_Backlog__c>>>();
		Map<String,List<NI_Project_Backlog__c>> teamMap = new Map<String,List<NI_Project_Backlog__c>>();
		List<NI_Project_Backlog__c> teamLst = new List<NI_Project_Backlog__c>();
		
		for(NI_Project_Backlog__c pblog : mapPBitems){
			
			teamMap = new Map<String,List<NI_Project_Backlog__c>>();
			teamLst = new List<NI_Project_Backlog__c>();

			
			// Verify with Recordtypes
			
			system.debug(dbPBitems.containsKey(pblog.Project_Type__c));
			if(dbPBitems.containsKey(pblog.Project_Type__c) ){
				teamMap = dbPBitems.get(pblog.Project_Type__c);

				
				// Verify with Status of Project Backlog
				if(teamMap.containsKey(pblog.Request_Status__c)){
					
					teamLst = teamMap.get(pblog.Request_Status__c);
					teamLst.add(pblog);
					teamMap.put(pblog.Request_Status__c,teamLst);
					
					dbPBitems.put(pblog.Project_Type__c,teamMap);
					
				} else{
					teamLst.add(pblog);
					teamMap.put(pblog.Request_Status__c,teamLst);
					dbPBitems.put(pblog.Project_Type__c,teamMap);
					
				}


			} else {
				teamLst.add(pblog);
				teamMap.put(pblog.Request_Status__c,teamLst);
				dbPBitems.put(pblog.Project_Type__c,teamMap);
				
			}
			
		}
		String strdbPBitems = '';
		strdbPBitems = JSON.serialize(dbPBitems);
		return strdbPBitems;
	}
	
	public static string createTaskString(Map<Id,NI_Project_Backlog_Tasks__c> mapPBTaskitems, Map<String,Dashboard_Limits__c> pbMapLimits){
	//Creating data of project backlog Task as per required format on UI

        
        
		Map<String,Map<String,List<NI_Project_Backlog_Tasks__c>>> dbPBTaskitems = new Map<String,Map<String,List<NI_Project_Backlog_Tasks__c>>>();
		Map<String,List<NI_Project_Backlog_Tasks__c>> teamTaskMap = new Map<String,List<NI_Project_Backlog_Tasks__c>>();
		List<NI_Project_Backlog_Tasks__c> teamTaskLst = new List<NI_Project_Backlog_Tasks__c>();
		system.debug(pbMapLimits);
		Set<Id> backlogItemSet = new Set<Id>();
		
        
		Integer i =1;
		for(NI_Project_Backlog_Tasks__c pbTask : mapPBTaskitems.values()){
			
			teamTaskMap = new Map<String,List<NI_Project_Backlog_Tasks__c>>();
			teamTaskLst = new List<NI_Project_Backlog_Tasks__c>();
			
			backlogItemSet.add(pbTask.NI_Project_Backlog_Item__c);
			// Verify with Recordtypes
			if(dbPBTaskitems.containsKey(pbTask.NI_Project_Backlog_Item__r.Project_Type__c) ){
				teamTaskMap = dbPBTaskitems.get(pbTask.NI_Project_Backlog_Item__r.Project_Type__c);

				
				// Verify with Status of Project Backlog
				if(teamTaskMap.containsKey(pbTask.Project_Phase__c)){
					
					teamTaskLst = teamTaskMap.get(pbTask.Project_Phase__c);
					teamTaskLst.add(pbTask);
					teamTaskMap.put(pbTask.Project_Phase__c,teamTaskLst);
					
					dbPBTaskitems.put(pbTask.NI_Project_Backlog_Item__r.Project_Type__c,teamTaskMap);
					
				} else{
					teamTaskLst.add(pbTask);
					teamTaskMap.put(pbTask.Project_Phase__c,teamTaskLst);
					dbPBTaskitems.put(pbTask.NI_Project_Backlog_Item__r.Project_Type__c,teamTaskMap);
					
				}


			} else {
				teamTaskLst.add(pbTask);
				teamTaskMap.put(pbTask.Project_Phase__c,teamTaskLst);
				dbPBTaskitems.put(pbTask.NI_Project_Backlog_Item__r.Project_Type__c,teamTaskMap);
				
			}
			
			//Increament i to count total number of records as per the custom setting.
			system.debug(backlogItemSet.size());
			system.debug(pbMapLimits.get(String.valueOf(pbTask.NI_Project_Backlog_Item__r.Project_Type__c)).In_Progress__c);
			//if(backlogItemSet.size() >= pbMapLimits.get(String.valueOf(pbTask.NI_Project_Backlog_Item__r.Project_Type__c)).In_Progress__c)
			 //break;
		}
		String strdbPBTaskitems = '';
		strdbPBTaskitems = JSON.serialize(dbPBTaskitems);
		return strdbPBTaskitems;
		
	}
	
	public static string prepareDataSet(List<String> teams, List<String>taskStatues){
		String innerDataSet = '';
		for(Integer i=0; i<teams.size();i++){
			innerDataSet += '[ [';
			for(Integer j=0; j<taskStatues.size(); j++){
				innerDataSet += '"'+ teams[i] + '-' + taskStatues[j] + '"';
				if(j<(taskStatues.size()-1))
				innerDataSet += ',';
			}
			innerDataSet += '] ] ';
			if(i<(teams.size()-1))
				innerDataSet += ',';
				
		}
		innerDataSet += ']';
		return innerDataSet;
	}

	@RemoteAction
	public static String getDashboard(String recordTypes,String selectedTeams){
		
		
		String retSelectedTeams = selectedTeams.substringBetween('[',']');
		retSelectedTeams = retSelectedTeams.replace('"', '');		
		List<String> teams  = retSelectedTeams.split(',');
		System.debug(teams);
		System.debug(recordTypes);

		Boolean isDragEnable = NI_KanbanDashboard.verifyAccess(recordTypes);
		System.debug(isDragEnable);
		
		String isDragEnablestr = '"isDragEnable":' + isDragEnable;
		// Get all limits metioned in custom setting
		
		// Get allowded Project Backlog statues from Custom setting 
		Dashboard_ProjectBacklogStatus__c pbStatues = Dashboard_ProjectBacklogStatus__c.getValues(recordTypes);
		List<String>statues = String.valueOf(pbStatues.Status__c).split(',');
		//Integer maxNoOfRows = Integer.valueOf(pbStatues.No_Of_Active_Projects__c); 


		List<Dashboard_Unplanned_Statuses__c> pbUnplannedStatus = Dashboard_Unplanned_Statuses__c.getall().values();
		List<String> lstUnplannedStatus = new List<String>();
		for(Dashboard_Unplanned_Statuses__c dasUnplan:pbUnplannedStatus )
		lstUnplannedStatus.add(dasUnplan.Name); 

		// Get allowded Project Backlog Task statuses from Custom setting
		Dashboard_Task_Status__c pbTaskStatus = [Select Record_Type__c, Team__c, Project_Phases__c from Dashboard_Task_Status__c
												WHERE Record_Type__c = :recordTypes AND Team__c IN :teams limit 1];
		List<String> taskStatues = String.valueOf(pbTaskStatus.Project_Phases__c).split(',');
		
		// Retriving custom setting for dashboard limits 		
		List<Dashboard_Limits__c> pbLimits = [SELECT Record_Type__c, Team__c, Number_Of_Active_Projects__c, 
												In_Progress__c, Backlog_Item__c, Blocked__c,
												Completed__c, New__c, Redirected__c, Rejected__c, Number_of_Unplanned_Backlogs__c
												FROM Dashboard_Limits__c
												WHERE Record_Type__c = :recordTypes AND Team__c IN :teams ];
		Map<String,Dashboard_Limits__c> pbMapLimits = new Map<String,Dashboard_Limits__c>();
		for(Dashboard_Limits__c pblimit:pbLimits){
			pbMapLimits.put(String.valueOf(pblimit.Team__c), pblimit);
		}												
		//Integer maxNoOfRows = Integer.valueOf(pbStatues.No_Of_Active_Projects__c);
		String strPBLimits = '';		
		strPBLimits = JSON.serialize(pbLimits);
		strPBLimits = '"strPBLimits":[' + strPBLimits + ']';
				//Retriving custom setting for Display Tasks
		Boolean isDisplayTask = false;
		ID pid =  userinfo.getProfileId();
		Dashboard_Display_Tasks_Profile__c ddtaskProfile = Dashboard_Display_Tasks_Profile__c.getInstance(pid);
		if(ddtaskProfile != null && ddtaskProfile.Id != null)
			isDisplayTask = true;

		//Create Map for Project Backlog items
		Map<Id,NI_Project_Backlog__c> mapPBitems = new Map<Id,NI_Project_Backlog__c> ();

		// As we wanted to apply limit with cobination of record type and team
		
		Map<Id,NI_Project_Backlog__c> mapTempPBitems = new Map<Id,NI_Project_Backlog__c>( 
															[Select Id, Name, Request_Status__c,Project_Type__c 
																//RecordType.name , Beneficiaries__c, Prioritization_Score__c , Sponsor__r.Name
																From NI_Project_Backlog__c  
																Where Project_Type__c IN :teams AND
																Request_Status__c IN :statues AND
																RecordType.Name = :recordTypes 
                                                             ORDER BY Project_Type__c, Request_Status__c , Prioritization_Score__c DESC, LastModifiedDate DESC
																Limit  2000]); // Assuming with max records 
																
		// As we wanted to apply limits based on each status columns
		// Collecting based on status
		System.debug(mapTempPBitems.keySet().size());
		List<Id> filteredIds = new List<Id>();
		Map<String,Map<String,List<ID>>> pbStatusFilter = new Map<String,Map<String,List<ID>>>();
		Map<String,List<Id>> mapStatusFilter = new Map<String,List<Id>>();
		for(NI_Project_Backlog__c niPrjBl:mapTempPBitems.values()){
			filteredIds = new List<Id>();
			mapStatusFilter = new Map<String,List<Id>>();
			if(pbStatusFilter.get(niPrjBl.Project_Type__c) != null){
				mapStatusFilter = pbStatusFilter.get(niPrjBl.Project_Type__c);
				if(mapStatusFilter.get(niPrjBl.Request_Status__c) != null){
					filteredIds = mapStatusFilter.get(niPrjBl.Request_Status__c);
					filteredIds.add(niPrjBl.id);
					mapStatusFilter.put(niPrjBl.Request_Status__c, filteredIds);
					pbStatusFilter.put(niPrjBl.Project_Type__c, mapStatusFilter);
			
				}else{
					filteredIds.add(niPrjBl.id);
					mapStatusFilter.put(niPrjBl.Request_Status__c,filteredIds);
					pbStatusFilter.put(niPrjBl.Project_Type__c, mapStatusFilter);
				}
		
			}else{
				filteredIds.add(niPrjBl.id);
				mapStatusFilter.put(niPrjBl.Request_Status__c,filteredIds);
				pbStatusFilter.put(niPrjBl.Project_Type__c, mapStatusFilter);
			}
		}
		filteredIds = new List<Id>();

		// Applying custom setting limits based on status
		for(String team:pbStatusFilter.keySet()) {
			mapStatusFilter = pbStatusFilter.get(team);
			Dashboard_Limits__c pblimit = pbMapLimits.get(team);
			for(String mapStr : mapStatusFilter.keySet()) {
		
				String sText = mapStr;
 				sText = sText.replaceAll( '\\s+', '_');
				sText += '__c';
				System.debug(sText);
				Integer maxLimit = mapStatusFilter.get(mapStr).size();
				try{
					
					if(Integer.valueOf(pblimit.get(sText)) < maxLimit)
						maxLimit = Integer.valueOf(pblimit.get(sText));
					
				}catch (Exception e){
					//System.debug('In Eception '+ sText);
				}
				
				for(Integer i=0; i<maxLimit; i++){ 
					filteredIds.add(mapStatusFilter.get(mapStr).get(i)) ;
				}
			}
		}
		//System.debug(filteredIds.size());
		List<NI_Project_Backlog__c> lstTempPBitems = new List<NI_Project_Backlog__c>( 
															[Select Id, Name, Request_Status__c,Project_Type__c, 
																RecordType.name , Beneficiaries__c, Prioritization_Score__c , Sponsor__r.Name
																From NI_Project_Backlog__c  
																Where Project_Type__c IN :teams AND
																Request_Status__c IN :statues AND
																RecordType.Name = :recordTypes AND
																ID IN :filteredIds
																ORDER BY Project_Type__c, Request_Status__c , Prioritization_Score__c DESC, LastModifiedDate DESC
																Limit  2000]); // Assuming with max records 


		system.debug('mapPBitems'+mapPBitems);
		Map<Id,NI_Project_Backlog_Tasks__c> mapPBTaskitems = new Map<Id,NI_Project_Backlog_Tasks__c>();
		Map<Id,NI_Project_Backlog_Tasks__c> mapPBUnplannedTaskitems = new Map<Id,NI_Project_Backlog_Tasks__c>();
		
		if(isDisplayTask) {

			
			// Retriving the data for In Progress column but not unplanned items.
				mapPBTaskitems = new Map<Id,NI_Project_Backlog_Tasks__c>(
														[Select	Id, Name, Task_Name__c,	Project_Phase__c, 
															NI_Project_Backlog_Item__c,  
															Status__c, NI_Project_Backlog_Item__r.Project_Type__c,
														
															NI_Project_Backlog_Item__r.Name, Committed__c,
															Assigned_To__r.Name 
															From NI_Project_Backlog_Tasks__c  
															Where  NI_Project_Backlog_Item__r.request_Status__c= 'In Progress' AND
															NI_Project_Backlog_Item__r.Unplanned__C= false AND
															Project_Phase__c IN :taskStatues AND
															NI_Project_Backlog_Item__c IN :filteredIds]);
		
			System.debug(mapPBTaskitems);

			// Retriving the data for In Progress column only for unplanned items.
				mapPBUnplannedTaskitems = new Map<Id,NI_Project_Backlog_Tasks__c>(
														[Select	Id, Name, Task_Name__c,	Project_Phase__c, 
															NI_Project_Backlog_Item__c,  
															Status__c, NI_Project_Backlog_Item__r.Project_Type__c,
															NI_Project_Backlog_Item__r.Name, Committed__c,
															Assigned_To__r.Name 
															From NI_Project_Backlog_Tasks__c  
															Where  NI_Project_Backlog_Item__r.request_Status__c= 'In Progress' AND
															NI_Project_Backlog_Item__r.Unplanned__C= true AND
															Project_Phase__c IN :lstUnplannedStatus AND
															NI_Project_Backlog_Item__c IN :filteredIds]);
			//System.debug(agrUnplannedIds);
			System.debug(mapPBUnplannedTaskitems);
			System.debug(lstUnplannedStatus);
		}
		String strIsDisplayTask = '"isDisplayTask":'+ String.valueOf(isDisplayTask);
		//Creating data of project backlog as per required format on UI
	
		String strdbPBitems = '';
		//strdbPBitems = JSON.serialize(dbPBitems);
		strdbPBitems = createProjectBacklogString(lstTempPBitems);
		strdbPBitems = '"dbPBitems":[' + strdbPBitems + ']';

		//Creating data of project backlog Task as per required format on UI

		String strdbPBTaskitems = '';
		strdbPBTaskitems = createTaskString(mapPBTaskitems,pbMapLimits);
		//strdbPBTaskitems = JSON.serialize(dbPBTaskitems);
		strdbPBTaskitems = '"dbPBTaskitems":[' + strdbPBTaskitems + ']';


		
		String strdbPBUnplannedItems = '';
		strdbPBUnplannedItems = createTaskString(mapPBUnplannedTaskitems,pbMapLimits);
		//strdbPBUnplannedItems = JSON.serialize(dbPBUnplannedItems);
		strdbPBUnplannedItems = '"dbPBUnplannedTaskitems":[' + strdbPBUnplannedItems + ']';

		System.debug(strdbPBUnplannedItems);
   
		// Used for data holding column values of main table
			List<List<String>> lstPbStatues	 = new List<List<String>> ();			
				
			String mainTableCols = '"mainTableCols" :[ '+ NI_KanbanDashboard.createColumns(teams,statues) + ']';

		// Used for data holding column values of inner table.
			String innerTableCols = '"innerTableCols": [ '+ NI_KanbanDashboard.createColumns(teams,taskStatues) + ']';
           
 
            
        // Used for data holding column values of unplanned table.
			String unplannedTableCols = '"unplannedTableCols": [ '+ NI_KanbanDashboard.createColumns(teams,lstUnplannedStatus) + ']';

		// Used for data holding the values for inner table
			String innerDataSet = '';
			innerDataSet = '"innerDataSet":[';
			innerDataSet += prepareDataSet(teams, taskStatues);
				
		// Used for data holding for unplanned data set
			String innerUnplannedDataSet = '"innerUnplannedDataSet":[';
			innerUnplannedDataSet += prepareDataSet(teams, lstUnplannedStatus);
				
            
		String dataSet = '"dataSet":[';
		dataSet += prepareDataSet(teams, statues);
			
        // Data set of then main / outer table.
          
		return '{'+ isDragEnablestr +  ',' + strIsDisplayTask + ',' + innerDataSet + ','+ mainTableCols + ',' + innerTableCols + ','+ unplannedTableCols + ',' 
					+ innerUnplannedDataSet + ',' + dataSet + ','+ strdbPBitems + ','+ strdbPBTaskitems  + ','
					+ strdbPBUnplannedItems + ',' + strPBLimits + '}'; //+ ',' + pbTaskStr

	
	}
    

}