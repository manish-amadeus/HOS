public class NI_SCRUM_Report 
{

    SCRUM_PS__c scrum;

    public NI_SCRUM_Report(ApexPages.StandardController controller) 
    {
        this.scrum = (SCRUM_PS__c)controller.getRecord();
    }

    public List<SCRUM_PS__c> getSCRUMPS()  
    {      
        List<SCRUM_PS__c> scrumPS = [SELECT Id, Name, AmountSort__c, Amount_Text__c, 
            FY01__c, FY02__c, FY03__c, FY04__c, FY05__c, FY06__c, FY07__c, FY08__c, FY09__c, FY10__c, FY11__c, FY12__c, 
            ReportSort__c, Service_Group__c, Grand_Total__c, BackColorIndex__c            
            FROM SCRUM_PS__c 
            ORDER BY ReportSort__c, AmountSort__c]; 
        return scrumPS; 
    } 
    
    public List<SCRUM_PS_Backlog__c> getSCRUMBackLog()  
    {      
        List<SCRUM_PS_Backlog__c> scrumBackLog = [SELECT Id, Name, ReportSort__c, RegionSort__c, 
            Region_Name__c, Service_Group__c, Q_Past__c, Q_Current__c, 
            Q01__c, Q02__c, Q03__c, Q04__c, Q_Future__c, Grand_Total__c, DataRefreshDate__c  
            FROM SCRUM_PS_Backlog__c 
            ORDER BY ReportSort__c]; 
        return scrumBackLog; 
    }
    
    public List<SCRUM_PS__c> getChart()  
    {      
        List<SCRUM_PS__c> scrumChart = [SELECT Id, Name, Service_Group__c, 
            FY01__c, FY02__c, FY03__c, FY04__c, FY05__c, FY06__c, 
            FY07__c, FY08__c, FY09__c, FY10__c, FY11__c, FY12__c                      
            FROM SCRUM_PS__c 
            WHERE Amount_Text__c = 'Actual' AND Service_Group__c != 'GRAND TOTAL' 
            ORDER BY Service_Group__c]; 
        return scrumChart; 
    } 
    

    public static List<ScheduledComparison> getScheduledComparisonData() 
    {
        
        String strCurrGroup = '';
        Decimal dCurrScheduled = 0;
        Decimal dCurrAmount = 0;
        Decimal dCurrForecast = 0;
        
        String strLYGroup = '';        
        Decimal dLYScheduled = 0;
        Decimal dLYAmount = 0;
        Decimal dLYForecast = 0;   
        
        Decimal dCurrScheduledGT = 0;
        Decimal dCurrAmountGT = 0;
        Decimal dCurrForecastGT = 0;       
        Decimal dLYScheduledGT = 0;
        Decimal dLYAmountGT = 0;   
        Decimal dLYForecastGT = 0;
         
        List<ScheduledComparison> dataSDC = new List<ScheduledComparison>();
        
        //Date dCurrent = date.newinstance(2012, 6, 15); 
        Date dCurrent = date.today();
        Date dLastYear = dCurrent.addYears(-1);   
        String strMonth = String.ValueOf(dCurrent.Month());
        
        if (dCurrent.Month() < 10)
        {
            strMonth = '0' + strMonth;
        }

        String strCurrentTP = 'FY-' + String.ValueOf(dCurrent.Year()) + '-' + strMonth;
        String strLastYearTP = 'FY-' + String.ValueOf(dLastYear.Year()) + '-' + strMonth;
        
        List<aggregateResult> curr =           
            [SELECT Service_Group__c, SUM(Scheduled_Amount__c), SUM(Forecast_Amount__c)
            FROM Services_Scrum_Snapshot__c 
            WHERE (Service_Group__c = 'CAD Services' OR 
            Service_Group__c = 'Data Services' OR 
            Service_Group__c = 'Integrations' OR 
            Service_Group__c = 'MeetingMatrix' OR 
            Service_Group__c = 'Project Management' OR 
            Service_Group__c = 'Report Services' OR 
            Service_Group__c = 'Solutions Consulting' OR 
            Service_Group__c = 'Strategic Consulting' OR 
            Service_Group__c = 'Systems Engineering' OR 
            Service_Group__c = 'Training') 
            AND Region_Name__c = 'US' 
            AND Target_Period__c =: strCurrentTP  
            AND Date_of_Pull__c =: dCurrent   
            GROUP BY Service_Group__c 
            ORDER BY Service_Group__c];      
            
        List<aggregateResult> ly =           
            [SELECT Service_Group__c, SUM(Scheduled_Amount__c), SUM(Forecast_Amount__c)
            FROM Services_Scrum_Snapshot__c
            WHERE (Service_Group__c = 'CAD Services' OR 
            Service_Group__c = 'Data Services' OR 
            Service_Group__c = 'Integrations' OR 
            Service_Group__c = 'MeetingMatrix' OR 
            Service_Group__c = 'Project Management' OR 
            Service_Group__c = 'Report Services' OR 
            Service_Group__c = 'Solutions Consulting' OR 
            Service_Group__c = 'Strategic Consulting' OR 
            Service_Group__c = 'Systems Engineering' OR 
            Service_Group__c = 'Training')
            AND Region_Name__c = 'US' 
            AND Target_Period__c =: strLastYearTP
            AND Date_of_Pull__c =: dLastYear  
            GROUP BY Service_Group__c 
            ORDER BY Service_Group__c];              
                
        for (AggregateResult ds : curr)  
        {

            strCurrGroup = '';
            dCurrScheduled = 0;
            dCurrAmount = 0;
            dCurrForecast = 0;
            
            strLYGroup = '';
            dLYScheduled = 0;
            dLYAmount = 0;
            dLYForecast = 0;

            strCurrGroup = (String)ds.get('Service_Group__c');
            dCurrScheduled = (Decimal)ds.get('expr0');
            dCurrAmount = (Decimal)ds.get('expr1');
            
            if (dCurrAmount > 0)
            {           
                dCurrForecast = (dCurrScheduled / dCurrAmount);
            }
            else
            {
                dCurrForecast = 0;
            }         

            for (AggregateResult dsLY : ly)  
            {
            
                strLYGroup = (String)dsLY.get('Service_Group__c');
               
                if (strCurrGroup == strLYGroup)
                { 
                              
                    dLYScheduled = (Decimal)dsLY.get('expr0');
                    dLYAmount = (Decimal)dsLY.get('expr1');

                    if (dLYAmount > 0)
                    {           
                        dLYForecast = (dLYScheduled / dLYAmount);
                    }
                    else
                    {
                        dLYForecast = 0;
                    }
                }  
                             
            }   

            dCurrScheduledGT += dCurrScheduled;
            dCurrAmountGT += dCurrAmount;
            dLYScheduledGT += dLYScheduled;
            dLYAmountGT += dLYAmount;

            dataSDC.add(new ScheduledComparison(strCurrGroup, dCurrScheduled, dCurrAmount, (dCurrForecast.SetScale(4) * 100).SetScale(2), dLYScheduled, dLYAmount, (dLYForecast.SetScale(4) * 100).SetScale(2)));

        }

        if (dCurrAmountGT > 0)
        {           
            dCurrForecastGT = (dCurrScheduledGT / dCurrAmountGT);
        }
        else
        {
            dCurrForecastGT = 0;
        }   

        if (dLYAmountGT > 0)
        {           
            dLYForecastGT = (dLYScheduledGT / dLYAmountGT);
        }
        else
        {
            dLYForecastGT = 0;
        }
                       
        dataSDC.add(new ScheduledComparison('Grand Totals', dCurrScheduledGT, dCurrAmountGT, (dCurrForecastGT.SetScale(4) * 100).SetScale(2), dLYScheduledGT, dLYAmountGT, (dLYForecastGT.SetScale(4) * 100).SetScale(2)));
   
        return dataSDC;
        
    }


    public class ScheduledComparison 
    {
        public String strGroup { get; set; }
        public Decimal dCurrScheduled { get; set; }
        public Decimal dCurrAmount { get; set; }
        public Decimal dCurrForecast { get; set; }
        public Decimal dLYScheduled { get; set; }
        public Decimal dLYAmount { get; set; }
        public Decimal dLYForecast { get; set; }
        
        public ScheduledComparison(String strGroup,
            Decimal dCurrScheduled, Decimal dCurrAmount, Decimal dCurrForecast, 
            Decimal dLYScheduled, Decimal dLYAmount, Decimal dLYForecast 
            ) 
        {
            this.strGroup = strGroup;
            this.dCurrScheduled = dCurrScheduled;
            this.dCurrAmount = dCurrAmount;
            this.dCurrForecast= dCurrForecast;
            this.dLYScheduled = dLYScheduled;
            this.dLYAmount = dLYAmount;
            this.dLYForecast = dLYForecast;
        }
    }
            

// HEADER LABEL FUNCTIONS ==================================

    public string colFY01
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-01';
        }
        set;
    }

    public string colFY02
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-02';
        }
        set;
    }

    public string colFY03
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-03';
        }
        set;
    }

    public string colFY04
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-04';
        }
        set;
    }

    public string colFY05
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-05';
        }
        set;
    }   

    public string colFY06
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-06';
        }
        set;
    }

    public string colFY07
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-07';
        }
        set;
    }

    public string colFY08
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-08';
        }
        set;
    }   

    public string colFY09
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-09';
        }
        set;
    }

    public string colFY10
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-10';
        }
        set;
    }

    public string colFY11
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-11';
        }
        set;
    }

    public string colFY12
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            return 'FY-' + String.ValueOf(CurrentYear) + '-12';
        }
        set;
    }  


    public string colQCurrent
    {
        get 
        {
            Integer CurrentYear = Datetime.Now().Year();
            Integer CurrentMonth = Datetime.Now().Month();
            return 'Q' + String.ValueOf((CurrentMonth / 3) + 1) + ' ' + String.ValueOf(CurrentYear);
        }
        set;
    }  

    public string colQ1
    {
        get 
        {
            Datetime dt = Datetime.Now().addMonths(3);
            Integer CurrentYear = dt.Year();
            Integer CurrentMonth = dt.Month();
            return 'Q' + String.ValueOf((CurrentMonth / 3) + 1) + ' ' + String.ValueOf(CurrentYear);
        }
        set;
    } 

    public string colQ2
    {
        get 
        {
            Datetime dt = Datetime.Now().addMonths(6);
            Integer CurrentYear = dt.Year();
            Integer CurrentMonth = dt.Month();
            return 'Q' + String.ValueOf((CurrentMonth / 3) + 1) + ' ' + String.ValueOf(CurrentYear);
        }
        set;
    } 
    
    public string colQ3
    {
        get 
        {
            Datetime dt = Datetime.Now().addMonths(9);
            Integer CurrentYear = dt.Year();
            Integer CurrentMonth = dt.Month();
            return 'Q' + String.ValueOf((CurrentMonth / 3) + 1) + ' ' + String.ValueOf(CurrentYear);
        }
        set;
    } 
    
    public string colQ4
    {
        get 
        {
            Datetime dt = Datetime.Now().addMonths(12);
            Integer CurrentYear = dt.Year();
            Integer CurrentMonth = dt.Month();
            return 'Q' + String.ValueOf((CurrentMonth / 3) + 1) + ' ' + String.ValueOf(CurrentYear);
        }
        set;
    }         
        
   
