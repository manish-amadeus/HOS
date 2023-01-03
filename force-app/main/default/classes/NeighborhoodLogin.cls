/****************************************************************************************
Name            : NeighborhoodLogin Class
Author          : Sean Harris
Created Date    : 03/10/2016
Last Mod Date   : 03/10/2016
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
public class NeighborhoodLogin 
{
    
    public String username {get; set;}
    public String password {get; set;}
	public boolean rememberUserName {get; set;}
    public boolean displayError {get; set;}
    public String baseURL {get; set;}

    
    public NeighborhoodLogin()
    {  
        // INITALIZE ERROR DISPLAY FLAG 
        displayError = false;  
        baseURL = URL.getSalesforceBaseUrl().toExternalForm();
		baseURL = baseURL.replace('https://c.','');
        baseURL = baseURL.replace('https://','');
		baseURL = baseURL.replace('.salesforce.com','');
        baseURL = baseURL.replace('.visual.force.com','');
        baseURL = 'https://' + baseURL + '.salesforce.com/servlet/networks/session/create?site=0DM60000000Caqv&amp;refURL=http%3A%2F%2Fnewmarket.' + baseURL + '.force.com%2Fneighborhood%2Flogin&amp;inst=32';
    }
    
    public pageReference doLogin()
    {  
        
        // REDIRECT URL WITH URL PARAMS FOR LANDING PAGE TO CAPTURE VALUES TO SET COOKIES 
		String startUrl = '/apex/CommunityGettingStarted';
        
        if (system.currentPageReference().getParameters().get('startURL') != null)
        {
            startUrl = system.currentPageReference().getParameters().get('startURL');
        }
        
        // ATTEMPT LOGIN
        pageReference pr = Site.login(username, password, startUrl); 
        
        // IF LOGIN FAILS
        if (pr == null)
        {
            displayError = true;
        }
        
	    return pr;
        
    }
    
}