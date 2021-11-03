/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsUserParsers Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   : 03/23/2021
Last Mod By     : Arul Geetha Amalraj
NICC Reference  : NICC-046831
Description     : Deserialize/Parse the JSON response from Callouts to the connected Amadeus Cross Orgs.
				: Cross_Orgs Project-> Users (Active, Inactive, Forzen, Login History) with Salesforce and Platform Licenses
Changes			: Frozen User Updates (03/23/2021)
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
MaintainedBy 	: Arul Geetha Amalraj
Dependencies 	: DTS_CrossOrgsUserCallout_Batch.cls
TestClass    	: DTS_CrossOrgsUserCallout_Test.cls (100%)			
**********************************************************************************************************************************************/
public class DTS_CrossOrgsUserParsers{
	
	public static Integer parseTotal(String response){		

		Integer totalsize;
		JSONParser parser = JSON.createParser(response);
			for(Integer i=0; i<=10; i++){
				parser.nextToken();
				if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'totalsize')) {
                //parser.nextToken();
				parser.nextValue(); 
                totalSize = parser.getIntegerValue();                                    
				}							
			}
		return totalSize;      
		
	}//End of parseTotal
	
	
	public static String parseURL(String response){		
		
		String nextEndPointUrl;
		JSONParser parser = JSON.createParser(response);
			for(Integer i=0; i<=10; i++){
				parser.nextToken();
				if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'nextRecordsUrl')) {
                //parser.nextToken();
				parser.nextValue(); 
                nextEndPointUrl=parser.getText();                                     
				}							
			}
		return nextEndPointUrl;  
		
	}//End of parseURL
	
	public static List<DTS_Amadeus_Users__c> parseUsers(String response,String OrgId, String ncred){
		
		List<User> uLists = new List<User>();
        List<DTS_Amadeus_Users__c> amUsers = new List<DTS_Amadeus_Users__c>();
            
        JSONParser parser = JSON.createParser(response);
		while (parser.nextToken() != null) {
			 // Start at the array of User
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
				// Advance to the start object marker
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    User uList = (User)parser.readValueAs(User.class);
                    uLists.add(uList);
                    }
                }
            }
        }
        System.debug('Users in Batches :'+uLists.size()); 
		
		for(User u: uLists){
            DTS_Amadeus_Users__c amU = new DTS_Amadeus_Users__c();
            amU.UserID__c = Id.valueOf(u.Id);
			amU.UserExtID__c = Id.valueOf(u.Id)+':'+ncred;
			amU.FirstName__c = u.FirstName;
			amU.LastName__c = u.LastName;					           
			amU.name = u.Name.length()>=80 ? u.Name.substring(0,80) : u.Name;                        
			amU.UserName__c = u.UserName; 
			amU.FederationID__c = u.FederationIdentifier; 
			amU.Email__c = u.Email;
			amU.IsActive__c = u.IsActive; 
			amU.UserLastLoginDate__c = u.LastLoginDate;
			amU.UserCreatedDate__c = u.CreatedDate;
			amU.UserLastModifiedDate__c = u.LastModifiedDate;
			amU.Profile__c = u.Profile.name; 
			amU.UserLicense__c = u.Profile.UserLicense.name;						
            amU.AmadeusOrg__c = OrgId;
			//Frozen User Updates
			amU.isFrozen__c = False;
			amU.FreezeDate__c = Null;            
            amUsers.add(amU);        
        }
		amUsers.sort();
		//system.debug ('Profile :' + amUsers[0].Profile__c +':'+ 'License :' + amUsers[0].UserLicense__c);	
		system.debug ('AmUsers Size :'+amUsers.size());
		return amUsers;		
						
    }//End of parseUsers

	public static List<UserLogin> parseFrozenUsers(String response){
		
		List<UserLogin> ufLists = new List<UserLogin>();
         
        JSONParser parser = JSON.createParser(response);
		while (parser.nextToken() != null) {
			 // Start at the array of UserLogin
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
				// Advance to the start object marker
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    UserLogin ufList = (UserLogin)parser.readValueAs(UserLogin.class);
                    ufLists.add(ufList);
                    }
                }
            }
        }
        System.debug('Frozen Users w All Licenses :'+ufLists.size()); 		
		return ufLists;		
						
    }//End of parseFrozenUsers	
	
	public static List<LoginHistory> parseLogins(String response){
		
		List<LoginHistory> lhLists = new List<LoginHistory>();
         
        JSONParser parser = JSON.createParser(response);
		while (parser.nextToken() != null) {
			 // Start at the array of LoginHistory
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
				// Advance to the start object marker
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    LoginHistory lhList = (LoginHistory)parser.readValueAs(LoginHistory.class);
                    lhLists.add(lhList);
                    }
                }
            }
        }
        System.debug('LoginHistory Size :'+lhLists.size()); 		
		return lhLists;		
						
    }//End of parseLogins	
}