/************************************************************************************************
Name            : FillAccountSchedule_Test Class
Author          : Shashikant Nikam 
Created Date    : 05/03/2019
Last Mod Date   : 05/03/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for FillAccountSchedule
                : 
                : 
*************************************************************************************************/
@isTest
public class FillAccountSchedule_Test 
{

	static testmethod void testSchedulableClass() 
	{
		FillAccountSchedule fas = new FillAccountSchedule(new string[0], 1, '');		
		fas.isTest = true;
		fas.execute(null);
	}
    
}