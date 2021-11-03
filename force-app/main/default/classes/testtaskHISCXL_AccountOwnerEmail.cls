@isTest(SeeAllData = true)
private class testtaskHISCXL_AccountOwnerEmail
{
static testMethod void MyUnitTest()    
{
        User u = [SELECT Id FROM User WHERE IsActive = true AND Email != NULL LIMIT 1];

        Account a = new Account(Name = 'Apex Test Account', BillingPostalCode = '03801', 
              BillingCountry = 'US', BillingState = 'NH', BillingStreet = '75 NH Ave', 
              BillingCity = 'Portsmouth', Type = 'Customer', OwnerId = u.Id);        
        insert a;
   
        Task t = new Task(WhatId = a.Id, OwnerId = a.OwnerId, Subject = 'HIS-CXL Inquiry', 
             Status = 'Not Started', Priority = 'Normal');         

        // Get the WhatId of the new Task and assign it to a variable
        String task_whatid = a.Id; 


        // Get the 3 character Prefix for the Account Object
        String account_prefix = Schema.SObjectType.Account.getKeyPrefix();         
         
        try{ 
            insert t;
 
        // Get the Id of the new Task and assign it to a variable
        String task_Id = t.Id;

        // Check to see that the Task was created on the Account Object
        if(task_whatid.startsWith(account_prefix)){

        Account acct = [SELECT id, a.Owner.Email, a.Name 
                FROM Account a WHERE id = :a.Id]; 

        string [] strEmailccAddress = New string[]{'hiscancellation@hisnet.com'};
        String senderDisplayName = 'NI SalesforceAdmin';
        String replyTo = 'NoReply@newmarketinc.com';
        String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + task_Id; 

        }                
                }catch(DMLException e){ 
       system.debug('ERROR Inserting Task:'+e.getDMLMessage(0)); 
  } 
   
   }
  }