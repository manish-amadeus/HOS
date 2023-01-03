/****************************************************************************************
Name            : AH_UTIL_ResetPassword_Ctlr
Author          : Sean Harris
Created Date    : 03/18/2020
Last Mod Date   : 08/22/2021
Last Mod By     : Stuart Emery
NICC Reference  : NICC-041882
Description     : UPDATED 08/11/2021 PER NICC-052490
                : Controller for the AH_UTIL_ResetPassword Visualforce page.
                :            
******************************************************************************************/
public class AH_UTIL_ResetPassword_Ctlr 
{
    
    // PUBLIC VARIABLES ======================================
    
    // COLLECTIONS
    public List<SelectOption> lstValidUsers {get; set;} 
    public Map<Id, userDetail> mapUsers {get; set;} 
    public userDetail selUserDetail {get; set;}
    
    // STRINGS
    public String selUser {get; set;}    
    public String strErrorMsg {get; set;}
    public String toastMsg {get; set;}
    public String strConfirmationMsg {get; set;}
    public String strTempProfileName {get; set;}
    public String strCurrentProfileName {get; set;}
    public String strUserLicenseName {get; set;}
    public String strPasswordResetProfilePlatform {get; set;}
    public String strPasswordResetProfileSalesforce {get; set;}
    
    // BOOLEANS
    public Boolean displayDialog1 {get; set;}
    public Boolean displayDialog2 {get; set;}
    public Boolean displayDialog3 {get; set;}
    public Boolean isSuccess {get; set;}
    public Boolean bShowDetail {get; set;}
    public Boolean bHasIssue {get; set;}
    public Boolean bIslocked {get; set;}
    public Boolean bDisableUnlockBtn {get; set;}
    public Boolean bPwdChangedLast24Hours {get; set;}
    public Boolean bChangedUserProfile {get; set;}
    public Boolean bDisableClearMobilePhoneBtn {get; set;}
    public Boolean bDisableResetPwdBtn {get; set;}
    public Boolean bSalesforceLicenseType {get; set;}
    public Boolean bSalesforcePlatformLicenseType {get; set;}
    public Boolean bValidUserLicenseType {get; set;}
    
    // PRIVATE VARIABLES ====================================
    private User runningUser {get; set;} 
    private User resetUser {get; set;} 
    private Profile tempProfile {get; set;}
    private String runningUserProfileName {get; set;}
    private String runningUserProfileId {get; set;}
    private String runningUserUserName {get; set;}
    private String passwordResetProfile {get; set;}
    private String passwordResetProfilePlatform {get; set;}
    private String restUserCurrentProfile {get; set;}
    
    
    public AH_UTIL_ResetPassword_Ctlr()
    {
        
        // VARIABLE INITIALIZATIONS
        initVariables();
        
        // PICKLIST INITIALIZATIONS
        fillPicklists();
        
    } 
    
    private void initVariables()
    {
        strErrorMsg = '';
        toastMsg = '';
        strConfirmationMsg = '';       
        displayDialog1 = false;
        displayDialog2 = false;
        displayDialog3 = false;
        bShowDetail = false;
        bHasIssue = true;
        runningUserProfileName = '';
        runningUser = [SELECT Id, Name, UserName, ProfileId, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];  
        runningUserProfileName = runningUser.Profile.Name;
        runningUserUserName = runningUser.UserName;
        runningUserProfileId = runningUser.ProfileId;
        strCurrentProfileName = runningUser.Profile.Name;
        bDisableUnlockBtn = true;
        bChangedUserProfile = false;
        bDisableClearMobilePhoneBtn = true;
        bDisableResetPwdBtn = true;
        strTempProfileName = '';
        bSalesforceLicenseType = false;
        bSalesforcePlatformLicenseType = false;
        bValidUserLicenseType = false;
        
    }
    
