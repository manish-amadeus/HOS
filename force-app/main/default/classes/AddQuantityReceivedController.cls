/*-------------------------------------------------
    @Author: Prashant Wayal
    @Date: 02/02/2016
    @Description: Distribute Quantity Controller
---------------------------------------------------*/

public class AddQuantityReceivedController
{
    public Id assetId{get;set;}
    public List<Asset> assetList{get;set;}  
    public Asset parentAssetObj{ get; set; }           
    public AddQuantityReceivedController(Apexpages.standardController controller)    
    {                
        assetId = ApexPages.currentPage().getParameters().get('Id');
        if(!Test.isRunningTest()){
            List<String> fldList = new List<String>{'Quantity_Billed__c'};
            controller.addFields(fldList);
        }
        parentAssetObj = (Asset)controller.getRecord();
        assetList = new List<Asset>();
        assetList = [SELECT Id,Quantity_Received__c,Name FROM Asset WHERE Parent_DI__c = : assetId];        
    }
    //Method that update the Deployment Instance List after the quantity is distributed
    public Pagereference doSubmit()
    {
        Decimal quanitityDistributed = 0;
        for(Asset asObj: assetList){
            quanitityDistributed += asObj.Quantity_Received__c;
        }       
        if(parentAssetObj.Quantity_Billed__c < quanitityDistributed){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity distributed should not be more than available quantity.'));
            return null;
        }
        else{
            update assetList;
            PageReference ref = new PageReference('/'+parentAssetObj.Id);
            ref.setRedirect(true);
            return ref;
        }
        return null;                
    }
    
}