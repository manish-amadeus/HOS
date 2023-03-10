/***********************************************************************************************
Name            : AH_PLCM_Thank_You
Author          : Vikrant Joshi
Created Date    : 12-june-2019
Last Mod Date   : 12-june-2019
Last Mod By     : Vikrant Joshi
NICC Reference  : 
Description     : Class for Thank you page
************************************************************************************************/
public class AH_PLCM_Thank_You extends AH_PLCM_Common_Class {
    //Variables Declaration
    public string MigrationDate { get; set; }
    public string ProjectName { get; set; }
    Date dtMigrationDate = null;
    string[] arrMonth = new string[]{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};

    public AH_PLCM_Thank_You() {
        List<NI_Documentation__c> lstProjects = null;
        try {
            //Get migration date from NI Documentation record
            lstProjects = new List<NI_Documentation__c>([SELECT Document_Name__c,AH_PLCM_Migration_Date__c, AH_PLCM_Proposed_Migration_Date__c FROM NI_Documentation__c WHERE Id =: ProjectId]);
            
            if(lstProjects != null && lstProjects.size() > 0) {
                if(!String.IsBlank(string.valueOf(lstProjects.get(0).AH_PLCM_Proposed_Migration_Date__c))) {
                    //If requested migration date is selected by user then set value from it
                    dtMigrationDate = lstProjects.get(0).AH_PLCM_Proposed_Migration_Date__c;
                }
                else {
                    //Set migration date value
                    dtMigrationDate = lstProjects.get(0).AH_PLCM_Migration_Date__c;
                }
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

    //Go back to introduction page on click of back button
    public PageReference BackToIntroductionPage() {
        try {
            //Redirect Back to Introduction Page
            return RedirectToPage(PageNames.IntroductionPage, null);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('BackToIntroductionPage',ex);
        }        
    }
}