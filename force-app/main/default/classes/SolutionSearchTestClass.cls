@isTest
private class SolutionSearchTestClass 
{

    static testMethod void myUnitTest() 
    {
        
        // CREATE 100 SOLUTIONS FOR TESTING AND ASSET THEY WERE INSERTED =======================================================================
        List<Solution> lstSolutionInsert = new List<Solution>();
        
        for (integer j = 1; (j < 26); j++)
        {
            Solution s = NI_TestClassData.createSolution(j);  
            s.SolutionName = 'BEO TAX FORM REVIEWED SOLUTION #' + String.valueOf(j);
            s.SolutionNote = 'RESOLUTION #1: Do Nothing. \n\n\n';
            s.SolutionNote += 'RESOLUTION #2: Call your Mom. \n\n\n';
            s.SolutionNote += 'RESOLUTION #3: Call the Police. \n\n\n'; 
            s.Status = 'Reviewed';
            lstSolutionInsert.add(s);
        }  
        
        for (integer j = 26; (j < 51); j++)
        {
            Solution s = NI_TestClassData.createSolution(j);  
            s.SolutionName = 'BEO TAX FORM ARCHIVED SOLUTION #' + String.valueOf(j);
            s.SolutionNote = 'RESOLUTION #1: Do Nothing. \n\n\n';
            s.SolutionNote += 'RESOLUTION #2: Call your Mom. \n\n\n';
            s.SolutionNote += 'RESOLUTION #3: Call the Police. \n\n\n'; 
            s.Status = 'Archived';
            lstSolutionInsert.add(s);
        }          
        
        for (integer j = 51; (j < 76); j++)
        {
            Solution s = NI_TestClassData.createSolution(j);  
            s.SolutionName = 'BEO TAX FORM DRAFT SOLUTION #' + String.valueOf(j);
            s.SolutionNote = 'RESOLUTION #1: Do Nothing. \n\n\n';
            s.SolutionNote += 'RESOLUTION #2: Call your Mom. \n\n\n';
            s.SolutionNote += 'RESOLUTION #3: Call the Police. \n\n\n'; 
            s.Status = 'Draft';
            lstSolutionInsert.add(s);
        }   
        
        for (integer j = 76; (j < 101); j++)
        {
            Solution s = NI_TestClassData.createSolution(j);  
            s.SolutionName = 'BEO TAX FORM SENT FOR REVIEW SOLUTION #' + String.valueOf(j);
            s.SolutionNote = 'RESOLUTION #1: Do Nothing. \n\n\n';
            s.SolutionNote += 'RESOLUTION #2: Call your Mom. \n\n\n';
            s.SolutionNote += 'RESOLUTION #3: Call the Police. \n\n\n'; 
            s.Status = 'Sent For Review';
            lstSolutionInsert.add(s);
        }   
    
    
        Database.insert(lstSolutionInsert);
        
        List<Solution> lstSolutionAssertion = new List<Solution>([SELECT Id, SolutionNumber, SolutionName FROM Solution]);
        
        system.assertEquals(100, lstSolutionAssertion.Size());
        
        // CREATE A TEST CASE TO ATTACH A SOLUTION TO ==========================================================================================
        Account a = NI_TestClassData.createTestAccount(1); 
        insert a;         
        
        Case c = NI_TestClassData.createTestCase(1, a.Id); 
        insert c; 

        // SELECT ONE SOLUTION TO ATTACH TO CASE ===============================================================================================
        Solution sol = [SELECT id, SolutionNumber, SolutionName FROM Solution WHERE SolutionName = 'BEO TAX FORM REVIEWED SOLUTION #1'];
        
        List<User> lstUsers = new List<User>();
        
        User uSptMgr = NI_TestClassData.createTestUser(1, 'AH Support Managers - Lightning'); 
        lstUsers.add(uSptMgr);   
        
        User uSptTech = NI_TestClassData.createTestUser(2, 'AH Support CSR - Lightning'); 
        lstUsers.add(uSptTech);  
        
        Database.insert(lstUsers);
        
        
        System.runAs(uSptMgr)
        {
            
            // PAGE REFERENCE
            PageReference pageRef = Page.SolutionSearch;
            Test.setCurrentPage(pageRef);             
            
            // ADD URL PARAMS
            pageRef.getParameters().put('caseid', c.Id);
            
            // CONTROLLER 
            SolutionSearch ctrl = new SolutionSearch(new ApexPages.StandardController(sol));
            
            List<SelectOption> testoptions = ctrl.getStatuses();
            
            SelectOption sOpt = testoptions[0];
            string strOptVal = sOpt.getValue();
            ctrl.setStatus(strOptVal);
            
            system.assertEquals(strOptVal, ctrl.getStatus());  
            
            // USER SEARCH EMULATION 
            ctrl.strCaseId = c.Id;
            ctrl.strCaseNumber = c.CaseNumber;      
            
            ctrl.searchText = 'beo';        
            ctrl.doSearch();
            
            List<Solution> lstRes1 = ctrl.results;
            system.assertEquals(75, lstRes1.size());
            
            ctrl.searchText = 'REVIEWED';       
            ctrl.doSearch();    
            
            List<Solution> lstRes2 = ctrl.results;
            system.assertEquals(25, lstRes2.size());
            
            ctrl.goBack(); 
            
            ctrl.searchText = '!XXXXXXX';       
            ctrl.doSearch();
            
            List<Solution> lstRes3 = ctrl.results;
            system.assertEquals(75, lstRes3.size());
            
            // NEW SEARCH =============================
            ctrl.newSearch();
            ctrl.setStatus('All');
            
            ctrl.searchText = 'tax';       
            ctrl.doSearch();    
            
            List<Solution> lstRes4 = ctrl.results;
            system.assertEquals(100, lstRes4.size());
            
            // NEW SEARCH =============================
            ctrl.newSearch();
            ctrl.setStatus('Reviewed');
            
            ctrl.searchText = 'tax';       
            ctrl.doSearch();
            
            List<Solution> lstRes5 = ctrl.results;
            system.assertEquals(25, lstRes5.size());
            
            
            ctrl.drillDownCount = 0; 
            ctrl.bGoBack = true; 
            ctrl.goBack(); 
            
            ctrl.sql = '';
            ctrl.searchText = '!beo';        
            ctrl.doSearch();    
            
            ctrl.sql = 'BAD QUERY SYNTAX TO CAUSE INTENTIONAL ERROR';
            ctrl.searchText = 'beo';        
            ctrl.doSearch();    
            
            ctrl.searchText = 'beo';        
            ctrl.doSearch(); 
            ctrl.goBack(); 
            
            ctrl.drillDownCount = -1000;
            ctrl.sql = 'AND BAD QUERY SYNTAX TO CAUSE AND INTENTIONAL ERROR';
            ctrl.goBack();  
            
            
            // FETCH         
            String strDescText = ctrl.getDescText();
            String strResoText = ctrl.getResoText();  
            
            // PAGE REFERENCE FUNCTIONS
            PageReference pr1;       
            //pr1.getParameters().put('id', sol.Id);        
            ctrl.RetrieveDesc();
            
            PageReference pr2; 
            //pr2.getParameters().put('id', sol.Id);
            ctrl.RetrieveReso();
            
            ctrl.selectSol();
            
            List<Solution> sl1 = ctrl.getSolutions();
            List<Solution> sl2 = ctrl.results;
            
            ctrl.results = null;
            sl2 = ctrl.results;    
            
        }
        
        System.runAs(uSptTech)
        {
            
            // PAGE REFERENCE
            PageReference pageRef2 = Page.SolutionSearch;
            Test.setCurrentPage(pageRef2);             
            
            // CONTROLLER 
            SolutionSearch ctrl2 = new SolutionSearch(new ApexPages.StandardController(sol));
            
            ctrl2.searchText = 'beo'; 
            ctrl2.doSearch(); 
            
            List<Solution> lstResT1 = ctrl2.results; 
            system.assertEquals(75, lstResT1.size()); 
        
        	ctrl2.searchText = 'REVIEWED'; 
            ctrl2.doSearch(); 
            
            List<Solution> lstResT2 = ctrl2.results; 
            system.assertEquals(25, lstResT2.size()); 
            
            ctrl2.searchText = '#25'; 
            ctrl2.doSearch(); 
        
			List<Solution> lstResT3 = ctrl2.results; 
            system.assertEquals(1, lstResT3.size()); 
            
        }
        
    }    
    
}