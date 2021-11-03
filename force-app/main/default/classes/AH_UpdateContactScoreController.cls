/********************************************************************************************************
Name            : AH_UpdateContactScoreController Class
Author          : Ria Chawla
Created Date    : 09/14/2017
Last Mod Date   : 09/27/2017 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-024092
Description     : Controller for the AH_UpdateContactScore Visualforce page 
                : The Visualforce Page is opened from Survey Response Data's List View.
                : This page is used to update NPS and OSAT on Contact records.
/**********************************************************************************************************/
public class AH_UpdateContactScoreController 
{
    
    public ApexPages.StandardSetController setCon {get; set;}
    public date dt = date.Today();
    public string displayStartDate {get; set;} 	
    public string displayEndDate {get; set;}
    public boolean disableButton {get; set;}
    public Id batchJobId {get; set;}
    public boolean isRendered {get; set;}
    public List<Contact> failedContactsList {get; set;}
    public String message {get; set;}
    
    
    public AH_UpdateContactScoreController(ApexPages.StandardSetController controller)
    {
        // INITIALIZE THE STANDARD SET CONTROLLER
        this.setCon = controller;
        //SET THE DEFAULT START DATE TO JANUARY 1 OF THE CURRENT YEAR 
        displayStartDate = '01/01/' + String.valueOf(dt.year());
        //SET THE DEFAULT END DATE TO END OF DAY TODAY  
        displayEndDate = String.valueOf(date.today().format());
    }
    
    //FUNCTION IS CALEED WHEN SUBMIT BUTTON IS CLICKED
    public void doSubmit()
    {
        
        // DISABLE SUBMIT BUTTON
        disableButton = true;
        
        //DISPLAY MESSAGE BATCH IS PROCESSING
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Batch job is processing. Please click Refresh to check status of batch job.');
        ApexPages.addMessage(myMsg);
        
        //PARSE INTO DATE TO SEND TO THE BATCH CLASS
        Datetime strDt = Date.parse(displayStartDate);
        Datetime endDt = Date.parse(displayEndDate);
        endDt = endDt.addDays(1);
        
        //CALL THE BATCH CLASS TO UPDATE CONTACT SCORE FOR SURVEY RESPONSE DATA RECORDS CREATED OR MODIFIED BETWEEN START DATE AND END DATE
        AH_BatchSurveyResponseData batchSurveyRecords = new AH_BatchSurveyResponseData(strDt, endDt);
        batchJobId = Database.executeBatch(batchSurveyRecords, 25); 
        system.debug('batchJobId = ' + batchJobId);
        
    }
    
    //FUNCTION IS CALLED WHEN REFRESH BUTTON IS CLICKED
    public void refreshPage()
    {
        
        isRendered = true;
        message = '';
        AsyncApexJob asyncJob = new AsyncApexJob();
        AH_Batch_Apex_Result__c batchApexResult = new AH_Batch_Apex_Result__c();
        failedContactsList = new List<Contact>();
        
        //IF VARIABLE IS NOT NULL GET THE APEX BATCH JOB SCHEDULED ELSE DISPLAY MESSAGE 'NO BATCH JOB FOUND.'
        if (batchJobId != null)
        {
            
            system.debug('batchJobId = ' + batchJobId);
            
            try
            {
                asyncJob = [SELECT Id, ApexClassId, CompletedDate, CreatedById, CreatedDate, NumberOfErrors, Status
                            FROM AsyncApexJob
                            WHERE Id =: batchJobId 
                            LIMIT 1];
            }
            catch (Exception e)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage());
                ApexPages.addMessage(myMsg);
            }
        }
        else
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'No Batch job found. Plese refresh and submit again.');
            ApexPages.addMessage(myMsg);
        }
        
        system.debug('asyncJob = ' + asyncJob);
        
        //CHECK THE STATUS OF BATCH JOB FETCHED AND DISPLAY MESSAGE ON PAGE ACCORDINGLY
        if (asyncJob.Status == 'Completed')
        {
            
            try
            {
                
                //FETCH THE RESULT OF BATCH APEX RESULT TO DISPLAY NUMBER OF RECORDS PROCESSED, FAILED ETC ON PAGE
                batchApexResult = [SELECT Id, Name, Failed_Contact_Records__c, Failed_Records__c, Success_Records__c, Total_Survey_Records_Processed__c
                                   FROM AH_Batch_Apex_Result__c 
                                   WHERE Batch_Job_Id__c =: batchJobId 
                                   LIMIT 1];
                
            }
            catch (Exception e)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Batch is still processing.');
                ApexPages.addMessage(myMsg);
            }
            
            // TO DISPLAY LIST OF CONTACTS FOR WHICH UPDATE FAILED
            List<String> contactIdList = new List<String>();
            String contactIds = '';
            
            if (batchApexResult.Failed_Contact_Records__c != null && batchApexResult.Failed_Contact_Records__c != '')
            {
                contactIds = batchApexResult.Failed_Contact_Records__c;
                contactIds = contactIds.substringBetween('{', '}');
                contactIdList = contactIds.split(', ');
                system.debug('contactIdList = ' + contactIdList);
                failedContactsList = [SELECT Id, Name, Account.Name FROM Contact WHERE Id IN : contactIdList];
                system.debug('failedContactsList = ' + failedContactsList);
            }
            
            message = 'Successfully completed. <br/>' +
                'Total Survey Response Data Records Processed: ' + batchApexResult.Total_Survey_Records_Processed__c + '<br/>' +
                'Total Contact Record Update Successes: ' + batchApexResult.Success_Records__c + '<br/>'+
                'Total Contact Record Update Failures: ' + batchApexResult.Failed_Records__c + '<br/>' ;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, message);
            ApexPages.addMessage(myMsg);
        }
        else 
        {
            if (asyncJob.Status == 'In Progress')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Batch is still processing.');
                ApexPages.addMessage(myMsg);
            }
            else
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Batch is still processing.');
                ApexPages.addMessage(myMsg);
            }            
        }
        
    }
    
}