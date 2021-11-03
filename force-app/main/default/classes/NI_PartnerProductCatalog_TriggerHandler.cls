public class NI_PartnerProductCatalog_TriggerHandler
{
    private boolean m_isExecuting = false;
    
    public NI_PartnerProductCatalog_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }
         
    //Before Insert Methods      
    
    /****functionality no longer required. commented by kasim on 4/27/16
    public void OnBeforeInsert(List<CHANNEL_ORDERS__Partner_Product_Catalog__c> newListTrigger)
    {
        /****functionality no longer required. commented by kasim on 4/27/16
        //Set<String> prodCatlogNames = new Set<String>();
        for(CHANNEL_ORDERS__Partner_Product_Catalog__c p : newListTrigger)
        {
            prodCatlogNames.add(p.Name);
        }
        //Call the Method that Creates DI Index if not Exists
        //createDiIndex(prodcatlogNames);
       
        
    } ****/
    /****functionality no longer required. commented by kasim on 4/27/16
    public void OnBeforeUpdate(List<CHANNEL_ORDERS__Partner_Product_Catalog__c> newListTrigger,Map<Id,CHANNEL_ORDERS__Partner_Product_Catalog__c> oldMapTrigger)
    {
       
        //Set<String> prodCatlogNames = new Set<String>();
        for(CHANNEL_ORDERS__Partner_Product_Catalog__c p : newListTrigger)
        {            
           // CHANNEL_ORDERS__Partner_Product_Catalog__c oldprodCatlog = oldMapTrigger.get(p.Id);
            //Check the Name is Updated
           // if(p.Name != oldprodCatlog.Name)
           // prodCatlogNames.add(p.Name);
        }
       
        //Call the Method that Creates DI Index if not Exists
        //if(!prodcatlogNames.isEmpty()){
         //   createDiIndex(prodcatlogNames);    
        //}    
         
    } ****/
    
    /*----------------------------------------
    * @Added By: Kasim Badami
    * @Added On: 02/17/2016
    
    * @Description: Method that Auto update the "DI Index" on Product
      
      // functionality commented by Kasim as per stu's email dated 4/27/16 as follows,
      // A new Product Classification system is being put in place that will eliminate the need for individual DIs for each Salesforce Product.
    ------------------------------------------*/
    /*public void createDiIndex(Set<String> prodCatlogNames)
    {
        //List all DI Index which already exists                
        for(List<NI_DeploymentInstanceIndex__c> diIndexList : [SELECT Id,Name FROM NI_DeploymentInstanceIndex__c WHERE Name IN : prodCatlogNames])
        {
            for(NI_DeploymentInstanceIndex__c index : diIndexList){
                prodCatlogNames.remove(index.Name);                
            }
        }                
        List<NI_DeploymentInstanceIndex__c> newIndexList = new List<NI_DeploymentInstanceIndex__c>();
        //Loop through the remaining product Catlog Names and create the new DI Index for them
        for(String prodcatlogName : prodCatlogNames){
            NI_DeploymentInstanceIndex__c index = new NI_DeploymentInstanceIndex__c();
            index.Name = prodcatlogName;
            newIndexList.add(index);        
        }
        if(!newIndexList.isEmpty()){
            database.Insert(newIndexList);        
        }
    }*/
}