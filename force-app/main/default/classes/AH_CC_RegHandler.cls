/****************************************************************************************
Name            : AH_CC_RegHandler
Author          : Sean Harris
Created Date    : 10/29/2019
Last Mod Date   : 10/29/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Customized Registration Handler class used in mapping community users to 
                : Salesforce provider authenticated ones.
******************************************************************************************/
global class AH_CC_RegHandler implements Auth.RegistrationHandler 
{
    
    global User createUser(Id portalId, Auth.UserData data)
    {
        User u = null;
        try
        {
            u = [SELECT Id 
                 FROM User 
                 WHERE email =: data.email 
                 AND UserType = 'PowerCustomerSuccess' 
                 AND IsActive = true];
        }
        catch (Exception ex) 
        { 
            NI_Error_Logger.WriteToLog('The following error occurred when automation tried to match external user to Customer Central Community user: ' + ex.getMessage(), 'User', 'AH_CC_RegHandler', 'Update'); 
        }
        return u;
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data)
    {
        try
        {
            User u = [SELECT Id, External_Salesforce_Username__c  
                      FROM User 
                      WHERE Id =: userId];
            u.External_Salesforce_Username__c = data.Username;
            
            update u;
        }
        catch (Exception ex) 
        { 
        	system.debug(' ERROR = ' + ex.getMessage());
            NI_Error_Logger.WriteToLog('The following error occurred when automation tried to update User.External_Salesforce_Username__c: ' + ex.getMessage(), 'User', 'AH_CC_RegHandler', 'Update'); 
        }
    }    

//    global boolean canCreateUser(Auth.UserData data) 
//    {
//        return false;
//    }
    
}