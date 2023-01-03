/****************************************************************************************
Name            : AH_Rally_DataPull (TC Org Name: LRPullDataRally) 
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : 
				: 
				: 
******************************************************************************************/
public class AH_Rally_DataPull 
{

    @auraEnabled
    public static String callout(String endPoint, String CaseID)
    {
        
        system.debug('nitesh'+ CaseID);
        
        case cs = [SELECT Id, Rally_Artifact_Ref__c FROM Case WHERE Id =: CaseID];
        
        system.debug('nitesh' + cs.Rally_Artifact_Ref__c);
        
        try
        {
            if (cs.Rally_Artifact_Ref__c != null)
            {
                String res = AH_Rally_Library.sendRequestObject('GET', cs.Rally_Artifact_Ref__c, null);
                system.debug('nitesh'+ res);
                return res; 
            }
            else
            {
                return 'Please create user story first';
            }
            
        }
        catch (exception exp)
        {
            system.debug(exp.getMessage() + '...' + exp.getLineNumber());
            return 'null'; 
        }
        
    }
    
    @auraEnabled
    public static Map<String, List<String>> LRupdateSfofUserStory(String Owner, String USproject, String UserStoryId, String RallyStatus, String Release, String CaseId, String MasterTicket, String SalesforcePriority)
    {
        
        Case c = new Case();
        c.Id = CaseId;
        c.User_Story_Owner__c = Owner;
        c.User_Story_Project__c = USproject;
        c.User_Story_Id__c = UserStoryId;
        c.User_Story_Release__c = Release;
        c.UserStory_Rally_Status__c = RallyStatus;
        c.Master_Ticket__c = MasterTicket;
        c.Customer_Severity__c = AH_Rally_FieldMapper.getSalesforceCasePriorityMapping('Customer_Severity__c', SalesforcePriority);
        
        Map<String, List<String>> returnData = new Map<String, List<String>>();
        Case cs = [SELECT Id, Rally_Artifact_Ref__c FROM Case WHERE Id =: CaseID];
        
        try
        {
            
            String res = AH_Rally_Library.sendRequestObject('GET', cs.Rally_Artifact_Ref__c.replace('.js', '/Discussion.js?pagesize=100'), null);
            system.debug('nitesh'+ res);
            update c;
            List<String> reslist = new List<String>();
            List<String> CSRID = new List<String>();
            reslist.add(res);
            returnData.put('res', reslist);
            List<Case_Comment_Relation__c> CSR = [SELECT Rally_discussion_Id__c FROM Case_Comment_Relation__c WHERE Case_Id__c =: CaseID];
            
            for (Case_Comment_Relation__c csrdata : CSR)
            {
                CSRID.add(csrdata.Rally_discussion_Id__c);
            }
            
            if (CSRID.size() == 0)
            {
                CSRID.add('null');
                returnData.put('commentList', CSRID);
            }
            else
            {
                returnData.put('commentList', CSRID);
            }
            
            return returnData;
            
        }
        catch (exception exp)
        {
            system.debug(exp.getMessage() + '...' + exp.getLineNumber());
            List<String> reslist = new List<String>();
            reslist.add('null');
            returnData.put('res', reslist);
            return returnData;
        }

    }
    
