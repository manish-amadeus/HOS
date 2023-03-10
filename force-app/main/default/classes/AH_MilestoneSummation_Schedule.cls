/****************************************************************************************
Name            : AH_MilestoneSummation_Schedule
Author          : Shashikant Nikam
Created Date    : 06/18/2018
Modified Date   : 07/03/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : To schedule Renewal process of those activity line items that have renewal date of yesterday.
				: 
******************************************************************************************/
global class AH_MilestoneSummation_Schedule implements Schedulable 
{
    
    @ReadOnly
    global void execute(SchedulableContext sc)
    {
        
        // VARIABLES
        Map<String, MilestoneWrapper> milestoneWrapperMap = new Map<String, MilestoneWrapper>();
        String dbQuery = '';
        List<String> projectTypeList = new List<String>();
        List<String> milestoneTypeList = new List<String>();
        List<String> projectNameList = new List<String>();
        List<String> targetPeriodList = new List<String>();
        List<String> milestoneNameList = new List<String>();
        AH_Milestone_Settings__c milestoneSettings = AH_Milestone_Settings__c.getOrgDefaults();
        
        // CREATE DYNAMIC SOQL
        dbQuery = 'SELECT pse__Project__r.pse__Region__r.Name regionName, ';
        dbQuery += 'pse__Project__r.pse__Group__r.Name groupName, '; 									// pse__Override_Project_Practice__r.Name practiceName, 
        dbQuery += 'SUM(pse__Milestone_Amount__c) milestoneAmount, pse__Target_Date__c targetDate ';	// Target_Period__c targetPeriod 
        dbQuery += 'FROM pse__Milestone__c '; 

        if (milestoneSettings != null)
        {
            
            // LIST TO HOLD PROJECT TYPES
            if (milestoneSettings.Project_Type__c != null && milestoneSettings.Project_Type__c != '')
            {
                projectTypeList = milestoneSettings.Project_Type__c.split(',');
            }
            
            // LIST TO HOLD MILESTONE TYPES
            if (milestoneSettings.Milestone_Type__c != null && milestoneSettings.Milestone_Type__c != '')
            {
                milestoneTypeList = milestoneSettings.Milestone_Type__c.split(',');
            }
            
            // LIST TO HOLD PROJECT NAMES
            if (milestoneSettings.Project_Name__c != null && milestoneSettings.Project_Name__c != '')
            {
                projectNameList = milestoneSettings.Project_Name__c.split(',');
                for (Integer i = 0; i < projectNameList.size(); i++)
                {
                    projectNameList[i] = '%' + projectNameList[i] + '%';
                }
            }
            
            // LIST TO HOLD TARGET PERIODS
            if (milestoneSettings.Target_Period__c != null && milestoneSettings.Target_Period__c != '')
            {
                targetPeriodList = milestoneSettings.Target_Period__c.split(',');
                for (Integer i = 0; i < targetPeriodList.size(); i++)
                {
                    targetPeriodList[i] = '%' + targetPeriodList[i] + '%';
				}
            }
            
            // LIST TO HOLD MILESTONE NAMES
            if (milestoneSettings.Milestone_Name__c != null && milestoneSettings.Milestone_Name__c != '')
            {
                milestoneNameList = milestoneSettings.Milestone_Name__c.split(',');
                for (Integer i = 0; i < milestoneNameList.size(); i++)
                {
                    milestoneNameList[i] = '%' + milestoneNameList[i] + '%';
                }
            }            
            
            // FILTER CRITERIA
            dbQuery += ' WHERE Id != NULL ';
            
            if (!projectTypeList.isEmpty())
            {
                dbQuery += ' AND pse__Project__r.pse__Project_Type__c IN : projectTypeList';
            }
            if (!projectNameList.isEmpty())
            {
                dbQuery += ' AND (NOT pse__Project__r.Name LIKE : projectNameList) '; 
            }

            // ADDED BY SHASHIKANT ON 6/12/2019
            List<pse__Time_Period__c> periodList = [SELECT Id, Name, pse__Start_Date__c, pse__End_Date__c, pse__Type__c 
                                                    FROM pse__Time_Period__c 
                                                    WHERE Name LIKE : targetPeriodList 
                                                    AND pse__Type__c = 'Year'];
system.debug('*^* periodList = ' + periodList);
			String periodConditionQuery = '';
            
            if (!periodList.isEmpty())
            {
                periodConditionQuery += ' AND ( ';
                
                Integer cnt = 1;
                for (pse__Time_Period__c tPeriod : periodList)
                {
                    
                    String stDate = String.valueOf(tPeriod.pse__Start_Date__c);
                    stDate = stDate.replace('00:00:00', '');
                    String endDate = String.valueOf(tPeriod.pse__End_Date__c);
                    endDate = endDate.replace('00:00:00', '');
                    
                    periodConditionQuery += ' (pse__Target_Date__c >= ' + stDate + ' AND pse__Target_Date__c <= ' + endDate + ') ';
                    
                    if (cnt < periodList.size())
                	{
                         periodConditionQuery += ' OR ';
                    }
                    cnt++;
                }
                periodConditionQuery += ' ) ';
			}
            
            system.debug(' **** periodConditionQuery = ' + periodConditionQuery);
            
            dbQuery += periodConditionQuery;

            if (milestoneSettings.Milestone_Amount__c != null)
            {
                dbQuery += ' AND (pse__Milestone_Amount__c > ' + milestoneSettings.Milestone_Amount__c + ') ';
            }
            
            if (!milestoneTypeList.isEmpty())
            {
                dbQuery += ' AND (Milestone_Type__c IN : milestoneTypeList) ';
            }
            
            if (!milestoneNameList.isEmpty())
            {
                dbQuery += ' AND (NOT (Name LIKE :milestoneNameList)) ';
            }
            
        }     
        
        // ADD GROUP BY CLAUSE TO THE QUERY
        dbQuery += ' GROUP BY pse__Project__r.pse__Region__r.Name, pse__Project__r.pse__Group__r.Name, pse__Target_Date__c '; // pse__Override_Project_Practice__r.Name, Target_Period__c';
        
        List<AggregateResult> aggrList = new List<AggregateResult>();
        aggrList = Database.query(dbQuery);  

        //ITERATE OVER THE LIST AND CREATE A MAP TO HOLD MILESTONE DETAILS
        for (AggregateResult aggr : aggrList)
        {
            
            MilestoneWrapper milestoneWrapperObj = new MilestoneWrapper();  
            milestoneWrapperObj.projectRegion = (String)aggr.get('regionName');
            milestoneWrapperObj.projectGroup = (String)aggr.get('groupName');
            milestoneWrapperObj.milestoneAmount = (Decimal)aggr.get('milestoneAmount');
            milestoneWrapperObj.targetDate = (Date)aggr.get('targetDate');
            milestoneWrapperMap.put((String)aggr.get('regionName') + (String)aggr.get('groupName') + (Date)aggr.get('targetDate'), milestoneWrapperObj);
            
        }  

        //CALL BATCH TO CREATE RECORDS OF SERVICES SCRUM SNAPSHOT AS PER MILESTONE DETAILS FETCHED IN ABOVE QUERY
        AH_MilestoneSummation_Batch batch = new AH_MilestoneSummation_Batch(milestoneWrapperMap);
        Database.executeBatch(batch, 1);  
        
    }     
           
    // WRAPPER CLASS TO STORE MILESTONE DETAILS
    public class MilestoneWrapper
    {
        public String projectRegion {get; set;}
        public String projectGroup {get; set;}
        public String projectPractice {get; set;}
        public Decimal milestoneAmount {get; set;} 
        public String targetPeriod {get; set;}
        public Date targetDate {get; set;} 
    }
    
}