/****************************************************************************************
Name            : Salesforce_User_BeforeInsert Trigger
Author          : Supriya Galinde
Created Date    : 2/16/2017
Last Mod Date   : 3/15/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : Class that handles all trigger code for the Salesforce_User__c Object
                : 
                : 
******************************************************************************************/
public class Salesforce_User_TriggerHandler {
     private boolean m_isExecuting = false;
    
    
    public Salesforce_User_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }
    
    public void OnBeforeInsert(List<Salesforce_User__c> newTrigger)
    {
        Set<id> niOrgDetailsSet = new Set<id>();       
        	for (Salesforce_User__c user: newTrigger)
        	{
            	niOrgDetailsSet.add(user.OrgName__c);           	
        	}
        if(!niOrgDetailsSet.isEmpty()){
            getAllActiveBillingRecords(niOrgDetailsSet);
        }
    }
    
    public void OnBeforeUpdate(List<Salesforce_User__c> newTrigger)
    {
        Set<id> niOrgDetailsSet = new Set<id>();       
        	for (Salesforce_User__c user: newTrigger)
        	{
            	niOrgDetailsSet.add(user.OrgName__c);           	
        	}
        system.debug('niOrgDetailsSet'+niOrgDetailsSet);
        if(!niOrgDetailsSet.isEmpty()){
            getAllActiveBillingRecords(niOrgDetailsSet);
        }
    }
    
    //METHOD TO GET ACTIVE BILLING RECORDS FROM ACTIVITY LINE ITEMS
    public void getAllActiveBillingRecords(Set<Id> niOrgDetailsSet){
        List<NI_Org_Details_to_Accounts__c> accountsList = new List<NI_Org_Details_to_Accounts__c>();
        Map<Id, Set<Id>> mapOrgAccount = new Map<Id, Set<Id>>();
        List<NI_Org_Details__c> niOrgDetailsList = new List<NI_Org_Details__c>();
        List<NI_Org_Details__c> niOrgDetailsToUpdate = new List<NI_Org_Details__c>();
        Map<Id, Decimal> accActivityMap = new Map<Id, Decimal>();
        Map<Id, Decimal> orgUserMap = new Map<Id, Decimal>();
        List<AggregateResult> activityLineAggr = new List<AggregateResult>();
        Set<Id> accountIdSet = new Set<Id>();
        
        //GET THE LIST OF ALL ACCOUNTS LINKED WITH THE ORG WHOSE STATUS IS ACTIVE
        //AS niOrgDetailsSet CONTAINS ONLY 200 RECORDS BECAUSE IN TRIGGER MAX COUNT OF RECORD IS 200
        //SO APPLYING MAX LIMIT TO BELOW QUERY
        for(List<NI_Org_Details_to_Accounts__c> accList : [SELECT NIOrgDetailsID__c, AccountID__c 
                                                           FROM NI_Org_Details_to_Accounts__c 
                        WHERE NIOrgDetailsID__c IN :niOrgDetailsSet AND Status__c = 'Active' ])
        {
            for(NI_Org_Details_to_Accounts__c acc :accList )
            	accountsList.add(acc);
        }
        
        //GET Purchased_Limited_Users__c FROM NI_Org_Details__c
        niOrgDetailsList = [SELECT Purchased_Limited_Users__c, Purchased_Full_Users__c, Current_Limited_Users__c, Current_Full_Users__c
                            FROM NI_Org_Details__c 
                            WHERE Id IN :niOrgDetailsSet];
        
        //system.debug('accountsList'+accountsList);
        //ITERATE OVER ACCOUNTS LIST AND CREATE A MAP OF ORG AND ACCOUNT
        for(NI_Org_Details_to_Accounts__c orgAccount : accountsList){
            //CREATE A SET OF ALL ACCOUNTS
            accountIdSet.add(orgAccount.AccountID__c);
            
            //IF MAP ALREADY HAS ORG_ID ADD ACCOUNTID TO THE SET 
            if(mapOrgAccount.containsKey(orgAccount.NIOrgDetailsID__c)){
                //system.debug('orgAccount.NIOrgDetailsID__c'+orgAccount.NIOrgDetailsID__c);               
                Set<Id> accIdSet = mapOrgAccount.get(orgAccount.NIOrgDetailsID__c);
                accIdSet.add(orgAccount.AccountID__c);
                mapOrgAccount.put(orgAccount.NIOrgDetailsID__c, accIdSet);
            }
            //ELSE CREATE A NEW KEY AND VALUE PAIR
            else{
                mapOrgAccount.put(orgAccount.NIOrgDetailsID__c, new Set<Id> { orgAccount.AccountID__c });
            }
        }
        //system.debug('mapOrgAccount'+mapOrgAccount);
        
        //GET SUM OF UNITS OF ALL ACTIVITY LINE ITEMS WHOSE STATUS = 'ACTIVE',
        //PRODUCT'S  Product_Line_Global__c = 'Delphi.fdc', 
        //PRODUCT'S LIMITED USER = TRUE, BILLING START DATE < TODAY()
        if(!accountIdSet.isEmpty()){
            for( List<AggregateResult>
            activityLineAgg : [SELECT count(Id) cnt, sum(Units__c) sumOfUnits, Billing_Contract__r.Account__r.Id accIdd FROM Activity_Line_Item__c 
                                WHERE Billing_Contract__r.Account__r.Id IN :accountIdSet
                                AND Status__c = 'Active'
                                //AND Product__r.di_index__r.Name = 'idx1'
                                AND Product__r.Product_Line_Global__c = 'Delphi.fdc'
                                AND Product__r.Limited_User__c = true
                                AND Contract_Start_Date__c < today
                                GROUP BY Billing_Contract__r.Account__r.Id])
            {        
        	for(AggregateResult agr : activityLineAgg){   
            	accActivityMap.put((ID)agr.get('accIdd'), (Decimal)agr.get('sumOfUnits'));
        		}
            }
        }
         
        //FOR EACH ORG ID IN MAP
        for(Id orgId : mapOrgAccount.keySet()){
            //GET THE SET OF ACCOUNT ASSOCIATED WITH THAT ORG
            Set<Id> accIdSet2 = mapOrgAccount.get(orgId);
            //ITERATE OVER ACCOUNTS
            for(Id accntId : accIdSet2){
                //IF MAP OF ACCOUNT AND ACTIVITY LINE ITEM CONTAINS ACCOUNTID AS KEY GET THE VALUE OF SUM AND
                //STORE IT IN A MAP OF ORG_ID AND DECIMAL TO UPDATE Purchased_Limited_Users__c FIELD
                if(accActivityMap.containsKey(accntId)){
                    Decimal c = accActivityMap.get(accntId);
                    if(orgUserMap.containsKey(orgId)){
                        Decimal temp = orgUserMap.get(orgId);
                        temp = temp + c;
                        orgUserMap.put(orgId, temp);
                    }
                    else{
                        if(c != null){
                            orgUserMap.put(orgId,c);
                        }
                        else{
                            orgUserMap.put(orgId,0);
                        }
                    }
                }
            }
        }
        //ITERATE OVER NI_Org_Details__c AND UPDATE Purchased_Limited_Users__c WITH THE SUM FROM MAP
        for(NI_Org_Details__c orgDetails : niOrgDetailsList ){
            if(orgUserMap.containsKey(orgDetails.Id)){
                 orgDetails.Purchased_Limited_Users__c = orgUserMap.get(orgDetails.Id);
                niOrgDetailsToUpdate.add(orgDetails);
            }
            else{
                orgDetails.Purchased_Limited_Users__c = 0;
                niOrgDetailsToUpdate.add(orgDetails);
            }
        }
        
        if(!niOrgDetailsToUpdate.isEmpty()){
            update niOrgDetailsToUpdate;
        }
        system.debug('Limits.getQueries()'+Limits.getQueries());
    }
}