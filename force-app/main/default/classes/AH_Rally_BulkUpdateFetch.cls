/****************************************************************************************
Name            : AH_Rally_BulkUpdateFetch (TC Org Name: BulkUpdateUsingRallyFetch)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : duplicate class for BulkUpdateUsinggRallyFetch to get the User study id's
				: from rally which has duplicate salesforce case id
				: 
******************************************************************************************/
public class AH_Rally_BulkUpdateFetch 
{
    
    public static String query;
    public Integer totalUpdatedRecords = 0; 
    public List<AH_Rally_UserStoryDetails> defectList;
    public static Set<Case> caseList;
    public static List<Case> finalCaseListToUpdate;
    public String workspaceUrl;
    public static Set<String> CaseofSalesforce;
    
    // stores response for total count of updated records
    public String countResponse;
    
    // stores response after hitting fecth endpoint
    public String response;
    
    static
    {
        caseList = new Set<Case>();
        finalCaseListToUpdate = new List<Case>();
        CaseofSalesforce = new Set<String>();
//        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'BulkUpdateUsingRallyFetchVar'];
//        Blob bodyBlob = sr.Body;
//        query = bodyBlob.toString(); 
    	query = 'SELECT Id, User_Story_Id__c FROM Case WHERE Rally_Artifact_Ref__c != null ORDER BY CreatedDate DESC LIMIT 45000';
    
    }
    
    public AH_Rally_BulkUpdateFetch()
    {
        defectList = new List<AH_Rally_UserStoryDetails>();
        init();
    }
        
    public void init()
    {
        
        // set workspace endpoint         
        workspaceUrl = AH_Rally_Library.workspaceUrl();
        System.debug(' aaa workspaceUrl = ' + workspaceUrl); 
        
        // convert to GMT
        String LastUpdateDate = AH_Rally_Credentials.dateFilterValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        System.debug('*** LastUpdateDate = ' + LastUpdateDate);
        
        String lastUpdateEndPoint = LastUpdateDate.replace(':','%3A');
        String queryEndPointForCount = AH_Rally_Credentials.endPoint + '/slm/webservice/' + AH_Rally_Credentials.versionNumber + '/hierarchicalrequirement.js?workspace=' + workspaceUrl + '&query=(LastUpdateDate'+'%20%3E%3D%20%22' + lastUpdateEndPoint + '%22%20)';
        system.debug('Query End Point = ' + queryEndPointForCount); 
        
        countResponse = AH_Rally_Library.sendRequestObject('GET', queryEndPointForCount, null);
        System.debug(countResponse);
        
        // parse for TotalResultCount
        JSONParser dateparser = JSON.createParser(countResponse);
        
        while (dateparser.nextToken() != null) 
        {
            if (dateparser.getText() == 'TotalResultCount')
            {
                dateparser.nextToken();
                totalUpdatedRecords = Integer.valueOf(dateparser.getText());
                
            }
        }
        
        // for loop which will do n number of callouts based on number of records updated in rally  
        Integer index = 1;
        
        for (Integer i = 0; i <= totalUpdatedRecords / 200; i++)
        {
            
            populateDefectList(index);
            
            index = index + 200;
            
            // if records are more than 1400 records than we will break it
            if (index > 1400)
            {
                break;
            }
            
        }
        
    }
    
