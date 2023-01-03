/****************************************************************************************
Name            : NICP_Functions Class
Author          : Sean Harris
Created Date    : 07/11/2012c
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-005289 - https://c.na4.visual.force.com/apex/ni_change_control_tabbed_layout?id=a0s60000003oX0yAAE
Description     : Class for handling Live Agent events
                : 
                : 
******************************************************************************************/
public with sharing class NICP_Functions 
{

    public String getAccountName{get; set;} 
    public User u;
    
    public NICP_Functions(ApexPages.StandardController controller) 
    {
        try 
        {
            User u = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
            Account a = [SELECT Id, Name FROM Account WHERE Id =: u.AccountId];
            getAccountName = a.Name;
        }
        catch (Exception e){getAccountName = 'Please Specify';}
    }
}