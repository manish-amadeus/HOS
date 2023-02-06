/****************************************************************************************
Name            : NI_TriggerManager Class
Author          : Sean Harris
Created Date    : 05/02/2014
Last Mod Date   : 03/22/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : A utility class that is used mostly for the purposes of preventing
                : recursive execution of triggers
                : 
******************************************************************************************/
public class NI_TriggerManager 
{
    
    public static Boolean isFirstTime = true;
    public static Boolean isFirstTimeCustService = true;
    public static Boolean isFirstTimeCustDet = true;
    public static Boolean isBypassOppUdate = true;
    public static Boolean isValidOrgDetails = true;
    public static Boolean isFirstTimeCustAgreement = true;    
    
    // NICC SWITCH
    public static Boolean Bypass_NICC_Updates = false;
    
    // DEPLOYMENT INSTANCE SWITCH
    public static Boolean isBypassDIUpdate = false;
    
    // OPPORTUNITY SWITCH
    public static Boolean isOpportunityInvoked = false;
    
    // OPPORTUNITY LINE ITEM SWITCH
    public static Boolean isOpptyLineItemInvoked = false;
    
	// OPPORTUNITY LINE ITEM - Opportunity.Amount__c ROLLUP SWITCH
    public static Boolean isExecutingRollupAmount = false;    
    
    public static integer intCauseDivByZero = 1;
    
    // DI INDEX VARAIABLES 
    public static List<Asset> lstDIsWithOldDIIndexes;
    public static Boolean isFirstSoftraxBillingInsert = true; 

    // CASE TRIGGER EXECUTION SWITCHES 
    public static Boolean bypassTriggersInvokedByCaseDML = false;   
//    public static Boolean processedSolutions = false; 

    // CANCELLATION TRIGGER EXECUTION SWITCHES 
    public static Boolean isFirstSOChatterGroupPost = true;  
    public static Boolean is1stInsert_Cancellation = true; 
    public static Boolean is1stUpdate_Cancellation = true;     

    // ACTIVITY LINE ITEM TRIGGER EXECUTION SWITCHES 
    public static Boolean is1stInsert_ActivityLineItem = true; 
    public static Boolean is1stUpdate_ActivityLineItem = true;   
    
    // PSA PROJECT TRIGGER EXECUTION SWITCHES 
    public static Boolean is1stInsert_Project = true; 
    public static Boolean is1stUpdate_Project = true; 
    
    // PSA MILESTONE TRIGGER EXECUTION SWITCHES 
    public static Boolean is1stInsert_Milestone = true; 
    public static Boolean is1stUpdate_Milestone = true;  
    
    // PSA ASSIGNMENT TRIGGER EXECUTION SWITCHES
    public static Boolean is1stInsert_Assignment = true; 
    public static Boolean is1stUpdate_Assignment = true;  

    // CASE DETAIL TRIGGER EXECUTION SWITCH
    public static Boolean is1stInsert_Case_Report_Detail = true; 
    

}