/****************************************************************************************
Name            : AH_Agile_NewDirect_Contrl_Test Class
Author          : Bhagwat Garkal
Created Date    : 05/13/2021
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Controller for AH_Agile_NewDirect_Contrl_Test VF Page
				: 
******************************************************************************************/
@isTest
public class AH_Agile_NewDirect_Contrl_Test {

    static testMethod void testMethod1(){
        AH_Agile_NewDirect_Contrl contrl = new AH_Agile_NewDirect_Contrl();
        Test.startTest();
        	contrl.reDirectPage();
        Test.stopTest();
    }
}