/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsLicenseCallout_Batch Class
Author          : Arul Geetha Amalraj
Created Date    : 12/02/2020
Last Mod Date   : 02/22/2023
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Callout to the connected Amadeus Cross Orgs to pull UserLicenses,PermissionSet Licenses, Usage Based Entitlements.
				: Flexible to include/exclude orgs with Named Credentials, Custom MDT and Static Resources.								
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
MaintainedBy 	: Arul Geetha Amalraj
Dependencies 	: DTS_CrossOrgsLicenseParsers.cls
TestClass    	: DTS_CrossOrgsLicenseCallout_Test.cls (96%)
**********************************************************************************************************************************************/

global class DTS_CrossOrgsLicenseCallout_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	
    global Database.QueryLocator start(Database.BatchableContext BC) {
		//Get connected Orgs CalloutMDT from SR
		StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'DTS_CrossOrgs_SR'];
		Blob bodyBlob = sr.Body;
        String query = bodyBlob.toString();
		System.debug('Static Resource :'+ query);		
		return Database.getQueryLocator(query);		
	}		
    
	global void execute(Database.BatchableContext BC, List<DTS_Amadeus_Organizations__c> scope) {
		
		if(scope != null){
			 
			DTS_Amadeus_Organizations__c tempScope = (DTS_Amadeus_Organizations__c)scope[0];            
			System.debug('tempscope Org:'+ tempScope.CalloutMDT__c);            
				
			DTS_Amadeus_Organizations__c amOrg = [Select Id, name, CalloutMDT__c from DTS_Amadeus_Organizations__c where CalloutMDT__c =:tempScope.CalloutMDT__c Limit 1];
			String ncred  	= amOrg.CalloutMDT__c;
			String OrgId 	= amOrg.Id;	
			
			//Callout Queries:- User License, PermissionSet License,Usage Entitlements
			String ulQuery = 'SELECT+ID,+MasterLabel,+Status,+TotalLicenses,+UsedLicenses+From+UserLicense';
			String plQuery = 'SELECT+ID,+MasterLabel,+Status,+TotalLicenses,+UsedLicenses,+ExpirationDate+From+PermissionSetLicense';
			String teQuery = 'SELECT+ID,+MasterLabel,+ResourceGroupKey,+StartDate,+EndDate,+Frequency,+CurrentAmountAllowed,+AmountUsed,+UsageDate+From+TenantUsageEntitlement';
			
			//Variables for Upsert/Update			
			List<DTS_Amadeus_Licenses__c> lList = new List<DTS_Amadeus_Licenses__c>();					
				
			//Callout for UserLicense
			HttpRequest ulReq = new HttpRequest();
			String ulEndPoint = 'callout:'+ncred+'/services/data/v49.0/query/?q='+ulQuery;
			ulReq.setEndpoint(ulEndPoint);
			ulReq.setMethod('GET');
			ulReq.setTimeout(20000);
			Http ulHttp = new Http();
			HTTPResponse ulRes = ulHttp.send(ulReq);
			System.debug('UL HTTP Status Code : '+ ulRes.getStatusCode() + ' & ' + 'UL Response :-' + ulRes.getBody());
			//System.debug(ulRes.getHeader('Location'));			
			String ulSTR = ulRes.getBody();
						
			//Callout for PermissionSetLicense
			HttpRequest plReq = new HttpRequest();			
			String plEndPoint = 'callout:'+ncred+'/services/data/v49.0/query/?q='+plQuery;
			plReq.setEndpoint(plEndPoint);
			plReq.setMethod('GET');
			plReq.setTimeout(20000);
			Http plHttp = new Http();
			HTTPResponse plRes = plHttp.send(plReq);
			System.debug('PL HTTP Status Code : '+ plRes.getStatusCode()+ ' & ' + 'PL Response :-' + plRes.getBody());
			//System.debug(plRes.getHeader('Location'));			
			String plSTR = plRes.getBody();
			
			//Callout for Usage_Based Entitlements
			HttpRequest teReq = new HttpRequest();
            String teEndPoint = 'callout:'+ncred+'/services/data/v49.0/query/?q='+teQuery;
            teReq.setEndpoint(teEndPoint);
            teReq.setMethod('GET');
			teReq.setTimeout(20000);
            Http teHttp = new Http();
            HTTPResponse teRes = teHttp.send(teReq);
            System.debug('TE HTTP Status Code : '+ teRes.getStatusCode() + ' & ' + 'TE Response :-' + teRes.getBody());
            //System.debug(teRes.getHeader('Location'));            
            String teSTR = teRes.getBody();
			
			//Calling JSON Parser/Deserializer Methods for Licenses			
			if(ulRes.getStatusCode()==200){
				List<DTS_Amadeus_Licenses__c> ulList = DTS_CrossOrgsLicenseParsers.parseUserLicenses(ulSTR,OrgId,ncred);
				System.debug('Parsed UserLicense List : '+ ulList.size());
                if(ulList.size()>0){
                    lList.addAll(ulList);
                }				
			}
			if(plRes.getStatusCode()==200){
				List<DTS_Amadeus_Licenses__c> plList = DTS_CrossOrgsLicenseParsers.parsePermSetLicenses(plSTR,OrgId,ncred);
				System.debug('Parsed PermissionSetLicense List : '+ plList.size());
                if(plList.size()>0){
                  lList.addAll(plList);   
                }				
			}
			System.debug('License List Size for : '+ncred+':' +lList.size());
			
            //Upsert Records based on the External Id`s
            if(lList.size()>0){
               try{
				Upsert lList LicenseExtID__c; 
				System.debug ('Upserted Licenses List Scuccessfully for : ' + ncred);
			   }
               catch (exception e){
            	System.debug ('Upsert Licenses failed for : ' + ncred);
				NI_Error_Logger.WriteToLog ('CrossOrg Upsert License Failed for :' + ncred + ' Error Message :-'+e.getmessage(), 'NI_Admin_Error_Log__c', 'DTS_CrossOrgsLicenseCallout_Batch', 'UPSERT');   
			   } 	
            }
            
			//Calling JSON Parser/Deserializer Methods for Entitlements
            if(teRes.getStatusCode()==200){
				List<DTS_Amadeus_Entitlements__c> etList = DTS_CrossOrgsLicenseParsers.parseEntitlements(teSTR,OrgId,ncred);
				System.debug('Parsed U-Based Ent List : '+ etList.size());
                if(etList.size()>0){
                  try{
					Upsert etList EntitlementExtID__c; 
					System.debug ('Upserted eList Scuccessfully for : ' + ncred);
					}
					catch (exception e){
					System.debug ('Upsert Entitlements failed for : ' + ncred);
					NI_Error_Logger.WriteToLog ('CrossOrg Upsert Entitlements Failed for :' + ncred + ' Error Message :-'+e.getmessage(), 'NI_Admin_Error_Log__c', 'DTS_CrossOrgsLicenseCallout_Batch', 'UPSERT');   
					}     
                }
			}			
			 
		 }//End of Scope		
		
	}
		
	global void finish(Database.BatchableContext BC) {
		system.debug('In the finsh method of CrossOrgsCalloutBatch Apex.......');		
	}
}