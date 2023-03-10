public class ViewNICCPageDispatcher 
{ 

    public ViewNICCPageDispatcher(ApexPages.StandardController sc)
    { 
    
    }
    
    public PageReference redirectToPage() 
    {
 
 		NI_Change_Control__c r;
 
        RecordType rtHostedRFC = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        RecordType rtSFCR = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Salesforce.com Change Request' AND isActive = true];
               
    	if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
    	{	
        	r = [Select Id, RecordTypeId From NI_Change_Control__c Where Id = :ApexPages.currentPage().getParameters().get('id')];
    	}
        else
        {
        	r = new NI_Change_Control__c();
        	r.RecordTypeId = rtHostedRFC.Id;
        }

        if (r.recordtypeid == rtSFCR.Id)
        {
            PageReference customPage = Page.NI_Change_Control_Tabbed_Layout; 
            customPage.setRedirect(true);  
            customPage.getParameters().put('id', r.id);  
            return customPage;    
        }   
        else
        {
            PageReference newPage = new PageReference('/' + r.id);
            newPage.getParameters().put('nooverride', '1');    
            return newPage.setRedirect(true);   
        }
        
// ORIGINAL CODE ===============
//        NI_Change_Control__c r = [Select id, recordtypeid From NI_Change_Control__c Where Id = :ApexPages.currentPage().getParameters().get('id')];
        
        // SANDBOX
        //if (r.recordtypeid == '012P00000000FG2')
        // PRODUCTION
//        if (r.recordtypeid == '01260000000166y')
//        {
//            PageReference customPage =  Page.NI_Change_Control_Tabbed_Layout;
//            customPage.setRedirect(true);
//            customPage.getParameters().put('id', r.id);
//            return customPage;
//        }
//        Else
//        {
//            PageReference newPage = new PageReference('/' + r.id);
//            newPage.getParameters().put('nooverride', '1');
//            return newPage.setRedirect(true);
//        }
        
    }    
    
    static testMethod PageReference testredirectToPageByPage()
    {
        
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
       
        NI_Change_Control__c nicc = new NI_Change_Control__c (RecordTypeId = rt.Id, Outage_Required__c = 'No', Custom_Script__c = 'No', Data_Change__c = 'No', Request_Summary__c = 'Apex Test Request Summary Text', Date_Required__c = System.today());
        insert nicc;
        
        PageReference pref = Page.Dispatcher_NI_Change_Control_View_Page;
        Test.setCurrentPage(pref);        
        pref.getParameters().put('id', nicc.id);

        ViewNICCPageDispatcher v = new ViewNICCPageDispatcher(new ApexPages.StandardController(nicc));

        PageReference ref = v.redirectToPage();
        
//		PageReference customPage = Page.NI_Change_Control_Tabbed_Layout;
//		customPage.setRedirect(true);
//		customPage.getParameters().put('id', nicc.id);
//		return customPage;
		
//		PageReference newPage = new PageReference('/' + nicc.id);
//		newPage.getParameters().put('nooverride', '1');
//		return newPage.setRedirect(true);
		
		return ref;        

    }   
    
    static testMethod PageReference testredirectToPageById()
    {
        
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        
        NI_Change_Control__c nicc = new NI_Change_Control__c (RecordTypeId = rt.Id, Outage_Required__c = 'No', Custom_Script__c = 'No', Data_Change__c = 'No', Request_Summary__c = 'Apex Test Request Summary Text', Date_Required__c = System.today());
        insert nicc;

        PageReference pref = new PageReference('/' + nicc.id);
        Test.setCurrentPage(pref);  
        
        ViewNICCPageDispatcher v = new ViewNICCPageDispatcher(new ApexPages.StandardController(nicc));

        PageReference ref = v.redirectToPage();
        
		return ref;        

    }      
    
}