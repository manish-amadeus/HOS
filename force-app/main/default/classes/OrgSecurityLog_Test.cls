/************************************************************************************************
Name            : OrgSecurityLog_Test
Author          : Beth Van Belle
Last Mod Date   : 05/05/2022
Last Mod By     : Beth Van Belle
Description     : Test Class to create security logs
*************************************************************************************************/

@IsTest
public class OrgSecurityLog_Test{
    @IsTest
    public static void testCreateLog(){
        List<String> ids = new List<String>{'id1','id2'};
        OrgSecurityLog__c securityLog = new OrgSecurityLog__c (
            Source__c = 'ASEM Polling',
            EventType__c = 'Logging Event', // Category of event
            Severity__c = 'Warning', // Security level of event
            Description__c = 'Polling Search Initiated', // High level description
            Details__c = String.format(
                'User ID: {0} ',new List<String>{UserInfo.getUserId()}) + 
                String.format(
                'Org ID: {0}', ids)
            );

            OrgSecurityLogCls.EnableSecurityLogCreation = true;        
            insert securityLog;
            OrgSecurityLogCls.EnableSecurityLogCreation = false;
            List<OrgSecurityLog__c> logs = [Select Id, Name, Description__c from OrgSecurityLog__c];
            System.assert(logs.size() ==1);
            System.assert(logs[0].Description__c=='Polling Search Initiated');

    }

    @IsTest
    public static void testCannotCreateLog(){
        List<String> ids = new List<String>{'id1','id2'};
        OrgSecurityLog__c securityLog = new OrgSecurityLog__c (
            Source__c = 'ASEM Polling',
            EventType__c = 'Logging Event', // Category of event
            Severity__c = 'Warning', // Security level of event
            Description__c = 'Polling Search Initiated', // High level description
            Details__c = String.format(
                'User ID: {0} ',new List<String>{UserInfo.getUserId()}) + 
                String.format(
                'Org ID: {0}', ids)
            );
            string error;
            try{
                insert securityLog;
            }
            catch(exception e){
                error = e.getMessage();
            }
            System.assert(error.contains('Security Logs cannot be manually created.'));

            List<OrgSecurityLog__c> logs = [Select Id, Name, Description__c from OrgSecurityLog__c];
            System.assert(logs.size() ==0);

    }

    @IsTest
    public static void testDeleteLog(){
        List<String> ids = new List<String>{'id1','id2'};
        OrgSecurityLog__c securityLog = new OrgSecurityLog__c (
            Source__c = 'ASEM Polling',
            EventType__c = 'Logging Event', // Category of event
            Severity__c = 'Warning', // Security level of event
            Description__c = 'Polling Search Initiated', // High level description
            Details__c = String.format(
                'User ID: {0} ',new List<String>{UserInfo.getUserId()}) + 
                String.format(
                'Org ID: {0}', ids)
            );

            OrgSecurityLogCls.EnableSecurityLogCreation = true;        
            insert securityLog;
            OrgSecurityLogCls.EnableSecurityLogCreation = false;
            
            List<OrgSecurityLog__c> logs = [Select Id, Name, Description__c from OrgSecurityLog__c];
            delete logs[0];

            List<OrgSecurityLog__c> logresults = [Select Id, Name, Description__c from OrgSecurityLog__c];
            System.assert(logresults.size() ==1);
            System.assert(logresults[0].Description__c=='Security Log entry deleted');
    }

    @IsTest
    public static void testUpdateLog(){
        List<String> ids = new List<String>{'id1','id2'};
        OrgSecurityLog__c securityLog = new OrgSecurityLog__c (
            Source__c = 'ASEM Polling',
            EventType__c = 'Logging Event', // Category of event
            Severity__c = 'Warning', // Security level of event
            Description__c = 'Polling Search Initiated', // High level description
            Details__c = String.format(
                'User ID: {0} ',new List<String>{UserInfo.getUserId()}) + 
                String.format(
                'Org ID: {0}', ids)
            );
            OrgSecurityLogCls.EnableSecurityLogCreation = true; 
            insert securityLog;
            securityLog.Description__c = 'Changed description';
            
            String error;
            try{
                update securityLog;
            }  
            catch(exception e){
                error = e.getMessage();
            }
            System.assert(error.contains('Security Logs cannot be updated.'));
     
           
            OrgSecurityLogCls.EnableSecurityLogCreation = false;
 
            List<OrgSecurityLog__c> logs = [Select Id, Name, Description__c from OrgSecurityLog__c];
            System.assert(logs.size() ==1);
            System.assert(logs[0].Description__c=='Polling Search Initiated');
    }
}