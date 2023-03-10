/****************************************************************************************
Name            : billingContractVSOEController
Author          : CLD
Created Date    : 07/22/2016
Last Mod Date   : 06/05/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
******************************************************************************************/
public class billingContractVSOEController 
{
    
    public Billing_Contract__c billingContract {get; set;}
    public List<activityLineModel> activitylineItems {get; set;}
    public List<activityLineModel> undefinedLines {get; set;}
    public List<activityLineModel> softwareLines {get; set;}
    public List<activityLineModel> nonsoftwareLines {get; set;}
    public List<activityLineModel> pcsLines {get; set;}
    public Boolean renderUndefined {get; set;}
    public Boolean renderSoftware {get; set;}
    public Boolean renderNonSoftware {get; set;}
    public Decimal softwareElementTotal {get; set;}
    public Decimal nonsoftwareElementTotal {get; set;}
    public Decimal totalFV_nonSoftwareCategory {get; set;}
    public Decimal totalFV_Software {get; set;}
    public Decimal totalFV_Support {get; set;}
    public Decimal totalFV {get; set;}
    public Decimal totalAdjustedRev {get; set;}
    public Decimal totalAdjustedRev_HostingSupport {get; set;}
    public Decimal totalAdjustedRev_Services {get; set;}
    public Decimal totalAdjustedRev_Subscription {get; set;}
    public Decimal totalAdjustedRev_Software {get; set;}
    public Decimal totalAdjustedRev_Support {get; set;}
    public Decimal totalFV_PCS {get; set;}
    public Decimal residualAmount {get; set;}
    public Boolean disablePage {get; set;}
    public Boolean disableFinalize {get; set;}
    public Boolean disablePCS {get; set;}
    public String baseURL {get; set;}
    
    
    public billingContractVSOEController(ApexPages.StandardController controller) 
    {
        this.billingContract = (Billing_Contract__c)controller.getRecord(); 
        loadLineItems();
    }
    
