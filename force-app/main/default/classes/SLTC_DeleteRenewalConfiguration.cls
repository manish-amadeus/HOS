/**********************************************************
Name : SLTC_DeleteRenewalConfiguration
Author : Heema Solanki
Created Date : 4/14/2022
Last Mod Date : 12/5/2022
Last Mod By : Japtej Lamba
Description : Controller Class for SLTC_DeleteRenewalConfiguration VF Page to Delete Existing Configuration and Redirect to Installed Products Cart Page.
***********************************************************/
public class SLTC_DeleteRenewalConfiguration {

    Id proposalId  = apexpages.currentpage().getparameters().get('id');
    List<Apttus_Config2__ProductConfiguration__c> prodConfig = [SELECT name,id,SLTC_Renewal_Configuration__c FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c =: proposalId limit 1];

    public PageReference deleteRenewalOppty()
    {
        PageReference pg;
        if(!prodConfig.isEmpty() && prodConfig[0].SLTC_Renewal_Configuration__c == true){
            DELETE prodConfig;
        }
        pg = new PageReference('/apex/Apttus_Config2__Cart?businessObjectId=' +proposalId+ '&flow=NGDefault&useAdvancedApproval=true&launchState=assetsgrid#!/assetsgrid');
        pg.setRedirect(true);
        return pg;
    }
}