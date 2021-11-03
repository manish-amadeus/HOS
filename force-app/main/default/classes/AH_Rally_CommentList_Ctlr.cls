/****************************************************************************************
Name            : AH_Rally_CommentList_Ctlr  (TC Org Name: CommentListOnCase)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Controller for AH_Rally_CommentList
				: 
				: 
******************************************************************************************/ 
public class AH_Rally_CommentList_Ctlr 
{
    
    // controller extension used on commentlistsection page     
    public Case currentCase {get; set;}
    public Case quriedCase;
    // wrapper which is used to populate comment with status respectively
    public List<CommentAndRallyAssociation> myCmmList {get; set;}
    public List<CaseComment> myCommentList;
    public List<Case_Comment_Relation__c> myCcrList;
    public Set<Id> commentIds;
    Set<CaseComment> myCommentSet;
    public ApexPages.StandardController con;
    public String urlInstance {get; set;}
    // Req 2 30/9
    public Map<String, String> commenthistory = new Map<String, String>();
    public Pagereference commentViewer; 
    String commentHistoryBody;
    String str;
    String baseurl;
    // Req 2 30/09 ends
    
    
    // constructor for extension controller which is used to initialize the variables
    public AH_Rally_CommentList_Ctlr(ApexPages.StandardController controller) 
    {
        con = controller;
        urlInstance = URL.getSalesforceBaseUrl().toExternalForm();
        init(con);
    }
    
