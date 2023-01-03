/****************************************************************************************
Name            : NeighborhoodLogin_Test Class
Author          : Sean Harris
Created Date    : 03/10/2016
Last Mod Date   : 03/10/2016
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
@isTest 
public class NeighborhoodLogin_Test
{
 
    public static testMethod void testNeighborhoodLogin() 
    {   
        
    	//PAGE REFERENCE
        PageReference pageRef = Page.NeighborhoodLogin;
        Test.setCurrentPage(pageRef);
        
        //CONTROLLER 
        NeighborhoodLogin ctrl = new NeighborhoodLogin();
    	ctrl.username = 'xxxxxxx@newmarketinc.com';
    	ctrl.password = 'xxxxxxx'; 
		ctrl.rememberUserName = true;        
        ctrl.doLogin();
        
    }
    
}