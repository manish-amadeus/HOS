/*************************************************************************************************
Name            : AH_Admin_CodeSearch_Test Test Class
Author          : Sean Harris
Created Date    : 02/03/2012
Last Mod Date   : 02/05/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for AH_Admin_CodeSearch Class
                : 
                : 
*************************************************************************************************/
@isTest
public class AH_Admin_CodeSearch_Test 
{

    static testMethod void AH_AdminCodeSearch1() 
    {
        
        PageReference pageRef = Page.AH_Admin_CodeSearch;
        Test.setCurrentPage(pageRef);
        
        AH_Admin_CodeSearch ctrl = new AH_Admin_CodeSearch(); 
        
        Test.startTest();
        
        ctrl.strKeyword = 'A TEST STRING';
        
        ctrl.bApexClasses = true;
        ctrl.bApexTriggers = false;  
        ctrl.bVFPages = false;  
        ctrl.bVFComponents = false;         
        ctrl.doSearch();
        
        Test.stopTest();
        
        ctrl.bApexClasses = false;
        ctrl.bApexTriggers = true; 
        ctrl.doSearch();
        
        ctrl.bApexTriggers = false;
        ctrl.bVFPages = true; 
        ctrl.doSearch();
        
        ctrl.bVFPages = false;
        ctrl.bVFComponents = true; 
        ctrl.doSearch();        
        
    }
    
}