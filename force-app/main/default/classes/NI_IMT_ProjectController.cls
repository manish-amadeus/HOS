/************************************************************************************************
Name            : NI_IMT_ProjectController Class
Author          : Damodar Raut
Created Date    : 04/05/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that is used to select multiple projects and schedule them
                : 
*************************************************************************************************/
public with sharing class NI_IMT_ProjectController {
    private string soql{get;set;}
    public integer offsetSize = 0;
    public integer limitSize{get;set;}
    private Id imtProjRecordTypeId;
    public List<ProjectWrapper> projectList{get;set;}
    public pse__Proj__c pro{get;set;}
    public date startDate {get;set;}
    public date endDate {get;set;}
    public date cutoverDate {get;set;}
    public String migrationSetId {get;set;}
    public List<String> projectStatus {get;set;}
    
    // the current sort direction. defaults to asc
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
    }
    // the current field to sort by. defaults to name
    public String sortField {
        get  { if (sortField == null) {sortField = 'Name'; } return sortField;  }
        set;
    }   
    
    public NI_IMT_ProjectController(ApexPages.standardController controller) {
        //FETCH THE RECORDTYPE FOR IMT IHG PROJECT
        limitSize= 20;
        pro = (pse__Proj__c)controller.getRecord();
        migrationSetId = Apexpages.currentPage().getParameters().get('migrationSetID');
        IMT_Migration_Set__c schSet = [SELECT RecordType.Name FROM IMT_Migration_Set__c WHERE Id = :migrationSetId LIMIT 1];
        String schedulingSetRecordTypeName = schSet.RecordType.Name;
        String projectRecordTypeName = String.valueOf(IMT_Scheduling_Set_Config__c.getValues(schedulingSetRecordTypeName).get('Record_Type__c'));
        String projectStatusStr = String.valueOf(IMT_Scheduling_Set_Config__c.getValues(schedulingSetRecordTypeName).get('Project_Status__c'));
        projectStatus = projectStatusStr.split(',');
        imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get(projectRecordTypeName).getRecordTypeId();
        system.debug(LoggingLevel.ERROR,projectStatus);
    }
    
    public pagereference init() {       
        soql = 'SELECT Name,pse__Region__r.Name,pse__Start_Date__c,IMT_Property__r.Timezone__c,pse__Project_Manager__c,IMT_Property__r.Subregion__c FROM pse__Proj__c where RecordtypeId = :imtProjRecordTypeId AND pse__Stage__c IN :projectStatus AND IMT_Cut_Over_Date__c = NULL AND IMT_Property__r.Status__c = \'Active\'';        
        runQuery();
        return null;
    }
	
    // toggles the sorting of query from asc<-->desc
    public void toggleSort() {
        // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        runQuery();
    }
    
    public void runQuery() {
        try{
            List<pse__Proj__c> projects = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' LIMIT '+limitSize+' OFFSET '+offsetSize);
            system.debug(soql + ' order by ' + sortField + ' ' + sortDir + ' LIMIT '+limitSize+' OFFSET '+offsetSize);
        	projectList = new List<ProjectWrapper>();
            for(pse__Proj__c pro : projects)
            {               
                ProjectWrapper pwrap = new ProjectWrapper();
                pwrap.proj  = pro;
                pwrap.selected = false;
                projectList.add(pwrap);                
            }                       
        }
        catch(Exception e)
        {
            system.debug('Error:'+e.getMessage());            
        }
    }
    
    //FETCH RESULTS BASED ON FILTERS
    public void runSearch() {
        offsetSize = 0;
        Decimal complx;
        String name = Apexpages.currentPage().getParameters().get('projectName');
        String region = Apexpages.currentPage().getParameters().get('region');
        String complexity = Apexpages.currentPage().getParameters().get('complexity');
        String timezone = Apexpages.currentPage().getParameters().get('tzone');
        limitSize = Integer.valueOf(Apexpages.currentPage().getParameters().get('limitSize'));
        String brand = Apexpages.currentPage().getParameters().get('brand');
        String opProfile = Apexpages.currentPage().getParameters().get('opProfile');
        String subregion = Apexpages.currentPage().getParameters().get('subregion');
        String manager = Apexpages.currentPage().getParameters().get('manager');
        complexity = complexity.trim();
        if(String.isNotBlank(complexity))
        	complx = decimal.valueOf(complexity);
        startDate = pro.pse__Start_Date__c;
        endDate = pro.pse__End_Date__c;
        cutoverDate = pro.IMT_Cut_Over_Date__c;
        
        system.debug(name+region);
        soql = 'SELECT Name,pse__Region__r.Name,pse__Start_Date__c,IMT_Property__r.Timezone__c,pse__Project_Manager__c,IMT_Property__r.Subregion__c FROM pse__Proj__c where RecordtypeId = :imtProjRecordTypeId AND pse__Stage__c=\'Not Scheduled\' AND IMT_Cut_Over_Date__c = NULL AND IMT_Property__r.Status__c = \'Active\'';
        if (name!=null) {
        	soql += ' and name LIKE \'%'+String.escapeSingleQuotes(name)+'%\'';    
        }
        if (region!='none') {
            soql += ' and pse__Region__c =\''+region+'\'';
        }
        if(complx != null) {
            soql += ' and IMT_Property__r.IMT_Complexity_Value__c = '+complx;
        }
        if(timezone != 'none') {
            soql += ' and IMT_Property__r.Timezone__c = \''+timezone+'\'';
        }
        if(brand != 'none') {
            soql += ' and IMT_Property__r.Brand__c = \''+brand+'\'';
        }
        if(opProfile != 'none') {
            soql += ' and IMT_Property__r.Operational_Profile__c = \''+opProfile+'\'';
        }
        if(subregion != 'none') {
            soql += ' and IMT_Property__r.Subregion__c = \''+subregion+'\'';
        }
        if(manager != 'none') {
            soql += ' and pse__Project_Manager__c = \''+manager+'\'';
        }
        system.debug('SOQL is'+soql);
        runquery();
    }
    
    //REDIRECT TO CREATE ASSIGNMENT PAGE IF PROJECT SELECTED ELSE SHOW ERROR MESSAGE
    public Pagereference createAssignment() {
        List<String> listOfProjects = new List<String>();
        String listOfProjectsStr = '';
        for(ProjectWrapper wrap : projectList){
            if(wrap.selected){
                listOfProjects.add(wrap.proj.Id);
                listOfProjectsStr = listOfProjectsStr + wrap.proj.Id + ':';
            }
        }
        system.debug('Projects' + listOfProjects);
        PageReference pageRef;
        List<pse__Proj__c>	emptyTimezonePrjs = new List<pse__Proj__c>();
        if(listOfProjects.size() != 0)
        {
        	emptyTimezonePrjs = [SELECT Name FROM pse__Proj__c WHERE IMT_Property__r.Timezone__c=NULL AND Id IN :listOfProjects];
        }
        if(listOfProjects.size() == 0)
        {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select atleast one Project'));
        }
        else if(emptyTimezonePrjs.size() > 0) {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select Project with timezone value'));	
        }
        else
        {
            system.debug(listOfProjects.size());
            pageRef = page.NI_IMT_CreateSchedule;
            pageRef.getParameters().put('ids', listOfProjectsStr);
            pageRef.getParameters().put('migrationSetID', migrationSetId);
        }
        return pageref ;
    }
    
    //FETCH IHG PROJECT REGIONS
    public List<pse__Region__c> getRegionList() {
        List<pse__Region__c> regions = [SELECT Id,Name FROM pse__Region__c WHERE Name IN (
        								'Americas', 'Asia Middle East Africa','Europe','Greater China') ORDER BY Name] ;
        return regions ;
    }
    
    //FETCH IHG PROJECTS TIMEZONE
    public Set<String> getTimezoneList() {
        Set<String> timeZones = new Set<String>();
        for(NI_IMT_Property__c p : [SELECT Timezone__c FROM NI_IMT_Property__c WHERE Timezone__c != NULL]) {
            timeZones.add(p.Timezone__c);
        }
        return timeZones;
    }
    
    //FETCH PROJECT MANAGERS
    public Map<Id, String> getProjectManagers() {
    	Map<Id, String> pmMap = new Map<Id, String>();
	    for(Contact con : [SELECT ReportsToId, ReportsTo.Name FROM Contact WHERE ReportsToId != NULL ORDER BY ReportsTo.Name]) {
	    	if (!pmMap.containsKey(con.ReportsToId) && con.ReportsTo.Name != NULL) {
                pmMap.put(con.ReportsToId, con.ReportsTo.Name);
            }
	    }
	    system.debug(LoggingLevel.ERROR,pmMap);
	    return pmMap;
    }
    
    //wrapper class
    public class ProjectWrapper {
        public pse__Proj__c proj {get; set;}
        public Boolean selected {get; set;}
        public ProjectWrapper(){}        
    }
    
    //GET BRAND
    public List<String> getBrand() {
		List<String> options = new List<String>();
		Schema.DescribeFieldResult fieldResult = NI_IMT_Property__c.Brand__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple) {
			options.add(f.getValue());
		}       
   		return options;
	}
	
	//GET OPERATIONAL PROFILE
    public List<String> getOperationProfile() {
		List<String> options = new List<String>();
		Schema.DescribeFieldResult fieldResult = NI_IMT_Property__c.Operational_Profile__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple) {
			options.add(f.getValue());
		}       
   		return options;
	}
	
	//GET SUB REGIONS
	public List<String> getSubRegion() {
		List<String> options = new List<String>();
		Schema.DescribeFieldResult fieldResult = NI_IMT_Property__c.Subregion__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple) {
			options.add(f.getValue());
		}       
   		return options;
	}
    
}