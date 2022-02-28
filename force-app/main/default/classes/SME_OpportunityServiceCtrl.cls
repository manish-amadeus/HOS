/**
* Company     : PwC Sales & Marketing Excellence Solution.
* Description : 
* 
* ****************************************************************************************
* History     : 
* [1.APR.2019] Peeyush Tripathi - Created this class.
  20 APR 2020 Nagendra SIngh - declared "rollUpSummary" as Future method as per discussion with Vijay since this method causing 
     too many SOQL error when we do renew quote. 
*/
public class SME_OpportunityServiceCtrl {
    
    /*
    First step is to create a context for SME_LREngineCtrl, by specifying parent and child objects and
    lookup relationship field name
    
    */
    
    // This method is declared as Future method on 24 APR 2020 By Nagendra as per discussion with Vijay since this method causing 
    // too many SOQL error when we do renew quote. 
   //@Future
   public static void rollUpSummary(Set<Id> newOppId){
        List<Opportunity> objects = new List<Opportunity>();
        objects = [Select id,Account_Plan__c,isWon,isClosed,CloseDate,Amount,Name from Opportunity where id in :newOppId and  Account_Plan__c!=null];
        try{
            if(objects != null && objects.size()>0){
                SME_LREngineCtrl.Context ctx = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                            Opportunity.SobjectType,  // child object
                                                            Schema.SObjectType.Opportunity.fields.Account_Plan__c // relationship field name
                                                           );     
                SME_LREngineCtrl.Context ctx1 = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                             Opportunity.SobjectType,  // child object
                                                             Schema.SObjectType.Opportunity.fields.Account_Plan__c, // relationship field name
                                                             'Opportunity.isWon = TRUE'
                                                            );   
                SME_LREngineCtrl.Context ctx2 = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                             Opportunity.SobjectType,  // child object
                                                             Schema.SObjectType.Opportunity.fields.Account_Plan__c, // relationship field name
                                                             'Opportunity.isWon = FALSE AND (Opportunity.isClosed = True)'
                                                            ); 
                SME_LREngineCtrl.Context ctx3 = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                             Opportunity.SobjectType,  // child object
                                                             Schema.SObjectType.Opportunity.fields.Account_Plan__c, // relationship field name
                                                             //'Opportunity.CloseDate - date.today() < \'30\''
                                                             //'(Date.valueOf(Opportunity.CloseDate).daysBetween(TODAY)) < \'30\''
                                                             //'DATEDIFF(day, Opportunity, GETDATE()) AS DateDiff < \'30\''
                                                             'Opportunity.CloseDate >= TODAY AND Opportunity.CloseDate <= NEXT_N_DAYS:30'
                                                            ); 
                
                SME_LREngineCtrl.Context ctx4 = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                             Opportunity.SobjectType,  // child object
                                                             Schema.SObjectType.Opportunity.fields.Account_Plan__c, // relationship field name
                                                             'Opportunity.isClosed = False'
                                                            ); 
                SME_LREngineCtrl.Context ctx5 = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                             Opportunity.SobjectType,  // child object
                                                             Schema.SObjectType.Opportunity.fields.Account_Plan__c, // relationship field name
                                                             'Opportunity.isWon = TRUE'
                                                            ); 
                SME_LREngineCtrl.Context ctx6 = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                             Opportunity.SobjectType,  // child object
                                                             Schema.SObjectType.Opportunity.fields.Account_Plan__c, // relationship field name
                                                             'Opportunity.isWon = FALSE AND (Opportunity.isClosed = True)'
                                                            ); 
                SME_LREngineCtrl.Context ctx7 = new SME_LREngineCtrl.Context(SME_Account_Plan__c.SobjectType, // parent object
                                                             Opportunity.SobjectType,  // child object
                                                             Schema.SObjectType.Opportunity.fields.Account_Plan__c, // relationship field name
                                                             'Opportunity.isClosed = False'
                                                            );
                
                System.debug('ctx '+ctx); 
                /*
                Next, one can add multiple rollup fields on the above relationship. 
                Here specify 
                1. The field to which aggregated value will be saved in master/parent object
                2. The field to aggregate in child object
                3. The aggregate operation to be done i.e. SUM, AVG, COUNT, MIN/MAX
                */
                        
                ctx.add(
                    new SME_LREngineCtrl.RollupSummaryField(
                        Schema.SObjectType.SME_Account_Plan__c.fields.Total_Opportunity_Value__c,
                        Schema.SObjectType.Opportunity.fields.Amount,
                        SME_LREngineCtrl.RollupOperation.Sum 
                    )); 
                ctx1.add(
                    new SME_LREngineCtrl.RollupSummaryField(
                        Schema.SObjectType.SME_Account_Plan__c.fields.Total_Opportunities_Won__c,
                        Schema.SObjectType.Opportunity.fields.Amount,
                        SME_LREngineCtrl.RollupOperation.Sum 
                    )); 
                ctx2.add(
                    new SME_LREngineCtrl.RollupSummaryField(
                        Schema.SObjectType.SME_Account_Plan__c.fields.Total_Opportunities_Lost__c,
                        Schema.SObjectType.Opportunity.fields.Amount,
                        SME_LREngineCtrl.RollupOperation.Sum 
                    )); 
                ctx3.add(
                    new SME_LREngineCtrl.RollupSummaryField(
                        Schema.SObjectType.SME_Account_Plan__c.fields.Current_Opportunities__c,
                        Schema.SObjectType.Opportunity.fields.Amount,
                        SME_LREngineCtrl.RollupOperation.Sum 
                    )); 
                ctx4.add(
                    new SME_LREngineCtrl.RollupSummaryField(
                        Schema.SObjectType.SME_Account_Plan__c.fields.Total_Pipeline__c,
                        Schema.SObjectType.Opportunity.fields.Amount,
                        SME_LREngineCtrl.RollupOperation.Sum 
                    ));
                ctx5.add(
                    new SME_LREngineCtrl.RollupSummaryField(
                        Schema.SObjectType.SME_Account_Plan__c.fields.Total_of_Closed_Won_Opportunities__c,
                        Schema.SObjectType.Opportunity.fields.Name,
                        SME_LREngineCtrl.RollupOperation.Count 
                    ));
                ctx6.add(
                    new SME_LREngineCtrl.RollupSummaryField(
                        Schema.SObjectType.SME_Account_Plan__c.fields.Total_of_Closed_Lost_Opportunities__c,
                        Schema.SObjectType.Opportunity.fields.Name,
                        SME_LREngineCtrl.RollupOperation.Count 
                    ));
                ctx7.add(
                    new SME_LREngineCtrl.RollupSummaryField(
                        Schema.SObjectType.SME_Account_Plan__c.fields.Total_of_Open_Opportunities__c,
                        Schema.SObjectType.Opportunity.fields.Name,
                        SME_LREngineCtrl.RollupOperation.Count 
                    )); 
        
                /* 
                Calling rollup method returns in memory master objects with aggregated values in them. 
                Please note these master records are not persisted back, so that client gets a chance 
                to post process them after rollup
                */ 
                // Need to add them in a single list and then update
            Sobject[] masters = SME_LREngineCtrl.rollUp(ctx, objects);    
                Sobject[] masters1 = SME_LREngineCtrl.rollUp(ctx1, objects); 
                Sobject[] masters2 = SME_LREngineCtrl.rollUp(ctx2, objects); 
                Sobject[] masters3 = SME_LREngineCtrl.rollUp(ctx3, objects); 
                Sobject[] masters4 = SME_LREngineCtrl.rollUp(ctx4, objects); 
                Sobject[] masters5 = SME_LREngineCtrl.rollUp(ctx5, objects); 
                Sobject[] masters6 = SME_LREngineCtrl.rollUp(ctx6, objects);
                Sobject[] masters7 = SME_LREngineCtrl.rollUp(ctx7, objects);
                
                // Persiste the changes in master
                List<Sobject> updateAccPlanList = new List<Sobject>();
                if(masters[0].Id != null){
                    
                    update masters;
                    
                }
                if(masters1[0].Id != null){
                     
                    update masters1;
                }
                if(masters2[0].Id != null){
                   
                    update masters2;
                }
                 if(masters3[0].Id != null){
                    
                    update masters3;
                 }
                if(masters4[0].Id != null){
                   
                    update masters4;
                }
                if(masters5[0].Id != null){
                    
                    update masters5;
                }
                if(masters6[0].Id != null){
                    
                    update masters6;
                }
                if(masters7[0].Id != null){
                   
                    update masters7;
                }
            }
        } 
        catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_OpportunityServiceCtrl', 'rollUpSummary', e);
        }
    }
    public static void addAddress(List<Opportunity> newOpportunityList){
    //     if(checkRecursive.runOnce())    {
    //     list<id> OppIds= new list<id>();
    //     for(Opportunity p :newOpportunityList){
    //         if(p.AccountId!=null){
    //             OppIds.add(p.id);
    //         }
    //     }
    //     list<Opportunity> oppobj= [select name,AccountId,Address_new__c,Account.BillingCity,Account.BillingAddress from Opportunity where id in :OppIds];
    //     for(Opportunity p : oppobj){
    //         if(p.AccountId!=null){
    //             p.Address_new__c = p.Account.BillingCity;
    //         }
    //     }
    //     update oppobj;
    // }
    } 
}