/****************************************************************************************
Name            : AH_UpdateBacklogMilestones_Ctlr
Author          : Sean Harris
Created Date    : 04/25/2020
Last Mod Date   : 06/25/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller class for AH_UpdateBacklogMilestones Page
                :            
******************************************************************************************/
public class AH_UpdateBacklogMilestones_Ctlr 
{

    // RECORD VARIABLES
    public pse__Proj__c p;   
    
    // COLLECTION VARIABLES
    public List<SelectOption> lstChangeReasons {get; set;}
    public List<displayGridRow> lstMilestones {get; set;}
    public List<displayGridRow> lstSelMilestones {get; set;}
    
    // BOOLEAN VARIABLES
    public boolean bOp1 {get; set;}
    public boolean bOp2 {get; set;}
    public boolean bOp3 {get; set;}
    public boolean bOp4 {get; set;}
    public boolean bIsConsolidated {get; set;}
    public boolean bIsLocked {get; set;}
    public boolean bSubmitted4Approval {get; set;}
    
    // STRING VARIABLES
	public String selMasterReason {get; set;}
	public String strMilestoneChangeNote {get; set;}
    public String strErrorMsg {get; set;} 
    public String strMSID {get; set;} 
    public String strALIID {get; set;} 
    public String strOLIID {get; set;} 
    public String strApprover {get; set;} 
    
    // NUMERIC VARIABLES
    public Integer iCount {get; set;} 
    public Integer iSelIndex {get; set;} 
    public Integer iSelSize {get; set;} 
    public Decimal dTotalAmount {get; set;} 
    
    public AH_UpdateBacklogMilestones_Ctlr(ApexPages.StandardController stndCtlr)
    {        
        p = [SELECT Id, Name, Milestone_Change_Note__c, pse__Opportunity__c FROM pse__Proj__c WHERE Id =: stndCtlr.getRecord().Id];
        
        initPage();            
    }
    
    private void initPage()
    {
        // INITIALIZE VARIABLES
        bOp1 = true;
        bOp2 = false;
        bOp3 = false;
        bOp4 = false;
        strErrorMsg = '';
		bIsConsolidated = false;
		iSelIndex = 0;
        selMasterReason = 'CHOOSE ONE'; 
        strMilestoneChangeNote = ''; 
        bIsLocked = Approval.isLocked(p.Id); 
        
        if (p.Milestone_Change_Note__c != null)
        {
            strMilestoneChangeNote = p.Milestone_Change_Note__c;
        }             
        
        // FILL REASON FOR MILESTONE CHANGE PICKLIST
        lstChangeReasons = new List<SelectOption>();
        Schema.DescribeFieldResult dfr = pse__Milestone__c.Reason_for_Milestone_Change__c.getDescribe();
        lstChangeReasons.add(new SelectOption('CHOOSE ONE', 'CHOOSE ONE'));
        for (Schema.PicklistEntry plv : dfr.getPicklistValues())
        {
            lstChangeReasons.add(new SelectOption(plv.getValue(), plv.getLabel()));
        }       

        if (bIsLocked)
        {
            strErrorMsg = 'The related Project is locked in an existing approval process and therefore this utility cannot be used.';
        }
        
    }
    
