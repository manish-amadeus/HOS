@isTest
private class TestOppClosedWonVerifyContactRole 
{
static testMethod void testNI_Opportunity_ClosedWon_Verify_ContactRole()   
    {
     /***  NI_Opportunity_TriggerHandler.myUnitTest2 Method replaces this Test Class
        //Create an Account
        Account a = new Account(Name = 'Apex Test Account', BillingPostalCode = '03801', BillingCountry = 'US', BillingState = 'NH', BillingStreet = '75 NH Ave', BillingCity = 'Portsmouth', Type = 'Customer');
        insert a;     

        //Create a Contact     
        Contact c = new Contact(LastName='Smith', AccountId = a.Id, Status__c = 'Active', MailingStreet='75 NH Ave', MailingCity='Portsmouth',MailingState='NH', MailingCountry='US', MailingPostalCode='03801');
        insert c;    
    
        //Create a test opportunity
        Opportunity testOpportunity = new Opportunity(Name='Apex Test Opportunity Name', StageName='Prospecting', Order_Status__c= 'Prospect',Amount=25000);
        testOpportunity.CloseDate = date.today();
        insert testOpportunity;
        
        //Create a Customer Project Contact for the Opportunity
        OpportunityContactRole ocpc = new OpportunityContactRole(OpportunityId=testOpportunity.Id, ContactId=c.Id,
        Role='Customer Project Contact');
        insert ocpc;
        
        //Create a Bill To Contact for the Opportunity
        //OpportunityContactRole obtc = new OpportunityContactRole(OpportunityId=testOpportunity.Id, ContactId=c.Id,
        //Role='Bill To');
        //insert obtc;
        
        //Create a Ship To Contact for the Opportunity
        OpportunityContactRole ostc = new OpportunityContactRole(OpportunityId=testOpportunity.Id, ContactId=c.Id,
        Role='Ship To');
        insert ostc;

        Try
        {        
        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;
        }
        catch(Exception e)
        {
         Boolean expectedExceptionThrown =  e.getMessage().contains('There must be an active Bill To, Ship To and Customer Project Contact') ? true : false;
         System.AssertEquals(expectedExceptionThrown, true);
         }
         
*/          
      }    
   }