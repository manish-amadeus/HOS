/***********************************************************************************************
Name            : AH_Outage_StartNotificationsExt
Author          : Shashikant Nikam
Created Date    : 06/07/2018
Last Mod Date   : 06/08/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : This class handles the code that updates the fields on NI Trust Outage records 
				: when Start Notifications button is clicked
                :
************************************************************************************************/
public class AH_Outage_StartNotificationsExt 
{
    
	NI_Trust_Outage__c out = new NI_Trust_Outage__c();
    public NI_Trust_Outage__c outage {get; set;}
    public Boolean showButton {get; set;}
    
    // CONSTRUCTOR
    public AH_Outage_StartNotificationsExt(ApexPages.StandardController std)
    {
        this.out = (NI_Trust_Outage__c)std.getRecord();
        outage = [SELECT ID, Status__c, RecordTypeID, Send_Notifications__c, Severity__c FROM NI_Trust_Outage__c WHERE Id =: out.id];
    }
    
	// METHOD TO UPDATE THE FIELDS - Send Notificatons & Status
    public PageReference startNotifications()
    {
        
        if (outage.id != NULL)
        {

            // RETRIVE VALID RECORD TYPES FROM CUSTOM SETTINGS
            NI_Trust_Outage_Email__c outage_CustSetting = NI_Trust_Outage_Email__c.getInstance();
            List<String> lstRecTypes = new List<String>();
            
            if (outage_CustSetting.Record_Types__c != NULL)
            {
                lstRecTypes = outage_CustSetting.Record_Types__c.split(',');
            }
            
            // CREATE SET OF VALID RECORD TYPE IDS
            Set<String> setRecordTypeIds = new Set<String>();
            Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.NI_Trust_Outage__c.getRecordTypeInfosByName();
            for (String recType : lstRecTypes)
            {
                if (recordTypesMap.containsKey(recType)) 
                {
                    Schema.RecordTypeInfo rr = recordTypesMap.get(recType);
                    setRecordTypeIds.Add(rr.getRecordTypeId());
                }
            }
            
            // UPDATE ONLY WHEN RECORD SATIFIES BELOW CONDITION ELSE SHOW INFO PAGE
            if (outage.Status__c == 'New' && outage.Send_Notifications__c == False 
                && (outage.Severity__c == '1 - Critical' || outage.Severity__c == '2 - Urgent')
                && setRecordTypeIds.contains(outage.RecordTypeId) 
               )
            {
                outage.Status__c = 'Open Stage 1';
                outage.Send_Notifications__c = TRUE;
                
                update outage;
                Pagereference pgRef = new PageReference('/'+outage.id);
				return pgRef;
            }
            else if (!setRecordTypeIds.contains(outage.RecordTypeId))
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Notifications will be sent only to specified Record Types.'));
                showButton = true;
            }
            else if (outage.Severity__c != '1 - Critical' && outage.Severity__c != '2 - Urgent')
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Notifications will not be sent for Severity 3 & 4.'));
                showButton = true;
            }
            else if (outage.Send_Notifications__c == true)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Already Nofitications have been started.'));
                showButton = true;
            } 
            else 
            {
                Pagereference pgRef = new PageReference('/'+outage.id);
				return pgRef;
            }
		}
        return null;
    }
    
}