/****************************************************************************************
Name            : AH_Rally_FieldMapper (TC Org Name: SFToRallyFields) 
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : 
				: 
				: 
******************************************************************************************/ 
public class AH_Rally_FieldMapper 
{
    
    public static Map<String, List<String>> oldValuesMap(Case c)
    {
        Map<String, List<String>> caseOldValsM = new Map<String,  List<String>>();
        System.debug('c.Competitor_1__r.Name,  ' + c.Competitor_1__r.Name);
        caseOldValsM.put('Competitor1',  new List<String>{c.Competitor_1__c, 'Competitor_1__r.Name'});
        caseOldValsM.put('Competitor2', new List<String>{c.Competitor_2__c, 'Competitor_2__r.Name'});
        caseOldValsM.put('Competitor3', new List<String>{c.Competitor_3__c, 'Competitor_3__r.Name'});
        caseOldValsM.put('Competitor4', new List<String>{c.Competitor_4__c, 'Competitor_4__r.Name'});
        caseOldValsM.put('Competitor5', new List<String>{c.Competitor_5__c, 'Competitor_5__r.Name'});
        caseOldValsM.put('Competitor1BID', new List<String>{c.Competitor_1_BID__c, 'Competitor_1_BID__c'});
        caseOldValsM.put('Competitor2BID', new List<String>{c.Competitor_2_BID__c, 'Competitor_2_BID__c'});
        caseOldValsM.put('Competitor3BID', new List<String>{c.Competitor_3_BID__c, 'Competitor_3_BID__c'});
        caseOldValsM.put('Competitor4BID', new List<String>{c.Competitor_4_BID__c, 'Competitor_4_BID__c'});
        caseOldValsM.put('Competitor5BID', new List<String>{c.Competitor_5_BID__c, 'Competitor_5_BID__c'});
        caseOldValsM.put('DemandPropertyID', new List<String>{c.Demand_Property_ID__c, 'Demand_Property_ID__c'});
        caseOldValsM.put('DemandPropertyID1', new List<String>{c.Demand_Property_ID_1__c, 'Demand_Property_ID_1__c'});
        caseOldValsM.put('DemandPropertyID2', new List<String>{c.Demand_Property_ID_2__c, 'Demand_Property_ID_2__c'});
        caseOldValsM.put('DemandPropertyID3', new List<String>{c.Demand_Property_ID_3__c, 'Demand_Property_ID_3__c'});
        caseOldValsM.put('DemandPropertyID4', new List<String>{c.Demand_Property_ID_4__c, 'Demand_Property_ID_4__c'});
        caseOldValsM.put('DemandPropertyID5', new List<String>{c.Demand_Property_ID_5__c, 'Demand_Property_ID_5__c'});
        caseOldValsM.put('PropertyMapping', new List<String>{c.Property_Mapping__c, 'Property_Mapping__c'});
        caseOldValsM.put('PropertyMapping1', new List<String>{c.Property_Mapping_1__c, 'Property_Mapping_1__c'});
        caseOldValsM.put('PropertyMapping2', new List<String>{c.Property_Mapping_2__c, 'Property_Mapping_2__c'});
        caseOldValsM.put('PropertyMapping3', new List<String>{c.Property_Mapping_3__c, 'Property_Mapping_3__c'});
        caseOldValsM.put('PropertyMapping4', new List<String>{c.Property_Mapping_4__c, 'Property_Mapping_4__c'});
        caseOldValsM.put('PropertyMapping5', new List<String>{c.Property_Mapping_5__c, 'Property_Mapping_5__c'});
        System.debug('caseOldValsM ' + caseOldValsM);
        return caseOldValsM;
    }
    
