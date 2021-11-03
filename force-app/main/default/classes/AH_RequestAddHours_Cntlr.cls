/****************************************************************************************
Name            : AH_RequestAddHours_Cntlr
Author          : Bhuleshwar Deshpande 
Created Date    : 10/17/2019
Last Mod Date   : 10/30/2019  
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : 
Description     : Apex Class AH_RequestAddHours_Cntlr which is a controller for 
: AH_RequestAdditionalHours VF Page.

******************************************************************************************/

public class AH_RequestAddHours_Cntlr {
    
    public List<LayoutSections> lstSections {get; set;} 
    public  SObject sObjectRecord {get; set;}   
    public  String strLayoutFields {get; set;} 
    public  Id strRecordId {get; set;}
    public  String strSObject {get; set;} 
    public  String strSObjectLabel {get; set;}  
    public  Id recordTypeId {get; set;}
    public  Boolean showEditView{get; set;}
    private final Opportunity ahopportunityObj; 

    public string strRecordType{get;set;}
    public String selectedRecordType{get;set;}
    public List<LayoutFields> requiredField{get;set;} 
    public Map<String, String> fieldsMap = new Map<String, String>();
    public Opportunity opportunityObjNew = new Opportunity(); 
    public List<String> fieldsList;
    
    public AH_RequestAddHours_Cntlr(ApexPages.StandardController controller)
    {
        strSObject = 'Opportunity'; 
        showEditView= true;
    }  
    
    // CANCEL BUTTON 
    public Pagereference cancelSave()
    {        
        return new Pagereference('/006/o');
    }
    public void showSelectedRecord() 
    {
        system.debug('strLayoutFields  :' + strLayoutFields );
        lstSections = (List<LayoutSections>)JSON.deserialize(strLayoutFields, List<LayoutSections>.class); 
        
        Schema.DescribeSObjectResult dr = Opportunity.sObjectType.getDescribe();
        
        system.debug('dr : '+dr);
        strSObject = dr.getName(); 
        strSObjectLabel = dr.getLabel(); 
        SObjectType sObjectType = Schema.getGlobalDescribe().get(strSObject); 
        String strQuery = 'SELECT '; 
        system.debug('lstSections : '+ lstSections);
        requiredField = new List<LayoutFields>();
        
        for(LayoutSections objL : lstSections) 
        { 
            List<LayoutFields> lstFieldsTemp = new List<LayoutFields>(); 
            
            for(LayoutFields oField : objL.Fields) 
            {
                if(oField.Field != null && sObjectType.getDescribe().fields.getMap().containsKey(oField.Field))
                { 
                    LayoutFields oLayoutFields = new LayoutFields(); 
                    oLayoutFields.Field = oField.Field; 
                    oLayoutFields.isUpdatable = 'true'; 
                    oLayoutFields.isRequired = oField.isRequired;
                    oLayoutFields.isrender = true; 
                    strQuery += oField.Field + ', ';                   
                    lstFieldsTemp.add(oLayoutFields);
                    if(oField.isRequired=='true')
                    {
                        this.requiredField.add(oLayoutFields);
                    }                                        
                } 
            } 
            objL.Fields = lstFieldsTemp;             
        }
       // CREATE OPP RECORD 
       // 
       system.debug('requiredField : '+requiredField);
        
        
        Opportunity Obj = new Opportunity();
        this.sObjectRecord = (SObject) Obj;
        this.sObjectRecord.clear();
        system.debug('sObjectRecord : '+sObjectRecord);
        
        
        opportunityObjNew = ((Opportunity)this.sObjectRecord).clone(false,false,false,false);
        system.debug('opportunityObjNew : '+opportunityObjNew);
        
        User stuUser = [SELECT ID FROM User WHERE Name = 'Stuart Emery' LIMIT 1];
        
        // ASSIGN VALUES TO SHOW AUTO POPULATED ON EDIT FORM 
        opportunityObjNew.OwnerId = UserInfo.getUserId();
        opportunityObjNew.Name = '- Embrace';
        opportunityObjNew.CloseDate = date.today();
        opportunityObjNew.StageName ='Solution Validation -Prove 60%';
        opportunityObjNew.Type_Custom__c ='After Market';
        opportunityObjNew.Probability = 60;
  		
        system.debug('opportunityObjNew' + opportunityObjNew);
        
        this.sObjectRecord = (SObject) opportunityObjNew;
        
    }

    // CREATE CLONED RECORD HERE
    public PageReference create_RequestOpportunity()
    {
        try
        {
            insert opportunityObjNew;
            String oid= String.valueOf(this.sObjectRecord.get('Id'));
            return new PageReference('/'+opportunityObjNew.Id);
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
            System.debug('The following exception has occurred: ' + e.getMessage());
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