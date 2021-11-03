/************************************************************************************************
Name            : NI_AccountPlan_TriggerHandler Class
Author          : Sean Harris
Created Date    : 10/31/2014
Last Mod Date   : 10/31/2014
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Class that handles all trigger code for the NI_AccountPlan_TriggerHandler Object
                :
                :
*************************************************************************************************/
public class NI_AccountPlan_TriggerHandler
{

    private boolean m_isExecuting = false;
   
    public NI_AccountPlan_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }

    public void OnBeforeInsert(List<SFDC_Acct_Plan__c> newTrigger)
    {

    }
   
    public void OnBeforeUpdate(List<SFDC_Acct_Plan__c> newTrigger)
    {
    	rollupSummaries(newTrigger);
    }

    public void OnBeforeDelete(List<SFDC_Acct_Plan__c> newTrigger)
    {
       
    }
   
    public void OnAfterInsert(List<SFDC_Acct_Plan__c> newTrigger)
    {
		// ROLLUP TO RELATED ACCOUNT PLANS ====================== 
        invokeAcctPlanRollup(newTrigger); 		       
    }
   
    public void OnAfterUpdate(List<SFDC_Acct_Plan__c> newTrigger, Map<Id, SFDC_Acct_Plan__c> oldMapTrigger)
    {      
        // ROLLUP TO RELATED ACCOUNT PLANS ====================== 
        invokeAcctPlanRollup(newTrigger); 		
    }
       
    public void OnAfterDelete(List<SFDC_Acct_Plan__c> newTrigger)
    {
       	// ROLLUP TO RELATED ACCOUNT PLANS ====================== 
        invokeAcctPlanRollup(newTrigger); 		
    }
   
    public void OnAfterUnDelete(List<SFDC_Acct_Plan__c> newTrigger)
    {
       
    }   
    
    
    // =================================================================================================
    //  FUNCTIONS
    // =================================================================================================
    public void invokeAcctPlanRollup(List<SFDC_Acct_Plan__c> newTrigger)
    {   

        Set<Id> setAcctPlans = new Set<Id>(); 

        for (SFDC_Acct_Plan__c s : newTrigger)
        {
            setAcctPlans.Add(s.Master_Account_Plan__c); 
        } 
        
        Set<Id> setMasterAcctPlans = new Set<Id>(); 

        for (SFDC_Acct_Plan__c ap : [SELECT Id, Master_Account_Plan__c FROM SFDC_Acct_Plan__c WHERE Id IN : setMasterAcctPlans])
        {
            setMasterAcctPlans.Add(ap.Master_Account_Plan__c); 
        } 
        
        List<SFDC_Acct_Plan__c> lstMasterAcctPlans = new List<SFDC_Acct_Plan__c>();
        
        for (SFDC_Acct_Plan__c aps : [SELECT Id, Invoke_Rollups__c FROM SFDC_Acct_Plan__c WHERE Id IN : setAcctPlans])
        {
            aps.Invoke_Rollups__c = true;
            lstMasterAcctPlans.Add(aps);
        }
        
        Database.Update(lstMasterAcctPlans);        
        
    }
  
    private void rollupSummaries(List<SFDC_Acct_Plan__c> newTrigger)
    {

        // SET OF ALL STRATEGY IDS IN TRIGGER        
        Set<Id> setAcctPlan = new Set<Id>(); 
		
        // FILL SET OF ALL STRATEGY IDS IN TRIGGER WHEN Invoke_Rollups__c IS CHECKED
        // ZERO OUT ALL THE QUASI-ROLLUP FIELDS TO INITIALIZE THEM PRIOR TO REFRESHING THEM
        for (SFDC_Acct_Plan__c p : newTrigger)
        {
            if (p.Invoke_Rollups__c)
            {                
                setAcctPlan.Add(p.Id); 
                
                p.Actual_Services_Sales_Plan__c = 0.0; 
                p.Actual_Software_Sales_Plan__c = 0.0; 
                p.Actual_Subscription_Sales_Plan__c = 0.0; 
                
                p.Lost_Services_Sales_Plan__c = 0.0; 
                p.Lost_Software_Sales_Plan__c = 0.0; 
                p.Lost_Subscription_Sales_Plan__c = 0.0; 
                
                p.Planned_Services_Sales_Plan__c = 0.0; 
                p.Planned_Software_Sales_Plan__c = 0.0; 
                p.Planned_Subscription_Sales_Plan__c = 0.0; 
                
                p.Potential_Services_Sales_Plan__c = 0.0; 
                p.Potential_Software_Sales_Plan__c = 0.0; 
                p.Potential_Subscription_Sales_Plan__c = 0.0;               
                
                p.Invoke_Rollups__c = false;
                
            } 
        } 

        // GET ALL OPPORTUNITIES RELATED TO STRATEGIES SUMMED BY ROLLUPS
        AggregateResult[] groupedResults = 
            [SELECT Master_Account_Plan__c, 
             SUM(Actual_Services_Sales_Strategy__c), 
             SUM(Actual_Software_Sales_Strategy__c), 
             SUM(Actual_Subscription_Sales_Strategy__c), 
             SUM(Lost_Services_Sales_Strategy__c), 
             SUM(Lost_Software_Sales_Strategy__c), 
             SUM(Lost_Subscription_Sales_Strategy__c),  
             SUM(Planned_Services_Sales_Strategy__c), 
             SUM(Planned_Software_Sales_Strategy__c), 
             SUM(Planned_Subscription_Sales_Strategy__c), 
             SUM(Potential_Services_Sales_Strategy__c), 
             SUM(Potential_Software_Sales_Strategy__c), 
             SUM(Potential_Subscription_Sales_Strategy__c) 
             FROM SFDC_Acct_Plan__c 
             WHERE Master_Account_Plan__c IN : setAcctPlan 
             GROUP BY Master_Account_Plan__c]; 

        // LOOP THROUGH ALL STRATEGIES IN TRIGGER AND CONDITIONALLY SUM (INCREMENT) QUASI-ROLLUP FIELDS 
        for (SFDC_Acct_Plan__c s : newTrigger)
        {            
            for (AggregateResult ar : groupedResults)  
            {
                if (ar.get('Master_Account_Plan__c') == s.Id)
                {                    
                    s.Actual_Services_Sales_Plan__c += Double.valueOf(ar.get('expr0')); 
                    s.Actual_Software_Sales_Plan__c += Double.valueOf(ar.get('expr1')); 
                    s.Actual_Subscription_Sales_Plan__c += Double.valueOf(ar.get('expr2')); 
                    s.Lost_Services_Sales_Plan__c += Double.valueOf(ar.get('expr3')); 
                    s.Lost_Software_Sales_Plan__c += Double.valueOf(ar.get('expr4')); 
                    s.Lost_Subscription_Sales_Plan__c += Double.valueOf(ar.get('expr5')); 
                    s.Planned_Services_Sales_Plan__c += Double.valueOf(ar.get('expr6')); 
                    s.Planned_Software_Sales_Plan__c += Double.valueOf(ar.get('expr7')); 
                    s.Planned_Subscription_Sales_Plan__c += Double.valueOf(ar.get('expr8'));                     
                    s.Potential_Services_Sales_Plan__c += Double.valueOf(ar.get('expr9')); 
                    s.Potential_Software_Sales_Plan__c += Double.valueOf(ar.get('expr10')); 
                    s.Potential_Subscription_Sales_Plan__c += Double.valueOf(ar.get('expr11')); 
             
                } 			
            }             
        } 
        
    }

    
}