    public static Map<String, List<String>> newValuesMap(Case c)
    {
        Map<String, List<String>> caseNewValsM = new Map<String, List<String>>();
        System.debug(' new values c ' + c);
        caseNewValsM.put('Competitor1', new List<String>{c.Competitor_1__c, 'Competitor_1__r.Name'});
        caseNewValsM.put('Competitor2', new List<String>{c.Competitor_2__c, 'Competitor_2__r.Name'});
        caseNewValsM.put('Competitor3', new List<String>{c.Competitor_3__c, 'Competitor_3__r.Name'});
        caseNewValsM.put('Competitor4', new List<String>{c.Competitor_4__c, 'Competitor_4__r.Name'});
        caseNewValsM.put('Competitor5', new List<String>{c.Competitor_5__c, 'Competitor_5__r.Name'});
        caseNewValsM.put('Competitor1BID', new List<String>{c.Competitor_1_BID__c, 'Competitor_1_BID__c'});
        caseNewValsM.put('Competitor2BID', new List<String>{c.Competitor_2_BID__c, 'Competitor_2_BID__c'});
        caseNewValsM.put('Competitor3BID', new List<String>{c.Competitor_3_BID__c, 'Competitor_3_BID__c'});
        caseNewValsM.put('Competitor4BID', new List<String>{c.Competitor_4_BID__c, 'Competitor_4_BID__c'});
        caseNewValsM.put('Competitor5BID', new List<String>{c.Competitor_5_BID__c, 'Competitor_5_BID__c'});
        caseNewValsM.put('DemandPropertyID', new List<String>{c.Demand_Property_ID__c, 'Demand_Property_ID__c'});
        caseNewValsM.put('DemandPropertyID1', new List<String>{c.Demand_Property_ID_1__c, 'Demand_Property_ID_1__c'});
        caseNewValsM.put('DemandPropertyID2', new List<String>{c.Demand_Property_ID_2__c, 'Demand_Property_ID_2__c'});
        caseNewValsM.put('DemandPropertyID3', new List<String>{c.Demand_Property_ID_3__c, 'Demand_Property_ID_3__c'});
        caseNewValsM.put('DemandPropertyID4', new List<String>{c.Demand_Property_ID_4__c, 'Demand_Property_ID_4__c'});
        caseNewValsM.put('DemandPropertyID5', new List<String>{c.Demand_Property_ID_5__c, 'Demand_Property_ID_5__c'});
        caseNewValsM.put('PropertyMapping', new List<String>{c.Property_Mapping__c, 'Property_Mapping__c'});
        caseNewValsM.put('PropertyMapping1', new List<String>{c.Property_Mapping_1__c, 'Property_Mapping_1__c'});
        caseNewValsM.put('PropertyMapping2', new List<String>{c.Property_Mapping_2__c, 'Property_Mapping_2__c'});
        caseNewValsM.put('PropertyMapping3', new List<String>{c.Property_Mapping_3__c, 'Property_Mapping_3__c'});
        caseNewValsM.put('PropertyMapping4', new List<String>{c.Property_Mapping_4__c, 'Property_Mapping_4__c'});
        caseNewValsM.put('PropertyMapping5', new List<String>{c.Property_Mapping_5__c, 'Property_Mapping_5__c'});
        System.debug('caseNewValsM ' + caseNewValsM);
        return caseNewValsM;
    }

    public static String getRallyPriorityMapping(String sSalesforceField, String sValue ){
        String sExternalValue='Medium';
        List<AH_Field_Mapping__mdt> fieldMapping= [SELECT Id,Label,Map_Value__c,MasterLabel,Salesforce_Field__c 
                    FROM AH_Field_Mapping__mdt 
                    WHERE Salesforce_Field__c=:sSalesforceField and MasterLabel=:sValue];
        if (fieldMapping.size()>0){
            sExternalValue=fieldMapping[0].Map_Value__c;
        }
        return sExternalValue;
    }

    public static String getSalesforceCasePriorityMapping(String sSalesforceField, String sExternalValue ){
        String sSalesforceValue='3 - Minor';
       List <AH_Field_Mapping__mdt> fieldMapping= [SELECT Id,Label,Map_Value__c,MasterLabel,Salesforce_Field__c 
                    FROM AH_Field_Mapping__mdt 
                    WHERE Salesforce_Field__c=:sSalesforceField and Map_Value__c=:sExternalValue];
        if (fieldMapping.size()>0){
            sSalesforceValue=fieldMapping[0].MasterLabel;
        }
        return sSalesforceValue;
    }
}