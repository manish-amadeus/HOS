/************************************************************************************************************************
Name            : NI_Scheduled_DINames Schedulable Class
Author          : Sean Harris
Created Date    : 7/28/2014
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-010621 - Product Group Consolidation Data Project 
Description     : Scans Product2 & Product_Group__c objects for records where the Update_Related_DI_Names__c equals true.
                : Collects all related Product2 Ids then performs an update to all DI records referenced to these Products.
                : It updates by setting a bogus DI Name value invoking the workflow to then build and change the name.
				: This in turn will trigger another workflow that flags the Asset.WriteHistory__c field.
				: because of this, the NI_Scheduled_DIHistory class must be scheduled to run after this job.
*************************************************************************************************************************/
global class NI_Scheduled_DINames implements Schedulable 
{
    
    // RUN NI_Scheduled_DINames.scheduleIt(); IN DEV CONSOLE TO CREATE SCHEDULED APEX JOB
    global static String scheduleIt(String CRON_EXP) 
    {
        NI_Scheduled_DINames sched = new NI_Scheduled_DINames();
        return System.schedule('Update Deployment Instance Names', CRON_EXP, sched);
    }    
    
    global void execute(SchedulableContext sc) 
    {
        
        // LIST TO RESTORE Product_Group__c.Update_Related_DI_Names__c THAT ARE true TO false
        List<Product_Group__c> lstProductGroupRestore = new List<Product_Group__c>();
        
        // SET TO HOLD PRODUCT GROUP IDS OF CHECKED RECORDS
        Set<Id> setProductGroupIds = new Set<Id>();
        
        // FILL SET WITH PRODUCT GROUP IDS OF CHECKED RECORDS AND A LIST TO BE UPDATED
        for (Product_Group__c g : [SELECT Id, Update_Related_DI_Names__c FROM Product_Group__c WHERE Update_Related_DI_Names__c = true])
        {
            setProductGroupIds.Add(g.Id); 
            g.Update_Related_DI_Names__c = false; 
            lstProductGroupRestore.Add(g);            
        }
        
        // LIST TO UPDATE Product2.Update_Related_DI_Names__c FIELD VALUE TO true
        List<Product2> lstProductUpdates = new List<Product2>();
        
        // FILL LIST TO UPDATE Product2.pdate_Related_DI_Names__c FIELD VALUE TO true
        for (Product2 pUps : [SELECT Id, Update_Related_DI_Names__c FROM Product2 WHERE Product_Group__c IN : setProductGroupIds])
        {
            pUps.Update_Related_DI_Names__c = true;
            lstProductUpdates.Add(pUps);
        } 
        
        // UPDATE RELATED PRODUCT'S Update_Related_DI_Names__c FIELD TO true
        Database.Update(lstProductUpdates, false);
        
        // LIST TO RESTORE Product2.Update_Related_DI_Names__c THAT ARE true TO false
        List<Product2> lstProductRestore = new List<Product2>();
        
        // SET TO HOLD PRODUCT IDS OF CHECKED RECORDS
        // SET THAT IS PASSED TO BATCH METHOD
        Set<Id> setProductIds = new Set<Id>();
        
        // FILL LIST TO UPDATE Product2.Update_Related_DI_Names__c FIELD VALUE TO false
        for (Product2 p : [SELECT Id, Update_Related_DI_Names__c FROM Product2 WHERE Update_Related_DI_Names__c = true])
        {
            setProductIds.Add(p.Id);
            p.Update_Related_DI_Names__c = false;
            lstProductRestore.Add(p);
        } 
        
        // IF RECORDS FOUND START BATCH PROCESSING 
        if (lstProductRestore.size() > 0)
        {
            
            NI_Scheduled_DINames_Batch b = new NI_Scheduled_DINames_Batch(setProductIds);
            ID batchprocessid = Database.executeBatch(b);

            // USE DATABASE DML METHOD TO UPDATE THE PRODUCT FLAGS BACK TO FALSE
            Database.SaveResult[] results1 = Database.Update(lstProductRestore, false);
            for (Database.SaveResult sr1: results1)
            {
                if (!sr1.isSuccess())
                {
                    Database.Error err1 = sr1.getErrors()[0];
                    System.debug(err1.getMessage());
                } 
            }           
        }
        
        if (lstProductGroupRestore.size() > 0)
        {
            // USE DATABASE DML METHOD TO UPDATE THE PRODUCT FLAGS BACK TO FALSE
            Database.SaveResult[] results2 = Database.Update(lstProductGroupRestore, false);
            for (Database.SaveResult sr2: results2)
            {
                if (!sr2.isSuccess())
                {
                    Database.Error err2 = sr2.getErrors()[0];
                    System.debug(err2.getMessage());
                } 
            }           
        }
        
    }
    
}