/****************************************************************************************
Name            : AH_SalesRegionEditor_Ext_Test Class
Author          : Sean Harris
Created Date    : 03/22/2017
Last Mod Date   : 03/22/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class for AH_SalesRegionEditor_Ext Class
                :              
******************************************************************************************/
@isTest
public class AH_SalesRegionEditor_Ext_Test 
{
   
    static testMethod void testSalesRegionEditorExt1() 
    {
        
        //PAGE REFERENCE
        PageReference pageRef = Page.AH_SalesRegionEditor;
        Test.setCurrentPage(pageRef);
        
        //CREATE A TEST USER RECORD
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        u.ProfileId = '00e30000000qF7tAAE';
        u.FirstName = 'Aname';
        insert u;

        //CREATE A TEST USER FOR RUN AS
        User u2 = NI_TestClassData.createTestUser(2, 'NI Administrator');
        insert u2;         

        //INSTANTIATE CONTROLLER
        AH_SalesRegionEditor_Ext ctrl = new AH_SalesRegionEditor_Ext(new ApexPages.StandardController(u));            
        
        ctrl.getUsers();
        ctrl.disableListEdit();
        
        ctrl.EnableListEdit();
        ctrl.save();
        ctrl.search();
        
        //SET THE bMissingADP VARIABLE TO TRUE AND CALL THE SEARCH METHOD  
        ctrl.bMissingADP = true;
        ctrl.search();
        
        //SET THE strName AND bMissingADP TO FALSE VARIABLES AND CALL THE SEARCH METHOD   
        ctrl.strName = 'NI Administrator';
        ctrl.bMissingADP = false;
        ctrl.search();
        
        //SET THE strName AND bMissingADP TO TRUE VARIABLES AND CALL THE SEARCH METHOD   
        ctrl.strName = 'NI Administrator';
        ctrl.bMissingADP = true;
        ctrl.search();
        ctrl.EnableListEdit();
        ctrl.lstUsers[0].Sales_Region__c = 'APAC';
        
        test.startTest();
        system.runas(u2)
        {
           ctrl.save(); 
        }
        test.stopTest();
        
        //VERIFY THAT THE ADP NUMBER OF THE TEST USER RECORD WAS UPDATED SUCCESSFULLY  
        User updatedUser = [SELECT Id, Sales_Region__c 
                            FROM User
                            WHERE Id =: u.Id];
        System.assertEquals('APAC', updatedUser.Sales_Region__c);
        
        //VERIFY THAT A USER HISTORY RECORD WAS CREATED
        List<NI_User_History__c> lstInsertedUserHistory = [SELECT Id FROM NI_User_History__c];
        System.assertEquals(1, lstInsertedUserHistory.size());  
    }
    
    static testMethod void testSalesRegionEditorExt2() 
    {
        
        //PAGE REFERENCE
        PageReference pageRef = Page.AH_SalesRegionEditor;
        Test.setCurrentPage(pageRef);
        
        //CREATE A TEST USER RECORD
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        u.ProfileId = '00e30000000qF7tAAE';
        u.FirstName = 'Aname';        
        insert u;        
        
        //INSTANTIATE CONTROLLER
        AH_SalesRegionEditor_Ext ctrl = new AH_SalesRegionEditor_Ext(new ApexPages.StandardController(u));            
        ctrl.getUsers();
        
        //SET THE strName AND bMissingADP TO TRUE VARIABLES AND CALL THE SEARCH METHOD   
        ctrl.strName = 'NI Administrator';
        ctrl.bMissingADP = true;
        ctrl.search();
        ctrl.lstUsers[0].Sales_Region__c = null;
        
        try {
        ctrl.save();
         } catch (DMLException e) {
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Sales Region: data value too large') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
         }
        
        //VERIFY THAT THE ADP NUMBER OF THE TEST USER RECORD WAS UPDATED SUCCESSFULLY  
        User updatedUser = [SELECT Id, Sales_Region__c 
                            FROM User
                            WHERE Id =: u.Id];
        System.assertEquals(null, updatedUser.Sales_Region__c);
         
    }


}