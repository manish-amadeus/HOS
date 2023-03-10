/*
 * File           : AH_UDC_PrefixHelper_TEST.cls
 * Created By     : George Tasker
 * Created Date   : 2019-Nov-20
 * Modified By    : George.Tasker@amadeus.com
 * Description    : Test class for PrefixHelper.cls
 */
@isTest
private class AH_UDC_PrefixHelper_TEST
{
   //@isTest
   //static void testPrefixHelper_Namespace() {
      //String s = '';
      //string s2 = '';

      ////String prefix = AH_UDC_PrefixHelper.getObjPrefix().replace('__','');

      ////s = AH_UDC_PrefixHelper.getRemoteActionPrefix();
      ////System.AssertEquals(s, prefix + (prefix.length() > 0 ? '.' : ''), 'getRemoteActionPrefix does not return the expected value');

      //s = AH_UDC_PrefixHelper.getObjectName('AH_UDC_Workbook__c');
      //System.AssertEquals(s, prefix + (prefix.length() > 0 ? '__' : '') + 'AH_UDC_Workbook__c', 'getObjectName does not return the expected value');

      ////s = AH_UDC_PrefixHelper.getNamespace();
      ////System.AssertEquals(s, prefix, 'getNamespace does not return the expected value');

      //s = AH_UDC_PrefixHelper.getClassName('myClass');
      //System.AssertEquals(s, prefix + (prefix.length() > 0 ? '.' : '') + 'myClass', 'getClassName does not return the expected value');
   //}

   @isTest
   static void testPrefixMgr_Callable()
   {
      Boolean usingManagedPackageCode = false;

      for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values())
      {
         String sobjName = String.valueOf(sObjectType);

         if (sobjName.contains('AHUDC__')) { usingManagedPackageCode = true; }
      }

      Map<string, Object> args = new Map<string, Object> ();
      args.put('mode', 'All');
      Callable extension = (Callable) Type.forName('AH_UDC_PrefixHelper').newInstance();

      Object result;

      //result = extension.call('getObjectPrefix', args);
      //System.assertEquals(usingManagedPackageCode ? 'AHUDC__' : '', (string)result, 'Expected this test to return the Object prefix');

      //result = extension.call('getClassPrefix', args);
      //System.assertEquals(usingManagedPackageCode ? 'AHUDC.' : '', (string)result, 'Expected this test to return the Class prefix');

      //result = extension.call('getFieldPrefix', args);
      //System.assertEquals(usingManagedPackageCode ? 'AHUDC.' : '', (string)result, 'Expected this test to return the Field prefix');

      //result = extension.call('getRemoteActionPrefix', args);
      //System.assertEquals(usingManagedPackageCode ? 'AHUDC.' : '', (string)result, 'Expected this test to return the RemoteAction prefix');

      //result = extension.call('getNamespace', args);
      //System.assertEquals(usingManagedPackageCode ? 'AHUDC' : '', (string)result, 'Expected this test to return the package namespace');

      string baseName = 'BaseName__c';
      args.put('baseName', baseName);
      result = extension.call('getObjectName', args);
      System.assertEquals(usingManagedPackageCode ? 'AHUDC__' + baseName : baseName, (string)result, 'Expected this test to return the Object name');

      result = extension.call('getClassName', args);
      System.assertEquals(usingManagedPackageCode ? 'AHUDC.' + baseName : baseName, (string)result, 'Expected this test to return the Class name');

      result = extension.call('getFieldName', args);
      System.assertEquals(usingManagedPackageCode ? 'AHUDC__' + baseName : baseName, (string)result, 'Expected this test to return the Field name');

      //string restUrl = 'apexrest/Rest_UnitTest';
      //args.put('baseApexRestUrl',restUrl);
      //result = extension.call('getApexRestUrl', args);
      //System.assertEquals(usingManagedPackageCode ? restUrl.replace('apexrest/','apexrest/AHUDC/') : restUrl, (string)result, 'Expected this test to return the URL');

      //string objectName = 'AH_UDC_Workbook__c';
      //args.put('ObjectNameParam',objectName);
      //result = extension.call('objectExists', args);
      //System.assertEquals(true, (Boolean)result, 'Expected this test to return true that the object exists');

      try
      {
         result = extension.call('unknownmethod', args);
         System.assert(false, 'This should have failed, because \'unknownmethod\' is not a callable method');
      }
      catch (Exception exc)
      {
         // this is what should happen
      }

      ////Force namespace to emulate packaged code
      //AH_UDC_PrefixHelper.namespace = 'AHUDC';
      //baseName = 'AH_UDC_Text__c';
      //args.put('baseName', baseName);
      //result = extension.call('getObjectName', args);
      //System.assertEquals(usingManagedPackageCode ? 'AHUDC__' + baseName : baseName, (string)result, 'Expected this test to return the Object name');

      //baseName = 'AH_UDC_Text';
      //args.put('baseName', baseName);
      //result = extension.call('getObjectName', args);
      //System.assertEquals(baseName, (string)result, 'Expected this test to return the name');

      //AH_UDC_PrefixHelper.namespace = 'AHUDC';
      //baseName = 'AH_UDC_Text__c';
      //args.put('baseName', baseName);
      //result = extension.call('getObjectName', args);
      //System.assertEquals(usingManagedPackageCode ? 'AHUDC__' + baseName : baseName, (string)result, 'Expected this test to return the Object name');

      //baseName = 'AH_UDC_Text';
      //args.put('baseName', baseName);
      //result = extension.call('getObjectName', args);
      //System.assertEquals(baseName, (string)result, 'Expected this test to return the name');
   }
}