    private void fillPicklists()
    {
        
        lstValidUsers = new List<SelectOption>();
        //selUser = '0';
        lstValidUsers.add(new SelectOption('0', 'CHOOSE USER'));
        
        //GET THE CUSTOM METADATA TYPE VALUES
        List<Reset_Password_Utility_Settings__mdt> cs = new List<Reset_Password_Utility_Settings__mdt>(
            [SELECT Allowed_User_Profiles__c, Running_User_Username__c, Password_Reset_Profile_Platform__c, Password_Reset_Profile_Salesforce__c 
             FROM Reset_Password_Utility_Settings__mdt
             WHERE
             Running_User_Username__c =: runningUserUserName
             LIMIT 1
            ]);
        
        Set<String> setProfileNames = new Set<String>();
        List<String> lstProfiles = new List<String>();
        String pName = '';
        
        
        //ASSIGN VARIABLES BASED ON CUSTOM METADATA TYPE VALUES
        for (Reset_Password_Utility_Settings__mdt utilCS : cs)  
        {
            strPasswordResetProfilePlatform = utilCS.Password_Reset_Profile_Platform__c;
            strPasswordResetProfileSalesforce = utilCS.Password_Reset_Profile_Salesforce__c;
            
            //PARSE THE LIST OF PROFILES FROM THE CUSTOM METADATA TYPE
            lstProfiles = utilCS.Allowed_User_Profiles__c.trim().split(',');
        }
        setProfileNames.addAll(lstProfiles);
        
        Set<Id> setValidProfileIds = new Set<Id>();
        for (Profile p : [SELECT Id FROM Profile WHERE Name IN : setProfileNames])
        {
            setValidProfileIds.add(p.Id);
        }
        
        List<User> lstUsers = new List<User>([SELECT Id, Name, LastLoginDate, Email, IsActive, Username, LastPasswordChangeDate,
                                              MobilePhone, Profile.UserLicense.Name    
                                              FROM User 
                                              WHERE IsActive = true 
                                              AND Id != : runningUser.Id 				// EXCLUDE RUNNING USER
                                              AND ProfileId IN : setValidProfileIds    	// VALID PROFILE IDS FROM Reset_Password_Utility_Settings__mdt CUSTOM METADATA TYPE
                                              AND ProfileId != '00e30000000mGqrAAE'		// System Adimistrator
                                              ORDER BY Name ASC]);
        
        if (cs.size() > 0 && lstUsers.size() > 0)
        {
            
            mapUsers = new Map<Id, userDetail>();
            
            List<UserLogin> lstUserLogins = new List<UserLogin>([SELECT UserId, IsFrozen, IsPasswordLocked 
                                                                 FROM UserLogin 
                                                                 WHERE UserId IN : lstUsers]);
            
            for (User u : lstUsers)
            {
                
                lstValidUsers.add(new SelectOption(u.Id, u.Name));
                
                userDetail ud = new userDetail(
                    u.Id,
                    u.Name,
                    u.Email,
                    u.Username,
                    u.MobilePhone,
                    convertToLocalDateTime(u.LastLoginDate),
                    false,
                    false,
                    false,
                    convertToLocalDateTime(u.LastPasswordChangeDate),
                    u.Profile.UserLicense.Name
                    
                );
                
                mapUsers.put(u.Id, ud);
                
            }            
            
            for (UserLogin ul : lstUserLogins)
            {
                if (mapUsers.containsKey(ul.UserId))
                { 
                    mapUsers.get(ul.UserId).isFrozen = ul.IsFrozen;
                    mapUsers.get(ul.UserId).isLocked = ul.IsPasswordLocked;
 
                    if (ul.IsFrozen == true)
                    {
                        mapUsers.get(ul.UserId).hasIssue = true;
                    }
                    
                    if (ul.IsPasswordLocked == true)
                    {
                        mapUsers.get(ul.UserId).isLocked = true;  
                    }                      
                    
                }            
            }   
            
        }
        
    }
    
