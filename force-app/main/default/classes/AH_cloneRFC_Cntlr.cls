/****************************************************************************************
Name            : AH_cloneRFC_Cntlr Class
Author          : Shashikant Nikam
Created Date    : 09/09/2019
Last Mod Date   : 09/16/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Controller for AH_cloneRFC Lightning component
				: 
******************************************************************************************/
  
public with sharing class AH_cloneRFC_Cntlr
{
    public List<LayoutSections> lstSections {get; set;} 
    public SObject sObjectRecord {get; set;}   
    public String strLayoutFields {get; set;} 
    public Id strRecordId {get; set;}
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
    
    public AH_cloneRFC_Cntlr(ApexPages.StandardController controller)
    {
        strSObject = 'NI_Change_Control__c';

        if(ApexPages.currentPage().getParameters().get('Id') != null && ApexPages.currentPage().getParameters().get('Id') !='')
        {
            showEditView= true;
            strRecordId = ApexPages.currentPage().getParameters().get('Id');
            system.debug('strRecordId : '+strRecordId);
            String strQuery = '';
            strQuery += 'SELECT Id, RecordTypeId FROM ' + strSObject + ' WHERE Id =: strRecordId'; 
            sObjectRecord = database.query(strQuery); 
            
            if(ApexPages.currentPage().getParameters().get('rt')!=null && ApexPages.currentPage().getParameters().get('rt') !='')
            {
                recordTypeId =  ApexPages.currentPage().getParameters().get('rt').escapeHtml4();            
            }
            else
            {
                recordTypeId = String.valueOf(sObjectRecord.get('RecordTypeId'));
            }
            selectedRecordType=[select Name from recordType where id=:recordTypeId].Name;            
            this.strRecordType=recordTypeId;                                    
            
        }
        
        this.niccObj = (NI_Change_Control__c)controller.getRecord();

        system.debug('this.niccObj : '+this.niccObj);
        
        fieldsMap.put('Requester__c','Requester__c');
        fieldsMap.put('Request_Summary__c','Request_Summary__c');
        fieldsMap.put('Request_Details__c','Request_Details__c');
        fieldsMap.put('Priority__c','Priority__c');
        fieldsMap.put('Deployment_Group__c','Deployment_Group__c');
        fieldsMap.put('Platform__c','Platform__c');
        fieldsMap.put('Data_Change__c','Data_Change__c');
        fieldsMap.put('Change_Type__c','Change_Type__c');
        fieldsMap.put('Detail_Change_Type__c','Detail_Change_Type__c');
        fieldsMap.put('Outage_Required__c','Outage_Required__c');
        fieldsMap.put('New_Custom_Script__c','New_Custom_Script__c');
        fieldsMap.put('Manager_Reviewer__c','Manager_Reviewer__c');
        fieldsMap.put('Peer_Reviewer__c','Peer_Reviewer__c');
        fieldsMap.put('Name','Name');
        fieldsMap.put('Developer_Compiler__c','Developer_Compiler__c');
        fieldsMap.put('Related_Servers__c','Related_Servers__c');
        fieldsMap.put('Product__c','Product__c');
        fieldsMap.put('Change_Status__c','Change_Status__c');
        fieldsMap.put('Cloned__c','Cloned__c');
        fieldsMap.put('Cloned_From__c','Cloned_From__c');
        fieldsMap.put('OwnerId','OwnerId');
        fieldsMap.put('RecordTypeId','RecordTypeId');
        
        retrieveAllFields();
            
    }
    
    // CANCEL BUTTON 
    public Pagereference cancelSave()
    {        
        return new Pagereference('/'+ApexPages.currentPage().getParameters().get('Id'));
    }
    
	
    // DISPLAY THE FORM IN EDIT MODE WITH PRE POPULATED VALUES USING LAYOUT SECTIONS
    public void showSelectedRecord() 
    {
        system.debug('strLayoutFields : '+strLayoutFields);
        lstSections = (List<LayoutSections>)JSON.deserialize(strLayoutFields, List<LayoutSections>.class); 
        Schema.SObjectType token;
        if(strRecordId != null)
        {
            token = strRecordId.getSObjectType();
        }
        
        Schema.DescribeSObjectResult dr = token.getDescribe(); 
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
                system.debug('oField : '+oField.Field);
                
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
        
        system.debug('requiredField : '+requiredField);
        
        if(strRecordId != null)
        {
            strQuery += 'Id FROM ' + strSObject + ' WHERE Id =: strRecordId';
            sObjectRecord = database.query(strQuery); 
            this.sObjectRecord.put('RecordTypeId',recordTypeId);
            
            niccObjNew = ((NI_Change_Control__c)this.sObjectRecord).clone(false,false,false,false);
            system.debug('niccObjNew : '+niccObjNew);

            Map<String, Object> fieldsToValue = niccObjNew.getPopulatedFieldsAsMap();
            for(String s : fieldsToValue.keySet())
            {
                system.debug(s +' : '+niccObjNew.get(s));

				if(!fieldsMap.containsKey(s)  &&  fieldsList.contains(s) ) //&&  s != 'HasAllArtifacts__c' && s != 'Ready_for_Manager_Reviewer_Approval__c' && s!= 'Request_for_Standard_Change__c' ) 
                {
                    if(!Test.isRunningTest()){
                    	system.debug('Not in my list : '+s);
                    	niccObjNew.put(s, null);
                    }
                }
            }
            niccObjNew.Cloned__c = true;
            niccObjNew.OwnerId = UserInfo.getUserId();
            system.debug('fieldsToValue : '+fieldsToValue);

            this.sObjectRecord = (SObject) niccObjNew;
            
        }
    }

    // CREATE CLONED RECORD HERE
    public PageReference create_NI_Change_Control()
    {
        try
        {
			insert niccObjNew;
            String oid= String.valueOf(this.sObjectRecord.get('Id'));
            //system.debug('niccObjNew : '+niccObjNew);

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
    

    // RETRIEVE ALL THE FIELDS LIST USING METADATA API CALL
    public void retrieveAllFields()
    {
        fieldsList = new List<String>();
        
        String queryURL = 'sobjects/NI_Change_Control__c/describe';
        HttpResponse res = getHttpResponse(queryURL);
        String responseBody = res.getBody();
        //system.debug('Object Describe responseBody : '+responseBody);
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        //system.debug('resultMap size : '+resultMap.size());
        for(String s : resultMap.keyset())
        {
            if (s == 'fields')
            {
                List<Object> fieldsList1 = (List<Object>)resultMap.get(s);

                system.debug('Field List size : '+fieldsList1.size());
                
                for(Object s1 : fieldsList1)
                {
                    Map<String, Object> s1Map = (Map<String, Object>)s1;
                    for(String s2 : s1Map.keyset())
                    {
                        if (s2 == 'name' && String.valueOf(s1Map.get('updateable')) == 'true')
                        {
                            //system.debug('s1Map Field Name: '+s1Map.get(s2));
                        	fieldsList.add(String.valueOf(s1Map.get(s2)));
						}
                    }
                }
            }
        }
        
        system.debug('fieldsList size : '+fieldsList.size());
        //system.debug('fieldsList size from Metadata API call : '+fieldsList);
    }
    
    // SEND HTTP REQUEST
    private HttpResponse getHttpResponse (String URL)
    {
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        system.debug('salesforceHost : '+salesforceHost);
        
        String queryURL = salesforceHost + '/services/data/v45.0/' + URL;
        system.debug('queryURL : '+queryURL);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(queryURL);
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        
        return resp;
    }  

}