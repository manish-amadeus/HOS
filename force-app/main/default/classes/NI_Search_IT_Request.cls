/*************************************************************************************************
Name            : NI_Search_IT_Request_Test Class
Author          : Swapnil Patil
Created Date    : 02/17/2017
Last Mod Date   : 05/26/2017
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Apex Class for the Internal IT Request Knowledge Base Search functionality
                : 
*************************************************************************************************/
public class NI_Search_IT_Request {

    public String group_id{get;set;}
    
    
    public NI_Search_IT_Request()
    {
           //Getting Values from Cutom Setting with Group Name->Default
           NI_Search_IT_Request__c group_Cust_Setting = NI_Search_IT_Request__c.getValues('Default');
           //Setting group_id Using Custom Setting
           group_id=group_Cust_Setting.Group_ID__c;
        
        }
    
    
    
}