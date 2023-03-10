/****************************************************************************************
Name            : ParentSolutionController_Test 
Author          : Sean Harris
Created Date    : 04/25/2017
Last Mod Date   : 04/25/2017 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Tests Extension Controller for the VisualForce page called ParentSolution
                :
****************************************************************************************/
@isTest
public class ParentSolutionController_Test 
{
	
	static testMethod void testParentSolutionController()
    {
		ParentSolutionController psc = new ParentSolutionController();
		psc.case();
	}

}