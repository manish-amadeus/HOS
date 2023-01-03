/****************************************************************************************
Name            : AH_SurveyResponseDataTriggerHandler Class
Author          : Ria Chawla
Created Date    : 09/07/2017
Last Mod Date   : 01/10/2018 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-024092
Description     : Class that handles all trigger code for the Confirmit_Survey_Response_Data__c Object
                : UPDATED 1/10/2018 PER NICC-025511 
******************************************************************************************/
public class AH_SurveyResponseDataTriggerHandler 
{
    
    
    public void OnBeforeInsert(List<Confirmit_Survey_Response_Data__c> newTrigger)
    {
        Update_Contact(newTrigger);  
    }

/*  ---- COMMENTED CODE AS THIS WILL BE HANDLED VIA BATCH APEX ----
    public void onAfterInsert(List<Confirmit_Survey_Response_Data__c> newTrigger)
    {
        
        Set<Id> contactIdSet = new Set<Id>();
        List<Confirmit_Survey_Response_Data__c> dataToProcess = new List<Confirmit_Survey_Response_Data__c>();
        
        // LOOP THROUGH THE NEWTRIGGER AND CREATE A SET TO HOLD CONTACT IDS
        for (Confirmit_Survey_Response_Data__c surveyData : newTrigger)
        {
            if (surveyData.Contact__c != null)
            {
                contactIdSet.add(surveyData.Contact__c);
                dataToProcess.add(surveyData);
            }
        }
        
        if (!contactIdSet.isEmpty())
        {
            calculateNPSandOST(dataToProcess, contactIdSet);
        }
        
    }
*/

/*  ---- COMMENTED CODE AS THIS WILL BE HANDLED VIA BATCH APEX ----
    public void onAfterUpdate(List<Confirmit_Survey_Response_Data__c> newTrigger, Map<Id,Confirmit_Survey_Response_Data__c> oldMapTrigger)
    {

        Set<Id> contactIdSet = new Set<Id>();
        List<Confirmit_Survey_Response_Data__c> dataToProcess = new List<Confirmit_Survey_Response_Data__c>();
        
        // LOOP THROUGH THE NEWTRIGGER AND CREATE A SET TO HOLD CONTACT IDS IF THEIR NPS OR OSAT IS UPDATED
        for (Confirmit_Survey_Response_Data__c surveyData : newTrigger)
        {
            Confirmit_Survey_Response_Data__c oldData = oldMapTrigger.get(surveyData.Id);
            if ((oldData.NPS__c != surveyData.NPS__c || oldData.OSAT__c != surveyData.OSAT__c) && surveyData.Contact__c != null)
            {
                contactIdSet.add(surveyData.Contact__c);
                dataToProcess.add(surveyData);
            }
        }
        
        if (!contactIdSet.isEmpty())
        {
            calculateNPSandOST(dataToProcess, contactIdSet);
        }
        
    }
*/

