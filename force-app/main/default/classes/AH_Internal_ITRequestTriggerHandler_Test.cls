/****************************************************************************************
Name            : AH_Internal_ITRequestTriggerHandler_Test Test Class
Author          : Stuart Emery
Created Date    : 5/23/2017
Last Mod Date   : 5/26/2017
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : test Class for AH_Internal_IT_Request_Trigger_Handler Class
                : 
******************************************************************************************/
@isTest
private class AH_Internal_ITRequestTriggerHandler_Test {
    
    // ======================================================================================================================================= //
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        test.startTest();  
        system.debug(' *** AH_Internal_ITRequestTriggerHandler_Test.createTestData() - START ***'); 
        
        // CREATE A TEST USER TO USE AS THE REQUESTER
        User ru = NI_TestClassData.createTestUser(1, 'NI Administrator');
        ru.FirstName = 'Requester';
        ru.LastName = 'Testuser';
        insert ru;
        
         // CREATE A TEST USER TO USE AS THE REQUESTER
        User ru2 = NI_TestClassData.createTestUser(2, 'NI Administrator');
        ru2.FirstName = 'Requester2';
        ru2.LastName = 'Testuser';
        insert ru2;
        
        // CREATE A TEST USER TO USE AS THE OWNER
        User owner = NI_TestClassData.createTestUser(3, 'NI Administrator');
        owner.FirstName = 'Owner';
        owner.LastName = 'Testuser';
        insert owner; 
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_Internal_ITRequestTriggerHandler_Test.createTestData');  
        system.debug(' *** AH_Internal_ITRequestTriggerHandler_Test.createTestData() - END ***'); 
        test.stopTest();  
        
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 1: Insert Record
    // ======================================================================================================================================= //
    @isTest static void ITRequestTest1() 
    {    
        
        test.startTest();  
        system.debug(' *** AH_Internal_ITRequestTriggerHandler_Test.ITRequestTest1() - START ***'); 
        
        User requester = [SELECT Id FROM User WHERE FirstName = 'Requester' AND LastName = 'Testuser'];
        
        
        
        
        system.runAs(requester)        
        {
            AH_Internal_IT_Request__c r = new AH_Internal_IT_Request__c();
            r.Subject__c = 'Test';
            Insert r;
        }    
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_Internal_ITRequestTriggerHandler_Test.ITRequestTest1');        
        system.debug(' *** AH_Internal_ITRequestTriggerHandler_Test.ITRequestTest1() - END ***'); 
        test.stopTest();  
        
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 2: Change Owner
    // ======================================================================================================================================= //
    @isTest static void ITRequestTest2()     
    {   
        
        test.startTest();  
        system.debug(' *** AH_Internal_ITRequestTriggerHandler_Test.ITRequestTest2() - START ***');     
        
        User requester = [SELECT Id FROM User WHERE FirstName = 'Requester' AND LastName = 'Testuser'];
        User requester2 = [SELECT Id FROM User WHERE FirstName = 'Requester2' AND LastName = 'Testuser'];
        User owner = [SELECT Id FROM User WHERE FirstName = 'Owner' AND LastName = 'Testuser'];
        
        //CREATE A TEST QUEUE TO USE AS THE RECORD OWNER
        Group grp = NI_TestClassData.createGroup('PUBLIC TEST GRP 1', 'PUBLICTESTGRP1', 'Queue'); 
        insert grp;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = grp.id, SObjectType = 'AH_Internal_IT_Request__c');
            insert testQueue;
        }
        
        system.runAs(requester)        
        {
            AH_Internal_IT_Request__c r = new AH_Internal_IT_Request__c();
            r.Subject__c = 'Test';
            Insert r;
        }    
        
        //GET THE INSERTED REQUEST
        AH_Internal_IT_Request__c reqInserted = [SELECT Id FROM AH_Internal_IT_Request__c];
        
        
        //UPDATE THE OWNER OF THE IT REQUEST TO A QUEUE TO TEST THE REQUESTER SHARE APEX SHARING METHOD
        reqInserted.OwnerId = grp.Id;
        Update reqInserted;
        
        
        List<AH_Internal_IT_Request__Share> lstRequesterShare = new List<AH_Internal_IT_Request__Share>([SELECT Id,ParentId,UserOrGroupId,AccessLevel,RowCause
                                                                                                         FROM AH_Internal_IT_Request__Share 
                                                                                                         WHERE ParentId =: reqInserted.Id
                                                                                                         AND UserOrGroupId =:requester.Id 
                                                                                                         AND AccessLevel = 'Read'
                                                                                                         AND RowCause = 'Requester_Share__c']);
        system.assertEquals(1, lstRequesterShare.size(), 'Number of Requester Shares should be 1.');
/*****************************************************************************************************************************************************************
       Tests The "Change_Requester_Share" Method in The AH_Internal_IT_Request_Trigger_Handler Apex Class
******************************************************************************************************************************************************************/
        //UPDATE THE OWNER OF THE IT REQUEST TO A NEW USER TO TEST THE REQUESTER SHARE APEX SHARING METHOD
        reqInserted.Requester__c = requester2 .Id;
        Update reqInserted;
        
        //SEARCH FOR RECORD SHARES FOR THE ORIGINAL REQUESTER
        List<AH_Internal_IT_Request__Share> lstRequesterShareRemove = new List<AH_Internal_IT_Request__Share>([SELECT Id,ParentId,UserOrGroupId,AccessLevel,RowCause
                                                                                                         FROM AH_Internal_IT_Request__Share 
                                                                                                         WHERE ParentId =: reqInserted.Id
                                                                                                         AND UserOrGroupId =:requester.Id 
                                                                                                         AND AccessLevel = 'Read'
                                                                                                         AND RowCause = 'Requester_Share__c']);
        
        //VERIFY NO RECORD SHARES EXIST FOR THE ORGINAL REQUESTER
        system.assertEquals(0, lstRequesterShareRemove.size(), 'Number of Requester Shares for old Requester should be 0.');
        
        
        //SEARCH FOR RECORD SHARES FOR THE NEW REQUESTER
        List<AH_Internal_IT_Request__Share> lstRequesterShareAdd = new List<AH_Internal_IT_Request__Share>([SELECT Id,ParentId,UserOrGroupId,AccessLevel,RowCause
                                                                                                         FROM AH_Internal_IT_Request__Share 
                                                                                                         WHERE ParentId =: reqInserted.Id
                                                                                                         AND UserOrGroupId =:requester2.Id 
                                                                                                         AND AccessLevel = 'Read'
                                                                                                         AND RowCause = 'Requester_Share__c']);
        
        //VERIFY 1 RECORD SHARE EXIST FOR THE NEW REQUESTER
        system.assertEquals(1, lstRequesterShareAdd.size(), 'Number of Requester Shares for new Requester should be 1.');
        
        system.debug('  >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_Internal_ITRequestTriggerHandler_Test.ITRequestTest2');   
        system.debug(' *** AH_Internal_ITRequestTriggerHandler_Test.ITRequestTest2() - END ***');         
        test.stopTest();  
        
    }
    
    
}