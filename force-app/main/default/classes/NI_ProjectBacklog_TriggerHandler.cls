/************************************************************************************************
Name            : NI_ProjectBacklog_TriggerHandler Class
Author          : Prashant Wayal
Created Date    : 12/04/2015
Last Mod Date   : 5/9/2021
Last Mod By     : Stuart Emery
NICC Reference  : NICC-016293
Description     : Updated 05/09/2021 per NICC-048128
                : Handles the Logic for the NI Project Backlog Triggers
                :
                :
*************************************************************************************************/
public class NI_ProjectBacklog_TriggerHandler
{

    private boolean isExecuting = false;
    
    private NI_Project_Backlog__c projBacklog;
    public String newRecordId;
    public String oldRecordId;
    Public List<String> taskBacklogId;
    Public Map<String, String> newtaskBacklogId;
    Public Map<String, String> oldtaskBacklogId;
    private Set<Id> setRecTypeIds;
    
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
   
    public NI_ProjectBacklog_TriggerHandler(boolean isExecuting)
    {
        isExecuting = isExecuting;
        
         // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        
    // GET RECORD TYPE REFERENCES TO CUSTOM METADATA TYPE FOR UPDATING MARGIN %
    // USE SAME RECORD TYPES AS USED FOR PRIORITY CALCULATION
       setRecTypeIds = new Set<Id>();
        for (AH_Recalculate_Priority_Record_Types__mdt cs : [SELECT Record_Type_Name__c FROM AH_Recalculate_Priority_Record_Types__mdt])
        {
            setRecTypeIds.add(Schema.SObjectType.NI_Project_Backlog__c.getRecordTypeInfosByName().get(cs.Record_Type_Name__c).getRecordTypeId());
        }
        
    }

    public boolean IsTriggerContext
    {
        get {return isExecuting;}
    }

    public void OnBeforeInsert(List<NI_Project_Backlog__c> newTrigger)
    { 
        
        Set<Id> projectBacklogId = new Set<Id>();
        Set<Id> projectBacklogIdSet = new Set<Id>();
		for(NI_Project_Backlog__c backlogProj : newTrigger){                     
            
            if(backlogProj.Unplanned__c == true && backlogProj.Request_Status__c == 'In Progress' && backlogProj.Project_Type__c != null){
                projectBacklogId.add(backlogProj.Id);                
        	}
            
            if(backlogProj.Request_Status__c == 'In Progress' && backlogProj.Project_Type__c != null){
                projectBacklogIdSet.add(backlogProj.Id);
             
            }
            
            //CALL THE METHOD TO UPDATE THE MARGIN %
            if(setRecTypeIds.contains(backlogProj.RecordTypeId))
            {
              Update_Margin(newTrigger);  
            }
        }
        
        if(!projectBacklogId.isEmpty()){
            checkToAllowProjectAsUnplanned(newTrigger);
        }
        
        if(!projectBacklogIdSet.isEmpty()){
            checkToAllowProjAsInProgress(newTrigger);
        }
    }
   
    public void OnBeforeUpdate(List<NI_Project_Backlog__c> newTrigger, Map<Id, NI_Project_Backlog__c> oldMapTrigger )
    {
        rollupSummaries(newTrigger);
        system.debug('in before update');
        Set<Id> projectBacklogId = new Set<Id>();
        Set<Id> projectBacklogIdSet = new Set<Id>();  
        for(NI_Project_Backlog__c backlogProj : newTrigger){
            system.debug('backlogProj'+backlogProj);            
            NI_Project_Backlog__c oldProject = oldMapTrigger.get(backlogProj.Id);
            
            if(backlogProj.Unplanned__c == true && 
            	oldMapTrigger.get(backlogProj.id).Unplanned__c != backlogProj.Unplanned__c &&
            	backlogProj.Request_Status__c == 'In Progress' && 
            	backlogProj.Project_Type__c != null){
                projectBacklogId.add(backlogProj.Id);                
        	}
        	/* if(backlogProj.Request_Status__c == 'In Progress' && backlogProj.Project_Type__c != null &&
        	 	oldMapTrigger.get(backlogProj.id).Request_Status__c != backlogProj.Request_Status__c){
                projectBacklogIdSet.add(backlogProj.Id);
            }*/
            
            
            if(backlogProj.Project_Type__c != null &&
        	 	oldMapTrigger.get(backlogProj.id).Request_Status__c != backlogProj.Request_Status__c){
                projectBacklogIdSet.add(backlogProj.Id);
            }
            
             //CALL THE METHOD TO UPDATE THE MARGIN %
            if(setRecTypeIds.contains(backlogProj.RecordTypeId) && oldMapTrigger.get(backlogProj.id).Solution_Domain__c != backlogProj.Solution_Domain__c)
            {
              Update_Margin(newTrigger);  
            }
            
        }
        if(!projectBacklogId.isEmpty()){
            checkToAllowProjectAsUnplanned(newTrigger);
        }
        if(!projectBacklogIdSet.isEmpty()){
            checkToAllowProjAsInProgress(newTrigger);
        }
    }