    @auraEnabled
    public static Map<String, List<String>> insertComment(List<Decimal> cmm, String CaseID, List<String> cmb)
    {
        
        system.debug('nitesh'+ cmm);
        
        Map<String, List<String>> returnData = new map<String, List<String>>();
        Case cs = [SELECT Id, Rally_Artifact_Ref__c FROM Case WHERE Id =: CaseID];
        String UserStoryId = (cs.Rally_Artifact_Ref__c.substringAfterLast('/'));
        UserStoryId = UserStoryId.replace('.js', '');  
        List<Case_Comment_Relation__c> caseRel = new List<Case_Comment_Relation__c>();
        
        List<CaseComment> caseCmm = new List<CaseComment>();

        system.debug(cmm.size());
        system.debug(cmb.size());
        for (Decimal listdata :cmm)
        {
            system.debug(listdata);
        }
        
        if (cmb.size() > 0)
        {
            
            Integer commentCount = 0;
            for (Decimal cmList : cmm)
            {
                CaseComment cmData = new CaseComment();
                Case_Comment_Relation__c caseRelData = new Case_Comment_Relation__c();
                cmData.CommentBody = cmb[commentCount]; 
                cmData.ParentId = CaseID; 
                caseCmm.add(cmData); 
                caseRelData.Case_Id__c = CaseID; 
                caseRelData.Defect_Id__c = UserStoryId; 
                caseRelData.Rally_discussion_Id__c = cmList + ''; 
                caseRelData.Status__c = 'Received'; 
                caseRel.add(caseRelData);
                commentCount++;
            }
            
        }

        try
        {
            
            String res = AH_Rally_Library.sendRequestObject('GET', cs.Rally_Artifact_Ref__c.replace('.js', '/Attachments.js'), null);
            String ss = cs.Rally_Artifact_Ref__c;
            ss = ss.substringBefore('hierarchicalrequirement') + 'attachmentcontent/';
            system.debug(ss);
            List<String> attURL = new List<String>();
            attURL.add(ss);
            
            if (caseCmm.size() > 0)
            {
                insert caseCmm;
                for (integer i = 0; i < caseCmm.size(); i++)
                {
                    caseRel[i].Sf_Comment_Id__c = caseCmm[i].Id;
                }
                insert caseRel;
            }
            
            system.debug('nitesh'+ res);

            List<String> reslist = new list<string>();
            List<String> CSRID = new list<string>();
            reslist.add(res);
            returnData.put('res', reslist);
            List<Case_Attachment_Relation__c> CSR = [SELECT Rally_Attachment_Id__c FROM Case_Attachment_Relation__c WHERE Case_Id__c =: CaseID];
            
            for (Case_Attachment_Relation__c csrdata : CSR)
            {
                CSRID.add(csrdata.Rally_Attachment_Id__c);
            }
            
            if (CSRID.size() == 0)
            {
                CSRID.add('null');
                returnData.put('Attachment', CSRID);
            }
            else
            {
                returnData.put('Attachment', CSRID);
            }
            
            returnData.put('AttURL', attURL);
            return returnData;
            
        }
        catch (exception exp)
        {
            system.debug(exp.getMessage() + '...' + exp.getLineNumber());
            List<String> reslist = new List<String>();
            reslist.add('null');
            returnData.put('res', reslist);
            return returnData;
        }
        
    }      
    
    @auraEnabled
    public static String insertAttachment(List<String> attId, List<String> attName, List<String> attContent, String CaseID)
    {

system.debug(' ::: insertAttachment');        
system.debug(' ::: CaseID = ' + CaseID);
system.debug(' ::: attId = ' + attId);

        Case cs = [SELECT Id, Rally_Artifact_Ref__c FROM Case WHERE Id =: CaseID];
        List<Attachment> attList = new List<Attachment>();
        
        List<Case_Attachment_Relation__c> attListRel = new List<Case_Attachment_Relation__c>();
system.debug(' ::: cs.Rally_Artifact_Ref__c = ' + cs.Rally_Artifact_Ref__c); 
        
        String UserStoryId = (cs.Rally_Artifact_Ref__c.substringAfterLast('/'));
        UserStoryId = UserStoryId.replace('.js', '');  
        
//        try
//        {
            
            for (integer i = 0; i < attId.size(); i++ )
            {
                
                String ss = cs.Rally_Artifact_Ref__c;
                ss = ss.substringBefore('hierarchicalrequirement') + 'attachmentcontent/' + attid[i] + '.js';
system.debug(' ::: ss = ' + ss);
                
                String res = AH_Rally_Library.sendRequestObject('GET', ss, null);
system.debug(' ::: res = ' + res);      
                
                AH_Rally_AttachmentJSON attcls = (AH_Rally_AttachmentJSON)json.deserialize(res, AH_Rally_AttachmentJSON.class);
           
system.debug(' ::: attcls = ' + attcls);  
                
                Attachment att = new Attachment();
                String strblob = '';
                
                if (Test.isRunningTest())
                {
                    strblob = 'Hello world';
                }                    
                else
                {
                    strblob = String.valueOf(attcls.AttachmentContent.Content);
                }
                    
                att.Body = EncodingUtil.base64Decode(strblob);
                att.ContentType = attContent[i];
                att.Name = attName[i];
                att.ParentId = CaseID;
                attList.add(att);
                
            }
            
            system.debug(attList);
            
            if (attList.size() > 0)
            {
                
                insert attList;
                
                for (integer i = 0; i < attList.size(); i++)
                {
                    Case_Attachment_Relation__c attRel = new Case_Attachment_Relation__c();
                    attRel.Case_Id__c = CaseID;
                    attRel.Defect_Id__c = UserStoryId;
                    attRel.Rally_Attachment_Id__c = attid[i];
                    attRel.Sf_Attachment_Id__c = attList[i].Id;
                    attRel.Status__c = 'Received';
                    attListRel.add(attRel);
                }
                
                system.debug(attListRel);
                
                if (attListRel.size() > 0)
                {
                    insert attListRel;
                }
                
            }
            
            return 'Refresh';
            
//        }
//        catch (exception exp)
//        {
//            system.debug(' ::: ' + exp.getMessage() + ', Line #: ' + exp.getLineNumber());
//            return exp.getMessage();
//        }
        
    }
    
}