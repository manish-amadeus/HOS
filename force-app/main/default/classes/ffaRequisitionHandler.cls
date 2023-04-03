/*******************************************************************************************
Name              : ffaRequisitionHandler
Author            : CLD Partners
Created Date      : Mar 3, 2016
Last Modified By  : Stuart Emery
Last Modified Date: 5/18/2017
Description       : Contains methods to handle operations on the SCM Requisition
Last Updated:     : Updated 02/4/2019 per NICC-032619
                  : 5/13/2016 By Stuart Emery.  Adding Logic to Populate the Requisition
                  : field on the SCMC__Purchase_Order__c Object Per NICC-017893
              
                  Updated By Stuart Emery on 5/18/2017 per NICC-022386
                  Updated 12/27/2017 per NICC-025314
*******************************************************************************************/
public class ffaRequisitionHandler {
    
    public static void setFirstLevelApprover(List<SCMC__Requisition__c> reqList)
    {
        Set<Id> userIdSet = new Set<Id>();
        for(SCMC__Requisition__c req : reqList)
        {
            userIdSet.add(req.OwnerId);
        }
        //Map<Id, User> userMap = new Map<Id,User>([SELECT Id, ManagerId FROM User WHERE Id in :userIdSet]);
        
        //UPDATED PER NICC-025314 TO INCLUDE SUPPLY REQ MANAGER APPROVAL OVERRIDE FIELD
        Map<Id, User> userMap = new Map<Id,User>([SELECT Id, ManagerId, Manager.ManagerId,Manager.Purchase_Approval_Authority__c,
                                                  Manager.Manager.Purchase_Approval_Authority__c,Manager.Manager.ManagerId,Supply_Req_Manager_Approval_Override__c,
                                                  Supply_Req_Manager_Approval_Override__r.Purchase_Approval_Authority__c,
                                                  Supply_Req_Manager_Approval_Override__r.Supply_Req_Manager_Approval_Override__r.Purchase_Approval_Authority__c   
                                                  FROM User WHERE Id in :userIdSet]);
        
        
        //ADDED PER NICC-025314
        Map<Id, User> mapAllStandardUsers = new Map<Id,User>([SELECT Id, ManagerId, Name, Purchase_Approval_Authority__c, Supply_Req_Manager_Approval_Override__c  
                                                              FROM User WHERE UserType = 'Standard']);
        
        system.debug('Number of Users: ' + mapAllStandardUsers.size());
        
        for(SCMC__Requisition__c req : reqList)
        {
            System.Debug('************ ffaRequisitionHandler - setFirstLevelApprover - userMap'+ userMap);
            
            //INITIALLY SET APPROVER LEVEL FIELDS TO NULL
            req.First_Level_Approver__c = null;
            req.Second_Level_Approver__c = null;
            req.Third_Level_Approver__c = null;
            
            if(userMap.containsKey(req.OwnerId))
            {
                //SEE IF THE RECORD OWNER HAS THE SUPPLY REQ MANAGER FIELD POPULATED ON HIS/HER USER RECORD.  IF SO, SET THIS USER AS THE FIRST LEVEL APPROVER
                if(userMap.get(req.OwnerId).Supply_Req_Manager_Approval_Override__c != null)
                {
                    req.First_Level_Approver__c = userMap.get(req.OwnerId).Supply_Req_Manager_Approval_Override__c;
                    System.Debug('************ ffaRequisitionHandler - req.First_Level_Approver__c = userMap.get(req.OwnerId).Supply_Req_Manager_Approval_Override__c: '+ userMap.get(req.OwnerId).Supply_Req_Manager_Approval_Override__c);  
                    System.Debug('************ ffaRequisitionHandler - req.First_Level_Approver__c: '+ req.First_Level_Approver__c);  
                }
                //req.First_Level_Approver__c = userMap.get(req.OwnerId).Supply_Req_Manager_Approval_Override__c != null ? userMap.get(req.OwnerId).Supply_Req_Manager_Approval_Override__c : null;
                
                //IF THE FIRST LEVEL APPROVER WAS NOT SET IN THE STEP ABOVE, SET THE FIRST LEVEL APPROVER AS THE MANAGER OF THE RECORD OWNER
                if(req.First_Level_Approver__c == null)
                {
                    if(userMap.get(req.OwnerId).ManagerId != null)
                    {
                        req.First_Level_Approver__c = userMap.get(req.OwnerId).ManagerId;
                        System.Debug('************ ffaRequisitionHandler - req.First_Level_Approver__c = userMap.get(req.OwnerId).ManagerId: '+ userMap.get(req.OwnerId).ManagerId);
                        System.Debug('************ ffaRequisitionHandler - req.First_Level_Approver__c: '+ req.First_Level_Approver__c);
                        System.Debug('************ ffaRequisitionHandler - req.Requisition_Budget__c: '+ req.Requisition_Budget__c);
                    }
                }
                
                
                //IF THE FIRST LEVEL APPROVER'S PURCHASE APPROVAL AUTHORITY IS LESS THAN THE AMOUNT OF THE REQUISITION, 
                //SET THE SECOND LEVEL APPROVER
                System.Debug('************ ffaRequisitionHandler - mapAllStandardUsers.get(req.First_Level_Approver__c).Purchase_Approval_Authority__c: '+ mapAllStandardUsers.get(req.First_Level_Approver__c).Purchase_Approval_Authority__c);
                System.Debug('************ ffaRequisitionHandler - mapAllStandardUsers.get(req.First_Level_Approver__c).ManagerId: '+ mapAllStandardUsers.get(req.First_Level_Approver__c).ManagerId); 
                 
                //ORIGINAL CODE TO CHECK FOR REQUISITION BUDGET FIELD
                //if((mapAllStandardUsers.get(req.First_Level_Approver__c).Purchase_Approval_Authority__c < req.Requisition_Budget__c)
                //UPDATED PER NICC-032619 TO LOOK AT USD REQUISITION BUDGET
                if((mapAllStandardUsers.get(req.First_Level_Approver__c).Purchase_Approval_Authority__c < req.USD_Requisition_Budget__c)   
                   ||
                   (mapAllStandardUsers.get(req.First_Level_Approver__c).Purchase_Approval_Authority__c == null))
                {   
                    
                    System.Debug('************ ffaRequisitionHandler - mapAllStandardUsers.get(req.First_Level_Approver__c).Supply_Req_Manager_Approval_Override__c: '+ mapAllStandardUsers.get(req.First_Level_Approver__c).Supply_Req_Manager_Approval_Override__c); 
                    if(mapAllStandardUsers.get(req.First_Level_Approver__c).Supply_Req_Manager_Approval_Override__c != null)
                    {
                        req.Second_Level_Approver__c = mapAllStandardUsers.get(req.First_Level_Approver__c).Supply_Req_Manager_Approval_Override__c;
                        System.Debug('************ ffaRequisitionHandler - req.Second_Level_Approver__c: '+ req.Second_Level_Approver__c);  
                    }
                    //SEE IF THE FIRST LEVEL APPROVER HAS THE SUPPLY REQ MANAGER FIELD POPULATED ON HIS/HER USER RECORD.  IF SO, SET THIS USER AS THE SECOND LEVEL APPROVER
                    // req.Second_Level_Approver__c = mapAllStandardUsers.get(req.First_Level_Approver__c).Supply_Req_Manager_Approval_Override__c != null ? mapAllStandardUsers.get(req.First_Level_Approver__c).Supply_Req_Manager_Approval_Override__c : null;
                    
                    //IF THE SECOND LEVEL APPROVER WAS NOT SET IN THE STEP ABOVE, SET THE SECOND LEVEL APPROVER AS THE MANAGER OF THE FIRST LEVEL APPROVER
                    System.Debug('************ ffaRequisitionHandler - req.Second_Level_Approver__c: '+ req.Second_Level_Approver__c);
                    if(req.Second_Level_Approver__c == null)
                    {
                        if(mapAllStandardUsers.get(req.First_Level_Approver__c).ManagerId != null)
                        {
                            req.Second_Level_Approver__c = mapAllStandardUsers.get(req.First_Level_Approver__c).ManagerId;
                            System.Debug('************ ffaRequisitionHandler - req.Second_Level_Approver__c: '+ req.Second_Level_Approver__c);  
                        }
                        //req.Second_Level_Approver__c = mapAllStandardUsers.get(req.First_Level_Approver__c).ManagerId != null ? mapAllStandardUsers.get(req.First_Level_Approver__c).ManagerId : null;
                    }
                }
                
                
                //IF THE SECOND LEVEL APPROVER'S PURCHASE APPROVAL AUTHORITY IS LESS THAN THE AMOUNT OF THE REQUISITION, 
                //SET THE THIRD LEVEL APPROVER
                //ORIGINAL CODE
                //if((req.Second_Level_Approver__c != null) && ((mapAllStandardUsers.get(req.Second_Level_Approver__c).Purchase_Approval_Authority__c < req.Requisition_Budget__c)
                //UPDATED PER NICC-032619 TO LOOK AT USD REQUISITION BUDGET
                if((req.Second_Level_Approver__c != null) && ((mapAllStandardUsers.get(req.Second_Level_Approver__c).Purchase_Approval_Authority__c < req.USD_Requisition_Budget__c)                                              
                   ||
                   (mapAllStandardUsers.get(req.Second_Level_Approver__c).Purchase_Approval_Authority__c == null)))
                {   
                    //SEE IF THE SECOND LEVEL APPROVER HAS THE SUPPLY REQ MANAGER FIELD POPULATED ON HIS/HER USER RECORD.  IF SO, SET THIS USER AS THE THIRD LEVEL APPROVER
                    req.Third_Level_Approver__c = mapAllStandardUsers.get(req.Second_Level_Approver__c).Supply_Req_Manager_Approval_Override__c != null ? mapAllStandardUsers.get(req.Second_Level_Approver__c).Supply_Req_Manager_Approval_Override__c : null;
                    
                    //IF THE THIRD LEVEL APPROVER WAS NOT SET IN THE STEP ABOVE, SET THE SECOND LEVEL APPROVER AS THE MANAGER OF THE FIRST LEVEL APPROVER
                    if(req.Third_Level_Approver__c == null)
                    {
                        req.Third_Level_Approver__c = mapAllStandardUsers.get(req.Second_Level_Approver__c).ManagerId != null ? mapAllStandardUsers.get(req.Second_Level_Approver__c).ManagerId : null;
                    }
                }
                
                System.Debug('************ ffaRequisitionHandler - setThirdLevelApprover - req.Third_Level_Approver__c: '+ req.Third_Level_Approver__c);
                
                
                //if((userMap.get(req.OwnerId).Manager.Purchase_Approval_Authority__c < req.Requisition_Budget__c) && (userMap.get(req.OwnerId).Manager.ManagerId != null))
                // {  
                //     req.Second_Level_Approver__c = userMap.get(req.OwnerId).Manager.ManagerId != null ? userMap.get(req.OwnerId).Manager.ManagerId : null;
                //     System.Debug('************ ffaRequisitionHandler - setSecondLevelApprover - req.Second_Level_Approver__c'+ req.Second_Level_Approver__c);
                // }
                
                //IF THE SECOND LEVEL APPROVER'S PURCHASE APPROVAL AUTHORITY IS LESS THAN THE AMOUNT OF THE REQUISITION, 
                //SET THE SECOND THIRD LEVEL APPROVER TO THE MANAGER OF THE SECOND LEVEL APPROVER
                //if((userMap.get(req.OwnerId).Manager.Manager.Purchase_Approval_Authority__c < req.Requisition_Budget__c) && (userMap.get(req.OwnerId).Manager.Manager.ManagerId != null))
                //{  
                //    req.Third_Level_Approver__c = userMap.get(req.OwnerId).Manager.Manager.ManagerId != null ? userMap.get(req.OwnerId).Manager.Manager.ManagerId : null;
                //    System.Debug('************ ffaRequisitionHandler - setThirdLevelApprover - req.Third_Level_Approver__c'+ req.Third_Level_Approver__c);
                //}
            }
        }
    }      
    
