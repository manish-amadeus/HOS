/****************************************************************************************
Name            : IT_UserDatabaseHome_Test Class
Author          : Stuart Emery
Created Date    : 4/1/2015
Last Mod Date   : 4/1/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test Class for IT_UserDatabaseHome Class
                :              
******************************************************************************************/
@isTest(SeeAllData=false)
private class IT_UserDatabaseHome_Test {
    
    static testMethod void testSearchMultipleUsers() 
    {
        
        //PAGE REFERENCE
        PageReference pageRef = Page.IT_UserDatabaseHome;
        Test.setCurrentPage(pageRef);
        
        //CREATE 50 TEST USERS
        List<User> lstUsersToInsert = new List<User>();
        for (Integer j=0;j<50;j++) 
        {
            User u = NI_TestClassData.createTestUser(j, 'NI Administrator');
            lstUsersToInsert.add(u);
        }
        Database.insert(lstUsersToInsert);  
        
        //INSTANTIATE CONTROLLER
        IT_UserDatabaseHome ctrl = new IT_UserDatabaseHome();            
        
        ctrl.search();
        ctrl.Beginning();
        ctrl.Previous();
        ctrl.Next();
        //ctrl.End();
        
        //TEST DISABLEPREVIOUS BOOLEAN  
        ctrl.getDisablePrevious();
        
        //TEST DISABLENEXT BOOLEAN  
        ctrl.getDisableNext();
        
        //TEST TOTAL_SIZE  
        ctrl.getTotal_size();
        
        //TEST PAGENUMBER  
        ctrl.getPageNumber();
            
        //SET THE strName VARIABLE AND CALL THE SEARCH METHOD   
        ctrl.strName = 'NI Administrator';
        ctrl.search();
        ctrl.End();
        //TEST TOTALPAGES  
        ctrl.getTotalPages();
    }
    
    
}