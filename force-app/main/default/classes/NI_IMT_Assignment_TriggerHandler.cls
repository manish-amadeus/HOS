// DISABLED "IMT" Implementation Tool designed for IHG 
/************************************************************************************************
Name            : NI_IMT_Assignment_TriggerHandler Class
Author          : Damodar Raut
Created Date    : 04/22/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that handles all trigger code for the Assignment Object
                : 
*************************************************************************************************/
public class NI_IMT_Assignment_TriggerHandler 
{


    public NI_IMT_Assignment_TriggerHandler()
    {

    }

/*    
    public void OnBeforeInsert(List<pse__Assignment__c> newTrigger) 
    {
    	if (!NI_FUNCTIONS.bypassTriggerCode('pse__Assignment__c'))
        {
    		validateScheduleComplexity(newTrigger);
    	}   
    }
    
    public void OnBeforeUpdate(List<pse__Assignment__c> newTrigger, Map<Id, pse__Assignment__c> oldMapTrigger)
    {
         if (!NI_FUNCTIONS.bypassTriggerCode('pse__Assignment__c')) {
         	 String imtProjRecordTypeName = String.valueOf(NI_IMT_Assignment_Settings__c.getValues('Default').get('Assignment_Project_Record_Type_Name__c'));
         	 List<pse__Assignment__c> filteredAssign = new List<pse__Assignment__c>();
         	 for(pse__Assignment__c assign :newTrigger) {
         	 	if(assign.Project_Record_Type__c == imtProjRecordTypeName
            		&& (assign.pse__Status__c != oldMapTrigger.get(assign.Id).pse__Status__c)
            		&& (assign.pse__Status__c == 'Scheduled')
            		) {
            			filteredAssign.add(assign);     
                }
         	 }
         	 if(filteredAssign.size() > 0) {
            	validateScheduleComplexity(filteredAssign);
            }
		}                  
    }

    public void OnBeforeDelete(List<pse__Assignment__c> newTrigger)
    {
        
    }
    
    public void OnAfterInsert(List<pse__Assignment__c> newTrigger)
    {
        system.debug(LoggingLevel.ERROR,'In Assignment Trigger after insert');
        if (!NI_FUNCTIONS.bypassTriggerCode('pse__Assignment__c')){
        	makeScheduleComplexityCalculations(newTrigger);
        }
    }
    
    public void OnAfterUpdate(List<pse__Assignment__c> newTrigger, Map<Id, pse__Assignment__c> oldMapTrigger) {
    	if (!NI_FUNCTIONS.bypassTriggerCode('pse__Assignment__c')) {
    		//FETCH THE RECORDTYPE FOR IMT IHG PROJECT
            String imtProjRecordTypeName = String.valueOf(NI_IMT_Assignment_Settings__c.getValues('Default').get('Assignment_Project_Record_Type_Name__c'));
            List<Id> canceledFallbackIds = new List<Id>();
            List<Id> canceledIds = new List<Id>();
            List<pse__Assignment__c> filteredAssign = new List<pse__Assignment__c>();
            for(pse__Assignment__c assign :newTrigger) {
            	if(assign.Project_Record_Type__c == imtProjRecordTypeName
            		&& (assign.pse__Status__c != oldMapTrigger.get(assign.Id).pse__Status__c)
            		&& (assign.pse__Status__c == 'Canceled' || assign.pse__Status__c == 'Fallback')
            		) {
            			canceledFallbackIds.add(assign.Id);     
                }
                if(assign.Project_Record_Type__c == imtProjRecordTypeName
            		&& (assign.pse__Status__c != oldMapTrigger.get(assign.Id).pse__Status__c)
            		&& (assign.pse__Status__c == 'Canceled')
            		) {
            			canceledIds.add(assign.Id);     
                }
                if(assign.Project_Record_Type__c == imtProjRecordTypeName
            		&& (assign.pse__Status__c != oldMapTrigger.get(assign.Id).pse__Status__c)
            		&& (assign.pse__Status__c == 'Scheduled')
            		) {
            			filteredAssign.add(assign);     
                }
            }
            if(canceledFallbackIds.size() > 0) {
            	assignmentCanceledNotification(canceledFallbackIds);
            }
            if(canceledIds.size() > 0) {
            	updateScheduleComplexityOnCancel(canceledIds);
            	createRecurringTaskForPM(canceledIds);
            }
            if(filteredAssign.size() > 0) {
            	makeScheduleComplexityCalculations(filteredAssign);
            }
    	}
    }
    
    public void OnAfterDelete(List<pse__Assignment__c> newTrigger)
    {
        
    }
    
    public void OnAfterUnDelete(List<pse__Assignment__c> newTrigger)
    {
        
    }
    
    private void validateScheduleComplexity(List<pse__Assignment__c> newTrigger){
    	
    		
    		if(newTrigger[0].IMT_Migration_Set__c != NULL) {
    			
	            List<IMT_Migration_Set__c> migList = [SELECT Scheduled_Complexity_1__c,Scheduled_Complexity_2__c,
		            										Scheduled_Complexity_3__c,Scheduled_Complexity_4__c,Scheduled_Complexity_Mix__c,
		            										Total_Budget__c, Total_Scheduled__c,Budgeted_Complexity_Mix__c ,Status__c   
		                                                 FROM IMT_Migration_Set__c
		                                                    WHERE Id =:newTrigger[0].IMT_Migration_Set__c LIMIT 1];
	            system.debug(migList[0]);
	            //Scheduling set status not Open display error
	            if(migList[0].Status__c != 'Open') {
	            	for(pse__Assignment__c assign :newTrigger) {
	            		assign.addError('An assignment cannot be added to a scheduling set that is not open');	
	            	}	
	            }
	            else {
	            	//Validate total schedule not to go over the total budget
		            Decimal schComplexity1 = 0;
		            Decimal schComplexity2 = 0;
		            Decimal schComplexity3 = 0;
		            Decimal schComplexity4 = 0;
		            Decimal scheduleCompMix = 0;
		            if(migList.size() > 0) {
		            	if(migList[0].Scheduled_Complexity_1__c != NULL)
		            		schComplexity1 = migList[0].Scheduled_Complexity_1__c;
		            	if(migList[0].Scheduled_Complexity_2__c != NULL)	
		        			schComplexity2 = migList[0].Scheduled_Complexity_2__c;
		        		if(migList[0].Scheduled_Complexity_3__c != NULL)	
		        			schComplexity3 = migList[0].Scheduled_Complexity_3__c;
		        		if(migList[0].Scheduled_Complexity_4__c != NULL)
		        			schComplexity4 = migList[0].Scheduled_Complexity_4__c;
		        		if(migList[0].Scheduled_Complexity_Mix__c != NULL)
		        			scheduleCompMix = migList[0].Scheduled_Complexity_Mix__c;
		            }
		            system.debug('total scheduled '+migList[0].Total_Scheduled__c+'comp1 ' + schComplexity1+'comp2 ' + schComplexity2+'comp3 ' + schComplexity3+'comp4 ' + schComplexity4 +'schcompmix'+scheduleCompMix);
		    		for(pse__Assignment__c assign :newTrigger) {
		    			// While validating for Scheduled and Tentative status 		    			
		    			if(assign.pse__Status__c == 'Scheduled' ) { 
			                if(assign.Operational_Profile__c == 'A' )  {
			                    schComplexity1 += 1;    
			                }
			                if(assign.Operational_Profile__c == 'B')  {
			                    schComplexity2 += 1;    
			                }
			                if(assign.Operational_Profile__c == 'C')  {
			                    schComplexity3 += 1;    
			                }
			                if(assign.Operational_Profile__c == 'D')  {
			                    schComplexity4 += 1;    
			                }
			                if(assign.Complexity_Value__c != NULL) {
			                	scheduleCompMix += assign.Complexity_Value__c;
			                }
		    			}
		            }		            
		            system.debug(LoggingLevel.Error, 'total scheduled '+migList[0].Total_Scheduled__c+'comp1 ' + schComplexity1+'comp2 ' + schComplexity2+'comp3 ' + schComplexity3+'comp4 ' + schComplexity4+'schcompmix'+scheduleCompMix+'plndcompmix'+migList[0].Budgeted_Complexity_Mix__c);
		            Decimal totalScheduled = migList[0].Total_Scheduled__c + schComplexity1 + schComplexity2 + schComplexity3 + schComplexity4;
		            if(totalScheduled > migList[0].Total_Budget__c) {
		            	for(pse__Assignment__c assign :newTrigger) {
		            		assign.addError('The assignment will overschedule the total budget of the scheduling set');	
		            	}
		            }
		            else if(scheduleCompMix > migList[0].Budgeted_Complexity_Mix__c) {
		            	for(pse__Assignment__c assign :newTrigger) {
		            		assign.addError('The assignment will overschedule the planned complexity mix of the scheduling set');	
		            	}
		            }
	    		}
    		}
    	
    }
    
    private void makeScheduleComplexityCalculations(List<pse__Assignment__c> newTrigger){
    	
            if(newTrigger[0].IMT_Migration_Set__c != NULL) {
	            Decimal schComplexity1 = 0;
	            Decimal schComplexity2 = 0;
	            Decimal schComplexity3 = 0;
	            Decimal schComplexity4 = 0;
	            Decimal scheduleCompMix = 0;
	            List<IMT_Migration_Set__c> migList = [SELECT Scheduled_Complexity_1__c,Scheduled_Complexity_2__c,
		            										Scheduled_Complexity_3__c,Scheduled_Complexity_4__c,Scheduled_Complexity_Mix__c 
		                                                 FROM IMT_Migration_Set__c
		                                                    WHERE Id =:newTrigger[0].IMT_Migration_Set__c LIMIT 1];
	            if(migList.size() > 0) {
	            	if(migList.size() > 0) {
		            	if(migList[0].Scheduled_Complexity_1__c != NULL)
		            		schComplexity1 = migList[0].Scheduled_Complexity_1__c;
		            	if(migList[0].Scheduled_Complexity_2__c != NULL)	
		        			schComplexity2 = migList[0].Scheduled_Complexity_2__c;
		        		if(migList[0].Scheduled_Complexity_3__c != NULL)	
		        			schComplexity3 = migList[0].Scheduled_Complexity_3__c;
		        		if(migList[0].Scheduled_Complexity_4__c != NULL)
		        			schComplexity4 = migList[0].Scheduled_Complexity_4__c;
		        		if(migList[0].Scheduled_Complexity_Mix__c != NULL)
		        			scheduleCompMix = migList[0].Scheduled_Complexity_Mix__c;
		            }
	            }
	            
	            for(pse__Assignment__c assign :newTrigger) {
	    			system.debug(assign);
	    			if(assign.pse__Status__c == 'Scheduled') { 
		                if(assign.Operational_Profile__c == 'A' )  {
		                    schComplexity1 += 1;    
		                }
		                if(assign.Operational_Profile__c == 'B')  {
		                    schComplexity2 += 1;    
		                }
		                if(assign.Operational_Profile__c == 'C')  {
		                    schComplexity3 += 1;    
		                }
		                if(assign.Operational_Profile__c == 'D')  {
		                    schComplexity4 += 1;    
		                }
		                if(assign.Complexity_Value__c != NULL) {
		                	scheduleCompMix += assign.Complexity_Value__c;
		                }
	    			}
	            }
	            system.debug(LoggingLevel.ERROR,'In Assignment Trigger after insert'+ schComplexity3);
	            IMT_Migration_Set__c migrationObj = [SELECT Scheduled_Complexity_1__c,Scheduled_Complexity_2__c,
		            										Scheduled_Complexity_3__c,Scheduled_Complexity_4__c,Scheduled_Complexity_Mix__c 
		                                                 FROM IMT_Migration_Set__c
		                                                    WHERE Id =:newTrigger[0].IMT_Migration_Set__c LIMIT 1];
	            migrationObj.Scheduled_Complexity_1__c = schComplexity1;
	            migrationObj.Scheduled_Complexity_2__c = schComplexity2;
	            migrationObj.Scheduled_Complexity_3__c = schComplexity3;
	            migrationObj.Scheduled_Complexity_4__c = schComplexity4;
	            migrationObj.Scheduled_Complexity_Mix__c = scheduleCompMix;
	            update migrationObj;
	        }
        
    }
    //UPDATE SCHEDULE COMPLEXITY WHEN ASSIGNMENTS CANCELED
    private void updateScheduleComplexityOnCancel(List<Id> canceledIds) {
    	//UPDATE SCHEDULED COMPLEXITY MIX
    	Map<Id, Decimal> canceledCompMap = new Map<Id,Decimal>();
    	for(AggregateResult result :[SELECT SUM(Complexity_Value__c) total,IMT_Migration_Set__c 
										FROM pse__Assignment__c 
    										WHERE ID IN :canceledIds GROUP BY IMT_Migration_Set__c]) {
    		canceledCompMap.put((Id)result.get('IMT_Migration_Set__c'), (Decimal)result.get('total'));										
		}
		
		List<IMT_Migration_Set__c> migList = [SELECT Scheduled_Complexity_Mix__c FROM IMT_Migration_Set__c WHERE Id IN :canceledCompMap.keySet()];
		for(IMT_Migration_Set__c mig :migList) {
			for(Id key :canceledCompMap.keySet()) {
				if(mig.Id == key) {
					mig.Scheduled_Complexity_Mix__c -= canceledCompMap.get(key);
				}	
			}			
		}
		update migList;
		
		//UPDATE SCHEDULE COMPLEXITIES
		//SCHEDULE COMPLEXITY 1
		Map<Id, Decimal> canceledCompMap1 = new Map<Id,Decimal>();
    	for(AggregateResult result :[SELECT COUNT(Complexity_Value__c) total,IMT_Migration_Set__c 
    									FROM pse__Assignment__c 
    										WHERE ID IN :canceledIds AND Operational_Profile__c = 'A' 
    										GROUP BY IMT_Migration_Set__c]) {
    		canceledCompMap1.put((Id)result.get('IMT_Migration_Set__c'), (Decimal)result.get('total'));										
		}
		
		List<IMT_Migration_Set__c> migList1 = [SELECT Scheduled_Complexity_1__c FROM IMT_Migration_Set__c WHERE Id IN :canceledCompMap1.keySet()];
		for(IMT_Migration_Set__c mig1 :migList1) {
			for(Id key :canceledCompMap1.keySet()) {
				if(mig1.Id == key) {
					mig1.Scheduled_Complexity_1__c -= canceledCompMap1.get(key);
				}	
			}			
		}
		update migList1;
		
		//SCHEDULE COMPLEXITY 2
		Map<Id, Decimal> canceledCompMap2 = new Map<Id,Decimal>();
    	for(AggregateResult result :[SELECT COUNT(Complexity_Value__c) total,IMT_Migration_Set__c 
    									FROM pse__Assignment__c 
    										WHERE ID IN :canceledIds AND Operational_Profile__c = 'B' 
    										GROUP BY IMT_Migration_Set__c]) {
    		canceledCompMap2.put((Id)result.get('IMT_Migration_Set__c'), (Decimal)result.get('total'));										
		}
		
		List<IMT_Migration_Set__c> migList2 = [SELECT Scheduled_Complexity_2__c FROM IMT_Migration_Set__c WHERE Id IN :canceledCompMap2.keySet()];
		for(IMT_Migration_Set__c mig2 :migList2) {
			for(Id key :canceledCompMap2.keySet()) {
				if(mig2.Id == key) {
					mig2.Scheduled_Complexity_2__c -= canceledCompMap2.get(key);
				}	
			}			
		}
		update migList2;
		
		//SCHEDULE COMPLEXITY 3
		Map<Id, Decimal> canceledCompMap3 = new Map<Id,Decimal>();
    	for(AggregateResult result :[SELECT COUNT(Complexity_Value__c) total,IMT_Migration_Set__c 
    									FROM pse__Assignment__c 
    										WHERE ID IN :canceledIds AND Operational_Profile__c = 'C' 
    										GROUP BY IMT_Migration_Set__c]) {
    		canceledCompMap3.put((Id)result.get('IMT_Migration_Set__c'), (Decimal)result.get('total'));										
		}
		
		List<IMT_Migration_Set__c> migList3 = [SELECT Scheduled_Complexity_3__c FROM IMT_Migration_Set__c WHERE Id IN :canceledCompMap3.keySet()];
		for(IMT_Migration_Set__c mig3 :migList3) {
			for(Id key :canceledCompMap3.keySet()) {
				if(mig3.Id == key) {
					mig3.Scheduled_Complexity_3__c -= canceledCompMap3.get(key);
				}	
			}			
		}
		update migList3;
		
		//SCHEDULE COMPLEXITY 4
		Map<Id, Decimal> canceledCompMap4 = new Map<Id,Decimal>();
    	for(AggregateResult result :[SELECT COUNT(Complexity_Value__c) total,IMT_Migration_Set__c 
    									FROM pse__Assignment__c 
    										WHERE ID IN :canceledIds AND Operational_Profile__c = 'D' 
    										GROUP BY IMT_Migration_Set__c]) {
    		canceledCompMap4.put((Id)result.get('IMT_Migration_Set__c'), (Decimal)result.get('total'));										
		}
		
		List<IMT_Migration_Set__c> migList4 = [SELECT Scheduled_Complexity_4__c FROM IMT_Migration_Set__c WHERE Id IN :canceledCompMap4.keySet()];
		for(IMT_Migration_Set__c mig4 :migList4) {
			for(Id key :canceledCompMap4.keySet()) {
				if(mig4.Id == key) {
					mig4.Scheduled_Complexity_4__c -= canceledCompMap4.get(key);
				}	
			}			
		}
		update migList4;
    }
    
    
    //EMAIL SENT TO MANAGER WHEN PROJECT IS CANCELED OR FALLBACK
    private void assignmentCanceledNotification(List<Id> canceledFallbackIds) {
    	
    	List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    	
    	for(pse__Assignment__c assign : [SELECT Cancellation_Reason__c,pse__Project__r.Property_Code__c,pse__Status__c,
		Scheduled_DateTime_GMT__c,pse__Project__r.IMT_Property__r.Name, pse__Project__r.pse__Project_Manager__r.Email, Link__c  
		FROM pse__Assignment__c WHERE Id IN :canceledFallbackIds]) {
			if (assign.pse__Project__r.pse__Project_Manager__r.Email != null) {
    			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    	//Set list of people who should get the email
		    	List<String> sendTo = new List<String>();
			    sendTo.add(assign.pse__Project__r.pse__Project_Manager__r.Email);
			    mail.setToAddresses(sendTo);
			    //Set who the email is sent from
			    mail.setReplyTo(UserInfo.getUserEmail());
			    mail.setSenderDisplayName(UserInfo.getName());
				//Set email contents
				String sub = 'The ' + assign.pse__Project__r.Property_Code__c + ' ' + assign.pse__Project__r.IMT_Property__r.Name + ' Migration Scheduled for ';
			    sub += assign.Scheduled_DateTime_GMT__c + ' has been ' + assign.pse__Status__c;
			    mail.setSubject(sub);
			    String body = 'The ' + assign.pse__Project__r.Property_Code__c + ' ' + assign.pse__Project__r.IMT_Property__r.Name + ' migration scheduled for ';
			    body += assign.Scheduled_DateTime_GMT__c + ' was ' + assign.pse__Status__c + ' due to ' + assign.Cancellation_Reason__c;
			    body += '<br/></br>Please view detail for additional detail ' + assign.Link__c;
			    mail.setHtmlBody(body);
			    //Add your email to the master list
			    mails.add(mail);
        	}
    	}	 	
    	//Send all emails in the master list
  		Messaging.sendEmail(mails);
    }
    
    //CREATE RECURRING TASK FOR PROJECT MANAGER
     private void createRecurringTaskForPM(List<Id> canceledIds) {
     	List<Task> recurringTasks = new List<Task>();
     	for(pse__Assignment__c assign : [SELECT pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c,
     										pse__Project__r.pse__Project_Manager__c  
     										FROM pse__Assignment__c WHERE Id IN :canceledIds]) {
			if(assign.pse__Project__r.pse__Project_Manager__c != NULL) {
				Task recurTask = new Task();
				recurTask.OwnerId = assign.pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c;
				recurTask.WhoId = assign.pse__Project__r.pse__Project_Manager__c;
				recurTask.Subject = 'Follow-up on Rescheduling';
				recurTask.WhatId = assign.Id;
				recurTask.IsRecurrence = true;
				recurTask.RecurrenceStartDateOnly = System.today();
				recurTask.RecurrenceEndDateOnly = System.today()+30;
				recurTask.RecurrenceType = 'RecursWeekly';
				recurTask.RecurrenceDayOfWeekMask = 4;
				recurTask.IsReminderSet = TRUE; 
				recurTask.RecurrenceInterval = 1;
				recurringTasks.add(recurTask);	
			}									
		}
		insert recurringTasks;
     }
    
*/    
}