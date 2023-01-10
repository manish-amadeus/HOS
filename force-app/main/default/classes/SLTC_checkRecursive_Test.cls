/**********************************************************
*************************************
Name :   SLTC_checkRecursive_Test
Author : Jaswanth R
Created Date : 6/12/22
Last Mod Date :  6/12/2022
Last Mod By : Jaswanth R
NICC Reference : 
Description :Test class for SLTC_checkRecursive Class
***********************************************************
*************************************/
@isTest
public class SLTC_checkRecursive_Test {
    @isTest
    private static void checkRecursiveTest(){
       Boolean isNew = SLTC_checkRecursive.runOnce();
        System.assertEquals(true, isNew == true, 'run is set to be true');
    }
    
}