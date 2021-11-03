/****************************************************************************************
Name            : AH_SurveyResponseDataTriggerHandlerTest Test Class
Author          : Ria Chawla
Created Date    : 9/7/2017
Last Mod Date   : 1/10/2018
Last Mod By     : Stuart Emery
NICC Reference  : NICC-024092
Description     : test Class for AH_SurveyResponseDataTriggerHandler Class
                : UPDATED 1/10/2018 PER NICC-025511
******************************************************************************************/
@isTest
public class AH_SurveyResponseDataTriggerHandlerTest 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData()
    {
        
        test.startTest();  
        system.debug(' *** AH_SurveyResponseDataTriggerHandlerTest.createTestData() - START ***');
        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(539);
        a.Name = 'APEX TESTER ACCOUNT'; 
        insert a;
        
        // CREATE A TEST CONTACT RECORD
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex' + 1;
        c.LastName = 'Testuseryu' + 1;          
        insert c;
        
        // CREATE A TEST CONTACT RECORD TO BE DELETED
        Contact c2 = NI_TestClassData.createTestContact(2, a.Id);
        c2.FirstName = 'Apex' + 2;
        c2.LastName = 'To Delete' + 2;          
        insert c2;
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SurveyResponseDataTriggerHandlerTest.createTestData');  
        system.debug(' *** AH_SurveyResponseDataTriggerHandlerTest.createTestData() - END ***'); 
        test.stopTest();
        
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD BEFORE INSERT: 
    // ======================================================================================================================================= //
    
    @isTest static void beforeInsertUpdateTestMethod() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_SurveyResponseDataTriggerHandlerTest.beforeInsertUpdateTestMethod() - START ***');
        
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'Apex1'];
        
        Confirmit_Survey_Response_Data__c csrd = new Confirmit_Survey_Response_Data__c();
        csrd.Confirmit_Contact_ID__c = c.Id;
        csrd.NPS__c = 5;
        csrd.OSAT__c = 5;
        csrd.Confirmit_CompositeKey__c = 'abcd';
        insert csrd;
        
        Confirmit_Survey_Response_Data__c insertedCSRD = [SELECT Id, Contact__c FROM Confirmit_Survey_Response_Data__c];
        
        System.assertEquals(c.Id, insertedCSRD.Contact__c);
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SurveyResponseDataTriggerHandlerTest.beforeInsertUpdateTestMethod');        
        system.debug(' *** AH_SurveyResponseDataTriggerHandlerTest.beforeInsertUpdateTestMethod() - END ***'); 
        test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD BEFORE INSERT NO CONTACT RECORD:
    // Tests inserting a Survey Response Data Record where the Confirmit_Contact_ID__c value no longer exists.  The contact record was merged
    // or deleted in Salesforce 
    // ======================================================================================================================================= 
    
    @isTest static void beforeInsertUpdateTestMethodNoContact() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_SurveyResponseDataTriggerHandlerTest.beforeInsertUpdateTestMethodNoContact() - START ***');
        
        //LIST OF SURVEY RESPONSE DATA RECORDS TO INSERT
        List<Confirmit_Survey_Response_Data__c> lstRecordsToInsert = new List<Confirmit_Survey_Response_Data__c>();
        
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'Apex1'];
        
        Confirmit_Survey_Response_Data__c csrd = new Confirmit_Survey_Response_Data__c();
        csrd.Confirmit_Contact_ID__c = c.Id;
        csrd.NPS__c = 5;
        csrd.OSAT__c = 5;
        csrd.Confirmit_CompositeKey__c = 'abcd';
        
        lstRecordsToInsert.add(csrd);        
        
        //SELECT THE CONTACT RECORD THAT WILL BE DELETED
        Contact c2 = [SELECT Id FROM Contact WHERE FirstName = 'Apex2'];
        id cId = c2.Id;
        
        //DELETE THE CONTACT RECORD
        Delete c;
        
        Confirmit_Survey_Response_Data__c csrd2 = new Confirmit_Survey_Response_Data__c();
        csrd2.Confirmit_Contact_ID__c = cId;
        csrd2.NPS__c = 5;
        csrd2.OSAT__c = 5;
        csrd2.Confirmit_CompositeKey__c = 'abcd123';
        
        lstRecordsToInsert.add(csrd2);
        
        insert lstRecordsToInsert;
        
        //GET THE INSERTED RECORDS
        List<Confirmit_Survey_Response_Data__c> lstInsertedCSRD = [SELECT Id, Contact__c FROM Confirmit_Survey_Response_Data__c];
        
        //VERIFY THAT 2 RECORDS WERE SUCCESSFULLY INSERTED
        System.assertEquals(2, lstInsertedCSRD.size());
        
        //GET THE INSERTED RECORDS THAT DO NOT HAVE THE Contact__c FIELD UPDATED
        List<Confirmit_Survey_Response_Data__c> lstInsertedNoContact = [SELECT Id, Contact__c FROM Confirmit_Survey_Response_Data__c
                                                                        WHERE Contact__c = null];
        
        //VERIFY THERE IS 1 RECORD THAT DOES NOT HAVE THE CONTACT FIELD UDPATED
        System.assertEquals(1, lstInsertedNoContact.size());
        
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SurveyResponseDataTriggerHandlerTest.beforeInsertUpdateTestMethodNoContact');        
        system.debug(' *** AH_SurveyResponseDataTriggerHandlerTest.beforeInsertUpdateTestMethodNoContact() - END ***'); 
        test.stopTest();
        
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD: TEST THE calculateNPSandOST METHOD IN THE AH_SurveyResponseDataTriggerHandler APEX CLASS
    // ======================================================================================================================================= //
    
    @isTest static void testCalculateNPSandOST() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_SurveyResponseDataTriggerHandlerTest.testCalculateNPSandOST() - START ***');
        
        List<Confirmit_Survey_Response_Data__c> lstSurveysToInsert = new List<Confirmit_Survey_Response_Data__c>();
        
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'Apex1'];
        
        Confirmit_Survey_Response_Data__c sData1 = new Confirmit_Survey_Response_Data__c();
        sData1.Contact__c = c.Id;
        sData1.NPS__c = 5;
        sData1.OSAT__c = 5;
        sData1.Confirmit_CompositeKey__c = 'abcd';
        lstSurveysToInsert.add(sData1);
        
        Confirmit_Survey_Response_Data__c sData2 = new Confirmit_Survey_Response_Data__c();
        sData2.Contact__c = c.Id;
        sData2.NPS__c = 9;
        sData2.OSAT__c = 10;
        sData2.Confirmit_CompositeKey__c = 'efgh';
        lstSurveysToInsert.add(sData2);
        
        Confirmit_Survey_Response_Data__c sData3 = new Confirmit_Survey_Response_Data__c();
        sData3.Contact__c = c.Id;
        sData3.NPS__c = 10;
        sData3.OSAT__c = 7;
        sData3.Confirmit_CompositeKey__c = 'ijkl';
        lstSurveysToInsert.add(sData3);      
        
        Confirmit_Survey_Response_Data__c sData4 = new Confirmit_Survey_Response_Data__c();
        sData4.Contact__c = c.Id;
        sData4.NPS__c = 4;
        sData4.OSAT__c =10;
        sData4.Confirmit_CompositeKey__c = 'mnop';
        lstSurveysToInsert.add(sData4);
        insert lstSurveysToInsert;
        
        List<Confirmit_Survey_Response_Data__c> lstInsertedSurveys = [SELECT Id, Contact__c FROM Confirmit_Survey_Response_Data__c];
        
        //SET TO HOLD THE CONTACT IDs OF THE INSERTED SURVEY RESPONSE RECORDS
        Set<Id> contactIdSet = new Set<Id>();
        
        //LIST TO HOLD THE SURVEY RESPONSE RECORDS TO PROCESS
//        List<Confirmit_Survey_Response_Data__c> lstRecordsToProcess = new List<Confirmit_Survey_Response_Data__c>();
        
        //LOOP THROUGH RESPONSE DATA RECORDS AND STORE THEIR CONTACTS IN A SET
        for (Confirmit_Survey_Response_Data__c surveyData : lstInsertedSurveys)
        {
            if (surveyData.Contact__c != null)
            {
                contactIdSet.add(surveyData.Contact__c);
//                lstRecordsToProcess.add(surveyData);
            }
        }
        
        AH_SurveyResponseDataTriggerHandler handler = new AH_SurveyResponseDataTriggerHandler();
//		List<Contact> contactsToUpdate = handler.calculateNPSandOST(lstRecordsToProcess, contactIdSet);
        List<Contact> contactsToUpdate = handler.calculateNPSandOST(contactIdSet);
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SurveyResponseDataTriggerHandlerTest.testCalculateNPSandOST');        
        system.debug(' *** AH_SurveyResponseDataTriggerHandlerTest.testCalculateNPSandOST() - END ***'); 
        test.stopTest();
        
    }        
    
}