/************************************************************************************************
Name            : OrgNiCls
Author          : Beth Van Belle
Last Mod Date   : 05/05/2022
Last Mod By     : Beth Van Belle
Description     : Utility class to retry insert when rowlock or timeout exception occurs
*************************************************************************************************/
public with sharing class OrgNi {

    public static final Set<String> retriableStatusCodes = new Set<String>{'UNABLE_TO_LOCK_ROW', 'QUERY_TIMEOUT', 'REQUEST_RUNNING_TOO_LONG'};
 
    public static void insertWithRetry(List<sobject> records, integer retries) {
        Boolean success = false;
        Integer retryCount = 0; 
        do { 
            try { 
                Data.create (records);
                success = true;
            } 
            catch (Exception e) 
            {
                if (OrgNi.hasRetriableError(e)) 
                {
                    retryCount++;
                    system.debug(loggingLevel.error, ' insertWithRetry retryCount = '+ retryCount + ' DML rows = ' + limits.getDMLRows());
                }
                else 
                {
                    throw e;
                }
                        
            }
        } 
        while (!success && retryCount < retries);
    }

    //Examines the exception for errors that may be retriable, e.g. locking
    public static Boolean hasRetriableError(System.Exception theException) {

		System.Exception cause = theException;
		
		while (cause != null) {

			if (cause instanceof System.DMLException) {

				System.DmlException dmlException = (System.DmlException)cause;

				for (Integer i = 0; i < dmlException.getNumDml(); i++)
					if (retriableStatusCodes.contains(dmlException.getDmlStatusCode(i)))
						return true;

			}

			cause = theException.getCause();
			
		}

		return false;
    }
	
}