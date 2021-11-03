/************************************************************************************************
Name            : NI_Pager_Bonus_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 5/14/2014
Last Mod Date   : 5/23/2014
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_Pager_Bonus__c Object
                : 
                : 
*************************************************************************************************/
public class NI_Pager_Bonus_TriggerHandler 
{

    public void OnBeforeInsert(List<NI_Pager_Bonus__c> newTrigger)
    {
      
      //SET TO HOLD THE IDs OF THE PAGER BONUS OWNER
        Set<Id> setOwner = new Set<Id>();
        
        for(NI_Pager_Bonus__c p : newTrigger)
           {
             if(p.Employee_Name__c == null)
               {
                 setOwner.add(p.OwnerId);  //ADD THE OWNERID TO THE SET IF THE EMPLOYEE NAME IS NULL
               }
             else
               {
                 setOwner.add(p.Employee_Name__c);  //ADD THE ID OF THE EMPLOYEE NAME TO THE SET IF IT EXISTS
               }      
           }  
      
      //CREATE A MAP TO HOLD THE MANAGER RECORDS FOR THE EMPLOYEE NAME OF THE NI PAGER BONUS RECORD  
        Map<Id, User> mapMgr = new Map<Id, User>([SELECT Id, ManagerId, Manager.Name  
                                                           FROM User
                                                           WHERE Id IN: setOwner]);
        for(NI_Pager_Bonus__c pb : newTrigger)
           {
            if(pb.Employee_Name__c == null)
              {
                pb.Employee_Name__c = pb.OwnerId;
              }  
            
            if(mapMgr.get(pb.Employee_Name__c).Manager.Name != null) //CHECK TO SEE IF THE EMPLOYEE HAS A MANAGER
               {
                 pb.Final_Approver__c = mapMgr.get(pb.Employee_Name__c).Manager.Id;
               }
             else
               {
                 pb.Final_Approver__c = null;
               }      
           }                 
  }

//==========================================================================================================================    
   public void OnBeforeUpdate(List<NI_Pager_Bonus__c> newTrigger, Map<Id,NI_Pager_Bonus__c> oldMapTrigger)
    {
        //SET TO HOLD THE IDs OF THE PAGER BONUS OWNER
        Set<Id> setOwner = new Set<Id>();
        
        for(NI_Pager_Bonus__c p : newTrigger)
           {
             setOwner.add(p.Employee_Name__c);
           }  
      
      //CREATE A MAP TO HOLD THE MANAGER RECORDS FOR THE EMPLOYEE NAME OF THE NI PAGER BONUS RECORD  
        Map<Id, User> mapMgr = new Map<Id, User>([SELECT Id, ManagerId, Manager.Name  
                                                           FROM User
                                                           WHERE Id IN: setOwner]);
        for(NI_Pager_Bonus__c pb : newTrigger)
           {
             NI_Pager_Bonus__c oldPB = oldMapTrigger.get(pb.Id);
                   
             if (pb.Employee_Name__c != oldPB.Employee_Name__c)
                {        
                  if(mapMgr.get(pb.Employee_Name__c).Manager.Name != null) //CHECK TO SEE IF THE EMPLOYEE HAS A MANAGER
                    {
                      pb.Final_Approver__c = mapMgr.get(pb.Employee_Name__c).Manager.Id;
                    }
                  else
                    {
                      pb.Final_Approver__c = null;
                    }     
                }      
        
            }
      }      

//=====================================================================================================================
    
