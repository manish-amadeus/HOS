/****************************************************************************************
Name            : StatusReportRedirectTestClass Class
Author          : Sean Harris
Created Date    : 04/10/2015
Last Mod Date   : 07/17/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
@isTest (SeeAllData=true)
private class StatusReportFormTestClass 
{
    
    static testMethod void myUnitTest() 
    {    
        
        String strTransactionalSurveyScore;
        String strLastReportDate;
        Date dtLastStatusReportDate;
        Date dtLastMonday;
        Date dtThisMonday;
        Decimal iTest = 0;
        Boolean bSBtns = false;
        
        User uSysAdm = NI_TestClassData.createTestUser(0, 'System Administrator'); 
        uSysAdm.Department = 'Support';
        insert uSysAdm;
        
        User sptMgr = NI_TestClassData.createTestUser(1, 'NI Support Managers'); 
        sptMgr.Department = 'Support';
        insert sptMgr;
        
        User sptTech = NI_TestClassData.createTestUser(2, 'NI Support CSR'); 
        sptTech.Department = 'Support';
        insert sptTech;        
        
        system.runAs(sptMgr)
        {
            
            RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'EMEA TAC A v1' AND isActive = true LIMIT 1];
            StatusReport__c sr = new StatusReport__c(
                
                Associate__c = sptTech.Id, 
                RecordTypeId = rt.Id,
                FinalStatus__c = 'Meets', 
                Score_Final__c = 10, 
                
                Comment01__c = 'test comment', 
                Comment02__c = 'test comment', 
                Comment03__c = 'test comment', 
                Comment04__c = 'test comment', 
                Comment05__c = 'test comment', 
                Comment06__c = 'test comment', 
                Comment07__c = 'test comment', 
                Comment08__c = 'test comment', 
                Comment09__c = 'test comment', 
                Comment10__c = 'test comment', 
                CommentFinal__c = 'test comment', 
                
                Exceeds01__c = false, 
                Exceeds02__c = false, 
                Exceeds03__c = false, 
                Exceeds04__c = false, 
                Exceeds05__c = false, 
                Exceeds06__c = false, 
                Exceeds07__c = false, 
                Exceeds08__c = false, 
                Exceeds09__c = false, 
                Exceeds10__c = false, 
                
                Meets01__c = true, 
                Meets02__c = true, 
                Meets03__c = true, 
                Meets04__c = true, 
                Meets05__c = true, 
                Meets06__c = true, 
                Meets07__c = true, 
                Meets08__c = true, 
                Meets09__c = true, 
                Meets10__c = true, 
                
                Missed01__c = false, 
                Missed02__c = false, 
                Missed03__c = false, 
                Missed04__c = false, 
                Missed05__c = false, 
                Missed06__c = false, 
                Missed07__c = false, 
                Missed08__c = false, 
                Missed09__c = false, 
                Missed10__c = false, 
                
                Score01__c = 1, 
                Score02__c = 1, 
                Score03__c = 1, 
                Score04__c = 1, 
                Score05__c = 1, 
                Score06__c = 1, 
                Score07__c = 1, 
                Score08__c = 1, 
                Score09__c = 1, 
                Score10__c = 1, 
                
                Value01__c = 'test value', 
                Value02__c = 'test value', 
                Value03__c = 'test value', 
                Value04__c = 'test value', 
                Value05__c = 'test value', 
                Value06__c = 'test value', 
                Value07__c = 'test value', 
                Value08__c = 'test value', 
                Value09__c = 'test value', 
                Value10__c = 'test value' 
                
            );                                                                       
            
            insert sr;    
            
            // PAGE REFERENCE
            PageReference srTESTv1 = Page.SReportEMEATACAv1;
            Test.setCurrentPage(srTESTv1);
            srTESTv1.getParameters().put('RecordType', rt.id);
            
            // CONTROLLER 
            StatusReportForm ctrl = new StatusReportForm(new ApexPages.StandardController(sr));        
            
            //
            ctrl.iScore1 = 1; 
            ctrl.iScore2 = 1; 
            ctrl.iScore3 = 1; 
            ctrl.iScore4 = 1; 
            ctrl.iScore5 = 1; 
            ctrl.iScore6 = 1; 
            ctrl.iScore7 = 1; 
            ctrl.iScore8 = 1; 
            ctrl.iScore9 = 1; 
            ctrl.iScore10 = 1; 
            ctrl.iScoreFinal = 1;
            //strTransactionalSurveyScore = ctrl.TransactionalSurveyScore;
            strLastReportDate = ctrl.LastReportDate;
            //dtLastStatusReportDate = ctrl.LastStatusReportDate();
            dtLastMonday = ctrl.LastMonday();
            dtThisMonday = ctrl.ThisMonday(); 
            iTest = ctrl.roundNumber(10, 0);
            iTest = ctrl.roundNumber(null, 0);
            
            ctrl.initForm();
            //ctrl.ShiftTime();
            //ctrl.SurveyScore();
            
            // SET ALL CHECKBOXES MEETS
            sr.Exceeds01__c = false; 
            sr.Exceeds02__c = false; 
            sr.Exceeds03__c = false; 
            sr.Exceeds04__c = false; 
            sr.Exceeds05__c = false; 
            sr.Exceeds06__c = false; 
            sr.Exceeds07__c = false; 
            sr.Exceeds08__c = false; 
            sr.Exceeds09__c = false; 
            sr.Exceeds10__c = false; 
            
            sr.Meets01__c = true; 
            sr.Meets02__c = true; 
            sr.Meets03__c = true; 
            sr.Meets04__c = true; 
            sr.Meets05__c = true; 
            sr.Meets06__c = true; 
            sr.Meets07__c = true; 
            sr.Meets08__c = true; 
            sr.Meets09__c = true; 
            sr.Meets10__c = true;         
            
            sr.Missed01__c = false; 
            sr.Missed02__c = false; 
            sr.Missed03__c = false; 
            sr.Missed04__c = false; 
            sr.Missed05__c = false; 
            sr.Missed06__c = false; 
            sr.Missed07__c = false; 
            sr.Missed08__c = false; 
            sr.Missed09__c = false; 
            sr.Missed10__c = false; 
            
            update sr;
            
            // CHECKBOXES WHEN ALL MEETS ARE CHECKED      
            ctrl.S1MissedCheckbox();
            ctrl.S1MeetsCheckbox();
            ctrl.S1ExceedsCheckbox();
            
            ctrl.S2MissedCheckbox();
            ctrl.S2MeetsCheckbox();
            ctrl.S2ExceedsCheckbox();
            
            ctrl.S3MissedCheckbox();
            ctrl.S3MeetsCheckbox();
            ctrl.S3ExceedsCheckbox();
            
            ctrl.S4MissedCheckbox();
            ctrl.S4MeetsCheckbox();
            ctrl.S4ExceedsCheckbox();
            
            ctrl.S5MissedCheckbox();
            ctrl.S5MeetsCheckbox();
            ctrl.S5ExceedsCheckbox();
            
            ctrl.S6MissedCheckbox();
            ctrl.S6MeetsCheckbox();
            ctrl.S6ExceedsCheckbox();
            
            ctrl.S7MissedCheckbox();
            ctrl.S7MeetsCheckbox();
            ctrl.S7ExceedsCheckbox();
            
            ctrl.S8MissedCheckbox();
            ctrl.S8MeetsCheckbox();
            ctrl.S8ExceedsCheckbox();
            
            ctrl.S9MissedCheckbox();
            ctrl.S9MeetsCheckbox();
            ctrl.S9ExceedsCheckbox();
            
            ctrl.S10MissedCheckbox();
            ctrl.S10MeetsCheckbox();
            ctrl.S10ExceedsCheckbox();
            
            // SET ALL CHECKBOXES EXCEEDS        
            sr.Exceeds01__c = true; 
            sr.Exceeds02__c = true; 
            sr.Exceeds03__c = true; 
            sr.Exceeds04__c = true; 
            sr.Exceeds05__c = true; 
            sr.Exceeds06__c = true; 
            sr.Exceeds07__c = true; 
            sr.Exceeds08__c = true; 
            sr.Exceeds09__c = true; 
            sr.Exceeds10__c = true; 
            
            sr.Meets01__c = false; 
            sr.Meets02__c = false; 
            sr.Meets03__c = false; 
            sr.Meets04__c = false; 
            sr.Meets05__c = false; 
            sr.Meets06__c = false; 
            sr.Meets07__c = false; 
            sr.Meets08__c = false; 
            sr.Meets09__c = false; 
            sr.Meets10__c = false;         
            
            sr.Missed01__c = false; 
            sr.Missed02__c = false; 
            sr.Missed03__c = false; 
            sr.Missed04__c = false; 
            sr.Missed05__c = false; 
            sr.Missed06__c = false; 
            sr.Missed07__c = false; 
            sr.Missed08__c = false; 
            sr.Missed09__c = false; 
            sr.Missed10__c = false; 
            
            update sr;
            
            // CHECKBOXES WHEN ALL EXCEEDS ARE CHECKED          
            ctrl.S1MissedCheckbox();
            ctrl.S1MeetsCheckbox();
            ctrl.S1ExceedsCheckbox();
            
            ctrl.S2MissedCheckbox();
            ctrl.S2MeetsCheckbox();
            ctrl.S2ExceedsCheckbox();
            
            ctrl.S3MissedCheckbox();
            ctrl.S3MeetsCheckbox();
            ctrl.S3ExceedsCheckbox();
            
            ctrl.S4MissedCheckbox();
            ctrl.S4MeetsCheckbox();
            ctrl.S4ExceedsCheckbox();
            
            ctrl.S5MissedCheckbox();
            ctrl.S5MeetsCheckbox();
            ctrl.S5ExceedsCheckbox();
            
            ctrl.S6MissedCheckbox();
            ctrl.S6MeetsCheckbox();
            ctrl.S6ExceedsCheckbox();
            
            ctrl.S7MissedCheckbox();
            ctrl.S7MeetsCheckbox();
            ctrl.S7ExceedsCheckbox();
            
            ctrl.S8MissedCheckbox();
            ctrl.S8MeetsCheckbox();
            ctrl.S8ExceedsCheckbox();
            
            ctrl.S9MissedCheckbox();
            ctrl.S9MeetsCheckbox();
            ctrl.S9ExceedsCheckbox();
            
            ctrl.S10MissedCheckbox();
            ctrl.S10MeetsCheckbox();
            ctrl.S10ExceedsCheckbox();        
            
            // SET ALL CHECKBOXES MISSED
            sr.Exceeds01__c = false; 
            sr.Exceeds02__c = false; 
            sr.Exceeds03__c = false; 
            sr.Exceeds04__c = false; 
            sr.Exceeds05__c = false; 
            sr.Exceeds06__c = false; 
            sr.Exceeds07__c = false; 
            sr.Exceeds08__c = false; 
            sr.Exceeds09__c = false; 
            sr.Exceeds10__c = false; 
            
            sr.Meets01__c = false; 
            sr.Meets02__c = false; 
            sr.Meets03__c = false; 
            sr.Meets04__c = false; 
            sr.Meets05__c = false; 
            sr.Meets06__c = false; 
            sr.Meets07__c = false; 
            sr.Meets08__c = false; 
            sr.Meets09__c = false; 
            sr.Meets10__c = false;  
            
            sr.Missed01__c = true; 
            sr.Missed02__c = true; 
            sr.Missed03__c = true; 
            sr.Missed04__c = true; 
            sr.Missed05__c = true; 
            sr.Missed06__c = true; 
            sr.Missed07__c = true; 
            sr.Missed08__c = true; 
            sr.Missed09__c = true; 
            sr.Missed10__c = true;         
            
            update sr;
            
            // CHECKBOXES WHEN ALL MISSED ARE CHECKED         
            ctrl.S1MissedCheckbox();
            ctrl.S1MeetsCheckbox();
            ctrl.S1ExceedsCheckbox();
            
            ctrl.S2MissedCheckbox();
            ctrl.S2MeetsCheckbox();
            ctrl.S2ExceedsCheckbox();
            
            ctrl.S3MissedCheckbox();
            ctrl.S3MeetsCheckbox();
            ctrl.S3ExceedsCheckbox();
            
            ctrl.S4MissedCheckbox();
            ctrl.S4MeetsCheckbox();
            ctrl.S4ExceedsCheckbox();
            
            ctrl.S5MissedCheckbox();
            ctrl.S5MeetsCheckbox();
            ctrl.S5ExceedsCheckbox();
            
            ctrl.S6MissedCheckbox();
            ctrl.S6MeetsCheckbox();
            ctrl.S6ExceedsCheckbox();
            
            ctrl.S7MissedCheckbox();
            ctrl.S7MeetsCheckbox();
            ctrl.S7ExceedsCheckbox();
            
            ctrl.S8MissedCheckbox();
            ctrl.S8MeetsCheckbox();
            ctrl.S8ExceedsCheckbox();
            
            ctrl.S9MissedCheckbox();
            ctrl.S9MeetsCheckbox();
            ctrl.S9ExceedsCheckbox();
            
            ctrl.S10MissedCheckbox();
            ctrl.S10MeetsCheckbox();
            ctrl.S10ExceedsCheckbox();                
            
            
            
            // ========================================================================================================================================
            //  EMEA TAC A v1	EMEA TAC Analyst Status Report - Version 1
            // ========================================================================================================================================
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'EMEA TAC A v1' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            update sr;
            PageReference srEMEATACAv1 = Page.SReportEMEATACAv1;
            Test.setCurrentPage(srEMEATACAv1);
            srEMEATACAv1.getParameters().put('RecordType', rt.id);
            StatusReportForm ctrlEMEAAv1 = new StatusReportForm(new ApexPages.StandardController(sr));   
            ctrlEMEAAv1.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrlEMEAAv1.GetScore(j, 'Meets');
                ctrlEMEAAv1.GetScore(j, 'Exceeds');
            }
            
            // ========================================================================================================================================
            //  EMEA TAC A v2	EMEA TAC Analyst Status Report - Version 2
            // ========================================================================================================================================
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'EMEA TAC A v2' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;
            PageReference srEMEATACAv2 = Page.SReportEMEATACAv2;
            Test.setCurrentPage(srEMEATACAv2);
            srEMEATACAv2.getParameters().put('RecordType', rt.id);
            StatusReportForm ctrlEMEAAv2 = new StatusReportForm(new ApexPages.StandardController(sr));   
            ctrlEMEAAv2.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrlEMEAAv2.GetScore(j, 'Meets');
                ctrlEMEAAv2.GetScore(j, 'Exceeds');
            }            
            
            // ========================================================================================================================================
            //  EMEA TAC S v1	EMEA TAC Specialist Status Report - Version 1 
            // ========================================================================================================================================
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'EMEA TAC S v1' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;
            PageReference srEMEATACSv1 = Page.SReportEMEATACSv1;
            Test.setCurrentPage(srEMEATACSv1);
            srEMEATACSv1.getParameters().put('RecordType', rt.id);
            StatusReportForm ctrlEMEASv1 = new StatusReportForm(new ApexPages.StandardController(sr));   
            ctrlEMEASv1.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrlEMEASv1.GetScore(j, 'Meets');
                ctrlEMEASv1.GetScore(j, 'Exceeds');
            }
            
            // ========================================================================================================================================
            //  US TAC A v1	US TAC Analyst Status Report - Version 1
            // ========================================================================================================================================
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US TAC A v1' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;                
            PageReference srUSTACAv1 = Page.SReportUSTACAv1;
            Test.setCurrentPage(srUSTACAv1);
            srUSTACAv1.getParameters().put('RecordType', rt.id); 
            StatusReportForm ctrlUSTACAv1 = new StatusReportForm(new ApexPages.StandardController(sr));
            ctrlUSTACAv1.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrlUSTACAv1.GetScore(j, 'Meets');
                ctrlUSTACAv1.GetScore(j, 'Exceeds');
            }        
            
            // ========================================================================================================================================
            //  US TAC S v1	US TAC Specialist Status Report - Version 1
            // ========================================================================================================================================      
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US TAC S v1' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;  
            PageReference srUSTACSv1 = Page.SReportUSTACSv1;
            Test.setCurrentPage(srUSTACSv1);
            srUSTACSv1.getParameters().put('RecordType', rt.id); 
            StatusReportForm ctrlUSTACSv1 = new StatusReportForm(new ApexPages.StandardController(sr));        
            ctrlUSTACSv1.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrlUSTACSv1.GetScore(j, 'Meets');
                ctrlUSTACSv1.GetScore(j, 'Exceeds');
            }        
            
            // ========================================================================================================================================
            //  US BRT v1	US BRT Status Report - Version 1
            // ========================================================================================================================================       
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US BRT v1' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;        
            PageReference srUSBRTv1 = Page.SReportUSBRTv1;
            Test.setCurrentPage(srUSBRTv1);
            srUSBRTv1.getParameters().put('RecordType', rt.id);
            StatusReportForm ctrlUSBRTv1 = new StatusReportForm(new ApexPages.StandardController(sr));         
            ctrlUSBRTv1.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrlUSBRTv1.GetScore(j, 'Meets');
                ctrlUSBRTv1.GetScore(j, 'Exceeds');
            }        
            
            // ========================================================================================================================================
            //  PSS v1	PSS Status Report - Version 1
            // ========================================================================================================================================
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'PSS v1' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;
            PageReference srPSSv1 = Page.SReportPSSv1;
            Test.setCurrentPage(srPSSv1);
            srPSSv1.getParameters().put('RecordType', rt.id);
            StatusReportForm ctrlPSSv1 = new StatusReportForm(new ApexPages.StandardController(sr));         
            ctrlPSSv1.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrlPSSv1.GetScore(j, 'Meets');
                ctrlPSSv1.GetScore(j, 'Exceeds');
            }
            
            // ========================================================================================================================================
            //  US INT v1	US Integrations Status Report - Version 1
            // ========================================================================================================================================
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US INT v1' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;
            PageReference srUSINTv1 = Page.SReportUSINTv1;
            Test.setCurrentPage(srUSINTv1);
            srUSINTv1.getParameters().put('RecordType', rt.id);
            StatusReportForm ctrlUSINTv1 = new StatusReportForm(new ApexPages.StandardController(sr));         
            ctrlUSINTv1.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrlUSINTv1.GetScore(j, 'Meets');
                ctrlUSINTv1.GetScore(j, 'Exceeds');
            }
            
            // ========================================================================================================================================
            //  US TAC A v2		US TAC Analyst Status Report - Version 2
            // ========================================================================================================================================
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US TAC A v2' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;
            PageReference sr_US_TAC_A_v2 = Page.SReportUSTACAv2;
            Test.setCurrentPage(sr_US_TAC_A_v2);
            sr_US_TAC_A_v2.getParameters().put('RecordType', rt.id);
            StatusReportForm ctrl_US_TAC_A_v2 = new StatusReportForm(new ApexPages.StandardController(sr));         
            ctrl_US_TAC_A_v2.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrl_US_TAC_A_v2.GetScore(j, 'Meets');
                ctrl_US_TAC_A_v2.GetScore(j, 'Exceeds');
            }        
            
            // ========================================================================================================================================
            //  US TAC Senior A v1	US TAC Senior Analyst - Version 1 
            // ========================================================================================================================================
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US TAC Senior A v1' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;
            PageReference sr_US_TAC_Senior_A_v1 = Page.SReportUSTACSeniorAv1;
            Test.setCurrentPage(sr_US_TAC_Senior_A_v1);
            sr_US_TAC_Senior_A_v1.getParameters().put('RecordType', rt.id);
            StatusReportForm ctrl_US_TAC_Senior_A_v1 = new StatusReportForm(new ApexPages.StandardController(sr));         
            ctrl_US_TAC_Senior_A_v1.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrl_US_TAC_Senior_A_v1.GetScore(j, 'Meets');
                ctrl_US_TAC_Senior_A_v1.GetScore(j, 'Exceeds');
            }   
            
            // ========================================================================================================================================
            //  US TAC Lead A v1	US TAC Lead Analyst - Version 1
            // ========================================================================================================================================
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US TAC Lead A v1' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;
            PageReference sr_US_TAC_Lead_A_v1 = Page.SReportUSLeadAv1;
            Test.setCurrentPage(sr_US_TAC_Lead_A_v1);
            sr_US_TAC_Lead_A_v1.getParameters().put('RecordType', rt.id);
            StatusReportForm ctrl_US_TAC_Lead_A_v1 = new StatusReportForm(new ApexPages.StandardController(sr));         
            ctrl_US_TAC_Lead_A_v1.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrl_US_TAC_Lead_A_v1.GetScore(j, 'Meets');
                ctrl_US_TAC_Lead_A_v1.GetScore(j, 'Exceeds');
            }           
            
            // ========================================================================================================================================
            //  PMS Standard v1		PMS Standard - Version 2
            // ========================================================================================================================================
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'PMS Standard v1' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;
            PageReference sr_PMSStandardv1 = Page.SReportUSLeadAv2;
            Test.setCurrentPage(sr_PMSStandardv1);
            sr_PMSStandardv1.getParameters().put('RecordType', rt.id);
            StatusReportForm ctrl_PMSStandardv1 = new StatusReportForm(new ApexPages.StandardController(sr));         
            ctrl_PMSStandardv1.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrl_PMSStandardv1.GetScore(j, 'Meets');
                ctrl_PMSStandardv1.GetScore(j, 'Exceeds');
            }  
            
            // ========================================================================================================================================
            //  PMS Technical v1	PMS Technical Status Report - Version 1
            // ========================================================================================================================================
            rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'PMS Technical v1' AND isActive = true LIMIT 1];
            sr.RecordTypeId = rt.Id;
            Update sr;
            PageReference srPMSTechnicalv1 = Page.SReportPMSTechnicalv1;
            Test.setCurrentPage(srPMSTechnicalv1);
            srPMSTechnicalv1.getParameters().put('RecordType', rt.id);
            StatusReportForm ctrlPMSTechnicalv1 = new StatusReportForm(new ApexPages.StandardController(sr));   
            ctrlPMSTechnicalv1.SummerizeScores();
            
            for (Integer j = 1; j < 11; j++)
            {
                ctrlPMSTechnicalv1.GetScore(j, 'Meets');
                ctrlPMSTechnicalv1.GetScore(j, 'Exceeds');
            }            
            
            sr.Score01__c = 100; 
            sr.Score02__c = 100; 
            sr.Score03__c = 100; 
            sr.Score04__c = 100; 
            sr.Score05__c = 100; 
            sr.Score06__c = 100; 
            sr.Score07__c = 100; 
            sr.Score08__c = 100; 
            sr.Score09__c = 100; 
            sr.Score10__c = 100; 
            
            Update sr;
            ctrl.SummerizeScores();
            
            ctrl.Send();
            sr.Associate__c = null;
            
            // TEST CheckForNoChecks                
            sr.Exceeds01__c = false; 
            sr.Exceeds02__c = false; 
            sr.Exceeds03__c = false; 
            sr.Exceeds04__c = false; 
            sr.Exceeds05__c = false; 
            sr.Exceeds06__c = false; 
            sr.Exceeds07__c = false; 
            sr.Exceeds08__c = false; 
            sr.Exceeds09__c = false; 
            sr.Exceeds10__c = false; 
            
            sr.Meets01__c = false; 
            sr.Meets02__c = false; 
            sr.Meets03__c = false; 
            sr.Meets04__c = false; 
            sr.Meets05__c = false; 
            sr.Meets06__c = false; 
            sr.Meets07__c = false; 
            sr.Meets08__c = false; 
            sr.Meets09__c = false; 
            sr.Meets10__c = false;  
            
            sr.Missed01__c = false; 
            sr.Missed02__c = false; 
            sr.Missed03__c = false; 
            sr.Missed04__c = false; 
            sr.Missed05__c = false; 
            sr.Missed06__c = false; 
            sr.Missed07__c = false; 
            sr.Missed08__c = false; 
            sr.Missed09__c = false; 
            sr.Missed10__c = false;  
            
            update sr;
            ctrl.Send();        
            ctrl.CheckForNoChecks();
            
            PageReference pr2 = ctrl.selectCase();
            
            bSBtns = ctrl.ShowButtons;
            
        }
        
    }
    
}