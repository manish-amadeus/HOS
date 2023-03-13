/************************************************************************************************
Name            : OrgNiCls
Author          : Beth Van Belle
Last Mod Date   : 05/05/2022
Last Mod By     : Beth Van Belle
Description     : Test class to retry insert when rowlock or timeout exception occurs
*************************************************************************************************/

@IsTest
public with sharing class OrgNi_Test {
   
        @IsTest
        public static void testHasNOTRetriableException(){
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
                Exception NItestexception;
                boolean result = true;
                try{
                //OrgSecurityLogCls.EnableSecurityLogCreation = true;        
                insert securityLog;
                }
                catch(System.DMLexception e){
                        NItestexception = e;
                }
                result = OrgNi.hasRetriableError(NItestexception);
                System.assert(!result);

        }   

        @IsTest
        public static void testInsertWithRetry(){
                List<String> ids = new List<String>{'id1','id2'};
                OrgInfo__c info = new OrgInfo__c (
                        
                    );
                    List<OrgInfo__c> listToInsert = new List<OrgInfo__c>();
                    listToInsert.add(info);
        
                    OrgNi.insertWithRetry(listToInsert,2);
                    List<OrgInfo__c> infos = [Select Id, Name from OrgInfo__c];
                    System.assert(infos.size() ==1);

        }   
}