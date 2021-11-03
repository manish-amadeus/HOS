/************************************************************************************************************************
Name            : AH_RFCSourceChanges Controller Class
Author          : Sean Harris
Created Date    : 06/04/2018
Last Mod Date   : 06/04/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description		: Controller for AH_RFCSourceChanges VF Page
     			: 
*************************************************************************************************************************/
public class AH_RFCSourceChanges 
{
    
    public NI_Change_Control__c nicc {get; set;}  
    public List<sourceWrapper> lstUserSelections {get; set;} 
    public List<sourceWrapper> lstSelectedSSCs {get; set;} 
    public List<AH_SFDC_Source_Control__c> lstSSCs {get; set;} 
    public String pageSubTitle {get; set;} 
    public String strKeyword {get; set;} 
    public boolean bApexClasses {get; set;}  
    public boolean bApexTriggers {get; set;}
    public boolean bVFPages {get; set;}
    public boolean bVFComponents {get; set;}    
    public boolean bProcessBuilders {get; set;} 
    public boolean bValidationRules {get; set;}
   
    public AH_RFCSourceChanges(ApexPages.StandardController stdController)
    {
        
        pageSubTitle = ''; 
        lstSelectedSSCs = new List<sourceWrapper>();
        
        // IF Id PARAMETER EXISTS 
        if (ApexPages.CurrentPage().getParameters().containsKey('Id')) 
        {
            
            if (!Test.isRunningTest())
            {
                stdController.addFields(new List<String>{'Name', 'Request_Summary__c'});
            }            

            this.nicc = (NI_Change_Control__c)stdController.getRecord();
            pageSubTitle = nicc.Name;
            
            // FILL PREVIOUSLY SELECTED LIST
            for (AH_SFDC_Source_Control__c ssc : [SELECT Id, API_Name__c, Salesforce_Source_Type__c  
                                                  FROM AH_SFDC_Source_Control__c 
                                                  WHERE Id IN (SELECT AH_SFDC_Source_Control__c FROM AH_SFDC_Source_Change__c WHERE NI_Change_Control__c =: nicc.id)])
            {                
                lstSelectedSSCs.add(new sourceWrapper(ssc));
            }
            
            strKeyword = '';
            bApexClasses = true;
            bApexTriggers = false; 
            bVFPages = false;
            bVFComponents = false;
            bProcessBuilders = false;
            bValidationRules = false;
            doSearch();
            
        }
        else
        {
            pageSubTitle = 'ERROR: No NICC Id Param';
        }
        
    }

    public void doSearch() 
    {

        lstUserSelections = new List<sourceWrapper>();
               
        if (!bApexClasses && !bApexTriggers && !bVFPages && !bVFComponents && !bProcessBuilders && !bValidationRules)
        {
            return; 
        }   

        String strKW = '%' + strKeyword + '%';   
        String sql = 'SELECT Id, API_Name__c, Salesforce_Source_Type__c ';
        sql += 'FROM AH_SFDC_Source_Control__c ';
        sql += 'WHERE Salesforce_Source_Type__c IN (';
            
        if (bApexClasses)
        {
            sql += '\'Apex Class\', ';
        }
        if (bApexTriggers)
        {
            sql += '\'Apex Trigger\', ';
        }
        if (bVFPages)
        {
            sql += '\'Visualforce Page\', ';
        }
        if (bVFComponents)
        {
			sql += '\'Visualforce Component\', ';
        }
        if (bProcessBuilders)
        {
            sql += '\'Process Builder\', ';
        }
        if (bValidationRules)
        {
            sql += '\'Validation Rule\', ';
        }
        sql = sql.removeEnd(', ');
        sql += ') ';    

        if ((strKeyword == '') || (strKeyword == null))
        {
            //sql += 'AND API_Name__c LIKE \'a%\' '; 
        }
        else
        {
            sql += 'AND API_Name__c LIKE \'%' + String.escapeSingleQuotes(strKeyword) + '%\' '; 
        }
        
        if (lstSelectedSSCs.size() > 0)
        {
            sql += 'AND Id NOT IN (';
            for (sourceWrapper x : lstSelectedSSCs)
            {
                sql += '\'' + x.ssc.Id + '\', ';
            }
            sql = sql.removeEnd(', ');
            sql += ') '; 
        }
        
        sql += 'ORDER BY API_Name__c ASC LIMIT 50 ';
        
system.debug('sql='+sql);   
        
        lstSSCs = Database.query(sql);

        for (AH_SFDC_Source_Control__c sc : lstSSCs)
        {
            lstUserSelections.add(new sourceWrapper(sc));
        }
   
    }

    public void syncSource()
    {
        AH_SF_SourceSync s = new AH_SF_SourceSync();
        s.invokeSync();
    }
    
    public PageReference saveRecord()
    {

    	PageReference pr = new PageReference('/' + nicc.Id);
        
        List<AH_SFDC_Source_Change__c> lstExisting = new List<AH_SFDC_Source_Change__c>([SELECT Id FROM AH_SFDC_Source_Change__c WHERE NI_Change_Control__c =: nicc.Id]);
        if (lstExisting.size() > 0)
        {
system.debug('deleting references...');            
            database.delete(lstExisting);
        }
        
        List<AH_SFDC_Source_Change__c> lstNew = new List<AH_SFDC_Source_Change__c>();
        
        for (sourceWrapper u : lstSelectedSSCs)
        {
            AH_SFDC_Source_Change__c sc = new AH_SFDC_Source_Change__c();
            sc.NI_Change_Control__c = nicc.id;
            sc.AH_SFDC_Source_Control__c = u.ssc.Id;
            lstNew.add(sc);
        }

        if (lstNew.size() > 0)
        {
            database.insert(lstNew);
        }

        return pr;
        
    }

    public void addSelected()
    {

        for (sourceWrapper sw : lstUserSelections)
        {
            if (sw.isSelected)
            {
                sw.isSelected = false;
                lstSelectedSSCs.add(sw);
            }
        }
        
        doSearch();
        
    } 
    
    public void removeSelected()
    {
        
        Integer j = 0;
        while (j < lstSelectedSSCs.size())
        {
            if (lstSelectedSSCs.get(j).isSelected)
            {
                lstSelectedSSCs.remove(j);
            }
            else
            {
                j++;
            }
        } 
        
        doSearch();
        
    }    
    
    
    // WRAPPER CLASSES
    public class sourceWrapper 
    {
        public AH_SFDC_Source_Control__c ssc {get; set;}
        public Boolean isSelected {get; set;}
        
        public sourceWrapper(AH_SFDC_Source_Control__c s) 
        {
            this.ssc = s;
            this.isSelected = false; 
        }
    }        
    
}