    public void loadMilestones()
    {
        
        lstMilestones = new List<displayGridRow>();
        Map<String, String> mapPackageTracker = new Map<String, String>();
        Map<String, String> mapPropertyTracker = new Map<String, String>();
        Set<Id> setOLIIds = new Set<Id>();
        Integer iIndex = 0;
        String strKeyTmp = '';
        iCount = 0;
        
        for (pse__Milestone__c ms : [SELECT Id, 
                                     Activity_Line_Item__r.Product_Package__c, Activity_Line_Item__r.Product_Package__r.Name, 
                                     Managed_Property__c, Managed_Property__r.Name, 
                                     Activity_Line_Item__c, Activity_Line_Item__r.Name, 
                                     Name, Reason_for_Milestone_Change__c, Milestone_Type__c, Opportunity__c, Target_Period__c, pse__Project__c, 
                                     IsActive__c, Contracted_Milestone__c, pse__Status__c, pse__Milestone_Amount__c, 
                                     Activity_Line_Item__r.Opp_Product_ID__c, 
                                     Activity_Line_Item__r.Product__r.Name, 
                                     Activity_Line_Item__r.Product__r.Unit__c, 
                                     Activity_Line_Item__r.Units__c 
                                     FROM pse__Milestone__c
                                     WHERE pse__Project__c =: p.Id
                                     //AND IsActive__c = 1 
                                     //AND Contracted_Milestone__c = 1
                                     AND Milestone_Type__c IN ('Billable Milestone', 'Complimentary')
                                     ORDER BY Activity_Line_Item__r.Product_Package__r.Name, Activity_Line_Item__r.Opp_Product_ID__c, Managed_Property__r.Name, Name])       
        {

            // ADD OLI IDS TO A SET
            if (ms.Activity_Line_Item__r.Opp_Product_ID__c != null)
            {
                setOLIIds.add(ms.Activity_Line_Item__r.Opp_Product_ID__c);
            }

            
            // RESET KEY TEMP
            strKeyTmp = 'NOT_SPECIFIED';
            
            if (ms.Activity_Line_Item__r.Product_Package__c != null)
            {
                strKeyTmp = ms.Activity_Line_Item__r.Product_Package__c;
            }

            if (ms.Activity_Line_Item__r.Opp_Product_ID__c != null)
            {
                strKeyTmp += '-' + ms.Activity_Line_Item__r.Opp_Product_ID__c;
            }
               
            
			if (!mapPackageTracker.containsKey(strKeyTmp))
			{
                // CREATE PRODUCT PACKAGE GROUP HEADER
                mapPackageTracker.put(strKeyTmp, ms.Activity_Line_Item__r.Product_Package__r.Name);
                displayGridRow grPackage = new displayGridRow (
                	'Package',
                    false,
                    false,
                    false,
                    null,
                    ms.Activity_Line_Item__r.Product_Package__r.Name,
                    null, 
                    null, 
                    null, 
                    null, 
                    null,
                    strKeyTmp, 
                    iIndex,
                    ms.Activity_Line_Item__r.Product_Package__r.Name, 
                    ms.Managed_Property__r.Name,
                    false
                );
                lstMilestones.add(grPackage);
                iIndex++;

                // RESET KEY TEMP
                strKeyTmp = 'NOT_SPECIFIED'; 
                
                if (ms.Activity_Line_Item__r.Product_Package__c != null)
                {
                    strKeyTmp = ms.Activity_Line_Item__r.Product_Package__c;
                }
                
                if (ms.Managed_Property__c != null)
                {
                    strKeyTmp += '-' + ms.Managed_Property__c;
                }    
                else
                {
                    strKeyTmp += '-NOT_SPECIFIED';
                }
                
                if (ms.Activity_Line_Item__r.Opp_Product_ID__c != null)
                {
                    strKeyTmp += '-' + ms.Activity_Line_Item__r.Opp_Product_ID__c;
                }     
                
                if (!mapPropertyTracker.containsKey(strKeyTmp))
                {                
                    // CREATE MANAGED PROPERTY HEADER
                    mapPropertyTracker.put(strKeyTmp, ms.Managed_Property__r.Name);
                    displayGridRow grProperty = new displayGridRow (
                        'Property',
                        false,
                        false,
                        false,
                        null,
                        ms.Managed_Property__r.Name,
                        null, 
                        null, 
                        null, 
                        null, 
                        null,
                        strKeyTmp, 
                        iIndex,
                        ms.Activity_Line_Item__r.Product_Package__r.Name, 
                        ms.Managed_Property__r.Name,
                        false
                    );
                    
                    if (ms.Managed_Property__r.Name != null && bIsConsolidated)
                    {
                        lstMilestones.add(grProperty);
                        iIndex++;
                    }                
                    
                }

                // CREATE MILESTONE ROW
                displayGridRow grMS1 = new displayGridRow (
                    'Milestone',
                    false,
                    false,
                    false,
                    ms,
                    null, 
                    ms.Activity_Line_Item__r.Opp_Product_ID__c, 
                    ms.Activity_Line_Item__r.Name, 
                    ms.Activity_Line_Item__r.Product__r.Name, 
                    ms.Activity_Line_Item__r.Product__r.Unit__c, 
                    ms.Activity_Line_Item__r.Units__c, 
                    strKeyTmp, 
                    iIndex,
                    ms.Activity_Line_Item__r.Product_Package__r.Name, 
                    ms.Managed_Property__r.Name,
                    false 
                );
                lstMilestones.add(grMS1);  
                iCount++;
                iIndex++;
            }
            else
            {
                
                // RESET KEY TEMP
                strKeyTmp = 'NOT_SPECIFIED'; 
                
                if (ms.Activity_Line_Item__r.Product_Package__c != null)
                {
                    strKeyTmp = ms.Activity_Line_Item__r.Product_Package__c;
                }
                
                if (ms.Managed_Property__c != null)
                {
                    strKeyTmp += '-' + ms.Managed_Property__c;
                }    
                else
                {
                    strKeyTmp += '-NOT_SPECIFIED';
                }
                
                if (ms.Activity_Line_Item__r.Opp_Product_ID__c != null)
                {
                    strKeyTmp += '-' + ms.Activity_Line_Item__r.Opp_Product_ID__c;
                }            
            
                if (!mapPropertyTracker.containsKey(strKeyTmp))
                {
                    // CREATE MANAGED PROPERTY HEADER
                    mapPropertyTracker.put(strKeyTmp, ms.Managed_Property__r.Name);
                    displayGridRow grProperty = new displayGridRow (
                        'Property',
                        false,
                        false,
                        false,
                        null,
                        ms.Managed_Property__r.Name,
                        null, 
                        null, 
                        null, 
                        null, 
                        null,
                        strKeyTmp, 
                        iIndex,
                    	ms.Activity_Line_Item__r.Product_Package__r.Name, 
                        ms.Managed_Property__r.Name,
                    	false
                    );
                    
                    if (ms.Managed_Property__r.Name != null && bIsConsolidated)
                    {
                        lstMilestones.add(grProperty);
                        iIndex++;
                    }

                    // CREATE MILESTONE ROW
                    displayGridRow grMS2 = new displayGridRow (
                        'Milestone',
                        false,
                        false,
                        false,
                        ms,
                        null, 
                        ms.Activity_Line_Item__r.Opp_Product_ID__c, 
                        ms.Activity_Line_Item__r.Name, 
                        ms.Activity_Line_Item__r.Product__r.Name, 
                        ms.Activity_Line_Item__r.Product__r.Unit__c, 
                        ms.Activity_Line_Item__r.Units__c,
                        strKeyTmp, 
                        iIndex,
                    	ms.Activity_Line_Item__r.Product_Package__r.Name, 
                    	ms.Managed_Property__r.Name,
                    	false
                    );
                    lstMilestones.add(grMS2);     
					iCount++; 
                    iIndex++;
                }
                else
                {
                    // CREATE MILESTONE ROW
                    displayGridRow grMS3 = new displayGridRow (
                        'Milestone',
                        false,
                        false,
                        false,
                        ms,
                        null, 
                        ms.Activity_Line_Item__r.Opp_Product_ID__c, 
                        ms.Activity_Line_Item__r.Name, 
                        ms.Activity_Line_Item__r.Product__r.Name, 
                        ms.Activity_Line_Item__r.Product__r.Unit__c, 
                        ms.Activity_Line_Item__r.Units__c,
                        strKeyTmp, 
                        iIndex,
                    	ms.Activity_Line_Item__r.Product_Package__r.Name, 
                    	ms.Managed_Property__r.Name,
                    	false
                    );
                    lstMilestones.add(grMS3);  
                    iCount++;
                    iIndex++;
                }
            }
  			
        }        
system.debug(' **^** TEST lstMilestones.size() = ' + lstMilestones.size());  
        // LOOP THROUGH MILESTONES AND SET LOCKS ON "APPROVED" RELATED ROWS 
        Set<String> setLockKeys = new Set<String>();
        
        for (displayGridRow m1 : lstMilestones)
        {
            if (m1.strRowType == 'Milestone' && m1.mileStone.pse__Status__c == 'Approved')
            {
                setLockKeys.add(m1.strKey);
            }
        }
        
        for (String s : setLockKeys)
        {
            for (displayGridRow m2 : lstMilestones)
            {
                if (s == m2.strKey)
                {
                    m2.bIsViewOnly = true;
                }
            }
        }            
		
        // UPDATE PRODUCT UNIT TO VALUE ON RELATED OLI PRODUCTS
        for (OpportunityLineItem oli : [SELECT Id, Name, Product2Id, Product2.Unit__c
                                        FROM OpportunityLineItem 
                                        WHERE Id IN : setOLIIds])
        {
            for (displayGridRow ms2 : lstMilestones)
            {              
                if (oli.Id == ms2.opportunityLineItemId)
                {
                    ms2.productUnit = oli.Product2.Unit__c;
                }
            }        
        }        
        
        
    }

