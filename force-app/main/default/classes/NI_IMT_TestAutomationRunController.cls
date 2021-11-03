public class NI_IMT_TestAutomationRunController 
{

    public List<String> options {get; set;}
    public List<String> optionsDesc {get; set;}
    public Map<Integer,String> optionMap {get; set;}
    public List<String> status {get; set;}
    public List<String> failureReason {get; set;}
    public List<boolean> chkbox {get; set;}
    public Map<String,String> statusMap ;
    public Map<String,String> failureReasonMap ;
    public List<String> showList {get; set;}
    public List<String> chkList {get; set;}
    public boolean displaylistpanel {get; set;}
    public boolean displayResult {get; set;}
	public String responseTxt {get; set;}

    public NI_IMT_TestAutomationRunController () 
    {
        displaylistpanel = true;
        displayResult = false;
        options = new List<String>();
        options.add('checkPropertyCountryCode');
        options.add('checkPropertyComplexityValue');
        options.add('checkPropertyUniqueCode');
        options.add('checkPropertyCodeLength');
        options.add('checkGlobalSuperUserPropertyPermission');
        options.add('checkGlobalSuperUserImtContactPermission');
        options.add('checkGlobalSuperUserSchedulingSetPermission');
        options.add('checkGlobalSuperUserProjectTaskPermission');
        options.add('checkGlobalSuperUserProjectPermission');
        options.add('checkGlobalSuperUserEventPermission');
        options.add('checkGlobalSuperUserSchedulePermission');
        options.add('checkGlobalSuperUserKnowledgePermission');
        options.add('checkGlobalSuperUserReportPermission');
        
        options.add('checkGlobalManagerPropertyPermission');
        options.add('checkGlobalManagerImtContactPermission');
        options.add('checkGlobalManagerSchedulingSetPermission');
        options.add('checkGlobalManagerProjectTaskPermission');
        options.add('checkGlobalManagerProjectPermission');
        options.add('checkGlobalManagerEventPermission');
        options.add('checkGlobalManagerSchedulePermission');
        options.add('checkGlobalManagerKnowledgePermission');
        options.add('checkGlobalManagerReportPermission');
        
        optionMap = new Map<Integer,String>();
        optionMap.put(1,'Property Country Code Length');
        optionMap.put(2,'Property Complexity value');
        optionMap.put(3,'Property Code Uniqueness');
        optionMap.put(4,'Property  Code Length');
        optionMap.put(5,'Global Super User Property Access');
        optionMap.put(6,'Global Super User IMT Contact Access');
        optionMap.put(7,'Global Super User Scheduling Set Access');
        optionMap.put(8,'Global Super User Project Task Access');
        optionMap.put(9,'Global Super User Project Access');
        optionMap.put(10,'Global Super User Event Access');
        optionMap.put(11,'Global Super User Schedule Access');
        optionMap.put(12,'Global Super User Knowledge Access');
        optionMap.put(13,'Global Super User Report Access');
        optionMap.put(14,'Global Manager Property Access');
        optionMap.put(15,'Global Manager IMT Contact Access');
        optionMap.put(16,'Global Manager Scheduling Set Access');
        optionMap.put(17,'Global Manager Project Task Access');
        optionMap.put(18,'Global Manager Project Access');
        optionMap.put(19,'Global Manager Event Access');
        optionMap.put(20,'Global Manager Schedule Access');
        optionMap.put(21,'Global Manager Knowledge Access');
        optionMap.put(22,'Global Manager Report Access');
        
        optionsDesc = new List<String>();
        optionsDesc.add('The property country code should be 2 characters');
        optionsDesc.add('The property complexity value must be maximum 20');
        optionsDesc.add('The property code must be unique');
        optionsDesc.add('The property code must be 5 characters only and cannot contain numbers');
        optionsDesc.add('Check the Property access permission for Global Super User profile');
        optionsDesc.add('Check the IMT Contact access permission for Global Super User profile');
        optionsDesc.add('Check the Scheduling Set access permission for Global Super User profile');
        optionsDesc.add('Check the Project Task access permission for Global Super User profile');
        optionsDesc.add('Check the Project access permission for Global Super User profile');
        optionsDesc.add('Check the Event access permission for Global Super User profile');
        optionsDesc.add('Check the Schedule access permission for Global Super User profile');
        optionsDesc.add('Check the Knowledge access permission for Global Super User profile');
        optionsDesc.add('Check the Report access permission for Global Super User profile');
        optionsDesc.add('Check the Property access permission for Global Manager profile');
        optionsDesc.add('Check the IMT Contact access permission for Global Manager profile');
        optionsDesc.add('Check the Scheduling Set access permission for Global Manager profile');
        optionsDesc.add('Check the Project Task access permission for Global Manager profile');
        optionsDesc.add('Check the Project access permission for Global Manager profile');
        optionsDesc.add('Check the Event access permission for Global Manager profile');
        optionsDesc.add('Check the Schedule access permission for Global Manager profile');
        optionsDesc.add('Check the Knowledge access permission for Global Manager profile');
        optionsDesc.add('Check the Report access permission for Global Manager profile');
        status = new List<String>();
        failureReason = new List<String>();
        chkbox = new List<boolean>();
        for(integer i=0;i<options.size();i++){
            status.add('');
            failureReason.add('');
            chkbox.add(false);
        }
    }
     
    public class MyWrapper{
      	public string testmethodname2 {get; set;}
        public string testcasename2 {get; set;}
        public string desc2 {get; set;}
        public string status2 {get; set;}
        public boolean chkbox2 {get; set;}
		public string failureReason2 {get; set;}
        MyWrapper(string methodName, string caseName, string description, string testStatus, boolean cb, String failureReason){ // 
			this.testmethodname2 = methodName;
            this.testcasename2 = caseName;
            this.desc2 = description;
            this.status2 = testStatus;
            this.chkbox2 = cb;
            this.failureReason2 = failureReason;
        }
   }
   
   public List<MyWrapper> myWrapperList {
        get{
            if(myWrapperList == null){
                myWrapperList = new List<MyWrapper>();
                for(integer i=0;i<optionMap.size();i++){
                    myWrapperList.add(new MyWrapper(options[i], optionMap.get(i+1), optionsDesc[i],status[i],chkbox[i],failureReason[i]));
                }
            }
            return myWrapperList;
        }
        private set;
    }
        
    public PageReference test() {
        
        chkList = new List<String>();
        for(MyWrapper m : myWrapperList) {
            if(m.chkbox2) {
                chkList.add(m.testmethodname2);
            }             
        }
        System.debug('List: '+chkList);
            
   
        if(chkList != null) {
    
            displayResult = true;
            displaylistpanel = false;
        
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            
            String jString = '[{"classId": "01p17000000FvTB","testMethods": ["';
            for(integer i=0;i<chkList.size();i++){
                jString = jString + chkList[i] + '","';
            }
            jString = jString.removeEnd(',"');
            string endstring = ']}]'; 
            jString = jString + endString;
            String url = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v28.0/tooling/runTestsSynchronous/';
            //String url = 'https://cs22.salesforce.com/services/data/v28.0/tooling/runTestsSynchronous/';
            req.setEndpoint(url);
            req.setBody('{"tests" :'+jString+'}');
            req.setTimeout(120000);
            req.setMethod('POST');
            
            HttpResponse res = new HttpResponse();
            Http h =new Http();
            res = h.send(req);
            System.debug('res: '+res);
            system.debug('res body : '+res.getBody());
            
            List<string> successList = new List<string>();
            List<string> failureList = new List<string>();
            StatusMap =  new Map<String , String>();
            failureReasonMap =  new Map<String , String>();
            
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                system.debug(parser.getText());
                if(parser.getText() == 'successes') {
                    String successName = '';
                    while(Parser.getText()!= 'failures'){
                        if(Parser.getText() =='methodName'){
                            Parser.nextToken();
                            successName = successName + parser.getText();
                            successList.add(successName);
                            statusMap.put(successName,'PASS');
                            successName = '';
                        }
                        parser.nextToken();
                    }
                }     
                if(Parser.getText()=='failures') {
                    String failureName = '';
                    String failureReason = '';
                    While(parser.nextToken() != null) {
                        if(Parser.getText() =='methodName') {
                            Parser.nextToken();
                            failureName = failureName+parser.getText();
                            failureList.add(failureName);
                            statusMap.put(failureName,'FAIL');
                            Parser.nextToken();
                            Parser.nextToken();
                            failureReason = parser.getText();
                            Parser.nextToken();
                            Parser.nextToken();
                            failureReason += ' ' + parser.getText();
                            failureReasonMap.put(failureName,failureReason);
                            failureName = '';
                            failureReason = '';
                        }
                    }
                }
            }                     
            for(MyWrapper w : myWrapperList) {
                if(statusMap.containskey(w.testmethodname2)){ 
                    w.status2 = statusMap.get(w.testmethodname2);  
                    if(statusMap.get(w.testmethodname2) == 'FAIL') {
                    	w.failureReason2 = 	failureReasonMap.get(w.testmethodname2);
                    }
                }
                else{
                    w.status2 = '';
                }
            }
            system.debug('successList: '+successList);
            system.debug('failureList: '+failureList);  
        }
        else {
            System.debug('No test Selected');
        }
        return null;
    }
    
    public List<boolean> getchkbox() {
        return chkbox;
    }
    
    public void setchkbox(List<boolean> chkbox) {
        this.chkbox = chkbox;
    }
    
}