// =============================================================================================
// APEX CHARTING CODE
// =============================================================================================        
        
    // Make the chart data available via JavaScript remoting 
    
    @RemoteAction
    public static List<ChartData> getRemoteData() {
        return NI_SCRUM_Report.getSCRUMChartData();
    }

    // The actual chart data; needs to be static to be 
    
    // called by a @RemoteAction method 
    
    public static List<ChartData> getSCRUMChartData() 
    {
    
        List<ChartData> dataSCRUM = new List<ChartData>();        
        
        Decimal data01 = 0;
        Decimal data02 = 0;
        Decimal data03 = 0;
        Decimal data04 = 0;
        Decimal data05 = 0;
        Decimal data06 = 0;
        Decimal data07 = 0;
        Decimal data08 = 0;
        Decimal data09 = 0;
        Decimal data10 = 0;
        
        Boolean bIsFirstRun = true;
        //Date dCurrent = date.newinstance(2012, 6, 15); 
        Date dCurrent = date.today();
        Date dLastYear = dCurrent.addYears(-1);   
        String strMonth = String.ValueOf(dCurrent.Month());
        
        Date dCompare = date.newinstance(2000, 1, 1);
        Date dLYMonthStart = date.newinstance(dLastYear.Year(), dLastYear.Month(), 1);
        Date dLYMonthEnd = dLYMonthStart.addMonths(1);
        
        if (dCurrent.Month() < 10)
        {
            strMonth = '0' + strMonth;
        }

        String strLastYearTP = 'FY-' + String.ValueOf(dLastYear.Year()) + '-' + strMonth;
        
        List<aggregateResult> lym =           
            [SELECT Date_of_Pull__c, Service_Group__c, SUM(Scheduled_Amount__c)
            FROM Services_Scrum_Snapshot__c 
            WHERE (
                Service_Group__c = 'CAD Services' OR 
                Service_Group__c = 'Data Services' OR 
                Service_Group__c = 'Integrations' OR 
                Service_Group__c = 'MeetingMatrix' OR 
                Service_Group__c = 'Project Management' OR 
                Service_Group__c = 'Report Services' OR 
                Service_Group__c = 'Solutions Consulting' OR 
                Service_Group__c = 'Strategic Consulting' OR 
                Service_Group__c = 'Systems Engineering' OR 
                Service_Group__c = 'Training'
            ) 
            AND Region_Name__c = 'US' 
            AND Target_Period__c =: strLastYearTP 
            AND Date_of_Pull__c >=: dLYMonthStart 
            AND Date_of_Pull__c <: dLYMonthEnd 
            GROUP BY Date_of_Pull__c, Service_Group__c 
            ORDER BY Date_of_Pull__c, Service_Group__c];           
        
        for (AggregateResult ds : lym)  
        {
            
            if (bIsFirstRun == true)
            {
                dCompare = (Date)ds.get('Date_of_Pull__c');
                bIsFirstRun = false;
            }
            
            if (dCompare == (Date)ds.get('Date_of_Pull__c'))
            {
                if ((String)ds.get('Service_Group__c') == 'CAD Services')
                {
                    data01 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Data Services')
                {
                    data02 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Integrations')
                {
                    data03 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'MeetingMatrix')
                {
                    data04 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Project Management')
                {
                    data05 = (Decimal)ds.get('expr0');
                }            
                if ((String)ds.get('Service_Group__c') == 'Report Services')
                {
                    data06 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Solutions Consulting')
                {
                    data07 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Strategic Consulting')
                {
                    data08 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Systems Engineering')
                {
                    data09 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Training')
                {
                    data10 = (Decimal)ds.get('expr0');
                }                      
            }
            else
            {    
                // COMMIT RECORD TO LIST
                dataSCRUM.add(new ChartData(String.ValueOf(dCompare.Month()) + '/' + String.ValueOf(dCompare.Day()) + '/' + String.ValueOf(dCompare.Year()), data01, data02, data03, data04, data05, data06, data07, data08, data09, data10));
                dCompare = (Date)ds.get('Date_of_Pull__c');
                
                data01 = 0;
                data02 = 0;
                data03 = 0;
                data04 = 0;
                data05 = 0;
                data06 = 0;
                data07 = 0;
                data08 = 0;
                data09 = 0;
                data10 = 0;
            
                if ((String)ds.get('Service_Group__c') == 'CAD Services')
                {
                    data01 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Data Services')
                {
                    data02 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Integrations')
                {
                    data03 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'MeetingMatrix')
                {
                    data04 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Project Management')
                {
                    data05 = (Decimal)ds.get('expr0');
                }            
                if ((String)ds.get('Service_Group__c') == 'Report Services')
                {
                    data06 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Solutions Consulting')
                {
                    data07 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Strategic Consulting')
                {
                    data08 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Systems Engineering')
                {
                    data09 = (Decimal)ds.get('expr0');
                }
                if ((String)ds.get('Service_Group__c') == 'Training')
                {
                    data10 = (Decimal)ds.get('expr0');
                }                                  
            }
            
        }

        dataSCRUM.add(new ChartData(String.ValueOf(dCompare.Month()) + '/' + String.ValueOf(dCompare.Day()) + '/' + String.ValueOf(dCompare.Year()), data01, data02, data03, data04, data05, data06, data07, data08, data09, data10));
        
        return dataSCRUM;
        
    }
        
    public class ChartData 
    {
        public String strDay { get; set; }
        public Decimal data01 { get; set; }
        public Decimal data02 { get; set; }
        public Decimal data03 { get; set; }
        public Decimal data04 { get; set; }
        public Decimal data05 { get; set; }
        public Decimal data06 { get; set; }
        public Decimal data07 { get; set; }
        public Decimal data08 { get; set; }
        public Decimal data09 { get; set; }
        public Decimal data10 { get; set; }
        
        public ChartData(String strDay,
            Decimal data01, Decimal data02, Decimal data03, 
            Decimal data04, Decimal data05, Decimal data06, 
            Decimal data07, Decimal data08, Decimal data09, Decimal data10
            ) 
        {
            this.strDay = strDay;
            this.data01 = data01;
            this.data02 = data02;
            this.data03 = data03;
            this.data04 = data04;
            this.data05 = data05;
            this.data06 = data06;
            this.data07 = data07;
            this.data08 = data08;
            this.data09 = data09;
            this.data10 = data10;
        }
    }
 
        
        

    
}