    public void OnBeforeDelete(List<NI_Project_Backlog__c> newTrigger)
    {
       
    }
   
    public void OnAfterInsert(List<NI_Project_Backlog__c> newTrigger)
    {
        // Rollup parent project backlogs
        invokeProjectRollup(newTrigger);
        AutoCreateNIProjectTasks(newTrigger);
        cloneNIProjectTasks(newTrigger);
    }
   
    public void OnAfterUpdate(List<NI_Project_Backlog__c> newTrigger, Map<Id, NI_Project_Backlog__c> oldMapTrigger)
    {      
        // Rollup parent project backlogs
        invokeProjectRollup(newTrigger);
       
        AutoCreateNIProjectTasks(newTrigger);
    }
       
    public void OnAfterDelete(List<NI_Project_Backlog__c> newTrigger)
    {
         // Rollup parent project backlogs 
        invokeProjectRollup(newTrigger);     
    }
   
    public void OnAfterUnDelete(List<NI_Project_Backlog__c> newTrigger)
    {
       
    } 
    
     //=================================================================================================================   
    public void Update_Margin(List<NI_Project_Backlog__c> newTrigger)
    {
        if (!bpSwitch.Bypass_AH_Project_Backlog_Margin_Calc__c)
        {
        
        system.debug('*** ENTERING NI_ProjectBacklog_TriggerHandler.Update_Margin()'); 
        
        Map<String, AH_Solution_Domain_Attributes__c> mapWS = new Map<String, AH_Solution_Domain_Attributes__c>();
        
        for(AH_Solution_Domain_Attributes__c ahsd : [SELECT Id, Name, Margin__c FROM AH_Solution_Domain_Attributes__c
                                     WHERE Active__c = true])
        {
            mapWS.put(ahsd.Name, ahsd);
        } 
        
        //LOOP THROUGH THE PROJECT BACKLOG RECORDS AND POPULATE THE MARGIN % FIELD
        for (NI_Project_Backlog__c pb : newTrigger)
        {
            //SET THE INITAL MARGIN VALUE TO NULL DURING THE LOOP
            pb.Margin__c = null;
            
            //SEE IF THE PROJECT BACKLOG SOLUTION DOMAIN HAS A MATCHING AH SOLUTION DOMAIN ATTRIBUTE RECORD.
            If(mapWS.containsKey(pb.Solution_Domain__c))
            {
                
                //IF A MATCHING RECORD IS FOUND, UPDATE THE MARGIN % TO MATCH THE AH SOLUTION DOMAIN ATTRIBUTE RECORD
                
                system.debug('SOLUTION DOMAIN MAP: ' + mapWS.get(pb.Solution_Domain__c).Id);
                if(mapWS.get(pb.Solution_Domain__c).Margin__c != null)
                {
                    pb.Margin__c = mapWS.get(pb.Solution_Domain__c).Margin__c;
                }
                
            }
        }        
    }
    }
    
    
    // =================================================================================================
    //  FUNCTIONS
    // =================================================================================================
    public void checkToAllowProjectAsUnplanned(List<NI_Project_Backlog__c> newTrigger){
        system.debug('checkToAllowProjectAsUnplanned');
        Map<ID,Schema.RecordTypeInfo> rtMap = NI_Project_Backlog__c.sObjectType.getDescribe().getRecordTypeInfosById();
        String team;
        String recordType;
        Integer countOfUnplannedProj;
        
        List<Dashboard_Limits__c> dashboardLimits = Dashboard_Limits__c.getAll().values();
        
        List<AggregateResult> allUnplannedProjects; 
		Map<String,Integer> mapAgr = new Map<String,Integer>();
        allUnplannedProjects = [SELECT Project_Type__c, RecordType.Name RecordTypeName, COUNT(Id) totalCount FROM NI_Project_Backlog__c WHERE Unplanned__c = true AND Request_Status__c = 'In Progress' AND Project_Type__c != NULL Group by Project_Type__c, RecordType.Name];                   
        for(AggregateResult ag : allUnplannedProjects ){
			String concatStr = String.valueOf(ag.get('Project_Type__c')) + '-' + String.valueOf(ag.get('RecordTypeName'));
			mapAgr.put(concatStr,Integer.valueOf(ag.get('totalCount')));
		}
		
		Map<String,Integer> mapDashboardCust = new Map<String,Integer>();
		for(Dashboard_Limits__c dashboardLimit : dashboardLimits){
			String concatStr = String.valueOf(dashboardLimit.Team__c) + '-' + String.valueOf(dashboardLimit.Record_Type__c);
			mapDashboardCust.put(concatStr, Integer.valueOf(dashboardLimit.Number_of_Unplanned_Backlogs__c));
		}
		for(NI_Project_Backlog__c newProj : newTrigger){
			
			if(newProj.Unplanned__c == true && 
               newProj.Request_Status__c == 'In Progress' && 
			   newProj.Project_Type__c != null){

			  
				recordType = rtMap.get(newProj.recordTypeID).getName();
				String concatStr = String.valueOf(newProj.Project_Type__c) + '-' + String.valueOf(recordType);
				Integer agrTotalCount = 0;
				if(mapAgr.get(concatStr) != null)
					agrTotalCount = (mapAgr.get(concatStr)+1);
									 
				if(mapDashboardCust.get(concatStr) != null && agrTotalCount > mapDashboardCust.get(concatStr)) {
					newProj.Unplanned__c.addError('There can only be '+ mapDashboardCust.get(concatStr) +' unplanned project(s) for '+newProj.Project_Type__c+' team.');
				}
			}
		}
		
	}
    
