public with sharing class PsaMyAssignmentsController 
{
	public List<pse__Assignment__c> assignments{get; set;}
	public Integer lastModDays;
	public Integer startWithinDays;
	public Date maxLastModDate = System.Today() - 5;
	public Date minStartDate = System.Today();
	public Date maxStartDate = System.Today();
	
	public Id userID {get; set;}
	
	public Integer getLastModDays()
	{
		if(lastModDays==0) lastModDays=null;
		return lastModDays;
	}
	
	public void setLastModDays(Integer lmd)
	{
		this.lastModDays = lmd;
	}

	public Integer getStartWithinDays()
	{
		if(startWithinDays==0) startWithinDays=null;
		return startWithinDays;
	}
	
	public void setStartWithinDays(Integer swd)
	{
		this.startWithinDays = swd;
	}
	
	public Date getMaxLastModDate()
	{
		return maxLastModDate;
	}

	// the soql without the order and limit
  	private String soql {get;set;}
  	
	// the current sort direction. defaults to asc
	public String sortDir 
	{
		get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
		set;
	}
  
  	// the current field to sort by. defaults to last name
  	public String sortField 
  	{
    	get  { if (sortField == null) {sortField = 'pse__Start_Date__c'; } return sortField;  }
   		set;
  	}
  	
	// toggles the sorting of query from asc<-->desc
	public void toggleSort() 
	{
		// simply toggle the direction
		sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
		// run the query again
		runQuery();
	}
  
  	public PsaMyAssignmentsController()
  	{
  		lastModDays = 5;
  		//startWithinDays = 10;
  		userID = UserInfo.getUserId();
  		soql = 'SELECT Id, Name, pse__Assignment_Number__c, pse__Start_Date__c, pse__End_Date__c, pse__Location__c, pse__Milestone__r.Name, ' +
  			'pse__Project__r.Name, pse__Scheduled_Days__c, pse__Scheduled_Hours__c, pse__Status__c, LastModifiedDate ' +
  			'FROM pse__Assignment__c WHERE pse__Resource__r.pse__Salesforce_User__c = :userID AND LastModifiedDate > :maxLastModDate';
  		runQuery();
  	}
  	
	// runs the actual query
	public void runQuery() 
	{
		try
		{
			assignments = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 75');
		} 
		catch (Exception e) 
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occurred: ' + e.getMessage()));
		}
  	}
  	
	// Runs the search with parameters passed via Javascript
	public PageReference runSearch() 
	{
    	//String modDays = Apexpages.currentPage().getParameters().get('modDays');
    	//String swDays = Apexpages.currentPage().getParameters().get('startWithinDays');
    	
		soql = 'SELECT Id, Name, pse__Assignment_Number__c, pse__Start_Date__c, pse__End_Date__c, pse__Location__c, pse__Milestone__r.Name, ' +
  			'pse__Project__r.Name, pse__Scheduled_Days__c, pse__Scheduled_Hours__c, pse__Status__c, LastModifiedDate ' +
  			'FROM pse__Assignment__c WHERE pse__Resource__r.pse__Salesforce_User__c = :userID';
  		
  		try
  		{
  			/*
			if (modDays != null && !modDays.equals(''))
			{
				lastModDays = Integer.valueOf(modDays);
				this.maxLastModDate = System.Today().addDays(-lastModDays);
				soql += ' AND LastModifiedDate > :maxLastModDate';
			}
			
			if (swDays != null && !swDays.equals(''))
			{
				startWithinDays = Integer.valueOf(swDays);
				this.minStartDate = System.Today();
				this.maxStartDate = System.Today().addDays(startWithinDays);
				//soql += ' AND (pse__Start_Date__c >= :minStartDate OR pse__Start_Date__c <= :maxStartDate)';
				soql += ' AND pse__Start_Date__c >= :minStartDate AND pse__Start_Date__c <= :maxStartDate';
			}
			*/

			if (lastModDays != null && lastModDays!=0)
			{
				this.maxLastModDate = System.Today().addDays(-lastModDays);
				soql += ' AND LastModifiedDate > :maxLastModDate';
			}
			
			if (startWithinDays != null && startWithinDays !=0)
			{
				this.minStartDate = System.Today();
				this.maxStartDate = System.Today().addDays(startWithinDays);
				//soql += ' AND (pse__Start_Date__c >= :minStartDate OR pse__Start_Date__c <= :maxStartDate)';
				soql += ' AND pse__Start_Date__c >= :minStartDate AND pse__Start_Date__c <= :maxStartDate';
			}
			
			runQuery();
  		}
  		catch(Exception e)
  		{
  			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
  		}

    	return null;
	}
}