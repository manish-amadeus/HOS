// DISABLED "IMT" Implementation Tool designed for IHG 
/****************************************************************************************
Name            : NI_IMT_AutomationTest Class
Author          : Damodar Raut
Created Date    : 06/03/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that contains all test cases for IMT Tool testing
                : 
                : 
******************************************************************************************/
@isTest
public class NI_IMT_AutomationTest 
{

    static testMethod void test1() 
    {  
        test.startTest();
        system.assert(true);
        test.stopTest();
    }  
    
/*    
    //TEST GLOBAL SUPER USER PROPERTY PERMISSION
    public static testmethod void checkGlobalSuperUserPropertyPermission() 
    {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
        system.runAs(globalSuperUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL SUPER USER IMT CONTACT PERMISSION
    public static testmethod void checkGlobalSuperUserImtContactPermission() 
    {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
        system.runAs(globalSuperUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST GLOBAL SUPER USER SCHEDULING SET PERMISSION
    public static testmethod void checkGlobalSuperUserSchedulingSetPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
        system.runAs(globalSuperUser) {
            Schema.DescribeSObjectResult drSObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL SUPER USER PROJECT TASK PERMISSION
    public static testmethod void checkGlobalSuperUserProjectTaskPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
        system.runAs(globalSuperUser) {
            Schema.DescribeSObjectResult drSObj = pse__Project_Task__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL SUPER USER PROJECT PERMISSION
    public static testmethod void checkGlobalSuperUserProjectPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
        system.runAs(globalSuperUser) {
            Schema.DescribeSObjectResult drSObj = pse__Proj__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST GLOBAL SUPER USER SCHEDULE PERMISSION
    public static testmethod void checkGlobalSuperUserSchedulePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
        system.runAs(globalSuperUser) {
            Schema.DescribeSObjectResult drSObj = pse__Schedule__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL SUPER USER KNOWLEDGE PERMISSION
    public static testmethod void checkGlobalSuperUserKnowledgePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
        system.runAs(globalSuperUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL SUPER USER REPORT PERMISSION
    //public static testmethod void checkGlobalSuperUserReportPermission() {
//        Id roleId = NULL;
//        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
//        User globalSuperUser = imtUsers[0];
//        insert globalSuperUser;
//        system.runAs(globalSuperUser) {
//            Schema.DescribeSObjectResult drSObj = Report.sObjectType.getDescribe();
//            system.assert(drSObj.isCreateable());
//            system.assert(drSObj.isAccessible());
//            system.assert(drSObj.isUpdateable());
//            system.assert(drSObj.isDeletable());
//
//        }
        //Profile globalSuperUser = NI_IMT_TestDataFactory.reportAccess('NI IMT Global Super User');
        //system.assert(globalSuperUser.PermissionsCreateCustomizeReports);
        //system.assert(globalSuperUser.PermissionsEditMyReports);
        //system.assert(globalSuperUser.PermissionsNewReportBuilder);
    //}
    
    //TEST GLOBAL MANAGER USER PROPERTY PERMISSION
    public static testmethod void checkGlobalManagerPropertyPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Manager', 1, roleId);
        User globalManagerUser = imtUsers[0];
        insert globalManagerUser;
        system.runAs(globalManagerUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL MANAGER USER IMT CONTACT PERMISSION
    public static testmethod void checkGlobalManagerImtContactPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Manager', 1, roleId);
        User globalManagerUser = imtUsers[0];
        insert globalManagerUser;
        system.runAs(globalManagerUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST GLOBAL MANAGER USER SCHEDULING SET PERMISSION
    public static testmethod void checkGlobalManagerSchedulingSetPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Manager', 1, roleId);
        User globalManagerUser = imtUsers[0];
        insert globalManagerUser;
        system.runAs(globalManagerUser) {
            Schema.DescribeSObjectResult drSObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL MANAGER USER PROJECT TASK PERMISSION
    public static testmethod void checkGlobalManagerProjectTaskPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Manager', 1, roleId);
        User globalManagerUser = imtUsers[0];
        insert globalManagerUser;
        system.runAs(globalManagerUser) {
            Schema.DescribeSObjectResult drSObj = pse__Project_Task__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL MANAGER USER PROJECT PERMISSION
    public static testmethod void checkGlobalManagerProjectPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Manager', 1, roleId);
        User globalManagerUser = imtUsers[0];
        insert globalManagerUser;
        system.runAs(globalManagerUser) {
            Schema.DescribeSObjectResult drSObj = pse__Proj__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST GLOBAL MANAGER USER SCHEDULE PERMISSION
    public static testmethod void checkGlobalManagerSchedulePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Manager', 1, roleId);
        User globalManagerUser = imtUsers[0];
        insert globalManagerUser;
        system.runAs(globalManagerUser) {
            Schema.DescribeSObjectResult drSObj = pse__Schedule__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL MANAGER USER KNOWLEDGE PERMISSION
    public static testmethod void checkGlobalManagerKnowledgePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Manager', 1, roleId);
        User globalManagerUser = imtUsers[0];
        insert globalManagerUser;
        system.runAs(globalManagerUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL MANAGER USER REPORT PERMISSION
//    public static testmethod void checkGlobalManagerReportPermission() {
//        Id roleId = NULL;
//        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Manager', 1, roleId);
//        User globalManagerUser = imtUsers[0];
//        insert globalManagerUser;
//        system.runAs(globalManagerUser) {
//            Schema.DescribeSObjectResult drSObj = Report.sObjectType.getDescribe();
//            system.assert(!drSObj.isCreateable());
//            system.assert(drSObj.isAccessible());
//            system.assert(!drSObj.isUpdateable());
//            system.assert(!drSObj.isDeletable());
//        }
//    }
    
    
    //TEST GLOBAL TRAINING USER PROPERTY PERMISSION
    public static testmethod void checkGlobalTrainingPropertyPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Manager', 1, roleId);
        User globalTrainingUser = imtUsers[0];
        insert globalTrainingUser;
        system.runAs(globalTrainingUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL TRAINING USER IMT CONTACT PERMISSION
    public static testmethod void checkGlobalTrainingImtContactPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Training (Knowledge)', 1, roleId);
        User globalTrainingUser = imtUsers[0];
        insert globalTrainingUser;
        system.runAs(globalTrainingUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST GLOBAL TRAINING USER SCHEDULING SET PERMISSION
    public static testmethod void checkGlobalTrainingSchedulingSetPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Training (Knowledge)', 1, roleId);
        User globalTrainingUser = imtUsers[0];
        insert globalTrainingUser;
        system.runAs(globalTrainingUser) {
            Schema.DescribeSObjectResult drSObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL TRAINING USER PROJECT TASK PERMISSION
    public static testmethod void checkGlobalTrainingProjectTaskPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Training (Knowledge)', 1, roleId);
        User globalTrainingUser = imtUsers[0];
        insert globalTrainingUser;
        system.runAs(globalTrainingUser) {
            Schema.DescribeSObjectResult drSObj = pse__Project_Task__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL TRAINING USER PROJECT PERMISSION
    public static testmethod void checkGlobalTrainingProjectPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Training (Knowledge)', 1, roleId);
        User globalTrainingUser = imtUsers[0];
        insert globalTrainingUser;
        system.runAs(globalTrainingUser) {
            Schema.DescribeSObjectResult drSObj = pse__Proj__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST GLOBAL TRAINING USER SCHEDULE PERMISSION
    public static testmethod void checkGlobalTrainingSchedulePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Training (Knowledge)', 1, roleId);
        User globalTrainingUser = imtUsers[0];
        insert globalTrainingUser;
        system.runAs(globalTrainingUser) {
            Schema.DescribeSObjectResult drSObj = pse__Schedule__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL TRAINING USER KNOWLEDGE PERMISSION
    public static testmethod void checkGlobalTrainingKnowledgePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Training (Knowledge)', 1, roleId);
        User globalTrainingUser = imtUsers[0];
        insert globalTrainingUser;
        system.runAs(globalTrainingUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL TRAINING USER REPORT PERMISSION
//    public static testmethod void checkGlobalTrainingReportPermission() {
//        Id roleId = NULL;
//        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Training (Knowledge)', 1, roleId);
//        User globalTrainingUser = imtUsers[0];
//        insert globalTrainingUser;
//        system.runAs(globalTrainingUser) {
//            Schema.DescribeSObjectResult drSObj = Report.sObjectType.getDescribe();
//            system.assert(!drSObj.isCreateable());
//            system.assert(drSObj.isAccessible());
//            system.assert(!drSObj.isUpdateable());
//            system.assert(!drSObj.isDeletable());
//        }
//    }
    
    //TEST GLOBAL LEADERSHIP USER PROPERTY PERMISSION
    public static testmethod void checkGlobalLeadershipPropertyPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Leadership', 1, roleId);
        User globalLeadershipUser = imtUsers[0];
        insert globalLeadershipUser;
        system.runAs(globalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL LEADERSHIP USER IMT CONTACT PERMISSION
    public static testmethod void checkGlobalLeadershipImtContactPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Leadership', 1, roleId);
        User globalLeadershipUser = imtUsers[0];
        insert globalLeadershipUser;
        system.runAs(globalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST GLOBAL LEADERSHIP USER SCHEDULING SET PERMISSION
    public static testmethod void checkGlobalLeadershipSchedulingSetPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Leadership', 1, roleId);
        User globalLeadershipUser = imtUsers[0];
        insert globalLeadershipUser;
        system.runAs(globalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL LEADERSHIP USER PROJECT TASK PERMISSION
    public static testmethod void checkGlobalLeadershipProjectTaskPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Leadership', 1, roleId);
        User globalLeadershipUser = imtUsers[0];
        insert globalLeadershipUser;
        system.runAs(globalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = pse__Project_Task__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL LEADERSHIP USER PROJECT PERMISSION
    public static testmethod void checkGlobalLeadershipProjectPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Leadership', 1, roleId);
        User globalLeadershipUser = imtUsers[0];
        insert globalLeadershipUser;
        system.runAs(globalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = pse__Proj__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST GLOBAL LEADERSHIP USER SCHEDULE PERMISSION
    public static testmethod void checkGlobalLeadershipSchedulePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Leadership', 1, roleId);
        User globalLeadershipUser = imtUsers[0];
        insert globalLeadershipUser;
        system.runAs(globalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = pse__Schedule__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL LEADERSHIP USER KNOWLEDGE PERMISSION
    public static testmethod void checkGlobalLeadershipKnowledgePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Leadership', 1, roleId);
        User globalLeadershipUser = imtUsers[0];
        insert globalLeadershipUser;
        system.runAs(globalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST GLOBAL LEADERSHIP USER REPORT PERMISSION
//    public static testmethod void checkGlobalLeadershipReportPermission() {
//        Id roleId = NULL;
//        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Leadership', 1, roleId);
//        User globalLeadershipUser = imtUsers[0];
//        insert globalLeadershipUser;
//        system.runAs(globalLeadershipUser) {
//            Schema.DescribeSObjectResult drSObj = Report.sObjectType.getDescribe();
//            system.assert(!drSObj.isCreateable());
//            system.assert(drSObj.isAccessible());
//            system.assert(!drSObj.isUpdateable());
//            system.assert(!drSObj.isDeletable());
//        }
//    }
    
    //TEST REGIONAL ADMIN USER PROPERTY PERMISSION
    public static testmethod void checkRegionalAdminPropertyPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Admin', 1, roleId);
        User regionalAdminUser = imtUsers[0];
        insert regionalAdminUser;
        system.runAs(regionalAdminUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL ADMIN USER IMT CONTACT PERMISSION
    public static testmethod void checkRegionalAdminImtContactPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Admin', 1, roleId);
        User regionalAdminUser = imtUsers[0];
        insert regionalAdminUser;
        system.runAs(regionalAdminUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST REGIONAL ADMIN USER SCHEDULING SET PERMISSION
    public static testmethod void checkRegionalAdminSchedulingSetPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Admin', 1, roleId);
        User regionalAdminUser = imtUsers[0];
        insert regionalAdminUser;
        system.runAs(regionalAdminUser) {
            Schema.DescribeSObjectResult drSObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL ADMIN USER PROJECT TASK PERMISSION
    public static testmethod void checkRegionalAdminProjectTaskPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Admin', 1, roleId);
        User regionalAdminUser = imtUsers[0];
        insert regionalAdminUser;
        system.runAs(regionalAdminUser) {
            Schema.DescribeSObjectResult drSObj = pse__Project_Task__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL ADMIN USER PROJECT PERMISSION
    public static testmethod void checkRegionalAdminProjectPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Admin', 1, roleId);
        User regionalAdminUser = imtUsers[0];
        insert regionalAdminUser;
        system.runAs(regionalAdminUser) {
            Schema.DescribeSObjectResult drSObj = pse__Proj__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL ADMIN USER SCHEDULE PERMISSION
    public static testmethod void checkRegionalAdminSchedulePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Admin', 1, roleId);
        User regionalAdminUser = imtUsers[0];
        insert regionalAdminUser;
        system.runAs(regionalAdminUser) {
            Schema.DescribeSObjectResult drSObj = pse__Schedule__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL ADMIN USER KNOWLEDGE PERMISSION
    public static testmethod void checkRegionalAdminKnowledgePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Admin', 1, roleId);
        User regionalAdminUser = imtUsers[0];
        insert regionalAdminUser;
        system.runAs(regionalAdminUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL ADMIN USER REPORT PERMISSION
//    public static testmethod void checkRegionalAdminReportPermission() {
//        Id roleId = NULL;
//        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Admin', 1, roleId);
//        User regionalAdminUser = imtUsers[0];
//        insert regionalAdminUser;
//        system.runAs(regionalAdminUser) {
//            Schema.DescribeSObjectResult drSObj = Report.sObjectType.getDescribe();
//            system.assert(!drSObj.isCreateable());
//            system.assert(drSObj.isAccessible());
//            system.assert(!drSObj.isUpdateable());
//            system.assert(!drSObj.isDeletable());
//        }
//    }
    
    //TEST IMPLEMENTATION LEADS USER PROPERTY PERMISSION
    public static testmethod void checkImplementationLeadsPropertyPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Implementation Leads', 1, roleId);
        User implementationLeadsUser = imtUsers[0];
        insert implementationLeadsUser;
        system.runAs(implementationLeadsUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST IMPLEMENTATION LEADS USER IMT CONTACT PERMISSION
    public static testmethod void checkImplementationLeadsImtContactPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Implementation Leads', 1, roleId);
        User implementationLeadsUser = imtUsers[0];
        insert implementationLeadsUser;
        system.runAs(implementationLeadsUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST IMPLEMENTATION LEADS USER SCHEDULING SET PERMISSION
    public static testmethod void checkImplementationLeadsSchedulingSetPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Implementation Leads', 1, roleId);
        User implementationLeadsUser = imtUsers[0];
        insert implementationLeadsUser;
        system.runAs(implementationLeadsUser) {
            Schema.DescribeSObjectResult drSObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST IMPLEMENTATION LEADS USER PROJECT TASK PERMISSION
    public static testmethod void checkImplementationLeadsProjectTaskPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Implementation Leads', 1, roleId);
        User implementationLeadsUser = imtUsers[0];
        insert implementationLeadsUser;
        system.runAs(implementationLeadsUser) {
            Schema.DescribeSObjectResult drSObj = pse__Project_Task__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(drSObj.isDeletable());
        }
    }
    
    //TEST IMPLEMENTATION LEADS USER PROJECT PERMISSION
    public static testmethod void checkImplementationLeadsProjectPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Implementation Leads', 1, roleId);
        User implementationLeadsUser = imtUsers[0];
        insert implementationLeadsUser;
        system.runAs(implementationLeadsUser) {
            Schema.DescribeSObjectResult drSObj = pse__Proj__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST IMPLEMENTATION LEADS USER SCHEDULE PERMISSION
    public static testmethod void checkImplementationLeadsSchedulePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Implementation Leads', 1, roleId);
        User implementationLeadsUser = imtUsers[0];
        insert implementationLeadsUser;
        system.runAs(implementationLeadsUser) {
            Schema.DescribeSObjectResult drSObj = pse__Schedule__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST IMPLEMENTATION LEADS USER KNOWLEDGE PERMISSION
    public static testmethod void checkImplementationLeadsKnowledgePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Implementation Leads', 1, roleId);
        User implementationLeadsUser = imtUsers[0];
        insert implementationLeadsUser;
        system.runAs(implementationLeadsUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST IMPLEMENTATION LEADS USER REPORT PERMISSION
//    public static testmethod void checkImplementationLeadsReportPermission() {
//        Id roleId = NULL;
//        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Implementation Leads', 1, roleId);
//        User implementationLeadsUser = imtUsers[0];
//        insert implementationLeadsUser;
//        system.runAs(implementationLeadsUser) {
//            Schema.DescribeSObjectResult drSObj = Report.sObjectType.getDescribe();
//            system.assert(!drSObj.isCreateable());
//            system.assert(drSObj.isAccessible());
//            system.assert(!drSObj.isUpdateable());
//            system.assert(!drSObj.isDeletable());
//        }
//    }
    
    //TEST REGIONAL LEADERSHIP USER PROPERTY PERMISSION
    public static testmethod void checkRegionalLeadershipPropertyPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Leadership', 1, roleId);
        User regionalLeadershipUser = imtUsers[0];
        insert regionalLeadershipUser;
        system.runAs(regionalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL LEADERSHIP USER IMT CONTACT PERMISSION
    public static testmethod void checkRegionalLeadershipImtContactPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Leadership', 1, roleId);
        User regionalLeadershipUser = imtUsers[0];
        insert regionalLeadershipUser;
        system.runAs(regionalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST REGIONAL LEADERSHIP USER SCHEDULING SET PERMISSION
    public static testmethod void checkRegionalLeadershipSchedulingSetPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Leadership', 1, roleId);
        User regionalLeadershipUser = imtUsers[0];
        insert regionalLeadershipUser;
        system.runAs(regionalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL LEADERSHIP USER PROJECT TASK PERMISSION
    public static testmethod void checkRegionalLeadershipProjectTaskPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Leadership', 1, roleId);
        User regionalLeadershipUser = imtUsers[0];
        insert regionalLeadershipUser;
        system.runAs(regionalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = pse__Project_Task__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL LEADERSHIP USER PROJECT PERMISSION
    public static testmethod void checkRegionalLeadershipProjectPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Leadership', 1, roleId);
        User regionalLeadershipUser = imtUsers[0];
        insert regionalLeadershipUser;
        system.runAs(regionalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = pse__Proj__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL LEADERSHIP USER EVENT PERMISSION
//    public static testmethod void checkRegionalLeadershipEventPermission() {
//        Id roleId = NULL;
//        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Leadership', 1, roleId);
//        User regionalLeadershipUser = imtUsers[0];
//        insert regionalLeadershipUser;
//        system.runAs(regionalLeadershipUser) {
//            Schema.DescribeSObjectResult drSObj = Event.sObjectType.getDescribe();
//            system.assert(!drSObj.isCreateable());
//            system.assert(drSObj.isAccessible());
//            system.assert(!drSObj.isUpdateable());
//            system.assert(!drSObj.isDeletable());
//        }
//    }
    
    //TEST REGIONAL LEADERSHIP USER SCHEDULE PERMISSION
    public static testmethod void checkRegionalLeadershipSchedulePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Leadership', 1, roleId);
        User regionalLeadershipUser = imtUsers[0];
        insert regionalLeadershipUser;
        system.runAs(regionalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = pse__Schedule__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL LEADERSHIP USER KNOWLEDGE PERMISSION
    public static testmethod void checkRegionalLeadershipKnowledgePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Leadership', 1, roleId);
        User regionalLeadershipUser = imtUsers[0];
        insert regionalLeadershipUser;
        system.runAs(regionalLeadershipUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST REGIONAL LEADERSHIP USER REPORT PERMISSION
//    public static testmethod void checkRegionalLeadershipReportPermission() {
//        Id roleId = NULL;
//        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Leadership', 1, roleId);
//        User regionalLeadershipUser = imtUsers[0];
//        insert regionalLeadershipUser;
//        system.runAs(regionalLeadershipUser) {
//            Schema.DescribeSObjectResult drSObj = Report.sObjectType.getDescribe();
//            system.assert(!drSObj.isCreateable());
//            system.assert(drSObj.isAccessible());
//            system.assert(!drSObj.isUpdateable());
//            system.assert(!drSObj.isDeletable());
//        }
//    }
    
    //TEST TRIAGE USER PROPERTY PERMISSION
    public static testmethod void checkTriageUserPropertyPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Triage User', 1, roleId);
        User triageUser = imtUsers[0];
        insert triageUser;
        system.runAs(triageUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST TRIAGE USER IMT CONTACT PERMISSION
    public static testmethod void checkTriageUserImtContactPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Triage User', 1, roleId);
        User triageUser = imtUsers[0];
        insert triageUser;
        system.runAs(triageUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST TRIAGE USER SCHEDULING SET PERMISSION
    public static testmethod void checkTriageUserSchedulingSetPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Triage User', 1, roleId);
        User triageUser = imtUsers[0];
        insert triageUser;
        system.runAs(triageUser) {
            Schema.DescribeSObjectResult drSObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST TRIAGE USER PROJECT TASK PERMISSION
    public static testmethod void checkTriageUserProjectTaskPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Triage User', 1, roleId);
        User triageUser = imtUsers[0];
        insert triageUser;
        system.runAs(triageUser) {
            Schema.DescribeSObjectResult drSObj = pse__Project_Task__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST TRIAGE USER PROJECT PERMISSION
    public static testmethod void checkTriageUserProjectPermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Triage User', 1, roleId);
        User triageUser = imtUsers[0];
        insert triageUser;
        system.runAs(triageUser) {
            Schema.DescribeSObjectResult drSObj = pse__Proj__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
        
    //TEST TRIAGE USER SCHEDULE PERMISSION
    public static testmethod void checkTriageUserSchedulePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Triage User', 1, roleId);
        User triageUser = imtUsers[0];
        insert triageUser;
        system.runAs(triageUser) {
            Schema.DescribeSObjectResult drSObj = pse__Schedule__c.sObjectType.getDescribe();
            system.assert(!drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(!drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST TRIAGE USER KNOWLEDGE PERMISSION
    public static testmethod void checkTriageUserKnowledgePermission() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Triage User', 1, roleId);
        User triageUser = imtUsers[0];
        insert triageUser;
        system.runAs(triageUser) {
            Schema.DescribeSObjectResult drSObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(drSObj.isCreateable());
            system.assert(drSObj.isAccessible());
            system.assert(drSObj.isUpdateable());
            system.assert(!drSObj.isDeletable());
        }
    }
    
    //TEST TRIAGE USER REPORT PERMISSION
//    public static testmethod void checkTriageUserReportPermission() {
//        Id roleId = NULL;
//        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Triage User', 1, roleId);
//        User triageUser = imtUsers[0];
//        insert triageUser;
//        system.runAs(triageUser) {
//            Schema.DescribeSObjectResult drSObj = Report.sObjectType.getDescribe();
//            system.assert(!drSObj.isCreateable());
//            system.assert(drSObj.isAccessible());
//            system.assert(!drSObj.isUpdateable());
//            system.assert(!drSObj.isDeletable());
//        }
//    }
    
    //TEST PROPERTY COUNTRY CODE IS 2 CHARACTERS
    public static testmethod void checkPropertyCountryCodeIsTwoChars() {
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(2);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        system.assert(testProp1.Id != NULL);
        
        NI_IMT_Property__c testProp2 = props[1];
        testProp2.Country__c = 'USA';
        try {
            insert testProp2;
        } catch (Exception e ) {
            system.assert(e.getMessage().contains('The country code must be 2 characters'));
        }   
    }
    
    //TEST PROPERTY COMPLEXITY VALUE IS MAXIMUM 20
    public static testmethod void checkPropertyComplexityMaxValue() {
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(2);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        system.assert(testProp1.Id != NULL);
        
        NI_IMT_Property__c testProp2 = props[1];
        testProp2.IMT_Complexity_Value__c = 21;
        try {
            insert testProp2;
        } catch (Exception e ) {
            system.assert(e.getMessage().contains('Complexity value cannot be greater than 20'));
        }   
    }
    
    //TEST PROPERTY CODE IS UNIQUE
    public static testmethod void checkPropertyHasUniqueCode() {
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(2);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        system.assert(testProp1.Id != NULL);
        
        NI_IMT_Property__c testProp2 = props[1];
        testProp2.Property_Code__c = 'TESTA';
        try {
            insert testProp2;
        } catch (Exception e ) {
            system.assert(e.getMessage().contains('DUPLICATE_VALUE'));
            //system.assert(e.getMessage().contains('AAA'));
        }   
    }
    
    //TEST PROPERTY CODE LENGTH AND CHARACTERS
    public static testmethod void checkPropertyCodeValidation() {
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(2);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        system.assert(testProp1.Id != NULL);
        
        NI_IMT_Property__c testProp2 = props[1];
        testProp2.Property_Code__c = 'TESTAB';
        try {
            insert testProp2;
        } catch (Exception e ) {
            system.assert(e.getMessage().contains('The property code must be 5 characters only and cannot contain numbers'));
        }
        
        testProp2.Property_Code__c = 'TEST1';
        try {
            insert testProp2;
        } catch (Exception e ) {
            system.assert(e.getMessage().contains('The property code must be 5 characters only and cannot contain numbers'));
        }   
    }
    
    //TEST PROPERTY PO AND PERFORM SELECTED
    public static testmethod void checkPropertyPoPerformValidation() {
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(2);
        NI_IMT_Property__c testProp1 = props[0];
        testProp1.PO__c = TRUE;
        testProp1.PERFORM__c  = TRUE;
        insert testProp1;
        system.assert(testProp1.Id != NULL);
        
        NI_IMT_Property__c testProp2 = props[1];
        testProp2.PO__c = TRUE;
        try {
            insert testProp2;
        } catch (Exception e ) {
            system.assert(e.getMessage().contains('When PO has been selected, the PERFORM checkbox must also be selected'));
        }   
        
        testProp2.PO__c = FALSE;
        testProp2.PERFORM__c = FALSE;
        insert testProp2;
        system.assert(testProp2.Id != NULL);
    }
    
    //TEST PROPERTY CODE CHANGE
    public static testmethod void checkPropertyCodeCannotChange() {
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(2);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        system.assert(testProp1.Id != NULL);
        testProp1.Property_Code__c = 'TESTB';
        try {
            update testProp1;
        } catch (Exception e ) {
            system.debug(system.LoggingLevel.ERROR,e.getMessage());
            system.assert(e.getMessage().contains('The property code cannot be changed once the record has been saved'));
        } 
    }
    
    //TEST PROPERTY NAME CHANGE
//    public static testmethod void checkPropertyNameChange() {
//        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(2);
//        NI_IMT_Property__c testProp1 = props[0];
//        system.runAs(new User(Id = Userinfo.getUserId())) {
//            insert testProp1;
//            system.assert(testProp1.Id != NULL);
//        }
//        Id roleId = NULL;
//        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Implementation Leads', 1, roleId);
//        User newUser = imtUsers[0];
//        insert newUser;
//        system.runAs(newUser) {
//            system.debug('Name' + testProp1.Name);
//            //testProp1.Name = 'TESTB';
//            NI_IMT_Property__c prop1 = [SELECT City__c FROM NI_IMT_Property__c WHERE Id = :testProp1.Id];
//            prop1.City__c = 'LA';
//            try {
//                update prop1;
//            } catch (Exception e ) {
//                system.debug(system.LoggingLevel.ERROR,e.getMessage());
//                system.assert(e.getMessage().contains('The property code cannot be changed once the record has been saved'));
//            }       
//        }
//    }
    
    //TEST IF PROPERTY STATUS IS CHANGED TO "Inactive", THE PROJECT STAGE AND ASSIGNMENT STATUS IS CANCELED.
    public static testmethod void checkPropertyNoLongerEligible() {
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();
        NI_IMT_TestDataFactory.createSchedulingSetConfig();    
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
        
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
                
        system.runAs(globalSuperUser) {
        
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
            
            Contact contact1 = contacts[1];
            contact1.pse__Is_Resource__c = true;
            contact1.pse__Is_Resource_Active__c = true;
            contact1.pse__Salesforce_User__c = globalSuperUser.Id;
            insert contact1;
            
            NI_IMT_TestDataFactory.createPermissionControl(globalSuperUser.Id, contact1.Id, regionId);
            
            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
            pse__Proj__c testProj1 = projects[0];
            testProj1.pse__Project_Manager__c = contact1.Id;
            insert testProj1;
            
            List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
            IMT_Migration_Set__c set1 = schedulingSets[0];
            set1.RecordTypeId = imtSchdlSetRecordTypeId;
            insert set1;
        
            List<pse__Schedule__c> schduleList = NI_IMT_TestDataFactory.createSchedule(1);
            pse__Schedule__c schedule1 = schduleList[0];
            insert schedule1;
        
            List<pse__Assignment__c> assignments = NI_IMT_TestDataFactory.createAssignments(1,schedule1.Id,testProj1.Id,contact1.Id,set1.Id);
            pse__Assignment__c assignment1 = assignments[0];
            assignment1.pse__Status__c = 'Complete';
            insert assignment1;
            
            testProp1.Status__c = 'Inactive';
            update testProp1;
            
            pse__Proj__c updatedProj = [SELECT pse__Stage__c FROM pse__Proj__c WHERE Id = :testProj1.Id];
            system.assertEquals('Canceled', updatedProj.pse__Stage__c);
            
            pse__Assignment__c updatedAssign = [SELECT pse__Status__c from pse__Assignment__c WHERE  id =:assignment1.Id];
            system.assertEquals('Canceled', updatedAssign.pse__Status__c);
        }
    }
    
    //TEST IMT CONTACT COUNTRY CODE IS 2 CHARACTERS
    public static testmethod void checkImtContactCountryCodeIsTwoChars() {
        List<NI_IMT_Contact__c> contacts = NI_IMT_TestDataFactory.createImtContacts(2);
        NI_IMT_Contact__c testCon1 = contacts[0];
        insert testCon1;
        system.assert(testCon1.Id != NULL);
        
        NI_IMT_Contact__c testCon2 = contacts[1];
        testCon2.Country__c = 'USA';
        try {
            insert testCon2;
        } catch (Exception e ) {
            system.assert(e.getMessage().contains('The country code must be 2 characters'));
        }   
    }
    
    //TEST IMT CONTACT HAS UNIQUE EMAIL ADDRESS
    public static testmethod void checkImtContactHasUniqueEmail() {
        List<NI_IMT_Contact__c> contacts = NI_IMT_TestDataFactory.createImtContacts(2);
        NI_IMT_Contact__c testCon1 = contacts[0];
        insert testCon1;
        system.assert(testCon1.Id != NULL);
        
        NI_IMT_Contact__c testCon2 = contacts[1];
        testCon2.Email__c = testCon1.Email__c;
        try {
            insert testCon2;
        } catch (Exception e ) {
            system.assert(e.getMessage().contains('DUPLICATE_VALUE'));
        }   
    }
    
    //TEST PROJECT START DATE CANNOT BE AFTER END DATE
    public static testmethod void checkProjectStartDateBeforeEndDate() {
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
        Contact contact1 = contacts[0];
        insert contact1;
        
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();
        
        List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
        pse__Proj__c testProj1 = projects[0];
        insert testProj1;
        system.assert(testProj1.Id != NULL);
        
        testProj1.pse__Start_Date__c = testProj1.pse__End_Date__c + 1;
        try {
            update testProj1;
        } catch (Exception e ) {
            system.assert(e.getMessage().contains('Start Date should be some date before End date'));
        }        
    }
    
    
    //TEST PROJECT CANNOT SKIP STAGE
    public static testmethod void checkProjectCannotSkipStage() {
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
        Contact contact1 = contacts[0];
        insert contact1;
        
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();
        
        List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
        pse__Proj__c testProj1 = projects[0];
        testProj1.pse__Stage__c = 'Pre';
        insert testProj1;
        system.assert(testProj1.Id != NULL);
        
        testProj1.pse__Stage__c = 'Post';
        try {
            update testProj1;
        } catch (Exception e ) {
            system.assert(e.getMessage().contains('Stage cannot be changed to the new value selected'));
        }        
    }
    
//    //TEST PROJECT START DATE IS SET WHEN PROJECT TASK CREATED
//    public static testmethod void checkProjectStartDateWhenProjectTaskCreated() {
//        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');        
//        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
//        NI_IMT_Property__c testProp1 = props[0];
//        insert testProp1;        
//        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
//        Contact contact1 = contacts[0];
//        insert contact1;        
//        NI_IMT_TestDataFactory.createCustomSettings();
//        NI_IMT_TestDataFactory.createChatterGroups();        
//        List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
//        pse__Proj__c testProj1 = projects[0];
//        testProj1.pse__Start_Date__c = Date.today() + 2;
//        insert testProj1;
//        system.assert(testProj1.Id != NULL);        
//        List<pse__Project_Task__c> projTasks =  NI_IMT_TestDataFactory.createProjectTask(1, testProj1.Id);     
//         pse__Project_Task__c projTask = projTasks[0];
//         insert projTask;         
//         system.assert(testProj1.pse__Start_Date__c == Date.today());
//    }
    
//    //TEST PROPERTY CODE, BRAND, NAME AND REGION IS COPIED TO PROJECT AFTER CREATION
//    public static testmethod void checkProjectPropertyInfo() {
//        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');        
//        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
//        NI_IMT_Property__c testProp1 = props[0];
//        testProp1.Region__c = 'Americas';
//        testProp1.Subregion__c = 'Northeast';
//        testProp1.Brand__c = 'InterContinental';
//        insert testProp1;        
//        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
//        Contact contact1 = contacts[0];
//        insert contact1;        
//        NI_IMT_TestDataFactory.createCustomSettings();
//        NI_IMT_TestDataFactory.createChatterGroups();        
//        List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
//        pse__Proj__c testProj1 = projects[0];
//        insert testProj1;
//        system.assert(testProj1.Id != NULL);
//        pse__Proj__c updatedProj = [SELECT Property_Code__c,Subregion__c,IMT_Property__c FROM pse__Proj__c WHERE Id =:testProj1.Id];
//        system.assertEquals(updatedProj.Property_Code__c, testProp1.Property_Code__c);
//         system.assertEquals(updatedProj.Subregion__c, testProp1.Subregion__c);
//         system.assertEquals(updatedProj.IMT_Property__c, testProp1.Id);
//    }
    
    //TEST SCHEDULING SET TOTAL PLANNED VALUE CANNOT EXCEED 100
    public static testmethod void checkSchedulingSetTotalPlannedValueNotAbove100() {
        NI_IMT_TestDataFactory.createSchedulingSetConfig();
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(2);
        IMT_Migration_Set__c set1 = schedulingSets[0];
        set1.RecordTypeId = imtSchdlSetRecordTypeId;
        insert set1;
        system.assert(set1.Id != NULL);
        IMT_Migration_Set__c set2 = schedulingSets[1];
        set2.RecordTypeId = imtSchdlSetRecordTypeId;
        set2.Budgeted_Complexity_1__c = 101;
        set2.Start__c = set2.Start__c + 1;
        try {
            insert set2;
        }
        catch (Exception e) {
            system.assert(e.getMessage().contains('Total planned value cannot be greater than 100'));    
        }
    }
    
    //TEST SCHEDULING SET DATE MUST BE UNIQUE 
    public static testmethod void checkSchedulingSetHasUniqueDate() {
        NI_IMT_TestDataFactory.createSchedulingSetConfig();
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(2);
        IMT_Migration_Set__c set1 = schedulingSets[0];
        set1.RecordTypeId = imtSchdlSetRecordTypeId;
        insert set1;
        system.assert(set1.Id != NULL);
        IMT_Migration_Set__c set2 = schedulingSets[1];
        set2.RecordTypeId = imtSchdlSetRecordTypeId;
        try {
            insert set2;
        }
        catch (Exception e) {
            system.assert(e.getMessage().contains('The date for the scheduling set needs to be unique.'));    
        }
    }
    
    //TEST SCHEDULING SET DATE MUST BE UNIQUE 
//    public static testmethod void checkSchedulingSetClosedStatus() {
//        List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
//        IMT_Migration_Set__c set1 = schedulingSets[0];
//        set1.Start__c = Date.Today() + 22;
//        Test.startTest();
//        insert set1;
//        Test.stopTest();
//        system.assertEquals('Closed', set1.Status__c);
//    }
    
    //TEST SCHEDULING SET NOT OPEN
    public static testmethod void checkSchedulingSetNotCompleteForAddingAssignments() {
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();    
        NI_IMT_TestDataFactory.createSchedulingSetConfig();
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
        
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
                
        system.runAs(globalSuperUser) {
        
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
            
            Contact contact1 = contacts[1];
            contact1.pse__Is_Resource__c = true;
            contact1.pse__Is_Resource_Active__c = true;
            insert contact1;
            
            NI_IMT_TestDataFactory.createPermissionControl(globalSuperUser.Id, contact1.Id, regionId);
            
            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
            pse__Proj__c testProj1 = projects[0];
            insert testProj1;
            
            List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
            IMT_Migration_Set__c set1 = schedulingSets[0];
            set1.Status__c = 'Complete';
            set1.RecordTypeId = imtSchdlSetRecordTypeId;
            insert set1;
        
            List<pse__Schedule__c> schduleList = NI_IMT_TestDataFactory.createSchedule(1);
            pse__Schedule__c schedule1 = schduleList[0];
            insert schedule1;
        
            List<pse__Assignment__c> assignments = NI_IMT_TestDataFactory.createAssignments(1,schedule1.Id,testProj1.Id,contact1.Id,set1.Id);
            pse__Assignment__c assignment1 = assignments[0];
            try {
                insert assignment1;
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains('An assignment cannot be added to a scheduling set that is not open'));    
            }
        }
    }
    
    //TEST SCHEDULING SET SHOULD BE OPEN WHILE ADDING ASSIGNMENTS
    public static testmethod void checkSchedulingSetNotClosedForAddingAssignments() {
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();    
        NI_IMT_TestDataFactory.createSchedulingSetConfig();
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
        
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
                
        system.runAs(globalSuperUser) {
        
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
            
            Contact contact1 = contacts[1];
            contact1.pse__Is_Resource__c = true;
            contact1.pse__Is_Resource_Active__c = true;
            insert contact1;
            
            NI_IMT_TestDataFactory.createPermissionControl(globalSuperUser.Id, contact1.Id, regionId);
            
            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
            pse__Proj__c testProj1 = projects[0];
            insert testProj1;
            
            List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
            IMT_Migration_Set__c set1 = schedulingSets[0];
            set1.RecordTypeId = imtSchdlSetRecordTypeId;
            set1.Status__c = 'Closed';
            insert set1;
        
            List<pse__Schedule__c> schduleList = NI_IMT_TestDataFactory.createSchedule(1);
            pse__Schedule__c schedule1 = schduleList[0];
            insert schedule1;
        
            List<pse__Assignment__c> assignments = NI_IMT_TestDataFactory.createAssignments(1,schedule1.Id,testProj1.Id,contact1.Id,set1.Id);
            pse__Assignment__c assignment1 = assignments[0];
            try {
                insert assignment1;
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains('An assignment cannot be added to a scheduling set that is not open'));    
            }
        }
    }
    
    //TEST ASSIGNMENT CREATION DO NOT OVERBOOK SCHEDULE
    public static testmethod void checkAssignmentsOverbooking() {
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();    
        NI_IMT_TestDataFactory.createSchedulingSetConfig();    
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
        
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
                
        system.runAs(globalSuperUser) {
        
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
            
            Contact contact1 = contacts[1];
            contact1.pse__Is_Resource__c = true;
            contact1.pse__Is_Resource_Active__c = true;
            insert contact1;
            
            NI_IMT_TestDataFactory.createPermissionControl(globalSuperUser.Id, contact1.Id, regionId);
            
            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
            pse__Proj__c testProj1 = projects[0];
            insert testProj1;
            
            List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
            IMT_Migration_Set__c set1 = schedulingSets[0];
            set1.Budgeted_Complexity_1__c = 0;
            set1.RecordTypeId = imtSchdlSetRecordTypeId;
            insert set1;
        
            List<pse__Schedule__c> schduleList = NI_IMT_TestDataFactory.createSchedule(1);
            pse__Schedule__c schedule1 = schduleList[0];
            insert schedule1;
        
            List<pse__Assignment__c> assignments = NI_IMT_TestDataFactory.createAssignments(1,schedule1.Id,testProj1.Id,contact1.Id,set1.Id);
            pse__Assignment__c assignment1 = assignments[0];
            try {
                insert assignment1;
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains('The assignment will overschedule the total budget of the scheduling set'));    
            }
        }
    }
    
    //TEST ASSIGNMENT CREATION DO NOT OVERBOOK SCHEDULE MIX
    public static testmethod void checkAssignmentsOverbookingMix() {
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();    
        NI_IMT_TestDataFactory.createSchedulingSetConfig();    
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
        
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
                
        system.runAs(globalSuperUser) {
        
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
            
            Contact contact1 = contacts[1];
            contact1.pse__Is_Resource__c = true;
            contact1.pse__Is_Resource_Active__c = true;
            insert contact1;
            
            NI_IMT_TestDataFactory.createPermissionControl(globalSuperUser.Id, contact1.Id, regionId);
            
            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
            pse__Proj__c testProj1 = projects[0];
            insert testProj1;
            
            List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
            IMT_Migration_Set__c set1 = schedulingSets[0];
            set1.RecordTypeId = imtSchdlSetRecordTypeId;
            set1.Budgeted_Complexity_Mix__c = 0;
            insert set1;
        
            List<pse__Schedule__c> schduleList = NI_IMT_TestDataFactory.createSchedule(1);
            pse__Schedule__c schedule1 = schduleList[0];
            insert schedule1;
        
            List<pse__Assignment__c> assignments = NI_IMT_TestDataFactory.createAssignments(1,schedule1.Id,testProj1.Id,contact1.Id,set1.Id);
            pse__Assignment__c assignment1 = assignments[0];
            try {
                insert assignment1;
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains('The assignment will overschedule the planned complexity mix of the scheduling set'));    
            }
        }
    }
    
    //TEST APPROVAL PROCESS WHEN ASSIGNMENT IS CREATED BY REGIONAL ADMIN
    public static testmethod void checkCreateAssignmentByRegionalAdmin() {
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();    
        NI_IMT_TestDataFactory.createSchedulingSetConfig();    
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
        
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Regional Admin', 1, roleId);
        User newUser = imtUsers[0];
        insert newUser;
                
        system.runAs(newUser) {
        
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
            testProp1.Timezone__c = 'IST ( GMT 5.50 )';
            update testProp1;
            
            Contact contact1 = contacts[1];
            contact1.pse__Is_Resource__c = true;
            contact1.pse__Is_Resource_Active__c = true;
            insert contact1;
            
            Id migrationOpId = NI_IMT_TestDataFactory.createMigrationOperator();
            
            NI_IMT_TestDataFactory.createPermissionControl(newUser.Id, migrationOpId, regionId);
            
            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(2, regionId, testProp1.Id, contact1.Id);
            pse__Proj__c testProj1 = projects[0];
            insert testProj1;
            pse__Proj__c testProj2 = projects[1];
            insert testProj2;
            
            List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
            IMT_Migration_Set__c set1 = schedulingSets[0];
            set1.RecordTypeId = imtSchdlSetRecordTypeId;
            insert set1;
        
            //TEST CREATE ASSIGNMENT
            ApexPages.currentPage().getParameters().put('Ids',+testProj1.Id+':'+testProj2.Id+'|');
            ApexPages.currentPage().getParameters().put('migrationSetID',set1.Id);
            NI_IMT_CreateScheduleController cntrlObj = new NI_IMT_CreateScheduleController();
            cntrlObj.init();
            PageReference ref = cntrlObj.createAssignment();
            pse__Assignment__c newAssign = [SELECT pse__Status__c FROM  pse__Assignment__c WHERE pse__Project__c = :testProj1.Id];
            system.assertEquals('Tentative', newAssign.pse__Status__c);
            ProcessInstance processInstance = [SELECT ProcessDefinitionId FROM ProcessInstance WHERE TargetObjectId = :newAssign.Id];
            ProcessDefinition processDefinition = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'IMT_Approve_Assignment_Created_Regional'];
            system.assertEquals(processInstance.ProcessDefinitionId, processDefinition.Id);
        }
    }
    
//    //TEST APPROVAL PROCESS WHEN ASSIGNMENT IS CREATED BY IMPLEMENTATION LEAD
//    public static testmethod void checkCreateAssignmentByImplementationLead() {
//        NI_IMT_TestDataFactory.createCustomSettings();
//        NI_IMT_TestDataFactory.createChatterGroups();
//        NI_IMT_TestDataFactory.createSchedulingSetConfig();    
//        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();        
//        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
//        Contact contact2 = contacts[0];
//        contact2.pse__Is_Resource__c = true;
//        contact2.pse__Is_Resource_Active__c = true;
//        insert contact2;        
//        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
//        Id roleId = NULL;
//        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Implementation Leads', 1, roleId);
//        User newUser = imtUsers[0];
//        insert newUser;                
//        system.runAs(newUser) {        
//            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
//            NI_IMT_Property__c testProp1 = props[0];
//            insert testProp1;
//            testProp1.Timezone__c = 'IST ( GMT 5.50 )';
//            update testProp1;            
//            Contact contact1 = contacts[1];
//            contact1.pse__Is_Resource__c = true;
//            contact1.pse__Is_Resource_Active__c = true;
//            insert contact1;            
//            Id migrationOpId = NI_IMT_TestDataFactory.createMigrationOperator();            
//            NI_IMT_TestDataFactory.createPermissionControl(newUser.Id, migrationOpId, regionId);            
//            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(2, regionId, testProp1.Id, contact1.Id);
//            pse__Proj__c testProj1 = projects[0];
//            insert testProj1;
//            pse__Proj__c testProj2 = projects[1];
//            insert testProj2;            
//            List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
//            IMT_Migration_Set__c set1 = schedulingSets[0];
//            set1.RecordTypeId = imtSchdlSetRecordTypeId;
//            insert set1;        
//            //TEST CREATE ASSIGNMENT
//            ApexPages.currentPage().getParameters().put('Ids',+testProj1.Id+':'+testProj2.Id+'|');
//            ApexPages.currentPage().getParameters().put('migrationSetID',set1.Id);
//            NI_IMT_CreateScheduleController cntrlObj = new NI_IMT_CreateScheduleController();
//            cntrlObj.init();
//            PageReference ref = cntrlObj.createAssignment();
//            pse__Assignment__c newAssign = [SELECT pse__Status__c FROM  pse__Assignment__c WHERE pse__Project__c = :testProj1.Id];
//            system.assertEquals('Tentative', newAssign.pse__Status__c);
//            ProcessInstance processInstance = [SELECT ProcessDefinitionId FROM ProcessInstance WHERE TargetObjectId = :newAssign.Id];
//            ProcessDefinition processDefinition = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'IMT_Approve_Assignment_Created_By_Lead'];
//            system.assertEquals(processInstance.ProcessDefinitionId, processDefinition.Id);
//        }
//    }
    
    //TEST APPROVAL PROCESS WHEN ASSIGNMENT CREATION TRIGGERS TIME ZONE DIFFERENCE
    public static testmethod void checkCreateAssignmentTriggerTimezoneDifference() {
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();    
        NI_IMT_TestDataFactory.createSchedulingSetConfig();    
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
        
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User newUser = imtUsers[0];
        insert newUser;
                
        system.runAs(newUser) {
        
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(2);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
            testProp1.Timezone__c = 'IST ( GMT 5.50 )';
            update testProp1;
            
            NI_IMT_Property__c testProp2 = props[1];
            insert testProp2;
            testProp2.Timezone__c = 'CEST ( GMT 2.00 )';
            update testProp2;
            
            Contact contact1 = contacts[1];
            contact1.pse__Is_Resource__c = true;
            contact1.pse__Is_Resource_Active__c = true;
            insert contact1;
            
            Id migrationOpId = NI_IMT_TestDataFactory.createMigrationOperator();
            
            NI_IMT_TestDataFactory.createPermissionControl(newUser.Id, migrationOpId, regionId);
            
            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
            pse__Proj__c testProj1 = projects[0];
            insert testProj1;
            List<pse__Proj__c> projects2 = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp2.Id, contact1.Id);
            pse__Proj__c testProj2 = projects2[0];
            insert testProj2;
            
            List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
            IMT_Migration_Set__c set1 = schedulingSets[0];
            set1.RecordTypeId = imtSchdlSetRecordTypeId;
            insert set1;
        
            //TEST CREATE ASSIGNMENT
            ApexPages.currentPage().getParameters().put('Ids',+testProj1.Id+':'+testProj2.Id+'|');
            ApexPages.currentPage().getParameters().put('migrationSetID',set1.Id);
            NI_IMT_CreateScheduleController cntrlObj = new NI_IMT_CreateScheduleController();
            cntrlObj.init();
            PageReference ref = cntrlObj.createAssignment();
            pse__Assignment__c newAssign = [SELECT pse__Status__c FROM  pse__Assignment__c WHERE pse__Project__c = :testProj1.Id];
            system.assertEquals('Tentative', newAssign.pse__Status__c);
            ProcessInstance processInstance = [SELECT ProcessDefinitionId FROM ProcessInstance WHERE TargetObjectId = :newAssign.Id];
            ProcessDefinition processDefinition = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'IMT_Approve_Assignment_Time_Difference'];
            system.assertEquals(processInstance.ProcessDefinitionId, processDefinition.Id);
        }
    }
  
    //TEST CANCELLATION  REASON IS REQUIRED WHEN ASSIGNMENT CANCELLED OR FALLBACK
    public static testmethod void checkAssignmentCancelationReasonValidation() {
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();    
        NI_IMT_TestDataFactory.createSchedulingSetConfig();    
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
        
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
                
        system.runAs(globalSuperUser) {
        
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
            
            Contact contact1 = contacts[1];
            contact1.pse__Is_Resource__c = true;
            contact1.pse__Is_Resource_Active__c = true;
            insert contact1;
            
            NI_IMT_TestDataFactory.createPermissionControl(globalSuperUser.Id, contact1.Id, regionId);
            
            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
            pse__Proj__c testProj1 = projects[0];
            insert testProj1;
            
            List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
            IMT_Migration_Set__c set1 = schedulingSets[0];
            set1.RecordTypeId = imtSchdlSetRecordTypeId;
            insert set1;
        
            List<pse__Schedule__c> schduleList = NI_IMT_TestDataFactory.createSchedule(1);
            pse__Schedule__c schedule1 = schduleList[0];
            insert schedule1;
        
            List<pse__Assignment__c> assignments = NI_IMT_TestDataFactory.createAssignments(1,schedule1.Id,testProj1.Id,contact1.Id,set1.Id);
            pse__Assignment__c assignment1 = assignments[0];
            insert assignment1;
            assignment1.pse__Status__c = 'Canceled';
            try {
                update assignment1;
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains('When removing an assignment from the schedule, a reason is required'));    
            }
            
            assignment1.pse__Status__c = 'Fallback';
            try {
                update assignment1;
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains('When removing an assignment from the schedule, a reason is required'));    
            }
        }
    }
    
    //TEST SCHEDULED COUNT AND COMPLEXITY MIX ARE UPDATED WHEN ASSIGNMENTS ARE CREATED AND CANCELED
    public static testmethod void checkAssignmentScheduleCountAndComplexityMix() {
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();    
        NI_IMT_TestDataFactory.createSchedulingSetConfig();    
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
        
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
                
        system.runAs(globalSuperUser) {
        
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
            
            Contact contact1 = contacts[1];
            contact1.pse__Is_Resource__c = true;
            contact1.pse__Is_Resource_Active__c = true;
            contact1.pse__Salesforce_User__c = globalSuperUser.Id;
            insert contact1;
            
            NI_IMT_TestDataFactory.createPermissionControl(globalSuperUser.Id, contact1.Id, regionId);
            
            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
            pse__Proj__c testProj1 = projects[0];
            testProj1.IMT_Complexity_Value__c = 1;
            testProj1.Operational_Profile__c = 'A';
            insert testProj1;
            
            List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
            IMT_Migration_Set__c set1 = schedulingSets[0];
            set1.RecordTypeId = imtSchdlSetRecordTypeId;
            insert set1;
        
            List<pse__Schedule__c> schduleList = NI_IMT_TestDataFactory.createSchedule(1);
            pse__Schedule__c schedule1 = schduleList[0];
            insert schedule1;
        
            List<pse__Assignment__c> assignments = NI_IMT_TestDataFactory.createAssignments(1,schedule1.Id,testProj1.Id,contact1.Id,set1.Id);
            pse__Assignment__c assignment1 = assignments[0];
            insert assignment1;
            
            IMT_Migration_Set__c schdlSet = [SELECT Scheduled_Complexity_1__c,Total_Scheduled__c,Scheduled_Complexity_Mix__c FROM IMT_Migration_Set__c WHERE Id =:set1.Id];
            system.assertEquals(1, schdlSet.Scheduled_Complexity_1__c);
            system.assertEquals(1, schdlSet.Total_Scheduled__c);
            system.assertEquals(1, schdlSet.Scheduled_Complexity_Mix__c);
            
            assignment1.pse__Status__c = 'Canceled';
            assignment1.Cancellation_Reason__c = 'Not in Good Standing';
            update assignment1;
            
            IMT_Migration_Set__c schdlSet1 = [SELECT Scheduled_Complexity_1__c,Total_Scheduled__c,Scheduled_Complexity_Mix__c FROM IMT_Migration_Set__c WHERE Id =:set1.Id];
            system.assertEquals(0, schdlSet1.Scheduled_Complexity_1__c);
            system.assertEquals(0, schdlSet1.Total_Scheduled__c);
            system.assertEquals(0, schdlSet1.Scheduled_Complexity_Mix__c);
            
        }
    }
    
    //TEST ONLY ONE ASSIGNMENT IS ACTIVE FOR A PROJECT
    public static testmethod void checkOnlyOneAssignmentActiveForProject() {
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();    
        NI_IMT_TestDataFactory.createSchedulingSetConfig();    
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
        
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
                
        system.runAs(globalSuperUser) {
        
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
            
            Contact contact1 = contacts[1];
            contact1.pse__Is_Resource__c = true;
            contact1.pse__Is_Resource_Active__c = true;
            contact1.pse__Salesforce_User__c = globalSuperUser.Id;
            insert contact1;
            
            NI_IMT_TestDataFactory.createPermissionControl(globalSuperUser.Id, contact1.Id, regionId);
            
            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
            pse__Proj__c testProj1 = projects[0];
            insert testProj1;
            
            List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(1);
            IMT_Migration_Set__c set1 = schedulingSets[0];
            set1.RecordTypeId = imtSchdlSetRecordTypeId;
            insert set1;
        
            List<pse__Schedule__c> schduleList = NI_IMT_TestDataFactory.createSchedule(1);
            pse__Schedule__c schedule1 = schduleList[0];
            insert schedule1;
        
            List<pse__Assignment__c> assignments = NI_IMT_TestDataFactory.createAssignments(1,schedule1.Id,testProj1.Id,contact1.Id,set1.Id);
            pse__Assignment__c assignment1 = assignments[0];
            insert assignment1;
            
            ApexPages.currentPage().getParameters().put('Ids',+testProj1.Id+':');
            ApexPages.currentPage().getParameters().put('migrationSetID',set1.Id);
            NI_IMT_CreateScheduleController cntrlObj = new NI_IMT_CreateScheduleController();
            cntrlObj.init();
            try {
                PageReference ref = cntrlObj.createAssignment();
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains('An assignment cannot be added to a project that already has an active date'));    
            }
        }
    }
        
    //TEST PROJECT TASK START DATE CANNOT BE AFTER END DATE
    public static testmethod void checkProjectTaskStartDateCannotBeAfterEndDate() {
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
        Contact contact1 = contacts[0];
        insert contact1;
        
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();
        
        List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
        pse__Proj__c testProj1 = projects[0];
        insert testProj1;
        
        List<pse__Project_Task__c> projTasks =  NI_IMT_TestDataFactory.createProjectTask(2, testProj1.Id);     
         
         Date dToday = Date.Today();
        Datetime startDate = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
        Date dToday1 = Date.Today() + 2;
        Datetime endDate = datetime.newInstance(dToday1.year(), dToday1.month(),dToday1.day());
         
         pse__Project_Task__c projTask = projTasks[0];
         projTask.pse__Start_Date_Time__c = startDate;
         projTask.pse__End_Date_Time__c = endDate;
         insert projTask;
         system.assert(projTask.Id != NULL);
         
        Date dToday2 = Date.Today() - 2;
        Datetime endDate1 = datetime.newInstance(dToday2.year(), dToday2.month(),dToday2.day());
         pse__Project_Task__c projTask2 = projTasks[1];
         projTask2.pse__Start_Date_Time__c = startDate;
         projTask2.pse__End_Date_Time__c = endDate1;
         try {
            insert projTask2;
        }
        catch(Exception e) {
            system.assert(e.getMessage().contains('Start date &amp; time must be before the end date &amp; time'));    
        }
    }
    
    //TEST PROJECT TASK START CANNOT BE COMPLETED IF NOT STARTED
    public static testmethod void checkProjectTaskCannotBeCompletdIfNotStarted() {
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
        Contact contact1 = contacts[0];
        insert contact1;
        
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();
        
        List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
        pse__Proj__c testProj1 = projects[0];
        insert testProj1;
        
        List<pse__Project_Task__c> projTasks =  NI_IMT_TestDataFactory.createProjectTask(1, testProj1.Id);     
         pse__Project_Task__c projTask = projTasks[0];
         insert projTask;
         system.assert(projTask.Id != NULL);
         
         projTask.pse__Started__c  = false;
         projTask.pse__Completed__c  = true;
         try {
            update projTask;
        }
        catch(Exception e) {
            system.assert(e.getMessage().contains('Can not mark as completed if not started'));    
        }
    }
    
    //TEST KNOWLEDGE APPROVAL 
    public static testmethod void checkKnowledgeApprovedOrRetiredOnlyByGlobalTraining() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
                    
        system.runAs(globalSuperUser) {
            List<NI_IMT_Knowledge__c> knowledgeList = NI_IMT_TestDataFactory.createKnowledgeArticles(1);
            NI_IMT_Knowledge__c knowledge1 = knowledgeList[0];
            knowledge1.Status__c = 'Approved';
            try {
                insert knowledge1;
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains('Please contact the Knowledge team when using this value'));    
            }
            knowledge1.Status__c = 'Retired';
            try {
                insert knowledge1;
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains('Please contact the Knowledge team when using this value'));    
            }
        }
        List<User> imtUsers1 = NI_IMT_TestDataFactory.createUsers('NI IMT Global Training (Knowledge)', 1, roleId);
        User globalTrainingUser = imtUsers1[0];
        globalTrainingUser.UserName='nntstuser@niimttest.com';
        insert globalTrainingUser;
        system.runAs(globalTrainingUser) {
            List<NI_IMT_Knowledge__c> knowledgeList = NI_IMT_TestDataFactory.createKnowledgeArticles(2);
            NI_IMT_Knowledge__c knowledge1 = knowledgeList[0];
            knowledge1.Status__c = 'Approved';
            insert knowledge1;
            system.assert(knowledge1.Id != NULL);
            
            NI_IMT_Knowledge__c knowledge2 = knowledgeList[1];
            knowledge2.Status__c = 'Retired';
            insert knowledge2;
            system.assert(knowledge2.Id != NULL);
        }
    }
    
    //TEST KNOWLEDGE APPROVAL 
    public static testmethod void checkKnowledgeApproval() {
        //Check Draft status
        List<NI_IMT_Knowledge__c> knowledgeList = NI_IMT_TestDataFactory.createKnowledgeArticles(2);
        NI_IMT_Knowledge__c knowledge1 = knowledgeList[0];
        insert knowledge1;
        system.assert(knowledge1.Id != NULL);
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(knowledge1.Id);
        req1.setSubmitterId(knowledge1.OwnerId);
        req1.setProcessDefinitionNameOrId('IMT_Knowledge');
        Approval.ProcessResult result = Approval.process(req1);
        ProcessInstance processInstance = [SELECT ProcessDefinitionId FROM ProcessInstance WHERE TargetObjectId = :knowledge1.Id];
        ProcessDefinition processDefinition = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'IMT_Knowledge'];
        system.assertEquals(processInstance.ProcessDefinitionId, processDefinition.Id);
        
        //Check Rejected status
        NI_IMT_Knowledge__c knowledge2 = knowledgeList[1];
        knowledge2.Status__c = 'Rejected';
        insert knowledge2;
        system.assert(knowledge2.Id != NULL);
        
        Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
        req2.setComments('Submitting request for approval.');
        req2.setObjectId(knowledge2.Id);
        req2.setSubmitterId(knowledge2.OwnerId);
        req2.setProcessDefinitionNameOrId('IMT_Knowledge');
        Approval.ProcessResult result2 = Approval.process(req2);
        ProcessInstance processInstance2 = [SELECT ProcessDefinitionId FROM ProcessInstance WHERE TargetObjectId = :knowledge2.Id];
        ProcessDefinition processDefinition2 = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'IMT_Knowledge'];
        system.assertEquals(processInstance2.ProcessDefinitionId, processDefinition2.Id);
    }
    
    //TEST TASK CANNOT BE DELETED IF CREATED BY OTHERS
    public static testmethod void checkProjectTaskDeletionOthersTask() {
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        Id imtId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group Task').getRecordTypeId();
        Task task1 = new Task();
        task1.Type = 'Email';
        task1.Description = 'Test';
        task1.OwnerId = UserInfo.getUserId();
        task1.WhatId = testProp1.Id; 
        task1.RecordTypeId = imtId;
        insert task1;
         
         Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
                
        system.runAs(globalSuperUser) {
            try {
                delete task1;
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY'));    
            }
        }
    }
    
    //TEST TASK CAN BE DELETED IF CREATED BY SAME USER
    public static testmethod void checkProjectTaskDeletionMyTask() {
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Global Super User', 1, roleId);
        User globalSuperUser = imtUsers[0];
        insert globalSuperUser;
                    
        system.runAs(globalSuperUser) {
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
        
            Id imtId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group Task').getRecordTypeId();
            Task task1 = new Task();
            task1.Type = 'Email';
            task1.Description = 'Test'; 
            task1.OwnerId = UserInfo.getUserId(); 
            task1.WhatId = testProp1.Id; 
            task1.RecordTypeId = imtId;
            insert task1;
            delete task1;
            List<Task> tasks = [SELECT Type FROM Task WHERE Id = :task1.Id];
            system.assertEquals(0, tasks.size());
        }
    }
    
    //TEST PROJECT TASK START DATE IS NOT BEFORE PROJECT START DATE
    public static testmethod void checkProjectTaskStartDateNotBeforeProjectStart() {
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
        Contact contact1 = contacts[0];
        insert contact1;
        
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();
        
        List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
        pse__Proj__c testProj1 = projects[0];
        insert testProj1;
        system.assert(testProj1.Id != NULL);
        Id recordTypeId = Schema.getGlobalDescribe().get('pse__Project_Task__c').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
        List<pse__Project_Task__c> projTasks =  NI_IMT_TestDataFactory.createProjectTask(1, testProj1.Id);     
         pse__Project_Task__c projTask = projTasks[0];
         projTask.RecordTypeId = recordTypeId;
         Date dToday = testProj1.pse__Start_Date__c - 1;
        Datetime startDate = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
         projTask.pse__Start_Date_Time__c = startDate;
         try {
            insert projTask;
        }
        catch(Exception e) {
            system.assert(e.getMessage().contains('Start date cannot be before project start date'));    
        }
    }
    
    //TEST PROJECT TASK START DATE IS NOT BEFORE PROJECT START DATE
    public static testmethod void checkProjectTaskEndDateNotBeforeProjectEnd() {
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
        Contact contact1 = contacts[0];
        insert contact1;
        
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();
        
        List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
        pse__Proj__c testProj1 = projects[0];
        insert testProj1;
        system.assert(testProj1.Id != NULL);
        Id recordTypeId = Schema.getGlobalDescribe().get('pse__Project_Task__c').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
        List<pse__Project_Task__c> projTasks =  NI_IMT_TestDataFactory.createProjectTask(1, testProj1.Id);     
         pse__Project_Task__c projTask = projTasks[0];
         projTask.RecordTypeId = recordTypeId;
         Date dToday = testProj1.pse__End_Date__c + 1;
        Datetime endDate = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
         projTask.pse__End_Date_Time__c  = endDate;
         try {
            insert projTask;
        }
        catch(Exception e) {
            system.assert(e.getMessage().contains('End date cannot be after project end date'));    
        }
    }
    
    //TEST PROJECT END DATE IS SET WHEN PROJECT TASK COMPLETES
    public static testmethod void checkProjectEndDateWhenTaskComplete() {
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
        Contact contact1 = contacts[0];
        insert contact1;
        
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();
        
        List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
        pse__Proj__c testProj1 = projects[0];
        testProj1.pse__Tasks_Total_Points__c = 40;
        testProj1.pse__Tasks_Total_Points_Complete__c = 0;
        insert testProj1;
        system.assert(testProj1.Id != NULL);
        
        testProj1.pse__Tasks_Total_Points_Complete__c = 40;
         update testProj1;
         pse__Proj__c updatedProj = [SELECT pse__End_Date__c FROM pse__Proj__c WHERE Id =:testProj1.Id];
         system.assertEquals(system.today(), updatedProj.pse__End_Date__c);
    }
    
    //TEST IMPLEMENTATION LEAD CANNOT MODIFY END DATE
    public static testmethod void checkProjectTaskEndDateCannotBeChanged() {
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();
        NI_IMT_TestDataFactory.createSchedulingSetConfig();    
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(2);
        Contact contact2 = contacts[0];
        contact2.pse__Is_Resource__c = true;
        contact2.pse__Is_Resource_Active__c = true;
        insert contact2;
        
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        Id roleId = NULL;
        List<User> imtUsers = NI_IMT_TestDataFactory.createUsers('NI IMT Implementation Leads', 1, roleId);
        User newUser = imtUsers[0];
        insert newUser;
                
        system.runAs(newUser) {
        
            List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
            NI_IMT_Property__c testProp1 = props[0];
            insert testProp1;
            
            Contact contact1 = contacts[1];
            contact1.pse__Is_Resource__c = true;
            contact1.pse__Is_Resource_Active__c = true;
            insert contact1;
                        
            List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(2, regionId, testProp1.Id, contact1.Id);
            pse__Proj__c testProj1 = projects[0];
            insert testProj1;
            
            Id recordTypeId = Schema.getGlobalDescribe().get('pse__Project_Task__c').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
            List<pse__Project_Task__c> projTasks =  NI_IMT_TestDataFactory.createProjectTask(1, testProj1.Id);     
             pse__Project_Task__c projTask = projTasks[0];
             projTask.RecordTypeId = recordTypeId;
             insert projTask;
            Date dToday = testProj1.pse__End_Date__c - 1;
            Datetime endDate = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
             projTask.pse__End_Date_Time__c  = endDate;
            try {
                update projTask;
            }
            catch(Exception e) {
                system.assert(e.getMessage().contains('Implementation lead cannot modify end date'));    
            }
        }
    }
    
    //TEST PROJECT START DATE IS UPDATED WHEN FIRST PROJECT TASK CREATED
    public static testmethod void checkProjectStartDateWhenFirstTaskCreated() {
        Id regionId = NI_IMT_TestDataFactory.getRegionId('Asia Middle East Africa');
        
        List<NI_IMT_Property__c> props = NI_IMT_TestDataFactory.createProperties(1);
        NI_IMT_Property__c testProp1 = props[0];
        insert testProp1;
        
        List<Contact> contacts = NI_IMT_TestDataFactory.createContacts(1);
        Contact contact1 = contacts[0];
        insert contact1;
        
        NI_IMT_TestDataFactory.createCustomSettings();
        NI_IMT_TestDataFactory.createChatterGroups();
                
        List<pse__Proj__c> projects = NI_IMT_TestDataFactory.createProjects(1, regionId, testProp1.Id, contact1.Id);
        pse__Proj__c testProj1 = projects[0];
        testProj1.pse__Start_Date__c = Date.today() - 2;
        insert testProj1;
        system.assert(testProj1.Id != NULL);
        
        Id recordTypeId = Schema.getGlobalDescribe().get('pse__Project_Task__c').getDescribe().getRecordTypeInfosByName().get('IMT - IHG GRS Project').getRecordTypeId();
        List<pse__Project_Task__c> projTasks =  NI_IMT_TestDataFactory.createProjectTask(1, testProj1.Id);     
         pse__Project_Task__c projTask = projTasks[0];
         projTask.RecordTypeId = recordTypeId;
         insert projTask;
         
         pse__Proj__c updatedProj = [SELECT pse__Start_Date__c FROM pse__Proj__c WHERE Id =:testProj1.Id];
         system.assertEquals(system.today(), updatedProj.pse__Start_Date__c);
    }
    
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIHISPartnerPermission() {
        List<User> nonImtUsers = NI_IMT_TestDataFactory.createUsers('NI Customer Community Plus User', 1, NULL);
        User nonImtUser = nonImtUsers[0];
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNISalesPartnerPermission() {
        List<User> nonImtUsers = NI_IMT_TestDataFactory.createUsers('NI Customer Community Plus User', 1, NULL);
        User nonImtUser = nonImtUsers[0];
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIAdministratorPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Administrator');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
        
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIChangeControlPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Change Control Force.com - One App User');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIChatterExternalPostFilePermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Chatter External Post File');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIChatterFreePermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Chatter Free User');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIClientServicesPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Client Services');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIContractsPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Contracts');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
        
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNICustomerCommunityPlusPermission() {
        List<User> nonImtUsers = NI_IMT_TestDataFactory.createUsers('NI Customer Community Plus User', 1, NULL);
        User nonImtUser = nonImtUsers[0];
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIDCInfrastructurePermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI DC Infrastructure');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIDCOperationsPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI DC Operations');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIDevelopmentPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Development');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIEPMPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI EPM');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIExecutiveManagementPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Executive Management');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIExecutiveManagementLODPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Executive Management LOD');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIFinancePermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Finance');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIFinancePlatformPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Finance - Platform');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
        
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIFinance2016Permission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Finance 2016');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIFinancialForceAccountantPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI FinancialForce Accountant');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIInsideSalesPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Inside Sales');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIITPlatformPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI IT - Platform');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIITStandardPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI IT - Standard');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIMarketingPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Marketing');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIPartnerCommunityUserPermission() {
        List<User> nonImtUsers = NI_IMT_TestDataFactory.createUsers('NI Customer Community Plus User', 1, NULL);
        User nonImtUser = nonImtUsers[0];
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIPartnerPortalEnterpriseSalesTeamPermission() {
        List<User> nonImtUsers = NI_IMT_TestDataFactory.createUsers('NI Customer Community Plus User', 1, NULL);
        User nonImtUser = nonImtUsers[0];
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIPlatformUserPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Platform User');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIPlatformUserLimitedPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Platform User - Limited');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIPreSalesPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI PreSales');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIProductManagementPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Product Management');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIPSAManagementPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI PSA Management');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIPSAProjectManagementPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI PSA Project Management');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIPSAProjectManagementPlatformPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI PSA Project Management - Platform');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIPSAProjectOfficePermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI PSA Project Office');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIPSATEPlatformPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI PSA T&E - Platform');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIPSATESalesforcePermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI PSA T&E - Salesforce');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIReportUserPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Report User');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNISalesPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Sales');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNISalesManagementPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Sales Management');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIStandardUserPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Standard User');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNISubscriptionManagementPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Subscription Management');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNISupportCSRPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Support CSR');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNISupportManagersPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Support Managers');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
    
    //TEST NON IMT USER ACCESS TO IMT
    public static testmethod void checkNIWebServicesAdminPermission() {
        User nonImtUser = NI_IMT_TestDataFactory.createNonImtUser('NI Web Services Admin');
        insert nonImtUser;
        system.runAs(nonImtUser) {
            Schema.DescribeSObjectResult propertyObj = NI_IMT_Property__c.sObjectType.getDescribe();
            system.assert(!propertyObj.isAccessible());
            
            Schema.DescribeSObjectResult imtContactObj = NI_IMT_Contact__c.sObjectType.getDescribe();
            system.assert(!imtContactObj.isAccessible());
            
            Schema.DescribeSObjectResult schedulingSetObj = IMT_Migration_Set__c.sObjectType.getDescribe();
            system.assert(!schedulingSetObj.isAccessible());
            
            Schema.DescribeSObjectResult knowledgeObj = NI_IMT_Knowledge__c.sObjectType.getDescribe();
            system.assert(!knowledgeObj.isAccessible());
            
            List<RecordTypeInfo> infos = pse__proj__C.SObjectType.getDescribe().getRecordTypeInfos();
            boolean hasAcccess = false;
            if (infos.size() > 1) {
                for (RecordTypeInfo i : infos) {
                   if (i.isAvailable() && (i.getName() == 'IMT - IHG GRS Project')) {
                        hasAcccess = true;
                   }
                }
            } 
            system.assert(!hasAcccess);
        }
    }
*/    
}