    public void checkToAllowProjAsInProgress(List<NI_Project_Backlog__c> newTrigger){
        system.debug('checkToAllowProjAsInProgress');
        Map<ID,Schema.RecordTypeInfo> rtMap = NI_Project_Backlog__c.sObjectType.getDescribe().getRecordTypeInfosById();
        String team;
        String recordType;
        Integer countOfInProgressProj;
        
        List<Dashboard_Limits__c> dashboardLimits = Dashboard_Limits__c.getAll().values();
        
        List<AggregateResult> allInProgressProjects; 
		Map<String,Integer> mapAgr = new Map<String,Integer>();
        Set<String> strStatus=new Set<String>();
        for(NI_Project_Backlog__c newProj : newTrigger){
            strStatus.add(newProj.Request_Status__c);
          }
 
        allInProgressProjects = [SELECT Project_Type__c, RecordType.Name RecordTypeName,Request_Status__c RequestStatus, COUNT(Id) totalCount FROM NI_Project_Backlog__c WHERE Request_Status__c =: strStatus AND Project_Type__c != NULL Group by Project_Type__c, RecordType.Name, Request_Status__c];                   
        
		for(AggregateResult ag : allInProgressProjects ){
			String concatStr = String.valueOf(ag.get('Project_Type__c')) + '-' + String.valueOf(ag.get('RecordTypeName'))  + '-' + String.valueOf(ag.get('RequestStatus'));
			mapAgr.put(concatStr,Integer.valueOf(ag.get('totalCount')));
		}
		
		Map<String,Dashboard_Limits__c> mapDashboardCust = new Map<String,Dashboard_Limits__c>();
		for(Dashboard_Limits__c dashboardLimit : dashboardLimits){
			String concatStr = String.valueOf(dashboardLimit.Team__c) + '-' + String.valueOf(dashboardLimit.Record_Type__c);
			mapDashboardCust.put(concatStr, dashboardLimit);
		}

		
		for(NI_Project_Backlog__c newProj : newTrigger){
			if(newProj.Project_Type__c != null ){
				recordType = rtMap.get(newProj.recordTypeID).getName();
				String concatStr = String.valueOf(newProj.Project_Type__c) + '-' + String.valueOf(recordType) + '-' + String.valueOf(newProj.Request_Status__c);
				String mapDashKey = String.valueOf(newProj.Project_Type__c) + '-' + String.valueOf(recordType) ;
				Integer agrTotalCount = 0;
				if(mapAgr.get(concatStr) != null)
					agrTotalCount = (mapAgr.get(concatStr));
				
				String sText = '';
				sText = String.valueOf(newProj.Request_Status__c);
 								sText = sText.replaceAll( '\\s+', '_');
        						sText += '__c';
//				System.debug(mapDashboardCust);
//				System.debug(mapDashboardCust.get(mapDashKey));
//				System.debug(mapDashboardCust.get(mapDashKey).get(sText));
//				System.debug(mapAgr);
//				System.debug(mapAgr.get(concatStr));
//				System.debug(agrTotalCount);



				if(mapDashboardCust.get(mapDashKey) != null && sText != '' &&
					mapDashboardCust.get(mapDashKey).get(sText) != null &&
					agrTotalCount >= Integer.valueOf(mapDashboardCust.get(mapDashKey).get(sText))) {
					//system.debug('IN IF Condition ' +Integer.valueOf(mapDashboardCust.get(mapDashKey).get(sText)));
					newProj.addError('There can only be '+Integer.valueOf(mapDashboardCust.get(mapDashKey).get(sText)) +' ' + newProj.Request_Status__c+' project(s) for '+newProj.Project_Type__c+' team.');
				}
				
			}
		
		}
		
		
		
		       
		/*for(NI_Project_Backlog__c newProj : newTrigger){
			if(newProj.Project_Type__c != null ){
				team = newProj.Project_Type__c;
				recordType = rtMap.get(newProj.recordTypeID).getName();         
				for(AggregateResult ag : allInProgressProjects ){                       
					for(Dashboard_Limits__c dashboardLimit : dashboardLimits ){                                                 	   
						if((ag.get('Project_Type__c') == dashboardLimit.Team__c) && (ag.get('Name') == dashboardLimit.Record_Type__c)){
							if(dashboardLimit.Team__c==team) {   
								try{
									String sText = String.valueOf(newProj.Request_Status__c);
 									sText = sText.replaceAll( '\\s+', '_');
        							sText += '__c';
									countOfInProgressProj = Integer.valueOf(ag.get('totalCount'));
									if( countOfInProgressProj >= Integer.valueOf(dashboardLimit.get(sText) )){
										newProj.Request_Status__c.addError('There can only be '+ Integer.valueOf(dashboardLimit.get(sText)) +' '+ newProj.Request_Status__c +' Projects for '+team+' team.');
									}
								} catch(Exception e){}                                   
							}
						}
					}               
				}
			}
		}*/
	}
   
       
      public void invokeProjectRollup(List<NI_Project_Backlog__c> newTrigger)
    {   

        Set<Id> setProjectIds = new Set<Id>(); 
       

        for (NI_Project_Backlog__c s : newTrigger)
        {
            setProjectIds.Add(s.Master_Project__c);
        } 
        
        Set<Id> setMasterProjectIds = new Set<Id>(); 

        for (NI_Project_Backlog__c ap : [SELECT Id, Master_Project__c FROM NI_Project_Backlog__c WHERE Id IN : setProjectIds])
        {
            setMasterProjectIds.Add(ap.Master_Project__c); 
        } 
        
        List<NI_Project_Backlog__c> lstMasterProjects = new List<NI_Project_Backlog__c>();
        
        for (NI_Project_Backlog__c aps : [SELECT Id, Invoke_Rollups__c FROM NI_Project_Backlog__c WHERE Id IN : setMasterProjectIds])
        {
            aps.Invoke_Rollups__c = true;
            lstMasterProjects.Add(aps);
        }
        
        Database.Update(lstMasterProjects);        
        
    }
        
