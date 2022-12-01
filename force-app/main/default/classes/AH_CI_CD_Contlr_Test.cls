@isTest
public class AH_CI_CD_Contlr_Test {
    
    
     // =============================================================================================================
    // 		TEST AH_CI_CD_Contlr_Test
    // =============================================================================================================    
    @isTest static void test_testCICD()
    {
        Test.startTest();
            AH_Demo_CI_CD_Contlr contlr = new AH_Demo_CI_CD_Contlr();
            contlr.testCICD('cicdtest');
        Test.stopTest();
    }
}