/****************************************************************************************
Name            : AH_CopyUserAttributesController_Test Class
Author          : Shashikant Nikam
Created Date    : 10/15/2018
Last Mod Date   : 10/16/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-030898
Description     : Test class for the AH_CopyUserAttributesController controller class.
                : 
                : 
*****************************************************************************************/
@isTest
public class AH_CopyUserAttributesController_Test 
{
    
    @testSetup static void createData()
    {
        
        Test.startTest();
        
        // RETRIEVWE USER ROLE ID
        UserRole ur = [select Id, Name from UserRole where Name = 'Services & Support'];
        
        List<User> userList = new List<User>();
        
        // CREATE SOURCE USER
        User u1 = NI_TestClassData.createTestUser(1, 'System Administrator');
        u1.UserRoleId = ur.id;
        u1.Amadeus_Division__c = 'Hospitality';
        u1.DepartmentCode__c = '001';
        u1.CompanyName = 'Amadeus';
        u1.Department = 'Development';
        u1.NI_Location__c = '0110';
        u1.NI_Office__c = 'NI_Office__c';
        u1.Non_Amadeus_Hospitality_User__c = TRUE;
        u1.Purchase_Approval_Authority__c = 7.00;
        u1.Title = 'Amadeus Employee AAAAAA';
        u1.UserTeam__c = 'SE US';
        u1.UserPermissionsInteractionUser = TRUE;
        u1.UserPermissionsSupportUser = FALSE;
        u1.UserPermissionsSFContentUser = TRUE;
        u1.Xactly_User__c = TRUE;
        
        // CREATE DESTINATION USER
        User u2 = NI_TestClassData.createTestUser(2, 'System Administrator');
        
        // USER WITH DIFFERENT LICENSE
        User u3 = NI_TestClassData.createTestUser(3, 'AH Chatter External User');
        
        userList.add(u1);
        userList.add(u2);
        userList.add(u3);
        insert userList;
        
        List<User> insertedUsers = new List<User>([SELECT ID FROM User 
                                                   WHERE NAME = 'System Administrator1' 
                                                   OR NAME = 'AH Chatter External User3' 
                                                   OR NAME = 'System Administrator2']);
        system.assertEquals(3, insertedUsers.size(), 'Inserted users count mismatch..');
        
        // CREATE GROUPS
        List<Group> grpList = new List<Group>();
        for (Integer i=0; i<=4; i++)
        {
            Group g = NI_TestClassData.createGroup('Test Grp '+i, 'Test_Grp_'+i, 'Regular');
            grpList.add(g);
        }
        insert grpList;
        Set<ID> grpIds = new Set<ID>();
        grpIds.add(grpList[0].id);
        grpIds.add(grpList[1].id);
        grpIds.add(grpList[2].id);
        grpIds.add(grpList[3].id);
        grpIds.add(grpList[4].id);
        
        List<Group> insertedGrps = new List<Group>([SELECT ID FROM Group 
                                                    WHERE type='Regular' AND ID IN: grpIds]);
        system.assertEquals(5, insertedGrps.size(), 'Inserted groups count mismatch..');
        
        // ASSGIN GROUPS TO USERS
        List<GroupMember> gmList = new List<GroupMember>();
        GroupMember gm1 = NI_TestClassData.createGroupMember(grpList[0].id, u1.id);
        gmList.add(gm1);
        GroupMember gm2 = NI_TestClassData.createGroupMember(grpList[1].id, u1.id);
        gmList.add(gm2);
        GroupMember gm3 = NI_TestClassData.createGroupMember(grpList[2].id, u1.id);
        gmList.add(gm3);
        GroupMember gm4 = NI_TestClassData.createGroupMember(grpList[3].id, u2.id);
        gmList.add(gm4);
        GroupMember gm5 = NI_TestClassData.createGroupMember(grpList[4].id, u2.id);
        gmList.add(gm5);
        
        insert gmList;
        List<GroupMember> insertedGrpms = new List<GroupMember>([ SELECT ID FROM GroupMember 
                                                                 WHERE GroupId in: grpIds]);
        system.assertEquals(5, insertedGrpms.size(), 'Inserted group member count mismatch..');
        
        // CREATE QUEUES
        List<Group> queueList = new List<Group>();
        for (Integer i=10; i<=12; i++)
        {
            Group g = NI_TestClassData.createGroup('Test Queue '+i, 'Test_Queue_'+i, 'Queue');
            queueList.add(g);
        } 
        insert queueList;
        grpIds.add(queueList[0].id);
        grpIds.add(queueList[1].id);
        grpIds.add(queueList[2].id);
        
        List<Group> insertedQueues = new List<Group>([SELECT ID FROM Group WHERE type='Queue' AND Id IN: grpIds]);
        system.assertEquals(3, insertedQueues.size(), 'Inserted Queues count mismatch..');
        
        // ASSGIN QUEUES TO USERS
        List<GroupMember> gmList1 = new List<GroupMember>();
        GroupMember gm11 = NI_TestClassData.createGroupMember(queueList[0].id, u1.id);
        gmList1.add(gm11);
        GroupMember gm21 = NI_TestClassData.createGroupMember(queueList[1].id, u1.id);
        gmList1.add(gm21);
        GroupMember gm31 = NI_TestClassData.createGroupMember(queueList[2].id, u2.id);
        gmList1.add(gm31);
        
        insert gmList1;
        List<GroupMember> insertedGrpms1 = new List<GroupMember>([ SELECT ID FROM GroupMember WHERE GroupId IN: grpIds]);
        system.assertEquals(8, insertedGrpms1.size(), 'Inserted group member count mismatch..');
        
        // CREATE PREMISSOIN SETS
        List<PermissionSet> permissionSetList = new List<PermissionSet>();
        for (Integer i=0; i<=2; i++)
        {
            PermissionSet pr = new PermissionSet(Label='Test Permisson Set '+i,Name='Test_Permisson_Set_'+i);
            permissionSetList.add(pr);
        }
        
        insert permissionSetList;
        
        Set<ID> permSetIds = new Set<ID>();
        permSetIds.add(permissionSetList[0].Id);
        permSetIds.add(permissionSetList[1].Id);
        permSetIds.add(permissionSetList[2].Id);
        
        List<PermissionSet> insertedpermSets = new List<PermissionSet>([SELECT ID FROM PermissionSet WHERE ID IN: permSetIds]);
        system.assertEquals(3, insertedpermSets.size(), 'Inserted Permission Sets count mismatch..');
        
        // ASSIGN PREMISSOIN SETS
        List<PermissionSetAssignment> prList = new List<PermissionSetAssignment>();
        PermissionSetAssignment pm1 = new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = permissionSetList[0].id);
        PermissionSetAssignment pm2 = new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = permissionSetList[1].id);
        PermissionSetAssignment pm3 = new PermissionSetAssignment(AssigneeId = u2.id, PermissionSetId = permissionSetList[2].id);
        prList.add(pm1);
        prList.add(pm2);
        prList.add(pm3);
        insert prList;
        List<PermissionSetAssignment> insertedpermSetsAsmnt = new List<PermissionSetAssignment>([SELECT ID FROM PermissionSetAssignment
                                                                                                 WHERE PermissionSetId IN: permSetIds]);
        system.assertEquals(3, insertedpermSetsAsmnt.size(), 'Inserted Permission Sets count mismatch..');
        
        Test.stopTest();
        
    }
    
    // METHOD TO TEST ATTRIBUTES COPIED TO DESTINATION USER
    @isTest
    static void testMethod1()
    {
        
        Test.startTest();
        
        User user_1 = [SELECT ID, NAME FROM USER WHERE Name = 'System Administrator1'];
        User user_2 = [SELECT ID, NAME FROM USER WHERE Name = 'System Administrator2'];
        
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_CopyUserAttributes;
        pageRef.getParameters().put('user1', user_1.Name);
        
        Test.setCurrentPage(pageRef);
        
        AH_CopyUserAttributesController a = new AH_CopyUserAttributesController();
        a.search();
        
        pageRef.getParameters().put('user2', user_2.Name);
        
        a.contact1.OwnerId = user_1.Id;
        a.contact2.OwnerId = user_2.Id;
        
        a.verifyUsers();
        
        a.updateUser();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        system.debug('pageMessages : '+pageMessages);
        
        system.debug('pageMessages01 : ' + pageMessages[0].getSummary());
        system.debug('pageMessages02 : ' + pageMessages[1].getSummary());
        system.debug('pageMessages03 : ' + pageMessages[2].getSummary());
        system.debug('pageMessages04 : ' + pageMessages[3].getSummary());
        
        /*system.assertEquals('User Attributes assigned Succcessfully !!!', pageMessages[0].getSummary(), 'Error while copying User Attributes..');
        system.assertEquals('Groups assigned Succcessfully !!!', pageMessages[1].getSummary(), 'Error while copying Groups..');
        system.assertEquals('Permission Sets assigned Succcessfully !!!', pageMessages[2].getSummary(), 'Error while copying Permission Sets..');
        system.assertEquals('Queues assigned Succcessfully !!!', pageMessages[3].getSummary(), 'Error while copying Queues..');*/
        
        User user_22 = [SELECT ID, NAME, DepartmentCode__c, CompanyName, Xactly_User__c, ProfileId, UserRoleId 
                        FROM USER WHERE Name = 'System Administrator2'];
        
        UserRole ur = [select Id, Name from UserRole where Name = 'Services & Support'];
        Profile pr = [select ID, Name from Profile where Name = 'System Administrator'];
        
        //system.assertEquals(user_22.UserRoleId, ur.Id, 'User Role mismatch...');
        //system.assertEquals(user_22.ProfileId, pr.Id, 'User profile mismatch...');
        
        Test.stopTest();
        
    }
    
    // CHECK THE SEARCH STRING CODE    
    @isTest
    static void testMethod2()
    {
        Test.startTest();
        
        List<User> uList = [ SELECT ID, NAME FROM USER WHERE Name Like 'System Administrator%' ORDER BY Name];
        
        PageReference pageRef2 = Page.AH_CopyUserAttributes;
        pageRef2.getParameters().put('lksrch', 'System Administra');
        
        Test.setCurrentPage(pageRef2);
        AH_CopyUserAttributesController b = new AH_CopyUserAttributesController();
        b.search();
        
        Test.stopTest();
        
    }
    
    // TEST METHOD FOR DESTINATION USER& USERS WITH DIFF LICENSE TYPES
    @isTest
    static void testMethod3()
    {
        Test.startTest();
        
        User user_1 = [SELECT ID, NAME FROM USER WHERE Name = 'System Administrator1'];
        User user_2 = [SELECT ID, NAME FROM USER WHERE Name = 'AH Chatter External User3'];
        
        PageReference pageRef2 = Page.AH_CopyUserAttributes;
        pageRef2.getParameters().put('user2', user_2.Name);
        Test.setCurrentPage(pageRef2);
        AH_CopyUserAttributesController b = new AH_CopyUserAttributesController();
        b.search();
        
        b.contact1.OwnerId = user_1.Id;
        b.contact2.OwnerId = user_2.Id;
        
        b.verifyUsers();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        system.debug('pageMessages : ' + pageMessages);        
        system.assertEquals('Users have different License Type.', pageMessages[0].getSummary(), 'User Licenses should mismatch..');
        
        Test.stopTest();
        
    }
    
}