public class SME_CompetitiveAnalysisServiceCtrl {

    public static void assignCompetitor(List<SME_Competitive_Analysis__c>  newCompList){
         for(SME_Competitive_Analysis__c ca : newCompList){
            if(ca.SME_Competitor__c != null){
                ca.SME_Competitor_Account_Id__c = ca.SME_Competitor__c;
            }
        }
    }
}