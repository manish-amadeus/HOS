/****************************************************************************************
Name            : AH_CopyUserAttributesController Class
Author          : Shashikant Nikam
Created Date    : 10/04/2018
Last Mod Date   : 10/16/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-030898
Description     : Controller for AH_CopyUserAttributes AND AH_CustomUserLookup VF page
				: Contains the code to update the Destination User
				: 
*****************************************************************************************/

public class AH_CopyUserAttributesController {
    
    public Contact contact1 {get;set;}
    public Contact contact2 {get;set;}
    public List<User> results {get;set;} 
    public string searchString {get;set;} 
    
    public boolean attrCheckAll {get; set;}
    public boolean grpCheckAll {get; set;}
    public boolean permCheckAll {get; set;}
    public boolean queueCheckAll {get; set;}
    
    private String userId_1;
    private String userId_2;

    private User user_1;
    private User user_2;

    public List<attribsWrapper> attrList {get; set;}
    public List<groupWrapper> grpList {get; set;}
    public List<permissionSetWrapper> permSetList {get; set;}
    public List<queueWrapper> queueList {get; set;}
        
    // CONSTRUCTOR
    public AH_CopyUserAttributesController() 
    {
        system.debug('in constructor...');
        
        // BY DEFAULT ALL THE CHECKBOXES ARE SET TO TRUE
        attrCheckAll = true;
        grpCheckAll = true;
        permCheckAll = true;
        queueCheckAll = true;
        
        // USER LOOKUP FIELDS
        contact1 = new Contact();
        contact2 = new Contact();       
        
        // GET THE CURRENT SEARCH STRING
        searchString = System.currentPageReference().getParameters().get('lksrch');
        system.debug('searchString : '+searchString);
        
        // THESE VARIABLES ARE USED TO CUSTOM LOOKUP PAGE RESULT FILTERING PURPOSE
        userId_1 = System.currentPageReference().getParameters().get('user1');
        userId_2 = System.currentPageReference().getParameters().get('user2');
        
        system.debug('userId_1 : '+userId_1);
        system.debug('userId_2 : '+userId_2);
        
        // CALL runSearch() METHOD
        runSearch();
    }
    
    // PERFORM THE KEYWORD SEARCH
    public PageReference search() 
    {
        runSearch();
        return null;
    }
    
    // PREPARE THE QUEY & ISSUE THE SEARCH COMMAND 
    private void runSearch() 
    {
        // TODO prepare query string for complex serarches & prevent injections
        results = performSearch(searchString);               
    } 
    
    // RUN THE SEARCH & RETURN THE RECORDS FOUND 
    private List<User> performSearch(string searchString) 
    {
        String soql = 'select id, name from User';
        
        boolean flag = false;
        if(searchString != '' && searchString != null)
        {
            soql = soql +  ' WHERE name LIKE \'%' + searchString +'%\''; 
            flag = true;
        }
        
        system.debug('in performSearch userId_1 : '+userId_1);
        
        User u;
        if (userId_1 != NULL && userId_1 != '' )
        {
            u = [Select Id, Name, Profile.UserLicenseId From User where Name= :userId_1];
            
            if (flag == true)
            {
                soql = soql +' AND Profile.UserLicenseId = \''+u.Profile.UserLicenseId +'\'';
            }
            else 
            {
            	soql = soql +' WHERE Profile.UserLicenseId = \''+u.Profile.UserLicenseId +'\'';
            }
            soql = soql +' AND Name != \''+ userId_1 +'\'';
        }
        
        User u2;
        if (userId_2 != NULL && userId_2 != '' )
        {
            u2 = [Select Id, Name, Profile.UserLicenseId From User where Name= :userId_2];
        
            if (flag == true)
            {
                soql = soql +' AND Profile.UserLicenseId = \''+u2.Profile.UserLicenseId +'\'';
            }
            else 
            {
            	soql = soql +' WHERE Profile.UserLicenseId = \''+u2.Profile.UserLicenseId +'\'';
            }
            soql = soql + ' AND Name != \''+ userId_2 +'\'';
        }
        
        soql = soql + ' limit 25';
        
        System.debug('soql : ' +soql);
        return database.query(soql); 
    }
    
