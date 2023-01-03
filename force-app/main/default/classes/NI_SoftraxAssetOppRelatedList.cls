/****************************************************************************************
Name            : NI_SoftraxAssetOppRelatedList Class
Author          : Stuart Emery
Created Date    : 10/06/2013
Last Mod Date   : 11/10/2013
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Controller for the NI_SoftraxAssetsOpportunityVF Visualforce page
                : The NI_SoftraxAssetsOpportunityVF page is used by the Contracts Team
                : to identify Softrax Assets that need to be cancelled as part of the
                : related Opportunity.                
******************************************************************************************/


public with sharing class NI_SoftraxAssetOppRelatedList {
    public NI_SoftraxAssetOppRelatedList(){
        
    }
      
      /*private Opportunity o;
                
      //USED TO ENABLE OR DISABLE THE CANCEL CHECKBOX ON THE VF PAGE  
        public Boolean bDisabled {get; set;}
        
        public Boolean isDisabled {get; set;}
        public Boolean disableEdit {get; set;}
        public Boolean disableSave {get; set;}
        public Boolean disableCancel {get; set;}
         
                                             
      //STXWRAPPER CLASS LIST TO HOLD THE SOFTRAX ASSETS 
        public List<stxAssetsWrapper> lstStxAsset {get; set;}
        
        public NI_SoftraxAssetOppRelatedList(ApexPages.StandardController stdController)
        {                      
                  
            this.o = (Opportunity)stdController.getRecord();


            // CALL THE METHODS TO POPULATE THE LISTS
            disableListEdit();
            //getStxAssets();
            
        }
         
         
         public void disableListEdit(){
             bDisabled = true;
             getStxAssets();
             
            }
            
          public void EnableListEdit(){
             bDisabled = false;
             getStxAssets();
                
            }
            
            //QUERY TO RETURN A LIST OF SOFTRAX ASSETS
          public List<stxAssetsWrapper> getStxAssets() 
          {
                system.debug('Opportuinty = ' + o + ' =======================================================');

                //if(lstStxAsset == null) {
                    lstStxAsset = new List<stxAssetsWrapper>();
                    for(Softrax_Asset__c sa: [SELECT stx.Id, stx.Name, stx.Description__c, stx.Start_Date__c, stx.End_Date__c, 
                                              stx.Quantity__c,stx.Cancel_Asset__c,stx.Status__c, stx.Account__c,stx.Fee__c
                                              FROM Softrax_Asset__c stx 
                                              WHERE stx.Account__c =: o.AccountId AND stx.Status__c = 'Active' 
                                              ORDER BY stx.Name ASC]) {
                  //AS EACH SOFTRAX ASSET IS PROCESSED WE CREATE A NEW stxAssetWrapper OBJECT AND ADD IT TO THE lstStxAsset LIST
                    lstStxAsset.add(new stxAssetsWrapper(sa));
                  //}
                }
                
                System.debug('**NUMBER OF lstxAsset RECORDS: ' + lstStxAsset.size());                
                return lstStxAsset;
   
            } 
            
     public PageReference saveSelected() {        
          
        //LIST OF SOFTRAX ASSETS THAT WILL BE POPULATED WITH ONLY THE SELECTED SOFTRAX ASSETS
          List<Softrax_Asset__c> lstSelectedAssets = new List<Softrax_Asset__c>();
          
        //LIST OF SOFTRAX ASSETS THAT WILL BE POPULATED WITH ONLY THE NON-SELECTED SOFTRAX ASSETS
          List<Softrax_Asset__c> lstNonSelectedAssets = new List<Softrax_Asset__c>();  
          
        //LIST OF SELECTED SOFTRAX ASSETS TO UPDATE  
          List<Softrax_Asset__c> lstStxAssetsToUpdate = new List<Softrax_Asset__c>();
        
        //WE LOOP THROUGH OUR lstStxAsset LIST TO SEE IF THE SELECTED PROPERTY IS SET TO TRUE AND ADD THE RECORD TO THE lstSelectedAssets LIST OR THE
        //lstNonSelectedAssets LIST
          for(stxAssetsWrapper sw: lstStxAsset) 
            {
             if(sw.isSelected == true) 
              {
               lstSelectedAssets.add(sw.stx);
              }
          else
              {
               lstNonSelectedAssets.add(sw.stx);
              }  
            } 
            
          //LOOP THROUGH THE lstSelectedAssets LIST AND SET THE Cancel__c FIELD TO 'TRUE' FOR THE SELECTED RECORDS AND ADD THEM TO THE lstStxAssetsToUpdate LIST 
            for(Softrax_Asset__c s : lstSelectedAssets)
               {
                s.Cancel_Asset__c = true;
                lstStxAssetsToUpdate.add(s);
               }
               
          //LOOP THROUGH THE lstNonSelectedAssets LIST AND SET THE Cancel__c FIELD TO 'FALSE' FOR THE SELECTED RECORDS AND ADD THEM TO THE lstStxAssetsToUpdate LIST   
            for(Softrax_Asset__c n : lstNonSelectedAssets)
               {
                n.Cancel_Asset__c = false;
                lstStxAssetsToUpdate.add(n);
               }   
                
                //USE DATABASE DML METHOD TO UPDATE ALL OF THE SELECTED AND NON-SELECTED RECORDS
                  if(lstStxAssetsToUpdate.size() > 0)
                  {
                   Database.SaveResult[] results = Database.update(lstStxAssetsToUpdate,false);
                    for(Database.SaveResult sr: results)
                    {
                      if(!sr.isSuccess())
                       {
                         Database.Error err = sr.getErrors()[0];
                         System.debug(err.getMessage());
                         ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage()));
                         
                        }
                    }
                }                     
                
                
                lstStxAsset = null; //SET THE LIST TO NULL SO A NEW LIST IS CREATED
                disableListEdit(); //CALL THE disableListEdit METHOD WHICH CALLS THE getStxAssets METHOD AND DISABLED EDIT MODE
                
                return null;
        }            
         
       
 //============================================================================================================                  
        
         //WRAPPER CLASS TO BUILD THE SOFTRAX ASSETS LIST  
           public class stxAssetsWrapper {
                public Softrax_Asset__c stx {get; set;}
                public Boolean isSelected {get; set;}
                //public Boolean isDisabled {get; set;}
                public Boolean disableEdit {get; set;}
                public Boolean disableSave {get; set;}
                public Boolean disableCancel {get; set;}
                public Id idStxAsset {get; set;}
        
                //This is the contructor method. 
                public stxAssetsWrapper(Softrax_Asset__c s) {
                    stx = s;
                    //isDisabled = b;
                    idStxAsset = stx.Id;*/
                    
                    /*
                    if(isDisabled = true)
                      {
                       disableEdit = false;
                       disableSave = true;
                       disableCancel = true;
                      }
                      
                    if(isDisabled = false)
                      {
                       disableEdit = true;
                       disableSave = false;
                       disableCancel = false;
                      }
                      */ 
                    
                    /*if(stx.Cancel_Asset__c == true) 
                      {
                       isSelected = true;
                      }
                  else
                      {
                       isSelected = false;                   
                      }
      }
   }*/
}