/************************************************************************************************
Name            : NI_License_Audit_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 8/25/2014
Last Mod Date   : 8/25/2014
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_License_Audit__c Object
                : 
                : 
*************************************************************************************************/
public class NI_License_Audit_TriggerHandler 
{
    
    Public String strContractMgrRole;
    
    public void OnBeforeInsert(List<NI_License_Audit__c> newTrigger)
    {
        
        //LIST TO HOLD THE VALUES FROM THE NI_License_Audit_Settings__c CUSTOM SETTING  
        List<NI_License_Audit_Settings__c> lstCS = NI_License_Audit_Settings__c.getAll().values();
        
        //LIST TO HOLD THE LICENSE AUDIT RECORDS THAT SHOULD BE PASSED TO THE "Update_ContractManager" METHOD
        List<NI_License_Audit__c> lstLicenseAuditsToUpdate = new List<NI_License_Audit__c>();
        
        //SET TO HOLD THE UNIQUE DEFAULT CONTRACT MANAGER VALUES FROM THE CUSTOM SETTING
        Set<String> setDefaultContractMgr = new Set<String>();
        
        //LOOP THROUGH THE lstCS AND GET THE DEFAULT CONTRACT MANAGER VALUE 
        for (NI_License_Audit_Settings__c las : lstCS)
        {
            if(las.Default_Contract_Manager__c != null)
            {
                setDefaultContractMgr.add(las.Default_Contract_Manager__c);
                strContractMgrRole = las.Default_Contract_Manager__c;
                System.debug('DEFAULT CONTRACT MANAGER ROLE: ' + strContractMgrRole);
            }  
        }
        
        
        for(NI_License_Audit__c la : newTrigger)
        {
            if(la.Contracts_Manager__c == null && setDefaultContractMgr.size()>0 && la.Account__c != null)
            {
                lstLicenseAuditsToUpdate.add(la);
            } 
        }
        
        System.debug('NUMBER OF LICENSE AUDIT RECORDS TO UPDATE CONTRACT MANAGER FIELD: ' + lstLicenseAuditsToUpdate.size());
        if(lstLicenseAuditsToUpdate.size()>0)
        {
            Update_ContractsManager(lstLicenseAuditsToUpdate);
        }
    }
    
    public void OnAfterUpdate(List<NI_License_Audit__c> newTrigger)
    {
        system.debug('in after update');
        set<id> setAssetIds = new set<id>();
        Map<Id, Asset> mapAsset;
        List<Compliance_Audit__c> auditCompliantList = new List<Compliance_Audit__c>();
        
        for(NI_License_Audit__c objLicenseAudit : newTrigger){
            if(objLicenseAudit.Asset__c != null || objLicenseAudit.Asset__c != ''){
                //create a set of asset Ids in order to get account details from Asset(DI)
                setAssetIds.add(objLicenseAudit.Asset__c);
            }
        }
        
        if(!setAssetIds.isEmpty()){
            //As we are getting only 200 records in trigger so applying LIMIT(avoid error if there are more than 50000 records)
            mapAsset = new Map<Id,Asset>([SELECT id, AccountId From Asset WHERE id IN :setAssetIds LIMIT 200]);
            system.debug('MapAsset'+ mapAsset);
        }                
        
        for(NI_License_Audit__c objLicenseAudit : newTrigger){
            //if asset OR cluster is not null AND Variance is negative AND Phase is 'Closed'
            if((objLicenseAudit.Asset__c != null || objLicenseAudit.Cluster__c != null)
               && (objLicenseAudit.License_Variance__c < 0) && (objLicenseAudit.Phase__c == 'Closed')){
                system.debug('in if');
                system.debug('in if closed');
                   //Create a new Compliance_Audit__c object and set values
                Compliance_Audit__c objCompliance = new Compliance_Audit__c();
                
                if((objLicenseAudit.Asset__c != null) && (mapAsset.ContainsKey(objLicenseAudit.Asset__c))){
                    Asset objAsset = mapAsset.get(objLicenseAudit.Asset__c);
                    objCompliance.Account__c = objAsset.AccountId;
                    system.debug('Account__c');
                }
                else if(objLicenseAudit.Cluster__c != null){
                    system.debug('in IfElse');
                    objCompliance.Cluster__c = objLicenseAudit.Cluster__c;
                }
                objCompliance.Original_Status__c = 'Compliant';
                objCompliance.Current_Status__c ='Non Compliant';
                objCompliance.Product_Line__c= 'Delphi';
                objCompliance.Related_Attributes__c = 'User License';
                auditCompliantList.add(objCompliance);
            }
        }
        
        if(auditCompliantList.size()>0){
            insert auditCompliantList;
        }
    }
    
