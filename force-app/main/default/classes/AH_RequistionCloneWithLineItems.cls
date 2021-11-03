/****************************************************************************************
Name            : AH_RequistionCloneWithLineItems
Author          : Sean Harris
Created Date    : 06/05/2017
Last Mod Date   : 08/10/2017
Last Mod By     : Ria Chawla
NICC Reference  : 
Description     : Extention Class for AH_RequistionCloneWithLineItems VF page
				: 
				: 
******************************************************************************************/
public class AH_RequistionCloneWithLineItems 
{

    private ApexPages.StandardController controller {get; set;}
    private SCMC__Requisition__c req {get; set;}
    public SCMC__Requisition__c newReq {get; set;}
    public SCMC__Requisition__c r {get; set;}
    
    //ADDED BY RIA 8/10/2017
    Private Set<String> setApiNames = new Set<String>();
    Map<string, string> MapMappingTable=new map<string,string>();
    Public String qry = '';
    
    // WRAPPER CLASS LIST TO HOLD THE REQUISITION LINE ITEMS
    public List<ReqItem> lstReqLineItems {get; set;}
    public string strReqNumber {get; set;}
    public string strReqId {get; set;}

    // initialize the controller
    public AH_RequistionCloneWithLineItems(ApexPages.StandardController controller) 
    { 
        // initialize the stanrdard controller
        this.controller = controller;
        
        // load the current record
        //SCMC__Requisition__c r = (SCMC__Requisition__c)controller.getRecord(); 
        r = (SCMC__Requisition__c)controller.getRecord(); 
        
        //COMMENTED BY RIA
        //req = [SELECT Id, Name, Requisition_Budget__c FROM SCMC__Requisition__c WHERE Id =: r.Id];        
        //strReqNumber = req.Name;
        //strReqId = req.Id;
        
        //ADDED BY RIA
        //GET THE FIELD API NAMES OF THE REQUISITION OBJECT
        Schema.DescribeSObjectResult scResult = SCMC__Requisition__c.sObjectType.getDescribe();
        for(string apiName : scResult.fields.getMap().keySet())  
        {
            setApiNames.add(apiName);
        }
    }


    public PageReference doClone() 
    {
        //ADDED BY RIA 8/10/2017
        system.debug('in doClone()');
        getFieldsFromCustomSetting();
        String requisitionId = r.Id;
        if(qry != '' && qry != null){
            qry = 'SELECT Id, Name, ' + qry + ' Requisition_Budget__c FROM SCMC__Requisition__c WHERE Id = :requisitionId';
        }
        else{
           qry = 'SELECT Id, Name, Requisition_Budget__c FROM SCMC__Requisition__c WHERE Id = :requisitionId'; 
        }
        req = Database.Query(qry);
        strReqNumber = req.Name;
        strReqId = req.Id;
        newReq = req.Clone();
        if(MapMappingTable.size() > 0){
            system.debug('size>0');
                for(String apiName : MapMappingTable.keySet()){
                    system.debug('apiName'+apiName);
                    newReq.put(apiName,req.get(apiName.stripHtmlTags()));
                }
        }
        //NEWLY ADDED/MODIFIED CODE ENDS
       
		//COMMENTED BY RIA
        //req = [SELECT Id, Name, Requisition_Budget__c FROM SCMC__Requisition__c WHERE Id =: r.Id];        
        newReq.Previous_Renewal__c = req.Id; 
       	newReq.Is_Monthly_Renewal__c = true;
        insert newReq;
        
        List<SCMC__Requisition_Line_Item__c> lstReqLineItemInserts = new List<SCMC__Requisition_Line_Item__c>();  
        boolean bIsCustomSettingCompliant = true;
        
        
        for (ReqItem lst : lstReqLineItems)
        {
            if (lst.isSelected)
            {

                SCMC__Requisition_Line_Item__c i = new SCMC__Requisition_Line_Item__c();
                i.SCMC__Requisition__c = newReq.Id;
                i.Previous_Renewal__c = lst.rli.Id;
                i.RecordTypeId = lst.rli.RecordTypeId;
                i.SCMC__Description__c = lst.rli.SCMC__Description__c;
                i.Item_Part_Number__c = lst.rli.Item_Part_Number__c;
                i.SCMC__Quantity__c = lst.rli.SCMC__Quantity__c;
                i.Unit_Cost__c = lst.rli.Unit_Cost__c;
                i.CurrencyIsoCode = lst.rli.CurrencyIsoCode;
                i.Budgeted__c = lst.rli.Budgeted__c;
                i.General_Ledger_Account_list__c = lst.rli.General_Ledger_Account_list__c;
                i.Line_of_Business_Dimension_2__c = lst.rli.Line_of_Business_Dimension_2__c;
                i.Department_Dimension_3__c = lst.rli.Department_Dimension_3__c;
                i.Capital_SOW_Number__c = lst.rli.Capital_SOW_Number__c;
                i.SCMC__Warehouse__c = lst.rli.SCMC__Warehouse__c;
                i.SCMC__Suggested_Supplier__c = lst.rli.SCMC__Suggested_Supplier__c;  
                i.Contractor__c = lst.rli.Contractor__c;
                i.Purchase_Type__c = lst.rli.Purchase_Type__c;
                i.Clone_Created__c = true;
                lstReqLineItemInserts.add(i);

            }
        }
        
        database.insert(lstReqLineItemInserts);
        
        return new PageReference('/' + newReq.Id);
        
    }
    
