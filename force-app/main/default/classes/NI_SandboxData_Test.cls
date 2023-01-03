/****************************************************************************************
Name            : NI_SandboxData_Test
Author          : Sean Harris
Created Date    : 5/9/2012
Last Mod Date   : 2/14/2014
Last Mod By     : Sean Harris
NICC Reference  : NICC-007105: Creation of class to populate new dev sandboxes
Description     : Test class for NI_SandboxData  
                : 
******************************************************************************************/
@isTest
public class NI_SandboxData_Test 
{

    static testMethod void test1() 
    {    
        Test.startTest();
        NI_SandboxData s = new NI_SandboxData();
        system.assert(true);
        Test.stopTest();        
    }
    
    /*
    static testMethod void test1() 
    {    
        
        Test.startTest();
        
        // SYNCS PRODUCTS TO PRODUCTION
        NI_SandboxData s = new NI_SandboxData(1);
        
        Test.stopTest();
        
    }
    
    static testMethod void test2() 
    {    
        
        Test.startTest();
        
        // CREATES ACCOUNTS CONTACTS & CASES
        NI_SandboxData s = new NI_SandboxData(2);
        
        Test.stopTest();

    }

    static testMethod void test3() 
    {    
        
        Test.startTest();
        
        // INITIALIZES FFA
        NI_SandboxData.createFFAQueue();
        NI_SandboxData s = new NI_SandboxData(3);
        
        Test.stopTest();
        
    }
    */
}