/************************************************************************************************
Name            : AH_SourceVersionsCtrl Class
Author          : Sean Harris
Created Date    : 10/12/2018
Last Mod Date   : 10/12/2018
Last Mod By     : Sean Harris
NICC Reference  :
Description     : 
                : 
*************************************************************************************************/
public class AH_SourceVersionsCtrl 
{
    
    public String currentCreated {get; set;} 
    public String currentSyntax {get; set;} 
    public String created01 {get; set;} 
    public String syntax01 {get; set;} 
    public String created02 {get; set;} 
    public String syntax02 {get; set;} 
    public String created03 {get; set;} 
    public String syntax03 {get; set;} 
    public String created04 {get; set;} 
    public String syntax04 {get; set;} 
    public String created05 {get; set;} 
    public String syntax05 {get; set;} 
    public String created06 {get; set;} 
    public String syntax06 {get; set;} 
    public String created07 {get; set;} 
    public String syntax07 {get; set;} 
    public String created08 {get; set;} 
    public String syntax08 {get; set;} 
    public String created09 {get; set;} 
    public String syntax09 {get; set;} 
    public String strTitle {get; set;} 

    public AH_SourceVersionsCtrl()
    {
        
        if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
        {  

            integer i = 1;
            string strHeader = '';
            string strSyntax = '';
            DateTime dt;
            string strDT = '';
            
            AH_SFDC_Source_Control__c ssControl = [SELECT Id, CreatedDate, Syntax__c, API_Name__c  
                                                   FROM AH_SFDC_Source_Control__c 
                                                   WHERE Id =: ApexPages.CurrentPage().getParameters().get('id')];
            
            strTitle = 'Version History for: ' + ssControl.API_Name__c;
            dt = ssControl.CreatedDate;
            strDT = dt.format('MM/dd/yyy h:mm a');
            strHeader = 'Current Last Modified Date: ' + strDT;
            strSyntax = ssControl.Syntax__c;
            
            currentCreated = strHeader;
            currentSyntax = strSyntax;
            
            
            for (AH_SFDC_Source_Version__c ver : [SELECT Id, CreatedDate, Syntax__c FROM AH_SFDC_Source_Version__c 
                                                  WHERE SFDC_Source_Control__c =: ssControl.Id 
                                                  ORDER BY CreatedDate DESC 
                                                  LIMIT 9])
            {
                
                if (i == 10)
                {
                    break;
                }
                
                dt = ver.CreatedDate;
            	strDT = dt.format('MM/dd/yyy h:mm a');
                strHeader = 'Last Active Date: ' + strDT;
                strSyntax = ver.Syntax__c;
                
                if (i == 1)
                {
                    created01 = strHeader;
                    syntax01 = strSyntax;
                }
                if (i == 2)
                {
                    created02 = strHeader;
                    syntax02 = strSyntax;
                }
                if (i == 3)
                {
                    created03 = strHeader;
                    syntax03 = strSyntax;
                }
                if (i == 4)
                {
                    created04 = strHeader;
                    syntax04 = strSyntax;
                }
                if (i == 5)
                {
                    created05 = strHeader;
                    syntax05 = strSyntax;
                }
                if (i == 6)
                {
                    created06 = strHeader;
                    syntax06 = strSyntax;
                }
                if (i == 7)
                {
                    created07 = strHeader;
                    syntax07 = strSyntax;
                }
                if (i == 8)
                {
                    created08 = strHeader;
                    syntax08 = strSyntax;
                }
                if (i == 9)
                {
                    created09 = strHeader;
                    syntax09 = strSyntax;
                }
                i++;
            }
            
        }

        
    }
       
}