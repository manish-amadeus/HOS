/************************************************************************************************
Name            : OrgApexBatch - Batch Class
Author          : Michael Pedro
Last Mod Date   : 05/05/2022
Last Mod By     : Michael Pedro
Description     : Batch class for org search apex metadata
*************************************************************************************************/
@IsTest
public class OrgApexBatch 
{   
    // need re-work to handle batchable data limits

    // global List<OrgInfoBatch.OrgApexClassQueryInfo> allOrgApexQueryInfo;
    
    // global OrgApexBatch(List<OrgInfoBatch.OrgApexClassQueryInfo> queryInfo) 
    // {
    //     this.allOrgApexQueryInfo = queryInfo;
    // }
    
    // global Iterable<OrgInfoBatch.OrgApexClassQueryInfo> start(Database.BatchableContext bc) 
    // {       
    //     return this.allOrgApexQueryInfo;
    // }

    // global void execute(Database.BatchableContext bc, List<OrgInfoBatch.OrgApexClassQueryInfo> orgApexClassesInfo) 
    // {
    //     for (OrgInfoBatch.OrgApexClassQueryInfo apexInfo: orgApexClassesInfo) {
    //       //  if (apexInfo.OrgInfoResult != null) {
    //             // upsert apex class 
    //             if (apexInfo.OrgApexClassResult != null) {
    //                 List<OrgApexClass__c> apexClassesForUpsert = new List<OrgApexClass__c>();
    //                 for (OrgApexClass__c ac :apexInfo.OrgApexClassResult) {
    //                     ac.OrgInfo__c = apexInfo.OrgInfoId;
    //                     apexClassesForUpsert.add(ac);
                        
    //                 }
                    
    //                 OrgNi.insertWithRetry(apexClassesForUpsert,3);
    //             }
    //             //Upsert apex triggers
    //             if (apexInfo.OrgApexTriggerResult != null) {
    //                 List<OrgApexTrigger__c> apexTriggersForUpsert = new List<OrgApexTrigger__c>();
    //                 for (OrgApexTrigger__c at :apexInfo.OrgApexTriggerResult) {
    //                     at.OrgInfo__c = apexInfo.OrgInfoId;
    //                     apexTriggersForUpsert.add(at); 
    //                 }
    //                 OrgNi.insertWithRetry(apexTriggersForUpsert,3);
    //             }
                
    //             //Upsert approval process
    //             if (apexInfo.OrgApprovalProcessResult != null) {
    //                 List<OrgApprovalProcess__c> approvalProcesssForUpsert = new List<OrgApprovalProcess__c>();
    //                 for (OrgApprovalProcess__c ap :apexInfo.OrgApprovalProcessResult) {
    //                     ap.OrgInfo__c = apexInfo.OrgInfoId;
    //                     approvalProcesssForUpsert.add(ap); 
    //                 }
    //                 OrgNi.insertWithRetry(ApprovalProcesssForUpsert,3);
    //             }
    //             //Upsert custom Objects
    //             if (apexInfo.OrgCustomObjectResult != null) {
    //                 List<OrgCustomObject__c> customObjectsForUpsert = new List<OrgCustomObject__c>();
    //                 for (OrgCustomObject__c co :apexInfo.OrgCustomObjectResult) {
    //                     co.OrgInfo__c = apexInfo.OrgInfoId;
    //                     CustomObjectsForUpsert.add(co); 
    //                 }
    //                 OrgNi.insertWithRetry(customObjectsForUpsert,3);
    //             }

    //             //Upsert custom Tabs
    //             if (apexInfo.OrgCustomTabResult != null) {
    //                 List<OrgCustomTab__c> customTabsForUpsert = new List<OrgCustomTab__c>();
    //                 for (OrgCustomTab__c co :apexInfo.OrgCustomTabResult) {
    //                     co.OrgInfo__c = apexInfo.OrgInfoId;
    //                     CustomTabsForUpsert.add(co); 
    //                 }
    //                 system.debug(logginglevel.info,'xxxx results to insert');
    //                     system.debug(logginglevel.info,customTabsForUpsert.size());
    //                 OrgNi.insertWithRetry(customTabsForUpsert,3);
    //             }
    //        // }
    //     }
    // }
    
    // global void finish(Database.BatchableContext bc)
    // {
    // }
    
}