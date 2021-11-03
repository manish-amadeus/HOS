/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : INTGR_REST_XMLGenerator
Author          : Princy Jain
Created Date    : 03/21/2018
Last Mod Date   : 01/14/2019
Last Mod By     : 
NICC Reference  : 
Description     : Class to generate the XML string based on the data provided.
				: 
************************************************************************************************/
public class INTGR_REST_XMLGenerator 
{

    public static string generateXMLRequestString(sObject caseObj, Map <String, String> sourceTargetFieldMap) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Integration Object, Map of source and target object field based w.r.t. Integration account selected
        // Return: String of request body in XML
        // Description: Method responsible to generate XML request body string
        
        system.debug(' *** ENTERING INTGR_REST_XMLGenerator.generateXMLRequestString() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String objType = '';
        DOM.Document doc = new DOM.Document();
        
        // CREATE REQUEST ENVELOPE 
        Dom.XmlNode request = doc.createRootElement('request', null, null);
        
        // CREATE BODY OF THE REQUEST 
        Dom.XmlNode entry = request.addChildElement('entry', null, null);
        
        if (caseObj != null && sourceTargetFieldMap.size() > 0) 
        {
            objType = caseObj.getSObjectType() + '';
            for (String fieldVal: sourceTargetFieldMap.keyset()) 
            {
                if (new INTGR_Case_SOQLDataProvider().isValidField(fieldVal, objType)) 
                {
                    if (sourceTargetFieldMap.get(fieldVal) != null && caseObj.get(fieldVal) != null) 
                    {
                        entry.addChildElement(sourceTargetFieldMap.get(fieldVal), null, null).addTextNode(caseObj.get(fieldVal).toString());
                    }
                }
            }
        }
        
        system.debug(' *** EXITING INTGR_REST_XMLGenerator.generateXMLRequestString() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return (doc.toXmlString());
        
    }
    
}