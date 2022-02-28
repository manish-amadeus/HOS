/**
 * Company     : PwC Sales & Marketing Excellence Solution.
 * Description : 
 * 
 * ****************************************************************************************
 * History     : 
 * [03.APR.2019] Peeyush Tripathi- Created this trigger.
 */
trigger Opportunity_Trigger on Opportunity (before insert,before delete, after insert, after update, after delete, before update) {
    new SME_OpportunityTriggerHandlerCtrl().run();
    
    //AD Sales Functionality
        
    //Trigger handler to update revenue on Agency and primary account
    // new ADS_AccountAmntUpdateOppTriggerHandler().run();
    
    //Trigger handler for Ad Sales processes
    // new ADS_OpportunityTriggerHandler().run();       
}