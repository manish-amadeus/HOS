/**********************************************************
*************************************
Name : SLTC_Account_Matching_Invocable
Author : Prateek
Created Date : 12-09-21
Last Mod Date : 1-11-21
Last Mod By : Jaswanth
NICC Reference :
Description : Class used to create invocable method which call from Flows(SLTC_Lead_Trigger_Handler_After_Insert_Update)
               to find out all the duplicate realted to lead company
***********************************************************
*************************************/

public class SLTC_Account_Matching_Invocable{
    
    @InvocableMethod (label = 'Lead to check Duplicate account' description = 'Find duplicate account related to lead company')    
    // find duplicate account and Update Lead fields Account__c if Single match
    public static void findDuplicateAccount ( List<List<Lead>> leadData) {
        try{
            List<Lead> curentLeads = new List<Lead>();
            for(List<Lead> lead : leadData){
                curentLeads.addAll(lead);
            }
            if(curentLeads.isEmpty()){
                return;
            }
            
            List<String> companies = new List<String>();
            List<Lead> Leads = [SELECT Id, Name, Account__c,Company, street,City, State, Country, PostalCode FROM  Lead WHERE Id IN : curentLeads AND Company != NULL];
            for(Lead leadItem : Leads){
                companies.add(leadItem.Company);
            }
            
            //creating SOSL Search string
            String searchTerms = '(';
            for(String company : companies){
                searchTerms  += ' '+company+' OR';
            }
            searchTerms = searchTerms.removeEnd('OR');
            searchTerms += ')';
        
            
            //SOSL dynamic query
            String searchquery='FIND :searchTerms IN Name FIELDS RETURNING Account(Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, OwnerId)'; 
            
            List<List<SObject>> searchList = search.query(searchquery);
            List<Account> accountMatch = (List<Account>)searchList.get(0);
            System.debug(accountMatch.size());
            List<Group> groupList = [SELECT ID, Name, developerName, type FROM Group WHERE  type= 'Queue' AND developername = 'SLTC_Lead_Evaluation_Queue' LIMIT 1];
            
            //Once lead got created it should assign to SLTC_Lead_Evaluation_Queue Queue
            if(accountMatch.isEmpty()){
                for(Lead currentLead : Leads){
                    if(!groupList.isEmpty()){
                        currentLead.ownerId = groupList[0].Id;
                    }
                }
                UPDATE Leads;
                return;
            }
            
            //Map of company name with all matching Accounts
            Map<String, List<Account>> map_of_companyName_Account = generate_Map_companyName_Account(accountMatch); 
            System.debug(map_of_companyName_Account);
            List<Lead> leads_to_update = new List<Lead>();
            for(Lead currentLead : Leads){
                String companyName = generateKey(map_of_companyName_Account.keySet(), currentLead.company);
                List<Account> account_match = map_of_companyName_Account.get(companyName);
                if(account_match == NULL){
                    CONTINUE;
                }
                
                //list of matching account by company name
                currentLead.SLTC_Duplicate_Account__c = generate_hyperLink(account_match);
                for(Account acc : account_match){
                    System.debug(acc);
                    String billingStreet = String.isNotBlank(acc.BillingStreet) ? acc.BillingStreet.trim() : '';
                    String BillingCity = String.isNotBlank(acc.BillingCity) ? acc.BillingCity.trim() : '';
                    String state = String.isNotBlank(acc.BillingState) ? acc.BillingState.trim() : '';
                    String postalCode = String.isNotBlank(acc.BillingPostalCode) ? acc.BillingPostalCode.trim() : '';
                    String country = String.isNotBlank(acc.BillingCountry) ? acc.BillingCountry.trim() : '';
                    if(String.isBlank(currentLead.Account__c) && billingStreet.equalsIgnoreCase(currentLead.street) &&
                    billingCity.equalsIgnoreCase(currentLead.city) &&
                    state.equalsIgnoreCase(currentLead.state) &&
                    postalCode.equalsIgnoreCase(currentLead.postalCode) &&
                    country.containsIgnoreCase(currentLead.country)){
                        currentLead.ownerId = acc.ownerId;
                        currentLead.Account__c = acc.Id;
                        currentLead.status = 'Engaged'; 
                        currentLead.SLTC_Date_on_Assigned__c = Date.today();
                        sendCustomNotification(currentLead, acc);
                    } 
                }
                leads_to_update.add(currentLead);
            }
            UPDATE leads_to_update;
        }Catch(Exception exec){
            String message = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
            NI_Error_Logger.WriteToLog(message, ' Lead', ' SLTC_Account_Matching_Invocable', 'Query');
        } 

       
    }
    
    //create Map of CompanyName with all the matching account
    private static Map<String, List<Account>> generate_Map_companyName_Account(List<Account> accounts){
      Map<String,List<Account>> map_of_companyName_Account = new Map<String,List<Account>>();
      for(Account acc : accounts){
          if(!map_of_companyName_Account.containsKey(acc.Name)){
              map_of_companyName_Account.put(acc.Name, new List<Account>());
          }
          map_of_companyName_Account.get(acc.Name).add(acc);
      }
      return map_of_companyName_Account;   
    }
    
    //send notification using util subflow
    private static void sendCustomNotification(Lead lead, Account acc){
        Map<String, Object> flowMap = new Map<String, Object>();
        flowMap.put('currentRecord', lead.Id);
        flowMap.put('GroupName', '');
        flowMap.put('NotificationDeveloperName', 'SLTC_Duplocate_Account_For_Lead');
        String templateBopdy = 'You have been assigned the new lead '+lead.Name+' for the '+acc.Name+' Account.';
        flowMap.put('TemplateBody', templateBopdy);
        flowMap.put('Title', 'Lead Assigned');
        flowMap.put('UserId', acc.OwnerId);
        
        //call to autolauch flow to compare duplicate
        Flow.Interview.SLTC_Send_Notification_Bell notification = new Flow.Interview.SLTC_Send_Notification_Bell(flowMap);
        notification.start();
        
    }
    
    private static String generateKey(Set<String> matchingName, String comanyName){
        for(String st : matchingName){
            if(st.contains(comanyName)){
                return st;
            }
        }        
        return null;
    }
    
    //Generate hyper link for duplicate account
    private static String generate_hyperLink(List<Account> matchingAccount){
        String data = '';
        for(Account acc : matchingAccount){
            data += '<a href="/'+acc.Id+'">'+acc.Name+'</a>';
            data += '<br/>';
          
        }
        data = data.removeEnd('<br/>');
        return data;
    }
    
}