    public void init(ApexPages.StandardController controller)
    {
        
        // varible created for holding defect Id on 9 april by saurabh
        String defectId;
        String Target = '::'; 
        
        currentCase = (Case)controller.getRecord();
        quriedCase = [SELECT Id, CaseNumber, Rally_Artifact_Ref__c FROM Case WHERE Id =: currentCase.Id];
        myCmmList = new List<CommentAndRallyAssociation>();
        commentIds = new Set<Id>();
        myCommentList = [SELECT Id, LastModifiedDate, CreatedById, CommentBody, LastModifiedBy.Name, CreatedBy.Name, CreatedDate FROM CaseComment WHERE ParentId =: controller.getId() ORDER BY LastModifiedDate DESC];
        myCommentSet = new Set<CaseComment>();
        
        // converting comment list to set in order use set methods
        for (CaseComment ct : myCommentList)
        {
            commentIds.add(ct.Id);
            myCommentSet.add(ct);
        } 
        
        myCcrList = [SELECT Case_Id__c, Status__c, To_be_Send__c, Defect_Id__c, Rally_discussion_Id__c, Sf_Comment_Id__c FROM Case_Comment_Relation__c WHERE Sf_Comment_Id__c IN :commentIds];
        
        if (!myCcrList.isEmpty())
        {
            defectId = myCcrList[0].Defect_Id__c;
        }  
              
        Set<Case_Comment_Relation__c> presentCcr = new Set<Case_Comment_Relation__c>();  
        
        for (CaseComment cmt : myCommentList)
        {
            for (Case_Comment_Relation__c myccr : myCcrList)
            {
                if (myccr.Sf_Comment_Id__c == cmt.Id)
                {
                    presentCcr.add(myccr);
                }  
            }    
        }
        
        // populate the wrapper with both comment and its status
        if (!presentCcr.isEmpty())
        {
            List<CaseComment> cmtNeedToRemove = new List<CaseComment>();
            for (CaseComment cmt : myCommentSet)
            {                 
                for (Case_Comment_Relation__c myccr : presentCcr)
                {    
                    if (myccr.Sf_Comment_Id__c == cmt.Id)
                    {
                        myCmmList.add(new CommentAndRallyAssociation(myccr, cmt));
                        cmtNeedToRemove.add(cmt);
                    } 
                }         
            }
            if (myCommentSet.removeAll(cmtNeedToRemove))
            {
                for (CaseComment cmt : myCommentSet)
                {
                    myCmmList.add(new CommentAndRallyAssociation(new Case_Comment_Relation__c(), cmt));
                }
            }
        }
        else
        {
            for (CaseComment cmt : myCommentSet)
            {
                myCmmList.add(new CommentAndRallyAssociation(new Case_Comment_Relation__c(), cmt));
            }
        }
        
        //order comments by last modified date
        CommentAndRallyAssociation temp = new CommentAndRallyAssociation(new Case_Comment_Relation__c(), new CaseComment(CommentBody=''));
        
        for (Integer i = 0; i < myCmmList.size(); i++)
        {
            for (Integer j = 0; j < (myCmmList.size()-i - 1); j++)
            {
                if (myCmmList[j].cmt.LastModifiedDate < myCmmList[j + 1].cmt.LastModifiedDate)
                {
                    temp = myCmmList[j];
                    myCmmList[j] = myCmmList[j + 1];
                    myCmmList[j + 1] = temp;
                }
            }
        }
        
        // modify 9 april 2015 by saurabh for sorting comment as per rally 
        // retrieving  discussion from rally to check comment and discussion pattern are same or not
// NEEDS COVERAGE          if (!Test.isRunningTest())
// NEEDS COVERAGE          {
            if (myCommentList.size() > 0 && defectID != null) 
            {
                String endpoint = AH_Rally_Credentials.endPoint + '/slm/webservice/' + AH_Rally_Credentials.versionNumber + '/HierarchicalRequirement/' + defectID + '/Discussion.js?pagesize=100';            
                String getRequestedBody = AH_Rally_Library.sendRequestObject('GET', endpoint, null);
system.debug(' ::*:: AH_Rally_CommentList_Ctlr.init.getRequestedBody = ' + getRequestedBody); 

                JSONParser parser = JSON.createParser(getRequestedBody);   
                
                List<String> sortedDiscussionId = new List<String>(); 
                List<DateTime> createdDateList = new List<DateTime>();
                List<String> sortedCommentId = new list<string>();
                
                while (parser.nextToken() != null)
                {
                    if (parser.getText() == 'Results')
                    {
                        
                        String objectId = '';
                        while (parser.nextToken() != null)
                        {  
                            // finding DiscussionId from json
                            if (parser.getText() == 'ObjectID') 
                            {
                                parser.nextToken();
                                objectId = '' + parser.getText();
                                sortedDiscussionId.add(objectId);
                            }  
                            if (parser.getText() == 'CreationDate')
                            {
                                parser.nextToken();
                                DateTime d = parser.getDatetimeValue();
                                createdDateList.add(d);
                            } 
                            
                        }
                        
                    }
                    
                }
                
                integer num = sortedDiscussionId.size();
                
                // sorting discussionId on basis of creationDate of rally obj
                for (integer i = 0; i < num; i++)
                {
                    for (integer j = num - 1; j > i; j--)
                    {
                        if (createdDateList[i]<createdDateList[j])
                        {
                            DateTime tempDate = createdDateList[i];
                            String tempId = sortedDiscussionId[i];
                            createdDateList[i] = createdDateList[j];
                            sortedDiscussionId[i] = sortedDiscussionId[j];
                            createdDateList[j] = tempDate;
                            sortedDiscussionId[j] = tempId;
                        }
                    }
                }
                
                //taking commentId in order as per in rally
                for (integer i = 0; i < sortedDiscussionId.size(); i++)
                {
                    for (Case_Comment_Relation__c ccr : myCcrList)
                    {
                        if (sortedDiscussionId[i] == ccr.Rally_discussion_Id__c)
                        {
                            sortedCommentId.add(ccr.Sf_Comment_Id__c);
                        }
                    }
                    
                }
                
                List<CommentAndRallyAssociation>  tempMyCmmList = new List<CommentAndRallyAssociation>();
                
                for(CommentAndRallyAssociation mcmm : MyCmmList)
                {
                    tempMyCmmList.add(mcmm);
                }
                
                integer arrange = 0;
                
                for (Integer i = 0; i < tempMyCmmList.size(); i++)
                {
                    boolean arrangeit = false;
                    String tempId = '' + tempMyCmmList[i].cmt.Id;
                    system.debug('orignal ' + tempMyCmmList[i].cmt.CommentBody);
                    for (Integer j= 0; j < sortedCommentId.size(); j++)
                    {  
                        system.debug('arrange' + arrange); 
                        if (tempId == sortedCommentId[j])
                        {
                            myCmmList[j + arrange] = tempMyCmmList[i];
                            arrangeit = true;
                            system.debug('after' + myCmmList[j + arrange].cmt.CommentBody);
                        }
                        
                    }
                    
                    if (!arrangeit)
                    {
                        arrange++;
                    }
                    
                }
                
            }
            
// NEEDS COVERAGE        }    
        
    }
    
