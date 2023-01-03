/****************************************************************************************
Name            : AH_Rally_FieldMapper_Test (TC Org Name: SFToRallyFieldsTestClass)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Test class for AH_Rally_FieldMapper
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_FieldMapper_Test 
{
    
    @isTest static void SFToRally() 
    {
        // Create Account
        Account acc = NI_TestClassData.createTestAccount(1);
        acc.Name = 'AH_Rally_FieldMapper_Test Account';     
        insert acc;   
        // Create Case
		Case cObj = NI_TestClassData.createTestCase(1, acc.Id);
        cObj.Subject = 'AH_Rally_FieldMapper_Test Case# 1';
        cObj.Competitor_1__c = acc.id;
        cObj.Competitor_2__c = acc.id;
        cObj.Competitor_3__c = acc.id;
        cObj.Competitor_4__c = acc.id;
        cObj.Competitor_5__c = acc.id;
        cObj.Competitor_1_BID__c = '111';
        cObj.Competitor_2_BID__c = '111';
        cObj.Competitor_3_BID__c = '111';
        cObj.Competitor_4_BID__c = '111';
        cObj.Competitor_5_BID__c = '111';
        cObj.Demand_Property_ID__c = '111';
        cObj.Demand_Property_ID_1__c = '111';
        cObj.Demand_Property_ID_2__c = '111';
        cObj.Demand_Property_ID_3__c = '111';
        cObj.Demand_Property_ID_4__c = '111';
        cObj.Demand_Property_ID_5__c = '111';
        cObj.Property_Mapping__c = '111';
        cObj.Property_Mapping_1__c = '111';
        cObj.Property_Mapping_2__c = '111';
        cObj.Property_Mapping_3__c = '111';
        cObj.Property_Mapping_4__c = '111';
        cObj.Property_Mapping_5__c = '111';      
        insert cObj;
        AH_Rally_FieldMapper.oldValuesMap(cObj);
        AH_Rally_FieldMapper.newValuesMap(cObj);
    }
    
}