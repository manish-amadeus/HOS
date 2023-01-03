/************************************************************************************************
Name            : AH_UpdateUserRecords_Batch Class
Author          : Stuart Emery
Created Date    : 03/22/2019
Last Mod Date   : 04/27/2020 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-039914
Description     : UPDATED 04/27/2020 PER NICC-042785
                : 
*************************************************************************************************/
global class AH_UpdateUserRecords_Batch implements Database.Batchable<sObject> 
{
    
    public List<User> lstUser;
    public String query;
    
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        query = 'SELECT Id, IsActive, UserType, LastLoginDate, Manager.Email ' +  
            'FROM User ' +
            'WHERE IsActive = true';
        
        if (Test.isRunningTest())
        {
            query += ' AND FirstName =  \'Apex CustomLast Login User\'';
            query += ' LIMIT 1';
        }
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<User> scope)
    {
        
        List<User> lstUsersToUpdate = new List<User>();     
        
        system.debug(scope.size());
        
        try
        { 
            for (User u : scope)
            {
                u.Last_Login_Date_Custom__c = u.LastLoginDate;
                system.debug('Manager Email Address: ' + u.Manager.Email);
                u.AH_Manager_Email__c = u.Manager.Email; //ADDED 04/27/2020 PER NICC-042785
                
                lstUsersToUpdate.add(u);
            }        
            
            system.debug('NUMBER OF USERS TO UPDATE: ' + lstUsersToUpdate.size());
            
            if (lstUsersToUpdate.size() > 0)
            {
                database.update(lstUsersToUpdate, false);
            }
            
        }
        catch (Exception e) { system.debug('Error occured while executing a scheduled job... at line number : ' + e.getLineNumber() +' => ' + e);
            // TRACK THIS ERROR IN NI Error Log OBJECT
            NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n','User',  'AH_BatchUpdateUserRecords', 'INSERT');
        }
        
        
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
}