/**
 * Company     : PwC Sales & Marketing Excellence Solution.
 * Description : 
 * 
 * ****************************************************************************************
 * History     : 
 * [24.Jun.2019] Nagendra Singh - Written logic to Sync Type and Strategy Type,Objective Type fields.
 */
public class SME_AccountPlanGSOTServiceCtrl {
    
    //Sync Type field of GSO -Start [24.Jun.2019] Nagendra Singh 
     public static void checkDuplicateGSO(List<SME_Account_Plan_GSOT__c> newGSOTList,Map<Id,SME_Account_Plan_GSOT__c> oldGSOMap){
        Id goalRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GOALS_RT).getRecordTypeId();
        Id startegyRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GSOT_STRATEGY_RECORD_TYPE).getRecordTypeId();
        Id objectiveRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GSOT_OBJECTIVE_RECORD_TYPE).getRecordTypeId();
        Set<Id> accPlanIds = new Set<id>();
        Set<String> typeValSet = new Set<String>();
        Set<String> nameValSet = new Set<String>();
        for(SME_Account_Plan_GSOT__c newGSO : newGSOTList){
            accPlanIds.add(newGSO.SME_Account_Plan__c);
            typeValSet.add(newGSO.SME_Type__c);                 
        }
        try{
            Map<id,SME_Account_Plan_GSOT__c> existingGSO = new  Map<id,SME_Account_Plan_GSOT__c>([select id,SME_Account_Plan__c,SME_Type__c,SME_Goal_Name__c,SME_Objective_Name__c,SME_Strategy_Name__c 
                                                                                                  from SME_Account_Plan_GSOT__c where SME_Account_Plan__c in :accPlanIds And SME_Type__c in : typeValSet ]);
            System.debug('existingGSO' + existingGSO);
            
            Integer i=0;
            for(SME_Account_Plan_GSOT__c newGSO : newGSOTList){
                
                for(Id gsoId : existingGSO.keyset()){
                    if(goalRecordTypeId == newGSO.RecordTypeId && 
                       existingGSO.get(gsoId).SME_Goal_Name__c == newGSO.SME_Goal_Name__c &&
                       existingGSO.get(gsoId).SME_Type__c == newGSO.SME_Type__c &&
                       newGSO.Id != gsoId){
                           
                           Trigger.new[i].addError(Label.GSO_Duplicate_Error);
                           
                    }else if(objectiveRecordTypeId == newGSO.RecordTypeId && 
                             existingGSO.get(gsoId).SME_Objective_Name__c == newGSO.SME_Objective_Name__c &&
                             existingGSO.get(gsoId).SME_Type__c == newGSO.SME_Type__c&&
                             newGSO.Id != gsoId){
                             	Trigger.new[i].addError(Label.GSO_Duplicate_Error);    
                    }else if(startegyRecordTypeId == newGSO.RecordTypeId &&
                             existingGSO.get(gsoId).SME_Strategy_Name__c == newGSO.SME_Strategy_Name__c &&
                             existingGSO.get(gsoId).SME_Type__c == newGSO.SME_Type__c&&
                             newGSO.Id != gsoId){
                             	Trigger.new[i].addError(Label.GSO_Duplicate_Error);    
                    }
                }
                
                i++;
            }
        }
        catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanGSOTServiceCtrl', 'checkDuplicateGSO', e);
        }
    }
    //End of logic [24.Jun.2019] Nagendra Singh 
    
    //Method to roll up Goals/Strategies/Objectives on Account Plan
    public void rollUpSummary(List<SME_Account_Plan_GSOT__c> newGSOTList){
        SME_Account_Plan_GSOT__c[] objects = newGSOTList;
        String NonCompletedStatus1 = SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_DRAFT;
        String NonCompletedStatus2 = SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_IN_PROGRESS;
        String NonCompletedStatus3 = SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_NOT_COMPLETED;
        String CompletedStatus = SME_GlobalConstantCtrl.GSOT_STATUS_PICKLIST_VALUE_ACHIEVED;
        
        try{
        Id goalRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.Goals_RT).getRecordTypeId();
        Id  strategyRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GSOT_Strategy_Record_Type).getRecordTypeId();
        Id objectiveRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GSOT_Objective_Record_Type).getRecordTypeId();
       
        SME_LREngineCtrl.Context ctxIncompletedGoal = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                SME_Account_Plan_GSOT__c.SobjectType,  // child object
                                                Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.SME_Account_Plan__c, // relationship field name
                                                'SME_Account_Plan_GSOT__c.RecordTypeId = \''+goalRecordTypeId+'\' and  (( SME_Status__c  =\''+NonCompletedStatus1+'\' ) OR  ( SME_Status__c  =\''+NonCompletedStatus2+'\' ) OR  ( SME_Status__c  =\''+NonCompletedStatus3+'\' )) '                                              
                                                ); 
        
        SME_LREngineCtrl.Context ctxCompletedGoal = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                SME_Account_Plan_GSOT__c.SobjectType,  // child object
                                                Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.SME_Account_Plan__c, // relationship field name
                                                'SME_Account_Plan_GSOT__c.RecordTypeId = \''+goalRecordTypeId+'\' and ( SME_Status__c  =\''+CompletedStatus+'\' )  '                                              
                                                );
        SME_LREngineCtrl.Context ctxIncompletedStrategy = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                SME_Account_Plan_GSOT__c.SobjectType,  // child object
                                                Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.SME_Account_Plan__c, // relationship field name
                                                'SME_Account_Plan_GSOT__c.RecordTypeId = \''+strategyRecordTypeId+'\'   and ( ( SME_Status__c  =\''+NonCompletedStatus1+'\' ) OR  ( SME_Status__c  =\''+NonCompletedStatus2+'\' ) OR  ( SME_Status__c  =\''+NonCompletedStatus3+'\' )) '                                              
                                                ); 
       
        SME_LREngineCtrl.Context ctxCompletedStrategy = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                SME_Account_Plan_GSOT__c.SobjectType,  // child object
                                                Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.SME_Account_Plan__c, // relationship field name
                                                'SME_Account_Plan_GSOT__c.RecordTypeId = \''+strategyRecordTypeId+'\' and ( SME_Status__c  =\''+CompletedStatus+'\' )  '                                              
                                                );
        
        SME_LREngineCtrl.Context ctxIncompletedObjective = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                SME_Account_Plan_GSOT__c.SobjectType,  // child object
                                                Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.SME_Account_Plan__c, // relationship field name
                                                'SME_Account_Plan_GSOT__c.RecordTypeId = \''+objectiveRecordTypeId+'\'  and  (( SME_Status__c  =\''+NonCompletedStatus1+'\' ) OR  ( SME_Status__c  =\''+NonCompletedStatus2+'\' ) OR  ( SME_Status__c  =\''+NonCompletedStatus3+'\' )) '                                              
                                                ); 
       
        SME_LREngineCtrl.Context ctxCompletedObjective = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                SME_Account_Plan_GSOT__c.SobjectType,  // child object
                                                Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.SME_Account_Plan__c, // relationship field name
                                                'SME_Account_Plan_GSOT__c.RecordTypeId = \''+objectiveRecordTypeId+'\' and ( SME_Status__c  =\''+CompletedStatus+'\' )  '                                              
                                                );
        
        ctxIncompletedGoal.add(
        new SME_LREngineCtrl.RollupSummaryField(
            Schema.SObjectType.SME_Account_Plan__c.fields.SME_Non_Completed_Goals__c,
            Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.Name,
            SME_LREngineCtrl.RollupOperation.Count 
        ));
        
        ctxCompletedGoal.add(
        new SME_LREngineCtrl.RollupSummaryField(
            Schema.SObjectType.SME_Account_Plan__c.fields.SME_Completed_Goals__c,
            Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.Name,
            SME_LREngineCtrl.RollupOperation.Count 
        ));
        
        ctxIncompletedStrategy.add(
        new SME_LREngineCtrl.RollupSummaryField(
            Schema.SObjectType.SME_Account_Plan__c.fields.SME_Non_Completed_Strategies__c,
            Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.Name,
            SME_LREngineCtrl.RollupOperation.Count 
        ));
        
        ctxCompletedStrategy.add(
        new SME_LREngineCtrl.RollupSummaryField(
            Schema.SObjectType.SME_Account_Plan__c.fields.SME_Completed_Strategies__c,
            Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.Name,
            SME_LREngineCtrl.RollupOperation.Count 
        ));
        
        ctxIncompletedObjective.add(
        new SME_LREngineCtrl.RollupSummaryField(
            Schema.SObjectType.SME_Account_Plan__c.fields.SME_Non_Completed_Objectives__c,
            Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.Name,
            SME_LREngineCtrl.RollupOperation.Count 
        ));
        
        ctxCompletedObjective.add(
        new SME_LREngineCtrl.RollupSummaryField(
            Schema.SObjectType.SME_Account_Plan__c.fields.SME_Completed_Objectives__c,
            Schema.SObjectType.SME_Account_Plan_GSOT__c.fields.Name,
            SME_LREngineCtrl.RollupOperation.Count 
        ));
         doRollUp(ctxIncompletedGoal, objects);
         doRollUp(ctxCompletedGoal, objects);
         doRollUp(ctxIncompletedStrategy, objects);
         doRollUp(ctxCompletedStrategy, objects);
         doRollUp(ctxIncompletedObjective, objects); 
         doRollUp(ctxCompletedObjective, objects); 
         }catch(Exception e){
           SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanGSOTServiceCtrl', 'rollUpSummary', e);
        }    
    }
    
    
    //Method to update rollup fields
    public static void doRollUp(SME_LREngineCtrl.Context ctx ,SME_Account_Plan_GSOT__c[] objects){
        Sobject[] objRollup = SME_LREngineCtrl.rollUp(ctx, objects);
        try{
        update objRollup;
         }catch(Exception e){
         
           SME_GlobalExceptionHandlerCtrl.processException('SME_AccountPlanGSOTServiceCtrl', 'doRollUp', e);
        }    
    }
    //Method to update Status completed for Goal/Strategy if Strategy/Objective is completed
    public static void updateStatus(List<SME_Account_Plan_GSOT__c> newGSOList){
        Id goalRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.Goals_RT).getRecordTypeId();
        Id startegyRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GSOT_Strategy_Record_Type).getRecordTypeId();
        Id objectiveRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GSOT_Objective_Record_Type).getRecordTypeId();
        List<SME_Account_Plan_GSOT__c> gsoList = new List<SME_Account_Plan_GSOT__c>();
        Set<Id> strategyIds = new Set<Id>();
        Set<Id> goalIds = new Set<Id>();
        
        map<Id,boolean> gsoIdsToUpdate = new  map<Id,boolean> ();
       
            for(SME_Account_Plan_GSOT__c gso: newGSOList){
                if( gso.SME_Status__c == 'Completed'){
                    if(gso.RecordTypeId == objectiveRecordTypeId){
                       strategyIds.add(gso.SME_Strategy__c); 
                       gsoIdsToUpdate.put(gso.SME_Strategy__c,true);
                    }else if(gso.RecordTypeId == startegyRecordTypeId){
                       goalIds.add(gso.SME_Goal__c); 
                       gsoIdsToUpdate.put(gso.SME_Goal__c,true);
                    }
                }
            } 
        
        List<SME_Account_Plan_GSOT__c> allGSO = [Select id,RecordTypeId,SME_Strategy__c,SME_Goal__c,SME_Status__c from  SME_Account_Plan_GSOT__c
                                                 where SME_Strategy__c in : strategyIds or SME_Goal__c in :goalIds ];
       system.debug('allGSO'+allGSO);
        for(SME_Account_Plan_GSOT__c gso: allGSO ){
              
            if(gso.SME_Status__c !='Completed'){
                if(gsoIdsToUpdate.containskey(gso.SME_Goal__c) ) {
                    gsoIdsToUpdate.put(gso.SME_Goal__c,false);
                } 
                if(gsoIdsToUpdate.containskey(gso.SME_Strategy__c) ){
                    
                     gsoIdsToUpdate.put(gso.SME_Strategy__c,false); 
                }
            }
        }
        for(Id gsoId: gsoIdsToUpdate.keyset()){
            if(gsoIdsToUpdate.get(gsoId)){
               SME_Account_Plan_GSOT__c gso = new SME_Account_Plan_GSOT__c(Id=gsoId,SME_Status__c ='Completed');
               gsoList.add(gso); 
            }
            
            
        }
        
        update gsoList;
    }      
}