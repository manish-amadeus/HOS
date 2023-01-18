/**********************************************************
*************************************
Name :   SLTC_Global_Constatnt_Test
Author : Jaswanth R
Created Date : 6/12/2022
Last Mod Date :  6/12/2022
Last Mod By : Jaswanth R
NICC Reference : 
Description :Test class for SLTC_Global_Constant
***********************************************************
*************************************/
@isTest
public class SLTC_Global_Constant_Test {
    @isTest
    private static void globalConstantTest(){
        new SLTC_Global_Constant();
        System.assertEquals('Renewal', SLTC_Global_Constant.RENEWAL);
    }
    
}