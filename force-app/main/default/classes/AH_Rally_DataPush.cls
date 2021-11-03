/****************************************************************************************
Name            : AH_Rally_DataPush (TC Org Name: LRReSubmitToRally) 
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : 
				: 
				: 
******************************************************************************************/
public class AH_Rally_DataPush 
{

    @AuraEnabled 
    public static string LRReSubmit(Id dataID) 
    {
        
        Case caseRecord = [SELECT Id, UserStory_Rally_Status__c, Rally_Artifact_Ref__c FROM Case WHERE Id =: dataID];
        
        if (caseRecord.Rally_Artifact_Ref__c == null) 
        { 
            return 'Please create user story first'; 
        } 
        else 
        { 
            string state = caseRecord.UserStory_Rally_Status__c; 
            
            // Start US138824 - ONLY ALLOW "Re-Submit to Rally" when Rally Status is "Need More Information", "Verified", or "Closed" 
            switch on state 
            {
                when 'Need More Information','Verified' 
                {
                    return 'X'; // Success to resubmit data to rally
                }
                when 'Closed' 
                {
                    return 'Y'; // Success to resubmit data to rally
                }
                when else 
                {  				// default Error
                    return 'Resubmit to rally is only Allowed if Rally Status is "Need More Information", "Verified" OR "Closed"';
                }
            }
            // End  US138824           
        }
    }
    
    //US125897
    public static Map<String, String> relationalFieldsArr = new Map<String, String> {'Competitor1' => 'Competitor_1__r.Name','Competitor2' => 'Competitor_2__r.Name','Competitor3' => 'Competitor_3__r.Name','Competitor4' => 'Competitor_4__r.Name','Competitor5' => 'Competitor_5__r.Name'};
    
    @AuraEnabled 
    public static string LRReSubmiteSendCallout(Id dataID) 
    {
        
        Map<String,String> RallySfMapping = AH_Rally_Library.getMapping();
        List<String> realValues = new List<String>();
         String setvalue = 'abc';
        
        try
        {
            
            case caseRecord = [SELECT Id, UserStory_Rally_Status__c, Rally_Artifact_Ref__c, 
                               Competitor_1__r.Name, Competitor_2__r.Name, Competitor_3__r.Name, Competitor_4__r.Name, Competitor_5__r.Name, 
                               Competitor_1_BID__c, Competitor_2_BID__c, Competitor_3_BID__c, Competitor_4_BID__c, Competitor_5_BID__c,
                               Demand_Property_ID__c, Demand_Property_ID_1__c, Demand_Property_ID_2__c, Demand_Property_ID_3__c, Demand_Property_ID_4__c, Demand_Property_ID_5__c, 
                               Property_Mapping__c, Property_Mapping_1__c, Property_Mapping_2__c, Property_Mapping_3__c, Property_Mapping_4__c, Property_Mapping_5__c 
                               FROM Case WHERE Id =: dataID];
            
            JSONGenerator gen = JSON.createGenerator(true);   
            gen.writeStartObject();
            gen.writeFieldName('hierarchicalrequirement');
            gen.writeStartObject();
            gen.writeStringField('L3KanbanStage','Advance Investigation');
            
            Map<String, String> fieldsRally = getRallyFields(caseRecord);
            
            for (String rallyNameField : fieldsRally.keySet())
            {
                String value = fieldsRally.get(rallyNameField);
                if (value == null)
                {
                    value='';
                }
                gen.writeStringField(rallyNameField,value);
            }

            gen.writeEndObject();
            gen.writeEndObject();
            String jstring = gen.getAsString();
            System.debug('-----------------' + jstring);
            
            String response = AH_Rally_Library.sendRequestObject('POST', caseRecord.Rally_Artifact_Ref__c, jstring);
            System.debug(response);
            
            if (response.contains('Could not read: Could not read HierarchicalRequirement'))
            {
                return 'User Story is deleted in Rally';
            } 
            else 
            {
                case cs = new case();
                cs.Id = dataID; 
                cs.UserStory_Rally_Status__c = 'Advance Investigation';
                cs.Status = 'Paused - Development Team Review'; 
                update cs;
                return 'Refresh';
            }
        }
        catch (exception exp)
        {
            system.debug(exp.getMessage() + '...' + exp.getLineNumber());
            return exp.getMessage();
        }
  
    }
    
    public static Map<String, String> getRallyFields(Case c)
    {
        
        Map<String, String> caseNewValsM = new Map<String, String>();
        
        caseNewValsM.put('Competitor1', c.Competitor_1__r.Name);
        caseNewValsM.put('Competitor2', c.Competitor_2__r.Name);
        caseNewValsM.put('Competitor3', c.Competitor_3__r.Name);
        caseNewValsM.put('Competitor4', c.Competitor_4__r.Name);
        caseNewValsM.put('Competitor5', c.Competitor_5__r.Name);
        caseNewValsM.put('Competitor1BID', c.Competitor_1_BID__c);
        caseNewValsM.put('Competitor2BID', c.Competitor_2_BID__c);
        caseNewValsM.put('Competitor3BID', c.Competitor_3_BID__c);
        caseNewValsM.put('Competitor4BID', c.Competitor_4_BID__c);
        caseNewValsM.put('Competitor5BID', c.Competitor_5_BID__c);
        caseNewValsM.put('DemandPropertyID', c.Demand_Property_ID__c);
        caseNewValsM.put('DemandPropertyID1', c.Demand_Property_ID_1__c);
        caseNewValsM.put('DemandPropertyID2', c.Demand_Property_ID_2__c);
        caseNewValsM.put('DemandPropertyID3', c.Demand_Property_ID_3__c);
        caseNewValsM.put('DemandPropertyID4', c.Demand_Property_ID_4__c);
        caseNewValsM.put('DemandPropertyID5', c.Demand_Property_ID_5__c);
        caseNewValsM.put('PropertyMapping', c.Property_Mapping__c);
        caseNewValsM.put('PropertyMapping1', c.Property_Mapping_1__c);
        caseNewValsM.put('PropertyMapping2', c.Property_Mapping_2__c);
        caseNewValsM.put('PropertyMapping3', c.Property_Mapping_3__c);
        caseNewValsM.put('PropertyMapping4', c.Property_Mapping_4__c);
        caseNewValsM.put('PropertyMapping5', c.Property_Mapping_5__c);
        System.debug('caseNewValsM ' + caseNewValsM);
        return caseNewValsM; 
        
    }
    
}