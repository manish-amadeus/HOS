/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsUserCallout_Batch Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Callout to the connected Amadeus Orgs to pull Users (Active, Inactive, Frozen) with Salesforce or Platform Licenses.
				: Flexible to include/exclude orgs with Named Credentials, Custom MDT and Static Resources			
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
MaintainedBy 	: Arul Geetha Amalraj
Dependencies 	: DTS_CrossOrgsUserParsers.cls
TestClass    	: DTS_CrossOrgsUserCallout_Test.cls (91%)
**********************************************************************************************************************************************/

global class DTS_CrossOrgsUserCallout_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	
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
			
			//Variables for Upsert
			List<DTS_Amadeus_Users__c> usersList = new List<DTS_Amadeus_Users__c>();
			List<UserLogin> UsersFrList = new List<UserLogin>();            
			List<DTS_Amadeus_Users__c> ufList = new List<DTS_Amadeus_Users__c>();

			//Variables for Composite Batch with interpolation.
			Integer totalsize;
			Integer iCtr;
			String nextRecordsUrl;
			String baseNextUrl;
			
			//Query for User Callout
			String uQuery = 'SELECT+ID,+FirstName,+LastName,+Name,+UserName,+Email,+FederationIdentifier,+IsActive,+LastLoginDate,+CreatedDate,+LastModifiedDate,+Profile%2EName,+Profile%2EUserLicense%2EName+From+User+where+Profile%2EUserLicense%2EName+Like+%27Salesforce%25%27+LIMIT+10000';
			String queryURL = '?q='+ uQuery;
			//System.debug(queryURL);			
			String EndPoint = 'callout:'+ncred+'/services/data/v49.0/query/'+queryURL;
			//System.debug(EndPoint);
			
			HttpRequest req = new HttpRequest();
			req.setEndpoint(EndPoint);
			req.setMethod('GET');
			req.setTimeout(20000);			
			Http http = new Http();
			HTTPResponse res = http.send(req);
			System.debug('Status Code: '+ res.getStatusCode()+ ', '+ 'Header Location: ' + res.getHeader('Location'));			
			System.debug(res.getBody());
			String str = res.getBody();	
			
			//Query for UserLogin Callout (Frozen Users)
			String ufQuery = 'SELECT+ID,+UserID,+isFrozen,+LastModifiedDate+From+UserLogin+where+isFrozen=True+LIMIT+10000';			
			String queryFrURL = '?q='+ ufQuery;
			//System.debug(queryFrURL);			
			String fEndPoint = 'callout:'+ncred+'/services/data/v49.0/query/'+queryFrURL;
			//System.debug(fEndPoint);
			
			HttpRequest reqF = new HttpRequest();
			reqF.setEndpoint(fEndPoint);
			reqF.setMethod('GET');
			reqF.setTimeout(20000);			
			Http httpF = new Http();
			HTTPResponse resF = httpF.send(reqF);
			System.debug('Status Code: '+ resF.getStatusCode()+ ', '+ 'Header Location: ' + resF.getHeader('Location'));			
			System.debug(resF.getBody());
			String strF = resF.getBody();	

			if(res.getStatusCode()==200){
				List<DTS_Amadeus_Users__c> uList = DTS_CrossOrgsUserParsers.parseUsers(str,OrgId,ncred);				
				system.debug (uList.size());
				if(uList.size()>0){
                    usersList.addAll(uList);
				}	
				totalsize = DTS_CrossOrgsUserParsers.parseTotal(str);
				System.debug('TotalSize: '+ totalsize);
				iCtr = totalSize/2000;
				System.debug('iCtr: '+ iCtr);
				if(totalsize>2000){
					nextRecordsUrl = DTS_CrossOrgsUserParsers.parseURL(str);
					System.debug('nextRecordsUrl: '+ nextRecordsUrl);
					if(nextRecordsUrl!=Null){
						baseNextUrl = nextRecordsUrl.split('-')[0];
						System.debug('baseNextUrl: '+ baseNextUrl);
					}
						for(Integer i=1; i <=iCtr; i++){
						string strURL = baseNextUrl+'-'+i*2000;
						System.debug('strURL: '+ strURL);
						List<DTS_Amadeus_Users__c> xList = getXtraRecords(strURL,OrgId,ncred);
						system.debug (xList.size());				
						if(xList.size()>0){
						usersList.addAll(xList);
						}				
					}
				}				
			}
			
			if(resF.getStatusCode()==200){
				List<UserLogin> uFrList = DTS_CrossOrgsUserParsers.parseFrozenUsers(strF);				
				system.debug (uFrList.size());
				if(uFrList.size()>0){
                    UsersFrList.addAll(uFrList);
				}	
				totalsize = DTS_CrossOrgsUserParsers.parseTotal(strF);
				System.debug('TotalSize: '+ totalsize);
				iCtr = totalSize/2000;
				System.debug('iCtr: '+ iCtr);
				if(totalsize>2000){
					nextRecordsUrl = DTS_CrossOrgsUserParsers.parseURL(strF);
					System.debug('nextRecordsUrl: '+ nextRecordsUrl);
					if(nextRecordsUrl!=Null){
						baseNextUrl = nextRecordsUrl.split('-')[0];
						System.debug('baseNextUrl: '+ baseNextUrl);
					}
						for(Integer i=1; i <=iCtr; i++){
						string strURL = baseNextUrl+'-'+i*2000;
						System.debug('strURL: '+ strURL);
						List<UserLogin> xList = getFrozenRecords(strURL,ncred);
						system.debug (xList.size());				
						if(xList.size()>0){
						UsersFrList.addAll(xList);
						}				
					}
				}				
			}
			System.debug(UsersFrList.size());

			//Upsert Users based on the External Id
            if(usersList.size()>0){
               try{
				Upsert usersList UserExtID__c; 
				System.debug ('Upserted Users List Scuccessfully for : ' + ncred);
			   }
               catch (exception e){
            	System.debug ('Upsert Users failed for : ' + ncred);
				NI_Error_Logger.WriteToLog ('CrossOrg Upsert Users Failed for :' + ncred + ' Error Message :-'+e.getmessage(), 'NI_Admin_Error_Log__c', 'DTS_CrossOrgsUserCallout_Batch', 'UPSERT');   
			   } 	
            }
			
			Map<Id,UserLogin> mapLogins = new Map<Id,UserLogin>();
			//Get the Frozen UserIDs
			if(UsersFrList.size()>0){				
				for(UserLogin u : UsersFrList){
					mapLogins.put(u.UserId, u);  
				}							
			}
			System.debug('Frozen Users :'+ mapLogins.size());
			
			//Get the list of Inactive Users w Salesforce and Salesforce Platform License
			ufList = [Select Id,UserID__c, isFrozen__c, FreezeDate__c from DTS_Amadeus_Users__c where amadeusorg__c = :OrgId and isActive__c = False and UserID__c in:mapLogins.keyset()];
			System.debug('Inactive Amadeus Users : '+ufList.size());	
		
			if(ufList.size()>0){
				for(DTS_Amadeus_Users__c a:ufList ){
					if(mapLogins.containsKey(a.UserID__c)){
						a.isFrozen__c = True;
						a.FreezeDate__c = mapLogins.get(a.UserID__c).LastModifiedDate;	
					}												
				}
				try{
					Update ufList; 
					System.debug ('Updated frozen Users Successfully for : ' + ncred);
				}
				catch (exception e){
					System.debug('Update frozen Users Failed for : ' + ncred);
					NI_Error_Logger.WriteToLog ('CrossOrg update frozen Users Failed for :' + ncred + ': Error Message :-'+e.getmessage(), 'NI_Admin_Error_Log__c', 'DTS_CrossOrgsUserCallout_Batch', 'UPDATE');			   			
				}		
			}			
			
		}//End of Scope
	}
	
	Private static List<DTS_Amadeus_Users__c> getXtraRecords(String strURL, String OrgId, String ncred){	
					
		String EndPoint = 'callout:'+ncred+strURL;
		System.debug(EndPoint);
		
		HttpRequest req = new HttpRequest();
		req.setEndpoint(EndPoint);
		req.setMethod('GET');
		req.setTimeout(20000);			
		Http http = new Http();
		HTTPResponse res = http.send(req);
		System.debug('Status Code: '+ res.getStatusCode()+ ', '+ 'Header Location: ' + res.getHeader('Location'));			
		//System.debug(res.getHeader('Location'));
		System.debug(res.getBody());
		String responseBody = res.getBody();
		if (res.getStatusCode()==200){
			List<DTS_Amadeus_Users__c> xList = DTS_CrossOrgsUserParsers.parseUsers(responseBody,OrgId, ncred);	
			return xList;
		}
		else{
			return null;
		}
		
	}//EOC getXtraRecords

	Private static List<UserLogin> getFrozenRecords(String strURL, String ncred){	
					
		String EndPoint = 'callout:'+ncred+strURL;
		System.debug(EndPoint);
		
		HttpRequest req = new HttpRequest();
		req.setEndpoint(EndPoint);
		req.setMethod('GET');		
		Http http = new Http();
		HTTPResponse res = http.send(req);
		System.debug('Status Code: '+ res.getStatusCode()+ ', '+ 'Header Location: ' + res.getHeader('Location'));			
		//System.debug(res.getHeader('Location'));
		System.debug(res.getBody());
		String responseBody = res.getBody();
		if (res.getStatusCode()==200){
			List<UserLogin> xList = DTS_CrossOrgsUserParsers.parseFrozenUsers(responseBody);	
			return xList;
		}
		else{
			return null;
		}
		
	}//EOC getFrozenRecords
	global void finish(Database.BatchableContext BC) {
		system.debug('In the finsh method of CrossOrgsUsersCalloutBatch Apex.......');		
	}
}