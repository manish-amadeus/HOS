/************************************************************************************************************************
Name            : AH_SF_SourceSync Class
Author          : Sean Harris
Created Date    : 06/04/2018
Last Mod Date   : 06/04/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description		: 
     			: 
*************************************************************************************************************************/
public class AH_SF_SourceSync 
{

    public string sid {get; set;}     
    public DateTime dt {get; set;} 
    public List<AH_SFDC_Source_Control__c> lstSFSC {get; set;} 
    public List<AH_SFDC_Source_Version__c> lstVersionInserts {get; set;} 
    public List<AH_SFDC_Source_Control__c> lstUpserts {get; set;}  

	public List<PBRecord> lstProcessBuilders {get; set;}
    public PBWrap pbw {get; set;}
    public List<VRRecord> lstValidationRules {get; set;}
    public VRWrap vrw {get; set;}
    
    public AH_SF_SourceSync()
    {
        
    }
    
    public void invokeSync()
    {
        initVars();
        processApexClasses();
        processApexTriggers();
        processApexPages();
        processApexComponents();
        // TOOLING API CALLOUT METHODS
        if (!Test.isRunningTest())
        {
            processProcBuilders();
        	processValidationRules();
        }
        commitRecords();
    }
    
    public void initVars()
    {
        
    	sid = (string)UserInfo.getSessionId();
		dt = null;
        
        // GET SOURCE MAX CONTROL Source_Last_Modified__c
        try 
        {
            List<AggregateResult> lstMaxModDate = new List<AggregateResult>(
                [SELECT MAX(Source_Last_Modified__c) MaxModDate
                 FROM AH_SFDC_Source_Control__c]);
            if (!lstMaxModDate.isEmpty())
            {
                dt = (DateTime)lstMaxModDate[0].get('MaxModDate'); 
            }           
        }
		catch (exception ex) { }
        
        // IF NO MAX DATE FOUND THEN SET DATETIME BACK TO GET ALL
        if (dt == null || test.isRunningTest())
        {
            dt = Datetime.newInstance(2000, 1, 1);
        }
	
        // FILL LIST OF ALL APEX CLASS SOURCE CONTROL RECORDS
        lstSFSC = new List<AH_SFDC_Source_Control__c>(
            [SELECT Id, API_Name__c, Syntax__c, Source_Last_Modified__c, Source_Last_Modified_By__c, Salesforce_Source_Type__c 
             FROM AH_SFDC_Source_Control__c]); 
        
        lstVersionInserts = new List<AH_SFDC_Source_Version__c>(); 
    	lstUpserts = new List<AH_SFDC_Source_Control__c>(); 
        
system.debug(' *** lstSFSC.size() = ' + lstSFSC.size());        
        
    }
    
