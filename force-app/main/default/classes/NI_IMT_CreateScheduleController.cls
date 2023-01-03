/************************************************************************************************
Name            : NI_IMT_CreateScheduleController Class
Author          : Damodar Raut
Created Date    : 04/05/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that is used to create schedule and assignments
                : 
*************************************************************************************************/
public class NI_IMT_CreateScheduleController {
    
    public List<String> projIds {get;set;}
    public List<pse__Proj__c> projDetails {get;set;}
    public List<AssignmentWrapper> assignmentList{get;set;}
    public String migrationSetId{get;set;}
    public String status {get;set;}
    public static Profile proDetail{get;set;}    
    public String assignmentResource {get;set;}
    public Integer maxProjectAssignments {get;set;}
    public Decimal timeSpan {get;set;}
    
    public NI_IMT_CreateScheduleController() {
        string projectIds = ApexPages.currentPage().getParameters().get('Ids');
        system.debug(projectIds);system.debug(projectIds.length());
        //projectIds = projectIds.removeStart('(');
        projectIds = projectIds.removeEnd('|');
        //projIds = projectIds.split(',[\\s]*');
        projIds = projectIds.split(':');
        system.debug(projIds);system.debug(projIds.size());
        migrationSetId = Apexpages.currentPage().getParameters().get('migrationSetID');
        IMT_Migration_Set__c schSet = [SELECT RecordType.Name FROM IMT_Migration_Set__c WHERE Id = :migrationSetId LIMIT 1];
        String schedulingSetRecordTypeName = schSet.RecordType.Name;
        assignmentResource = String.valueOf(IMT_Scheduling_Set_Config__c.getValues(schedulingSetRecordTypeName).get('Resource__c'));
        maxProjectAssignments = Integer.valueOf(IMT_Scheduling_Set_Config__c.getValues(schedulingSetRecordTypeName).get('Number_of_Assignments_per_Project__c'));
        timeSpan = (decimal) IMT_Scheduling_Set_Config__c.getValues(schedulingSetRecordTypeName).get('Timezone_Limit__c');
        proDetail = getProfileDetail();        
        if(proDetail != null && 
           ( NI_IMT_Assignment_Settings__c.getValues('Default').get('Regional_Admin_Profile_Name__c') == proDetail.Name ||
           	 NI_IMT_Assignment_Settings__c.getValues('Default').get('Implementation_Lead_Profile_Name__c') == proDetail.Name)){
           	
        	status =  'Tentative';  	
        } else{
        	status = 'Scheduled';
        }
    }
    
    public void init() {
       projDetails = [SELECT IMT_Property__r.IMT_Complexity_Value__c,Name,IMT_Property__r.Timezone__c FROM pse__Proj__c WHERE Id in :projIds]; 
       assignmentList = new List<AssignmentWrapper>();
        for(pse__Proj__c pro : projDetails)
        {               
            AssignmentWrapper pwrap = new AssignmentWrapper();
            pwrap.proj  = pro;
            pwrap.scheduleTime = '';
            assignmentList.add(pwrap);                
        } 
    }
    public Profile getProfileDetail(){
    	if(proDetail == null){    		
    		return [Select Id, Name From Profile where id = :UserInfo.getProfileId()];
    	} else{
    		return proDetail;
    	}
    }
    