    // method used to edit the comment
    public PageReference editCaseComment()
    {
        PageReference pref = new PageReference('/' + ApexPages.currentPage().getParameters().get('editCommentId') + '/e?parent_id=' + quriedCase.Id + '&retURL=%2F' + quriedCase.Id);
        return pref;
    }
    
    // method which is used to call init to rerender after send link is clicked
    public void init1()
    {
        init(con);
    }
    
    // method used to create new comment
    public PageReference createNewComment()
    {
        PageReference pref = new PageReference('/00a/e?parent_id=' + quriedCase.Id + '&retURL=%2F' + quriedCase.Id);
        return pref;
    }
    
    // method used to delete comment
    public void deleteComment()
    {
        CaseComment cmt = [SELECT Id FROM CaseComment WHERE Id =: ApexPages.currentPage().getParameters().get('deleteCmtId')];
        delete cmt;
    }
    
    // Req 2 Code starts 06/10 
    public Pagereference ViewHistory()
    {
        
        Case c1 = [SELECT Id, CaseNumber, Rally_Artifact_Ref__c FROM Case WHERE Id = :currentCase.Id];
        system.debug(c1);
        commentViewer = Apexpages.currentpage();
        Id id = ApexPages.currentPage().getParameters().get('id');
        
        baseurl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + id;
        
        str = Apexpages.currentpage().getURL();
        system.debug(baseurl);
        
        CaseComment cmt = [SELECT Id, commentbody, CreatedBy.Name, CreatedDate FROM CaseComment WHERE Id =: ApexPages.currentPage().getParameters().get('HistoryCmtId')];  
        commentHistoryBody = cmt.commentbody;  
        //change 4/3 2015 
        //Case_Comment_Relation__C ccrc = new Case_Comment_Relation__C();
        List<Case_Comment_Relation__C> ccrclist = [SELECT Rally_discussion_Id__c FROM Case_Comment_Relation__c WHERE sf_Comment_Id__c =: cmt.Id];  
        
        if (ccrclist.size() > 0) 
        {
            //code uncommented 30/10
            AH_Rally_CommentView ccv = new AH_Rally_CommentView();
            String creatorName = '' + cmt.CreatedBy.Name + '';
            AH_Rally_CommentView.init(quriedCase.Id, '' + ccrclist[0].Rally_discussion_Id__c, creatorName); 
            Commenthistory = ccv.getMap();
        }
        else
        {
            Commenthistory.clear();
            Commenthistory.put(commentHistoryBody, '');
        }
        
        return page.AH_Rally_CommentViewer; 
        
    }
    
    public Pagereference MainPage()
    {
        baseurl = baseurl.substringBefore('?');  
        PageReference pref = new PageReference(baseurl );  
        system.debug('base url is test: '+ baseurl );
        pref = new PageReference('/apex/CommentListSection');
        commentViewer.setRedirect(false);
        // Code by Veena Aphale ends
        return pref;
    }
    
    // call this method if you want to show all comments  
    public Map<string, string> getcommenthistory()
    {
        return commenthistory;
    }
    
    // wrapper(object) which is used to dispaly on the inline visual force page
    public class CommentAndRallyAssociation
    {
        
        public Case_Comment_Relation__c ccr {get; set;}
        public CaseComment cmt {get; set;}
        public String cmtBody {get; set;}
        public String content {get; set;}
        
        //constructor which is used to intialize the variables declared above.
        public CommentAndRallyAssociation(Case_Comment_Relation__c cc, CaseComment cm)
        {
            ccr = cc;
            cmt = cm;
            List<String> body = new List<String>();
            
            if (cm.CommentBody != '' || cm.CommentBody != null)
            {
                cmtBody = cm.CommentBody;
                String str = cmtBody;
                content = '';
                
                //providing line breaks if the case comment consists of new line 
                body = str.split('\r\n', -2);
                if (!body.isEmpty())
                {
                    for (String i : body)
                    {
                        if (i == '')
                        {
                            content = content + '<div><br/></div>';
                        }
                        else
                        {
                            content = content + '<div>' + i + '</div>';
                        }                        
                    }
                }
            }            
        }
        
    }
    
}