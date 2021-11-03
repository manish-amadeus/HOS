/****************************************************************************************
Name            : AH_Rally_ProductMapping_Ctlr (TC Org Name: ProductMapping) 
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : Controller class for AH_Rally_ProductMapping (TC Org Name: ProductProjectMapping) 
				: 
				: 
******************************************************************************************/
public class AH_Rally_ProductMapping_Ctlr 
{
    
    // PUBLIC VARIABLES
    public List<CaseProductWithProject> lstMappings {get; set;}
    public List<CaseProductWithProject> lstNewMapping {get; set;}
    public List<SelectOption> soProjects {get; set;}
    public Integer iSelectedRow {get; set;}
    public String strAddMsg {get; set;} 
    public String strAddMsgStyle {get; set;} 
    public String strEditMsg {get; set;} 
    public String strEditMsgStyle {get; set;}     
    public String strMappingCount {get; set;} 
    public String strDeletionDetails {get; set;} 
	public Boolean bShowDeleteConfirmDialog {get; set;}
    public Boolean bShowEditConfirmDialog {get; set;}
    
    // PRIVATE VARIABLES
    private String strMappingName;
    private integer iLastIndex;
    
    
    public AH_Rally_ProductMapping_Ctlr()
    {

        // INITIALIZE VARIABLES 
        iSelectedRow = 0;        
        strAddMsg = '';
        strAddMsgStyle = 'text-align:center;color: green !important;';
        strEditMsg = '';
        strEditMsgStyle = 'color: green !important;';
        bShowDeleteConfirmDialog = false;
        bShowEditConfirmDialog = false;
        strDeletionDetails = '';
        
        // GET A LIST OF PROJECTS FROM RALLY AND POPULATE A SelectOption LIST WITH THE NAMES
        Map<String, String> projectUrl = AH_Rally_Library.projectList();
        List<String> lstSorter = new List<String>();
        lstSorter.addAll(projectUrl.keySet());
        lstSorter.sort();
        
        soProjects = new List<SelectOption>();
		soProjects.add(new SelectOption('', '--None--'));
        
        for (String str : lstSorter)
        {
            soProjects.add(new SelectOption(str, str));
        }
        
        loadLists();
        
    }
    
    private void loadLists()
    {

        iLastIndex = 0;
        
        // RETRIEVE ALL MAPPINGS FROM CUSTOM SETTING
        //Map<String, ProductMapping__c> myProductMap = ProductMapping__c.getAll();
        List<ProductMapping__c> lstProductMapping = new List<ProductMapping__c>(
            [SELECT Id, Name, Product_Family__c, Product__c, Affected_Component__c, Component__c, Project__c 
             FROM ProductMapping__c
             ORDER BY Product_Family__c, Product__c, Affected_Component__c, Component__c]);
        
        // INSTANTIATE MAPPING LIST
        lstMappings = new List<CaseProductWithProject>();

        // LOOP THROUGH RETRIEVED MAPPINGS FROM CUSTOM SETTING AND POPULATE WRAPPER CLASS LIST
        //for (ProductMapping__c pm : myProductMap.Values())
        for (ProductMapping__c pm : lstProductMapping)
        {
			
            // CREATE NEW DUMMY Case RECORD. THIS IS USED TO INHERIT DEPENDENT PICKLIST SELECTIONS
            Case newCs = new Case();
            
            //  MAPPING LEGEND ======================
            // "Solution Domain"	Product_Family__c 
            // "Case Product Line"	Product__c
            // "Module"				Affected_Component__c
            // "Component"			Component__c  
            newCs.Product_Family__c = pm.Product_Family__c; 
            newCs.Case_Product_Line__c = pm.Product__c; 
            newCs.Module__c = pm.Affected_Component__c;
            newCs.Component__c = pm.Component__c;
            
            CaseProductWithProject myCaseWithProject = new CaseProductWithProject(newCs, pm.Project__c, pm.Name, false, iLastIndex);
            lstMappings.add(myCaseWithProject);
            
            iLastIndex++;
            
        }
        
        strMappingCount = iLastIndex + ' Mapping Records Found';        

        // CREATE UNIQUE CUSTOM SETTING NAME
        Blob b = Crypto.GenerateAESKey(128);
		String strCSName = EncodingUtil.ConvertTohex(b);
        iLastIndex++;
        
        // LIST TO HOLD ONE NEW MAPPING
        lstNewMapping = new List<CaseProductWithProject>();
        CaseProductWithProject newMapping = new CaseProductWithProject(new Case(), '--None--', strCSName, true, iLastIndex);
        lstNewMapping.add(newMapping);   
        
    }
    
