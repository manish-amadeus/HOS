/****************************************************************************************
Name            : AH_Rally_CaseSyncBatch  (TC Org Name: RallyCaseSyncBatch)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : This Batch class is used to process the updated userstories in rally
				: In each Call retrieve 200 records and update in salesforce. 
				: It will run recursively till each and every record processed.
				: 
******************************************************************************************/
global class AH_Rally_CaseSyncBatch implements Database.Batchable<AH_Rally_UserStoryDetails>, Database.AllowsCallouts, Database.Stateful 
{
    
    public String workspaceUrl;
    public String response;
    public List<AH_Rally_UserStoryDetails> defectList {get; set;}
    public Integer totalUpdatedRecords = 0;
    public Integer index = 1;
    public List<String> lstUs;
    public Map<String, AH_Rally_UserStoryDetails> mapLstUs;
    public Boolean counterFlag = true;
    
    public AH_Rally_CaseSyncBatch(Integer index, Integer totalUpdatedRecords)
    {
        this.index = index;
        this.totalUpdatedRecords = totalUpdatedRecords;
        defectList = new List<AH_Rally_UserStoryDetails>();
        lstUs = new list<String>();
        mapLstUs = new Map<String, AH_Rally_UserStoryDetails>();
        System.debug('=============>################## '+index+' =================))) '+totalUpdatedRecords);
    }
    
    public Iterable<AH_Rally_UserStoryDetails> start(Database.BatchableContext BC) 
    {        
        return populateDefectList(this.index);
    }
    
    public void execute(Database.BatchableContext BC, List<AH_Rally_UserStoryDetails> records) 
    {    
        
        for (AH_Rally_UserStoryDetails us:records)
        {         
            lstUs.add(us.FormattedID);
            mapLstUs.put(us.FormattedID, us);            
        }
        
        List<Case> lstcase = [SELECT Id, UserStory_Rally_Status__c, User_Story_Release__c, Target_Completion_Date__c, Target_Release_Quarter__c, User_Story_Owner__c, 
                               User_Story_Id__c, Customer_Severity__c   
                              FROM Case 
                              WHERE User_Story_Id__c IN : lstUs]; 
        
        List<Case> caseUpdate = new List<Case>();
        
        for (Case c : lstcase)
        {         
            if (mapLstUs.containsKey(c.User_Story_Id__c))
            {
                c.UserStory_Rally_Status__c =mapLstUs.get(c.User_Story_Id__c).L3KanbanStage;
                
                if (mapLstUs.get(c.User_Story_Id__c).Release != null)
                {
                    c.User_Story_Release__c  = mapLstUs.get(c.User_Story_Id__c).Release.refObjectName;
                }
                else
                {
                    c.User_Story_Release__c = 'Unscheduled';
                }
                
                if (mapLstUs.get(c.User_Story_Id__c).TargetCompletionDate != null)
                {
                    c.Target_Completion_Date__c = date.valueOf(mapLstUs.get(c.User_Story_Id__c).TargetCompletionDate);                
                }
                else
                {
                    c.Target_Completion_Date__c = null;
                }  
                
                if (mapLstUs.get(c.User_Story_Id__c).TargetReleaseQuarter != null) 
                {
                    System.debug(' Inside Not null If **** ' + mapLstUs.get(c.User_Story_Id__c).TargetReleaseQuarter);
                    c.Target_Release_Quarter__c = String.valueOf(mapLstUs.get(c.User_Story_Id__c).TargetReleaseQuarter);
                }
                else
                {
                    c.Target_Release_Quarter__c = null;
                }
                
                if (mapLstUs.get(c.User_Story_Id__c).owner != null)
                {
                    c.User_Story_Owner__c = mapLstUs.get(c.User_Story_Id__c).owner.refObjectName;
                }
                else
                {
                    c.User_Story_Owner__c = null;
                }
                
                if (mapLstUs.get(c.User_Story_Id__c).SalesforcePriority != null)
                {
                    c.Customer_Severity__c = AH_Rally_FieldMapper.getSalesforceCasePriorityMapping('Customer_Severity__c', mapLstUs.get(c.User_Story_Id__c).SalesforcePriority) ;
                }
                else
                {
                    c.Customer_Severity__c = null;
                }
                
                caseUpdate.add(c); 
                
            }
            
        }
        
        update caseUpdate;
        
    }  
    
    public void finish(Database.BatchableContext BC)
    {
        
        this.index = this.index + 200;
        // if total count (Rally) is equal to the Index (flag) do nothing
        if (totalUpdatedRecords == this.index)
        { 
            System.debug('=============>################## End Of Records===================== ');
            //if update is success then  Rally_Setup__c Schedular_Last_Run__c field is updated
            AH_Rally_Setup__c rsm = [SELECT Username__c, RallyURL__c, Schedular_Last_Run__c FROM AH_Rally_Setup__c ORDER BY Name ASC LIMIT 1];
            rsm.Schedular_Last_Run__c = System.now();        
            update rsm;
            
        }
        else if(totalUpdatedRecords < this.index)
        {
            System.debug('=============>################## ' + this.index + ' =================))) ' + totalUpdatedRecords);
            
            this.index = (this.index - (this.index - totalUpdatedRecords)) - 200;
            System.debug('=============>###remainingRecords######## ' + this.index + ' =================))) ' + totalUpdatedRecords); 
            Database.executeBatch(new AH_Rally_CaseSyncBatch(this.index, totalUpdatedRecords), 200); 
        }
        else
        {
            Database.executeBatch(new AH_Rally_CaseSyncBatch(this.index,totalUpdatedRecords),200); 
        }
        
    }
    
    public List<AH_Rally_UserStoryDetails> populateDefectList(Integer i)
    { 
        if (this.totalUpdatedRecords == 0 && i == 1 && !test.isRunningTest())
        {
            AH_Rally_CaseSync rs = new AH_Rally_CaseSync();
            this.totalUpdatedRecords = rs.init();
        } 
        
        workspaceUrl = AH_Rally_Library.workspaceUrl();
        String endPoint = AH_Rally_Credentials.endPoint+'/slm/webservice/' + AH_Rally_Credentials.versionNumber + '/hierarchicalrequirement.js?workspace='+workspaceUrl+'&fetch=L3KanbanStage,SalesforcePriority,owner,LastUpdateDate,Release,FormattedID,RetentionRisk,TargetCompletionDate,SalesforceCase,TargetReleaseQuarter&order=LastUpdateDate%20desc&start='+i+'&pagesize=200';    
        response = AH_Rally_Library.sendRequestObject('GET', endPoint, null);
        response = response.replace('_ref','ref');
        system.debug('### response ## ' + response);
        
        // Parse entire JSON response.
        JSONParser parser = JSON.createParser(response);
        
        while (parser.nextToken() != null) 
        {
            // Start at the array of Results.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) 
            {
                if (parser.getCurrentName() == 'Results')
                {
                    while (parser.nextToken() != null) 
                    {
                        // Advance to the start object marker to find next Result object.Owner
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            // Read entire DefectInfo object, including its project object.
                            // write logic for checking with the particular date or hour and read it as Defect info Object
                            AH_Rally_UserStoryDetails usd= (AH_Rally_UserStoryDetails)parser.readValueAs(AH_Rally_UserStoryDetails.class);                                                                  
                            defectList.add(usd);
                            // Skip the child start array and start object markers.
                            parser.skipChildren();
                        }
                    }
                }
            }
        }    
        
        System.debug('Lst ------------------------ '+defectList);
        
        return defectList;
        
    }
    
}