    //if we hit the above endpoint it will give all the values with respect to defect.
    public void populateDefectList(Integer i)
    {
        
        String endpoint = AH_Rally_Credentials.endPoint + '/slm/webservice/' + AH_Rally_Credentials.versionNumber + '/hierarchicalrequirement.js?workspace=' + workspaceUrl + '&fetch=L3KanbanStage,SalesforcePriority,owner,LastUpdateDate,Release,FormattedID,RetentionRisk,TargetCompletionDate,SalesforceCase,TargetReleaseQuarter&order=LastUpdateDate%20desc&start=' + i + '&pagesize=200';    
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
                            //write logic for checking with the particular date or hour and read it as Defect info Object
                            
                            AH_Rally_UserStoryDetails usd= (AH_Rally_UserStoryDetails)parser.readValueAs(AH_Rally_UserStoryDetails.class);                                                                  
                            defectList.add(usd);
                            
                            // Skip the child start array and start object markers.
                            parser.skipChildren();
                        }
                    }
                }
            }
        }    
        
    }    
    
    public void bulkUpdateRallyField()
    {
        
        // method which does update
        Set<String> userStoryIdSet = new Set<String>();
        List<sObject> records = Database.Query(query);
system.debug(' :::: records = ' + records);        
        for (sObject s : records)
        {
            String id_trim = ((Case)s).Id;    
            // Salesforce case id                       
            CaseofSalesforce.add(id_trim.left(15));
            userStoryIdSet.add(((Case)s).User_Story_Id__c);
        }
system.debug(' :::: CaseofSalesforce = ' + CaseofSalesforce);          
        //Set to hold duplicate case id's from rally
        Set<String> caseIdSet = new Set<String>();
        
        //Set to hold duplicate rally study id
        Set<String> duplicateRallyStudyIdSet = new Set<String>();
system.debug(' :::: defectList = ' + defectList);         
        if (!defectList.isEmpty())
        {
            for (AH_Rally_UserStoryDetails dqr : defectList)
            {
system.debug(' :::: dqr.SalesforceCase = ' + dqr.SalesforceCase);                 
                // filter and validation of Salesforce case id with Rally_Salesforce case id
                if (dqr.SalesforceCase != null)
                {
                    if (dqr.SalesforceCase.LinkID != null && CaseofSalesforce.contains(dqr.SalesforceCase.LinkID))                                
                    {
                        //Filter records based on user story id of rally and Salesforce
                        if (userStoryIdSet.contains(dqr.FormattedId))
                        {
                            
                            Case c = new Case(Id = dqr.SalesforceCase.LinkID);
                            
                            c.UserStory_Rally_Status__c = dqr.L3KanbanStage;                                                         
                            if (dqr.Release != null)
                            {
                                c.User_Story_Release__c  = dqr.Release.refObjectName;
                            }
                            else
                            {
                                c.User_Story_Release__c = 'Unscheduled';
                            }
                            
                            if (dqr.TargetCompletionDate != null)
                            {
                                c.Target_Completion_Date__c = date.valueOf(dqr.TargetCompletionDate);
                            }
                            else
                            {
                                c.Target_Completion_Date__c = null;
                            }
                            
                            // US118032
                            if (dqr.TargetReleaseQuarter != null) 
                            {
                                System.debug(' Inside Not null If ****  ' + dqr.TargetReleaseQuarter);
                                c.Target_Release_Quarter__c = String.valueOf(dqr.TargetReleaseQuarter);
                            }
                            else
                            {
                                c.Target_Release_Quarter__c = null;
                            }
                            
                            if (dqr.owner != null)
                            {
                                c.User_Story_Owner__c = dqr.owner.refObjectName;
                            }
                            else
                            {
                                c.User_Story_Owner__c = null;
                            }
                            
                            if (dqr.SalesforcePriority != null)
                            {
                                c.Customer_Severity__c = AH_Rally_FieldMapper.getSalesforceCasePriorityMapping('Customer_Severity__c', dqr.SalesforcePriority);
                            }
                            else
                            {
                                c.Customer_Severity__c = null;
                            }
                            
                            System.debug(dqr);
                            System.debug(c);
                            
                            caseList.add(c);    
                            
                        }
                        else
                        {
                            duplicateRallyStudyIdSet.add(dqr.SalesforceCase.LinkId+','+dqr.FormattedId);
                            System.debug('*** Duplicate story id *** '+dqr.FormattedId + ' *** Case Id *** '+dqr.SalesforceCase.LinkID);
                        }

                    }
                }
            }
            
        }   
        
        if (!test.isRunningTest())
        {
            
            finalCaseListToUpdate.addAll(caseList);    
            //final update of batch       
            System.debug('*** finalCaseListToUpdate *** '+finalCaseListToUpdate);    
            update finalCaseListToUpdate;
            
            //if case id is linked with more than 1 user story, send email to user
            if (!duplicateRallyStudyIdSet.isEmpty())
            {
                sendEmailToUser(duplicateRallyStudyIdSet);
            }
            
        }
        
        //if update is success then  Rally_Setup__c Schedular_Last_Run__c field is updated
        AH_Rally_Setup__c rsm = [SELECT Username__c, RallyURL__c, Schedular_Last_Run__c FROM AH_Rally_Setup__c ORDER BY Name ASC LIMIT 1];
        rsm.Schedular_Last_Run__c = System.now();
        
        if (!test.isRunningTest())
        {
            update rsm;
        }
        
    }
    
    public static void sendEmailToUser(Set<String> duplicateCaseStudyIdSet)
    {
        
        // Method to send an email to user when one case id is linked to than one user story in rally
        // @params set of duplicate case id and user story id        
        
        Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
        mail.setToAddresses(new String[]{'tbombassei@travelclick.com'});
        mail.setSubject('Case is linked with more than one user story');
        mail.setHTMLBody(generateEmailTemplate(duplicateCaseStudyIdSet));
        
        if (!test.isRunningTest()) 
        {
            Messaging.sendEmail(new Messaging.Email[]{mail});  
        }
        
    }

    public static String generateEmailTemplate(Set<String> duplicateCaseStudyIdSet)
    {
        
        // method to generate an email template to send in an email to user with table having case id and user story id
        // @params set of duplicate case id and user story id        
        
        String templateBody = 'Below user stories are found to be linked with cases in salesforce which are already linked to another user stories in rally. <br/><br/>';
        templateBody += '<table border="1"><thead><th> Case Id </th><th> User Story Id </th></thead>';
        templateBody += '<tbody>';
        
        for (String s : duplicateCaseStudyIdSet)
        {
            List<String> storyAndCaseList = s.split(',');
            templateBody += '<tr><td>' + storyAndCaseList[0] + '</td><td>' + storyAndCaseList[1] + '</td></tr>';
        }
        
        templateBody += '</tbody></table><br/><br/><br/>';
        templateBody += 'Thank you,<br/>';
        templateBody += 'Salesforce Admin<br/>';
        
        return templateBody;
        
    }
    
}