    private boolean isValidMapping(String strSolutionDomain, String strCaseProductLine, String strModule, String strComponent, boolean isUpdate)
    {
        
        boolean bRet = true;

        List<ProductMapping__c> lstProductMapping = new List<ProductMapping__c>(
            [SELECT Id 
             FROM ProductMapping__c 
             WHERE Product_Family__c =: strSolutionDomain
             AND Product__c =: strCaseProductLine
             AND Affected_Component__c =: strModule
             AND Component__c =: strComponent]);
        
        if (!lstProductMapping.isEmpty())
        {
            bRet = false;
system.debug(' ::::::: lstProductMapping.size() = ' + lstProductMapping.size());   
system.debug(' ::::::: isUpdate = ' + isUpdate);   
            if (isUpdate && lstProductMapping.size() == 1)
            {
                bRet = true;
            }
        }
        
        return bRet;
        
    }
    
    public void doAddRow()
    {
        
        strAddMsg = ''; 
        strAddMsgStyle = 'text-align:center;color: red !important;'; 

        // VALIDATE USER INPUT 
        if (isValidMapping(lstNewMapping[0].myCase.Product_Family__c, 
                           lstNewMapping[0].myCase.Case_Product_Line__c, 
                           lstNewMapping[0].myCase.Module__c, 
                           lstNewMapping[0].myCase.Component__c, 
                           false) == false) 
        {
            strAddMsg = 'We cannot add this new mapping because there is an existing mapping with the same values and they need to be unique.'; 
            return; 
        }

        if (lstNewMapping[0].myCase.Product_Family__c == '--None--' || lstNewMapping[0].myCase.Product_Family__c == null)
        {
            strAddMsg = 'Please choose a valid value for Rally Solution Domain.';   
            return;
        }

        if (lstNewMapping[0].myCase.Case_Product_Line__c == '--None--' || lstNewMapping[0].myCase.Case_Product_Line__c == null)
        {
            strAddMsg = 'Please choose a valid value for Case Product Line.'; 
            return; 
        }

        if (lstNewMapping[0].myCase.Module__c == '--None--' || lstNewMapping[0].myCase.Module__c == null) 
        {
            strAddMsg = 'Please choose a valid value for Module.'; 
            return; 
        }

        if (lstNewMapping[0].Project == '--None--' || lstNewMapping[0].Project == null) 
        {
            strAddMsg = 'Please choose a valid value for Project.'; 
            return; 
        }
        
		// TRY MAPPING INSERT        
        try
        {
            
            ProductMapping__c pm = new ProductMapping__c(); 
            
            pm.Name = lstNewMapping[0].mapName; 
            pm.Product_Family__c = lstNewMapping[0].myCase.Product_Family__c; 
            pm.Product__c = lstNewMapping[0].myCase.Case_Product_Line__c; 
            pm.Affected_Component__c = lstNewMapping[0].myCase.Module__c; 
            pm.Component__c = lstNewMapping[0].myCase.Component__c; 
            pm.Project__c = lstNewMapping[0].project; 
            insert pm; 
			
            loadLists(); 
            
            strAddMsg = 'Mapping added successfully'; 
			strAddMsgStyle = 'text-align:center;color: green !important;'; 
            
        }
        catch (Exception ex)
        { 
            strAddMsg = 'The following error occurred when adding mapping: ' + ex.getMessage(); 
            return; 
        } 
       
    }

    public void doEdit()
    {
        
        strEditMsg = '';
        strEditMsgStyle = 'color: green !important;';
        
        for (CaseProductWithProject cwp : lstMappings)
        {
            cwp.inEditMode = false;
            if (cwp.iIndex == iSelectedRow)
            {
                cwp.inEditMode = true;
            }
        }
        
    }
    
    public void doCancelEdit()
    {
        strEditMsg = '';
        strEditMsgStyle = 'color: green !important;';        
        lstMappings[iSelectedRow].inEditMode = false;
    }
    
    public void editDialogClose()
    {
        strEditMsg = '';
        strEditMsgStyle = 'color: green !important;';        
        lstMappings[iSelectedRow].inEditMode = false;
        bShowEditConfirmDialog = false;
    }
    
