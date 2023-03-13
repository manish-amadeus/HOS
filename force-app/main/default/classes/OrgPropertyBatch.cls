/************************************************************************************************
Name            : OrgPropertyBatch - Batch Class
Author          : Michael Pedro
Last Mod Date   : 05/05/2022
Last Mod By     : Michael Pedro
Description     : Property related object batch class for org search
*************************************************************************************************/
@IsTest
public class OrgPropertyBatch
{   
    // need re-work to handle batchable data limits

    // global List<OrgInfoBatch.OrgPropertyQueryInfo> allOrgPropertyQueryInfo;
    
    // global OrgPropertyBatch(List<OrgInfoBatch.OrgPropertyQueryInfo> queryInfo) 
    // {
    //     this.allOrgPropertyQueryInfo = queryInfo;
    // }
    
    // global Iterable<OrgInfoBatch.OrgPropertyQueryInfo> start(Database.BatchableContext bc) 
    // {       
    //     return this.allOrgPropertyQueryInfo;
    // }

    // global void execute(Database.BatchableContext bc, List<OrgInfoBatch.OrgPropertyQueryInfo> orgPropertiesInfo) 
    // {
    //     for (OrgInfoBatch.OrgPropertyQueryInfo propInfo: orgPropertiesInfo) {
    //        // if (propInfo.OrgInfoResult != null) {
    //             // upsert properties
    //             if (propInfo.OrgPropertyResult != null) {
    //                 List<OrgProperty__c> propsForUpsert = new List<OrgProperty__c>();
    //                 for (OrgProperty__c p :propInfo.OrgPropertyResult) {
    //                     p.OrgInfo__c = propInfo.OrgInfoId;
    //                     propsForUpsert.add(p);
    //                 }
    //                 OrgNi.insertWithRetry(propsForUpsert,3);
    //             }
    //             // upsert property integrations
    //             if (propInfo.orgPropertyIntegrationSettingResult != null) {
    //                 List<OrgPropertyIntegrationSetting__c> propertyIntForUpsert = new List<OrgPropertyIntegrationSetting__c>();
    //                 for (OrgPropertyIntegrationSetting__c pi :propInfo.orgPropertyIntegrationSettingResult) {
    //                     pi.OrgInfo__c = propInfo.OrgInfoId;
    //                     propertyIntForUpsert.add(pi);
    //                 }
    //                 OrgNi.insertWithRetry(propertyIntForUpsert,3);
    //             }

    //             if (propInfo.OrgPropertyMenuItemCountsResult != null) {
    //                 List<OrgPropMenuItemCount__c> propMenuCounts = new List<OrgPropMenuItemCount__c>();
    //                 for (OrgPropMenuItemCount__c pmc :propInfo.OrgPropertyMenuItemCountsResult) {
    //                     pmc.OrgInfo__c = propInfo.OrgInfoId;
    //                     propMenuCounts.add(pmc);
    //                 }
    //                 OrgNi.insertWithRetry(propMenuCounts,3);
    //             }

    //             if (propInfo.OrgPropDocumentTemplateResult != null) {
    //                 List<OrgPropDocTemplateCount__c> docTemps = new List<OrgPropDocTemplateCount__c>();
    //                 for (OrgPropDocTemplateCount__c dt :propInfo.OrgPropDocumentTemplateResult) {
    //                     dt.OrgInfo__c = propInfo.OrgInfoId;
    //                     docTemps.add(dt);
    //                 }
    //                 OrgNi.insertWithRetry(docTemps,3);
    //             }

    //             if (propInfo.OrgSetupValueResult != null) {
    //                 List<OrgSetupValue__c> svs = new List<OrgSetupValue__c>();
    //                 for (OrgSetupValue__c sv :propInfo.OrgSetupValueResult) {
    //                     sv.OrgInfo__c = propInfo.OrgInfoId;
    //                     svs.add(sv);
    //                 }
    //                 OrgNi.insertWithRetry(svs,3);
    //             }
    //      //   }
    //     }
    // }
    
    // global void finish(Database.BatchableContext bc)
    // {
    // }
    
}