// DISABLED "IMT" Implementation Tool designed for IHG 
/****************************************************************************************
Name            : IMTLocalTimeCtrl_Test Class
Author          : Damodar Raut
Created Date    : 04/01/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Test class for IMTLocalTimeCtrl
				: 
				: 
******************************************************************************************/
@isTest
public class IMTLocalTimeCtrl_Test 
{
    
    public static testmethod void test1() 
    {
      
        // Create a sample record
        NI_IMT_Property__c rec = new NI_IMT_Property__c();
        rec.Name = 'InterContinental';
        rec.Property_Code__c = 'LATST';
        rec.Street__c = 'Santa Monica Blvd';
        rec.Country__c = 'US';
        rec.State__c = 'CA';
        rec.City__c = 'Los Angeles';
        rec.Phone__c = '+1650 1234 5678';
        insert rec;
        //system.assert(rec.Id != null);
        
        PageReference pageRef = Page.NI_IMT_Property_Local_Time;
        Test.setCurrentPageReference(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.standardController(rec);
        IMTLocalTimeCtrl ctrl = new IMTLocalTimeCtrl(sc);
        ctrl.ctTime = '';
        ctrl.freq = 1.5;
        //System.assert(lt_x.refreshTime() == null);
        //system.assert(lt_x.ctTime != 'Unknown');

    }
    
}