/****************************************************************************************
Name            : AH_New_NI_Change_Control_Request_Cntlr Class
Author          : Shashikant Nikam
Created Date    : 09/18/2019
Last Mod Date   : 09/18/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Controller for AH_New_NI_Change_Control_Request VF Page
				: 
******************************************************************************************/
  
public class AH_New_NI_Change_Control_Request_Cntlr {

    public List<LayoutSections> lstSections {get; set;} 
    public SObject sObjectRecord {get; set;}   
    public String strLayoutFields {get; set;}
    //public Id strRecordId {get; set;}
    public String strSObject {get; set;} 
    public String strSObjectLabel {get; set;}  
    public Id recordTypeId {get; set;} 
    public Boolean showEditView{get; set;}
    private final NI_Change_Control__c niccObj;
    
    public string strRecordType{get;set;}
    public String selectedRecordType{get;set;}  
    public List<LayoutFields> requiredField{get;set;} 
	public Map<String, String> fieldsMap = new Map<String, String>();
    public NI_Change_Control__c niccObjNew = new NI_Change_Control__c();
    public List<String> fieldsList;
    
    public AH_New_NI_Change_Control_Request_Cntlr(ApexPages.StandardController controller)
    {
        strSObject = 'NI_Change_Control__c';
        showEditView= true;
        
        if(ApexPages.currentPage().getParameters().get('rt')!=null && ApexPages.currentPage().getParameters().get('rt') !='')
        {
            recordTypeId =  ApexPages.currentPage().getParameters().get('rt').escapeHtml4();            
        }
        else
        {
            system.debug('Record Type ID not found...');
        }
        system.debug('recordTypeId : '+recordTypeId);
        
        selectedRecordType=[select Name from recordType where id=:recordTypeId].Name;            
        this.strRecordType=recordTypeId;

        this.niccObj = (NI_Change_Control__c)controller.getRecord();

        system.debug('this.niccObj : '+this.niccObj);
    }
    
    // CANCEL BUTTON 
    public Pagereference cancelSave()
    {        
        return new Pagereference('/a0s/o');
    }
    
	
    public void showSelectedRecord()
    {
        system.debug('strLayoutFields : '+strLayoutFields);
        
        lstSections = (List<LayoutSections>)JSON.deserialize(strLayoutFields, List<LayoutSections>.class);
        
        Schema.DescribeSObjectResult dr = NI_Change_Control__c.sObjectType.getDescribe();
        
        //system.debug('dr : '+dr);
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
                    //strQuery += oField.Field + ', ';                   
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
        
        NI_Change_Control__c obj = new NI_Change_Control__c();
        this.sObjectRecord = (SObject) obj;
        this.sObjectRecord.clear();
        this.sObjectRecord.put('RecordTypeId',recordTypeId);
        system.debug('sObjectRecord : '+sObjectRecord);
        
        niccObjNew = ((NI_Change_Control__c)this.sObjectRecord).clone(false,false,false,false);
        system.debug('niccObjNew : '+niccObjNew);
        
        User stuUser = [SELECT ID FROM User WHERE Name = 'Stuart Emery' LIMIT 1];
        
        // ASSIGN VALUES TO SHOW AUTO POPULATED ON EDIT FORM 
        niccObjNew.OwnerId = UserInfo.getUserId();
        niccObjNew.Salesforce_Application__c = 'Salesforce';
        niccObjNew.Change_Steps__c = 'Deploy related changes from the Development Sandbox.';
        niccObjNew.Test_Plan__c = 'Confirm standard work flows are functioning as designed per the related \'NI Project Backlog\' record.';
        niccObjNew.Rollback_Plan__c = 'Undeploy related functionality.';
        niccObjNew.Change_Reason__c = 'Additional Functionality';
        niccObjNew.Priority__c = 'Medium';
        niccObjNew.Date_Required__c = Date.today().addDays(7);
        niccObjNew.NI_Change_Owner__c = stuUser.id;
        niccObjNew.Approval_Status__c = 'Not Submitted';
        niccObjNew.Change_Status__c = 'Open';
        
        this.sObjectRecord = (SObject) niccObjNew;
    }

    // SAVE BUTTON 
    // CREATE NI_Change_Control__c RECORD HERE
    public PageReference create_NI_Change_Control()
    {
        try
        {
			insert niccObjNew;
            String oid= String.valueOf(this.sObjectRecord.get('Id'));
            return new PageReference('/'+niccObjNew.Id);
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
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