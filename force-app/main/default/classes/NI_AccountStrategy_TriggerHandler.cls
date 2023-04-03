/************************************************************************************************
Name            : NI_AccountStrategy_TriggerHandler Class
Author          : Sean Harris
Created Date    : 10/29/2014
Last Mod Date   : 10/29/2014
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Class that handles all trigger code for the Account_Strategy__c Object
                :
                :
*************************************************************************************************/
public class NI_AccountStrategy_TriggerHandler
{

    private boolean m_isExecuting = false;
   
    public NI_AccountStrategy_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }

    public void OnBeforeInsert(List<SFDC_Strategy__c> newTrigger)
    {

    }
   
    public void OnBeforeUpdate(List<SFDC_Strategy__c> newTrigger)
    {
    	rollupSummaries(newTrigger);
    }

    public void OnBeforeDelete(List<SFDC_Strategy__c> newTrigger)
    {
       
    }
   
    public void OnAfterInsert(List<SFDC_Strategy__c> newTrigger)
    {
		// ROLLUP TO RELATED ACCOUNT PLANS ====================== 
        invokeAcctPlanRollup(newTrigger); 		       
    }
   
    public void OnAfterUpdate(List<SFDC_Strategy__c> newTrigger, Map<Id, SFDC_Strategy__c> oldMapTrigger)
    {      
        // ROLLUP TO RELATED ACCOUNT PLANS ====================== 
        invokeAcctPlanRollup(newTrigger); 		
    }
       
    public void OnAfterDelete(List<SFDC_Strategy__c> newTrigger)
    {
system.debug(' ENTERING OnAfterDelete() ===================================== ');        
       	// ROLLUP TO RELATED ACCOUNT PLANS ====================== 
        invokeAcctPlanRollup(newTrigger); 		
    }
   
    public void OnAfterUnDelete(List<SFDC_Strategy__c> newTrigger)
    {
    	
    }   
    
    
    // =================================================================================================
    //  FUNCTIONS
    // =================================================================================================
    public void invokeAcctPlanRollup(List<SFDC_Strategy__c> newTrigger)
    {   
system.debug(' THE TRIGGER SIZE ===================================== ' + newTrigger.size());
system.debug('     THE TRIGGER  ===================================== ' + newTrigger[0]);        
        Set<Id> setStrats = new Set<Id>(); 

        for (SFDC_Strategy__c s : newTrigger)
        {
            setStrats.Add(s.SFDC_Acct_Plan__c); 
        } 
        
        Set<Id> setAcctPlans = new Set<Id>(); 

        for (SFDC_Acct_Plan__c ap : [SELECT Id, Master_Account_Plan__c FROM SFDC_Acct_Plan__c WHERE Id IN : setStrats])
        {
            setAcctPlans.Add(ap.Master_Account_Plan__c); 
        } 
        
        List<SFDC_Acct_Plan__c> lstAcctPlans = new List<SFDC_Acct_Plan__c>();
        
        for (SFDC_Acct_Plan__c aps : [SELECT Id, Invoke_Rollups__c FROM SFDC_Acct_Plan__c WHERE Id IN : setAcctPlans])
        {
            aps.Invoke_Rollups__c = true;
            lstAcctPlans.Add(aps);
        }
        
        Database.Update(lstAcctPlans);        
       
    }
    
    private void rollupSummaries(List<SFDC_Strategy__c> newTrigger)
    {

        // SET OF ALL STRATEGY IDS IN TRIGGER        
        Set<Id> setStrats = new Set<Id>(); 
		
        // FILL SET OF ALL STRATEGY IDS IN TRIGGER WHEN Invoke_Rollups__c IS CHECKED
        // ZERO OUT ALL THE QUASI-ROLLUP FIELDS TO INITIALIZE THEM PRIOR TO REFRESHING THEM
        for (SFDC_Strategy__c s : newTrigger)
        {
            if (s.Invoke_Rollups__c)
            {                
                setStrats.Add(s.Id); 
                s.Actual_Services__c = 0.0;
                s.Actual_Software__c = 0.0;
                s.Actual_Subscription__c = 0.0;
                s.Lost_Services__c = 0.0;
                s.Lost_Software__c = 0.0;
                s.Lost_Subscription__c = 0.0;               
                s.Potential_Services__c = 0.0;
                s.Potential_Software__c = 0.0;
                s.Potential_Subscription__c = 0.0;
                s.Invoke_Rollups__c = false;
            } 
        } 

        // GET ALL OPPORTUNITIES RELATED TO STRATEGIES SUMMED BY ROLLUPS
        AggregateResult[] groupedResults = 
            [SELECT Strategy__c, StageName, SUM(Services_Roll_Up_Amount__c), SUM(Software_Roll_Up_Amount__c), SUM(Subscriptions_Roll_Up_Summary__c) 
             FROM Opportunity 
             WHERE Strategy__c IN : setStrats 
             GROUP BY Strategy__c, StageName];         

        // LOOP THROUGH ALL STRATEGIES IN TRIGGER AND CONDITIONALLY SUM (INCREMENT) QUASI-ROLLUP FIELDS 
        for (SFDC_Strategy__c s : newTrigger)
        {            
            for (AggregateResult ar : groupedResults)  
            {
                if (ar.get('Strategy__c') == s.Id)
                {                    
                    if (ar.get('StageName') == 'Closed Won')
                    {
                        // OPPORTUNITY STAGE - WON FIELDS ================
                        s.Actual_Services__c += Double.valueOf(ar.get('expr0'));
                        s.Actual_Software__c += Double.valueOf(ar.get('expr1'));
                        s.Actual_Subscription__c += Double.valueOf(ar.get('expr2'));
                    }
                    else
                    {
                        if ((ar.get('StageName') == 'Closed Lost') || (ar.get('StageName') == 'Did Not Materialize'))
                        {
                            // OPPORTUNITY STAGE - LOST FIELDS ===============
                            s.Lost_Services__c += Double.valueOf(ar.get('expr0'));
                            s.Lost_Software__c += Double.valueOf(ar.get('expr1'));
                            s.Lost_Subscription__c += Double.valueOf(ar.get('expr2'));
                        }
                        else
                        {
                            // OPPORTUNITY STAGE - OTHER FIELDS ==============                
                            s.Potential_Services__c += Double.valueOf(ar.get('expr0'));
                            s.Potential_Software__c += Double.valueOf(ar.get('expr1'));
                            s.Potential_Subscription__c += Double.valueOf(ar.get('expr2'));
                        } 
                    }                    
                } 			
            }             
        } 
        
    }

    
}