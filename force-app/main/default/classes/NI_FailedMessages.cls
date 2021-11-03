public class NI_FailedMessages {
	
	public Integer refreshInterval {get; set;}
	public NI_FailedMessages(){
		WinaproachIncidentSettings__c winSettings 	= WinaproachIncidentSettings__c.getValues('Default');		
		if (winSettings.Refresh_Interval__c != null){
			refreshInterval = (winSettings.Refresh_Interval__c.intValue())*1000;
			
		}
	}
	
	
}