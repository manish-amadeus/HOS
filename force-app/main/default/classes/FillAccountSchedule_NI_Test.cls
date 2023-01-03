/****************************************************************************************
Name            : FillAccountSchedule_NI_Test Class
Author          : Sean Harris
Created Date    : 7/25/2013
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class FillAccountSchedule_NI_Test
{

    // TEST METHOD FOR CLASS ===================================================
    public static testmethod void testFake() 
    {
        FillAccountSchedule_NI fas = new FillAccountSchedule_NI();        
        fas.isTest = true;
        fas.execute(null);
    }
    
}