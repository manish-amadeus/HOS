@isTest
public class AH_DemoCICDContlr_2_Test {
    // =============================================================================================================
    // 		TEST AH_DemoCICDContlr
    // =============================================================================================================    
    @isTest static void test_testCICD()
    {
        Test.startTest();
            AH_DemoCICDContlr contlr = new AH_DemoCICDContlr();
            contlr.testCICD('cicdtest');
        Test.stopTest();
    }
}