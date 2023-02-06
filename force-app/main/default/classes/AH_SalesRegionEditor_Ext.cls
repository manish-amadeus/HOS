/****************************************************************************************
Name            : AH_SalesRegionEditor_Ext Class
Author          : Sean Harris
Created Date    : 03/22/2017
Last Mod Date   : 03/22/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller Extension for the AH_SalesRegionEditor Visualforce page
                :              
******************************************************************************************/
public class AH_SalesRegionEditor_Ext 
{
   
    // LIST TO HOLD THE USER RECORDS  
    public List<User> lstUsers {get; set;}
    
    // STRING TO HOLD THE NAME OF THE USER 
    public String strName {get; set;}
    
    // STRING TO HOLD THE WILDCARD NAME OF THE USER FOR THE SEARCH 
    public String strNameSearch {get; set;}
    
    // USED TO CONDITIONALLY RENDER THE CANCEL BUTTON  
    public Boolean bShowCancel {get; set;}
    
    // USED TO CONDITIONALLY RENDER THE SAVE BUTTON  
    public Boolean bShowSave {get; set;}
    
    // USED TO CONDITIONALLY RENDER THE CLOSE BUTTON  
    public Boolean bShowClose {get; set;}
    
    // USED TO ENABLE OR DISABLE THE CANCEL CHECKBOX ON THE VF PAGE  
    public Boolean bDisabled {get; set;}
    
    // USED TO CONDITIONALLY RENDER THE searchPanelContainer OUTPUTPANEL  
    public Boolean showSearch {get; set;}
    
    // VARIABLE TO HOLD THE COUNT OF USER RECORDS DISPLAYED  
    public integer lstSize {get; set;}
    
    // USED TO FILTER USERS WITH MISSING ADP NUMBERS ON THE VF PAGE  
    public Boolean bMissingADP {get; set;}
    
    // LIST TO HOLD THE VALUES OF THE USER RECORDS BEFORE CHANGES ARE COMMITTED TO THE DATABASE
    List<objUserBeforeValues> lstUserBeforeValues = new List<objUserBeforeValues>();
    
    // LIST TO HOLD THE USER RECORDS TO UPDATE
    List<User> lstUsersToUpdate = new List<User>();
    
    // LIST TO HOLD THE NI USER HISTORY RECORDS TO INSERT
    List<NI_User_History__c> lstUserHistoryToInsert = new List<NI_User_History__c>();
    
    //
    public List<SelectOption> lstRegions {get; set;} 
    
    //
    //public string selRegion {get; set;} 
        

    public AH_SalesRegionEditor_Ext(ApexPages.StandardController stdController)
    { 
        //CALL THE DISABLELISTEDIT METHOD  
        disableListEdit();   
        
        lstRegions = new List<SelectOption>();
        Schema.DescribeFieldResult dfr2 = User.Sales_Region__c.getDescribe();
        lstRegions.add(new SelectOption('', ''));
        for (Schema.PicklistEntry plv2 : dfr2.getPicklistValues())
        {
            lstRegions.add(new SelectOption(plv2.getValue(), plv2.getLabel()));
        }

    }
    
    // DISABLE EDIT MODE  
    public void disableListEdit()
    {
        bDisabled = true;
        showSearch = true;
        //strName = null;
        getUsers();      
    }
    
    // ENABLE EDIT MODE  
    public void EnableListEdit()
    {
        bDisabled = false;
        showSearch = false;
        getUsers();        
    }
    
