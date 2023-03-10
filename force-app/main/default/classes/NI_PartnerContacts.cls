public with sharing class NI_PartnerContacts 
{

    //This class is the controller for the partner contracts page
    //It gets all users whose names are in the custom setting Partner Channel Contacts
     public list<User> partnerContacts; 
     public list<user> getPartnerContacts()
     {
         return partnerContacts;
     }

    public NI_PartnerContacts()    
    {  
        List<String> pManagement;
        List<NI_Partner_Channel_Order__c> lstCSPartnerChannel = NI_Partner_Channel_Order__c.getAll().values();
        for(NI_Partner_Channel_Order__c cs : lstCSPartnerChannel)
        {
          if(cs.Name == 'Cendyn')
            {
               pManagement  = cs.Partner_Contacts__c.split(',');
           
            }
        }
        if( pManagement != null )
            partnerContacts = [ SELECT Id, AboutMe, FullPhotoURL, Name, Email, Phone, Title, SmallPhotoURL FROM User where User.Name in :PManagement Order by Title ];
    }
}