/***********************************************************************************************
Name            : AH_PLCM_MM_Thank_You
Author          : Tushar Gupta
Created Date    : 02-JULY-2020
Last Mod Date   : 02-JULY-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Class for Thank you page
************************************************************************************************/
public class AH_PLCM_MM_Thank_You extends AH_PLCM_MM_Common_Class {
    //Variables Declaration
     public string MigrationDate { get; set; }
     public string ProjectName { get; set; }
     Date dtMigrationDate = null;
     string[] arrMonth = new string[]{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};

    public AH_PLCM_MM_Thank_You() {
        List<NI_Documentation__c> lstProjects = null;
        try {
            //Get migration date from NI Documentation record
            lstProjects = new List<NI_Documentation__c>([SELECT Document_Name__c,DRC_Call_Date__c FROM NI_Documentation__c WHERE Id =: ProjectId]);
            
            if(lstProjects != null && lstProjects.size() > 0) {
                dtMigrationDate = lstProjects.get(0).DRC_Call_Date__c;
            }
            
            //Fetch Project Name 
            ProjectName=lstProjects.get(0).Document_Name__c;
            //Format date
            MigrationDate = dtMigrationDate.day() + '-' + arrMonth.get(dtMigrationDate.month() - 1) + '-' + dtMigrationDate.year();
            }
        catch (Exception ex) {
            //set error variable to redirect at error page
            IsErrorOccurred = true;
        }
        finally {
            //Release objects memory
            lstProjects = null;
            dtMigrationDate = null;
            arrMonth = null;
        }
    }

     //Go back to welcome page on click of back button
    public PageReference BackToWelcomePage() {
        try {
            //Redirect Back to Welcome Page
            return RedirectToPage(PageNames.WelcomePage, null);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('BackToWelcomePage', ex);
        }        
    }
}