    public void cloneNIProjectTasks(List<NI_Project_Backlog__c> newTrigger){
        for (NI_Project_Backlog__c s : newTrigger) {
            if(s.Custom_Record_Id__c != null && s.Custom_Record_Id__c != ''){
                // If project is cloned by user oldRecordId will be custom record id i.e. old project id
          		oldRecordId = s.Custom_Record_Id__c;
                newRecordId = s.id;
      		}
        }
        if(oldRecordId !='' && newRecordId!=''){
         //It get executed when Custom_Record_Id__c field is present i.e. user has clicked 'clone w/task'
         cloneItems();
      }	
    
    }
    
   /**
    * Thic function auto creates tasks for project type added in custom settings "Auto-Create NI Project Tasks Settings"
    * This function is developed to support bulk operation but with an assumption that 
    * maximum 5 task will be created per project and maximum 4000 can be processed at a time.
    *
    * @param list<Product_Distribution__c> newTrigger List of product distribution record to process
    * @param Map<Id,Product_Distribution__c> oldMapTrigger Map of old data
    * @author Kasim badami
    * @return void
    * @Created On : 
    * @Last modified By : Kasim
    * @Last modified on : 04/27/2016
    */
    

    
    public void AutoCreateNIProjectTasks(List<NI_Project_Backlog__c> newTrigger){
      Set<Id> setProjectIds = new Set<Id>(); 
     // Set<Id> setCloneProjectIds = new Set<Id>(); 
     String setCloneProjectIds;
     newRecordId = '';
     oldRecordId = '';
     system.debug('newTrigger'+newTrigger);  
      for (NI_Project_Backlog__c s : newTrigger)
      {
          //&& s.Project_Type__c=='Business Systems'
          system.debug('record id==>' + s.Custom_Record_Id__c);
          system.debug('Total_Project_Tasks__c=>' + s.Project_Level_LOE__c);
          
          
          if(s.Custom_Record_Id__c == null || s.Custom_Record_Id__c == '') {
              // If Custom record id is not present new project is created 
              if(s.Project_Level_LOE__c != NULL && s.Total_Project_Tasks__c == 0 ){
                  setProjectIds.Add(s.id);
              }
      		} 
      }
      
     
    
        
          //Map<String_dataset_name, CustomSettingName__c> mcs = CustomSettingName__c.getAll();
          //It get executed when user has created new record
          Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.NI_Project_Backlog_Tasks__c ; 
          Map<String,Schema.RecordTypeInfo> TaskRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
          
          Schema.DescribeSObjectResult cfrSchemaProject = Schema.SObjectType.NI_Project_Backlog__c; 
          Map<String,Schema.RecordTypeInfo> ProjectRecordTypeInfo = cfrSchemaProject.getRecordTypeInfosByName();
          
          
          Decimal estimatedHour =0 ;
          integer counter = 0;
          integer list_size = 40;
          // set query offset to 40
          integer setSize = setProjectIds.size();
          Decimal limitToLoop = setSize / list_size ;
          decimal roundedLimitToLoop  = limitToLoop.setScale(0, RoundingMode.CEILING);
          system.debug(roundedLimitToLoop +'===roundedLimitToLoop');
          list<NI_Project_Backlog_Tasks__c > taskToAdd;
          integer autoTaskcount = database.countQuery('SELECT count() FROM Auto_Create_NI_Project_Tasks_Settings__c where Active__c  = true');
          system.debug('autoTaskcount=='+autoTaskcount);
          string taskName;
          string taskPhase;
          string assignedUser;
          Map<string, Auto_Create_NI_Project_Tasks_Settings__c> autoTaskSetting = Auto_Create_NI_Project_Tasks_Settings__c.getAll();
          if(setSize > 0 && autoTaskcount > 0){
                integer counttemp = 0;
              for(integer i=0; i <=roundedLimitToLoop  ;i++){
                system.debug('counttemp==='+counttemp);
                  taskToAdd = new list<NI_Project_Backlog_Tasks__c>();
                  integer queryOffset = i*list_size;
                  system.debug('i===='+i+'sql===select recordtypeid ,id, name,Project_Type__c,Project_Level_LOE__c from NI_Project_Backlog__c where Id IN '+setProjectIds+' order by createddate  limit '+list_size+' offset '+queryOffset);
                  List<NI_Project_Backlog__c> NIProjects = [select recordtypeid ,id, name,Project_Type__c,Project_Level_LOE__c from NI_Project_Backlog__c where Id IN :setProjectIds order by createddate  limit :list_size offset :queryOffset ];
                  if(NIProjects.size() > 0){
                      for( NI_Project_Backlog__c NIProjectsHeap :NIProjects){
                             //taskToAdd = new list<NI_Project_Backlog_Tasks__c>();
                            NI_Project_Backlog_Tasks__c objTask;  
                            for (string name : autoTaskSetting.keySet())
                            {
                                Id prRecid = ProjectRecordTypeInfo.get(autoTaskSetting.get(name).Project_Record_Type__c).getRecordTypeId();
                                
                                Id taskRecid = TaskRecordTypeInfo.get(autoTaskSetting.get(name).Task_Record_Type__c).getRecordTypeId();
                                if(autoTaskSetting.get(name).active__c == true && autoTaskSetting.get(name).Team__c== NIProjectsHeap.Project_Type__c && NIProjectsHeap.recordtypeid == prRecid){
                                    taskName = NIProjectsHeap.name+' ('+autoTaskSetting.get(name).Phase__c+')';
                                    estimatedHour = (NIProjectsHeap.Project_Level_LOE__c/autoTaskcount);
                                    taskPhase = autoTaskSetting.get(name).Phase__c;
                                    assignedUser = autoTaskSetting.get(name).Assigned_To_User_ID__c;
                                    objTask= new NI_Project_Backlog_Tasks__c (RecordTypeId=taskRecid ,NI_Project_Backlog_Item__c=NIProjectsHeap.id,name=taskName,Assigned_To__c=assignedUser,Project_Phase__c=taskPhase,Task_Estimate_hrs__c=estimatedHour.setScale(1));
                                    taskToAdd.add(objTask); 
                                }
                            }
                        }
                        insert taskToAdd;
                        system.debug('taskToAdd==='+taskToAdd);
                   }
                   counttemp++;
               }
            }
     
    }
  
