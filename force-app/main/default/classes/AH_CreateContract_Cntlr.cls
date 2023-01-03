/****************************************************************************************
Name            : AH_CreateContract_Cntlr
Author          : Bhuleshwar Deshpande 
Created Date    : 09/16/2019
Last Mod Date   : 09/18/2019
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : 
Description     : Apex Class AH_CreateContract_Cntlr which is a controller for 
: AH_CreateContract VF Page.

******************************************************************************************/
  
public class AH_CreateContract_Cntlr {
    
    public List<LayoutSections> lstSections {get; set;} 
    public  SObject sObjectRecord {get; set;}   
    public  String strLayoutFields {get; set;} 
    public  Id strRecordId {get; set;}
    public  String strSObject {get; set;} 
    public  String strSObjectLabel {get; set;}  
    public  Id recordTypeId {get; set;} 
    public  Boolean showEditView{get; set;}
    private final Contract ahcontractObj; 
    
    public string strRecordType{get;set;}
    public String selectedRecordType{get;set;}  
    public List<LayoutFields> requiredField{get;set;} 
    public Map<String, String> fieldsMap = new Map<String, String>();
    public Contract contractObjNew = new Contract(); 
    public List<String> fieldsList;
    
    public AH_CreateContract_Cntlr(ApexPages.StandardController controller)
    {
        strSObject = 'Contract'; 
        
        system.debug('Current Page Record ID   :'  + ApexPages.currentPage().getParameters().get('oppid'));
        if(ApexPages.currentPage().getParameters().get('oppid') != null && ApexPages.currentPage().getParameters().get('oppid') !='')
        {
            showEditView= true;
            strRecordId = ApexPages.currentPage().getParameters().get('oppid');
            system.debug('strRecordId : '+strRecordId);

        }
        
        this.ahcontractObj = (Contract)controller.getRecord(); 
    }  
    
    // CANCEL BUTTON 
    public Pagereference cancelSave()
    {        
        return new Pagereference('/'+ApexPages.currentPage().getParameters().get('oppid')); 
    }
    public void showSelectedRecord() 
    {
        system.debug('strLayoutFields  :' + strLayoutFields );
        lstSections = (List<LayoutSections>)JSON.deserialize(strLayoutFields, List<LayoutSections>.class); 
        
        Schema.DescribeSObjectResult dr = Contract.sObjectType.getDescribe();
        
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
        if(strRecordId != null)
        {
            
            Contract ct = new Contract();
            this.sObjectRecord = (SObject) ct;
            this.sObjectRecord.clear();
            contractObjNew = ((Contract)this.sObjectRecord).clone(false,false,false,false);
            //QUERY ON OPPORTUNITY
            String oppQuery = 'select id, Name,'+'Account.BillingState,Account.BillingCity,Account.BillingStreet,Account.BillingPostalCode,Account.BillingCountry,'+'Account.Name '+'FROM Opportunity '+' WHERE ID = \''+strRecordId +'\'';
            Opportunity oppRecord = database.query(oppQuery);
            contractObjNew.OwnerId = UserInfo.getUserId();
            contractObjNew.Name = oppRecord.Name;
            contractObjNew.AccountId = oppRecord.AccountId;
            contractObjNew.BillingCity = oppRecord.Account.BillingCity;
            contractObjNew.BillingCountry = oppRecord.Account.BillingCountry;
            contractObjNew.BillingPostalCode = oppRecord.Account.BillingPostalCode;
            contractObjNew.BillingStreet  = oppRecord.Account.BillingStreet ;

            this.sObjectRecord = (SObject) contractObjNew;
            
        }
    }

    // CREATE CLONED RECORD HERE
    public PageReference create_Contract()
    {
        try
        {
            insert contractObjNew;
            String oid= String.valueOf(this.sObjectRecord.get('Id'));
            return new PageReference('/'+contractObjNew.Id);
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