    // POPULATE SOURCE USER DATA 
    public PageReference verifyUsers ()
    {
        system.debug('contact1 => ' +contact1);
        system.debug('contact2 => ' +contact2);
        
        if (contact1.OwnerId != NULL && contact2.OwnerId != NULL) 
        {
            retrieveUserData(contact1.OwnerId, contact2.OwnerId);
        }

        return null;
    }

    // RETRIEVE SOURCE USER'S DATA
    public void retrieveUserData(String userId1, String userId2) 
    {
        attrCheckAll = true;
        grpCheckAll = true;
        permCheckAll = true;
        queueCheckAll = true;

        system.debug(userId1 +' => '+ userId2);

		// RETRIEVE EXISTING USER INFO
        user_1 = queryUser(userId1);
		user_2 = queryUser(userId2);
     
        system.debug('user_1 => ' +user_1);
        system.debug('user_2 => ' +user_2);
        
        // CHECK IF BOTH USERS HAVE SAME LICENSE
        if ( user_1 != NULL && user_2 != NULL && 
            user_1.Profile.UserLicenseId == user_2.Profile.UserLicenseId )
        {
            system.debug('Users share same License...');
            
            // CREATE LIST OF CORE ATTRIBUTES AND INSERT IN WRAPPER CLASS
            List<String> coreAttribs = new list<String>{
                'Amadeus Division',
                'Company',
                'Department',
                'Department Code',
                'Financial Location/Segment',
                'Locale Settings Section',
                'Manager',
                'NI Office',
                'Non Amadeus Hospitality User',
                'Profile',
                'Purchase Approval Authority',
                'Role',
                'Time Zone',
                'Title',
                'User Team',
                'Force.com Flow User',
                'Service Cloud User',
                'Salesforce CRM Content',
                'Xactly User'};
                    
			attrList = new List<attribsWrapper>();
            
            for ( String str : coreAttribs)
            {
                attribsWrapper a = new attribsWrapper();
                a.attribName = str;
                a.isSelected = true;
                attrList.add(a);
            }
            system.debug('attrList : '+attrList);
            
            // INITIALIZE THE WRAPPER LISTS
            grpList = new List<groupWrapper>();
            queueList = new List<queueWrapper>();
            permSetList = new List<permissionSetWrapper>();
            
            // GET THE LIST OF GROUPS OF SOURCE USER
            List<Group> userGrpList = new List<Group>([SELECT ID, Name, DeveloperName FROM Group 
                                                   WHERE ID IN (select groupId from GroupMember where UserOrGroupId =: user_1.id)]);
            Set<ID> srcUserGrpIds = new Set<ID>();
			for (Group gr : userGrpList)
            {
                srcUserGrpIds.add(gr.id);
            }
            system.debug('Source User Group Id Set 1 : '+srcUserGrpIds);
            
            // GET THE LIST OF GROUPS OF DESTINATION USER
            List<Group> userGrpList2 = new List<Group>([SELECT ID, Name, DeveloperName FROM Group 
                                                   WHERE ID IN (select groupId from GroupMember where UserOrGroupId =: user_2.id)]);
            Set<ID> srcUserGrpIds2 = new Set<ID>();
			for (Group gr : userGrpList2)
            {
                srcUserGrpIds2.add(gr.id);
            }
            system.debug('Source User Group Id Set 2 : '+srcUserGrpIds2);
            
            
            // CREATE QUEUE WRAPPER LIST
            List<Group> queues = new List<Group>(
                [SELECT ID, Name, DeveloperName 
                 FROM Group 
                 WHERE ID IN (SELECT groupId FROM GroupMember 
                              WHERE (UserOrGroupId =: user_1.id OR UserOrGroupId =: srcUserGrpIds) AND Group.Type = 'Queue') 
                 AND ID NOT IN (SELECT groupId FROM GroupMember 
                               WHERE (UserOrGroupId =: user_2.id OR UserOrGroupId =: srcUserGrpIds2) AND Group.Type = 'Queue') ]);

            system.debug('Source User queues : '+queues);
            
            if (!queues.isEmpty())
            {
                for(Group g : queues)
                {
                    queueWrapper wrapperObj = new queueWrapper();
                    wrapperObj.queueName = g.Name;
                    wrapperObj.id = g.id;
                    wrapperObj.isSelected = true;
                    queueList.add(wrapperObj);
                }
            }
                       
            // CREATE GROUPS WRAPPER LIST
            List<Group> groups = new List<Group>([SELECT ID, Name, DeveloperName FROM Group 
                       WHERE ID IN (SELECT groupId FROM GroupMember WHERE UserOrGroupId =: user_1.id AND Group.Type != 'Queue') 
                       AND ID NOT IN (SELECT groupId FROM GroupMember WHERE UserOrGroupId =: user_2.id AND Group.Type != 'Queue')]);
            
            System.debug('Groups : '+groups);
            if (!groups.isEmpty())
            {
                for(Group g : groups)
                {
                    groupWrapper wrapperObj = new groupWrapper();
                    wrapperObj.groupName = g.Name;
                    wrapperObj.id = g.id;
                    wrapperObj.isSelected = true;
                    grpList.add(wrapperObj);
                }
            }
            
            // CREATE PERMISSION SET WRAPPER LIST
            // QUERY ON USER 2
            List<PermissionSetAssignment> user2PermList = new List<PermissionSetAssignment>(
                										[SELECT Id, PermissionSet.Name, PermissionSetId, Assignee.Name 
                                                         FROM PermissionSetAssignment WHERE AssigneeId =: user_2.id]);
            Set<String> u2PermIds = new Set<String>();
            for (PermissionSetAssignment p: user2PermList)
            {
                u2PermIds.add(p.PermissionSetId);
            }
            system.debug('u2PermIds : '+u2PermIds);
            
            Set<Id> validPermIds = new Set<Id>();
            for (PermissionSet p : [select ID from PermissionSet where IsOwnedByProfile = false])
            {
                validPermIds.add(p.id);
            }
            
            // QUERY ON USER 1
            List<PermissionSetAssignment> permList = new List<PermissionSetAssignment>(
                		[SELECT Id, PermissionSet.Name, PermissionSetId, 
                         Assignee.Name 
                         FROM PermissionSetAssignment 
                         WHERE AssigneeId =: user_1.id 
                         AND PermissionSetId NOT IN: u2PermIds 
                        AND PermissionSetId IN: validPermIds]);

            System.debug('Permission Sets : '+permList);
            
            if (!permList.isEmpty())
            {
                for(PermissionSetAssignment p : permList)
                {
                    permissionSetWrapper wrapperObj = new permissionSetWrapper();
                    wrapperObj.permSetName = p.PermissionSet.Name;
                    wrapperObj.PermissionSetId = p.PermissionSetId;
                    wrapperObj.isSelected = true;
                    permSetList.add(wrapperObj);
                }
            }
        }
        else {
            system.debug('User License not matching...');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Users have different License Type.');
			ApexPages.addMessage(myMsg);
		}
        system.debug('Limits.getQueries : '+Limits.getQueries());
    }
    