    public void processApexClasses()
    {
        
system.debug(' >>> CUSTOM APEX CLASSES >>> ');
        
        boolean bFound; 
        
        // LOOP THROUGH ALL CUSTOM APEX CLASSES CHANGED AFTER MAX Source_Last_Modified__c
        for (ApexClass c : [SELECT Id, Name, Body, BodyCrc, LastModifiedDate, LastModifiedById    
                            FROM ApexClass 
                            WHERE LastModifiedDate >: dt 
                            AND NamespacePrefix = null])
        {
            
            // INITIALIZE FIND FLAG
            bFound = false;
            
            // LOOP THROUGH APEX CLASS SOURCE CONTROL RECORDS
            for (AH_SFDC_Source_Control__c s : lstSFSC)
            {
                // MATCH ON NAME
                if (c.Name == s.API_Name__c && s.Salesforce_Source_Type__c == 'Apex Class')
                {
                    // SET FIND FLAG
                    bFound = true;
                    
                    // IS A CHANGE WAS MADE TO THE CLASS
system.debug(' ??? c.Name = ' + c.Name);     
system.debug(' ??? c.LastModifiedDate = ' + c.LastModifiedDate + ', s.Source_Last_Modified__c = ' + s.Source_Last_Modified__c);
                    if (c.LastModifiedDate != s.Source_Last_Modified__c)
                    {
                        // CREATE COPY OF SYNTAX IN A VERSON RECORD
                        AH_SFDC_Source_Version__c v = new AH_SFDC_Source_Version__c(); 
                        v.SFDC_Source_Control__c = s.Id; 
                        v.Syntax__c = s.Syntax__c; 
                        lstVersionInserts.add(v); 
                        
                        // UPDATE THE SOURCE CONTROL RECORD WITH THE NEW SYNTAX
                        AH_SFDC_Source_Control__c ex = s; 
                        ex.Source_Last_Modified__c = c.LastModifiedDate; 
                        ex.Source_Last_Modified_By__c = c.LastModifiedById; 
                        ex.Syntax__c = 'Body length too long to fit'; 
                        if (c.Body.Length() < 131070)
                        {
                            ex.Syntax__c = c.Body; 
                        }         
                        lstUpserts.add(ex);                         
                    }
					// MATCH FOUND SO BREAK OUT OF FOR LOOP
					break;    
                }                
            }
            
            // IF THE CLASS WAS NOT FOUND IN SOURCE CONTROL THEN CREATE NEW RECORD
            if (!bFound)
            {
                AH_SFDC_Source_Control__c sc = new AH_SFDC_Source_Control__c();
                sc.Salesforce_Source_Type__c = 'Apex Class';
                sc.API_Name__c = c.Name;
                sc.CRC__c = c.bodyCrc;
                sc.Label__c = c.Name;
                sc.Salesforce_ID__c = c.Id;
                sc.Source_Last_Modified__c = c.LastModifiedDate;
                sc.Source_Last_Modified_By__c = c.LastModifiedById;
                sc.Syntax__c = 'Body length too long to fit';
                if (c.Body.Length() < 131070)
                {
                    sc.Syntax__c = c.Body;
                }
                lstUpserts.add(sc);
            }            
        }                
        
        
    }
    
    public void processApexTriggers()
    {
        
system.debug(' >>> CUSTOM APEX TRIGGERS >>> ');
        
        boolean bFound; 


        // LOOP THROUGH ALL CUSTOM APEX TRIGGERS CHANGED AFTER MAX Source_Last_Modified__c
        for (ApexTrigger t : [SELECT Id, Name, Body, BodyCrc, LastModifiedDate, LastModifiedById, NamespacePrefix   
                              FROM ApexTrigger
                              WHERE LastModifiedDate >: dt 
                              AND NamespacePrefix = null])
        {
            
            // INITIALIZE FIND FLAG
            bFound = false;
            
            // LOOP THROUGH APEX CLASS SOURCE CONTROL RECORDS
            for (AH_SFDC_Source_Control__c s : lstSFSC)
            {
                // MATCH ON NAME
                if (t.Name == s.API_Name__c && s.Salesforce_Source_Type__c == 'Apex Trigger')
                {
                    // SET FIND FLAG
                    bFound = true;
                    
                    // IS A CHANGE WAS MADE TO THE CLASS
system.debug(' ??? t.Name = ' + t.Name);     
system.debug(' ??? t.LastModifiedDate = ' + t.LastModifiedDate + ', s.Source_Last_Modified__c = ' + s.Source_Last_Modified__c);
                    if (t.LastModifiedDate != s.Source_Last_Modified__c)
                    {
                        // CREATE COPY OF SYNTAX IN A VERSON RECORD
                        AH_SFDC_Source_Version__c v = new AH_SFDC_Source_Version__c(); 
                        v.SFDC_Source_Control__c = s.Id; 
                        v.Syntax__c = s.Syntax__c; 
                        lstVersionInserts.add(v); 
                        
                        // UPDATE THE SOURCE CONTROL RECORD WITH THE NEW SYNTAX
                        AH_SFDC_Source_Control__c ex = s; 
                        ex.Source_Last_Modified__c = t.LastModifiedDate; 
                        ex.Source_Last_Modified_By__c = t.LastModifiedById; 
                        ex.Syntax__c = 'Body length too long to fit'; 
                        if (t.Body.Length() < 131070)
                        {
                            ex.Syntax__c = t.Body; 
                        }         
                        lstUpserts.add(ex);                         
                    }
					// MATCH FOUND SO BREAK OUT OF FOR LOOP
					break;    
                }                
            }
            
            // IF THE CLASS WAS NOT FOUND IN SOURCE CONTROL THEN CREATE NEW RECORD
            if (!bFound)
            {
                AH_SFDC_Source_Control__c sc = new AH_SFDC_Source_Control__c();
                sc.Salesforce_Source_Type__c = 'Apex Trigger';
                sc.API_Name__c = t.Name;
                sc.CRC__c = t.bodyCrc;
                sc.Label__c = t.Name;
                sc.Salesforce_ID__c = t.Id;
                sc.Source_Last_Modified__c = t.LastModifiedDate;
                sc.Source_Last_Modified_By__c = t.LastModifiedById;
                sc.Syntax__c = 'Body length too long to fit';
                if (t.Body.Length() < 131070)
                {
                    sc.Syntax__c = t.Body;
                }
                lstUpserts.add(sc);
            }            
        }        
    }

