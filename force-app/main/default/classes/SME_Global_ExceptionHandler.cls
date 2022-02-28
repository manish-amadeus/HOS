/**************************************************************************************************   
Apex Class Name 	 :  SME_Global_ExceptionHandler
Version              :  2.0                                                                          
Created Date         :  Sep 29,2020                                                        
Function             :  This is the exception logger class which is used to log the exceptions being happened in the apex transaction 
							and we can see the logs in exception object records
Story                :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                   Date                   Description                                    
* -------------------------------------------------------------------------------------------------  

* Kathir                      Sep 29,2020             Second Iteration
***************************************************************************************************/
public with sharing class SME_Global_ExceptionHandler {
    
    //private singleton constructor
    private SME_Global_ExceptionHandler(){
    }

    // Log Exception
    public static void logExceptions (List<ExceptionWrapper> exceprionWrappers) {
        List<SME_Exception_Log__c> exceptionLogs = new List<SME_Exception_Log__c>();
        for(ExceptionWrapper exceprionWrapper : exceprionWrappers){
            exceptionLogs.add(exceprionWrapper.exceptionLog);
        }
        insert exceptionLogs;
    }

    /**********************************************************************************************
     * Method Name: processException
     * Parameter Name: componentName,methodName,ex
     * Purpose: This will log the exception details in exception log custom object.
    ***********************************************************************************************/
    public static void processException(String componentName, String methodName, Exception ex){
        List<ExceptionWrapper> lstwrapper = new List<ExceptionWrapper>();
        Integer count = 1;
        if(ex.getTypeName() == 'System.DmlException' &&  !Test.isRunningTest()){
            count = ex.getNumDml();
        }
            
        
        for (Integer index = 0; index < count; index++) { 
        	// Process exception here System.debug(e.getDmlMessage(i)); 
         	ExceptionWrapper objwrapper = new ExceptionWrapper(componentName, methodName, null, ex);
            lstwrapper.add(objwrapper);
        }
        logExceptions(lstwrapper);
    }
    
    /**********************************************************************************************
     * Method Name: processException
     * Parameter Name: componentName,methodName,apexJobId,ex
     * Purpose: This will log the exception details in exception log custom object.
    ***********************************************************************************************/
    public static void processException(String componentName, String methodName, String apexJobId, Exception ex){
    	List<ExceptionWrapper> lstwrapper = new List<ExceptionWrapper>();
        ExceptionWrapper objwrapper = new ExceptionWrapper(componentName, methodName, apexJobId, ex);
        lstwrapper.add(objwrapper);
        logExceptions(lstwrapper);
    }
    
    
    public class ExceptionWrapper {
        SME_Exception_Log__c exceptionLog;

        public ExceptionWrapper(String componentName, String methodName,String apexJobId, Exception ex){
            exceptionLog = new SME_Exception_Log__c (
                    SME_Apex_Component__c       = componentName,
                    SME_Apex_Method__c          = methodName,
                    SME_Exception_Message__c    = ex.getMessage(),
                    SME_Line_Number__c          = ex.getLineNumber(),
                    SME_Stack_Trace__c          = ex.getStackTraceString(),
                    SME_Exception_Type__c       = ex.getTypeName(),
                    SME_Running_User__c         = UserInfo.getUserId(),
                    XAAS_ApexJobId__c           = apexJobId
            );
        }
    }

}