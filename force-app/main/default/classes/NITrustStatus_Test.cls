/**************************************************************************************** 
Name            : NITrustStatus_Test Class 
Author          : Sean Harris
Created Date    : 05/07/2013
Last Mod Date   : 05/27/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-007128
Description     :  
                :  
                :  
******************************************************************************************/
@isTest //(SeeAllData=true) 
public class NITrustStatus_Test
{

    @testSetup 
    static void createTestData()
    {
        
        //CREATE TEST ACCOUNT 
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'Amadeus Hospitality Business Systems';
        insert a1;
        
        //CREATE TEST CONTACT
        Contact c1 = NI_TestClassData.createTestContact(1, a1.id);
        c1.FirstName = 'Dummy';
        c1.LastName = 'Contact';
        c1.Email = 'abc@test.com';
        insert c1;
        
        NI_Trust__c trust = new NI_Trust__c();
        
        NI_Trust__c objT1 =  NI_TestClassData.createTestNITrust('Delphi as a Service (DaaS)', 1);
        insert objT1;
        NI_Trust__c objT2 =  NI_TestClassData.createTestNITrust('Delphi as a Service (DaaS) 2', 2);
        insert objT2;               
        
    }
    
    // ======================================================================================================================
    // 		TEST METHODS
    // ======================================================================================================================
 
