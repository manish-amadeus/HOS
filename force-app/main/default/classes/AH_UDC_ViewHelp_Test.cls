/***********************************************************************************************
  Name            : AH_UDC_ViewHelp
  Author          : Tushar Gupta
  Created Date    : 14-Apr-2021
  Last Mod Date   : 14-Apr-2021 , 15-June-2021
  Last Mod By     : Tushar Gupta , Ravi Shah
  NICC Reference  : 
  Description     : Test class for AH_UDC_PopOut_Help
 ************************************************************************************************/
@isTest
public class AH_UDC_ViewHelp_Test {

   private static final String TEST_USER_NAME = 'test@user.com';
   private static final String TEST_Workbook_Name = 'Test Workbook 1';

   @TestSetup
   private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      //Create Account record
      Account objAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
      insert objAccount;

      //Create Contact record
      Contact objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert objContact;

      // Get ProfileId to create User WITH chatter
      Profile profileId = [SELECT Id FROM profile WHERE name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER,
                                                                                              AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER)];
      System.assert(profileId != null && profileId.Id != null, 'Profile (' + AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER + ') record not found');

      //Create User record
      User objUser = AH_UDC_TestData.GetUserObject(objContact.Id, profileId.Id, 'Test', 'User', 'Mr.', 'test@user.com', TEST_USER_NAME + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
      insert objUser;

      // Create Property Account object with blank property name to get more code coverage
      AH_UDC_PropertyAccount__c objProperty = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
      insert objProperty;

      //Create NI Doc record
      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
      insert objNIDoc;

      //Insert Contact NI Doc mapping record
      AH_UDC_Contact__c objUDCContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContact.Id, UserInfo.getDefaultCurrency());
      insert objUDCContact;

      //Insert Workbook Record
      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, TEST_Workbook_Name, 'Test Workbook 1 Description', product);
      insert objWorkbook;

      //Insert Workbook Step Record
      AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
      objWorkbookStep.URL__c = 'https://www.lipsum.com/';
      objWorkbookStep.Description__c = 'Test Step 1 Description';
      insert objWorkbookStep;

   }

   @isTest
   private static void AH_UDC_ViewHelp_Test() {
      String userNamePostfix = AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX);
      List<User> lstUser = [SELECT Id
                            FROM User
                            WHERE UserName = :(TEST_USER_NAME + userNamePostfix)];
      System.assert(lstUser.size() > 0, 'User records could not be found.');

      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id, Name, Help__c
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Workbook__r.Name = :TEST_Workbook_Name];
      System.assert(lstWorkbookStep.size() > 0, 'WorkbookStep records could not be found.');

      System.runAs(lstUser[0]) {
         PageReference pageRef = Page.AH_UDC_ViewHelp;
         pageRef.getParameters().put('id', lstWorkbookStep[0].Id);
         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
         System.assertEquals(lstWorkbookStep[0].Name, popout.StepName, 'Workbook Step name could not matched');
         System.assertEquals(lstWorkbookStep[0].Help__c, popout.HelpText, 'Workbook Step help text could not matched');
         Test.stopTest();
      }
   }

   @isTest
   private static void AH_UDC_ViewHelp_Negative_Test1() {
      PageReference pageRef = Page.AH_UDC_ViewHelp;
      pageRef.getParameters().put('id', 'a1029000002aFZ2AAM'); // Input invalid Step id
      pageRef.getParameters().put('Popout', 'false'); // Input community false
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
      System.assert(popout.IsErrorOccurred, 'Error could not occurred');
      Test.stopTest();
   }

   @isTest
   private static void AH_UDC_ViewHelp_Negative_Test2() {
      PageReference pageRef = Page.AH_UDC_ViewHelp;
      pageRef.getParameters().put('Popout', 'true');
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
      System.assert(popout.IsErrorOccurred, 'Error could not occurred');
      Test.stopTest();
   }

   @isTest
   private static void AH_UDC_ViewHelp_Negative_Test3() {
      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id, Name, Help__c
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Workbook__r.Name = :TEST_Workbook_Name];
      System.assert(lstWorkbookStep.size() > 0, 'WorkbookStep records could not be found.');
      PageReference pageRef = Page.AH_UDC_ViewHelp;
      pageRef.getParameters().put('id', lstWorkbookStep[0].Id);
      pageRef.getParameters().put('community', 'false'); // Input community false
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      AH_UDC_ViewHelp popout = new AH_UDC_ViewHelp();
      System.assert(popout.IsErrorOccurred, 'Error could not occurred');
      Test.stopTest();
   }
}