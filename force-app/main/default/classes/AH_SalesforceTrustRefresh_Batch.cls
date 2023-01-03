/************************************************************************************************
Name            : AH_SalesforceTrustRefresh_Batch Class
Author          : Bhuleshwar Deshpande
Created Date    : 10/09/2018
Last Mod Date   : 05/23/2018 
Last Mod By     : Sean Harris   
NICC Reference  : 
Description     : Schedule BatchApexob AH_Batch_SalesforceTrustRefresh 
				:
*************************************************************************************************/
global class AH_SalesforceTrustRefresh_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    
    public String apiType; 

    // CONSTRUCTOR
    public AH_SalesforceTrustRefresh_Batch(String apiTypeStr) 
    {   
        apiType = apiTypeStr;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator('select id from recordtype where id != null');
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) 
    {
        string s = 'temp';
    }      
    
    global void finish(Database.BatchableContext bc)
    {
		string s = 'temp';
    }

}