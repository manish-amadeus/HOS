/************************************************************************************************
Name            : OrgUserBatch - Batch class
Author          : Michael Pedro
Last Mod Date   : 05/05/2022
Last Mod By     : Michael Pedro
Description     : User related object batch class for org search
*************************************************************************************************/
@IsTest
public class OrgUserBatch
{   
        // need re-work to handle batchable data limits


    // global List<OrgInfoBatch.OrgUserQueryInfo> allOrgUserQueryInfo;
    // //global List<OrgInfoBatch.OrgApexClassQueryInfo> allOrgApexClassQueryInfo = new List<OrgInfoBatch.OrgApexClassQueryInfo>();

      
    // global OrgUserBatch(List<OrgInfoBatch.OrgUserQueryInfo> queryInfo) 
    // {
    //     this.allOrgUserQueryInfo = queryInfo;
    // }
    
    // global Iterable<OrgInfoBatch.OrgUserQueryInfo> start(Database.BatchableContext bc) 
    // {       
    //    return this.allOrgUserQueryInfo;
    // }

    // global void execute(Database.BatchableContext bc, List<OrgInfoBatch.OrgUserQueryInfo> orgUsersInfo) 
    // {
    //     // upsert all users with asem profiles
    //     for (OrgInfoBatch.OrgUserQueryInfo userInfo: orgUsersInfo) {
    //         // if (userInfo.OrgInfoResult != null) {
    //            if (userInfo.OrgUserResult != null) {
    //                 List<OrgUser__c> usersForUpsert = new List<OrgUser__c>();
    //                 for (OrgUser__c u :userInfo.OrgUserResult) {
    //                     u.OrgInfo__c = userInfo.OrgInfoId;
    //                     usersForUpsert.add(u);
    //                 }
    //                 OrgNi.insertWithRetry(usersForUpsert,3);
    //             }
    //             // Upsert profiles 
    //             if (userInfo.OrgProfileResult != null) {
    //                 List<OrgProfile__c> profilesForUpsert = new List<OrgProfile__c>();
    //                 for (OrgProfile__c p :userInfo.OrgprofileResult) {
    //                     p.OrgInfo__c = userInfo.OrgInfoId;
    //                     profilesForUpsert.add(p);
    //                 }
    //                 OrgNi.insertWithRetry(profilesForUpsert,3);
    //             }
                
    //             // Upsert custom fields
    //             if (userInfo.OrgCustomFieldResult != null) {
    //                 List<OrgCustomField__c> customFieldsForUpsert = new List<OrgCustomField__c>();
    //                 for (OrgCustomField__c p :userInfo.OrgcustomFieldResult) {
    //                     p.OrgInfo__c = userInfo.OrgInfoId;
    //                     customFieldsForUpsert.add(p);
    //                 }
    //                 OrgNi.insertWithRetry(customFieldsForUpsert,3);
                   
    //             }
    //       //  }
    //     }
    // }
    
    // global void finish(Database.BatchableContext bc)
    // {
    //    /* system.debug(logginglevel.info,'xxxfinish user batch');
    //     system.debug(logginglevel.info,this.allOrgApexClassQueryInfo);
        
    //     allOrgApexClassQueryInfo = OrgInfoBatch.orgInfoQuery.
    //     if (this.allOrgApexClassQueryInfo != null) {
    //        Database.executeBatch(new OrgApexBatch(this.allOrgApexClassQueryInfo), 1);
    //     }*/
    // }
    
}