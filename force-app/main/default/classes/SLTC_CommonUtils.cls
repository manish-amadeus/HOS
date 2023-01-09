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
            Id cartId;
            Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
            if (proposal != null && request != null) {
                request.QuoteId = proposal.Id;
                if(Test.isRunningTest()){
                    Apttus_Config2__ProductConfiguration__c prod_config = new Apttus_Config2__ProductConfiguration__c();
                    prod_config.Apttus_QPConfig__Proposald__c = proposal.Id;
                    INSERT prod_config;
                    cartId=prod_config.Id;
                } else{
                    Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
                    cartId = response.CartId;
                }
            }
            if(cartId!=null){
                cartIds.add(cartId);
            }
        }
        return cartIds;
    }
}