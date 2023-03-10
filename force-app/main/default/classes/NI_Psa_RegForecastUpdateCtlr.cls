/****************************************************************************************
Name            : NI_Psa_RegForecastUpdateCtlr Class
Author          : Stuart Emery
Created Date    : 1/10/2014
Last Mod Date   : 9/18/2018
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : NICC-009265
Description     : Controller for the NI_Psa_RegionForecastUpdate Visualforce page
: The NI_Psa_RegionForecastUpdate Visualforce page is used by the 
: the Project Office to mass update Financialforce - PSA Forecasts
: by Region              
******************************************************************************************/


public with sharing class NI_Psa_RegForecastUpdateCtlr {
    
    private pse__Region__c r;
    
    Id id = System.currentPageReference().getParameters().get('id');
    
    //LIST TO HOLD THE FORECAST RECORDS  
    public List<pse__Forecast__c> lstFcast {get; set;}
    
    // TO CATCH THE FILTER VALUES
    public pse__Forecast__c forecast { get; set; }
    
    //STRING TO HOLD THE START DATE OF THE CURRENT TIME PERIOD RELATED TO THE FORECAST RECORD 
    public String startDate {get; set;}
    
    //STRING TO HOLD THE END DATE OF THE CURRENT TIME PERIOD RELATED TO THE FORECAST RECORD  
    public String endDate {get; set;}
    
    //USED TO CONDITIONALLY RENDER THE CANCEL BUTTON  
    public Boolean bShowCancel {get; set;}
    
    //USED TO CONDITIONALLY RENDER THE SAVE BUTTON  
    public Boolean bShowSave {get; set;}
    
    //USED TO CONDITIONALLY RENDER THE CLOSE BUTTON  
    public Boolean bShowClose {get; set;}
    
    //USED TO ENABLE OR DISABLE THE CANCEL CHECKBOX ON THE VF PAGE  
    public Boolean bDisabled {get; set;}
    
    //USED TO CONDITIONALLY RENDER THE searchPanelContainer OUTPUTPANEL  
    public Boolean showSearch {get; set;}         
       
    public NI_Psa_RegForecastUpdateCtlr(ApexPages.StandardController stdController)
    {                      
        
        this.r = (pse__Region__c)stdController.getRecord();
        forecast = new pse__Forecast__c ();
        //CALL THE DISABLELISTEDIT METHOD  
        disableListEdit();     
    }
    
    //DISABLE EDIT MODE  
    public void disableListEdit()  
    {
        bDisabled = true;
        showSearch = true;
        getForecasts();      
    }
    
    //ENABLE EDIT MODE  
    public void EnableListEdit()
    {
        bDisabled = false;
        showSearch = false;
        getForecasts();        
    }
    
    //QUERY TO RETURN A LIST OF FORECAST RECORDS
    public List<pse__Forecast__c> getForecasts() 
    {
        bShowCancel = false;
        bShowSave = false;
        bShowClose = true;
        Date dt = Date.TODAY();
        Date stDate;
        Date enDate;
        
        if(startDate == null)
        {
            stDate = Date.newInstance(dt.year(), 01, 01);
            startDate = stDate.format();
        } 
        else {
            List<String> parts = startDate.split('\\/');
			stDate = Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[0]), Integer.valueOf(parts[1]));
        }
        
        if(endDate == null)
        {
            enDate = Date.newInstance(dt.year(), 12, 31);
            endDate = enDate.format();
        }  
        else {
            List<String> parts = endDate.split('\\/');
			enDate = Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[0]), Integer.valueOf(parts[1]));
        }
        
        System.debug('ID : '+ id);  
        system.debug('Region :' + forecast.pse__Region__c);
        system.debug('Practice :' + forecast.pse__Practice__c);
        system.debug('Group :' + forecast.pse__Group__c);
        
        lstFcast = new List<pse__Forecast__c>();
        
        // ADDED BY BHULESHWAR ON 09/18/2018
        String  forcastQuery =  'SELECT pse__Region__r.name,'+ 
            'pse__Practice__r.name,'+
            'Name,'+
            'pse__Plan__c, ' +  
            'pse__Entered_Forecast__c,'+
            'pse__Region__c, '+
            'pse__Previous_Period_Forecast__c,'+
            'pse__Override_Commit__c,' +
            'pse__Override_Upside__c,' +
            'pse__Override_Downside__c,' +
            'pse__Time_Period__r.Name,' +
            'pse__Group__c,pse__Practice__c ' +
            'FROM pse__Forecast__c ' +
            'WHERE '+
            'pse__Time_Period__r.pse__Start_Date__c >=: stDate ' +
            'AND pse__Time_Period__r.pse__End_Date__c <=: enDate ';
            
        if(forecast.pse__Region__c == Null && id != NULL)
        {
            forcastQuery += ' AND pse__Region__c =: id ';
		}
        else 
            if(forecast.pse__Region__c != Null )
        {
            forcastQuery += 'AND pse__Region__c  = \''+forecast.pse__Region__c +'\'';
        }
        
        if(forecast.pse__Practice__c != Null)
        {
            forcastQuery += 'AND pse__Practice__c = \''+forecast.pse__Practice__c +'\'';  
        }
        if(forecast.pse__Group__c != Null)  
        {
            forcastQuery += 'AND pse__Group__c =\''+forecast.pse__Group__c +'\''; 
        }
        
        forcastQuery +=' ORDER BY pse__Practice__r.name,pse__Time_Period__r.Name ASC ';
        
        system.debug('Forcast query :' + forcastQuery);
        
        try
        {
            lstFcast = Database.query(forcastQuery);
        }
        catch (Exception ex)
        {
            system.debug('Error Type: ' + ex.getTypeName() + ', \nCause: ' + ex.getCause() + ', \nLine Number: ' + ex.getLineNumber() + ', \nError Message: ' + ex.getMessage() + '\n'+ex);
        }  
        
        system.debug(' *** NI_Psa_RegForecastUpdateCtlr - getForecasts - lstFcast = ' + lstFcast);  
        
        return lstFcast;
    }
    
    //CUSTOME SAVE METHOD
    public PageReference save() {
        
        bShowCancel = false;
        bShowSave = false;
        bShowClose = true;
        showSearch = true;   
        
        //USE TRY CATCH METHOD TO UPDATE ALL OF THE FORECAT RECORDS
        Try
        {
            Update lstFcast;
        } 
        catch (Exception e) 
        {   
            System.debug(e.getMessage());
            ApexPages.addMessages(e); //DISPLAY THE ERROR MESSAGE ON THE VF PAGE
        }
        
        lstFcast = null; //SET THE LIST TO NULL SO A NEW LIST IS CREATED
        disableListEdit(); //CALL THE disableListEdit METHOD WHICH CALLS THE getForecasts METHOD AND DISABLED EDIT MODE
        
        return null;
    }
    
    public PageReference search() {
        
        getForecasts();
        return null;
    }                                      
    
}