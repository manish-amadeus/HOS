public class MigrationPortalController {
    // true if authkey URL parameter is correct
    public Boolean authenticated {get;set;}
    // Migration Customer to be used
    public MigrationCustomer__c migrationcustomer {get;set;}
    // the contact found by authkey URL parameter
    public Contact loggedincontact {get;set;}
    // the value of authkey parameter
    public String authkey {get;set;}
    // the upgrade date
    public Date migrationdate {get;set;}
    // the list of files already uploaded - for merge documents upload page
    public String[] uploadeddocs {get;set;}
    // the number of files already uploaded - for merge documents upload page
    public Integer uploadeddocssize {get;set;}
    // for file upload form - file contents - for merge documents upload page
    public Blob uploadeddocbody {get;set;}
    // for file upload form - file name - for merge documents upload page
    public String uploadeddocname {get;set;}
    // list of active properties (with users lists on each of them)
    //  - for Review Properties and Users page
    public PropertyListItem[] propertylist {get;set;}
    // list of inactive properties - for Review Properties and Users page
    public PropertyListItem[] inactivepropertylist {get;set;}
    // list of inactive users - for Review Properties and Users page
    public UserListItem[] inactiveuserlist {get;set;}
    // "I have read and acknowledge..." checkbox state - for Accept On-line Terms
    public Boolean agreementread {get;set;}
    // to display the message "check I have read... checkbox"
    // - for Accept On-line Terms
    public Boolean agreementnotread {get;set;}
    // use logged in contact as authorization contact
    // - for Accept On-line Terms
    public Boolean usecontactdata {get;set;}
    // true if users and properties selection should be locked
    // - for Review Properties and Users page
    public Boolean usersselectionlocked {get;set;}
    // true if merge documents upload should be locked
    // - for Upload Merge Documents Templates and Logos page
    public Boolean fileuploadlocked {get;set;}
    // holds info on a page to be displayed
    // - for MigrationPortalPage
    public MigrationPortalPage__c page {get;set;}
    
    // for home page to return there from some step - to display
    //  a message next to that step
    public Integer stepsaved {get;set;}
    // the name of the file to delete - for upload merge documents page
    public String filetodelete {get;set;}
    
    // DTO to display Migration Properties on Review Properties and Users page
    public class PropertyListItem {
        
        public MigrationProperty__c property{get;set;}
        public Boolean selected {get;set;}
        public UserListItem[] userlist {get;set;}
        public PropertyListItem(MigrationProperty__c prop) {
            this.property=prop;
            this.selected=false;
            this.userlist = new UserListItem[0];
        }
    }
    
    // DTO to display Migration End Users on Review Properties and Users page
    public class UserListItem {
        public Boolean selected {get;set;}
        public MigrationEndUser__c user {get;set;}
        public UserListItem(MigrationEndUser__c u) {
            this.user=u;
            this.selected=false;
        }
    }
    
    // constructor, handles authentication and MigrationCustomer record retrieval
    public MigrationPortalController() {
        // initialize variables
        authenticated=false;
        authkey=null;
        uploadeddocs = new String[0];
        usersselectionlocked=false;
        fileuploadlocked=false;
        agreementnotread=false;
        stepsaved=0;
        
        // get auth key from request parameters
        if (ApexPages.currentPage().getParameters().containsKey('authkey')) 
            authkey=EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('authkey').replace(' ','+'),'UTF-8');
        if (ApexPages.currentPage().getParameters().containsKey('stepsaved')) 
            stepsaved=Integer.valueOf(ApexPages.currentPage().getParameters().get('stepsaved'));
        uploadeddocname=ApexPages.currentPage().getParameters().get('authkey');
        // find the Contact record for this auth key
        // and then retrieve MigrationCustomer record 
        // for this Contact's Account
        // if successful it means successful authentication
        if (authkey!=null) {
            Id accountid = null;
            for (Contact c:[SELECT Id 
                    , Name
                    , Title
                    , Email
                    , MailingCity
                    , MailingStreet
                    , MailingState
                    , MailingPostalCode
                    , Account.Name
                    , AccountId
                    , Account.Delphi_Net_Upgrade_Date__c 
                    FROM Contact 
                    WHERE MigrationPortalKey__c=:authkey
            ]) {
                accountid = c.AccountId;
                loggedincontact = c;
                migrationdate = c.Account.Delphi_Net_Upgrade_Date__c;
                if (migrationdate!=null&&migrationdate.addDays(-5)<=date.today()) {
                    usersselectionlocked=true;
                    fileuploadlocked=true;
                }
                
            }
            if (accountid!=null) {
                for (MigrationCustomer__c mc:[SELECT
                    Id
                    , AcceptOnlineTermsCompleted__c
                    , AgreementEmailSent__c
                    , AgreementTextAccepted__c
                    , AuthorizationContact__c
                    , ContactCityStateZip__c
                    , ContactEmail__c
                    , ContactName__c
                    , ContactStreetAddress__c
                    , ContactTitle__c
                    , ContactVenue__c
                    , CustomerParentAccount__c
                    , PropertiesUsersReviewedIP__c
                    , ReviewPropertiesAndUsersCompleted__c
                    , ScheduleOnlineTrainingCompleted__c
                    , UnlockUsersSelection__c
                    , UnlockFileUpload__c
                    , UploadMergeDocumentsCompleted__c
                    FROM MigrationCustomer__c
                    WHERE CustomerParentAccount__c=:accountid
                ]) {
                    migrationcustomer = mc;
                    authenticated = true;
                    // check if file upload or properties/users selection is locked
                    if (migrationcustomer.UnlockFileUpload__c)
                        fileuploadlocked=false;
                    if (migrationcustomer.UnlockUsersSelection__c)
                        usersselectionlocked=false;
                }
            }
        }
    }
    // prepares data for Upload Merge Documents page and handles file upload
    public void uploaddocs() {
        if (authenticated) {
            // save uploaded file, clear doc body and name variables
            if (uploadeddocname!=null&&uploadeddocbody!=null&&uploadeddocbody.size()>0) {
                for (Attachment att:[SELECT Id FROM Attachment WHERE ParentId=:migrationcustomer.Id AND name=:uploadeddocname]) 
                    delete att;
                Attachment doc = new Attachment();
                doc.OwnerId = UserInfo.getUserId();
                doc.IsPrivate = false;
                doc.ParentId = migrationcustomer.Id;
                doc.Name=uploadeddocname;
                doc.Body=uploadeddocbody;
                insert doc;
                uploadeddocbody=null;
                uploadeddocname=null;
            }
            
        }
        // fetch the names of files already uploaded
        uploadeddocs=new String[0];
        for (Attachment att:[SELECT Name FROM Attachment WHERE ParentId=:migrationcustomer.Id]) {
            uploadeddocs.add(att.Name);
        }
        uploadeddocssize = uploadeddocs.size();
        
    }
    // delete an uploaded document
    public void deletedoc() {
        if (filetodelete!=null) {
            for (Attachment att:[SELECT Id FROM Attachment WHERE ParentId=:migrationcustomer.Id AND name=:filetodelete]) 
                delete att;
        }
        uploaddocs();
    }
    // mark Upload Merge Documents... step complete and return to the home page
    public PageReference completeuploaddocsstep() {
        
        uploaddocs();
        
        if (!migrationcustomer.UploadMergeDocumentsCompleted__c)
            update new MigrationCustomer__c(Id=migrationcustomer.Id, UploadMergeDocumentsCompleted__c=true);
        PageReference pg = new PageReference('/migrationportal/MigrationPortalHome?authkey='+authkey);
        return pg;
    }
    // prepare data for Review Properties and Users page
    public void reviewusers() {
        propertylist = new PropertyListItem[0];
        inactivepropertylist = new PropertyListItem[0];
        inactiveuserlist = new UserListItem[0];
        // retrieve Migration Properties
        Map<Id, PropertyListItem> propertyidtoitem = new Map<Id, PropertyListItem>();
        for (MigrationProperty__c mp: [SELECT 
            Id
            , Name
            , StreetAddress__c
            , Active__c
            , City__c
            , Zip__c
            , State__c
            , SelectedForMigration__c
            FROM MigrationProperty__c
            WHERE MigrationCustomer__c = :migrationcustomer.Id
        ]) {
            PropertyListItem pli = new PropertyListItem(mp);
            if (mp.SelectedForMigration__c) pli.selected=true;
            propertyidtoitem.put(mp.Id, pli);
        }
        // retrieve Migration End Users, put them to the lists
        for (MigrationEndUser__c meu:[SELECT
            Id
            , Active__c
            , Email__c
            , LoginName__c
            , Name__c
            , MigrationProperty__c
            , MigrationProperty__r.Name
            , SelectedForMigration__c
            , TrainingModulesTaken__c
            , Role__c
            FROM MigrationEndUser__c
            WHERE MigrationCustomer__c = :migrationcustomer.Id
        ]) {
            UserListItem uli = new UserListItem(meu);
            if (meu.SelectedForMigration__c==true)
                uli.selected = true;
                
            if (meu.Active__c) {
                if (meu.MigrationProperty__c!=null) {
                    
                    propertyidtoitem.get(meu.MigrationProperty__c).userlist.add(uli);
                    
                }
            } else {
                inactiveuserlist.add(uli);
            }
        }
        // populate properties lists to be displayed on the page
        for (Id propertyid:propertyidtoitem.keySet()) {
            PropertyListItem pli = propertyidtoitem.get(propertyid);
            if (pli.property.Active__c)
                propertylist.add(pli);
            else 
                inactivepropertylist.add(pli);
        }
        
    }
    // save properties and users selection from Review Properties and Users
    // and then return to the home page
    public PageReference selectusers() {
        Map<Id, Boolean> selectedusers = new Map<Id, Boolean>();
        MigrationProperty__c[] mpstoupdate = new MigrationProperty__c[0];
        for (PropertyListItem pli:propertylist) {
            for (UserListItem uli:pli.userlist)
                selectedusers.put(uli.user.Id, uli.selected);
            mpstoupdate.add(new MigrationProperty__c(Id=pli.property.Id, SelectedForMigration__c=pli.selected));
        }
        for (PropertyListItem pli:inactivepropertylist) {
            mpstoupdate.add(new MigrationProperty__c(Id=pli.property.Id, SelectedForMigration__c=pli.selected));
        }
        for (UserListItem uli:inactiveuserlist)
            selectedusers.put(uli.user.Id, uli.selected);
        MigrationEndUser__c[] meustoupdate = new MigrationEndUser__c[0];
        for (Id userid:selectedusers.keySet())
            meustoupdate.add(new MigrationEndUser__c(Id=userid, SelectedForMigration__c=selectedusers.get(userid)));
        update mpstoupdate;
        update meustoupdate;
        
        String ip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        update new MigrationCustomer__c(Id=migrationcustomer.Id, PropertiesUsersReviewedIP__c=ip);
        
        reviewusers();
        PageReference pg = new PageReference('/migrationportal/MigrationPortalHome?authkey='+authkey+'&stepsaved=1');
        return pg;
    }
    // mark Review Properties and Users step complete
    // and return to the home page
    public PageReference completeselectusersstep() {
        if (!migrationcustomer.ReviewPropertiesAndUsersCompleted__c)
            update new MigrationCustomer__c(Id=migrationcustomer.Id, ReviewPropertiesAndUsersCompleted__c=true);
        selectusers();
        
        PageReference pg = new PageReference('/migrationportal/MigrationPortalHome?authkey='+authkey+'&stepsaved=1');
        return pg;
    }
    // prepare the data for Accept On-line Terms step
    public void prepareacceptterms() {
        if (migrationcustomer.ContactCityStateZip__c==null)
            migrationcustomer.ContactCityStateZip__c = loggedincontact.MailingCity+' '+loggedincontact.MailingState+' '+loggedincontact.MailingPostalCode;
        if (migrationcustomer.ContactEmail__c==null)
            migrationcustomer.ContactEmail__c=loggedincontact.Email;
        if (migrationcustomer.ContactName__c==null)
            migrationcustomer.ContactName__c=loggedincontact.Name;
        if (migrationcustomer.ContactStreetAddress__c==null)
            migrationcustomer.ContactStreetAddress__c=loggedincontact.MailingStreet;
        if (migrationcustomer.ContactTitle__c==null)
            migrationcustomer.ContactTitle__c=loggedincontact.Title;
        if (migrationcustomer.ContactVenue__c==null)
            migrationcustomer.ContactVenue__c=loggedincontact.Account.Name;
        agreementread = false;
        if (migrationcustomer.AuthorizationContact__c!=null)
            usecontactdata=true;
        else
            usecontactdata=false;
    }
    // handle I Submit button click on 
    // Accept On-line Terms page
    public PageReference acceptterms() {
        PageReference actionpg=null;
        if (!agreementread)
            agreementnotread=true;
        else {
            if (usecontactdata) {
                migrationcustomer.AuthorizationContact__c=loggedincontact.Id;
                migrationcustomer.ContactCityStateZip__c = loggedincontact.MailingCity+' '+loggedincontact.MailingState+' '+loggedincontact.MailingPostalCode;
                migrationcustomer.ContactEmail__c=loggedincontact.Email;
                migrationcustomer.ContactName__c=loggedincontact.Name;
                migrationcustomer.ContactStreetAddress__c=loggedincontact.MailingStreet;
                migrationcustomer.ContactTitle__c=loggedincontact.Title;
                migrationcustomer.ContactVenue__c=loggedincontact.Account.Name;
            }
            MigrationPortalPage__c agreementpage=null;
            for (MigrationPortalPage__c pg:[SELECT Name, HTML__c FROM MigrationPortalPage__c WHERE RelativeURL__c='UpgradeTerms' LIMIT 1])
                agreementpage=pg;
            if (agreementpage!=null)
                migrationcustomer.AgreementTextAccepted__c = '<h1>'+agreementpage.Name+'</h1>'+agreementpage.HTML__c;
            migrationcustomer.AcceptOnlineTermsCompleted__c=true;
            migrationcustomer.IAcknowledgeAndHaveTheAuthorityCheckbox__c=agreementread;
            migrationcustomer.AgreementAcceptedBy__c=loggedincontact.Id;
            String ip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            migrationcustomer.AgreementAcceptedIP__c=ip;
            update migrationcustomer;
            actionpg = new PageReference('/migrationportal/MigrationPortalHome?authkey='+authkey+'&stepsaved=2');
            
        }
        return actionpg;
    }
    // redirect to the home page
    public PageReference backtohome() {
        PageReference pg = new PageReference('/migrationportal/MigrationPortalHome?authkey='+authkey);
        pg.setRedirect(true);
        return pg;
    }
    // fetch a Migration Portal Page record by its Relative URL
    // to display it at [portal root URL]/page/[Relative URL]
    public void showpage() {
        if (ApexPages.currentPage().getParameters().containsKey('pageid')) {
            String pageid = ApexPages.currentPage().getParameters().get('pageid');
            for (MigrationPortalPage__c pg:[SELECT Name, HTML__c FROM MigrationPortalPage__c WHERE RelativeURL__c=:pageid LIMIT 1])
                page = pg;
        }
    }
    // test all the methods
    public static testMethod void testThis() {
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        Account parentacc = new Account(Name='Test Parent'
            , Industry='Hospitality Companies'
            , BillingState='CA'
            , BillingStreet='1 Test Street'
            , BillingCountry='US'
            , BillingCity='San Francisco'
            , BillingPostalCode='11111'
            , Delphi_Net_subscription_id__c='test'
            , Delphi_Net_Upgrade_Date__c = Date.today().addDays(6)
        );
        Account propertyacc = new Account(Name='Test Property'
            , Industry='Hospitality Companies'
            , BillingState='CA'
            , BillingStreet='2 Test Street'
            , BillingCountry='US'
            , BillingCity='San Francisco'
            , BillingPostalCode='22222'
            , Delphi_Net_location_id__c='test1'
        );
        insert new Account[]{parentacc, propertyacc};
        Contact portalusercontact = new Contact(
            FirstName='Test'
            , LastName='Test'
            , AccountId=parentacc.Id
            , MailingStreet='1 Test St.'
            , MailingCountry='US'
            , MailingState='CA'
            , MailingCity='San Francisco'
            , MailingPostalCode='33333'
            
        );
        insert portalusercontact;
        MigrationProperty__c mp = new MigrationProperty__c (
            Name='test1'
            , DelphiNetStatus__c='Active'
            , DelphiNetID__c='test1'
            , DelphiNetSubscriptionID__c='test'
        );
        insert mp;
        MigrationEndUser__c meu1=new MigrationEndUser__c(
            UserId__c='test1'
            , PropertyId__c='test1'
            , SubscriptionId__c='test'
            , Name__c='Test Test'
            , Email__c='test@example.com'
            , LoginName__c='test@example.com'
            , Role__c='User'
            , DelphiNetStatus__c='Active'
        );
        insert meu1;
        MigrationEndUser__c meu2=new MigrationEndUser__c(
            UserId__c='test2'
            , PropertyId__c='test1'
            , SubscriptionId__c='test'
            , Name__c='Test2 Test2'
            , Email__c='test2@example.com'
            , LoginName__c='test2@example.com'
            , Role__c='User'
            , DelphiNetStatus__c='Inactive'
        );
        insert meu2;
        MigrationPortalPage__c pg=new MigrationPortalPage__c(Name='Test', HTML__c='Test', RelativeURL__c='Test');
        insert pg;
        portalusercontact = [SELECT MigrationPortalKey__c FROM Contact WHERE Id=:portalusercontact.Id];
        PageReference pageRef = Page.MigrationPortalHome;
        pageRef.getParameters().put('authkey', EncodingUtil.urlDecode(portalusercontact.MigrationPortalKey__c,'UTF-8'));
        pageRef.getParameters().put('pageid','Test');
        Test.setCurrentPage(pageRef);
        MigrationPortalController controller = new MigrationPortalController();
        controller.uploadeddocbody=Blob.valueOf('test');
        controller.uploadeddocname='test';
        controller.uploaddocs();
        controller.completeuploaddocsstep();
        controller.reviewusers();
        controller.propertylist[0].selected=true;
        controller.propertylist[0].userlist[0].selected=true;
        controller.selectusers();
        controller.prepareacceptterms();
        controller.completeselectusersstep();
        controller.agreementread=true;
        controller.acceptterms();
        controller.backtohome();
        controller.showpage();
    }
}