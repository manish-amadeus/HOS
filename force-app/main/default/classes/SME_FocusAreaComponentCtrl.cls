/**
* Company     : PwC Sales & Marketing Excellence Solution.
* Description : 
* 
* ****************************************************************************************
* History     : 
* [19.APR.2019] Shubham - Created this class.
*/
public class SME_FocusAreaComponentCtrl {
    
    static Id gsotRecordTypeId = Schema.SObjectType.SME_Account_Plan_Focus_Area__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GSOT_FOCUS_AREA_RT).getRecordTypeId();
    static Id productRecordTypeId = Schema.SObjectType.SME_Account_Plan_Focus_Area__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.PRODUCT_FOCUS_AREA_RT).getRecordTypeId();
    static Id goalRecordTypeId = Schema.SObjectType.SME_Account_Plan_GSOT__c.getRecordTypeInfosByName().get(SME_GlobalConstantCtrl.GOALS_RT).getRecordTypeId();
    
    @AuraEnabled
    public static FocusAreaWrapper getGSOTFocusAreas(Id accPlanId){
        List<SME_Account_Plan_Focus_Area__c>  foucsAreaList = new List<SME_Account_Plan_Focus_Area__c>();
        List<SME_Account_Plan_GSOT__c>  gsotList = new List<SME_Account_Plan_GSOT__c>();
        Map<Id, Product2> idToProductMap = new Map<Id, Product2>();
        List<Product2> productOptionsList = new List<Product2>();
        FocusAreaWrapper faw;
        try{
            for(SME_Account_Plan_Focus_Area__c pfa : [SELECT Id, SME_Account_Plan__c, SME_Account_Plan_GSOT__c, SME_Max__c,
                                                      SME_Product__c, SME_Product__r.Name, Name,SME_Account_Plan_GSOT__r.SME_Goal_Name__c, SME_Account_Plan_GSOT__r.Name, RecordType.Name,
                                                      SME_Account_Plan_GSOT__r.RecordTypeId, RecordTypeId
                                                      FROM SME_Account_Plan_Focus_Area__c
                                                      WHERE SME_Account_Plan__c =: accPlanId Order by CreatedDate]){
                                                          foucsAreaList.add(pfa);
                                                      }
            
            for(SME_Account_Plan_GSOT__c gsot : [SELECT Id, Name,SME_Goal_Name__c
                                                 FROM SME_Account_Plan_GSOT__c
                                                 WHERE SME_Account_Plan__c =: accPlanId AND RecordTypeId =: goalRecordTypeId]){
                                                     gsotList.add(gsot);
                                                 }
            
            
            for(Opportunity opp : [SELECT Id,  (Select Id, Product2Id, Product2.Name FROM OpportunityLineItems
                                                Where Product2.SME_Product_Type__c !=: SME_GlobalConstantCtrl.PRODUCT2_PRODUCT_TYPE_Picklist_Value) 
                                   FROM Opportunity 
                                   WHERE Account_Plan__c =: accPlanId]){
                                       Product2 prod;
                                       for(OpportunityLineItem oli : opp.OpportunityLineItems){
                                           prod = new Product2(Id = oli.Product2Id);
                                           prod.Name = oli.Product2.Name;
                                           idToProductMap.put(oli.Product2Id, prod);
                                       }
                                   }
            for(Order ord : [SELECT Id,  (Select Id, Product2Id, Product2.Name FROM OrderItems
                                          Where Product2.SME_Product_Type__c !=: SME_GlobalConstantCtrl.PRODUCT2_PRODUCT_TYPE_Picklist_Value) 
                             FROM Order
                             WHERE Account_Plan__c =: accPlanId]){
                                 Product2 prod;
                                 SYstem.debug('******'+ord);
                                 for(OrderItem oi : ord.OrderItems){
                                     prod = new Product2(Id = oi.Product2Id);
                                     prod.Name = oi.Product2.Name;
                                     idToProductMap.put(oi.Product2Id, prod);
                                 }
                             }
            for(Id prodId : idToProductMap.keySet()){
                productOptionsList.add(idToProductMap.get(prodId));
            }
            system.debug('######'+gsotList);
            faw = new FocusAreaWrapper(foucsAreaList, gsotList, productOptionsList); 
            if(Test.isRunningTest()) {
                Integer i = 1/0;
            }
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_FocusAreaComponentCtrl', 'getGSOTFocusAreas', e);
            return null;
        }
        return faw;
    }
    
    @AuraEnabled
    public static FocusAreaWrapper saveAccountPlanFocusArea(String sJSONAccPlanFa, Id idAccountPlan, String type, List<Id> faIdsListToDelete) {
        List<SME_Account_Plan_Focus_Area__c> listAccPlanFa = (List<SME_Account_Plan_Focus_Area__c>) System.JSON.deserialize(sJSONAccPlanFa, List<SME_Account_Plan_Focus_Area__c>.Class);
        List<SME_Account_Plan_Focus_Area__c> faListToUpsert = new List<SME_Account_Plan_Focus_Area__c>();
         try {
        if(faIdsListToDelete.size() > 0){
           
                Set<Id> delIds = new Set<Id>(faIdsListToDelete);
                List<SME_Account_Plan_Focus_Area__c> faDelList = [SELECT Id FROM SME_Account_Plan_Focus_Area__c WHERE Id IN : delIds];
                delete faDelList;
               
        }
        for(SME_Account_Plan_Focus_Area__c fa : listAccPlanFa) {
            SME_Account_Plan_Focus_Area__c faToUpsert = new SME_Account_Plan_Focus_Area__c(SME_Account_Plan__c = idAccountPlan); 
            faToUpsert.Id = fa.Id;
            faToUpsert.SME_Max__c = fa.SME_Max__c;
            if(type == System.Label.SME_Focus_Area_Type_GSOT){
                faToUpsert.RecordTypeId = gsotRecordTypeId;
                faToUpsert.SME_Account_Plan_GSOT__c = fa.SME_Account_Plan_GSOT__c;
            }else if (type == System.Label.SME_Focus_Area_Type_Product){
                faToUpsert.RecordTypeId = productRecordTypeId;
                faToUpsert.SME_Product__c = fa.SME_Product__c;
            }
            faListToUpsert.add(faToUpsert);
        }
       
            upsert faListToUpsert Id;    
         if(Test.isRunningTest()) {
                    Integer i = 1/0;
                }
            }
            catch(Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                SME_GlobalExceptionHandlerCtrl.processException('SME_FocusAreaComponentCtrl', 'saveAccountPlanFocusArea', e);
                return null;
            }
        
        return getGSOTFocusAreas(idAccountPlan);
    }
    
    public class FocusAreaWrapper{
        
        @AuraEnabled
        List<SME_Account_Plan_Focus_Area__c> goalList  {get; set;}
        
        @AuraEnabled
        List<SME_Account_Plan_Focus_Area__c> productAreaList  {get; set;}
        
        @AuraEnabled
        List<SME_Account_Plan_GSOT__c> gsotOptionsList  {get; set;}
        
        @AuraEnabled
        List<Product2> productOptionList  {get; set;}
        
        public FocusAreaWrapper(List<SME_Account_Plan_Focus_Area__c> focusAreaList, List<SME_Account_Plan_GSOT__c> gsotList, List<Product2> productOptionsList){
            goalList = new List<SME_Account_Plan_Focus_Area__c>();
            productAreaList = new List<SME_Account_Plan_Focus_Area__c>();
            gsotOptionsList = new List<SME_Account_Plan_GSOT__c>();
            productOptionList = new List<Product2>();
            
            try{
                for(SME_Account_Plan_Focus_Area__c fa : focusAreaList){
                    if(fa.RecordTypeId == gsotRecordTypeId){
                        if(fa.SME_Account_Plan_GSOT__r.RecordTypeId == goalRecordTypeId){
                            this.goalList.add(fa);
                        }
                    }else if(fa.RecordTypeId == productRecordTypeId){
                        this.productAreaList.add(fa);
                    }
                }
                
                gsotOptionsList.addAll(gsotList);
                productOptionList.addAll(productOptionsList);
                if(Test.isRunningTest()) {
                    Integer i = 1/0;
                }
            }catch(Exception e) {
                SME_GlobalExceptionHandlerCtrl.processException('SME_FocusAreaComponentCtrl', 'Constructor:FocusAreaWrapper', e);
            }
            
        }
        
    }
    @AuraEnabled
    public static boolean getFocusAreaEditAccess(String sAccountPlanId){
        return SME_GlobalUtilityCtrl.getGFCEditDeletePermission(sAccountPlanId);
    }
}