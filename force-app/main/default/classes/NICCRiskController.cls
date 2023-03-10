/****************************************************************************************
Name            : NICCRiskController Class
Author          : Sean Harris
Created Date    : 12/13/13
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-009015
Description     : 
                : 
                : 
******************************************************************************************/
public class NICCRiskController 
{

    public Boolean getState() 
    {
        return true;
    }


    public List<NICC_Risk_Setup__c> lstNICCRiskSetup {get; set;} 
    public List<NICC_Risk__c> lstNICCRisk {get; set;} 
    public String RiskType {get; set;}
    public String NICC_ID {get; set;}
    public boolean displayPopup {get; set;}
    
    Boolean bIsInReadMode;
    Boolean bIsInEditMode;


    public NICCRiskController(ApexPages.StandardController controller) 
    {
    
        bIsInReadMode = true;
        bIsInEditMode = false;
        RiskType = 'Hosted';
       
        if (ApexPages.CurrentPage().getParameters().get('nicc') != null)
        {        
            NICC_ID = ApexPages.CurrentPage().getParameters().get('nicc');
        }
        
        if (ApexPages.CurrentPage().getParameters().get('type') != null)
        {        
            RiskType = ApexPages.CurrentPage().getParameters().get('type');
        }
                
    }
    
    public pageReference initRisk()
    {
 
        //if ((!NICCHasRiskRecords(NICC_ID, RiskType)) && (ApexPages.CurrentPage().getParameters().get('nicc') != null) && (ApexPages.CurrentPage().getParameters().get('type') != null))
        if (NICCHasRiskRecords(NICC_ID, RiskType) == false)
        {
            createNICCRisk(NICC_ID, RiskType);
        }    

        PageReference pr = new PageReference('/apex/NICCRisk?nicc=' + NICC_ID + '&type=' + RiskType);
        pr.setRedirect(true);  
                           
        return pr;
    
    }

    public boolean inEditMode
    {
        get 
        {
            return bIsInEditMode;
        }
        set;
    }

    public boolean inReadMode
    {
        get 
        {
            return bIsInReadMode;
        }
        set;
    }
    
    public void closePopup() 
    {        
        displayPopup = false;    
    }
    
    public void showPopup() 
    {        
        displayPopup = true;    
    }

    public void EditRec()
    {
        bIsInReadMode = false;
        bIsInEditMode = true;
        getRiskSetup();
    }
    
    public void CancelRec()
    {
        bIsInReadMode = true;
        bIsInEditMode = false;
        getRiskSetup();
    }
    
    public void SelectRec()
    {
        bIsInReadMode = true;
        bIsInEditMode = false;
        getRiskSetup();
    }    

    public List<NICC_Risk_Setup__c> getRiskSetup()  
    {    
      
        List<NICC_Risk_Setup__c> lstRS = new List<NICC_Risk_Setup__c>([
            SELECT Id, Description__c, SortOrder__c, Help_Text__c, 
            Level1Desc__c, Level2Desc__c, Level3Desc__c, Level4Desc__c, 
            Level1Weight__c, Level2Weight__c, Level3Weight__c, Level4Weight__c   
            FROM NICC_Risk_Setup__c 
            WHERE Type__c = : RiskType 
            ORDER BY SortOrder__c 
        ]);
        
        lstNICCRiskSetup = lstRS;
        
        return lstRS; 
        
    } 

    public List<NICC_Risk__c> getRiskRecord()  
    {   
    
        List<NICC_Risk__c> lstRS = new List<NICC_Risk__c>([
            SELECT Id, 
                Description__c, 
                Level1Desc__c, 
                Level1Value__c, 
                Level2Desc__c, 
                Level2Value__c, 
                Level3Desc__c, 
                Level3Value__c, 
                Level4Desc__c, 
                Level4Value__c,
                Help_Text__c, 
                SortOrder__c   
            FROM NICC_Risk__c
            WHERE NICC_ID__c = : NICC_ID AND 
            Type__c = : RiskType 
            ORDER BY SortOrder__c 
        ]);
        
        lstNICCRisk = lstRS;
        
        return lstRS; 
        
    }
   
    public PageReference SaveInlineChanges()
    {
        update lstNICCRiskSetup;
        CancelRec();
        return ApexPages.CurrentPage();
    }

    public PageReference SavePartialRiskChanges()
    {
    
        PageReference pr = null; 
    
        update lstNICCRisk;

        updateRiskLevel((Id)NICC_ID, null);
            
        pr = new PageReference('/' + NICC_ID);
        pr.setRedirect(true); 
        
        return pr; 
        
    }
    
    public PageReference SaveRiskChanges()
    {
    
        PageReference pr = null; 
    
        update lstNICCRisk;
        
        String strLevel = calculateRisk((Id)NICC_ID, RiskType);
        updateRiskLevel((Id)NICC_ID, strLevel); 

        pr = new PageReference('/' + NICC_ID);
        pr.setRedirect(true); 
        
        return pr; 
        
    }

    public PageReference QuickSavePartialRiskChanges()
    {

        PageReference pr = null; 
    
        update lstNICCRisk;

        updateRiskLevel((Id)NICC_ID, null);         
        
        return ApexPages.CurrentPage(); 
        
        //return pr;         
  
    }
    
