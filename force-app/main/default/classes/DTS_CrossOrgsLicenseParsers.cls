/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsLicenseParsers Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Deserialize/Parse the JSON response from Callouts to the connected Amadeus Cross Orgs
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
MaintainedBy 	: Arul Geetha Amalraj
Dependencies 	: DTS_CrossOrgsLicenseCallout_Batch Class
TestClass    	: DTS_CrossOrgsLicenseCallout_Test.cls (100%)
**********************************************************************************************************************************************/
 
public class DTS_CrossOrgsLicenseParsers{
	
	public static List<DTS_Amadeus_Entitlements__c> parseEntitlements(String response,String OrgId, String ncred){        
        
        List<TenantUsageEntitlement> tEnts = new List<TenantUsageEntitlement>();
        List<DTS_Amadeus_Entitlements__c> amdEnts = new List<DTS_Amadeus_Entitlements__c>();
        
		JSONParser parser = JSON.createParser(response);
        while (parser.nextToken() != null) {
            // Start at the array of TenantUsageEntitlement
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                // Advance to the start object marker
					if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    TenantUsageEntitlement tEnt = (TenantUsageEntitlement)parser.readValueAs(TenantUsageEntitlement.class);
                    tEnts.add(tEnt);
                    }
                }
            }
        }
        System.debug('TenantUsageEntitlement Size :'+ tEnts.size());   
  
        for(TenantUsageEntitlement t: tEnts){
            DTS_Amadeus_Entitlements__c amdEnt = new DTS_Amadeus_Entitlements__c();
            amdEnt.EntitlementID__c = Id.valueOf(t.Id); 
			amdEnt.EntitlementExtID__c = Id.valueOf(t.Id)+':'+ncred;           
			amdEnt.name = t.masterLabel.length()>=80 ? t.masterLabel.substring(0,80) : t.masterLabel;
            amdEnt.ResourceID__c= t.ResourceGroupKey;
            amdEnt.StartDate__c = t.StartDate;
            amdEnt.EndDate__c = t.EndDate;
			amdEnt.UsageDate__c = t.UsageDate; 			
            amdEnt.Frequency__c = t.Frequency;            
            amdEnt.Allowance__c = Integer.valueof(t.CurrentAmountAllowed);
            //system.debug(amE.Allowance__c);            
            amdEnt.AmountUsed__c = Integer.valueof(t.AmountUsed);
            //system.debug(amE.AmountUsed__c);                
            amdEnt.AmadeusOrg__c = OrgId;            
            amdEnts.add(amdEnt);        
        }
        amdEnts.sort(); 
        system.debug ('AmadeusEntitlements Size :'+ amdEnts.size());
        return amdEnts;
                                
    }// EOC parseEntitlements
	
	public static List<DTS_Amadeus_Licenses__c> parseUserLicenses(String response, String OrgId, String ncred){
		
		List<UserLicense> uLicenses = new List<UserLicense>();
        List<DTS_Amadeus_Licenses__c> amdLicenses = new List<DTS_Amadeus_Licenses__c>(); 
        
		JSONParser parser = JSON.createParser(response); 
        while (parser.nextToken() != null) {
            // Start at the array of UserLicense
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                // Advance to the start object marker
					if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    UserLicense uLicense = (UserLicense)parser.readValueAs(UserLicense.class);
                    uLicenses.add(uLicense);
                    }
                }
            }
        }
		
		System.debug('UserLicense Size :'+uLicenses.size());
		
        for(UserLicense u: uLicenses){
			DTS_Amadeus_Licenses__c amdLicense = new DTS_Amadeus_Licenses__c();
			amdLicense.LicenseID__c = Id.valueOf(u.Id); 
			amdLicense.LicenseExtID__c = Id.valueOf(u.Id)+':'+ncred;			        
			amdLicense.name = u.masterLabel.length()>=80 ? u.masterLabel.substring(0,80) : u.masterLabel;			
			amdLicense.status__c= u.status;
			amdLicense.TotalLicenses__c = u.totalLicenses;
			amdLicense.UsedLicenses__c = u.usedLicenses;				
			amdLicense.LicenseType__c = 'User License'; 				
			amdLicense.AmadeusOrg__c = OrgId;				
			amdLicenses.add(amdLicense);        
		}		
		system.debug ('Amadeus UserLicenses Size :'+ amdLicenses.size());
        return amdLicenses;
						
    }//EOC parseUserLicenses
	
	public static List<DTS_Amadeus_Licenses__c> parsePermSetLicenses(String response, String OrgId, String ncred){
		
		List<PermissionSetLicense> psLicenses = new List<PermissionSetLicense>();
        List<DTS_Amadeus_Licenses__c> amdLicenses = new List<DTS_Amadeus_Licenses__c>(); 
        
		JSONParser parser = JSON.createParser(response);
        while (parser.nextToken() != null) {
            // Start at the array of PermissionSetLicense
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                // Advance to the start object marker
					if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    PermissionSetLicense psLicense = (PermissionSetLicense)parser.readValueAs(PermissionSetLicense.class);
                    psLicenses.add(psLicense);
                    }
                }
            }
        }
		
		System.debug('PermissionSetLicense Size :'+psLicenses.size());
		
        for(PermissionSetLicense p: psLicenses){
			DTS_Amadeus_Licenses__c amdLicense = new DTS_Amadeus_Licenses__c();
			amdLicense.LicenseID__c = Id.valueOf(p.Id); 
			amdLicense.LicenseExtID__c = Id.valueOf(p.Id)+':'+ncred;			            
			amdLicense.name = p.masterLabel.length()>=80 ? p.masterLabel.substring(0,80) : p.masterLabel;			
			amdLicense.status__c= p.status;
			amdLicense.TotalLicenses__c = p.totalLicenses;
			amdLicense.UsedLicenses__c = p.usedLicenses;				
			amdLicense.LicenseType__c = 'PermissionSet License'; 
			amdLicense.ExpirationDate__c = p.ExpirationDate;				
			amdLicense.AmadeusOrg__c = OrgId;				
			amdLicenses.add(amdLicense);        
		}		
		system.debug ('Amadeus PermissionSet Licenses Size :'+ amdLicenses.size());
        return amdLicenses;
						
    }//EOC parsePermSetLicenses	
	
}