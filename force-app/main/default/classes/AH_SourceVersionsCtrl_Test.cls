/************************************************************************************************
Name            : AH_SourceVersionsCtrl_Test Class
Author          : Sean Harris
Created Date    : 10/12/2018
Last Mod Date   : 10/12/2018
Last Mod By     : Sean Harris
NICC Reference  :
Description     : 
                : 
*************************************************************************************************/
@isTest
public class AH_SourceVersionsCtrl_Test 
{

    
    // =============================================================================================================
    //  TEST DATA CREATION 
    // =============================================================================================================
    static testMethod void testAH_SourceVersionsCtrl1() 
    {

        datetime dt = datetime.now();
        string strDT = dt.format('MM/dd/yyy h:mm a');

        Test.startTest();
        
        // CREATE TEST SALESFORCE SOURCE CONTROL RECORD
        AH_SFDC_Source_Control__c s1 = new AH_SFDC_Source_Control__c();
        s1.API_Name__c = 'NI_TestClassData_Test';
        s1.Salesforce_Source_Type__c = 'Apex Class';
        s1.CRC__c = 997391997;
        s1.Description__c = 'test class';
        s1.Label__c = 'NI_TestClassData_Test';
        s1.Salesforce_ID__c = '01p600000000iZh';
        s1.Syntax__c = 'for (integer i = 0; i < 1000; i++) ';
        s1.Source_Last_Modified__c = dt;
        s1.Source_Last_Modified_By__c = UserInfo.getUserId();
        insert s1;

        
        // CREATE SF SOURCE VERSION RECORDS
        List<AH_SFDC_Source_Version__c> lstVersions = new List<AH_SFDC_Source_Version__c>();
        
        AH_SFDC_Source_Version__c v01 = new AH_SFDC_Source_Version__c();
        v01.Last_Active__c = dt.addMonths(-1);
        v01.SFDC_Source_Control__c = s1.Id;
        v01.Syntax__c = 'for (integer i = 0; i < 900; i++) ';
		lstVersions.add(v01); 

        AH_SFDC_Source_Version__c v02 = new AH_SFDC_Source_Version__c();
        v02.Last_Active__c = dt.addMonths(-2);
        v02.SFDC_Source_Control__c = s1.Id;
        v02.Syntax__c = 'for (integer i = 0; i < 800; i++) ';
		lstVersions.add(v02); 

        AH_SFDC_Source_Version__c v03 = new AH_SFDC_Source_Version__c();
        v03.Last_Active__c = dt.addMonths(-3);
        v03.SFDC_Source_Control__c = s1.Id;
        v03.Syntax__c = 'for (integer i = 0; i < 700; i++) ';
		lstVersions.add(v03); 

        AH_SFDC_Source_Version__c v04 = new AH_SFDC_Source_Version__c();
        v04.Last_Active__c = dt.addMonths(-4);
        v04.SFDC_Source_Control__c = s1.Id;
        v04.Syntax__c = 'for (integer i = 0; i < 600; i++) ';
		lstVersions.add(v04); 

        AH_SFDC_Source_Version__c v05 = new AH_SFDC_Source_Version__c();
        v05.Last_Active__c = dt.addMonths(-5);
        v05.SFDC_Source_Control__c = s1.Id;
        v05.Syntax__c = 'for (integer i = 0; i < 500; i++) ';
		lstVersions.add(v05); 

        AH_SFDC_Source_Version__c v06 = new AH_SFDC_Source_Version__c();
        v06.Last_Active__c = dt.addMonths(-6);
        v06.SFDC_Source_Control__c = s1.Id;
        v06.Syntax__c = 'for (integer i = 0; i < 400; i++) ';
		lstVersions.add(v06); 

        AH_SFDC_Source_Version__c v07 = new AH_SFDC_Source_Version__c();
        v07.Last_Active__c = dt.addMonths(-7);
        v07.SFDC_Source_Control__c = s1.Id;
        v07.Syntax__c = 'for (integer i = 0; i < 300; i++) ';
		lstVersions.add(v07); 

        AH_SFDC_Source_Version__c v08 = new AH_SFDC_Source_Version__c();
        v08.Last_Active__c = dt.addMonths(-8);
        v08.SFDC_Source_Control__c = s1.Id;
        v08.Syntax__c = 'for (integer i = 0; i < 200; i++) ';
		lstVersions.add(v08); 

        AH_SFDC_Source_Version__c v09 = new AH_SFDC_Source_Version__c();
        v09.Last_Active__c = dt.addMonths(-9);
        v09.SFDC_Source_Control__c = s1.Id;
        v09.Syntax__c = 'for (integer i = 0; i < 100; i++) ';
		lstVersions.add(v09);         

        AH_SFDC_Source_Version__c v10 = new AH_SFDC_Source_Version__c();
        v10.Last_Active__c = dt.addMonths(-10);
        v10.SFDC_Source_Control__c = s1.Id;
        v10.Syntax__c = 'for (integer i = 0; i < 75; i++) ';
		lstVersions.add(v10); 

        AH_SFDC_Source_Version__c v11 = new AH_SFDC_Source_Version__c();
        v11.Last_Active__c = dt.addMonths(-11);
        v11.SFDC_Source_Control__c = s1.Id;
        v11.Syntax__c = 'for (integer i = 0; i < 50; i++) ';
		lstVersions.add(v11); 

        AH_SFDC_Source_Version__c v12 = new AH_SFDC_Source_Version__c();
        v12.Last_Active__c = dt.addMonths(-12);
        v12.SFDC_Source_Control__c = s1.Id;
        v12.Syntax__c = 'for (integer i = 0; i < 25; i++) ';
		lstVersions.add(v12); 
        
        database.insert(lstVersions);        
        
        Test.stopTest();
        
        // =============================================================================================================
        // 		VISUALFORCE PAGE TESTING
        // =============================================================================================================
                
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_SourceVersions;

        // ADD URL PARAM
        pageRef.getParameters().put('id', s1.Id);        
        
        // SET TEST PAGE
		Test.setCurrentPage(pageRef); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_SourceVersionsCtrl ctrl = new AH_SourceVersionsCtrl();            

        // ASSERTIONS 
        strDT = dt.format('MM/dd/yyy h:mm a');
        system.assertEquals('Current Last Modified Date: ' + strDT, ctrl.currentCreated); 
/* 
        strDT = dt.addMonths(-1).format('MM/dd/yyy h:mm a');
        system.assertEquals('Last Active Date: ' + strDT, ctrl.created01);
       
        strDT = dt.addMonths(-2).format('MM/dd/yyy h:mm a');
        system.assertEquals('Last Active Date: ' + strDT, ctrl.created02);  
        
        strDT = dt.addMonths(-3).format('MM/dd/yyy h:mm a');
        system.assertEquals('Last Active Date: ' + strDT, ctrl.created03); 
        
        strDT = dt.addMonths(-4).format('MM/dd/yyy h:mm a');
        system.assertEquals('Last Active Date: ' + strDT, ctrl.created04);
        
        strDT = dt.addMonths(-5).format('MM/dd/yyy h:mm a');
        system.assertEquals('Last Active Date: ' + strDT, ctrl.created05);
        
        strDT = dt.addMonths(-6).format('MM/dd/yyy h:mm a');
        system.assertEquals('Last Active Date: ' + strDT, ctrl.created06);
        
        strDT = dt.addMonths(-7).format('MM/dd/yyy h:mm a');
        system.assertEquals('Last Active Date: ' + strDT, ctrl.created07);
        
        strDT = dt.addMonths(-8).format('MM/dd/yyy h:mm a');
        system.assertEquals('Last Active Date: ' + strDT, ctrl.created08);
        
        strDT = dt.addMonths(-9).format('MM/dd/yyy h:mm a');
        system.assertEquals('Last Active Date: ' + strDT, ctrl.created09); 
       
        system.assertEquals('Version History for: NI_TestClassData_Test', ctrl.strTitle); 
        
        system.assertEquals('for (integer i = 0; i < 1000; i++) ', ctrl.currentSyntax);        
        system.assertEquals('for (integer i = 0; i < 900; i++) ', ctrl.syntax01);         
        system.assertEquals('for (integer i = 0; i < 800; i++) ', ctrl.syntax02);          
        system.assertEquals('for (integer i = 0; i < 700; i++) ', ctrl.syntax03);         
        system.assertEquals('for (integer i = 0; i < 600; i++) ', ctrl.syntax04);         
        system.assertEquals('for (integer i = 0; i < 500; i++) ', ctrl.syntax05);         
        system.assertEquals('for (integer i = 0; i < 400; i++) ', ctrl.syntax06);         
        system.assertEquals('for (integer i = 0; i < 300; i++) ', ctrl.syntax07);         
        system.assertEquals('for (integer i = 0; i < 200; i++) ', ctrl.syntax08);         
        system.assertEquals('for (integer i = 0; i < 100; i++) ', ctrl.syntax09);         
*/ 
        
    }    
    
}