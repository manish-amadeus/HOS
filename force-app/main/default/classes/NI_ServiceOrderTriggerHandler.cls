/********************************************************************************************
Name            : NI_ServiceOrderTriggerHandler
Author          : Suzanne LeDuc
Created Date    : 1/8/2013
Last Mod Date   : 6/17/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-006222
Description     : Trigger Handler Class for Service Order and Service Order Detail Triggers
                : 
                : 
*********************************************************************************************/

public class NI_ServiceOrderTriggerHandler
{
  //ADDED PER SALESFORCE.COM CHANGE REQUEST: NICC-010386   
    public static void handleServiceOrderProvision(List<CHANNEL_ORDERS__Service_Order__c> oldServiceOrders, List<CHANNEL_ORDERS__Service_Order__c> newServiceOrders )
     {
       //SET TO HOLD THE NEW SERVICE ORDER IDs
         Set<Id> setSOIds = new Set<Id>();
         
       //LOOP THROUGH THE NewServiceOrders AND ADD THE IDs TO THE setSOIds
         for(CHANNEL_ORDERS__Service_Order__c sOrder : NewServiceOrders)
            {
              setSOIds.add(sOrder.Id);
            }
         
         System.debug('setSOIds Size: ' + setSOIds.size());
         
         RecordType rtHRM = [SELECT Name, Id FROM RecordType WHERE sObjectType =: 'NI_Org_Details__c' AND Name =: 'HRM Support Admin'];
         RecordType rtLOD = [SELECT Name, Id FROM RecordType WHERE sObjectType =: 'NI_Org_Details__c' AND Name =: 'LOD Support Admin'];
        
       //LIST OF OPPORTUNITY LINE ITEMS TO UPSERT  
         List<OpportunityLineItem> lstOppLineItemsToUpsert = new List <OpportunityLineItem>();
             
       //LIST OF OPPORTUNITY LINE ITEMS RELATED TO NEW SERVICE ORDERS  
         List<OpportunityLineItem> lstOppLineItems = [SELECT Id, Quantity, ServiceDate, Service_Order__c 
                                                      FROM OpportunityLineItem 
                                                      WHERE Service_Order__c IN :setSOIds];
                                                      
        //LIST OF SO DETAILS RELATED TO NEW SERVICE ORDERS THAT ARE BY USER
        List<CHANNEL_ORDERS__Service_Order_Detail__c> lstSoItems = [SELECT Id, CHANNEL_ORDERS__Product_Name__c, CHANNEL_ORDERS__Partner_Order__c,CHANNEL_ORDERS__pc_Product_ID__C
                                                                    FROM CHANNEL_ORDERS__Service_Order_Detail__c
                                                                    WHERE CHANNEL_ORDERS__pc_Pricing_Unit__c = 'User' AND CHANNEL_ORDERS__Partner_Order__c in :setSOIds];
                                                                        
                                                                        
         System.debug('***NUMBER OF OPPORTUNITY LINE ITEMS TO UPSERT: ' + lstOppLineItems.size());
         
         for(CHANNEL_ORDERS__Service_Order__c so : newServiceOrders)
            {
                if( so.CHANNEL_ORDERS__Service_Order_Status__c == 'Provisioned' || so.CHANNEL_ORDERS__Service_Order_Status__c == 'Activated')
                {    
                    //List<OpportunityLineItem> lineItems = new List<OpportunityLineItem> ( [SELECT  Id, Quantity, ServiceDate, ServiceOrderId__c FROM OpportunityLineItem WHERE ServiceOrderId__c = :so.Id]);
                    for(OpportunityLineItem lineItem: lstOppLineItems)
                    {
                        if(so.Id == lineItem.Service_Order__c)
                        { 
                            lineItem.ServiceDate = so.CHANNEL_ORDERS__Service_Start_Date__c;
                            lstOppLineItemsToUpsert.add(lineItem);
                        }
                        
                      
                    }
                    
                    List<NI_Org_Details__c> lstOrgDetails = [SELECT Id, Org_ID__c, Annual_Salesforce_Renewal_Date__c, Org_Status__c FROM NI_Org_Details__c
                                                              WHERE Org_ID__c =: so.CHANNEL_ORDERS__Customer_Org_ID__c AND ( RecordTypeId =: rtHRM.Id OR RecordTypeId =: rtLOD.Id )];
                    
                    if( lstOrgDetails.size() > 0 && so.CHANNEL_ORDERS__Order_Type__c == 'Initial' )
                    {
                        lstOrgDetails[0].Annual_Salesforce_Renewal_Date__c = so.CHANNEL_ORDERS__Service_Start_Date__c;
                        lstOrgDetails[0].Org_Status__c = 'Provisioned';
                        
                        Database.upsert( lstOrgDetails[0]);
                    }
                    else if ( so.CHANNEL_ORDERS__Order_Type__c == 'Cancellation Order' )
                    {
                         Date cancellEffectiveDate = Date.newInstance( Date.Today().Year(), lstOrgDetails[0].Annual_Salesforce_Renewal_Date__c.Month(), lstOrgDetails[0].Annual_Salesforce_Renewal_Date__c.day());
                    
                         lstOrgDetails[0].Org_Status__c = 'Cancelled';
                         lstOrgDetails[0].Cancellation_Date__c = cancellEffectiveDate;
                         Database.upsert( lstOrgDetails[0]);
                    }
                    else if ( so.CHANNEL_ORDERS__Order_Type__c == 'Upgrade - Partner App' )
                    {
                        //Change the license type to the new license type
                        string licenseTypeName = '';
                        //Get the new license type by first getting the licenses for this order
                        List<CHANNEL_ORDERS__Service_Order_Detail__c> detailItems = new List<CHANNEL_ORDERS__Service_Order_Detail__c>();
                        for( CHANNEL_ORDERS__Service_Order_Detail__c soDetail :lstSOItems )
                        {
                            if( soDetail.CHANNEL_ORDERS__Partner_Order__c == so.Id )
                            {
                                detailItems.Add(soDetail);
                            }
                        }
                        //Get the License Type
                        Service_Order_Settings__c soSettings = Service_Order_Settings__c.getValues('AdminLicenseCodes');
                        List<String> licenseTypes = soSettings.License_Types__c.Split('\n');
                        for( String licenseType: licenseTypes )
                        {
                            List<String> licenseInfo = licenseType.Split(',');
                           //System.Debug('product id ' + detailitems[0].CHANNEL_ORDERS__pc_Product_ID__C);
                           //System.Debug('licenseinfo ' + licenseInfo[1].trim());
                           if(!detailitems.isempty() && detailitems[0].CHANNEL_ORDERS__pc_Product_ID__C.Containsignorecase( licenseInfo[1].trim())  )
                           {
                               licenseTypeName = licenseInfo[0].Trim();
                           }
                        }
                         if( licenseTypeName != '')
                         {
                             lstOrgDetails[0].License_Type__c = licenseTypeName;
                             Database.upsert( lstOrgDetails[0]);
                         }
                    }
                }
                else  if( so.CHANNEL_ORDERS__Service_Order_Status__c == 'Error')
                {    
                    //List<OpportunityLineItem> lineItems = new List<OpportunityLineItem> ( [SELECT  Id, Quantity, ServiceDate, ServiceOrderId__c FROM OpportunityLineItem WHERE ServiceOrderId__c = :so.Id]);
                    for(OpportunityLineItem lineItem: lstOppLineItems)
                    {
                        if(so.Id == lineItem.Service_Order__c)
                        { 
                            lineItem.Service_Order__c = NULL;
                            lstOppLineItemsToUpsert.add(lineItem);
                        }
                    }
                }
            }
         
         if(!Test.isRunningTest())
         {
         	Database.upsert(lstOppLineItemsToUpsert);    
         }
     }
//=============================================================================================================================    
    