    //==========================================================================================================================    
    public void Update_ContractsManager(List<NI_License_Audit__c> newTrigger)
    {        
        
        //SET TO HOLD THE UNIQUE ACCOUNT IDs OF THE LICENSE AUDIT RECORDS
        Set<Id> setAccountIds = new Set<Id>();
        
        //SET TO HOLD THE UNIQUE ACCOUNT OWNER IDs OF THE LICENSE AUDIT RECORDS
        Set<Id> setAcctOwnerIds = new Set<Id>();
        
        for(NI_License_Audit__c la : newTrigger)
        {
            setAccountIds.add(la.Account__c);  
        }
        
        //MAP TO HOLD THE ACCOUNTS RELATED TO THE LICENSE AUDIT RECORDS.  THIS IS USED TO POPULATE LOOKUP FIELDS  
         Map<Id, Account> mapAccount = new Map<Id, Account> ([SELECT Id,OwnerId
                                   FROM Account
                                   WHERE Id IN : setAccountIds]);
        
        List<Account> lstAccounts = ([SELECT Id, OwnerId
                                      FROM Account
                                      WHERE Id IN :setAccountIds]);
        
        for(Account a : lstAccounts)
        {
            setAcctOwnerIds.add(a.OwnerId);  
        }
        
        List<UserTeamMember> lstUtm = ([SELECT Id,OwnerId,UserId,TeamMemberRole 
                                           FROM UserTeamMember
                                           WHERE 
                                           TeamMemberRole = :strContractMgrRole
                                           AND OwnerId IN :setAcctOwnerIds]);
        
        //List<AccountTeamMember> lstAtm = ([SELECT Id,AccountId,UserId 
        //                                   FROM AccountTeamMember
        //                                   WHERE 
        //                                   TeamMemberRole = :strContractMgrRole
        //                                   AND AccountId IN :setAccountIds]);
        
        //MAP TO HOLD ACCOUNT TEAM MEMBER ACCOUNTIDs AND USERIDs FOR THE ACCOUNTS RELATED TO THE LICENSE AUDIT
        //Map<Id, Id> mapAtm = new Map<Id, Id>();
        
        //System.debug('NUMBER OF ACCOUNT TEAM MEMBER RECORDS: ' + lstAtm.size());
        //for(AccountTeamMember atm : lstAtm)
        //{
        //  mapAtm.put(atm.AccountId, atm.UserId);
        //}
        //System.debug('mapAtm Size:' + mapAtm.size());
        
        //MAP TO HOLD USER TEAM MEMBER OWNERIDs AND USERIDs FOR THE ACCOUNT OWNERS RELATED TO THE LICENSE AUDIT
        Map<Id, Id> mapUtm = new Map<Id, Id>();
        
        for(UserTeamMember utm : lstUtm)
        {
          mapUtm.put(utm.OwnerId, utm.UserId);
        }
        System.debug('mapUtm Size:' + mapUtm.size());
        
        //LOOP THROUGH THE newTrigger COLLECTION AND UPDATE THE LOOKUP FIELDS
        for (NI_License_Audit__c la2 : newTrigger)
        {
          //la2.Contracts_Manager__c = mapAtm.get(la2.Account__c);
          la2.Contracts_Manager__c = mapUtm.get(mapAccount.get(la2.Account__c).OwnerId);  
          System.debug('CONTRACTS MANAGER: ' + mapUtm.get(mapAccount.get(la2.Account__c).OwnerId)); 
        }    
    }  
}