    private void rollupSummaries(List<NI_Project_Backlog__c> newTrigger)
    {

        // Set of project Ids        
        Set<Id> setProjectIds = new Set<Id>(); 
    
        ///Get the projects and check if it is invloved in update process
        //If invloved, set child project fields to 0 for update
        for (NI_Project_Backlog__c p : newTrigger)
        {
            System.debug('*** parent *** '+p.Name);
            if (p.Invoke_Rollups__c)
            {    
                System.debug('*** invoke rollup *** ');            
                setProjectIds.Add(p.Id); 
                
                p.Child_Project_Estimated_LOE_hrs__c = 0.0; 
                p.Child_Project_Actual_LOE_hrs__c = 0.0; 
                p.Child_Project_Remaining_LOE_hrs__c = 0.0; 
                
                p.Child_Project_Task_Hours_Design__c = 0.0; 
                p.Child_Project_Task_Hours_Development__c = 0.0; 
                p.Child_Project_Task_Hours_Support__c = 0.0; 
                
                p.Child_Project_Task_Hours_Validation__c = 0.0; 
                
                p.Invoke_Rollups__c = false;
                
            } 
        } 

        // Get all child projects summed up by rollup fields
        AggregateResult[] groupedResults = 
            [SELECT Master_Project__c, 
             SUM(Estimated_Hours__c), 
             SUM(Total_Actual_Hours__c), 
             SUM(Remaining_Hours__c), 
             SUM(Design_Hours__c), 
             SUM(Development_Hours__c), 
             SUM(Support_Hours__c),  
             SUM(Validation_Hours__c)             
             FROM NI_Project_Backlog__c 
             WHERE Master_Project__c IN : setProjectIds
             GROUP BY Master_Project__c]; 

        //Loop through project backlogs and add total values from child projects to child project fields
        for (NI_Project_Backlog__c s : newTrigger)
        {            
            System.debug('*** inside cal *** ');
            for (AggregateResult ar : groupedResults)  
            {
                System.debug('*** master *** '+ar.get('Master_Project__c') + ' *** s.Id *** '+s.Id);
                if (ar.get('Master_Project__c') == s.Id)
                {
                    System.debug('*** master id matches *** ');  
                    System.debug('*** est *** '+ar.get('expr0'));
                    System.debug('*** act *** '+ar.get('expr1'));
                    System.debug('*** rem *** '+ar.get('expr2'));
                    System.debug('*** des *** '+ar.get('expr3'));
                    System.debug('*** dev *** '+ar.get('expr4'));
                    System.debug('*** sup *** '+ar.get('expr5'));
                    System.debug('*** val *** '+ar.get('expr6'));
                                      
                    s.Child_Project_Estimated_LOE_hrs__c = Double.valueOf(ar.get('expr0')); 
                    s.Child_Project_Actual_LOE_hrs__c = Double.valueOf(ar.get('expr1')); 
                    s.Child_Project_Remaining_LOE_hrs__c = Double.valueOf(ar.get('expr2')); 
                    s.Child_Project_Task_Hours_Design__c = Double.valueOf(ar.get('expr3')); 
                    s.Child_Project_Task_Hours_Development__c = Double.valueOf(ar.get('expr4')); 
                    s.Child_Project_Task_Hours_Support__c = Double.valueOf(ar.get('expr5')); 
                    s.Child_Project_Task_Hours_Validation__c = Double.valueOf(ar.get('expr6')); 
                    
                    System.debug('*** after *** ');  
                    System.debug('*** est *** '+Double.valueOf(ar.get('expr0')));
                    System.debug('*** act *** '+Double.valueOf(ar.get('expr1')));
                    System.debug('*** rem *** '+Double.valueOf(ar.get('expr2')));
                    System.debug('*** des *** '+Double.valueOf(ar.get('expr3')));
                    System.debug('*** dev *** '+Double.valueOf(ar.get('expr4')));
                    System.debug('*** sup *** '+Double.valueOf(ar.get('expr5')));
                    System.debug('*** val *** '+Double.valueOf(ar.get('expr6')));
                    
                }       
            }             
        } 
        
    }
    
