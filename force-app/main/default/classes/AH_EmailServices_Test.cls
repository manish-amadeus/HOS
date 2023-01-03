/****************************************************************************************
Name            : AH_EmailServices_Test
Author          : Sean Harris
Created Date    : 07/08/2021
Modified Date   : 07/08/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for AH_EmailServices_Test
				: 
******************************************************************************************/
@isTest
public class AH_EmailServices_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    { 

        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(184);
        a.Name = 'AH_EmailServices_Test ACCOUNT'; 
        insert a;    
        
        // CREATE TEST CASE RECORD 
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'AH_EmailServices_Test CASE';
        insert c;
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: Test using Account
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {    
        
        Account a = [SELECT Id FROM Account WHERE Name = 'AH_EmailServices_Test ACCOUNT'];
        
        // CREATE EMAIL MESSAGE
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail em = new Messaging.InboundEmail();

        em.subject = 'AH_EmailServices_Test';
        em.plainTextBody = 'AH_EmailServices_Test [ref:_' + a.Id + '_:ref] ';
        em.htmlBody = '<html><head></head><body><h1>AH_EmailServices_Test</h1><br/>[ref:_' + a.Id + '_:ref]<br/></body></html>';
        em.fromAddress = 'fromAddress@amadeushospitality.com';
        em.fromName = 'Don Ho'; 
        List<String> lstToAddresses = new List<String>();
        lstToAddresses.add('toAddress@amadeushospitality.com');
        em.toAddresses = lstToAddresses; 

        // CREATE 2 EMAIL ATTACHMENTS
        Messaging.InboundEmail.BinaryAttachment att1 = new Messaging.InboundEmail.BinaryAttachment();
        att1.body = blob.valueOf('AH_EmailServices_Test Email Attachment 1');
        att1.fileName = 'AH_EmailServices_Test1.txt';
        att1.mimeTypeSubType = 'text/plain';
        
        Messaging.InboundEmail.BinaryAttachment att2 = new Messaging.InboundEmail.BinaryAttachment();
        att2.body = blob.valueOf('AH_EmailServices_Test Email Attachment 2');
        att2.fileName = 'AH_EmailServices_Test2.txt';
        att2.mimeTypeSubType = 'text/plain';
        
        em.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { att1, att2 };
       
        // CALL EMAIL SERVICE CLASS
        Test.startTest();
        
        AH_EmailServices cls = new AH_EmailServices();
        cls.handleInboundEmail(em, env);
        
        Test.stopTest();
        
        // DO ASSERTIONS
        List<EmailMessage> lstAsserts1 = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE RelatedToId =: a.Id]);
        system.assertEquals(1, lstAsserts1.size());
        
        List<ContentDocumentLink> lstAsserts2 = new List<ContentDocumentLink>([SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: a.Id]);
        system.assertEquals(2, lstAsserts2.size());
        
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: Test using Case
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {    
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_EmailServices_Test CASE'];

        // CREATE EMAIL MESSAGE WITH REF:_ ID IN BODY
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail em = new Messaging.InboundEmail();
        em.subject = 'AH_EmailServices_Test';
        em.plainTextBody = 'AH_EmailServices_Test [ref:_' + c.Id + '_:ref] ';
        em.htmlBody = '<html><head></head><body><h1>AH_EmailServices_Test</h1><br/>[ref:_' + c.Id + '_:ref]<br/></body></html>';
        em.fromAddress = 'fromAddress@amadeushospitality.com';
        em.fromName = 'Yuri Ho'; 
        List<String> lstToAddresses = new List<String>();
        lstToAddresses.add('toAddress@amadeushospitality.com');
        em.toAddresses = lstToAddresses; 
        
        // CREATE 2 EMAIL ATTACHMENTS
        Messaging.InboundEmail.BinaryAttachment att1 = new Messaging.InboundEmail.BinaryAttachment();
        att1.body = blob.valueOf('AH_EmailServices_Test Email Attachment 1');
        att1.fileName = 'AH_EmailServices_Test1.txt';
        att1.mimeTypeSubType = 'text/plain';
        
        Messaging.InboundEmail.BinaryAttachment att2 = new Messaging.InboundEmail.BinaryAttachment();
        att2.body = blob.valueOf('AH_EmailServices_Test Email Attachment 2');
        att2.fileName = 'AH_EmailServices_Test2.txt';
        att2.mimeTypeSubType = 'text/plain';
        
        em.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { att1, att2 };
            
        // CALL EMAIL SERVICE CLASS
        Test.startTest();
        
        AH_EmailServices cls = new AH_EmailServices();
        cls.handleInboundEmail(em, env);
        
        Test.stopTest();
        
        // DO ASSERTIONS
        List<EmailMessage> lstAsserts1 = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE RelatedToId =: c.Id]);
        system.assertEquals(1, lstAsserts1.size());
        
        List<ContentDocumentLink> lstAsserts2 = new List<ContentDocumentLink>([SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: c.Id]);
        system.assertEquals(2, lstAsserts2.size());
        
    }    

    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: OPT OUT/OPT IN FUNCTIONALITY
    // ======================================================================================================================================= 
    @isTest static void test3() 
    { 

        // CREATE EMAIL MESSAGE WITH "OPT OUT" SWITCH
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail em = new Messaging.InboundEmail();
        em.subject = 'opt OUT'; 
        em.plainTextBody = 'AH_EmailServices_Test'; 
        em.htmlBody = '<html><head></head><body><h1>AH_EmailServices_Test</h1><br/></body></html>';
        em.fromAddress = UserInfo.getUserEmail();
        em.fromName = 'Ida Ho'; 
        List<String> lstToAddresses = new List<String>();
        lstToAddresses.add('toAddress@amadeushospitality.com');
        em.toAddresses = lstToAddresses; 

        User usrAssert1 = [SELECT Id, AH_Email_Services_Reply_Opt_Out__c FROM User WHERE Email =: UserInfo.getUserEmail()];
        system.assertEquals(false, usrAssert1.AH_Email_Services_Reply_Opt_Out__c);
        
        // CALL EMAIL SERVICE CLASS
        Test.startTest();
        
        AH_EmailServices cls = new AH_EmailServices();
        cls.handleInboundEmail(em, env);
        
        Test.stopTest();
        
        // DO ASSERTIONS
        User usrAssert2 = [SELECT Id, AH_Email_Services_Reply_Opt_Out__c FROM User WHERE Email =: UserInfo.getUserEmail()];
        system.assertEquals(true, usrAssert2.AH_Email_Services_Reply_Opt_Out__c); 
                

        // CREATE EMAIL MESSAGE WITH "OPT IN" SWITCH
        Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
        Messaging.InboundEmail em2 = new Messaging.InboundEmail();
        em2.subject = 'opt IN'; 
        em2.plainTextBody = 'AH_EmailServices_Test'; 
        em2.htmlBody = '<html><head></head><body><h1>AH_EmailServices_Test</h1><br/></body></html>';
        em2.fromAddress = UserInfo.getUserEmail();
        em2.fromName = 'Ida Ho'; 
        List<String> lstToAddresses2 = new List<String>();
        lstToAddresses2.add('toAddress@amadeushospitality.com');
        em2.toAddresses = lstToAddresses2; 

        // CALL EMAIL SERVICE CLASS
    
        AH_EmailServices cls2 = new AH_EmailServices();
        cls.handleInboundEmail(em2, env2);
 
        // DO ASSERTIONS
        User usrAssert3 = [SELECT Id, AH_Email_Services_Reply_Opt_Out__c FROM User WHERE Email =: UserInfo.getUserEmail()];
        system.assertEquals(false, usrAssert3.AH_Email_Services_Reply_Opt_Out__c); 
                
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 5: REPLY ALERTING
    // ======================================================================================================================================= 
    @isTest static void test5() 
    {    

        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_EmailServices_Test CASE'];

        // CREATE EMAIL MESSAGE WITH REF:_ ID IN BODY
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail em = new Messaging.InboundEmail();
        em.subject = 'RE: AH_EmailServices_Test';
        em.plainTextBody = 'AH_EmailServices_Test [ref:_' + c.Id + '_:ref] ';
        em.htmlBody = '<html><head></head><body><h1>AH_EmailServices_Test</h1><br/>[ref:_' + c.Id + '_:ref]<br/></body></html>';
        em.fromAddress = UserInfo.getUserEmail();
        em.fromName = 'Sum Yung Ho'; 
        List<String> lstToAddresses = new List<String>();
        lstToAddresses.add( UserInfo.getUserEmail() );
        em.toAddresses = lstToAddresses; 

        
        // CALL EMAIL SERVICE CLASS
        Test.startTest();
        
        AH_EmailServices cls = new AH_EmailServices();
        cls.handleInboundEmail(em, env);
        
        Test.stopTest();
        
        // DO ASSERTIONS

        
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 6: Exception Coverage
    // ======================================================================================================================================= 
    @isTest static void test6() 
    {    

        // CREATE EMAIL MESSAGE WITHOUT REF:_ ID TO CAUSE ERROR IN TRY CATCH BLOCK
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail em = new Messaging.InboundEmail();
        em.subject = 'AH_EmailServices_Test'; 
        em.plainTextBody = 'AH_EmailServices_Test'; 
        em.htmlBody = '<html><head></head><body><h1>AH_EmailServices_Test</h1><br/></body></html>';
        em.fromAddress = 'fromAddress@amadeushospitality.com';
        em.fromName = 'Don Ho'; 
        List<String> lstToAddresses = new List<String>();
        lstToAddresses.add('toAddress@amadeushospitality.com');
        em.toAddresses = lstToAddresses; 
        
        // CALL EMAIL SERVICE CLASS
        Test.startTest();
        
        AH_EmailServices cls = new AH_EmailServices();
        cls.handleInboundEmail(em, env);
        
        Test.stopTest();
        
        // DO ASSERTIONS
        List<NI_Admin_Error_Log__c> lstAsserts1 = new List<NI_Admin_Error_Log__c>([SELECT Id FROM NI_Admin_Error_Log__c WHERE Apex_Class_Name__c = 'AH_EmailServices']);
        //system.assertEquals(1, lstAsserts1.size()); 
        
    }
    
}