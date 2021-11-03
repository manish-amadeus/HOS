/****************************************************************************************
Name            : AH_Rally_CreateUserStory (TC Org Name: CreateUserStoryInRally)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Used to create defect in rally with the salesforce field values
				: 
				: 
******************************************************************************************/
global class AH_Rally_CreateUserStory 
{
    
    // Fields of Notes
    public static string AffectedComponent;
    public static string Productofcase;
    public static string Productfamileyofcase;
    public static string SalesforceOwner;
    public static string Accname;
    public static string AccNumber;
    public static string AccId;
    public static string ContactName;
    public static string AccBilling;
    public static string L3Stepstoreprodeuce;
    public static string L3ticketSummary;
    public static string CasePriority;
    public static string Email;
    public static string caseType;    
    public static Map<String, String> projectUrl;
    public static string proName;
    public static string urlofproject;
    public static string cid;
    public static string FoundIn; // used
    
    // US125897
    public static string competitor1,competitor2,competitor3,
        competitor4,competitor5,competitor1Bid,competitor2Bid,
        competitor3Bid,competitor4Bid,competitor5Bid,demandPropertyId,demandPropertyId1,demandPropertyId2,
        demandPropertyId3,demandPropertyId4,demandPropertyId5,propertyMapping,propertyMapping1,propertyMapping2,
        propertyMapping3,propertyMapping4,propertyMapping5;

    // US125897
    public static Map<String, String> relationalFieldsArr = new Map<String, String> {'Competitor1' => 'Competitor_1__r.Name','Competitor2' => 'Competitor_2__r.Name','Competitor3' => 'Competitor_3__r.Name','Competitor4' => 'Competitor_4__r.Name','Competitor5' => 'Competitor_5__r.Name'};
        
    static 
    {
    	projectUrl = new Map<String, String>();
    }

    // this apex method is called from button to create defect in rally
    webservice static String createUserStory(String caseID)
    {
        
        Case c = [SELECT Id, CaseNumber, Case_Product_Line__c, Customer_Severity__c, Product_TC__c, 
                  Owner.Name, Account.Name, Account.AccountNumber, Account.iHotelier_License_ID__c, Account.BillingStreet, Contact.Name, Contact.Email, 
                  Product_Family__c, Module__c, Component__c, L3_Steps_To_Reproduce__c, L3_Ticket_Summary__c,
                  UserStoryLink__c, User_Story_Id__c, UserStory_Rally_Status__c, User_Story_Release__c, User_Story_Project__c, Rally_Case_Type__c, Rally_Artifact_Ref__c, 
                  Competitor_1__r.Name, Competitor_2__r.Name, Competitor_3__r.Name, Competitor_4__r.Name, Competitor_5__r.Name, 
                  Competitor_1_BID__c, Competitor_2_BID__c, Competitor_3_BID__c, Competitor_4_BID__c, Competitor_5_BID__c, 
                  Demand_Property_ID__c, Demand_Property_ID_1__c, Demand_Property_ID_2__c, Demand_Property_ID_3__c, Demand_Property_ID_4__c, Demand_Property_ID_5__c, 
                  Property_Mapping__c, Property_Mapping_1__c, Property_Mapping_2__c, Property_Mapping_3__c, Property_Mapping_4__c, Property_Mapping_5__c
                  FROM Case 
                  WHERE Id =: caseID];
        
        cid = caseID;
        FoundIn = c.CaseNumber;        
        
        // values of Notes in rally
        AffectedComponent = c.Module__c;
        Productofcase = c.Case_Product_Line__c;
        Productfamileyofcase = c.Product_Family__c;
        SalesforceOwner = c.Owner.Name;

        Accname = c.Account.Name;
        AccNumber = c.Account.AccountNumber;
        AccId = c.Account.iHotelier_License_ID__c;
        ContactName = c.Contact.Name;
        AccBilling = c.Account.BillingStreet;
        L3Stepstoreprodeuce = c.L3_Steps_To_Reproduce__c;
        L3ticketSummary = c.L3_Ticket_Summary__c;
        CasePriority = AH_Rally_FieldMapper.getRallyPriorityMapping('Customer_Severity__c', c.Customer_Severity__c);
        Email = c.Contact.Email;
        caseType = c.Rally_Case_Type__c;               
        competitor1 = c.Competitor_1__r.Name;
        competitor2 = c.Competitor_2__r.Name;
        competitor3 = c.Competitor_3__r.Name;
        competitor4 = c.Competitor_4__r.Name;
        competitor5 = c.Competitor_5__r.Name;
        competitor1Bid = c.Competitor_1_BID__c;
        competitor2Bid = c.Competitor_2_BID__c;
        competitor3Bid = c.Competitor_3_BID__c;
        competitor4Bid = c.Competitor_4_BID__c;
        competitor5Bid = c.Competitor_5_BID__c;
        demandPropertyId = c.Demand_Property_ID__c;
        demandPropertyId1 = c.Demand_Property_ID_1__c;
        demandPropertyId2 = c.Demand_Property_ID_2__c;
        demandPropertyId3 = c.Demand_Property_ID_3__c;
        demandPropertyId4 = c.Demand_Property_ID_4__c;
        demandPropertyId5 = c.Demand_Property_ID_5__c;
        propertyMapping = c.Property_Mapping__c;
        propertyMapping1 = c.Property_Mapping_1__c;
        propertyMapping2 = c.Property_Mapping_2__c;
        propertyMapping3 = c.Property_Mapping_3__c;
        propertyMapping4 = c.Property_Mapping_4__c;
        propertyMapping5 = c.Property_Mapping_5__c;
        proName = '';
        
        /*
        ==============================
		Product Project Mapping Legend
        ==============================     
        Solution Domain (Product_Family__c) = Case.Product_Family__c 
        Case Product Line (Product__c) = Case.Case_Product_Line__c  
        Module (Affected_Component__c) = Case.Module__c 
        Component (Component__c) = Case.Case_Product_Line__c 
        */   
        
system.debug(' ::*:: c.Product_Family__c = ' + c.Product_Family__c); 
system.debug(' ::*:: c.Case_Product_Line__c = ' + c.Case_Product_Line__c);  
system.debug(' ::*:: c.Module__c = ' + c.Module__c);  
system.debug(' ::*:: c.Component__c = ' + c.Component__c);       
                 
        List<ProductMapping__c> lstProdProjMapping = new List<ProductMapping__c>(
            [SELECT Product_Family__c, Product__c, Component__c, Affected_Component__c, Project__c 
             FROM ProductMapping__c 
             WHERE Product_Family__c =: c.Product_Family__c 
             AND Product__c =: c.Case_Product_Line__c 
             AND Affected_Component__c =: c.Module__c 
             AND Component__c =: c.Component__c]);
        
system.debug(' ::*:: Custom Setting Query = SELECT Product_Family__c, Product__c, Component__c, Affected_Component__c, Project__c FROM ProductMapping__c WHERE Product_Family__c = \'' + c.Product_Family__c + '\' AND Product__c = \'' + c.Case_Product_Line__c + '\' AND Affected_Component__c = \'' + c.Module__c + '\' AND Component__c = \'' + c.Component__c + '\' ');
system.debug(' ::*:: lstProdProjMapping.size() = ' + lstProdProjMapping.size());  
        
        if (lstProdProjMapping.size() == 1)
        {
            proName = lstProdProjMapping[0].Project__c; 
        }
        
system.debug(' ::*:: proName = ' + proName); 
        
        if (proName == '')
        {
system.debug(' ::*:: proName = ' + proName + ', error in class');             
            return 'error in class';
        }
        
        try
        { 
            
            // Endpoint to create user Story in Rally
            String endpoint = AH_Rally_Credentials.endPoint + '/slm/webservice/' + AH_Rally_Credentials.versionNumber + '/hierarchicalrequirement/create.js';
            
            String getRequestedBody = AH_Rally_Library.sendRequestObject('POST', endpoint, jsonString(caseID));
            getRequestedBody = getRequestedBody.replace('_ref', 'ref');
            JSONParser parser = JSON.createParser(getRequestedBody);
        
system.debug(' ::*:: getRequestedBody = ' + getRequestedBody);  
        
            AH_Rally_UserStoryDetails usd = new AH_Rally_UserStoryDetails(); 
            
            while (parser.nextToken() != null) 
            {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) 
                {
                    while (parser.nextToken() != null) 
                    {
                        if (parser.getCurrentName() == 'Object')
                        {
                            while (parser.nextToken() != null)
                            { 
                                if (parser.getCurrentToken() == JSONToken.START_OBJECT)
                                {
                                    usd = (AH_Rally_UserStoryDetails)parser.readValueAs(AH_Rally_UserStoryDetails.class);
                                    break;
                                }
                            }
                        }
                    }
                }
            }              
            
            String projectreplaceurl = AH_Rally_Credentials.endPoint + '/slm/webservice/' + AH_Rally_Credentials.versionNumber + '/project/';
            String projectid = usd.Project.ref.replaceFirst(projectreplaceurl,'');
            projectid = projectid.replace('.js',''); 
            String linkofUserStory = 'https://rally1.rallydev.com/#/' + projectid + 'ud/detail/userstory/' + usd.Objectid;
            
            c.UserStory_Rally_Status__c = usd.L3KanbanStage;  
            c.User_Story_Id__c = usd.FormattedID;       
            c.Rally_Artifact_Ref__c = usd.ref;
            c.UserStoryLink__c = linkofUserStory;       
            c.User_Story_Project__c = usd.Project.refObjectName;
            System.debug('***  ' + usd);
            if (usd.Release != null)
            {
                c.User_Story_Release__c = usd.Release.refObjectName;   
            }
            else
            {
                c.User_Story_Release__c = 'Unscheduled';
            }
 
            update c;
            return usd.ref;
            
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            return 'error in class'; 
        }
        
    }

    public static String jsonString(String caseid)
    {
        try
        {
            
            String Note = '';
            
            if (!Test.isRunningTest())
            {
                if (Accname == null)
                {
                    Accname = '';
                }
                if (AccNumber == null)
                {
                    AccNumber = '';
                }
                if (AccId == null)
                {
                    AccId = '';
                }
                if (ContactName == null)
                {
                    ContactName = '';
                }
                if (AccBilling == null)
                {
                    AccBilling = '';
                }
                if (AffectedComponent == null)
                {
                    AffectedComponent = '';
                }
                if (Email == null)
                {
                    Email = '';
                }
                if (caseType == null)
                {
                    caseType = '';
                }
                
                Note = '<b> Issue Details: </b><br/><br/><table width="50%" cellspacing="5" cellpadding="3"><tr><td valign="top"> Product Family:</td><td>' + Productfamileyofcase + '</td></tr><tr><td valign="top"> Product:</td><td>' + Productofcase + '</td></tr><tr><td valign="top">  Affected Component:</td><td>'+AffectedComponent+'</td></tr><tr><td valign="top"> Case Owner:</td><td>'+SalesforceOwner+'</td></tr><tr><td valign="top"> Business Name:</td><td>'+Accname+'</td></tr><tr><td valign="top"> BID Number:</td><td>'+AccNumber+'</td></tr><tr><td valign="top"> I-Hotelier License ID:</td><td>'+AccId+'</td></tr><tr><td valign="top"> Customer Name:</td><td>'+ContactName+'</td></tr><tr><td valign="top"> Customer Email:</td><td>'+Email+'</td></tr><tr><td valign="top"> Business Location:</td><td>'+AccBilling+'</td></tr><tr><td valign="top"> Salesforce Case Id:</td><td>'+FoundIn+'</td></tr><tr><td valign="top">Rally Case Type:</td><td>'+caseType+'</td></tr><tr><td valign="top">Steps To Reproduce:</td><td>'+L3Stepstoreprodeuce+'</td></tr></table>';
                
            }
            
            String setvalue = 'abc';
            List<String> realValues = new List<String>();
            
            // get the map according to the mapping done for the defect fields with salesforce fields
            Map<String, String> RallySfMapping = AH_Rally_Library.getMapping();
            
            // form dynamic query from the mapping
            String query = 'SELECT ';
            
            for (String rallyName : RallySfMapping.keySet())
            {
                String value = RallySfMapping.get(rallyName);
                if (value != 'None')
                {   
                    
                    System.debug('value = ' + value);
                    if (!(value.startsWith('Default')))
                    {
                        realValues.add(value);
                        query = query + value + ',';
                    } 
                }
            } 
            
            query = query.removeEnd(',');
            query = query + ' FROM Case WHERE Id = \'' + caseid + '\'';
            
            system.debug('&&&&& query ' + query);
            
            //get the record values by query 
            Case case1 = Database.query(query);
            system.debug('^^^ case data ' +case1);
            system.debug(' *** ' + projectUrl);
            system.debug(' *** ' + projectUrl);
            projectUrl = AH_Rally_Library.projectList();
            urlofproject = projectUrl.get(proName);
            
            //form the json body which is used to create defect 
            JSONGenerator gen = JSON.createGenerator(true);   
            gen.writeStartObject();
            gen.writeFieldName('Defect');
            gen.writeStartObject();
            gen.writeStringField('_rallyAPIMajor', '1');
            gen.writeStringField('_rallyAPIMinor', '43');  
            gen.writeFieldName('Workspace');
            gen.writeStartObject();
            gen.writeStringField('_rallyAPIMajor', '1');
            gen.writeStringField('_rallyAPIMinor', '43');
            gen.writeStringField('_ref', AH_Rally_Library.workspaceUrl());  
            gen.writeStringField('_refObjectName', AH_Rally_Library.getWorkspaceName()); 
            gen.writeStringField('_type', 'Workspace'); 
            gen.writeEndObject(); 
            gen.writeFieldName('Project');
            gen.writeStartObject();
            gen.writeStringField('_rallyAPIMajor', '1');
            gen.writeStringField('_rallyAPIMinor', '43');  
            System.debug(' *** ' + urlofproject);
            if (!Test.isRunningTest())
            {
                gen.writeStringField('_ref', urlofproject);  
            }
            gen.writeStringField('_refObjectName', proName);
            gen.writeStringField('_type', 'Project'); 
            gen.writeEndObject(); 
            gen.writeFieldName('SalesforceCase');
            gen.writeStartObject();
            gen.writeStringField('LinkID', cid);
            gen.writeStringField('DisplayString', FoundIn);    
            gen.writeEndObject();  
            
            //setting custom field ; Static mapping
            gen.writeStringField('Description', Note + '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<br/><br/><b> Issue Description:  </b><br/><br/>'+L3ticketSummary); 

            // Dynamic Mapping from User Field from RSM
            for (String str:RallySfMapping.keySet())
            {
                for (String s:realValues)
                {
                    setvalue='abc';
                    if (RallySfMapping.get(Str) == s)
                    { 
                        // If Rally Field name is SalesforceCreationDate then setvalue is datetime that is serialized   
                        System.debug('Field Name: '+str);
                        System.debug('Field Value: '+case1.get(s));
                        if(str.equalsIgnoreCase('SalesforceCreationDate')){
                            setvalue = JSON.serialize(case1.get(s)).remove('"');
                        }
                        else if (relationalFieldsArr.containsKey(str)) //US125897
                        { 
                            
                            String strBreak = relationalFieldsArr.get(str);
                            
                            List<String> strBreakArray=strBreak.split('\\.');

                            try
                            {
                                setvalue = String.valueOf(case1.getSObject(strBreakArray[0]).get(strBreakArray[1]));  
                            }
                            catch (Exception e)
                            {
                                System.debug(e.getMessage());
                                setvalue = '';
                            }

                        }
                        else if (str.equalsIgnoreCase('SalesforcePriority'))
                        {
                            setvalue = AH_Rally_FieldMapper.getRallyPriorityMapping('Customer_Severity__c',(String)case1.get(s));
                        }
                        else
                        {
                            setvalue = String.valueOf(case1.get(s));
                        }
                        if (setvalue == null)
                        {
                            setvalue = 'None';
                        }
                        break;
                    }
                    
                }
                
                if (setvalue == 'abc')
                {
                    setvalue = RallySfMapping.get(str);
                    if ((setvalue.startsWith('Default')))
                    {
                        setvalue = setvalue.remove('DefaultValue--');                       
                    }
                    
                }
                
                if (setvalue!='None')
                {
                    gen.writeStringField(str,setvalue);
                }
                
            }       
            
            gen.writeEndObject();           
            gen.writeEndObject(); 
            String jstring = gen.getAsString();
            
            system.debug('++++++++++++++++++++++++++'+jstring);
            return jstring; 
            
        }
        catch (Exception e)
        {
            system.debug(e.getMessage() + '|| '
                        + e.getLineNumber() );
            throw e;
        }
        
    }
    
}