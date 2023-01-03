/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsLoginHistory_Batch Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : CrossOrgs Project: Callout to the connected Amadeus Orgs to pull Yesterday`s LoginHistory	
				: Flexible to include/exclude orgs with Named Credentials, Custom MDT and Static Resources.	
Comments		: Schedule DTS_CrossOrgsLoginCallout_Batch.cls. Use this only if needed.Can bring ~10000 login records for a  day 						
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
MaintainedBy 	: Arul Geetha Amalraj
Dependencies 	: DTS_CrossOrgsUserParsers.cls
TestClass    	: DTS_CrossOrgsLoginCallout_Test.cls (96%)
**********************************************************************************************************************************************/
global class DTS_CrossOrgsLoginHistory_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	
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
			
			//Variables for Insert
			List<DTS_Amadeus_Logins__c> amhList = new List<DTS_Amadeus_Logins__c>();
			List<LoginHistory> UsersHrList = new List<LoginHistory>();			
			
			//Variables for Composite Batch with interpolation.
			Integer totalsize;
			Integer iCtr;
			String nextRecordsUrl;
			String baseNextUrl;
			
			//Query for LoginHistory
			String hQuery = 'select+ID%2CLoginTime%2CUserId%2CLoginType+%2CSourceIp%2CStatus+%2CLoginUrl%2CApplication%2CCountryISO+From+LoginHistory+where+LoginTime+%3E%3D+YESTERDAY+AND+LoginTime+%3C+TODAY+LIMIT+10000';
			String queryURL = '?q='+ hQuery;
			System.debug(queryURL);			
			String EndPoint = 'callout:'+ncred+'/services/data/v49.0/query/'+queryURL;
			System.debug(EndPoint);
			
			HttpRequest reqH = new HttpRequest();
			reqH.setEndpoint(EndPoint);
			reqH.setMethod('GET');
			reqH.setTimeout(20000);			
			Http httpH = new Http();
			HTTPResponse resH = httpH.send(reqH);
			System.debug('Status Code: '+ resH.getStatusCode()+ ', '+ 'Header Location: ' + resH.getHeader('Location'));			
			System.debug(resH.getBody());
			String strH = resH.getBody();
			
			if(resH.getStatusCode()==200){
				List<LoginHistory> uhList = DTS_CrossOrgsUserParsers.parseLogins(strH);				
				system.debug ('Initial List Size :'+ uhList.size());
				if(uhList.size()>0){
                    UsersHrList.addAll(uhList);
				}	
				totalsize = DTS_CrossOrgsUserParsers.parseTotal(strH);
				System.debug('TotalSize: '+ totalsize);
				iCtr = totalSize/2000;
				System.debug('iCtr: '+ iCtr);
				if(totalsize>2000){
					nextRecordsUrl = DTS_CrossOrgsUserParsers.parseURL(strH);
					System.debug('nextRecordsUrl: '+ nextRecordsUrl);
					if(nextRecordsUrl!=Null){
						baseNextUrl = nextRecordsUrl.split('-')[0];
						System.debug('baseNextUrl: '+ baseNextUrl);
					}
						for(Integer i=1; i <=iCtr; i++){
						string strURL = baseNextUrl+'-'+i*2000;
						System.debug('strURL: '+ strURL);
						List<LoginHistory> xList = getLoginRecords(strURL,ncred);
						system.debug (xList.size());				
						if(xList.size()>0){
						UsersHrList.addAll(xList);
						}				
					}
				}				
			}
			System.debug('Total LoginHistory Size :' + UsersHrList.size());
			
			//Get unique logged in User IDs from Login History						
			Map<Id,LoginHistory> mapLogins = new Map<Id,LoginHistory>();
			if(UsersHrList.size()>0){
				for(LoginHistory h : UsersHrList){
					mapLogins.put(h.UserId, h);  
				}				
			}			
			System.debug('Unique UserID`s from LoginHistory:'+ mapLogins.size());
			
			//Get the list of active Amadeus Users w Salesforce and Salesforce Platform License
			List<DTS_Amadeus_Users__c> lhList = new List<DTS_Amadeus_Users__c>();
			lhList = [Select Id,UserID__c, name from DTS_Amadeus_Users__c where amadeusorg__c = :OrgId  and isActive__c = True and UserID__c in:mapLogins.keyset()];
			System.debug('Active DTS Users who are Logged in Yesterday: '+lhList.size());			
			
			//Map of Amadeus Users for the iteration
			Map<Id,DTS_Amadeus_Users__c> mapUsers = new Map<Id,DTS_Amadeus_Users__c>();
			if(lhList.size()>0){			
				for(DTS_Amadeus_Users__c m : lhList){
					mapUsers.put(m.UserID__c, m);
				}			
			}
			System.debug('Uniques DTS Users who are Logged in Yesterday: '+lhList.size());
			
		//History based iteration
		if(lhList.size()>0){ 
			for(LoginHistory h:UsersHrList){
				if(mapUsers.containsKey(h.UserID)){
					DTS_Amadeus_Logins__c amh = new DTS_Amadeus_Logins__c();
					amh.UserID__c = mapUsers.get(h.UserID).Id;
					amh.name = mapUsers.get(h.UserID).name;			
					amh.LoginTime__c = h.LoginTime;
					amh.LoginDate__c = amh.LoginTime__c.date();
					amh.SourceIp__c = h.SourceIp;
					amh.LoginType__c = h.LoginType;				
					amh.Status__c = h.Status;
					amh.LoginUrl__c = h.LoginUrl; 
					amh.Application__c = h.Application; 
					amh.CountryISO__c = h.CountryISO; 
					amhList.add(amh);					
				}				
			}		
		}		
		System.debug('Login History List for Insert: '+ amhList.size());	
		
			if(amhList.size()>0){
				try{
				Insert amhList; 
				System.debug ('Inserted LoginHistory Successfully for : ' + ncred);
				}
				catch (exception e){
				System.debug('Insert Login History Failed for : ' + ncred);
				NI_Error_Logger.WriteToLog ('CrossOrg Insert Login History Failed for :' + ncred + ': Error Message :-'+e.getmessage(), 'NI_Admin_Error_Log__c', 'DTS_CrossOrgsLoginCallout_Batch', 'INSERT');			   			
				}			
			}
			
		}//End of Scope
	}

	Private static List<LoginHistory> getLoginRecords(String strURL, String ncred){	
					
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
			List<LoginHistory> xList = DTS_CrossOrgsUserParsers.parseLogins(responseBody);	
			return xList;
		}
		else{
			return null;
		}
		
	}//EOC getLoginRecords
	global void finish(Database.BatchableContext BC) {
		system.debug('In the finsh method of CrossOrgsUsersCalloutBatch Apex.......');		
	}
}