    public void confirmReset()
    {
        
        if (selUser == '0')
            {
            strErrorMsg = 'Please choose a user before submitting a reset.';
        } 
        
        else
        {
            strErrorMsg = '';
            Id uId = (Id)selUser;
            resetUser = [SELECT Id, ProfileId, Name, Email, Profile.UserLicense.Name FROM User WHERE Id =: uId];
            restUserCurrentProfile = resetUser.ProfileId;
            bPwdChangedLast24Hours = selUserDetail.isChangedLast24hrs;
            strUserLicenseName = resetUser.Profile.UserLicense.Name;
            System.Debug('RESETUSER USER LICENSE NAME: ' + strUserLicenseName);
            strConfirmationMsg = 'You are about to send a reset password email to: ' + resetUser.Email + ' for user: ' + resetUser.Name + '. Please confirm.'; 
            showDialog1();
        }    
        
    }
    
    public void confirmMobileUpdate()
    {
        
        if (selUser == '0')
            {
            strErrorMsg = 'Please choose a user.';
        }  
          
        else
        {
            strErrorMsg = '';
            Id uId = (Id)selUser;
            resetUser = [SELECT Id, Name, Email FROM User WHERE Id =: uId];
            strConfirmationMsg = 'You are about to clear the Mobile Phone Number for user: ' + resetUser.Name + '. Please confirm.'; 
            showDialog2();
        }
                 
    }
    
    public void confirmUserUnlock()
    {
        
        if (selUser == '0')
            {
            strErrorMsg = 'Please choose a user.';
        } 
        
        else
        {
            strErrorMsg = '';
            Id uId = (Id)selUser;
            resetUser = [SELECT Id, Name, Email FROM User WHERE Id =: uId];
            strConfirmationMsg = 'You are about to unlock the user record for: ' + resetUser.Name + '. Please confirm.'; 
            showDialog3();
        }
                 
    }
    