    /*NO LONGER NEEDED
    public static void handleServiceOrderDetailChange(List<CHANNEL_ORDERS__Service_Order_Detail__c> oldServiceOrderDetails, List<CHANNEL_ORDERS__Service_Order_Detail__c> newServiceOrderDetails )
    {
        for( CHANNEL_ORDERS__Service_Order_Detail__c soDetail : newServiceOrderDetails  )
        {
          //Update the Cost field of the Service order we are adding
            if( !soDetail.CHANNEL_ORDERS__Product_ID__c.contains('SBX') )
            {
                System.debug('not sandbox');
            //If the Fixed Price is not null it should equal Fixed Price, Else if PNR * Customer Price ( user/month) > Floor Price, Cost should equal PNR * Customer Price ( user/month) else Floor Price
               if( soDetail.CHANNEL_ORDERS__Pricing_Type__c == 'Fixed' )
               {
                   soDetail.Cost__c = soDetail.Fixed_Price_Custom__c * soDetail.CHANNEL_ORDERS__Quantity__c;
               } 
               else
               {
                   if( ((soDetail.CHANNEL_ORDERS__PNR__c/100) * soDetail.CHANNEL_ORDERS__Customer_Price__c) > soDetail.Floor_Price_Custom__c)
                   {
                       soDetail.Cost__c = ((soDetail.CHANNEL_ORDERS__PNR__c/100) * soDetail.CHANNEL_ORDERS__Customer_Price__c) * soDetail.CHANNEL_ORDERS__Quantity__c;
                   }
                   else
                   {
                       soDetail.Cost__c = soDetail.Floor_Price_Custom__c * soDetail.CHANNEL_ORDERS__Quantity__c;
                   }
               }
        
            }
        }
    }
*/

//===============================================================================================================================

