/*************************************************************************************************
Name            : NIUtil_TabURLs Class
Author          : Sean Harris
Created Date    : 02/03/2012
Last Mod Date   : 02/05/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for NIUtil_TabURLs VF Page
                : 
                : 
*************************************************************************************************/
public class NIUtil_TabURLs 
{

    public List<tabUrls> lstStandardObjects {get; set;} 
    public List<tabUrls> lstCustomObjects {get; set;} 
    public List<tabUrls> lstManagedObjects {get; set;} 
    public List<tabUrls> lstCustomSettings {get; set;} 
    public integer count {get; set;} 
    
    public boolean bIncludeStandardObjects {get; set;} 
    public boolean bIncludeCustomObjects {get; set;} 
    public boolean bIncludeManagedObjects {get; set;} 
    public boolean bIncludeCustomSettings {get; set;} 
    public string strKeyword {get; set;} 

    
    public NIUtil_TabURLs()
    {
        count = 0;
        bIncludeStandardObjects = true; 
        bIncludeCustomObjects = true; 
        bIncludeManagedObjects = true; 
        bIncludeCustomSettings = true; 
        strKeyword = '';
//        doSearch();
    }

    public void doSearch()
    {
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        Set<String> keyPrefixSet = gd.keySet(); 
        lstStandardObjects = new List<tabUrls>();
        lstCustomObjects = new List<tabUrls>();
        lstManagedObjects = new List<tabUrls>();
        lstCustomSettings = new List<tabUrls>();
        string serverURL = URL.getSalesforceBaseUrl().toExternalForm();
        count = 0;
        boolean bInclude;
        
system.debug(' *** strKeyword = ' + strKeyword);
system.debug(' *** bIncludeStandardObjects = ' + bIncludeStandardObjects);
system.debug(' *** bIncludeCustomObjects = ' + bIncludeCustomObjects);
system.debug(' *** bIncludeManagedObjects = ' + bIncludeManagedObjects);
system.debug(' *** bIncludeCustomSettings = ' + bIncludeCustomSettings);
        
        for (String sObj : keyPrefixSet)
        {
            
            Schema.DescribeSObjectResult r = gd.get(sObj).getDescribe();   

            bInclude = true;
        
            if (strKeyword != '')
            {                   
                if ((r.getKeyPrefix() != null) && (r.isDeprecatedAndHidden() == false))
                {                    
                    string strSearch = (r.getLabel().toUpperCase() + ' ' + r.getName().toUpperCase() + ' ' + r.getKeyPrefix().toUpperCase());                   
                    if (!strSearch.contains(strKeyword.toUpperCase()))
                    {                         
                        bInclude = false;
                    }
                }
            }
            
            if (bInclude)
            {
                
                if ((r.getKeyPrefix() != null) && (r.isDeprecatedAndHidden() == false))
                {
                    
                    string isAccessible = 'false';
                    if (r.isAccessible())
                    {
                        isAccessible = 'true';
                    }
                    
                    tabUrls tu = new tabUrls(r.getLabel(), r.getName(), r.getKeyPrefix(), serverURL + '/' + r.getKeyPrefix(), isAccessible);
                    
                    // STANDARD OBJECT
                    if (bIncludeStandardObjects)
                    {
                        if (!r.isCustom())
                        {
                            if (lstStandardObjects.size() < 999)
                            {
                                lstStandardObjects.add(tu);
                                count++;
                            }                    
                        }    
                    }
                    
                    // CUSTOM OBJECT
                    if (bIncludeCustomObjects)
                    {
                        if (r.isCustom())
                        {
                            if (tu.strAPIName.indexOf('__', tu.strAPIName.indexOf('__') + 1) == -1)
                            {
                                if (lstCustomObjects.size() < 999)
                                {                            
                                    lstCustomObjects.add(tu);
                                    count++;
                                }
                            }
                        }   
                    }
                    
                    // MANAGED OBJECT
                    if (bIncludeManagedObjects) 
                    {
                        if (r.isCustom())
                        {
                            if (tu.strAPIName.indexOf('__', tu.strAPIName.indexOf('__') + 1) > -1)
                            {
                                if (lstManagedObjects.size() < 999)
                                {                            
                                    lstManagedObjects.add(tu);
                                    count++;
                                }
                            }
                        } 
                    }
                    
                    // CUSTOM SETTING
                    if (bIncludeCustomSettings)
                    {
                        if (r.isCustomSetting())
                        {
                            if (lstCustomSettings.size() < 999)
                            {
                                lstCustomSettings.add(tu);
                                count++;
                            }
                        }                        
                    }
                    
                }

            }
            
        } 
        
    }
    
    public class tabUrls 
    {
        
        public String strObjName {get; set;}
        public String strAPIName {get; set;}
        public String strObjPrefix {get; set;}
        public String strTabUrl {get; set;}
        public String strIsAccessible {get; set;}
        
        public tabUrls(String strObjName, String strAPIName, String strObjPrefix, String strTabUrl, String strIsAccessible) 
        {
            this.strObjName = strObjName;
            this.strAPIName = strAPIName;
            this.strObjPrefix = strObjPrefix;
            this.strTabUrl = strTabUrl;
            this.strIsAccessible = strIsAccessible;
        }
        
    }  

}