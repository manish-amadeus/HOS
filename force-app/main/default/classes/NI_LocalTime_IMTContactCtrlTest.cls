/****************************************************************************************
Name            : NI_LocalTime_IMTContactCtrlTest Class
Author          : 
Created Date    : 
Last Mod Date   : 7/29/2019 
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : 
Description     : Test Class for the NI_Partner_Case_ListView Controller
: 
: 
******************************************************************************************/
@isTest(SeeAllData=true)
public class NI_LocalTime_IMTContactCtrlTest {
	public static testmethod void testController() {

        NI_IMT_Contact__c con = new NI_IMT_Contact__c(
          	First_Name__c = 'Migration',
            Last_Name__c = 'Operator',
            Country__c = 'IN',
            City__c = 'LA',
            Email__c = 'test@xyz.com',
            Phone__c = '1212243567',
            Postal_Code__c = '9090',
            Street__c = 'Street 1',
            Title__c = 'Mr'          
        );
        insert con;
        system.assert(con.Id != null);
        
        PageReference pageRef = Page.NI_IMT_Contact_Local_Time;
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(con);
        NI_LocalTime_IMTContactCtrl  lt_x = new NI_LocalTime_IMTContactCtrl(sc);
        
        system.debug('lt_x.ctTime' + lt_x.ctTime);
        system.debug('lt_x' + lt_x);
        System.assert(lt_x.refreshTime() == null);
        //ADDED ON 7/29/2019
        system.assert(lt_x.ctTime == 'Unknown');
    }

}