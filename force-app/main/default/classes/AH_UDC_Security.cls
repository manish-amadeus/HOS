/*
 * File           : Security.cls
 * Created By     : George Tasker (george.tasker@amadeus.com)
 * Created Date   :
 * Description    : Contains methods which implement DML operations that enforce OLS and FLS security based on the User performing
 *                  the operation. This code is based on code originally written and shared by Delphi.fdc and Central Sales
 * Test classes   : Security_TEST
 * Dependencies   : LogHelper
 */
public with sharing class AH_UDC_Security {

   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //CRUD/FLS checking methods
   private static final String ID = 'Id';
   private static final String RELATED_FIELD_INDICATOR = '__r';
   //Always check security if value is true even if call is from trigger.
   //If value is false then it will check based on other security related flags
   private static Boolean isStrictSecurityCheck = false;
   private static Boolean isTestExecutingTrigger = false;
   private static final Set<String> SYSTEM_FIELDS = new Set<String> {
      'id', 'isdeleted', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 'Lastvieweddate',
      'lastreferenceddate', 'systemmodstamp', 'createdby', 'lastmodifiedby', 'owner', 'ownerid'
   };

   private static Boolean isStrictDisableSObjectQueryRecordStorage = false;

   public class InsufficientPrivilegesException extends Exception { }

   // Get value of isStrictDisableSObjectQueryRecordStorage
   public static Boolean getIsStrictDisableSObjectQueryRecordStorage() {
      return AH_UDC_Security.isStrictDisableSObjectQueryRecordStorage;
   }

   // Set value of isStrictDisableSObjectQueryRecordStorage
   public static void setIsStrictDisableSObjectQueryRecordStorage(Boolean value) {
      isStrictDisableSObjectQueryRecordStorage = value;
   }

   //T hrows privilege exception if current user doesn't have create privilege for the specified object.
   public static void checkIsObjectCreateable(sObject theObject) {
      if (!isSecurityCheck()) { return; }

      checkIsObjectCreateable(theObject.getSObjectType().getDescribe().getName());
   }

   // Throws privilege exception if current user doesn't have create privilege for the specified object.
   public static void checkIsObjectCreateable(String objectTypeName) {
      if (!isSecurityCheck()) { return; }

      Schema.DescribeSObjectResult dor = AH_UDC_DescribeCache.getObjectDescribe(AH_UDC_PrefixHelper.getObjectName(objectTypeName));

      if (!dor.isAccessible()) { throwInsufficientPrivileges(objectTypeName, null); }
      if (!dor.isCreateable()) { throwInsufficientPrivileges(objectTypeName, null); }
   }

   // Check fields Filterable in Soql query (not Enabled Encryption) .
   public static Boolean checkisFieldFilterable(String objectTypeName, String[] fieldNames) {
      Boolean isFilterable = true;

      for (String fieldName : fieldNames) {
         Schema.DescribeFieldResult fieldDescribe = AH_UDC_DescribeCache.getFieldDescribe(AH_UDC_PrefixHelper.getObjectName(objectTypeName), AH_UDC_PrefixHelper.getObjectName(fieldName));

         if (!fieldDescribe.isFilterable()) { isFilterable = false; }
      }

      return isFilterable;
   }

   // Throws privilege exception if current user doesn't have update privilege for the specified object.
   public static void checkIsObjectUpdateable(sObject theObject) {
      if (!isSecurityCheck()) { return; }

      string objectTypeName = theObject.getSObjectType().getDescribe().getName();
      checkIsObjectUpdateable(objectTypeName);
   }

   // Throws privilege exception if current user doesn't have update privilege for the specified object.
   public static void checkIsObjectUpdateable(String objectTypeName) {
      if (!isSecurityCheck()) { return; }

      Schema.DescribeSObjectResult dor = AH_UDC_DescribeCache.getObjectDescribe(AH_UDC_PrefixHelper.getObjectName(objectTypeName));

      if (!dor.isAccessible()) { throwInsufficientPrivileges(objectTypeName, null); }
      if (!dor.isUpdateable()) { throwInsufficientPrivileges(objectTypeName, null); }
   }

   // Throws privilege exception if current user doesn't have update privilege for the specified object.
   public static void checkIsObjectDeletable(sObject theObject) {
      if (!isSecurityCheck()) { return; }

      string objectTypeName = theObject.getSObjectType().getDescribe().getName();
      checkIsObjectDeletable(objectTypeName);
   }

   // Throws privilege exception if current user doesn't have update privilege for the specified object.
   public static void checkIsObjectDeletable(String objectTypeName) {
      if (!isSecurityCheck()) { return; }

      Schema.DescribeSObjectResult dor = AH_UDC_DescribeCache.getObjectDescribe(AH_UDC_PrefixHelper.getObjectName(objectTypeName));

      if (!dor.isAccessible()) { throwInsufficientPrivileges(objectTypeName, null); }
      if (!dor.isDeletable()) { throwInsufficientPrivileges(objectTypeName, null); }
   }

   //Throws privilege exception if current user doesn't have read privilege for the specified object.
   public static void checkIsObjectAccessible(String objectTypeName) {
      if (!isSecurityCheck()) { return; }

      Schema.DescribeSObjectResult dor = AH_UDC_DescribeCache.getObjectDescribe(AH_UDC_PrefixHelper.getObjectName(objectTypeName));

      if (!dor.isAccessible()) { throwInsufficientPrivileges(objectTypeName, null); }
   }

   // Throws privilege exception if current user doesn't have create privilege for the specified field.
   public static void checkIsFieldCreateable(String objectTypeName, String fieldName) {
      if (!isSecurityCheck()) { return; }

      Schema.DescribeFieldResult fieldDescribe = AH_UDC_DescribeCache.getFieldDescribe(AH_UDC_PrefixHelper.getObjectName(objectTypeName), AH_UDC_PrefixHelper.getObjectName(fieldName));

      // Missing in ASEM version
      if (!fieldDescribe.isPermissionable()) { return; }
      if (fieldDescribe.isAutoNumber()) { return; }
      if (fieldDescribe.isCalculated()) { return; }

      if (!fieldDescribe.isCreateable() && !fieldDescribe.isCalculated()) {
         throwInsufficientPrivileges(objectTypeName, fieldName);
      }
   }

   // Throws privilege exception if current user doesn't have create privilege for the specified fields.
   public static void checkAreFieldsCreatable(String objectTypeName, String[] fieldNames) {
      if (!isSecurityCheck()) { return; }

      for (String fieldName : fieldNames) {
         if (fieldName.endsWith(RELATED_FIELD_INDICATOR)) { continue; }

         String objName = AH_UDC_PrefixHelper.getObjectName(objectTypeName);
         String fldName = AH_UDC_PrefixHelper.getFieldName(fieldName);
         Schema.DescribeFieldResult fieldDescribe = AH_UDC_DescribeCache.getFieldDescribe(objName, fldName);

         // If it cannot be permissioned, dont validate. Might also add if not nillable, which means Required.
         if (!fieldDescribe.isPermissionable()) { continue; }
         if (fieldDescribe.isAutoNumber()) { continue; }
         if (fieldDescribe.isCalculated()) { continue; }

         if (!fieldDescribe.isCreateable()) {
            //NOTE: This field is not FORMULA() type field, but it is never creatable/updateable, but 
            //      the .isCalculated() field returns FALSE... bug with Salesforce
            if (objectTypeName != 'Opportunity' && fieldName != 'ExpectedRevenue') {
               throwInsufficientPrivileges(objectTypeName, fieldName);
            }
         }
      }
   }

   // Throws privilege exception if current user doesn't have create privilege for the populated fields on the passed in object
   public static void checkAreFieldsCreatable(sObject theObject) {
      if (theObject == null) { return; }

      if (!isSecurityCheck()) { return; }

      //Get the object type name
      String objectTypeName = theObject.getSObjectType().getDescribe().getName();

      // Get the names of the fields from this object instance that are populated and
      // add them (if not already in the set) to the list of fieldNames being created
      Set<String> fieldNames = new Set<String>();
      for (String fieldName : theObject.getPopulatedFieldsAsMap().keySet()) {
         fieldNames.add(fieldName);
      }

      // Remove the fields that we will not check
      fieldNames.removeAll(SYSTEM_FIELDS);

      checkAreFieldsCreatable(objectTypeName, new List<String> (fieldNames));
   }

   // NOTE: This function assumes that all of the objects passed in are of the same type
   public static void checkAreFieldsCreatable(List<sObject> theObjects) {
      if (theObjects == null || theObjects.size() == 0) { return; }

      if (!isSecurityCheck()) { return; }

      // This is the only object type we will allow to be created during this operation
      SObjectType objectType = theObjects[0].getsObjectType();

      // ASEM version of this function made a call to checkAreFieldsCreatable() per object, which was very inefficient

      // Build a consolidated list of which field(s) are populated on one or more of the objects
      Set<String> fieldNames = new Set<String>();
      for (sObject theObject : theObjects) {
         // Since the function takes a list of sObjects, it is possible someone could try to insert multiple object types
         // in the same operation, but we don't allow that
         if (theObject.getsObjectType() != objectType) {
            throw new DmlException('Multiple object types cannot be created in the same operation');
         }

         // Get the names of the fields from this object instance that are populated and
         // add them (if not already in the set) to the list of fieldNames being created
         for (String fieldName : theObject.getPopulatedFieldsAsMap().keySet()) {
            fieldNames.add(fieldName);
         }
      }

      // Remove the fields that we will not check
      fieldNames.removeAll(SYSTEM_FIELDS);

      checkAreFieldsCreatable(objectType.getDescribe().getName(), new List<String>(fieldNames));
   }

   // Throws privilege exception if current user doesn't have update privilege for the specified field.
   public static void checkIsFieldUpdateable(String objectTypeName, String fieldName) {
      if (!isSecurityCheck()) { return; }

      if (fieldName.endsWith(RELATED_FIELD_INDICATOR)) { return; }

      if (SYSTEM_FIELDS.contains(fieldName.toLowerCase())) { return; }

      Schema.DescribeFieldResult fieldDescribe = AH_UDC_DescribeCache.getFieldDescribe(AH_UDC_PrefixHelper.getObjectName(objectTypeName), AH_UDC_PrefixHelper.getObjectName(fieldName));

      checkIsFieldUpdateable(objectTypeName, fieldDescribe);
   }

   private static void checkIsFieldUpdateable(String objectTypeName, Schema.DescribeFieldResult fieldDescribe) {
      if (fieldDescribe.isAutoNumber()) { return; }

      if (fieldDescribe.isCalculated()) { return; }

      if (fieldDescribe.getType() == Schema.DisplayType.Reference) { return; }

      if (SYSTEM_FIELDS.contains(fieldDescribe.getName().toLowerCase())) { return; }

      if (!fieldDescribe.isUpdateable()) {
         throwInsufficientPrivileges(objectTypeName, fieldDescribe.getName());
      }
   }

   // Throws privilege exception if current user doesn't have update privilege for the specified fields.
   public static void checkAreFieldsUpdateable(String objectTypeName, String[] fieldNames) {
      if (!isSecurityCheck()) { return; }

      Set<String> fields = new Set<String> ();
      fields.addAll(fieldNames);
      fields.remove(ID);
      fields.remove('RecordType');

      // ASEM version of this class was missing this
      fields.removeAll(SYSTEM_FIELDS);

      for (String fieldName : fields) {
         if (fieldName.endsWith(RELATED_FIELD_INDICATOR)) { continue; }

         checkIsFieldUpdateable(objectTypeName, fieldName);
      }
   }

   // Checks that the current user has complete access to the specified object -- insert, update, and delete for object and all fields
   public static void checkHasFullPrivilege(String objectTypeName) {
      if (!isSecurityCheck()) { return; }

      //Get all object describes and check for creatable and Updateable
      List<Schema.DescribeFieldResult> fieldDescribes = AH_UDC_DescribeCache.getFieldDescribes(AH_UDC_PrefixHelper.getObjectName(objectTypeName));

      for (Schema.DescribeFieldResult fieldDescribe : fieldDescribes) {

         if (!fieldDescribe.isPermissionable()) { continue; }
         if (fieldDescribe.isAutoNumber()) { continue; }
         if (fieldDescribe.isCalculated()) { continue; }

         if (!fieldDescribe.isCreateable() || !fieldDescribe.isUpdateable()) {
            throwInsufficientPrivileges(objectTypeName, fieldDescribe.getName());
         }
      }

      checkIsObjectDeletable(objectTypeName);
   }

   // Check if field named in fieldName for the object named in objectTypeName is accessible
   public static Boolean checkIsFieldAccessible(String objectTypeName, String fieldName) {
      if (!isSecurityCheck()) { return true; }

      if (fieldName.endsWith(RELATED_FIELD_INDICATOR)) { return false; }

      return checkAreFieldsAccessible(objectTypeName, new List<String> { fieldName });
   }

   // Check if all of the fields listed in fieldNames for the object named in objectTypeName are accessible
   public static Boolean checkAreFieldsAccessible(String objectTypeName, String[] fieldNames) {
      if (!isSecurityCheck()) { return true; }

      for (String fieldName : fieldNames) {
         if (fieldName.endsWith(RELATED_FIELD_INDICATOR)) { continue; }

         // ASEM Code did not have this
         if (SYSTEM_FIELDS.contains(fieldName)) { continue; }

         Schema.DescribeFieldResult fieldDescribe = AH_UDC_DescribeCache.getFieldDescribe(AH_UDC_PrefixHelper.getObjectName(objectTypeName), AH_UDC_PrefixHelper.getObjectName(fieldName));
         if (!fieldDescribe.isAccessible()) {
            return false;
         }
      }

      return true;
   }

   // This is important for AlternateLanguageUtils
   public static Set<String> getAccessibleFields(String objectTypeName, Set<String> fieldNames) {
      Set<String> accessibleFields = new Set<String> ();

      for (String fieldName : fieldNames) {
         if (fieldName.endsWith(RELATED_FIELD_INDICATOR)) { continue; }  

         Schema.DescribeFieldResult fieldDescribe = AH_UDC_DescribeCache.getFieldDescribe(AH_UDC_PrefixHelper.getObjectName(objectTypeName), AH_UDC_PrefixHelper.getObjectName(fieldName));
         if (fieldDescribe.isAccessible()) {
            accessibleFields.add(fieldName);
         }
      }

      return accessibleFields;
   }

   // Do a standard sObject.put by field name and value, but first check that current user has required FLS permission.
   public static void putWithFlsCheck(sObject theObject, String fieldName, object theValue) {
      if (isSecurityCheck()) {
         String objectTypeName = theObject.getSObjectType().getDescribe().getName();

         if (theObject.Id == null) {
            checkIsFieldCreateable(objectTypeName, AH_UDC_PrefixHelper.getObjectName(fieldName));
         } else {
            checkIsFieldUpdateable(objectTypeName, AH_UDC_PrefixHelper.getObjectName(fieldName));
         }
      }

      theObject.put(fieldName, theValue);
   }

   // ************* Creates *************
   public static void createObject(sObject o) {
      createObjects(new List<SObject> { o }, true);
   }

   public static void createObject(sObject o, Boolean withFLS) {
      createObjects(new List<SObject> { o }, withFLS);
   }

   public static void createObjects(List<sObject> l) {
      createObjects(l, true);
   }

   // This method should only be called from outside of this class by the SystemContext class methods
   public static void createObjects(List<sObject> l, Boolean withFLS) {
      if (l == null || l.size() == 0) { return; }

      checkIsObjectCreateable(l[0]);
      if (withFLS) { checkAreFieldsCreatable(l); }

      insert l;
   }

   // ************* Updates *************
   public static void updateObject(sObject o) {
      updateObjects(new List<SObject> { o }, true);
   }

   public static void updateObject(sObject o, Boolean withFLS) {
      updateObjects(new List<SObject> { o }, withFLS);
   }

   public static void updateObjects(List<sObject> l) {
      updateObjects(l, true);
   }

   // This method should only be called from outside of this class by the SystemContext class methods
   public static void updateObjects(List<sObject> l, Boolean withFLS) {
      if (l == null || l.size() == 0) { return; }

      checkIsObjectUpdateable(l[0]);
      if (withFLS) { checkAreFieldsUpdateable(l); }

      update l;
   }

   // ************* Upserts *************
   public static void upsertObject(sObject o) {
      upsertObjects(new List<SObject> { o }, true);
   }

   public static void upsertObject(sObject o, Boolean withFLS) {
      upsertObjects(new List<SObject> { o }, withFLS);
   }

   public static void upsertObjects(List<sObject> l) {
      upsertObjects(l, true);
   }

   // This method should only be called from outside of this class by the SystemContext class methods
   public static void upsertObjects(List<sObject> l, Boolean withFLS) {
      if (l == null || l.size() == 0) { return; }

      string objectTypeName = l[0].getSObjectType().getDescribe().getName();

      Boolean canCreate = false;
      Boolean canUpdate = false;

      for (sObject o : l) {
         if (o.Id == null) {
            if (!canCreate) {
               checkIsObjectCreateable(objectTypeName);
               canCreate = true;
            }
         } else {
            if (!canUpdate) {
               checkIsObjectUpdateable(objectTypeName);
               canUpdate = true;
            }
         }

         if (canCreate && canUpdate) { break; }
      }

      if (withFLS) { checkAreFieldsUpdateable(l); }

      upsert l;
   }

   // ************* Deletes *************
   public static void deleteObject(sObject o) {
      deleteObjects(new List<SObject> { o }, true);
   }

   public static void deleteObject(sObject o, Boolean withFLS) {
      deleteObjects(new List<SObject> { o }, withFLS);
   }

   public static void deleteObjects(List<sObject> l) {
      deleteObjects(l, true);
   }

   // This method should only be called from outside of this class by the SystemContext class methods
   // Note that the withFLS parameter does nothing except keep the same signature as the other functions
   public static void deleteObjects(List<sObject> l, Boolean withFLS) {
      if (l == null || l.size() == 0) { return; }

      //checkIsObjectDeletable(l[0]);

      SObjectType objType = l[0].getSObjectType();
      //Schema.DescribeSObjectResult dsr = objType.getDescribe();

      if (objType.getDescribe().isDeletable()) { 
         delete l;
      } else {
         throwInsufficientPrivileges(objType.getDescribe().getName(), null);
      }
   }

   // ************* Check Methods **************
   public static void checkAreFieldsUpdateable(List<sObject> theObjects) {
      if (!isSecurityCheck()) { return; }

      for (sObject obj : theObjects) {
         checkAreFieldsUpdateable(obj);
      }
   }

   // Throws privilege exception if current user doesn't have update privilege for the populated fields on the passed in object
   public static void checkAreFieldsUpdateable(sObject theObject) {
      if (!isSecurityCheck()) { return; }

      //Get the object type name
      String objectTypeName = theObject.getSObjectType().getDescribe().getName();

      //Get the fields from the object        
      Map<String, Object> fieldsToValue = theObject.getPopulatedFieldsAsMap();

      AH_UDC_Security.checkAreFieldsUpdateable(objectTypeName, new List<String> (fieldsToValue.keySet()));
   }
/*
   public static void checkAreFieldsUpsertable(List<SObject> theObjects) {
      if (!isSecurityCheck()) { return; }

      for (sObject obj : theObjects) {
         checkAreFieldsUpsertable(obj);
      }
   }

   //Throws privilege exception if current user doesn't have create and update privilege for the populated fields on the passed in object
   public static void checkAreFieldsUpsertable(sObject theObject) {
      if (!isSecurityCheck()) { return; }

      // Get the object type name
      String objectTypeName = theObject.getSObjectType().getDescribe().getName();

      // Get the fields from the object        
      Map<String, Object> fieldsToValue = theObject.getPopulatedFieldsAsMap();
      Map<String, Object> mutableMap = new Map<String, Object> (fieldsToValue);

      // ID fields aren't Updateable by any user so we remove them from the collection
      for (String field : SYSTEM_FIELDS) {
         if (mutableMap.containsKey(field)) {
            mutableMap.remove(field);
         }
      }

      AH_UDC_Security.checkAreFieldsCreatable(objectTypeName, new List<String> (mutableMap.keySet()));

      Security.checkAreFieldsUpdateable(objectTypeName, new List<String> (mutableMap.keySet()));
   }

   // Returns TRUE if the current user has the permission set named in permissionSetName assigned
   public static Boolean userHasPermissionSet(String permissionSetName) {
      return userHasPermissionSet(new List<String> { permissionSetName });
   }

   // Returns TRUE if the current user has any of the permission sets in listPermissionSetNames assigned
   public static Boolean userHasPermissionSet(List<String> listPermissionSetNames) {
      Integer count = [SELECT COUNT()
                       FROM PermissionSetAssignment
                       WHERE AssigneeId = :UserInfo.getUserId()
                       AND PermissionSet.Name = :listPermissionSetNames];
      return count > 0;
   }

   // Returns TRUE if the current user belongs to the profile named in profileName
   public static Boolean userHasProfile(String profileName) {
      List<Profile> listProfiles = [SELECT Name
                                    FROM Profile
                                    WHERE Id = :UserInfo.getProfileId()];

      // If the Profile is not found, there is something seriously wrong!
      if (listProfiles.size() == 0) { return false; }

      return listProfiles[0].Name.equalsIgnoreCase(profileName);
   }

   public static Boolean userHasCustomPermission(String customPermissionDeveloperName) {
      // Query the Custom Permissions to get the 
      List<CustomPermission> listCustomPermissions = [SELECT Id, DeveloperName
                                                      FROM CustomPermission
                                                      WHERE DeveloperName = :customPermissionDeveloperName];

      // If the Custom Permission is not found, the user definitely does not have it granted
      if (listCustomPermissions.size() == 0) { return false; }

      // Query to determine which of these custom Settings are assigned to this user
      Integer count = [SELECT COUNT()
                       FROM SetupEntityAccess
                       WHERE SetupEntityId = :listCustomPermissions[0].Id
                       AND ParentId IN(SELECT PermissionSetId
                                       FROM PermissionSetAssignment
                                       WHERE AssigneeId = :UserInfo.getUserId())];

      return count > 0;
   }
*/

   // Throw an exception due to insufficent privilege on object and field
   @TestVisible public static void throwInsufficientPrivileges(String objectTypeName, String fieldName) {
      String identifier = AH_UDC_PrefixHelper.getObjectName(objectTypeName);
      if (!String.isEmpty(fieldName)) {
         identifier += '.' + AH_UDC_PrefixHelper.getFieldName(fieldName);
      }

      AH_UDC_LogHelper.Debug(LoggingLevel.ERROR, Label.AH_UDC_Insufficient_Privileges + ': ' + identifier);

      AH_UDC_LogHelper.Log('Security', 'Security', AH_UDC_LogHelper.getClassAndMethodName(new DmlException('StackTrace')),
                     Label.AH_UDC_Insufficient_Privileges + ': ' + identifier);

      throw new InsufficientPrivilegesException(Label.AH_UDC_Insufficient_Privileges + ': ' + identifier);
   }

/* Not needed by the UDC map
   // New security methods with strongly-typed/validated list of fields
   public static list<string> getFieldNamesFromSObjectFields(List<Schema.SObjectField> schemaFields) {
      list<String> fieldNames = new list<String> ();

      for (Schema.SObjectField sof : schemaFields) {
         string fieldName = sof.getDescribe().getLocalName();
         fieldNames.add(fieldName);
      }

      return fieldNames;
   }
*/
   // Executing isSecurityCheck method to check if method is called from trigger or UI. 
   // If method is called from Trigger then it will skip checking access
   public static Boolean isSecurityCheck() {
      if (isStrictSecurityCheck) { return true; }

      if (trigger.IsExecuting || (Test.IsRunningTest() && isTestExecutingTrigger)) { return false; }

      return true;
   }

   public static Boolean getIsStrictSecurityCheck() {
      return isStrictSecurityCheck;
   }

   public static void setIsStrictSecurityCheck(Boolean value) {
      isStrictSecurityCheck = value;
   }

   public static void setIsTestExecutingTrigger(Boolean value) {
      isTestExecutingTrigger = value;
   }
}