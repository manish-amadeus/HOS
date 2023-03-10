trigger UpdateLastStatusReportDate on StatusReport__c (after insert)
{

    for (StatusReport__c sr : Trigger.new) 
    {  

        User u = [SELECT Name, Id, LastStatusReportDate__c FROM User WHERE Id = :sr.Associate__c];
        u.LastStatusReportDate__c = Date.today();
        Update u;

    }

}