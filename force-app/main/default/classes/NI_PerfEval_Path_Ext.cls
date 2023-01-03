/****************************************************************************************
Name            : NI_PerfEval_Path_Ext Class
Author          : Sean Harris
Created Date    : 12/3/2014
Last Mod Date   : 12/3/2014
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles events in VF Pages:
                :    NI_PerfEval_Path
                :
******************************************************************************************/
public with sharing class NI_PerfEval_Path_Ext 
{

    private NI_Career_Path__c cp; 
    public Id pathId {get; set;}
    public Id PerfEvalId {get; set;}
    public boolean inEditMode {get; set;}
    
    
    
    // =======================================================================
	//  CLASS CONSTRUCTOR ====================================================
	// =======================================================================
    public NI_PerfEval_Path_Ext(ApexPages.StandardController stdController)
    {

        this.cp = (NI_Career_Path__c)stdController.getRecord();
        inEditMode = true;
        
        if (ApexPages.CurrentPage().getParameters().containsKey('evid')) 
     	{
            PerfEvalId = ApexPages.CurrentPage().getParameters().get('evid');            
        }
        
        // IF NI_Employee_Performance_Evaluation__c IS NULL THEN IT IS NEW PATH SO ASSIGN ID FROM URL PARAM 
        if (cp.NI_Employee_Performance_Evaluation__c == null)
        {
            cp.NI_Employee_Performance_Evaluation__c = PerfEvalId;
        }
 
    }

    // =========================================================================================
    //  DML FUNCTIONS ==========================================================================
    // =========================================================================================
    public Pagereference savePath()
    {
        upsert cp;
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_View?id=' + PerfEvalId);
        pageRef.setRedirect(true);
        return pageRef;   
    }    

    public Pagereference deletePath()
    {
        delete cp; 
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_View?id=' + PerfEvalId); 
        pageRef.setRedirect(true); 
        return pageRef; 
    } 
    
    public Pagereference doSaveAndNew()
    {
        upsert cp;
        PageReference pageRef = new PageReference('/apex/NI_PerfEval_Path?retURL=/apex/NI_PerfEval_View?id=' + PerfEvalId + '&evid=' + PerfEvalId);
        pageRef.setRedirect(true); 
        return pageRef; 
    }



    
}