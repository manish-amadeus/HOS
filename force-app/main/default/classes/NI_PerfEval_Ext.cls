/****************************************************************************************
Name            : NI_PerfEval_Ext Class
Author          : Sean Harris
Created Date    : 11/19/2014
Last Mod Date   : 11/07/2015
Last Mod By     : Stuart Emery
NICC Reference  : Recent Updates Per NICC-015837
Description     : Class that handles events in VF Pages:
                :    NI_PerfEval_New, NI_PerfEval_View, NI_PerfEval_Edit
                :
******************************************************************************************/
public with sharing class NI_PerfEval_Ext 
{
    
    // RECORD SPECIFIC VARIABLES ===================================== 
    public NI_Employee_Performance_Evaluation__c pe {get; set;}    
    private Id id = System.currentPageReference().getParameters().get('id');
    private ApexPages.StandardController stdCtrl;
    
    // USER IDENTIFIER VARIABLES =====================================
    public boolean bIsEmployee {get; set;}
    public boolean bIsManager {get; set;}
    public boolean bIsAdministrator {get; set;}
    private final string strAdminPassword = 'nihr14';
    
    // RELATED LIST ID ===============================================
    public Id goalId {get; set;}
    public Id pathId {get; set;}  

    // LISTS TO HOLD RELATED RECORDS =================================
    public List<NI_PE_Assessment__c> lstAssessment {get; set;}
    public List<NI_PE_Assessment__c> lstMgmntAssessment {get; set;}    
    public List<NI_Career_Path__c> lstCareerPaths {get; set;}
    public List<NI_PerfEval_Goals__c> lstGoals {get; set;}
    public List<ProcessInstanceStep> lstApprovalHistory {get;set;}  //LIST TO HOLD THE PERFORMANCE EVALUATION APPROVAL HISTORY
    
    // USER DISPLAY SWITCHES =========================================
    public boolean bShowEditButton {get; set;}
    public boolean bShowCreateNewButton {get; set;}
    public boolean bShowSharingButton {get; set;}
    public boolean bShowFormLock {get; set;}
    public boolean bShowManagerRatingColumn {get; set;}
    public boolean bShowManagerRatingSummary {get; set;}
    public boolean bShowManagerOverallRating {get; set;}
    public boolean bShowAddGoalButton {get; set;}
    public boolean bShowGoalActionColumn {get; set;}
    public boolean bShowAddPathButton {get; set;}
    public boolean bShowAddPathActionColumn {get; set;}
    public boolean bShowNoteAndAttachments {get; set;}
    public boolean bShowApprovalHistory {get; set;}    
    public boolean bShowSendToManagerButton {get; set;}
    public boolean bShowReturnToEmployeeButton {get; set;}
    public boolean bShowReviewWithEmployeeButton {get; set;}
    public boolean bShowEmployeeSignoffButton {get; set;}
    
    public boolean bShowDeleteButton {get; set;}
    public boolean bShowCoManager {get; set;}
    public boolean bShowInfoSection {get; set;}
    public boolean bShowAssessmentSection {get; set;}
    public boolean bShowMgtAssessmentSection {get; set;}
    public boolean bShowPerfSummarySection {get; set;}
    public boolean bShowOverallRatingSection {get; set;}
    public boolean bShowGoalsSection {get; set;}
    public boolean bShowCareerPathSection {get; set;}
    public boolean bDisplayApprovals {get; set;}

    public boolean bShowCreateNewEvalButton {get; set;}
    
    // =======================================================================
    // CLASS CONSTRUCTOR =====================================================
    // =======================================================================
    public NI_PerfEval_Ext(ApexPages.StandardController stdController)
    {

        this.stdCtrl = stdController;
        this.pe = (NI_Employee_Performance_Evaluation__c)stdController.getRecord();
        
        // ADMINISTRAVIVE BACKDOOR ===========================================
        bIsAdministrator = false;
        
        string strAdminPass = '';
        
        if (ApexPages.CurrentPage().getParameters().containsKey('admin')) 
        {
            strAdminPass = ApexPages.CurrentPage().getParameters().get('admin');            
        } 
        
        if (strAdminPass == strAdminPassword)
        {
            bIsAdministrator = true;
        }

        // DETECT USER ROLE VIEWING EVALUTION ================================
        bIsEmployee = false;
        bIsManager = false;

            
        System.debug('NI_PerfEval_Ext Constructor runas test: Current Id = ' + UserInfo.getUserId() + ' , Current User = ' + UserInfo.getUserName() + ', Current Profile = ' + UserInfo.getProfileId() + ', pe.Employee_Name__c = ' + pe.Employee_Name__c + ', pe.Manager__c = ' + pe.Manager__c);
                      
        
        if (pe.Employee_Name__c == UserInfo.getUserId())
        {
            bIsEmployee = true;
        }
        
                if ((pe.Manager__c == UserInfo.getUserId()) || (pe.Collaborating_Manager__c == UserInfo.getUserId())
           || (pe.Collaborating_Manager_2__c == UserInfo.getUserId()) || (pe.Collaborating_Manager_3__c == UserInfo.getUserId())) 
 
        {
            bIsManager = true;
        } 
        
        // NICC-012857 - Start
        if (NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'HR Admin') && !bIsEmployee)
        {
            bIsAdministrator = true;
        }        
        // NICC-012857 - End        
        
        // INITIALIZE COMPONENT VISIBLITY ===================================
        initComponentVisibilty();
    
        // POPULATE RELATED LISTS =========================================== 
        getAssessments();
        getMgmntAssessments(); 
        getGoals();
        getCareerPaths();
        getlstApprovalHistory();

    }



    
    // =========================================================================
    //  RECORD STATUS VARIABLE SETTER FUNCTIONS
    // =========================================================================
    public boolean isEmployeeDraft(NI_Employee_Performance_Evaluation__c peval)
    { 
        boolean bRet = false; 
        if (peval.Status__c == 'Employee Draft')
        {
            bRet = true;
        } 
        return bRet;
    }
    
    public boolean isManagerDraft(NI_Employee_Performance_Evaluation__c peval)
    { 
        boolean bRet = false;
        if (peval.Status__c == 'Manager Draft')
        {
            bRet = true;
        } 
        return bRet;
    }
    
    public boolean isInReview(NI_Employee_Performance_Evaluation__c peval)
    { 
        boolean bRet = false;
        if (peval.Status__c == 'In Review')
        {
            bRet = true;
        } 
        return bRet;
    }

    public boolean isPendingApproval(NI_Employee_Performance_Evaluation__c peval)
    { 
        boolean bRet = false;
        if (peval.Status__c == 'Pending Approval')
        {
            bRet = true;
        } 
        return bRet;
    }
    
    public boolean isEvaluationComplete(NI_Employee_Performance_Evaluation__c peval)
    { 
        boolean bRet = false;
        if (peval.Status__c == 'Evaluation Complete')
        {
            bRet = true;
        } 
        return bRet;
    }
    
    

    
    // =======================================================================
    //  RECORD LOADING FUNCTIONS 
    // =======================================================================
    
    // QUERY TO RETURN A LIST OF ASSESSMENT RECORDS ==========================
    public List<NI_PE_Assessment__c> getAssessments() 
    {
        
        lstAssessment = [SELECT Category__c, Description__c, Manager_Rating__c, Self_Appraisal_Rating__c
                         FROM NI_PE_Assessment__c
                         WHERE NI_Employee_Performance_Evaluation__c =: id
                         AND Category__c != 'Management Skills' 
                         ORDER BY Category__c ASC, Description__c ASC];
        
        return lstAssessment; 
        
    }
    
    // QUERY TO RETURN A LIST OF MANAGEMENT SKILL ASSESSMENT RECORDS ========
    public List<NI_PE_Assessment__c> getMgmntAssessments() 
    {
        
        lstMgmntAssessment = [SELECT Category__c, Description__c, Manager_Rating__c, Self_Appraisal_Rating__c
                              FROM NI_PE_Assessment__c
                              WHERE NI_Employee_Performance_Evaluation__c =: id
                              AND Category__c = 'Management Skills' 
                              ORDER BY Category__c ASC, Description__c ASC];
        
        return lstMgmntAssessment; 
        
    }

    // QUERY TO RETURN A LIST OF Goal RECORDS ==============================
    public List<NI_PerfEval_Goals__c> getGoals() 
    {
        
        lstGoals = [SELECT Category__c, Current_Previous_Year__c, Goal__c, Status__c, Name, Id, CreatedBy.Name, Set_By__r.Name  
                    FROM NI_PerfEval_Goals__c
                    WHERE Employee_Performance_Evaluation__c =: id
                    ORDER BY Current_Previous_Year__c ASC, Category__c ASC, Status__c ASC];
        
        return lstGoals; 
        
    }    
    
    // QUERY TO RETURN A LIST OF Career Path RECORDS =======================
    public List<NI_Career_Path__c> getCareerPaths() 
    {
        
        lstCareerPaths = [SELECT Career_Path_Comments__c, Department__c, Manager__c, Name, Id 
                          FROM NI_Career_Path__c
                          WHERE NI_Employee_Performance_Evaluation__c =: id];
        
        return lstCareerPaths; 
        
    }
    

   
    
    
    // =======================================================================
    //  DML FUNCTIONS
    // =======================================================================
    public PageReference createEval() 
    { 

system.debug(' ================  ENTERING NI_PerfEval_Ext.createEval() ================ ');
        
        Date dtToday = Date.today();
        string strYear = String.ValueOf(dtToday.year());

		// SMH ADDED THIS LOGIC TO SET THE YEAR TO CURRENT - 1 WHEN CREATED AFTER DECEMBER
        if (dtToday.month() < 7) // IF CURRENT MONTH IS: Jan, Feb, Mar, Apr, May or June
        {
            strYear = String.ValueOf(dtToday.year() - 1);
        }
        
        User u = [SELECT Id, Name, Title, ManagerId FROM User WHERE Id =: UserInfo.getUserId()];
        
system.debug('USER from UserInfo.getUserId() = ' + u); 
        
        //CREATE A NEW PERFORMANCE EVALUATION RECORD  
        NI_Employee_Performance_Evaluation__c e = new NI_Employee_Performance_Evaluation__c();
//        e.OwnerId = UserInfo.getUserId();		// SMH
        e.Employee_Name__c = UserInfo.getUserId();
        e.Job_Title__c = u.Title;
        e.Manager__c = u.ManagerId;
        e.Performance_Evaluation_Year__c = strYear;
        insert e;
        
//        pe = e;			// SMH
        
        //CREATE A NEW ASSESSMENT RECORD
        
        //LIST TO HOLD THE PERFORMANCE EVALUDATION ASSESSMENT CUSTOM SETTINGS RECORDS  
        List<Performance_Evaluations_Assessments__c> lstCS = Performance_Evaluations_Assessments__c.getall().values();
        
        if (lstCS.size() < 1)
        {
            System.debug('THERE ARE NO RECORDS IN THE Performance_Evaluations_Assessments__c CUSTOM SETTING');
        }
        else
        {             
            //LIST TO HOLD THE ASSESSMENT VALUES FROM THE CUSTOM SETTING  
            List<NI_PE_Assessment__c> lstAssessmentsToInsert = new List<NI_PE_Assessment__c>();
            
            for (Performance_Evaluations_Assessments__c p : lstCS)
            {
                NI_PE_Assessment__c a = new NI_PE_Assessment__c();
                a.NI_Employee_Performance_Evaluation__c = e.Id;
                a.Category__c = p.Category__c;        
                a.Description__c = p.Description__c;
                lstAssessmentsToInsert.add(a); 
            }    
            
            Database.insert(lstAssessmentsToInsert);
            
            PageReference pageRef = Page.NI_PerfEval_Edit; 
            pageRef.setRedirect(true);  
            pageRef.getParameters().put('id', e.id);  
            return pageRef;    
            
        }
        return null; 
    }                    
 
    // CALL SAVE METHODS
    public PageReference callSaveMethods() 
    {        
        
        saveAssessments(); 
        
        pe.Manager_Assessments_Complete__c = false; 
        
        if (bHasAllAssessments(pe.Id, 'MANAGER'))
        {
            pe.Manager_Assessments_Complete__c = true; 
        }
        
        pe.Employee_Assessments_Complete__c = false; 
        
        if (bHasAllAssessments(pe.Id, 'EMPLOYEE'))
        {
            pe.Employee_Assessments_Complete__c = true; 
        }         
        
        stdCtrl.save(); 
                
        PageReference pageRef = new PageReference('/' + id); 
        pageRef.setRedirect(true);
        return pageRef;           
        
    }   
       
    // CUSTOM SAVE ASSESSMENTS METHOD
    public PageReference saveAssessments() 
    {         
        // USE TRY CATCH METHOD TO UPDATE ALL OF THE ASSESSMENT RECORDS
        try
        {
            //Update lstAssessment;
            database.update(lstAssessment);
            database.update(lstMgmntAssessment);
        } 
        catch (Exception e) 
        {   
            System.debug(e.getMessage());
            ApexPages.addMessages(e);       // DISPLAY THE ERROR MESSAGE ON THE VF PAGE            
        }
        
        lstAssessment = null; //SET THE LIST TO NULL SO A NEW LIST IS CREATED
        
        PageReference pageRef = new PageReference('/' + id);
        pageRef.setRedirect(true);
        return pageRef;           

    }     

    
    

    // =======================================================================
    //  COMMANDBUTTON FUNCTIONS
    // =======================================================================
    public PageReference editEval() 
    {   
        string strURL = '/apex/NI_PerfEval_Edit?id=' + id;
        if (bIsAdministrator)
        {
            strURL += '&admin=' + strAdminPassword;
        }
        PageReference pageRef = new PageReference(strURL);
        pageRef.setRedirect(true);
        return pageRef;        
    }
    
    public PageReference cancelEditEval() 
    {             
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_View?id=' + id);
        pageRef.setRedirect(true);
        return pageRef;        
    } 
    
    public PageReference deleteEval() 
    { 
        Schema.DescribeSObjectResult s = NI_Employee_Performance_Evaluation__c.sObjectType.getDescribe();
        String keyPrefix = s.getKeyPrefix();

        // DELETE THE PERFORMANCE EVALUATION RECORD
        NI_Employee_Performance_Evaluation__c e = [SELECT Id FROM NI_Employee_Performance_Evaluation__c WHERE Id =: id LIMIT 1];  
        delete e;       

        PageReference pageRef = new PageReference('/' + keyPrefix);
        pageRef.setRedirect(true);
        return pageRef; 
    } 
   
    public PageReference sendToManager() 
    { 
        pe.Status__c = 'Employee Completed';
        PageReference pageRef = callSaveMethods();
        pageRef.setRedirect(true);
        return pageRef;
    } 

    public PageReference returnToEmployee() 
    { 
        pe.Status__c = 'Manager Rejected';
        PageReference pageRef = callSaveMethods();
        pageRef.setRedirect(true);
        return pageRef;
    } 

    public PageReference reviewWithEmployee() 
    { 
        pe.Status__c = 'Manager Completed';
        PageReference pageRef = callSaveMethods();
        pageRef.setRedirect(true);
        return pageRef;
    } 

    public PageReference employeeSignoff() 
    { 

        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Approval process initiated');
        req1.setObjectId(pe.Id);
        //req1.setSubmitterId(pe.OwnerId); 
        //req1.setProcessDefinitionNameOrId('Performance_Evaluation_Approval'); 
        //req1.setSkipEntryCriteria(true); 
        
        //SUBMIT FOR APPROVAL
        Approval.ProcessResult result = Approval.process(req1);   
        
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_View?id=' + id);
        pageRef.setRedirect(true);
        return pageRef; 
    }     

    public PageReference newGoal()
    {
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_Goal?retURL=/apex/NI_PerfEval_View?id=' + id + '&evid=' + id);
        pageRef.setRedirect(true);
        return pageRef;          
    }
    
    public PageReference selectGoal() 
    {
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_Goal?retURL=/apex/NI_PerfEval_View?id=' + id + '&evid=' + id + '&id=' + goalId);
        pageRef.setRedirect(true); 
        return pageRef;         
    }  

    public PageReference newPath()
    {
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_Path?retURL=/apex/NI_PerfEval_View?id=' + id + '&evid=' + id);
        pageRef.setRedirect(true);
        return pageRef;          
    }
    
    public PageReference selectPath() 
    {
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_Path?retURL=/apex/NI_PerfEval_View?id=' + id + '&evid=' + id + '&id=' + pathId);
        pageRef.setRedirect(true); 
        return pageRef;         
    }      

    
    
    
    // =======================================================================
    //  RECORD VERIFICATION FUNCTIONS 
    // =======================================================================
    private boolean bHasAllAssessments(Id idRecordId, string sMode)
    {
        boolean bRet = true;
        
        if (sMode == 'MANAGER')
        {
            for (NI_PE_Assessment__c a1 : [SELECT Category__c, Description__c, Manager_Rating__c, Self_Appraisal_Rating__c
                                           FROM NI_PE_Assessment__c
                                           WHERE NI_Employee_Performance_Evaluation__c =: idRecordId
                                           AND Category__c = 'Management Skills' 
                                           ORDER BY Category__c ASC, Description__c ASC])
            {
                if (a1.Self_Appraisal_Rating__c == null)
                {
                    bRet = false;
                }
            }
        }
        else
        {
            for (NI_PE_Assessment__c a2 : [SELECT Category__c, Description__c, Manager_Rating__c, Self_Appraisal_Rating__c
                                           FROM NI_PE_Assessment__c
                                           WHERE NI_Employee_Performance_Evaluation__c =: idRecordId
                                           AND Category__c != 'Management Skills' 
                                           ORDER BY Category__c ASC, Description__c ASC])
            {
                if (a2.Self_Appraisal_Rating__c == null)
                {
                    bRet = false;
                }
            }
        }
        return bRet;
    }

    //METHOD TO POPULATE THE APPROVAL HISTORY LIST  
        private void getlstApprovalHistory() {
            
            //GET THE TIMEZONE FOR THE CURRENT USER  
              TimeZone tz = UserInfo.getTimeZone();
        
        //SET THE CURRENT DATETIME TO THE TIMEZONE OF THE CURRENT USER  
        //localDt = DateTime.now().format('MM/dd/yyyy h:mm a, z',tz.toString());
           
            lstApprovalHistory = [SELECT Id, 
                                  SystemModstamp, OriginalActor.Name, Actor.Name, Comments, 
                                  StepStatus, ProcessInstance.Status, ProcessInstance.LastModifiedById  
                                  FROM ProcessInstanceStep
                                  WHERE ProcessInstance.TargetObjectId =: Id
                                  ORDER BY SystemModstamp DESC];
                                 
             
             System.debug('**NUMBER OF lstApprovalHistory RECORDS: ' + lstApprovalHistory.size());
               //if(lstApprovalHistory.size()>0)
               //       {
               //         bDisplayApprovals = true;
               //       }
               //   else
               //       {
               //         bDisplayApprovals = false;
                //      }                          
                                            
            }      

    
    
    // =======================================================================
    // VISIBILTY & EDIT SWITCHES =============================================
    // =======================================================================
    
    @TestVisible private void initComponentVisibilty()
    {
        
        // ADMIN VIP PASS =========================================
        if (bIsAdministrator)
        {
            bShowEditButton = true;
            bShowSharingButton = true;
            bShowFormLock = false;
            bShowManagerRatingColumn = true;
            bShowManagerRatingSummary = true;
            bShowManagerOverallRating = true;
            bShowAddGoalButton = true;
            bShowGoalActionColumn = true;
            bShowAddPathButton = true;
            bShowAddPathActionColumn = true;
            bShowNoteAndAttachments = true; 
            bShowApprovalHistory = true;
            bDisplayApprovals = false;
            bShowSendToManagerButton = true; 
            bShowReturnToEmployeeButton = true; 
            bShowReviewWithEmployeeButton = true; 
            bShowEmployeeSignoffButton = true;
            // FOR EDIT VF PAGE
            bShowDeleteButton = true;
            bShowCoManager = true;
            bShowInfoSection = true;
            bShowAssessmentSection = true;
            bShowMgtAssessmentSection = true;
            bShowPerfSummarySection = true;
            bShowOverallRatingSection = true;
            bShowGoalsSection = true;
            bShowCareerPathSection = true;              
            return;                   
        }
        
        
        // EMPLOYEE CONDITIONS ====================================
        
        
        // IF EMPLOYEE IS VIEWING AND IS EMPLOYEE DRAFT ===========
        if (bIsEmployee && isEmployeeDraft(pe))
        {
            bShowEditButton = true;
            bShowSharingButton = true;
            bShowFormLock = false;
            bShowManagerRatingColumn = false;
            bShowManagerRatingSummary = false;
            bShowManagerOverallRating = false;
            bShowAddGoalButton = true;
            bShowGoalActionColumn = true;
            bShowAddPathButton = true;
            bShowAddPathActionColumn = true;
            bShowNoteAndAttachments = true; 
            bShowApprovalHistory = false;
            bDisplayApprovals = false;
            bShowSendToManagerButton = true; 
            bShowReturnToEmployeeButton = false; 
            bShowReviewWithEmployeeButton = false; 
            bShowEmployeeSignoffButton = false;
            // FOR EDIT VF PAGE
            bShowDeleteButton = true;
            bShowCoManager = false;
            bShowInfoSection = true;
            bShowAssessmentSection = true;
            bShowMgtAssessmentSection = true;
            bShowPerfSummarySection = true;
            bShowOverallRatingSection = true;
            bShowGoalsSection = true;
            bShowCareerPathSection = true;            
            return;            
        }

        // IF EMPLOYEE IS VIEWING AND IS MANGAGER DRAFT ===========
        if (bIsEmployee && isManagerDraft(pe))
        {
            bShowEditButton = false;
            bShowSharingButton = true;
            bShowFormLock = true;
            bShowManagerRatingColumn = false;
            bShowManagerRatingSummary = false;
            bShowManagerOverallRating = false;
            bShowAddGoalButton = false;
            bShowGoalActionColumn = false;
            bShowAddPathButton = false;
            bShowAddPathActionColumn = false;
            bShowNoteAndAttachments = true; 
            bShowApprovalHistory = false;
            bDisplayApprovals = false;
            bShowSendToManagerButton = false; 
            bShowReturnToEmployeeButton = false; 
            bShowReviewWithEmployeeButton = false; 
            bShowEmployeeSignoffButton = false; 
            // FOR EDIT VF PAGE
            bShowDeleteButton = false;
            bShowCoManager = false;
            bShowInfoSection = false;
            bShowAssessmentSection = false;
            bShowMgtAssessmentSection = false;
            bShowPerfSummarySection = false;
            bShowOverallRatingSection = false;
            bShowGoalsSection = false;
            bShowCareerPathSection = false;                        
            return;            
        } 
        
        // IF EMPLOYEE IS VIEWING AND IS IN REVIEW ================
        if (bIsEmployee && isInReview(pe))
        {
            bShowEditButton = false;
            bShowSharingButton = true;
            bShowFormLock = false;
            bShowManagerRatingColumn = true;
            bShowManagerRatingSummary = true;
            bShowManagerOverallRating = true;
            bShowAddGoalButton = false;
            bShowGoalActionColumn = false;
            bShowAddPathButton = false;
            bShowAddPathActionColumn = false;
            bShowNoteAndAttachments = true; 
            bShowApprovalHistory = false;
            bDisplayApprovals = false;
            bShowSendToManagerButton = false; 
            bShowReturnToEmployeeButton = false; 
            bShowReviewWithEmployeeButton = false; 
            bShowEmployeeSignoffButton = false; 
            // FOR EDIT VF PAGE
            bShowDeleteButton = false;
            bShowCoManager = false;
            bShowInfoSection = false;
            bShowAssessmentSection = false;
            bShowMgtAssessmentSection = false;
            bShowPerfSummarySection = false;
            bShowOverallRatingSection = false;
            bShowGoalsSection = true;
            bShowCareerPathSection = true;             
            return;             
        }
        
        // IF EMPLOYEE IS VIEWING AND IS PENDING APPROVAL ========
        if (bIsEmployee && isPendingApproval(pe))
        {
            bShowEditButton = false;
            bShowSharingButton = true;
            bShowFormLock = false;
            bShowManagerRatingColumn = true;
            bShowManagerRatingSummary = true;
            bShowManagerOverallRating = true;
            bShowAddGoalButton = false;
            bShowGoalActionColumn = false;
            bShowAddPathButton = false;
            bShowAddPathActionColumn = false;
            bShowNoteAndAttachments = true; 
            bShowApprovalHistory = true;
            bDisplayApprovals = false;
            bShowSendToManagerButton = false; 
            bShowReturnToEmployeeButton = false; 
            bShowReviewWithEmployeeButton = false; 
            bShowEmployeeSignoffButton = false; 
            // FOR EDIT VF PAGE
            bShowDeleteButton = false;
            bShowCoManager = false;
            bShowInfoSection = false;
            bShowAssessmentSection = false;
            bShowMgtAssessmentSection = false;
            bShowPerfSummarySection = false;
            bShowOverallRatingSection = false;
            bShowGoalsSection = true;
            bShowCareerPathSection = true;             
            return;             
        }
        
        // IF EMPLOYEE IS VIEWING AND IS COMPLETE ================
        if (bIsEmployee && isEvaluationComplete(pe))
        {
            bShowEditButton = false;
            bShowCreateNewButton = true;
            bShowSharingButton = true;
            bShowFormLock = false;
            bShowManagerRatingColumn = true;
            bShowManagerRatingSummary = true;
            bShowManagerOverallRating = true;
            bShowAddGoalButton = false;
            bShowGoalActionColumn = false;
            bShowAddPathButton = false;
            bShowAddPathActionColumn = false;
            bShowNoteAndAttachments = true; 
            bShowApprovalHistory = false;
            bDisplayApprovals = true;
            bShowSendToManagerButton = false; 
            bShowReturnToEmployeeButton = false; 
            bShowReviewWithEmployeeButton = false; 
            bShowEmployeeSignoffButton = false;    
            // FOR EDIT VF PAGE
            bShowDeleteButton = false;
            bShowCoManager = false;
            bShowInfoSection = false;
            bShowAssessmentSection = false;
            bShowMgtAssessmentSection = false;
            bShowPerfSummarySection = false;
            bShowOverallRatingSection = false;
            bShowGoalsSection = true;
            bShowCareerPathSection = true;             
            return;             
        }   
        
        
        // MANAGER CONDITIONS ====================================
        

        // IF MANAGER IS VIEWING AND IS EMPLOYEE DRAFT ===========
        if ((bIsManager || bIsManagerHierarchyUser()) && isEmployeeDraft(pe))
        //if (bIsManager && isEmployeeDraft(pe))
        {
            bShowEditButton = false;
            bShowSharingButton = true;
            bShowFormLock = false;
            bShowManagerRatingColumn = false;
            bShowManagerRatingSummary = false;
            bShowManagerOverallRating = false;
            bShowAddGoalButton = false;
            bShowGoalActionColumn = false;
            bShowAddPathButton = false;
            bShowAddPathActionColumn = false;
            bShowNoteAndAttachments = true; 
            bShowApprovalHistory = false;
            bDisplayApprovals = false;
            bShowSendToManagerButton = false; 
            bShowReturnToEmployeeButton = false; 
            bShowReviewWithEmployeeButton = false; 
            bShowEmployeeSignoffButton = false; 
            // FOR EDIT VF PAGE
            bShowDeleteButton = false;
            bShowCoManager = false;
            bShowInfoSection = false;
            bShowAssessmentSection = false;
            bShowMgtAssessmentSection = false;
            bShowPerfSummarySection = false;
            bShowOverallRatingSection = false;
            bShowGoalsSection = false;
            bShowCareerPathSection = false;           
            return;             
        }  

        // IF MANAGER IS VIEWING AND IS MANAGER DRAFT ===========
        if ((bIsManager || bIsManagerHierarchyUser()) && isManagerDraft(pe))
        //if (bIsManager && isManagerDraft(pe))
        {
            bShowEditButton = true;
            bShowSharingButton = true;
            bShowFormLock = false;
            bShowManagerRatingColumn = true;
            bShowManagerRatingSummary = true;
            bShowManagerOverallRating = true;
            bShowAddGoalButton = true;
            bShowGoalActionColumn = true;
            bShowAddPathButton = true;
            bShowAddPathActionColumn = true;
            bShowNoteAndAttachments = true; 
            bShowApprovalHistory = false;
            bDisplayApprovals = false;
            bShowSendToManagerButton = false; 
            bShowReturnToEmployeeButton = true; 
            bShowReviewWithEmployeeButton = true; 
            bShowEmployeeSignoffButton = false; 
            // FOR EDIT VF PAGE
            bShowDeleteButton = true;
            bShowCoManager = true;
            bShowInfoSection = true;
            bShowAssessmentSection = true;
            bShowMgtAssessmentSection = true;
            bShowPerfSummarySection = true;
            bShowOverallRatingSection = true;
            bShowGoalsSection = true;
            bShowCareerPathSection = true;              
            return;             
        }
        
        // IF MANAGER IS VIEWING AND IS IN REVIEW ===============
        //if (bIsManager && isInReview(pe))
        if ((bIsManager || bIsManagerHierarchyUser()) && isInReview(pe))
        {
            bShowEditButton = true;
            bShowSharingButton = true;
            bShowFormLock = false;
            bShowManagerRatingColumn = true;
            bShowManagerRatingSummary = true;
            bShowManagerOverallRating = true;
            bShowAddGoalButton = true;
            bShowGoalActionColumn = true;
            bShowAddPathButton = true;
            bShowAddPathActionColumn = true;
            bShowNoteAndAttachments = true; 
            bShowApprovalHistory = false;
            bDisplayApprovals = false;
            bShowSendToManagerButton = false; 
            bShowReturnToEmployeeButton = false; 
            bShowReviewWithEmployeeButton = false; 
            bShowEmployeeSignoffButton = true; 
            // FOR EDIT VF PAGE
            bShowDeleteButton = true;
            bShowCoManager = true;
            bShowInfoSection = true;
            bShowAssessmentSection = true;
            bShowMgtAssessmentSection = true;
            bShowPerfSummarySection = true;
            bShowOverallRatingSection = true;
            bShowGoalsSection = true;
            bShowCareerPathSection = true;              
            return;             
        }
        
        // IF MANAGER IS VIEWING AND IS PENDING APPROVAL ========
        //if (bIsManager && isPendingApproval(pe))
        if ((bIsManager || bIsManagerHierarchyUser()) && isPendingApproval(pe))
        {
            bShowEditButton = false;
            bShowSharingButton = true;
            bShowFormLock = false;
            bShowManagerRatingColumn = true;
            bShowManagerRatingSummary = true;
            bShowManagerOverallRating = true;
            bShowAddGoalButton = false;
            bShowGoalActionColumn = false;
            bShowAddPathButton = false;
            bShowAddPathActionColumn = false;
            bShowNoteAndAttachments = true; 
            bShowApprovalHistory = true;
            bDisplayApprovals = false;
            bShowSendToManagerButton = false; 
            bShowReturnToEmployeeButton = false; 
            bShowReviewWithEmployeeButton = false; 
            bShowEmployeeSignoffButton = false; 
            // FOR EDIT VF PAGE
            bShowDeleteButton = false;
            bShowCoManager = false;
            bShowInfoSection = false;
            bShowAssessmentSection = false;
            bShowMgtAssessmentSection = false;
            bShowPerfSummarySection = false;
            bShowOverallRatingSection = false;
            bShowGoalsSection = true;
            bShowCareerPathSection = true;             
            return;             
        }
        
        // IF MANAGER IS VIEWING AND IS COMPLETE ================
        //if (bIsManager && isEvaluationComplete(pe))
        if ((bIsManager || bIsManagerHierarchyUser()) && isEvaluationComplete(pe)) 
        {
            bShowEditButton = false;
            bShowSharingButton = true;
            bShowFormLock = false;
            bShowManagerRatingColumn = true;
            bShowManagerRatingSummary = true;
            bShowManagerOverallRating = true;
            bShowAddGoalButton = false;
            bShowGoalActionColumn = false;
            bShowAddPathButton = false;
            bShowAddPathActionColumn = false;
            bShowNoteAndAttachments = true; 
            bShowApprovalHistory = false;
            bDisplayApprovals = true;
            bShowSendToManagerButton = false; 
            bShowReturnToEmployeeButton = false; 
            bShowReviewWithEmployeeButton = false; 
            bShowEmployeeSignoffButton = false; 
            // FOR EDIT VF PAGE
            bShowDeleteButton = false;
            bShowCoManager = false;
            bShowInfoSection = false;
            bShowAssessmentSection = false;
            bShowMgtAssessmentSection = false;
            bShowPerfSummarySection = false;
            bShowOverallRatingSection = false;
            bShowGoalsSection = true;
            bShowCareerPathSection = true;             
            return;             
        }       
        
    }  
   
    //======================================================================================================================    
    public boolean bIsManagerHierarchyUser()
    {
        List<NI_Employee_Performance_Evaluation__Share> lstManagerShares = [SELECT ParentId, UserOrGroupId
                                                                            FROM NI_Employee_Performance_Evaluation__Share 
                                                                            WHERE ParentId =: pe.Id
                                                                            AND (RowCause = 'Manager_Hierarchy_Share__c'
                                                                            OR RowCause = 'Manager_Change__c')
                                                                            AND UserOrGroupId =: UserInfo.getUserId()];
        
        System.debug('lstManagerShare Record Count: ' + lstManagerShares.size());
        If(lstManagerShares.size()>0)
        {
            Return true; 
        }
        else
        {
            Return false;  
        }  
    } 
        
    // SMH 2017-11-15
    public pageReference newPerfEvalChecker()
    {
        
        // ADDED FOR NICC-025661 (START)
        Date dtToday = Date.today();
        string strYear = String.ValueOf(dtToday.year());

        if (dtToday.month() < 7) // IF CURRENT MONTH IS: Jan, Feb, Mar, Apr, May or June
        {
            strYear = String.ValueOf(dtToday.year() - 1);
        }        
        // ADDED FOR NICC-025661 (END)
        // 
        List<NI_Employee_Performance_Evaluation__c> lstOpenPerfEvals = new List<NI_Employee_Performance_Evaluation__c>(
            [SELECT Id 
             FROM NI_Employee_Performance_Evaluation__c
             WHERE Status__c != 'Evaluation Complete' 
             AND Performance_Evaluation_Year__c =: strYear 		// ADDED FOR NICC-025661
             AND Employee_Name__c =: UserInfo.getUserId()]);
        
        bShowCreateNewEvalButton = true;
            
        if (lstOpenPerfEvals.size() > 0)
        {
            bShowCreateNewEvalButton = false;            
            ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR, Label.PerfEval_New_Eval_Dupe_Found);
            ApexPages.addMessage(msg1); 
        }
        else
        {
            ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.INFO, Label.PerfEval_New_Eval_Message);
            ApexPages.addMessage(msg2);    
        }         
        
        return null;
        
    }


}