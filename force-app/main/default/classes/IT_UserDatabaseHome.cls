/****************************************************************************************
Name            : IT_UserDatabaseHome Class
Author          : Stuart Emery
Created Date    : 4/1/2015
Last Mod Date   : 4/1/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Class for IT_UserDatabaseHome Visualforce Page
                :              
******************************************************************************************/
public class IT_UserDatabaseHome {
    
    //TRACK THE SOQL OFFSET
    private integer counter=0;
    
    //SETS THE NUMBER OF ROWS PER PAGE 
    private integer list_size=20;
    
    //TOTAL NUMBER OF RECORDS  
    public integer total_size;
    
    //LIST TO HOLD THE USER RECORDS  
    public List<User> lstUsers {get; set;}
    
    //STRING TO HOLD THE NAME OF THE USER 
    public String strName {get; set;}
    
    //STRING TO HOLD THE WILDCARD NAME OF THE USER FOR THE SEARCH 
    public String strNameSearch {get; set;}
    
    
    
    public IT_UserDatabaseHome() {
        
        
        //getUsers();     
        
    }
    //====================================================================================================              
    //QUERY TO RETURN A LIST OF USER RECORDS
    public List<User> getUsers() 
    { 
        if(strName != null)
        {                                                        
            strNameSearch = '%' + strName + '%'; 
            lstUsers = [SELECT Name, Email, DepartmentCode__c, NI_Location__c, ADP_Record_Number__c, IsActive, UserType
                        FROM User
                        WHERE UserType = 'Standard'
                        AND IsActive = true
                        AND Name LIKE :strNameSearch    
                        ORDER BY Name ASC
                        LIMIT :list_size
                        OFFSET :counter];
            
            total_size = [select count() from User 
                          WHERE 
                          UserType = 'Standard'
                          AND IsActive = true
                          AND Name LIKE :strNameSearch];
            
            
            return lstUsers;                                  
        }
        return null;
    } 
  //=======================================================================================================================  
    public PageReference search() {
        
        getUsers();
        return null;
    }
    //======================================================================================================================
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += list_size;
        return null;
    }
    
    public PageReference End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        return null;
    }
    
    public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons
        if (counter > 0) return false; else return true;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }
    
    public Integer getTotal_size() {
        return total_size;
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
    
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
            
        } else {
            return (total_size/list_size);
        }
    }
    
}