    public void processApexPages()
    {
        
system.debug(' >>> CUSTOM VISUALFORCE PAGES >>> ');
        
        boolean bFound; 

        // LOOP THROUGH ALL CUSTOM VISUALFORCE PAGES CHANGED AFTER MAX Source_Last_Modified__c
        for (ApexPage p : [SELECT Id, Name, Markup, MasterLabel, LastModifiedDate, LastModifiedById, NamespacePrefix   
                           FROM ApexPage
                           WHERE LastModifiedDate >: dt 
                           AND NamespacePrefix = null])
        {
            
            // INITIALIZE FIND FLAG
            bFound = false;
            
            // LOOP THROUGH APEX CLASS SOURCE CONTROL RECORDS
            for (AH_SFDC_Source_Control__c s : lstSFSC)
            {
                // MATCH ON NAME
                if (p.Name == s.API_Name__c && s.Salesforce_Source_Type__c == 'Visualforce Page')
                {
                    // SET FIND FLAG
                    bFound = true;
                    
                    // IS A CHANGE WAS MADE TO THE CLASS
system.debug(' ??? p.Name = ' + p.Name);     
system.debug(' ??? p.LastModifiedDate = ' + p.LastModifiedDate + ', s.Source_Last_Modified__c = ' + s.Source_Last_Modified__c);
                    if (p.LastModifiedDate != s.Source_Last_Modified__c)
                    {
                        // CREATE COPY OF SYNTAX IN A VERSON RECORD
                        AH_SFDC_Source_Version__c v = new AH_SFDC_Source_Version__c(); 
                        v.SFDC_Source_Control__c = s.Id; 
                        v.Syntax__c = s.Syntax__c; 
                        lstVersionInserts.add(v); 
                        
                        // UPDATE THE SOURCE CONTROL RECORD WITH THE NEW SYNTAX
                        AH_SFDC_Source_Control__c ex = s; 
                        ex.Source_Last_Modified__c = p.LastModifiedDate; 
                        ex.Source_Last_Modified_By__c = p.LastModifiedById; 
                        ex.Syntax__c = 'Body length too long to fit'; 
                        if (p.Markup.Length() < 131070)
                        {
                            ex.Syntax__c = p.Markup; 
                        }         
                        lstUpserts.add(ex);                         
                    }
					// MATCH FOUND SO BREAK OUT OF FOR LOOP
					break;    
                }                
            }
            
            // IF THE CLASS WAS NOT FOUND IN SOURCE CONTROL THEN CREATE NEW RECORD
            if (!bFound)
            {
                AH_SFDC_Source_Control__c sc = new AH_SFDC_Source_Control__c();
                sc.Salesforce_Source_Type__c = 'Visualforce Page';
                sc.API_Name__c = p.Name;
                sc.Label__c = p.MasterLabel;
                sc.Salesforce_ID__c = p.Id;
                sc.Source_Last_Modified__c = p.LastModifiedDate;
                sc.Source_Last_Modified_By__c = p.LastModifiedById;
                sc.Syntax__c = 'Body length too long to fit';
                if (p.Markup.Length() < 131070)
                {
                    sc.Syntax__c = p.Markup;
                }
                lstUpserts.add(sc);
            }            
        }
    }        

