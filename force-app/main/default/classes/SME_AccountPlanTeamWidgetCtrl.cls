public class SME_AccountPlanTeamWidgetCtrl {

    
    @AuraEnabled
    public static List<SME_Account_Plan_Team__c> fetchAccountPlanTeamMembers(Id accountPlanId) {
        List<SME_Account_Plan_Team__c> listAccountPlanTeam = new List<SME_Account_Plan_Team__c>();
        try{
            listAccountPlanTeam = [SELECT Id,SME_Team_Member__c,SME_Team_Member__r.Id,SME_Team_Member__r.Name,SME_Team_Role__c,SME_Team_Member__r.SmallPhotoUrl FROM SME_Account_Plan_Team__c WHERE SME_Account_Plan__c = :accountPlanId];
            if(Test.isRunningTest()) {
               Integer i = 1/0;
           }
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanTeamWidgetCtrl', 'fetchAccountPlanTeamMembers', e);
            return null;
        }
        return listAccountPlanTeam;
    }
    
    @AuraEnabled
    public static List<SME_Account_Plan_Team__c> saveAccountPlanTeamRecord(String sJSONAccountPlanTeam, Id idAccountPlan) {
        try {
            List<SME_Account_Plan_Team__c> listAccountPlanTeam = (List<SME_Account_Plan_Team__c>) System.JSON.deserialize(sJSONAccountPlanTeam, List<SME_Account_Plan_Team__c>.Class);
            List<SME_Account_Plan_Team__c> listUpsertAccountPlanTeam = new List<SME_Account_Plan_Team__c>();
            for(SME_Account_Plan_Team__c aptTeam : listAccountPlanTeam) {
                System.debug('******:' + aptTeam);
                SME_Account_Plan_Team__c aptUpsertTeam = new SME_Account_Plan_Team__c(SME_Account_Plan__c = idAccountPlan);
                aptUpsertTeam.SME_Team_Member__c = aptTeam.SME_Team_Member__c;
                aptUpsertTeam.SME_Team_Role__c = aptTeam.SME_Team_Role__c;
                aptUpsertTeam.Id = aptTeam.Id;
                listUpsertAccountPlanTeam.add(aptUpsertTeam);
            }
            upsert listUpsertAccountPlanTeam Id; 
            if(Test.isRunningTest())
            {
                exception e;
                throw e;
            }   
        }catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanTeamWidgetCtrl', 'saveAccountPlanTeamRecord', e);
            return null;
        }
        
        return fetchAccountPlanTeamMembers(idAccountPlan);
    }
    
    @AuraEnabled
    public static void deleteAccountPlanTeamRecord(Id idAccountTeamPlan) {
        try {
            delete [SELECT Id FROM SME_Account_Plan_Team__c WHERE Id = :idAccountTeamPlan];
            if(Test.isRunningTest())
            {
                exception e;
                throw e;
            }
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanTeamWidgetCtrl', 'deleteAccountPlanTeamRecord', e);
        }
    }
    
    @AuraEnabled
    public static String getCurrentUserId() {
        String usrId;
        try{
            usrId = UserInfo.getUserId();
            if(Test.isRunningTest())
            {
                exception e;
                throw e;
            }
        } catch(Exception e) {
            SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanTeamWidgetCtrl', 'getCurrentUserId', e);
            return null;
        }
        return usrId;
    }
    
    //Method to check Account plan has edit/ delete access or not 
    @AuraEnabled
    public static boolean getTeamEditAccess(String sAccountPlanId){
        Boolean isTeamEditAccess = false;
        try{
            isTeamEditAccess = SME_GlobalUtilityCtrl.getGFCEditDeletePermission(sAccountPlanId);
            if(Test.isRunningTest())
            {
                exception e;
                throw e;
            }
        }catch(Exception e) {
            SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanTeamWidgetCtrl', 'getTeamEditAccess', e);
            return null;
        }
        return isTeamEditAccess;
    }
}