    public void OnAfterInsert(List<NI_Pager_Bonus__c> newTrigger)
    {
      //CALL THE FINAL APPROVER APEX SHARING METHOD
        Change_FinalApprover_Share(newTrigger);
        
      //CALL THE EMPLOYEE NAME APEX SHARING METHOD  
        Change_EmployeeName_Share(newTrigger);  
    }
    
//===================================================================================================================    
    public void OnAfterUpdate(List<NI_Pager_Bonus__c> newTrigger, Map<Id,NI_Pager_Bonus__c> oldMapTrigger)
    {
        //CREATE  LIST TO HOLD ALL RECORDS WHERE THE NEW FINAL APPROVER DOESN'T MATCH THE OLD FINAL APPROVER
          List<NI_Pager_Bonus__c> lstFinalApproverShare = new List<NI_Pager_Bonus__c>();
          
        //CREATE  LIST TO HOLD ALL RECORDS WHERE THE NEW EMPLOYEE NAME DOESN'T MATCH THE OLD EMPLOYEE NAME
          List<NI_Pager_Bonus__c> lstEmployeeNameShare = new List<NI_Pager_Bonus__c>();  
                     
          for (NI_Pager_Bonus__c pb : newTrigger) 
            {
              NI_Pager_Bonus__c oldPb = oldMapTrigger.get(pb.Id);
                
                if (pb.Final_Approver__c != oldPb.Final_Approver__c)
                  {
                   lstFinalApproverShare.add(pb);
                  }
                  
                if (pb.Employee_Name__c != oldPb.Employee_Name__c)
                  {
                   lstEmployeeNameShare.add(pb);
                  }  
            }      
             
      //CALL THE FINAL APPROVER APEX SHARING METHOD
        if(lstFinalApproverShare.size()>0)
           {  
             Change_FinalApprover_Share(lstFinalApproverShare);
           }  
        
      //CALL THE EMPLOYEE NAME APEX SHARING METHOD
        if(lstEmployeeNameShare.size()>0)
          {  
            Change_EmployeeName_Share(lstEmployeeNameShare);
          }                  
    }  
    

/*================================================================================================
                      APEX SHARING METHODS
==================================================================================================*/

  //EMPLOYEE NAME SHARE
    public void Change_EmployeeName_Share(List<NI_Pager_Bonus__c> newTrigger)
        {          
    
          //LIST OF SHARES THAT NEED TO BE REMOVED
            List<NI_Pager_Bonus__Share> lstSharesToRemove = new List<NI_Pager_Bonus__Share>([
                SELECT id
                FROM NI_Pager_Bonus__Share 
                WHERE ParentId IN : newTrigger 
                AND RowCause = 'Employee__c']); 
            
          // BULK REMOVE SHARE RECORDS
             if(lstSharesToRemove.size() > 0)
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
             List<NI_Pager_Bonus__Share> lstSharesToInsert = new List<NI_Pager_Bonus__Share>();
            
             for (NI_Pager_Bonus__c pb : newTrigger)
                 {
                    if ((pb.Employee_Name__c != pb.OwnerId) && (pb.Employee_Name__c != null))
                      {
                        NI_Pager_Bonus__Share pbShare = new NI_Pager_Bonus__Share();
                        pbShare.ParentId = pb.Id;
                        pbShare.UserOrGroupId = pb.Employee_Name__c;
                        pbShare.AccessLevel = 'Edit';
                        pbShare.RowCause = Schema.NI_Pager_Bonus__Share.RowCause.Employee__c;
                        lstSharesToInsert.add(pbShare);
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
         
//======================================================================================================================
  //FINAL APPROVER SHARE  
    public void Change_FinalApprover_Share(List<NI_Pager_Bonus__c> newTrigger)
    {          

      //LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Pager_Bonus__Share> lstSharesToRemove = new List<NI_Pager_Bonus__Share>([
            SELECT id
            FROM NI_Pager_Bonus__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Final_Approver__c']); 
        
      // BULK REMOVE SHARE RECORDS
         if(lstSharesToRemove.size() > 0)
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
         List<NI_Pager_Bonus__Share> lstSharesToInsert = new List<NI_Pager_Bonus__Share>();
        
         for (NI_Pager_Bonus__c pb : newTrigger)
             {
               if ((pb.Final_Approver__c != pb.OwnerId) && (pb.Final_Approver__c != null))
                  {
                    NI_Pager_Bonus__Share pbShare = new NI_Pager_Bonus__Share();
                    pbShare.ParentId = pb.Id;
                    pbShare.UserOrGroupId = pb.Final_Approver__c;
                    pbShare.AccessLevel = 'Edit';
                    pbShare.RowCause = Schema.NI_Pager_Bonus__Share.RowCause.Final_Approver__c;
                    lstSharesToInsert.add(pbShare);
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
    
    
}