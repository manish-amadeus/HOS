@isTest
Private class DI_Management_TriggerHandlerTest {
    
    public static testMethod void testDIRecordUpdate() 
    {
        test.startTest();
        List<NI_DeploymentInstanceIndex__c> lstDI_Indx = new List<NI_DeploymentInstanceIndex__c>(); 
        NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');
        lstDI_Indx.add(diIdx1);
        NI_DeploymentInstanceIndex__c diIdx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST');
        lstDI_Indx.add(diIdx2);
        NI_DeploymentInstanceIndex__c diIdx3 = NI_TestClassData.createDI_Index(3, 'APEX TEST');
        lstDI_Indx.add(diIdx3);
        insert lstDI_Indx;
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        Product2 p2_1 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Support');
        p2_1.DI_Index__c = diIdx2.Id;
        insert p2_1 ;
        DI_Management__c dim = new DI_Management__c ();
        dim.Core_DI_Index__c = diIdx1.id;
        dim.Peripheral_DI_Product__c = p2_1.id;
        dim.Relationship__c = 'Core-Peripheral';
        insert dim;
        DI_Management__c getdim = [SELECT Id,Unique_Record__c,Relationship__c FROM DI_Management__c WHERE id = :dim.Id];
        getdim.Core_DI_Index__c =diIdx3.id;
        update getdim;
        test.stoptest();
        system.assertEquals(getdim.Unique_Record__c, diIdx1.id+''+p2_1.id+''+'Core-Peripheral');
        
    }
}