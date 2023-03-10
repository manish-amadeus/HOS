/****************************************************************************************
Name            : AH_CaseToOpportunityExt
Author          : Archita Shrotriya
Created Date    : 21/09/2017
Last Mod Date   : 01/10/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Extention Class for AH_CaseToOpportunity VF page
				: 
				: 
******************************************************************************************/
public class AH_CaseToOpportunityExt 
{
    
    public Opportunity opportunity {get; set;}  
    public Note nt {get; set;}
    public case caseDetail {get; set;}  
    Id supportRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support to Sales').getRecordTypeId();
    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close Case').getRecordTypeId();        
    public User usr = new User(); 
    Attachment attachment = new Attachment();
    solution sol = new solution();
    Public RecordType supportRecordTypeName;
    
    
    public AH_CaseToOpportunityExt(ApexPages.StandardController controller) 
    { 
        
        try
        {
            if (ApexPages.CurrentPage().getParameters().containsKey('caseid'))
            {
                if ((ApexPages.CurrentPage().getParameters().get('caseid') != 'null') && (ApexPages.CurrentPage().getParameters().get('caseid') != null))
                {    
                    caseDetail = new Case();
                    caseDetail= [SELECT Id, AccountId, Account.Name, Asset.Name, CaseNumber,
                                 Source.Name, Contact.Name, Solution_Domain__c, Account.MTech_Owner__c,
                                 Account.OwnerId, Description, Contact.id, Subject, Account.Secondary_Account_Owner__c
                                 FROM Case 
                                 WHERE Id =: ApexPages.CurrentPage().getParameters().get('caseid')];    

                    if (caseDetail.ContactId != null)                        
                    {
                        
                        opportunity = new Opportunity();                    
                        opportunity.RecordTypeId = supportRecordTypeId;
                        
                        if (caseDetail.Asset.Name != null)
                        {
                            opportunity.Name = caseDetail.Account.Name + ' ' + caseDetail.Asset.Name;
                        }
                        else
                        {
                            opportunity.Name = caseDetail.Account.Name;
                        }        
                        
                        opportunity.AccountId = caseDetail.AccountId;
                        opportunity.Opportunity_Source__c = 'Support';
                        opportunity.CloseDate = system.today().addMonths(2).toStartofMonth().addDays(-1); 
                        opportunity.StageName = 'Potential Opportunity - 0%';
                        opportunity.CaseId__c = caseDetail.Id; //ADDED BY STUART EMERY ON 10/20/2017
                        
                        // SET OPPORTUNITY OWNER
                        opportunity.OwnerId = caseDetail.Account.OwnerId; // DEFAULT
                        
                        if (caseDetail.Account.Secondary_Account_Owner__c != null)
                        {
                            opportunity.OwnerId = caseDetail.Account.Secondary_Account_Owner__c;
                        }                        
                       
                        if ((caseDetail.Solution_Domain__c == 'Service Optimization') && (caseDetail.Account.MTech_Owner__c != null))
                        {
                            opportunity.OwnerId = caseDetail.Account.MTech_Owner__c;
                        }
                        
                        /*
                        if ((caseDetail.Solution_Domain__c == 'Sales & Catering') && (caseDetail.Account.Secondary_Account_Owner__c != null))
                        {
                            opportunity.OwnerId = caseDetail.Account.Secondary_Account_Owner__c;
                        }
						*/
                        /* This is not needed. default opportunity.OwnerId is set above on line 64
                        //NEW CODE ADDED BY STUART EMERY ON 10/18/2017
                        if ((caseDetail.Solution_Domain__c != 'Service Optimization' && 
                             caseDetail.Solution_Domain__c != 'Sales & Catering') || 
                             caseDetail.Solution_Domain__c == null)
                        {
                            opportunity.OwnerId = caseDetail.Account.OwnerId;
                        }
                       	*/
                    } else { ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No contact assosiated with case, Please insert contact details and try again.')); }
                }
            }
        } catch (Exception e) { ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not able to create Opportunity')); }
        
    }
    
    public PageReference save()
    {
        
        try
        {            
            insert opportunity; 
            if (opportunity != null)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'New Opportunity' + ' ' + opportunity.Name + ' ' + 'created successfully. Thank you!'));                     
            }
        } catch (Exception e) { ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not able to create Opportunity ' + e.getMessage())); }
        
        // Copy Case description to Opportunity Note 
        try
        {            
            if (caseDetail.Description != null && caseDetail.Description != '')
            {
                nt = new Note();
                nt.body = caseDetail.Description;
                nt.ParentId = opportunity.Id;
                nt.Title = 'Description';
                database.insert(nt);
            }
        } catch (DMLException e) { ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not able to copy case description to Note ' + e.getMessage())); }

        try
        {            
            // Update case details and close the case   
            Opportunity opp = [SELECT Id, Opportunity_Number__c, RecordTypeId FROM Opportunity WHERE Id =: opportunity.Id];
            RecordType supportRecordTypeName = [SELECT Name FROM RecordType WHERE Id =: opp.RecordTypeId];
            
            caseDetail.Reason = 'Sales /Services';    
            caseDetail.Case_Reason__c = 'Sales / Services';
            caseDetail.Opportunity_Number__c = opp.Opportunity_Number__c;
            caseDetail.Status = 'CLOSED';
            caseDetail.RecordTypeId = caseRecordTypeId;
            caseDetail.Resolution__c = 'As we discussed your recent inquiry to Support requires a billable engagement. I have engaged our Sales Team on your behalf. A member of the Sales team will be reaching out to you on how to proceed.\n\n'; 
            caseDetail.Resolution__c += 'Thank you,\n'; 
            caseDetail.Resolution__c += 'Amadeus Hospitality Support'; 
            
            caseDetail.Subject = caseDetail.Subject + ' -Case Closed to Opportunity #' + opp.Opportunity_Number__c;
            Database.update(caseDetail);
            
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Case '+ caseDetail.CaseNumber + ' is updated successfully '));
            
            // Add solution to case using custom setting            
            Map<String, AH_Case_Solution__c> mapOppSolution = new Map<String, AH_Case_Solution__c>(); 
            
            for (AH_Case_Solution__c cs : [SELECT Id, Name, Solution__c FROM AH_Case_Solution__c])
            {
                mapOppSolution.put(cs.Name, cs);
            } 

            AH_Case_Solution__c custSet = new AH_Case_Solution__c();
            string solNumber = '';

            if (!mapOppSolution.isEmpty())
            {
                custSet = mapOppSolution.get(supportRecordTypeName.Name);
            }     

            if (custSet != null)
            {
                solNumber = custSet.Solution__c;
            }

            if (solNumber != null && solNumber != '')
            {
                sol = [SELECT Id, SolutionName FROM Solution WHERE SolutionNumber =: solNumber];
                CaseSolution s = new CaseSolution(CaseId = caseDetail.id, SolutionId = sol.id);
                database.insert(s);
            } else { ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Case Solution is not present in custom setting hence could not attach.')); }
        } catch (DMLException e) { ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not able to close case')); }       
        
        return null;
        
    }
    
    public PageReference viewOpportunity()
    {
        PageReference pg = new PageReference('/' + opportunity.Id);
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference closeAndReturn()
    {
        PageReference pg = new PageReference('/' + caseDetail.Id);
        pg.setRedirect(true);
        return pg;
    }
    
}