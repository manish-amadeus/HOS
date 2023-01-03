/****************************************************************************************
Name            : AH_BatchUpdateCaseTodaysStartEndTime Class
Author          : Cybage Developer - Shashikant Nikam
Created Date    : 01/15/2018
Last Mod Date   : 08/13/2019
Last Mod By     : Cybage Developer - Shashikant Nikam
NICC Reference  : NICC-026092
Description     : This batch class calls AH_BatchCaseTodaysStartEndTimeHandler 
				: which updates the Start & End Time and Previous Business Hoturs on Case.
                :
*****************************************************************************************/
global class AH_BatchUpdateCaseTodaysStartEndTime implements Database.Batchable<sObject> 
{

    public static String dayOfWeek = System.now().format('EEEE');

    global Database.QueryLocator start (Database.BatchableContext BC){
        
        String query = NULL; 
        
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes = [SELECT 	Name, Enabled_Activity_Types__c, Clear_Case_Origins__c, Enabled_Case_Type__c
                        	FROM AH_Case_Flags_Store_Types__c
                            WHERE Name = 'Default' LIMIT 1];
        
		String recTypes = flagRecTypes.Enabled_Case_Type__c;
        System.debug('flagRecTypes => ' +flagRecTypes);
            
        if ( recTypes != NULL) {

			List<String> lstRecordtypes = String.valueOf(recTypes).split(',');
			System.debug('List of Case Record Types :'+lstRecordtypes);
            
            query = 'select id, BusinessHours.Id, BusinessHours.Name, '+
                'BusinessHours.MondayStartTime, BusinessHours.MondayendTime,'+ 
                'BusinessHours.TuesdayStartTime, BusinessHours.TuesdayendTime,'+
                'BusinessHours.WednesdayStartTime, BusinessHours.WednesdayendTime, '+
                'BusinessHours.ThursdayStartTime, BusinessHours.ThursdayendTime, '+
                'BusinessHours.FridayStartTime, BusinessHours.FridayendTime, '+
                'BusinessHours.SaturdayStartTime, BusinessHours.SaturdayendTime, '+
                'BusinessHours.SundayStartTime, BusinessHours.SundayendTime, '+
                'AH_Case_Flagged_Date__c, AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, '+
                'AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c, '+
                'AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, '+
                'AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c, '+
                'AH_Enable_Case_Flag__c from Case where AH_Case_Flagged_Date__c != NULL and RecordTypeId in : lstRecordtypes'; 
				
            System.debug('Query : ' +query);
        }
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext BC, List<Case> cases ){

        List<Case> case_list = new List<Case>();
        List<Case> case_to_be_passed = new List<Case>();
        System.debug('Case size after query : ' +cases.size());

		// CREATED BY CYBAGE FOR NICC-026092
		// CONDITIONALLY SETS CASE FLAG RELATED FIELD BEFORE COMMIT TO DATABASE (IF TRIGGER BYPASS NOT ON)               
		if (!NI_FUNCTIONS.bypassTriggerCode('CASE FLAGS'))
		{
            AH_CaseFlagPreferences__c caseFlagSetting = AH_CaseFlagPreferences__c.getInstance();
            
            for(Case c : cases) 
            {
                if (caseFlagSetting.Organisation_Wide__c == true ||
                    (caseFlagSetting.Organisation_Wide__c == false && c.AH_Enable_Case_Flag__c == true)) 
                {
                    case_to_be_passed.add(c);
                }
            }
            System.debug('Cases to be processed : ' +case_to_be_passed.size());
            
            AH_BatchCaseTodaysStartEndTimeHandler handler_obj = new AH_BatchCaseTodaysStartEndTimeHandler();
            case_list = handler_obj.getCasesWithTime(case_to_be_passed);
            
            Set<ID> caseIds = new Set<ID>();
            for(Case cs : case_list)
            {
                caseIds.add(cs.id);
            }
            
            List<Case> csList = new List<Case>([SELECT ID FROM Case where ID IN: caseIds FOR UPDATE]);
            
            if (!case_list.isEmpty()){
                System.debug('Case List to be updated : '+case_list);
                NI_Case_TriggerHandler.callFuture = false;
                update case_list;
            }
            
        }
        system.debug('case_list.size  :' + case_list.size() );
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}