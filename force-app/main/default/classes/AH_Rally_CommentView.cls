/****************************************************************************************
Name            : AH_Rally_CommentView (TC Org Name: CaseCommentViewer) 
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Helper class for AH_Rally_CommentList_Ctlr
				: 
				: 
******************************************************************************************/
public class AH_Rally_CommentView 
{
    
    public static Map<String, String> commenthistory = new Map<String, String>();
    
    
    public AH_Rally_CommentView() 
    { 
    } 
    
    public Static void init(Id caseId, String rallyDiscussionId, String creatorName)
    {
        
        String defectId;
        String body;
        String target='::';        
        String comment;
        String owner;
        Integer len;
        Integer comnumber;
        List<Integer> ordercomments = new List<Integer>();
        
        List<Case_Comment_Relation__c> ccr = new List<Case_Comment_Relation__c>([SELECT defect_ID__c FROM Case_Comment_Relation__c WHERE case_Id__c =: caseID]);
        
system.debug(' ::: Case Comment relation = ' + ccr);
        
        for (Case_Comment_Relation__c cc : ccr)
        {
            defectID = cc.defect_ID__c;
        }
        
        String endpoint = AH_Rally_Credentials.endPoint + '/slm/webservice/' + AH_Rally_Credentials.versionNumber + '/HierarchicalRequirement/' + defectID + '/Discussion.js';            
        String getRequestedBody = AH_Rally_Library.sendRequestObject('GET', endpoint, null);
        
        JSONParser parser = JSON.createParser(getRequestedBody);
        
        while (parser.nextToken() != null)
        {
            
system.debug(' ::: parser.getText() = ' + parser.getText()); 
            
            if (parser.getText() == 'Results')
            {
                
                String objectId = '';
                while (parser.nextToken() !=null)
                {  
                    
                    // Finding DiscussionId from json
                    if (parser.getText() == 'ObjectID') 
                    {
                        parser.nextToken();
                        objectId = '' + parser.getText();
                    }    
                    
                    if (parser.getText() == 'Text')
                    {     
                        
                        parser.nextToken();
                        body = parser.getText();
                        
system.debug(' ::: body = ' + body);
                        
                        body = body.replace(target, '%^&');
                        comment = body.subStringBefore('%^&');
                        owner = creatorName;
                        
system.debug(' ::: body (after) = ' + body);
system.debug(' ::: comment = ' + comment);
                        
                        //comparing rallyDisussionId of click comment relation object to objectId coming from json
                        if (objectId.equals(rallyDiscussionId))
                        {
system.debug(' ::: Comment is greater than 4000 char');
                            commenthistory.put(comment, owner);
system.debug(' ::: Length = ' + comment.length() + ' Comment: ' + comment + ' Owner: ' + owner);
                        }
//                        else
//                        {
//							system.debug('Comment is less than 4000 char');
//                            //Req 2 Code 17-3-15
//                            //commenthistory.put(comment,owner);
//                            System.debug('Length is :' + comment.length() + ' Comment: ' + comment + ' Owner: ' + owner);
//                        }
                        
system.debug(' ::: commenthistory = ' + commenthistory);
                        
                    }
                    
                }
                
            }
            
        }
        
    } 
    
    public Map<String, String> getMap()
    {
        
system.debug(' ::: Map = ' + commenthistory + ' size' + commenthistory.size());
        
        if (commenthistory.size() < 1 || commenthistory.isEmpty())
        {
            commenthistory.put('THIS COMMENT IS DELETED FROM RALLY', '');
        }
        
        return commenthistory;
        
    }
    
}