/************************************************************************************************
Name            : NI_RequisitionLineItem_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 06/01/2017 
Last Mod Date   : 06/01/2017 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-018180
Description     : Class that handles all trigger code for the Requisition Line Item Object
                : UPDATED 12/28/2017 PER NICC-025314
*************************************************************************************************/
public class NI_RequisitionLineItem_TriggerHandler 
{
    
    public void OnAfterInsert(List<SCMC__Requisition_Line_Item__c> newTrigger)
    {
        //ORIGINAL CODE COMMENTED PER NICC-025314
        //rollupLineItemTotal(newTrigger, null);
        
        //ADDED 12/28/2017 PER NICC-025314. CALL THE METHOD TO UPDATE THE APPROVER FIELDS ON THE REQUISITION
        updateApprovers(newTrigger);
        
        if (!NI_FUNCTIONS.bypassTriggerCode('SUPPLYREQRENEWAL'))
        {      
            boolean b = isCustomSettingCompliant(newTrigger);
        }
        
    }
    
    public void OnAfterUpdate(List<SCMC__Requisition_Line_Item__c> newTrigger, Map<Id, SCMC__Requisition_Line_Item__c> oldMapTrigger) 
    {
        /* ORIGINAL CODE COMMENTED PER NICC-025314
for (SCMC__Requisition_Line_Item__c rl : newTrigger) 
{
SCMC__Requisition_Line_Item__c oldRl = oldMapTrigger.get(rl.Id);

if (rl.SCMC__Budget__c != oldRl.SCMC__Budget__c)
{
rollupLineItemTotal(newTrigger, oldMapTrigger);
} 
}
*/
        
        //ADDED 12/28/2017 PER NICC-025314. CALL THE METHOD TO UPDATE THE APPROVER FIELDS ON THE REQUISITION
        updateApprovers(newTrigger);
        
        if (!NI_FUNCTIONS.bypassTriggerCode('SUPPLYREQRENEWAL'))
        {      
            boolean b = isCustomSettingCompliant(newTrigger);
        }
        
    }
    
    public void OnAfterDelete(List<SCMC__Requisition_Line_Item__c> newTrigger)
    {
        //ORIGINAL CODE COMMENTED PER NICC-025314
        //rollupLineItemTotal(newTrigger, null);
        
        //ADDED 12/28/2017 PER NICC-025314. CALL THE METHOD TO UPDATE THE APPROVER FIELDS ON THE REQUISITION
        updateApprovers(newTrigger);
        
        if (!NI_FUNCTIONS.bypassTriggerCode('SUPPLYREQRENEWAL'))
        {      
            boolean b = isCustomSettingCompliant(newTrigger);
        }
    }
    
