/**
* Company     : PwC Sales & Marketing Excellence Solution.
* Description : 
* 
* ****************************************************************************************
* History     : 
* [17.APR.2019] Nagendra - Created this class.
*/
public class SME_GSOTabCtrl {
    public class AccountPlanInfoWrapper{
        @AuraEnabled public Map<String,List<GSOTInfoWrapper>> accountPlanInfoWrapperMap;
        @AuraEnabled public List<GSOTInfoWrapper> objectivesList;
        @AuraEnabled public List<GSOTInfoWrapper> goalsList;
        @AuraEnabled public List<GSOTInfoWrapper> strategiesList;
        @AuraEnabled public List<GSOTInfoWrapper> actionList;
        @AuraEnabled public List<ownerListWrapper> aptMembers;
        
        @AuraEnabled public Id objectiveRecordTypeId;
        @AuraEnabled public Id goalRecordTypeId;
        @AuraEnabled public Id strategyRecordTypeId;
    }
    public class ownerListWrapper{
        @AuraEnabled public String OwnerId;
        @AuraEnabled public String Name;
        public ownerListWrapper(String Owner,String sOwnerName){
            this.OwnerId = Owner;
            this.Name = sOwnerName;
        }
    }
    //Wrapper to collect all the data required on component 
    public class GSOTInfoWrapper{
        @AuraEnabled public String Type;
        @AuraEnabled public Integer Open;
        @AuraEnabled public Integer Achieved;
        
        @AuraEnabled public Date DueDate;
        @AuraEnabled public String Owner;
        @AuraEnabled public Integer NoOfActions;
        @AuraEnabled public String Status;
        @AuraEnabled public String Priority;
        @AuraEnabled public String Description;
        @AuraEnabled public SME_Account_Plan_GSOT__c objGSOT;
        
        @AuraEnabled public String Link;
        @AuraEnabled public String Subject;
        @AuraEnabled public String AssignedTo;
        
