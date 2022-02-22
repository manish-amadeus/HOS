/****************************************************************************************
Name            : AH_SCIM_User Class
Author          : Ganesh Bora
Created Date    : 05/01/2022
Last Mod Date   :  
Last Mod By     : 
NICC Reference  :  
Description     : Wrapper class for SCIM User resource type
                : 
****************************************************************************************/
public class AH_SCIM_User 
{

	public class Addresses 
    {
		public String country;
		public String streetAddress;
		public String formatted;
		public String postalCode;
		public String locality;
		public String type;
		public String region;
		public Boolean primary;
	}

	public class Meta 
    {
		public String resourceType = 'User';
	}

	public class Roles 
    {
		public String display;
		public String value;
	}
	public class Emails
    {
		public String value{get;set;}
		public Boolean primary{get;set;}
	}
	public List<String> schemas;
	public List<Addresses> addresses;
	public String preferredLanguage;
	public Meta meta;
	public List<Roles> roles;
	public List<Roles> groups;
    public Name name;
    public list<Emails> emails{get;set;}
	public String externalId;
    public String id;
	public Boolean active;
	public String userName;
    public string managementCompanyName;
    public string managementCompanyID;
    public string accountName;
    public string accountID;
    public List<Custom> custom {get;set;}
    public class custom {
		public String value {get;set;} 
		public String key {get;set;} 
    }
	public class Name 
    {
		public String formatted;
		public String familyName;
		public String givenName;
	}
	public AH_SCIM_User()
    {
        //AH_SCIM_User.schemas = new List <string>();
        //AH_SCIM_User.schemas.add('urn:ietf:params:scim:schemas:core:2.0:User');
        //AH_SCIM_User.schemas.add('urn:ietf:params:scim:schemas:extension:enterprise:2.0:User');
    }
}