/*
 * Name           : DescribeCache.cls
 * Created By     : Someone long, long ago
 * Created Date   : 
 * Description    : Code was a copy of DescribeCache.cls from the ASEM (Delphi.fdc)
 * Modified       : 2022-Apr-28 (George Tasker / george.tasker@amadeus.com)
 *                  Code updated to create user-specific caches so that test class methods that
 *                  have multiple RUNAS() statements using different users will have the correct 
 *                  OLS/FLS values returned from the cache
 * Dependencies   : PrefixMgr
 * Test Classes   : DescribeCache_TEST.cls
 */
public with sharing class AH_UDC_DescribeCache {
   private static Map<Id, UserSpecificCache> m_mapUserSpecificCache = new Map<Id, UserSpecificCache>();

   private class UserSpecificCache {
      protected Map<String, Schema.SObjectType> allObjectTokens = null;
      protected Map<String, Schema.DescribeSObjectResult> objectDescribesByName = new Map<String, Schema.DescribeSObjectResult> ();
      protected Map<String, Map<String, Schema.SObjectField>> fieldTokensByObject = new Map<String, Map<String, Schema.SObjectField>> ();
      protected Map<String, List<Schema.ChildRelationship>> childRelDescribesByObject = new Map<String, List<Schema.ChildRelationship>> ();
      protected Map<String, Map<String, Schema.DescribeFieldResult>> fieldDescribesByObjectAndField = New Map<String, Map<String, Schema.DescribeFieldResult>> ();
   }

   //Returns object describe result for specified object type.
   public static Schema.DescribeSObjectResult getObjectDescribe(String objectTypeName) {
      return getObjectDescribe(objectTypeName, true);
   }

   public Static Schema.DescribeSObjectResult getObjectDescribe(String objectTypeName, Boolean shouldThrowException) {

      String lowerObjectTypeName = objectTypeName.toLowerCase();

      //Cached already?
      if (GetUserSpecificCache().objectDescribesByName.containsKey(lowerObjectTypeName)) {
         return GetUserSpecificCache().objectDescribesByName.get(lowerObjectTypeName);
      }

      GetAllObjectTokens();

      if (!GetUserSpecificCache().allObjectTokens.containsKey(lowerObjectTypeName)) {
         if (shouldThrowException) {
            throw new DescribeCacheException('Object type not found: ' + objectTypeName);
         } else {
            return null;
         }
      }

      Schema.DescribeSObjectResult result = GetUserSpecificCache().allObjectTokens.get(lowerObjectTypeName).getDescribe();
      GetUserSpecificCache().objectDescribesByName.put(lowerObjectTypeName, result);

      return result;
   }

   private static void GetAllObjectTokens() {
      // If MAP has already been populated, nothing to do
      if (GetUserSpecificCache().allObjectTokens != null) return;

      Map<String, Schema.SObjectType> globalDescribes = Schema.getGlobalDescribe();
      GetUserSpecificCache().allObjectTokens = new Map<String, Schema.SObjectType> ();

      //JD - Bypass set of namespace prefix when using a standard object in a namespaced environments
      for (String key : globalDescribes.keySet()) {
         //only adding namespaces if the key is custom object.
         if (key.contains('__c') || key.contains('__share')) {
            GetUserSpecificCache().allObjectTokens.put(AH_UDC_PrefixHelper.getObjectName(key).toLowerCase(), globalDescribes.get(key));
         } else {
            GetUserSpecificCache().allObjectTokens.put(key.toLowerCase(), globalDescribes.get(key));
         }
      }
   }

   private static UserSpecificCache GetUserSpecificCache() {
      // If this is the first time this user has tried to get something from the cache, create an empty cache for them
      if (!m_mapUserSpecificCache.containsKey(UserInfo.getUserId())) {
         m_mapUserSpecificCache.put(UserInfo.getUserId(), new UserSpecificCache());
      }

      return m_mapUserSpecificCache.get(UserInfo.getUserId());
   }

   //Returns describe result for specified object field
   public static Schema.DescribeFieldResult getFieldDescribe(String objectTypeName, String casedFieldName) {
      return getFieldDescribe(objectTypeName, casedFieldName, false);
   }

   //Returns describe result for specified object field
   public static Schema.DescribeFieldResult getFieldDescribe(String objectTypeName, String casedFieldName, Boolean checkReadAccess) {

      String fieldName = casedFieldName.toLowerCase();

      //Parse any relationships out of fieldName
      String[] fieldNameParts = fieldName.split('\\.');

      if (fieldNameParts.size() > 1) {
         //Construct name of custom field -- replace '__r' with '__c' if it's custom
         String relFieldName = fieldNameParts[0];
         if (relFieldName.endsWith('__r')) {
            relFieldName = relFieldName.left(relFieldName.length() - 3) + '__c';
         } else {
            relFieldName = relFieldName + 'Id';
         }

         //Get describe for the relationship field
         Schema.DescribeFieldResult relFieldDescribe = getFieldDescribe(objectTypeName, relFieldName, checkReadAccess);

         //Get the object type it points to
         List<Schema.SObjectType> referenceTo = relFieldDescribe.getReferenceTo();
         if (referenceTo == null || referenceTo.size() == 0) {
            throw new DescribeCacheException('Not a lookup or master/detail field: ' + relFieldName);
         }

         //Recursive call for the remainder
         Schema.DescribeSObjectResult objectDescribe = referenceTo[referenceTo.size() - 1].getDescribe();

         if (checkReadAccess && !objectDescribe.isAccessible()) {
            throw new DescribeCacheException('User does not have access to object: ' + objectDescribe.getName());
         }

         String fieldNameRemainder = fieldName.substring(fieldNameParts[0].length() + 1);

         return getFieldDescribe(objectDescribe.getName(), fieldNameRemainder, checkReadAccess);
      } else {
         GetAllObjectTokens();
         // Certain fields on standard SF objects (e.g. Opportunity.Account) really have an internal name
         // that has "Id" appended to the end of the field name.  But for backward compatibility, Salesforce
         // did not fix these standard objects to have "Id" on the developer name, but for purposes of how
         // this is used in Describes, the field name needs the "Id" added.
         if (fieldNameParts.size() == 1) {
            if (fieldName != 'name'
                && !fieldName.endsWith('__c')
                && !fieldName.endsWith('__r')
                && GetUserSpecificCache().allObjectTokens.containsKey(fieldName)) {
               fieldName = fieldName + 'Id';
            }
         }
      }

      Map<String, Schema.DescribeFieldResult> fieldsByName = GetUserSpecificCache().fieldDescribesByObjectAndField.get(objectTypeName);

      //Check cache
      if (fieldsByName != null && fieldsByName.containsKey(fieldName)) {
         return fieldsByName.get(fieldName);
      }

      //Check for cached field token map
      Map<String, Schema.Sobjectfield> fieldTokens = GetUserSpecificCache().fieldTokensByObject.get(objectTypeName);
      if (fieldTokens == null) {
         Schema.DescribeSObjectResult objectDescribe = getObjectDescribe(objectTypeName);
         fieldTokens = objectDescribe.fields.getMap();
         GetUserSpecificCache().fieldTokensByObject.put(objectTypeName, fieldTokens);
      }

      Schema.Sobjectfield field = fieldTokens.get(fieldName);
      if (field == null) {
         throw new DescribeCacheException('Field not found1: ' + objectTypeName + '.' + fieldName);
      }

      Schema.DescribeFieldResult result = field.getDescribe();

      if (fieldsByName == null) {
         fieldsByName = new Map<String, Schema.DescribeFieldResult> ();
         GetUserSpecificCache().fieldDescribesByObjectAndField.put(objectTypeName, fieldsByName);
      }
      fieldsByName.put(fieldName, result);

      if (checkReadAccess && !result.isAccessible()) {
         throw new DescribeCacheException('User does not have access to field: ' + objectTypeName + '.' + fieldName);
      }

      return result;
   }

   //Returns a list of describe results, one for each field in the path specified by casedFieldName.
   //Throws if any field in path is not found.
   public static List<Schema.DescribeFieldResult> getFieldDescribes(String objectTypeName, String casedFieldName) {
      return getFieldDescribes(objectTypeName, casedFieldName, true);
   }

   //Returns a list of describe results, one for each field in the path specified by casedFieldName.
   public static List<Schema.DescribeFieldResult> getFieldDescribes(String objectTypeName, String casedFieldName, Boolean throwIfNotFound) {

      List<Schema.DescribeFieldResult> resultList = new List<Schema.DescribeFieldResult> ();
      getFieldDescribes(objectTypeName, casedFieldName, resultList, throwIfNotFound);

      return resultList;
   }

   public static void getFieldDescribes(String objectTypeName, String casedFieldName, List<Schema.DescribeFieldResult> resultList) {
      getFieldDescribes(objectTypeName, casedFieldName, resultList, true);
   }

   public static void getFieldDescribes(String objectTypeName, String casedFieldName, List<Schema.DescribeFieldResult> resultList, Boolean throwIfNotFound) {

      String fieldName = casedFieldName.toLowerCase();

      //Parse any relationships out of fieldName
      String[] fieldNameParts = fieldName.split('\\.');
      if (fieldNameParts.size() > 1) {
         //Construct name of custom field -- replace '__r' with '__c' if it's custom
         String relFieldName = fieldNameParts[0];
         if (relFieldName.endsWith('__r')) {
            relFieldName = relFieldName.left(relFieldName.length() - 3) + '__c';
         } else {
            relFieldName += 'Id';
         }

         //Get describe for the relationship field
         Schema.DescribeFieldResult relFieldDescribe = getFieldDescribe(objectTypeName, relFieldName, false);
         resultList.add(relFieldDescribe);

         //Get the object type it points to
         List<Schema.SObjectType> referenceTo = relFieldDescribe.getReferenceTo();
         if (referenceTo == null || referenceTo.size() == 0) {
            throw new DescribeCacheException('Not a lookup or master/detail field: ' + relFieldName);
         }

         //Recursive call for the remainder
         Schema.DescribeSObjectResult objectDescribe = referenceTo[referenceTo.size() - 1].getDescribe();

         String fieldNameRemainder = fieldName.substring(fieldNameParts[0].length() + 1);

         getFieldDescribes(objectDescribe.getName(), fieldNameRemainder, resultList);

         return;
      }

      Map<String, Schema.DescribeFieldResult> fieldsByName = GetUserSpecificCache().fieldDescribesByObjectAndField.get(objectTypeName);

      //Check for cached field token map
      Map<String, Schema.Sobjectfield> fieldTokens = GetUserSpecificCache().fieldTokensByObject.get(objectTypeName);
      if (fieldTokens == null) {
         Schema.DescribeSObjectResult objectDescribe = getObjectDescribe(objectTypeName);
         fieldTokens = objectDescribe.fields.getMap();
         GetUserSpecificCache().fieldTokensByObject.put(objectTypeName, fieldTokens);
      }

      Schema.Sobjectfield field = fieldTokens.get(fieldName);
      if (field == null) {
         if (throwIfNotFound) {
            throw new DescribeCacheException('Field not found2: ' + objectTypeName + '.' + casedFieldName);
         } else {
            return;
         }
      }

      Schema.DescribeFieldResult result = field.getDescribe();

      if (fieldsByName == null) {
         fieldsByName = new Map<String, Schema.DescribeFieldResult> ();
         GetUserSpecificCache().fieldDescribesByObjectAndField.put(objectTypeName, fieldsByName);
      }
      fieldsByName.put(fieldName, result);

      resultList.add(result);
   }

   //Return all field describes for the specified object.
   public static List<Schema.DescribeFieldResult> getFieldDescribes(String objectTypeName) {

      Map<String, Schema.DescribeFieldResult> fieldsByName = GetUserSpecificCache().fieldDescribesByObjectAndField.get(objectTypeName);

      //Check cache
      if (fieldsByName == null) {
         fieldsByName = new Map<String, Schema.DescribeFieldResult> ();
         GetUserSpecificCache().fieldDescribesByObjectAndField.put(objectTypeName, fieldsByName);
      }

      //Check for cached field token map
      Map<String, Schema.Sobjectfield> fieldTokens = GetUserSpecificCache().fieldTokensByObject.get(objectTypeName);
      if (fieldTokens == null) {
         Schema.DescribeSObjectResult objectDescribe = getObjectDescribe(objectTypeName);
         fieldTokens = objectDescribe.fields.getMap();
         GetUserSpecificCache().fieldTokensByObject.put(objectTypeName, fieldTokens);
      }

      for (Schema.Sobjectfield fieldToken : fieldTokens.values()) {
         Schema.DescribeFieldResult fieldDescribe = fieldToken.getDescribe();
         if (!fieldsByName.containsKey(fieldDescribe.getName().toLowerCase())) {
            fieldsByName.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
         }
      }

      return fieldsByName.values();
   }

   //Returns the relationship information for the specified object and relationship name.
   //Returns null if the relationship is not found on the object
   public static Schema.ChildRelationship getChildRelationship(String objectTypeName, String relationshipName) {

      List<Schema.ChildRelationship> childRels = GetUserSpecificCache().childRelDescribesByObject.get(objectTypeName);

      if (childRels == null) {
         Schema.DescribeSObjectResult objectDescribe = getObjectDescribe(objectTypeName);
         childRels = objectDescribe.getChildRelationships();
         GetUserSpecificCache().childRelDescribesByObject.put(objectTypeName, childRels);
      }

      for (Schema.ChildRelationship rel : childRels) {
         if (rel.getRelationshipName() == relationshipName) {
            return rel;
         }
      }

      return null;
   }

   //Gets the localized label for the specified picklist value.
   public static String getPicklistLabel(String objectTypeName, String fieldName, String picklistValue) {

      Schema.DescribeFieldResult fieldDescribe = getFieldDescribe(AH_UDC_PrefixHelper.getObjectName(objectTypeName), fieldName);
      List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();

      for (Schema.PicklistEntry picklistEntry : picklistEntries)
      if (picklistEntry.getValue() == picklistValue) {
         return picklistEntry.getLabel();
      }

      throw new DescribeCacheException('Picklist entry not found: ' + objectTypeName + '.' + fieldName + '.' + picklistValue);
   }

   public class FieldDescribeInfo {

      //API path of the field including any relationships
      public String fullFieldPath;

      //Label "path" including the label of each field in the chain of relationships
      public String fullFieldLabel;

      //Salesforce describe info for the field
      public Schema.DescribeFieldResult fieldDescribe;

   }

   public class DescribeCacheException extends System.Exception {
   }
}