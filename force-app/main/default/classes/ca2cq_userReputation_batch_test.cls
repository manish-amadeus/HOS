@isTest
private class ca2cq_userReputation_batch_test {

    static String TOTAL_QUESTIONS			= 'total_questions';
    static String TOTAL_REPLIES_MADE 		= 'total_replies_made';
    static String TOTAL_REPLIES_RECEIVED	= 'total_replies_received';
    static String TOTAL_LIKES_MADE 			= 'total_likes_made';
    static String TOTAL_LIKES_RECEIVED 		= 'total_likes_received';
    static String TOTAL_BA_AUTHOR 			= 'total_bestA_author';
    static String TOTAL_BA_SELECTOR 		= 'total_bestA_selector';

    static List<Network> nw;
    static List<Community> allComs;
    static List<NetworkMember> nm;
    static Map<Id, Map<Id, Map<String, Integer>>> testPointsToMigrate;
    static Map<Id, Map<String, Integer>> repRules;

    public static void populateData(){
        // create configs
        ca2cq_config__c obj = ca2cq_util.getAppSettings();
        obj.Notification_email__c = 'SOMe@test.org';
        upsert obj;

        //Get rep rules to get Id of a network
        Map<Id, Network> reputationEnabled = new Map<Id, Network>([SELECT OptionsReputationEnabled FROM Network WHERE OptionsReputationEnabled = TRUE AND STATUS = 'Live' LIMIT 50]);

        Map<Id, Map<String, Integer>> thisRepRules = new Map<Id, Map<String, Integer>>();

        for (Id comKey : reputationEnabled.keySet()) {
        	Network auxNw = reputationEnabled.get(comKey);

            Map<String, Integer> typeToPoints = new Map<String, Integer>();
            List<ReputationPointsRule> communityReputation = [SELECT Type, Points FROM ReputationPointsRule WHERE ParentId =: comKey];
            for (ReputationPointsRule rpR : communityReputation){
                typeToPoints.put(rpR.Type, rpR.Points);
            }

            thisRepRules.put(comKey, typeToPoints);
        }

        // Save the static variable
        repRules = thisRepRules;

        Set <Id> allNetIdsSet = thisRepRules.keySet();
        List<Id> allNetIdsList = new List<Id>(allNetIdsSet);

        // Set member
        nm = [SELECT Id, MemberId, NetworkId, ReputationPoints FROM NetworkMember WHERE NetworkId IN : allNetIdsList LIMIT 1];

        Map<Id, Map<String, Integer>> userPointsList = new Map<Id, Map<String, Integer>>();
        // Get member
        if (nm.size() > 0) {
            System.debug('There is at least one network with reputation enabled.');
            NetworkMember member = nm.get(0);

            // Populate stats
            Map<String,Integer> user1 = new Map<String,Integer>{TOTAL_QUESTIONS => 5,
                TOTAL_REPLIES_MADE => 5,
                TOTAL_REPLIES_RECEIVED => 5,
                TOTAL_LIKES_MADE => 5,
                TOTAL_LIKES_RECEIVED => 5,
                TOTAL_BA_AUTHOR => 5,
                TOTAL_BA_SELECTOR => 5};

            userPointsList.put(member.MemberId, user1);

            Map<Id, Map<Id, Map<String, Integer>>> pointsToMigrate = new Map<Id, Map<Id, Map<String, Integer>>>();

            pointsToMigrate.put(member.NetworkId, userPointsList);

            testPointsToMigrate = pointsToMigrate;
        } else {
            System.debug('No communities with reputation enabled.');
        }
    }

    @isTest(SeeAllData = true)
    static void testMigration() {
        //Initialize data
        populateData();

        if (nm != null && nm.size() > 0) {
            System.debug('Starting migration.');
            // Given - there is a networkMember on the org.
            System.Test.startTest();

            // Get member
            NetworkMember member = nm.get(0);

            // Get a random community
            List<Community> migComs = [SELECT Id FROM Community LIMIT 1];

            // Set commmunity as ready to be migrated\
            ca2cq_Zone_community__c z2c = new ca2cq_Zone_community__c(Active_for_Migration__c = TRUE,
                                                                      Community_Id__c = member.NetworkId,
                                                                      Name = 'test',
                                                                     zoneId__c = migComs.get(0).Id);
            upsert z2c;

            Id batchInstanceId = Database.executeBatch(new ca2cq_userReputation_batch(testPointsToMigrate));
            System.Test.stopTest();

            NetworkMember updatedNm = [SELECT Id, MemberId, NetworkId, ReputationPoints
                                       FROM NetworkMember
                                       WHERE Id =: member.Id];

            System.assertNotEquals(member.ReputationPoints, updatedNm.ReputationPoints);
        } else {
            System.debug('There are no live communities with reputation available. Please, enable reputation levels on any network and make sure it is published.');
        }
    }
}