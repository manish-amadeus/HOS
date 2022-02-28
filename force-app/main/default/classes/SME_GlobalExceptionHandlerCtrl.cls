/*
    Class for Exception Handling
*/

public with sharing class SME_GlobalExceptionHandlerCtrl {

    // Log Exception
    public static void logExceptions (List<ExceptionWrapper> exceprionWrappers) {
        List<SME_Exception_Log__c> exceptionLogs = new List<SME_Exception_Log__c>();
        for(ExceptionWrapper exceprionWrapper : exceprionWrappers){
            exceptionLogs.add(exceprionWrapper.exceptionLog);
        }
        insert exceptionLogs;
    }

    
    public static void processException(String componentName, String methodName, Exception e){
        system.debug('Enter in Process Exception');
        List<ExceptionWrapper> lstwrapper = new List<ExceptionWrapper>();
        Integer count = 1;
        if(e.getTypeName() == 'System.DmlException')
            count = e.getNumDml();
        
        for (Integer i = 0; i < count; i++) { 
        	// Process exception here System.debug(e.getDmlMessage(i)); 
         	ExceptionWrapper objwrapper = new ExceptionWrapper(componentName, methodName, e);
            lstwrapper.add(objwrapper);
        }
        for(ExceptionWrapper exp: lstwrapper){
            System.debug('componentName>>>>' + exp);
        }
        logExceptions(lstwrapper);
        }
    
    
    public class ExceptionWrapper {
        SME_Exception_Log__c exceptionLog;

        public ExceptionWrapper(String componentName, String methodName, Exception e){
            exceptionLog = new SME_Exception_Log__c (
                    SME_Apex_Component__c       = componentName,
                    SME_Apex_Method__c          = methodName,
                    SME_Exception_Message__c    = e.getMessage(),
                    SME_Line_Number__c          = e.getLineNumber(),
                    SME_Stack_Trace__c          = e.getStackTraceString(),
                    SME_Exception_Type__c       = e.getTypeName(),
                    SME_Running_User__c         = UserInfo.getUserId()
            );
        }
    }

}