/**********************************************************
Name : SLTC_AmadeusAssetCallback
Author : Heema Solanki
Created Date : 3/9/2022
Last Mod Date : 12/8/2022
Last Mod By : Japtej Lamba
Description : Asset Callback class for Apttus Asset Line Item
	    : Adds filter on Asset Status and Related Opportunity fields
***********************************************************/
global class SLTC_AmadeusAssetCallback implements Apttus_Config2.CustomClass.IAssetLineItemCallback4{
        
        private Apttus_Config2.CustomClass.IAssetLineItemCallback4 callback = null;
        private transient Apttus_Config2__ProductConfiguration__c cart = null;
        private List<String> assetSearchScope = null;
        private String assetSearchFilter = null;
        public Id relatedOppty ; 

        global void start(Apttus_Config2.ProductConfiguration cart, String assetSearchFilter,List<String> assetSearchScope) {
                this.cart = cart.getConfigSO();
                relatedOppty = this.cart.SLTC_Related_Opportunity__c;
        }

        global String getQueryFilter(ID accountId) {
                return null;
        }

        global String getFilterExpr(Apttus_Config2.CustomClass.ActionParams params) {
                String returnFilter = ' Apttus_Config2__AssetStatus__c=\'Activated\' AND SLTC_Related_Opportunity__c = \'' + relatedOppty + '\' ';
                return returnFilter;
        }

        global List<String> getAssetSearchScope(){
                // delegate to the asset callback
                return null;
        }

        global void finish() {
                // delegate to the asset callback
        }

        global Boolean validateAssetTermination(Set<ID> assetIds, Set<ID> accountIds, Date eDate) {
                return true;
        }

        global Date getAssetTerminationDate() {
                return null;
        }
}