    public PageReference createAssignment() {
       //CREATE SCHEDULE AND ASSIGNMENTS FOR THE SELECTED PROJECTS 
       system.debug('Data is' + assignmentList+migrationSetId);
       List<pse__Assignment__c> activeProjects = [SELECT pse__Project__c FROM pse__Assignment__c WHERE pse__status__c IN ('Scheduled', 'Tentative', 'Completed') AND pse__Project__c IN :projIds];
       if(activeProjects.size() == maxProjectAssignments) {
       		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'The maximum number of scheduled/tentative schedules that can be added per project is ' + maxProjectAssignments));
       		return null;
       }
       IMT_Migration_Set__c mig = [SELECT OwnerId,Start__c, End__c,Max_Timezone_Offset__c,Min_Timezone_Offset__c,Time_Zone_Span__c FROM IMT_Migration_Set__c WHERE id =:migrationSetId LIMIT 1];
        //CREATE SCHEDULE
        List<pse__Schedule__c> schedules = new List<pse__Schedule__c>();
        for(AssignmentWrapper wrap :assignmentList) {
            Decimal hours = 0;
            if(wrap.proj.IMT_Property__r.IMT_Complexity_Value__c != null)
                hours = wrap.proj.IMT_Property__r.IMT_Complexity_Value__c;
            pse__Schedule__c sch = new pse__Schedule__c (
                pse__Start_Date__c = mig.Start__c,
                pse__End_Date__c = mig.Start__c,
                pse__Monday_Hours__c = hours,
                pse__Tuesday_Hours__c = hours,
                pse__Wednesday_Hours__c = hours,
                pse__Thursday_Hours__c = hours,
                pse__Friday_Hours__c = hours,
                pse__Saturday_Hours__c = hours,
                pse__Sunday_Hours__c = hours,
                IMT_Project__c = wrap.proj.Id,
                IMT_Migration_Set__c = mig.Id
            );
            schedules.add(sch);
        }
        system.debug('Schedules' + schedules);
        insert schedules;
        //SELECT MIGRATION OPERATOR
        Contact operator = [SELECT Id,name FROM Contact WHERE name = :assignmentResource LIMIT 1];
        
        List<pse__Schedule__c> schdList = [SELECT IMT_Project__r.RecordType.Name,IMT_Project__r.pse__Project_Manager__c  from pse__Schedule__c where IMT_Migration_Set__c = :mig.Id AND IMT_Project__c in :projIds];
        system.debug(schdList.size());
        List<pse__Assignment__c> assignList = new List<pse__Assignment__c>();
        //MAX AND MIN TIMEZONE OFFSET
        Decimal maxOffset;
        Decimal minOffset;
        
        if(mig.Max_Timezone_Offset__c != null) {
            maxOffset = mig.Max_Timezone_Offset__c;
        }
        else {
            maxOffset = 25;
        }
        
        if(mig.Min_Timezone_Offset__c != null) {
            minOffset = mig.Min_Timezone_Offset__c;
        }
        else {
            minOffset = 25;
        }
        
        for(AssignmentWrapper wrap :assignmentList) {
            for(pse__Schedule__c sc :schdList) { 
                if(wrap.Proj.Id == sc.IMT_Project__c) {
                    //CALCULATE GMT DATE TIME
                    Decimal offset = 0;
                    String offsetStr = wrap.Proj.IMT_Property__r.Timezone__c.substringBetween('( GMT ',' )');
                    offset = Decimal.valueOf(offsetStr);
                    Integer mins = Integer.valueOF(offset*60*-1);
                    //As per requirement assignment scheduled local time will be 10 pm
                    DateTime localDateTime = DateTime.newInstance(mig.Start__c.year(), mig.Start__c.month(), mig.Start__c.day(), 22, 0, 0);
                    DateTime gmtDateTime = localDateTime.addMinutes(mins);
                    
                    //CALCULATE MAX MIN OFFSET
                    if(maxOffset == 25) {
                    	maxOffset = offset;  
                    }
                    else if(offset > maxOffset){
                    	maxOffset = offset;     
                    }
                    
                    if(minOffset == 25) {
                    	minOffset = offset;  
                    }
                    else if(offset < minOffset){
                    	minOffset = offset;     
                    }
                    
                    pse__Assignment__c assign1 = new pse__Assignment__c(
                        Name = wrap.Proj.Name,
                        pse__Bill_Rate__c = 0,
                        pse__Schedule__c = sc.Id,
                        pse__Project__c = sc.IMT_Project__c,
                        pse__Resource__c = operator.Id,
                        pse__Status__c = status,
                        IMT_Migration_Set__c = mig.Id,
                        Local_Date_Time__c = localDateTime,
                        Scheduled_DateTime_GMT__c = gmtDateTime,
                        Project_Record_Type__c = sc.IMT_Project__r.RecordType.Name,
                        Project_Manager__c =  sc.IMT_Project__r.pse__Project_Manager__c
                    );
                    assignList.add(assign1);
                }
        	}
        }
        
        mig.Max_Timezone_Offset__c = maxOffset;
        mig.Min_Timezone_Offset__c = minOffset;
        update mig;
        
        if(Math.abs(maxOffset - minOffset) > timeSpan && maxOffset != 25 && minOffset != 25) {
        	for(pse__Assignment__c assgn :assignList) {
        		assgn.pse__Status__c = 'Tentative';
        	}	
        }
        
        system.debug('assignList' + assignList);
        try {
        	insert assignList;
        } catch (DMLException e) {
        	delete schdList;
        	ApexPages.addMessages(e);
        	return null;
        } 
        system.debug(LoggingLevel.Error, UserInfo.getProfileId());
        Profile pro = getProfileDetail();
        if(Math.abs(maxOffset - minOffset) > timeSpan && maxOffset != 25 && minOffset != 25) {
        	
        	for(pse__Assignment__c asg : assignList){
        		executeApprovalProcess(asg,'IMT_Approve_Assignment_Time_Difference');		        	
        	}
        }  
        
        //Implementation lead profile
        else if(pro.Name == NI_IMT_Assignment_Settings__c.getValues('Default').get('Implementation_Lead_Profile_Name__c')){
        	for(pse__Assignment__c pasg : assignList){
        		if(pasg.pse__Status__c == 'Tentative'){
        			executeApprovalProcess(pasg,'IMT_Approve_Assignment_Created_By_Lead');		        	
        		}
        	}
        }
        
        //Implementation Regional Admin profile
        else if(pro.Name == NI_IMT_Assignment_Settings__c.getValues('Default').get('Regional_Admin_Profile_Name__c')){
        	for(pse__Assignment__c pasg : assignList){
        		if(pasg.pse__Status__c == 'Tentative'){
		        	executeApprovalProcess(pasg,'IMT_Approve_Assignment_Created_Regional');
        		}
        	}
        }        
          
        return new PageReference('/'+migrationSetId);
    }
    
    public class AssignmentWrapper{
        public pse__Proj__c proj {get;set;}
        public String scheduleTime {get;set;}
        
        AssignmentWrapper(){ }
    }
    
    public void executeApprovalProcess(pse__Assignment__c pasg, String processName){
    	// Create an approval request 
    	system.debug(LoggingLevel.Error,pasg);
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(pasg.Id);
        
        system.debug(LoggingLevel.Error,pasg.OwnerId);
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(pasg.OwnerId); 
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId(processName);
        req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        system.debug(LoggingLevel.Error,result);
    }
}