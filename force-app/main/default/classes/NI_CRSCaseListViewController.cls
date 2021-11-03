public class NI_CRSCaseListViewController {

	public Integer refreshInterval {get; set;}
	public NI_CRSCaseListViewController(){
		WinaproachIncidentSettings__c winSettings 	= WinaproachIncidentSettings__c.getValues('Default');		
		if (winSettings.Refresh_Interval__c != null){
			refreshInterval = (winSettings.Refresh_Interval__c.intValue())*1000;
			
		}
	}
    
	
}