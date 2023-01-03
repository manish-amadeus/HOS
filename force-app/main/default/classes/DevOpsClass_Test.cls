/**********************************************************************************************************
Name            : DevOpsClass_Test Class
Author          : Sean Harris
Created Date    : 09/21/2022
Last Mod Date   : 09/21/2022
Last Mod By     : Sean Harris
NICC Reference  :
Description     : DEVOPS TEST
***********************************************************************************************************/
@isTest
public class DevOpsClass_Test 
{

    static testMethod void test1() 
    { 
        string s = DevOpsClass.testString(); 
        system.assertEquals('Hello World! this is retest for the team for deployment with full test with full team', s);
    }
    
}
