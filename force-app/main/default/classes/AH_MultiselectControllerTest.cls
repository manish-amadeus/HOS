/****************************************************************************************
Name            : AH_MultiselectControllerTest Test Class
Author          : Cybage Developer - Shashikant Nikam
Created Date    : 01/15/2018
Last Mod Date   : 04/18/2018
Last Mod By     : Cybage Developer - Ria Chawla
NICC Reference  : NICC-026092
Description     : Test class for AH_MultiselectController aoex class.
                :
*****************************************************************************************/
@isTest
private class AH_MultiselectControllerTest 
{
    
    static testMethod void testMultiselectController() 
    {
        AH_MultiselectController c = new AH_MultiselectController();
        
        c.leftOptions1 = new List<SelectOption>();
        c.rightOptions1 = new List<SelectOption>();

        c.leftOptionsHidden = 'A&a&b&b&C&c';
        c.rightOptionsHidden = '';
        
        system.assertEquals(c.leftOptions1.size(), 3);
        system.assertEquals(c.rightOptions1.size(), 0);
    }
    
}