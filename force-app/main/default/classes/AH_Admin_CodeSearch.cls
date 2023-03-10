/*************************************************************************************************
Name            : AH_Admin_CodeSearch Class
Author          : Sean Harris
Created Date    : 02/03/2012
Last Mod Date   : 02/05/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for AH_Admin_CodeSearch VF Page
                : 
                : 
*************************************************************************************************/
public class AH_Admin_CodeSearch 
{

    public string strObjLink {get; set;}  
    public List<resultRecord> lstMatches {get; set;} 
    public boolean bApexClasses {get; set;}  
    public boolean bApexTriggers {get; set;}
    public boolean bVFPages {get; set;}
    public boolean bVFComponents {get; set;}
    public boolean bExcludeTests {get; set;}
 	public string strKeyword {get; set;}
    
    
    public AH_Admin_CodeSearch()
    {
        strKeyword = '';
        bApexClasses = true;
        bApexTriggers = false; 
        bVFPages = false;
        bVFComponents = false;
        bExcludeTests = false;
        lstMatches = new List<resultRecord>(); 
    }  

    public void newSearch()
    {    
        strKeyword = ''; 
        lstMatches.clear();   
    }

    public void doSearch()
    {

        lstMatches.clear(); 
        if (strKeyword.trim() == '')
        {
            return; 
        }        
        if (!bApexClasses && !bApexTriggers && !bVFPages && !bVFComponents)
        {
            return; 
        }       

        lstMatches = new List<resultRecord>(); 
        
        if (bApexClasses)
        {
            for (ApexClass x : [SELECT Id, Name, ApiVersion, Body, BodyCrc, CreatedById, CreatedDate, IsValid, LastModifiedById, LastModifiedDate, 
                                LengthWithoutComments, NamespacePrefix, Status, SystemModstamp 
                                FROM ApexClass
                                WHERE NamespacePrefix = null
                               	ORDER BY Name ASC])
            {
                if (x.Body.toUpperCase().Contains(strKeyword.toUpperCase()))
                {    
                    if (x.Name.toUpperCase().Contains('TEST'))
                    {
                        if (!bExcludeTests)
                        {
                            lstMatches.add(new resultRecord(x.ApiVersion, URL.getSalesforceBaseUrl().toExternalForm() + '/' + x.Id, 
                                                        x.Name, x.NamespacePrefix, x.Status, x.CreatedDate, x.LastModifiedDate, 'Apex Test Class'));
                        }
                    }
                    else
                    {
                        lstMatches.add(new resultRecord(x.ApiVersion, URL.getSalesforceBaseUrl().toExternalForm() + '/' + x.Id, 
                                                        x.Name, x.NamespacePrefix, x.Status, x.CreatedDate, x.LastModifiedDate, 'Apex Class'));
                    }
                    
                }
            }
        }

        if (bApexTriggers)
        {
            for (ApexTrigger x : [SELECT Id, Name, ApiVersion, Body, BodyCrc, CreatedById, CreatedDate, IsValid, LastModifiedById, LastModifiedDate, 
                                  LengthWithoutComments, NamespacePrefix, Status, SystemModstamp 
                                  FROM ApexTrigger
                                  WHERE NamespacePrefix = null
                                  ORDER BY Name ASC])
            {
                if (x.Body.toUpperCase().Contains(strKeyword.toUpperCase()))
                {    
                    lstMatches.add(new resultRecord(x.ApiVersion, URL.getSalesforceBaseUrl().toExternalForm() + '/' + x.Id, 
                                                    x.Name, x.NamespacePrefix, x.Status, x.CreatedDate, x.LastModifiedDate, 'Apex Trigger'));
                }
            }                    
        }        

        if (bVFPages)
        {
            for (ApexPage x : [SELECT Id, Name, ApiVersion, Markup, MasterLabel, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, NamespacePrefix  
                               FROM ApexPage  
                               WHERE NamespacePrefix = null
                               ORDER BY Name ASC])
            {
                if (x.Markup.toUpperCase().Contains(strKeyword.toUpperCase()))
                {    
                    lstMatches.add(new resultRecord(x.ApiVersion, URL.getSalesforceBaseUrl().toExternalForm() + '/' + x.Id, 
                                                    x.Name, x.NamespacePrefix, '', x.CreatedDate, x.LastModifiedDate, 'Visualforce Page'));
                }
            }            
        }

        if (bVFComponents)
        {
            for (ApexComponent x : [SELECT Id, Name, ApiVersion, Markup, MasterLabel, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, NamespacePrefix  
                                    FROM ApexComponent  
                                    WHERE NamespacePrefix = null
                                    ORDER BY Name ASC])
            {
                if (x.Markup.toUpperCase().Contains(strKeyword.toUpperCase()))
                {    
                    lstMatches.add(new resultRecord(x.ApiVersion, URL.getSalesforceBaseUrl().toExternalForm() + '/' + x.Id, 
                                                    x.Name, x.NamespacePrefix, '', x.CreatedDate, x.LastModifiedDate, 'Visualforce Component'));
                }
            }            
        }

    }

    public PageReference selectObject() 
    {
        PageReference newPage = new PageReference(strObjLink);        
        newPage.setRedirect(true);
        return newPage;        
    }

    public class resultRecord 
    {
        public Decimal ApiVersion { get; set; }
        //public String strBody { get; set; }
        public String strURL { get; set; }
        public String strName { get; set; }
        public String strNameSpace { get; set; }
        public String strStatus { get; set; }
        public DateTime dtCreated { get; set; }
        public DateTime dtModified { get; set; }
        public String strModuleType { get; set; }
        
        public resultRecord (
            Decimal ApiVersion, 
            //String strBody, 
            String strURL, 
            String strName, 
            String strNameSpace, 
            String strStatus, 
            DateTime dtCreated, 
            DateTime dtModified, 
            String strModuleType 
        ) 
        {
            this.ApiVersion = ApiVersion; 
            //this.strBody = strBody;
            this.strURL = strURL;
            this.strName = strName;
            this.strNameSpace = strNameSpace; 
            this.strStatus = strStatus;
            this.dtCreated = dtCreated;
            this.dtModified = dtModified; 
            this.strModuleType = strModuleType;
        }   
        
    }    
    
}