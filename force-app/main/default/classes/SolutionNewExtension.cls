public with sharing class SolutionNewExtension 
{

    ApexPages.StandardController GstdController;
    public SFDC_CSP_Development_Request__c c;
    public Solution s;

    public SolutionNewExtension(ApexPages.StandardController controller) 
    {
        GstdController = controller;
        this.s = (Solution)controller.getRecord(); 
        if (ApexPages.CurrentPage().getParameters().containsKey('crid')) 
        {    
            c = [SELECT Id, Name, Title__c, Description__c, Child_Solution__c, Product_Group__c, Version__c, Part__c, Support_Priority__c, Fix_Revision__c FROM SFDC_CSP_Development_Request__c WHERE id = :ApexPages.CurrentPage().getParameters().get('crid')];
            
            if (c.Child_Solution__c == null)
            {
                s.SolutionName = c.Title__c;
                s.Description__c = c.Description__c;
                s.Product_Group__c = c.Product_Group__c;
                s.Version__c = c.Version__c;
                s.Part__c = c.Part__c;
                s.Hidden_Support_Priority__c = c.Support_Priority__c;
                s.Fix_Revision__c = c.Fix_Revision__c;
            }
            else
            {
                //s.adderror('Error: ' + c.Name + ' has a solution associated and therefore cannot have a new solution created from it.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + c.Name + ' has a solution associated and therefore cannot have a new solution created from it.'));
            }
             
        }
        
    }
    
    public PageReference saveSolution()
    {
    
        ApexPages.StandardController sc = new ApexPages.StandardController(new Solution());
        PageReference pr = GstdController.save();
        s = (Solution)GstdController.getRecord(); 
        
        if (ApexPages.CurrentPage().getParameters().containsKey('crid')) 
        {    
            SFDC_CSP_Development_Request__c c = [SELECT Id, Title__c, Description__c FROM SFDC_CSP_Development_Request__c WHERE id = :ApexPages.CurrentPage().getParameters().get('crid')];
            c.Child_Solution__c = s.Id;
            update c;
        }
        
        return pr;
    
    }
    

}