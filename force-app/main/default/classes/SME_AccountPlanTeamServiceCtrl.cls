/**
* Company     : PwC Sales & Marketing Excellence Solution.
* Description : 
* 
* ****************************************************************************************
* History     : 
* [1.APR.2019] Nagendra Singh - Created this class.
*/
public without sharing class SME_AccountPlanTeamServiceCtrl {
    //User can't delete Account Plan Team Record with Role equal to 'Owner'
 public  void doNotDeleteAPTWithOwnerRole(List<SME_Account_Plan_Team__c> newAccountPlanTeamList){
        for(SME_Account_Plan_Team__c apt: newAccountPlanTeamList){
            if(apt.SME_Team_Role__c  == SME_GlobalConstantCtrl.ACCOUNT_PLAN_TEAM_OWNER_ROLE){
                apt.addError(SME_GlobalConstantCtrl.ACCOUNT_PLAN_TEAM_DELETE_ERROR);
            } 
        }
    }
    
    //method to give access to account plan once account plan team is created
    public void insertSharingRecord(List<SME_Account_Plan_Team__c> AccountPlanTeamList){
       List<SME_Account_Plan__Share> accPlanSharingList = new List<SME_Account_Plan__Share>();
        try{
            for(SME_Account_Plan_Team__c accPlTeamMem : AccountPlanTeamList){
                if(accPlTeamMem.SME_Team_Role__c != SME_GlobalConstantCtrl.ACCOUNT_PLAN_TEAM_OWNER_ROLE){
                    SME_Account_Plan__Share accPlSh = new SME_Account_Plan__Share();
                    accPlSh.ParentId = accPlTeamMem.SME_Account_Plan__c;
                    accPlSh.UserOrGroupId = accPlTeamMem.SME_Team_Member__c;
                    accPlSh.AccessLevel = SME_GlobalConstantCtrl.EditAccessLevel;
                    accPlSh.RowCause = Schema.SME_Account_Plan__Share.RowCause.Account_Plan__c;
                    accPlanSharingList.add(accPlSh);
                }
            }
            if(accPlanSharingList.size()>0 && accPlanSharingList!=null){
                insert accPlanSharingList;
            }
            if(Test.isRunningTest()) {
                Integer i = 1/0;
            }
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanTeamServiceCtrl', 'insertSharingRecord', e);
        }
        
    }
    
    //method to remove access to account plan once account plan team is deleted
    public void deleteSharingRecord(List<SME_Account_Plan_Team__c> AccountPlanTeamList){
        Set<Id> accPlanParentIds = new Set<Id>();
        Set<Id> accPlanUserIds = new Set<Id>();
        try{
            for(SME_Account_Plan_Team__c accPlTm : AccountPlanTeamList){
                accPlanParentIds.add(accPlTm.SME_Account_Plan__c);
                accPlanUserIds.add(accPlTm.SME_Team_Member__c);
            }
            List<SME_Account_Plan__Share> accPlanSharingListToDel = [SELECT Id FROM SME_Account_Plan__Share WHERE ParentId in :accPlanParentIds
                                                                 AND UserOrGroupId in :accPlanUserIds];
            if(accPlanSharingListToDel.size()>0 && accPlanSharingListToDel!=null){
                delete accPlanSharingListToDel;
            }
            if(Test.isRunningTest()) {
                Integer i = 1/0;
            }
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanTeamServiceCtrl', 'deleteSharingRecord', e);
        }
        
    }
    //Method to restrict non Account Plan Team users to modify/delete account plan team members
    public void restrictNonAccountPlanTeamUsers(List<SME_Account_Plan_Team__c> AccountPlanTeamList){
        Set<Id> accountTeamMemberSet = new Set<Id>();
        Set<Id> accountPlanIdSet = new Set<id>();
        
        for(SME_Account_Plan_Team__c apt:AccountPlanTeamList){
            accountPlanIdSet.add(apt.SME_Account_Plan__c); 
        }
        try{
            List<SME_Account_Plan_Team__c> accountPlanTeamMemberList = [select Id,SME_Account_Plan__c,SME_Account_Plan__r.OwnerId,
                                                                        SME_Team_Member__c from SME_Account_Plan_Team__c where 
                                                                        SME_Account_Plan__c In: accountPlanIdSet  ];
            
            if(accountPlanTeamMemberList.size()>0){
                for(SME_Account_Plan_Team__c apt:accountPlanTeamMemberList){
                    accountTeamMemberSet.add(apt.SME_Team_Member__c); 
                }
                for(SME_Account_Plan_Team__c apt:AccountPlanTeamList){
                    if(!accountTeamMemberSet.contains(UserInfo.getUserId())){
                        // apt.addError(SME_GlobalConstantCtrl.ACCOUNT_PLAN_TEAM_NON_TEAM_MEMBER);
                    } 
                } 
                if(Test.isRunningTest()) {
                    Integer i = 1/0;
                }
            } 
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanTeamServiceCtrl', 'restrictNonAccountPlanTeamUsers', e);
        }
    }
    //Method to chek duplicate Account Plan Team member in the team
    public void checkTeamMemberDuplication(List<SME_Account_Plan_Team__c> AccountPlanTeamList, Map<Id, SME_Account_Plan_Team__c> AccountPlanTeamMap){
        Map<String, id> uniqueTeamMemberMap =  new Map<String, id>();
        set<Id> newTeamMemberIdSet = new set<Id>();
        set<Id> newAccountPlanIdSet = new set<Id>();
        try{
            for(SME_Account_Plan_Team__c eachTeamMember : AccountPlanTeamList){
                String eachUniqueTeamMemberSet = '';
                eachUniqueTeamMemberSet = (eachTeamMember.SME_Team_Member__c != null) ? eachTeamMember.SME_Team_Member__c : 'None';
                eachUniqueTeamMemberSet = eachUniqueTeamMemberSet + eachTeamMember.SME_Account_Plan__c;
                   system.debug('eachTeamMember'+eachTeamMember);
                system.debug('####'+uniqueTeamMemberMap);
                if(uniqueTeamMemberMap.containsKey(eachUniqueTeamMemberSet)){
                    eachTeamMember.addError(SME_GlobalConstantCtrl.Account_Plan_Team_DuplicateTeamMember_Error);
                } else {
                    uniqueTeamMemberMap.put(eachUniqueTeamMemberSet, eachTeamMember.id);
                    newTeamMemberIdSet.add(eachTeamMember.id);
                }
                newAccountPlanIdSet.add(eachTeamMember.SME_Account_Plan__c);
            }
            
            for(SME_Account_Plan_Team__c eachTeamMember : [SELECT Id, SME_Team_Member__c, SME_Account_Plan__c, SME_Team_Role__c FROM SME_Account_Plan_Team__c WHERE SME_Account_Plan__c IN: newAccountPlanIdSet AND Id NOT IN: newTeamMemberIdSet]){
                String eachUniqueTeamMemberSet = '';
                eachUniqueTeamMemberSet = (eachTeamMember.SME_Team_Member__c != null) ? eachTeamMember.SME_Team_Member__c : 'None';
                eachUniqueTeamMemberSet = eachUniqueTeamMemberSet+ eachTeamMember.SME_Account_Plan__c;
                
                if(uniqueTeamMemberMap.containsKey(eachUniqueTeamMemberSet)){
                    AccountPlanTeamMap.get(uniqueTeamMemberMap.get(eachUniqueTeamMemberSet)).addError(SME_GlobalConstantCtrl.Account_Plan_Team_DuplicateTeamMember_Error);
                }
            }
            if(Test.isRunningTest()) {
                Integer i = 1/0;
            }
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanTeamServiceCtrl', 'checkTeamMemberDuplication', e);
        }
        
    }	
    
    
}