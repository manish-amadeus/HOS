/****************************************************************************************
Name            : AH_CostControlUpdate_Ext_Test Class 
Author          : Cybage
Created Date    : 08/17/2017
Last Mod Date   : 07/02/2019
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : NICC-023466
Description     : Test Class for AH_CostControlUpdate_Ext
				: 
				: 
******************************************************************************************/
@isTest
public class AH_CostControlUpdate_Ext_Test 
{
    
    static testMethod void testMethodPass() 
    {     
        
        c2g__codaDimension2__c dim2 = new c2g__codaDimension2__c(Name = 'AIP', c2g__ReportingCode__c = 'Test code');
        insert dim2;
        
        c2g__codaDimension2__c dim12 = new c2g__codaDimension2__c(Name = 'Amadeus', c2g__ReportingCode__c = 'Test code1');
        insert dim12;

        c2g__codaDimension3__c dim3 = new c2g__codaDimension3__c(Name = '000 - BALANCE SHEET', c2g__ReportingCode__c = 'Test code');
        insert dim3;
        
        c2g__codaDimension3__c dim13 = new c2g__codaDimension3__c(Name = '100 - FINANCE - ACCOUNTING', c2g__ReportingCode__c = 'Test code1');
        insert dim13;
    
        Id rtId = Schema.SObjectType.c2g__codaCompany__c.getRecordTypeInfosByName().get('SUT').getRecordTypeId();
        
        c2g__codaCompany__c com = new c2g__codaCompany__c(RecordTypeID = rtId, Name='Newmarket AP', c2g__SalesTaxCompanyCode__c = 'Test Tax1');
        insert com;   
                                                             
        c2g__codaCompany__c com1 = new c2g__codaCompany__c(RecordTypeID = rtId, Name='Newmarket US', c2g__SalesTaxCompanyCode__c = 'Test Tax1');
        insert com1;		

        Amadeus_Mapping_Table__c amd = new Amadeus_Mapping_Table__c(FFA_Company__c = com.Id, Cost_Center_Dim_3__c = dim3.Id, Business_Line_Dim_2__c = dim2.Id,Output__c = '12345', Mapping_Type__c = 'BPC COST CENTER');
        insert amd;

        Amadeus_Mapping_Table__c amd1 = new Amadeus_Mapping_Table__c(FFA_Company__c = com1.Id, Cost_Center_Dim_3__c=dim13.Id,Business_Line_Dim_2__c =dim12.Id,Output__c=null,Mapping_Type__c='BPC COST CENTER');
        insert amd1;
        
        // CREATE TEST USER RECORDS 
        User u1 = NI_TestClassData.createTestUser(1, 'NI Administrator');
        u1.FFA_Company__c = 'Newmarket AP';
        u1.FFA_Dimension_3__c = '000 - BALANCE SHEET';
        u1.FFA_Dimension_2__c = 'AIP';        
        u1.Cost_Ctr__c = '12345';        
        insert u1;
        
        User u2 = NI_TestClassData.createTestUser(2, 'NI Administrator');
        u2.FirstName = 'Dummy';
        u2.FFA_Company__c = 'Newmarket US';
        u2.FFA_Dimension_3__c = '190 - FINANCE - CONTROLLING';
        u2.FFA_Dimension_2__c = 'Amadeus';             
        insert u2;

/*        
        u1.FFA_Company__c = 'Newmarket AP';
        u1.FFA_Dimension_3__c = '000 - BALANCE SHEET';
        u1.FFA_Dimension_2__c = 'AIP';        
        u1.Cost_Ctr__c = '12345';
        update u1;   
        
        u2.FirstName = 'Dummy';
        u2.FFA_Company__c = 'Newmarket US';
        u2.FFA_Dimension_3__c = '190 - FINANCE - CONTROLLING';
        u2.FFA_Dimension_2__c = 'Amadeus';     
        update u2;  
*/        
        
        Test.startTest();
        {
            
            u1.Controlling_Verified__c = true;
            update u1; 

            List<User> lstUsers = [SELECT Id, Name, Email, Controlling_Verified__c FROM User]; 

            ApexPages.StandardController scontroller = new ApexPages.StandardController(u1);
            AH_CostControlUpdate_Ext cstController = new AH_CostControlUpdate_Ext(scontroller);           

            cstController.doSave();
            cstController.getDisablePrevious();
            cstController.getDisableNext();
            cstController.Next();
            cstController.Previous();
            
            system.assertNotEquals(1, lstUsers.size());
            
        }
        
        Test.stopTest();
        
    }   	
    
    static testMethod void testMethodFail() 
    {        
        
        // CREATE A TEST USER RECORD
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        insert u;
        
        Test.startTest();
        {  
            
            List<User> lstUsers = [SELECT Id, Name, Email, Controlling_Verified__c FROM User ];
            system.debug(lstUsers);                
            
            ApexPages.StandardController scontroller = new ApexPages.StandardController(u);
            AH_CostControlUpdate_Ext cstController = new AH_CostControlUpdate_Ext(scontroller);

            cstController.usrlst[0].usr.Controlling_Verified__c =NULL;
            cstController.usrlst[0].flag =True;
            cstController.doSave();
            cstController.OffsetSize = 10;
            cstController.getDisablePrevious();
            
            // cstController.OffsetSize = cstController.countTotalRecords+10;     (CAUSES System.UnexpectedException: Maximum SOQL offset allowed is 2000 ERROR)       
            cstController.OffsetSize = (cstController.countTotalRecords / 25) + 25; 
            cstController.getDisableNext();
            cstController.Next();
            cstController.Previous();
            
            system.assertNotEquals(1, lstUsers.size());
            
        }
        
        Test.stopTest();
        
    }         
    
}