/***This class is used by the Partner Marketing Tab. The Partner Marketing tab is used to provide
the Partner with information on how to market their product with Newmarket as well as information
on User conferences***/


public class NI_PartnerMarketingController {
   
   
   //Attachment for the Company's Logo
   public Attachment companyLogo {
      get {
          if (companyLogo == null)
              companyLogo = new Attachment();
              return companyLogo;
        }
      set;
      }
      
     //Attachment for the Company's Press Release
     public Attachment companyPressRelease {
      get {
          if (companyPressRelease == null)
              companyPressRelease = new Attachment();
              return companyPressRelease;
        }
      set;
      }
      
    //Variables on VF Page
    public String CompanyName { get; set; }
    public String CompanyDescription { get; set; }
    public String LogoContentType { get; set; }
    public String PressReleaseContentType { get; set; }
    
    //Constructor
    public NI_PartnerMarketingController()
    {
    
    }  
    
  //This method creates a case containing the company's name, description, logo and press release   
  public PageReference upload() {

    String caseQueueName;
    List<NI_Partner_Channel_Order__c> lstCSPartnerChannel = NI_Partner_Channel_Order__c.getAll().values();
    for (NI_Partner_Channel_Order__c cs : lstCSPartnerChannel)
    {
        if(cs.Name == 'Cendyn')
        {
            caseQueueName = cs.Case_Default_Queue__c;
        }
    }
    
    String messageString = 'Marketing Collateral has been sent to Newmarket Partner Management.';
    
    System.Debug( 'Logo content type ' + LogoContentType );
    System.Debug( 'press release content type ' + PressReleaseContentType);
    
    
    if( companyLogo.Name != NULL && ( LogoContentType !='image/jpeg' && LogoContentType !='image/png' && LogoContentType !='image/gif' && LogoContentType !='image/jpg') )
    {
        messageString = 'The Logo Should be a Jpeg or Png';
        
    }
    if( companyPressRelease.Name!= NULL && ( PressReleaseContentType != 'Text/Plain' && PressReleaseContentType != 'Text/Enriched'  && PressReleaseContentType != 'application/msword'))
    {
        messageString = 'The Press Release should be in a text file or Microsoft Word document';
    }
    
    
    
   
    Case marketingCase = new Case();
    marketingCase.Description = 'HRM New Marketing Collateral from Partner Portal ' + companyName + ' ' + dateTime.Now();
    marketingCase.Description +=' Company Name: ' + CompanyName;
    marketingCase.Description += ' Company Description: ' + CompanyDescription;
    marketingCase.Subject = 'HRM New Marketing Collateral from Partner Portal '+  + companyName + ' ' + dateTime.Now();
    marketingCase.Origin = 'Email';
    marketingCase.Status = 'New';
    marketingCase.Has_No_Di__c = true;
       
    Group caseQueue = [SELECT Id FROM GROUP Where Name = :caseQueueName];
    marketingCase.ownerId = caseQueue.Id;
    
    insert marketingCase;
    
    if( companyLogo.Name != NULL )
    {
        companyLogo.OwnerId = userInfo.getUserId();
        companyLogo.ParentId = marketingCase.Id; // the record the file is attached to
        companyLogo.IsPrivate = false;
         try {
              insert companyLogo;
             
            } catch (DMLException e) {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
              return null;
            } finally {
              companyLogo = new Attachment(); 
     
        }
    }
    
    if( companyPressRelease.Name != NULL )
    {
        companyPressRelease.OwnerId = userInfo.getUserId();
        companyPressRelease.ParentId = marketingCase.Id;
        companyPressRelease.IsPrivate = false;
        
          try {
              insert companyPressRelease;
             
            } catch (DMLException e) {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
              return null;
            } finally {
              companyPressRelease = new Attachment(); 
     
        }
    }
    
   

    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, messageString));
    return null;
  }
  
  
  
 
  
}