/************************************************************************************************
Name            : AH_CancelRenewals Class
Author          : Sean Harris
Created Date    : 01/18/2018
Last Mod Date   : 07/22/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-025668
Description     : Controller class for AH_CancelRenewals VF Page 
                : 
                : 
                : 
*************************************************************************************************/
public class AH_CancelRenewals 
{

    // PUBLIC VARIABLES ======================================
    
    // OBJECT VARIABLES
    public User u {get; set;}  
    public Account a {get; set;}
    public Activity_Line_Item__c aliEdit {get; set;}  
    public NI_Cancellation__c niCancellation {get; set;} 
  
    // COLLECTIONS
    public List<activityLineItem> lstActivityLineItems {get; set;} 
    public List<cancellationLineItem> lstCancellations {get; set;} 
    public List<SelectOption> lstSearchResults {get; set;} 
    public List<SelectOption> lstGenReasons {get; set;} 
    public List<SelectOption> lstLateReasons {get; set;} 
    public Set<Id> setAccountIds {get; set;} 
    // BOOLEANS 
    public Boolean displayEditCxl {get; set;}  
    public Boolean displayConfirm {get; set;} 
    public Boolean displayViewCxl {get; set;} 
    public Boolean isAccepted {get; set;} 
    public Boolean isInternalUser {get; set;} 
    public Boolean showMainDetails {get; set;}  
    public Boolean bHasChildAccts {get; set;} 
    public Boolean cxlEditMode {get; set;} 
    public Boolean bShowCxlDialog {get; set;} 
    public Boolean hasRemainingQty {get; set;} 
    public Boolean hasCancellations {get; set;} 
    public Boolean isCxlForDiffAcct {get; set;} 
    public Boolean hasChildren {get; set;}
    public Boolean hasRenewableProducts {get; set;}
    public Boolean isLate {get; set;}
    public Boolean isSuccess {get; set;}
    public Boolean displayAttachFiles {get; set;}   
    public Boolean bActiveSearch {get; set;} 
    public Boolean showSaveError {get; set;}
    // NUMERICS
    public Integer iALIIndex {get; set;} 
    public Integer iCxlIndex {get; set;} 
    public Decimal iQuantityToCancel {get; set;} 
    // STRINGS
    public String accKeyword {get; set;}     
    public String strSearchMsg {get; set;}  
    public String msgColor {get; set;} 
    public String saveError {get; set;}     
    public String selAccId {get; set;} 
    public String toastMsg {get; set;} 
    public String strQuery {get; set;} 
    
    // IDS
    public Id aliId {get; set;} 
    // USER INPUT VARIABLES    
    public String selGenReason {get; set;} 
    public String selLateReason {get; set;} 
    public String strSpecificUserNames {get; set;} 
    public String strRenewalCancellationNote {get; set;} 
    public Id contactId {get; set;}
    public String contactName {get; set;}     
    // FILE UPLOAD VARIABLES
    public transient Blob upFileBlob { get; set; }
    public String upFileName {get; set;} 
    public Integer upFileSize {get; set;}
    public Id delCVerId {get; set;}
    public Id delCDocId {get; set;}
    public String strFileMsg {get; set;}
    public List<ContentVersion> lstCVs {get; set;}
    
    public String Contact_lktp {get; set;} 
    public String Contact_mod {get; set;} 
    

