public with sharing class ChangeRequestDetailsExtension 
{

    ApexPages.StandardController GstdController;
    public SFDC_CSP_Development_Request__c c;
    public Solution s;
        
    public ChangeRequestDetailsExtension(ApexPages.StandardController controller) 
    {
        GstdController = controller;
        this.c = (SFDC_CSP_Development_Request__c)controller.getRecord(); 
        
        if (ApexPages.CurrentPage().getParameters().containsKey('sol')) 
        {    
            s = [SELECT Id, SolutionNumber, SolutionName, Description__c, Product_Group__c, Version__c, Part__c FROM Solution WHERE id = :ApexPages.CurrentPage().getParameters().get('sol')];
            
            c.Child_Solution__c = s.Id;
            c.Product_Group__c = s.Product_Group__c;
            c.Version__c = s.Version__c;
            c.Part__c = s.Part__c;    
            c.Title__c = s.SolutionNumber + ' - ' + s.SolutionName;
            c.Description__c = s.Description__c;

        }
    }

}