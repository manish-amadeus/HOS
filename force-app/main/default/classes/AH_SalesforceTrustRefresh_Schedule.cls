/********************************************************************************************************
Name            : AH_SalesforceTrustRefresh_Schedule Class
Author          : Bhuleshwar Deshpande
Created Date    : 10/09/2018
Last Mod Date   : 05/28/2018 
Last Mod By     : Sean Harris  
NICC Reference  :   
Description     : Scheduler class for AH_SalesforceTrustRefresh
				: 
**********************************************************************************************************/
global class AH_SalesforceTrustRefresh_Schedule implements Schedulable 
{ 

    global void execute(SchedulableContext sc)
    {

        for (AH_Salesforce_Trust_Config__mdt mdt : [SELECT MasterLabel, Endpoint_URL__c, Limit__c, Days_Ago__c, Sort_By_Field__c 
                                                    FROM AH_Salesforce_Trust_Config__mdt
                                                    ORDER BY Execution_Order__c ASC]) 
        {
            
            String strEndpoint = mdt.Endpoint_URL__c + '?limit=' + String.valueOf(mdt.Limit__c);
            
            if (mdt.Days_Ago__c != null)
            {
                Integer iDays = Integer.valueOf(mdt.Days_Ago__c);
                strEndpoint += '&startTime=' + String.valueOf(system.today() - iDays);
            }
            
            if (mdt.Sort_By_Field__c != null)
            {
                strEndpoint += '&sort=' + mdt.Sort_By_Field__c;
            }  
            
            if (mdt.MasterLabel == 'Instances')
            {
                strEndpoint += '&childProducts=false';
                system.debug(' **** Instances Endpoint = ' + strEndpoint);
                AH_SalesforceTrustRefresh.getInstances(strEndpoint);
            }
            
            if (mdt.MasterLabel == 'Incidents')
            {
                system.debug(' **** Incidents Endpoint = ' + strEndpoint);
                AH_SalesforceTrustRefresh.getIncidents(strEndpoint);
            }
            
            if (mdt.MasterLabel == 'Maintenances')
            {
                system.debug(' **** Maintenances Endpoint = ' + strEndpoint);
                AH_SalesforceTrustRefresh.getMaintenances(strEndpoint);
            }

            if (mdt.MasterLabel == 'Messages')
            {
                system.debug(' **** Messages Endpoint = ' + strEndpoint);
                AH_SalesforceTrustRefresh.getGeneralMessages(strEndpoint);
            }            
        
        }
  
    }
    
}