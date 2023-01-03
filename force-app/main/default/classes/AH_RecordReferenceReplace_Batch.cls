/****************************************************************************************
Name            : AH_RecordReferenceReplace_Batch Class
Author          : Shashikant Nikam
Created Date    : 07/03/2019
Last Mod Date   : 12/12/2019
Last Mod By     : Shashikant Nikam  
NICC Reference  : 
Description     : Batch class to iterate over list of sObjects, collect the list of records & pass to the AH_RecordReferenceUpdate_Batch for actual replacement of record reference
:
******************************************************************************************/

global class AH_RecordReferenceReplace_Batch implements Database.Batchable<String>, Database.Stateful
{
    Map<Integer,List<String>> mapp = new Map<Integer,List<String>>();
    public ID inputID;
    public ID replacementID;
    public String timeStamp;
    public Integer count;
    public Boolean runBatch = false;
    List<sObject> updateList = new List<sObject>();
    
    // CONSTRUCTOR
    public AH_RecordReferenceReplace_Batch (Id inputSFID, Id replaceSFID, Map<Integer,List<String>> objectToField, String timeString)
    {
        system.debug('In batch constructor method..'+inputSFID);
        inputID = inputSFID;
        replacementID = replaceSFID;
        timeStamp = timeString;
        system.debug('objectToField : '+objectToField);
       	mapp  = objectToField;        
    }
    
    
    // START METHOD
    global Iterable<String> start (Database.BatchableContext BC)
    {
        count = 0;
        List<String> lst = new List<String>();
        if(!mapp.isEmpty())
        {
            for(Integer cnt : mapp.keySet())
            {
                List<String> ll = mapp.get(cnt);
                
                String s = ll[0] +'=>'+ ll[1];
                if(Test.isRunningTest() && (ll[0] == 'pse__Milestone__c' || ll[0] == 'Case'))
                {
                    lst.add(s);
                    break;
                }
                else if (!Test.isRunningTest()) {
                	lst.add(s);
                }
            }
        }
        return lst;
    }
    
    
    // EXECUTE METHOD
    global void execute (Database.BatchableContext BC, List<String> scope)
    {
        List<String> parts = scope[0].split('=>');
        system.debug('parts[0] : '+parts[0]);
        //if(parts[0] == 'Opportunity' && parts[1] == 'License_Program_Payment_Terms__c')
        //{
            system.debug('In execute method..');
            system.debug('Scope size : '+scope.size());
            system.debug('Scope element : '+scope[0]);
            system.debug('replacementID : '+replacementID);
        
            String dbQuery = 'SELECT ID, Name FROM '+parts[0]+' WHERE '+parts[1]+' = \''+ inputID +'\'';
            system.debug('dbQuery : '+dbQuery);
            
            // EXECUTE SELECT QUERY TO FIND OUT THE REFERENCED RECORD
            List<sObject> sObjList = new List<sObject>();
            try  
            {
                sObjList = Database.query(dbQuery);
                system.debug('sObjList size : '+sObjList.size());
                count++;
            }
            catch(Exception e)
            {
                system.debug('Found exception : '+e);
                
                if (e.getMessage().contains('No such column \'Name\' on entity'))
                {
                    String dbQuery1 = 'SELECT ID FROM '+parts[0]+' WHERE '+parts[1]+' = \''+ inputID +'\'';
                    system.debug('Second dbQuery : '+dbQuery1);
                    
                    sObjList = Database.query(dbQuery1);
                    count++;
                }
            }
            
            
            if (!sObjList.isEmpty())
            {
                for (sObject s : sObjList)
                {
                    s.put(parts[1], replacementID);
                    updateList.add(s);
                }
                
            }
        //}
    }

    
    // FINISH METHOD
    global void finish (Database.BatchableContext BC)
    {
        // CALL THE UPDATE BATCH TO REPLACE THE REFERENCES  
        system.debug('in Replace_Batch finish method....Calling update batch...'+updateList.size());
        AH_RecordReferenceUpdate_Batch updateBatch = new AH_RecordReferenceUpdate_Batch(updateList, timeStamp);
        ID updateBatchID = Database.executeBatch(updateBatch,250);

        // INSERT RECORD IN Job_Run_History__c FOR REPLACE BATCH  
        Job_Run_History__c runHist = new Job_Run_History__c();
        runHist.Apex_Class__c = 'AH_RecordReferenceReplace_Batch';
        runHist.Status__c = 'Run';
        runHist.No_of_Items_Processed__c = count++;
        runHist.Target_Object__c = ''; 
        runHist.User__c = UserInfo.getUserName();
        runHist.Created_Date__c = Datetime.now();
        runHist.Unique_Timestamp__c = timeStamp; 
        runHist.Status_Detail__c = 'Success';
        
        insert runHist;
    }
}