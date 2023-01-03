/************************************************************************************************
Name            : NI_Org_Details_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 7/16/2013
Last Mod Date   : 2/24/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_Org_Details__c Object
: 
: 
*************************************************************************************************/
public class NI_Org_Details_TriggerHandler 
{
    
    private boolean m_isExecuting = false;
    
    
    public NI_Org_Details_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }
    
    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }
    
    //public void OnBeforeInsert(List<NI_Org_Details__c> newTrigger)
    //{
    
    //}
    
    //public void OnBeforeUpdate(List<NI_Org_Details__c> newTrigger)
    //{
    
    //}
    
    //public void OnBeforeDelete(List<NI_Org_Details__c> newTrigger)
    //{
    
    //}    
    
    public void OnAfterInsert(List<NI_Org_Details__c> newTrigger)
    {
        NIOrgDetailsToAccounts(newTrigger);
       // NIOrgDetailsCreateAudit(newTrigger);
    }
    
    public void OnAfterUpdate(List<NI_Org_Details__c> newTrigger, Map<Id,NI_Org_Details__c> OldMapOrgDetails)
    {   
        system.debug('newTrigger' + newTrigger);
        system.debug('OldMapOrgDetails' + OldMapOrgDetails);
		system.debug('in AfterUpdate');
		NIOrgDetailsUpdateAudit(newTrigger, OldMapOrgDetails);        
    } 
    
    //public void OnAfterDelete(List<NI_Org_Details__c> newTrigger)
    //{
    
    //}
    
    //public void OnAfterUnDelete(List<NI_Org_Details__c> newTrigger)
    //{
    
    //}     
    
    /****************************************************************************************
    Name            : NIOrgDetailsToAccounts
    Author          : Sean Harris
    Created Date    : 07/10/2012
    Last Mod Date   : 07/16/2013
    Last Mod By     : Stuart Emery
    NICC Reference  : NICC-005291 - https://c.na4.visual.force.com/apex/ni_change_control_tabbed_layout?id=a0s60000003oX6NAAU
    Description     : Creates junction object record when new Org Details record is inserted
    : 
    : 
    ******************************************************************************************/
    public void NIOrgDetailsToAccounts(List<NI_Org_Details__c> newTrigger)
    {
        
        List<NI_Org_Details_to_Accounts__c> lstToInsert = new List<NI_Org_Details_to_Accounts__c>();
        
        //SET TO HOLD THE ACCOUNTID OF THE NI ORG DETAILS RECORD
        Set<Id> setAccountIds = new Set<Id>();  
        
        //MAP TO HOLD THE PARENT ACCOUNTID AND THE ORG ID
        Map<Id,String> mapAccountOrgId = new Map<Id,String>();  
        
        //LIST OF CHANNEL_ORDERS__Customer__c TO INSERT   
        List<CHANNEL_ORDERS__Customer__c> lstCustomersToInsert = new List<CHANNEL_ORDERS__Customer__c>(); 
        
        // TARGETED RECORD TYPES - NICC-011686
        RecordType rtHRM = [SELECT Name, Id FROM RecordType WHERE sObjectType =: 'NI_Org_Details__c' AND Name =: 'HRM Support Admin'];
        RecordType rtLOD = [SELECT Name, Id FROM RecordType WHERE sObjectType =: 'NI_Org_Details__c' AND Name =: 'LOD Support Admin'];
        
        for (NI_Org_Details__c d : newTrigger) 
        {
            if (d.ParentAccountId__c != null)
            {
                lstToInsert.add(new NI_Org_Details_to_Accounts__c(AccountID__c = d.ParentAccountId__c, NIOrgDetailsID__c = d.Id));
                // NICC-011686
                if ((d.RecordTypeId == rtHRM.Id) || (d.RecordTypeId == rtLOD.Id))
                {
                    setAccountIds.add(d.ParentAccountId__c);
                }
                
                mapAccountOrgId.put(d.ParentAccountId__c, d.Org_ID__c);
//                System.debug('MAP ACCOUNTORGID: ' + d.ParentAccountId__c + ', ' + d.Org_ID__c);
//                System.debug(d.Org_ID__c);
//                System.debug(mapAccountOrgId.get(d.ParentAccountId__c));   
            }
        }   
//        System.debug('MAP ACCOUNTORGID SIZE: ' + mapAccountOrgId.size());
        Database.insert(lstToInsert);

        //LIST TO HOLD THE ACCOUNT INFORMATION TO BE USED IN CREATING CHANNEL ORDER CUSTOMER RECORDS   
        List<Account> lstOrgDetailAccounts = [SELECT Id, Name, BillingCity, BillingCountry, BillingState, BillingStreet, BillingPostalCode 
                                              FROM Account 
                                              WHERE Id IN :setAccountIds];   
        
        //LOOP THROUGH THE lstOrgDetailAccounts AND BUILD THE LIST OF CHANNEL ORDER CUSTOMERS TO INSERT
        for (Account a : lstOrgDetailAccounts)
        {
            CHANNEL_ORDERS__Customer__c customerRecord = new CHANNEL_ORDERS__Customer__c(); 
            
            customerRecord.CHANNEL_ORDERS__Customer_Company_Name__c = a.Name; 
            customerRecord.CHANNEL_ORDERS__Customer_City__c = a.BillingCity; 
            customerRecord.CHANNEL_ORDERS__Customer_Country__c = a.BillingCountry; 
            customerRecord.CHANNEL_ORDERS__Customer_Org_ID__c = mapAccountOrgId.get(a.Id); 
//            System.debug('Map Id: ' + mapAccountOrgId.get(a.Id));  
            customerRecord.CHANNEL_ORDERS__Customer_State__c = a.BillingState; 
            customerRecord.CHANNEL_ORDERS__Customer_Street__c = a.BillingStreet; 
            customerRecord.CHANNEL_ORDERS__Customer_ZIP_Postal_Code__c = a.BillingPostalCode; 
            lstCustomersToInsert.add(customerRecord); 
        }
        Database.insert(lstCustomersToInsert); 
    }
    
    public void NIOrgDetailsUpdateAudit(List<NI_Org_Details__c> newTrigger, Map<Id,NI_Org_Details__c> OldMapOrgDetails)
    {
        system.debug('  entering NIOrgDetailsUpdateAudit ...');
// START - SHarris
        Set<Id> setOrgDetIds = new Set<Id>();
        for (NI_Org_Details__c od : newTrigger)
        {
            setOrgDetIds.Add(od.Id);
        }
        List<Compliance_Audit__c> ListAuditComplaintCompare = new List<Compliance_Audit__c>(
            [SELECT Id, Customer_Org__c, CreatedDate, Original_Status__c, Current_Status__c, Product_Line__c, Related_Attributes__c  
             FROM Compliance_Audit__c
             WHERE CreatedDate = TODAY 
             AND Customer_Org__c IN : setOrgDetIds]
        );
// END - SHarris
        List<Compliance_Audit__c> ListAuditComplaint = new List<Compliance_Audit__c>();
        NI_Org_Details__c oldOrg;
        
        
        for(NI_Org_Details__c objOrgDetails : newTrigger)
        {
            //get the value of old NI_Org_Details__c from oldMapTrigger 
            oldOrg = OldMapOrgDetails.get(objOrgDetails.id);
            //check if any one of the following field is updated
            if((oldOrg.License_Type_Compliant__c != objOrgDetails.License_Type_Compliant__c) 
               || (oldOrg.Data_Storage_Compliant__c != objOrgDetails.Data_Storage_Compliant__c)
               || (oldOrg.File_Storage_Compliant__c != objOrgDetails.File_Storage_Compliant__c)
               || (oldOrg.Limited_Users_Compliant__c != objOrgDetails.Limited_Users_Compliant__c))
            {
                //check if the old value was true and new value is false
                if((oldOrg.File_Storage_Compliant__c == true && objOrgDetails.File_Storage_Compliant__c == false)||
                   (oldOrg.License_Type_Compliant__c == true && objOrgDetails.License_Type_Compliant__c == false)||
                   (oldOrg.Limited_Users_Compliant__c == true && objOrgDetails.Limited_Users_Compliant__c == false)||
                   (oldOrg.Data_Storage_Compliant__c == true && objOrgDetails.Data_Storage_Compliant__c == false))
                {

                    //create new Compliance_Audit__c object and set values
                    Compliance_Audit__c objCompliance = new Compliance_Audit__c();   
                    
// START - SHarris  
                    for (Compliance_Audit__c lstCompare : ListAuditComplaintCompare)
                    {
                        if (lstCompare.Customer_Org__c == objOrgDetails.Id)
                        {
                            objCompliance = lstCompare;
                            break;             
                        }
                    }
// END - SHarris
                    objCompliance.Customer_Org__c = objOrgDetails.Id;
                    objCompliance.Original_Status__c = 'Compliant';
                    objCompliance.Current_Status__c ='Non Compliant';
                    objCompliance.Product_Line__c= 'Delphi.fdc';
                    String str = '';
                    if(oldOrg.License_Type_Compliant__c == true && objOrgDetails.License_Type_Compliant__c == false){
                        str += 'License Type; ';
                    }
                    if(oldOrg.Limited_Users_Compliant__c == true && objOrgDetails.Limited_Users_Compliant__c == false){
                        str += 'Limited User; ';
                    }
                    if(oldOrg.Data_Storage_Compliant__c == true && objOrgDetails.Data_Storage_Compliant__c == false){
                        str += 'Data Storage; ';
                    }
                    if(oldOrg.File_Storage_Compliant__c == true && objOrgDetails.File_Storage_Compliant__c == false){
                        str += 'File Storage; ';
                    }
                    str = str.removeEnd('; ');
                    objCompliance.Related_Attributes__c = str;
                    ListAuditComplaint.add(objCompliance);    
                }
                
                                    
                
                //check if old value was false and new value is true
                if((oldOrg.File_Storage_Compliant__c == false && objOrgDetails.File_Storage_Compliant__c == True)||
                   (oldOrg.License_Type_Compliant__c == false && objOrgDetails.License_Type_Compliant__c == True)||
                   (oldOrg.Data_Storage_Compliant__c == false && objOrgDetails.Data_Storage_Compliant__c == True)||
                   (oldOrg.Limited_Users_Compliant__c == false && objOrgDetails.Limited_Users_Compliant__c == True))
                {
                    
                    //create new Compliance_Audit__c object and set values
                    Compliance_Audit__c objCompliance = new Compliance_Audit__c();   
                    
// START - SHarris  
                    for (Compliance_Audit__c lstCompare : ListAuditComplaintCompare)
                    {
                        if (lstCompare.Customer_Org__c == objOrgDetails.Id)
                        {
                            objCompliance = lstCompare;
                            break;             
                        }
                    }
// END - SHarris          
                    objCompliance.Customer_Org__c = objOrgDetails.Id;
                    objCompliance.Original_Status__c = 'Non Compliant';
                    objCompliance.Current_Status__c ='Compliant';
                    objCompliance.Product_Line__c= 'Delphi.fdc';
                    String str = '';
                    if(oldOrg.File_Storage_Compliant__c == false && objOrgDetails.File_Storage_Compliant__c == true){
                        str += 'File Storage; ';
                    }
                    if(oldOrg.License_Type_Compliant__c == false && objOrgDetails.License_Type_Compliant__c == true){
                        str += 'License Type; ';
                    }
                    if(oldOrg.Data_Storage_Compliant__c == false && objOrgDetails.Data_Storage_Compliant__c == true){
                        str += 'Data Storage; ';
                    }
                    if(oldOrg.Limited_Users_Compliant__c == false && objOrgDetails.Limited_Users_Compliant__c == true){
                        str += 'Limited User; ';
                    }
                    str = str.removeEnd('; ');
                    //system.debug('str'+str);
                    objCompliance.Related_Attributes__c = str;
                    ListAuditComplaint.add(objCompliance); 
                }                
            }
        }
        
        if(ListAuditComplaint.size()>0){
// START - SHarris               
//            insert ListAuditComplaint;            
            upsert ListAuditComplaint; 
// END - SHarris            
        }
    }
    
 }