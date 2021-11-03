/****************************************************************************************
Name            : AH_CaseValidationHelper_Ctlr
Author          : Sean Harris
Created Date    : 11/05/2020
Last Mod Date   : 11/05/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : Controller for the AH_CaseValidationHelper Visualforce page.
                :            
******************************************************************************************/
public class AH_CaseValidationHelper_Ctlr 
{
   
    // PUBLIC VARIABLES ======================================
    // COLLECTIONS
	public List<lookupResult> lstLookupResult {get; set;} 
    public List<Lightning_Knowledge__kav> lstAttachedLKAs {get; set;}  	
    
    // OBJECTS
    public Case csCopy {get; set;} 
    public Account a {get; set;}    
    public Id selLKAId {get; set;} 
    
    // STRINGS
    public String strSearchTitle {get; set;}
    public String searchText {get; set;}
    public String strMsg {get; set;} 
    public String strCxlBtnText {get; set;} 
    public String strCxlBtnStyle {get; set;} 
    public String strMsgColor {get; set;} 
    public String toastMsg {get; set;} 
    
    // NUMERICS
    public Integer iSelLKAVersion {get; set;} 
    
    // BOOLEANS    
    public Boolean showAttachLKA {get; set;} 
    public Boolean isSuccess {get; set;}
    
