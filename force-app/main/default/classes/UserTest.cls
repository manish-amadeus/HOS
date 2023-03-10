/************************************************************************************************
Name            : UserTest Class
Author          : Mike Pedro 
Created Date    : 05/18/2022
Last Mod Date   : 05/18/2022
Last Mod By     : Mike Pedro
NICC Reference  : NICC-058970 
Description     : 
                : 
*************************************************************************************************/

/**
 * This test class should be used as a central place for creating all
 * personas user records, and assigning those user records to any
 * permission sets utilized by the application.
 * <p>
 * This class should be modified to include methods for each persona.
 */
@isTest
public class UserTest {
    private static Integer userNumber = 0;

    public static User createStandardUser() {
        return createUserWithProfile('Standard User');
    }

    public static User createPlatformUser() {
        return createUserWithProfile('Standard Platform User');
    }

    public static User createUserWithProfile(string profileName) {
        Integer userNum = userNumber++;
        String email = 'unit.test.user+' + userNum + '@' + UserInfo.getOrganizationId() + '.test.com';
        User u = NI_TestClassData.createTestUser(1, profileName);
        if (Userinfo.isMultiCurrencyOrganization()) {
            ((SObject) u).put('CurrencyIsoCode', 'USD');
        }
        insert u;

        return u;
    }

    /**
     * Example showing how to create a user with a default assignment of some permission
     * sets.
     */
    public static User createUserWithPerms() {
        return createUser(new List<String>{ 'permission_set_name_1', 'permission_set_name_2' });
    }

    private static User createUser(List<String> permissionSets) {
        User u = createStandardUser();

        // add user to perm sets
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id, Name FROM PermissionSet WHERE Name IN :permissionSets]) {
            psas.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id));
        }
        insert psas;

        return u;
    }
}