	public void doSelectPackage()
    {
           
        Integer iIndx = (iSelIndex + 1);
        Integer iRows = (iIndx + (lstMilestones.size() - iIndx));

        for (integer i = iIndx; (i < iRows); i++)
        {            
            if (lstMilestones[i].strRowType != 'Package')
            { 
                if (!lstMilestones[i].bIsViewOnly)
                {                
                    lstMilestones[i].bIsPropertySelected = lstMilestones[iSelIndex].bIsPackageSelected;
                    lstMilestones[i].bIsMilestoneSelected = lstMilestones[iSelIndex].bIsPackageSelected;   
                }
            }
            else
            {                
                break;
            }
        }
        
    }
    
	public void doSelectProperty()
    {
   
        Integer iIndx = (iSelIndex + 1);
        Integer iRows = (iIndx + (lstMilestones.size() - iIndx));

        for (integer i = iIndx; (i < iRows); i++)
        {         
            if (lstMilestones[i].strRowType != 'Package' && lstMilestones[i].strRowType != 'Property')
            {
                if (!lstMilestones[i].bIsViewOnly)
                {
                    lstMilestones[i].bIsMilestoneSelected = lstMilestones[iSelIndex].bIsPropertySelected; 
                }         
            }
            else
            {
                break;
            }
        }
        
    }
	
