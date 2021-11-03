/*****************************************************************************************************
Name            : AH_Finance_RequestRejectInvocable_Test
Author          : Stuart Emery
Created Date    : 03/24/2020
Last Mod Date   : 03/24/2020 
Last Mod By     : Stuart Emery
Version         : 1.0
Description     : Test Class for the AH_Finance_Request_Reject_Invocable Apex Class 
				: 
******************************************************************************************************/
@isTest
public class AH_Finance_RequestRejectInvocable_Test 
{
    
    // CREATE TEST DATA
    @testSetup static void createTestData()
    {
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.AH_Finance_Request__c; 
        Map<String, Schema.RecordTypeInfo> financeRequestRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        // GET THE ID OF THE SALES CREDIT NOTE REQUEST RECORD TYPE
        Id rtCovid19 = financeRequestRecordTypeInfo.get('COVID-19').getRecordTypeId();
        
        // INSERT TEST FINANCE REQUEST RECORD
        AH_Finance_Request__c fr = new AH_Finance_Request__c();
        fr.RecordTypeId = rtCovid19;
        fr.Approval_Status__c = 'Not Submitted';
        fr.Relief_Request_Type__c = 'Fees Relief Request';
        
        insert fr;
        
    }
    
    // TEST STARTING AND APPROVAL PROCESS AND UPDATING A RECORD
    @isTest static void testRecordInsert()
    {
        
        Test.startTest();
        
        AH_Finance_Request__c fr1 = [SELECT Id FROM AH_Finance_Request__c Limit 1];
        
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(fr1.Id);
        
        // SUBMIT APPROVAL
        Approval.ProcessResult result = Approval.process(app);
        
        // UPDATE FINANCE REQUEST TO INVOKE AUTOMATED REJECTED APPROVAL STATUS
        fr1.Relief_Reject_Reason__c = 'Low Valuation';
        
        update fr1;

        // ASSERT THAT THE APPROVAL STATUS IS APPROVED
        list<ProcessInstance> lstexistingApprovals = [SELECT Id, TargetObjectId
                                                      FROM ProcessInstance 
                                                      WHERE TargetObjectId =: fr1.Id
                                                      AND Status = 'Rejected'];
        
        system.debug('NUMBER OF APPROVALS: ' + lstexistingApprovals.size());
        system.assertEquals(1,lstexistingApprovals.size());
        
        Test.stopTest();
    }
    
}