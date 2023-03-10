/****************************************************************************************
Name            : AH_AddEscalation_Ctlr
Author          : Sean Harris
Created Date    : 11/18/2020
Last Mod Date   : 11/18/2020
Last Mod By     : Sean Harris 
NICC Reference  : 
Description     : Controller for the AH_AddEscalation Visualforce page.
                :            
******************************************************************************************/
public class AH_AddEscalation_Ctlr 
{
    
    Public Case cs {get; set;}
    Public Escalation_QA_Checklists__c esca {get; set;}
    public List<Escalation_QA_Checklists__c> lstEscalationResults {get; set;}
    Public List<SelectOption> lstRecordTypes {get; set;}
        
    Public Boolean bShowInitialDecision {get; set;} 
    Public Boolean bEscalationCreated {get; set;} 
    Public Boolean bShowSearch {get; set;} 
    Public Boolean bShowSelectRecType {get; set;} 
    Public Boolean bEscalationAttached {get; set;} 

    public String searchText {get; set;}     
    public String selSearchId {get; set;}
    public String selRecordType {get; set;}
    
    
    public AH_AddEscalation_Ctlr()
    {
        
        bShowInitialDecision = true;
        bEscalationCreated  = false;
        bShowSearch = false;
        bShowSelectRecType = false;
        bEscalationAttached = false;
        
        if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
        {
            cs = [SELECT Id FROM Case WHERE Id =: ApexPages.CurrentPage().getParameters().get('id')];
            
            lstRecordTypes = new List<SelectOption>();
            for (RecordType lst : [SELECT Id, Name, Description 
                                   FROM RecordType 
                                   WHERE IsActive = true 
                                   AND SObjectType = 'Escalation_QA_Checklists__c'])
            {
                if (lst.Description != null)
                {
                    lstRecordTypes.add(new SelectOption(lst.Id, lst.Name + ' - ' + lst.Description));
                }
                else
                {
                    lstRecordTypes.add(new SelectOption(lst.Id, lst.Name));
                }
            } 
            system.debug(lstRecordTypes);
        }
        
    }
    
    public void openSearch()
    {
        bShowInitialDecision = false; 
        bEscalationCreated = false; 
        bShowSearch = true; 
        bShowSelectRecType = false;
        bEscalationAttached = false; 
    }
    
    public void doSearch()
    {
        
        String sIds = '\'500000000000000AAA\'';
        for (Escalations_2_Cases__c junc : [SELECT Escalation__c FROM Escalations_2_Cases__c WHERE Case__c =: cs.Id])
        {
            sIds += ',\'' + junc.Escalation__c + '\'';
        }
        
        String strKeyWord = string.escapeSingleQuotes(searchText);    
        String q = 'SELECT Id, Name '; 
        q += 'FROM Escalation_QA_Checklists__c ';
        q += 'WHERE Name LIKE \'%' + strKeyWord + '%\' ';
        q += 'AND (NOT Id IN (' + sIds + ')) ';
        q += 'ORDER BY Name ASC ';
        q += 'LIMIT 200';
        		
        lstEscalationResults = new List<Escalation_QA_Checklists__c>();
        lstEscalationResults = Database.query(q);
        
    }
    
    public void doRecTypeSel()
    {
        bShowInitialDecision = false; 
        bEscalationCreated = false; 
        bShowSearch = false; 
        bShowSelectRecType = true;
        bEscalationAttached = false;     
    }
    
    public pageReference doCreate()
    {
        
        pageReference pr;
        
        try
        {
            esca = new Escalation_QA_Checklists__c();
            esca.Related_Case__c = cs.Id;
            esca.RecordTypeId = selRecordType;
            insert esca;
            
            Escalations_2_Cases__c junc = new Escalations_2_Cases__c();
            junc.Case__c = cs.Id;
            junc.Escalation__c = esca.Id;
            insert junc;      
            
            bShowInitialDecision = false;
            bEscalationCreated = true;
            bShowSearch = false;
            bShowSelectRecType = false;
            bEscalationAttached = false;        

            pr = new pageReference('/' + esca.Id + '/e?retURL=' + esca.Id);

            pr.setRedirect(true);
            
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage())); 
        }
        
        return pr;
        
    }
    
    public void doSelect()
    {
        try
        {
            Escalations_2_Cases__c junc = new Escalations_2_Cases__c();
            junc.Case__c = cs.Id;
            junc.Escalation__c = selSearchId;
            insert junc;  
            esca = [SELECT Id, Name FROM Escalation_QA_Checklists__c WHERE Id =: selSearchId];
            
            bShowInitialDecision = false;
            bEscalationCreated = false;                    
            bShowSearch = false;
            bShowSelectRecType = false;
            bEscalationAttached = true; 
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'An existing Escalation has been attached to the Case.')); 
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage())); 
        }
    }
 
    public pageReference goToCase()
    {
        
        pageReference pr;
        
        pr = new pageReference('/' + cs.Id);
        pr.setRedirect(true);
        
        return pr;
        
    }
    
}