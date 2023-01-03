// DISABLED "IMT" Implementation Tool designed for IHG 
/************************************************************************************************
Name            : NI_IMT_Property_TriggerHandler Class
Author          : Damodar Raut
Created Date    : 04/08/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that handles all trigger code for the Property Object
                : 
*************************************************************************************************/
public class NI_IMT_Property_TriggerHandler
{


    public NI_IMT_Property_TriggerHandler()
    {

    }

/*    
	public void OnBeforeInsert(List<NI_IMT_Property__c> newTrigger)
    {
		//FETCH THE RECORDTYPE FOR IMT PROPERTY
		Id imtPropRecordTypeId = Schema.getGlobalDescribe().get('NI_IMT_Property__c').getDescribe().getRecordTypeInfosByName().get('InterContinental Hotels Group').getRecordTypeId();
		// LOOP THROUGH PROPERTIES IN TRIGGER.NEW BATCH
		for (NI_IMT_Property__c property : newTrigger) 
		{
			//SET TIMEZONE VALUE
			if ((property.RecordTypeId == imtPropRecordTypeId))
			{
				property.Timezone__c =  getTimeZone(property.Country__c, property.State__c, property.City__c, property.Phone__c);
			}
		}
        
    }
    
    public void OnBeforeUpdate(List<NI_IMT_Property__c> newTrigger, Map<Id, NI_IMT_Property__c> oldMapTrigger)
    {
		if (!NI_FUNCTIONS.bypassTriggerCode('NI_IMT_Property__c'))
        { 
            //FETCH THE RECORDTYPE FOR IMT PROPERTY
			Id imtPropRecordTypeId = Schema.getGlobalDescribe().get('NI_IMT_Property__c').getDescribe().getRecordTypeInfosByName().get('InterContinental Hotels Group').getRecordTypeId();
            List<id> projectIds = new List<Id>();
            
            // LOOP THROUGH PROJECTS IN TRIGGER.NEW BATCH
            for (NI_IMT_Property__c property : newTrigger) 
            {
                //IMT PROPERTY ADDRESS CHANGED
                if ((property.RecordTypeId == imtPropRecordTypeId) && 
				((property.Country__c != oldMapTrigger.get(property.Id).Country__c)  
				|| (property.State__c != oldMapTrigger.get(property.Id).State__c)
				|| (property.City__c != oldMapTrigger.get(property.Id).City__c)
				|| (property.Phone__c != oldMapTrigger.get(property.Id).Phone__c))
				)
                {
                	property.Timezone__c =  getTimeZone(property.Country__c, property.State__c, property.City__c, property.Phone__c);    
                }
            }
                
        } 
                           
    }
	
    public void OnAfterUpdate(List<NI_IMT_Property__c> newTrigger, Map<Id, NI_IMT_Property__c> oldMapTrigger) {
    	//FETCH THE RECORDTYPE FOR IMT PROPERTY
		Id imtPropRecordTypeId = Schema.getGlobalDescribe().get('NI_IMT_Property__c').getDescribe().getRecordTypeInfosByName().get('InterContinental Hotels Group').getRecordTypeId();
        if (!NI_FUNCTIONS.bypassTriggerCode('NI_IMT_Property__c')) {
    		List<Id> notEligibleIds = new List<Id>();
    		for(NI_IMT_Property__c property :newTrigger) {
    			if ((property.RecordTypeId == imtPropRecordTypeId) && 
    			(property.Status__c != oldMapTrigger.get(property.Id).Status__c) &&
    			(property.Status__c == 'Inactive')) {
    				notEligibleIds.add(property.Id);		
    			}    				
    		}        
    		if(notEligibleIds.size() > 0) {
    			//NOTIFY PROJECT MANAGERS
    			chatterProjectManager(notEligibleIds);
    			//UPDATE PROJECT STAGE TO CANCELED
    			updateProjectToCanceled(notEligibleIds);
    		}
    	}  
    }
		
	private String getTimeZone(String country, String state, String city, String phone) {  
		String timeZone = '';
        String offset = '';
        String s = tz.LocalTime.CalculateLocalTime(country, state, city, phone);
        System.debug('JSON'+s);
        JSONParser parser = JSON.createParser(s);
        parser.nextToken();
        parser.nextValue();
        offset = parser.getText();
        parser.nextToken();
        parser.nextValue();
        String sEnd = parser.getText();
        if(offset != '' && offset!='N/A')
			timeZone = sEnd + ' ( GMT ' + offset + ' ) ';
		return timeZone;
    }
    
    //CHATTER FEEDS TO RELATED PROJECT MANAGER WHEN PROPERTY NO LONGER ELIGIBLE
    private void chatterProjectManager(List<id> notEligibleIds) {
    	String communityName = String.valueOf(NI_IMT_Chatter_Settings__c.getValues('Default').get('Community_Name__c'));
		if(String.isBlank(communityName)) {
			system.debug('Community Name can\'t be blank.');
		}
		else {
			Network imtNetwork = [SELECT id, name FROM Network WHERE Name = :communityName];
			if(imtNetwork != NULL) {					
				// POST CHATTER TO RELATED PROJECT MANAGER
				List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
				for(pse__Proj__c prj :[SELECT pse__Project_Manager__r.pse__Salesforce_User__c, IMT_Property__r.Name, IMT_Property__c, Link__c FROM pse__Proj__c WHERE IMT_Property__c IN :notEligibleIds]) {
	    			String lnk = '../'+prj.IMT_Property__c;
	    			String postText =  'The '+ prj.IMT_Property__r.Name +' property is Inactive. \nPlease view project detail for additional detail ' + prj.Link__c;
					ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
					input.subjectId = prj.pse__Project_Manager__r.pse__Salesforce_User__c;
			        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
			        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
			        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
			        textSegment.text = postText;
			        body.messageSegments.add(textSegment);
			        input.body = body;
			        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
			        batchInputs.add(batchInput);
				}
				if(!Test.isRunningTest()){
					ConnectApi.ChatterFeeds.postFeedElementBatch(imtNetwork.Id, batchInputs);
				}
			}
			else {
				system.debug('Community Name not found.');
			}
		}
    }
    
    //UPDATE PROJECT STAGE TO CANCELED
    private void updateProjectToCanceled(List<id> notEligibleIds) {
    	List<pse__Proj__c> projList = new List<pse__Proj__c>();
    	for(pse__Proj__c prj :[SELECT pse__Stage__c FROM pse__Proj__c WHERE IMT_Property__c IN :notEligibleIds]) {
    		prj.pse__Stage__c = 'Canceled';
    		projList.add(prj);
    	}
    	update projList;
    }
*/

}