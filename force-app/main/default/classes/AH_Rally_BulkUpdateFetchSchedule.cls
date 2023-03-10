/****************************************************************************************
Name            : AH_Rally_BulkUpdateFetchSchedule (TC Org Name: ScheduleBulkUpdateRallyFetch)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : 
				: 
				: 
******************************************************************************************/
global class AH_Rally_BulkUpdateFetchSchedule implements Schedulable, Database.AllowsCallouts 
{

    global void execute(SchedulableContext sc) 
    {
        doUpdateUsingFetch(); 
    }
       
    public static void doUpdateUsingFetch()
    {
        try
        {
            AH_Rally_CaseSync rs = new AH_Rally_CaseSync();
        	rs.calloutMaker();
        } 
        catch (Exception e)
        {
             //send email if the schedular fails
            AH_Rally_Setup__c rsm = [SELECT Case_Id__c, Rally_Exception_Count__c FROM AH_Rally_Setup__c LIMIT 1];
            
            if (rsm.Rally_Exception_Count__c == null)
            {
                rsm.Rally_Exception_Count__c = 0;
            }
            
            rsm.Rally_Exception_Count__c += 1;
            
            
            if (rsm.Rally_Exception_Count__c >= 4)
            {
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();              
                //mail.setToAddresses(new String[]{CONSTANT.L3_SUPPORT_EMAIL, CONSTANT.SALESFORCE_BATCH_JOB});
                mail.setToAddresses(new String[]{'sean.harris@amadeus.com', 'hospitality.itbssharedmb@amadeus.com'}); 
                mail.setSubject('Rally sync to salesforce.com has failed');   
                
                Case case_updated_rec;
                if (rsm.case_id__c != '' && rsm.case_id__c != null)
                {
                    case_updated_rec = [SELECT Status, Customer_Severity__c, Subject FROM Case WHERE Id =: rsm.case_id__c LIMIT 1];
                }
                
                if (rsm.case_id__c == null || rsm.case_id__c == '' || case_updated_rec.status == 'Closed')
                {
                    // START:: Prepare Case Object 
                    Case cs = new Case();
                    cs.Status = 'New';
                    cs.Customer_Severity__c = '2 - Major';                                                            
                    cs.Subject = 'Rally sync to salesforce.com has failed';
                    cs.Description = e.getStackTraceString();
                    cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();		//Changed to default for AH
                    cs.Origin = 'L3 BS Email to Case';																					// Changed from "Account Management Support" to "L3 CBS Email to Case" for US145431
                    cs.Number_of_Requests__c = 1;
                    cs.Rally_Case_Type__c = 'Defect';
                    cs.Requester_Self_Service__c = 'Tech Assistance Required, User Error';
                    cs.Product_Family__c = 'Corporate Business Systems';
                    cs.Product__c = 'Salesforce';
                    cs.L3_Ticket_Summary__c = 'Exception with ';
                    cs.L3_Steps_To_Reproduce__c = 'test';
                    cs.Case_Product_Line__c = 'Channel Management Link';
                    cs.Module__c = 'Other';
                    cs.Has_No_DI__c = true;
                    // Create case in salesforce
                    insert cs;
                    
                    // END:: Prepare Case Object 
                    
                    rsm.case_id__c = cs.Id;  
                    mail.setHtmlBody('<u style="color:red"><b>Rally sync to salesforce.com has failed with the following exception</b></u><br/>  <code>' + e.getStackTraceString() + '</code> <br/> <hr> <br/> <br/> <div>New case is created in Salesforce Org:-</div> <div>Case Id :-' + cs.Id + '</div><div>Status:-' + cs.status + '</div><div>Severity:- ' + cs.Customer_Severity__c + '</div><div>Subject :- ' + cs.Subject + '</div><div><a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/ '+ cs.id + '>Case URL</a></div>');
                    
                } 
                else if (case_updated_rec.status != 'Closed')
                {
                    mail.setHtmlBody('<u style="color:red"><b>Rally sync to salesforce.com has failed</b></u> <br/> <div>Here case is not closed yet:-</div> <div>Case Id :-' + rsm.case_id__c + '</div><div>Status:-' + case_updated_rec.status + '</div><div>Severity:- ' + case_updated_rec.Customer_Severity__c + '</div><div>Subject :- ' + case_updated_rec.Subject + '</div><br/><div><a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + case_updated_rec.id + '>Case URL</a></div>');
                }               

                Messaging.sendEmail(new Messaging.Email[]{mail});
                
                rsm.Rally_Exception_Count__c = 0;
                
            }
            
            update rsm; 
 
        }  
        
    }
    
}