    /**
    * This function is used to clone project with its related task.
    * @author Nidhi Singh
    * @return void
    * @Created On : 08/02/2016
    * @Last modified By : Nidhi
    * @Last modified on : 08/02/2016
    */
     public void cloneItems() {
       // setup the save point for rollback
        Savepoint sp = Database.setSavepoint();
        NI_Project_Backlog__c newProjBacklog;
        taskBacklogId = new List<String>();
        newtaskBacklogId = new Map<String, String>();
        oldtaskBacklogId = new Map<String, String>();
        
         try {
             
             cloneProjectNotesAttchment();
             //Clone Task and copy its notes and attachment
             String projectTaskFields = getFields('NI_Project_Backlog_Tasks__c');
             List<NI_Project_Backlog_Tasks__c> items = new List<NI_Project_Backlog_Tasks__c>();
             String TaskQuery = 'SELECT ' + projectTaskFields + ' FROM NI_Project_Backlog_Tasks__c p where NI_Project_Backlog_Item__c=\'' + oldRecordId+'\'';
          
             LIST<NI_Project_Backlog_Tasks__c> taskItems = Database.query(TaskQuery);   
             if(taskItems.size()>0){
                 
                 for (NI_Project_Backlog_Tasks__c pi : taskItems) {   
                               
                     NI_Project_Backlog_Tasks__c newPI = pi.clone();
                     newPI.Status__c = 'Not Started';
                     newPI.Hours_Remaining__c = newPI.Task_Estimate_hrs__c;
                     newPI.Sprint__c =null;
                     newPI.Committed__c=false;
                     newPI.Hours__c=0;   
                     newPI.Due_Date__c=Date.today().addDays(14);
                     newPI.NI_Project_Backlog_Item__c = newRecordId;
                     newPI.Task_ID__c = null;
                     taskBacklogId.add(pi.Id);
                     oldtaskBacklogId.put(pi.Id, newPI.Name);
                     
                     items.add(newPI);
                 }
                 insert items;
              
                 for(NI_Project_Backlog_Tasks__c newItemId : items) {
                     newtaskBacklogId.put(newItemId.Name, newItemId.Id);
                 }              
                 cloneTaskNotesAttchment(); 
                 
                 ID idproj = Id.valueOf(newRecordId);
                 NI_Project_Backlog__c updateProject = new NI_Project_Backlog__c(Id = idproj,
                                                             Custom_Record_Id__c = ''                              
                 											);
                 update updateProject;
         }    

         } catch (Exception e){  
            // roll everything back in case of error 
            system.debug('line number==='+e.getLinenumber()+'message=='+e.getmessage());
            Database.rollback(sp);
           // ApexPages.addMessages(e);
        
         }

  }
    
