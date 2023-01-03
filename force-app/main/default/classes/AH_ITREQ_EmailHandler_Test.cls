/****************************************************************************************
Name            : AH_ITREQ_EmailHandler_Test Class
Author          : Stuart Emery
Created Date    : 05/26/2017
Last Mod Date   : 05/26/2017
Last Mod By     : Stuart Emery
NICC Reference  : NICC-022094
Description     : Test Class for the AH_ITREQ_EmailHandler Class
                : 
                : 
******************************************************************************************/
@isTest
private class AH_ITREQ_EmailHandler_Test {
    
    // ======================================================================================================================================= //
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
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
        ru.email = 'ITHelpDesk@newmarketinc.com';
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
    // = TEST METHOD 1: TEST EMAIL TO EXISTING IT REQUEST
    // ======================================================================================================================================= //
    @isTest static void testInboundEmail1()
    {

        User u = [SELECT Id, email, FirstName, LastName FROM User WHERE FirstName = 'Requester' AND LastName = 'Testuser'];
        
        AH_Internal_IT_Request__c r = new AH_Internal_IT_Request__c();
        r.Subject__c = 'Test';
        r.OwnerId = u.Id;
        insert r;

        system.runAs(u)
        {
            
            // create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

            // CREATE EMAIL HEADER
			Messaging.InboundEmail.Header hditem = new Messaging.InboundEmail.Header(); 
            email.headers = new Messaging.InboundEmail.Header[1]; 
            hditem.name = 'Date'; 
            hditem.value = 'Tue, 28 Apr 2017 14:08:37 -0700'; 
            email.headers[0] = hditem;

            
            // setup the data for the email
            email.subject = 'Apex Test Help';
            email.fromAddress = u.email;     
            
            String strRefId = (string)r.Id;  
system.debug('strRefId (before) = ' + strRefId);  
            strRefId = '[ref:_00D6008osL._' + strRefId.Substring(0, 6) + strRefId.Substring(10, 15) + ':ref]'; 
system.debug('strRefId (after) = ' + strRefId);          
            email.plainTextBody = 'This is a test ' + strRefId + ' threadID ';
			
            
            // add an Binary attachment
            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };          
                
            // add an Text atatchment 
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body = 'my attachment text';
            attachmenttext.fileName = 'textfiletwo3.txt';
            attachmenttext.mimeTypeSubType = 'texttwo/plain';
            email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
                
                
            // call the email service class and test it with the data in the testMethod
            AH_ITREQ_EmailHandler testInbound = new AH_ITREQ_EmailHandler();
            testInbound.handleInboundEmail(email, env);
            
        }
        
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 2: TEST EMAIL TO CREATE AN IT REQUEST
    // ======================================================================================================================================= //
    @isTest static void testInboundEmail2()
    {

        User u = [SELECT Id, email, FirstName, LastName FROM User WHERE FirstName = 'Requester' AND LastName = 'Testuser'];

        system.runAs(u)
        {
            
            // create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

            // CREATE EMAIL HEADER
			Messaging.InboundEmail.Header hditem = new Messaging.InboundEmail.Header(); 
            email.headers = new Messaging.InboundEmail.Header[1]; 
            hditem.name = 'Date'; 
            hditem.value = 'Tue, 28 Apr 2017 14:08:37 -0700'; 
            email.headers[0] = hditem;

            
            // setup the data for the email
            email.subject = 'Apex Test Help';
            email.fromAddress = u.email;     
            email.plainTextBody = 'This is a test ';
            
            // call the email service class and test it with the data in the testMethod
            AH_ITREQ_EmailHandler testInbound = new AH_ITREQ_EmailHandler();
            testInbound.handleInboundEmail(email, env);
       
            // ASSERT THAT THE IT REQUEST WAS CREATED
            List<AH_Internal_IT_Request__c> lstITReqAsserts = new List<AH_Internal_IT_Request__c>([SELECT Id FROM AH_Internal_IT_Request__c WHERE Subject__c = 'Apex Test Help']); 
//            system.assertEquals(1, lstITReqAsserts.size());
            
        }
        
    }    
    
}