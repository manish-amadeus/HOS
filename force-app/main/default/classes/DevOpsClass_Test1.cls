/**********************************************************************************************************
Name            : DevOpsClass_Test1 Class
Author          : Sean Harris
Created Date    : 09/21/2022
Last Mod Date   : 09/21/2022
Last Mod By     : Sean Harris
NICC Reference  :
Description     : DEVOPS TEST
***********************************************************************************************************/
@isTest
public class DevOpsClass_Test1 
{

    static testMethod void test1() 
    { 
        string s = DevOpsClass1.testString(); 
        system.assertEquals('Hello World!', s);
    }
    
}
