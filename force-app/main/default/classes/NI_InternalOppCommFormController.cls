/****************************************************************************************
Name            : NI_InternalOppCommFormController Class
Author          : Stuart Emery
Created Date    : 8/29/2013
Last Mod Date   : 7/14/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-007986
Description     : Controller for the NI_InternalOppCommFormVF Visualforce page
                : The NI_InternalOppCommForm page is rendered as PDF and is printed
                : by the Contracts Team and given to Accounting along with the signed
                : contract.                
******************************************************************************************/


public with sharing class NI_InternalOppCommFormController {
        
        private Opportunity o;
        
      //LIST TO HOLD THE OPPORTUNITY CONTACT ROLE RECORDS RELATED TO THE OPPORTUNITY  
        public List<OpportunityContactRole> lstOppContactRole{get;set;}
        
      //LIST TO HOLD THE SOFTRAX ASSETS RELATED TO THE ACCOUNT OF THE OPPORTUNITY 
      //COMMENTED 7/4 
        /*public List<Softrax_Asset__c> lstStxAssets{get;set;}*/
    
    // ADDED 7/4
        public List<Activity_Line_Item__c> lstAliAssets{get;set;}
    
    
        Public boolean bDisplayAssets{get;set;} //USED TO RENDER THE SOFTRAX ASSETS DATA TABLE
        Public boolean bDisplayNoAssetsMsg{get;set;} //USED TO RENDER THE NO ACTIVE SOFTRAX ASSETS MESSAGE
        
        Public boolean bDisplayApprovals{get;set;} //USED TO RENDER THE APPROVALS DATA TABLE
        Public boolean bDisplayNoApprovalsMsg{get;set;} //USED TO RENDER THE NO APPROVALS MESSAGE
        
      //CURRENT DATE
        Public Date currDate{get;set;}//ADDED PER NICC: NICC-010798 TO DISPLAY THE CURRENT DATE IN THE USER'S TIME ZONE
        
      //public List<Asset> lstDIs{get;set;}
        
      //LIST TO HOLD THE OPPORTUNITY LINE ITEMS RELATED TO THE OPPORTUNITY  
        public List<OpportunityLineItem> lstOppLineItems{get;set;}   
        
      //STXWRAPPER CLASS LIST TO HOLD THE SOFTRAX ASSETS 
     //COMMENTED 7/4 
        /*public List<stxAssetsWrapper> lstStxAsset {get; set;}*/
    
    //ADDED 7/4
        public List<aliAssetsWrapper> lstAliAsset {get; set;}
        
        public list<OppLineItemsWrapper> rows { get; set; }
        public opportunity record { get; set; }
        
      //LIST TO HOLD THE OPPORTUNITY APPROVAL HISTORY  
        public List<ProcessInstanceStep> lstApprovalHistory{get;set;} 
      
      //GET THE PICKLIST VALUES OF THE PRODUCT FAMILY FIELD   
      //  Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
      //  public List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();   
        
        //QUERY TO RETURN A LIST OF ACTIVITY LINE ITEMS
            //public List<stxAssetsWrapper> getStxAssets() {
            public List<aliAssetsWrapper> getStxAssets() {
                //ADDED 7/4
                List<Account> accList = new List<Account>();
                if(o.AccountId != null){
                    accList = [SELECT Id, Name FROM Account WHERE Id = : o.AccountId LIMIT 1];
                }
               if(lstAliAsset == null) {
                    lstAliAsset = new List<aliAssetsWrapper>();
                    for(Activity_Line_Item__c ali: [SELECT ali.Name, 
                                                    ali.Product__c,
                                                    ali.Product__r.Name,
                                                    ali.Contract_Start_Date__c, 
                                                    ali.Contract_End_Date__c, 
                                                    ali.Units__c,
                                                    ali.Cancel_Line_Item__c,
                                                    ali.Status__c
                                              FROM Activity_Line_Item__c ali 
                                              WHERE ali.Account_Name__c=:accList[0].Name 
                                                    AND ali.Status__c = 'Active'
                                                    AND (ali.Opportunity__c =: o.Id
                                                    OR ali.Flagged_For_Cancellation_Opportunity__c =: o.Id)
                                              ORDER BY ali.Name ASC]) {
                  //AS EACH SOFTRAX ASSET IS PROCESSED WE CREATE A NEW stxAssetWrapper OBJECT AND ADD IT TO THE lstStxAsset LIST
                    lstAliAsset.add(new aliAssetsWrapper(ali));
                    }
                }
                
                
                System.debug('**NUMBER OF lstxAsset RECORDS: ' + lstAliAsset.size());
                if(lstAliAsset.size()>0)
                  {
                    bDisplayAssets = true;
                    bDisplayNoAssetsMsg = false;
                  }
               else
                  {
                    bDisplayAssets = false;
                    bDisplayNoAssetsMsg = true;
                  }                     
                
                
                
                
                
                
                
                
                
                /*if(lstStxAsset == null) {
                    lstStxAsset = new List<stxAssetsWrapper>();
                    for(Softrax_Asset__c sa: [SELECT stx.Name, stx.Description__c, stx.Start_Date__c, stx.End_Date__c, 
                                              stx.Quantity__c,stx.Cancel_Asset__c,stx.Status__c
                                              FROM Softrax_Asset__c stx 
                                              WHERE stx.Account__c=:o.AccountId AND stx.Status__c = 'Active' 
                                              ORDER BY stx.Name ASC]) {
                  //AS EACH SOFTRAX ASSET IS PROCESSED WE CREATE A NEW stxAssetWrapper OBJECT AND ADD IT TO THE lstStxAsset LIST
                    lstStxAsset.add(new stxAssetsWrapper(sa));
                    }
                }
                
                
                System.debug('**NUMBER OF lstxAsset RECORDS: ' + lstStxAsset.size());
                if(lstStxAsset.size()>0)
                  {
                    bDisplayAssets = true;
                    bDisplayNoAssetsMsg = false;
                  }
               else
                  {
                    bDisplayAssets = false;
                    bDisplayNoAssetsMsg = true;
                  } return lstStxAsset;*/                   
                  return lstAliAsset;
   
            } 
        
            public NI_InternalOppCommFormController(ApexPages.StandardController stdController){
                lstOppContactRole = new List<OpportunityContactRole>();
                /*COMMENTED 7/4
				lstStxAssets = new List<Softrax_Asset__c>();*/
                //lstDIs = new List<Asset>();
                lstAliAssets = new List<Activity_Line_Item__c> ();
                String pFam;
                record = (Opportunity)stdController.getRecord();
                rows = new list<OppLineItemsWrapper>();
                decimal subTotal, grandTotal = 0;
                
                this.o = (Opportunity)stdController.getRecord();
                currDate = System.today();
                
              //CALL THE METHODS TO POPULATE THE LISTS
                getlstOppContactRole();
                //getlstDIs();
                //getlstOppLineItems();
                getStxAssets();
                getlstOppLineItemsSubTotal();
                getlstApprovalHistory();
        }
        
      //METHOD TO POPULATE THE OPPORTUNITY CONTACT ROLES LIST  
        private void getlstOppContactRole() {
             
            lstOppContactRole = [SELECT ocr.Id, ocr.Contact.Id,ocr.Contact.Name,ocr.Contact.Account.Name,ocr.Contact.Title,
                                ocr.Contact.Status__c,ocr.Role,ocr.Contact.Email,ocr.Contact.MailingStreet,ocr.Contact.MailingState,
                                ocr.Contact.MailingCity,ocr.Contact.MailingPostalCode,ocr.Contact.MailingCountry 
                                FROM OpportunityContactRole ocr 
                                WHERE ocr.OpportunityId=:o.Id 
                                ORDER BY ocr.Contact.Name ASC];
                                 
             
             System.debug('**NUMBER OF lstOppContactRole RECORDS: ' + lstOppContactRole.size());                                         
                                            
            }
            
      //METHOD TO POPULATE THE APPROVAL HISTORY LIST  
        private void getlstApprovalHistory() {
           
          
           
            lstApprovalHistory = [SELECT Id, SystemModstamp, OriginalActor.Name, Actor.Name, Comments, 
                                  StepStatus, ProcessInstance.Status, ProcessInstance.LastModifiedById  
                                  FROM ProcessInstanceStep
                                  WHERE ProcessInstance.TargetObjectId =:o.Id
                                  ORDER BY SystemModstamp DESC];
                                 
             
             System.debug('**NUMBER OF lstApprovalHistory RECORDS: ' + lstApprovalHistory.size());
               if(lstApprovalHistory.size()>0)
                      {
                        bDisplayApprovals = true;
                        bDisplayNoApprovalsMsg = false;
                      }
                  else
                      {
                        bDisplayApprovals = false;
                        bDisplayNoApprovalsMsg = true;
                      }                          
                                            
            }    
                
        /*
        private void getlstDIs() {
                
            lstDIs = [SELECT a.Name, a.Version__c, a.Status, a.Quantity, a.Status_Change_Date__c, a.Ship_Date__c, 
                                 a.InstallDate, a.Product_Line__c, a.IsHostedDI__c
                                 FROM Asset a 
                                 WHERE a.AccountId=:opp.AccountId 
                                 ORDER BY a.Name ASC];                     
                                            
            }
         */
             
      //METHOD TO POPULATE THE OPPORTUNITY LINE ITEMS LIST - OLD CODE
      /*  
        private void getlstOppLineItems() {
             
            lstOppLineItems = [SELECT oli.Id,oli.PriceBookEntry.ProductCode,oli.PriceBookEntry.Name,
                                 oli.ListPrice,oli.UnitPrice,oli.TotalPrice,oli.Quantity,
                                 oli.PriceBookEntry.Product2.Family,oli.Opportunity.CurrencyISOCode   
                                 FROM OpportunityLineItem oli 
                                 WHERE oli.OpportunityId=:Id 
                                 ORDER BY oli.PriceBookEntry.Product2.Family DESC,oli.PriceBookEntry.ProductCode];                     
            
             System.debug('**NUMBER OF lstOppLineItems RECORDS: ' + lstOppLineItems.size());                                
            }
     */       
//======================================================================================================================            
     //METHOD TO POPULATE THE OPPORTUNITY LINE ITEMS LIST  
        private void getlstOppLineItemsSubTotal() {
         
       //SET TO HOLD THE UNIQUE PRODUCT FAMILY VALUES OF THE OPPORTUNITY LINE ITEMS
         Set<String> setProdFamily = new Set<String>();
         
       //LIST TO HOLD THE UNIQUE SORTED PRODUCT FAMILY VALUES OF THE OPPORTUNITY LINE ITEMS
         List<String> listProdFamily = new List<String>();         
        
         String pFam; //STRING TO HOLD THE PRODUCT FAMILY
         String cIso; //STRING TO HOLD THE CURRENCY ISO CODE
         rows = new list<OppLineItemsWrapper>();
         decimal subTotal, grandTotal = 0;
             
         lstOppLineItems = [SELECT oli.Id,oli.PriceBookEntry.ProductCode,oli.PriceBookEntry.Name,
                            oli.ListPrice,oli.UnitPrice,oli.TotalPrice,oli.Quantity,oli.PriceBookEntry.Product2.Name,
                            oli.PriceBookEntry.Product2.Family,oli.Opportunity.CurrencyISOCode   
                            FROM OpportunityLineItem oli 
                            WHERE oli.OpportunityId=:o.Id 
                            ORDER BY oli.PriceBookEntry.Product2.Family DESC,oli.PriceBookEntry.ProductCode];                     
            
          System.debug('**NUMBER OF lstOppLineItems RECORDS: ' + lstOppLineItems.size());
             
             
           //LOOP THROUGH THE OPPORTUNITY LINE ITEMS AND ADD THE PRODUCT FAMILY TO THE setProdFamily SET COLLECTION
             for(OpportunityLineItem li : lstOppLineItems)
                {  
                  setProdFamily.add(li.PriceBookEntry.Product2.Family);
                }
             
           //ADD THE VALUES IN THE setFamily SET COLLECTION TO THE listProdFamily LIST COLLECTION SO WE CAN SORT THE LIST   
             listProdFamily.addAll(setProdFamily);
             
           //SORT THE listProdFamily LIST COLLECTION   
             listProdFamily.Sort();
             
           //LOOP THROUGH THE ListProdFamily LIST COLLECTION TO SELECT A PRODUCT FAMILY  
             for(String pf : listProdFamily)  
                {
                 System.debug('**PRODUCT FAMILY: ' + pf); 
                 subTotal = 0;             
                 
               //LOOP THROUGH THE OPPORTUNITY LINE ITEMS FOR LINE ITEMS THAT MATCH THE CURRENT PRODUCT FAMILY  
                 for(OpportunityLineItem oli: lstOppLineItems)              
                    {
                     if(oli.PriceBookEntry.Product2.Family == pf)
                       {
                        pFam = oli.PriceBookEntry.Product2.Family;
                        subTotal += oli.TotalPrice;
                        cIso = oli.Opportunity.CurrencyISOCode;
                        
                      //PASS THE VALUES TO THE WRAPPER CLASS  
                        rows.add(new OppLineItemsWrapper('item',oli.pricebookentry.product2,oli.TotalPrice,oli.pricebookentry.product2.Family,oli,cIso));
                       }
                     }
          System.debug('**TOTAL RECORDS FOR ' + pf + ': ' + rows.size());                          
          
          grandTotal += subTotal;
          
        //PASS THE SUBTOTAL ROW TO THE WRAPPER CLASS  
          rows.add(new OppLineItemsWrapper('sub',null,subTotal,pFam,null,cIso));
        }
       
       //PASS THE GRAND TOTAL ROW TO THE WRAPPER CLASS 
        rows.add(new OppLineItemsWrapper('grand',null,grandTotal,null,null,cIso));
      }
           
//========================================================================================================================               
         //WRAPPER CLASS TO BUILD THE SOFTRAX ASSETS LIST  
           /*COMMENTED 7/4
            * public class stxAssetsWrapper {
                public Softrax_Asset__c stx {get; set;}
                public Boolean isSelected {get; set;}
        
                //This is the contructor method. 
                public stxAssetsWrapper(Softrax_Asset__c s) {
                    stx = s;
                    
                    if(stx.Cancel_Asset__c == true) 
                      {
                       isSelected = true;
                      }
                  else
                      {
                       isSelected = false;                   
                      }
                  }
               }*/
    //ADDED 4/7
    //WRAPPER CLASS TO BUILD THE ACTIVITY LINE ITEMS LIST  
           public class aliAssetsWrapper {
                public Activity_Line_Item__c ali {get; set;}
                public Boolean isSelected {get; set;}
        
                //This is the contructor method. 
                public aliAssetsWrapper(Activity_Line_Item__c a) {
                    ali = a;
                    
                    if(ali.Cancel_Line_Item__c == true) 
                      {
                       isSelected = true;
                      }
                  else
                      {
                       isSelected = false;                   
                      }
                  }
               }
    
    
    
    
//===============================================================================================================         
      //WRAPPER CLASS TO BUILD THE OPPORTUNITY LINE ITEMS LIST
        public class OppLineItemsWrapper {
        public OppLineItemsWrapper(string rT, product2 p, decimal amt, string fam, OpportunityLineItem o, String i) {
          rowType = rT;
          rowProduct = p;
          rowAmount = amt;
          prodFamily = fam;
          oppLineItem = o;
          curIso = i;         
        }
        public string rowType { get; set; }
        public Product2 rowProduct { get; set; }
        public decimal rowAmount { get; set; }
        public string prodFamily { get; set; }
        public OpportunityLineItem oppLineItem  { get; set; }
        public string curIso { get; set; }        
      }     
               
}