    public void doSaveEdit()
    {
        
        strEditMsg = '';
        strEditMsgStyle = 'color: green !important;';
        
        // VALIDATE USER INPUT       
        if (isValidMapping(lstMappings[iSelectedRow].myCase.Product_Family__c, 
                           lstMappings[iSelectedRow].myCase.Case_Product_Line__c, 
                           lstMappings[iSelectedRow].myCase.Module__c, 
                           lstMappings[iSelectedRow].myCase.Component__c,
                           true) == false)
        {
            strEditMsg = 'We cannot add this new mapping because there is an existing mapping with the same values and they need to be unique.';
            strEditMsgStyle = 'color:red !important;';   
            bShowEditConfirmDialog = true; 
            return;
        }        
         
        try
        {
            ProductMapping__c pm = [SELECT Id, Name, Product_Family__c, Product__c, Affected_Component__c, Component__c, Project__c 
                                    FROM ProductMapping__c 
                                    WHERE Name =: lstMappings[iSelectedRow].mapName];
            
            pm.Product_Family__c = lstMappings[iSelectedRow].myCase.Product_Family__c;
            pm.Product__c = lstMappings[iSelectedRow].myCase.Case_Product_Line__c;
            pm.Affected_Component__c = lstMappings[iSelectedRow].myCase.Module__c;
            pm.Component__c = lstMappings[iSelectedRow].myCase.Component__c;
            pm.Project__c = lstMappings[iSelectedRow].project;
            
            update pm;   
            
            strEditMsg = 'Mapping updated successfully';
      		bShowEditConfirmDialog = true; 
            
        }
        catch (Exception ex)
        {
            strEditMsg = 'The following error occurred when updating mapping: ' + ex.getMessage();
            strEditMsgStyle = 'color:red !important;';  
			bShowEditConfirmDialog = true;             
            return;            
        }

    }    

    public void deleteConfirm()
    {
        bShowDeleteConfirmDialog = true;
        strDeletionDetails = 'Mapping Name: ' + lstMappings[iSelectedRow].mapName + '<br/>';
        strDeletionDetails += 'Domain: ' + lstMappings[iSelectedRow].myCase.Product_Family__c + '<br/>';
        strDeletionDetails += 'Product: ' + lstMappings[iSelectedRow].myCase.Case_Product_Line__c + '<br/>';
        strDeletionDetails += 'Module: ' + lstMappings[iSelectedRow].myCase.Module__c + '<br/>';
        strDeletionDetails += 'Component: ' + lstMappings[iSelectedRow].myCase.Component__c + '<br/>';
        strDeletionDetails += 'Project: ' + lstMappings[iSelectedRow].project + '<br/>';        
    }

    public void deleteCancel()
    {
        bShowDeleteConfirmDialog = false;
    }

    public void doDelete()
    {
        
        try
        {
system.debug('lstMappings[iSelectedRow].mapName = ' + lstMappings[iSelectedRow].mapName);         
            ProductMapping__c pm = [SELECT Id FROM ProductMapping__c WHERE Name =: lstMappings[iSelectedRow].mapName];

            delete pm;   
            
            loadLists();
            
            strAddMsg = 'Mapping deleted successfully';
      
            bShowDeleteConfirmDialog = false;
            
        }
        catch (Exception ex)
        {
            strAddMsg = 'The following error occurred when deleting mapping: ' + ex.getMessage();
            strAddMsgStyle = 'text-align:center;color: red !important;';              
            return;            
        } 
        
    }    
        
    // page refernce method which will redirect to home page on click of cancel
    public PageReference cancelMapping() 
    {
        String pageUrl = String.valueOf(Apexpages.currentPage().getUrl()); 
        System.debug('****pageURL****' + pageUrl); 
        if (pageUrl != null && pageUrl.contains('lightning.force.com'))
        { 
            return new PageReference('/lightning/page/home?0.source=alohaHeader'); 
        }
        return new PageReference('/home/home.jsp'); 
    }

    // wrapper which is used to display on the mapping page which can be done by admin
    public class CaseProductWithProject 
    {
        
        public String project {get; set;} 
        public Case myCase {get; set;} 
        public String mapName {get; set;} 
        public boolean inEditMode {get; set;} 
        public integer iIndex {get; set;} 
        
        public CaseProductWithProject(Case c, String projectName, String mName, boolean b1, integer i1) 
        {
            project = projectName; 
            myCase = c; 
            mapName = mName; 
            inEditMode = b1; 
            iIndex = i1; 
        }
        
    } 
    
}