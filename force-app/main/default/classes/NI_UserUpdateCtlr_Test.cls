/****************************************************************************************
Name            : NI_User_UpdateCtlr_Test Class
Author          : Stuart Emery
Created Date    : 2/19/2015
Last Mod Date   : 3/5/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-013129
Description     : Test Class for NI_UserUpdateCtlr Class
                :              
******************************************************************************************/
@isTest(SeeAllData=false)
private class NI_UserUpdateCtlr_Test {
   
    static testMethod void testSuccessfullUpdate() 
    {
        
        //PAGE REFERENCE
        PageReference pageRef = Page.NI_UserFinanceFieldsUpdate;
        Test.setCurrentPage(pageRef);
        
        //CREATE A TEST USER RECORD
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        insert u;

        //CREATE A TEST USER FOR RUN AS
        User u2 = NI_TestClassData.createTestUser(2, 'NI Administrator');
        insert u2;         
        
        //INSTANTIATE CONTROLLER
        NI_UserUpdateCtlr ctrl = new NI_UserUpdateCtlr(new ApexPages.StandardController(u));            
        
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
        ctrl.lstUsers[0].ADP_Record_Number__c = '123';
        
        test.startTest();
        system.runas(u2)
        {
           ctrl.save(); 
        }
        test.stopTest();
        
        //VERIFY THAT THE ADP NUMBER OF THE TEST USER RECORD WAS UPDATED SUCCESSFULLY  
        User updatedUser = [SELECT Id, ADP_Record_Number__c 
                            FROM User
                            WHERE Id =: u.Id];
        System.assertEquals('123', updatedUser.ADP_Record_Number__c);
        
        //VERIFY THAT A USER HISTORY RECORD WAS CREATED
        List<NI_User_History__c> lstInsertedUserHistory = [SELECT Id FROM NI_User_History__c];
        System.assertEquals(1, lstInsertedUserHistory.size());  
    }
    
    static testMethod void testUnSuccessfullUpdate() 
    {
        
        //PAGE REFERENCE
        PageReference pageRef = Page.NI_UserFinanceFieldsUpdate;
        Test.setCurrentPage(pageRef);
        
        //CREATE A TEST USER RECORD
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        insert u;        
        
        //INSTANTIATE CONTROLLER
        NI_UserUpdateCtlr ctrl = new NI_UserUpdateCtlr(new ApexPages.StandardController(u));            
           
        //SET THE strName AND bMissingADP TO TRUE VARIABLES AND CALL THE SEARCH METHOD   
        ctrl.strName = 'NI Administrator';
        ctrl.bMissingADP = true;
        ctrl.search();
        ctrl.lstUsers[0].ADP_Record_Number__c = '12356789999';
        
        try {
        ctrl.save();
         } catch (DMLException e) {
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('ADP Record Number: data value too large') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
         }
        
        //VERIFY THAT THE ADP NUMBER OF THE TEST USER RECORD WAS UPDATED SUCCESSFULLY  
        User updatedUser = [SELECT Id, ADP_Record_Number__c 
                            FROM User
                            WHERE Id =: u.Id];
        System.assertEquals(null, updatedUser.ADP_Record_Number__c);
         
    }


}