    //==========================================================================================================================================  
    //METHOD TO CALCULATE NPS AND OSAT ON CONTACT OBJECT
    //public List<Contact> calculateNPSandOST(List<Confirmit_Survey_Response_Data__c> newTrigger, Set<Id> contactIdSet)
    public List<Contact> calculateNPSandOST(Set<Id> contactIdSet)
    {
system.debug('in calculateNPSandOST ... contactIdSet = ' + contactIdSet);        
/* 
        EXAMPLE OF THE LOGIC TO CALCULATE THE NPR SCORE
        NPR Example: 
        10 total surveys 
        6 surveys = promoter (9 or 10) 
        3 surveys = detractors (0-6) 
        1 survey = passive (7 or 8) 
        
        (6/10) - (3/10) 
        
        60% - 30% = 30 (represented as a number not a %) This is the number that should populate the "Net Promoter Score (NPS)" field.
                
        EXAMPLE OF LOGIC TO CALCULATE THE OSAT SCORE
        The Overall Satisfaction is the mean score of all of the results 
        Ex: 4 surveys 
        Survey 1 = 7 
        Survey 2 = 10 
        Survey 3 = 5 
        Survey 4 = 8 
        Mean Score: (7+10+5+8)/4 = 7.50. 
        Note: we would go out to 2 decimal places as shown above. 
        The "Overall Satisfaction" field on the Contact record would be populated with 7.50 
*/
        
        
        //Map<Id, Integer> totalSdCount = new Map<Id, Integer>();
        
        // PER ALESHA BENCIVENGA WE WANT TO -EXCLUDE- SURVEYS FROM THE TOTAL COUNT OF NPS IF THE NPS FIELD IS NULL.
        // WE WANT TO -EXCLUDE- THE SURVEYS FROM THE TOTAL COUNT OF THE OSAT IF THE OSAT FIELD IS NULL
        // WE CREATE SEPARATE MAP COLLECTIONS TO HOLD THE TOTAL NPS AND OSAT SURVEYS
        Map<Id, Integer> totalSdCountNPS = new Map<Id, Integer>(); 
        Map<Id, Integer> totalSdCountOSAT = new Map<Id, Integer>();
        Decimal promoters = 0.0;
        Decimal detractors = 0.0;
        Decimal osats = 0.0;
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, Net_Promoter_Score_NPS__c FROM Contact WHERE Id IN : contactIdSet]);
        Map<Id, Decimal> contPromoters = new Map<Id, Decimal>();
        Map<Id, Decimal> contDetractors = new Map<Id, Decimal>();
        Map<Id, Decimal> contOsats = new Map<Id, Decimal>();

system.debug('contactMap = ' + contactMap);
        
