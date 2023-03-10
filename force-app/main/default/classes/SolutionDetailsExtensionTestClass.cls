@isTest
public class SolutionDetailsExtensionTestClass 
{

    static testMethod void myUnitTest() 
    {

        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
                
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        insert c;
        
        Solution sol = NI_TestClassData.createSolution(1);        
        insert sol;        

        // PAGE REFERENCE
        PageReference pageRef = Page.SolutionDetails;
        Test.setCurrentPage(pageRef);
        
        // ADD URL PARAMS
        pageRef.getParameters().put('caseid', c.Id);
        
        // CONTROLLER 
        SolutionDetailsExtension ctrl = new SolutionDetailsExtension(new ApexPages.StandardController(sol));    

        PageReference ePR = ctrl.editSol(); 
        
        sol.SolutionNote = 'RESOLUTION #1: Do Nothing. \n\n\n';
        sol.SolutionNote += 'RESOLUTION #2: Call your Mom. \n\n\n';
        sol.SolutionNote += 'RESOLUTION #3: Call the Police. \n\n\n'; 
		update sol; 
        
        ctrl.getResolutions();

        // TEST NAVICATION BUTTONS		 
        PageReference pr3 = ctrl.moveNext();
		PageReference pr2 = ctrl.movePrev();		 
		PageReference pr4 = ctrl.moveLast(); 
        PageReference pr1 = ctrl.moveFirst();

		Integer i1 = ctrl.getCurrentReso(); 
		Integer i2 = ctrl.getTotalResos(); 
		Boolean b1 = ctrl.getDisablePrevious(); 
    	Boolean b2 = ctrl.getDisableNext(); 

        ctrl.attachCase();
        
    }

}