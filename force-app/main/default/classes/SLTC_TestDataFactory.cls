/******************************************************************************************
******************************
Name 			: SLTC_TestDataFactory
Author 			: Jaswanth
Created Date 	: 8/5/22
Last Mod Date 	: 8/5/22
Last Mod By 	: Lamu Sreeharsha
NICC Reference 	: 
Description 	: Test data factory for Amadeus class
: 
*******************************************************************************************
*******************************/

@Istest
public class SLTC_TestDataFactory{
    
    //Creating account at Bulk
    public static List<Account> createAccounts(String Prefix,String accountName,String AccountStatusValue, String recordTypeName, String typevalue, Integer NumberofRecords) {
        List<Account> AccountList = New List<Account>();
        Id accountRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        for(Integer index=0; index < NumberofRecords; index++){
            Account acc = new Account();
            acc.Name = Prefix + '_'+ accountName;
            acc.Current_MPE_Cluster__c= NULL;
            acc.Cluster__c = NUll;
            acc.BillingCountry = 'Canada';
            acc.BillingState = 'Alberta';
            acc.BillingStreet = 'N12/237 street';
            acc.BillingCity = 'India';
            acc.BillingPostalCode = '22101';
            acc.recordTypeid = accountRecordTypeId;
            acc.Type = typevalue;
            acc.SLTC_Account_Validation_Status__c = AccountStatusValue;
            AccountList.add(acc);           
        }
        return AccountList;
    }
    
