/****************************************************************************************
Name            : psaTransactionBiu_SetTimecardRevenueTxIneligible
Author          : CLD
Created Date    : November 14, 2011
Description     : When a Transaction record for a Timecard is created, checks whether
                : the record is a 'Ready-to-Bill Revenue' category and Type 'Timecard.'
                : If so, it sets the 'Related Record Ineligible' value to True so that
                : the timecard amount doesn't get included in transaction roll-ups to 
                : the Project, Region, and Practice.
******************************************************************************************/
trigger psaTransactionBiu_SetTimecardRevenueTxIneligible on pse__Transaction__c (before insert, before update) 
{
    public static final String TX_TYPE_TIMECARD = 'Timecard';
    public static final String TX_CATEGORY_RTBR = 'Ready-to-Bill Revenue';
    
    for(pse__Transaction__c tx: Trigger.New)
    {
        try
        {
            System.debug('***** Transaction type: ' + tx.pse__Type__c);
            System.debug('***** Transaction category: ' + tx.pse__Category__c);
            
            if(tx.pse__Type__c!=null && tx.pse__Type__c.equals(TX_TYPE_TIMECARD))
            {
                if(tx.pse__Category__c!=null && tx.pse__Category__c.equals(TX_CATEGORY_RTBR))
                {
                    System.debug('***** Timecard tx with ready-to-bill revenue: ' + tx.pse__Amount__c);
                    tx.pse__Related_Record_Deleted__c = true;
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Error setting related record ineligible for timecard transaction: ' + e.getMessage());
            tx.addError('Error setting related record ineligible for timecard transaction: ' + e.getMessage());
        }
    }
}