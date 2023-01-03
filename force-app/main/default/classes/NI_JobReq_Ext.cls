/****************************************************************************************
Name            : NI_JobRequisition_Ext Class
Author          : Stuart Emery
Created Date    : 2/6/2015
Last Mod Date   : 5/11/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-013795
Description     : Class that handles events in VF Pages: 
                :    
                :
******************************************************************************************/
public with sharing class NI_JobReq_Ext 
{
    
    //RECORD SPECIFIC VARIABLES ===================================== 
    public NI_Job_Requisition__c jr {get; set;}    
    public Id id;// = System.currentPageReference().getParameters().get('id');
    private ApexPages.StandardController stdCtrl;
    
    public boolean bPrimaryHW {get; set;}
    public boolean bMainHW {get; set;}
    public string rType {get; set;}
    public boolean bSecondaryHW {get; set;}
    public boolean bReplacement {get; set;}
    public boolean bStandardSFLicense {get; set;}
    public boolean bIsNewReq {get; set;}
    public string strMode {get; set;}
    public boolean bFFPSALicenseType {get; set;}
    public boolean bNISalesforceOrgSetup {get; set;}
    public boolean bRenderAttachFile {get; set;}
    public string strAttachmentUploadMessage {get; set;}
    public Blob jobDescription {get; set;}
    public String contentType {get; set;}
    public String fileName {get; set;}
    public boolean bFileName {get; set;}
    public List<Attachment> lstAttachments {get; set;} //LIST TO HOLD THE ATTACHMENT RECORDS FOR THE JOB REQUISITION 
    public NI_Job_Requisition__C j {get; set;}
    public Set<Id> setJrRecordTypeIds = new Set<Id>(); //SET TO HOLD THE RECORD TYPE IDs THAT SHOULD USE THE VISUALFORCE EDIT PAGE
    public String strDepartmentName {get; set;}
    public String strExecApproverName {get; set;}
    
    //LIST TO HOLD THE VALUES FROM THE NI Job Req Record Type VF Edit Page Detail CUSTOM SETTING  
    List<NI_Job_Req_Record_Type_VF_Edit_Page__c> lstCSRecordType = NI_Job_Req_Record_Type_VF_Edit_Page__c.getAll().values();
    Set<String> setCSRecordTypeName = new Set<String>();
    Map<String,String> mapCSRecordType = new Map<String,String>();
    
    //LIST TO HOLD THE VALUES FROM THE NI Job Req Salesforce Apps CUSTOM SETTING  
    List<NI_Job_Req_Salesforce_Apps__c> lstCS = NI_Job_Req_Salesforce_Apps__c.getAll().values();
    Set<String> setCSName = new Set<String>();
    Map<String,String> mapCS = new Map<String,String>();
    
    //LIST TO HOLD THE VALUES FROM THE NI Job Req FF - PSA License Types CUSTOM SETTING  
    List<NI_Job_Req_FF_PSA_License_Types__c> lstCSFFL = NI_Job_Req_FF_PSA_License_Types__c.getAll().values();
    /*    
//LIST TO HOLD THE VALUES FROM THE NI Job Req Chatter Group Post CUSTOM SETTING  
List<NI_Job_Req_Chatter_Group_Post__c> lstCSChatterGroup = NI_Job_Req_Chatter_Group_Post__c.getAll().values();

//SET TO HOLD THE CHATTER GROUP NAMES TO POST THE JOB DESCRIPTION.  
Set<String> setCSChatterGroup = new Set<String>();
*/    
    
    //MAP TO HOLD THE NAME AND LICENSE TYPE FROM THE NI Job Req FF - PSA License Types CUSTOM SETTING
    Map<String,String> mapFFLicense = new Map<String,String>();
    
    //SET TO HOLD THE NAME FROM THE NI Job Req FF - PSA License Types CUSTOM SETTING
    Set<String> setCSFFProfileName = new Set<String>();  
    
    //MAP TO HOLD ALL OF THE FIELDS OF THE JOB REQUISITION OBJECT
    String SobjectApiName = 'NI_Job_Requisition__c';
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
    List<String> lstFieldNames = new List<String>();
    
    //**************************************************************************************************
    //                                       CLASS CONSTRUCTOR
    //**************************************************************************************************
    
    public NI_JobReq_Ext(ApexPages.StandardController stdController)
    {
        
        //if (ApexPages.CurrentPage().getParameters().containsKey('Id')) 
        // {
        id = ApexPages.CurrentPage().getParameters().get('Id');            
        //  } 
        
        //SET INITIAL VARIABLES  
        bMainHW = true;
        bNISalesforceOrgSetup = true;
        
        //POPULATE THE mapFFLicense WITH THE PROFILE NAME AND LICENSE TYPE VALUES FROM THE
        //NI Job Req FF - PSA License Types CUSTOM SETTING 
        for (NI_Job_Req_FF_PSA_License_Types__c c  :  lstCSFFL)
        {
            mapFFLicense.put(c.Name,c.License_Type__c);
            setCSFFProfileName.add(c.Name);  
        }
        
        this.stdCtrl = stdController;
        this.jr = (NI_Job_Requisition__c)stdController.getRecord();
        
        //CALL THE METHOD TO POPULATE THE LIST OF ATTACHMENTS RELATED TO THIS JOB REQUISITION
        getAttachments();
        
        for(NI_Job_Req_Salesforce_Apps__c cs : lstCS)
        {
            setCSName.add(cs.Name);
            mapCS.put(cs.JobRegApiName__c,cs.Name);  
        }
        
        for(NI_Job_Req_Record_Type_VF_Edit_Page__c csRtype : lstCSRecordType)
        {
            setCSRecordTypeName.add(csRtype.Name);
            System.debug('CUSTOM SETTING RECORD TYPE: ' + csRtype.Name);
        }
        /*        
for(NI_Job_Req_Chatter_Group_Post__c csChatterPost : lstCSChatterGroup)
{
setCSChatterGroup.add(csChatterPost.Name);
System.debug('CUSTOM SETTING CHATTER POST: ' + csChatterPost.Name);
}
*/        
        //GET THE JOB REQUISITION RECORD TYPE 
        for(String strRecordTypeName : setCSRecordTypeName)
        {
            if(bRecordTypeFound(strRecordTypeName) == true)
            {
                setJrRecordTypeIds.add(NI_TestClassData.getRecordTypeId('NI_Job_Requisition__c', strRecordTypeName));
            }    
        } 
        System.debug('NUMBER OF RECORD TYPE IDs: ' + setJrRecordTypeIds.size());
        
        for(String fieldName : fieldMap.keyset())
        {
            lstFieldNames.add(fieldName);
        }
        
        if (ApexPages.CurrentPage().getParameters().containsKey('new')) 
        {
            bIsNewReq = true;            
        }
        
        //CALL THE METHOD TO GET THE NAME OF THE EXEC APPROVER FOR THE OUTPUT TEXT FIELD
        execApproverInitialLoad();
        
        //CALL THE METHOD TO GET THE DEPARTMENT DESCRIPTION OUTPUT TEXT FIELD
        departmentDescriptionInitialLoad();
        
    }
    
    //**************************************************************************************************
    //                                       PAGE REDIRECT METHODS
    //**************************************************************************************************
    
    //METHOD TO REDIRECT THE USER TO THE STANDARD NEW PAGE OR CUSTOM VISUALFORCE PAGE
    //WHEN THE NEW BUTTON IS CLICKED
    public PageReference redirectNewPage() 
    { 
        //GET THE OBJECT PREFEX CODE FOR THE JOB REQUISITION OBJECT  
        Schema.DescribeSObjectResult r = NI_Job_Requisition__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        String rType = ApexPages.currentPage().getParameters().get('RecordType');
        if (rType == null) 
        {
            //DETERMINE THE USER'S DEFAULT RECORD TYPE IF NO RECORD TYPE WAS PASSED IN
            List<Schema.RecordTypeInfo> jrRTypes = Schema.SObjectType.NI_Job_Requisition__c.RecordTypeInfos;
            //LOOP THROUGH EACH RECORD TYPE
            for (Schema.RecordTypeInfo rti : jrRTypes) {
                if (rti.isDefaultRecordTypeMapping()) {
                    rType = rti.getRecordTypeId();
                }
            }
        }
        System.debug('NEW JOB REQ RECORD TYPE ID: ' + rType);
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        PageReference newPage;
        
        //if (ApexPages.currentPage().getParameters().get('RecordType') == '012g00000000Z2x')
        if(setJrRecordTypeIds.size()>0 && setJrRecordTypeIds.contains(rType))
        {     
            
            System.debug('Record Type Id: ' + rType);
            createReq(rType);

            
            string strURL = '/apex/NI_JobReq_Edit?id=' +j.id + '&new=1';
            PageReference pageRef = new PageReference(strURL);
            pageRef.setRedirect(true);
            return pageRef; 
        } 
        else 
        {
            System.debug('Record Type Id: ' + rType);
            newPage = new PageReference('/' + keyPrefix + '/e?');
            newPage.getParameters().put('nooverride', '1');
            newPage.getParameters().put('RecordType', rType);
            newPage.getParameters().put('retURL', retURL);
            
            return newPage.setRedirect(true);
            //return null;
        }
        
        //newPage.getParameters().put('id', j.id);
        PageReference pageRef = ApexPages.currentPage();
        return pageRef;
        
    }
    //==================================================================================================================================   
    //METHOD TO REDIRECT THE USER TO THE STANDARD EDIT PAGE OR CUSTOM VISUALFORCE PAGE
    public PageReference redirectEditPage() 
    { 
        //GET THE OBJECT PREFEX CODE FOR THE JOB REQUISITION OBJECT  
        Schema.DescribeSObjectResult r = NI_Job_Requisition__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        NI_Job_Requisition__C jr = [SELECT Id, RecordTypeId
                                    FROM NI_Job_Requisition__c
                                    WHERE Id =: id];
        
        PageReference newPage;
        
        //if (jr.RecordTypeId == '012g00000000Z2x')
        if(setJrRecordTypeIds.size()>0 && setJrRecordTypeIds.contains(jr.RecordTypeId))
        {   
            string strURL = '/apex/NI_JobReq_Edit?id=' + jr.Id;
            PageReference pageRef = new PageReference(strURL);
            pageRef.setRedirect(true);
            return pageRef; 
        } 
        else 
        {
            System.debug('Record Type Id: ' + rType);
            newPage = new PageReference('/' + keyPrefix + '/e?');
            newPage.getParameters().put('nooverride', '1');
            newPage.getParameters().put('id',Id);
            newPage.getParameters().put('retURL', Id);
            return newPage.setRedirect(true);
        }
        
        //newPage.getParameters().put('id', j.id);
        PageReference pageRef = ApexPages.currentPage();
        return pageRef;
    }    
    
    //***********************************END REDIRECT METHODS******************************************************
    
    
    //CREATE JOB NEW JOB REQUISITION METHOD    
    public PageReference createReq(Id idRecordType) 
    { 
        system.debug(' ================  ENTERING NI_JobReq_Ext.createEval() ================ ');
        
        //VARIABLE TO HOLD THE SELECTED RECORD TYPE  
        //if (rType == null)
        //{
        //    rType = ApexPages.currentPage().getParameters().get('RecordType'); 
       // }
        
        User u = [SELECT Id, Name, DepartmentCode__c, NI_Location__c, NI_Office__c, ManagerId 
                  FROM User 
                  WHERE Id =: UserInfo.getUserId()];
        
        system.debug('USER from UserInfo.getUserId() = ' + u); 
        
        //CREATE A NEW JOB REQUISITION RECORD  
        j = new NI_Job_Requisition__c();
        j.OwnerId = UserInfo.getUserId();
        if(bUserDepartment(u.DepartmentCode__c) == true)
        {
            j.Department__c = getUserdepartment(u.DepartmentCode__c).Id;
        }
        else
        {
            j.Department__c = null;  
        }  
        if(bUserLocation(u.NI_Location__c) == true)
        {
            j.NI_Location__c = getUserLocation(u.NI_Location__c).Id;
        }
        else
        {
            j.NI_Location__c = null;
        }
        if(bUserOffice(u.NI_Office__c) == true)
        {
            j.NI_Office__c = getUserOffice(u.NI_Office__c).Id;
        }
        else
        {
            j.NI_Office__c = null;
        }
        j.Manager__c = u.Id;
        j.RecordTypeId = idRecordType;
        System.Debug('INSERT JOB REQ RECORD TYPE ID: ' + rType);
        insert j;
        
        //CALL THE METHOD TO GET THE NAME OF THE EXEC APPROVER FOR THE OUTPUT TEXT FIELD
        //  execApproverInitialLoad();
        
        string strURL = '/apex/NI_JobReq_Edit?id=' +j.id + '&new=1';
        PageReference pageRef = new PageReference(strURL);
        pageRef.setRedirect(true);
        return pageRef; 
        
    }
    
    //=============================================================================================
    //DELETE NEW JOB REQUISITION WHEN CANCEL BUTTON IS CLICKED
    public PageReference deleteJobReq() 
    { 
        Schema.DescribeSObjectResult s = NI_Job_Requisition__c.sObjectType.getDescribe();
        String keyPrefix = s.getKeyPrefix();
        
        //DELETE THE JOB REQUISITION RECORD
        NI_Job_Requisition__c j = [SELECT Id FROM NI_Job_Requisition__c WHERE Id =: id LIMIT 1];  
        delete j;       
        
        PageReference pageRef = new PageReference('/' + keyPrefix);
        pageRef.setRedirect(true);
        return pageRef;
    }      
    //=============================================================================================
    
    //**************************************************************************************************
    //                                       FUNCTIONS
    //**************************************************************************************************                                          
    
    public boolean bRecordTypeFound(String strRtype)
    {
        List<RecordType> lstRecordTypes = [SELECT Id FROM RecordType WHERE Name =:strRtype];
        If(lstRecordTypes.size()>0)
        {
            Return true; 
        }
        else
        {
            Return false;  
        }  
    }
    //=======================================================================================================   
    public boolean bUserDepartment(String depCode)
    {
        List<NI_Departments__c> lstDepartments = [SELECT Id FROM NI_Departments__c WHERE Name =:depCode];
        If(lstDepartments.size()>0)
        {
            Return true; 
        }
        else
        {
            Return false;  
        }  
    }
    
    //===============================================================================================
    public static NI_Departments__c getUserdepartment(String depCode) 
    {
        NI_Departments__c d = [SELECT Id, Name FROM NI_Departments__c WHERE Name =: depCode];
        return d;     
    }
    
    //===============================================================================================    
    public boolean bUserLocation(String location)
    {
        List<NI_Location__c> lstLocations = [SELECT Id FROM NI_Location__c WHERE Name =:location];
        If(lstLocations.size()>0)
        {
            Return true; 
        }
        else
        {
            Return false;  
        }  
    }
    
    //===============================================================================================
    public static NI_Location__c getUserLocation(String location) 
    {
        NI_Location__c l = [SELECT Id, Name FROM NI_Location__c WHERE Name =: location];
        return l;     
    }
    
    //===============================================================================================    
    public boolean bUserOffice(String office)
    {
        List<NI_Office__c> lstOffice = [SELECT Id FROM NI_Office__c WHERE Name =:office];
        If(lstOffice.size()>0)
        {
            Return true; 
        }
        else
        {
            Return false;  
        }  
    }
    
    //===============================================================================================
    public static NI_Office__c getUserOffice(String office) 
    {
        NI_Office__c o = [SELECT Id, Name FROM NI_Office__c WHERE Name =:office];
        return o;     
    }        
    
    //*******************************END FUNCTIONS SECTION************************************************    
    
    
    //****************************************************************************************************
    //                       BOOLEAN METHODS FOR VISUALFORCE PAGE FIELD RENDERING
    //****************************************************************************************************
    
    /*
//PRIMARY HARDWARE
public void showPrimaryHardwareDetails(){
if(jr.Hardware_Required__c == 'Yes'){
bPrimaryHW = true;
}
else
{  
bPrimaryHW = false;
}
}
*/
    //---------------------------------------------------------    
    //MAIN HARDWARE   
    public void mainHardware(){
        if(jr.Main_Hardware__c == 'No Hardware Needed'){
            bMainHW = false;
        }
        else
        {  
            bMainHW = true;
        }
    }
    
    //-----------------------------------------------------------------    
    //SHOW THE NEWMARKET SALESFORCE ORG REASON    
    public void showNewmarketSalesforceOrgReason(){
        if(jr.Newmarket_Salesforce_Org_Required__c == 'Yes'){
            bNISalesforceOrgSetup = true;
        }
        else
        {  
            bNISalesforceOrgSetup = false;
            jr.Mirror_Existing_Salesforce_User__c = null;
            jr.Financialforce_PSA__c = false;
            jr.FunnelSource__c = false;
            jr.Xactly__c = false;
            jr.Apttus__c = false;
            jr.Salesforce_com_License_Type__c = null;
            jr.Financialforce_PSA_License_Type__c = null; 
        }
    }    
    
    //==========================================================================================    
    public void showSecondaryHardwareDetails(){
        if(jr.Secondary_Hardware_Required__c == 'Yes'){
            bSecondaryHW = true;
        }
        else
        {  
            bSecondaryHW = false;
            
        }
    }
    
    //============================================================================================    
    public void showReplacementName(){
        if(jr.Job_Type__c == 'Replacement'){
            bReplacement = true;
            jr.Budgeted_Hire__c = 'Yes';
        }
        else
        {  
            bReplacement = false;
            jr.Budgeted_Hire__c = 'No';
        }
    }
    //=============================================================================================  
    public void checkUserLicenses(){
        String strField;   
        
        Set<String> setUsrLicenses = NI_UserPackageLicense.strUserLicenseNameSpace(jr.Mirror_Existing_Salesforce_User__c);
        strField = 'Financialforce_PSA__c';
        if(setUsrLicenses.contains('pse') == true)
        {
            jr.Financialforce_PSA__c = true;
            bFFPSALicenseType = true;  
        }
        else
        {
            jr.Financialforce_PSA__c = false;
            bFFPSALicenseType = false;  
        }
        
        if(setUsrLicenses.contains('amorgan') == true)
        {
            jr.FunnelSource__c = true; 
        }
        else
        {
            jr.FunnelSource__c = false;   
        }
        
        if(setUsrLicenses.contains('XactlyExpress') == true)
        {
            jr.Xactly__c = true; 
        }
        else
        {
            jr.Xactly__c = false;   
        }
        
        if(setUsrLicenses.contains('Apttus_Config2') == true)
        {
            jr.Apttus__c = true; 
        }
        else
        {
            jr.Apttus__c = false;   
        } 
        
        if(jr.Mirror_Existing_Salesforce_User__c != null)
        {       
            //GET THE PROFILE NAME OF THE SELECTED USER  
            String strUsrProfile = NI_UserPackageLicense.strProfileName(jr.Mirror_Existing_Salesforce_User__c);
            System.debug('COPY EXISTING SALESFORCE USER PROFILE: ' + strUsrProfile);
            
            if(strUsrProfile.contains('Platform') == true)
            {
                jr.Salesforce_com_License_Type__c = 'Platform';
                bStandardSFLicense = false;  
            }
            else
            {
                jr.Salesforce_com_License_Type__c = 'Standard';
                bStandardSFLicense = true;  
            }
            Boolean bProfileName = setCSFFProfileName.contains(strUsrProfile);
            System.debug('PROFILE EXISTS IN FF CUSTOM SETTINGS: ' + bProfileName);
         
            if(setCSFFProfileName.contains(strUsrProfile) && setUsrLicenses.contains('pse') == true)
            {
               jr.Financialforce_PSA_License_Type__c = mapFFLicense.get(strUsrProfile);
                System.Debug('FINACIALFORCE LICENSE TYPE: ' + mapFFLicense.get(strUsrProfile));
            }
            if(setCSFFProfileName.contains(strUsrProfile) == false && setUsrLicenses.contains('pse') == true)
            {
                jr.Financialforce_PSA_License_Type__c = '360° PSA Account View for CRM User';  
            }   
             if(setCSFFProfileName.contains(strUsrProfile) == false && setUsrLicenses.contains('pse') == false)
            {
                jr.Financialforce_PSA_License_Type__c = null;  
            }
        }
        else
        {
            jr.Salesforce_com_License_Type__c = null;  
        }
        
    }
    //=============================================================================================  
    public void changeSalesforceLicenseType(){
        if(jr.Salesforce_com_License_Type__c == 'Standard'){
            bStandardSFLicense = true;
        }
        else
        {  
            bStandardSFLicense = false;
        }
    }
    //===================================================================================    
    public void showFinancialforcePSALicenseOptions(){
        if(jr.Financialforce_PSA__c == True){
            bFFPSALicenseType = true;
            
        }
        else
        {  
            bFFPSALicenseType = false;
            jr.Financialforce_PSA_License_Type__c = null; 
        }
    }
    //========================================================================================
    public pageReference hasFileName(){
        
        If(fileName != null)
        {
            bFileName = true;  
        } 
        else
        {
            bFileName = false;  
        }      
        return null;
    }
    
    //=============================================================================================
    public PageReference getExecApprover() 
    {                
        System.debug('DEPARTMENT ID: ' + jr.Department__c);
        System.debug('LOCATION ID: ' + jr.NI_Location__c); 
        if(jr.NI_Location__c != null && jr.Department__c != null)
        {
            Id idExecApprover = NI_FUNCTIONS.getExecMember(jr.NI_Location__c,jr.Department__c); 
            jr.Exec_Approver__c = idExecApprover;
            strExecApproverName = getExecApproverName(idExecApprover);
        }
        if(jr.Department__c != null)        
        {
            strDepartmentName = getDepartmentDescription(jr.Department__c);
        }
        return null; 
    }
    
    //========================================================================================
    public pageReference hideAddAttachment(){
        bRenderAttachFile = false;
        return null;
    }
    
    //========================================================================================
    public pageReference changeManager()
    {
        User mgr = [SELECT Id, DepartmentCode__c, NI_Location__c
                    FROM User
                    WHERE Id =: jr.Manager__c];
        
        if(bUserDepartment(mgr.DepartmentCode__c) == true)
        {
            jr.Department__c = getUserdepartment(mgr.DepartmentCode__c).Id;
        }
        else
        {
            jr.Department__c = null;  
        }  
        if(bUserLocation(mgr.NI_Location__c) == true)
        {
            jr.NI_Location__c = getUserLocation(mgr.NI_Location__c).Id;
        }
        else
        {
            jr.NI_Location__c = null;    
            
        }
        getExecApprover(); //GET THE EXEC APPROVER BASED ON THE MANAGER CHANGE
        return null;
    }   
    //======================================================================================== 
    
    //*******************************************************************************************************
    //                                    CREATE RELATED RECORDS METHODS
    //*******************************************************************************************************
    public PageReference uploadAttachment() {
        
        Attachment attach = new Attachment();
        attach.Body = jobDescription;
        attach.Name = filename;
        //attach.ContentType=contentType;
        attach.ParentId = jr.Id;
        
        try {
            insert attach;
        } catch (DMLException e) {
            strAttachmentUploadMessage = 'Error uploading attachment ' + e;
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            return null;
        } 
        strAttachmentUploadMessage = '';
        jobDescription = null;
        getAttachments();
        return null;
    }
    //========================================================================================
    public PageReference createChatterPost() 
    { 
        
        //LIST TO HOLD THE VALUES FROM THE NI Job Req Chatter Group Post CUSTOM SETTING  
        List<NI_Job_Req_Chatter_Group_Post__c> lstCSChatterGroup = NI_Job_Req_Chatter_Group_Post__c.getAll().values();
        
        //SET TO HOLD THE CHATTER GROUP NAMES TO POST THE JOB DESCRIPTION.  
        Set<String> setCSChatterGroup = new Set<String>();
        
        for(NI_Job_Req_Chatter_Group_Post__c csChatterPost : lstCSChatterGroup)
        {
            setCSChatterGroup.add(csChatterPost.Name);
            System.debug('CUSTOM SETTING CHATTER POST: ' + csChatterPost.Name);
        }
        
        
        NI_Job_Requisition__c j = [SELECT Id, Job_Title__c, Job_Posting_URL__c FROM NI_Job_Requisition__c WHERE Id =: jr.Id];
        
        List<Attachment> lstAttachments = [SELECT Id, Name, Body FROM Attachment WHERE ParentId =: j.Id];       
        CollaborationGroup cg = [SELECT Id FROM CollaborationGroup WHERE Name IN: setCSChatterGroup LIMIT 1];
        
        if(lstAttachments.size()>0)
        {
            
            //CREATE A NEW CHATTER POST IN ALL NEWMARKET WITH JOB POSTITION ATTACHMENT  
            FeedItem post = new FeedItem();
            post.ParentId = cg.Id;
            post.Body = 'Career Opportunity: ' + j.Job_Title__c + '. Check out the link below for details';
            post.LinkUrl = j.Job_Posting_URL__c;
            post.ContentData = lstAttachments[0].body;
            post.ContentFileName = lstAttachments[0].Name;
            
            try {
                insert post;
            } catch (DMLException e) {
                System.debug('ERROR POSTING FILE TO CHATTER: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error posting file to All Newmarket International Chatter Group'));
                return null;
            }      
        } 
        PageReference pageRef = new PageReference('/' + cg.Id);
        pageRef.setRedirect(true);
        return pageRef;
        
        return null;
    }
    
    //=============================================================================================
    public PageReference sendToIT() 
    {                
        NI_Job_Requisition__c j = [SELECT Id, Status__c, IT_Status__c FROM NI_Job_Requisition__c WHERE Id =: jr.Id];
        
        if(j.Status__c != 'Closed' || j.IT_Status__c == null)
        {
            j.Status__c = 'Closed'; 
            j.IT_Status__c = 'Submitted to IT';
            try {
                update j;
            } catch (DMLException e) {
                System.debug('ERROR SUBMITTING TO IT:' + e.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Closing Requisition and Submitting to IT'));
                return null;
            }          
        }
        PageReference pageRef = new PageReference('/' + j.Id);
        pageRef.setRedirect(true);
        return pageRef;
        return null; 
    }             
    //==========================================================================================
    //QUERY TO RETURN A LIST OF ATTACHMENT RECORDS
    public List<Attachment> getAttachments() 
    {
        
        lstAttachments = [SELECT Id, Name, Body
                          FROM Attachment
                          WHERE ParentId =: jr.Id 
                          ORDER BY Name ASC];
        
        return lstAttachments;                                  
    }
    
    //========================================================================================
    public pageReference departmentDescriptionInitialLoad()
    {
        List<NI_Job_Requisition__c> lstJobReqs = [SELECT Id, Department__c
                                                  FROM NI_Job_Requisition__c
                                                  WHERE Id =: jr.Id
                                                  AND Department__c != Null];
        
        if(lstJobReqs.size()>0)
        {
            strDepartmentName = getDepartmentDescription(lstJobReqs[0].Department__c);
        }    
        
        return null;
    }   
    //==========================================================================================
    public static String getDepartmentDescription(Id idDepartment)
    {
        String depDescription;
        if(idDepartment != null)
        {  
            //SET TO HOLD THE DEPARTMENT TO LOCATION IDs 
            List<NI_Departments__c> lstDepartments = [SELECT Id, Description__c FROM NI_Departments__c WHERE Id =:idDepartment];  
            if(lstDepartments.size()>0)
            {   
                depDescription = lstDepartments[0].Description__c;
                return depDescription;  
            }
        }
        return null; 
    }
    
    //========================================================================================
    public pageReference execApproverInitialLoad()
    {
        List<NI_Job_Requisition__c> lstJobReqs = [SELECT Id, Exec_Approver__c
                                                  FROM NI_Job_Requisition__c
                                                  WHERE Id =: jr.Id
                                                  AND Exec_Approver__c != Null];
        
        if(lstJobReqs.size()>0)
        {
            strExecApproverName = getExecApproverName(lstJobReqs[0].Exec_Approver__c);
        }    
        
        return null;
    }   
    
    //==========================================================================================
    public static String getExecApproverName(Id idExec)
    {
        String strExecName;
        if(idExec != null)
        {  
            User u = [SELECT Id, Name FROM User WHERE Id =:idExec];  
            
            strExecName = u.Name;
            return strExecName;  
        }
        return null; 
    }
    
    //==================================================================================================================================================    
    //CLONE JOB NEW JOB REQUISITION METHOD    
    public PageReference cloneStandardReq() 
    { 
        system.debug(' ================  ENTERING NI_JobReq_Ext.cloneReq() ================ ');
        
        //GET THE JOB REQUISITION RECORD TYPE ID FOR THE "STANDARD - OPEN" RECORD TYPE
        Id rtIdStandard = NI_TestClassData.getRecordTypeId('NI_Job_Requisition__c', 'Standard');
        
        NI_Job_Requisition__c clone = [SELECT Id,RecordTypeId,OwnerId,Department__c,Dinero_User__c,Employment_Type__c,Exec_Approver__c,HotSOS_ASP__c,NI_Location__c,Main_Hardware__c,
                                       Manager__c,MTech_Salesforce_Org_Access__c,MTech_Salesforce_Org_Reason__c,Copy_Existing_MTech_Salesforce_User__c,MTech_Dev_VPN_Miami__c,
                                       MTech_Google_Apps__c,MTech_Sandbox_Environments__c,Newmarket_Salesforce_Org_Required__c,Newmarket_Salesforce_Org_Reason__c,
                                       Mirror_Existing_Salesforce_User__c,NI_Office__c,No_Hardware_Reason__c,Salesforce_com_License_Type__c,Secondary_Hardware__c,
                                       Job_Title__c,Apttus__c,Financialforce_Accounting__c,Financialforce_PSA__c,Financialforce_PSA_License_Type__c,FunnelSource__c,
                                       Xactly__c,Dynamics_GL__c,Webex__c,Softrax__c,MSDN_License__c,MSDN_License_Options__c,Existing_Employee_AD_Groups__c,
                                       Conference_Calling_Account__c,Additional_Requirements_Notes_to_IT__c
                                       FROM NI_Job_Requisition__c
                                       WHERE Id =: jr.Id];
        
        //CREATE A NEW JOB REQUISITION RECORD  
        j = new NI_Job_Requisition__c();
        j.RecordTypeId = rtIdStandard;
        j.OwnerId = clone.OwnerId;
        j.Department__c = clone.Department__c;
        j.Dinero_User__c = clone.Dinero_User__c;
        j.Employment_Type__c = clone.Employment_Type__c;
        j.Exec_Approver__c = clone.Exec_Approver__c;
        j.HotSOS_ASP__c = clone.HotSOS_ASP__c;
        j.NI_Location__c = clone.NI_Location__c;
        j.Main_Hardware__c = clone.Main_Hardware__c;
        j.Manager__c = clone.Manager__c;
        j.MTech_Salesforce_Org_Access__c = clone.MTech_Salesforce_Org_Access__c;
        j.MTech_Salesforce_Org_Reason__c = clone.MTech_Salesforce_Org_Reason__c;
        j.Copy_Existing_MTech_Salesforce_User__c = clone.Copy_Existing_MTech_Salesforce_User__c;
        j.MTech_Dev_VPN_Miami__c = clone.MTech_Dev_VPN_Miami__c;
        j.MTech_Google_Apps__c = clone.MTech_Google_Apps__c;
        j.MTech_Sandbox_Environments__c = clone.MTech_Sandbox_Environments__c;
        j.Newmarket_Salesforce_Org_Required__c = clone.Newmarket_Salesforce_Org_Required__c;
        j.Newmarket_Salesforce_Org_Reason__c = clone.Newmarket_Salesforce_Org_Reason__c;
        j.Mirror_Existing_Salesforce_User__c = clone.Mirror_Existing_Salesforce_User__c;
        j.NI_Office__c = clone.NI_Office__c;
        j.No_Hardware_Reason__c = clone.No_Hardware_Reason__c;
        j.Salesforce_com_License_Type__c = clone.Salesforce_com_License_Type__c;
        j.Secondary_Hardware__c = clone.Secondary_Hardware__c;
        j.Job_Title__c = clone.Job_Title__c;
        j.Apttus__c = clone.Apttus__c;
        j.Financialforce_Accounting__c = clone.Financialforce_Accounting__c;
        j.Financialforce_PSA__c = clone.Financialforce_PSA__c;
        j.Financialforce_PSA_License_Type__c = clone.Financialforce_PSA_License_Type__c;
        j.FunnelSource__c = clone.FunnelSource__c;
        j.Xactly__c = clone.Xactly__c;
        j.Dynamics_GL__c = clone.Dynamics_GL__c;
        j.Webex__c = clone.Webex__c;
        j.Softrax__c = clone.Softrax__c;
        j.MSDN_License__c = clone.MSDN_License__c;
        j.MSDN_License_Options__c = clone.MSDN_License_Options__c;
        j.Existing_Employee_AD_Groups__c = clone.Existing_Employee_AD_Groups__c;
        j.Conference_Calling_Account__c = clone.Conference_Calling_Account__c;
        j.Additional_Requirements_Notes_to_IT__c = clone.Additional_Requirements_Notes_to_IT__c;
        insert j;
        
        string strURL = '/apex/NI_JobReq_Edit?id=' +j.id + '&new=1';
        PageReference pageRef = new PageReference(strURL);
        pageRef.setRedirect(true);
        return pageRef; 
        
    }
    
    //==================================================================================================================================================    
    //CREATE INACTIVE USER IN SALESFORCE METHOD    
    public PageReference createSalesforceUser() 
    { 
        system.debug(' ================  ENTERING NI_JobReq_Ext.createSalesforceUser() ================ ');
        
        NI_Job_Requisition__c jobReq = [SELECT Id,Department__r.Name, NI_Location__r.Name,Manager__c,Newmarket_Salesforce_Org_Required__c,
                                        Mirror_Existing_Salesforce_User__c,NI_Office__r.Name, Employee_First_Name__c,Employee_Last_Name__c,
                                        Job_Title__c
                                        FROM NI_Job_Requisition__c
                                        WHERE Id =: jr.Id
                                        AND Newmarket_Salesforce_Org_Required__c = 'Yes'];
        
        String strEmail = jobReq.Employee_First_Name__c.substring(1,1) + jobReq.Employee_Last_Name__c + '@newmarketinc.com';
        String ADusername = jobReq.Employee_First_Name__c.substring(1,1) + jobReq.Employee_Last_Name__c;
        String strAlias = ADusername.substring(1,5);
        
        User copyUser = [SELECT Id, ProfileId, UserRoleId, LocaleSidKey, EmailEncodingKey, TimeZoneSidKey, CurrencyIsoCode, LanguageLocaleKey
                         FROM User
                         WHERE Id =: jobReq.Mirror_Existing_Salesforce_User__c];
        
        //CREATE A NEW JOB REQUISITION RECORD  
        User newUser = new User();
        newUser.FirstName = jobReq.Employee_First_Name__c;
        newUser.LastName = jobReq.Employee_Last_Name__c;
        newUser.Email = strEmail;
        newUser.UserName = strEmail;
        newUser.ADUserName__c = ADusername;
        newUser.Title = jobReq.Job_Title__c;
        newUser.ManagerId = jobReq.Manager__c;
        newUser.IsActive = False;
        newUser.ProfileId = copyUser.ProfileId;
        newUser.UserRoleId = copyUser.UserRoleId;
        newUser.DepartmentCode__c = jobReq.Department__r.Name;
        newUser.NI_Location__c = jobReq.NI_Location__r.Name;
        newUser.NI_Office__c = jobReq.NI_Office__r.Name;
        newUser.Alias = strAlias;
        newUser.LocaleSidKey = copyUser.LocaleSidKey;
        newUser.EmailEncodingKey = copyUser.EmailEncodingKey;
        newUser.TimeZoneSidKey = copyUser.TimeZoneSidKey;
        newUser.CurrencyIsoCode = copyUser.CurrencyIsoCode;
        newUser.LanguageLocaleKey = copyUser.LanguageLocaleKey;
        insert newUser;
        
        string strURL = '/' + jobReq.id;
        PageReference pageRef = new PageReference(strURL);
        pageRef.setRedirect(true);
        return pageRef; 
        
    }    
    
    
}