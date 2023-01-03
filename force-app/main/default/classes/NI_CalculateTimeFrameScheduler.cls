/****************************************************************************************
Name            : NI_CalculateTimeFrameScheduler
Author          : Sunita Mittal
Created Date    : 11/26/2015
Last Mod Date   : 7/12/2017 
Last Mod By     : Ria Chawla
NICC Reference  : 
Description     : Class that calculates Projected Date for projects
				  Controller for NI_UpdateProjectionsPage
: 
: 
******************************************************************************************/
global class NI_CalculateTimeFrameScheduler implements Schedulable
{
    public List<SelectOption> projTeams {get; set;}
    public List<SelectOption> projRecTypes {get; set;}
    public String selectedRecType {get; set;}
    public String selectedTeam {get; set;}
    public List<NI_Project_Backlog__c> projectsList{get; set;}
    public boolean disableButton {get; set;}
    ApexPages.StandardSetController setCon{get; set;}
    
    Date target_date = Date.today();
    Date ProjectedDate = Date.today();
    Date maxCompletionDate = Date.today();
    NI_Sprint__c sprint;
    Boolean findSprint = False;
   
    List <NI_Sprint__c> spList = [select name, Daily_Velocity__c, Sprint_Start_Date__c, Sprint_Completion_Date__c from NI_Sprint__c where Sprint_Completion_Date__c > :target_date order by Sprint_Completion_Date__c ASC];
    Date maxSprintCompletiondate = spList[spList.size()-1].Sprint_Completion_Date__c;
       
    public NI_CalculateTimeFrameScheduler(){}
    
    public NI_CalculateTimeFrameScheduler(ApexPages.StandardSetController controller) {
        //setCon=controller;
    }
    
     public NI_CalculateTimeFrameScheduler(ApexPages.StandardController controller) {
        //setCon=controller;
    }
    
    
    // method to find the concerned sprint
    public NI_Sprint__c calSprint(Date dt)
    {   
        Integer dailyVelocity = 0;
        for(NI_Sprint__c sp : spList)
        {
            system.debug('sp'+sp);
            if (sp.Sprint_Start_Date__c <= dt && sp.Sprint_Completion_Date__c >= dt)
            {                                
                findSprint = true;
                sprint = sp;
                break;
            }            
            else
            {  sprint = null;  }
        }             
        return sprint; 
    }
        
    public void execute(SchedulableContext SC)
    {                    
        calProjDate();
        nullProjectedDates();
    }
       
    //method to calculate the projected date of projects
    public void calProjDate()
    {
        //ADDED BY RIA
        disableButton= true;
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Projections are being calculated and could take several minutes.');
         ApexPages.addMessage(myMsg);
        system.debug('selectedRecType'+selectedRecType);
       	system.debug('selectedTeam'+selectedTeam);
        List<NI_Project_Backlog__c> projectsList = new List<NI_Project_Backlog__c>();
        if(selectedRecType != null && selectedTeam != null && selectedTeam != '--None--' ){
            projectsList = [SELECT id, Name, Request_Status__c,Remaining_LOE__c, Project_Level_LOE__c,
                            Prioritization_Score__c, Projected_Date__c, RecordType.Name 
                            from NI_Project_Backlog__c 
                            where (Request_Status__c ='In Progress' Or Request_Status__c = 'Backlog Item') 
                            AND Total_Project_Tasks__c > 0 AND 	RecordType.Name = :selectedRecType
                            AND Project_Type__c = :selectedTeam
                            order by Prioritization_Score__c DESC]; 
        }
        else if(selectedRecType != null){
            projectsList = [SELECT id, Name, Request_Status__c,Remaining_LOE__c, Project_Level_LOE__c,
                            Prioritization_Score__c, Projected_Date__c, RecordType.Name  
                            from NI_Project_Backlog__c 
                            where (Request_Status__c ='In Progress' Or Request_Status__c = 'Backlog Item') 
                            AND Total_Project_Tasks__c > 0 AND 	RecordType.Name = :selectedRecType
                            order by Prioritization_Score__c DESC];
        }
        else{
            projectsList =  [SELECT id, Name, Request_Status__c,Remaining_LOE__c, Project_Level_LOE__c,
                             Prioritization_Score__c, Projected_Date__c from NI_Project_Backlog__c where (Request_Status__c ='In Progress' Or Request_Status__c = 'Backlog Item') 
                             AND Total_Project_Tasks__c > 0 AND Project_Type__c = 'Business Systems'
                             order by Prioritization_Score__c DESC];
        }
        system.debug('projectsList'+projectsList);
        
        //loop around each eligible project to calculate its projected date    
        /*for(List<NI_Project_Backlog__c> allProjs : [SELECT id, Name, Request_Status__c,Remaining_LOE__c, Project_Level_LOE__c,Prioritization_Score__c, 
                                                  Projected_Date__c from NI_Project_Backlog__c where (Request_Status__c ='In Progress' Or Request_Status__c = 'Backlog Item') 
                                                  AND Total_Project_Tasks__c > 0 AND Project_Type__c = 'Business Systems' order by Prioritization_Score__c DESC
                                                 ]) */
        List<NI_Project_Backlog__c> projList = new List <NI_Project_Backlog__c>();
        Set<NI_Project_Backlog__c> projSet = new Set <NI_Project_Backlog__c>();
        List<NI_Project_Backlog__c> updatedproj = new List <NI_Project_Backlog__c>();
        	//for(NI_Project_Backlog__c proj : allProjs)
        for(NI_Project_Backlog__c proj : projectsList){   
            System.debug('Projects ::'+ proj);
            Integer velocity; 
            NI_Sprint__c projectSprint = calSprint(ProjectedDate);
            if(projectSprint != Null)
            {
                velocity = Integer.valueOf(projectSprint.Daily_Velocity__c);            
                if (velocity != 0 && velocity != Null && findSprint)
                {                   
                    if(proj.Request_Status__c == 'In Progress')
                    {
                        Decimal remainLOE = (proj.Remaining_LOE__c == null) ? 0.0: proj.Remaining_LOE__c;
                        ProjectedDate = noOfWeekends(ProjectedDate,Integer.valueOf(remainLOE / velocity));
                    }        
                    else if(proj.Request_Status__c == 'Backlog Item')
                    { 
                        Decimal projLOE = (proj.Project_Level_LOE__c == null) ? 0.0: proj.Project_Level_LOE__c;
                        ProjectedDate = noOfWeekends(ProjectedDate , Integer.valueOf(projLOE / velocity));
                    }                
                }
                else
                {
                    ProjectedDate = projectSprint.Sprint_Completion_Date__c;
                }
                if(ProjectedDate > maxSprintCompletiondate)
                    ProjectedDate = maxSprintCompletiondate;
            }                
                else 
                {   system.debug('in else for proj ::'+ proj.name);
                    ProjectedDate = maxSprintCompletiondate;                
                }  
                system.debug('ProjectedDate ::'+ ProjectedDate);           
                proj.Projected_Date__c = string.valueOf(ProjectedDate.Month()) + '/' +String.valueOf(ProjectedDate.Year());
                projSet.add(proj);
            }
            updatedproj.addAll(projSet);
            system.debug('updatedproj ::'+ updatedproj);
            update updatedproj;  
        //disableButton= false;
        //}                              
    }
    
     webservice static void projectedDateCal()
    {
        NI_CalculateTimeFrameScheduler cal = new NI_CalculateTimeFrameScheduler ();
        cal.calProjDate();
        cal.nullProjectedDates();
    }
       
    //adding only working days
    public Date noOfWeekends(Date StartDate  , Integer AdditionDay)
    {   
        Integer NoOfWeekends = 0 ;
        Date startOfWeek = StartDate.toStartOfWeek();
        
        //Day difference count in between the dates
        Integer dayOfWeek  = startOfWeek.daysBetween(StartDate);
 
        NoOfWeekends =  (AdditionDay/5)*2 +  ( (dayOfWeek + Math.mod(AdditionDay , 5)) > 5 ? 2 : 0 );       
        AdditionDay = AdditionDay + noOfWeekends ;
        return StartDate.addDays(AdditionDay) ; 
    }
    
    //null out projected dates for no more eligible projects
    public void nullProjectedDates()
    {
        List <NI_Project_Backlog__c> projects = [Select Projected_Date__c from NI_Project_Backlog__c where Request_Status__c NOT IN ('In Progress','Backlog Item') And Projected_Date__c != null];
        system.debug('projects'+projects);
        List <NI_Project_Backlog__c> toUpdate = new List<NI_Project_Backlog__c>();
        if(!projects.isEmpty())
        {
            for(NI_Project_Backlog__c pr : projects)
            {
                pr.Projected_Date__c = null;
                toUpdate.add(pr);
            }
        update toUpdate;
        }    
    }  
    
    webservice static void scheduleThis()
    {
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(10);
 
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
      
        NI_CalculateTimeFrameScheduler notifySchedule = new NI_CalculateTimeFrameScheduler ();        
        System.schedule('Projected date Schedule' + sysTime.getTime(),chron_exp, notifySchedule);
    }
    
    //ADDED BY RIA
    //WHEN PAGE LOADS, THIS FUNCTION IS CALLED TO POPULATE RECORD TYPE PICKLIST ON VF PAGE
       public List<SelectOption> getAllRecTypes(){
           system.debug('in getAllRecTypes');
        projRecTypes = new List<SelectOption>();
        List<RecordType> recTypes = new List<RecordType>([select id, name from recordtype 
                                                          where sobjecttype='NI_Project_Backlog__c']);
        for(RecordType rt : recTypes){
            projRecTypes.add(new SelectOption(rt.Name, rt.Name));
        }
        return projRecTypes;
    }
    
    //WHEN RECORD TYPE IS SELECTED THIS FUNCTION IS CALLED TO GET TEAMS FOR SELECTED RECORD TYPE FROM CUSTOM SETTINGS
     public PageReference getTeams(){
         disableButton= false;
         system.debug('in getTeams()');
        projTeams = new List<SelectOption>();
        List<String> teamsList = new List<String>();
         
        List<Project_Backlog_Record_Types__c> projRecWithTeam = Project_Backlog_Record_Types__c.getAll().values();
         Project_Backlog_Record_Types__c recTypeWithTeam = new Project_Backlog_Record_Types__c();
         if(selectedRecType != null){
             recTypeWithTeam = Project_Backlog_Record_Types__c.getValues(selectedRecType);
         }
    
         teamsList = recTypeWithTeam.Teams__c.split(',');
         for(String t : teamsList){
              projTeams.add(new SelectOption(t, t)); 
         }
        return null;
    }
    
    //WHEN SUBMIT BUTTON IS CLICKED THIS FUNCTION IS CALLED
    public PageReference doSubmit(){
        disableButton= true;
        calProjDate();
        nullProjectedDates();
        return null;
    }
    //WHEN CANCEL BUTTON IS CLICKED THIS FUNCTION IS CALLED
    public PageReference doCancel(){
         Schema.DescribeSObjectResult result = NI_Project_Backlog__c.SObjectType.getDescribe(); 
  		PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
  		pageRef.setRedirect(true); 
  		return pageRef; 
    }
}