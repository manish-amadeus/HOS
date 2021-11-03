@isTest
public class NI_IMT_TestAutomationRunCtrlTest {
    public static testmethod void testConfigurationController() {
        NI_IMT_TestAutomationRunController controller = new NI_IMT_TestAutomationRunController();
        //controller.myWrapperList();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NI_IMT_TestAutomationRunCtrlMock());
        controller.test();
        Test.stopTest();
        
    }
}