    public static void setPODefaultValues(List<SCMC__Purchase_Order_Line_Item__c> poLineList)
    {
        Set<Id> reqLineIdSet = new Set<Id>();
        //Step 1 : Grab all of the default values we will need to populate:
        Map<String, c2g__codaDimension2__c> dim2Map = new Map<String, c2g__codaDimension2__c>();
        for(c2g__codaDimension2__c dim2 : [SELECT Id, Name FROM c2g__codaDimension2__c])
        {
            dim2Map.put(dim2.Name, dim2);
        }
        Map<String, c2g__codaDimension3__c> dim3Map = new Map<String, c2g__codaDimension3__c>();
        for(c2g__codaDimension3__c dim3 : [SELECT Id, Name FROM c2g__codaDimension3__c])
        {
            dim3Map.put(dim3.Name, dim3);
        }
        Map<String, c2g__codaGeneralLedgerAccount__c> glaMap = new Map<String, c2g__codaGeneralLedgerAccount__c>();
        for(c2g__codaGeneralLedgerAccount__c gla : [SELECT Id, Name FROM c2g__codaGeneralLedgerAccount__c])
        {
            glaMap.put(gla.Name, gla);
        }
        for(SCMC__Purchase_Order_Line_Item__c poLine : poLineList)
        {
            reqLineIdSet.add(poLine.SCMC__Requisition_Line_Item__c);
        }
        Map<Id, SCMC__Requisition_Line_Item__c> reqLineMap = new Map<Id, SCMC__Requisition_Line_Item__c>(
            [SELECT Id, 
             Department_Dimension_3__c, 
             General_Ledger_Account_list__c,
             Line_of_Business_Dimension_2__c,
             SCMC__Purchase_Order_Award__c,
             SCMC__Requisition__r.Line_of_Business_Dimension_2__c,
             SCMC__Purchase_Order_Award__r.SCMC__Purchase_Order__c
             FROM SCMC__Requisition_Line_Item__c
             WHERE id in :reqLineIdSet]);
        
        //step 2: Loop back through the po lines and populate these fields.
        for(SCMC__Purchase_Order_Line_Item__c poLine : poLineList)
        {
            if(reqLineMap.containsKey(poLine.SCMC__Requisition_Line_Item__c))
            {
                SCMC__Requisition_Line_Item__c tmpReq = reqLineMap.get(poLine.SCMC__Requisition_Line_Item__c);
                if(dim2Map.containsKey(tmpReq.Line_of_Business_Dimension_2__c)){
                    poLine.Dimension_2__c = dim2Map.get(tmpReq.Line_of_Business_Dimension_2__c).id;
                }
                if(dim3Map.containsKey(tmpReq.Department_Dimension_3__c)){
                    poLine.Dimension_3__c = dim3Map.get(tmpReq.Department_Dimension_3__c).Id;
                }
                if(glaMap.containsKey(tmpReq.General_Ledger_Account_list__c)){
                    poLine.SCMFFA__General_Ledger_Account__c = glaMap.get(tmpReq.General_Ledger_Account_list__c).Id;
                }
            }
        }
    }
    