    // PRIVATE VARIABLES ====================================
//    private String strSOQL {get; set;}
    private Case cs {get; set;}
    private List<CaseArticle> lstCaseArticles {get; set;} 
    
    
    public AH_CaseValidationHelper_Ctlr(ApexPages.StandardController controller) 
    {
        
        strCxlBtnText = 'Cancel';
        showAttachLKA = false;
        strCxlBtnStyle = 'slds-button slds-button_destructive';
        strMsgColor = 'green';
        isSuccess = false;
        
        cs = (Case)controller.getRecord(); 
        
        if (cs.Id == null) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No case found.')); 
        }
        else
        {
         
            Case csCopy = [SELECT Id, CaseNumber, Status, Origin, Priority, Subject, Type, 
                           AccountId, Account.Name, ContactId, Contact.Name, RecordTypeId, RecordType.Name, 
                           DI_to_be_tagged__c, Has_No_DI__c, Customer_Severity__c, Case_Reason__c
                           FROM Case WHERE Id =: cs.Id];
             
            if (csCopy.AccountId != null)
            {
                a = [SELECT Id, Name FROM Account WHERE Id =: csCopy.AccountId];
            }

            lstCaseArticles = new List<CaseArticle>(); 
            fillAttachedLKAs();
            
        }
      
    }
	
    // ================================================================================================================================
	//  FUNCTIONS & METHODS ===========================================================================================================    
    // ================================================================================================================================
    public void fillAttachedLKAs()
    {
        
        Set<Id> setIDs = new Set<Id>();
        
        for (CaseArticle ca1 : [SELECT KnowledgeArticleId FROM CaseArticle WHERE CaseId =: cs.Id])
        {
            setIDs.add(ca1.KnowledgeArticleId);
        }
        
        if (lstCaseArticles != null)
        {
            for (CaseArticle ca2 : lstCaseArticles)
            {
                setIDs.add(ca2.KnowledgeArticleId);
            }            
        }
        
        lstAttachedLKAs = new List<Lightning_Knowledge__kav>();
        for (Lightning_Knowledge__kav kav : [SELECT Id, KnowledgeArticleId, ArticleNumber, VersionNumber, Solution_Domain__c, Title, RecordType.Name 
                                             FROM Lightning_Knowledge__kav 
                                             WHERE KnowledgeArticleId IN : setIDs])    
        {
            lstAttachedLKAs.add(kav);
        }
   
    }
    
    public void openSearch()
    {
        strSearchTitle = 'Quick Update - Article Search';
        showAttachLKA = true;        
    }

    public pageReference doClose()
    {
        pageReference pr = new pageReference('/' + cs.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    public void closeSearch()
    {
        if (lstLookupResult != null)
        {
            lstLookupResult.clear();
        }
        showAttachLKA = false;
    }
    
    public void doAttach()
    {
        showAttachLKA = true;
        openSearch();
    }
    
    public void closeCase()
    {   
        cs.Status = 'Closed';
        doSave();
    }

    public void doLKASearch()
    {
        
        String strKeyWord = string.escapeSingleQuotes(searchText);    
        String q = 'SELECT Id, KnowledgeArticleId, ArticleNumber, VersionNumber, Solution_Domain__c, Title, RecordType.Name '; 
        q += 'FROM Lightning_Knowledge__kav ';
        q += 'WHERE Id != null ';
        //q += 'AND RecordType.Name != \'Procedural\' '; 
        q += 'AND PublishStatus != \'Archived\' '; 
        q += 'AND (';
        q += 'Title LIKE \'%' + strKeyWord + '%\' ';
        q += 'OR ArticleNumber LIKE \'%' + strKeyWord + '%\') ';
        q += 'ORDER BY Title ASC ';
		q += 'LIMIT 200';
		
        List<Lightning_Knowledge__kav> lstLKAResults = Database.query(q);
        
        lstLookupResult = new List<lookupResult>();
        
        for (Lightning_Knowledge__kav lka : lstLKAResults)
        {
            lookupResult lr3 = new lookupResult(
                lka.Id,
                lka.Title,
                lka.ArticleNumber,
                lka.Solution_Domain__c,
                lka.KnowledgeArticleId, 
                lka.VersionNumber
            );
            lstLookupResult.add(lr3);
        }        
        
    }

    public void doArticleSelect()
    {    
        CaseArticle ca = new CaseArticle();
        ca.CaseId = cs.Id;
        ca.KnowledgeArticleId = selLKAId;
        ca.ArticleLanguage = 'en_US';
        ca.ArticleVersionNumber = iSelLKAVersion;       
        lstCaseArticles.add(ca);
        fillAttachedLKAs();
    }
    
    public void doArticleRemove()
    {    
        
        List<CaseArticle> lstCA = new List<CaseArticle>([SELECT Id, KnowledgeArticleId FROM CaseArticle WHERE CaseId =: cs.Id AND KnowledgeArticleId =: selLKAId]);
		Integer iIdx = 0;
        
        for (Lightning_Knowledge__kav kav1 : lstAttachedLKAs)
        {         
            if (kav1.KnowledgeArticleId == selLKAId)
            {            
                break;
            }
            iIdx++;
        }
        
		lstAttachedLKAs.remove(iIdx);
        
        if (!lstCA.isEmpty())
        {
            database.delete(lstCA);
        }
   
    }        
    
    public void doSave()
    {

        strCxlBtnText = 'Cancel'; 
        strCxlBtnStyle = 'slds-button slds-button_destructive'; 
        strMsgColor = 'green';         
     	strMsg = '';
        
        try
        {
            
            update cs;
            
            if (!lstCaseArticles.isEmpty())
            {
                List<CaseArticle> lstCaseArticleInserts = new List<CaseArticle>();
                for (CaseArticle csArt : lstCaseArticles)
                {
                    if (csArt.Id == null)
                    {
                        lstCaseArticleInserts.add(csArt);
                    }
                }
                
                if (!lstCaseArticleInserts.isEmpty())
                {
                    database.insert(lstCaseArticleInserts);
                }
                
            }
            
            isSuccess = true;
            strCxlBtnText = 'Done';
            strCxlBtnStyle = 'slds-button slds-button_success';
            toastMsg = 'Case was saved successfully!';
            
            if (cs.Status == 'Closed')
            {
                toastMsg = 'Case was closed successfully!';
            }
            
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, strMsg));
        }
        catch (Exception e)
        {
            strMsgColor = 'red'; 
            strMsg = e.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, strMsg)); 
            isSuccess = false;
        }        
        
    }
    
    // ================================================================================================================================
	//  WRAPPER CLASSES ===============================================================================================================
    // ================================================================================================================================
    public class lookupResult
    {  
        
        public Id recId {get; set;}
        public String strName {get; set;}  
        public String strVal1 {get; set;}  
		public String strVal2 {get; set;}  
        public Id KnowledgeArticleId {get; set;} 
        public Integer iArticleVersionNumber {get; set;}  
        
        public lookupResult(Id p1, String p2, String p3, String p4, Id p5, Integer p6)
        {
            this.recId = p1; 
            this.strName = p2;  
            this.strVal1 = p3; 
            this.strVal2 = p4; 
            this.KnowledgeArticleId = p5; 
            this.iArticleVersionNumber = p6; 
        }
        
    }    
    
}