    public PageReference selectMS() 
    {
        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + strMSID;
        PageReference pr = new PageReference(strUrl); 
        pr.setRedirect(true); 
        return pr; 
    }     

    public PageReference selectALI() 
    {
        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + strALIID;
        PageReference pr = new PageReference(strUrl); 
        pr.setRedirect(true); 
        return pr; 
    }    
    
    public PageReference selectOLI() 
    {
        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + strOLIID;
        PageReference pr = new PageReference(strUrl); 
        pr.setRedirect(true); 
        return pr; 
    }    
    
    // =====================================================
    // VF PAGE BUTTON METHODS
    // =====================================================
    
    // STEP 1: =============================================
    public pageReference step1Cancel()
    {        
        pageReference pr = new pageReference('/' + p.Id); 
        pr.setRedirect(true);
        return pr; 		
    }   

    public void step1Next()
    {
        
        bOp1 = false;
        bOp2 = true;
        bOp3 = false;
        bOp4 = false;  
        strErrorMsg = '';
        
        // PAGE VALIDATION        
        if (selMasterReason == 'CHOOSE ONE')
        {
            strErrorMsg = '* Milestone Change Reason is required.'; 
            bOp1 = true;
            bOp2 = false;  
            return;
        }
        
        if (strMilestoneChangeNote == '')
        {
            strErrorMsg = '* Milestone Change Note is required.'; 
            bOp1 = true;
            bOp2 = false;  
            return;
        }
system.debug(' **^** calling loadMilestones() from step1Next()');        
        loadMilestones();
        
    }

    // STEP 2: =============================================
    public void step2Prev()
    {
        bOp1 = true;
        bOp2 = false;
        bOp3 = false;
        bOp4 = false; 
        strErrorMsg = '';
    }
 
    public void step2Next()
    {
        
        bOp1 = false;
        bOp2 = false;
        bOp3 = true;
        bOp4 = false; 
        strErrorMsg = '';
		iSelSize = 0;
        dTotalAmount = 0;
        
        lstSelMilestones = new List<displayGridRow>();
        for (displayGridRow ms : lstMilestones)
        {
            if (ms.strRowType == 'Milestone' && ms.bIsMilestoneSelected)
            {
                lstSelMilestones.add(ms);
                if (ms.mileStone.pse__Milestone_Amount__c != null)
                {
                    dTotalAmount += ms.mileStone.pse__Milestone_Amount__c;
                }
            }
        }         

        iSelSize = lstSelMilestones.size();
        
        if (lstSelMilestones.isEmpty())
        {
            strErrorMsg = '* No Milestones were selected'; 
            bOp2 = true;
            bOp3 = false;            
        }
        
    }

    // STEP 3: =============================================
    public void step3Prev()
    {
        bOp1 = false;
        bOp2 = true;
        bOp3 = false;
        bOp4 = false;
        strErrorMsg = '';
    }

