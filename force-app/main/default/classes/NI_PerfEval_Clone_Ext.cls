/****************************************************************************************
Name            : NI_PerfEval_Clone_Ext Class
Author          : Stuart Emery
Created Date    : 10/24/2015
Last Mod Date   : 10/24/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Class that handles events in VF Pages:
                :    NI_PerfEval_Clone
                :
******************************************************************************************/
public class NI_PerfEval_Clone_Ext {
    
    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
    // add the instance for the variables being passed by id on the url
    private NI_Employee_Performance_Evaluation__c pe {get;set;}
    // set the id of the record that is created -- ONLY USED BY THE TEST CLASS
    public ID newRecordId {get;set;}
    
    // initialize the controller
    public NI_PerfEval_Clone_Ext(ApexPages.StandardController controller) 
    { 
        // initialize the stanrdard controller
        this.controller = controller;
        // load the current record
        pe = (NI_Employee_Performance_Evaluation__c)controller.getRecord(); 
    }
    
    // method called from the VF's action attribute to clone the Change Request
    public PageReference cloneWithGoals() 
    {
        
          //GET RECORDTYPE ID FOR THE "EMPLOYEE STAGE" RECORD TYPE ON THE PERFORMANCE EVALUATION OBJECT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.NI_Employee_Performance_Evaluation__c; 
        Map<String, Schema.RecordTypeInfo> PerfEvalRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtEmployeeStageId = PerfEvalRecordTypeInfo.get('Employee Stage').getRecordTypeId();
        
        // LIST OF CLONED GOALS FOR INSERT 
        List<NI_PerfEval_Goals__c> lstGoalsToInsert = new List<NI_PerfEval_Goals__c>();
        
        // LIST OF ALL RELATED GOALS BELONGING TO PERFORMANCE EVALUATIONS
        List<NI_PerfEval_Goals__c> lstGoals = new List<NI_PerfEval_Goals__c>([
            SELECT Id, 	Category__c, Current_Previous_Year__c, Employee_Performance_Evaluation__c, Goal__c, Set_By__c
            FROM NI_PerfEval_Goals__c 
            WHERE Employee_Performance_Evaluation__c = : pe.Id 
            AND Current_Previous_Year__c = 'Goal For Coming Year'
        ]);
        
        // SET SAVE POINT FOR ROLLBACK 
        //Savepoint sp = Database.setSavepoint();
        NI_Employee_Performance_Evaluation__c newPE = new NI_Employee_Performance_Evaluation__c();  
        
        
        NI_Employee_Performance_Evaluation__c currentPE = [SELECT Id, Employee_Name__c, Employee_Name__r.ManagerId, Job_Title__c, Performance_Evaluation_Year__c,  
                                                           Status__c, Time_in_Position__c, Title__c, RecordTypeId
                                                           FROM NI_Employee_Performance_Evaluation__c                         
                                                           WHERE Id = : pe.id];
        
        Date currDate = Date.today();
        newPE.RecordTypeId = rtEmployeeStageId;                   
        newPE.Employee_Name__c = currentPE.Employee_Name__c;
        newPE.Job_Title__c = currentPE.Job_Title__c;
        newPE.Performance_Evaluation_Year__c = String.valueOf(currDate.Year());
        newPE.Status__c = 'Employee Draft';
        newPE.Time_in_Position__c = currentPE.Time_in_Position__c;
        newPE.Manager__c = currentPE.Employee_Name__r.ManagerId;
        
        
        // INSERT CLONED PERFORMANCE EVALUATION RECORD        
        insert newPE;
        
        //VARIABLE TO HOLD THE ID OF THE NEW PERFORMANCE EVALUATION RECORD
        newRecordId = newPE.Id;
 
 //========================================================       
 //       CREATE ASSESSMENT RECORDS
 //========================================================
        
        //LIST TO HOLD THE PERFORMANCE EVALUDATION ASSESSMENT CUSTOM SETTINGS RECORDS  
        List<Performance_Evaluations_Assessments__c> lstCS = Performance_Evaluations_Assessments__c.getall().values();
        
        if (lstCS.size() < 1)
        {
            System.debug('THERE ARE NO RECORDS IN THE Performance_Evaluations_Assessments__c CUSTOM SETTING');
        }
        else
        {             
            //LIST TO HOLD THE PRODUCT CODE VALUE FROM THE CUSTOM SETTING  
            List<NI_PE_Assessment__c> lstAssessmentsToInsert = new List<NI_PE_Assessment__c>();
            
            for (Performance_Evaluations_Assessments__c p : lstCS)
            {
                NI_PE_Assessment__c a = new NI_PE_Assessment__c();
                a.NI_Employee_Performance_Evaluation__c = newPE.Id;
                a.Category__c = p.Category__c;        
                a.Description__c = p.Description__c;
                lstAssessmentsToInsert.add(a); 
            }    
            
            Database.insert(lstAssessmentsToInsert);
        }        
        
        
        // LOOP THROUGH ALL RELATED ARTIFACTS AND ADD TO INSERT LIST
        for (NI_PerfEval_Goals__c g : lstGoals)
        {            
            NI_PerfEval_Goals__c newG = new NI_PerfEval_Goals__c();
            newG.Category__c = g.Category__c; 
            newG.Current_Previous_Year__c = 'Goal From Last Year';
            newG.Employee_Performance_Evaluation__c = newPE.Id;
            newG.Goal__c = g.Goal__c;
            newG.Set_By__c = g.Set_By__c;
            lstGoalsToInsert.add(newG);         
        }
        
        //USE DATABASE DML METHOD TO INSERT GOALS
        if(lstGoalsToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstGoalsToInsert,true);
            for(Database.SaveResult sr: results)
            {
                if(!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }
        }                     
        //return new PageReference('/'+ newPE.id +'/e?retURL=%2F'+newPE.id);
        return new PageReference('/'+ newPE.id);
    }       
}