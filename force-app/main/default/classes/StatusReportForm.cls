/****************************************************************************************
Name            : StatusReportForm Class
Author          : Sean Harris
Created Date    : 04/10/2015
Last Mod Date   : 04/10/2015
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
public with sharing class StatusReportForm 
{
    
    public boolean displayHelperReportLink {get; set;}
    public string strAssociateID {get; set;}
    public Integer OverdueCasePercent {get; set;}
    private StatusReport__c sr;
    public string strRecordTypeName {get; set;}   
    public Decimal iScore1, iScore2, iScore3, iScore4, iScore5, iScore6, iScore7, iScore8, iScore9, iScore10, iScoreFinal;
    public List<Case> userCases {get; set;}
    public String CaseId {get; set;}
    
    public Integer iScoreLabel1 {get; set;}
    public Integer iScoreLabel2 {get; set;}
    public Integer iScoreLabel3 {get; set;}
    public Integer iScoreLabel4 {get; set;}
    public Integer iScoreLabel5 {get; set;}
    public Integer iScoreLabel6 {get; set;}
    public String baseURL {get; set;}
    
    public String LastReportDate 
    {
        get 
        {
            Date dt = LastStatusReportDate();
            return String.valueOf(dt);
        } 
        set;
    }  
    
    public StatusReportForm(ApexPages.StandardController controller) 
    {
        
        baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        baseURL = baseURL.replace('https://c.','');
        baseURL = baseURL.replace('https://','');
        baseURL = baseURL.replace('.salesforce.com','');
        baseURL = baseURL.replace('.visual.force.com','');
        
        baseURL = 'https://' + baseURL + '.salesforce.com/img/icon/custom51_100/books16.png';
        system.debug('base URL : '+baseURL);
        
        this.sr = (StatusReport__c)controller.getRecord();
        if (ApexPages.CurrentPage().getParameters().containsKey('RecordType')) 
        {
            sr.RecordTypeId = ApexPages.CurrentPage().getParameters().get('RecordType');
            RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Id = :sr.RecordTypeId];
            strRecordTypeName = rt.Name;            
        }
        else
        {
            RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Id = :sr.RecordTypeId];
            strRecordTypeName = rt.Name;                  
        }
        
        fetchScoreLabels();
        
    }
    
    public void initForm() 
    {
        
        displayUserCases();
        displayHelperReportLink = true;
        
        sr.Score01__c = 0;
        sr.Score02__c = 0;
        sr.Score03__c = 0;
        sr.Score04__c = 0;
        sr.Score05__c = 0;
        sr.Score06__c = 0;
        sr.Score07__c = 0;
        sr.Score08__c = 0;
        sr.Score09__c = 0;
        sr.Score10__c = 0; 
        
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
        
    }
    
    public Date LastStatusReportDate()
    {
        Date rtDate = Date.today();
        if (sr.Associate__c != null)
        {
            User u = [SELECT LastStatusReportDate__c FROM User WHERE Id = :sr.Associate__c];
            if (u.LastStatusReportDate__c != null)
            {
                rtDate = u.LastStatusReportDate__c;
            }
        }
        return rtDate;
    }
    
    public void displayUserCases() 
    {
        
        userCases = new List<Case>();
        
        if (sr.Associate__c != null) 
        { 
            system.debug('entering case loop...');            
            for (Case cs : [SELECT Id, CaseNumber, Subject, CreatedDate, ClosedDate 
                            FROM Case 
                            WHERE OwnerId = :sr.Associate__c 
                            AND ClosedDate >: LastStatusReportDate() 
                            ORDER BY CreatedDate DESC 
                            LIMIT 100]) 
            {
                userCases.add(cs);
            } 	 	
        }
        system.debug('found ' + userCases.size() + ' cases');          
    }       
    
    public PageReference selectCase() 
    {
        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + CaseId;
        PageReference CasePage = new PageReference(strUrl);
        CasePage.setRedirect(true);
        return CasePage;       
    }    
    
    public void SummerizeScores() 
    {
        
        iScore1 = 0;
        iScore2 = 0;
        iScore3 = 0;
        iScore4 = 0;
        iScore5 = 0;
        iScore6 = 0;
        iScore7 = 0;
        iScore8 = 0;
        iScore9 = 0;
        iScore10 = 0;
        
        if (sr.Score01__c != null)
        {
            iScore1 = sr.Score01__c;
        }
        if (sr.Score02__c != null)
        {
            iScore2 = sr.Score02__c;
        }
        if (sr.Score03__c != null)
        {
            iScore3 = sr.Score03__c;
        }
        if (sr.Score04__c != null)
        {
            iScore4 = sr.Score04__c;
        }
        if (sr.Score05__c != null)
        {
            iScore5 = sr.Score05__c;
        }
        if (sr.Score06__c != null)
        {
            iScore6 = sr.Score06__c;
        }
        if (sr.Score07__c != null)
        {
            iScore7 = sr.Score07__c;
        }
        if (sr.Score08__c != null)
        {
            iScore8 = sr.Score08__c;
        }
        if (sr.Score09__c != null)
        {
            iScore9 = sr.Score09__c;
        }
        if (sr.Score10__c != null)
        {
            iScore10 = sr.Score10__c;
        }
        
        iScoreFinal = (iScore1 + iScore2 + iScore3 + iScore4 + iScore5 + iScore6 + iScore7 + iScore8 + iScore9 + iScore10);        
        sr.Score_Final__c = iScoreFinal;
        
        Integer iFormNeeds = 0;
        Integer iFormMeets = 0;
        Integer iFormExceeds = 0;
        boolean bUseCompanyScoring = false;
        
        //RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Id = :sr.RecordTypeId];
        
        // SET FINAL SCORE VARIABLES 
        if (strRecordTypeName == 'EMEA TAC A v1')
        {
            iFormMeets = 60;
            iFormExceeds = 80;
        }
        
        if (strRecordTypeName == 'EMEA TAC A v2')
        {
            SptStatusRptsScores__c sssEMEATACA = SptStatusRptsScores__c.getValues('EMEA TAC A');
            iFormNeeds = (integer)sssEMEATACA.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssEMEATACA.DemonstratesMin__c;
            iFormExceeds = (integer)sssEMEATACA.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }
        
        if (strRecordTypeName == 'EMEA TAC S v1')
        {
            iFormMeets = 55;
            iFormExceeds = 60;
        }
        
        if (strRecordTypeName == 'US TAC Senior A v1')
        {        
            SptStatusRptsScores__c sssUSTACSeniorA = SptStatusRptsScores__c.getValues('US TAC Senior A');
            iFormNeeds = (integer)sssUSTACSeniorA.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssUSTACSeniorA.DemonstratesMin__c;
            iFormExceeds = (integer)sssUSTACSeniorA.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }
        
        if (strRecordTypeName == 'US TAC Lead A v1')
        {        
            SptStatusRptsScores__c sssUSTACLeadA = SptStatusRptsScores__c.getValues('US TAC Lead A');
            iFormNeeds = (integer)sssUSTACLeadA.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssUSTACLeadA.DemonstratesMin__c;
            iFormExceeds = (integer)sssUSTACLeadA.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }
        
        if (strRecordTypeName == 'US TAC Lead A v2')
        {        
            SptStatusRptsScores__c sssUSTACLeadA = SptStatusRptsScores__c.getValues('US TAC Lead A');
            iFormNeeds = (integer)sssUSTACLeadA.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssUSTACLeadA.DemonstratesMin__c;
            iFormExceeds = (integer)sssUSTACLeadA.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }
        
        if (strRecordTypeName == 'US TAC A v1')
        {        
            SptStatusRptsScores__c sssUSTACA = SptStatusRptsScores__c.getValues('US TAC A');
            iFormNeeds = (integer)sssUSTACA.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssUSTACA.DemonstratesMin__c;
            iFormExceeds = (integer)sssUSTACA.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }
        
        if (strRecordTypeName == 'US TAC A v2')
        {        
            SptStatusRptsScores__c sssUSTACA = SptStatusRptsScores__c.getValues('US TAC A');
            iFormNeeds = (integer)sssUSTACA.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssUSTACA.DemonstratesMin__c;
            iFormExceeds = (integer)sssUSTACA.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }
        
        if (strRecordTypeName == 'US TAC S v1')
        {
            SptStatusRptsScores__c sssUSTACS = SptStatusRptsScores__c.getValues('US TAC S');
            iFormNeeds = (integer)sssUSTACS.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssUSTACS.DemonstratesMin__c;
            iFormExceeds = (integer)sssUSTACS.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }
        
        if (strRecordTypeName == 'US BRT v1')
        {
            SptStatusRptsScores__c sssUSBRT = SptStatusRptsScores__c.getValues('US BRT');
            iFormNeeds = (integer)sssUSBRT.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssUSBRT.DemonstratesMin__c;
            iFormExceeds = (integer)sssUSBRT.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }
        
        if (strRecordTypeName == 'PSS v1')
        {
            SptStatusRptsScores__c sssUSPSS = SptStatusRptsScores__c.getValues('US PSS');
            iFormNeeds = (integer)sssUSPSS.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssUSPSS.DemonstratesMin__c;
            iFormExceeds = (integer)sssUSPSS.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }        
        
        if (strRecordTypeName == 'US INT v1')
        {
            SptStatusRptsScores__c sssUSINT = SptStatusRptsScores__c.getValues('US Interfaces');
            iFormNeeds = (integer)sssUSINT.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssUSINT.DemonstratesMin__c;
            iFormExceeds = (integer)sssUSINT.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }           
        
        if (strRecordTypeName == 'PMS Standard v1')
        {
            SptStatusRptsScores__c sssPMSStnd = SptStatusRptsScores__c.getValues('PMS Standard');
            iFormNeeds = (integer)sssPMSStnd.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssPMSStnd.DemonstratesMin__c;
            iFormExceeds = (integer)sssPMSStnd.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }    
        
        if (strRecordTypeName == 'PMS Technical v1')
        {
            SptStatusRptsScores__c sssUSPMSTech = SptStatusRptsScores__c.getValues('PMS Technical');
            iFormNeeds = (integer)sssUSPMSTech.NeedsDevelopmentMin__c;
            iFormMeets = (integer)sssUSPMSTech.DemonstratesMin__c;
            iFormExceeds = (integer)sssUSPMSTech.DemonstratesMax__c;
            bUseCompanyScoring = true;
        }    
        
        if (bUseCompanyScoring)
        {
            if (iScoreFinal < iFormNeeds)
            {
                sr.FinalStatus__c = 'Does Not Demonstrate (DND)';
            }
            if ((iScoreFinal >= iFormNeeds) && (iScoreFinal < iFormMeets))
            {
                sr.FinalStatus__c = 'Needs Development (ND)';
            }
            if ((iScoreFinal >= iFormMeets) && (iScoreFinal <= iFormExceeds))
            {
                sr.FinalStatus__c = 'Demonstrates (D)';
            }
            if (iScoreFinal > iFormExceeds)
            {
                sr.FinalStatus__c = 'Exceeds Expectations (EX)';
            }                 
        }
        else
        {
            if (iScoreFinal < iFormMeets)
            {
                sr.FinalStatus__c = 'Missed';
            }
            if ((iScoreFinal >= iFormMeets) && (iScoreFinal < iFormExceeds))
            {
                sr.FinalStatus__c = 'Meets';
            }
            if (iScoreFinal >= iFormExceeds)
            {
                sr.FinalStatus__c = 'Exceeds';
            } 
        }             
    }    
    
    public Integer GetScore(Integer iSectionId, String strStatus)
    {
        
        Integer iRetVal = 0;
        SptStatusRptsScores__c s;
        
        if ((strRecordTypeName == '') || (strRecordTypeName == null))
        {
            return iRetVal;
        }
        if (strRecordTypeName == 'US INT v1')
        {
            s = SptStatusRptsScores__c.getValues('US Interfaces');
        }
        if (strRecordTypeName == 'PSS v1')
        {
            s = SptStatusRptsScores__c.getValues('US PSS');
        }
        if (strRecordTypeName == 'US BRT v1')
        {
            s = SptStatusRptsScores__c.getValues('US BRT');
        }
        if (strRecordTypeName == 'US TAC S v1')
        {
            s = SptStatusRptsScores__c.getValues('US TAC S');
        }
        if (strRecordTypeName == 'US TAC A v1')
        {
            s = SptStatusRptsScores__c.getValues('US TAC A');
        }
        if (strRecordTypeName == 'US TAC A v2')
        {
            s = SptStatusRptsScores__c.getValues('US TAC A');
        }
        if (strRecordTypeName == 'US TAC Senior A v1')
        {
            s = SptStatusRptsScores__c.getValues('US TAC Senior A');
        }
        if (strRecordTypeName == 'US TAC Lead A v1')
        {
            s = SptStatusRptsScores__c.getValues('US TAC Lead A');
        }
        if (strRecordTypeName == 'US TAC Lead A v2')
        {
            s = SptStatusRptsScores__c.getValues('US TAC Lead A');
        }
        if (strRecordTypeName == 'EMEA TAC S v1')
        {
            s = SptStatusRptsScores__c.getValues('EMEA TAC S');
        }
        if (strRecordTypeName == 'EMEA TAC A v1')
        {
            s = SptStatusRptsScores__c.getValues('EMEA TAC A');
        }
        if (strRecordTypeName == 'EMEA TAC A v2')
        {
            s = SptStatusRptsScores__c.getValues('EMEA TAC A');
        }
        if (strRecordTypeName == 'PMS Standard v1')
        {
            s = SptStatusRptsScores__c.getValues('PMS Standard');
        }
        if (strRecordTypeName == 'PMS Technical v1')
        {
            s = SptStatusRptsScores__c.getValues('PMS Technical');
        }
        
        if (iSectionId == 1)
        {
            if (strStatus == 'Meets')
            {
                iRetVal = (integer)s.Meets_Score_1__c;
            }
            if (strStatus == 'Exceeds')
            {
                iRetVal = (integer)s.Exceeds_Score_1__c;
            }                
        }
        if (iSectionId == 2)
        {
            if (strStatus == 'Meets')
            {
                iRetVal = (integer)s.Meets_Score_2__c;
            }
            if (strStatus == 'Exceeds')
            {
                iRetVal = (integer)s.Exceeds_Score_2__c;
            }                  
        }
        if (iSectionId == 3)
        {
            if (strStatus == 'Meets')
            {
                iRetVal = (integer)s.Meets_Score_3__c;
            }
            if (strStatus == 'Exceeds')
            {
                iRetVal = (integer)s.Exceeds_Score_3__c;
            }              
        }
        if (iSectionId == 4)
        {
            if (strStatus == 'Meets')
            {
                iRetVal = (integer)s.Meets_Score_4__c;
            }
            if (strStatus == 'Exceeds')
            {
                iRetVal = (integer)s.Exceeds_Score_4__c;
            }               
        }
        if (iSectionId == 5)
        {
            if (strStatus == 'Meets')
            {
                iRetVal = (integer)s.Meets_Score_5__c;
            }
            if (strStatus == 'Exceeds')
            {
                iRetVal = (integer)s.Exceeds_Score_5__c;
            }                   
        }
        if (iSectionId == 6)
        {
            if (strStatus == 'Meets')
            {
                iRetVal = (integer)s.Meets_Score_6__c;
            }
            if (strStatus == 'Exceeds')
            {
                iRetVal = (integer)s.Exceeds_Score_6__c;
            }             
        }
        if (iSectionId == 7)
        {
            if (strStatus == 'Meets')
            {
                iRetVal = (integer)s.Meets_Score_7__c;
            }
            if (strStatus == 'Exceeds')
            {
                iRetVal = (integer)s.Exceeds_Score_7__c;
            }                 
        }
        if (iSectionId == 8)
        {
            if (strStatus == 'Meets')
            {
                iRetVal = (integer)s.Meets_Score_8__c;
            }
            if (strStatus == 'Exceeds')
            {
                iRetVal = (integer)s.Exceeds_Score_8__c;
            }     
        }
        if (iSectionId == 9)
        {
            if (strStatus == 'Meets')
            {
                iRetVal = (integer)s.Meets_Score_9__c;
            }
            if (strStatus == 'Exceeds')
            {
                iRetVal = (integer)s.Exceeds_Score_9__c;
            }     
        }
        if (iSectionId == 10)
        {
            if (strStatus == 'Meets')
            {
                iRetVal = (integer)s.Meets_Score_10__c;
            }
            if (strStatus == 'Exceeds')
            {
                iRetVal = (integer)s.Exceeds_Score_10__c;
            }     
        }
        
        return iRetVal;
        
    }
    
    
    public void CheckForNoChecks()
    {
        if ((sr.Missed01__c == false) && (sr.Meets01__c == false) && (sr.Exceeds01__c == false))
        {
            sr.Missed01__c = true;
        }
        if ((sr.Missed02__c == false) && (sr.Meets02__c == false) && (sr.Exceeds02__c == false))
        {
            sr.Missed02__c = true;
        }
        if ((sr.Missed03__c == false) && (sr.Meets03__c == false) && (sr.Exceeds03__c == false))
        {
            sr.Missed03__c = true;
        }
        if ((sr.Missed04__c == false) && (sr.Meets04__c == false) && (sr.Exceeds04__c == false))
        {
            sr.Missed04__c = true;
        }
        if ((sr.Missed05__c == false) && (sr.Meets05__c == false) && (sr.Exceeds05__c == false))
        {
            sr.Missed05__c = true;
        }
        if ((sr.Missed06__c == false) && (sr.Meets06__c == false) && (sr.Exceeds06__c == false))
        {
            sr.Missed06__c = true;
        }
        if ((sr.Missed07__c == false) && (sr.Meets07__c == false) && (sr.Exceeds07__c == false))
        {
            sr.Missed07__c = true;
        }
        if ((sr.Missed08__c == false) && (sr.Meets08__c == false) && (sr.Exceeds08__c == false))
        {
            sr.Missed08__c = true;
        }
        if ((sr.Missed09__c == false) && (sr.Meets09__c == false) && (sr.Exceeds09__c == false))
        {
            sr.Missed09__c = true;
        }
        if ((sr.Missed10__c == false) && (sr.Meets10__c == false) && (sr.Exceeds10__c == false))
        {
            sr.Missed10__c = true;
        }
    }    
    
    
    // =============== CHECKBOX FUNCTIONS =============== //
    
    public void S1MissedCheckbox()
    {
        CheckForNoChecks();
        sr.Score01__c = 0;
        if (sr.Missed01__c == true)
        {
            sr.Meets01__c = false;
            sr.Exceeds01__c = false;
            sr.Score01__c = 0;
        }
        SummerizeScores(); 
    }    
    
    public void S1MeetsCheckbox()
    {
        CheckForNoChecks();
        sr.Score01__c = 0;
        if (sr.Meets01__c == true)
        {
            sr.Missed01__c = false;
            sr.Exceeds01__c = false;
            sr.Score01__c = GetScore(1, 'Meets');
        }
        SummerizeScores(); 
    }
    
    public void S1ExceedsCheckbox()
    {
        CheckForNoChecks();
        sr.Score01__c = 0;
        if (sr.Exceeds01__c == true)
        {
            sr.Missed01__c = false;
            sr.Meets01__c = false;
            sr.Score01__c = GetScore(1, 'Exceeds');
        }
        SummerizeScores(); 
    }    
    
    public void S2MissedCheckbox()
    {
        CheckForNoChecks();
        sr.Score02__c = 0;
        if (sr.Missed02__c == true)
        {
            sr.Meets02__c = false;
            sr.Exceeds02__c = false;
            sr.Score02__c = 0;
        }
        SummerizeScores(); 
    }    
    
    public void S2MeetsCheckbox()
    {
        CheckForNoChecks();
        sr.Score02__c = 0;
        if (sr.Meets02__c == true)
        {
            sr.Missed02__c = false;
            sr.Exceeds02__c = false;
            sr.Score02__c = GetScore(2, 'Meets');
        }
        SummerizeScores(); 
    }
    
    public void S2ExceedsCheckbox()
    {
        CheckForNoChecks();
        sr.Score02__c = 0;
        if (sr.Exceeds02__c == true)
        {
            sr.Missed02__c = false;
            sr.Meets02__c = false;
            sr.Score02__c = GetScore(2, 'Exceeds');
        }
        SummerizeScores(); 
    }        
    
    public void S3MissedCheckbox()
    {
        CheckForNoChecks();
        sr.Score03__c = 0;
        if (sr.Missed03__c == true)
        {
            sr.Meets03__c = false;
            sr.Exceeds03__c = false;
            sr.Score03__c = 0;
        }
        SummerizeScores(); 
    }    
    
    public void S3MeetsCheckbox()
    {
        CheckForNoChecks();
        sr.Score03__c = 0;
        if (sr.Meets03__c == true)
        {
            sr.Missed03__c = false;
            sr.Exceeds03__c = false;
            sr.Score03__c = GetScore(3, 'Meets');
        }
        SummerizeScores(); 
    }
    
    public void S3ExceedsCheckbox()
    {
        CheckForNoChecks();
        sr.Score03__c = 0;
        if (sr.Exceeds03__c == true)
        {
            sr.Missed03__c = false;
            sr.Meets03__c = false;
            sr.Score03__c = GetScore(3, 'Exceeds');
        }
        SummerizeScores(); 
    }    
    
    public void S4MissedCheckbox()
    {
        CheckForNoChecks();
        sr.Score04__c = 0;
        if (sr.Missed04__c == true)
        {
            sr.Meets04__c = false;
            sr.Exceeds04__c = false;
            sr.Score04__c = 0;
        }
        SummerizeScores(); 
    }    
    
    public void S4MeetsCheckbox()
    {
        CheckForNoChecks();
        sr.Score04__c = 0;
        if (sr.Meets04__c == true)
        {
            sr.Missed04__c = false;
            sr.Exceeds04__c = false;
            sr.Score04__c = GetScore(4, 'Meets');
        }
        SummerizeScores(); 
    }
    
    public void S4ExceedsCheckbox()
    {
        CheckForNoChecks();
        sr.Score04__c = 0;
        if (sr.Exceeds04__c == true)
        {
            sr.Missed04__c = false;
            sr.Meets04__c = false;
            sr.Score04__c = GetScore(4, 'Exceeds');
        }
        SummerizeScores(); 
    }    
    
    public void S5MissedCheckbox()
    {
        CheckForNoChecks();
        sr.Score05__c = 0;
        if (sr.Missed05__c == true)
        {
            sr.Meets05__c = false;
            sr.Exceeds05__c = false;
            sr.Score05__c = 0;
        }
        SummerizeScores(); 
    }    
    
    public void S5MeetsCheckbox()
    {
        CheckForNoChecks();
        sr.Score05__c = 0;
        if (sr.Meets05__c == true)
        {
            sr.Missed05__c = false;
            sr.Exceeds05__c = false;
            sr.Score05__c = GetScore(5, 'Meets');
        }
        SummerizeScores(); 
    }
    
    public void S5ExceedsCheckbox()
    {
        CheckForNoChecks();
        sr.Score05__c = 0;
        if (sr.Exceeds05__c == true)
        {
            sr.Missed05__c = false;
            sr.Meets05__c = false;
            sr.Score05__c = GetScore(5, 'Exceeds');
        }
        SummerizeScores(); 
    }
    
    public void S6MissedCheckbox()
    {
        CheckForNoChecks();
        sr.Score06__c = 0;
        if (sr.Missed06__c == true)
        {
            sr.Meets06__c = false;
            sr.Exceeds06__c = false;
            sr.Score06__c = 0;
        }
        SummerizeScores(); 
    }    
    
    public void S6MeetsCheckbox()
    {
        CheckForNoChecks();
        sr.Score06__c = 0;
        if (sr.Meets06__c == true)
        {
            sr.Missed06__c = false;
            sr.Exceeds06__c = false;
            sr.Score06__c = GetScore(6, 'Meets');
        }
        SummerizeScores(); 
    }
    
    public void S6ExceedsCheckbox()
    {
        CheckForNoChecks();
        sr.Score06__c = 0;
        if (sr.Exceeds06__c == true)
        {
            sr.Missed06__c = false;
            sr.Meets06__c = false;
            sr.Score06__c = GetScore(6, 'Exceeds');
        }
        SummerizeScores(); 
    }  
    
    public void S7MissedCheckbox()
    {
        CheckForNoChecks();
        sr.Score07__c = 0;
        if (sr.Missed07__c == true)
        {
            sr.Meets07__c = false;
            sr.Exceeds07__c = false;
            sr.Score07__c = 0;
        }
        SummerizeScores(); 
    }    
    
    public void S7MeetsCheckbox()
    {
        CheckForNoChecks();
        sr.Score07__c = 0;
        if (sr.Meets07__c == true)
        {
            sr.Missed07__c = false;
            sr.Exceeds07__c = false;
            sr.Score07__c = GetScore(7, 'Meets');
        }
        SummerizeScores(); 
    }
    
    public void S7ExceedsCheckbox()
    {
        CheckForNoChecks();
        sr.Score07__c = 0;
        if (sr.Exceeds07__c == true)
        {
            sr.Missed07__c = false;
            sr.Meets07__c = false;
            sr.Score07__c = GetScore(7, 'Exceeds');
        }
        SummerizeScores(); 
    }   
    
    public void S8MissedCheckbox()
    {
        CheckForNoChecks();
        sr.Score08__c = 0;
        if (sr.Missed08__c == true)
        {
            sr.Meets08__c = false;
            sr.Exceeds08__c = false;
            sr.Score08__c = 0;
        }
        SummerizeScores(); 
    }    
    
    public void S8MeetsCheckbox()
    {
        CheckForNoChecks();
        sr.Score08__c = 0;
        if (sr.Meets08__c == true)
        {
            sr.Missed08__c = false;
            sr.Exceeds08__c = false;
            sr.Score08__c = GetScore(8, 'Meets');
        }
        SummerizeScores(); 
    }
    
    public void S8ExceedsCheckbox()
    {
        CheckForNoChecks();
        sr.Score08__c = 0;
        if (sr.Exceeds08__c == true)
        {
            sr.Missed08__c = false;
            sr.Meets08__c = false;
            sr.Score08__c = GetScore(8, 'Exceeds');
        }
        SummerizeScores(); 
    }  
    
    public void S9MissedCheckbox()
    {
        CheckForNoChecks();
        sr.Score09__c = 0;
        if (sr.Missed09__c == true)
        {
            sr.Meets09__c = false;
            sr.Exceeds09__c = false;
            sr.Score09__c = 0;
        }
        SummerizeScores(); 
    }    
    
    public void S9MeetsCheckbox()
    {
        CheckForNoChecks();
        sr.Score09__c = 0;
        if (sr.Meets09__c == true)
        {
            sr.Missed09__c = false;
            sr.Exceeds09__c = false;
            sr.Score09__c = GetScore(9, 'Meets');
        }
        SummerizeScores(); 
    }
    
    public void S9ExceedsCheckbox()
    {
        CheckForNoChecks();
        sr.Score09__c = 0;
        if (sr.Exceeds09__c == true)
        {
            sr.Missed09__c = false;
            sr.Meets09__c = false;
            sr.Score09__c = GetScore(9, 'Exceeds');
        }
        SummerizeScores(); 
    }                   
    
    public void S10MissedCheckbox()
    {
        CheckForNoChecks();
        sr.Score10__c = 0;
        if (sr.Missed10__c == true)
        {
            sr.Meets10__c = false;
            sr.Exceeds10__c = false;
            sr.Score10__c = 0;
        }
        SummerizeScores(); 
    }    
    
    public void S10MeetsCheckbox()
    {
        CheckForNoChecks();
        sr.Score10__c = 0;
        if (sr.Meets10__c == true)
        {
            sr.Missed10__c = false;
            sr.Exceeds10__c = false;
            sr.Score10__c = GetScore(10, 'Meets');
        }
        SummerizeScores(); 
    }
    
    public void S10ExceedsCheckbox()
    {
        CheckForNoChecks();
        sr.Score10__c = 0;
        if (sr.Exceeds10__c == true)
        {
            sr.Missed10__c = false;
            sr.Meets10__c = false;
            sr.Score10__c = GetScore(10, 'Exceeds');
        }
        SummerizeScores(); 
    }
    
    // =============== CHECKBOX FUNCTIONS =============== //  
    
    public Decimal roundNumber(Decimal roundNumber, Integer decimalPlace)  
    {
        if (roundNumber != null)
        {
            Decimal decPlace = Math.POW(10 , decimalPlace);
            return Math.round(roundNumber * decPlace) / decPlace;
        }  
        else
        {
            return 0 ;
        }
    }
    
    public Date LastMonday() 
    {
        DateTime t = DateTime.now();
        Date d = t.Date();
        d = d.toStartofWeek();
        d = d.addDays(-7);
        return d;
    }
    
    public Date ThisMonday() 
    {
        DateTime t = DateTime.now();
        Date d = t.Date();
        d = d.toStartofWeek();
        d = d.addDays(1);
        return d;
    }
    
    public PageReference send() 
    {
        
        if (sr.Associate__c == null)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Please choose an associate before emailing.' );
            ApexPages.addMessage(msg);             
            return null;
        }
        
        User u = [SELECT Email, Name, FirstName FROM User WHERE Id = :sr.Associate__c];
        
        if (u.Email != null)
        {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {u.Email};
                mail.setToAddresses(toAddresses);
            mail.setBccSender(true);
            mail.setSubject('A New Status Report For You Has Been Created');
            mail.setPlainTextBody(u.FirstName + ', Please find your new Status Report Here: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/a3B');
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            
            for (Messaging.SendEmailResult result : r) 
            {
                //                if (!r[0].isSuccess()) 
                //                {
                //                    System.debug(result);
                //                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'The following error occured sending the email: ' + result);
                //                    ApexPages.addMessage(msg);                     
                //                }
                //                else
                //                {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Email Sent Successfully' );
                ApexPages.addMessage(msg);
                //                }
            }
            
        }            
        //        else
        //        {
        //            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Email for associate not found!' );
        //            ApexPages.addMessage(msg);        
        //        }
        
        return null;
        
    }
    
    public Boolean ShowButtons 
    {
        get 
        {
            Boolean bRetVal = false;
            
            Profile p1 = [SELECT Id, Name FROM Profile WHERE Name = 'NI Support Managers' LIMIT 1];
            Profile p2 = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            
            if ((UserInfo.getProfileId() == p1.Id) || (UserInfo.getProfileId() == p2.Id))
            {
                bRetVal = true; 
            }
            
            return bRetVal;
        }
        set;
    }
    
    public void fetchScoreLabels() 
    {
        
        // SET FINAL SCORE VARIABLES 
        if (strRecordTypeName == 'EMEA TAC A v1')
        {
            
        }
        
        if (strRecordTypeName == 'EMEA TAC A v2')
        {
            SptStatusRptsScores__c sssEMEATACA = SptStatusRptsScores__c.getValues('EMEA TAC A');
            iScoreLabel1 = (integer)sssEMEATACA.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssEMEATACA.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssEMEATACA.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssEMEATACA.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssEMEATACA.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssEMEATACA.ExceedsExpectations__c;   
        }        
        
        if (strRecordTypeName == 'EMEA TAC S v1')
        {
            
        }
        
        if (strRecordTypeName == 'US TAC A v1')
        {        
            SptStatusRptsScores__c sssUSTACA = SptStatusRptsScores__c.getValues('US TAC A');
            iScoreLabel1 = (integer)sssUSTACA.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssUSTACA.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssUSTACA.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssUSTACA.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssUSTACA.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssUSTACA.ExceedsExpectations__c;           
        }
        
        if (strRecordTypeName == 'US TAC A v2')
        {        
            SptStatusRptsScores__c sssUSTACA = SptStatusRptsScores__c.getValues('US TAC A');
            iScoreLabel1 = (integer)sssUSTACA.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssUSTACA.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssUSTACA.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssUSTACA.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssUSTACA.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssUSTACA.ExceedsExpectations__c;           
        }
        
        if (strRecordTypeName == 'US TAC Senior A v1')
        {        
            SptStatusRptsScores__c sssUSTACSeniorA = SptStatusRptsScores__c.getValues('US TAC Senior A');
            iScoreLabel1 = (integer)sssUSTACSeniorA.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssUSTACSeniorA.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssUSTACSeniorA.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssUSTACSeniorA.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssUSTACSeniorA.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssUSTACSeniorA.ExceedsExpectations__c;           
        }
        
        if (strRecordTypeName == 'US TAC Lead A v1')
        {        
            SptStatusRptsScores__c sssUSLEADA = SptStatusRptsScores__c.getValues('US TAC Lead A');
            iScoreLabel1 = (integer)sssUSLEADA.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssUSLEADA.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssUSLEADA.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssUSLEADA.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssUSLEADA.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssUSLEADA.ExceedsExpectations__c;           
        }
        
        if (strRecordTypeName == 'US TAC Lead A v2')
        {        
            SptStatusRptsScores__c sssUSLEADA = SptStatusRptsScores__c.getValues('US TAC Lead A');
            iScoreLabel1 = (integer)sssUSLEADA.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssUSLEADA.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssUSLEADA.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssUSLEADA.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssUSLEADA.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssUSLEADA.ExceedsExpectations__c;           
        }
        
        if (strRecordTypeName == 'US TAC S v1')
        {
            SptStatusRptsScores__c sssUSTACS = SptStatusRptsScores__c.getValues('US TAC S');
            iScoreLabel1 = (integer)sssUSTACS.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssUSTACS.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssUSTACS.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssUSTACS.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssUSTACS.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssUSTACS.ExceedsExpectations__c;           
        }
        
        if (strRecordTypeName == 'US BRT v1')
        {
            SptStatusRptsScores__c sssUSBRT = SptStatusRptsScores__c.getValues('US BRT');
            iScoreLabel1 = (integer)sssUSBRT.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssUSBRT.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssUSBRT.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssUSBRT.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssUSBRT.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssUSBRT.ExceedsExpectations__c;           
        }
        
        if (strRecordTypeName == 'PSS v1')
        {
            SptStatusRptsScores__c sssUSPSS = SptStatusRptsScores__c.getValues('US PSS');
            iScoreLabel1 = (integer)sssUSPSS.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssUSPSS.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssUSPSS.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssUSPSS.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssUSPSS.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssUSPSS.ExceedsExpectations__c;           
        }        
        
        if (strRecordTypeName == 'US INT v1')
        {
            SptStatusRptsScores__c sssUSINT = SptStatusRptsScores__c.getValues('US Interfaces');
            iScoreLabel1 = (integer)sssUSINT.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssUSINT.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssUSINT.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssUSINT.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssUSINT.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssUSINT.ExceedsExpectations__c;
        } 
        
        if (strRecordTypeName == 'PMS Standard v1')
        {
            SptStatusRptsScores__c sssPMSTech = SptStatusRptsScores__c.getValues('PMS Standard');
            iScoreLabel1 = (integer)sssPMSTech.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssPMSTech.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssPMSTech.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssPMSTech.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssPMSTech.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssPMSTech.ExceedsExpectations__c;
        } 
        
        if (strRecordTypeName == 'PMS Technical v1')
        {
            SptStatusRptsScores__c sssPMSStnd = SptStatusRptsScores__c.getValues('PMS Technical');
            iScoreLabel1 = (integer)sssPMSStnd.DoesNotDemonstrate__c;
            iScoreLabel2 = (integer)sssPMSStnd.NeedsDevelopmentMin__c;
            iScoreLabel3 = (integer)sssPMSStnd.NeedsDevelopmentMax__c;
            iScoreLabel4 = (integer)sssPMSStnd.DemonstratesMin__c;
            iScoreLabel5 = (integer)sssPMSStnd.DemonstratesMax__c;
            iScoreLabel6 = (integer)sssPMSStnd.ExceedsExpectations__c;
        }         
    }
    
}