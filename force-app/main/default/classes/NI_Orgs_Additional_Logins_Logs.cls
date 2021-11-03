/****************************************************************************************
Name            : NI_Orgs_Additional_Logins_Logs Class
Author          : Swapnil Patil
Created Date    : 7/31/2016
Last Mod Date   : 8/23/2016
Last Mod By     : Stuart Emery
NICC Reference  : NICC-019058
Description     : Controller for the NI Orgs Additional Logins Logs Visualforce page.
                : This controller creates an NI Org Details Additional Logins Log record
                : everytime an Org Details Additional Login record is viewed
                : There is an override on the standard "View" page to redirect to the 
                : NI Orgs Additional Logins Logs Visualforce page                
******************************************************************************************/
public class NI_Orgs_Additional_Logins_Logs {
    public ID lid;
    private NI_Org_Details_Additional_Logins__c niLogin;
    public NI_Orgs_additional_Logins_Logs(ApexPages.standardController  stdCon){
        this.niLogin = (NI_Org_Details_Additional_Logins__c)stdcon.getRecord(); 
        system.debug(this.niLogin);
        if(niLogin.id != null){
            lid = niLogin.id;
        }
    }
   public Pagereference insertViewDetail(){
        //NI_Org_Details_Additional_Logins__c niLogin = [Select ]
        NI_Org_Details_Additional_Logins_Logs__c niLoginLog = new NI_Org_Details_Additional_Logins_Logs__c();
        niLoginLog.Name = 'Additional Logins Log ' + Datetime.Now().format();
        niLoginLog.NI_Org_Details_Additional_Logins__c = lid;
        niLoginLog.Source_IP__c = GetUserIPAddress();
        insert niLoginLog;
       
       PageReference newPage;
       newPage = new PageReference('/' + lid);
       newPage.getParameters().put('nooverride', '1');
        
        newPage.getParameters().put('id', lid);
        return newPage.setRedirect(true);
        
        //return null;
    }
    public static String GetUserIPAddress() {
     string ReturnValue = '';  
       
     // True-Client-IP has the value when the request is coming via the caching integration.
            ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
     
              // X-Salesforce-SIP has the value when no caching integration or via secure URL.
            if (ReturnValue == '' || ReturnValue == null) {
             ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            } // get IP address when no caching (sandbox, dev, secure urls)
     
             if (ReturnValue == '' || ReturnValue == null) {
             ReturnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
            } // get IP address from standard header if proxy in use
     
     return ReturnValue;
      
    }
    
}