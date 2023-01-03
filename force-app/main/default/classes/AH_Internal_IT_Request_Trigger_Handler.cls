/*************************************************************************************************
Name            : AH_Internal_IT_Request_Trigger_Handler Class
Author          : Stuart Emery
Created Date    : 02/17/2017
Last Mod Date   : 05/26/2017
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Trigger Handler Class for the Internal_IT_Request__c Object
                : 
*************************************************************************************************/
public class AH_Internal_IT_Request_Trigger_Handler {
    
    public AH_Internal_IT_Request_Trigger_Handler()
    {
        
    }
    
    public void OnBeforeInsert(List<AH_Internal_IT_Request__c> newTrigger)
    {
        System.debug(' *** ENTERING AH_Internal_IT_Request_Trigger_Handler.OnBeforeInsert()');
        
        setRequesterField(newTrigger);
    }
    
    //===================================================================================================================
    public void OnAfterInsert(List<AH_Internal_IT_Request__c> newTrigger)
    {
        System.debug(' *** ENTERING AH_Internal_IT_Request_Trigger_Handler.OnAfterInsert()');
        
        Change_Requester_Share(newTrigger);
        
        //CALL THE FOLLOWRECORD METHOD 
        followRecord(newTrigger, null, 'insert');
    }
    
    //===================================================================================================================    
    public void OnBeforeUpdate(List<AH_Internal_IT_Request__c> newTrigger, Map<Id,AH_Internal_IT_Request__c> oldMapTrigger)
    {  
        System.debug(' *** ENTERING AH_Internal_IT_Request_Trigger_Handler.OnBeforeUpdate()');
        
        //CREATE LIST TO HOLD ALL RECORDS WHERE THE OLD OWNER OF THE RECORD WAS A USER AND THE NEW OWNER IS A QUEUE
        List<AH_Internal_IT_Request__c> lstChangeRequester = new List<AH_Internal_IT_Request__c>(); 
        
        for (AH_Internal_IT_Request__c r : newTrigger) 
        {
            AH_Internal_IT_Request__c oldR = oldMapTrigger.get(r.Id);
            
            System.debug(' *** OLD OWNER:' + oldR.ownerId);
            System.debug(' *** OLD OWNER TYPE:' + oldR.OwnerId.getSObjectType());
            System.debug(' *** NEW OWNER:' + r.ownerId);
            System.debug(' *** NEW OWNER TYPE:' + r.OwnerId.getSObjectType());
              
            if((oldR.OwnerId.getSObjectType() == User.SObjectType) && (r.OwnerId.getSObjectType() == Group.SObjectType)) 
            {
                lstChangeRequester.add(oldR);
            } 
        }      
        
        //CALL THE METHOD TO UPDATE THE REQUESTER FIELD
        if (lstChangeRequester.size() > 0)
        {  
            setRequesterField(lstChangeRequester);
        }
      
    }
    
    //===================================================================================================================    
    public void OnAfterUpdate(List<AH_Internal_IT_Request__c> newTrigger, Map<Id,AH_Internal_IT_Request__c> oldMapTrigger)
    { 
        System.debug(' *** ENTERING AH_Internal_IT_Request_Trigger_Handler.OnAfterUpdate()');
        
        //CALL THE FOLLOWRECORD METHOD 
        followRecord(newTrigger, oldMapTrigger, 'update');
        
        //CREATE LIST TO HOLD ALL RECORDS WHERE THE NEW REQUESTER DOESN'T MATCH THE OLD REQUESTER
        List<AH_Internal_IT_Request__c> lstRequesterShare = new List<AH_Internal_IT_Request__c>(); 
        
        for (AH_Internal_IT_Request__c r : newTrigger) 
        {
            AH_Internal_IT_Request__c oldR = oldMapTrigger.get(r.Id);
            
            if (r.Requester__c != oldR.Requester__c)
            {
                lstRequesterShare.add(r);
            } 
        }      
        
        System.debug(' *** lstRequesterShare.size():' + lstRequesterShare.size());
        
        //CALL THE REQUESTER APEX SHARING METHOD
        if (lstRequesterShare.size() > 0)
        {  
            Change_Requester_Share(lstRequesterShare);
        }         
    }        
    
    //========================================================================    
    private void setRequesterField(List<AH_Internal_IT_Request__c> newTrigger)
    {
        System.debug(' *** ENTERING AH_Internal_IT_Request_Trigger_Handler.setRequesterField()');
        
        for (AH_Internal_IT_Request__c r : newTrigger)
        {
            if((r.Requester__c == null) && (r.OwnerId.getSObjectType() == User.SObjectType))
            {
                r.Requester__c = r.OwnerId;
                System.debug('SETTING REQUESTER TO: ' + UserInfo.getName());    
            }
        }     
    }
    
    // ================================================================================================
    //  APEX SHARING METHODS
    // ================================================================================================
    