    public static void setPOHeaderDefaultValues(List<SCMC__Purchase_Order_Line_Item__c> poLineList)
    {
        String DEFAULT_BS_DIM3 = '000 - BALANCE SHEET';
        Set<Id> reqLineIdSet = new Set<Id>();
        List<SCMC__Purchase_Order__c> poUpdateList = new List<SCMC__Purchase_Order__c>();
        Map<Id, Id> poDimension2Map = new Map<Id, Id>();
        Map<Id, Id> poCompanyMap = new Map<Id, Id>();
        Map<String, Id> acctCurrencyMap = new Map<String, Id>();
        
        //Step 1 : Grab all of the default values we will need to populate:
        Map<String, c2g__codaDimension2__c> dim2Map = new Map<String, c2g__codaDimension2__c>();
        for(c2g__codaDimension2__c dim2 : [SELECT Id, Name FROM c2g__codaDimension2__c])
        {
            dim2Map.put(dim2.Name, dim2);
        }
        Map<String, c2g__codaDimension3__c> dim3Map = new Map<String, c2g__codaDimension3__c>();
        for(c2g__codaDimension3__c dim3 : [SELECT Id, Name FROM c2g__codaDimension3__c])
        {
            dim3Map.put(dim3.Name, dim3);
        }
        Map<String, c2g__codaCompany__c> companyMap = new Map<String, c2g__codaCompany__c>();
        for(c2g__codaCompany__c company : [SELECT Id, Name FROM c2g__codaCompany__c])
        {
            companyMap.put(company.Name, company);
        }
        for(c2g__codaAccountingCurrency__c acctCurr : [SELECT Id, Name, c2g__ownerCompany__c FROM c2g__codaAccountingCurrency__c])
        {
            acctCurrencyMap.put(acctCurr.c2g__ownerCompany__c + '|' + acctCurr.Name, acctCurr.id);
        }
        
        
        for(SCMC__Purchase_Order_Line_Item__c poLine : poLineList)
        {
            System.Debug('************ ffaRequisitionHandler - setPOHeaderDefaultValues - poline.SCMC__Requisition_Line_Item__c = '+ poline.SCMC__Requisition_Line_Item__c);
            reqLineIdSet.add(poLine.SCMC__Requisition_Line_Item__c);
        }
        
        //REQUISITION - ADDED BY STUART EMERY ON 5/13/2016 PER NICC-017893
        SCMC__Requisition_Line_Item__c req = [SELECT Id, SCMC__Requisition__c, SCMC__Requisition__r.SCMC__Requisition_Name__c 
                                              FROM SCMC__Requisition_Line_Item__c WHERE Id IN: reqLineIdSet LIMIT 1];
        
        Map<Id, SCMC__Requisition_Line_Item__c> reqLineMap = new Map<Id, SCMC__Requisition_Line_Item__c>(
            [SELECT Id, 
             Department_Dimension_3__c, 
             Line_of_Business_Dimension_2__c,
             SCMC__Purchase_Order_Award__c,
             SCMC__Requisition__r.Line_of_Business_Dimension_2__c,
             SCMC__Requisition__r.Company__c,
             SCMC__Purchase_Order_Award__r.SCMC__Purchase_Order__c
             FROM SCMC__Requisition_Line_Item__c
             WHERE id in :reqLineIdSet]);
        System.Debug('************ ffaRequisitionHandler - setPOHeaderDefaultValues - reqLineMap'+ reqLineMap);
        //step 2: Loop back through the po lines and populate these fields.
        for(SCMC__Purchase_Order_Line_Item__c poLine : poLineList)
        {
            SCMC__Requisition_Line_Item__c tmpReq = reqLineMap.get(poLine.SCMC__Requisition_Line_Item__c);
            if(dim2Map.containsKey(tmpReq.SCMC__Requisition__r.Line_of_Business_Dimension_2__c) && tmpReq.SCMC__Purchase_Order_Award__r.SCMC__Purchase_Order__c != null){
                poDimension2Map.put(tmpReq.SCMC__Purchase_Order_Award__r.SCMC__Purchase_Order__c, dim2Map.get(tmpReq.SCMC__Requisition__r.Line_of_Business_Dimension_2__c).id);
            }
            if(companyMap.containsKey(tmpReq.SCMC__Requisition__r.Company__c) && tmpReq.SCMC__Purchase_Order_Award__r.SCMC__Purchase_Order__c != null){
                poCompanyMap.put(tmpReq.SCMC__Purchase_Order_Award__r.SCMC__Purchase_Order__c, companyMap.get(tmpReq.SCMC__Requisition__r.Company__c).id);
            }
        }
        //Step 3: Populate the PO Header with the appropriate default information
        for(SCMC__Purchase_Order__c po : [SELECT Id, SCMC__Currency_Master__r.Name , Accounting_Currency__c, Dimension_2__c, Dimension_3__c, SCMFFA__Company__c, Requisition__c FROM SCMC__Purchase_Order__c WHERE Id in: poDimension2Map.keyset()])
        {
            if(poDimension2Map.containsKey(po.id)){
                po.Dimension_2__c = poDimension2Map.get(po.id);
            }
            //default the 000 balance sheet dimension 3 value.
            if(dim3Map.containsKey(DEFAULT_BS_DIM3)){
                po.Dimension_3__c = dim3Map.get(DEFAULT_BS_DIM3).id;
            }
            if(poCompanyMap.containsKey(po.id)){
                po.SCMFFA__Company__c = poCompanyMap.get(po.id);
            }
            if(acctCurrencyMap.containsKey(po.SCMFFA__Company__c + '|' + po.SCMC__Currency_Master__r.Name)){
                po.Accounting_Currency__c = acctCurrencyMap.get(po.SCMFFA__Company__c + '|' + po.SCMC__Currency_Master__r.Name);
            }
            po.Requisition__c = req.SCMC__Requisition__c; //ADDED BY STUART EMERY ON 5/13/2016 PER NICC-017893
            po.SCMC__Purchase_Order_Name__c = req.SCMC__Requisition__r.SCMC__Requisition_Name__c; //ADDED BY STUART EMERY ON 5/12/2017 PER NICC-022386
            
            poUpdateList.add(po);
        }
        update poUpdateList;
    }
    
}