/****************************************************************************************
Name         : taskHISCXL_AccountOwnerEmail
Author       : Stuart Emery
Created Date : February 12, 2012
Last Modified: February 3, 2013
SF Change Req: NICC-004188
Description  : Send an e-mail to the Account Owner when a Task with the "HIS-CXL Inquiry"               
             : Subject is created on an Account
******************************************************************************************/
trigger taskHISCXL_AccountOwnerEmail on Task (after insert) { 
     //Check to see if there is only one task being entered 
     //Check to see if Task Subject = "HIS-CXL Inquiry"
     //Check to see if the WhatId of the Task != Null  
         if ((trigger.new.size() == 1) && 
        (trigger.new[0].Subject == 'HIS-CXL Inquiry') && (trigger.new[0].WhatId != Null)){

   // Get the 3 character Prefix for the Account Object
        String account_prefix = Schema.SObjectType.Account.getKeyPrefix();

   // Get the WhatId of the new Task and assign it to a variable
        String task_whatid = trigger.new[0].WhatId; 
        
   // Get the Id of the new Task and assign it to a variable
        String task_Id = trigger.new[0].Id;     

   // Check to see that the Task was created on the Account Object
         if(task_whatid.startsWith(account_prefix)){

        Account acct = [SELECT id, a.Owner.Email, a.Name 
           FROM Account a WHERE id = :trigger.new[0].whatid]; 
        
        try{ 
        
        // ADDED BY STUART EMERY ON 2/3/2013 to cc 'hiscancellation@hisnet.com'
        string [] strEmailccAddress = New string[]{'hiscancellation@hisnet.com'};
        String senderDisplayName = 'NI SalesforceAdmin';
        String replyTo = 'NoReply@newmarketinc.com';
        String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + task_Id; 
     
        messaging.Singleemailmessage mail=new messaging.Singleemailmessage(); 
      //Save the Email in Activity History must be set to false when sending mail to Users;
          mail.setSaveAsActivity(false); 
      //Set the Sender Display name; 
          mail.setSenderDisplayName(senderDisplayName); 
      //Set the Reply-To address; 
          mail.setReplyTo(replyTo); 
          mail.setTargetObjectId(acct.Owner.Id);
          mail.setCcAddresses(strEmailccAddress);
          mail.setSubject('HIS-CXL Task: ' + acct.Name);
          mail.setPlainTextBody('A HIS-CXL Task has been created for ' + acct.Name  + '\n\r' +
          'Click the link below to view the Task:' + '\n\r' + fullRecordURL);

        try{ 
            messaging.sendEmail(new messaging.Singleemailmessage[]{mail});}catch(DMLException e){ 
            system.debug('ERROR SENDING FIRST EMAIL:'+e.getDMLMessage(0));}}catch(Exception Ex){trigger.new[0].addError('Errors occured: '+Ex); 
            system.debug(Ex); 
        } 


      } 



} 
}