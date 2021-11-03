/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsHubLoginHistory Class
Author          : Arul Geetha Amalraj
Created Date    : 12/02/2020
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : CrossOrgs Project: Callout to the connected Amadeus Orgs to pull Yesterday`s LoginHistory				
Comments 		: Schedule DTS_CrossOrgsHubLogins.cls and use this only if needed.Can bring ~10000 Yesterday`s login records on a daily basis			
TestClass    	: DTS_CrossOrgsHubData_Test.cls(95%)				 
				:
**********************************************************************************************************************************************/

global class DTS_CrossOrgsHubLoginHistory implements Schedulable{	
   
	global void execute(SchedulableContext sc) {
		getHistoryData();
	}		
		
	public static void getHistoryData(){
		
		//Get Hub_Org details from SR
		StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'DTS_CrossOrgsHub_SR'];
		Blob bodyBlob = sr.Body;
        String query = bodyBlob.toString();
		System.debug('Static Resource :'+ query);
		DTS_Amadeus_Organizations__c hubOrg = Database.Query(query);		
		
		//Query Yesterday`s Login History 		        
		Datetime dToday = System.today();
		Datetime dYestday = System.today().addDays(-1);
		System.debug('Yesterday :'+ dYestday); 
		List<LoginHistory> hQuery = [SELECT Id,UserID,LoginTime,SourceIp,LoginType,Status,LoginUrl,Application,CountryISO From LoginHistory where LoginTime >= :dYestday and LoginTime <:dToday LIMIT 10000];	
		System.debug('Yesterday`s LoginHistory for All Licenses :'+ hQuery.size());		
		
		//Variables	
		List<DTS_Amadeus_Users__c> lhList = new List<DTS_Amadeus_Users__c>();
		List<DTS_Amadeus_Logins__c> amhList = new List<DTS_Amadeus_Logins__c> ();
		
		//Get unique logged in User IDs from Login History
		Map<Id,LoginHistory> mapLogins = new Map<Id,LoginHistory>();
		if(hQuery.size()>0){			
			for(LoginHistory h : hQuery){
				mapLogins.put(h.UserId, h);  
			}					
		}
		System.debug('Unique UserID`s from LoginHistory:'+ mapLogins.size());
		
		//Get the list of active Amadeus Users w Salesforce and Salesforce Platform License
		lhList = [Select Id,UserID__c, name from DTS_Amadeus_Users__c where amadeusorg__c = :hubOrg.Id and isActive__c = True and UserID__c in:mapLogins.keyset()];
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
			for(LoginHistory h:hQuery ){
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
			System.debug ('Inserted LoginHistory Scuccessfully for Hub : ' + hubOrg.name);
			}
			catch (exception e){
			System.debug('Insert Login History Failed for Hub : ' + hubOrg.name);
			NI_Error_Logger.WriteToLog ('HubOrg Insert Login History Failed for Hub :' + hubOrg.name + ': Error Message :-'+e.getmessage(), 'NI_Admin_Error_Log__c', 'DTS_CrossOrgsHubLoginHistory', 'INSERT');			   			
			}			
		}
			
	}//End of getLoginData
}

/*
    // Cron Schedule-Added here for ref:-Scheduled from UI
    DTS_CrossOrgsHubLoginHistory b = new DTS_CrossOrgsHubLoginHistory ();
    String sch = '0 0 22 * * ?';
    system.schedule('CrossOrgsHubLoginHistory: Daily @10:00 PM', sch, b);

*/