    private User queryUser (String uId)
    {
        User u = [Select Id, Name, 
                  Profile.UserLicenseId, 
                  UserRoleId, 
                  Amadeus_Division__c, 
                  DepartmentCode__c, 
                  CompanyName, 
                  Department, 
                  NI_Location__c, 
                  LocaleSidKey, 
                  ManagerId, 
                  NI_Office__c, 
                  Non_Amadeus_Hospitality_User__c, 
                  ProfileId, 
                  Purchase_Approval_Authority__c, 
                  TimeZoneSidKey, 
                  Title, 
                  UserTeam__c, 
                  UserPermissionsInteractionUser, 
                  UserPermissionsSupportUser, 
                  UserPermissionsSFContentUser, 
                  Xactly_User__c 
                   FROM User where Id =: uId ];
        
        return u;
    }
    
    // UPDATE DESTINATION USER 
    public PageReference updateUser () 
    {
        system.debug('grpList : '+grpList);
        system.debug('permSetList : '+permSetList);
        system.debug('queueList : '+queueList);
        system.debug('attrList : '+attrList);
	
        user_1 = queryUser(contact1.OwnerId);
        user_2 = queryUser(contact2.OwnerId);

    	system.debug('updateUser user_1 => ' +user_1);
        system.debug('updateUser user_2 => ' +user_2);
        
        if ( user_1 != NULL && user_2 != NULL && 
            user_1.Profile.UserLicenseId == user_2.Profile.UserLicenseId )
        {
            system.debug('in if...');
            updateAttributes();
            updateGroups();
            updatePermSets();
            updateQueues();
        
            system.debug('User updated successfully !!!');
            
            // UPDATE WREAPPER LISTS
        	verifyUsers();
            
        }
        else {
            system.debug('User License not matching...');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Users have different License Type.');
			ApexPages.addMessage(myMsg);
		}
        system.debug('Limits.getQueries : '+Limits.getQueries());
        return null;
    }
    
