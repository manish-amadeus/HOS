/****************************************************************************************
Name            : AH_SAPCashEntryJournal_Schedule
Author          : Bhagwat Garkal
Created Date    : 10/14/2021
Modified Date   : 11/23/2021
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Schedulable class to Create Cash Entries and Journals.
                : new AH_SAPCashEntryJournal_Schedule().execute(null);
                :
******************************************************************************************/
global class AH_SAPCashEntryJournal_Schedule implements Schedulable 
{

    global Boolean isTest {get; set;} 
    private String strFFACompanyName = 'Newmarket US';
    
    
    global AH_SAPCashEntryJournal_Schedule() 
    {
        isTest = false; 
    }

    global AH_SAPCashEntryJournal_Schedule(String strFFACoName) 
    {
        isTest = false; 
        strFFACompanyName = strFFACoName;
    }
    
    global static String scheduleIt(String strFFACoName, String CRON_EXP) 
    {
        AH_SAPCashEntryJournal_Schedule sched = new AH_SAPCashEntryJournal_Schedule(strFFACoName);
        return system.schedule('SAP Cash Entry Journals - ' + strFFACoName, CRON_EXP, sched);
    }    
    
    global void execute(SchedulableContext sc) 
    {
        
        system.debug('  In AH_SAPCashEntryJournal_Schedule.execute ... '); 
        
        // SWITCH RUNNING USER'S FFA COMPANY TO A SINGLE
        //NI_FUNCTIONS.setSingleFFACompanyForUser(strFFACompanyName, Userinfo.getUserId()); 
        setSingleFFACompanyForUser(strFFACompanyName, Userinfo.getUserId());
                
        AH_SAPCashEntryJournal_Batch batchable = new AH_SAPCashEntryJournal_Batch(strFFACompanyName); 
        List<Id> batchJobIdList = new List<Id>(); 
        Id batchJobId = Database.executeBatch(batchable, 20); 		// ADDED 2022-10-06 
        batchJobIdList.add(batchJobId); 
        
        system.debug('  batchJobIdList ==> ' + batchJobIdList); 
        
        List<AsyncApexJob> aajLst = [SELECT Id, ApexClassId, ApexClass.Name, CompletedDate, ExtendedStatus, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                                     FROM AsyncApexJob 
                                     WHERE Id IN : batchJobIdList];
        
        system.debug('  aajLst ==> ' + aajLst); 
        
        if (aajLst != null && aajLst.Size() != 0)
        {
            // Create DTS Integration Logs.
            DTS_Integration_Log__c dtslogObj = new DTS_Integration_Log__c();
            
            dtslogObj.Date_Time__c = System.now(); //aajLst[0].CompletedDate;
            dtslogObj.Details__c = aajLst[0].ExtendedStatus;
            dtslogObj.Integration_Name__c = 'GFT SAP Integration';
            
            if (aajLst[0].Status == 'Failed')
            {
                dtslogObj.Integration_Status__c = 'Failure';
                dtslogObj.Type__c  = 'Failure';
            }
            else
            {
                dtslogObj.Integration_Status__c = 'Active';
                dtslogObj.Type__c  = 'Success';
            }   
            
            //dtslogObj.Job_Process_ID__c = batchJobId;
            dtslogObj.Job_Process_Name__c = aajLst[0].ApexClass.Name;
            dtslogObj.Job_Process_Type__c = 'Apex Batch Job';
            dtslogObj.Requires_Business_Assistance_to_Resolve__c = true;
            dtslogObj.Summary__c = 'Batch processing of SAP cash entries and journals has completed with ' + aajLst[0].Status;
            
            //insert dtslogObj; WILL CAUSE MIXED DML OPERATION ERROR
            
        }
        
    }

    /*private String getNextRun(DateTime dt) 
    {       
        return '0 ' + 
               string.valueOf(dt.minute()) + ' ' +
               string.valueOf(dt.hour()) + ' ' + 
               string.valueOf(dt.day()) + ' ' +
               string.valueOf(dt.month()) + ' ' + 
               '? '  + 
               string.valueOf(dt.year());
    }*/
    
    public static boolean setSingleFFACompanyForUser(String strCompanyName, Id userId)
    {
        
        boolean bRetVal = false;
        
        try
        {
            
            // CLEAR OUT ANY EXISTING FFA COMPANIES ON USER
            List<GroupMember> lstGroupMemberDeletes = new List<GroupMember>(
                [SELECT Id FROM GroupMember WHERE UserOrGroupId =: userId]); 
            
            if (!lstGroupMemberDeletes.isEmpty())
            {
                Database.delete(lstGroupMemberDeletes);
            }
            
            // ADD SINGLE FFA COMPANY TO USER
            c2g__codaCompany__c ffaCO = [SELECT Id, OwnerId FROM c2g__codaCompany__c WHERE Name =: strCompanyName];                                                                 
            
            GroupMember gm = new GroupMember();
            gm.GroupId = ffaCO.OwnerId;
            gm.UserOrGroupId = userId;
            insert gm;
            
            bRetVal = true;
            
        }
        catch (Exception ex){}
        
        return bRetVal;
        
    }

}