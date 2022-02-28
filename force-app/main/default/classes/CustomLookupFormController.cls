/**
 *
 */
public with sharing class CustomLookupFormController {
    

    private final static Integer iMaxResult = 5;
    /***
    * get user LookupSearchResult list
    *@param sSearchTerm search condition
    *@return user LookupSearchResult list
    */
    @AuraEnabled
    public static List<LookupSearchResult> searchAccount(String searchTerm) {
        System.debug('searchUser');
        // Prepare query paramters
        searchTerm += '*';
        
        // Execute search query
        List<List<SObject>> listSearchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
            Account (Id, Name WHERE RecordType.Name='Competitor'
              )
            LIMIT :iMaxResult];
        
        // Prepare listResults
        List<LookupSearchResult> listResults = new List<LookupSearchResult>();
        /*Id currentUser = UserInfo.getUserId();
        listResults.add(new LookupSearchResult(currentUser, 'User', '', 'DemoUser', 'demo.user@pwc.com'));*/

        // Extract Retail Stores & convert them into LookupSearchResult
        String sUserIcon = 'standard:account';
        Account [] listAccts = ((List<Account>) listSearchResults[0]);
        for (Account ur :listAccts) {
            listResults.add(new LookupSearchResult(ur.Id, 'SME_Competitor__c', sUserIcon, ur.Name, ''));
        }

        return listResults;
    }

     @AuraEnabled
    public static List<LookupSearchResult> searchAccPlan(String searchTerm) {
        System.debug('searchUser');
        // Prepare query paramters
        searchTerm += '*';
        
        // Execute search query
        List<List<SObject>> listSearchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
            SME_Account_Plan__c (Id, Name
              )
            LIMIT :iMaxResult];
        
        // Prepare listResults
        List<LookupSearchResult> listResults = new List<LookupSearchResult>();
        /*Id currentUser = UserInfo.getUserId();
        listResults.add(new LookupSearchResult(currentUser, 'User', '', 'DemoUser', 'demo.user@pwc.com'));*/

        // Extract Retail Stores & convert them into LookupSearchResult
        String sUserIcon = 'standard:account';
        SME_Account_Plan__c [] listAccPlans = ((List<SME_Account_Plan__c>) listSearchResults[0]);
        for (SME_Account_Plan__c ur :listAccPlans) {
            listResults.add(new LookupSearchResult(ur.Id, 'SME_Account_Plan__c', sUserIcon, ur.Name, ''));
        }

        return listResults;
    }

    @AuraEnabled
    public static List<LookupSearchResult> getDefaultParentAccPlan(String recordId){
        List<SME_Account_Plan__c> acctPlan = [SELECT Id,Name FROM SME_Account_Plan__c WHERE Id =:recordId];
         // Prepare listResults
        List<LookupSearchResult> listResults = new List<LookupSearchResult>();
        /*Id currentUser = UserInfo.getUserId();
        listResults.add(new LookupSearchResult(currentUser, 'User', '', 'DemoUser', 'demo.user@pwc.com'));*/

        // Extract Retail Stores & convert them into LookupSearchResult
        String sUserIcon = 'standard:account';
        for (SME_Account_Plan__c ur :acctPlan) {
            listResults.add(new LookupSearchResult(ur.Id, 'SME_Account_Plan__c', sUserIcon, ur.Name, ''));
        }
        return listResults;
    }

}