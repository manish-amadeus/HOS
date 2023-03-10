/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : INTGR_REST_JSONGenerator
Author          : Princy Jain
Created Date    : 03/21/2018
Last Mod Date   : 01/14/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class to generate json string based on the data provided
				: CLASS DEPENDANCIES: INTGR_Case_SOQLDataProvider
				: 
************************************************************************************************/
public class INTGR_REST_JSONGenerator 
{
    
    public static String generateJSONRequestString(sObject obj, Map <String, String> sourceTargetFieldMap) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Integration Object, Map of source and target object field based w.r.t. Integration account selected.
        // Return: String of request body in JSON.
        // Description: Method responsible to generate JSON request body string.        
        
        system.debug(' *** ENTERING INTGR_REST_JSONGenerator.generateJSONRequestString() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String objType = obj.getSObjectType() + '';
        String jsonString = '{';
         
        if (obj != null && sourceTargetFieldMap.size() > 0)
        {
            for (String fieldVal : sourceTargetFieldMap.keyset()) 
            {                 
                if (new INTGR_Case_SOQLDataProvider().isValidField(fieldVal, objType)) 
                {
                    if (sourceTargetFieldMap.get(fieldVal) != null && obj.get(fieldVal) != null) 
                    {               
                        String replaceStr = '<br />';
                        // string strValue = ((string)obj.get(fieldVal)); THIS CAUSES ERROR WHEN NOT A STRING: Invalid conversion from runtime type Boolean to String
                        string strValue = string.valueOf(obj.get(fieldVal));
                        jsonString += '"' + sourceTargetFieldMap.get(fieldVal) + '" : "' + strValue + '",';
                    }
                }
            }
        }
        
        jsonString = jsonString.substring(0, jsonString.length() - 1) + '}';
        
        if (system.Label.Integration_Debug_Show_All == 'true')
        {
            system.debug(' **** jsonString = ' + jsonString);
        }    
        
        system.debug(' *** EXITING INTGR_REST_JSONGenerator.generateJSONRequestString() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return jsonString;
        
    }
    
}