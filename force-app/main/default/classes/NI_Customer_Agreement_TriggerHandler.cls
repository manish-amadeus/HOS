/************************************************************************************************
Name            : NI_Customer_Agreement_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 10/1/2015
Last Mod Date   : 12/28/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-015836
Description     : Class that handles all trigger code for the NI_Customer_Agreement__c Object
                :
*************************************************************************************************/
public class NI_Customer_Agreement_TriggerHandler {
    
    //public static boolean bRun = true;
    
    public NI_Customer_Agreement_TriggerHandler()
    {
        
    }
    
    //========================================================================================================================
    public void OnBeforeInsert(List<NI_Customer_Agreement__c> newTrigger)
    {
        Set_CustomVendorAgreementValues(newTrigger);
        Set_ServicesOnlyOrderField(newTrigger);
        Set_PercentageValues(newTrigger);
    }
    
    //===================================================================================================================    
    public void OnAfterUpdate(List<NI_Customer_Agreement__c> newTrigger, Map<Id,NI_Customer_Agreement__c> oldMapTrigger)
    {  
        //ONLY EXECUTE THE LOGIC ONCE
        System.debug('NI_TriggerManager.isFirstTimeCustAgreement: ' + NI_TriggerManager.isFirstTimeCustAgreement);
        if(NI_TriggerManager.isFirstTimeCustAgreement)
        {
            NI_TriggerManager.isFirstTimeCustAgreement = false;
            
            //CREATE LIST TO HOLD ALL RECORDS WHERE THE PREVIOUS INSTALL DATE IS NULL AND THE CURRENT INSTALL DATE IS NOT NULL
            List<NI_Customer_Agreement__c> lstPrevInstallDateNullAmortization = new List<NI_Customer_Agreement__c>();
            
            //CREATE LIST TO HOLD ALL RECORDS WHERE THE PREVIOUS INSTALL DATE IS NULL AND THE CURRENT INSTALL DATE IS NOT NULL
            //AND THE ROYALTY DISTRIBUTION TRIGGER IS "Installed" OR "Installed OR Receipt of Payment"
            List<NI_Customer_Agreement__c> lstPrevInstallDateNullRoyalty = new List<NI_Customer_Agreement__c>();
            
            //CREATE LIST TO HOLD ALL RECORDS WHERE THE AMOUNT RECEIVED IS GREATER THAN THE TOTAL PRICE
            //AND THE ROYALTY DISTRIBUTION TRIGGER IS "Receipt of Payment" OR "Installed AND Receipt of Payment"
            List<NI_Customer_Agreement__c> lstAmntReceivedGreaterThanTotalPrice = new List<NI_Customer_Agreement__c>();
            
            //CREATE LIST TO HOLD ALL RECORDS WHERE THE NEW INSTALL DATE DOESN'T MATCH THE OLD INSTALL DATE
            List<NI_Customer_Agreement__c> lstInstallDateChange = new List<NI_Customer_Agreement__c>();
            
            //CREATE LIST TO HOLD ALL RECORDS WHERE THE INSTALL DATE HAS BEEN SET TO A NULL VALUE
            List<NI_Customer_Agreement__c> lstInstallDateChangeToNull = new List<NI_Customer_Agreement__c>();
            
            //CREATE LIST TO HOLD ALL RECORDS WHERE THE PREVIOUS CANCELLATION DATE IS NULL AND THE CURRENT CANCELLATION DATE IS NOT NULL
            List<NI_Customer_Agreement__c> lstPrevCancelDateNullAmortization = new List<NI_Customer_Agreement__c>();
            
            for (NI_Customer_Agreement__c ca : newTrigger) 
            {
                NI_Customer_Agreement__c oldCA = oldMapTrigger.get(ca.Id);
                
                
                //LOGIC FOR UPDATING THE INSTALL DATE FIELD FROM A NULL TO A NON-NULL VALUE.
                //USED FOR AMORTIZATION DISTRIBUTION RECORD CREATION
                if (
                    (ca.Status__c == 'Active')
                    &&
                    (ca.Install_Date__c != null) && (oldCA.Install_Date__c == null))
                {
                    lstPrevInstallDateNullAmortization.add(ca);   
                }
  //========================================================================================================================================              
                //LOGIC FOR UPDATING THE INSTALL DATE FIELD FROM A NULL TO A NON-NULL VALUE
                //USED FOR ROYALTY DISTRIBUTION RECORD CREATION
                if (
                    (ca.Status__c == 'Active')
                    &&
                    (ca.Install_Date__c != null) && (oldCA.Install_Date__c == null) 
                    &&
                    ((ca.Royalty_Distribution_Trigger__c == 'Installed') || (ca.Royalty_Distribution_Trigger__c == 'Installed OR Receipt of Payment'))
                )
                {
                    lstPrevInstallDateNullRoyalty.add(ca);   
                }
 //==============================================================================================================================================               
                //LOGIC FOR AMOUNT RECEIVED GREATER THAN OR EQUAL TO TOTAL PRICE
                //USED FOR ROYALTY DISTRIBUTION RECORD CREATION
                if (
                    (ca.Status__c == 'Active')
                    &&
                    ((ca.Amount_Received__c >= ca.Sale_Price__c) && (ca.Amount_Received__c != oldCA.Amount_Received__c))
                    &&
                    ((ca.Royalty_Distribution_Trigger__c == 'Receipt of Payment') || ((ca.Install_Date__c != null) && (ca.Royalty_Distribution_Trigger__c == 'Installed AND Receipt of Payment')))
                )
                {
                    lstAmntReceivedGreaterThanTotalPrice.add(ca);   
                }

  //==============================================================================================================================================               
                //LOGIC FOR AMOUNT RECEIVED GREATER THAN OR EQUAL TO TOTAL PRICE
                //USED FOR ROYALTY DISTRIBUTION RECORD CREATION FOR 'Installed OR Receipt of Payment' 
                if (
                    (ca.Status__c == 'Active')
                    &&
                    ((ca.Amount_Received__c >= ca.Sale_Price__c) && (ca.Amount_Received__c != oldCA.Amount_Received__c))
                    &&
                    (ca.Royalty_Distribution_Trigger__c == 'Installed OR Receipt of Payment')
                )
                {
                    lstAmntReceivedGreaterThanTotalPrice.add(ca);   
                }               
 //======================================================================================================================================================               
                //LOGIC FOR INSTALL DATE CHANGES
                if (
                    (ca.Status__c == 'Active')
                    &&
                    ((ca.Install_Date__c != null) && (oldCA.Install_Date__c != null) && (ca.Install_Date__c != oldCA.Install_Date__c) && (ca.Manual_Override__c != true))
                    ||
                    ((ca.Install_Date__c != null) && (oldCA.Install_Date__c != null) && (oldCA.Manual_Override__c == true) && (ca.Manual_Override__c == false)))
                {
                    lstInstallDateChange.add(ca);
                }
 //=======================================================================================================================================================                
                //LOGIC FOR SETTING THE INSTALL DATE TO NULL
                if (
                    (ca.Status__c == 'Active')
                    &&
                    (ca.Install_Date__c == null) && (oldCA.Install_Date__c != null))
                {
                    lstInstallDateChangeToNull.add(ca);   
                }
  //======================================================================================================================================================              
                //LOGIC FOR UPDATING THE CANCELLATION DATE FIELD FROM A NULL TO A NON-NULL VALUE.
                //USED FOR NEGATIVE AMORTIZATION DISTRIBUTION RECORD CREATION
                if (
                    (ca.Cancellation_Date__c != null)
                    &&
                    (ca.Cancellation_Date__c != oldCA.Cancellation_Date__c)
                    )
                {
                    lstPrevCancelDateNullAmortization.add(ca);   
                }
            }      
  //======================================================================================================================================================          
            System.debug('NUMBER OF NEW INSTALL DATE RECORDS FOR AMORTIZATION CREATION: ' + lstPrevInstallDateNullAmortization.size());
            //CALL THE METHOD TO CREATE THE AMORTIZATION DISTRIBUTION RECORDS WHEN THE INSTALL DATE IS INITIALLY SET
            if (lstPrevInstallDateNullAmortization.size() > 0)
            {  
                Create_Amortization_Distribution_Records(lstPrevInstallDateNullAmortization,false);
            }
            
            System.debug('NUMBER OF NEW INSTALL DATE RECORDS FOR ROYALTY CREATION: ' + lstPrevInstallDateNullRoyalty.size());
            //CALL THE METHOD TO CREATE THE ROYALTY DISTRIBUTION RECORDS WHEN THE INSTALL DATE IS INITIALLY SET
            if (lstPrevInstallDateNullRoyalty.size() > 0)
            {  
                Create_Royalty_Distribution_Records(lstPrevInstallDateNullRoyalty,false);
            }
            
            System.debug('NUMBER OF AMOUNT PAID RECORDS FOR ROYALTY CREATION: ' + lstAmntReceivedGreaterThanTotalPrice.size());
            //CALL THE METHOD TO CREATE THE ROYALTY DISTRIBUTION RECORDS WHEN THE AMOUNT RECEIVED IS GREATER THAN THE TOTAL PRICE
            if (lstAmntReceivedGreaterThanTotalPrice.size() > 0)
            {  
                Create_Royalty_Distribution_Records_AmountReceived(lstAmntReceivedGreaterThanTotalPrice);
            }
            
            
            System.debug('NUMBER OF CHANGED INSTALL DATE RECORDS: ' + lstInstallDateChange.size());
            //CALL THE METHOD TO CREATE THE AMORTIZATION DISTRIBUTION RECORDS WHEN THE INSTALL DATE IS CHANGED
            if (lstInstallDateChange.size() > 0)
            {  
                Create_Amortization_Distribution_Records(lstInstallDateChange,false);
                Create_Royalty_Distribution_Records(lstInstallDateChange,true);
            }
            
            System.debug('NUMBER OF INSTALL DATE CHANGED TO NULL RECORDS: ' + lstInstallDateChangeToNull.size());
            //CALL THE METHOD TO CREATE THE AMORTIZATION DISTRIBUTION RECORDS WHEN THE INSTALL DATE IS CHANGED TO A NULL VALUE
            if (lstInstallDateChangeToNull.size() > 0)
            {  
                Create_Amortization_Distribution_Records(lstInstallDateChangeToNull,false);
                Create_Royalty_Distribution_Records(lstInstallDateChangeToNull,true);
            }
            
            System.debug('NUMBER OF NEW CANCELLATION DATE RECORDS FOR AMORTIZATION CREATION: ' + lstPrevCancelDateNullAmortization.size());
            //CALL THE METHOD TO CREATE THE NEGATIVE AMORTIZATION DISTRIBUTION RECORDS WHEN THE CANCELLATION DATE IS INITIALLY SET
            if (lstPrevCancelDateNullAmortization.size() > 0)
            {  
                Amortization_Distribution_Cancellations(lstPrevCancelDateNullAmortization);
                Royalty_Distribution_Cancellations(lstPrevCancelDateNullAmortization);
            }
            
        }        
    }  
    //====================================================================================================================
    public void Create_Amortization_Distribution_Records(List<NI_Customer_Agreement__c> newTrigger, Boolean bInvoice)
    {          
        System.debug(' *** ENTERING NI_Customer_Agreement_TriggerHandler.Create_Amortization_Distribution_Records()');
        
        //DECLARE VARIABLES
        Date dtDistributionDate; //VARIABLE TO HOLD THE DISTRIBUTION DATE
        Date dtToday = Date.today(); //VARIABLE TO HOLD THE CURRENT DATE
        Integer intTerm;
        Integer monthDiff;
        decimal clsdAmount;
        
        //GET RECORDTYPE ID FOR THE "AMORTIZATION" RECORD TYPE ON THE DISTRIBUTION OBJECT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.NI_Distribution__c; 
        Map<String, Schema.RecordTypeInfo> DistributionRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtAmortizationId = DistributionRecordTypeInfo.get('Amortization').getRecordTypeId();
        
        //LIST OF UPDATED CUSTOMER AGREEMENT RECORDS TO USE FOR DISTRIBUTION RECORD CREATION
        List<NI_Customer_Agreement__c> lstCustomerAgreements = [SELECT Id, Account__c,Account__r.Franchisor__c,Account__r.ParentId,Sale_Price__c,Product_Family__c,
                                                                Account__r.Territory__c,Deployment_Instance__c,Opportunity__c,Install_Date__c,Amortization_Term__c,
                                                                Royalty_Base_Amount__c,Royalty_Percentage__c, Minimum_Royalty__c, General_Ledger_Credit_Account__c,
                                                                General_Ledger_Debit_Account__c
                                                                FROM NI_Customer_Agreement__c
                                                                WHERE Id IN: newTrigger
                                                                AND Manual_Override__c != true];
        
        //System.debug('NUMBER OF CUSTOMER AGREEMENT RECORDS FOR AMORTIZATION DISTRIBUTION CREATION: ' + lstCustomerAgreements.size());
        
        
        //LIST OF DISTRIBUTION RECORDS TO INSERT   
        List<NI_Distribution__c> lstDistributionsToInsert = new List<NI_Distribution__c>();
        
        //LIST OF INVOICE DETAIL RECORDS RELATED TO CUSOTMER AGREEMENT RECORDS THAT HAVE A STATUS OF "RENEWAL"
        List<NI_Invoice_Detail__c> lstInvoiceDetailRecords = [SELECT Id, Billing_End_Date__c, Billing_Start_Date__c,Customer_Agreement__c, 
                                                              Customer_Agreement__r.Status__c,Total_Price__c, NI_Invoice__c, NI_Invoice__r.Invoice_Number__c,
                                                              NI_Invoice__r.Date__c,NI_Invoice__r.Paid_Amount__c, NI_Invoice__r.Paid_Date__c
                                                              FROM NI_Invoice_Detail__c
                                                              WHERE Customer_Agreement__c IN: newTrigger
                                                              AND Customer_Agreement__r.Status__c = 'Renewal'
                                                              AND Customer_Agreement__r.Manual_Override__c != true];
        
        System.debug('INVOICE DETAIL RECORDS RELATED TO CUSOTMER AGREEMENT RECORDS: ' + lstInvoiceDetailRecords.size());

//================LOGIC FOR AMORTIZATION RECORDS THAT ARE NOT CREATED FROM INVOICE RECORDS=============================================================        
        if (bInvoice == false)
        {    
            //LIST OF CLOSED DISTRIBTION RECORDS
            List<NI_Distribution__c> lstClosedDistributions = new List<NI_Distribution__c>([
                SELECT Id, Customer_Agreement__c, Amount__c 
                FROM NI_Distribution__c 
                WHERE RecordType.Name = 'Amortization'
                AND Customer_Agreement__c IN : newTrigger
                AND Status__c = 'Closed'
            ]);
            
            
            //LIST OF DISTRIBTION RECORD THAT NEED TO BE DELETED
            List<NI_Distribution__c> lstDistributionsToDelete = new List<NI_Distribution__c>([
                SELECT Id, Amount__c 
                FROM NI_Distribution__c 
                WHERE RecordType.Name = 'Amortization'
                AND Customer_Agreement__c IN : newTrigger
                AND Status__c = 'Pending'
            ]);
            
            System.debug('NUMBER OF DISTRIBUTION RECORDS TO DELETE: ' + lstDistributionsToDelete.size());
            
            // BULK DELETE RECORDS
            if (lstDistributionsToDelete.size() > 0)
            {
                Database.DeleteResult[] drList = Database.delete(lstDistributionsToDelete, false);
                for (Database.DeleteResult dr : drList) 
                {
                    if (dr.isSuccess()) 
                    {
                        //System.debug('**SUCCESSFULLY DELETED DISTRIBUTION RECORD ID: ' + dr.getId());
                    }
                    else 
                    {
                        Database.Error err = dr.getErrors()[0];
                        System.debug(err.getMessage());
                    }
                }        
            }     
            
            for (NI_Customer_Agreement__c ca : lstCustomerAgreements)
            {
                //LOOP THROUGH THE CLOSED DISTRIBUTION RECORDS AND CREATE A SINGLE DISTRIBUTION RECORD WITH A NEGATIVE AMOUNT OF ALL OF THE 
                //CLOSED DISTRIBUTION RECORDS
                if(lstClosedDistributions.size()>0)
                {
                    clsdAmount = 0;
                    for (NI_Distribution__c closedDist : lstClosedDistributions)
                    {
                        if(ca.Id == closedDist.Customer_Agreement__c)
                        {
                            clsdAmount = clsdAmount + closedDist.Amount__c;  
                        }  
                    }
                    NI_Distribution__c d2 = new NI_Distribution__c();
                    
                    d2.Amount__c = clsdAmount * -1;  
                    d2.Account_Name__c = ca.Account__c;
                    d2.Customer_Agreement__c = ca.Id;
                    d2.Distribution_Date__c = Date.Today();    
                    d2.Franchisor__c = ca.Account__r.Franchisor__c;
                    d2.Management_Company__c = ca.Account__r.ParentId;
                    d2.RecordTypeId = rtAmortizationId;
                    d2.Sale_Price__c = ca.Sale_Price__c;
                    d2.Territory__c = ca.Account__r.Territory__c;
                    d2.Deployment_Instance__c = ca.Deployment_Instance__c;
                    d2.Opportunity__c = ca.Opportunity__c;
                    d2.General_Ledger_Credit_Account__c = ca.General_Ledger_Credit_Account__c;
                    d2.General_Ledger_Debit_Account__c = ca.General_Ledger_Debit_Account__c;
                    
                    lstDistributionsToInsert.add(d2);       
                }
          //PERFORM THE NEXT STEPS IF THE INSTALL DATE ON THE CUSTOMER AGREEMENT IS NOT NULL      
                if(ca.Install_Date__c != null)
                {
                    
                    //AMORTIZATION RULES:
                    //Create equal monthly amortization records (Sale Price / Term) starting with month of “Install Date”.
                    //If Install Date is in prior month, sum all prior month amounts into current month’s distribution.
                    
                    intTerm = integer.valueOf(ca.Amortization_Term__c); //ASSIGN THE AMORTIZATION TERM TO AN INTEGER VARIABLE
                    
                    monthDiff = ca.Install_Date__c.monthsBetween(dtToday); //VARIABLE TO HOLD THE DIFFERENCE IN MONTHS BETWEEN TODAY AND THE INSTALL DATE
                    
                    System.debug('monthDiff Value: ' + monthDiff);
                    
                    //SET THE DISTRIBUTION DATE VARIABLE BASED ON THE DIFFERENCE IN MONTHS BETWEEN THE INSTALL DATE AND TODAY'S DATE
                    if(monthDiff>0)
                    {
                        dtDistributionDate = Date.Today();  
                    }  
                    else
                    {
                        dtDistributionDate = ca.Install_Date__c; 
                    }  
                    
                    System.debug('dtDistributionDate Value: ' + dtDistributionDate);
                    
                    //THE STANDARD CALCULATION FOR THE AMOUNT ON THE DISTRIBUTION RECORD WILL BE THE SALES PRICE OF THE CUSTOMER AGREEMENT RECORD
                    //DIVIDED BY THE AMORTIZATION TERMS 
                    Decimal dAmount; 
                                        
                    if(ca.Royalty_Base_Amount__c + ((ca.Sale_Price__c - ca.Royalty_Base_Amount__c) * (ca.Royalty_Percentage__c * .01)) < ca.Minimum_Royalty__c)
                    {
                        dAmount = ca.Minimum_Royalty__c/ca.Amortization_Term__c;
                    }       
                    else
                    {
                        dAmount = (ca.Royalty_Base_Amount__c + (ca.Sale_Price__c - ca.Royalty_Base_Amount__c) * (ca.Royalty_Percentage__c * .01))/ca.Amortization_Term__c ;  
                    }
                    
                    Decimal sumAmount;
                    
                    if(monthDiff>0)
                    {
                        sumAmount = dAmount * (monthDiff + 1);  
                    }
                    
                    Integer j;
                    
                    if(monthDiff>0)
                    {
                        intTerm = intTerm - monthDiff;
                    }    
                    
                    for (j=0;j<intTerm;j++)
                    {
                        NI_Distribution__c d = new NI_Distribution__c();
                        if(j == 0 && monthDiff>0)
                        {
                            d.Amount__c = sumAmount;
                        }
                        else
                        {
                            d.Amount__c = dAmount;  
                        }
                        d.Account_Name__c = ca.Account__c;
                        d.Customer_Agreement__c = ca.Id;
                        d.Distribution_Date__c = dtDistributionDate.addMonths(j);    
                        d.Franchisor__c = ca.Account__r.Franchisor__c;
                        d.Management_Company__c = ca.Account__r.ParentId;
                        d.RecordTypeId = rtAmortizationId;
                        d.Sale_Price__c = ca.Sale_Price__c;
                        d.Territory__c = ca.Account__r.Territory__c;
                        d.Deployment_Instance__c = ca.Deployment_Instance__c;
                        d.Opportunity__c = ca.Opportunity__c;
                        d.General_Ledger_Credit_Account__c = ca.General_Ledger_Credit_Account__c;
                        d.General_Ledger_Debit_Account__c = ca.General_Ledger_Debit_Account__c;
                        
                        lstDistributionsToInsert.add(d);    
                    }      
                } 
            }
        }
        
        System.Debug('lstDistributionsToInsert: ' + lstDistributionsToInsert.size());
        
        //=================LOGIC FOR AMORTIZATION DISTRIBUTION RECORDS CREATED FROM INVOICES==================================================    
        if (bInvoice == true)
        {
            System.debug('ENTERING INVOICE AMORTIZATION DISTRIBUTION LOGIC');
            
            //MAP OF INVOICE DETAIL RECORDS RELATED TO CUSTOMER AGREEMENTS
            Map<Id,NI_Invoice_Detail__c> mapInvDetail = new Map<Id,NI_Invoice_Detail__c> ();
            
            for(NI_Invoice_Detail__c invDet : lstInvoiceDetailRecords)
            {
                mapInvDetail.Put(invDet.Customer_Agreement__c, invDet);   
            }
            
            System.debug('MapInvDetail Size: '+ mapInvDetail.size());
            
            //PERFORM THE NEXT STEPS IF THERE ARE INVOICE DETAIL RECORDS
            If(mapInvDetail.size()>0)
            {   
                for (NI_Customer_Agreement__c ca : lstCustomerAgreements)
                {
                    System.debug('Billing Start Date: ' + mapInvDetail.get(ca.Id).Billing_Start_Date__c);
                    
                    if(mapInvDetail.get(ca.Id).Billing_Start_Date__c != null) 
                    {
                        System.Debug('Billing Start Date: ' + mapInvDetail.get(ca.Id).Billing_Start_Date__c);
                        
                        //AMORTIZATION RULES:
                        //Create equal monthly amortization records (Sale Price / Term) starting with month of the “Billing Start Date” of the Invoice Detail record.
                        //If Install Date is in prior month, sum all prior month amounts into current month’s distribution.
                        
                        intTerm = integer.valueOf(ca.Amortization_Term__c); //ASSIGN THE AMORTIZATION TERM TO AN INTEGER VARIABLE
                        
                        monthDiff = mapInvDetail.get(ca.Id).Billing_Start_Date__c.monthsBetween(dtToday); //VARIABLE TO HOLD THE DIFFERENCE IN MONTHS BETWEEN TODAY AND THE INVOICE DETAIL BILLING START DATE
                        
                        //SET THE DISTRIBUTION DATE VARIABLE BASED ON THE DIFFERENCE IN MONTHS BETWEEN THE INVOICE DETAIL BILLING START DATE AND TODAY'S DATE
                        if(monthDiff>0)
                        {
                            dtDistributionDate = Date.Today();  
                        }  
                        else
                        {
                            dtDistributionDate = mapInvDetail.get(ca.Id).Billing_Start_Date__c; 
                        }  
                        
                        //THE STANDARD CALCULATION FOR THE AMOUNT ON THE DISTRIBUTION RECORD WILL BE THE TOTAL PRICE OF THE INVOICE DETAIL RECORD
                        //DIVIDED BY THE AMORTIZATION TERMS 
                        Decimal dAmount; 
                        
                        if(ca.Royalty_Base_Amount__c + ((mapInvDetail.get(ca.Id).Total_Price__c - ca.Royalty_Base_Amount__c) * (ca.Royalty_Percentage__c * .01)) < ca.Minimum_Royalty__c)
                        {
                            dAmount = ca.Minimum_Royalty__c/ca.Amortization_Term__c;
                        }       
                        else
                        {
                            dAmount = (ca.Royalty_Base_Amount__c + (mapInvDetail.get(ca.Id).Total_Price__c - ca.Royalty_Base_Amount__c) * (ca.Royalty_Percentage__c * .01))/ca.Amortization_Term__c ;  
                        }
                        
                        System.debug('dAmount: ' + dAmount);
                        
                        //Decimal sumAmount = dAmount * (monthDiff + 1);
                        Decimal sumAmount;
                    if(monthDiff>0)
                    {
                        sumAmount = dAmount * (monthDiff + 1);  
                    }
                        
                        Integer j;
                        
                        //intTerm = intTerm - monthDiff;
                        if(monthDiff>0)
                    {
                        intTerm = intTerm - monthDiff;
                    }    
                        
                        for (j=0;j<intTerm;j++)
                        {
                            NI_Distribution__c d3 = new NI_Distribution__c();
                            if(j == 0 && monthDiff>0)
                            {
                                d3.Amount__c = sumAmount;
                            }
                            else
                            {
                                d3.Amount__c = dAmount;  
                            }
                            d3.Account_Name__c = ca.Account__c;
                            d3.Customer_Agreement__c = ca.Id;
                            d3.Distribution_Date__c = dtDistributionDate.addMonths(j);    
                            d3.Franchisor__c = ca.Account__r.Franchisor__c;
                            d3.Management_Company__c = ca.Account__r.ParentId;
                            d3.RecordTypeId = rtAmortizationId;
                            d3.Sale_Price__c = ca.Sale_Price__c;
                            d3.Territory__c = ca.Account__r.Territory__c;
                            d3.Deployment_Instance__c = ca.Deployment_Instance__c;
                            d3.Opportunity__c = ca.Opportunity__c;
                            d3.General_Ledger_Credit_Account__c = ca.General_Ledger_Credit_Account__c;
                            d3.General_Ledger_Debit_Account__c = ca.General_Ledger_Debit_Account__c;
                            d3.NI_Invoice__c = mapInvDetail.get(ca.Id).NI_Invoice__c;
                            d3.Invoice_Date__c = mapInvDetail.get(ca.Id).NI_Invoice__r.Date__c;
                            d3.Invoice_Number__c = String.ValueOf(mapInvDetail.get(ca.Id).NI_Invoice__r.Invoice_Number__c.format());
                            d3.Invoice_Detail__c = mapInvDetail.get(ca.Id).Id;
                            //d3.Invoice_Paid_Amount__c = mapInvDetail.get(ca.Id).NI_Invoice__r.Paid_Amount__c;  
                            d3.Invoice_Paid_Date__c = mapInvDetail.get(ca.Id).NI_Invoice__r.Paid_Date__c;    
                            
                            lstDistributionsToInsert.add(d3);    
                        }      
                    }        
                }       
            }         
        } 
        
        System.debug('NUMBER OF AMORTIZATION RECORDS TO INSERT: ' + lstDistributionsToInsert.size());
        
        //USE DATABASE DML METHOD TO BULK INSERT THE DISTRIBUTION RECORDS
        if(lstDistributionsToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstDistributionsToInsert,true);
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
    //====================================================================================================================
    public void Create_Royalty_Distribution_Records(List<NI_Customer_Agreement__c> newTrigger, Boolean bDeleteOld)
    {          
        System.debug(' *** ENTERING NI_Customer_Agreement_TriggerHandler.Create_Royalty_Distribution_Records()');
        
        //LIST OF UPDATED CUSTOMER AGREEMENT RECORDS TO USE FOR DISTRIBUTION RECORD CREATION
        List<NI_Customer_Agreement__c> lstCustomerAgreements = [SELECT Id, Account__c,Account__r.Franchisor__c,Account__r.ParentId,Sale_Price__c,Amount_Received__c,
                                                                Account__r.Territory__c,Deployment_Instance__c,Opportunity__c,Install_Date__c,Amortization_Term__c,
                                                                Royalty_Base_Amount__c,Royalty_Percentage__c,Royalty_Payment__c, General_Ledger_Credit_Account__c,
                                                                General_Ledger_Debit_Account__c
                                                                FROM NI_Customer_Agreement__c
                                                                WHERE Id IN: newTrigger
                                                                AND Manual_Override__c != true];
        
        
        
        //LIST OF CLOSED DISTRIBTION RECORDS
        List<NI_Distribution__c> lstClosedDistributions = new List<NI_Distribution__c>([
            SELECT Id, Customer_Agreement__c, Amount__c, Sale_Price__c 
            FROM NI_Distribution__c 
            WHERE RecordType.Name = 'Royalty'
            AND Customer_Agreement__c IN : newTrigger
            AND Status__c = 'Closed'
        ]);
        
        
        //LIST OF DISTRIBTION RECORDS THAT NEED TO BE DELETED
        if (bDeleteOld == true)
        {
            List<NI_Distribution__c> lstDistributionsToDelete = new List<NI_Distribution__c>([
                SELECT Id, Amount__c 
                FROM NI_Distribution__c 
                WHERE RecordType.Name = 'Royalty'
                AND Customer_Agreement__c IN : newTrigger
                AND Status__c = 'Pending'
            ]);
            
            // BULK DELETE RECORDS
            if (lstDistributionsToDelete.size() > 0)
            {
                Database.DeleteResult[] drList = Database.delete(lstDistributionsToDelete, false);
                for (Database.DeleteResult dr : drList) 
                {
                    if (dr.isSuccess()) 
                    {
                        //System.debug('**SUCCESSFULLY DELETED DISTRIBUTION RECORD ID: ' + dr.getId());
                    }
                    else 
                    {
                        Database.Error err = dr.getErrors()[0];
                        System.debug(err.getMessage());
                    }
                }        
            }
        }
        
        //LIST OF DISTRIBUTION RECORDS TO INSERT   
        List<NI_Distribution__c> lstDistributionsToInsert = new List<NI_Distribution__c>();
        
        //GET RECORDTYPE ID FOR THE "ROYALTY" RECORD TYPE ON THE DISTRIBUTION OBJECT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.NI_Distribution__c; 
        Map<String, Schema.RecordTypeInfo> DistributionRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtRoyaltyId = DistributionRecordTypeInfo.get('Royalty').getRecordTypeId();
        
        Integer intTerm;
        
        for (NI_Customer_Agreement__c ca : lstCustomerAgreements)
        {
            //LOOP THROUGH THE CLOSED DISTRIBUTION RECORDS AND CREATE A SINGLE DISTRIBUTION RECORD WITH A NEGATIVE AMOUNT OF ALL OF THE 
            //CLOSED DISTRIBUTION RECORDS
            if(lstClosedDistributions.size()>0)
            {
                decimal clsdAmount;
                clsdAmount = 0;
                
                for (NI_Distribution__c closedDist : lstClosedDistributions)
                {
                    if(ca.Id == closedDist.Customer_Agreement__c)
                    {
                        //ONLY INCLUDE CLOSED DISTRIBUTION RECORDS WHERE THE AMOUNT RECEIVED FIELD ON THE CUSTOMER AGREEMENT RECORD
                        //IS LESS THAN THE SALES PRICE FIELD ON THE DISTRIBUTION RECORD
                        if((ca.Amount_Received__c != null) && (closedDist.Sale_Price__c != null) && (ca.Amount_Received__c < closedDist.Sale_Price__c))
                        {
                            clsdAmount = clsdAmount + closedDist.Amount__c;  
                        }  
                    }
                }      
                NI_Distribution__c d2 = new NI_Distribution__c();
                
                d2.Amount__c = clsdAmount * -1;  
                d2.Account_Name__c = ca.Account__c;
                d2.Customer_Agreement__c = ca.Id;
                d2.Distribution_Date__c = Date.Today();    
                d2.Franchisor__c = ca.Account__r.Franchisor__c;
                d2.Management_Company__c = ca.Account__r.ParentId;
                d2.RecordTypeId = rtRoyaltyId;
                d2.Sale_Price__c = ca.Sale_Price__c;
                d2.Territory__c = ca.Account__r.Territory__c;
                d2.Deployment_Instance__c = ca.Deployment_Instance__c;
                d2.Opportunity__c = ca.Opportunity__c;
                d2.General_Ledger_Credit_Account__c = ca.General_Ledger_Credit_Account__c;
                d2.General_Ledger_Debit_Account__c = ca.General_Ledger_Debit_Account__c;
                
                lstDistributionsToInsert.add(d2);       
            }
            
           //PERFORM THE NEXT STEPS IF THE INSTALL DATE ON THE CUSTOMER AGREEMENT IS NOT NULL 
            if(ca.Install_Date__c != null)
            {
                
                //ROYALTY DISTRIBUTION RULES:
                //Create a single Royalty record 
                //If Install Date is in prior month, sum all prior month amounts into current month’s distribution.
                
                intTerm = 1; //integer.valueOf(ca.Amortization_Term__c); //ASSIGN THE AMORTIZATION TERM TO AN INTEGER VARIABLE
                Date dtDistributionDate; //VARIABLE TO HOLD THE DISTRIBUTION DATE
                Date dtToday = Date.today(); //VARIABLE TO HOLD THE CURRENT DATE
                Integer monthDiff = ca.Install_Date__c.monthsBetween(dtToday); //VARIABLE TO HOLD THE DIFFERENCE IN MONTHS BETWEEN TODAY AND THE INSTALL DATE
                
                System.debug('Create_Royalty_Distribution_Records() monthDiff: ' + monthDiff);
                
                
                //SET THE DISTRIBUTION DATE VARIABLE BASED ON THE DIFFERENCE IN MONTHS BETWEEN THE INSTALL DATE AND TODAY'S DATE
                if(monthDiff>0)
                {
                    dtDistributionDate = Date.Today();  
                }  
                else
                {
                    dtDistributionDate = ca.Install_Date__c; 
                }  
                
                //dtDistributionDate = ca.Install_Date__c; 
                //THE STANDARD CALCULATION FOR THE AMOUNT ON THE DISTRIBUTION RECORD WILL BE THE SALES PRICE OF THE CUSTOMER AGREEMENT RECORD
                //DIVIDED BY THE AMORTIZATION TERMS 
                Decimal dAmount = ca.Royalty_Payment__c;
                
                /*
                Decimal sumAmount;
                
                if(monthDiff>0)
                    {
                        sumAmount = dAmount * (monthDiff + 1);  
                    }
                
                Integer j;
                
                //intTerm = intTerm - monthDiff;
                if(monthDiff>0)
                    {
                        intTerm = intTerm - monthDiff;
                    }
                
                for (j=0;j<intTerm;j++)
                {
                    NI_Distribution__c d = new NI_Distribution__c();
                    if(j == 0 && monthDiff>0)
                    {
                        d.Amount__c = sumAmount;
                    }
                    else
                    {
                        d.Amount__c = dAmount;  
                    }
                 */
                    NI_Distribution__c d = new NI_Distribution__c();
                    d.Amount__c = dAmount;
                    d.Account_Name__c = ca.Account__c;
                    d.Customer_Agreement__c = ca.Id;
                    //d.Distribution_Date__c = dtDistributionDate.addMonths(j);
                    d.Distribution_Date__c = dtDistributionDate;    
                    d.Franchisor__c = ca.Account__r.Franchisor__c;
                    d.Management_Company__c = ca.Account__r.ParentId;
                    d.RecordTypeId = rtRoyaltyId;
                    d.Sale_Price__c = ca.Sale_Price__c;
                    d.Territory__c = ca.Account__r.Territory__c;
                    d.Deployment_Instance__c = ca.Deployment_Instance__c;
                    d.Opportunity__c = ca.Opportunity__c;
                    d.General_Ledger_Credit_Account__c = ca.General_Ledger_Credit_Account__c;
                    d.General_Ledger_Debit_Account__c = ca.General_Ledger_Debit_Account__c;
                    
                    lstDistributionsToInsert.add(d);    
                }      
            //} 
        }    
        
        System.debug('ROYALTY DISTRIBUTION RECORDS TO INSERT: ' + lstDistributionsToInsert.size());
        
        //USE DATABASE DML METHOD TO BULK INSERT THE DISTRIBUTION RECORDS
        if(lstDistributionsToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstDistributionsToInsert,true);
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
    
    //====================================================================================================================
    public void Create_Royalty_Distribution_Records_AmountReceived(List<NI_Customer_Agreement__c> newTrigger)
    {          
        System.debug(' *** ENTERING NI_Customer_Agreement_TriggerHandler.Create_Royalty_Distribution_Records_AmountReceived()');
        
        Set<Id> setCustAgreementIds = new Set<Id>();
        
        for (NI_Customer_Agreement__c agr : newTrigger)
        {
            setCustAgreementIds.add(agr.Id);  
        }
        
        //LIST OF INVOICE DETAIL RECORDS RELATED TO CUSTOMER AGREEMENT RECORDS
        List<NI_Invoice_Detail__c> lstInvoiceDetails = [SELECT Id, Customer_Agreement__c, NI_Invoice__r.Paid_Date__c
                                           FROM NI_Invoice_Detail__c
                                           WHERE Customer_Agreement__c IN: setCustAgreementIds];
        
        //MAP USED TO REFERENCE THE INVOICE DETAIL RECORD BY CUSTMER AGREEMENT ID
        Map<Id,NI_Invoice_Detail__c> mapInvoiceDetails = new Map<Id,NI_Invoice_Detail__c>();
        
        for(NI_Invoice_Detail__c invDet : lstInvoiceDetails)
        {
          mapInvoiceDetails.put(invDet.Customer_Agreement__c,invDet);  
        }
        
        
        //LIST OF UPDATED CUSTOMER AGREEMENT RECORDS TO USE FOR DISTRIBUTION RECORD CREATION
        List<NI_Customer_Agreement__c> lstCustomerAgreements = [SELECT Id, Account__c,Account__r.Franchisor__c,Account__r.ParentId,Sale_Price__c,Amount_Received__c,
                                                                Account__r.Territory__c,Deployment_Instance__c,Opportunity__c,Install_Date__c,Amortization_Term__c,
                                                                Royalty_Base_Amount__c,Royalty_Percentage__c,Royalty_Payment__c, General_Ledger_Credit_Account__c,
                                                                General_Ledger_Debit_Account__c
                                                                FROM NI_Customer_Agreement__c
                                                                WHERE Id IN: newTrigger
                                                                AND Manual_Override__c != true];
        
        
        
        //LIST OF DISTRIBUTION RECORDS TO INSERT   
        List<NI_Distribution__c> lstDistributionsToInsert = new List<NI_Distribution__c>();
        
        //GET RECORDTYPE ID FOR THE "ROYALTY" RECORD TYPE ON THE DISTRIBUTION OBJECT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.NI_Distribution__c; 
        Map<String, Schema.RecordTypeInfo> DistributionRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtRoyaltyId = DistributionRecordTypeInfo.get('Royalty').getRecordTypeId();
        
        for (NI_Customer_Agreement__c ca : lstCustomerAgreements)
        {
                    
                //ROYALTY DISTRIBUTION RULES:
                //Create a single Ryoalty record 
                
                    NI_Distribution__c d = new NI_Distribution__c();
                    
                    d.Amount__c = ca.Royalty_Payment__c;  
                    d.Account_Name__c = ca.Account__c;
                    d.Customer_Agreement__c = ca.Id;
                    d.Distribution_Date__c = mapInvoiceDetails.get(ca.Id).NI_Invoice__r.Paid_Date__c;    
                    d.Franchisor__c = ca.Account__r.Franchisor__c;
                    d.Management_Company__c = ca.Account__r.ParentId;
                    d.RecordTypeId = rtRoyaltyId;
                    d.Sale_Price__c = ca.Sale_Price__c;
                    d.Territory__c = ca.Account__r.Territory__c;
                    d.Deployment_Instance__c = ca.Deployment_Instance__c;
                    d.Opportunity__c = ca.Opportunity__c;
                    d.General_Ledger_Credit_Account__c = ca.General_Ledger_Credit_Account__c;
                    d.General_Ledger_Debit_Account__c = ca.General_Ledger_Debit_Account__c;
                    
                    lstDistributionsToInsert.add(d);    
                }         
        
        System.debug('ROYALTY DISTRIBUTION RECORDS TO INSERT: ' + lstDistributionsToInsert.size());
        
        //USE DATABASE DML METHOD TO BULK INSERT THE DISTRIBUTION RECORDS
        if(lstDistributionsToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstDistributionsToInsert,true);
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
    
    //=========================================================================================================================          
    //THIS METHOD UPDATES THE CUSTOMER AGREEMENT FIELDS BASED ON THE CUSTOM VENDOR AGREEMENT RULES
    public void Set_CustomVendorAgreementValues(List<NI_Customer_Agreement__c> newTrigger)
    {   
        System.debug(' *** ENTERING NI_Customer_Agreement_TriggerHandler.Set_CustomVendorAgreementValues()');
        
        
        //SET TO HOLD THE VENDOR AGREEMENT IDs OF THE CUSTOMER AGREEMENT RECORDS 
        Set<Id> setVendorAgreementIds = new Set<Id>();
        
        //SET TO HOLD THE ACCOUNT IDs OF THE CUSTOMER AGREEMENT RECORDS   
        Set<Id> setAccountIds = new Set<Id>();  
        
        for (NI_Customer_Agreement__c ca : newTrigger) 
        {
            setVendorAgreementIds.add(ca.Vendor_Agreement__c);                
            setAccountIds.add(ca.Account__c);   
        }
        
        System.debug('NUMBER OF VENDOR AGREEMENT IDs: ' + setVendorAgreementIds.size());
        System.debug('NUMBER OF ACCOUNT IDs: ' + setVendorAgreementIds.size());
        
        //LIST OF CUSTOM VENDOR AGREEMENT RECORDS RELATED TO VENDOR AGREEMENT RECORDS
        List<NI_Vendor_Agreement__c> lstCustVendorAgreements = [SELECT Id,Amortization_Term__c, Billable_Transaction_Percent__c,Franchisor__c,Product_Family__c,
                                                                Royalty_Base_Amount__c,Royalty_Distribution_Trigger__c,Royalty_Percentage__c,
                                                                Royalty_Transaction_Percent__c,Vendor__c,Vendor_Agreement__c, Minimum_Royalty__c
                                                                FROM NI_Vendor_Agreement__c
                                                                WHERE Vendor_Agreement__c IN :setVendorAgreementIds];
        
        System.debug('NUMBER OF CUSTOM VENDOR AGREEMENTS: ' + lstCustVendorAgreements.size());
        
        //PERFORM THE NEXT STEPS IF THERE ARE CUSTOM VENDOR AGREEMENT RECORDS
        If(lstCustVendorAgreements.size()>0)
        {
            
            //MAP OF CUSTOM VENDOR AGREEMENT RECORDS RELATED TO VENDOR AGREEMENT RECORDS
            Map<Id,NI_Vendor_Agreement__c> mapCustVendorAgreementIds = new Map<Id,NI_Vendor_Agreement__c>();
            
            for(NI_Vendor_Agreement__c cva : lstCustVendorAgreements)
            {
                mapCustVendorAgreementIds.put(cva.Vendor_Agreement__c,cva);  
            }
            
            
            System.debug('NUMBER OF CUSTOM VENDOR AGREEMENTS: ' + lstCustVendorAgreements.size());
            
            
            //MAP OF ACCOUNT RECORDS RELATED TO THE CUSTOMER AGREEMENT RECORD
            Map<Id,Account> mapAccounts = new Map<Id,Account> ([SELECT Id, Franchisor__c
                                                                FROM Account
                                                                WHERE Id IN: setAccountIds]);
            
            for(NI_Customer_Agreement__c cagr : newTrigger)
            {
                System.Debug('CUST AGREEMENT ACCOUNT FRANCHISOR: ' + mapAccounts.get(cagr.Account__c).Franchisor__c);
                
                if((mapCustVendorAgreementIds.containskey(cagr.Vendor_Agreement__c)) && (mapAccounts.get(cagr.Account__c).Franchisor__c == mapCustVendorAgreementIds.get(cagr.Vendor_Agreement__c).Franchisor__c))  
                {
                    cagr.Amortization_Term__c = mapCustVendorAgreementIds.get(cagr.Vendor_Agreement__c).Amortization_Term__c;
                    cagr.Billable_Transaction_Percent__c = mapCustVendorAgreementIds.get(cagr.Vendor_Agreement__c).Billable_Transaction_Percent__c;
                    cagr.Product_Family__c = mapCustVendorAgreementIds.get(cagr.Vendor_Agreement__c).Product_Family__c;
                    cagr.Royalty_Base_Amount__c = mapCustVendorAgreementIds.get(cagr.Vendor_Agreement__c).Royalty_Base_Amount__c;
                    cagr.Royalty_Distribution_Trigger__c = mapCustVendorAgreementIds.get(cagr.Vendor_Agreement__c).Royalty_Distribution_Trigger__c;
                    cagr.Royalty_Percentage__c = mapCustVendorAgreementIds.get(cagr.Vendor_Agreement__c).Royalty_Percentage__c;
                    cagr.Royalty_Transaction_Percent__c = mapCustVendorAgreementIds.get(cagr.Vendor_Agreement__c).Royalty_Transaction_Percent__c;
                    cagr.Minimum_Royalty__c = mapCustVendorAgreementIds.get(cagr.Vendor_Agreement__c).Minimum_Royalty__c;
                    cagr.Vendor_Agreement__c = mapCustVendorAgreementIds.get(cagr.Vendor_Agreement__c).Id;   
                } 
            }
        }
    }
    
    //=========================================================================================================================          
    //THIS METHOD UPDATES THE SERVICES ONLY FIELD ON THE CUSTOMER AGREEMENT
    public void Set_ServicesOnlyOrderField(List<NI_Customer_Agreement__c> newTrigger)
    {   
        System.debug(' *** ENTERING NI_Customer_Agreement_TriggerHandler.Set_ServicesOnlyOrderField()');
        
        //SET TO HOLD THE OPPORTUNITY IDs OF THE CUSTOMER AGREEMENT RECORDS 
        Set<Id> setOpportunityIds = new Set<Id>(); 
        
        for (NI_Customer_Agreement__c ca : newTrigger) 
        {
            setOpportunityIds.add(ca.Opportunity__c);                   
        }
        
        List<Opportunity> lstOpportunities = [SELECT Id FROM Opportunity
                                              WHERE Id IN: setOpportunityIds];
        
        List<OpportunityLineItem> lstOppLineItems = [SELECT Id,OpportunityId,PricebookEntry.Product2.Revenue_Category__c
                                                     FROM OpportunityLineItem 
                                                     WHERE OpportunityId IN: setOpportunityIds];
        
        List<Opportunity> lstServiceOnlyOpportunities = new List<Opportunity>();
        
        for(NI_Customer_Agreement__c cagr : newTrigger)
        {
            Boolean bServiesOnlyOpp = true;
            
            for(OpportunityLineItem oli: lstOppLineItems) 
            {
                if((oli.OpportunityId == cagr.Opportunity__c) && (oli.PricebookEntry.Product2.Revenue_Category__c != 'Services'))
                {
                    bServiesOnlyOpp = false;  
                }  
            }
            if(bServiesOnlyOpp == true)
            {
                cagr.Services_Only_Order__c = true; 
            }
        }
    }
    //=========================================================================================================================          
    //THIS METHOD UPDATES THE PERCENTAGE FIELDS ON THE CUSTOMER AGREEMENT FIELDS BASED ON THE CUSTOM VENDOR AGREEMENT RULES
    //DUE TO CURRENT LIMITATIONS IN PROCESS BUILDER, PERCENT FIELDS ARE NOT BORUGHT OVER WHEN CREATING NEW RECORDS
    public void Set_PercentageValues(List<NI_Customer_Agreement__c> newTrigger)
    {   
        System.debug(' *** ENTERING NI_Customer_Agreement_TriggerHandler.Set_PercentageValues()');
        
        //SET TO HOLD THE VENDOR AGREEMENT IDs RELATED TO THE INSERTED CUSTOMER AGREEMENTS
        Set<Id> setVendorAgreementIds = new Set<Id>();
        
        for (NI_Customer_Agreement__c ca : newTrigger) 
        {
            setVendorAgreementIds.add(ca.Vendor_Agreement__c);                   
        }
        
        
        
        //LIST OF VENDOR AGREEMENT RECORDS RELATED TO THE CUSTOM AGREEMENT RECORDS
        Map<Id,NI_Vendor_Agreement__c> mapVendorAgreements = new Map<Id,NI_Vendor_Agreement__c> ([SELECT Id, Billable_Transaction_Percent__c,Royalty_Percentage__c,
                                                                                                  Royalty_Transaction_Percent__c 
                                                                                                  FROM NI_Vendor_Agreement__c
                                                                                                  WHERE Id IN :setVendorAgreementIds]);
        
        
        System.debug('NUMBER OF VENDOR AGREEMENTS: ' + mapVendorAgreements.size());
        
        //PERFORM THE NEXT STEPS IF THERE ARE VENDOR AGREEMENT RECORDS
        If(mapVendorAgreements.size()>0)
        {   
            for(NI_Customer_Agreement__c cagr : newTrigger)
            {   
                if(mapVendorAgreements.containskey(cagr.Vendor_Agreement__c))  
                {
                    cagr.Billable_Transaction_Percent__c = mapVendorAgreements.get(cagr.Vendor_Agreement__c).Billable_Transaction_Percent__c;
                    cagr.Royalty_Percentage__c = mapVendorAgreements.get(cagr.Vendor_Agreement__c).Royalty_Percentage__c;
                    cagr.Royalty_Transaction_Percent__c = mapVendorAgreements.get(cagr.Vendor_Agreement__c).Royalty_Transaction_Percent__c;
                    If(cagr.Discount__c != null)
                    {
                        cagr.Discount__c = cagr.Discount__c * 100;
                    } 
                }
            }
        }
    }
    
//=====================================================================================================================================================
//     THIS SECTION HANDLES THE CUSTOMER AGREEMENT CANCELLATION LOGIC                  
//
//=====================================================================================================================================================

    public void Amortization_Distribution_Cancellations(List<NI_Customer_Agreement__c> newTrigger)
    {          
        System.debug(' *** ENTERING NI_Customer_Agreement_TriggerHandler.Amortization_Distribution_Cancellations()');
        
        //DECLARE VARIABLES
        Date dtDistributionDate; //VARIABLE TO HOLD THE DISTRIBUTION DATE
        Date dtToday = Date.today(); //VARIABLE TO HOLD THE CURRENT DATE
        Integer intTerm;
        Integer monthDiff;
        decimal clsdAmount;
        
        //GET RECORDTYPE ID FOR THE "AMORTIZATION" RECORD TYPE ON THE DISTRIBUTION OBJECT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.NI_Distribution__c; 
        Map<String, Schema.RecordTypeInfo> DistributionRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtAmortizationId = DistributionRecordTypeInfo.get('Amortization').getRecordTypeId();
        
        //LIST OF UPDATED CUSTOMER AGREEMENT RECORDS TO USE FOR DISTRIBUTION RECORD CREATION
        List<NI_Customer_Agreement__c> lstCustomerAgreements = [SELECT Id, Account__c,Account__r.Franchisor__c,Account__r.ParentId,Sale_Price__c,Product_Family__c,
                                                                Account__r.Territory__c,Deployment_Instance__c,Opportunity__c,Install_Date__c,Amortization_Term__c,
                                                                Royalty_Base_Amount__c,Royalty_Percentage__c, Minimum_Royalty__c, General_Ledger_Credit_Account__c,
                                                                General_Ledger_Debit_Account__c, Cancellation_Date__c
                                                                FROM NI_Customer_Agreement__c
                                                                WHERE Id IN: newTrigger
                                                                AND Manual_Override__c != true];
        
        
        //LIST OF DISTRIBUTION RECORDS TO INSERT   
        List<NI_Distribution__c> lstDistributionsToInsert = new List<NI_Distribution__c>();
        
        
        //LIST OF CLOSED DISTRIBTION RECORDS WITH POSITIVE AMOUNTS
        List<NI_Distribution__c> lstClosedDistributionsPositive = new List<NI_Distribution__c>([
            SELECT Id, Customer_Agreement__c, Amount__c 
            FROM NI_Distribution__c 
            WHERE RecordType.Name = 'Amortization'
            AND Customer_Agreement__c IN : newTrigger
            AND Status__c = 'Closed'
            AND Amount__c >= 0
        ]);
        
        //LIST OF CLOSED DISTRIBTION RECORDS WITH NEGATIVE AMOUNTS
        List<NI_Distribution__c> lstClosedDistributionsNegative = new List<NI_Distribution__c>([
            SELECT Id, Customer_Agreement__c, Amount__c 
            FROM NI_Distribution__c 
            WHERE RecordType.Name = 'Amortization'
            AND Customer_Agreement__c IN : newTrigger
            AND Status__c = 'Closed'
            AND Amount__c < 0
        ]);
           
        //LIST OF DISTRIBTION RECORD THAT NEED TO BE DELETED
        List<NI_Distribution__c> lstDistributionsToDelete = new List<NI_Distribution__c>([
            SELECT Id, Amount__c 
            FROM NI_Distribution__c 
            WHERE RecordType.Name = 'Amortization'
            AND Customer_Agreement__c IN : newTrigger
            AND Status__c = 'Pending'
            AND Amount__c < 0
        ]);
        
        System.debug('NUMBER OF CANCELLATION DISTRIBUTION RECORDS TO DELETE: ' + lstDistributionsToDelete.size());
        
        // BULK DELETE RECORDS
        if (lstDistributionsToDelete.size() > 0)
        {
            Database.DeleteResult[] drList = Database.delete(lstDistributionsToDelete, false);
            for (Database.DeleteResult dr : drList) 
            {
                if (dr.isSuccess()) 
                {
                    //System.debug('**SUCCESSFULLY DELETED DISTRIBUTION RECORD ID: ' + dr.getId());
                }
                else 
                {
                    Database.Error err = dr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }        
        }
//================================================================================================================================   
        //LIST OF PENDING DISTRIBTION RECORDS
        List<NI_Distribution__c> lstPendingDistributions = new List<NI_Distribution__c>([
            SELECT Id, Customer_Agreement__c, Amount__c, Distribution_Date__c 
            FROM NI_Distribution__c 
            WHERE RecordType.Name = 'Amortization'
            AND Customer_Agreement__c IN : newTrigger
            AND Status__c = 'Pending'
        ]);
        
        System.debug('lstPendingDistributions: ' + lstPendingDistributions.size());
        
        for (NI_Customer_Agreement__c ca : lstCustomerAgreements)
        {
            //LOOP THROUGH THE PENDING AMORTIZATION DISTRIBUTION RECORDS AND CREATE DISTRIBUTION RECORDS WITH NEGATIVE AMOUNTS FOR EACH 
            if(lstPendingDistributions.size()>0)
            {
                for (NI_Distribution__c pendingDist : lstPendingDistributions)
                {
                    if((ca.Id == pendingDist.Customer_Agreement__c) && (ca.Cancellation_Date__c != null))
                    {   
                        NI_Distribution__c d = new NI_Distribution__c();
                        
                        d.Amount__c = pendingDist.Amount__c * -1;  
                        d.Account_Name__c = ca.Account__c;
                        d.Customer_Agreement__c = ca.Id;
                        //d.Distribution_Date__c = Date.Today();
                        d.Distribution_Date__c = pendingDist.Distribution_Date__c;    
                        d.Franchisor__c = ca.Account__r.Franchisor__c;
                        d.Management_Company__c = ca.Account__r.ParentId;
                        d.RecordTypeId = rtAmortizationId;
                        d.Sale_Price__c = ca.Sale_Price__c;
                        d.Territory__c = ca.Account__r.Territory__c;
                        d.Deployment_Instance__c = ca.Deployment_Instance__c;
                        d.Opportunity__c = ca.Opportunity__c;
                        d.General_Ledger_Credit_Account__c = ca.General_Ledger_Credit_Account__c;
                        d.General_Ledger_Debit_Account__c = ca.General_Ledger_Debit_Account__c;
                        
                        lstDistributionsToInsert.add(d);       
                    }  
                }
                
            }
            
            //LOOP THROUGH THE CLOSED DISTRIBUTION RECORDS WITH POSITIVE AMOUNTS AND CREATE A SINGLE DISTRIBUTION RECORD WITH A NEGATIVE AMOUNT OF ALL OF THE 
            //CLOSED DISTRIBUTION RECORDS
            if(lstClosedDistributionsPositive.size()>0)
            {
                clsdAmount = 0;
                for (NI_Distribution__c closedDist : lstClosedDistributionsPositive)
                {
                    if(ca.Id == closedDist.Customer_Agreement__c)
                    {
                        clsdAmount = clsdAmount + closedDist.Amount__c;  
                    }  
                }
                NI_Distribution__c d2 = new NI_Distribution__c();
                
                d2.Amount__c = clsdAmount * -1;  
                d2.Account_Name__c = ca.Account__c;
                d2.Customer_Agreement__c = ca.Id;
                d2.Distribution_Date__c = Date.Today();    
                d2.Franchisor__c = ca.Account__r.Franchisor__c;
                d2.Management_Company__c = ca.Account__r.ParentId;
                d2.RecordTypeId = rtAmortizationId;
                d2.Sale_Price__c = ca.Sale_Price__c;
                d2.Territory__c = ca.Account__r.Territory__c;
                d2.Deployment_Instance__c = ca.Deployment_Instance__c;
                d2.Opportunity__c = ca.Opportunity__c;
                d2.General_Ledger_Credit_Account__c = ca.General_Ledger_Credit_Account__c;
                d2.General_Ledger_Debit_Account__c = ca.General_Ledger_Debit_Account__c;
                
                lstDistributionsToInsert.add(d2);       
            }
        
        //LOOP THROUGH THE CLOSED DISTRIBUTION RECORDS WITH NEGATIVE AMOUNTS AND CREATE A SINGLE DISTRIBUTION RECORD WITH A POSITIVE AMOUNT OF ALL OF THE 
            //CLOSED DISTRIBUTION RECORDS WITH NEGATIVE AMOUNTS
            if(lstClosedDistributionsNegative.size()>0)
            {
                clsdAmount = 0;
                for (NI_Distribution__c closedDistNeg : lstClosedDistributionsNegative)
                {
                    if(ca.Id == closedDistNeg.Customer_Agreement__c)
                    {
                        clsdAmount = clsdAmount + closedDistNeg.Amount__c;  
                    }  
                }
                NI_Distribution__c d3 = new NI_Distribution__c();
                
                d3.Amount__c = clsdAmount * -1;  
                d3.Account_Name__c = ca.Account__c;
                d3.Customer_Agreement__c = ca.Id;
                d3.Distribution_Date__c = Date.Today();    
                d3.Franchisor__c = ca.Account__r.Franchisor__c;
                d3.Management_Company__c = ca.Account__r.ParentId;
                d3.RecordTypeId = rtAmortizationId;
                d3.Sale_Price__c = ca.Sale_Price__c;
                d3.Territory__c = ca.Account__r.Territory__c;
                d3.Deployment_Instance__c = ca.Deployment_Instance__c;
                d3.Opportunity__c = ca.Opportunity__c;
                d3.General_Ledger_Credit_Account__c = ca.General_Ledger_Credit_Account__c;
                d3.General_Ledger_Debit_Account__c = ca.General_Ledger_Debit_Account__c;
                
                lstDistributionsToInsert.add(d3);       
            }
        }  
          
        
        System.debug('NUMBER OF AMORTIZATION RECORDS TO INSERT: ' + lstDistributionsToInsert.size());   
        
        //USE DATABASE DML METHOD TO BULK INSERT THE DISTRIBUTION RECORDS
        if(lstDistributionsToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstDistributionsToInsert,true);
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
//=======================================================================================================================================================    
    public void Royalty_Distribution_Cancellations(List<NI_Customer_Agreement__c> newTrigger)
    {          
        System.debug(' *** ENTERING NI_Customer_Agreement_TriggerHandler.Royalty_Distribution_Cancellations()');
        
        //DECLARE VARIABLES
        Date dtDistributionDate; //VARIABLE TO HOLD THE DISTRIBUTION DATE
        Date dtToday = Date.today(); //VARIABLE TO HOLD THE CURRENT DATE
        Integer intTerm;
        Integer monthDiff;
        decimal clsdAmount;
        
      //GET RECORDTYPE ID FOR THE "ROYALTY" RECORD TYPE ON THE DISTRIBUTION OBJECT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.NI_Distribution__c; 
        Map<String, Schema.RecordTypeInfo> DistributionRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtRoyaltyId = DistributionRecordTypeInfo.get('Royalty').getRecordTypeId();
        
        //LIST OF UPDATED CUSTOMER AGREEMENT RECORDS TO USE FOR DISTRIBUTION RECORD CREATION
        List<NI_Customer_Agreement__c> lstCustomerAgreements = [SELECT Id, Account__c,Account__r.Franchisor__c,Account__r.ParentId,Sale_Price__c,Product_Family__c,
                                                                Account__r.Territory__c,Deployment_Instance__c,Opportunity__c,Install_Date__c,Amortization_Term__c,
                                                                Royalty_Base_Amount__c,Royalty_Percentage__c, Minimum_Royalty__c, General_Ledger_Credit_Account__c,
                                                                General_Ledger_Debit_Account__c, Cancellation_Date__c, Royalty_Payment__c
                                                                FROM NI_Customer_Agreement__c
                                                                WHERE Id IN: newTrigger
                                                                AND Manual_Override__c != true];
        
        
        //LIST OF DISTRIBUTION RECORDS TO INSERT   
        List<NI_Distribution__c> lstDistributionsToInsert = new List<NI_Distribution__c>();
        
        
        //LIST OF CLOSED DISTRIBTION RECORDS WITH POSITIVE AMOUNTS
        List<NI_Distribution__c> lstClosedDistributionsPositive = new List<NI_Distribution__c>([
            SELECT Id, Customer_Agreement__c, Amount__c 
            FROM NI_Distribution__c 
            WHERE RecordType.Name = 'Royalty'
            AND Customer_Agreement__c IN : newTrigger
            AND Status__c = 'Closed'
            AND Amount__c >= 0
        ]);
        
        //LIST OF CLOSED DISTRIBTION RECORDS WITH NEGATIVE AMOUNTS
        List<NI_Distribution__c> lstClosedDistributionsNegative = new List<NI_Distribution__c>([
            SELECT Id, Customer_Agreement__c, Amount__c 
            FROM NI_Distribution__c 
            WHERE RecordType.Name = 'Royalty'
            AND Customer_Agreement__c IN : newTrigger
            AND Status__c = 'Closed'
            AND Amount__c < 0
        ]);
           
        //LIST OF DISTRIBTION RECORD THAT NEED TO BE DELETED
        List<NI_Distribution__c> lstDistributionsToDelete = new List<NI_Distribution__c>([
            SELECT Id, Amount__c 
            FROM NI_Distribution__c 
            WHERE RecordType.Name = 'Royalty'
            AND Customer_Agreement__c IN : newTrigger
            AND Status__c = 'Pending'
            AND Amount__c < 0
        ]);
        
        System.debug('NUMBER OF CANCELLATION DISTRIBUTION RECORDS TO DELETE: ' + lstDistributionsToDelete.size());
        
        // BULK DELETE RECORDS
        if (lstDistributionsToDelete.size() > 0)
        {
            Database.DeleteResult[] drList = Database.delete(lstDistributionsToDelete, false);
            for (Database.DeleteResult dr : drList) 
            {
                if (dr.isSuccess()) 
                {
                    //System.debug('**SUCCESSFULLY DELETED DISTRIBUTION RECORD ID: ' + dr.getId());
                }
                else 
                {
                    Database.Error err = dr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }        
        }
//================================================================================================================================   
        //LIST OF PENDING DISTRIBTION RECORDS
        List<NI_Distribution__c> lstPendingDistributions = new List<NI_Distribution__c>([
            SELECT Id, Customer_Agreement__c, Amount__c, Distribution_Date__c 
            FROM NI_Distribution__c 
            WHERE RecordType.Name = 'Royalty'
            AND Customer_Agreement__c IN : newTrigger
            AND Status__c = 'Pending'
        ]);
        
        for (NI_Customer_Agreement__c ca : lstCustomerAgreements)
        {   
            if((ca.Cancellation_Date__c != null) && (ca.Install_Date__c != null))
                    {   
                        monthDiff = ca.Install_Date__c.monthsBetween(ca.Cancellation_Date__c);
                        
                        NI_Distribution__c d = new NI_Distribution__c();
                        
                        d.Amount__c = (ca.Royalty_Payment__c * (365 - monthDiff)/365) * -1;
                        d.Amount__c = (ca.Royalty_Payment__c * (365 - monthDiff)/365) * -1; 
                        d.Account_Name__c = ca.Account__c;
                        d.Customer_Agreement__c = ca.Id;
                        d.Distribution_Date__c = Date.Today();    
                        d.Franchisor__c = ca.Account__r.Franchisor__c;
                        d.Management_Company__c = ca.Account__r.ParentId;
                        d.RecordTypeId = rtRoyaltyId;
                        d.Sale_Price__c = ca.Sale_Price__c;
                        d.Territory__c = ca.Account__r.Territory__c;
                        d.Deployment_Instance__c = ca.Deployment_Instance__c;
                        d.Opportunity__c = ca.Opportunity__c;
                        d.General_Ledger_Credit_Account__c = ca.General_Ledger_Credit_Account__c;
                        d.General_Ledger_Debit_Account__c = ca.General_Ledger_Debit_Account__c;
                        
                        lstDistributionsToInsert.add(d);       
                    }  
                
        //LOOP THROUGH THE CLOSED DISTRIBUTION RECORDS WITH NEGATIVE AMOUNTS AND CREATE A SINGLE DISTRIBUTION RECORD WITH A POSITIVE AMOUNT OF ALL OF THE 
            //CLOSED DISTRIBUTION RECORDS WITH NEGATIVE AMOUNTS
            if(lstClosedDistributionsNegative.size()>0)
            {
                clsdAmount = 0;
                for (NI_Distribution__c closedDistNeg : lstClosedDistributionsNegative)
                {
                    if(ca.Id == closedDistNeg.Customer_Agreement__c)
                    {
                        clsdAmount = clsdAmount + closedDistNeg.Amount__c;  
                    }  
                }
                NI_Distribution__c d3 = new NI_Distribution__c();
                
                d3.Amount__c = clsdAmount * -1;  
                d3.Account_Name__c = ca.Account__c;
                d3.Customer_Agreement__c = ca.Id;
                d3.Distribution_Date__c = Date.Today();    
                d3.Franchisor__c = ca.Account__r.Franchisor__c;
                d3.Management_Company__c = ca.Account__r.ParentId;
                d3.RecordTypeId = rtRoyaltyId;
                d3.Sale_Price__c = ca.Sale_Price__c;
                d3.Territory__c = ca.Account__r.Territory__c;
                d3.Deployment_Instance__c = ca.Deployment_Instance__c;
                d3.Opportunity__c = ca.Opportunity__c;
                d3.General_Ledger_Credit_Account__c = ca.General_Ledger_Credit_Account__c;
                d3.General_Ledger_Debit_Account__c = ca.General_Ledger_Debit_Account__c;
                
                lstDistributionsToInsert.add(d3);       
            }  
        }
        //USE DATABASE DML METHOD TO BULK INSERT THE DISTRIBUTION RECORDS
        if(lstDistributionsToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstDistributionsToInsert,true);
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

//================USED TO PREVENT RECURSIVE TRIGGER LOGIC=================================================================================    
 /*
    public static boolean runOnce(){
        if(bRun)
        {
            bRun=false;
            return true;
        }
        else
        {
            return bRun;
        }
        
    }
    */
}