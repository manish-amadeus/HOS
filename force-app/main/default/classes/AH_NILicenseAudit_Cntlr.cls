/****************************************************************************************
Name            : AH_NILicenseAudit_Cntlr
Author          : Bhuleshwar Deshpande 
Created Date    : 09/30/2019
Last Mod Date   :   
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : 
Description     : Apex Class AH_NILicenseAudit_Cntlr which is a controller for 
: AH_NILicenseAudit VF Page.

******************************************************************************************/

public class AH_NILicenseAudit_Cntlr {
    
    public List<LayoutSections> lstSections {get; set;} 
    public  SObject sObjectRecord {get; set;}   
    public  String strLayoutFields {get; set;} 
    public  Id strRecordId {get; set;}
    public  String strSObject {get; set;} 
    public  String strSObjectLabel {get; set;}   
    public  Id recordTypeId {get; set;} 
    public  Boolean showEditView{get; set;}
    private final NI_License_Audit__c ahnilincenseauditObj; 
    
    public string strRecordType{get;set;}
    public String selectedRecordType{get;set;}  
    public List<LayoutFields> requiredField{get;set;} 
    public Map<String, String> fieldsMap = new Map<String, String>();
    public NI_License_Audit__c nilisenauditObjNew = new NI_License_Audit__c(); 
    public List<String> fieldsList;
    
    public AH_NILicenseAudit_Cntlr(ApexPages.StandardController controller)
    {
        strSObject = 'NI_License_Audit__c'; 
        showEditView= true;
    }  
    
    
    // CANCEL BUTTON 
    public Pagereference cancelSave()
    {        
        return new Pagereference('/a8O/o');
    }
    
    public void showSelectedRecord() 
    {
        system.debug('strLayoutFields  :' + strLayoutFields );
        lstSections = (List<LayoutSections>)JSON.deserialize(strLayoutFields, List<LayoutSections>.class); 
        
        Schema.DescribeSObjectResult dr = NI_License_Audit__c.sObjectType.getDescribe();
        
        
        strSObject = dr.getName(); 
        strSObjectLabel = dr.getLabel();
        
        SObjectType sObjectType = Schema.getGlobalDescribe().get(strSObject); 
        
        system.debug('lstSections : '+ lstSections);
        requiredField = new List<LayoutFields>();
        
        for(LayoutSections objL : lstSections) 
        { 
            List<LayoutFields> lstFieldsTemp = new List<LayoutFields>(); 
            
            for(LayoutFields oField : objL.Fields) 
            {
                system.debug('oField : '+oField.Field);
                
                if(oField.Field != null && sObjectType.getDescribe().fields.getMap().containsKey(oField.Field))
                { 
                    LayoutFields oLayoutFields = new LayoutFields(); 
                    oLayoutFields.Field = oField.Field; 
                    oLayoutFields.isUpdatable = 'true'; 
                    oLayoutFields.isRequired = oField.isRequired;
                    oLayoutFields.isrender = true; 
                    lstFieldsTemp.add(oLayoutFields);
                    if(oField.isRequired=='true')
                    {
                        this.requiredField.add(oLayoutFields);
                    }                                        
                }   
            }   
            objL.Fields = lstFieldsTemp;             
        }
        
        system.debug('requiredField : '+requiredField);
        
        
        NI_License_Audit__c Obj = new NI_License_Audit__c();
        this.sObjectRecord = (SObject) Obj;
        this.sObjectRecord.clear();
        system.debug('sObjectRecord : '+sObjectRecord);
        
        
        nilisenauditObjNew = ((NI_License_Audit__c)this.sObjectRecord).clone(false,false,false,false);
        system.debug('nilisenauditObjNew : '+nilisenauditObjNew);
        
        User stuUser = [SELECT ID FROM User WHERE Name = 'Stuart Emery' LIMIT 1];
        
        // ASSIGN VALUES TO SHOW AUTO POPULATED ON EDIT FORM 
        nilisenauditObjNew.OwnerId = UserInfo.getUserId();
        nilisenauditObjNew.Phase__c = 'Pending Customer Approval';
        nilisenauditObjNew.Audit_Origin__c='Internal';
        this.sObjectRecord = (SObject) nilisenauditObjNew;
        
    }  
    
    // CREATE SAVE RECORD HERE
    public PageReference create_NILicenseAudit()
    {
        try
        {
            insert nilisenauditObjNew;
            String oid= String.valueOf(this.sObjectRecord.get('Id')); 
            return new PageReference('/'+nilisenauditObjNew.Id); 
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
            
            System.debug('****** Exception Caught :   '+e.getMessage());

        }
        
        return null;
    }
    public class LayoutSections 
    {
        public String header {get; set;} 
        public String columns {get; set;} 
        public List<LayoutFields> fields {get; set;} 
    } 
    public class LayoutFields 
    {
        public String field {get; set;} 
        public String isUpdatable {get; set;} 
        public String isRequired {get; set;} 
        public boolean isRender {get; set;} 
    }
    
    
}