        public String getFields(String objectName) {
        String SobjectApiName = objectName;
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
 
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        return commaSepratedFields;
    }
    
    //Method called from cloneItems to clone Notes and attachment of Project
    public void cloneProjectNotesAttchment() {
        // copy attachments of project:
        List<Attachment> insertingAttachments = new List<Attachment>();
        List<Attachment> lstAttachments = [SELECT Id, Body, Name, ParentId, LastModifiedDate, contentType, OwnerId FROM Attachment WHERE ParentId = :oldRecordId];

        for (Attachment att : lstAttachments){
            Attachment  newattch = new Attachment();  
            newattch = att.clone(false);
            newattch.body = att.body; 
            newattch.name = att.name;            
            newattch.OwnerId=att.OwnerId;                           
            newattch.parentId = newRecordId;
            insertingAttachments.add(newattch);                           
       }
        
        if (insertingAttachments.size() > 0){
            insert  insertingAttachments;         
        }    
        //copy Notes of project:
        List<Note> insertingNotes = new List<Note>();
        List<Note> lstNotes = [SELECT Id, Title, ParentId, LastModifiedDate, createdbyid, body FROM Note where ParentId = :oldRecordId];
        
        for (Note eachNote : lstNotes){
            Note newDemandNote= new Note();
            newDemandNote = eachNote.clone(false);
            newDemandNote.Body = eachNote.Body;                            
            newDemandNote.Title=eachNote.Title;   
            newDemandNote.ParentId = newRecordId;        
            insertingNotes.add(newDemandNote);                            
        }
       
        if (insertingNotes.size() >0){
            insert insertingNotes;
            }        
        } 
    //Method called from cloneItems to clone Notes and attachment of task
    public void cloneTaskNotesAttchment() {
        // copy attachments:
        List<Attachment> insertingAttachments = new List<Attachment>();
        List<Attachment> lstAttachments = [SELECT Id, Body, Name, ParentId, LastModifiedDate, contentType, OwnerId FROM Attachment WHERE ParentId IN :taskBacklogId];
        
        for (Attachment att : lstAttachments){
            Attachment  newattch = new Attachment();  
            newattch = att.clone(false);
            newattch.body = att.body; 
            newattch.name = att.name;            
            newattch.OwnerId=att.OwnerId;                           
            newattch.parentId = newtaskBacklogId.get(oldtaskBacklogId.get(att.ParentId));
            insertingAttachments.add(newattch);                           
       }
        
        if (insertingAttachments.size() > 0){
            insert  insertingAttachments;         
        }    
    // copy Notes:
        List<Note> insertingNotes = new List<Note>();
        List<Note> lstNotes = [SELECT Id, Title, ParentId, LastModifiedDate, createdbyid, body FROM Note where ParentId In :taskBacklogId];
        
        for (Note eachNote : lstNotes){
            Note newDemandNote= new Note();
            newDemandNote = eachNote.clone(false);
            newDemandNote.Body = eachNote.Body;                            
            newDemandNote.Title=eachNote.Title;   
            newDemandNote.ParentId = newtaskBacklogId.get(oldtaskBacklogId.get(eachNote.ParentId));        
            insertingNotes.add(newDemandNote);                            
        }
       
        if (insertingNotes.size() >0){
            insert insertingNotes;
            }        
        } 

    
}