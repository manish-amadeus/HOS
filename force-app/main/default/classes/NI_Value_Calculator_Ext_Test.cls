/****************************************************************************************
Name            : NI_Value_Calculator_Ext_Test Class
Author          : Sean Harris
Created Date    : 10/03/2014
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-011403 Newmarket Value Calculator 
Description     : 
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_Value_Calculator_Ext_Test
{

    public static testMethod void testTrigHandler() 
    {
        
//      PageReference pageRef = Page.NI_Value_Calculator; 
//        System.assertNotEquals(pageRef, null, 'NI_Value_Calculator page reference is null'); 
//        Test.setCurrentPage(pageRef); 

        NI_Value_Calculator__c NIValCal = new NI_Value_Calculator__c(
        
            Annual_Quota_per_rep__c = 2500000, 
            Average_Booking_Amount_per_rep__c = 25000, 
            Total_amount_of_Competitor_solution__c = 20000, 
            Total_amount_of_Newmarket_solution__c = 30000, 
            
            Average_of_events_per_booking__c = 8, 
            Average_of_Bookings_per_rep__c = 40, 
            Guest_Rooms__c = 400, 
            Meeting_Space__c = 30000, 
            Number_of_Sales_People__c = 6, 
            Percent_Increase_in_booking_size__c = 28, 
            Percent_Increase_in_Win_Rate__c = 25, 
    
            Co_Prop_Ven_Name__c = 'Test Property Name'         
        
        );
        
        ApexPages.StandardController sc = new ApexPages.StandardController(NIValCal);
        NI_Value_Calculator_Ext ext = new NI_Value_Calculator_Ext(sc);
        System.assertNotEquals(ext, null, 'NI_Value_Calculator_Ext controller was not created'); 
        
        PageReference pageRef = Page.NI_Value_Calculator;
//        pageRef.getParameters().put('id', String.valueOf(testAccountPlanInsert.Id));
        Test.setCurrentPage(pageRef);
        ext.Save(); 
        

        
//        Apexpages.StandardController xxx = new NI_Value_Calculator__c(); 
//        NI_Value_Calculator__c nivc = new NI_Value_Calculator__c(); 
//        NI_Value_Calculator_Ext nivce = new NI_Value_Calculator_Ext(); 
//        System.assertNotEquals(controller, null, 'NI_Value_Calculator_Ext controller was not created'); 
//        controller.Save(); 
        
    }    

}