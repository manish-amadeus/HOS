/************************************************************************************************
Name            : AH_ChangeRequest_ChangeOwner_Cntlr Class
Author          : Shashikant Nikam 
Created Date    : 12/21/2020
Last Mod By     : Shashikant Nikam
Last Mod Date   : 12/28/2020
NICC Reference  : 
Description     : Class to change the owner of SFDC_CSP_Development_Request__c object records from List View 
                : 
                : 
*************************************************************************************************/

public class AH_ChangeRequest_ChangeOwner_Cntlr 
{
    public SFDC_CSP_Development_Request__c cr  {get; set ;}
    private Set<ID> crIdSet = new Set<ID>();
    public String errorMessage {get; set ;}
    public Boolean showForm {get; set ;}
    
    public AH_ChangeRequest_ChangeOwner_Cntlr(ApexPages.StandardSetController stdSetController) 
    {
        errorMessage = 'Please select at least one row.';

        cr = new SFDC_CSP_Development_Request__c();
        
        // PREPOULATING RUNING USER NAME IN USER FIELD TO AVOID Cancel BUTTON ERROR
        cr.OwnerId = UserInfo.getUserId();
        
        // ITERATE OVER SELECTED CRs
        for(SObject sObj : stdSetController.getSelected())
        {
            system.debug('Id : '+sObj.get('Id'));
            crIdSet.add(String.valueOf(sObj.get('Id')));
            system.debug('crIdSet : '+crIdSet);
        }
        
        if(!crIdSet.isEmpty())
        {
            showForm = true;
        }
        else
        {
            showForm = false;
        }
    }
    
    // Save BUTTON
    public PageReference doSave()
    {
        Id userId = Id.valueOf(cr.OwnerId);
        system.debug('userId : '+userId);
        List<SFDC_CSP_Development_Request__c> CRListtobeUpdated = new List<SFDC_CSP_Development_Request__c>();
        
        for(SFDC_CSP_Development_Request__c CR : ([SELECT ID, OwnerId FROM SFDC_CSP_Development_Request__c WHERE ID IN : crIdSet]))
		{
            CR.OwnerId = userId;
            system.debug('CR.OwnerId : '+CR.OwnerId);
        	CRListtobeUpdated.add(CR);
        }
        system.debug('CRListtobeUpdated : '+CRListtobeUpdated);
        if(!CRListtobeUpdated.isEmpty())
        {
            try
            {
                Database.update(CRListtobeUpdated);
                PageReference pgRef = new PageReference('/apex/ChangeRequestTab');
                pgRef.setRedirect(true);
                system.debug('pgRef : '+pgRef);
                return pgRef;
            }
            catch(Exception e)
            {
                system.debug('Exception found while chnaging CR Owner : '+e);
            }
        }
        return null;
    }
    
    // Cancel BUTTON 
    public PageReference doCancel()
    {
        PageReference pgRef = new PageReference('/apex/ChangeRequestTab');
        pgRef.setRedirect(true);
        system.debug('pgRef : '+pgRef);
        return pgRef;
    }
}