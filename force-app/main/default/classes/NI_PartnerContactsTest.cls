@isTest //(SeeAllData=true)                                      
public class NI_PartnerContactsTest 
{
    public static testMethod void NI_PartnerContactsTest() 
    {
        Account pAccount = NI_TestClassData.CreateTestAccount(1);
        insert pAccount;
        Contact pContact = NI_TestClassData.CreateTestContact(1, pAccount.id);
        insert pContact;
        Contact pContact2 = NI_TestClassData.CreateTestContact(2, pAccount.id);
        insert pContact2;
    
    
        NI_Partner_Channel_Order__c pSettings;
        pSettings = NI_Partner_Channel_Order__c.getValues('Cendyn');
        
        if( pSettings == null )
        {
            pSettings = new NI_Partner_Channel_Order__c();
            pSettings.Name = 'Cendyn';
            pSettings.Partner_Contacts__c = pContact.Name + ',' + pContact2.Name;
            Database.insert( pSettings );
        }
    
        
        NI_PartnerContacts pContactsClass = new NI_PartnerContacts();
        pContactsClass.getPartnerContacts();
      
    }
    
}