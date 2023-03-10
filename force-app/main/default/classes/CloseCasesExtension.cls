/****************************************************************************************
Name            : CloseCasesExtension 
Author          : Black Iron Group
Created Date    : 08/01/2010
Last Mod Date   : 04/13/2017 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : This class is the extension controller for the CloseCases VF page
                : It bulk changes the status & resolution types and inserts a case comment
				: on selected child cases selected on parent case page. 
				: There is a custom "Close Cases" button on the Child Cases related list. 
******************************************************************************************/
public with sharing class CloseCasesExtension 
{
    
	ApexPages.StandardSetController con;
	public string comments {get; set;}
	public Case parentCase {get; set;}

	public CloseCasesExtension(ApexPages.StandardSetController controller) 
	{
        con = controller;
    }

    public PageReference cancel() 
    { 
        // REDIRECT BACK TO CASE
    	return new PageReference(ApexPages.currentPage().getParameters().get('retURL')); 
    }
    
    public PageReference load() 
    {
        // CHECK TO SEE IF ANY CHILD CASES WERE SELECTED
    	if (con.getSelected().size() == 0) 
    	{
            // IF NOT REDIRECT BACK TO CASE
       		return new PageReference(ApexPages.currentPage().getParameters().get('retURL')); 
    	} 
        else 
        {
            // FILL LIST WITH SELECT CHILD CASE IDS
        	List<Case> lstCases = (List<Case>)con.getSelected();
            // EXTRACT PARENT ID FROM 1ST SELECTED CHILD CASE
        	Id parentId = (Id)lstCases[0].ParentId;            
            // RETRIEVE PARENT CASE TO GET DEFAULT STATUS & RESOLUTION TYPE 
        	parentCase = [SELECT Id, CaseNumber, Subject, Status, Resolution_Type__c FROM Case WHERE Id =: parentId];
        }
        return null;
    }
    
    public PageReference saveNew() 
    { 

        // LIST OF CHILD CASE COMMENTS TO BE INSERTED
        List<CaseComment> lstCaseCommentInserts = new List<CaseComment>();
        
        // LOOP THOUGH ALL SELECTED CHILD CASES UPDATING STATUS & RESOLUTION TYPE AND ADD COMMENT TO LIST
    	for (Case c : (List<Case>)con.getSelected()) 
    	{
    		c.Status = parentCase.Status;
    		c.Resolution_Type__c = parentCase.Resolution_Type__c; 
            // CREATE A CASE COMMENT RECORD IF ONE WAS SPECIFIED
            if ((comments != null) && (comments.length() > 0))
            {
                lstCaseCommentInserts.add(new CaseComment(ParentId = c.Id, IsPublished = false, CommentBody = comments));
            }
    	}

        // INSERT CASE COMMENTS
    	database.insert(lstCaseCommentInserts);
        
        // UPDATE STATUS & RESOLUTION TYPE ON SELECTED CHILD CASES
    	con.save();
        
	    return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        
    }

}