    //Creating contact at bulk
    public static List<Contact> createContact(String Name,String recordTypename,Id accountid,Integer totalcontact){
        Id ContactRecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordTypename).getRecordTypeId();
        List<Contact> contactRecordList = NEW List<Contact>();
        for(Integer index = 0; index < totalcontact; index++){
            Contact contactRecord = NEW Contact();
            contactRecord.FirstName = 'Test';
            contactRecord.LastName = Name;
            contactRecord.RecordTypeId = ContactRecordTypeId;
            contactRecord.MailingCountry = 'Canada';
            contactRecord.MailingState = 'Alberta';
            contactRecord.MailingStreet = 'N12/237 street';
            contactRecord.MailingCity = 'India';
            contactRecord.MailingPostalCode = '22101';
            contactRecord.AccountId = accountid;
            contactRecord.Phone = '45689000';
            contactRecord.Email =  'www.contactemail@gmail.com';
            contactRecordList.add(contactRecord);    
        }
        RETURN contactRecordList;
    }
    
    //Create lead at bulk
    public static List<Lead> createLead(Integer totalLead, String leadName, Id recordTypeId){
        String constData = leadName;
        List<Lead> leads = new List<Lead>();
        for(Integer index=0; index < totalLead; index++){
            Lead lead = new Lead();
            lead.salutation = 'Mr.';
            lead.FirstName = constData;
            lead.LastName = constData+'l';
            lead.company = leadName;
            lead.status = 'Open';
            lead.LeadSource = 'Web';
            lead.street = 'N12/237 street';
            lead.city = 'India';
            lead.state = 'Alberta';
            lead.phone='211205';
            lead.email = 'p@211205gmail.com';
            lead.sltc_Product_Interest_Area__c = 'Bundle';
            lead.PostalCode = '22101';
            lead.country = 'Canada';
            Lead.recordTypeId = recordTypeId;
            leads.add(lead);
        }
        return leads;
    }     
    
    //opportunity
    public static List<Opportunity> createOpportunity(String opportunityStages, String TypeValue, Account accountRecord , Integer NumberofRecords, String recordTypeName) {
        Id opportunityRecordTypeId = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        List<Opportunity> opportunities  = new list<Opportunity>();        
        for(Integer index=0; index < NumberofRecords; index++){
            Opportunity opp= new Opportunity();
            opp.Name='Test';
            opp.AccountId= accountRecord.Id;
            opp.Opportunity_Source__c='CEM';
            opp.Type=TypeValue;
            opp.Agreement_Term_Begin_Date__c= System.today();
            opp.Agreement_Term_End_Date__c= System.today().addYears(1);
            opp.CloseDate = System.today().addDays(30);
            opp.Sale_Type__c='Migration';
            opp.Type_Custom__c='Termination';
            opp.Win_Loss_Notes__c='Test';      
            opp.SLTC_Opportunity_Description__c='TEST123';
            opp.recordTypeId = opportunityRecordTypeId;  
            opp.stageName = opportunityStages;    
            Id pricebookId = Test.getStandardPricebookId();
            opp.Pricebook2Id = pricebookId;
            if(opportunityStages == 'Awaiting QA' || opportunityStages == 'Information Needed'){ 
                opp.Win_Loss_Reason__c = 'Price';
            }else if(opportunityStages =='Closed Lost'){
                opp.Win_Loss_Reason__c = 'Duplicate Opportunity Exists';
            }
            else if(opportunityStages == 'Closed Won'){ 
                opp.Win_Loss_Reason__c = 'Price';
            }
            opportunities.add(opp);
        }       
        return opportunities;
    }
    
    //User
    public static User createuser(String prefix ,String firstName, String lastName,String rolename) {
        Id ProfileId = [SELECT Id FROM Profile WHERE Name =: prefix LIMIT 1].Id;
        Id userrole = [SELECT Id FROM UserRole Where DeveloperName =: rolename].Id;
        User userRecord = new User();
        userRecord.Username = genearteUniqueString() + '@test' + UserInfo.getOrganizationId() + '.org';
        userRecord.FirstName = firstName+' ';
        userRecord.LastName =  lastName;
        userRecord.Alias = 'Sprojm';
        userRecord.Email = 'Abc@pwc.com';
        userRecord.TimeZoneSidKey = 'America/New_York';
        userRecord.LocaleSidKey = 'en_US';
        userRecord.EmailEncodingKey = 'ISO-8859-1';
        userRecord.ProfileId = ProfileId;
        userRecord.LanguageLocaleKey = 'en_US';
        userRecord.No_AD_Account_Standard_User__c= True;
        userRecord.UserRoleId=userrole;
        return userRecord;
    }
    
    //Genrate unique string
    private static String genearteUniqueString(){
        String orgId = UserInfo.getOrganizationId();  
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');   
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;
        return uniqueName;
    }
    
    //Assign the custom-permission 
    public static permissionSet createPermissionSet(String permissionName){
        PermissionSet ps = new PermissionSet();
        ps.Name = permissionName;
        ps.Label = permissionName;
        INSERT ps;
        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [select Id from CustomPermission where DeveloperName =: permissionName][0].Id;
        INSERT sea;
        return ps;
    }
    
    //get the permissionset
    public static permissionSet getpermissionset(String permissionName){
        PermissionSet ps = new PermissionSet();       
        ps = [select Id,Name from PermissionSet where Name=: permissionName];
        return ps;
    }
    
    //create OpportunityTeamMember
    public static List<OpportunityTeamMember> createOpportunityTeamMember(List<Opportunity> opportunityRecords, Id userId) { 
        List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();
        for(Opportunity oppId : opportunityRecords){
            OpportunityTeamMember oppTeam = new OpportunityTeamMember();
            oppTeam.UserId = userId;
            oppTeam.OpportunityAccessLevel = 'Edit';
            oppTeam.TeamMemberRole='Product Specialist';
            oppTeam.SLTC_Offerings__c='PMS';
            oppTeam.OpportunityId=oppId.Id;
            oppTeamList.Add(oppTeam);    
        }
        return oppTeamList;
    }
    
    //create Opportunitysplit
    public static List<OpportunitySplit> createOpportunitysplit(List<Opportunity> opportunityRecords, Id userId) { 
        Id FirstYearSaleOpportunitySplitTypeId = [ SELECT Id, MasterLabel FROM OpportunitySplitType WHERE MasterLabel = 'First Year Sale' ].Id;
        List<OpportunitySplit> opportunitysplitList = new List<OpportunitySplit>();
        for(Opportunity oppId : opportunityRecords){
            OpportunitySplit oppsplit = new OpportunitySplit();
            oppsplit.SplitOwnerId = userId;
            oppsplit.SplitPercentage=50;
            oppsplit.SplitTypeId=FirstYearSaleOpportunitySplitTypeId;
            oppsplit.OpportunityId=oppId.Id;
            opportunitysplitList.Add(oppsplit);    
        }
        return opportunitysplitList;
    }
    
    //AccountAffiliation
    public static List<SLTC_Account_Affiliation__c> createAccountAffiliation(Id AccountId,Id AccAffId,string affType,boolean Active,integer recordCount,Id BrandId){
        List<SLTC_Account_Affiliation__c> newAccAff= new List<SLTC_Account_Affiliation__c>();
        Integer var=0;
        SLTC_Account_Affiliation__c accAffSingle=new SLTC_Account_Affiliation__c();
        accAffSingle.SLTC_Account__c=AccountId;
        accAffSingle.SLTC_Account_Affliation__c=AccAffId;
        accAffSingle.SLTC_Affiliation_Type__c=affType;
          accAffSingle.SLTC_Active__c=Active;
        accAffSingle.SLTC_Brand__c=BrandId;
        accAffSingle.SLTC_Future_Date__c=date.today();
        for(var=0;var<recordCount;var++){
            newAccAff.add(accAffSingle);
        }
        return newAccAff;
    }
    //Brand
    public static SLTC_Brand__c createBrandOnAccount(Id AccountId,String Name) {
        SLTC_Brand__c newBrand=new SLTC_Brand__c();
        newBrand.Name=Name;
        newBrand.SLTC_Account__c=AccountId;
        return newBrand;
    }
    
    //OpportunityContactRole
    public static List<OpportunityContactRole> createOpportunityContactRole(Id oppId, Id contactId, String role){
        list<OpportunityContactRole> contactRoleList=new list<OpportunityContactRole>();
        OpportunityContactRole contactRoleSingle=new OpportunityContactRole();
        contactRoleSingle.OpportunityId=oppId;
        contactRoleSingle.ContactId=contactId;
        contactRoleSingle.Role=role;
        contactRoleSingle.IsPrimary=FALSE;
        contactRoleList.add(contactRoleSingle);
        return contactRoleList;
    }
    
    //Proposal
    public static Apttus_Proposal__Proposal__c createProposal(Id accountId, Id contactId, Id oppId, String recordtypeName){
        Id ProposalRecordTypeId = SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
        //Pricebook2 pb2 = [select Id from Pricebook2 WHERE ];
        Apttus_Proposal__Proposal__c proposalrecord = NEW Apttus_Proposal__Proposal__c();
        proposalrecord.recordTypeid = ProposalRecordTypeId;
        proposalrecord.Apttus_Proposal__Opportunity__c = oppId;
        proposalrecord.SLTC_Primary_Contact__c = contactId;
        proposalrecord.Apttus_Proposal__Proposal_Name__c = 'Test proposalrecord';
        proposalrecord.Apttus_Proposal__Account__c= accountId;
        proposalrecord.Apttus_Proposal__Approval_Stage__c = 'Draft';
        proposalrecord.Apttus_QPConfig__BillToAccountId__c = accountId;
        proposalrecord.Apttus_Proposal__Primary__c = True;
        proposalrecord.Apttus_Proposal__ReadyToGenerate__c = True;
        proposalrecord.Apttus_Proposal__ReadyToPresent__c = True;
        //proposalrecord.Apttus_QPConfig__PriceListId__c = 'aCc2f000000VFFJCA4';
        proposalrecord.Apttus_QPConfig__ABOType__c = 'New';
        proposalrecord.Apttus_QPConfig__SyncAssetChangesToQuote__c = true;
        proposalrecord.Apttus_Proposal__Proposal_Category__c = 'Quote';
        proposalrecord.Apttus_QPConfig__SourceChannel__c = 'Direct';
        proposalrecord.Apttus_QPConfig__UseType__c = 'Main';
        proposalrecord.Apttus_QPApprov__Approval_Status__c = 'Not Submitted';
        proposalrecord.SLTC_Auto_renewal__c = true;
        //proposalrecord.SLTC_Product_Configuration__c = 'aCn2f0000000IMpCAM';
        proposalrecord.SLTC_Hide_List_Price__c = true;
        proposalrecord.SLTC_Term_Length_Month__c=12;
        proposalrecord.Apttus_Proposal__ExpectedEndDate__c =System.today().addYears(1);
            proposalrecord.Apttus_Proposal__ExpectedStartDate__c =System.today();
        return proposalrecord;
    }
    
    public static List<Apttus_Proposal__Proposal_Line_Item__c> createProposalLineItem(Id proposalId, List<Product2> products, String lineItemStatus){
        List<Apttus_Proposal__Proposal_Line_Item__c> lineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for(Product2 prod : products){
            Apttus_Proposal__Proposal_Line_Item__c item = new Apttus_Proposal__Proposal_Line_Item__c();
            item.Apttus_Proposal__Proposal__c = proposalId;
            item.Apttus_Proposal__Product__c = prod.Id;
            item.Apttus_QPConfig__ChargeType__c = 'Subscription Fee';
            item.Apttus_QPConfig__LineStatus__c = lineItemStatus;
            item.Apttus_QPConfig__LineType__c = 'Product/Service';
            item.Apttus_QPConfig__Uom__c = 'Each';
            item.Apttus_QPConfig__FulfillmentStatus__c  = 'Not Fulfilled';
            item.Apttus_QPApprov__Approval_Status__c = 'Not Submitted';
            
            lineItem.add(item);
            
        }
        return lineItem;
    }
    
    //create Product at bulk
    public static List<Product2> createProduct(String prefix, Integer count){
        List<Product2> products = new List<Product2>();
        for(Integer index=0; index < count; index++){
            Product2 prod = new Product2();
            prod.Name = prefix+' Product';
            prod.Description= prefix+index+'Product Entry For Product';
            prod.productCode = prefix+index+'SFDCPanther-123';
            prod.isActive = true;
            products.add(prod);
        }
        return products;
    }
    
    //create agreement
    public static Apttus__APTS_Agreement__c createAgreement(Id AccountId, Id OpportunityId, Id ContactId, Id ProposalId, String recordTypeName){
        Id agreementRecordTypeId = SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get(recordTypename).getRecordTypeId();
        Apttus__APTS_Agreement__c agreement_record=new Apttus__APTS_Agreement__c();
        
        agreement_record.Apttus__Account__c = AccountId;
        agreement_record.Apttus__Related_Opportunity__c = OpportunityId;
        agreement_record.SLTC_Primary_Contact__c = ContactId;
        agreement_record.RecordTypeId = agreementRecordTypeId;
        agreement_record.Apttus_QPComply__RelatedProposalId__c = ProposalId;
        agreement_record.Name = 'Agreement Record';
        return agreement_record;
    }
    
    //Create Contract Request
    public static Request__c createContractRequest(Id OpportunityId){
        Id RequestRecordTypeId = [ SELECT Id FROM RecordType where SobjectType ='Request__c' AND DeveloperName ='Contract_Request' ].Id;
        Request__c Request_record = new Request__c();
        
        Request_record.Request_Type__c = 'DOS Assistance';
        Request_record.Comments__c = 'createContractRequest';
        Request_record.RecordTypeId = RequestRecordTypeId;
        Request_record.Related_Opportunity__c = OpportunityId;
        return Request_record;
    }
    
    //Create Termination Request from Proposal
    public static Request__c createTerminationRequest_AtProposal(Id OpportunityId,Id ProposalId){
        Id RequestRecordTypeId = SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('SLTC_Termination_Request').getRecordTypeId();
        Request__c Request_record = new Request__c();
        
        Request_record.SLTC_Effective_date__c = System.today().addDays(7);
        Request_record.SLTC_Termination_Lost_Category__c = 'Internal Use';
        Request_record.SLTC_Request_Origin__c = 'Proposal (CPQ)';
        Request_record.SLTC_Termination_Lost_Reason__c = 'User License Reduction';
        Request_record.Related_Opportunity__c = OpportunityId;
        Request_record.RecordTypeId = RequestRecordTypeId;
        Request_record.SLTC_Quote_Proposal__c = ProposalId;
        return Request_record;
    }
    
    //Create Termination Request from Agreement
    public static Request__c createTerminationRequest_AtAgreement(Id OpportunityId,Id ProposalId,Id AgreementId){
        Id RequestRecordTypeId = SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('SLTC_Termination_Request').getRecordTypeId();
        Request__c Request_record = new Request__c();
        
        Request_record.SLTC_Effective_date__c = System.today().addDays(7);
        Request_record.SLTC_Termination_Lost_Category__c = 'Internal Use';
        Request_record.SLTC_Termination_Lost_Reason__c = 'Duplicate Opportunity, Contract, Subscription';
        Request_record.SLTC_Request_Origin__c = 'Agreement (CLM)';
        Request_record.Related_Opportunity__c = OpportunityId;
        Request_record.RecordTypeId = RequestRecordTypeId;
        Request_record.SLTC_Related_Agreement__c = AgreementId;
        Request_record.SLTC_Quote_Proposal__c = ProposalId;
        return Request_record;
    }
    
    //Create Termination Request from Zuora Subscription
    public static Request__c createTerminationRequest_AtZuora(Id accountIdValue, Id zuoraSubscriptionIdvalue){
        Id RequestRecordTypeId = SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('SLTC_Termination_Request').getRecordTypeId();
        Request__c Request_record = new Request__c();
        
        Request_record.SLTC_Effective_date__c = System.today().addDays(7);
        Request_record.SLTC_Termination_Lost_Category__c = 'Internal Use';
        Request_record.SLTC_Termination_Lost_Reason__c = 'Duplicate Opportunity, Contract, Subscription';
        Request_record.SLTC_Request_Origin__c = 'Subscription (Zuora)';
        Request_record.RecordTypeId = RequestRecordTypeId;
        Request_record.SLTC_Subscription_Zuora__c = zuoraSubscriptionIdvalue;
        Request_record.Account__c = accountIdValue;
        return Request_record;
    }
    
    //Create zuora subscription 
    public static Zuora__Subscription__c createZuoraSubscription(Id accountIdvalue){
        //Id subscriptionRecordTypeId = SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('').getRecordTypeId();
        Zuora__Subscription__c subscription_record = new Zuora__Subscription__c();
        
        subscription_record.Zuora__Account__c = accountIdvalue;
       // Request_record.RecordTypeId = subscriptionRecordTypeId;
        return subscription_record;
    }
    
    //create DealDeskRequest
    public static Request__c createDealDeskRequest(Id OpportunityId){
        Id RequestRecordTypeId = SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('SLTC_Deal_Desk_Request').getRecordTypeId();
        Request__c Request_record = new Request__c();
        
        Request_record.Related_Opportunity__c = OpportunityId;
        Request_record.RecordTypeId = RequestRecordTypeId;
        return Request_record;
    }
    
    //Create AccountTeamMember
    public static AccountTeamMember createAccountTeamMember(Id AccountId,Id userId, String userRole){
        AccountTeamMember accountteam_memberdata = New AccountTeamMember();
        
        accountteam_memberdata.AccountId = AccountId;
        accountteam_memberdata.AccountAccessLevel = 'ALL';
        accountteam_memberdata.SLTC_Offerings__c = 'Business Intelligence';
        accountteam_memberdata.OpportunityAccessLevel = 'ALL';
        accountteam_memberdata.CaseAccessLevel = 'ALL';
        accountteam_memberdata.TeamMemberRole = userRole;
        accountteam_memberdata.UserId = userId;
        return accountteam_memberdata;     
    }
    
    //create PricebookEntry
    public static List<PricebookEntry> createPricebookEntry(List<Product2> productList){
        List<PricebookEntry> pricebookEntry = new List<PricebookEntry>();
        for(Product2 item : productList){
            PricebookEntry standardPrice = new PricebookEntry();
            standardPrice.Pricebook2Id = Test.getStandardPricebookId();
            standardPrice.Product2Id = item.Id;
            standardPrice.UnitPrice = 100;
            standardPrice.IsActive = true;
            standardPrice.UseStandardPrice = false;
            pricebookEntry.add(standardPrice);
        }
        return pricebookEntry;
    }
    
    //create ContentVersion
    public static ContentVersion createContentVersion(){
        ContentVersion testContVer = new ContentVersion();
        testContVer.Title = 'Test Document 1';
        testContVer.PathOnClient = 'Test.txt';
        testContVer.VersionData = Blob.valueOf('Test Content');   
        testContVer.IsMajorVersion = true;
        return testContVer;  
    }
    
    //create ContentDocumentLink
    public static ContentDocumentLink createContentDocumentLink(Id recordIdValue,Id contentVersionIdvalue){
        ContentDocumentLink testContDocLink = new ContentDocumentLink(); 
        testContDocLink.LinkedEntityId = recordIdValue;
        testContDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionIdvalue].ContentDocumentId;  
        return testContDocLink;  
    }
    
    //create Order
    public static Apttus_Config2__Order__c createApttusOrder(Id AccountIdvalue, Id OpportunityIdValue,Id contactIdvalue,Id ProposalIdValue,Id AgreementIdvalue){ 
        Apttus_Config2__Order__c Order_record = new Apttus_Config2__Order__c();
        Order_record.Apttus_Config2__Type__c = 'New';
        Order_record.Apttus_Config2__Status__c = 'Pending';//Activated
        Order_record.Apttus_Config2__SoldToAccountId__c = AccountIdvalue;
        Order_record.Apttus_Config2__BillToAccountId__c = AccountIdvalue;
        Order_record.Apttus_Config2__ShipToAccountId__c = AccountIdvalue;
        Order_record.Apttus_Config2__PrimaryContactId__c = contactIdvalue;
        Order_record.Apttus_Config2__RelatedOpportunityId__c = OpportunityIdValue;
        Order_record.Apttus_CMConfig__AgreementId__c = AgreementIdvalue;
        return Order_record;
    }
    
    
    public static List<Apttus_Config2__AssetLineItem__c> createAssetLineItemwithproducts(Id accountIdvalue, List<Product2> products){
        List<Apttus_Config2__AssetLineItem__c> lineItem = new List<Apttus_Config2__AssetLineItem__c>();
        for(Product2 prod : products){
            Apttus_Config2__AssetLineItem__c item = new Apttus_Config2__AssetLineItem__c();
            item.Apttus_Config2__AccountId__c = accountIdvalue ;
            item.Apttus_Config2__ProductId__c = prod.Id;         
            lineItem.add(item);   
        }
        return lineItem;
    }
    
    //create Tax certificate
    public static Apttus_Config2__TaxCertificate__c createTaxcertificate(String JurisdictionValue){
        Apttus_Config2__TaxCertificate__c tax_record = New Apttus_Config2__TaxCertificate__c();
        tax_record.SLTC_Tax_Exempt_Issuing_Jurisdiction__c = JurisdictionValue;
        tax_record.Apttus_Config2__Description__c = 'Review TaxCertificate';
        return tax_record;     
    }
}