    // PRIVATE VARIABLES ====================================
    private String sortDirection = 'ASC'; 
    private String sortExp = 'Contract_End_Date__c'; 
    private Integer iDefaultCutOffDays {get; set;} 
    private String ipAddress {get; set;} 
    private Map<String, Decimal> mapCS {get; set;} 
    
    
    public AH_CancelRenewals()
    {

        initVariables();
        
        try 
        {
          
            // GET USER RECORD OF RUNNING USER
            u = [SELECT Id, Name, AccountId, ContactId, Cancellation_User__c FROM User WHERE Id =: UserInfo.getUserId()];
             
            // GET IP ADDRESS OF RUNNING USER
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
           
            // GET ACCOUNT RECORD OF RUNNING USER
            if (u.AccountId == null)
            {
                if (NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'Renewal Cancellation Managers'))
                {
                    isInternalUser = true;
                    if (ApexPages.CurrentPage().getParameters().containsKey('acctid')) 
                    {
                        a = [SELECT Id, Name, AccountNumber, OwnerId, ParentId, Franchisor__c, Brand__c 
                             FROM Account WHERE Id =: ApexPages.CurrentPage().getParameters().get('acctid')];
                    }
                }
            }
            else
            {
                if (u.Cancellation_User__c == 'True')
                {
                    if (ApexPages.CurrentPage().getParameters().containsKey('acctid')) 
                    {
                        String strUId = u.AccountId;
                        if (ApexPages.CurrentPage().getParameters().get('acctid') == strUId)
                        {
                            a = [SELECT Id, Name, AccountNumber, OwnerId, ParentId, Franchisor__c, Brand__c 
                                 FROM Account WHERE Id =: u.AccountId];
                        }
                        else
                        {
                            integer iForceError = (1 / 0);
                        }
                    }                
                    else
                    {
                        a = [SELECT Id, Name, AccountNumber, OwnerId, ParentId, Franchisor__c, Brand__c 
                             FROM Account WHERE Id =: u.AccountId];
                    }                    
                }
                else
                {
                    showMainDetails = false;
                    string message = Label.Cancel_Renewal_Form_Non_Cancellation_User_Message;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
                    ApexPages.addMessage(myMsg);   
                    return;
                }                    
            }

            // READ IN CUSTOM METADATA TYPES AND ADD TO MAP
            mapCS = new Map<String, Decimal>();
            for (Cancellation_Setting__mdt cs : [SELECT Product_Line__c, Days_Before_End_Date__c FROM Cancellation_Setting__mdt])
            {
                if (cs.Product_Line__c == 'Default')
                {
                    iDefaultCutOffDays = integer.valueOf(cs.Days_Before_End_Date__c);
                }
                mapCS.put(cs.Product_Line__c, cs.Days_Before_End_Date__c);
            }      
            
            if (a.Id != null)
            {
                loadProducts();
            }  
            
            loadAccountIdSet();

            // FILL CANCELLATION REASON PICKLIST
//            lstReasons = new List<SelectOption>();
//            Schema.DescribeFieldResult dfr = NI_Cancellation__c.Renewal_Cancellation_Reason__c.getDescribe();
//            lstReasons.add(new SelectOption('CHOOSE ONE', 'CHOOSE ONE'));
//            for (Schema.PicklistEntry plv : dfr.getPicklistValues())
//            {
//                lstReasons.add(new SelectOption(plv.getValue(), plv.getLabel()));
//            }  

            // FILL GENERAL CANCELLATION REASON PICKLIST
            lstGenReasons = new List<SelectOption>();
            Schema.DescribeFieldResult dfr2 = NI_Cancellation__c.General_Reason__c.getDescribe();
            lstGenReasons.add(new SelectOption('CHOOSE ONE', 'CHOOSE ONE'));
            for (Schema.PicklistEntry plv2 : dfr2.getPicklistValues())
            {
                lstGenReasons.add(new SelectOption(plv2.getValue(), plv2.getLabel()));
            }


            // FILL LATE CANCELLATION REASON PICKLIST
            lstLateReasons = new List<SelectOption>();
            Schema.DescribeFieldResult dfr3 = NI_Cancellation__c.Late_Cancellation_Reason__c.getDescribe();
            lstLateReasons.add(new SelectOption('CHOOSE ONE', 'CHOOSE ONE'));
            for (Schema.PicklistEntry plv3 : dfr3.getPicklistValues())
            {
                lstLateReasons.add(new SelectOption(plv3.getValue(), plv3.getLabel()));
            }            
            
        }
        catch (exception ex)
        {
            showMainDetails = false;
            string message = Label.Cancel_Renewal_Form_Default_Load_Message;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
            ApexPages.addMessage(myMsg);            
        }

    }

    
    // PAGE INITIALIZATION FUNCTIONS
    private void initVariables()
    {
        showMainDetails = true;
        isInternalUser = false;     
        iCxlIndex = 0;
        cxlEditMode = false;
        displayAttachFiles = false;   
        contactId = null;
        contactName = '';       
        Contact_lktp = '003';
        Contact_mod = '0';
    }
    
    private void loadAccountIdSet()
    {
        
        // FILLS A SET OF ACCOUNT IDS 5 LEVELS "DOWN" FROM USER'S ACCOUNT
        
        system.debug(' *** ENTERING AH_CancelRenewals.loadAccountIdSet() - QUERIES ISSUED = ' + Limits.getQueries());
        
        setAccountIds = new Set<Id>();        
        setAccountIds.add(a.Id);

        for (Account acc1 : [SELECT Id FROM Account WHERE ParentId =: a.Id])
        {
            setAccountIds.add(acc1.Id);
        }

        for (Account acc2 : [SELECT Id FROM Account WHERE ParentId IN : setAccountIds])
        {
            setAccountIds.add(acc2.Id);
        }

        for (Account acc3 : [SELECT Id FROM Account WHERE ParentId IN : setAccountIds])
        {
            setAccountIds.add(acc3.Id);
        }

        for (Account acc4 : [SELECT Id FROM Account WHERE ParentId IN : setAccountIds])
        {
            setAccountIds.add(acc4.Id);
        }

        for (Account acc5 : [SELECT Id FROM Account WHERE ParentId IN : setAccountIds])
        {
            setAccountIds.add(acc5.Id);
        }
      
        bHasChildAccts = false;
        if (setAccountIds.size() > 1)
        {
            bHasChildAccts = true;
        }

        system.debug(' *** EXITING AH_CancelRenewals.loadAccountIdSet() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void loadProducts()
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.loadProducts() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Integer iRow = 0;
        lstActivityLineItems = new List<activityLineItem>();
        iRow = 0;
        hasRenewableProducts = true;
        Date d = Date.today().AddDays(-210);  // NICC-027710        
        
        List<Activity_Line_Item__c> lstALISearchResults = new List<Activity_Line_Item__c>();        
// NICC-TBD (START)       
        
        // FILL LIST WITH ACCOUNT FINANCE POLICIES ON RELATED ACCOUNT
        List<AH_Account_Finance_Policy__c> lstPolicies = new List<AH_Account_Finance_Policy__c>(
            [SELECT Id, Name, Account__c, Solution_Domain__c, Billing_Contracts__c, Start_Date__c, End_Date__c 
             FROM AH_Account_Finance_Policy__c
             WHERE IsActive__c = true
             AND Account__c =: a.Id]); 
        
        // PARSE BILLING CONTRACT IDS FROM ACCOUNT FINANCE POLICY Billing_Contracts__c FIELD INTO A SET
        Set<Id> setBCIDs = new Set<Id>();
        
        for (AH_Account_Finance_Policy__c afp : lstPolicies)
        {
            if (afp.Billing_Contracts__c != null && afp.Billing_Contracts__c != '')
            {
                String strBCIds = afp.Billing_Contracts__c;
                for (String bcID : strBCIds.split(','))
                {
                    setBCIDs.add(bcID);
                }  
            }                
        }
   
// NICC-TBD (END)         
        String sSOQL = 'SELECT '; 
        sSOQL += 'Id, Name, SKU__c, '; 
        sSOQL += 'Contract_Start_Date__c, Contract_End_Date__c, '; 
        sSOQL += 'Units__c, Units_Cancelled__c, Units_Remaining__c, '; 
        sSOQL += 'Product__r.Name, Product__r.Product_Line_Global__c, '; 
// NICC-TBD (START) 
        
        // ADDED NEW FIELDS TO SELECT FOR CANCELLATION RESTRICTIONS
        sSOQL += 'Product__r.Solution_Domain_Global__c, ';
        sSOQL += 'Billing_Contract__c, ';
        sSOQL += 'Order_of_Delivery__c, ';
        sSOQL += 'Opportunity__r.AccountId, ';
        sSOQL += 'Opportunity__c, ';
        sSOQL += 'Product__c, ';
        sSOQL += 'Renewal_Date__c, ';
        
// NICC-TBD (END)        
        sSOQL += 'Opportunity__r.Opportunity_Number__c '; 
        sSOQL += 'FROM Activity_Line_Item__c '; 
        sSOQL += 'WHERE Billing_Contract__r.Account__r.Id = \'' + a.Id + '\' '; 
        sSOQL += 'AND Status__c = \'Active\' '; 
        sSOQL += 'AND Contract_Start_Date__c != null '; 
        sSOQL += 'AND Contract_End_Date__c != null '; 
        sSOQL += 'AND Revenue_Category__c IN (\'Hosting and Support\', \'Subscription\', \'Support\') '; 
        sSOQL += 'AND ( '; 
        sSOQL += '    (Contract_End_Date__c >: d) '; 
        sSOQL += '    OR '; 
        sSOQL += '    (Renewal_Processed__c = false AND Auto_Renewal__c = true) '; 
        sSOQL += ') '; 
        
// NICC-TBD (START)         
        sSOQL += 'AND Contract_Total_Amount__c >= 0 ';
// NICC-TBD (END)          
        
        sSOQL += 'ORDER BY ' + sortExpression  + ' ' + sortDirection + ', Order_of_Delivery__c'; 
        
        system.debug(' **** sSOQL = ' + sSOQL);     
        
        strQuery = sSOQL;
        
        lstALISearchResults = Database.query(sSOQL);
        
        
// NICC-TBD (START) 
        
        // FILL MAP WITH ALL MAX 'ORDER OF DELIVERY' VALUES (KEY IS COMPRISED OF Account Id + Opportunity Id + Product2 Id) 
        Map<String, Decimal> mapMaxOoDs = new Map<String, Decimal>();    
        // GET ORDER OF DELIVERY CEILINGS
        for (Activity_Line_Item__c alix : lstALISearchResults)
        {  
            if (alix.Opportunity__r.AccountId != null && alix.Opportunity__c != null && alix.Product__c != null)    // && alix.Order_of_Delivery__c != null
            {
                // CREATE MAP KEY
                string strMapKey = alix.Opportunity__r.AccountId + '-' + alix.Opportunity__c + '-' + alix.Product__c;
                Decimal iOOD = 1;
                // IF KEY EXISTS IN MAP
                if (mapMaxOoDs.containsKey(strMapKey))
                { 
                    if (alix.Order_of_Delivery__c != null)
                    {
                        iOOD = alix.Order_of_Delivery__c;
                    }
                    // IF 'ORDER OF DELIVERY' IS GREATER THAN EXISTING, REPLACE IT WITH GREATER VALUE
                    if (mapMaxOoDs.get(strMapKey) < iOOD) 
                    { 
                        mapMaxOoDs.put(strMapKey, iOOD); 
                    } 
                } 
                else 
                { 
                    // ADD NEW VALUE TO MAP
                    mapMaxOoDs.put(strMapKey, iOOD);
                } 
            } 
        }

// NICC-TBD (END)         
        
        // POPULATE ELIGABLE PRODUCTS 
        for (Activity_Line_Item__c a : lstALISearchResults)
        {  
            
            // INITALIZE LOOP VARIABLES
            Boolean isRecordLocked = false; 
            Integer iDays = iDefaultCutOffDays; 
            Integer iDaysLeft = 0;
            Date dDeadlineDate = a.Contract_End_Date__c; 
            Date dToday = Date.today();
            String sInternalEditLabel = 'CHANGE/CANCEL RENEWAL';
            String sInternalEditLabelStyle = 'text-align:center;';
            String strToolTip = 'This product recently automatically renewed per the terms of your agreement. If you would like additional details, please contact your sales manager.';
            
            // DETERMINE CANCELLATION DEADLINE
            if (mapCS.get(a.Product__r.Product_Line_Global__c) != null) 
            { 
                iDays = (Integer)mapCS.get(a.Product__r.Product_Line_Global__c);
                iDaysLeft = Date.today().daysBetween(dDeadlineDate.addDays(-iDays)); 
                dDeadlineDate = dDeadlineDate.addDays(-iDays);
            } 
            else
            {
                iDaysLeft = Date.today().daysBetween(dDeadlineDate.addDays(-30));
                dDeadlineDate = dDeadlineDate.addDays(-30);
            }
            
            // IF NO DAYS LEFT THEN LOCK IT FOR CUSTOMER
            if (iDaysLeft < 0) 
            {
                isRecordLocked = true; 
            } 
            
            // IF USER IS INTERNAL UNLOCK IT
            if (isInternalUser) 
            { 
                isRecordLocked = false; 
            } 
            
            // IF USER IS INTERNAL AND CANCELLATION DEADLINE HAS PASSED
            if ((dToday > dDeadlineDate) && isInternalUser) 
            { 
                sInternalEditLabel = 'SUBMIT LATE CANCELLATION'; 
                sInternalEditLabelStyle = 'text-align:center;color:red;'; 
            }
            
// NICC-TBD (START) 

            // MULTI-YEAR DEAL FIX (START)
            string strMapKey = a.Opportunity__r.AccountId + '-' + a.Opportunity__c + '-' + a.Product__c; 
            
            if (a.Order_of_Delivery__c != mapMaxOoDs.get(strMapKey) && mapMaxOoDs.get(strMapKey) != 1) 
            {                
                isRecordLocked = true; 
                sInternalEditLabel = 'MODIFICATION INELIGIBLE'; 
                strToolTip = 'This product is ineligible for modifications at this time.  If you would like additional details, please contact your sales manager.'; 
            } 
                            
            if (!lstPolicies.isEmpty())
            {

                // MULTI-YEAR DEAL FIX (END)
                
                Boolean bIsIneligible = false;
                for (AH_Account_Finance_Policy__c afp : lstPolicies)
                {                     
                    if (a.Renewal_Date__c >= afp.Start_Date__c && a.Renewal_Date__c <= afp.End_Date__c)
                    {
system.debug(' *%* a.SKU__c = ' + a.SKU__c + ',  a.Opportunity__r.Opportunity_Number__c = ' + a.Opportunity__r.Opportunity_Number__c + ' bIsIneligible = ' + bIsIneligible + ', mapMaxOoDs.get(strMapKey) = ' + mapMaxOoDs.get(strMapKey));                        
                        if (setBCIDs.contains(a.Billing_Contract__c))
                        {
                            bIsIneligible = true;
                        }
                        
                        if (afp.Solution_Domain__c != null && afp.Solution_Domain__c != '')
                        {               
                            if (a.Product__r.Solution_Domain_Global__c == afp.Solution_Domain__c)
                            {
                                bIsIneligible = true;
                            }                    
                        }                    
                    }
                }
                
                if (bIsIneligible)
                {
                    isRecordLocked = true; 
                    sInternalEditLabel = 'MODIFICATION INELIGIBLE'; 
                    strToolTip = 'This product is ineligible for modifications at this time.  If you would like additional details, please contact your sales manager.'; 
                } 
            }
           
// NICC-TBD (END) 

            activityLineItem ali = new activityLineItem (
                iRow, 
                a.Id, 
                a.Name,       
                a.Product__r.Name, 
                a.SKU__c, 
                a.Opportunity__r.Opportunity_Number__c, 
                a.Contract_Start_Date__c, 
                a.Contract_End_Date__c, 
                dDeadlineDate, 
                a.Units__c, 
                a.Units_Cancelled__c, 
                a.Units_Remaining__c, 
                isRecordLocked,
                sInternalEditLabel,         // NICC-027192
                sInternalEditLabelStyle,    // NICC-027192
                strToolTip,                 // NICC-TBD
                a.Order_of_Delivery__c      // NICC-TBD
            );
           
            lstActivityLineItems.add(ali);
            iRow++;    
            
        }        
  
        if (lstActivityLineItems.isEmpty())
        {
            hasRenewableProducts = false;
            string message = 'We have found no renewable products that this account has subscribed to. Please contact Amadeus Hospitality Sales if you have any questions.';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
            ApexPages.addMessage(myMsg);               
        }
        
        system.debug(' *** EXITING AH_CancelRenewals.loadProducts() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    

    private void loadCancellations(Id ActivityLineItemId)
    {        
        
        system.debug(' *** ENTERING AH_CancelRenewals.loadCancellations() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Integer iRow = 0;
        hasCancellations = false; 

        Map<String, String> mapStatuses = new Map<String, String>();
        for (Renewal_Cancellation_Status_Display__mdt csSts : [SELECT Customer_Facing_Status__c, Internal_Status__c 
                                                               FROM Renewal_Cancellation_Status_Display__mdt])
        {
            mapStatuses.put(csSts.Internal_Status__c, csSts.Customer_Facing_Status__c);
        }     
        
        // QUERY FOR ALL ITEMS THE CUSTOMER HAS REQUESTED CANCELATION ON 
        lstCancellations = new List<cancellationLineItem>(); 

        for (NI_Cancellation__c c : [SELECT 
                                     Id, 
                                     Name, 
                                     Master_Cancellation_Record__c, 
                                     Activity_Line_Item__c, 
                                     Activity_Line_Item__r.Name, 
                                     Activity_Line_Item__r.SKU__c, 
                                     Activity_Line_Item__r.Contract_Start_Date__c, 
                                     Activity_Line_Item__r.Contract_End_Date__c, 
                                     Activity_Line_Item__r.Units__c, 
                                     Activity_Line_Item__r.Product__r.Name, 
                                     Activity_Line_Item__r.Product__r.Product_Line_Global__c,
                                     Renewal_Cancellation_Requested__c,  
                                     Renewal_Cancellation_Quantity__c, 
//                                     Renewal_Cancellation_Reason__c, 
                                     General_Reason__c, 
                                     Late_Cancellation_Reason__c, 
                                     Renewal_Cancellation_Note__c, 
                                     Renewal_Cancellation_Request_DateTime__c, 
                                     Renewal_Cancellation_Requester__c, 
                                     Renewal_Cancellation_Requester__r.Name, 
                                     Opportunity__c, 
                                     Opportunity__r.Opportunity_Number__c, 
                                     Account__r.Name,
                                     Specific_User_Names__c, 
                                     Status__c 
                                     FROM NI_Cancellation__c
                                     WHERE Activity_Line_Item__c =: ActivityLineItemId 
                                     AND Renewal_Cancellation_Quantity__c > 0 
//                                     AND Status__c NOT IN ('Status__c')
                                     ORDER BY CreatedDate DESC])    
        {

            Boolean isRecordLocked = false;
            Integer iDays = iDefaultCutOffDays;
            Integer iDaysLeft = 0;
            Date dDeadlineDate = c.Activity_Line_Item__r.Contract_End_Date__c;
            
            if (mapCS.get(c.Activity_Line_Item__r.Product__r.Product_Line_Global__c) != null)
            {
                iDays = (Integer)mapCS.get(c.Activity_Line_Item__r.Product__r.Product_Line_Global__c);
                iDaysLeft = Date.today().daysBetween(c.Activity_Line_Item__r.Contract_End_Date__c.addDays(-iDays));  
                dDeadlineDate = dDeadlineDate.addDays(-iDays);
            }
            
            system.debug(' **** (loadCancellations) Product Line = ' + c.Activity_Line_Item__r.Product__r.Product_Line_Global__c + ', Contract End Date = ' + c.Activity_Line_Item__r.Contract_End_Date__c + ', iDays = ' + iDays + ', iDaysLeft = ' + iDaysLeft);            
            
            if (iDaysLeft < 0)
            {
                isRecordLocked = true;
            }           
            
            if (c.Status__c == 'Successfully Retained')
            {
                isRecordLocked = true;
            }
            
            system.debug(' **** (loadCancellations) isRecordLocked = ' + isRecordLocked); 
            
            cancellationLineItem cli = new cancellationLineItem (
                iRow, 
                c.Id, 
                c.Master_Cancellation_Record__c, 
                c.Name, 
                c.Activity_Line_Item__c, 
                c.Activity_Line_Item__r.Name, 
                c.Activity_Line_Item__r.SKU__c, 
                c.Activity_Line_Item__r.Contract_Start_Date__c, 
                c.Activity_Line_Item__r.Contract_End_Date__c, 
                dDeadlineDate, 
                c.Activity_Line_Item__r.Units__c, 
                c.Activity_Line_Item__r.Product__r.Name, 
                c.Activity_Line_Item__r.Product__r.Product_Line_Global__c, 
                c.Renewal_Cancellation_Requested__c,  
                c.Renewal_Cancellation_Quantity__c, 
//                c.Renewal_Cancellation_Reason__c, 
                c.General_Reason__c, 
                c.Late_Cancellation_Reason__c, 
                c.Renewal_Cancellation_Note__c, 
                c.Renewal_Cancellation_Request_DateTime__c, 
                c.Renewal_Cancellation_Requester__c, 
                c.Renewal_Cancellation_Requester__r.Name, 
                c.Opportunity__c, 
                c.Opportunity__r.Opportunity_Number__c,
                c.Account__r.Name,   
                c.Specific_User_Names__c,
                mapStatuses.get(c.Status__c), 
                isRecordLocked 
            );
            
            lstCancellations.add(cli);
            iRow++;
        }   
        
        if (lstCancellations.size() > 0)
        {
            hasCancellations = true;
        }        

        system.debug(' *** EXITING AH_CancelRenewals.loadCancellations() - QUERIES ISSUED = ' + Limits.getQueries());
               
    }
    
    public void openForm() 
    { 
                
        system.debug(' *** ENTERING AH_CancelRenewals.openForm() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // INITIALIZE VARIABLES
        displayEditCxl = true;      // SWITCH THAT DISPLAYS POPUP     
        saveError = null;           // STRING THAT HOLDS ERROR MESSAGES
        showSaveError = false;
        strSearchMsg = '';          // STRING THAT HOLDS SEARCH MESSAGE DETAILS
        bShowCxlDialog = false;     // SWITCH TO OPEN CANCELLATION FORM SECTION IN POPUP
        isCxlForDiffAcct = false;   // SWITCH THAT TOGGLES THE VISIBLITY OF THE ACCOUNT SEARCH SECTION IN POPUP
        hasRemainingQty = false;    // SWITCH TO LOCK DOWN EDITS WHEN THERE IS NOTHING TO CANCEL
        bActiveSearch = false;       
        accKeyword = '';            // ACCOUNT NAME KEYWORD
        selAccId = '';              // SELECTED ACCOUNT ID            
        iQuantityToCancel = 0;
        selGenReason = ''; 
        selLateReason = '';         
        strSpecificUserNames = '';
        strRenewalCancellationNote = '';
        isLate = false;         
        strFileMsg = '';
        lstCVs = new List<ContentVersion>();
        contactId = null;
        contactName = '';
        
        if (lstActivityLineItems[iALIIndex].strInternalEditLabel == 'SUBMIT LATE CANCELLATION')
        {
            isLate = true; 
        }        
        
        // ASSIGN TARGETED ACTIVITY LINE ITEM
        aliEdit = [SELECT Id, Units__c, Billing_Contract__r.Account__c, 
                   Product__c, Product__r.Name, Opportunity__c, 
                   Opportunity__r.Opportunity_Number__c, Contract_Start_Date__c, Contract_End_Date__c, Cancellation_Effective_Date__c, Units_Cancelled__c, Units_Remaining__c  
                   FROM Activity_Line_Item__c 
                   WHERE Id =: aliId];

        if (aliEdit.Units_Remaining__c > 0)
        {
            hasRemainingQty = true;
        }
        
        // CREATE NEW INSTANCE OF A CANCELLATION RECORD AND INITIALIZE SOME FIELDS
        niCancellation = new NI_Cancellation__c();
        
        if (u.ContactId != null)
        {
            niCancellation.Contact__c = u.ContactId;
        }
                
        niCancellation.Account__c = aliEdit.Billing_Contract__r.Account__c;
        niCancellation.Activity_Line_Item__c = aliEdit.Id;
        niCancellation.Product2__c = aliEdit.Product__c;
        niCancellation.Opportunity__c = aliEdit.Opportunity__c;
        niCancellation.Renewal_Cancellation_Quantity__c = 0; 
        niCancellation.Status__c = 'Pending Retention';
        niCancellation.DI_Not_Found__c = false;
        niCancellation.Effective_Date__c = aliEdit.Contract_End_Date__c;        
        
        // LOAD ALL CANCELLATIONS RELATED TO ACTIVITY LINE ITEM CHOSEN 
        loadCancellations(aliEdit.Id);
                
        system.debug(' *** EXITING AH_CancelRenewals.openForm() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    
    // CANCELLATION DML FUNCTIONS
    public void saveChanges() 
    { 
        
        system.debug(' *** ENTERING AH_CancelRenewals.saveChanges() - QUERIES ISSUED = ' + Limits.getQueries());
        
        saveError = null;
        showSaveError = true;

        // USER INPUT VALIDATION (START) ===========================================================

        if (selGenReason == 'CHOOSE ONE')
        {
            saveError = 'ERROR: Please select a Reason';
            return;            
        }

        if (isLate && selLateReason == 'CHOOSE ONE')
        {
            saveError = 'ERROR: Please select a Late Cancellation Reason';
            return;            
        }
        
        if (iQuantityToCancel < 1) 
        {
            saveError = 'ERROR: Quantity to Cancel cannot be less than 1';
            return;            
        }
        
        if (iQuantityToCancel > aliEdit.Units_Remaining__c)
        {
            saveError = 'ERROR: Quantity to Cancel cannot be greater than the remaining amount of ' + string.valueOf(aliEdit.Units_Remaining__c);
            return;            
        }
        
        if (isLate && strRenewalCancellationNote.trim() == '')
        {
            saveError = 'ERROR: Please fill in Additional Notes';
            return;            
        }        
        
        if (isCxlForDiffAcct)
        {
            if ((selAccId == '') || (selAccId == 'CHOOSE ONE'))
            {
                saveError = 'ERROR: Please search and choose a property to request cancellation for.';
                return;    
            }                
        }

        // BECAUSE THE SPEC STATES THAT ONLY ONE CANCELLATION CAN EXIST PER ACCOUNT/ACTIVITY LINE ITEM, RAISE ERROR IS ANY EXIST WITH POSITIVE QTY
        // OR UPDATE THE ZERO QTY & STATUS
        Id accIdTmp = a.Id;        
        if (selAccId != '')
        {   
            accIdTmp = (Id)selAccId;
        }        
      
        if (accountHasCxlForALI(accIdTmp, aliEdit.Id))
        {
            if (acctHasCxlForALIwZeroQty(accIdTmp, aliEdit.Id))
            {
                NI_Cancellation__c cxlUpdate = [SELECT Id,  
                                                Renewal_Cancellation_Quantity__c, 
                                                Renewal_Cancellation_Requested__c, 
                                                Renewal_Cancellation_Request_DateTime__c, 
                                                Renewal_Cancellation_Requester__c, 
                                                Renewal_Cancellation_Requesters_IP__c, 
                                                Deployment_Instance__c, 
                                                DI_Not_Found__c, 
                                                General_Reason__c, 
                                                Renewal_Cancellation_Note__c, 
                                                Status__c 
                                                FROM NI_Cancellation__c 
                                                WHERE Account__c =: accIdTmp 
                                                AND Activity_Line_Item__c =: aliEdit.Id]; 
                
                cxlUpdate.Renewal_Cancellation_Quantity__c = niCancellation.Renewal_Cancellation_Quantity__c;
                cxlUpdate.General_Reason__c = niCancellation.General_Reason__c;
                cxlUpdate.General_Reason__c = niCancellation.General_Reason__c;

                if (niCancellation.General_Reason__c == 'User Reduction')
                {
                    cxlUpdate.Number_of_Users_Reduced__c = niCancellation.Renewal_Cancellation_Quantity__c;
                }
                
                cxlUpdate.Renewal_Cancellation_Note__c = niCancellation.Renewal_Cancellation_Note__c;
                cxlUpdate.Specific_User_Names__c = niCancellation.Specific_User_Names__c;
                cxlUpdate.Status__c = 'New';
                niCancellation = cxlUpdate;
            }
            else
            {
                saveError = 'ERROR: A renewal cancellation request exists already for this account. Please click Close button below then choose Edit command in Action column.';
                return;                         
            }                 
        }         
        
        showSaveError = false;
        
        // USER INPUT VALIDATION ( END ) ===========================================================

        
        // PASS USER INPUT VALUES
        niCancellation.Renewal_Cancellation_Quantity__c = iQuantityToCancel; 
        niCancellation.General_Reason__c = selGenReason; 
        
        if (selLateReason != 'CHOOSE ONE')
        {
            niCancellation.Late_Cancellation_Reason__c = selLateReason;
        }
        
        niCancellation.Specific_User_Names__c = strSpecificUserNames;
        niCancellation.Renewal_Cancellation_Note__c = strRenewalCancellationNote;        
        
        // PASS USER INFORMATION
        niCancellation.Renewal_Cancellation_Requested__c = true;
        niCancellation.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
        niCancellation.Renewal_Cancellation_Requester__c = u.Id;
        niCancellation.Renewal_Cancellation_Requesters_IP__c = ipAddress;
        
        // ATTACH SELECTED ACCOUNT 
        if (isCxlForDiffAcct && (accIdTmp != null)) 
        {
            
            Account selAccount = [SELECT Id, Name, OwnerId, ParentId, Franchisor__c, Brand__c  
                                  FROM Account 
                                  WHERE Id =: accIdTmp];
            
            // GET OR CREATE A PARENT CANCELLATION RECORD AND ASSIGN ITS ID 
            niCancellation.Master_Cancellation_Record__c = getParentCxlId(a, aliEdit);
            
            niCancellation.Account__c = selAccount.Id;
            niCancellation.Account_Owner__c = selAccount.OwnerId;
            niCancellation.Management_Company__c = selAccount.ParentId;
            niCancellation.Franchisor__c = selAccount.Franchisor__c;
            niCancellation.Brand__c = selAccount.Brand__c;
            
        }    
        else
        {
            niCancellation.Cancellation_Notes__c = 'Account that user wants to cancel product on: ' + accKeyword;
        }

        // SET SELECTED CONTACT
        if (contactName != '' && isInternalUser)
        {
            niCancellation.Contact__c = contactId;
        }        
        
        // GET A LIST OF DEPLOYMENT INSTANCE RECORDS TO FIND A MATCH TO ATTEMPT TO SET THE DI ON THE CANCELLATION
        List<Asset> lstAsset = new List<Asset>([SELECT Id FROM Asset WHERE AccountId =: niCancellation.Account__c AND Product2Id =: aliEdit.Product__c]);
        
        if (lstAsset.size() == 1)
        {
            niCancellation.Deployment_Instance__c = lstAsset[0].Id;
        }
        else
        {
            niCancellation.DI_Not_Found__c = true;
        }

        string strErrorLog = errorStringBuilder(niCancellation);
        
        try
        {
            
            system.debug(' **** UPSERTING CANCELLATION FOR ' + niCancellation.Account__c + ' - ' + niCancellation);  
            
            upsert niCancellation;
            
            // LINK CHOOSEN FILES TO CANCELLATION
            saveFiles(niCancellation.Id);    
            
            // CLEAR ACCOUNT SEARCH RESULTS PICKLIST
            if (lstSearchResults != null)
            {
                lstSearchResults.clear();
            } 
            
            // RELOAD FORM TO REFRESH CANCELLATION GRID
            openForm();  
            
        }
        catch (Exception ex)
        {
            showSaveError = true;
            saveError = 'An error has occurred and has been logged with Amadeus Hospitality support. '; 
            NI_Error_Logger.WriteToLog('Error occurred on Line:' + ex.getLineNumber() + '\nError Message:' + ex.getMessage() + '\n\n' + strErrorLog, 'Neighborhood', 'AH_CancelRenewals', 'Upsert'); 
        }

        strSearchMsg = '';
        
        system.debug(' *** EXITING AH_CancelRenewals.saveChanges() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    

    public void saveCancellationEdit() 
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.saveCancellationEdit() - QUERIES ISSUED = ' + Limits.getQueries());
        
        niCancellation = [SELECT Id, Renewal_Cancellation_Quantity__c,  
//                          Renewal_Cancellation_Reason__c, 
                          General_Reason__c, 
                          Late_Cancellation_Reason__c, 
                          Renewal_Cancellation_Note__c, 
                          Specific_User_Names__c,                           
                          Renewal_Cancellation_Requested__c, 
                          Renewal_Cancellation_Request_DateTime__c, 
                          Renewal_Cancellation_Requester__c, 
                          Renewal_Cancellation_Requesters_IP__c                          
                          FROM NI_Cancellation__c 
                          WHERE Id =: lstCancellations[iCxlIndex].CancellationId];

        niCancellation.Renewal_Cancellation_Quantity__c = lstCancellations[iCxlIndex].CancellationQuantity;
//        niCancellation.Renewal_Cancellation_Reason__c = lstCancellations[iCxlIndex].CancellationReason;
        niCancellation.General_Reason__c = lstCancellations[iCxlIndex].GeneralReason;
        niCancellation.Late_Cancellation_Reason__c = lstCancellations[iCxlIndex].LateReason;
        niCancellation.Renewal_Cancellation_Note__c = lstCancellations[iCxlIndex].CancellationNote;
        niCancellation.Specific_User_Names__c = lstCancellations[iCxlIndex].SpecificUserNames;
        niCancellation.Renewal_Cancellation_Requested__c = true;
        niCancellation.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
        niCancellation.Renewal_Cancellation_Requester__c = u.Id;
        niCancellation.Renewal_Cancellation_Requesters_IP__c = ipAddress; 
        
        update niCancellation;

        displayViewCxl = false;
        
        // RELOAD FORM TO REFRESH CANCELLATION GRID
        openForm();        
        
        system.debug(' *** EXITING AH_CancelRenewals.saveCancellationEdit() - QUERIES ISSUED = ' + Limits.getQueries());

    }     
    
    public void cancelChanges() 
    { 
        
        system.debug(' *** ENTERING AH_CancelRenewals.cancelChanges() - QUERIES ISSUED = ' + Limits.getQueries());
        
        niCancellation = [SELECT Id, 
                          Renewal_Cancellation_Quantity__c,                          
                          Renewal_Cancellation_Requested__c, 
                          Renewal_Cancellation_Request_DateTime__c, 
                          Renewal_Cancellation_Requester__c, 
                          Renewal_Cancellation_Requesters_IP__c                          
                          FROM NI_Cancellation__c 
                          WHERE Id =: lstCancellations[iCxlIndex].CancellationId];
        
        // RECORD WHO MADE THIS REQUEST
        niCancellation.Renewal_Cancellation_Requested__c = true;
        niCancellation.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
        niCancellation.Renewal_Cancellation_Requester__c = u.Id;
        niCancellation.Renewal_Cancellation_Requesters_IP__c = ipAddress; 
        
        // UPDATE CANCELLATION TO MAKE IT INACTIVE
        niCancellation.Renewal_Cancellation_Quantity__c = 0;
        niCancellation.Status__c = 'User Error';
        niCancellation.Master_Cancellation_Record__c = null;
        
        update niCancellation;
        
        hideConfirmation();
        
        // RELOAD FORM TO REFRESH CANCELLATION GRID
        openForm();  
        
        system.debug(' *** EXITING AH_CancelRenewals.cancelChanges() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    

    // UTILITY FUNCTIONS & METHODS   
    private Id getParentCxlId(Account oAcc, Activity_Line_Item__c oAli)
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.getParentCxlId() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Id parentID = null;
        
        // LOOK FOR PARENT CANCELLATION
        List<NI_Cancellation__c> lstParentCancellation = new List<NI_Cancellation__c>([
             SELECT Id 
             FROM NI_Cancellation__c 
             WHERE Account__c =: oAcc.Id
             AND Activity_Line_Item__c =: oAli.Id
             LIMIT 1]); 
        
        if (lstParentCancellation.size() > 0)
        {
            parentID = (Id)lstParentCancellation[0].get('Id');
        }
        else
        {
            
            NI_Cancellation__c newCxl = new NI_Cancellation__c();
            
            newCxl.Renewal_Cancellation_Requested__c = true;
            newCxl.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
            newCxl.Renewal_Cancellation_Requester__c = u.Id;
            newCxl.Renewal_Cancellation_Requesters_IP__c = ipAddress;  
            
            newCxl.Status__c = 'New'; 
            
            newCxl.Account__c = oAcc.Id;
            newCxl.Account_Owner__c = oAcc.OwnerId;
            newCxl.Management_Company__c = oAcc.ParentId;
            newCxl.Franchisor__c = oAcc.Franchisor__c;
            newCxl.Brand__c = oAcc.Brand__c; 

            newCxl.Activity_Line_Item__c = oAli.Id;
            newCxl.Product2__c = aliEdit.Product__c;
            newCxl.Opportunity__c = aliEdit.Opportunity__c;
            newCxl.Renewal_Cancellation_Quantity__c = 0; 
            
            // COPY THE REQUIRED FIELDS TO THE PARENT TO AVOID VALIDATION RULE ERRORS 
//            newCxl.Renewal_Cancellation_Reason__c = niCancellation.Renewal_Cancellation_Reason__c;
            newCxl.General_Reason__c = niCancellation.General_Reason__c;
// ADD THIS TO PREVENT HEATHER'S VALIDATION RULE FROM BLOWING THIS UP
//          if (niCancellation.Renewal_Cancellation_Reason__c == 'User Reduction')
            if (niCancellation.General_Reason__c == 'User Reduction')
            {
                newCxl.Number_of_Users_Reduced__c = niCancellation.Renewal_Cancellation_Quantity__c;
            }            
            
            system.debug(' **** INSERTING CANCELLATION FOR ' + oAcc.Id + ' - ' + newCxl);  
            
            insert newCxl;
            
            parentID = newCxl.Id;
            
        }
        
        system.debug(' *** EXITING AH_CancelRenewals.getParentCxlId() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return parentID;
        
    }

    private boolean cxlHasChildCxls(Id CancellationId)
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.cxlHasChildCxls() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Boolean bHasChild = false;
        
        try
        {
            
            List<NI_Cancellation__c> lstCxl = new List<NI_Cancellation__c>([
                SELECT Id 
                FROM NI_Cancellation__c 
                WHERE Master_Cancellation_Record__c =: CancellationId]); 
            
            if (lstCxl.size() > 0)
            {
                bHasChild = true;
            }
            
        }
        catch (Exception e) {}
        
        system.debug(' *** EXITING AH_CancelRenewals.cxlHasChildCxls() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return bHasChild;
        
    }
    
    private boolean accountHasCxlForALI(Id AccountId, Id ActivityLineItemId)
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.accountHasCxlForALI() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Boolean bHasCxl = false;
        
        try
        {
            
            List<NI_Cancellation__c> lstCxl = new List<NI_Cancellation__c>([
                SELECT Id 
                FROM NI_Cancellation__c 
                WHERE Account__c =: AccountId 
                AND Status__c NOT IN ('Successfully Retained', 'Reactivated', 'User Error')
                AND Activity_Line_Item__c =: ActivityLineItemId]); 
            
            if (lstCxl.size() > 0)
            {
                bHasCxl = true;
            }
            
        }
        catch (Exception e) {}
        
        system.debug(' *** EXITING AH_CancelRenewals.accountHasCxlForALI() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return bHasCxl;
        
    }
    
    private boolean acctHasCxlForALIwZeroQty(Id AccountId, Id ActivityLineItemId)
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.acctHasCxlForALIwZeroQty() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Boolean bRetVal = true;
        
        try
        {
            
            List<NI_Cancellation__c> lstCxl = new List<NI_Cancellation__c>([
                SELECT Id, Renewal_Cancellation_Quantity__c  
                FROM NI_Cancellation__c 
                WHERE Account__c =: AccountId 
                AND Activity_Line_Item__c =: ActivityLineItemId
                AND Status__c NOT IN ('Successfully Retained', 'Reactivated', 'User Error')
                AND Renewal_Cancellation_Quantity__c > 0]); 
            
            if (lstCxl.size() > 0)
            {
                bRetVal = false;
            }
            
        }
        catch (Exception e) {}
        
        system.debug(' *** EXITING AH_CancelRenewals.acctHasCxlForALIwZeroQty() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return bRetVal;
        
    }    

    public void doSearch() 
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.doSearch() - QUERIES ISSUED = ' + Limits.getQueries());
        
        showSaveError = false;
        saveError = '';
        
        if (accKeyword == '')
        {
            return;
        }
        
        string accKeywordTemp = accKeyword;
        
        if ((accKeywordTemp == null) || (accKeywordTemp.trim() == ''))
        {
            strSearchMsg = 'No related account names found. Please search again.';
            msgColor = 'red';            
        }
        
        
        strSearchMsg = '';
        selAccId = '';
        integer i = 0;
        lstSearchResults = new List<SelectOption>(); 
        lstSearchResults.add(new SelectOption('CHOOSE ONE', 'CHOOSE ONE')); 
        String sName = '';
        msgColor = 'green';

        for (Account acc : [SELECT Id, Name 
                            FROM Account 
                            WHERE Type = 'Customer' 
                            AND Id IN : setAccountIds 
                            AND Id != : a.Id 
                            ORDER BY Name ASC])
        {
            sName = acc.Name;
            if (sName.toUpperCase().contains(accKeywordTemp.toUpperCase()))
            { 
                lstSearchResults.add(new SelectOption(acc.Id, acc.Name));
                i++;
            }
        }

        if (i == 0)
        {
            strSearchMsg = 'No related account names found. Please search again.';
            msgColor = 'red';
        } 
        else
        {
            if (i > 1)
            {
                strSearchMsg = string.valueOf(i) + ' accounts found containing: "' + accKeyword + '"';
            }            
        }
        
        // RESET KEYWORD
        accKeyword = '';
        bActiveSearch = true;
        
        system.debug(' *** EXITING AH_CancelRenewals.doSearch() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public void showSearch() 
    {    
        accKeyword = '';
        strSearchMsg = '';
        bActiveSearch = false;
    }
    
    private String errorStringBuilder(NI_Cancellation__c cxl)
    {
        
        String strErrorLogMsg = ''; 

        // BUILD ERROR LOG STRING
        strErrorLogMsg += '\nUser: ' + u.Name;
        strErrorLogMsg += '\nUser IP: ' + ipAddress;
        strErrorLogMsg += '\nError Time: ' + DateTime.now().format();
        strErrorLogMsg += '\nProduct: ' + cxl.Product__c;
        strErrorLogMsg += '\nOppty #: ' + cxl.Opportunity_Number__c;
        strErrorLogMsg += '\nReason: ' + selGenReason;
        strErrorLogMsg += '\nQuantity: ' + String.valueOf(iQuantityToCancel);
        strErrorLogMsg += '\nAcct Id: ' + selAccId;
        strErrorLogMsg += '\nUsers: ' + strSpecificUserNames;    
        strErrorLogMsg += '\nContact: ' + contactName;
        strErrorLogMsg += '\nNotes: ' + strRenewalCancellationNote;
        
        return strErrorLogMsg;
        
    }
    
    
    // MODAL DIALOG METHODS
    public void showCxlDialog() 
    {    
        bShowCxlDialog = true;
        isCxlForDiffAcct = false;
    }

    public void showCxlDialogForDiffAcct() 
    {    
        bShowCxlDialog = true;
        isCxlForDiffAcct = true;       
    }
    
    public void closeCxlDialog() 
    { 
        bShowCxlDialog = false;
        isCxlForDiffAcct = false;
        saveError = '';
        showSaveError = false;
    }    
    
    public PageReference closeEditCxl() 
    {
         
        PageReference pr = new PageReference('/apex/AH_CancelRenewals?acctid=' + a.Id);
        
        bShowCxlDialog = false;
        displayEditCxl = false;
        accKeyword = '';
        selAccId = '';
        saveError = null;
        showSaveError = false;

        if (lstSearchResults != null)
        {
            lstSearchResults.clear();
        }
        
        loadProducts();   
        pr.setRedirect(true);
        
        return pr;
        
    } 

    public void showCancellation() 
    {
        displayEditCxl = false;
        displayViewCxl = true; 
        displayConfirm = false; 
        // CONDITIONALLY DISPLAY RETRACT BUTTON. DO NOT ANT TO SHOW WHEN EDITING A CANCELLATION WITH CHILD CANCELLATIONS
        hasChildren = cxlHasChildCxls(lstCancellations[iCxlIndex].CancellationId);
    }   
    
    public void hideCancellation() 
    {
        displayEditCxl = true;
        displayViewCxl = false; 
        displayConfirm = false;       
    }     

    public void retractCancellation() 
    {    
        displayEditCxl = false;
        displayViewCxl = false; 
        displayConfirm = true; 
    }     

    public void showConfirmation() 
    {
        displayEditCxl = false;
        displayViewCxl = false; 
        displayConfirm = true;         
    }   
    
    public void hideConfirmation() 
    {        
        displayEditCxl = true;
        displayViewCxl = false; 
        displayConfirm = false;  
    }     

    public void showAttachFiles() 
    {        
        displayAttachFiles = true; 
    }    
    
    public void hideAttachFiles() 
    {        
        displayAttachFiles = false; 
    }        
    

    // FILE METHODS
    private void loadFiles(Id cancellationID) 
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.loadFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
        lstCVs.clear();
        
        Set<Id> setCDocIDs = new Set<Id>();
        for (ContentDocumentLink cl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: cancellationID])
        {
            setCDocIDs.add(cl.Id);
        }
        
        for (ContentVersion cv : [SELECT Id, Title, ContentDocumentId 
                                  FROM ContentVersion 
                                  WHERE ContentDocumentId IN (SELECT Id FROM ContentDocument WHERE Id IN : setCDocIDs)
                                  AND IsLatest = true
                                  ORDER BY Title ASC])
        {
            lstCVs.add(cv);
        }
        
        system.debug(' *** EXITING AH_CancelRenewals.loadFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    private void saveFiles(Id cancellationID) 
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.saveFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!lstCVs.isEmpty())
        {
            Set<Id> setCDocIds = new Set<Id>();
            for (ContentVersion cv : lstCVs)
            {
                setCDocIds.add(cv.ContentDocumentId);
            }
            
            List<ContentDocumentLink> lstCDLinkUpserts = new List<ContentDocumentLink>();
            
            for (ContentDocument cd: [SELECT Id FROM ContentDocument WHERE Id IN : setCDocIds])
            {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cd.Id;
                cdl.LinkedEntityId = cancellationID;
                cdl.ShareType = 'I';               
                lstCDLinkUpserts.add(cdl);
            }
            
            try
            {
                database.upsert(lstCDLinkUpserts);
            }
            catch (Exception ex)
            {
                system.debug('An Error occured when trying to delete ContentDocument records: LINE #' + ex.getLineNumber() + ' - ' + ex.getMessage());
            }
        }
        
        system.debug(' *** EXITING AH_CancelRenewals.saveFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    private void removeFiles() 
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.removeFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!lstCVs.isEmpty())
        {
            Set<Id> setCDocIds = new Set<Id>();
            for (ContentVersion cv : lstCVs)
            {
                setCDocIds.add(cv.ContentDocumentId);
            }
            List<ContentDocument> lstCDocuDeletes = new List<ContentDocument>([SELECT Id FROM ContentDocument WHERE Id IN : setCDocIds]);
            try
            {
                database.delete(lstCDocuDeletes);
            }
            catch (Exception ex)
            {
                system.debug('An Error occured when trying to delete ContentDocument records: LINE #' + ex.getLineNumber() + ' - ' + ex.getMessage());
            }
        }
        
        system.debug(' *** EXITING AH_CancelRenewals.removeFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void uploadFile() 
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.uploadFile() - QUERIES ISSUED = ' + Limits.getQueries());
        
        strFileMsg = '';
        
//        if (upFileBlob == null)
//        {
//            strFileMsg = 'No file chosen to add.';
//            return;
//        }
  
        try 
        {
            
            ContentVersion v = new ContentVersion();
            v.VersionData = upFileBlob;
            v.Title = upFileName;
            v.PathOnClient ='/' + upFileName;
            insert v;
            
            ContentVersion cv = [SELECT Id, Title, ContentDocumentId, ContentBodyId, ContentUrl, ContentLocation, IsLatest
                                 FROM ContentVersion 
                                 WHERE Id =: v.Id];   
            
            lstCVs.add(cv);
            
            upFileBlob = null;
            upFileName = null;
            upFileSize = null;
            strFileMsg = 'File added Successfully.';
            
        }
        catch (Exception ex)
        {
            strFileMsg = 'If this is the first attempt to attach a file please attach again. This is a known issue with the file upload component in Salesforce. Sorry for this inconvenience.';
        }
        
        system.debug(' *** EXITING AH_CancelRenewals.uploadFile() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
    
    public void deleteFile() 
    {
        
        system.debug(' *** ENTERING AH_CancelRenewals.deleteFile() - QUERIES ISSUED = ' + Limits.getQueries());
        
        for (Integer j = 0; j < lstCVs.size(); j++)
        {
            if (lstCVs[j].Id == delCVerId)
            {
                lstCVs.remove(j);
            }            
        }
        
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =: delCDocId];           
        delete cd;
        
        system.debug(' *** EXITING AH_CancelRenewals.deleteFile() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }


    // SORTING METHODS   
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
            {
                sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC';
            }
            else 
            {
                sortDirection = 'ASC';
            }
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
        {
            return 'ASC';
        }
        else
        {
            return sortDirection;
        }
    }
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }

    public PageReference sortData() 
    {
        string sortFullExp = sortExpression  + ' ' + sortDirection; 
        loadProducts();
        return null;
    }
    

    // INNER CLASSES
    public class activityLineItem
    {
        
        public Integer iIndex {get; set;} 
        public Id ActivityLineItemId {get; set;}
        public String ActivityLineItemName {get; set;}
        public String ProductName {get; set;}
        public String ProductSKU {get; set;}
        public String OpportunityNumber {get; set;}         
        public Date ContractStartDate {get; set;} 
        public Date ContractEndDate {get; set;} 
        public Date DeadlineDate {get; set;} 
        public Decimal QuantityContracted {get; set;} 
        public Decimal QuantityCancelled {get; set;} 
        public Decimal QuantityRemaining {get; set;} 
        public Boolean bUserChangeAllowed {get; set;} 
        public String strInternalEditLabel {get; set;}          // NICC-027192
        public String strInternalEditLabelStyle {get; set;}     // NICC-027192
        public String strToolTiptext {get; set;}                // NICC-TBD
        public Decimal OrderOfDelivery {get; set;}              // NICC-TBD
        
        public activityLineItem (
            Integer iIndex, 
            Id ActivityLineItemId, 
            String ActivityLineItemName, 
            String ProductName,
            String ProductSKU, 
            String OpportunityNumber,          
            Date ContractStartDate, 
            Date ContractEndDate,   
            Date DeadlineDate, 
            Decimal QuantityContracted, 
            Decimal QuantityCancelled,
            Decimal QuantityRemaining, 
            Boolean bUserChangeAllowed,
            String strInternalEditLabel,            // NICC-027192
            String strInternalEditLabelStyle,       // NICC-027192
            String strToolTiptext,                  // NICC-TBD
            Decimal OrderOfDelivery                 // NICC-TBD
        )
        {
            this.iIndex = iIndex; 
            this.ActivityLineItemId = ActivityLineItemId; 
            this.ActivityLineItemName = ActivityLineItemName; 
            this.ProductName = ProductName; 
            this.ProductSKU = ProductSKU; 
            this.OpportunityNumber = OpportunityNumber; 
            this.ContractStartDate = ContractStartDate; 
            this.ContractEndDate = ContractEndDate; 
            this.DeadlineDate = DeadlineDate;
            this.QuantityContracted = QuantityContracted; 
            this.QuantityCancelled = QuantityCancelled; 
            this.QuantityRemaining = QuantityRemaining; 
            this.bUserChangeAllowed = bUserChangeAllowed;   
            this.strInternalEditLabel = strInternalEditLabel;           // NICC-027192
            this.strInternalEditLabelStyle = strInternalEditLabelStyle; // NICC-027192
            this.strToolTiptext = strToolTiptext;                       // NICC-TBD
            this.OrderOfDelivery = OrderOfDelivery;                     // NICC-TBD
        }
        
    }   
    
    public class cancellationLineItem 
    {
        public Integer iIndex {get; set;} 
        public Id CancellationId {get; set;} 
        public Id ParentCancellationId {get; set;}  
        public String CancellationName {get; set;} 
        public Id ActivityLineItemId {get; set;}
        public String ActivityLineItemName {get; set;}
        public String ActivityLineItemSKU {get; set;}
        public Date ContractStartDate {get; set;} 
        public Date ContractEndDate {get; set;} 
        public Date DeadlineDate {get; set;} 
        public Decimal ContractedQuantity {get; set;} 
        public String ProductName {get; set;} 
        public String ProductLine {get; set;}
        public Boolean CancellationRequested {get; set;}  
        public Decimal CancellationQuantity {get; set;}
//        public String CancellationReason {get; set;} 
        public String GeneralReason {get; set;} 
        public String LateReason {get; set;} 
        public String CancellationNote {get; set;} 
        public DateTime CancellationRequestedDate {get; set;}
        public Id CancellationRequesterId {get; set;} 
        public String CancellationRequesterName {get; set;} 
        public Id OpportunityId {get; set;} 
        public String OpportunityNumber {get; set;} 
        public String AccountName {get; set;} 
        public String SpecificUserNames {get; set;} 
        public String CancellationStatus {get; set;} 
        public Boolean bUserChangeAllowed {get; set;} 
        
        public cancellationLineItem (
            Integer iIndex, 
            Id CancellationId, 
            Id ParentCancellationId, 
            String CancellationName, 
            Id ActivityLineItemId, 
            String ActivityLineItemName, 
            String ActivityLineItemSKU, 
            Date ContractStartDate, 
            Date ContractEndDate, 
            Date DeadlineDate, 
            Decimal ContractedQuantity, 
            String ProductName, 
            String ProductLine, 
            Boolean CancellationRequested,  
            Decimal CancellationQuantity, 
//            String CancellationReason, 
            String GeneralReason, 
            String LateReason, 
            String CancellationNote, 
            DateTime CancellationRequestedDate, 
            Id CancellationRequesterId, 
            String CancellationRequesterName, 
            Id OpportunityId, 
            String OpportunityNumber, 
            String AccountName,
            String SpecificUserNames, 
            String CancellationStatus, 
            Boolean bUserChangeAllowed
        )
        {
            this.iIndex = iIndex; 
            this.CancellationId = CancellationId; 
            this.ParentCancellationId = ParentCancellationId; 
            this.CancellationName = CancellationName; 
            this.ActivityLineItemId = ActivityLineItemId; 
            this.ActivityLineItemName = ActivityLineItemName; 
            this.ActivityLineItemSKU = ActivityLineItemSKU; 
            this.ContractStartDate = ContractStartDate; 
            this.ContractEndDate = ContractEndDate; 
            this.DeadlineDate = DeadlineDate;
            this.ContractedQuantity = ContractedQuantity; 
            this.ProductName = ProductName; 
            this.ProductLine = ProductLine; 
            this.CancellationRequested = CancellationRequested; 
            this.CancellationQuantity = CancellationQuantity; 
//            this.CancellationReason = CancellationReason; 
            this.GeneralReason = GeneralReason;
            this.LateReason = LateReason; 
            this.CancellationNote = CancellationNote; 
            this.CancellationRequestedDate = CancellationRequestedDate; 
            this.CancellationRequesterId = CancellationRequesterId; 
            this.CancellationRequesterName = CancellationRequesterName; 
            this.OpportunityId = OpportunityId; 
            this.OpportunityNumber = OpportunityNumber; 
            this.AccountName = AccountName; 
            this.SpecificUserNames = SpecificUserNames; 
            this.CancellationStatus = CancellationStatus;
            this.bUserChangeAllowed = bUserChangeAllowed; 
        }
        
    }

    
}