@isTest
public class OrgSearchRemote_Test {
  
  @isTest
  public static void testRemoteClasses() {
    OrgSearchRemote.login_element loginElement = new OrgSearchRemote.login_element();
    loginElement.username = 'username';
    loginElement.password = 'password';

    OrgSearchRemote.GetUserInfoResult userInfoResult = new OrgSearchRemote.GetUserInfoResult();
    userInfoResult.accessibilityMode = false;
    userInfoResult.chatterExternal = false;
    userInfoResult.currencySymbol = 'USD';
    userInfoResult.orgAttachmentFileSizeLimit = 1;
    userInfoResult.orgDefaultCurrencyIsoCode = 'USD';
    userInfoResult.orgDefaultCurrencyLocale = 'en-US';
    userInfoResult.orgDisallowHtmlAttachments = false;
    userInfoResult.orgHasPersonAccounts = false;
    userInfoResult.organizationId = '12345';
    userInfoResult.organizationMultiCurrency = false;
    userInfoResult.organizationName = 'name';
    userInfoResult.profileId = '12345';
    userInfoResult.roleId = '12234';
    userInfoResult.sessionSecondsValid = 1;
    userInfoResult.userEmail = 'email@email.com';
    userInfoResult.userId = '123456';
    userInfoResult.userLanguage = 'English';
    userInfoResult.userLocale = 'en-US';
    userInfoResult.userTimeZone = null;
    userInfoResult.userType = 'type';
    userInfoResult.userUiSkin = null;

    OrgSearchRemote.LoginResult loginResult = new OrgSearchRemote.LoginResult();
    loginResult.metadataServerUrl = 'url...';
    loginResult.passwordExpired = false;
    loginResult.sandbox = false;
    loginResult.serverUrl = 'url...';
    loginResult.sessionId = '123456487';
    loginResult.userId = '12345';

    OrgSearchRemote.getUserInfo_element guie = new OrgSearchRemote.getUserInfo_element();

    OrgSearchRemote.getUserInfoResponse_element userResponseElement = new OrgSearchRemote.getUserInfoResponse_element();
    userResponseElement.result = userInfoResult;

    OrgSearchRemote.loginResponse_element loginResponseElement = new OrgSearchRemote.loginResponse_element();
    loginResponseElement.result = loginResult;

    OrgSearchRemote.Soap soap = new OrgSearchRemote.soap();
    soap.clientCert_x = 'cert';
    soap.clientCertName_x = 'certName';
    soap.clientCertPasswd_x = 'password';
    soap.timeout_x = 500;

    Test.startTest();
    system.assertNotEquals(null, loginElement);
    system.assertNotEquals(null, userInfoResult);
    system.assertNotEquals(null, guie);
    system.assertNotEquals(null, userResponseElement);
    system.assertNotEquals(null, loginResponseElement);
    system.assertNotEquals(null, soap);
    Test.stopTest();
  }
}