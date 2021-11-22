// Provides methods that will run using the SystemContext rather than the current user's context
public without sharing class AH_UDC_SystemContext {

   // Execute the query contained in the 'query' string
   public List<sobject> query(String query) {
      List<sobject> lstObjs = Database.query(query);
      return lstObjs;
   }

   // Use when a database query needs to be run in SystemContext, rather than with the current User's access level
   //
   // objectName     - Name of the object to query, including any namespaces
   // fieldNames     - List of the field names whose values are to be returned in the results
   // whereClause    - [Optional]Contains the WHERE criteria, without the word "WHERE". 
   //                  Must not have single quotes escaped, this method will add the necessary escaping
   //                  Pass '' or null if not specifying a WHERE clause
   // orderBy        - [Optional]Comma seperated list of fields to use in ordering the results, optionally includes ASC/DESC for each field
   //                  Pass '' or null if not specifying an ORDER BY clause
   // maxRecords     - [Optional]Defaults to 50000 if a 0 or null is passed as in the parameter
   //
   // Returns on:
   //    Success - A list of objects, with only the requested fields, that match the search criteria
   //    Failed  - If an exception occurs, the object does not exist or is inaccessible, or any requested
   //              field does not exist or is inaccessible, one or more log messages are logged and an
   //              exception is thrown
   public List<SObject> query(String objectName, List<String>fieldNames, String whereClause, String orderBy, Integer maxRecords) {
      AH_UDC_LogHelper.debug('###objectName: ' + objectName);
      AH_UDC_LogHelper.debug('###fieldNames: ' + fieldNames);
      AH_UDC_LogHelper.debug('###whereClause: ' + whereClause);
      AH_UDC_LogHelper.debug('###orderBy: ' + orderBy);
      AH_UDC_LogHelper.debug('###maxRecords: ' + maxRecords);
      // Validate that requested object exists and is accessible
      Schema.sObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
      if (sObjType == null || !sObjType.getDescribe().isAccessible()) {
         String message = 'The requested object (' + objectName + ') was not found or is inaccessible';
         System.debug(LoggingLevel.ERROR, message);
         AH_UDC_LogHelper.Log('Error', 'System Context', AH_UDC_LogHelper.getClassAndMethodName(new DmlException()), message);
         throw new AH_UDC_SystemContextException(message);
      }

      // Retrieve the fields for this SObject so we can check accessibility for the requested fields
      Schema.DescribeSObjectResult sObjDescribe = sObjType.getDescribe();
      Map<String, Schema.SObjectField> sObjFieldsMap = sObjDescribe.fields.getMap();
      if (sObjFieldsMap == null) {
         // This should not be able to happen, but just in case...
         String message = 'Unable retrieve the object field map for ' + objectName;
         AH_UDC_LogHelper.debug(LoggingLevel.ERROR, message);
         AH_UDC_LogHelper.Log('Error', 'System Context', AH_UDC_LogHelper.getClassAndMethodName(new DmlException()), message);
         throw new AH_UDC_SystemContextException(message);
      }

      // Start building the query
      String query = 'SELECT ';

      // Will contain the ObjectName.FieldName of any requested fields that are not found or are inaccessible
      List<String>listErrantFields = new List<String>();

      // Loop through the fields checking that they are accessible and adding them to the list of fields
      // that will be returned for each object record
      Boolean firstField = true;
      for (string f : fieldNames) {

         // Ensure that field (f) exists, and that it is accessible.  Note that this loop will assess
         // all fields for existance/accessibility before exiting if a field is in error, so that 
         // the log messages will be recorded for all fields
         try {
            if (!sObjFieldsMap.get(f.toLowerCase()).getDescribe().isAccessible()) {
               listErrantFields.add(objectName + '.' + f);
            }
         }
         catch (Exception exc) {
            listErrantFields.add(objectName + '.' + f);
         }

         if (!firstField) {
            query += ', ';
         } else {
            firstField = false;
         }

         query += f;
      }

      // If any of the requested fields are inaccessible or don't exist, return an empty result list
      if (listErrantFields.size() > 0) {
         String message = 'While performing a query, the following requested field(s) either do not exist, or are inaccessible: ' + String.join(listErrantFields, ',');
         AH_UDC_LogHelper.debug(LoggingLevel.ERROR, message);
         AH_UDC_LogHelper.Log('Error', 'System Context', AH_UDC_LogHelper.getClassAndMethodName(new DmlException()), message);
         throw new AH_UDC_SystemContextException(message);
      }

      // FROM clause
      query += ' FROM ' + objectName;

      // WHERE clause
      if (!String.isBlank(whereClause)) {
         query += ' WHERE ' + whereClause;
      }

      // ORDER BY clause
      if (!String.isBlank(orderBy)) {
         query += ' ORDER BY ' + orderBy;
      }

      // LIMIT statement
      if (maxRecords == null || maxRecords == 0) {
         query += ' LIMIT 50000';
      } else {
         query += ' LIMIT ' + maxRecords;
      }

      List<SObject> listObjects = Database.query(query);

      return listObjects;
   }

   // Delete sObject list
   public void deleteSobjList(List<SObject> sObjList) {
      delete sObjList;
   }

   // Insert sObject list
   public void insertSobjList(List<SObject> sObjList) {
      insert sObjList;
   }

   // Upsert object
   public void upsertSObj(SObject sObj) {
      upsert sObj;
   }

   // Update object
   public void updateSObj(SObject sObj) {
      update sObj;
   }

   public class AH_UDC_SystemContextException extends Exception {}
}