    public PageReference cancelClone() 
    {
        return new PageReference('/' + r.Id);
    }    

    // CALLED BY VF ACTION PAGE DIRECTIVE
    public PageReference loadItems()
    {
        
        PageReference pr = null;
        
        lstReqLineItems = new List<ReqItem>();
        
        for (SCMC__Requisition_Line_Item__c rli : [SELECT Id, Name, SCMC__Requisition__c, RecordTypeId, RecordType.Name, Item_Part_Number__c, 
                                                   SCMC__Quantity__c, Unit_Cost__c, CurrencyIsoCode, Budgeted__c, General_Ledger_Account_list__c, 
                                                   Line_of_Business_Dimension_2__c, Department_Dimension_3__c, Capital_SOW_Number__c, SCMC__Warehouse__c, 
                                                   SCMC__Suggested_Supplier__c, Previous_Renewal__c, SCMC__Description__c, Contractor__c, 
                                                   Purchase_Type__c, Clone_Created__c      
                                                   FROM SCMC__Requisition_Line_Item__c 
                                                   //WHERE SCMC__Requisition__c =: req.Id]
                                                   WHERE SCMC__Requisition__c =: r.Id]
            )
        {           
            
            rli.SCMC__Quantity__c = rli.SCMC__Quantity__c.setScale(0);
            rli.Unit_Cost__c = rli.Unit_Cost__c.setScale(2);
            lstReqLineItems.Add(new ReqItem(rli, true));
        }

        return pr;
        
    }


    // ============================================================================================================================================    
    // INNER CLASS CONSTRUCTS    
    // ============================================================================================================================================     
    public class ReqItem
    {
        public SCMC__Requisition_Line_Item__c rli {get; set;}
        public boolean isSelected {get; set;}
        
        public ReqItem(SCMC__Requisition_Line_Item__c rli, boolean isSelected)
        {
            this.rli = rli;
            this.isSelected = isSelected;
        }
        
    }
    
    
    
    //ADDED BY RIA TO GET FIELD API NAMES FROM CUSTOM SETTINGS
    public void getFieldsFromCustomSetting(){
        String strAPIFieldNameToLowerCase;
        
        for(AH_Requisition_Fields_to_Clone__c fieldsToClone : AH_Requisition_Fields_to_Clone__c.getAll().values()){
            
            strAPIFieldNameToLowerCase = fieldsToClone.Requisition_Field_API_Name__c;
            strAPIFieldNameToLowerCase = strAPIFieldNameToLowerCase.toLowerCase();
            
            if(setApiNames.contains(strAPIFieldNameToLowerCase)){
                MapMappingTable.put(fieldsToClone.Requisition_Field_API_Name__c, fieldsToClone.Requisition_Field_API_Name__c);
                qry += fieldsToClone.Requisition_Field_API_Name__c + ', ';
            }
        }
    }
    
}