    public void processApexComponents()
    {
        
system.debug(' >>> CUSTOM VISUALFORCE COMPONENTS >>> ');
        
        boolean bFound; 

        // LOOP THROUGH ALL CUSTOM VISUALFORCE COMPONENTS CHANGED AFTER MAX Source_Last_Modified__c
        for (ApexComponent x : [SELECT Id, Name, Markup, MasterLabel, LastModifiedDate, LastModifiedById, NamespacePrefix  
                                FROM ApexComponent
                                WHERE LastModifiedDate >: dt 
                                AND NamespacePrefix = null])
        {
            
            // INITIALIZE FIND FLAG
            bFound = false;
            
            // LOOP THROUGH APEX CLASS SOURCE CONTROL RECORDS
            for (AH_SFDC_Source_Control__c s : lstSFSC)
            {
                // MATCH ON NAME
                if (x.Name == s.API_Name__c && s.Salesforce_Source_Type__c == 'Visualforce Component')
                {
                    // SET FIND FLAG
                    bFound = true;
                    
                    // IS A CHANGE WAS MADE TO THE CLASS
system.debug(' ??? x.Name = ' + x.Name);                    
system.debug(' ??? x.LastModifiedDate = ' + x.LastModifiedDate + ', s.Source_Last_Modified__c = ' + s.Source_Last_Modified__c);
                    if (x.LastModifiedDate != s.Source_Last_Modified__c)
                    {
                        // CREATE COPY OF SYNTAX IN A VERSON RECORD
                        AH_SFDC_Source_Version__c v = new AH_SFDC_Source_Version__c(); 
                        v.SFDC_Source_Control__c = s.Id; 
                        v.Syntax__c = s.Syntax__c; 
                        lstVersionInserts.add(v); 
                        
                        // UPDATE THE SOURCE CONTROL RECORD WITH THE NEW SYNTAX
                        AH_SFDC_Source_Control__c ex = s; 
                        ex.Source_Last_Modified__c = x.LastModifiedDate; 
                        ex.Source_Last_Modified_By__c = x.LastModifiedById; 
                        ex.Syntax__c = 'Body length too long to fit'; 
                        if (x.Markup.Length() < 131070)
                        {
                            ex.Syntax__c = x.Markup; 
                        }         
                        lstUpserts.add(ex);                         
                    }
					// MATCH FOUND SO BREAK OUT OF FOR LOOP
					break;    
                }                
            }
            
            // IF THE CLASS WAS NOT FOUND IN SOURCE CONTROL THEN CREATE NEW RECORD
            if (!bFound)
            {
                AH_SFDC_Source_Control__c sc = new AH_SFDC_Source_Control__c();
                sc.Salesforce_Source_Type__c = 'Visualforce Component';
                sc.API_Name__c = x.Name;
                sc.Label__c = x.MasterLabel;
                sc.Salesforce_ID__c = x.Id;
                sc.Source_Last_Modified__c = x.LastModifiedDate;
                sc.Source_Last_Modified_By__c = x.LastModifiedById;
                sc.Syntax__c = 'Body length too long to fit';
                if (x.Markup.Length() < 131070)
                {
                    sc.Syntax__c = x.Markup;
                }
                lstUpserts.add(sc);
            }            
        }        
        
    }

