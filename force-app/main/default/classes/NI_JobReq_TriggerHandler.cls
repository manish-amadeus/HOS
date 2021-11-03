/************************************************************************************************
Name            : NI_JobReq_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 2/23/2015
Last Mod Date   : 2/23/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_JobRequisition__c Object
                :
*************************************************************************************************/
public class NI_JobReq_TriggerHandler {
    
    private boolean m_isExecuting = false;
    
    //SET TO HOLD THE JOB REQUISITION RECORD TYPE IDs  
    public Set<Id> setRTypes = new Set<Id>();
    
    public NI_JobReq_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }
    
    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }
    //========================================================================================================================
    public void OnBeforeInsert(List<NI_Job_Requisition__c> newTrigger)
    {
        //LIST TO HOLD THE VALUES FROM THE NI_Job_Req_RecordType_Trigger_Handler CUSTOM SETTING  
        List<NI_Job_Req_RecordType_Trigger_Handler__c> lstCS = NI_Job_Req_RecordType_Trigger_Handler__c.getAll().values();
        
        //LIST TO HOLD THE JOB REQUISITION RECORDS THAT SHOULD BE PASSED TO THE "Update_ExecApproverField" METHOD
        List<NI_Job_Requisition__c> lstJobReqsToUpdate = new List<NI_Job_Requisition__c>();
        
        //LOOP THROUGH THE lstCS AND GET THE JOB REQUISITION RECORDTYPEIDs FOR THE RECORD TYPES THAT SHOULD EXECUTE THE "Update_ExecApproverField" METHOD 
        for (NI_Job_Req_RecordType_Trigger_Handler__c jrt : lstCS)
        {
            System.debug('JOB REQ TRIGGER HANDLER CUSTOM SETTING NAME: ' + jrt.Name);
            System.debug('JOB REQ TRIGGER HANDLER CUSTOM SETTING EXEC APPROVER: ' + jrt.Exec_Approver__c);
            if(jrt.Exec_Approver__c == true)
            {
                System.debug('JOB REQUISITION RECORD TYPE NAME: ' + jrt.Name);
                setRTypes.add(NI_TestClassData.getRecordTypeId('NI_Job_Requisition__c', jrt.Name)); 
            }
            
        }
        
        if (setRTypes.size()>0)
        {
            for(Id rTypeId : setRTypes)
            {
                for (NI_Job_Requisition__c jr : newTrigger) 
                {
                    if (jr.RecordTypeId == rTypeId)
                    {
                        lstJobReqsToUpdate.add(jr);  
                    }
                    
                }   
            }
            
        }
        
        Update_ExecApproverField(lstJobReqsToUpdate);
    }
    
    //===================================================================================================================    
    public void OnAfterInsert(List<NI_Job_Requisition__c> newTrigger)
    {
        
        //CALL THE MANAGER APEX SHARING METHOD  
        Change_Manager_Share(newTrigger);
        
        //CALL THE EXEC APPROVER APEX SHARING METHOD 
        Change_ExecApprover_Share(newTrigger);
        
        //LIST OF THE INSERTED JOB REQUISITIONS
        List<NI_Job_Requisition__c> lstInsertedJobReqs = [SELECT Id, Employee_to_Disable__c, Employee_Disable_Date__c, RecordType.Name 
                                                          FROM NI_Job_Requisition__c 
                                                          WHERE Id IN: newTrigger];
        
        //LIST OF REMOVE USERS
        List<NI_Job_Requisition__c> lstRemoveUser = new List<NI_Job_Requisition__c>();
        
        for(NI_Job_Requisition__c j : lstInsertedJobReqs)
        {
          if(j.RecordType.Name == 'Standard Remove User')
          {
            lstRemoveUser.add(j);  
              
          }  
            
        }
        System.debug('NUMBER OF REMOVE USER RECORDS: ' + lstRemoveUser.size());
        //CALL THE setUserExpirationDate METHOD 
        setUserExpirationDate(lstRemoveUser);
    }
    
    //========================================================================================================================
    public void OnBeforeUpdate (List<NI_Job_Requisition__c> newTrigger, Map<Id,NI_Job_Requisition__c> oldMapTrigger)
    {
        checkAttachments(newTrigger);
    }
    
    //===================================================================================================================    
    public void OnAfterUpdate(List<NI_Job_Requisition__c> newTrigger, Map<Id,NI_Job_Requisition__c> oldMapTrigger)
    {  
        //CREATE  LIST TO HOLD ALL RECORDS WHERE THE NEW MANAGER DOESN'T MATCH THE OLD MANAGER
        List<NI_Job_Requisition__c> lstManagerShare = new List<NI_Job_Requisition__c>();
        
        //CREATE  LIST TO HOLD ALL RECORDS WHERE THE NEW EXEC APPROVER DOESN'T MATCH THE OLD EXEC MEMBER
        List<NI_Job_Requisition__c> lstExecApproverShare = new List<NI_Job_Requisition__c>();  
        
        for (NI_Job_Requisition__c jr : newTrigger) 
        {
            NI_Job_Requisition__c oldJR = oldMapTrigger.get(jr.Id);
            
            if (jr.Manager__c != oldJR.Manager__c)
            {
                lstManagerShare.add(jr);
            }
            
            if (jr.Exec_Approver__c != oldJR.Exec_Approver__c)
            {
                lstExecApproverShare.add(jr);
            }  
        }      
        
        //CALL THE MANAGER APEX SHARING METHOD
        if (lstManagerShare.size() > 0)
        {  
            Change_Manager_Share(lstManagerShare);
        }  
        
        //CALL THE EXEC APPROVER APEX SHARING METHOD
        if (lstExecApproverShare.size() > 0)
        {  
            Change_ExecApprover_Share(lstExecApproverShare);
        }       
        
    }        
    
    //=========================================================================================================================          
    //THIS METHOD UPDATES THE EXEC APPROVER FIELD BASED ON THE NI LOCATION AND DEPARTMENT
    public void Update_ExecApproverField(List<NI_Job_Requisition__c> newTrigger)
    {
        
        //LIST OF NI JOB REQUISITION RECORDS IN newTrigger    
        List<NI_Job_Requisition__c> lstJobReq = [SELECT Id, Department__c,NI_Location__c
                                                 FROM NI_Job_Requisition__c 
                                                 WHERE Id IN: newTrigger];
        //SET TO HOLD THE DEPARTMENT IDs OF THE JOB REQUISITION RECORDS
        Set<Id> setDepartmentIds = new Set<Id>();
        
        //SET TO HOLD THE LOCATION IDs OF THE JOB REQUISITION RECORDS   
        Set<Id> setLocationIds = new Set<Id>();  
        
        for (NI_Job_Requisition__c jr : newTrigger) 
        {
            setDepartmentIds.add(jr.Department__c);                
            System.debug('DEPARTMENT ID: ' + jr.Department__c);
            setLocationIds.add(jr.NI_Location__c);
            System.debug('LOCATION ID: ' + jr.NI_Location__c);   
        }   
        
        if(setDepartmentIds.size()>0 && setLocationIds.size()>0)
        {  
            //SET TO HOLD THE DEPARTMENT TO LOCATION IDs 
            List<NI_Department_to_Location__c> lstDepToLocation = [SELECT Id,Employee__c,NI_Departments__c,Location__c,Role__c
                                                                   FROM NI_Department_to_Location__c
                                                                   WHERE NI_Departments__c IN: setDepartmentIds
                                                                   AND Location__c IN: setLocationIds
                                                                   AND Role__c = 'Exec Member'];  
            if(lstDepToLocation.size()>0)
            {
                for(NI_Job_Requisition__c jreq : newTrigger)
                {
                    for(NI_Department_to_Location__c dtl : lstDepToLocation)
                    {
                        if(jreq.Department__c == dtl.NI_Departments__c && jreq.NI_Location__c == dtl.Location__c)
                        {
                            jreq.Exec_Approver__c = dtl.Employee__c;
                        }
                    }
                }
            }    
        }
    }
    // ================================================================================================
    //  APEX SHARING METHODS
    // ================================================================================================
    
    //MANAGER SHARE
    public void Change_Manager_Share(List<NI_Job_Requisition__c> newTrigger)
    {          
        
        //LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Job_Requisition__Share> lstSharesToRemove = new List<NI_Job_Requisition__Share>([
            SELECT id 
            FROM NI_Job_Requisition__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Manager_Share__c']); 
        
        // BULK REMOVE SHARE RECORDS
        if (lstSharesToRemove.size() > 0)
        {
            Database.DeleteResult[] drList = Database.delete(lstSharesToRemove, false);
            for (Database.DeleteResult dr : drList) 
            {
                if (dr.isSuccess()) 
                {
                    System.debug('**SUCCESSFULLY DELETED SHARE RECORD ID: ' + dr.getId());
                }
                else 
                {
                    Database.Error err = dr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }        
        }
        
        //LIST OF SHARES THAT NEED TO BE ADDED   
        List<NI_Job_Requisition__Share> lstSharesToInsert = new List<NI_Job_Requisition__Share>();
        
        for (NI_Job_Requisition__c jr : newTrigger)
        {
            if ((jr.Manager__c != jr.OwnerId) && (jr.Manager__c != null))
            {
                NI_Job_Requisition__Share jrShare = new NI_Job_Requisition__Share();
                jrShare.ParentId = jr.Id;
                jrShare.UserOrGroupId = jr.Manager__c;
                jrShare.AccessLevel = 'Edit';
                jrShare.RowCause = Schema.NI_Job_Requisition__Share.RowCause.Manager_Share__c;
                lstSharesToInsert.add(jrShare);
            } 
            
        }
        
        //USE DATABASE DML METHOD TO ADD THE SHARES
        if(lstSharesToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstSharesToInsert,true);
            for(Database.SaveResult sr: results)
            {
                if(!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }
        } 
        
    }
    //=============================================================================================================    
    //EXEC APPROVER SHARE
    public void Change_ExecApprover_Share(List<NI_Job_Requisition__c> newTrigger)
    {          
        
        //LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Job_Requisition__Share> lstSharesToRemove = new List<NI_Job_Requisition__Share>([
            SELECT id 
            FROM NI_Job_Requisition__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Exec_Approver_Share__c']); 
        
        // BULK REMOVE SHARE RECORDS
        if (lstSharesToRemove.size() > 0)
        {
            Database.DeleteResult[] drList = Database.delete(lstSharesToRemove, false);
            for (Database.DeleteResult dr : drList) 
            {
                if (dr.isSuccess()) 
                {
                    System.debug('**SUCCESSFULLY DELETED SHARE RECORD ID: ' + dr.getId());
                }
                else 
                {
                    Database.Error err = dr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }        
        }
        
        //LIST OF SHARES THAT NEED TO BE ADDED   
        List<NI_Job_Requisition__Share> lstSharesToInsert = new List<NI_Job_Requisition__Share>();
        
        for (NI_Job_Requisition__c jr : newTrigger)
        {
            if ((jr.Exec_Approver__c != jr.OwnerId) && (jr.Exec_Approver__c != null))
            {
                NI_Job_Requisition__Share jrShare = new NI_Job_Requisition__Share();
                jrShare.ParentId = jr.Id;
                jrShare.UserOrGroupId = jr.Exec_Approver__c;
                jrShare.AccessLevel = 'Read';
                jrShare.RowCause = Schema.NI_Job_Requisition__Share.RowCause.Exec_Approver_Share__c;
                lstSharesToInsert.add(jrShare);
            } 
            
        }
        
        //USE DATABASE DML METHOD TO ADD THE SHARES
        if(lstSharesToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstSharesToInsert,true);
            for(Database.SaveResult sr: results)
            {
                if(!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }
        } 
        
    }
    
    //===================================================================================================================
    public void checkAttachments (List<NI_Job_Requisition__c> newTrigger)
    {
        //CREATE A SET TO HOLD ALL OF THE JOB REQUISITION IDs
        Set<Id> setJobReqId = new Set<Id>();
        
        for (NI_Job_Requisition__c j : newTrigger) 
        {
            setJobReqId.add(j.Id);                
        }
        
        List <Attachment> lstJobReqAttachments = [SELECT Id, ParentId FROM Attachment WHERE ParentId IN: setJobReqId];
        
        for(NI_Job_Requisition__c jrq : newTrigger)
        {
            jrq.Has_Attachment__c = false;
            for (Attachment jreqAttach : lstJobReqAttachments) 
            {
                if(jrq.Id == jreqAttach.ParentId)
                {
                    jrq.Has_Attachment__c = true;  
                } 
                else
                {
                    jrq.Has_Attachment__c = false; 
                }  
            }
            
        }
    }
    //===================================================================================================================
    public void setUserExpirationDate (List<NI_Job_Requisition__c> newTrigger)
    {
        //CREATE A SET TO HOLD ALL OF THE UNIQUE USER IDs
        Set<Id> setUsersToDisable = new Set<Id>();
        
        for (NI_Job_Requisition__c j : newTrigger) 
        {
            setUsersToDisable.add(j.Employee_to_Disable__c);                
        }
        
        //LIST OF ALL USERS RELATED TO THE JOB REQ
        List<User> lstUsers = [SELECT Id,Expiration_Date__c  FROM User WHERE Id IN: setUsersToDisable];
        
        //LIST TO HOLD THE USERS TO UPDATE
        List<User> lstUsersToUpdate = new List<User>();
        
        for (NI_Job_Requisition__c jr : newTrigger)
        {
            for(User u : lstUsers)
            {
                If(jr.Employee_to_Disable__c == u.Id)
                {
                    u.Expiration_Date__c = jr.Employee_Disable_Date__c;
                    lstUsersToUpdate.add(u);
                }
            }
        }  
        //USE DATABASE DML METHOD TO UPDATE THE USER RECORDS
        if(lstUsersToUpdate.size() > 0)
        {
            Database.SaveResult[] results = Database.update(lstUsersToUpdate,true);
            for(Database.SaveResult sr: results)
            {
                if(!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }
        } 
    }
    
}