    public PageReference QuickSaveRiskChanges()
    {

        PageReference pr = null; 
    
        update lstNICCRisk;

        String strLevel = calculateRisk((Id)NICC_ID, RiskType);
        updateRiskLevel((Id)NICC_ID, strLevel); 

        return ApexPages.CurrentPage(); 
        
        //return pr;         
  
    }

    public PageReference CancelRiskChanges()
    {
        PageReference pr = new PageReference('/' + NICC_ID);
        pr.setRedirect(true);                           
        return pr;        
    }
        
    public PageReference CreateRisks()
    {
        createNICCRisk((Id)NICC_ID, RiskType);
        return ApexPages.CurrentPage();   
    }

    public PageReference recreateRisks()
    {
        deleteNICCRisk((Id)NICC_ID);
        String strLevel = calculateRisk((Id)NICC_ID, RiskType);
        updateRiskLevel((Id)NICC_ID, strLevel);
        PageReference pr = new PageReference('/apex/NICCRiskInit?type=' + RiskType + '&nicc=' + NICC_ID);
        pr.setRedirect(true);                           
        return pr;   
    }
    
    private void createNICCRisk(Id idNICC, String strRiskType)
    {

        List<NICC_Risk__c> lst = new List<NICC_Risk__c>();
        
        for (NICC_Risk_Setup__c lstRS : [
            SELECT Id, Description__c, SortOrder__c, Type__c, Help_Text__c, 
            Level1Desc__c, Level2Desc__c, Level3Desc__c, Level4Desc__c, 
            Level1Weight__c, Level2Weight__c, Level3Weight__c, Level4Weight__c   
            FROM NICC_Risk_Setup__c 
            WHERE Type__c = : strRiskType
            ORDER BY SortOrder__c])
        {
            NICC_Risk__c l = new NICC_Risk__c();
            l.Description__c = lstRS.Description__c; 
            l.Level1Desc__c = lstRS.Level1Desc__c; 
            l.Level1Value__c = false;
            l.Level2Desc__c = lstRS.Level2Desc__c;
            l.Level2Value__c = false;
            l.Level3Desc__c = lstRS.Level3Desc__c;
            l.Level3Value__c = false;
            l.Level4Desc__c = lstRS.Level4Desc__c;
            l.Level4Value__c = false; 
            l.SortOrder__c = lstRS.SortOrder__c;
            l.NICC_ID__c = idNICC;
            l.Type__c = lstRS.Type__c;
            l.Help_Text__c = lstRS.Help_Text__c;
            lst.add(l);
        }

        Database.insert(lst);    
    
    }

    private void deleteNICCRisk(Id idNICC)
    {

        List<NICC_Risk__c> lst = new List<NICC_Risk__c>([
            SELECT Id  
            FROM NICC_Risk__c 
            WHERE NICC_ID__c = : idNICC
        ]);
        
        Database.Delete(lst);    
    
    }

    private Boolean NICCHasRiskRecords(Id idNICC, String strRiskType)
    {

        Boolean bHasRecords = false;
        
        List<NICC_Risk__c> lstRisks = new List<NICC_Risk__c>([SELECT Id FROM NICC_Risk__c WHERE Type__c = : strRiskType AND NICC_ID__c = : idNICC]);
        
        if (lstRisks.size() > 0)
        {
            bHasRecords = true;
        } 
       
        return bHasRecords;
    
    }
    
    private String calculateRisk(Id idNICC, String strRiskType)
    {

        String strRiskName = 'Low';
        Boolean bLevel1 = false;
        Boolean bLevel2 = false;
        Boolean bLevel3 = false;
        Boolean bLevel4 = false;
        
        for (NICC_Risk__c rsk : 
            [SELECT Id, NICC_ID__c, 
            Level1Value__c, Level2Value__c, Level3Value__c, Level4Value__c, Help_Text__c  
            FROM NICC_Risk__c 
            WHERE Type__c = : strRiskType AND NICC_ID__c = : idNICC]
            )
        {            
            if (rsk.Level1Value__c)
            {
                bLevel1 = true;
            }
            if (rsk.Level2Value__c)
            {
                bLevel2 = true;
            }
            if (rsk.Level3Value__c)
            {
                bLevel3 = true;
            }
            if (rsk.Level4Value__c)
            {
                bLevel4 = true;
            }                                    
        } 
        
        if (bLevel4)
        {
            strRiskName = 'High';
        }
        else
        {
            if (bLevel3)
            {
                strRiskName = 'Medium-High';
            }
            else
            {
                if (bLevel2)
                {
                    strRiskName = 'Medium';
                }
                else
                {
                    if (bLevel1)
                    {
                        strRiskName = 'Low';
                    }
                    else
                    {
                        strRiskName = null;
                    } 
                }            
            }
        }
               
        return strRiskName;
    
    }    
    
    private void updateRiskLevel(Id idNICC, String strRiskLevel)
    {    
        NI_Change_Control__c nicc = [SELECT Id, Risk_Level__c FROM NI_Change_Control__c WHERE id =: idNICC LIMIT 1];
        nicc.Risk_Level__c = strRiskLevel;
        Database.Update(nicc);
    }
    
//    private boolean hasEmptyRow()
//    {
//        boolean bRet = false;
        
//        for (NICC_Risk__c r : lstNICCRisk)
//        {
//            if (!r.Level1Value__c && !r.Level2Value__c && !r.Level3Value__c && !r.Level4Value__c)
//            {
//                bRet = true;
//            }
//        }
//        return bRet;
//    }
    
  
    
}