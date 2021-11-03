@isTest
private class NI_PFyre_AgentEvents_TrigHndlr_Test 
{

    static testMethod void myUnitTest() 
    {

		NI_PFyre_AgentEvents_TriggerHandler handler = new NI_PFyre_AgentEvents_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
        
        List<User> lstUsers = new List<User>();
        
        User u1 = NI_TestClassData.createTestUser(1, 'NI Support CSR'); 
        u1.UserTeam__c = 'SPT US TAC A';
        u1.PrairieFyreUserId__c = 'C1232F9B-986D-4E15-B1A2-3E87F6C3F4D4';
        lstUsers.add(u1); 
               
        Database.insert(lstUsers);

		List<NI_PFyre_AgentEvents__c> lstAEs = new List<NI_PFyre_AgentEvents__c>();

		NI_PFyre_AgentEvents__c p1 = new NI_PFyre_AgentEvents__c(
		ACDCount__c = 25, ACDDuration__c = 25, ACDHoldDuration__c = 25, DNDCount__c = 25, DNDDuration__c = 25, 
		EventType__c = 0, FKAgent__c = 'C1232F9B-986D-4E15-B1A2-3E87F6C3F4D4', FKDayOfWeek__c = 3, 
		FKTimeInterval__c = 32, HoldACDCount__c = 25, HoldNonACDCount__c = 25, HoldOutCount__c = 25, 
		LoginTime__c = System.today(), LogoutTime__c = System.today(), MakeBusyCount__c = 25, 
		MakeBusyDuration__c = 25, MidnightStartDate__c = System.today(), NonACDCount__c = 25, 
		NonACDDuration__c = 25, NonACDHoldDuration__c = 25, OutCount__c = 25, OutDuration__c = 25, OutHoldDuration__c = 25, 
		Position__c = '5654', RequeueCount__c = 25, RingingCount__c = 25, RingingDuration__c = 25, ShiftDuration__c = 25, 
		ShortACD__c = 25, WrapUpDuration__c = 25, Snapshot_Day__c = System.today(), Saleforce_User__c = u1.Id); 

        Map<Id, NI_PFyre_AgentEvents__c> mapOldMap = new Map<Id,NI_PFyre_AgentEvents__c>(
            [SELECT Id, Name FROM NI_PFyre_AgentEvents__c WHERE Id IN :lstAEs]);

        handler.OnBeforeInsert(lstAEs);

        handler.OnBeforeUpdate(lstAEs);

        handler.OnBeforeDelete(lstAEs);

        handler.OnAfterInsert(lstAEs);

        handler.OnAfterUpdate(lstAEs);

        handler.OnAfterUpdate(lstAEs);

        handler.OnAfterDelete(lstAEs);

        handler.OnAfterUndelete(lstAEs);  

    }
    
}