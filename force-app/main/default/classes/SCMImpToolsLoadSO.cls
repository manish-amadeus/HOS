global with sharing class SCMImpToolsLoadSO implements Schedulable, Database.Batchable<SObject>{
	private ApexPages.StandardSetController setController;
	
	global SCMImpToolsLoadSO() {
	}

    // this constructor is invoked from the multi select on the SOStage object view
    public SCMImpToolsLoadSO(ApexPages.StandardSetController controller) {
    	this.setcontroller = controller;
	}
    
	public PageReference process() {
		Database.executeBatch(this, 100);
		// Get the sObject describe result for the Catalog Load object
		Schema.DescribeSObjectResult r = SCMC__Sales_Order__c.sObjectType.getDescribe(); 
		String keyPrefix = r.getKeyPrefix();
		PageReference retPage = new PageReference('/' + keyPrefix + '/o');
		
		return retPage;
	}
	
	public PageReference goback() {
		PageReference retPage = setController.cancel();
		return retPage;
	}
	
	global void execute(SchedulableContext ctx) {       
        // Start Batch Apex job to pull requests and create requisitions
        Database.executeBatch(new SCMImpToolsLoadSO());              
    }
    
   	global Database.QueryLocator start(Database.BatchableContext ctx) {
        // Select all requests that don't yet have requisition associated with them
        return Database.getQueryLocator([Select id
        		,name
        		,Account__c
        		,Unit_Price__c
        		,Customer__c
        		,Quantity__c
        		,Loaded__c
        		,Item__c
        		,Existing_SO_Number__c
        		,Error__c
        		,Error_Message__c
        		,Customer_PO__c
        		,Currency__c
        		,SO_Date__c
         	From SCMImpToolsSO_Stage__c 
			where Loaded__c = false
			order by Existing_SO_Number__c]);
    }
   
    global void execute(Database.BatchableContext ctx, List<SObject> records){
    	Map<String, SCMC__Sales_Order__c>so = 
    		new Map<String, SCMC__Sales_Order__c>();
    	Map<String, List<SCMC__Sales_Order_Line_Item__c>> lines =
    		new Map<String, List<SCMC__Sales_Order_Line_Item__c>>();
    	String currSO = '';
    	Map<String, SCMC__Sales_Order__c>existSO = new Map<String, SCMC__Sales_Order__c>();
    	Map<String, SCMC__Item__c>items = new Map<String, SCMC__Item__c>();
    	Map<String, SCMC__Ownership_Code__c>owns = new Map<String, SCMC__Ownership_Code__c>();
    	Map<String, Account>customers =	new Map<String, Account>();
    	Map<ID, Account>accounts = new Map<ID, Account>();
    	Map<String, SCMC__Currency_Master__c>currs = new Map<String, SCMC__Currency_Master__c>();
    	for (SObject record : records){
    		SCMImpToolsSO_Stage__c stage = (SCMImpToolsSO_Stage__c)record;
    		items.put(stage.Item__c, null);
    		if (stage.Account__c == null){
     			String customer = stage.Customer__c;
    			customers.put(customer, null);
    		}else {
    			accounts.put(stage.Account__c, null);
    		}
    		existSO.put(stage.Existing_SO_Number__c, null);
    	}
    	/*List<SCMC__Sales_Order__c>exSOs = [select id, Existing_SO_Number__c from SCMC__Sales_Order__c
    			where Existing_SO_Number__c in :existSO.Keyset()];
    	for (SCMC__Sales_Order__c exSO : exSOs){
    		existSO.put(exSO.Existing_SO_Number__c, exSO);
    	}*/
    	List<SCMC__Currency_Master__c>cmasters = [select id
    			,name
    		from SCMC__Currency_Master__c
			limit 500];
		for (SCMC__Currency_Master__c cmaster : cmasters){
			currs.put(cmaster.name, cmaster);
		}
    	List<SCMC__Item__c>lItems = [select id, name 
    			from SCMC__Item__c
    			where name in :items.keySet()];
    	for (SCMC__Item__c item : lItems){
    		items.put(item.name, item);
    	}
    	
     	List<Account>lSites = [select id, name 
     				,SCMC__Active__c
     				,SCMC__Temporary_Hold__c
    			from Account
    			where name in :customers.keySet() and
    			SCMC__Active__c = true and
    			SCMC__Customer__c = true];
    	for (Account site : lSites){
    		customers.put(site.name, site);
    	}
    	List<Account>ISites = [select id, name 
     				,SCMC__Active__c
     				,SCMC__Temporary_Hold__c
    			from Account
    			where id in :accounts.keySet() and
    			SCMC__Active__c = true and
    			SCMC__Customer__c = true];
    	for (Account site : ISites){
    		accounts.put(site.id, site);
    	}
    	List<RecordType>rtypes = [select id
    		from RecordType
    		where DeveloperName = 'Item' and
    		SobjectType = 'SCMC__Sales_Order_Line_Item__c'];
    	boolean headErr = false;
    	for (SObject record : records){
    		SCMImpToolsSO_Stage__c stage = (SCMImpToolsSO_Stage__c)record;
    		Integer lineNum = 0;
    		if (currSO != stage.Existing_SO_Number__c){
    			//we have the full SO start a new 
    			lineNum = 0;
    			currSO = stage.Existing_SO_Number__c;
    			headErr = false;
    			SCMC__Sales_Order__c head = existSO.get(currSO);
    			if (head != null){
    				System.debug('SO already exists for ' + currSO);
    			} else {
    				System.debug('Creating new head for ' + currSO);
    				head = new SCMC__Sales_Order__c();
	     			head.SCMC__Customer_Purchase_Order__c = stage.Customer_PO__c;
	     			//head.Existing_SO_Number__c = stage.Existing_SO_Number__c;
	     			if (stage.Currency__c != null){
	     				head.SCMC__Currency__c = currs.get(stage.Currency__c).id;	
	     			}
	     			
	     			//String supplier = stage.Supplier__c.substring(8);
	     			Account site = null;
	     			String customer = '';
	     			if (stage.Account__c == null){
	     				customer = stage.customer__c;
	    				site = customers.get(customer);
    				} else {
    					customer = stage.Account__c;
    					site = accounts.get(customer);
    				}
	    			if (site == null){
	    				stage.Error__c = true;
	    				stage.Error_Message__c = 'Unknown customer ' + customer;
	    			} else if (site.SCMC__Active__c == false){
	    				stage.Error__c = true;
	    				stage.Error_Message__c = 'Customer must be active for a sales order ' + customer;
	    			} else if (site.SCMC__Temporary_Hold__c != null){
						stage.Error__c = true;
	    				stage.Error_Message__c = 'Customer must not be on hold for a sales order ' + customer;
	    				
	    			}else {
	    				head.SCMC__Customer_Account__c  = site.id;
	    			}
	    			head.SCMC__Status__c = 'New';
	    		}
	    		if (stage.Error__c){
	    			headErr = true;
	    		} else {
    				so.put(currsO, head);
	    			List<SCMC__Sales_Order_Line_Item__c>soLines =
	    				new List<SCMC__Sales_Order_Line_Item__c>();
	     			lines.put(currSO, soLines);	
	    		}
    		}
    		if (headErr){
    			stage.Error__c = true;
    		} else {
				List<SCMC__Sales_Order_Line_Item__c>soLines =
					lines.get(currSO);
				//create line and add to list
				SCMC__Sales_Order_Line_Item__c lItem =
					new SCMC__Sales_Order_Line_Item__c();
				lItem.SCMC__Price__c = stage.Unit_Price__c;
				lItem.SCMC__Taxable__c = false;
				lItem.SCMC__Quantity__c = stage.Quantity__c;
				//lItem.Customer_PO__c = stage.Customer_PO__c;
				lItem.SCMC__Line_Number__c = (++lineNum);
				SCMC__Item__c titem = items.get(stage.Item__c);
				if (tItem == null){
					stage.Error__c = true;
					stage.Error_Message__c = 'Unknown item';
				} else {
					lItem.SCMC__Item_Master__c = titem.id;
				}
				lItem.RecordTypeId= rTypes[0].id;
				if (!stage.Error__c){
					soLines.add(lItem);
				}
    		}
    			
       	}
       	Map<String,SCMC__Sales_Order__c>insSO = new Map<String, SCMC__Sales_Order__c>();
       	List<SCMC__Sales_Order_Line_Item__c>inssolines = 
       		new List<SCMC__Sales_Order_Line_Item__c>();
       	for (SObject record : records){
    		SCMImpToolsSO_Stage__c stage = (SCMImpToolsSO_Stage__c)record;
    		if (stage.Error__c){
    			//skip past error lines
    			continue;
    		} else {
    			System.debug('Should not get here ' + stage.Existing_SO_Number__c);
    			insSO.put(stage.Existing_SO_Number__c,so.get(stage.Existing_SO_Number__c));
    		}
    		
       	}
       	System.debug('so to insert ' + insSO);
       	if (insSO.Values().size() > 0){
       		upsert insSO.values();
       	}
       	
       	for (String NSSO : lines.keyset()){
       		List<SCMC__Sales_Order_Line_Item__c>nslines = 
       			lines.get(NSSO);
       		SCMC__Sales_Order__c nsHead = so.get(NSSO);
       		for(SCMC__Sales_Order_Line_Item__c nsline : nslines){
       			nsline.SCMC__Sales_Order__c = nsHead.id;
       		}
       		inssolines.addall(nslines);
       	}
       	insert inssolines;
        for (SObject record : records){
    		SCMImpToolsSO_Stage__c stage = (SCMImpToolsSO_Stage__c)record;
    		if (stage.Error__c){
    			//skip past error lines
    			continue;
    		}
    		stage.Loaded__c = true;
        }
        update records;
    }
    
    global void finish(Database.BatchableContext ctx) {
    }

}