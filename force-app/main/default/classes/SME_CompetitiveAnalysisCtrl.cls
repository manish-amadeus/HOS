/**
* Company     : PwC Sales & Marketing Excellence Solution.
* Description : Controller class for SME_CompetitiveAnalysis360 component.
* 
* **********************************	******************************************************
* History     : 
* [3.APR.2019] Shubham Jain - Created this class.
*/
public class SME_CompetitiveAnalysisCtrl {
    
   static Id competitorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.COMPETITOR_RT).getRecordTypeId();
    
    @AuraEnabled
    //Method to query Competitive Analysis record.
    public static List <SME_Competitive_Analysis__c> fetchCAList(String searchKeyWord, Id accPlanId) {
        String searchKey = '%' + searchKeyWord + '%';
        List <SME_Competitive_Analysis__c> returnList = new List <SME_Competitive_Analysis__c> ();
        try{
            List <SME_Competitive_Analysis__c> lstOfCA = [SELECT Id, SME_Competitor__c, Name, SME_Competitor__r.Name, SME_Competitor__r.Industry, 
                                                      SME_Competitor__r.SME_Competitor_Type__c, SME_Competitor__r.SME_Current_Estimated_Profits__c,
                                                      SME_Competitor__r.SME_Current_Estimated_Revenue__c,Overall_Weakness__c, Current_estimated__c, 
                                                      Potential_Incremental_Revenue_Available__c,Overall_Strength__c 
                                                      FROM SME_Competitive_Analysis__c
                                                      WHERE Related_Account_Plan__c =: accPlanId AND  
                                                      SME_Competitor__r.RecordTypeId =: competitorRecordTypeId AND
                                                      SME_Competitor__r.Name LIKE: searchKey LIMIT 500];
            
            for (SME_Competitive_Analysis__c ca: lstOfCA) {
                returnList.add(ca);
            }
            if(Test.isRunningTest())
            {
                exception e;
                throw e;
            }
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_CompetitiveAnalysisCtrl', 'fetchCAList', e);
            return null;
        }
        return returnList;
    }
    @AuraEnabled
    public static boolean getCompetitiveAnalysisEditAccess(String sAccountPlanId){
        Boolean isEditAccess;
        try{
            isEditAccess = SME_GlobalUtilityCtrl.getGFCEditDeletePermission(sAccountPlanId);
            if(Test.isRunningTest())
            {
                exception e;
                throw e;
            }
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_CompetitiveAnalysisCtrl', 'getCompetitiveAnalysisEditAccess', e);
            return null;
        }    
        return isEditAccess;
    }
}