    public void step3Save()
    {
        
        bOp1 = false;
        bOp2 = false;
        bOp3 = false;
        bOp4 = true;
        strErrorMsg = '';
        String strMilestoneType = 'Change Order Requested';
        Opportunity o = [SELECT Id, Effective_Date__c, OwnerId, Owner.Name, Owner.IsActive, Account.OwnerId, Account.Owner.Name  
                         FROM Opportunity 
                         WHERE Id =: p.pse__Opportunity__c]; 
        
        try
        {

            Date dtToday = Date.today();
            Date dtEffectiveDate = dtToday.addYears(20);
            if (o.Effective_Date__c != null)
            {
                dtEffectiveDate = o.Effective_Date__c;
            }
            Date dtYearOut = dtEffectiveDate.addDays(365);
            
            if (dtYearOut < dtToday)
            {
                strMilestoneType = 'Stale';
            }
            
            List<pse__Milestone__c> lstUpdates = new List<pse__Milestone__c>();
            
            for (displayGridRow ms : lstSelMilestones)
            {
                pse__Milestone__c x = new pse__Milestone__c(); 
                String strPreviousType = ms.mileStone.Milestone_Type__c; 
                x.Id = ms.mileStone.Id; 
                x.Reason_for_Milestone_Change__c = selMasterReason; 
                x.Milestone_Type_Previous__c = strPreviousType; 
                x.Milestone_Type__c = strMilestoneType; 
system.debug('**%** AH_UpdateBacklogMilestones:  NEW TYPE = ' + x.Milestone_Type__c + ', PREV TYPE = ' + x.Milestone_Type_Previous__c); 
                lstUpdates.add(x); 
            }
system.debug('**%** lstUpdates.size() = ' + lstUpdates.size()); 
            database.update(lstUpdates);
            //if (strMilestoneType == 'Change Order Requested')
            //{
            // CREATE CONDITION THAT MEETS ENTRY CRITERIA OF APPROVAL PROCESS
            p.Milestone_Change_Note__c = strMilestoneChangeNote;
            p.Cancellation_Approval_Status__c = 'Submitted';
            update p;                
            //}                

        }
        catch (Exception e)
        {
            strErrorMsg = 'An Error Occurred: ' + e.getMessage() + '\n\n';
            bOp1 = false;
            bOp2 = false;
            bOp3 = true;
            bOp4 = false; 
            return;
        }
        
        if (strMilestoneType == 'Change Order Requested')
        {
            try
            {      
                bSubmitted4Approval = false;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval.');
                req.setObjectId(p.Id); 
                if (o.Owner.IsActive)
                {
                    strApprover = 'Opportunity owner: ' + o.Owner.Name;
                    req.setNextApproverIds(new Id[] {o.OwnerId});
                }
                else
                {
                    strApprover = 'Account owner: ' + o.Account.Owner.Name + '(Opportunity owner: ' + o.Owner.Name + ' is not active)';
                    req.setNextApproverIds(new Id[] {o.Account.OwnerId}); 
                }
                
                Approval.ProcessResult result = Approval.process(req);
                bSubmitted4Approval = true;
            }
            catch (Exception e)
            {
                bOp1 = false;
                bOp2 = false;
                bOp3 = true;
                bOp4 = false;             
                strErrorMsg += 'An Error Occurred: ' + e.getMessage();        
            }     
        }
        
    }  
    
    // STEP 4: =============================================
    public pageReference step4Next()
    {
        pageReference pr = new pageReference('/' + p.Id); 
        pr.setRedirect(true);
        return pr; 
    }
    

    // INNER CLASSES =======================================  
    public class displayGridRow
    {
		
        public String strRowType {get; set;} 			// Package, Property, Milestone
        public Boolean bIsPackageSelected {get; set;}    
        public Boolean bIsPropertySelected {get; set;} 
        public Boolean bIsMilestoneSelected {get; set;} 
        public pse__Milestone__c mileStone {get; set;} 
        public String strHeader {get; set;} 
        public Id opportunityLineItemId {get; set;}
        public String activityLineItemNumber {get; set;}
        public String productName {get; set;}
        public String productUnit {get; set;}
        public Decimal Quantity {get; set;}
        public String strKey {get; set;} 
        public Integer iIndex {get; set;} 
        public String productPackageName {get; set;} 
        public String managedPropertyName {get; set;} 
        public Boolean bIsViewOnly {get; set;} 
        
        public displayGridRow(
            String s1, 
            Boolean b1, 
            Boolean b2, 
            Boolean b3, 
            pse__Milestone__c r1, 
            String s2, 
            Id oli, 
            String s3, 
            String s4, 
            String s5, 
            Decimal d1, 
            String s6, 
            Integer i1, 
            String s7,
            String s8,
            Boolean b4
        )
        {
            this.strRowType = s1;
            this.bIsPackageSelected = b1;
            this.bIsPropertySelected = b2;
            this.bIsMilestoneSelected = b3;
            this.mileStone = r1;
            this.strHeader = s2;
            this.opportunityLineItemId = oli;
            this.activityLineItemNumber = s3;
            this.productName = s4;
            this.productUnit = s5;
            this.Quantity = d1;   
            this.strKey = s6;
            this.iIndex = i1;
            this.productPackageName = s7;
            this.managedPropertyName = s8;
            this.bIsViewOnly = b4;
        }
        
    }    
     
}