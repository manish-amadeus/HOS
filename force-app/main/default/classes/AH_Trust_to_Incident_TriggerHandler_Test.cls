/**************************************************************************************** 
Name            : AH_Trust_to_Incident_TriggerHandler_Test Class 
Author          : Shashikant Nikam
Created Date    : 01/20/2020
Last Mod Date   : 01/20/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_Trust_to_Incident_TriggerHandler class 
                :  
                :  
******************************************************************************************/

@isTest
public class AH_Trust_to_Incident_TriggerHandler_Test {

    @testSetup
    static void createtestData()
    {
        
        Test.startTest();
        
        // CREATE TEST ACCOUNT 
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'Amadeus Hospitality Business Systems';
        insert a1;
        
        // CREATE TEST CONTACT
        Contact c1 = NI_TestClassData.createTestContact(1, a1.id);
        c1.FirstName = 'Dummy';
        c1.LastName = 'Contact';
        c1.Email = 'abc@test.com';
        insert c1;
        
        // CREATE TEST AH TRUST 
        NI_Trust__c objT1 =  NI_TestClassData.createTestNITrust('Delphi as a Service 1', 1);
        insert objT1;
        NI_Trust__c objT2 =  NI_TestClassData.createTestNITrust('Delphi as a Service 2', 2);
        insert objT2;
        
        // CREATE TEST AH TRUST OUTAGE
        NI_Trust_Outage__c outage = NI_TestClassData.createTestNITrustOutage(objT1.Id, DateTime.Now().addDays(1), DateTime.Now().addDays(1), 1, DateTime.Now().addDays(1).date(), '10:00', DateTime.Now().addDays(1).date(), '18:00');
        outage.Outage_End_Date_Time__c = DateTime.Now().addDays(1).addHours(1+1);
        outage.Outage_Start_Date_Time__c = DateTime.Now().addDays(1).addHours(1);
        outage.Description__c = 'Test Desc - '+1;
        outage.Make_Public__c = true;
        outage.Public_Details__c = 'Test Details - '+1;
        outage.Resolution__c = 'Test Resolution - '+1;
        outage.Type__c = 'Maintenance';
        outage.Severity__c = '1 - Critical';
        outage.Status__c = 'Open Stage 1';
        outage.Send_Notifications__c = TRUE;
        
        Database.Insert(outage);
        
        Test.stopTest();
    }

    // TEST METHOD FOR AFTER INSERT TRIGGER & HANDLER METHODS
    @isTest
	public static void testMethod1(){
        
       // Test.startTest();
        
        NI_Trust__c objT1 = [ SELECT ID, Platform_Name_External__c, Platform_Name_Internal__c FROM NI_Trust__c WHERE Platform_Name_External__c = 'Delphi as a Service 1' ];
        NI_Trust_Outage__c outage = [select ID, External_Platform_Name_HIDDEN__c,Internal_Platform_Name_HIDDEN__c from NI_Trust_Outage__c ];
        
       
        // CREATE AH TRUST TO INCIDENT JUNCTION OBJECT 
        AH_Trust_to_Incident__c juncObj1 = new AH_Trust_to_Incident__c();
        juncObj1.AH_Trust__c = objT1.id;
        juncObj1.AH_Trust_Incident__c = outage.id;
        Database.insert(juncObj1);

        NI_Trust_Outage__c outage1 = [select ID, External_Platform_Name_HIDDEN__c,Internal_Platform_Name_HIDDEN__c from NI_Trust_Outage__c WHERE id =: outage.id];
        
        system.assertEquals( objT1.id+'_'+objT1.Platform_Name_External__c, outage1.External_Platform_Name_HIDDEN__c, 'External platform name on Incident records is not matching...');
        system.assertEquals( objT1.id+'_'+objT1.Platform_Name_Internal__c, outage1.Internal_Platform_Name_HIDDEN__c, 'Internal platform name on Incident records is not matching...');
         
        Test.startTest();
        // UPDATE TRUST RECORD
        NI_Trust__c objT11 = [ SELECT ID, Platform_Name_External__c, Platform_Name_Internal__c FROM NI_Trust__c WHERE id =: objT1.id ];
        objT11.Platform_Name_External__c = 'Delphi as a Service UPDATED';
        Database.update(objT11);
        
        NI_Trust_Outage__c outage11 = [select ID, External_Platform_Name_HIDDEN__c,Internal_Platform_Name_HIDDEN__c from NI_Trust_Outage__c WHERE id =: outage1.id];
        system.debug('outage11 : '+outage11);
        system.debug('objT11.Platform_Name_External__c : '+objT11.id+'_'+objT11.Platform_Name_External__c);
        system.debug('outage11.External_Platform_Name_HIDDEN__c : '+outage11.External_Platform_Name_HIDDEN__c);
        
       // system.assertEquals( objT11.id+'_'+objT11.Platform_Name_External__c, outage11.External_Platform_Name_HIDDEN__c, 'External platform name is not updated on Incident record...');
       // system.assertEquals( objT11.id+'_'+objT11.Platform_Name_Internal__c, outage11.Internal_Platform_Name_HIDDEN__c, 'Internal platform name is not updated on Incident record...');
        
        // query for objT2
        NI_Trust__c objT2 = [ SELECT ID, Platform_Name_External__c, Platform_Name_Internal__c FROM NI_Trust__c WHERE Platform_Name_External__c = 'Delphi as a Service 2' ];
        
        // CREATE ANOTHER JUNCTION OBJECT
        AH_Trust_to_Incident__c juncObj2 = new AH_Trust_to_Incident__c();
        juncObj2.AH_Trust__c = objT2.id;
        juncObj2.AH_Trust_Incident__c = outage.id;
        Database.insert(juncObj2);
        
        
        NI_Trust__c objT12 = [ SELECT ID, Platform_Name_External__c, Platform_Name_Internal__c FROM NI_Trust__c WHERE id =: objT2.id ];
        NI_Trust_Outage__c outage2 = [select ID, External_Platform_Name_HIDDEN__c, Internal_Platform_Name_HIDDEN__c from NI_Trust_Outage__c WHERE id =: outage.id];
        //system.assertEquals( objT11.id+'_'+objT11.Platform_Name_External__c +','+objT12.id+'_'+objT12.Platform_Name_External__c, outage2.External_Platform_Name_HIDDEN__c, 'External platform name is not updated on Incident record...');
        system.assertEquals( objT11.id+'_'+objT11.Platform_Name_Internal__c +','+objT12.id+'_'+objT12.Platform_Name_Internal__c, outage2.Internal_Platform_Name_HIDDEN__c, 'Internal platform name is not updated on Incident record...');

        Test.stopTest();

    }
    