    /* NO LONGER NEEDED 
    public static void handleServiceOrderChange(List<CHANNEL_ORDERS__Service_Order__c> oldServiceOrders, List<CHANNEL_ORDERS__Service_Order__c> newServiceOrders )
     {
        // ADDED BY Stuart Emery ON 1/20/2013
        // CREATE A SET TO HOLD THE Customer_Org_ID__c VALUES OF THE RECORDS BEING UPDATED/INSERTED            
           Set<String> soCustOrgs = new Set<String>();
                
            // FILL THE soCustOrgs SET WITH THE CHANNEL_ORDERS__Customer_Org_ID__c VALUE OF THE RECORDS BEING UPDATED/INSERTED
            for(CHANNEL_ORDERS__Service_Order__c so : newServiceOrders)
             {
             soCustOrgs.add(so.CHANNEL_ORDERS__Customer_Org_ID__c);
             //System.debug('ORG ID: ' + so.CHANNEL_ORDERS__Customer_Org_ID__c);
             }
                        
             // CREATE A LIST OF ALL SERVICE ORDER RECORDS THAT HAVE THE SAME CHANNEL_ORDERS__Customer_Org_ID__c AS THE RECORDS BEING UPDATED/INSERTED 
             List<CHANNEL_ORDERS__Service_Order__c> allServiceOrdersList = new List<CHANNEL_ORDERS__Service_Order__c>(
                [SELECT Id, CHANNEL_ORDERS__Customer_Org_ID__c FROM CHANNEL_ORDERS__Service_Order__c
                 WHERE CHANNEL_ORDERS__Customer_Org_ID__c IN :soCustOrgs]);  
                                     
           
             //CREATE A LIST OF ALL SERVICE ORDER DETAIL RECORDS FOR SERVICE ORDERS IN THE otherServiceOrdersList LIST
             List<CHANNEL_ORDERS__Service_Order_Detail__c> serviceOrderDetailCompleteList = new List <CHANNEL_ORDERS__Service_Order_Detail__c>(
               [SELECT Id, Cost__c,CHANNEL_ORDERS__Product_ID__c FROM  CHANNEL_ORDERS__Service_Order_Detail__c 
                 WHERE CHANNEL_ORDERS__Partner_Order__c IN :allServiceOrdersList]);
  */
       
               /* ORIGINAL CODE
                for( CHANNEL_ORDERS__Service_Order__c serviceOrder : newServiceOrders  )
                {
                
                    String orgId = serviceOrder.CHANNEL_ORDERS__Customer_Org_ID__c;
                    List<CHANNEL_ORDERS__Service_Order_Detail__c> serviceOrderDetailCompleteList = [select id, Cost__c,CHANNEL_ORDERS__Product_ID__c from  CHANNEL_ORDERS__Service_Order_Detail__c 
                                    where CHANNEL_ORDERS__Partner_Order__c in ( select Id from CHANNEL_ORDERS__Service_Order__c CHANNEL_ORDERS__Customer_Org_ID__c 
                                    where CHANNEL_ORDERS__Customer_Org_ID__c = :orgId) ];
               */ 
               /*        
                Decimal cost = 0.0;
                 
                
                //Add up the cost from all those service orders that are licenses
                for(CHANNEL_ORDERS__Service_Order_Detail__c serviceOrderDetail: serviceOrderDetailCompleteList)
                {
               
                    if(  serviceOrderDetail.CHANNEL_ORDERS__Product_ID__c.Contains('ADM')         
                          || serviceOrderDetail.CHANNEL_ORDERS__Product_ID__c.Contains('STD')
                           )  
                          
                    {
                     System.debug(serviceOrderDetail.CHANNEL_ORDERS__Product_ID__c);
                     System.debug(serviceOrderDetail.Cost__c);
                       
                        cost = 0.0;
                        //cost += serviceOrderDetail.Cost__c;  
                                           
                    }
                }
              
                  System.debug( cost );
              
                //Now update the cost field on the Sandbox SODetails
                for( CHANNEL_ORDERS__Service_Order_Detail__c serviceOrderDetailUpdate: serviceOrderDetailCompleteList )
                {
                    //Update Full Copy
                    if( serviceOrderDetailUpdate.CHANNEL_ORDERS__Product_ID__c.Contains('SBX-FC') )
                    {
                                             
                        serviceOrderDetailUpdate.Cost__c = cost *.20;
                        
                          System.debug( serviceOrderDetailUpdate.Cost__c );          
                    }
                    //Update Configuration
                    if( serviceOrderDetailUpdate.CHANNEL_ORDERS__Product_ID__c.Contains('SBX-CF') )
                    {
                        serviceOrderDetailUpdate.Cost__c = cost *.05;
                    }           
                }          
                 Update serviceOrderDetailCompleteList;            
         }
*/
}