    public void loadLineItems()
    {
        activitylineItems = new List<activityLineModel>();
        undefinedLines = new List<activityLineModel>();
        softwareLines = new List<activityLineModel>();
        nonsoftwareLines = new List<activityLineModel>();
        pcsLines = new List<activityLineModel>();
        renderUndefined = false;
        renderSoftware = false;
        renderNonSoftware = false;
        softwareElementTotal = 0;
        nonsoftwareElementTotal = 0;
        totalAdjustedRev = 0;
        totalAdjustedRev_HostingSupport = 0;
        totalAdjustedRev_Services = 0;
        totalAdjustedRev_Subscription = 0;
        totalAdjustedRev_Software = 0;
        totalAdjustedRev_Support = 0;
        totalFV_nonSoftwareCategory = 0;
        totalFV_Software = 0;
        totalFV_PCS = 0;
        residualAmount = 0;
        totalFV = 0;
        totalFV_Support = 0;
        disablePage = false;    	
        disableFinalize = false;    	
        
        billingContract = [SELECT Id, Opportunity__c, Agreement__c, VSOE_Calculation_Status__c, VSOE_Calculation_Notes__c 
                           FROM Billing_Contract__c 
                           WHERE Id = : billingContract.Id];  	
        
        for(Activity_Line_Item__c ali : [
            SELECT Activity_Project_Billing__c,
            Billing_Contract__c,
            Billing_Contract__r.VSOE_Calculation_Status__c,
            Contract_Amount__c,
            Contract_End_Date__c,
            Contract_Start_Date__c,
            Contract_Total_Amount__c,
            CreatedById,
            CreatedDate,
            Final_SW_Group_Allocation__c,
            CurrencyIsoCode,
            Fair_Value__c,
            PCS_Days__c,
            Id,
            Activation_Date__c,
            VSOE_Element_Type__c,
            Activation_Required__c,
            IsDeleted,
            LastActivityDate,
            LastModifiedById,
            LastModifiedDate,
            List_Price__c,
            PCS_Notes__c,
            PSA_Milestone__c,
            Revenue_Category__c,
            Post_Contract_Support__c,
            Include_in_Revenue_Recognition__c,
            Name,
            Percent_of_Total__c,
            Product__c,
            Product_Description__c,
            Relative_Selling_Price_Allocation__c,
            Revenue_Recognized_to_Date__c,
            Service_Discount__c,
            Adjusted_Revenue_Amount__c,
            SKU__c,
            Software_Discount__c,
            VSOE_Discount__c,
            SystemModstamp,
            Units__c,
            VSOE_Pricing_Item__c 
            FROM Activity_Line_Item__c
            WHERE Billing_Contract__c = :billingContract.Id])
        {
            activityLineModel a = new activityLineModel();
            a.ali_object = ali;
            activitylineItems.add(a);
            
            totalFV += ali.Fair_Value__c;
            totalAdjustedRev += ali.Relative_Selling_Price_Allocation__c;
            totalAdjustedRev_HostingSupport += ali.Revenue_Category__c == 'Hosting and Support' ? ali.Relative_Selling_Price_Allocation__c : 0;
            totalAdjustedRev_Services += ali.Revenue_Category__c == 'Services' ? ali.Relative_Selling_Price_Allocation__c : 0;
            totalAdjustedRev_Subscription += ali.Revenue_Category__c == 'Subscription' ? ali.Relative_Selling_Price_Allocation__c : 0;
            totalAdjustedRev_Software += ali.Revenue_Category__c == 'Software' ? ali.Relative_Selling_Price_Allocation__c : 0;
            totalAdjustedRev_Support += ali.Revenue_Category__c == 'Support' ? ali.Relative_Selling_Price_Allocation__c : 0;
            
            if (ali.VSOE_Element_Type__c == 'Software')
            {
                
                softwareElementTotal += (ali.Relative_Selling_Price_Allocation__c);
                
                if (ali.Revenue_Category__c != 'Software')
                {
                    totalFV_nonSoftwareCategory += ali.Fair_Value__c;
                }
                
                if (ali.Revenue_Category__c == 'Software')
                {
                    totalFV_Software += ali.Fair_Value__c;
                }
                
                if (ali.Revenue_Category__c == 'Support')
                {
                    if (ali.Post_Contract_Support__c == false)
                    {
                        totalFV_Support += ali.Fair_Value__c;    
                    }                    
                }
                
                if (ali.Post_Contract_Support__c == true)
                {
                    pcsLines.add(a);
                    disablePCS = true;
                    totalFV_PCS += ali.Fair_Value__c;
                }
                else
                {
                    softwareLines.add(a);
                }
                
                renderSoftware = true;
                
            }
            
            if (ali.VSOE_Element_Type__c == 'Non-Software')
            {
                nonsoftwareLines.add(a);
                nonsoftwareElementTotal += (ali.Relative_Selling_Price_Allocation__c);
                renderNonSoftware = true;
            }
            
            if (ali.VSOE_Element_Type__c == null)
            {
                undefinedLines.add(a);
                renderUndefined = true;
                disableFinalize = true;
            }
            
            if (billingContract.VSOE_Calculation_Status__c == 'Complete')
            {
                disablePage = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'VSOE Calculation Complete - click Back to return to the Billing Contract'));  
            }
            
        }
        
        residualAmount = softwareElementTotal - totalFV_nonSoftwareCategory;
        
        // loop through all the activity lines and calculate the vsoe discount and adjustment:
        for (activityLineModel a :activitylineItems)
        {
            
            Activity_Line_Item__c ali = a.ali_object;
            
            if (ali.VSOE_Element_Type__c == 'Software')
            {
                if (ali.Revenue_Category__c != 'Software')
                {
                    if (ali.Post_Contract_Support__c == true)
                    {
                        ali.VSOE_Adjustment__c = ali.Contract_Total_Amount__c - ali.Fair_Value__c;	
                    }
                    else
                    {
                        ali.VSOE_Adjustment__c = ali.Contract_Total_Amount__c - ali.Fair_Value__c;	
                    }
                }
                
                //enter residual method
                if (ali.Revenue_Category__c == 'Software')
                {
                    Decimal finalSWGroupAllocation = totalFV_Software != 0 ? (ali.Fair_Value__c / totalFV_Software)* residualAmount : 0;
                    ali.VSOE_Adjustment__c = ali.Contract_Total_Amount__c - finalSWGroupAllocation;
                }
                
            }
            
            if (ali.VSOE_Element_Type__c == 'Non-Software')
            {
                ali.VSOE_Adjustment__c = ali.Contract_Total_Amount__c - ali.Relative_Selling_Price_Allocation__c;
            }
            
        } 
        
    }
    
    public PageReference saveLines()
    {
        
        List<Activity_Line_Item__c> updateList = new List<Activity_Line_Item__c>();
        
        for (activityLineModel a : activitylineItems)
        {
            
            if (a.ali_object.Post_Contract_Support__c == true)
            {
                a.ali_object.VSOE_Adjustment__c = a.ali_object.Contract_Total_Amount__c - a.ali_object.Fair_Value__c;  
            }
            
            updateList.add(a.ali_object);
            
        }
        
        if (updateList.size() > 0)
        {
            try 
            {
                update updateList;
                update updateList;
                update billingContract;
                loadLineItems();
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Lines Saved!'));  
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage())); 
                return null; 
            }
            return null; 
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No Line Items Selected!'));  
            return null; 
        }
        
    }
    
    public PageReference refresh()
    {
        
        List<Activity_Line_Item__c> updateList = new List<Activity_Line_Item__c>();
        
        for (activityLineModel a : activitylineItems)
        {
            
            if (a.ali_object.Post_Contract_Support__c == true)
            {
                a.ali_object.VSOE_Adjustment__c = a.ali_object.Contract_Total_Amount__c - a.ali_object.Fair_Value__c;  
            }
            
            updateList.add(a.ali_object);
            
        }
        
        if (updateList.size()>0)
        {
            try 
            {
                update updateList;
                update updateList;
                loadLineItems();
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Amounts Refreshed!'));  
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage())); 
                return null; 
            }
            return null; 
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Line Items Selected!'));  
            return null; 
        }
        
    }
    
    public PageReference createPCSLine()
    {
        
        activityLineModel newModel = new activityLineModel();
        
        Activity_Line_Item__c newAli = new Activity_Line_Item__c(
            Billing_Contract__c = billingContract.id,
            Revenue_Category__c = 'Support',
            Opportunity__c = billingContract.Opportunity__c,
            Units__c = 1,
            VSOE_Element_Type__c = 'Software',
            VSOE_Adjustment__c = 0,
            Post_Contract_Support__c = true,
            PCS_Days__c = 60
        );
        
        newModel.ali_object = newAli;
        newModel.pcsAmount = 0;
        newAli.Contract_Amount__c = newModel.pcsAmount;
        newAli.List_Price__c = newModel.pcsAmount;
        activitylineItems.add(newModel);
        
        try
        {
            insert newAli;
            newModel.ali_object = newAli;
            loadLineItems();
            saveLines();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'PCS Line added'));  
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage())); 
            return null; 
        }
        
        return null; 
        
    }
    
    public PageReference finalizeVSOE()
    {
        
        List<Activity_Line_Item__c> updateList = new List<Activity_Line_Item__c>();
        billingContract.VSOE_Calculation_Status__c = 'Complete';
        
        for (activityLineModel b : activitylineItems)
        {
            updateList.add(b.ali_object);
        }
        
        try 
        {
            
            update updateList;
            update billingContract;
            disablePage = true;
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'VSOE Calculation Complete - click Back to return to the Billing Contract')); 
            
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage())); 
            return null; 
        }
        
        return null; 
        
    }
    
    public PageReference backToBC()
    {
        PageReference ref = new PageReference('/' + billingContract.Id); 
        return ref; 
    }
    
    public void addRow()
    {
        activityLineModel mod = new activityLineModel();
        mod.check = true;
        mod.ali_object.Billing_Contract__c = billingContract.id;
        activitylineItems.add(mod);
    }
    
    // WRAPPER CLASS
    public class activityLineModel
    {
        
        public Activity_Line_Item__c ali_object {get;set;}
        public boolean check {get;set;}
        public Boolean isServices {get;set;}
        public Decimal pcsAmount {get;set;}
        
        public activityLineModel()
        {
            ali_object = new Activity_Line_Item__c();
            check = true;
            pcsAmount = 0;
        }
    }
    
}