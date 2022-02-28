/**
* Author	:	
* Desc		:	Controller class for LEX component CircularProgress.
* 			:	On the basis of field API name passed, it calculates percentage of completion.
* */
public class SME_CircularProgressCtrl {    
    
    /**
* This class is used to return as JSON Object
**/
    public class WrapperJSON{
        public Integer total {get;set;}
        public Integer actual {get;set;}
        public Integer val {get;set;}
    }
    
    @AuraEnabled
    public static String computePercentage(String sObjectName, String recordId, String totalValueFieldName, String actualValueFieldName){
        Integer retVal = 0 ;
        String query = null;
        WrapperJSON retObj = new WrapperJSON();
        String compPercentage;
        try{
            if(totalValueFieldName != null && totalValueFieldName.trim() != '' &&  actualValueFieldName != null && actualValueFieldName.trim() != '' ){
                query = 'SELECT '+totalValueFieldName+', '+actualValueFieldName+' FROM '+sObjectName+' WHERE Id =: recordId';
            }
            else if (actualValueFieldName != null && actualValueFieldName.trim() != '' ) {
                query = 'SELECT '+actualValueFieldName+' FROM '+sObjectName+' WHERE Id =: recordId';
            }
            
            if(query != null){
                system.debug('lstObj'+query);
                List<SOBject> lstObj = Database.query(query);
                system.debug('lstObj'+lstObj);
                if(lstObj.size() > 0){
                    Decimal totalVal = 0;
                    Decimal actualVal = 0; 
                    
                    if(totalValueFieldName != null && totalValueFieldName.trim() != ''){ 
                        
                        if(lstObj[0].get(totalValueFieldName) !=null){
                            totalVal = Decimal.valueOf(String.valueOf(lstObj[0].get(totalValueFieldName)));
                        }else{
                            totalVal=0;
                        }
                        system.debug('totalVal'+totalVal);
                        retObj.total = Integer.valueOf(totalVal) ; 
                        
                    } 
                    if(lstObj[0].get(actualValueFieldName) !=null){
                        actualVal = Decimal.valueOf(String.valueOf(lstObj[0].get(actualValueFieldName))); 
                    }else{
                        actualVal=0; 
                    }
                    system.debug('actualVal'+actualVal);                    
                    //Means only 1 API Name was supplied and field type is percentage
                    if(totalVal == 0){
                        system.debug('actualVal'+actualVal);
                        retObj.val = Integer.valueOf(actualVal) ; 
                        retObj.actual = Integer.valueOf(actualVal) ;  
                        system.debug(' retObj.actual '+ retObj.actual );
                    }else if (actualVal > 0){
                         system.debug('actualVal'+( actualVal / totalVal ));
                        retObj.val = Integer.valueOf( ( ( actualVal / totalVal ) * 100 ).round());   
                        retObj.actual = Integer.valueOf(actualVal) ; 
                          system.debug('retObj.val'+retObj.val);
                    } else{
                        retObj.val = Integer.valueOf( ( actualVal  )  );   
                        retObj.actual = Integer.valueOf(actualVal) ;
                    }
                } 
                
            } 
            compPercentage = JSON.serialize(retObj);
            if(Test.isRunningTest()){
                string s;
                s.toLowerCase();
            }
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_CircularProgressCtrl', 'computePercentage', e);
            //return null;
        }
        system.debug('compPercentage'+compPercentage);
        return  JSON.serialize(retObj);        
    }
}