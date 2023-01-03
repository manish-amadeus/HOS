/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsHubData Class
Author          : Arul Geetha Amalraj
Created Date    : 12/02/2020
Last Mod Date   : 03/23/2021
Last Mod By     : Arul Geetha Amalraj
NICC Reference  : NICC-046831
Description     : Part of the DTS Cross_Orgs Project. Pulls the current hub org`s UserLicenses/PermissionSetLicenses/U-Based Ent/Users
				: Scheduled to run daily @10:00PM - Cron Schedule => Added at the end for ref
Changes			: Frozen User Updates (03/23/2021)			
TestClass    	: DTS_CrossOrgsHubData_Test.cls(92%)		
**********************************************************************************************************************************************/

global class DTS_CrossOrgsHubData implements Schedulable{	
   
	global void execute(SchedulableContext sc) {
		getSetupData();
	}		
		
	public static void getSetupData(){
		
		//Get Hub_Org details from SR
		StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'DTS_CrossOrgsHub_SR'];
		Blob bodyBlob = sr.Body;
        String query = bodyBlob.toString();
		System.debug('Static Resource :'+ query);
		DTS_Amadeus_Organizations__c hubOrg = Database.Query(query);		
		
		//Queries:- User License, PermissionSet License,Usage Entitlements, Users, Frozen Users 			
		List<UserLicense> ulQuery = [Select Id, MasterLabel, Status, TotalLicenses, UsedLicenses From UserLicense];		
		List<PermissionSetLicense> plQuery = [Select Id, MasterLabel, Status, TotalLicenses, UsedLicenses, ExpirationDate From PermissionSetLicense];
		List<TenantUsageEntitlement> ueQuery = [Select Id, MasterLabel,ResourceGroupKey,StartDate,EndDate,UsageDate,Frequency,CurrentAmountAllowed,AmountUsed From TenantUsageEntitlement];
		List<User> uQuery = [SELECT Id,FirstName,LastName,Name,Email,UserName,FederationIdentifier,IsActive,LastLoginDate,CreatedDate,LastModifiedDate,Profile.Name,Profile.UserLicense.Name From User where Profile.UserLicense.Name Like 'Salesforce%' LIMIT 10000];
		List<UserLogin> ufQuery = [SELECT Id,UserID,isFrozen,LastModifiedDate From UserLogin where isFrozen = True LIMIT 10000];     

				
		//Variables for Upsert/Update
		List<DTS_Amadeus_Licenses__c> amLicenses = new List<DTS_Amadeus_Licenses__c>();
		List<DTS_Amadeus_Entitlements__c> amEnts = new List<DTS_Amadeus_Entitlements__c>();
		List<DTS_Amadeus_Users__c> amUsers = new List<DTS_Amadeus_Users__c>();
		List<DTS_Amadeus_Users__c> ufList = new List<DTS_Amadeus_Users__c>();		
		
		for(UserLicense ul:ulQuery){
			DTS_Amadeus_Licenses__c amUL = new DTS_Amadeus_Licenses__c();
			amUL.LicenseID__c = ul.Id;
			amUL.LicenseExtID__c = ul.Id +':'+'Hub_Org';			
			amUL.name = ul.MasterLabel.length()>=80 ? ul.MasterLabel.substring(0,80) : ul.MasterLabel;			
			amUL.status__c= ul.status;
			amUL.TotalLicenses__c = ul.totalLicenses;
			amUL.UsedLicenses__c = ul.usedLicenses;					
			amUL.LicenseType__c = 'User License'; 				
			amUL.AmadeusOrg__c = hubOrg.Id;
			amLicenses.add(amUL);			
		}
		System.debug('User Licenses :' + amLicenses.size());
		
		for(PermissionSetLicense p:plQuery){
			DTS_Amadeus_Licenses__c amPL = new DTS_Amadeus_Licenses__c();
			amPL.LicenseID__c = p.Id;
			amPL.LicenseExtID__c = p.Id+':'+'Hub_Org';			
			amPL.name = p.MasterLabel.length()>=80 ? p.MasterLabel.substring(0,80) : p.MasterLabel;
			amPL.status__c= p.status;
			amPL.TotalLicenses__c = p.totalLicenses;
			amPL.UsedLicenses__c = p.usedLicenses;			
			amPL.ExpirationDate__c = p.ExpirationDate;			
			amPL.LicenseType__c = 'PermissionSet License';			
			amPL.AmadeusOrg__c = hubOrg.Id;
			amLicenses.add(amPL);				
		}
		System.debug('Total Licenses (UL+PL) :' + amLicenses.size());
		
		for(TenantUsageEntitlement e:ueQuery){
			DTS_Amadeus_Entitlements__c amEnt = new DTS_Amadeus_Entitlements__c();
			amEnt.EntitlementID__c = e.Id;
			amEnt.EntitlementExtID__c = e.Id+':'+'Hub_Org';			
			amEnt.name = e.masterLabel.length()>=80 ? e.masterLabel.substring(0,80) : e.masterLabel;
			amEnt.ResourceID__c = e.ResourceGroupKey;
			amEnt.StartDate__c = e.StartDate;
			amEnt.EndDate__c = e.EndDate;
			amEnt.UsageDate__c = e.UsageDate;
			amEnt.Frequency__c = e.Frequency;
			amEnt.Allowance__c = Integer.valueof(e.CurrentAmountAllowed);
			amEnt.AmountUsed__c = Integer.valueof(e.AmountUsed);
			amEnt.AmadeusOrg__c = hubOrg.Id;
			amEnts.add(amEnt);				
		}
        System.debug('Entitlements :' + amEnts.size());
		
		//Upsert License List based on Ext_ID
		if(amLicenses.size()>0){
			try{
			Upsert amLicenses LicenseExtID__c; 
			System.debug ('Upserted Licenses Scuccessfully for Hub : ' + hubOrg.name);
			}
			catch (exception e){
			System.debug('Upsert Licenses Failed for Hub : ' + hubOrg.name);
			NI_Error_Logger.WriteToLog ('HubOrg Upsert License Failed for Hub :' + hubOrg.name + ': Error Message :-'+e.getmessage(), 'NI_Admin_Error_Log__c', 'DTS_CrossOrgsHubData', 'UPSERT');			   			
			}			
		}
		
		//Upsert Entitlements List based on Ext_ID
		if(amEnts.size()>0){
			try{
			Upsert amEnts EntitlementExtID__c; 
			System.debug ('Upserted Entitlements Scuccessfully for Hub : ' + hubOrg.name);
			}
			catch (exception e){
			System.debug('Upsert Entitlements Failed for Hub : ' + hubOrg.name);
			NI_Error_Logger.WriteToLog ('HubOrg Upsert Entitlements Failed for Hub :' + hubOrg.name + ': Error Message :-'+e.getmessage(), 'NI_Admin_Error_Log__c', 'DTS_CrossOrgsHubData', 'UPSERT');			   			
			}			
		}
		
		for(User u:uQuery){
			DTS_Amadeus_Users__c amU = new DTS_Amadeus_Users__c();
			amU.UserID__c = u.Id;
			amU.UserExtID__c = u.Id +':'+'Hub_Org';
			amU.FirstName__c = u.FirstName;
			amU.LastName__c = u.LastName;          
			amU.name = u.Name.length()>=80 ? u.Name.substring(0,80) : u.Name;		
			amU.Email__c = u.Email;
            amU.UserName__c = u.UserName;			
			amU.FederationID__c = u.FederationIdentifier; 
			amU.IsActive__c = u.IsActive; 
			amU.UserLastLoginDate__c = u.LastLoginDate;
			amU.UserCreatedDate__c = u.CreatedDate;
			amU.UserLastModifiedDate__c = u.LastModifiedDate;
			amU.Profile__c = u.Profile.name; 
			amU.UserLicense__c = u.Profile.UserLicense.name;		
            amU.AmadeusOrg__c = hubOrg.Id;
			//Frozen User Updates
			amU.isFrozen__c = False;
			amU.FreezeDate__c = Null;		
			amUsers.add(amU);					
		}
		System.debug('Users (Active+InActive) w Salesforce & Salesforce Platform Licenses :'+ amUsers.size());		
		
		//Upsert Users List based on Ext_ID
		if(amUsers.size()>0){
			try{
			Upsert amUsers UserExtID__c; 
			System.debug ('Upserted Users Scuccessfully for Hub : ' + hubOrg.name);
			}
			catch (exception e){
			System.debug('Upsert Users Failed for Hub : ' + hubOrg.name);
			NI_Error_Logger.WriteToLog ('HubOrg Upsert Users Failed for Hub :' + hubOrg.name + ': Error Message :-'+e.getmessage(), 'NI_Admin_Error_Log__c', 'DTS_CrossOrgsHubData', 'UPSERT');			   			
			}			
		}
		
		//Get the Frozen UserIDs
		Map<Id,UserLogin> mapLogins = new Map<Id,UserLogin>();
		if(ufQuery.size()>0){
			for(UserLogin u : ufQuery){
                 mapLogins.put(u.UserId, u);  
			}
		}			
		System.debug('Frozen Users w All Licenses :'+ mapLogins.size());
		
		//Get the list of Inactive Users w Salesforce and Salesforce Platform License
		ufList = [Select Id, UserID__c, isFrozen__c, FreezeDate__c from DTS_Amadeus_Users__c where amadeusorg__c = :hubOrg.Id and isActive__c = False and UserID__c in:mapLogins.keyset()];
		System.debug('Inactive Users w Salesforce & Salesforce Platform Licenses : '+ufList.size());	

		if(ufList.size()>0){
			for(DTS_Amadeus_Users__c a:ufList ){
				if(mapLogins.containsKey(a.UserID__c)){
					a.isFrozen__c = True;
					a.FreezeDate__c = mapLogins.get(a.UserID__c).LastModifiedDate;	
				}										
			}
			try{
				Update ufList; 
				System.debug ('Updated frozen Users Successfully for Hub : ' + hubOrg.name);
			}
			catch (exception e){
				System.debug('Update frozen Users Failed for Hub : ' + hubOrg.name);
				NI_Error_Logger.WriteToLog ('HubOrg update frozen Users Failed for Hub :' + hubOrg.name + ': Error Message :-'+e.getmessage(), 'NI_Admin_Error_Log__c', 'DTS_CrossOrgsHubData', 'UPDATE');			   			
			}		
		}		
			
	}//End of getSetupData
}

/*
    // Cron Schedule-Added here for ref
    DTS_CrossOrgsHubData b = new DTS_CrossOrgsHubData ();
    String sch = '0 0 22 * * ?';
    system.schedule('CrossOrgsHubData: Daily @10:00 PM', sch, b);
*/