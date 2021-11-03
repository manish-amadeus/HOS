/****************************************************************************************
Name            : AH_Rally_InsertIntoDB  (TC Org Name: InsertIntoDatabase)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : 
				: 
				: 
******************************************************************************************/
global class AH_Rally_InsertIntoDB 
{

    public static String getDefectId(String artifact)
    { 
        String endpoint = AH_Rally_Credentials.endPoint + '/slm/webservice/' + AH_Rally_Credentials.versionNumber + '/hierarchicalrequirement/';
        artifact = artifact.replace(endpoint, '');
        artifact = artifact.replace('.js', '');                        
        return artifact;                                
    }
    
    WebService static void UpdateSalesforceStatus(String RallyStatus, String CaseId)
    {
        Case c = new Case();
        c.Id = CaseId;
        c.UserStory_Rally_Status__c = RallyStatus;
        update c;
    }

    WebService static void updateSfofUserStory(String Owner, String USproject, String UserStoryId, String RallyStatus, String Release, String CaseId, String MasterTicket, String SalesforcePriority)
    {
        
        // called from Sync data for User Story Update
        // UserStoryId:UserStoryId,RallyStatus:RallyStatus,Release:Release,CaseId:"{!Case.Id}"        
        
        Case c = new Case();
        c.Id = CaseId;
        c.User_Story_Owner__c = Owner;
        c.User_Story_Project__c = USproject;
        c.User_Story_Id__c = UserStoryId;
        c.User_Story_Release__c = Release;
        c.UserStory_Rally_Status__c = RallyStatus;
        c.Master_Ticket__c = MasterTicket;
        c.Priority = SalesforcePriority;
        
        update c;
        
    }     
    
    WebService static void insertIntoCAR(String string_def, String cID, String RallyattachemntId, String Salesforceattid)
    {     
        
        //used to insert into  values Case_Attachment_Relation__c object form javascript used in button
        String defectId;         
        defectId = getDefectId(string_def);
        String s1 = cID; 
        Case_Attachment_Relation__c car = new Case_Attachment_Relation__c();
        
        if (cid.length() == 18)
        {            
            s1 = cID.left(15);
        }
        
        car.Case_Id__c = s1;       
        car.Defect_Id__c = defectId;
        car.Rally_Attachment_Id__c = RallyattachemntId;
        car.Sf_Attachment_Id__c = Salesforceattid;
        car.Status__c = 'Sent';
        
        insert car;
        
    }
    
    WebService static void UpdateIntoCARBasedOnOperation(String defectId, String cID, String RallyattachemntId, String Salesforceattid)
    {
        
        // used to update values of Case_Attachment_Relation__c object form javascript used in button query for defectId, cID, AttachmentId and Salesforceattid from car

        try
        {
            Case_Attachment_Relation__c carList = [SELECT Sf_Attachment_Id__c, Case_Id__c, To_be_Send__c FROM Case_Attachment_Relation__c WHERE To_be_Send__c = true AND Sf_Attachment_Id__c =: Salesforceattid];
            if (carList != null)
            {
                carList.Rally_Attachment_Id__c = RallyattachemntId;
                carList.Defect_Id__c = defectId;
                carList.Status__c = 'Sent';
                carList.To_be_Send__c = false; 
                update carList;
            }
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
        }
        
    }    
    
    WebService static void insertDataInCaseComment(String caseId, String defectId, String commentId, String SalesforceCommentId)
    {
        
        // Used to update values of Case_Comment_Relation__c object form javascript used in button
        
        Case_Comment_Relation__c obj = new Case_Comment_Relation__c();
        String s1 = caseId; 
        
        if (caseId.length() == 18)
        {            
            s1 = caseId.left(15);
        }

        obj.Case_Id__c = s1;
        obj.Defect_Id__c = getDefectId(defectId);
        obj.Rally_discussion_Id__c = commentId;
        obj.Sf_Comment_Id__c = SalesforceCommentId;
        obj.Status__c = 'Sent';
        
        insert obj;
        
    }
    
    WebService static void UpdateIntoCommentObject(String caseId, String defectId, String rallycommentId, String SalesforceCommentId)
    {
        
        //used to insert values of Case_Comment_Relation__c object form javascript used in button
        
        try
        { 
            Case_Comment_Relation__c obj = [SELECT Sf_Comment_Id__c FROM Case_Comment_Relation__c WHERE To_be_Send__c = true AND Sf_Comment_Id__c =: SalesforceCommentId]; 
            if (obj != null)
            {
                obj.Defect_Id__c = defectId;
                obj.Rally_discussion_Id__c = rallycommentId;
                obj.Status__c = 'Sent';
                Obj.To_be_Send__c = false;
                update obj;
            }
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
        }
        
    }

    
}