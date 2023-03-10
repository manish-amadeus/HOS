@isTest //(SeeAllData=true)                                      
public class NI_PartnerMarketingControllerTest 
{
    public static testMethod void NI_PartnerMarketingControllerTest() 
    {
       
        NI_Partner_Channel_Order__c pSettings;
        pSettings = NI_Partner_Channel_Order__c.getValues('Cendyn');
        
        if( pSettings == null )
        {
            pSettings = new NI_Partner_Channel_Order__c();
            pSettings.Name = 'Cendyn';
            pSettings.Case_Default_Queue__c = 'Q-Subscription Management';
            Database.insert( pSettings );
        }
    
        
        NI_PartnerMarketingController pMarketingClass = new NI_PartnerMarketingController();
        pMarketingClass.CompanyName = 'Partner Test';
        pMarketingClass.CompanyDescription = 'Partner Test';
        pMarketingClass.LogoContentType = 'image/jpg';
        pMarketingClass.PressReleaseContentType = 'application/msword';
        
       
        Blob logoBlob = Blob.valueOf('Test attachment Body');
        
        pMarketingClass.companyLogo.body = logoBlob;
        pMarketingClass.companyLogo.Name = 'Logo';
        pMarketingClass.companyLogo.contentType = 'image/jpg';
        
        
        
        Attachment pressRelease = new Attachment();
        Blob pressReleaseBlob = Blob.valueof('Test press release body');
        pMarketingClass.companyPressRelease.Name = 'Press Release Name';
        pMarketingClass.companyPressRelease.contentType = 'application/msword';
        pMarketingClass.companyPressRelease.Body = pressReleaseBlob;
        
          
        pMarketingClass.Upload();
        
       
        
    }
    
    public static testMethod void NI_PartnerMarketingControllerNegativeTest() 
    {
       
        NI_Partner_Channel_Order__c pSettings;
        pSettings = NI_Partner_Channel_Order__c.getValues('Cendyn');
        
        if( pSettings == null )
        {
            pSettings = new NI_Partner_Channel_Order__c();
            pSettings.Name = 'Cendyn';
            pSettings.Case_Default_Queue__c = 'Q-Subscription Management';
            Database.insert( pSettings );
        }
    
        
        NI_PartnerMarketingController pMarketingClass = new NI_PartnerMarketingController();
        pMarketingClass.CompanyName = 'Partner Test';
        pMarketingClass.CompanyDescription = 'Partner Test';
        pMarketingClass.LogoContentType = 'application/msword';
        pMarketingClass.PressReleaseContentType = 'image/jpg';
        
       
        Blob logoBlob = Blob.valueOf('Test attachment Body');
        
        pMarketingClass.companyLogo.body = logoBlob;
        pMarketingClass.companyLogo.Name = 'Logo';
        pMarketingClass.companyLogo.contentType = 'application/msword';
        
        
        
        Attachment pressRelease = new Attachment();
        Blob pressReleaseBlob = Blob.valueof('Test press release body');
        pMarketingClass.companyPressRelease.Name = 'Press Release Name';
        pMarketingClass.companyPressRelease.contentType = 'image/jpg';
        pMarketingClass.companyPressRelease.Body = pressReleaseBlob;
        
          
        pMarketingClass.Upload();
        
        
     
    }
    
    
    
    public static testMethod void NI_PartnerMarketingControllerExceptionTest() 
    {
       
        NI_Partner_Channel_Order__c pSettings;
        pSettings = NI_Partner_Channel_Order__c.getValues('Cendyn');
        
        if( pSettings == null )
        {
            pSettings = new NI_Partner_Channel_Order__c();
            pSettings.Name = 'Cendyn';
            pSettings.Case_Default_Queue__c = 'Q-Subscription Management';
            Database.insert( pSettings );
        }
    
        
        NI_PartnerMarketingController pMarketingClass = new NI_PartnerMarketingController();
        pMarketingClass.CompanyName = 'Partner Test';
        pMarketingClass.CompanyDescription = 'Partner Test';
        pMarketingClass.LogoContentType = 'application/msword';
        pMarketingClass.PressReleaseContentType = 'image/jpg';
        
       
        pMarketingClass.companyLogo.Name = 'Logo';
        pMarketingClass.companyLogo.contentType = 'application/msword';
        pMarketingClass.Upload();
          
        
        
        pMarketingClass.CompanyName = 'Partner T Exceptionest';
        pMarketingClass.CompanyDescription = 'Partner Exception Test';
        pMarketingClass.companyPressRelease.Name = 'Press Release Name';
        pMarketingClass.companyPressRelease.contentType = 'image/jpg';
        pMarketingClass.Upload();
          
      
        
        
     
    }
    
    
}