    public void processProcBuilders()
    {
        
system.debug(' >>> PROCESS BUILDERS >>> ');
        
        boolean bFound; 
        
        getProcessBuilders();
        
system.debug(' *** lstProcessBuilders.size() = ' + lstProcessBuilders.size());  
        
        // LOOP THROUGH ALL PROCESS BUILDERS CHANGED AFTER MAX Source_Last_Modified__c
        for (PBRecord pb : lstProcessBuilders)
        {
system.debug(' *** pb.ActiveVersion.LastModifiedDate = ' + pb.ActiveVersion.LastModifiedDate + ', dt = ' + dt);                          
            if (pb.ActiveVersion.LastModifiedDate > dt)
            {
                // INITIALIZE FIND FLAG
                bFound = false;
system.debug(' *** lstSFSC.size() = ' + lstSFSC.size());                
                // LOOP THROUGH APEX CLASS SOURCE CONTROL RECORDS
                for (AH_SFDC_Source_Control__c s : lstSFSC)
                {
                    // MATCH ON NAME
                    if (pb.DeveloperName == s.API_Name__c && s.Salesforce_Source_Type__c == 'Process Builder')
                    {
                        // SET FIND FLAG
                        bFound = true;
                        
                        // IS A CHANGE WAS MADE TO THE CLASS
system.debug(' ??? pb.DeveloperName = ' + pb.DeveloperName);                    
system.debug(' ??? pb.ActiveVersion.LastModifiedDate = ' + pb.ActiveVersion.LastModifiedDate + ', s.Source_Last_Modified__c = ' + s.Source_Last_Modified__c);
                        if (pb.ActiveVersion.LastModifiedDate != s.Source_Last_Modified__c)
                        {
                            // CREATE COPY OF SYNTAX IN A VERSON RECORD
//                            AH_SFDC_Source_Version__c v = new AH_SFDC_Source_Version__c(); 
//                            v.SFDC_Source_Control__c = s.Id; 
//                            v.Syntax__c = s.Syntax__c; 
//                            lstVersionInserts.add(v); 
                            
                            // UPDATE THE SOURCE CONTROL RECORD WITH THE NEW SYNTAX
                            AH_SFDC_Source_Control__c ex = s; 
                            ex.Source_Last_Modified__c = pb.ActiveVersion.LastModifiedDate; 
                            ex.Source_Last_Modified_By__c = pb.ActiveVersion.LastModifiedById; 
//                            ex.Syntax__c = 'Body length too long to fit'; 
//                            if (pb.Markup.Length() < 131070)
//                            {
//                                ex.Syntax__c = pb.Markup; 
//                            }         
                            lstUpserts.add(ex);                         
                        }
                        // MATCH FOUND SO BREAK OUT OF FOR LOOP
                        break;    
                    }                
                }
              
                // IF THE CLASS WAS NOT FOUND IN SOURCE CONTROL THEN CREATE NEW RECORD
                if (!bFound)
                {
                    AH_SFDC_Source_Control__c sc = new AH_SFDC_Source_Control__c();
                    sc.Salesforce_Source_Type__c = 'Process Builder';
                    sc.API_Name__c = pb.DeveloperName;
                    string strLabel = pb.DeveloperName;
                    sc.Label__c = strLabel.replace('_', ' '); 
                    sc.Description__c = pb.ActiveVersion.Description;
                    sc.Salesforce_ID__c = pb.ActiveVersionId;
                    sc.Source_Last_Modified__c = pb.ActiveVersion.LastModifiedDate;
                    sc.Source_Last_Modified_By__c = pb.ActiveVersion.LastModifiedById;
//                    sc.Syntax__c = 'Body length too long to fit';
//                    if (pb.Markup.Length() < 131070)
//                    {
//                        sc.Syntax__c = pb.Markup;
//                    }
                    lstUpserts.add(sc);
                }
            }
        }        
    }
    
