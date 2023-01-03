/****************************************************************************************
Name            : NI_Sales_Expense_Report_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 7/8/2013
Last Mod Date   : 7/8/2013
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Call the After Update Methods in the NI_Sales_Expense_Report_TriggerHandler Class
                : Call the handler methods in the appropriate order of execution
                : 
******************************************************************************************/
trigger NI_Sales_Expense_Report_AfterUpdate on Expense_Report__c (after update) 
{

    NI_Sales_Expense_Report_TriggerHandler handler = new NI_Sales_Expense_Report_TriggerHandler(true);

        handler.OnAfterUpdate(Trigger.new,Trigger.oldMap);
    
}