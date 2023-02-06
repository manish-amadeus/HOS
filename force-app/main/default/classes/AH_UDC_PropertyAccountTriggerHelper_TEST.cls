/**
 * Name          : AH_UDC_FormTriggerHelper_Test
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is a tet class for AH_UDC_FormTriggerHelper
 * Dependencies  : AH_UDC_FormTriggerHelper
 **/

@isTest
public class AH_UDC_PropertyAccountTriggerHelper_TEST {

   private static final string UDC_WORKBOOK_ADMIN = 'UDCWorkbookAdmin';

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();

      //Create Workbook Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    UDC_WORKBOOK_ADMIN, null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[0].Id);
      }
   }

   @isTest
   private static void TestCreatePropertyAccount() {
      Test.startTest();

      List<User> lstUsers = [SELECT Id
                             FROM User
                             WHERE Username = :('Test' + UDC_WORKBOOK_ADMIN + '@amadeus.com')
                             AND IsActive = true];
      System.assert(lstUsers.size() > 0, 'UDC Workbook Admin User record not found');

      //Check as UDC System Admin
      System.runAs(lstUsers[0]) {
         AH_UDC_PropertyAccount__c objPropertyAccount = new AH_UDC_PropertyAccount__c(PropertyName__c = 'Test Property Account');
         insert objPropertyAccount;

         List<AH_UDC_PropertyAccount__c> PAs = [select id, PropertyName__c, securitycode__c from AH_UDC_PropertyAccount__c];
         System.assertEquals(PAs.size() == 1, true, 'UDC Property Account does not exist');
         System.assertEquals(String.isEmpty(PAs[0].securitycode__c), false, 'UDC Property Account does not have a security code');

         string originalSecurityCode = PAs[0].securitycode__c;
         PAs[0].PropertyName__c = 'Test Property Account Update';
         update PAs[0];

         PAs = [select id, PropertyName__c, securitycode__c from AH_UDC_PropertyAccount__c];
         System.assertEquals(PAs.size(), 1, 'UDC Property Account does not exist after update');
         System.assertEquals(PAs[0].PropertyName__c, 'Test Property Account Update', 'UDC Property Account name was not updated');
         System.assertEquals(PAs[0].securitycode__c, originalSecurityCode, 'UDC Property Account after update has different security code');
      }

      Test.stopTest();
   }

   @isTest
   private static void TestCreatePropertyAccountException() {
      Test.startTest();

      List<User> lstUsers = [SELECT Id
                             FROM User
                             WHERE Username = :('Test' + UDC_WORKBOOK_ADMIN + '@amadeus.com')
                             AND IsActive = true];
      System.assert(lstUsers.size() > 0, 'UDC Workbook Admin User record not found');

      //Check as UDC System Admin
      System.runAs(lstUsers[0]) {
         AH_UDC_PropertyAccount__c objPropertyAccount = new AH_UDC_PropertyAccount__c(PropertyName__c = 'Test Property Account Exception');

         try
         {
            insert objPropertyAccount;
            System.assert(true, 'An exception should have occurred.');
         }
         catch(Exception exc) {
            List<AH_UDC_PropertyAccount__c> PAs = [select id, securitycode__c from AH_UDC_PropertyAccount__c];
            System.assertEquals(PAs.size(), 0, 'UDC Property Account exists and should not have been created');
         }
      }

      Test.stopTest();
   }
}