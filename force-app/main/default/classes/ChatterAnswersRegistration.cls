/**
 * This class has been generated to allow customization of Account creation for Chatter Answers Portal Users.
 * Chatter Answers requires that this class exist and implement ChatterAnswers.AccountCreator, renaming the class
 *   or removing the interface implementation is prohibited. */
public class ChatterAnswersRegistration implements ChatterAnswers.AccountCreator {
    public String createAccount(String firstname, String lastname, Id siteAdminId) {
       
       //ORIGINAL CHATTERANSWERSREGISTRATION CODE  
       //Account a = new Account(name = firstname + ' ' + lastname, ownerId = siteAdminId);
         
       //NEW CODE ADDED BY STUART EMERY ON 3/8/2014 TO INCORPORATE ACCOUNT CREATION VALIDATION RULES IN THE NEWMARKET ORG  
         Account a = NI_TestClassData.createTestAccount(1);
         a.name = firstname + ' ' + lastname; 
         a.ownerId = siteAdminId;
         insert a;
         return a.Id;
    }
}