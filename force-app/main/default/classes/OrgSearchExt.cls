/************************************************************************************************
Name            : OrgSearchExt
Author          : Michael Pedro
Last Mod Date   : 05/05/2022
Last Mod By     : Michael Pedro
Description     : Page for manual testing orgSearch batch/schedule
*************************************************************************************************/

public with sharing class OrgSearchExt {
    public String times { get; set; }
    public String[] orgDetailRecords { get; set; }
    public OrgInfo__c dateInfo {get; set;}
    public Boolean isTest { get; set; }
    public String schedName { get; set;}
    public String error { get; set; }
    public String message { get; set; }
    
    public OrgSearchExt() {        
        isTest = false;     
        error = '';
        times = '24';
        schedName = 'Org Detail Search';
        dateInfo = new OrgInfo__c();
        Date nextRun = Date.today().addDays(1);
        dateInfo.AHRenewalDate__c = DateTime.newInstance(nextRun.year(), nextRun.month(), nextRun.day(), 0,0,0);
        getOrgDetailList();
    }
    
    public SelectOption[] getTimesOptions() {
        List<SelectOption> options = new List<SelectOption>();

        for(Integer i = 1; i < 48; i++) {
            options.add(new SelectOption(string.valueOf(i), string.valueOf(i)));
        } 
        return options;
    }

      //Retrieve all the Org Detail Reocrds user has access to.
      public void getOrgDetailList(){
        try{
            orgDetailRecords = new List<String>();
            List<NI_Org_Details__c> details = Data.read('SELECT Id, Name, Admin_Login_Name_Encrypted__c, Org_Name__c FROM NI_Org_Details__c WHERE Org_Name__c != null ORDER BY Org_Name__c');
            for (NI_Org_Details__c orgDetail : details) { 
                if (orgDetail.Admin_Login_Name_Encrypted__c != null) {
                    orgDetailRecords.add(orgDetail.Id);
                }
            }
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
    
    public void search() {
        clearMessages();
        try {
            if(!isTest) {
                Database.executeBatch(new OrgInfoBatch(orgDetailRecords), 1);
            }       
            message = 'Batch submited successfully';
        }
        catch(Exception ex) {
            error = ex.getMessage();
        }
    }
    
    public void scheduleOrgSearch() {
        clearMessages();
        String schedDate = getScheduleDate();
        OrgSearchSchedule searchSched = new OrgSearchSchedule(orgDetailRecords, Integer.valueOf(times), schedName);     
        
        try {
            if(!isTest) {
                System.schedule(schedName, schedDate, searchSched);   
            }
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
        DateTime dt = dateInfo.AHRenewalDate__c;
        
        return '0 ' + 
               string.valueOf(dt.minute()) + ' ' +
               string.valueOf(dt.hour()) + ' ' + 
               string.valueOf(dt.day()) + ' ' +
               string.valueOf(dt.month()) + ' ' + 
               '? '  + 
               string.valueOf(dt.year());
    }
}