/***********************************************************************************************
  Name            : AH_UDC_DateFormat_Test
  Author          : Tushar Gupta
  Created Date    : 19-Mar-2021
  Last Mod Date   : 19-Mar-2021
  Last Mod By     : Tushar Gupta
  NICC Reference  : 
  Description     :Test class for Date format based on local
  Change History  :599332 - Workbook due date on Workbook Send screen should format according to Workbook User's locale
 ************************************************************************************************/
@isTest
public class AH_UDC_DateFormat_Test {

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   @isTest
   private static void AH_UDC_DateFormat_Test() {
      Test.startTest();
      //test for English (United States) format
      List<User> userUpdate = new List<User> (); //list for holding user updates
      userUpdate.add(new User(Id = UserInfo.getUserId(), LocaleSidKey = 'en_US')); //set the locale for the running user to English (United States)
      update userUpdate; //make the update
      String test_value = AH_UDC_DateFormat.GetDateFormat();
      System.assertEquals('mm/dd/yy', test_value, 'en_US format could not match'); 

      test_value = '';
      //now test for Arabic (Saudi Arabia) format
      userUpdate.clear(); //remove all user sobjects from the userUpdate List
      userUpdate.add(new User(Id = UserInfo.getUserId(), LocaleSidKey = 'ar_SA')); //set the locale for the running user to Arabic (Saudi Arabia)
      update userUpdate; //make the update
      test_value = AH_UDC_DateFormat.GetDateFormat(); 
      System.assertEquals('dd/mm/yy', test_value,'ar_SA format could not match'); 

      test_value = '';
      //now test for Chinese (Taiwan) format
      userUpdate.clear(); //remove all user sobjects from the userUpdate List
      userUpdate.add(new User(Id = UserInfo.getUserId(), LocaleSidKey = 'zh_TW')); //set the locale for the running user to Chinese (Taiwan)
      update userUpdate; //make the update
      test_value = AH_UDC_DateFormat.GetDateFormat(); 
      System.assertEquals('yy/mm/dd', test_value,'ar_SA format could not match');
      Test.stopTest();
   }
}