    // TEST METHOD FOR BEFORE & AFTER UPDATE TRIGGER & HANDLER METHODS
    @isTest
	public static void testMethod2(){
        
        Test.startTest();
        
        NI_Trust__c objT1 = [ SELECT ID, Platform_Name_External__c, Platform_Name_Internal__c FROM NI_Trust__c WHERE Platform_Name_External__c = 'Delphi as a Service 1' ];
        NI_Trust_Outage__c outage = [select ID, External_Platform_Name_HIDDEN__c,Internal_Platform_Name_HIDDEN__c from NI_Trust_Outage__c ];
        
        // CREATE AH TRUST TO INCIDENT JUNCTION OBJECT 
        AH_Trust_to_Incident__c juncObj1 = new AH_Trust_to_Incident__c();
        juncObj1.AH_Trust__c = objT1.id;
        juncObj1.AH_Trust_Incident__c = outage.id;
        Database.insert(juncObj1);
        
        NI_Trust_Outage__c outage1 = [select ID, External_Platform_Name_HIDDEN__c,Internal_Platform_Name_HIDDEN__c from NI_Trust_Outage__c WHERE id =: outage.id];
        
        // CREATE TEST AH TRUST 
        NI_Trust__c objT3 =  NI_TestClassData.createTestNITrust('Delphi as a Service 3', 3);
        insert objT3;
        
        // UPDATE AH TRUST TO INCIDENT JUNCTION OBJECT 
        juncObj1.AH_Trust__c = objT3.id;
        Database.update(juncObj1);
        
        NI_Trust_Outage__c outage11 = [select ID, External_Platform_Name_HIDDEN__c, Internal_Platform_Name_HIDDEN__c from NI_Trust_Outage__c WHERE id =: juncObj1.AH_Trust_Incident__c];
        
        NI_Trust__c objT33 = [ SELECT ID, Platform_Name_External__c, Platform_Name_Internal__c FROM NI_Trust__c WHERE id =: objT3.id ];
        system.assertEquals( objT33.id+'_'+objT33.Platform_Name_External__c, outage11.External_Platform_Name_HIDDEN__c, 'External platform name is not updated on Incident record..');
        
        Test.stopTest();
    }
    
    
    // TEST METHOD FOR BEFORE DELETE TRIGGER & HANDLER METHODS
    @isTest
	public static void testMethod3(){
        
        Test.startTest();
        
        NI_Trust__c objT1 = [ SELECT ID, Platform_Name_External__c, Platform_Name_Internal__c FROM NI_Trust__c WHERE Platform_Name_External__c = 'Delphi as a Service 1' ];
        NI_Trust_Outage__c outage = [select ID, External_Platform_Name_HIDDEN__c,Internal_Platform_Name_HIDDEN__c from NI_Trust_Outage__c ];
        system.debug('outageOld : '+outage);
        
        // CREATE AH TRUST TO INCIDENT JUNCTION OBJECT 
        AH_Trust_to_Incident__c juncObj1 = new AH_Trust_to_Incident__c();
        juncObj1.AH_Trust__c = objT1.id;
        juncObj1.AH_Trust_Incident__c = outage.id;
        Database.insert(juncObj1);
        
        Database.delete(juncObj1);
        
        NI_Trust_Outage__c outage1 = [select ID, External_Platform_Name_HIDDEN__c,Internal_Platform_Name_HIDDEN__c from NI_Trust_Outage__c WHERE id =: outage.id];
        system.debug('outage1 : '+outage1);
        system.assertEquals( NULL, outage1.External_Platform_Name_HIDDEN__c, 'External platform name shoulb be deleted..'); 
        
        Test.stopTest();
    }
}