    // ASSIGN SELECTED ATTRIBUTES TO DESTINATION USER
    private void updateAttributes()
    {
        Boolean isEligible = false;
        if (attrList!= NULL && !attrList.isEmpty())
        {
            for (attribsWrapper attr : attrList)
            {
                if (attr.isSelected == true)
                {
                    isEligible = true;
                    if (attr.attribName == 'Role')
                        user_2.UserRoleId = user_1.UserRoleId;
                    
                    if (attr.attribName == 'Amadeus Division')
                        user_2.Amadeus_Division__c = user_1.Amadeus_Division__c;
                    
                    if (attr.attribName == 'Company')
                        user_2.CompanyName = user_1.CompanyName;
                    
                    if (attr.attribName == 'Department')
                        user_2.Department = user_1.Department;
                    
                    if (attr.attribName == 'Department Code')
                        user_2.DepartmentCode__c = user_1.DepartmentCode__c;
                    
                    if (attr.attribName == 'Financial Location/Segment')
                        user_2.NI_Location__c = user_1.NI_Location__c;
                    
                    if (attr.attribName == 'Locale Settings Section')
                        user_2.LocaleSidKey = user_1.LocaleSidKey;
                    
                    if (attr.attribName == 'Manager')
                        user_2.ManagerId = user_1.ManagerId;
                    
                    if (attr.attribName == 'NI Office')
                        user_2.NI_Office__c = user_1.NI_Office__c;
                    
                    if (attr.attribName == 'Non Amadeus Hospitality User')
                        user_2.Non_Amadeus_Hospitality_User__c = user_1.Non_Amadeus_Hospitality_User__c;
                    
                    if (attr.attribName == 'Profile')
                        user_2.ProfileId = user_1.ProfileId;
                    
                    if (attr.attribName == 'Purchase Approval Authority')
                        user_2.Purchase_Approval_Authority__c = user_1.Purchase_Approval_Authority__c;
                    
                    if (attr.attribName == 'Time Zone')
                        user_2.TimeZoneSidKey = user_1.TimeZoneSidKey;
                    
                    if (attr.attribName == 'Title')
                        user_2.Title = user_1.Title;
                    
                    if (attr.attribName == 'User Team')
                        user_2.UserTeam__c = user_1.UserTeam__c;
                    
                    if (attr.attribName == 'Force.com Flow User')
                        user_2.UserPermissionsInteractionUser = user_1.UserPermissionsInteractionUser;
                    
                    if (attr.attribName == 'Service Cloud User')
                        user_2.UserPermissionsSupportUser = user_1.UserPermissionsSupportUser;
                    
                    if (attr.attribName == 'Salesforce CRM Content')
                        user_2.UserPermissionsSFContentUser = user_1.UserPermissionsSFContentUser;
                    
                    if (attr.attribName == 'Xactly User')
                        user_2.Xactly_User__c = user_1.Xactly_User__c;
                    
                }
            }
        }
        if (isEligible)
        {
            try {
                Database.upsert(user_2);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'User Attributes assigned Succcessfully !!!');
                ApexPages.addMessage(myMsg);
            }
            catch (Exception e)
            {
                System.debug('Exception occured while updating Attributes to Destination User. '+e);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'User Attributes assignment Failed !!!' +e);
                ApexPages.addMessage(myMsg);
            }
        }
    }
    
    // ASSIGN SELECTED GROUPS TO DESTINATION USER
    private void updateGroups()
    {
        system.debug('in updateGroups method..');
        List<GroupMember> grpMemberList = new List<GroupMember>();
        if (grpList!= NULL && !grpList.isEmpty())
        {
            for (groupWrapper g : grpList)
            {
                GroupMember gm = new GroupMember();
                if (g.isSelected == true)
                {
                    gm.groupId = g.id;
                    gm.UserOrGroupId = user_2.id;
                    grpMemberList.add(gm);
                }
            }
        }
        if (!grpMemberList.isEmpty())
        {
            try{
                Database.insert(grpMemberList);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Groups assigned Succcessfully !!!');
                ApexPages.addMessage(myMsg);
            }
			catch(Exception e)
            {
                System.debug('Exception occured while assigning Groups to Destination User. '+e);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Groups assignment Failed !!!' +e);
                ApexPages.addMessage(myMsg);
            }
        }
    }
    
    // ASSIGN SELECTED QUEUES TO DESTINATION USER
    private void updateQueues()
    {
        system.debug('in updateGroups method..');
        List<GroupMember> queueMemberList = new List<GroupMember>();
        if (queueList!= NULL && !queueList.isEmpty())
        {
            for (queueWrapper q : queueList)
            {
                GroupMember gm = new GroupMember();
                if (q.isSelected == true)
                {
                    gm.groupId = q.id;
                    gm.UserOrGroupId = user_2.id;
                    queueMemberList.add(gm);
                }
            }
        }
        if (!queueMemberList.isEmpty())
        {
            try{
                Database.insert(queueMemberList);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Queues assigned Succcessfully !!!');
                ApexPages.addMessage(myMsg);
            }
			catch(Exception e)
            {
                System.debug('Exception occured while assigning Groups to Destination User. '+e);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Queue assignment Failed !!!' +e);
                ApexPages.addMessage(myMsg);
            }
        }
    }
    
    // ASSIGN SELECTED PERMISSION SETS TO DESTINATION USER
    private void updatePermSets()
    {
        system.debug('in updatePermSets method..');
        List<PermissionSetAssignment> assignPermList = new List<PermissionSetAssignment>();
        if (permSetList != NULL && !permSetList.isEmpty())
        {
            for (permissionSetWrapper p : permSetList)
            {
                PermissionSetAssignment permAssignObj = new PermissionSetAssignment();
                if (p.isSelected == true)
                {
                    permAssignObj.PermissionSetId = p.PermissionSetId;
                    permAssignObj.AssigneeId = user_2.id;
                    assignPermList.add(permAssignObj);
                }
            }
        }
		system.debug('assignPermList : '+assignPermList);
            
        if (!assignPermList.isEmpty())
        {
            try{
                Database.insert(assignPermList);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Permission Sets assigned Succcessfully !!!');
                ApexPages.addMessage(myMsg);
            }
			catch(Exception e)
            {
                System.debug('Exception occured while assigning Permission Sets to Destination User. '+e);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Permission Set assignment Failed !!!' +e);
                ApexPages.addMessage(myMsg);
            }
        }
    }
    
    // WRAPPER CLASS TO HOLD CORE ATTRIBUTES
    public class attribsWrapper 
    {
        public Boolean isSelected {get; set;}
        public String attribName {get; set;}
        public attribsWrapper ()
        {
            isSelected = true;
        }
    }
    
    // WRAPPER CLASS TO HOLD PUBLIC GROUPS
    public class groupWrapper 
    {
        public Boolean isSelected {get; set;}
        public String groupName {get; set;}
        public String id {get; set;}
        public groupWrapper ()
        {
            isSelected = true;
        }
    }
    
    // WRAPPER CLASS TO HOLD PERMISSION SETS
    public class permissionSetWrapper 
    {
        public boolean isSelected {get; set;}
        public String permSetName {get; set;}
        public String PermissionSetId {get; set;}
        public permissionSetWrapper ()
        {
            isSelected = true;
        }
    }
    
    // WRAPPER CLASS TO HOLD QUEUES
    public class queueWrapper 
    {
        public boolean isSelected {get; set;}
        public String queueName {get; set;}
        public String id {get; set;}
        public queueWrapper()
        {
            isSelected = true;
        }
    }
    
    // USED BY THE VF PAGE TO SEND THE LINK TO THE RIGHT DOM ELEMENT
    public string getFormTag() 
    {
        system.debug('in getFormTag method....'+System.currentPageReference().getParameters().get('frm'));
        return System.currentPageReference().getParameters().get('frm');
	}
    
    // USED BY THE VF PAGE TO SEND THE LINK TO THE RIGHT DOM ELEMENT FOR THE TEXT BOX
    public string getTextBox() 
    {
        system.debug('in getFormTag method....'+System.currentPageReference().getParameters().get('txt'));
        return System.currentPageReference().getParameters().get('txt');
    }
}