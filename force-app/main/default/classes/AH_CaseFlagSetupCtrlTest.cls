/****************************************************************************************
Name            : AH_CaseFlagSetupCtrlTest Test Class
Author          : Cybage Developer - Ria Chawla
Created Date    : 01/15/2018
Last Mod Date   : 02/15/2018
Last Mod By     : Cybage Developer - Ria Chawla
NICC Reference  : NICC-026092
Description     : Test Class for: AH_CaseFlagSetupController
                :
*****************************************************************************************/
@isTest
public class AH_CaseFlagSetupCtrlTest 
{
    @isTest static void setClearFlagsCtrl()
    {
        //GET RECORDTYPEID ON 'CASE' RECORD TYPE
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        //CREATE A NEW DEFAULT RECORD TO STORE CASE RECORD TYPE TO ENABLE CASE FLAGS
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes.Name = 'Default';
        flagRecTypes.Enabled_Case_Type__c = String.valueof(rtCaseId);
        flagRecTypes.Enabled_Activity_Types__c = 'Email,Call';
        flagRecTypes.Clear_Case_Origins__c = 'Phone';
        insert flagRecTypes;
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(caseFlagSetting);
        AH_CaseFlagSetupController setupCtrl = new AH_CaseFlagSetupController(controller);
        setupCtrl.formatSelection = 'test';
        setupCtrl.excludedUsers = new List<User>();
        setupCtrl.doSave();
    }
    
    @isTest static void setClearFlagsCtrl2()
    {
        //GET RECORDTYPEID ON 'CASE' RECORD TYPE
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        //CREATE A NEW DEFAULT RECORD TO STORE CASE RECORD TYPE TO ENABLE CASE FLAGS
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes.Name = 'Default';
        flagRecTypes.Enabled_Case_Type__c = String.valueof(rtCaseId);
        flagRecTypes.Enabled_Activity_Types__c = 'Email,Call';
        flagRecTypes.Clear_Case_Origins__c = 'Phone';
        insert flagRecTypes;
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        AH_CaseFlagPreferences__c caseFlagSetting = new AH_CaseFlagPreferences__c();
        
        ApexPages.StandardController controller = new ApexPages.StandardController(caseFlagSetting);
        
        AH_CaseFlagSetupController setupCtrl = new AH_CaseFlagSetupController(controller);
    }
    
    @isTest
    static void testMultiselect1() 
    {
        // CREATE TEST DATA
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        AH_CaseFlagPreferences__c caseFlagSetting1 = new AH_CaseFlagPreferences__c();
        insert caseFlagSetting1;
        
        ApexPages.StandardController controller1 = new ApexPages.StandardController(caseFlagSetting1);
        AH_CaseFlagSetupController ctrl1 = new AH_CaseFlagSetupController(controller1);
        ctrl1.doSave();
        
        // ctrl1.selectedRecTypes.add(new SelectOption('0126000000011YUAAZ', 'Dummy rec type 1'));
		// ctrl1.selectedRecTypes.add(new SelectOption('0126000000011YUAAX', 'Dummy rec type 2'));
		// System.assertEquals(ctrl1.selectedRecTypes.size(), 2);

    }
}