    // =================================================================================================
    //  FUNCTIONS
    // =================================================================================================
    /* ORIGINAL CODE COMMENTED PER NICC-02531.  APPROVER FIELD UPDATES ARE NOW HANDLED BY THE updateApprovers METHOD
public void rollupLineItemTotal(List<SCMC__Requisition_Line_Item__c> newTrigger, Map<Id, SCMC__Requisition_Line_Item__c> oldMapTrigger)
{  

System.debug(' *** ENTERING NI_RequisitionLineItem_TriggerHandler.rollupLineItemTotal()');         

decimal dAmount = 0;
Set<Id> setReqIds = new Set<Id>(); 	
//LIST TO HOLD REQUISITION RECORDS WHERE THE SECOND LEVEL APPROVER NEEDS TO BE ADDED
List<SCMC__Requisition__c> lstReqSecondLevelApproverAdd = new List<SCMC__Requisition__c>();

//LIST TO HOLD REQUISITION RECORDS WHERE THE THIRD LEVEL APPROVER NEEDS TO BE ADDED
List<SCMC__Requisition__c> lstReqThirdLevelApproverAdd = new List<SCMC__Requisition__c>();

//LIST OF ALL REQUISITION LINE ITEMS RELATED TO THE REQUISITION
List<SCMC__Requisition_Line_Item__c> lsAllRequisitionLineItems = new List<SCMC__Requisition_Line_Item__c>();

//LIST TO HOLD REQUISITION RECORDS WHERE THE SECOND LEVEL APPROVER NEEDS TO BE REMOVED
List<SCMC__Requisition__c> lstReqSecondLevelApproverRemove = new List<SCMC__Requisition__c>();

//LIST TO HOLD REQUISITION RECORDS WHERE THE THIRD LEVEL APPROVER NEEDS TO BE REMOVED
List<SCMC__Requisition__c> lstReqThirdLevelApproverRemove = new List<SCMC__Requisition__c>();	

// GET IDS OF RELATED REQUISITIONS
for (SCMC__Requisition_Line_Item__c rl : newTrigger)
{
if (oldMapTrigger != null)  
{
SCMC__Requisition_Line_Item__c oldRLI = oldMapTrigger.get(rl.Id);
if (rl.SCMC__Budget__c != oldRLI.SCMC__Budget__c)
{
setReqIds.Add(rl.SCMC__Requisition__c); 
}
}
else
{
setReqIds.Add(rl.SCMC__Requisition__c); 
}   
} 

if (setReqIds.size() == 0)
{
return;
}

System.debug(' EXECUTING: NI_RequisitionLineItem_TriggerHandler.rollupLineItemTotal()'); 
System.debug(' NI_RequisitionLineItem_TriggerHandler.rollupLineItemTotal.newTrigger.size() = ' + newTrigger.size());  

//GET ALL REQUISITION LINE ITEMS RELATED TO REQUISITIONS OF THE LINE ITEMS THAT HAVE BEEN INSERTED, UPDATED OR DELETED
lsAllRequisitionLineItems = [SELECT Id, SCMC__Requisition__c, SCMC__Budget__c
FROM SCMC__Requisition_Line_Item__c
WHERE SCMC__Requisition__c IN : setReqIds];


for (SCMC__Requisition__c req : [SELECT Id, Name, First_Level_Approver__c,Second_Level_Approver__c, Third_Level_Approver__c, 
First_Level_Approver__r.Purchase_Approval_Authority__c,Second_Level_Approver__r.Purchase_Approval_Authority__c,
Third_Level_Approver__r.Purchase_Approval_Authority__c,
First_Level_Approver__r.ManagerId,
First_Level_Approver__r.Manager.Purchase_Approval_Authority__c,First_Level_Approver__r.Manager.ManagerId
FROM SCMC__Requisition__c WHERE Id IN : setReqIds])
{            

dAmount = 0;

for (SCMC__Requisition_Line_Item__c reqLIs : lsAllRequisitionLineItems)
{                    
if (req.Id == reqLIs.SCMC__Requisition__c) 
{                            
if (reqLIs.SCMC__Budget__c != null)
{
dAmount += (reqLIs.SCMC__Budget__c);
}
}
}

if((dAmount > req.First_Level_Approver__r.Purchase_Approval_Authority__c) && (req.Second_Level_Approver__c == null))
{
lstReqSecondLevelApproverAdd.add(req);  
}

if((dAmount <= req.First_Level_Approver__r.Purchase_Approval_Authority__c) && (req.Second_Level_Approver__c != null))
{
lstReqSecondLevelApproverRemove.add(req);  
}

if((dAmount > req.First_Level_Approver__r.Manager.Purchase_Approval_Authority__c) && (req.Third_Level_Approver__c == null))
{
lstReqThirdLevelApproverAdd.add(req);  
}

if((dAmount <= req.First_Level_Approver__r.Manager.Purchase_Approval_Authority__c) && (req.Third_Level_Approver__c != null))
{
lstReqThirdLevelApproverRemove.add(req);  
}

}


//CALL THE FUNCTION TO ADD THE SECOND LEVEL APPROVER
if(lstReqSecondLevelApproverAdd.size()>0)
{
updateSecondLevelApproverAdd(lstReqSecondLevelApproverAdd);
}

//CALL THE FUNCTION TO REMOVE THE SECOND LEVEL APPROVER
if(lstReqSecondLevelApproverRemove.size()>0)
{
updateSecondLevelApproverRemove(lstReqSecondLevelApproverRemove);
}

//CALL THE FUNCTION TO ADD THE THIRD LEVEL APPROVER
if(lstReqThirdLevelApproverAdd.size()>0)
{
updateThirdLevelApproverAdd(lstReqThirdLevelApproverAdd);
}

//CALL THE FUNCTION TO REMOVE THE THIRD LEVEL APPROVER
if(lstReqThirdLevelApproverRemove.size()>0)
{
updateThirdLevelApproverRemove(lstReqThirdLevelApproverRemove);
}

}
*/
    //===============================================================================================================   
    //ADDED 12/28/2017 PER NICC-02531
    public void updateApprovers(List<SCMC__Requisition_Line_Item__c> newTrigger)
    {
        System.debug(' *** ENTERING NI_RequisitionLineItem_TriggerHandler.updateApprovers()');
        
        //SET TO HOLD THE REQUISITION IDS
        Set<Id> setReqIds = new Set<Id>();
        
        // GET IDS OF RELATED REQUISITIONS
        for (SCMC__Requisition_Line_Item__c rl : newTrigger)
        {
            setReqIds.Add(rl.SCMC__Requisition__c); 
        }
        
        if (setReqIds.size() == 0)
        {
            return;
        }
        
        //LIST OF ALL ALL OF THE REQUISITIONS
        List<SCMC__Requisition__c> lstAllRequisitions = ([SELECT Id, OwnerId FROM SCMC__Requisition__c WHERE Id IN : setReqIds]);
        
        //PASS THE REQUISITIONS TO THE ffaRequisitionHander CLASS TO UPDATE THE APPROVER FIELDS
        ffaRequisitionHandler.setFirstLevelApprover(lstAllRequisitions);
    }
    //=============================================================================================================   
    /* ORIGINAL CODE COMMENTED PER NICC-02531.  APPROVER FIELD UPDATES ARE NOW HANDLED BY THE updateApprovers METHOD

public void updateSecondLevelApproverAdd(List<SCMC__Requisition__c> newTrigger)
{    
System.debug(' *** ENTERING NI_RequisitionLineItem_TriggerHandler.updateSecondLevelApproverAdd()');         

List<SCMC__Requisition__c> lstSecondLevelApproverUpdate = new List<SCMC__Requisition__c>();		

for (SCMC__Requisition__c r : newTrigger)
{
r.Second_Level_Approver__c = r.First_Level_Approver__r.ManagerId;
lstSecondLevelApproverUpdate.Add(r); 
}


if (lstSecondLevelApproverUpdate.size() > 0)
{
database.update(lstSecondLevelApproverUpdate);
} 

}

//=============================================================================================================   
public void updateSecondLevelApproverRemove(List<SCMC__Requisition__c> newTrigger)
{    
System.debug(' *** ENTERING NI_RequisitionLineItem_TriggerHandler.updateSecondLevelApproverRemove()');         

List<SCMC__Requisition__c> lstSecondLevelApproverUpdate = new List<SCMC__Requisition__c>();		

for (SCMC__Requisition__c r : newTrigger)
{
r.Second_Level_Approver__c = null;
lstSecondLevelApproverUpdate.Add(r); 
}

if (lstSecondLevelApproverUpdate.size() > 0)
{
database.update(lstSecondLevelApproverUpdate);
}

//System.debug(' EXECUTING: NI_RequisitionLineItem_TriggerHandler.rollupLineItemTotal()'); 
//System.debug(' NI_RequisitionLineItem_TriggerHandler.rollupLineItemTotal.newTrigger.size() = ' + newTrigger.size());  

}

//=============================================================================================================   
public void updateThirdLevelApproverAdd(List<SCMC__Requisition__c> newTrigger)
{    
System.debug(' *** ENTERING NI_RequisitionLineItem_TriggerHandler.updateThirdLevelApproverAdd()');         

List<SCMC__Requisition__c> lstThirdLevelApproverUpdate = new List<SCMC__Requisition__c>();		

for (SCMC__Requisition__c r : newTrigger)
{
r.Third_Level_Approver__c = r.First_Level_Approver__r.ManagerId;
lstThirdLevelApproverUpdate.Add(r); 
}


if (lstThirdLevelApproverUpdate.size() > 0)
{
database.update(lstThirdLevelApproverUpdate);
} 

}

//=============================================================================================================   
public void updateThirdLevelApproverRemove(List<SCMC__Requisition__c> newTrigger)
{    
System.debug(' *** ENTERING NI_RequisitionLineItem_TriggerHandler.updateThirdLevelApproverRemove()');         

List<SCMC__Requisition__c> lstThirdLevelApproverUpdate = new List<SCMC__Requisition__c>();		

for (SCMC__Requisition__c r : newTrigger)
{
r.Third_Level_Approver__c = null;
lstThirdLevelApproverUpdate.Add(r); 
}


if (lstThirdLevelApproverUpdate.size() > 0)
{
database.update(lstThirdLevelApproverUpdate);
}  

} 

****END OF COMMENTING ORIGINAL CODE PER NICC-02531****
*/  
    
