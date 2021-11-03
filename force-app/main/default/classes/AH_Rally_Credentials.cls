/****************************************************************************************
Name            : AH_Rally_Credentials (TC Org Name: RallyCredentials) 
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : class which can be extended by other classes which use rally credentails
				: 
******************************************************************************************/
public abstract class AH_Rally_Credentials  
{
    
    public static String userName;
    public static String pwd;
    public static String workspace_name;
    public static String Defect_Field;
    public static String versionNumber;
    public static String endPoint;
    public static DateTime dateFilterValue;
    public static String emailaddress;
    
    static 
    {
        AH_Rally_Setup__c obj = [SELECT Username__c, Schedular_Last_Run__c, RallyURL__c, API_Version__c, Password__c, workspace__c, Exception_Notification_Email__c, Story_Field_Map__c 
                                 FROM AH_Rally_Setup__c 
                                 ORDER BY Name ASC];
        userName = obj.Username__c;                       
        pwd = obj.Password__c; 
        workspace_name = obj.workspace__c;
        Defect_Field = obj.Story_Field_Map__c;
        versionNumber = obj.API_Version__c;
        endPoint = obj.RallyURL__c;
        dateFilterValue = obj.Schedular_Last_Run__c;
        emailaddress = obj.Exception_Notification_Email__c;
    }   
    
}