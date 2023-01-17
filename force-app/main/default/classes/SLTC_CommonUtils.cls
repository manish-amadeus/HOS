/****************************************************************************************
Name            : SLTC_CommonUtils 
Author          : Heema solanki
Created Date    : 2/8/2022
Last Mod Date   : 12/06/2022 
Last Mod By     : Japtej Lamba
NICC Reference  : 
Description     : Utils class for creating Cart record with Apttus API and Id list of Database Query execution
****************************************************************************************/
public class SLTC_CommonUtils{
    /*
    * Method to create Cart by Calling the Apttus_CPQApi for List of Quote/Proposal records
    * Return List of Cart Ids created
    */
    public static List<Id> createCart(List<Apttus_Proposal__Proposal__c> proposals) {
        List<Id> cartIds = new List<Id>();
        for(Apttus_Proposal__Proposal__c proposal : proposals){
            Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
            request.QuoteId = proposal.Id;
            Apttus_CPQApi.CPQ.CreateCartResponseDO response = null;
            if(!Test.isRunningTest()){
                   response = Apttus_CPQApi.CPQWebService.createCart(request);
            }
           
            if(response != NULL && response.CartId != null){
                cartIds.add( response.CartId);
            }
            
        }
        if(Test.isRunningTest()){
            cartIds = new List<Id>();
            Apttus_Config2__ProductConfiguration__c prod_config = new Apttus_Config2__ProductConfiguration__c(Apttus_QPConfig__Proposald__c=proposals[0].Id);
            INSERT prod_config;
            cartIds.add(prod_config.Id);
        }
        
        return cartIds;
    }
}