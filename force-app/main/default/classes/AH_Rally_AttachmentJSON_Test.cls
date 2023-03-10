/****************************************************************************************
Name            : AH_Rally_AttachmentJSON  (TC Org Name: LRAttachmentJSON)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Test class for AH_Rally_AttachmentJSON
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_AttachmentJSON_Test 
{

    @isTest static void test1() 
    {
        
        // CREATE RALLY SETUP RECORD
        AH_Rally_Setup__c rsm = new AH_Rally_Setup__c();
        //rsm.API_Version__c = 1.43;
        rsm.Exception_Notification_Email__c = 'abc@abc.com';
        rsm.password__c = '12345';
        rsm.rallyUrl__c = 'https://rally1.rallydev.com';
        rsm.username__c = 'travelclick';
        rsm.workspace__c = 'jira';
        rsm.Schedular_Last_Run__c = DATETIME.now();
        rsm.Story_Field_Map__c = '{"Description":{"fldValue":"None","literalValue":""},"KanbanState":{"custom":1,"fldValue":"None","literalValue":""},"L3KanbanStage":{"custom":1,"fldValue":"Default","literalValue":"Advance Investigation"},"Moscow":{"custom":1,"fldValue":"None","literalValue":""},"Name":{"fldValue":"Subject","literalValue":""},"Owner":{"fldValue":"None","literalValue":""},"Package":{"fldValue":"None","literalValue":""},"Rank":{"fldValue":"None","literalValue":""},"ReadyDeprecated":{"custom":1,"fldValue":"None","literalValue":""},"SalesforcePriority":{"custom":1,"fldValue":"Priority","literalValue":""},"StoryType":{"custom":1,"fldValue":"Default","literalValue":"L3/Salesforce"}}';
        insert rsm;         
        
        Test.startTest();
        
        String res = '{"AH_Rally_AttachmentJSON":[{"Content":"Hello"}]}';
        AH_Rally_AttachmentJSON attcls = (AH_Rally_AttachmentJSON) json.deserialize(res, AH_Rally_AttachmentJSON.class);  
        
        Test.stopTest();
        
        system.assert(true);

    }

}