    public void processValidationRules()
    {
        
system.debug(' >>> VALIDATION RULES >>> ');
        
        boolean bFound;     
           
		getValidationRules();    
        
system.debug(' *** lstValidationRules.size() = ' + lstValidationRules.size());  
                
        // LOOP THROUGH ALL VALIDATION RULES CHANGED AFTER MAX Source_Last_Modified__c
        for (VRRecord vr : lstValidationRules)
        {
system.debug(' *** vr.LastModifiedDate = ' + vr.LastModifiedDate + ', dt = ' + dt);  
            if (vr.LastModifiedDate > dt)
            {
                // INITIALIZE FIND FLAG
                bFound = false;
                string strFullValName = '';
                
                // LOOP THROUGH APEX CLASS SOURCE CONTROL RECORDS LOOKING FOR EXISTING VALIDATION RULES FOR UPSERTS
                for (AH_SFDC_Source_Control__c s : lstSFSC)
                {
                    // MATCH ON NAME
                    strFullValName = vr.EntityDefinitionId + '.' + vr.ValidationName;
                    if (strFullValName == s.API_Name__c && s.Salesforce_Source_Type__c == 'Validation Rule')
                    {
                        // SET FIND FLAG
                        bFound = true;
                        
                        // IS A CHANGE WAS MADE TO THE CLASS
system.debug(' ??? strFullValName = ' + strFullValName);                    
system.debug(' ??? vr.LastModifiedDate = ' + vr.LastModifiedDate + ', s.Source_Last_Modified__c = ' + s.Source_Last_Modified__c);
                        if (vr.LastModifiedDate != s.Source_Last_Modified__c)
                        {
                            // CREATE COPY OF SYNTAX IN A VERSON RECORD
//                            AH_SFDC_Source_Version__c v = new AH_SFDC_Source_Version__c(); 
//                            v.SFDC_Source_Control__c = s.Id; 
//                            v.Syntax__c = s.Syntax__c; 
//                            lstVersionInserts.add(v); 
                            
                            // UPDATE THE SOURCE CONTROL RECORD WITH THE NEW SYNTAX
                            AH_SFDC_Source_Control__c ex = s; 
                            ex.Source_Last_Modified__c = vr.LastModifiedDate; 
                            ex.Source_Last_Modified_By__c = vr.LastModifiedById; 
//                            ex.Syntax__c = 'Body length too long to fit'; 
//                            if (vr.Markup.Length() < 131070)
//                            {
//                                ex.Syntax__c = vr.Markup; 
//                            }         
                            lstUpserts.add(ex);                         
                        }
                        // MATCH FOUND SO BREAK OUT OF FOR LOOP
                        break;    
                    }                
                }
                
                // IF THE CLASS WAS NOT FOUND IN SOURCE CONTROL THEN CREATE NEW RECORD
                if (!bFound)
                {
                    AH_SFDC_Source_Control__c sc = new AH_SFDC_Source_Control__c();
                    sc.Salesforce_Source_Type__c = 'Validation Rule';
                    strFullValName = vr.EntityDefinitionId + '.' + vr.ValidationName;
                    sc.API_Name__c = strFullValName;
                    string strLabel = vr.ValidationName;
                    sc.Label__c = strLabel.replace('_', ' '); 
                    sc.Description__c = vr.Description;
                    sc.Salesforce_ID__c = vr.Id;
                    sc.Source_Last_Modified__c = vr.LastModifiedDate;
                    sc.Source_Last_Modified_By__c = vr.LastModifiedById;
//                    sc.Syntax__c = 'Body length too long to fit';
//                    if (vr.Markup.Length() < 131070)
//                    {
//                        sc.Syntax__c = vr.Markup;
//                    }
                    lstUpserts.add(sc);
                }                
            }
        }
    }
    
