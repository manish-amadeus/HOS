// DISABLED "IMT" Implementation Tool designed for IHG 
/************************************************************************************************
Name            : NI_Project_TriggerHandler Class
Author          : Damodar Raut
Created Date    : 03/30/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that handles all trigger code for the Project Object
                : 
*************************************************************************************************/
public class NI_IMT_Project_TriggerHandler
{

    public NI_IMT_Project_TriggerHandler()
    {
    }

/*    
    public void OnBeforeUpdate(List<pse__Proj__c> newTrigger, Map<Id, pse__Proj__c> oldMapTrigger) 
    {
    	if (!NI_FUNCTIONS.bypassTriggerCode('pse__Proj__c')) {
    		
    		//FETCH THE RECORDTYPE FOR IMT IHG PROJECT
            Id imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
            Map<Id, pse__Proj__c> cancelProjMap = new Map<Id, pse__Proj__c>();
    		for (pse__Proj__c project : newTrigger) {
                //IMT PROJECT STAGE CHANGED TO CANCELED
                if ((project.RecordTypeId == imtProjRecordTypeId) && (project.pse__Stage__c == 'Canceled') && (oldMapTrigger.get(project.Id).pse__Stage__c != 'Canceled')) {
                	cancelProjMap.put(project.Id, project); 
                }
            }
            if(cancelProjMap.size() > 0) {
            	List<Id> cantCancelIds = new List<Id>();
		    	for(pse__Assignment__c result :[SELECT pse__Project__c 
		    									FROM pse__Assignment__c 
		    								WHERE pse__status__c in ('Scheduled', 'Tentative') 
		    								AND pse__Project__c IN :cancelProjMap.keySet()]) {
		    		cantCancelIds.add(result.pse__Project__c);										
				}
				for (Id projId :cantCancelIds) {
					cancelProjMap.get(projId).addError(' IMT project cannot be canceled if an active assignment exists (i.e. Scheduled or Tentative)');	
				}
            }
    	}                 
    }

	public void OnAfterInsert(List<pse__Proj__c> newTrigger) 
    {
		if (!NI_FUNCTIONS.bypassTriggerCode('pse__Proj__c')) {
			//FETCH THE RECORDTYPE FOR IMT IHG PROJECT
	        Id imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
			List<id> projectPMAddedIds = new List<Id>();
		    for (pse__Proj__c project : newTrigger) {
			    //IMT PROJECT PM ADDED 
			    if ((project.RecordTypeId == imtProjRecordTypeId) && (project.pse__Project_Manager__c != NULL))
			    {
			    	projectPMAddedIds.add(project.Id);    
			    }
			}
			if(projectPMAddedIds.size() > 0) {
				postChatter(projectPMAddedIds);
			}
		}
    }
	
    public void OnAfterUpdate(List<pse__Proj__c> newTrigger, Map<Id, pse__Proj__c> oldMapTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('pse__Proj__c'))
        { 
            //FETCH THE RECORDTYPE FOR IMT IHG PROJECT
            Id imtProjRecordTypeId = Schema.getGlobalDescribe().get('pse__proj__C').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
            List<id> projectIds = new List<Id>();
            List<id> projectPMAddedIds = new List<Id>();
            List<id> projectEscalatedIds = new List<Id>();
            // LOOP THROUGH PROJECTS IN TRIGGER.NEW BATCH
            for (pse__Proj__c project : newTrigger) 
            {
                if((project.RecordTypeId == imtProjRecordTypeId)) {
	                //IMT PROJECT STAGE CHANGED TO CANCELED
	                if ((project.pse__Stage__c == 'Canceled') && (oldMapTrigger.get(project.Id).pse__Stage__c != 'Canceled'))
	                {
	                	projectIds.add(project.Id);    
	                }
	                
	                //IMT PROJECT PM CHANGED 
	                if ((project.pse__Project_Manager__c != oldMapTrigger.get(project.Id).pse__Project_Manager__c))
	                {
	                	projectPMAddedIds.add(project.Id);    
	                }
	                
	                //IMT PROJECT ESCALATED
	                if ((project.Escalate_Project__c) && (project.Escalate_Project__c != oldMapTrigger.get(project.Id).Escalate_Project__c))
	                {
	                	projectEscalatedIds.add(project.Id);    
	                }
                }
            }
                
            //IMT PROJECT STAGE CHANGED TO CANCELED
            if(projectIds.size() > 0) {
            	//UPDATE THE PROJECTS SCHEDULED ASSIGNMENTS AND SCHEDULE OBJECTS
            	updateAssignmentsAndSchedule(projectIds);
                //UPDTAE PROJECT TASKS
	            updateTasks(projectIds);
        	}
        	//IMT PROJECT PM ADDED
            if(projectPMAddedIds.size() > 0) {
				postChatter(projectPMAddedIds);
			}
			//IMT PROJECT ESCALATED
			if(projectEscalatedIds.size() > 0) {
				notifyManager(projectEscalatedIds);
			}
        }                  
    }
	
    //UPDATE THE PROJECTS SCHEDULED ASSIGNMENTS AND SCHEDULE
    private void updateAssignmentsAndSchedule(List<Id> projectIds) 
    {
    	List<pse__Assignment__c> projAssignments = [SELECT Id,pse__Status__c,pse__Exclude_from_Planners__c,pse__Schedule__c
                                                        FROM pse__Assignment__c 
                                                        WHERE pse__Project__c IN :projectIds
                                                        	AND pse__Status__c NOT IN ('Scheduled','Tentative')];
                    
        if(projAssignments.size() > 0)
        {
            List<Id> scheduleIds = new List<Id>();
            for(pse__Assignment__c assignmnt : projAssignments)
            {
                assignmnt.pse__Status__c = 'Canceled';
                assignmnt.pse__Exclude_from_Planners__c = TRUE;
                assignmnt.IMT_Cancellation_Reason__c = 'Project got canceled';
                assignmnt.Cancellation_Reason__c = 'Not in Good Standing';
                scheduleIds.add(assignmnt.pse__Schedule__c);                    
            }
            update projAssignments;
        
            List<pse__Schedule__c> scheduleList = [SELECT pse__Monday_Hours__c,
                                        pse__Tuesday_Hours__c,
                                        pse__Wednesday_Hours__c,
                                        pse__Thursday_Hours__c,
                                        pse__Friday_Hours__c,
                                        pse__Saturday_Hours__c,
                                        pse__Sunday_Hours__c 
                                        FROM pse__Schedule__c
                                        WHERE Id IN :scheduleIds];
        
            if(scheduleList.size() > 0)
            {
                for(pse__Schedule__c schedule : scheduleList)
                {
                    schedule.pse__Monday_Hours__c = 0;
                    schedule.pse__Tuesday_Hours__c = 0;
                    schedule.pse__Wednesday_Hours__c = 0;
                    schedule.pse__Thursday_Hours__c = 0;
                    schedule.pse__Friday_Hours__c = 0;
                    schedule.pse__Saturday_Hours__c = 0;
                    schedule.pse__Sunday_Hours__c = 0;                   
                }
                update scheduleList;
            }
        }
    }
    
    //UPDTAE PROJECT TASKS
    private void updateTasks(List<Id> projectIds) 
    {
    	List<pse__Project_Task__c> projTasks = [SELECT pse__Status__c FROM pse__Project_Task__c WHERE pse__Project__c IN :projectIds AND 
	                                                    pse__Status__c IN ('Draft','Planned','Started','Blocked','Deferred') ];
        if(projTasks.size() > 0) {
            for(pse__Project_Task__c t : projTasks) {
                t.pse__Status__c = 'Canceled';
            }
            update projTasks;
        }
    }
    
    //CHATTER FEEDS WHEN PM CHANGED
    private void postChatter(List<id> projectPMAddedIds) 
    {
    	String communityName = String.valueOf(NI_IMT_Chatter_Settings__c.getValues('Default').get('Community_Name__c'));
		String chatterGroupName = String.valueOf(NI_IMT_Chatter_Settings__c.getValues('Default').get('GSU_RA_Group__c'));
		if(String.isBlank(communityName) || String.isBlank(chatterGroupName)) {
			system.debug('Community Name and Chatter Group Name can\'t be blank.');
		}
		else {
			Network imtNetwork = [SELECT id, name FROM Network WHERE Name = :communityName];
			CollaborationGroup chatterGrp = [SELECT Id,name FROM CollaborationGroup where name = :chatterGroupName];
			if(imtNetwork != NULL && chatterGrp!=NULL) {					
				// POST GLOBAL SUPER USER CHATTER
				List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
				for(pse__Proj__c prj :[SELECT OwnerId, pse__Project_Manager__r.pse__Salesforce_User__c, IMT_Property__r.Name, IMT_Cut_Over_Date__c, Link__c FROM pse__Proj__c WHERE Id IN :projectPMAddedIds]) {
	    			List<Id> ids = new List<Id>();
					ids.add(chatterGrp.Id);
					ids.add(prj.pse__Project_Manager__r.pse__Salesforce_User__c);
	    			String postText =  'The '+ prj.IMT_Property__r.Name +' project has been assigned to you. \n Cut Over Date: ' + prj.IMT_Cut_Over_Date__c + '\nPlease view detail for additional detail ' + prj.Link__c;
					for(Integer i =0 ;i < ids.size(); i++ ) {
						ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
						input.subjectId = ids[i];
				        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
				        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
				        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
				        textSegment.text = postText;
				        body.messageSegments.add(textSegment);
				        input.body = body;
				        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
				        batchInputs.add(batchInput);
					}
					//ConnectApi.FeedElement feedElement1 = ConnectApi.ChatterFeeds.postFeedElement(imtNetwork.Id, chatterGrp.Id, ConnectApi.FeedElementType.FeedItem, postText);	
					//ConnectApi.FeedElement feedElement2 = ConnectApi.ChatterFeeds.postFeedElement(imtNetwork.Id, prj.pse__Project_Manager__r.pse__Salesforce_User__c, ConnectApi.FeedElementType.FeedItem, postText);		    	
				}
				if(!Test.isRunningTest()){
					ConnectApi.ChatterFeeds.postFeedElementBatch(imtNetwork.Id, batchInputs);
				}
			}
			else {
				system.debug('Community Name or Chatter Group not found.');
			}
		}
    }
    
    //EMAIL SENT PROJECT MANAGER'S MANAGER WHEN PROJECT ESCALATED
    private void notifyManager(List<id> projectEscalatedIds) {
    	//List<pse__Proj__c> escalatedProjects = [SELECT Name, pse__Project_Manager__r.pse__Salesforce_User__r.Manager.Email, IMT_Cut_Over_Date__c, Link__c,pse__Project_Manager__r.Name FROM pse__Proj__c WHERE Id IN :projectEscalatedIds];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(pse__Proj__c prj :[SELECT Name, pse__Project_Manager__r.pse__Salesforce_User__r.Manager.Email, 
        IMT_Cut_Over_Date__c, Link__c,pse__Project_Manager__r.Name FROM pse__Proj__c WHERE Id IN :projectEscalatedIds]) {
        	if (prj.pse__Project_Manager__r.pse__Salesforce_User__r.Manager.Email != null) {
    			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    	//Set list of people who should get the email
		    	List<String> sendTo = new List<String>();
			    sendTo.add(prj.pse__Project_Manager__r.pse__Salesforce_User__r.Manager.Email);
			    mail.setToAddresses(sendTo);
			    //Set who the email is sent from
			    mail.setReplyTo(UserInfo.getUserEmail());
			    mail.setSenderDisplayName(UserInfo.getName());
				//Set email contents
				String sub = 'The ' + prj.Name + ' has been Escalated';
			    mail.setSubject(sub);
			    String body = prj.pse__Project_Manager__r.Name + ' has escalated the ' + prj.Name + ' project. ';
			    body += '<br/>Cut Over Date: ' + prj.IMT_Cut_Over_Date__c;
			    body += '<br/></br>Please view detail for additional detail ' + prj.Link__c;
			    mail.setHtmlBody(body);
			    //Add your email to the master list
			    mails.add(mail);
        	}
    	}	 	
    	//Send all emails in the master list
  		Messaging.sendEmail(mails);
    }
*/    
    
}