    public static boolean isCustomSettingCompliant(List<SCMC__Requisition_Line_Item__c> newTrigger)
    {
        
        system.debug(' ENTERING NI_RequisitionLineItem_TriggerHandler.isCustomSettingCompliant ');        
        
        Id ReqId = newTrigger[0].SCMC__Requisition__c;
        
        // IF THE RECORD IS LOCKED FOR APPROVAL OR IS A BULK TRIGGER THEN EXIT FUNCTION
        if (Approval.isLocked(ReqId)) // || newTrigger.size() != 1)
        {
            return false;
        }
        
        // READ IN ALL CUSTOM SETTING DIM VALUES CONCATENATED TO GENERATE VALIDATION KEYS 
        Map<string, decimal> mapCSValues = new Map<string, decimal>();        
        for (RequisitionLineItemCloneSettings__c cs : RequisitionLineItemCloneSettings__c.getall().values())
        {
            mapCSValues.put(cs.General_Ledger_Account__c + cs.Line_of_Business__c + cs.Department__c, cs.Percentage_Increase_Threshold__c);
        }
        
        // POST LOOP VARIABLE DECLARATIONS
        boolean bRetVal = true;
        decimal dCurrItemTotal = 0.0;
        Set<String> setDistinctCombos = new Set<String>();
        
        for (SCMC__Requisition_Line_Item__c rli : [SELECT Id, General_Ledger_Account_list__c, Line_of_Business_Dimension_2__c, Department_Dimension_3__c, 
                                                   SCMC__Quantity__c, Unit_Cost__c, SCMC__Budget__c    
                                                   FROM SCMC__Requisition_Line_Item__c 
                                                   WHERE SCMC__Requisition__c =: ReqId])
        {
            // DETECT DISTINCT DIM COMBOS
            setDistinctCombos.add(rli.General_Ledger_Account_list__c + rli.Line_of_Business_Dimension_2__c + rli.Department_Dimension_3__c);
            // TALLY TOTALS    
            dCurrItemTotal += (rli.SCMC__Quantity__c * rli.Unit_Cost__c);
        } 
        
        // IF MORE THAN ONE DIM COMBINATION FOUND IN NEW REQ LINE ITEMS THEN NOT COMPLIANT
        if (setDistinctCombos.size() != 1)
        {
            bRetVal = false;
        }
        
        // WORKAROUND WAY TO GRAB FIRST ELEMENT VALUE IN DISTINCT DIM COMBO SET FOR NEXT BLOCK EVALUATION
        string firstValue = '';
        for (String s : setDistinctCombos)
        {
            firstValue = s;
            break;
        }
        
        // IF DIM COMBINATION NOT FOUND IN CUSTOM SETTING THEN NOT COMPLIANT
        if (!mapCSValues.containsKey(firstValue))
        {
            bRetVal = false;
        }        
        
        // GET CURRENT SCMC__Requisition__c RECORD TO COMPARE VALUES WITH SOURCE (CLONED FROM) RECORD
        SCMC__Requisition__c currRequisition = [SELECT Id, Is_Monthly_Renewal__c, Requisition_Budget__c, Previous_Renewal__c 
                                                FROM SCMC__Requisition__c 
                                                WHERE Id =: ReqId]; 
        
        // RESET FIELDS TARGETED FOR CONDITIONAL UPDATE 
        currRequisition.Is_Monthly_Renewal__c = false;
        //        currRequisition.Percentage_Increase_Agreed__c = 0.0; 
        //        currRequisition.Percentage_Increase_Offered__c = 0.0;    
        
        if (bRetVal)
        {
            
            if (currRequisition.Previous_Renewal__c != null) 
            {
                SCMC__Requisition__c prevRequisition = [SELECT Id, Requisition_Budget__c FROM SCMC__Requisition__c WHERE Id =: currRequisition.Previous_Renewal__c]; 
                
                if ((prevRequisition.Requisition_Budget__c != null) && (prevRequisition.Requisition_Budget__c > 0))
                {
                    
                    Decimal dDiff = (dCurrItemTotal - prevRequisition.Requisition_Budget__c); 
                    Decimal dPerc = ((dDiff / prevRequisition.Requisition_Budget__c) * 100); 
                    
                    currRequisition.Percentage_Increase_Agreed__c = dPerc; 
                    currRequisition.Percentage_Increase_Offered__c = dPerc; 
                    currRequisition.Is_Monthly_Renewal__c = true;
                    
                    // IF OVER % SPECIFIED IN CUSTOM SETTING, CEO HAS TO APPROVE SO UNCHECK BYPASS SWITCH 
                    if (dPerc > mapCSValues.get(firstValue)) 
                    { 
                        currRequisition.Is_Monthly_Renewal__c = false;
                    }
                    
                }
                
            }
            
        }
        
        update currRequisition; 
        
        return bRetVal;
        
    }    
    
}