    public static testMethod void testMethod1() 
    {
 
        NI_Trust__c trust = new NI_Trust__c(); 
 
        NI_Trust__c objT1 = [SELECT ID, Platform_Name_External__c 
                             FROM NI_Trust__c 
                             WHERE Platform_Name_External__c = 'Delphi as a Service (DaaS)' 
                             LIMIT 1];
        
        NI_Trust__c objT2 = [SELECT ID, Platform_Name_External__c 
                             FROM NI_Trust__c 
                             WHERE Platform_Name_External__c = 'Delphi as a Service (DaaS) 2' 
                             LIMIT 1];
        
        List<NI_Trust_Outage__c> lstOutages = new List<NI_Trust_Outage__c>();
        
        for (Integer i = 0; i < 7; i++)
        {
        	lstOutages.add(NI_TestClassData.createTestNITrustOutage(objT1.Id, DateTime.Now().addDays(-i), DateTime.Now().addDays(-i), 1, DateTime.Now().addDays(-i).date(), '10:00', DateTime.Now().addDays(-i).date(), '18:00'));
        	lstOutages[i].Outage_End_Date_Time__c = DateTime.Now().addDays(-i).addHours(i+1);
        	lstOutages[i].Outage_Start_Date_Time__c = DateTime.Now().addDays(-i).addHours(i);
        	//lstOutages[i].Detected_Date_Time__c = DateTime.Now().addDays(-i).addHours(i+0.5);
        	lstOutages[i].Description__c = 'Test Desc - '+i;
        	lstOutages[i].Make_Public__c = true;
            lstOutages[i].Status__c = 'New';
        	lstOutages[i].Severity__c = '1 - Critical';
        	lstOutages[i].Public_Details__c = 'Test Details - '+i;
        	lstOutages[i].Resolution__c = 'Test Resolution - '+i;
        	lstOutages[i].Type__c = 'Maintenance';
        }        
        lstOutages[2].Type__c = 'Service Disruption';
        lstOutages[4].Type__c = 'Degraded Service';
        lstOutages[5].Type__c = 'Upgrade';
        
        Database.Insert(lstOutages);
        
        // CREATE JUNCTION OBJECT 
        List<AH_Trust_to_Incident__c> junObjList = new List<AH_Trust_to_Incident__c>();
        AH_Trust_to_Incident__c juncObj1 = new AH_Trust_to_Incident__c();
        juncObj1.AH_Trust__c = objT1.id;
        juncObj1.AH_Trust_Incident__c = lstOutages[0].id;
        junObjList.add(juncObj1);
        
        AH_Trust_to_Incident__c juncObj2 = new AH_Trust_to_Incident__c();
        juncObj2.AH_Trust__c = objT1.id;
        juncObj2.AH_Trust_Incident__c = lstOutages[1].id;
        junObjList.add(juncObj2);
        
        AH_Trust_to_Incident__c juncObj3 = new AH_Trust_to_Incident__c();
        juncObj3.AH_Trust__c = objT1.id;
        juncObj3.AH_Trust_Incident__c = lstOutages[2].id;
        junObjList.add(juncObj3);
        
        Database.insert(junObjList);
        
        // check 3 junction records created...
        
        // UPDATE INCIDETNS TO EVALUATE FORMULA FIELD
        List<NI_Trust_Outage__c> outList = new List<NI_Trust_Outage__c>();
        for (Integer i = 0; i < 7; i++)
        {
            NI_Trust_Outage__c outage1 = new NI_Trust_Outage__c(id = lstOutages[i].id );
            outage1.Start_Time_GMT__c = '11:00';
            outage1.End_Time_GMT__c = '16:00';
            outList.add(outage1);
        }
        update outList;
        
        // PAGE REFERENCE
        PageReference pageRef = Page.NITrustStatus;
        Test.setCurrentPage(pageRef);
        
        // CONTROLLER 
        NITrustStatus ctrl = new NITrustStatus(new ApexPages.StandardController(trust));
        
        PageReference pageRef1 = Page.NITrustStatus;
        ApexPages.currentPage().getParameters().put('platformId', objT1.Id);
        Test.setCurrentPage(pageRef1);
                
        ctrl.showPlatformDetails();
        ctrl.nextMonth();
        ctrl.previousMonth();
        ctrl.displayHistory();
        ctrl.platformId = objT1.Id;
        ctrl.todayDate();
        ctrl.changeMonth();
        
        /*ctrl.getPlatforms();
        ctrl.getTrustStatuses();
         
 		ctrl.idOutageId = lstOutages[0].Id;
 		ctrl.findMessage();
 		string m1 = ctrl.getMessage();
 		
 		string c1 = ctrl.colDay1;
 		string c2 = ctrl.colDay2;
 		string c3 = ctrl.colDay3;
 		string c4 = ctrl.colDay4;
 		string c5 = ctrl.colDay5;
 		string c6 = ctrl.colDay6;
 		string c7 = ctrl.colDay7; 		
 		*/
    } 
    
    
    public static testMethod void testMethod2() 
    {
 
        NI_Trust__c trust = new NI_Trust__c(); 
 
        NI_Trust__c objT1 = [SELECT ID, Platform_Name_External__c 
                             FROM NI_Trust__c 
                             WHERE Platform_Name_External__c = 'Delphi as a Service (DaaS)' 
                             LIMIT 1];
        
        NI_Trust__c objT2 = [SELECT ID, Platform_Name_External__c 
                             FROM NI_Trust__c 
                             WHERE Platform_Name_External__c = 'Delphi as a Service (DaaS) 2' 
                             LIMIT 1];             
        
        List<NI_Trust_Outage__c> lstOutages = new List<NI_Trust_Outage__c>();
        
        for (Integer i = 0; i < 7; i++)
        {
        	lstOutages.add(NI_TestClassData.createTestNITrustOutage(objT1.Id, 
                                                                    DateTime.Now().addDays(-i), 
                                                                    DateTime.Now().addDays(i+10), 
                                                                    1, 
                                                                    DateTime.Now().addDays(-i).date(), 
                                                                    '10:00', 
                                                                    DateTime.Now().addDays(i+10).date(), 
                                                                    '18:00'));
        	lstOutages[i].Outage_End_Date_Time__c = DateTime.Now().addDays(i+6).addHours(i+1);
        	lstOutages[i].Outage_Start_Date_Time__c = DateTime.Now().addDays(-i).addHours(i);
        	//lstOutages[i].Detected_Date_Time__c = DateTime.Now().addDays(-i).addHours(i+0.5);
        	lstOutages[i].Description__c = 'Test Desc - '+i;
        	lstOutages[i].Make_Public__c = true;
            lstOutages[i].Status__c = 'New';
        	lstOutages[i].Severity__c = '1 - Critical';
        	lstOutages[i].Public_Details__c = 'Test Details - '+i;
        	lstOutages[i].Resolution__c = 'Test Resolution - '+i;
        	lstOutages[i].Type__c = 'Maintenance';
        }        
        lstOutages[2].Type__c = 'Service Disruption';
        lstOutages[4].Type__c = 'Degraded Service';
        lstOutages[5].Type__c = 'Upgrade';
        
        Database.Insert(lstOutages);
        
        // CREATE JUNCTION OBJECT 
        List<AH_Trust_to_Incident__c> junObjList = new List<AH_Trust_to_Incident__c>();
        AH_Trust_to_Incident__c juncObj1 = new AH_Trust_to_Incident__c();
        juncObj1.AH_Trust__c = objT1.id;
        juncObj1.AH_Trust_Incident__c = lstOutages[0].id;
        junObjList.add(juncObj1);
        
        AH_Trust_to_Incident__c juncObj2 = new AH_Trust_to_Incident__c();
        juncObj2.AH_Trust__c = objT1.id;
        juncObj2.AH_Trust_Incident__c = lstOutages[1].id;
        junObjList.add(juncObj2);
        
        AH_Trust_to_Incident__c juncObj3 = new AH_Trust_to_Incident__c();
        juncObj3.AH_Trust__c = objT1.id;
        juncObj3.AH_Trust_Incident__c = lstOutages[2].id;
        junObjList.add(juncObj3);
        
        Database.insert(junObjList);
        
        // check 3 junction records created...
        
        // UPDATE INCIDETNS TO EVALUATE FORMULA FIELD
        List<NI_Trust_Outage__c> outList = new List<NI_Trust_Outage__c>();
        for (Integer i = 0; i < 7; i++)
        {
            NI_Trust_Outage__c outage1 = new NI_Trust_Outage__c(id = lstOutages[i].id );
            outage1.Start_Time_GMT__c = '11:00';
            outage1.End_Time_GMT__c = '16:00';
            outList.add(outage1);
        }
        update outList;
        
        // PAGE REFERENCE
        PageReference pageRef = Page.NITrustStatus;
        Test.setCurrentPage(pageRef);
        
        // CONTROLLER 
        NITrustStatus ctrl = new NITrustStatus(new ApexPages.StandardController(trust));
        
        //PageReference pageRef1 = Page.NITrustStatus;
        ApexPages.currentPage().getParameters().put('platformId', objT1.Id);
        Test.setCurrentPage(pageRef);
        ctrl.platformId = objT1.Id;
        
        ctrl.showPlatformDetails();

        ApexPages.currentPage().getParameters().put('platformId', objT1.Id);
        ctrl.showPlatformDetails();
        
    } 
 
}