    //REQUESTER SHARE
    public void Change_Requester_Share(List<AH_Internal_IT_Request__c> newTrigger)
    {          
        System.debug(' *** ENTERING AH_Internal_IT_Request_Trigger_Handler.Change_Requester_Share');
            
        //LIST OF SHARES THAT NEED TO BE REMOVED
        List<AH_Internal_IT_Request__Share> lstSharesToRemove = new List<AH_Internal_IT_Request__Share>([
            SELECT id 
            FROM AH_Internal_IT_Request__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Requester_Share__c']); 
        
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
        List<AH_Internal_IT_Request__Share> lstSharesToInsert = new List<AH_Internal_IT_Request__Share>();
        
        for (AH_Internal_IT_Request__c r : newTrigger)
        {
            //if ((r.Requester__c != r.OwnerId) && (r.Requester__c != null))
            if (r.Requester__c != null)                
            {
                AH_Internal_IT_Request__Share rShare = new AH_Internal_IT_Request__Share();
                rShare.ParentId = r.Id;
                rShare.UserOrGroupId = r.Requester__c;
                rShare.AccessLevel = 'Read';
                rShare.RowCause = Schema.AH_Internal_IT_Request__Share.RowCause.Requester_Share__c;
                lstSharesToInsert.add(rShare);
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
//=================================================================================================================    
  //FOLLOW AND UNFOLLOW IT REQUEST RECORD METHOD  
    public static void followRecord(List<AH_Internal_IT_Request__c> newTrigger, Map<Id, AH_Internal_IT_Request__c> oldReqMap, String operation)
    {
        System.debug(' *** ENTERING AH_Internal_IT_Request_Trigger_Handler.followRecord()');
        
        List<EntitySubscription> entitySubToBeInsert = new List<EntitySubscription>();
        List<Id> entitySubIdsToBeDelete = new List<Id>();
       
        if(operation.equalsIgnoreCase('insert'))
        {
            for(AH_Internal_IT_Request__c currReq : newTrigger)
            {
                if(currReq.OwnerId.getSObjectType() == User.SObjectType)
                {
                    EntitySubscription follow = new EntitySubscription(parentId = currReq.id, subscriberid =currReq.ownerid);
                entitySubToBeInsert.add(follow);
                }    
            } 
        }
        else if(operation.equalsIgnoreCase('update'))
        {
            for(AH_Internal_IT_Request__c currReq : newTrigger)
            {
                //IF THE CURRENT OWNER IS A USER (NOT A QUEUE) AND DOES NOT EQUAL THE PREVIOUS OWNER, FOLLOW THE RECORD IN CHATTER
                if((oldReqMap.get(currReq.Id).OwnerId != currReq.OwnerId) && (currReq.OwnerId.getSObjectType() == User.SObjectType))
                {
                    EntitySubscription follow = new EntitySubscription(parentId = currReq.id, subscriberid =currReq.ownerid);
                    entitySubToBeInsert.add(follow);
                   
                    //entitySubIdsToBeDelete.add(oldReqMap.get(currReq.Id).OwnerId);
                }
                
                //IF THE PREVIOUS OWNER IS A USER (NOT A QUEUE) AND DOES NOT EQUAL THE CURRENT OWNER, UNFOLLOW THE RECORD IN CHATTER
                if((oldReqMap.get(currReq.Id).OwnerId != currReq.OwnerId) && (oldReqMap.get(currReq.Id).OwnerId.getSObjectType() == User.SObjectType))
                {  
                  entitySubIdsToBeDelete.add(oldReqMap.get(currReq.Id).OwnerId);
                }
                
                //if((oldReqMap.get(currReq.Id).Status__c != currReq.Status__c && currReq.Status__c != 'Closed') && (currReq.OwnerId.getSObjectType() == User.SObjectType))
                //{
                //  EntitySubscription follow = new EntitySubscription(parentId = currReq.id, subscriberid =currReq.ownerid);
                //  entitySubToBeInsert.add(follow);  
               // }
                
                //ONCE THE STATUS HAS BEEN SET TO "CLOSED" UNFOLLOW THE RECORD  
                if((oldReqMap.get(currReq.Id).Status__c != currReq.Status__c && currReq.Status__c == 'Closed') && (currReq.OwnerId.getSObjectType() == User.SObjectType))
                {
                    entitySubIdsToBeDelete.add(currReq.OwnerId);
                }
            }
        }
       
        if(!entitySubToBeInsert.isEmpty())
        {
            insert entitySubToBeInsert;
        }
       
        if(!entitySubIdsToBeDelete.isEmpty())
        {
            List<EntitySubscription> entitySubDelete = new List<EntitySubscription>();
            for(EntitySubscription currEntity : [select id from EntitySubscription where subscriberid =:entitySubIdsToBeDelete])
            {
                EntitySubscription ent = new EntitySubscription();
                ent.ID = currEntity.Id;
                entitySubDelete.add(ent);
            }
            Delete entitySubDelete;
        }
    }
 
}