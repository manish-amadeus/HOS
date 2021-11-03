/***********************************************************************************************
Name            : AH_PLCM_Terms_And_Conditions
Author          : Vikrant Joshi
Created Date    : 21-May-2019
Last Mod Date   : 21-May-2019
Last Mod By     : Vikrant Joshi
NICC Reference  : 
Description     : Class for Terms And Conditions page
************************************************************************************************/
public class AH_PLCM_Terms_And_Conditions extends AH_PLCM_Common_Class {
    //Initialize Variables
    public List<NI_Documentation__c> lstProjects { get; set; }
    public boolean Opt_Out_Social_Media_Feature { get; set; }
    public boolean TermsAndCondtionAccepted { get; set; }

    //Check if terms and conditions are alerady accepted
    public PageReference IsTermsAndConditionsAccepted() {
        try {
            //Initialize vairiale with default value
            TermsAndCondtionAccepted = true;
            
            //Get all projects for which terms and conditions are not accepted
            lstProjects = GetProjectsByUser(true);

            if(lstProjects != null && lstProjects.size() > 0) {
                TermsAndCondtionAccepted = false;               
            }
            else {
                //Redirect to Introduction page because user has alerady accepted terms and conditions for all accessible projects
                return RedirectToPage(PageNames.IntroductionPage, null);
            }
            return null;
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('IsTermsAndConditionsAccepted', ex);
        }
    }

    //Update flag for terms and condition on click of next button
    public PageReference AcceptTermsAndCondtion() {
        try {
            for (NI_Documentation__c obj : lstProjects) {
                //Update terms and condition flag and accepted date for all assigned projects
                obj.AH_PLCM_IsTerms_and_Conditions_Accepted__c = TermsAndCondtionAccepted;
                obj.AH_PLCM_IsOpt_Out_of_Social_Media__c = Opt_Out_Social_Media_Feature;
                obj.AH_PLCM_Terms_and_Cndtions_Accepted_Date__c = Date.Today();
            }

            //Update status in project object
            update lstProjects;

            //Redirect to Introduction Page
            return RedirectToPage(PageNames.IntroductionPage, null);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('AcceptTermsAndCondtion', ex);            
        }
    }
}