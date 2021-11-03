/****************************************************************************************
Name            : NI_PerfEval_Goal_Ext Class
Author          : Sean Harris
Created Date    : 12/2/2014
Last Mod Date   : 12/2/2014
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles events in VF Pages:
                :    NI_PerfEval_Goal
                :
******************************************************************************************/
public with sharing class NI_PerfEval_Goal_Ext 
{

    private NI_PerfEval_Goals__c pg; 
//    private ApexPages.StandardController stdCtrl; 
    
    public Id GoalId {get; set;}
    public Id PerfEvalId {get; set;}
    public boolean inEditMode {get; set;}
    
    
    
    // =======================================================================
	//  CLASS CONSTRUCTOR ====================================================
	// =======================================================================
    public NI_PerfEval_Goal_Ext(ApexPages.StandardController stdController)
    {
                
//        this.stdCtrl = stdController;
        this.pg = (NI_PerfEval_Goals__c)stdController.getRecord();
        inEditMode = true;
        
        // IF GOAL Id IS PRESENT THE
//		if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
//     	{
//            id = ApexPages.CurrentPage().getParameters().get('id');
//          	GoalId = ApexPages.CurrentPage().getParameters().get('id');
//            inEditMode = false;
//        }
        
        if (ApexPages.CurrentPage().getParameters().containsKey('evid')) 
     	{
            PerfEvalId = ApexPages.CurrentPage().getParameters().get('evid');            
        }
        
        // IF Employee_Performance_Evaluation__c IS NULL THEN IT IS NEW GOAL SO ASSIGN ID FROM URL PARAM 
        if (pg.Employee_Performance_Evaluation__c == null)
        {
            pg.Employee_Performance_Evaluation__c = PerfEvalId;
        }

    }

    // =========================================================================================
    //  DML FUNCTIONS ==========================================================================
    // =========================================================================================
    public Pagereference saveGoal()
    {
        upsert pg;
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_View?id=' + PerfEvalId);
        pageRef.setRedirect(true);
        return pageRef;   
    }    

    public Pagereference deleteGoal()
    {
        delete pg; 
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_View?id=' + PerfEvalId); 
        pageRef.setRedirect(true); 
        return pageRef; 
    } 
    
    public Pagereference doSaveAndNew()
    {
        upsert pg;
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_Goal?retURL=/apex/NI_PerfEval_View?id=' + PerfEvalId + '&evid=' + PerfEvalId);
        pageRef.setRedirect(true); 
        return pageRef; 
    }



    
}