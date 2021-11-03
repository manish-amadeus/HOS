/****************************************************************************************
Name            : AH_RecordReferenceWorkflow_Batch_Test Class
Author          : Shashikant Nikam
Created Date    : 08/09/2019
Last Mod Date   : 08/12/2019
Last Mod By     : Shashikant Nikam
NICC Reference  :
Description     : Test class for AH_RecordReferenceWorkflow_Batch class
                :
                :
 ******************************************************************************************/
@isTest
public class AH_RecordReferenceWorkflow_Batch_Test
{
	@isTest
	static void testMethod1()
	{
		Test.setMock(HttpCalloutMock.class, new AH_RecordReferenceSearch_Mock());

		Test.startTest();

		PageReference pageRef = Page.AH_RecordReferenceSearch;
		Test.setCurrentPage(pageRef);
		AH_RecordReferenceSearch_Cntlr cntlr = new AH_RecordReferenceSearch_Cntlr();
		cntlr.inputObjName = 'Case';
		cntlr.SearchObject();

		ApexPages.currentPage().getParameters().put('id','Case');
		cntlr.retrieveAllFields();

		system.assertEquals(2, cntlr.fieldsOptionsList.size(), 'Fields count mismatch.');

		cntlr.selectedField = 'Status';
		cntlr.inputKeyword = 'Completed';

		cntlr.searchReferences();

		system.assertEquals(1, cntlr.mapOfValidationRule.size(), 'Validation rule not found.');
		system.assertEquals(15, cntlr.workFlowIdNameList.size(), 'Workflow rules count mismatch.');

		List<String> idList = new List<String>();
		idList.add(cntlr.workFlowIdNameList[0]);

		AH_RecordReferenceWorkflow_Batch btch = new AH_RecordReferenceWorkflow_Batch(idList, cntlr.inputObjName, cntlr.selectedField, cntlr.inputKeyword, cntlr.mapOfValidationRule, cntlr.uniqueString2);
		Database.executeBatch(btch, 1);

		Test.stopTest();
	}
}