    // QUERY TO RETURN A LIST OF USER RECORDS
    public void getUsers() 
    {
        
        bShowCancel = false;
        bShowSave = false;
        bShowClose = true;
        lstSize = 0;
        lstUserBeforeValues.clear();
        lstUsersToUpdate.clear();
        lstUserHistoryToInsert.clear();
        //bMissingADP = true;  
        
        if (strName == null && (bMissingADP == false || bMissingADP == null))
        {                                                        
            lstUsers = [SELECT Name, Email, DepartmentCode__c, Sales_Region__c, IsActive, UserType
                        FROM User
                        WHERE UserType = 'Standard'
                        AND IsActive = true
                        AND Name LIKE 'a%' 
                        AND ProfileId IN ('00e30000000qF7tAAE', '00e30000000qF7jAAE', '00e30000000mGqrAAE', '00e3g000000kuSkAAI')
                        ORDER BY Name ASC];
            
            lstSize = lstUsers.size();
            
            if (lstUsers.size() > 0)
            {
                for (User usr : lstUsers)
                {
                    lstUserBeforeValues.add(new objUserBeforeValues(usr.Id, usr.Sales_Region__c));  
                }
            }
            
            return;// lstUsers;                                  
        }
        
        if (strName == null && bMissingADP == true)
        {
            lstUsers = [SELECT Name, Email, DepartmentCode__c, Sales_Region__c, IsActive, UserType
                        FROM User
                        WHERE UserType = 'Standard'
                        AND IsActive = true
                        AND ProfileId IN ('00e30000000qF7tAAE', '00e30000000qF7jAAE', '00e30000000mGqrAAE', '00e3g000000kuSkAAI')
                        AND Sales_Region__c = ''   
                        ORDER BY Name ASC];
            
            lstSize = lstUsers.size();
            
            if (lstUsers.size() > 0)
            {
                for (User usr : lstUsers)
                {
                    lstUserBeforeValues.add(new objUserBeforeValues(usr.Id, usr.Sales_Region__c));  
                }
            }
            
            return; // lstUsers;  
        }  
        
        if (strName != null && (bMissingADP == false || bMissingADP == null))
        {
            strNameSearch = '%' + strName + '%';                                   
            lstUsers = [SELECT Name, Email, DepartmentCode__c, Sales_Region__c, IsActive, UserType
                        FROM User
                        WHERE UserType = 'Standard'
                        AND IsActive = true 
                        AND ProfileId IN ('00e30000000qF7tAAE', '00e30000000qF7jAAE', '00e30000000mGqrAAE', '00e3g000000kuSkAAI')
                        AND Name LIKE :strNameSearch    
                        ORDER BY Name ASC];
            
            lstSize = lstUsers.size();
            
            if (lstUsers.size() > 0)
            {
                for (User usr : lstUsers)
                {
                    lstUserBeforeValues.add(new objUserBeforeValues(usr.Id, usr.Sales_Region__c));  
                }
            }
            
            return; // lstUsers;
            
        }
        
        if (strName != null && bMissingADP == true)
        {
            strNameSearch = '%' + strName + '%';
            lstUsers = [SELECT Name, Email, DepartmentCode__c, Sales_Region__c, IsActive, UserType
                        FROM User
                        WHERE UserType = 'Standard'
                        AND IsActive = true
                        AND ProfileId IN ('00e30000000qF7tAAE', '00e30000000qF7jAAE', '00e30000000mGqrAAE', '00e3g000000kuSkAAI')
                        AND Name LIKE :strNameSearch
                        AND Sales_Region__c = ''    
                        ORDER BY Name ASC];
            
            lstSize = lstUsers.size();
            
            if (lstUsers.size() > 0)
            {
                for (User usr : lstUsers)
                {
                    lstUserBeforeValues.add(new objUserBeforeValues(usr.Id, usr.Sales_Region__c));  
                }
            }
            
            return; //lstUsers;
            
        }      
         
    }         
    
    //CUSTOM SAVE METHOD
    public PageReference save() 
    {
        
        bShowCancel = false;
        bShowSave = false;
        bShowClose = true;
        showSearch = true;
        
        if (lstUsers.size() > 0)
        {
            for (User uNew : lstUsers)
            {
                for (objUserBeforeValues uOld : lstUserBeforeValues)
                {
                    if (uNew.Id == uOld.UserId && uNew.Sales_Region__c != uOld.strAdp)
                    {
                        System.debug('User to update Id:' + uNew.Id);
                        lstUsersToUpdate.add(uNew);
                        NI_User_History__c uh = new NI_User_History__c();
                        uh.User__c = uNew.Id;  
                        uh.Field_Name__c = 'Sales Region';
                        uh.Changed_From__c = uOld.strAdp;
                        uh.Changed_To__c = uNew.Sales_Region__c;
                        uh.Description__c = 'NI_SalesRegionEditor Visualforce Page used to update User records';
                        lstUserHistoryToInsert.add(uh);
                    }
                }
            } 
            
            if (lstUsersToUpdate.size()>0)    
            {
                //USE DATABASE DML METHOD TO UPDATE THE USER RECORDS
                integer intSuccess = 0;
                Database.SaveResult[] results = Database.update(lstUsersToUpdate,false);
                for (Database.SaveResult sr: results)
                {
                    if (!sr.isSuccess())
                    {
                        Database.Error err = sr.getErrors()[0];
                        System.debug(err.getMessage());
                        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage())); 
                    }
                    else
                    {
                        intSuccess += 1;
                        //Operation was successful, get the Id of the record that was processed
                        System.debug('Successfully Updated User Record. USER ID: ' + sr.getId());  
                    }
                }
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Total User Records Updated:  ' + intSuccess));
            }
            
            if (lstUserHistoryToInsert.size()>0)
            {
                //USE DATABASE DML METHOD TO INSERT THE USER HISTORY RECORDS
                Database.SaveResult[] results2 = Database.insert(lstUserHistoryToInsert, false);
                for (Database.SaveResult sr2: results2)
                {
                    if (!sr2.isSuccess())
                    {
                        Database.Error err = sr2.getErrors()[0];
                        System.debug(err.getMessage());
                    }
                    else
                    {
                        System.debug('Successfully Inserted User History Record. ID: ' + sr2.getId());  
                    }
                }
            }
        }  
        
        lstUsers = null; //SET THE LIST TO NULL SO A NEW LIST IS CREATED
        disableListEdit(); //CALL THE disableListEdit METHOD WHICH CALLS THE getUsers METHOD AND DISABLED EDIT MODE
        
        return null;
    }
    
    public PageReference search() 
    {        
        getUsers();
        return null;
    }
    
    //===========================================================================    
    
    //INNER CLASS TO HOLD THE OLD FIELD VALUES  
    public class objUserBeforeValues
    {
        public Id UserId { get; set; }
        public String strAdp { get; set; }
        
        public objUserBeforeValues(Id UserId, String strAdp) 
        {
            this.UserId = UserId;
            this.strAdp = strAdp;
        }    
    }    
    
}