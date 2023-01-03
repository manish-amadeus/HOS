/****************************************************************************************
Name            : AH_APT_AgreementLI_TriggerHandler
Author          : Apttus
Created Date    : 11/18/2013
Last Mod Date   : 07/20/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : This trigger conditionally updates the following fields:
				: Selected Products 	Apttus__APTS_Agreement__c.APTS_Selected_Products__c
				: Is HRM Selected?		Apttus__APTS_Agreement__c.APTS_Is_HRM_Selected__c
				: Updated 12/27/2018 per NICC-032076 
				: TEST CLASS IS: trgUpdateselProductsTest
******************************************************************************************/
public class AH_APT_AgreementLI_TriggerHandler 
{
    
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    public AH_APT_AgreementLI_TriggerHandler()
    {
        
        system.debug(' *** ENTERING AH_APT_AgreementLI_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();  
        
        system.debug(' *** EXITING AH_APT_AgreementLI_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    
    // ======================================================================================================================== 
    //  PUBLIC ENTRY METHODS 
    // ========================================================================================================================  
    public void OnAfterInsert(List<Apttus__AgreementLineItem__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_APT_AgreementLI_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        updateSelectedProducts(newTrigger);
        
        system.debug(' *** EXITING AH_APT_AgreementLI_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterUpdate(List<Apttus__AgreementLineItem__c> newTrigger, Map<Id, Apttus__AgreementLineItem__c> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING AH_APT_AgreementLI_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        updateSelectedProducts(newTrigger);
        
        system.debug(' *** EXITING AH_APT_AgreementLI_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterDelete(List<Apttus__AgreementLineItem__c> oldTrigger)
    {
        
        system.debug(' *** ENTERING AH_APT_AgreementLI_TriggerHandler.OnAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
        updateSelectedProducts(oldTrigger);
        
        system.debug(' *** EXITING AH_APT_AgreementLI_TriggerHandler.OnAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    
    // ======================================================================================================================== 
    //  PRIVATE HANDLER METHODS/FUNCTIONS 
    // ========================================================================================================================      
    private void updateSelectedProducts(List<Apttus__AgreementLineItem__c> newTrigger)
    {
        
        Set<Id> setAgreementIds = new Set<Id>();
        
        for (Apttus__AgreementLineItem__c ali : newTrigger)
        {
            setAgreementIds.add(ali.Apttus__AgreementId__c);
        }
        
        List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>(
            [SELECT Id, 
             (SELECT Id, APTS_Configuration_Type__c, Apttus_CMConfig__OptionId__c, Apttus__ProductId__r.Apttus_Revenue_Category__c, Apttus__ProductId__r.Productcode, Apttus_CMConfig__BaseProductId__c, 
              Apttus_CMConfig__OptionId__r.Apttus_Revenue_Category__c, Apttus_CMConfig__OptionId__r.ProductCode, Apttus__ProductId__r.Product_Line_Global__c, 
              Apttus_CMConfig__OptionId__r.Product_Line_Global__c, Apttus__ProductId__r.Product_Group__r.Name, 
              Apttus__ProductId__r.OM_Template_Keyword__c, Apttus_CMConfig__OptionId__r.OM_Template_Keyword__c 
              FROM Apttus__AgreementLineItems__r) 
             FROM Apttus__APTS_Agreement__c 
             WHERE Id IN : setAgreementIds]);
        
        for (Apttus__APTS_Agreement__c aa : lstAgreement)
        {
            
            aa.APTS_Selected_Products__c = '';
            
            for (Apttus__AgreementLineItem__c ali : aa.Apttus__AgreementLineItems__r)
            {
                
                // For Product Line
                /* COMMNETED AS PER THE REQUIREMNT OF - Project Utopia (https://na61.salesforce.com/aEQ3g0000004CC7GAM)
                if (string.isEmpty(ali.Apttus_CMConfig__OptionId__c))
                {
                    if (ali.Apttus__ProductId__r.Product_Group__r.Name == 'Meeting Intelligence')
                    {
                        aa.APTS_Selected_Products__c += ';HIS;';
                    } 
                    else if (ali.Apttus__ProductId__r.Product_Group__r.Name == 'HRM')
                    {
                        aa.APTS_Selected_Products__c += ';HRM;';
                        aa.APTS_Is_HRM_Selected__c = true;
                    } 
                    else if (ali.Apttus__ProductId__r.Product_Line_Global__c == 'CC Safeguard')
                    {
                        aa.APTS_Selected_Products__c += ';CC Safeguard;';
                    } 
                    else if (ali.Apttus__ProductId__r.Product_Line_Global__c == 'MeetingMatrix')
                    {
                        aa.APTS_Selected_Products__c += ';MeetingMatrix;';
                    }
                } 
                else 
                {
                    if (ali.Apttus__ProductId__r.Product_Group__r.Name == 'Meeting Intelligence')
                    {
                        aa.APTS_Selected_Products__c += ';HIS;';
                    } 
                    else if (ali.Apttus__ProductId__r.Product_Group__r.Name == 'HRM')
                    {
                        aa.APTS_Selected_Products__c += ';HRM;';
                        aa.APTS_Is_HRM_Selected__c = true;
                    }
                    else if (ali.Apttus_CMConfig__OptionId__r.Product_Line_Global__c == 'CC Safeguard')
                    {
                        aa.APTS_Selected_Products__c += ';CC Safeguard;';
                    } 
                    else if (ali.Apttus_CMConfig__OptionId__r.Product_Line_Global__c == 'MeetingMatrix')
                    {
                        aa.APTS_Selected_Products__c += ';MeetingMatrix;';
                    }
                }
                */
                
                
                // For revenue category
                if (string.isEmpty(ali.Apttus_CMConfig__OptionId__c))
                {
                    if (ali.Apttus__ProductId__r.Apttus_Revenue_Category__c != null)
                    {
                        aa.APTS_Selected_Products__c += ';' + ali.Apttus__ProductId__r.Apttus_Revenue_Category__c + ';';
                    }
                } 
                else 
                {
                    if (ali.Apttus_CMConfig__OptionId__r.Apttus_Revenue_Category__c != null)
                    {
                        aa.APTS_Selected_Products__c += ';' + ali.Apttus_CMConfig__OptionId__r.Apttus_Revenue_Category__c + ';';
                    }
                }
                
                
                // For Product Code
                /* COMMNETED AS PER THE REQUIREMNT OF - Project Utopia (https://na61.salesforce.com/aEQ3g0000004CC7GAM)
                if (string.isEmpty(ali.Apttus_CMConfig__OptionId__c))
                {
                    
                    if (ali.Apttus__ProductId__r.ProductCode == 'HRM-DFDCQS-01')
                    {
                        aa.APTS_Selected_Products__c += ';HRM Quick Start;';
                    }
                    
                    if (ali.Apttus__ProductId__r.ProductCode == 'DB-SUB-01' || 
                        ali.Apttus__ProductId__r.ProductCode == 'DB-SUB-02' || 
                        ali.Apttus__ProductId__r.ProductCode == 'DB-SUB-03' || 
                        ali.Apttus__ProductId__r.ProductCode == 'DB-SUB-04')
                    {
                        aa.APTS_Selected_Products__c += ';Connex for D&B;';
                    }
                    
                    if (ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-20-3' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-30-3' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-40-3' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-50-3' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-60-3' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-70-3' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-80-3' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-20-12' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-30-12' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-40-12' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-50-12' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-60-12' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-70-12' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-80-12' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-10-3' || 
                        ali.Apttus__ProductId__r.ProductCode == 'HRM-EMB-10-12')
                    {
                        aa.APTS_Selected_Products__c += ';HRM Embrace;';
                    } 
                    
                } 
                else 
                {
                    
                    if (ali.Apttus_CMConfig__OptionId__r.ProductCode == 'HRM-DFDCQS-01')
                    {
                        aa.APTS_Selected_Products__c += ';HRM Quick Start;';
                    }
                    
                    if (ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'DB-SUB-01' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'DB-SUB-02' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'DB-SUB-03' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'DB-SUB-04')
                    {
                        aa.APTS_Selected_Products__c += ';Connex for D&B;';
                    }
                    
                    if (ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-20-3' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-30-3' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-40-3' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-50-3' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-60-3' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-70-3' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-80-3' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-20-12' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-30-12' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-40-12' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-50-12' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-60-12' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-70-12' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-80-12' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-10-3' || 
                        ali.Apttus_CMConfig__OptionId__r.ProductCode  == 'HRM-EMB-10-12')
                    {
                        aa.APTS_Selected_Products__c += ';HRM Embrace;';
                    }
                }
				*/
                /*
                // ADDED BY SHASHIKANT ON - 02/14/2020 FOR Project Utopia
                // COMMENTED BY SHASHIKANT ON - 07/17/2020 FOR Project Utopia issue
                if(aa.APTS_Selected_Products__c != NULL && 
                   ali.Apttus__ProductId__r.OM_Template_Keyword__c != NULL && ali.Apttus__ProductId__r.OM_Template_Keyword__c != '')
                {
                    aa.APTS_Selected_Products__c += ';' + ali.Apttus__ProductId__r.OM_Template_Keyword__c + ';';
                }
				*/
                
                // ADDED BY SHASHIKANT ON - 07/17/2020 FOR Project Utopia issue and replaced above code with this (https://amadeus-hospitality.my.salesforce.com/aEQ3g0000004CbwGAE)
                if (ali.APTS_Configuration_Type__c == 'Standalone'
                    && aa.APTS_Selected_Products__c != NULL 
                    && ali.Apttus__ProductId__r.OM_Template_Keyword__c != NULL
                    && ali.Apttus__ProductId__r.OM_Template_Keyword__c != '')
                {
                    aa.APTS_Selected_Products__c += ';' + ali.Apttus__ProductId__r.OM_Template_Keyword__c + ';';
                }
                else if (ali.APTS_Configuration_Type__c == 'Bundle' 
                        && aa.APTS_Selected_Products__c != NULL
                        && ali.Apttus_CMConfig__OptionId__r.OM_Template_Keyword__c != NULL
                        && ali.Apttus_CMConfig__OptionId__r.OM_Template_Keyword__c != '')
                {
                    aa.APTS_Selected_Products__c += ';' + ali.Apttus_CMConfig__OptionId__r.OM_Template_Keyword__c + ';';
                }
				
                
            }
        }
        
        if (lstAgreement.size() > 0)
        {
            update lstAgreement;
        }  
        
    }
    
}