/*        
        // GET THE COUNT OF ALL SURVEY RECORDS PRESENT WHOSE CONTACT IS SAME AS THAT OF INSERTED OR UPDATED RECORD
        for (AggregateResult countSurveyRecords : [SELECT Contact__c, COUNT(Id) cnt  
                                                   FROM Confirmit_Survey_Response_Data__c
                                                   WHERE Contact__c IN : contactIdSet GROUP BY Contact__c])
        {
            totalSdCount.put((ID)countSurveyRecords.get('Contact__c'), (integer)countSurveyRecords.get('cnt'));
        }
*/
        
        // GET THE COUNT OF ALL SURVEY RECORDS PRESENT WHOSE CONTACT IS SAME AS THAT OF INSERTED OR UPDATED RECORD AND NPS IS NOT NULL
        for (AggregateResult countSurveyRecords : [SELECT Contact__c, COUNT(Id) cnt, SUM(NPS__c) npsCnt  
                                                   FROM Confirmit_Survey_Response_Data__c
                                                   WHERE Contact__c IN : contactIdSet
                                                   AND NPS__c != null
                                                   GROUP BY Contact__c])
        {
system.debug('Confirmit Survey Response NPS = ' + countSurveyRecords); 
            totalSdCountNPS.put((ID)countSurveyRecords.get('Contact__c'), (Integer)countSurveyRecords.get('cnt')); 
        }
       
        // GET THE COUNT OF SURVEY RECORDS PRESENT WHOSE CONTACT IS SAME AS THAT OF INSERTED OR UPDATED RECORD AND OSAT IS NOT NULL
        for (AggregateResult countSurveyRecords : [SELECT Contact__c, COUNT(Id) cnt, SUM(OSAT__c) sumOsat 
                                                   FROM Confirmit_Survey_Response_Data__c
                                                   WHERE Contact__c IN : contactIdSet
                                                   AND OSAT__c != null
                                                   GROUP BY Contact__c])
        {
system.debug('Confirmit Survey Response OSAT = ' + countSurveyRecords);             
            totalSdCountOSAT.put((ID)countSurveyRecords.get('Contact__c'), (Integer)countSurveyRecords.get('cnt'));
            contOsats.put((ID)countSurveyRecords.get('Contact__c'), (Decimal)countSurveyRecords.get('sumOsat'));
        }        
        
        // GET A LIST OF ALL SURVEY RESPONSE DATA RECORDS WHOSE CONTACT ID IS SAME AS THAT OF INSERTED OR UPDATED RECORD
        List<Confirmit_Survey_Response_Data__c> surveyResponseData = new List<Confirmit_Survey_Response_Data__c>();
        
        if (!contactIdSet.isEmpty())
        {
            surveyResponseData = [SELECT Id, Name, Contact__c, NPS__c, OSAT__c
                                  FROM Confirmit_Survey_Response_Data__c
                                  WHERE Contact__c IN : contactIdSet];
system.debug('surveyResponseData = ' + surveyResponseData);
        }
        
        // PREPOPULATED MAPS WITH CONTACT ID KEY AND DEFAULT 0 VALUES
        for (Id ct : contactMap.keySet())
        {
            contPromoters.put(ct, 0.0);
            contDetractors.put(ct, 0.0);
        }
                
        // LOOP THROUGH SURVEY RESPONSE DATA RECORDS AND STORE VALUES
        for (Confirmit_Survey_Response_Data__c respData : surveyResponseData)
        {
system.debug('Contact = ' + contactMap.get(respData.Contact__c) + ', NPS Score = ' + respData.NPS__c);            
            Decimal p = 0.0;
            Decimal d = 0.0;
            
            // GET THE COUNT OF SURVEY RECORDS WHOSE NPS VALUE 9 OR 10 (PROMOTERS)
            if (respData.NPS__c != null && (Integer.valueOf(respData.NPS__c) == 9 || Integer.valueOf(respData.NPS__c) == 10))
            {
                  
                p++;
                if (contPromoters.containsKey(respData.Contact__c))
                {
                    Decimal k = contPromoters.get(respData.Contact__c);
                    k = k + p;
                    contPromoters.put(respData.Contact__c, k);
                }
                else
                {
                    contPromoters.put(respData.Contact__c, p);
                }
                
            }
system.debug('Promoter Count = ' + contPromoters.get(respData.Contact__c));            
            //GET THE COUNT OF SURVEY RECORDS WHOSE NPS VALUE IS IN BETWEEN 0 AND 6 (DETRACTORS)
            if (respData.NPS__c != null && (Integer.valueOf(respData.NPS__c) >= 0 && Integer.valueOf(respData.NPS__c) <= 6))
            {
                
                d++;
                if (contDetractors.containsKey(respData.Contact__c))
                {
                    Decimal k = contDetractors.get(respData.Contact__c);
                    k = k + d;
                    contDetractors.put(respData.Contact__c, k);
                }
                else
                {
                    contDetractors.put(respData.Contact__c, d);
                }
            }
           	            
system.debug('Detractor Count = ' + contDetractors.get(respData.Contact__c));             
/*
            // GET SUM OF OSAT VALUES TO CALCULATE MEAN
            if (respData.OSAT__c != null)
            {
                if (contOsats.containsKey(respData.Contact__c))
                {
                    Decimal k = contOsats.get(respData.Contact__c);
                    k = k + respData.OSAT__c;
                    contOsats.put(respData.Contact__c, k);
                }
                else
                {
                    contOsats.put(respData.Contact__c, respData.OSAT__c);
                }
            }
*/
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (Id i : contactMap.keySet())
        {
system.debug('Contact = ' + contactMap.get(i).Name + ', Promoters = ' + contPromoters.get(i) + ', detractors = ' + contDetractors.get(i));   
            
            // RESET VARIABLES
            promoters = 0.0;
            detractors = 0.0;
            osats = 0.0;            
            
            if (contPromoters.containsKey(i))
            {
                //CALCULATE PERCENTAGE OF PROMOTERS
                promoters = (contPromoters.get(i) / totalSdCountNPS.get(i)) * 100;
            }
            
            if (contDetractors.containsKey(i))
            {
                // CALCULATE PERCENTAGE OF DETRACTORS
                detractors = (contDetractors.get(i) / totalSdCountNPS.get(i)) * 100;
            }
            
            if (contOsats.containsKey(i))
            {
                // CALCULATE MEAN OF OSAT VALUES
                osats = contOsats.get(i) / totalSdCountOSAT.get(i);
            }
            
            // GET THE CONTACT RECORD, UPDATE FIELDS AND ADD TO THE LIST TO UPDATE
            Contact con = contactMap.get(i);
            con.Net_Promoter_Score_NPS__c = (promoters - detractors);
            con.Overall_Satisfaction__c = osats;
system.debug('Contact = ' + con);           
            contactsToUpdate.add(con);
            
        }
        
        if (!contactsToUpdate.isEmpty())
        {
            if (system.isBatch())
            {
system.debug('isBatch = true');
system.debug('Contact List = ' + contactsToUpdate);
                return contactsToUpdate;
            }
            else
            {
system.debug('isBatch = false');
system.debug('Contact List = ' + contactsToUpdate);                
                updateContacts(contactsToUpdate);
            }
        }
        
        return null;
        
/*
		AH_UpdateContactScoreController.successContacts = 0;
		AH_UpdateContactScoreController.failedContacts = 0;

		// UPDATE NET PROMOTER SCORE AND OVERALL SATISFACTION VALUES ON CONTACT OBJECT
		if (!contactsToUpdate.isEmpty())
		{
			database.saveresult[] ds = Database.update(contactsToUpdate, false);
			for (database.SaveResult d : ds)
			{
				if (d.isSuccess())
				{
					AH_UpdateContactScoreController.successContacts++;
					//AH_BatchSurveyResponseData.contactsUpdatedSet.add()
					system.debug('AH_UpdateContactScoreController.successContacts = ' + AH_UpdateContactScoreController.successContacts);
				}
                else
                {
                    AH_UpdateContactScoreController.failedContacts++;
                    system.debug('AH_UpdateContactScoreController.failedContacts'+AH_UpdateContactScoreController.failedContacts);
                }
			}
		}
*/
    }
    
    public void updateContacts(List<Contact> contactsToUpdate)
    {
        if (!contactsToUpdate.isEmpty())
        {
            update contactsToUpdate;
        }
    }
    
    public void Update_Contact(List<Confirmit_Survey_Response_Data__c> newTrigger)
    {
		//THIS METHOD UPDATES THE CONTACT FIELD
        Set<Id> setContactIds = new Set<Id>();
        
        for (Confirmit_Survey_Response_Data__c s : newTrigger)
        {
            setContactIds.add(s.Confirmit_Contact_ID__c);
        }
        
        // MAP TO HOLD THE FIELD VALUES OF THE CONTACT RECORDS RELATED TO SURVEY RESPONSE DATA RECORDS
        Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id                                                                                                                                                                         
                                                             FROM Contact
                                                             WHERE Id IN: setContactIds]);        
        
        // IF THE SURVEY RESPONSE DATA RECORD BEING INSERTED HAS THE Confirmit_Contact_ID__c FIELD POPULATED, 
        // THEN POPULATE THE "CONTACT" FIELD WITH THE RELATED CONTACT BASED ON THE Confirmit_Contact_ID__c VALUE
        if (mapContacts.size() > 0)
        {
            for (Confirmit_Survey_Response_Data__c sr : newTrigger) 
            {
                // if (sr.Confirmit_Contact_ID__c != null && mapContacts.get(sr.Confirmit_Contact_ID__c).Id != null) 	// ORIGINAL CODE COMMENTED PER NICC-025511
                if (sr.Confirmit_Contact_ID__c != null && mapContacts.containsKey(sr.Confirmit_Contact_ID__c)) 			// NEW CODE ADDED 1/10/2018 PER NICC-025511   
                {
                    system.debug('SURVEY RESPONSE DATA CONTACT: ' + mapContacts.get(sr.Confirmit_Contact_ID__c).Id);   
                    sr.Contact__c = mapContacts.get(sr.Confirmit_Contact_ID__c).Id;
                }
            }          
        }
        
    }
    
}