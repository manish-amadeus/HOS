/****************************************************************************************
Name            : NI_ICEController Class
Author          : Sean Harris
Created Date    : 02/26/2014 
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
public class NI_ICEController 
{

    // THE OFFSET DAYS USED FOR LOCKING DOWN FORM PRIOR TO MIGRATION DATE
    public integer iDaysGrace {get; set;}

    public List<ICEProperty__c> lstMigrationProperty {get; set;} 
    public List<ICEUser__c> lstMigrationEndUser {get; set;} 
    public List<Attachment> lstAttachments {get; set;} 

    // TRUE IF AUTHKEY URL PARAMETER IS CORRECT
    public Boolean authenticated {get; set;}

    // TRUE IF USERS AND PROPERTIES SELECTION SHOULD BE LOCKED - FOR REVIEW PROPERTIES AND USERS PAGE
    public Boolean usersselectionlocked {get; set;}
                    
    // Migration Customer Record
    public ICESubscription__c iceSub {get; set;}
    
    // the contact found by authkey URL parameter
    public Contact loggedincontact {get; set;}
    // the value of authkey parameter
    public String authkey {get; set;}
    // the upgrade date
    public Date migrationdate {get; set;}
    // the list of files already uploaded - for merge documents upload page
    
    public String[] uploadeddocs {get; set;}
    // the number of files already uploaded - for merge documents upload page
    public Integer uploadeddocssize {get; set;}
    // for file upload form - file contents - for merge documents upload page
    public Blob uploadeddocbody {get; set;}
    // for file upload form - file name - for merge documents upload page
    public String uploadeddocname {get; set;}    

    // "I have read and acknowledge..." checkbox state - for Accept On-line Terms
    public Boolean agreementread {get; set;}
    // to display the message "check I have read... checkbox" - for Accept On-line Terms
    public Boolean agreementnotread {get; set;}
    // use logged in contact as authorization contact - for Accept On-line Terms
    
    public Boolean usecontactdata {get; set;}
    // true if merge documents upload should be locked - for Upload Merge Documents Templates and Logos page
    public Boolean fileuploadlocked {get; set;}
    // holds info on a page to be displayed - for MigrationPortalPage
//    public MigrationPortalPage__c page {get; set;}    
    // for home page to return there from some step - to display a message next to that step
    public Integer stepsaved {get; set;}
    // the name of the file to delete - for upload merge documents page
    public String filetodelete {get; set;}

 
    // CONSTRUCTOR, HANDLES AUTHENTICATION AND ICE SUBSCRIPTION RECORD RETRIEVAL
    public NI_ICEController() 
    {
        // INITIALIZE VARIABLES
        iDaysGrace = 10;
        authenticated = false;
        authkey = null;
        uploadeddocs = new String[0];
        usersselectionlocked = false;
        fileuploadlocked = false;
        agreementnotread = false;
        stepsaved = 0;
        
        // GET AUTH KEY FROM REQUEST PARAMETERS
        if (ApexPages.currentPage().getParameters().containsKey('authkey')) 
        {
            if (Test.isRunningTest())
            {
                authkey = ApexPages.currentPage().getParameters().get('authkey');
            }
            else
            {
                authkey = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('authkey').replace(' ', '+'), 'UTF-8');
            }
        }
       
        if (ApexPages.currentPage().getParameters().containsKey('stepsaved')) 
        {
            stepsaved = Integer.valueOf(ApexPages.currentPage().getParameters().get('stepsaved'));
        }

        // IF NO AUTHKEY FOUND IN URL THEN EXIT
        if (authkey == null)
        {
            return;
        }
        
        uploadeddocname = ApexPages.currentPage().getParameters().get('authkey');
          
        List<ICESubscription__c> lstICE = new List<ICESubscription__c>([
            SELECT Id, AcceptOnlineTermsCompleted__c, AgreementAcceptedIP__c, Contact__c, ContactCityStateZip__c, ContactEmail__c, 
            ContactName__c, ContactStreetAddress__c, ContactTitle__c, ContactVenue__c, DelphiNetIsActive__c, IAcknowledgeandHavetheAuthority__c, 
            ICE_Link__c, MigrationPortalKey__c, PropertySettingsCompleted__c, ReviewPropertiesAndUsersCompleted__c, ScheduledMigrationDate__c, 
            Status__c, StatusReason__c, SubscriptionID__c, SubscriptionName__c, UploadMergeDocumentsCompleted__c, UserSettingsCompleted__c, ContactFirstName__c       
            FROM ICESubscription__c
            WHERE MigrationPortalKey__c = : authkey LIMIT 1
        ]);         

        if (lstICE.Size() == 1)
        {

            if (lstICE[0].Contact__c == null)
            {
                return;
            } 

            loggedincontact = [SELECT Id, Name, Email, Account.Name, Title, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id = : lstICE[0].Contact__c LIMIT 1];
            migrationdate = lstICE[0].ScheduledMigrationDate__c;
            iceSub = lstICE[0];
            authenticated = true;
                    
            // IF ScheduledMigrationDate__c IS NULL THEN LOCK DOWN THE FORM 
            if (migrationdate == null)
            {
                usersselectionlocked = true;
                fileuploadlocked = true;
            }
            else
            {  
                if (migrationdate.addDays(-iDaysGrace) <= Date.today())
                {
                    usersselectionlocked = true;
                    fileuploadlocked = true;
                }
                else
                {
                    usersselectionlocked = false;
                    fileuploadlocked = false;
                }
            }

        }

    }

    // redirect to the home page
    public PageReference backtohome() 
    {
        PageReference pg = new PageReference('http://newmarketinc.force.com/migrationportal/NI_ICE_Home?authkey=' + authkey);
        pg.setRedirect(true);
        return pg;
    }

// ===================================================================    
// NIMigrationPortalReviewPropertiesUsers PAGE FUNCTIONS (STEP 1)
// ===================================================================    
    
    // LIST OF PROPERTIES RELATED TO VISITOR'S CONTACT RECORD
    public List<ICEProperty__c> getICEProperties()  
    {   
    
        List<ICEProperty__c> lstMP = new List<ICEProperty__c>(); 

        for (ICEProperty__c mp : [SELECT Id, PropertyName__c, StreetAddress__c, DelphiNetIsActive__c, City__c, Zip__c, State__c, SelectedForMigration__c, TimeZone__c
                                  FROM ICEProperty__c
                                  WHERE ICESubscriptionId__c = : iceSub.Id 
                                  AND HideOnICEForms__c = false 
                                  ORDER BY SelectedForMigration__c DESC, Name ASC]) 
        {
            lstMP.add(mp); 
           
        }
        
        lstMigrationProperty = lstMP;
                
        return lstMP; 
        
    }   
    
    
    // DISTINCT LIST OF USERS RELATED TO VISITOR'S CONTACT RECORD
    public List<ICEUser__c> getICEUsers()  
    {   
    
        List<ICEUser__c> lstMEU = new List<ICEUser__c>(); 
        Boolean bFound = false;

        for (ICEUser__c meu : [SELECT Id, DelphiNetIsActive__c, Email__c, LoginName__c, UserName__c, SelectedForMigration__c  
                               FROM ICEUser__c 
                               WHERE ICESubscriptionId__c = : iceSub.Id 
                               AND HideOnICEForms__c = false 
                               ORDER BY SelectedForMigration__c DESC, UserName__c ASC]) 
        {
        
            bFound = false;
            // DUPE FINDER
            for (ICEUser__c usr : lstMEU) 
            {
                if (meu.Email__c == usr.Email__c)
                {
                    bFound = true;
                }
            }
            // ADD NON-DUPES TO DISTINCT USER LIST
            if (!bFound)
            {
                lstMEU.add(meu); 
            }
            
        }
        
        lstMigrationEndUser = lstMEU; 
        
        return lstMEU; 
        
    }
    
    // SAVE BUTTON 
    public void submitReviewPropertiesUsers() 
    {

        if (lstMigrationProperty.Size() > 0)
        {
            Database.Update(lstMigrationProperty);
        }
        if (lstMigrationEndUser.Size() > 0)
        {
            Database.Update(lstMigrationEndUser);
        }
        
        String ip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
//        update new ICESubscription__c(Id = iceSub.Id, PropertiesUsersReviewedIP__c = ip);        
        
    }    
    
    // MARK REVIEW PROPERTIES AND USERS STEP COMPLETE AND RETURN TO THE HOME PAGE
    public PageReference completeReviewPropertiesUsers() 
    {
        if (!iceSub.ReviewPropertiesAndUsersCompleted__c)
        {
            update new ICESubscription__c(Id = iceSub.Id, ReviewPropertiesAndUsersCompleted__c = true);
        }
        submitReviewPropertiesUsers();        
        PageReference pg = new PageReference('http://newmarketinc.force.com/migrationportal/NI_ICE_Home?authkey=' + authkey + '&stepsaved=1');
        pg.setRedirect(true);
        return pg;
    }   
  
        

// ===================================================================    
// NIMigrationPortalPropertySettings PAGE FUNCTIONS (STEP 2)   
// ===================================================================    

    public List<ICEProperty__c> getSelectedProperties()  
    {   
    
        List<ICEProperty__c> lstMP = new List<ICEProperty__c>(); 

        for (ICEProperty__c mp : [SELECT Id, PropertyName__c, StreetAddress__c, DelphiNetIsActive__c, City__c, Zip__c, State__c, SelectedForMigration__c, TimeZone__c, EventOnly__c 
                                        FROM ICEProperty__c
                                        WHERE ICESubscriptionId__c = : iceSub.Id 
                                        AND SelectedForMigration__c = true 
                                        ORDER BY SelectedForMigration__c DESC, Name ASC]) 
        {
            lstMP.add(mp);            
        }
        
        lstMigrationProperty = lstMP;
//System.Debug('iceSub.Id = ' + iceSub.Id + ',    lstMigrationProperty.size() = ' + lstMigrationProperty.size());      
        return lstMP; 
        
    }   

    // SAVE BUTTON
    public void submitPropertySettings() 
    {

        if (lstMigrationProperty.Size() > 0)
        {
            Database.Update(lstMigrationProperty);
        }

        String ip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
//        update new ICESubscription__c(Id = iceSub.Id, PropertiesUsersReviewedIP__c = ip);        
        
    }    
    
    // MARK REVIEW PROPERTIES AND USERS STEP COMPLETE AND RETURN TO THE HOME PAGE
    public PageReference completePropertySettings() 
    {
        if (!iceSub.PropertySettingsCompleted__c)
        {
            update new ICESubscription__c(Id = iceSub.Id, PropertySettingsCompleted__c = true);
        }
        submitPropertySettings();        
        PageReference pg = new PageReference('http://newmarketinc.force.com/migrationportal/NI_ICE_Home?authkey=' + authkey + '&stepsaved=2');
        pg.setRedirect(true);
        return pg;
    }   


// ===================================================================    
// NIMigrationPortalUserSettings PAGE FUNCTIONS (STEP 3)   
// ===================================================================    

    public List<ICEUser__c> getSelectedUsers()  
    {   
    
        List<ICEUser__c> lstMEU = new List<ICEUser__c>(); 
        Boolean bFound = false;

        for (ICEUser__c meu : [SELECT Id, DelphiNetIsActive__c, Email__c, LoginName__c, UserName__c, SelectedForMigration__c, isCorporateAdmin__c, isPropertyAdmin__c, TimeZone__c  
                                FROM ICEUser__c 
                                WHERE ICESubscriptionId__c = : iceSub.Id 
                                AND SelectedForMigration__c = true 
                                ORDER BY SelectedForMigration__c DESC, UserName__c ASC]) 
        {
        
            bFound = false;
            // DUPE FINDER
            for (ICEUser__c usr : lstMEU) 
            {
                if (meu.Email__c == usr.Email__c)
                {
                    bFound = true;
                }
            }
            // ADD NON-DUPES TO DISTINCT USER LIST
            if (!bFound)
            {
                lstMEU.add(meu); 
            }
            
        }
        
        lstMigrationEndUser = lstMEU; 
        
        return lstMEU;         

    }   
    
    // SAVE BUTTON
    public void submitUsersSettings() 
    {

        if (lstMigrationEndUser.Size() > 0)
        {
            Database.Update(lstMigrationEndUser);
        }

        String ip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
//        update new ICESubscription__c(Id = iceSub.Id, PropertiesUsersReviewedIP__c = ip);        
        
    }    
    
    // MARK REVIEW PROPERTIES AND USERS STEP COMPLETE AND RETURN TO THE HOME PAGE
    public PageReference completeUsersSettings() 
    {
        if (!iceSub.UserSettingsCompleted__c)
        {
            update new ICESubscription__c(Id = iceSub.Id, UserSettingsCompleted__c = true);
        }
        submitUsersSettings();        
        PageReference pg = new PageReference('http://newmarketinc.force.com/migrationportal/NI_ICE_Home?authkey=' + authkey + '&stepsaved=3');
        pg.setRedirect(true);
        return pg;
    }   





// ===================================================================    
// NIMigrationPortal PAGE FUNCTIONS (STEP 4)   
// ===================================================================      
    // prepare the data for Accept On-line Terms step
    public void prepareacceptterms() 
    {
        if (iceSub.ContactCityStateZip__c == null)
        {
            iceSub.ContactCityStateZip__c = loggedincontact.MailingCity + ', ' + loggedincontact.MailingState + '. ' + loggedincontact.MailingPostalCode;
        }
        
        if (iceSub.ContactEmail__c == null)
        {
            iceSub.ContactEmail__c = loggedincontact.Email;
        }
        
        if (iceSub.ContactName__c == null)
        {
            iceSub.ContactName__c = loggedincontact.Name;
        }
        
        if (iceSub.ContactStreetAddress__c == null)
        {
            iceSub.ContactStreetAddress__c = loggedincontact.MailingStreet;
        }
        
        if (iceSub.ContactTitle__c == null)
        {
            iceSub.ContactTitle__c = loggedincontact.Title;
        }
        
        if (iceSub.ContactVenue__c == null)
        {
            iceSub.ContactVenue__c = loggedincontact.Account.Name;
        }
                
        agreementread = false;
        
//        if (iceSub.AuthorizationContact__c != null)
//        {
//            usecontactdata = true;
//        }
//        else
//        {
//            usecontactdata = false;
//        }

    }
    
    public PageReference acceptTerms() 
    {
    
        PageReference pg = null; 

        // VISITOR DETAILS =========================================================
//        iceSub.AuthorizationContact__c = loggedincontact.Id; 
//        iceSub.AgreementAcceptedBy__c = loggedincontact.Id; 
        iceSub.AcceptOnlineTermsCompleted__c = true; 
        iceSub.IAcknowledgeandHavetheAuthority__c = true; 

        String ip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP'); 
        iceSub.AgreementAcceptedIP__c = ip; 
        
        update iceSub; 
        
        pg = new PageReference('http://newmarketinc.force.com/migrationportal/NI_ICE_Home?authkey=' + authkey + '&stepsaved=4');         
        pg.setRedirect(true);
        return pg;
        
    }


// ===================================================================    
// NIMigrationPortal PAGE FUNCTIONS (STEP 5)   
// ===================================================================  

    public string strProp {get; set;} 
    public string strType {get; set;}    
    
    public List<SelectOption> getItems() 
    {
        
        List<SelectOption> options = new List<SelectOption>();

        for (ICEProperty__c mp : [SELECT Id, PropertyName__c 
                                    FROM ICEProperty__c
                                    WHERE ICESubscriptionId__c = : iceSub.Id 
                                    AND SelectedForMigration__c = true 
                                    ORDER BY Name ASC]) 
        {            
            options.add(new SelectOption(mp.PropertyName__c, mp.PropertyName__c));           
        }
        
        return options;
        
    }
    
    public List<SelectOption> getTypes() 
    {
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('ACCT', 'Account')); 
        options.add(new SelectOption('CNCT', 'Contact')); 
        options.add(new SelectOption('BOOK', 'Booking')); 
        options.add(new SelectOption('NRATE', 'Negotiated Rate'));
        options.add(new SelectOption('BEO', 'BEO'));
        options.add(new SelectOption('SAMP_BEO', 'Sample Merged BEO'));        
        options.add(new SelectOption('BQT', 'Banquet Check'));    
        options.add(new SelectOption('SAMP_BQT', 'Sample Merged Banquet Check'));

        return options;
        
    }    
        
    // prepares data for Upload Merge Documents page and handles file upload
    public void uploaddocs() 
    {
        if (authenticated) 
        {
            // save uploaded file, clear doc body and name variables
            if ((uploadeddocname != null) && (uploadeddocbody != null) && (uploadeddocbody.size() > 0))
            {
                
                string strFinalFileName = strProp + '_-_' + strType + '_-_' + uploadeddocname;

                Attachment doc = new Attachment();
                doc.OwnerId = UserInfo.getUserId();
                doc.IsPrivate = false;
                doc.ParentId = iceSub.Id;
//                doc.Name = uploadeddocname;
                doc.Name = strFinalFileName;
                doc.Body = uploadeddocbody;
                insert doc;
                uploadeddocbody = null;
                uploadeddocname = null;
            }
            
        }
        
        // fetch the names of files already uploaded
        uploadeddocs = new String[0];
        lstAttachments = new List<Attachment>();
        
        for (Attachment att : [SELECT Id, Name, Description FROM Attachment WHERE ParentId = : iceSub.Id ORDER BY Name]) 
        {
            uploadeddocs.add(att.Name);
            lstAttachments.add(att);
        }
        
        uploadeddocssize = uploadeddocs.size();
        
    }

/*
    // delete an uploaded document SMH NEW for prompt.
    public void deleteAttachment(string strAttachId) 
    {
        if (strAttachId != null) 
        {
            for (Attachment att : [SELECT Id FROM Attachment WHERE ParentId = : iceSub.Id AND Id = : strAttachId]) 
            {
                delete att;
            }
        }
        uploaddocs();
    }
*/

    public void deletedoc() 
    {
system.debug('========================= ' + filetodelete);    
        if (filetodelete != null) 
        {
            for (Attachment att : [SELECT Id FROM Attachment WHERE ParentId = : iceSub.Id AND Id = : filetodelete]) 
            delete att;
        }
        uploaddocs();
    }   

    // mark Upload Merge Documents... step complete and return to the home page
    public PageReference completeuploaddocsstep() 
    {
        
        uploaddocs();
        
        if (!iceSub.UploadMergeDocumentsCompleted__c)
        {
            update new ICESubscription__c(Id = iceSub.Id, UploadMergeDocumentsCompleted__c = true);
        }
        
        PageReference pg = new PageReference('http://newmarketinc.force.com/migrationportal/NI_ICE_Home?authkey=' + authkey + '&stepsaved=5');
        pg.setRedirect(true);
        return pg;
        
    }

}