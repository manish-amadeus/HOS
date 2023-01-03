public with sharing class OrgsInfoCls {
    public PollingResult__c pollRes { get; set; }   
    
    public String times { get; set; }
    
    public String[] accounts { get; set; }
    
    public Boolean isTest { get; set; }
    
    public String schedName { get; set;}
    
    public String error { get; set; }
    
    public String message { get; set; }
    
    public OrgsInfoCls() {
        pollRes = new PollingResult__c();
        isTest = false;     
        string selectedAccount = ApexPages.currentPage().getParameters().get('account');        
        
        error = '';
        pollRes.DateTime__c = DateTime.now().addHours(1);
        schedName = 'Polling Accounts';
        if(selectedAccount != null) {
            NI_Org_Details__c account = [SELECT Id FROM NI_Org_Details__c WHERE Id =: selectedAccount];
            accounts = new List<String>();
            accounts.add(account.Id);
        }
    }
    
    public SelectOption[] getTimesOptions() {
        List<SelectOption> options = new List<SelectOption>();
                
        for(Integer i = 1; i < 24; i++) {
            options.add(new SelectOption(string.valueOf(i), string.valueOf(i)));
        }
        if(times == null) {
            times = '4';
        }       
        return options;
    }
    
    public SelectOption[] getAccountsOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Boolean add = false;  
            
        if(accounts == null) {
             accounts = new List<String>();
             add = true;
        }   
        
        // CHANGES MADE TO THIS ROUTINE SINCE ENCRYPTED FIELDS CANNOT BE PART OF A SOQL WHERE CLAUSE NICC-015316
        for(NI_Org_Details__c account : [SELECT Id, Name, Admin_Login_Name_Encrypted__c, Org_Name__c FROM NI_Org_Details__c WHERE Org_Name__c != null ORDER BY Org_Name__c]) {
            options.add(new SelectOption(account.Id, account.Org_Name__c));
            if(account.Admin_Login_Name_Encrypted__c != null)
            {
              options.add(new SelectOption(account.Id, account.Org_Name__c));
            }  
            if(add && account.Admin_Login_Name_Encrypted__c != null) accounts.add(account.Id);
        }
        return options;
    }
    
    public void run() {
        clearMessages();
        try {       
            if(!isTest) Database.executeBatch(new FillAccountBatch(accounts), 1);
            message = 'Batch submited successfully';
        }
        catch(Exception ex) {
            error = ex.getMessage();
        }
    }
    
    public void schedule() {
        clearMessages();
        String schedDate = getScheduleDate();
        FillAccountSchedule fas = new FillAccountSchedule(accounts, Integer.valueOf(times), schedName);     
        
        try {
            if(!isTest) System.schedule(schedName, schedDate, fas);
            message = 'Scheduled successfully'; 
        }
        catch(Exception ex) {
            error = ex.getMessage();
        }
    }
    
    private void clearMessages() {
        error = '';     
        message = '';
    }
    
    private String getScheduleDate() {
        DateTime dt = pollRes.DateTime__c;
        
        return '0 ' + 
               string.valueOf(dt.minute()) + ' ' +
               string.valueOf(dt.hour()) + ' ' + 
               string.valueOf(dt.day()) + ' ' +
               string.valueOf(dt.month()) + ' ' + 
               '? '  + 
               string.valueOf(dt.year());
    }
    
    public static testmethod void testTimes() {
        SelectOption[] options = new OrgsInfoCls().getTimesOptions();
        
        for(Integer i = 1; i < 24; i++) {
            System.assertEquals(string.valueOf(i), options[i - 1].getValue());
            System.assertEquals(string.valueOf(i), options[i - 1].getLabel());
        }
    }
    
    public static testmethod void testFake() {
        OrgsInfoCls oic = new OrgsInfoCls();
        
        oic.isTest = true;
        oic.run();
        oic.times = '1';
        oic.getAccountsOptions();
        oic.schedule();
    }
}