    private void doReset()
    {
        Id uId2 = (Id)selUser;
        system.debug(' selUser = ' + selUser);        
        
        if (selUser != '0')
        {
            try 
            { 
                Id uId = (Id)selUser;
                String strSummary = runningUser.Name + ' sent a password reset to ' + resetUser.Name + ' (' + resetUser.Email + ') using the Reset Salesforce User Passwords Custom Admin Function.';
                
                System.debug('PASSWORD CHANGED LAST 24 HOURS: ' + bPwdChangedLast24Hours);
                If (bPwdChangedLast24Hours == true)
                {
                    //CHANGE THE PROFILE OF THE RESET PASSWORD USER TO THE RESET PASSWORD PROFILE IN ORDER TO BYPASS PROFILE PASSWORD
                    //POLICIES
                    If (strUserLicenseName == 'Salesforce Platform')
                    {
                      strTempProfileName = strPasswordResetProfilePlatform; 
                    }
                    
                    If (strUserLicenseName == 'Salesforce')
                    {
                      strTempProfileName = strPasswordResetProfileSalesforce; 
                    }
            
                    tempProfile = [SELECT Id, Name FROM Profile WHERE Name =: strTempProfileName];
            
                    passwordResetProfile = tempProfile.Id;
                    System.debug('PASSWORD RESET PROFILE ID: ' + tempProfile.Name);
                
                    assignProfileToUser(passwordResetProfile);
                    bChangedUserProfile = true;   
                }
                 
                
                User cUser = [SELECT Id, Name, Profile.Name FROM User WHERE Id =: uId LIMIT 1];
                
                System.Debug('CURRENT USER PROFILE: ' + cUser.Profile.Name);
                
                system.ResetPasswordResult r; 
                r = system.resetPassword(uId, true);
                
                system.debug(' RESULT = ' + r);      
                if (r == null)
                {
                    strErrorMsg = 'An error occurred!';
                }
                
                isSuccess = true;
                toastMsg = 'Password reset was issued.'; 
                displayDialog1 = false; 
                fillPicklists();
                
                //NEED TO USE @FUTURE METHOD IN ORDER TO ADDRESS MIXED DML OPERATION ERRORS SINCE WE
                //ARE UPDATING THE USER OBJECT AND THE EVENT LOG IN THE SAME TRANSACTION
                AH_WriteEventLogFutureMethod.writeEventLog(strSummary, (String)uId, runningUser.Id);
                
                //bShowDetail = false; 
                bShowDetail = true;
                strErrorMsg = 'A password reset has been sent to ' + resetUser.Email + ' for ' + resetUser.Name;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, strErrorMsg));
                strErrorMsg = '';
                
            }
            catch (Exception e)
            {
                strErrorMsg = e.getMessage();
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strErrorMsg));
                System.Debug('RESET PASSWORD ERROR: ' + strErrorMsg);
               
            }
            
            if (bChangedUserProfile == true)
            {  
                //CHANGE THE PROFILE OF THE RESET PASSWORD USER BACK TO THE ORIGINAL PROFILE
                assignProfileToUser(restUserCurrentProfile);
            }
        }
        else
        {
            strErrorMsg = 'Please choose a user before submitting a reset.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strErrorMsg));
        }
        
    }
    
    private void doClearMobilePhone()
    {
        
        system.debug(' selUser = ' + selUser);        
        
        if (selUser != '0')
        {
            try 
            { 
                Id uId = (Id)selUser;
                String strSummary = runningUser.Name + ' deleted the mobile phone information for user ' + resetUser.Name + ' (' + resetUser.Email + ') using the Reset Salesforce User Passwords Custom Admin Function.';
                
                resetUser.MobilePhone = '';
                
                Database.update(resetUser);
                
                isSuccess = true;
                toastMsg = 'Mobile Phone successfully cleared.'; 
                displayDialog2 = false; 
                fillPicklists();
                
                bShowDetail = true; 
                strErrorMsg = 'A Mobile Phone field update has been sent for ' + resetUser.Name;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, strErrorMsg));
                strErrorMsg = '';
                
                //NEED TO USE @FUTURE METHOD IN ORDER TO ADDRESS MIXED DML OPERATION ERRORS SINCE WE
                //ARE UPDATING THE USER OBJECT AND THE EVENT LOG IN THE SAME TRANSACTION
                AH_WriteEventLogFutureMethod.writeEventLog(strSummary, (String)uId, runningUser.Id);
                
            }
            catch (Exception e)
            {
                strErrorMsg = e.getMessage();
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strErrorMsg));
            }            
        }
        else
        {
            strErrorMsg = 'Please choose a user before submitting a reset.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strErrorMsg));
        }
        
        selUser = resetUser.Name;
        
    }
    
    private void doUnlockUser()
    {
        
        system.debug(' selUser = ' + selUser);        
        
        if (selUser != '0')
        {
            try 
            { 
                Id uId = (Id)selUser;
                String strSummary = runningUser.Name + ' unlocked the user record for ' + resetUser.Name + ' (' + resetUser.Email + ') using the Reset Salesforce User Passwords Custom Admin Function.';
                
                UserLogin lockedUer = [SELECT IsPasswordLocked FROM UserLogin WHERE UserId =: uId];
                lockedUer.IsPasswordLocked = false;              
                Database.update(lockedUer);
                
                isSuccess = true;
                toastMsg = 'User successfully unlocked.'; 
                displayDialog3 = false; 
                fillPicklists();
                
                bShowDetail = true; 
                strErrorMsg = 'A unlock user record update has been sent for ' + resetUser.Name;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, strErrorMsg));
                strErrorMsg = '';
                
                //NEED TO USE @FUTURE METHOD IN ORDER TO ADDRESS MIXED DML OPERATION ERRORS SINCE WE
                //ARE UPDATING THE USER OBJECT AND THE EVENT LOG IN THE SAME TRANSACTION
                AH_WriteEventLogFutureMethod.writeEventLog(strSummary, (String)uId, runningUser.Id);
                
            }
            catch (Exception e)
            {
                strErrorMsg = e.getMessage();
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strErrorMsg));
            }            
        }
        else
        {
            strErrorMsg = 'Please choose a user before submitting a reset.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strErrorMsg));
        }
        
        selUser = resetUser.Name;
        
    }
  /* THIS METHOD IS DEPRECATED 08/22/2021. IT HAS BEEN REPLACED WITH THE AH_WriteEventLogFutureMethod APEX CLASS 
    private static void writeEventLog(String strSummary, String strParentId, Id idUser)
    {
        AH_Event_Log__c evLog = new AH_Event_Log__c();
        evLog.Summary__c = strSummary;
        evLog.ParentId__c = strParentId;
        evLog.Running_User__c = idUser;
        insert evLog;
    }
*/    
    
    public void retUserDetail()   
    {
        
        selUserDetail = new userDetail();
        
        if (!mapUsers.isEmpty() && selUser != '0')
        {
            for (Id u : mapUsers.keySet())
            {
                Id i = (Id)selUser;
                if (u == i)
                {
                    selUserDetail = mapUsers.get(i);
                    bHasIssue = true;
                    bDisableResetPwdBtn = false;
                    
                    if(selUserDetail.UserLicenseType == 'Salesforce' || selUserDetail.UserLicenseType == 'Salesforce Platform')
                    {
                      bValidUserLicenseType = true;  
                    }
                    
                    if (selUserDetail.hasIssue == false)
                    {
                        bHasIssue = false;
                    }
                    if (selUserDetail.isLocked == true && bValidUserLicenseType == true)
                    {
                        bIsLocked = true;
                        bDisableUnlockBtn = false;
                    }
                    
                    if (selUserDetail.UserMobilePhone != null && bValidUserLicenseType == true)
                    {
                        bDisableClearMobilePhoneBtn = false;
                    }
                    
                    if (selUserDetail.isFrozen == true)
                    {
                        bDisableResetPwdBtn = true;
                    }
                    
                    if(bValidUserLicenseType == false)
                        {
                           bDisableResetPwdBtn = true;
                        }
                    
                    bShowDetail = true;
                    break;
                }
            } 
        }
        else
        {
            //            bShowDetail = false;
        }
        
        system.debug(' selUserDetail = ' + selUserDetail);
        
        //return null;
    }
    
    //THIS METHOD CHANGES THE PROFILE FOR THE PASSWORD RESET USER
    private void assignProfileToUser (string profId) {
        
        Id uId = (Id)selUser;
        resetUser.ProfileId = profId;
        Profile assignedProfileName = [SELECT NAME FROM PROFILE WHERE Id =: profId];
        String strSummaryProfile = runningUser.Name + ' changed the profile to ' + assignedProfileName.Name + ' for ' + resetUser.Name + ' (' + resetUser.Email + ') using the Reset Salesforce User Passwords Custom Admin Function.';
        system.debug('USER PROFILE ID = ' + profId);
        update resetUser;
        
        //NEED TO USE @FUTURE METHOD IN ORDER TO ADDRESS MIXED DML OPERATION ERRORS SINCE WE
        //ARE UPDATING THE USER OBJECT AND THE EVENT LOG IN THE SAME TRANSACTION
        AH_WriteEventLogFutureMethod.writeEventLog(strSummaryProfile, (String)selUser, runningUser.Id); 
    }
    
    //USING PAGEREFERENCE FOR PARTIAL PAGE REFRESH ACTIONS
    Public PageReference pageRefUserDetail()
    {
        // VARIABLE INITIALIZATIONS
        initVariables();
        
        // PICKLIST INITIALIZATIONS
        fillPicklists();
        
        // RETURN SELECTED USER DETAIL
        retUserDetail();
        
        return null;        
    }
    
    
    // ================================================================================================================================
    //  DIALOG METHODS 
    // ================================================================================================================================
    public void showDialog1() 
    {
        displayDialog1 = true;
    }
    
    public void showDialog2() 
    {
        displayDialog2 = true;
    }
    
    public void showDialog3() 
    {
        displayDialog3 = true;
    }
    
    public void hideDialog1() 
    {  
        displayDialog1 = false;  
        isSuccess = false;
        toastMsg = '';
    }
    
    public void hideDialog2() 
    {  
        displayDialog2 = false;  
        isSuccess = false;
        toastMsg = '';
    } 
    
    public void hideDialog3() 
    {  
        displayDialog3 = false;  
        isSuccess = false;
        toastMsg = '';
    } 
    
    public void submitDialog1() 
    {
        doReset();
        fillPicklists();
        selUser = resetUser.Name;
    }
    
    public void submitDialog2() 
    {
        doClearMobilePhone();
    }
    
    public void submitDialog3() 
    {
        doUnlockUser();
        fillPicklists();
        selUser = resetUser.Name;
        //retUserDetail();
    }
    
    private Datetime convertToLocalDateTime(DateTime gmt)
    {
        if (gmt == null)
        {
            return null;
        }
        Integer offset = UserInfo.getTimezone().getOffset(gmt); 
        Datetime local = gmt.addSeconds(offset/1000);
        return local;
    }
    
    
    // ================================================================================================================================
    //  WRAPPER CLASSES ===============================================================================================================
    // ================================================================================================================================
    public class userDetail
    {    
        
        public Id userId {get; set;}
        public String userName {get; set;}
        public String userEmail {get; set;}
        public String userUsername {get; set;}
        public String userMobilePhone {get; set;}
        public DateTime LastLoginDate {get; set;}
        public Boolean isFrozen {get; set;}
        public Boolean isLocked {get; set;}
        public Boolean hasIssue {get; set;}
        public DateTime LastPasswordChangeDate {get; set;}
        public Boolean isChangedLast24hrs {get; set;}
        public String userLicenseType {get; set;}
        
        public userDetail (Id p1, String p2, String p3, String p4, String p5, DateTime p6, Boolean p7, Boolean p8, Boolean p9, DateTime p10, String p11)
        {
            this.userId = p1; 
            this.userName = p2; 
            this.userEmail = p3; 
            this.userUsername = p4; 
            this.UserMobilePhone = p5;
            this.LastLoginDate = p6; 
            this.isFrozen = p7; 
            this.isLocked = p8; 
            this.hasIssue = p9; 
            this.LastPasswordChangeDate = p10;
            this.isChangedLast24hrs = false;
            this.UserLicenseType = p11;
            
            System.Debug('PWD LAST CHANGED: ' + this.LastPasswordChangeDate);
            
            if (p10 != null)
            {
                Long dt1Long = p10.getTime();
                Long dt2Long = DateTime.now().getTime();
                Long milliseconds = (dt2Long - dt1Long);
                Long seconds = (milliseconds / 1000);
                Long minutes = (seconds / 60);
                Long hours = (minutes / 60);
                System.debug('HOURS: ' + hours);
                //Long days = (hours / 24);                
                if (hours < 24)
                {
                    this.isChangedLast24hrs = true;
                    System.Debug('isChangedLast24hrs: ' + this.isChangedLast24hrs);
                    this.hasIssue = true;
                }                
            }
            
        }
        
        public userDetail()
        {
            this.userId = null; 
            this.userName = ''; 
            this.userEmail = ''; 
            this.userUsername = '';
            this.userMobilePhone = '';
            this.LastLoginDate = null; 
            this.isFrozen = false; 
            this.isLocked = false; 
            this.hasIssue = true;
            this.LastPasswordChangeDate = null;
            this.isChangedLast24hrs = false;
            this.UserLicenseType = '';
        }
        
    } 
    
}