        @AuraEnabled public String Name;
        @AuraEnabled public String RelatedTo;
        
        
        public GSOTInfoWrapper(String sType,Integer cOpen,Integer cAchieved){
            this.Type= sType;
            this.Open= cOpen;
            this.Achieved= cAchieved;                         
        }
        public GSOTInfoWrapper(Date dDueDate,String sOwner,Integer cNoOfActions,String sStatus,
                               String sPriority,String sDescription,String sType,String sName,
                               SME_Account_Plan_GSOT__c obj){
                                   this.DueDate= dDueDate;
                                   this.Owner= sOwner;
                                   this.NoOfActions= cNoOfActions;
                                   this.Status= sStatus; 
                                   this.Priority = sPriority; 
                                   this.Description = sDescription;
                                   this.Type = sType;
                                   this.Name = sName;
                                   this.objGSOT = obj;
                                   
                                   
                               }
        public GSOTInfoWrapper(String sAction,String sSubject,String sAssignedTo,String sStatus,String sType,
                               Date dDueDate,String sRelatedTo){
                                   this.DueDate= dDueDate;
                                   this.Link= sAction;
                                   this.Subject= sSubject;
                                   this.AssignedTo= sAssignedTo; 
                                   this.Status = sStatus;     
                                   this.Type = sType;
                                   this.RelatedTo = sRelatedTo;
                               }
        
    }
    //Method to get GSOT obejct info 
    @AuraEnabled
    public static AccountPlanInfoWrapper getGSOTInfo(String accountPlanId){
        String url= string.valueof(URL.getOrgDomainUrl());
        String url1 = url.substringBefore('.');
        String domain =url1.split('=')[1];
        map<Id,String> objectiveGSOTIds = new   map<Id,String>();
        List<GSOTInfoWrapper> goalTableList = new List<GSOTInfoWrapper>();
        map<String,GSOTInfoWrapper> countGoalTableMap = new map<String,GSOTInfoWrapper> ();
        map<String,GSOTInfoWrapper> countStartegyTableMap = new map<String,GSOTInfoWrapper> ();
        map<String,GSOTInfoWrapper> countObjectiveTableMap = new map<String,GSOTInfoWrapper> ();
        
        AccountPlanInfoWrapper accPlanInfoWrapper= new AccountPlanInfoWrapper();
        accPlanInfoWrapper.accountPlanInfoWrapperMap = new Map<String,List<GSOTInfoWrapper>>();
        accPlanInfoWrapper.objectivesList = new List<GSOTInfoWrapper>();
        accPlanInfoWrapper.goalsList = new List<GSOTInfoWrapper>();
        accPlanInfoWrapper.strategiesList = new List<GSOTInfoWrapper>();
        accPlanInfoWrapper.actionList = new List<GSOTInfoWrapper>();
        
        try{
        Id goalRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GOALS_RT).getRecordTypeId();
        Id startegyRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GSOT_STRATEGY_RECORD_TYPE).getRecordTypeId();
        Id objectiveRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GSOT_OBJECTIVE_RECORD_TYPE).getRecordTypeId();
        
        String query = 'Select id,SME_Priority__c, Name,Owner.Name ,(Select id from Tasks),SME_Goal_Name__c,RecordTypeId,SME_Due_Date__c,SME_Description__c,SME_Objective_Name__c,SME_Status__c,SME_Strategy_Name__c,SME_Type__c,SME_Owner_Start_Date__c from SME_Account_Plan_GSOT__c ';
        List<SME_Account_Plan_GSOT__c> gsotList= Database.query(query + ' where SME_Account_Plan__c =\''+accountPlanId+'\'');
        
        for(SME_Account_Plan_GSOT__c gsot:gsotList){
            if(gsot.RecordTypeId == goalRecordTypeId){
                accPlanInfoWrapper.goalsList.add(new GSOTInfoWrapper(gsot.SME_Due_Date__c,gsot.Owner.Name,gsot.Tasks.size(),gsot.SME_Status__c,gsot.SME_Priority__c,gsot.SME_Description__c,gsot.SME_Type__c,gsot.SME_Goal_Name__c,gsot)); 
                if(countGoalTableMap.containskey(gsot.SME_Type__c)) {
                    if(gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_ACHIEVED &&
                       gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_CANCELED){
                           GSOTInfoWrapper gsotInfo = countGoalTableMap.get(gsot.SME_Type__c);
                           gsotInfo.Open =  gsotInfo.Open +1;
                           countGoalTableMap.put(gsot.SME_Type__c,gsotInfo); 
                       }else if(gsot.SME_Status__c == SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_ACHIEVED){
                           GSOTInfoWrapper gsotInfo = countGoalTableMap.get(gsot.SME_Type__c);
                           gsotInfo.Achieved =  gsotInfo.Achieved +1;
                           countGoalTableMap.put(gsot.SME_Type__c,gsotInfo); 
                       }
                }else{
                    if(gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_ACHIEVED &&
                       gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_CANCELED){
                           countGoalTableMap.put(gsot.SME_Type__c,new GSOTInfoWrapper(gsot.SME_Type__c,1,0)); 
                       }else if(gsot.SME_Status__c == SME_GlobalConstantCtrl.GSOT_Status_Picklist_Value_Achieved){
                           countGoalTableMap.put(gsot.SME_Type__c,new GSOTInfoWrapper(gsot.SME_Type__c,0,1)); 
                       }
                    
                }
                
            }else if(gsot.RecordTypeId == startegyRecordTypeId){
                accPlanInfoWrapper.strategiesList.add(new GSOTInfoWrapper(gsot.SME_Due_Date__c,gsot.Owner.Name,gsot.Tasks.size(),gsot.SME_Status__c,gsot.SME_Priority__c,gsot.SME_Description__c,gsot.SME_Type__c,gsot.SME_Strategy_Name__c,gsot));  
                if(countStartegyTableMap.containskey(gsot.SME_Type__c)) {
                    if(gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_Status_Picklist_Value_Achieved &&
                       gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_CANCELED){
                           GSOTInfoWrapper gsotInfo = countStartegyTableMap.get(gsot.SME_Type__c);
                           gsotInfo.Open =  gsotInfo.Open +1;
                           countStartegyTableMap.put(gsot.SME_Type__c,gsotInfo); 
                       }else if(gsot.SME_Status__c == SME_GlobalConstantCtrl.GSOT_Status_Picklist_Value_Achieved){
                           GSOTInfoWrapper gsotInfo = countStartegyTableMap.get(gsot.SME_Type__c);
                           gsotInfo.Achieved =  gsotInfo.Achieved +1;
                           countStartegyTableMap.put(gsot.SME_Type__c,gsotInfo); 
                       }
                }else{
                    if(gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_Status_Picklist_Value_Achieved &&
                       gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_CANCELED){
                           countStartegyTableMap.put(gsot.SME_Type__c,new GSOTInfoWrapper(gsot.SME_Type__c,1,0)); 
                       }else if(gsot.SME_Status__c == SME_GlobalConstantCtrl.GSOT_Status_Picklist_Value_Achieved){
                           countStartegyTableMap.put(gsot.SME_Type__c,new GSOTInfoWrapper(gsot.SME_Type__c,0,1)); 
                       }
                    
                }
                
            }else if(gsot.RecordTypeId == objectiveRecordTypeId){
                objectiveGSOTIds.put(gsot.id,gsot.SME_Objective_Name__c);
                accPlanInfoWrapper.objectivesList.add(new GSOTInfoWrapper(gsot.SME_Due_Date__c,gsot.Owner.Name,gsot.Tasks.size(),gsot.SME_Status__c,gsot.SME_Priority__c,gsot.SME_Description__c,gsot.SME_Type__c,gsot.SME_Objective_Name__c,gsot)); 
                if(countObjectiveTableMap.containskey(gsot.SME_Type__c)) {
                    if(gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_ACHIEVED &&
                       gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_CANCELED){
                           GSOTInfoWrapper gsotInfo = countObjectiveTableMap.get(gsot.SME_Type__c);
                           gsotInfo.Open =  gsotInfo.Open +1;
                           countObjectiveTableMap.put(gsot.SME_Type__c,gsotInfo); 
                       }else if(gsot.SME_Status__c ==SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_ACHIEVED){
                           GSOTInfoWrapper gsotInfo = countObjectiveTableMap.get(gsot.SME_Type__c);
                           gsotInfo.Achieved =  gsotInfo.Achieved +1;
                           countObjectiveTableMap.put(gsot.SME_Type__c,gsotInfo); 
                       }
                }else{
                    if(gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_ACHIEVED &&
                       gsot.SME_Status__c != SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_CANCELED){
                           countObjectiveTableMap.put(gsot.SME_Type__c,new GSOTInfoWrapper(gsot.SME_Type__c,1,0)); 
                       }else if(gsot.SME_Status__c == SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_ACHIEVED){
                           countObjectiveTableMap.put(gsot.SME_Type__c,new GSOTInfoWrapper(gsot.SME_Type__c,0,1)); 
                       }
                } 
            }
        }
        
        for(Task t :[Select id,whatId,Subject,Status,Owner.Name,ActivityDate,Type from Task where whatId in :objectiveGSOTIds.keyset()]){
            String link=domain+'.lightning.force.com/lightning/r/Task/'+t.id+'/view';
            accPlanInfoWrapper.actionList.add(new GSOTInfoWrapper(link,t.Subject,t.Owner.Name,t.Status,t.Type,t.ActivityDate,objectiveGSOTIds.get(t.whatId)) );
        }
        for(Event e :[Select id,WhatId,Subject,Owner.Name,ActivityDate,Type from Event where whatId in :objectiveGSOTIds.keyset()]){
            
            String link=domain+'.lightning.force.com/lightning/r/Event/'+e.id+'/view';
            accPlanInfoWrapper.actionList.add(new GSOTInfoWrapper(link,e.Subject,e.Owner.Name,null,e.Type,e.ActivityDate,objectiveGSOTIds.get(e.whatId)) );
        }
        accPlanInfoWrapper.aptMembers = new List<ownerListWrapper>();
        for(SME_Account_Plan_Team__c apt:[Select id,SME_Team_Member__c,SME_Team_Member__r.Name from SME_Account_Plan_Team__c
                                          where SME_Account_Plan__c=:accountPlanId ]){
                                              accPlanInfoWrapper.aptMembers.add(new ownerListWrapper(apt.SME_Team_Member__r.Name,apt.SME_Team_Member__r.Name));
                                          }
        accPlanInfoWrapper.objectiveRecordTypeId = objectiveRecordTypeId;
        accPlanInfoWrapper.goalRecordTypeId = goalRecordTypeId;
        accPlanInfoWrapper.strategyRecordTypeId = startegyRecordTypeId;
        
        
        accPlanInfoWrapper.accountPlanInfoWrapperMap.put(SME_GlobalConstantCtrl.GSOT_GOAL_TABLE_NAME,countGoalTableMap.values());
        accPlanInfoWrapper.accountPlanInfoWrapperMap.put(SME_GlobalConstantCtrl.GSOT_STRATEGY_TABLE_NAME,countStartegyTableMap.values());
        accPlanInfoWrapper.accountPlanInfoWrapperMap.put(SME_GlobalConstantCtrl.GSOT_OBJECTIVE_TABLE_NAME,countObjectiveTableMap.values());
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SMEGSOTabCtrl', 'getGSOTInfo', e);
            return null;
        } 
        return accPlanInfoWrapper;
    }
    //Method to delete GSOT record
    @AUraEnabled
    public static void deleteGSOT(String gsotId){
        SME_Account_Plan_GSOT__c obj = [Select Id from SME_Account_Plan_GSOT__c where id =: gsotId];
        try{
            Delete obj ;
        }catch(Exception e){
            System.debug(e.getMessage());
            SME_GlobalExceptionHandlerCtrl.processException('SME_GSOTabCtrl', 'deleteGSOT', e);        
        }
        
    }
     @AuraEnabled
    public static String getTypePicklistVal( String recordTypeDeveloperName){
         list<Options> picklistValues = new list<Options>();
         SME_GSOT_Type__mdt gsotTypecustommetadata= [Select id,GSOT_Record_Type_Name__c,SME_GSOT_Type_Values__c from SME_GSOT_Type__mdt where DeveloperName =:recordTypeDeveloperName Limit 1];
         
        List<String> typeVal;
        if(gsotTypecustommetadata.SME_GSOT_Type_Values__c !=null){
            typeVal = gsotTypecustommetadata.SME_GSOT_Type_Values__c.split(';');
        }
        for(String s:typeVal ){
            Options pickVal = new Options();
            pickVal.value = s;
            pickVal.label =s;
            picklistValues.add(pickVal);
        }
        return JSON.serialize(picklistValues);       
    }
    //Method to check Account plan has edit/ delete access or not 
    @AuraEnabled
    public static boolean getGSOEditAccess(String sAccountPlanId){
        Boolean getGSOEdit;
        try{
        getGSOEdit = SME_GlobalUtilityCtrl.getGFCEditDeletePermission(sAccountPlanId);
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_GSO_TabCtrl', 'getGSOEditAccess', e);        
        }
        return getGSOEdit;
    }
     @AuraEnabled 
    public static List<Options> getStatus(){
        List<Options> options= new List<Options>();
        Schema.DescribeFieldResult fieldResult = SME_Account_Plan_GSOT__c.SME_Status__c.getDescribe();
       
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            Options option = new Options();
            option.label =  p.getLabel();
            option.value =  p.getValue();
            option.selectedVal = false;
            options.add(option);
        }
        return options;
    }
   /* @AuraEnabled 
    public static string getPicklistValueBasedonRecordType(String objectAPIName, String fieldAPIName, String recordTypeDeveloperName){
     return  SME_PicklistBasedOnRTypeCtrl.getPicklistValueBasedonRecordType(objectAPIName,fieldAPIName,recordTypeDeveloperName);
    }*/
    @AuraEnabled 
    public static List<Options> getPriority(){
        List<Options> options= new List<Options>();
        Schema.DescribeFieldResult fieldResult = SME_Account_Plan_GSOT__c.SME_Priority__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            Options option = new Options();
            option.label =  p.getLabel();
            option.value =  p.getValue();
            if(option.value == 'Medium'){
                 option.selectedVal = true;
            }else{
                 option.selectedVal = false;
            }
           
            options.add(option);
        }
        return options;
    }
    public class Options{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean selectedVal;
    }
}