/****************************************************************************************
Name            : AH_PartnerForm2Acct_TriggerHandler Class
Author          : Sean Harris
Created Date    : 10/13/2017
Last Mod Date   : 10/13/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-024156
Description     : 
                : 
                : 
******************************************************************************************/
public class AH_PartnerForm2Acct_TriggerHandler 
{
    
    public AH_PartnerForm2Acct_TriggerHandler()
    {
        
    }
    
    // ======================================================================================
    //  TRIGGER HANDLER ENTRY METHODS
    // ======================================================================================
    public void OnBeforeInsert(List<Partners_Form_Template_to_Account__c> newTrigger)
    { 
        system.debug(' *** ENTERING AH_PartnerForm2Acct_TriggerHandler.OnBeforeInsert()');        
        assignDupeManager(newTrigger);
    }
    
    public void OnAfterInsert(List<Partners_Form_Template_to_Account__c> newTrigger)
    { 
        system.debug(' *** ENTERING AH_PartnerForm2Acct_TriggerHandler.OnAfterInsert()');        
        processPartnerAccessAndShares(newTrigger);
    }
    
    public void OnBeforeUpdate(List<Partners_Form_Template_to_Account__c> newTrigger)
    { 
        system.debug(' *** ENTERING AH_PartnerForm2Acct_TriggerHandler.OnBeforeUpdate()');        
        assignDupeManager(newTrigger);
    }
    
    public void OnAfterUpdate(List<Partners_Form_Template_to_Account__c> newTrigger, Map<Id, Partners_Form_Template_to_Account__c> oldMapTrigger)
    {         
        system.debug(' *** ENTERING AH_PartnerForm2Acct_TriggerHandler.OnAfterUpdate()');
		processPartnerAccessAndShares(newTrigger);        
    } 


    // ======================================================================================
    //  TRIGGER HANDLER FUNCTIONS
    // ======================================================================================    
	private void assignDupeManager(List<Partners_Form_Template_to_Account__c> newTrigger)
    {
        for (Partners_Form_Template_to_Account__c pft : newTrigger)
        {
            pft.Dupe_Manager__c = string.valueOf(pft.Account__c) + string.valueOf(pft.Partners_Form_Template__c);
        }
    }

    private void processPartnerAccessAndShares(List<Partners_Form_Template_to_Account__c> newTrigger)
    {
        
        // INTENTIONALLY NOT BULKIFIED
        Id accId = (Id)newTrigger[0].get('Account__c');
/*        
        Id formId = (Id)newTrigger[0].get('Partners_Form_Template__c');
        Account a = [SELECT Id FROM Account WHERE Id =: accId]; 
        Partners_Form_Template_to_Account__c pft = [SELECT Id, Accepted_Terms__c, IP_Address__c  
                                                    FROM Partners_Form_Template_to_Account__c 
                                                    WHERE Account__c =: accId 
                                                    AND Partners_Form_Template__c =: formId];
*/
        
        // CREATE A SET OF PARTNER USER IDS TO LATER PASS TO A @FUTURE FUNCTION TO CHANGE PICKLIST VALUES ON USERS
        // THESE PICKLIST VALUES DRIVE PAGE VISIBLITY IN THE PARTNER CENTRAL COMMUNITY VIA AUDIENCES
        Set<Id> setUserIds = new Set<Id>(); 
        for (User u : [SELECT Id, ProfileId FROM User WHERE Profile.UserType = 'PowerPartner' AND AccountId =: accId])
        {
            setUserIds.add(u.Id);
        } 
        
        if (NI_FUNCTIONS.allFormsAccepted(accId))
        {    
            NI_FUNCTIONS.bulkChangePartnerFieldsOnUser(accId, setUserIds, 'True', null); 
        }
        else
        {        
            NI_FUNCTIONS.bulkChangePartnerFieldsOnUser(accId, setUserIds, 'False', null); 
        } 
        
    }
    
    
}