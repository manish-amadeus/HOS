/************************************************************************************************
Name            : PartnerRemote Class
Author          : Artem Glynskyi 
Created Date    : 02/01/2013
Last Mod By     : Sean Harris
Last Mod Date   : 07/16/2013
NICC Reference  : NICC-006221 
Description     : 
                : 
                : 
*************************************************************************************************/
@isTest
public class PartnerRemote_Test {
  
  @isTest
  public static void testRemoteClasses() {
    PartnerRemote.login_element loginElement = new PartnerRemote.login_element();
    loginElement.username = 'username';
    loginElement.password = 'password';

    PartnerRemote.GetUserInfoResult userInfoResult = new PartnerRemote.GetUserInfoResult();
    userInfoResult.accessibilityMode = false;
    userInfoResult.currencySymbol = 'USD';
    userInfoResult.orgAttachmentFileSizeLimit = 1;
    userInfoResult.orgDefaultCurrencyIsoCode = 'USD';
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

    PartnerRemote.LoginResult loginResult = new PartnerRemote.LoginResult();
    loginResult.metadataServerUrl = 'url...';
    loginResult.passwordExpired = false;
    loginResult.sandbox = false;
    loginResult.serverUrl = 'url...';
    loginResult.sessionId = '123456487';
    loginResult.userId = '12345';

    PartnerRemote.getUserInfo_element guie = new PartnerRemote.getUserInfo_element();

    PartnerRemote.loginResponse_element loginResponseElement = new PartnerRemote.loginResponse_element();
    loginResponseElement.result = loginResult;

    PartnerRemote.Soap soap = new PartnerRemote.soap();
    soap.clientCert_x = 'cert';
    soap.clientCertName_x = 'certName';
    soap.clientCertPasswd_x = 'password';
    soap.timeout_x = 500;
	Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
    Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl('endPoint'));          

    Test.startTest();
    system.assertNotEquals(null, loginElement);
    system.assertNotEquals(null, userInfoResult);
    system.assertNotEquals(null, guie);
    system.assertNotEquals(null, loginResponseElement);
    system.assertNotEquals(null, soap);
    Test.stopTest();
  }
}