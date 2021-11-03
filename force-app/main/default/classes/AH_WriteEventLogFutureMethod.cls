/****************************************************************************************
Name            : AH_WriteEventLogFutureMethod
Author          : Stuart Emery
Created Date    : 08/01/2021
Last Mod Date   : 08/01/2021
Last Mod By     : Stuart Emery
NICC Reference  : NICC-052490
Description     : Utility Class that writes to the AH_Event_Log__c Object using a @future method
                : This class was originally created for the AH_UTIL_ResetPassword_Ctlr Apex Class
                : and is called from that the class.  The @future method is used to
                : address mixed DML operation errors in the AH_UTIL_ResetPassword_Ctlr class
                : that were occuring because updates are made to user records and non-records
                : in the same transaction.
******************************************************************************************/
public class AH_WriteEventLogFutureMethod {
    
    @future 
    public static void writeEventLog(String strSummary, String strParentId, Id idUser)
    {
        AH_Event_Log__c evLog = new AH_Event_Log__c();
        evLog.Summary__c = strSummary;
        evLog.ParentId__c = strParentId;
        evLog.Running_User__c = idUser;
        insert evLog;
    }
    

}