global with sharing class SCMImpToolsLoadPO implements Schedulable, Database.Batchable<SObject>{

	private ApexPages.StandardSetController setController;
	
	global SCMImpToolsLoadPO() {
	}

    // this constructor is invoked from the multi select on the POStage object view
    public SCMImpToolsLoadPO(ApexPages.StandardSetController controller) {
    	this.setcontroller = controller;
	}
    
	public PageReference process() {
		Database.executeBatch(this, 100);
		// Get the sObject describe result for the Catalog Load object
		Schema.DescribeSObjectResult r = SCMC__Purchase_Order__c.sObjectType.getDescribe(); 
		String keyPrefix = r.getKeyPrefix();
		PageReference retPage = new PageReference('/' + keyPrefix + '/o');
		
		return retPage;
	}
	
	public PageReference goback() {
		PageReference retPage = setController.cancel();
		return retPage;
	}
    global void execute(SchedulableContext ctx)
    {       
        // Start Batch Apex job to pull requests and create requisitions
        Database.executeBatch(new SCMImpToolsLoadPO());              
    }
   	global Database.QueryLocator start(Database.BatchableContext ctx)
   	{
        // Select all requests that don't yet have requisition associated with them
        return Database.getQueryLocator([Select id
        		,name
        		,Unit_Cost__c
        		,Supplier__c
        		,Supplier_Commitment_Date__c
        		,Shipping_Addressee__c
        		,Ship_to_Warehouse__c
        		,Quantity__c
        		,Procured_For__c
        		,PO_Date__c
        		,Ownership__c
        		,Loaded__c
        		,Item__c
        		,Existing_SO_Number__c
        		,Existing_PO_Number__c
        		,Error__c
        		,Error_Message__c
         	From SCMImpToolsPO_Stage__c p
			where Loaded__c = false and
			Error__c = false
			order by Existing_PO_Number__c]);
    }
    
   
    global void execute(Database.BatchableContext ctx, List<SObject> records){
    	Map<String, SCMC__Purchase_Order__c>po = 
    		new Map<String, SCMC__Purchase_Order__c>();
    	Map<String, List<SCMC__Purchase_Order_Line_Item__c>> lines =
    		new Map<String, List<SCMC__Purchase_Order_Line_Item__c>>();
    	String currPO = '';
    	Map<String, SCMC__Purchase_Order__c>existPO = new Map<String, SCMC__Purchase_Order__c>();
    	Map<String, SCMC__Item__c>items = new Map<String, SCMC__Item__c>();
    	//Map<String, SFDC_Project__c>installations = new Map<String, SFDC_Project__c>();
    	Map<String, SCMC__Warehouse__c> houses =  new Map<String, SCMC__Warehouse__c>();
    	Map<String, SCMC__Ownership_Code__c>owns = new Map<String, SCMC__Ownership_Code__c>();
    	Map<String, SCMC__Supplier_Site__c>sites =
    		new Map<String, SCMC__Supplier_Site__c>();
    	Map<String, Account>accounts = new Map<String, Account>();
    	Map<String, RecordType>potypes = new Map<String, RecordType>();
    	RecordType[]typelist = [select id, name, DeveloperName
    			from RecordType
    			where sobjectType = 'SCMC__Purchase_Order__c'];
    	for (RecordType typel : typelist){
    		potypes.put(typel.name, typel);
    	}
    	for (SObject record : records){
    		SCMImpToolsPO_Stage__c stage = (SCMImpToolsPO_Stage__c)record;
    		items.put(stage.Item__c, null);
    		houses.put(stage.Ship_To_Warehouse__c, null);
    		owns.put(stage.Ownership__c, null);
    		//String supplier = stage.Supplier__c.substring(8);
     		String supplier = stage.Supplier__c;
    		sites.put(supplier, null);
    		accounts.put(stage.Procured_For__c, null);
    		existPO.put(stage.Existing_PO_Number__c, null);
    		//installations.put(stage.Installation__c,null);
    	}
    	/*List<SCMC__Purchase_Order__c>exPOs = [select id, Existing_PO_Number__c from SCMC__Purchase_Order__c
    			where Existing_PO_Number__c in :existPO.Keyset()];
    	for (SCMC__Purchase_Order__c exPO : exPOs){
    		existPO.put(exPO.Existing_PO_Number__c, exPO);
    	}*/
    	List<SCMC__Currency_Master__c>cmasters = [select id
    			,name
    		from SCMC__Currency_Master__c
    		limit 500];
    	Map<String, SCMC__Currency_Master__c>currs = new Map<String, SCMC__Currency_Master__c>();
    	for (SCMC__Currency_Master__c cm : cmasters){
    		currs.put(cm.name, cm);
    	}
    	List<SCMC__Item__c>lItems = [select id, name 
    			from SCMC__Item__c
    			where name in :items.keySet()];
    	for (SCMC__Item__c item : lItems){
    		items.put(item.name, item);
    	}
    	List<SCMC__Warehouse__c>house = [select id, name 
    			from SCMC__Warehouse__c
    			where name in :houses.keySet()];
    	for (SCMC__warehouse__c whouse : house){
    		houses.put(whouse.name, whouse);
    	}
     	List<SCMC__Ownership_Code__c>lowns = [select id, name 
    			from SCMC__Ownership_Code__c
    			where name in :owns.keySet()];
    	for (SCMC__Ownership_Code__c own : lowns){
    		owns.put(own.name, own);
    	}
     	List<SCMC__Supplier_Site__c>lSites = [select id, name 
    			from SCMC__Supplier_Site__c
    			where name in :sites.keySet()];
    	for (SCMC__supplier_Site__c site : lSites){
    		sites.put(site.name, site);
    	}
    	List<account>laccounts = [select id, name 
    			from Account
    			where name in :accounts.keySet()];
    	for (Account account : laccounts){
    		accounts.put(account.name, account);
    	}
    	SCMC__PO_Payment_Terms__c poTerms = null;
    	poTerms = [select id
	    		from SCMC__PO_Payment_Terms__c
	    		where SCMC__Terms_Name__c = 'Net 30'];
    	SCMC__Condition_Code__c ccode = null;
    	
    	/*List<SFDC_Project__c>insts = [select id, name 
    			,Hardware_Shipping_Date__c
    			from SFDC_Project__c
    			where name in :installations.keySet()];
    	for (SFDC_Project__c inst : insts){
    		installations.put(inst.name, inst);
    	}*/
    	
    	/*
    	ccode = [select id
	    		from SCMC__Condition_Code__c
	    		where name = 'New'];
	    		*/
    	List<RecordType>rtypes = [select id
    		from RecordType
    		where DeveloperName = 'Item' and
    		SobjectType = 'SCMC__Purchase_Order_Line_Item__c'];
    	boolean headErr = false;
    	for (SObject record : records){
    		SCMImpToolsPO_Stage__c stage = (SCMImpToolsPO_Stage__c)record;
    		Integer lineNum = 0;
    		if (currPO != stage.Existing_PO_Number__c){
    			//we have the full PO start a new 
    			lineNum = 0;
    			currPO = stage.Existing_PO_Number__c;
    			headErr = false;
    			SCMC__Purchase_Order__c head = existPO.get(currPO);
    			if (head != null){
    				System.debug('PO already exists for ' + currPO);
    			} else {
    				System.debug('Creating new head for ' + currPO);
    				head = new SCMC__Purchase_Order__c();
	     			//head.Existing_PO_Number__c = stage.Existing_PO_Number__c;
	     			//String supplier = stage.Supplier__c.substring(8);
	     			String supplier = stage.Supplier__c;
	    			SCMC__Supplier_Site__C site = sites.get(supplier);
	    			if (site == null){
	    				stage.Error__c = true;
	    				stage.Error_Message__c = 'Unknown supplier ' + supplier;
	    			}else {
	    				head.SCMC__Supplier_Site__c  = site.id;
	    			}
	    			head.SCMC__Status__c = 'Approved';
	    			head.SCMC__Status_Change_Date__c = System.Today();
	    			SCMC__Warehouse__c thouse = houses.get(stage.Ship_to_Warehouse__c);
	    			if (thouse == null){
	    				stage.Error__c = true;
	    				stage.Error_Message__c = 'Unknown warehouse';
	    			}else {
	    				head.SCMC__Ship_To_Warehouse__c = thouse.id;
	    			}
	    			head.SCMC__Purchase_Order_Date__c = stage.PO_Date__c;
	    			if (POterms == null){
	    				stage.Error__c = true;
	    				stage.Error_Message__c = 'Net 30 terms not defined';
	    			} else {
	    				head.SCMC__Payment_Terms__c = POterms.id;
	    			}
	    			if (stage.ownership__c != null){
		    			SCMC__Ownership_Code__c owncode = owns.get(stage.ownership__c);
		    			if (owncode == null){
		    				stage.Error__c = true;
		    				stage.Error_Message__c = 'Unknown ownership';
		    			} else {
		    				head.SCMC__Ownership__c = owns.get(stage.ownership__c).id;
		    			}
	    			}
	    			//head.NetSuite_Sales_Order__c = stage.Existing_SO_Number__c;
	    			Account cust = accounts.get(stage.Procured_For__c);
	    			if (cust != null){
	    				head.SCMC__Procured_for__c = cust.id;
	    				//head.Procured_For__c = cust.id;	
	    			}
	    			/*
	    			if (stage.CurrencyIsoCode != null){
	    				head.CurrencyIsoCode = stage.CurrencyIsoCode;
	    				head.Currency__c = currs.get(stage.CurrencyIsoCode).id;	
	    			}
	    			*/
	    			/*if (stage.Installation__c != null){
	    				head.Installation__c = installations.get(stage.Installation__c).id;
	    				if (head.Installation__c == null){
	    					stage.Error__c = true;
	    					stage.Error_Message__c += ' Unknown Installation';
	    				}
	    			}*/
	    			/*if (stage.record_type__c != null){
	    				RecordType poType = poTypes.get(stage.Record_Type__c);
	    				if (poType == null){
	    					stage.Error__c = true;
	    					stage.Error_Message__c += ' Unknown RecordTYpe';
	    				}else{
	    					head.RecordTypeID = poType.id;
	    				}
	    			}*/
	    		}
	    		if (stage.Error__c){
	    			headErr = true;
	    		} else {
    				po.put(currPO, head);
	    			List<SCMC__Purchase_Order_Line_Item__c>poLines =
	    				new List<SCMC__Purchase_Order_Line_Item__c>();
	     			lines.put(currPO, poLines);	
	    		}
    		}
    		if (headErr){
    			stage.Error__c = true;
    		} else {
				List<SCMC__Purchase_Order_Line_Item__c>poLines =
					lines.get(currPO);
				//create line and add to list
				SCMC__Purchase_Order_Line_Item__c lItem =
					new SCMC__Purchase_Order_Line_Item__c();
				lItem.SCMC__Unit_Cost__c = stage.Unit_Cost__c;
				lItem.SCMC__Taxable__c = false;
				lItem.SCMC__Supplier_Current_Promise_Date__c = stage.Supplier_Commitment_Date__c;
				lItem.SCMC__Supplier_Commitment_Date__c = stage.Supplier_Commitment_Date__c;
				lItem.SCMC__Status__c = 'Approved';
				lItem.SCMC__Status_Change_Date__c = System.Today();
				lItem.SCMC__Sales_Order_Line_Item__c = null;
				lItem.SCMC__Quantity__c = stage.Quantity__c;
				lItem.SCMC__Quantity_Received__c = 0;
				lItem.SCMC__Purchase_Order__c = null;
				lItem.SCMC__Line_Number__c = (++lineNum).format();
				SCMC__Item__c titem = items.get(stage.Item__c);
				if (tItem == null){
					stage.Error__c = true;
					stage.Error_Message__c = 'Unknown item';
				} else {
					lItem.SCMC__Item_Master__c = titem.id;
				}
				/*
				if (ccode == null){
					stage.Error__c = null;
					stage.Error_Message__c = 'Condition Code New is not available';
				} else {
					lItem.SCMC__Condition_Code__c = ccode.id;
				}
				*/
				lItem.RecordTypeId= rTypes[0].id;
				if (!stage.Error__c){
					poLines.add(lItem);
				}
    		}
    			
       	}
       	Map<String,SCMC__Purchase_Order__c>insPO = new Map<String, SCMC__Purchase_Order__c>();
       	List<SCMC__Purchase_Order_Line_Item__c>inspolines = 
       		new List<SCMC__Purchase_Order_Line_Item__c>();
       	for (SObject record : records){
    		SCMImpToolsPO_Stage__c stage = (SCMImpToolsPO_Stage__c)record;
    		if (stage.Error__c){
    			//skip past error lines
    			continue;
    		} else {
    			System.debug('Should not get here ' + stage.Existing_PO_Number__c);
    			insPO.put(stage.Existing_PO_Number__c,po.get(stage.Existing_PO_Number__c));
    		}
    		
       	}
       	System.debug('po to insert ' + insPO);
       	upsert insPO.values();
       	
       	for (String NSPO : lines.keyset()){
       		List<SCMC__Purchase_Order_Line_Item__c>nslines = 
       			lines.get(NSPO);
       		SCMC__Purchase_Order__c nsHead = po.get(NSPO);
       		for(SCMC__Purchase_Order_Line_Item__c nsline : nslines){
       			nsline.SCMC__Purchase_Order__c = nsHead.id;
       		}
       		inspolines.addall(nslines);
       	}
       	insert inspolines;
        for (SObject record : records){
    		SCMImpToolsPO_Stage__c stage = (SCMImpToolsPO_Stage__c)record;
    		if (stage.Error__c){
    			//skip past error lines
    			continue;
    		}
    		stage.Loaded__c = true;
        }
        update records;
    }
    
    global void finish(Database.BatchableContext ctx)
    {
    }
    	
}