    public void commitRecords()
    {
        
system.debug(' >>> COMMITTING RECORDS >>> ');
        
//for (AH_SFDC_Source_Version__c dbug1 : lstVersionInserts)
//{
//    system.debug('dbug1: ' + dbug1);
//} 
        
system.debug(' *** lstVersionInserts.size() = ' + lstVersionInserts.size()); 
        if (!lstVersionInserts.isEmpty())
        {
            database.insert(lstVersionInserts);
        }
        

//for (AH_SFDC_Source_Control__c dbug2 : lstUpserts)
//{
//    system.debug('dbug2: ' + dbug2.Salesforce_Source_Type__c + ', ' + dbug2.API_Name__c);
//}
        
system.debug(' *** lstUpserts.size() = ' + lstUpserts.size());  
        if (!lstUpserts.isEmpty())
        {
            database.upsert(lstUpserts);
        }    
    }

    public void getProcessBuilders()
    {

        lstProcessBuilders = new List<PBRecord>();
        String auth = 'Bearer ' + sid;
        String query = 'SELECT ActiveVersionId, DeveloperName, ActiveVersion.LastModifiedDate, ActiveVersion.LastModifiedById, ActiveVersion.Description FROM FlowDefinition WHERE NamespacePrefix = null AND ActiveVersionId != null';
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v41.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
        
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', auth);
        request.setEndpoint(endpoint);
        request.setMethod('GET');
     
        HttpResponse response = new Http().send(request);

system.debug(' getFlowVerions() response.getStatusCode() = ' + response.getStatusCode());   
system.debug(' response.getBody() = ' + response.getBody()); 

        if (response.getStatusCode() == 200)
        {    
                     
            pbw = (PBWrap)JSON.deserialize(response.getBody(), PBWrap.class);
system.debug(' pbw = ' + pbw);   
            try
            {
                for (PBRecord pb : pbw.records)
                {
                    lstProcessBuilders.add(pb);
                }
            }
            catch (Exception e) {}   
        }
      
    }
    
    public void getValidationRules()
    {
        
        lstValidationRules = new List<VRRecord>();
        String auth = 'Bearer ' + sid;
        String query = 'SELECT Id, LastModifiedDate, LastModifiedById, EntityDefinitionId, ValidationName, Description FROM ValidationRule WHERE NamespacePrefix = null AND Active = true';
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v41.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
        
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', auth);
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        
        HttpResponse response = new Http().send(request);
        
system.debug(' getFlows() response.getStatusCode() = ' + response.getStatusCode());           
system.debug(' response.getBody() = ' + response.getBody()); 
                
        if (response.getStatusCode() == 200)
        {
            vrw = (VRWrap)JSON.deserialize(response.getBody(), VRWrap.class);
system.debug(' vrw = ' + vrw); 
            try
            {
                for (VRRecord vr : vrw.records)
                {
                    lstValidationRules.add(vr);
                }
            }
            catch (Exception e) {}      
        }
    }


	// INNER CLASSES =======================================================
    public class Attributes 
    {
        public String type;
        public String url {get; set;}
    } 
    
    // PROCESS BUILDERS
    public class PBWrap
    {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<PBRecord> records {get; set;}
    }
    
    public class PBRecord 
    {
        public Attributes attributes;
        public String ActiveVersionId {get; set;}
        public String DeveloperName {get; set;}
        public ActiveVersion ActiveVersion {get; set;}
    } 

    public class ActiveVersion 
    {
        public Attributes attributes {get; set;}
        public DateTime LastModifiedDate {get; set;}
        public String LastModifiedById {get; set;}
        public String Description {get; set;} 
    }

    // VALIDATION RULES
    public class VRWrap
    {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;        
        public List<VRRecord> records {get; set;}
    }
    
    public class VRRecord 
    {
        public Attributes attributes;
        public String Id {get; set;} 
        public DateTime LastModifiedDate {get; set;}
        public String LastModifiedById {get; set;}
        public String EntityDefinitionId {get; set;}
        public String ValidationName {get; set;}
        public String Description {get; set;}    
    }       
        
}