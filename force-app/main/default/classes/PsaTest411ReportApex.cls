/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest 
private class PsaTest411ReportApex 
{

    static testMethod void testApex_Psa411ExtractScheduledApex() 
    {
    	// Test the batch method
    	Test.startTest();
    	new Psa411ReportExtract().runScheduledExtract();
    	Test.stopTest();	
    }
    
    static testMethod void testApex_Psa411ExtractTrigger() 
    {
    	// Test the manual method (using the trigger)
    	Test.startTest();
    	PSA_411_Report__c reportHeader = new PSA_411_Report__c();
    	reportHeader.From_Date__c = System.today() - 1;
    	reportHeader.To_Date__c = System.today() + 1;
    	reportHeader.Run_As_Scheduled_Batch__c = false;
    	insert reportHeader;
    	Test.stopTest();
    }
    
}