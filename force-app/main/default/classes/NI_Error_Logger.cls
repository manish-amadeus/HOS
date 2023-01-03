/************************************************************************************************
Name            : NI_Error_Logger Class
Author          : Sean Harris
Created Date    : 04/15/2013
Last Mod Date   : 04/23/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-006961
Description     : Class that contains static method for writing apex and custome errors messages
                : to the custom object NI_Admin_Error_Log__c
                : NICC-025235 - Added WriteToLogwithOrgDetailId() Method
				: NICC-034313 - Added WriteToLogwithOrgDetailId() method back after accidental overwrite
*************************************************************************************************/
public class NI_Error_Logger
{
    
    public static void WriteToLog(string strMessage, string strObjectName, string strClassName, string strDMLType)    
    {    
        
        system.debug(' *** ENTERING NI_Error_Logger.WriteToLog() #1 - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' **** Params: (' + strMessage + '), (' + strObjectName + '), (' + strClassName + '), (' + strDMLType + ')');        
        
        try
        {
            NI_Admin_Error_Log__c e = new NI_Admin_Error_Log__c(
                Message__c = strMessage, 
                Object_Name__c = strObjectName, 
                Apex_Class_Name__c = strClassName, 
                DML_Type__c = strDMLType
            );
            
            insert e;
            
        } 
        catch (Exception ex) 
        {
            system.debug(' **** Error Occured: ' + ex.getMessage());
        }            
        
        system.debug(' *** EXITING NI_Error_Logger.WriteToLog() #1 - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public static void WriteToLog(string strMessage, string strObjectName, string strClassName, string strDMLType, Id UserId, Id RecTypeId)    
    {
        
        system.debug(' *** ENTERING NI_Error_Logger.WriteToLog() #2 - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' **** Params: (' + strMessage + '), (' + strObjectName + '), (' + strClassName + '), (' + strDMLType + '), (' + UserId + '), (' + RecTypeId + ') ');        
        
        try
        {
            
            NI_Admin_Error_Log__c err = new NI_Admin_Error_Log__c();
            
            err.Message__c = strMessage; 
            err.Object_Name__c = strObjectName; 
            err.Apex_Class_Name__c = strClassName;
            err.DML_Type__c = strDMLType;
            err.User__c = UserId; 
            err.RecordTypeId = RecTypeId;
            
            database.insert(err, false);
            
        }
        catch (Exception ex) 
        {
            system.debug(' **** Error Occured: ' + ex.getMessage());
        }                 
        
        system.debug(' *** EXITING NI_Error_Logger.WriteToLog() #2 - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public static void WriteToLogwithOrgDetailId(String orgDetailId, string strMessage, string strObjectName, string strClassName, string strDMLType)
    {
        try
        {
            NI_Admin_Error_Log__c e = new NI_Admin_Error_Log__c(
                Message__c = strMessage, 
                Object_Name__c = strObjectName, 
                Apex_Class_Name__c = strClassName, 
                DML_Type__c = strDMLType,
                NI_Org_Details__c = orgDetailId
            );
            
            insert e;
            
        } 
        catch (Exception ex) 
        {
            system.debug(' **** Error Occured: ' + ex.getMessage());
        } 
        
    }
    
}