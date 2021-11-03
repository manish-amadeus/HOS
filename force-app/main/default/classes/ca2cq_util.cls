/**
 * @author Altimetrik
 * @description
 *    started on 10/08/2014
 *    utility methods
 * a test
 **/
public without sharing class ca2cq_util {
    // Constants

    public static String CONFIG_NAME = 'default';
	public static Integer BATCH_SIZE = 200;

    /*
	  params : none
	  return ca2cq_config__c
		Returns the custom setting
	*/
    public static ca2cq_config__c  getAppSettings(){

        ca2cq_config__c res = ca2cq_config__c.getInstance(CONFIG_NAME);

        if (res == null){
            res = new ca2cq_config__c();
            res.Name = CONFIG_NAME;
			res.Current_Executing_Level__c = 0;
			res.Batch_size__c = BATCH_SIZE;
        }

        return res;

    }

    /*
	  params : none
	  return String list
		Returns the communities selected for migration
	*/
    public static List<String> getCommunitiesToMigrate(){
        list<String> result = new list<String>();
        list<ca2cq_Zone_community__c> mapps = ca2cq_Zone_community__c.getAll().values();

        // Create map with existing ZoneIds and setup object
        for(ca2cq_Zone_community__c ca : mapps){
            if (ca.Active_for_Migration__c)
            {
                List<Community> comm = [SELECT Id, IsActive FROM Community WHERE Id =: ca.zoneId__c];

                if(comm[0].IsActive){
                    result.add(ca.zoneId__c);
                }
            }
        }
        return result;
    }

    /*
	  params : none
	  return Map of Communities with its Point Rules
		Get community reputation point rule if reputation is enabled.
	*/
    public static Map<Id, Map<String, Integer>> getCommunitiesPointRules(){
        Set<Id> auxSet = new Set<Id>();
        List<Id> auxList = new List<Id>();
        List<Id> communities = new List<Id>();

        //Get all communities that will receive the migrated questions
        List<ca2cq_Zone_community__c> allCommunities = ca2cq_Zone_community__c.getAll().values();

        Map<Id, Map<String, Integer>> result = new Map<Id, Map<String, Integer>>();

        for (ca2cq_Zone_community__c so : allCommunities){
            if (so.Active_for_Migration__c == True){
                if (!so.Community_Id__c.equals('null')){
                    auxList.add(so.Community_Id__c);
                }
            }
        }

        // If there are communities with reputation enabled
        if(auxList.size() > 0) {
            // Add results to a set to remove duplicates
            auxSet.addAll(auxList);
            // Add them back to a List
            communities.addAll(auxSet);

            // Get map of communities' OptionsReputationEnabled field
            Map<Id, Network> reputationEnabled = new Map<Id, Network>([SELECT OptionsReputationEnabled FROM Network WHERE Status ='Live']);

            for (Id comId : communities){
                Network nw = reputationEnabled.get(comId);

                if (nw != null && nw.OptionsReputationEnabled == True){
                    Map<String, Integer> typeToPoints = new Map<String, Integer>();
                    List<ReputationPointsRule> communityReputation = [SELECT Type, Points FROM ReputationPointsRule WHERE ParentId =: comId];
                    for (ReputationPointsRule rpR : communityReputation){
                        typeToPoints.put(rpR.Type, rpR.Points);
                    }

                    result.put(comId, typeToPoints);
                }
            }
        }
        return result;
    }

    /*
	  params : none
	  return Set of String with users in a community
		Get community users where reputation is enabled.
	*/
    public static Set<String> getUsersPerCommunity(){
        // Get communities with reputation enabled
        List<Network> repEnabled =  new List<Network>([SELECT Id FROM Network WHERE OptionsReputationEnabled = TRUE AND  Status ='Live']);

         Set<String> currentMembers = new Set<String>();

        for(NetworkMember nm : [SELECT Id, MemberId, NetworkId, ReputationPoints FROM NetworkMember WHERE NetworkId IN :repEnabled]){
            currentMembers.add(nm.NetworkId+'-'+nm.MemberId);
        }

        return currentMembers;
    }

    /*
	  params : none
	  return Map of communities, with user and their points
		Get community reputation point rule if reputation is enabled.
	*/
    public static Map<Id, Map<Id, Double>> getUserPointsPerCommunity() {
        // Map<CommunityId, Map<UserId, Points>>
        Map<Id, Map<Id, Double>> result = new Map<Id, Map<Id, Double>>();
        // Get communities with reputation enabled
        List<Network> repEnabled =  new List<Network>([SELECT Id FROM Network WHERE OptionsReputationEnabled = TRUE AND Status ='Live']);

        //Get reputation points from communities
        Map<Id, NetworkMember> communityPoints = new Map<Id, NetworkMember>([SELECT MemberId, NetworkId, ReputationPoints FROM NetworkMember WHERE NetworkId IN :repEnabled]);

        // For each community
        for (Network community : repEnabled) {

            // Map<UserId, Points>>
            Map<Id, Double> userPoints = new Map<Id, Double>();

            // For each community in networkMember map
            for (Id comKey : communityPoints.keySet()) {
                // Get user from map
                NetworkMember member = communityPoints.get(comKey);

                if (community.Id == member.NetworkId) {
                    userPoints.put(member.MemberId, member.ReputationPoints);
                }
            }

            // Put all member points in the current community
            result.put(community.Id, userPoints);
        }

        return result;
    }

    /*
	  params : none
	  return Map of Chatter Zones Ids to Network
	*/
    public static map<String,String> chatterZoneToNetwork() {
        map<String,String> result = new map<String,String>();
        list<ca2cq_Zone_community__c> mapps = ca2cq_Zone_community__c.getAll().values();

        // Create map with existing ZoneIds and setup object
        Map<Id, ca2cq_Zone_community__c> zoneIdToConfig = new Map<Id, ca2cq_Zone_community__c>();

        for(ca2cq_Zone_community__c ca : mapps){
            if (ca.Community_Id__c =='null')
                result.put(ca.zoneId__c, null );
            else
                result.put(ca.zoneId__c, ca.Community_Id__c );
        }
        return result;
    }

    /*
      params : none
      return Map of dataCategory to Topics
    */
    public static  Map<String, String> getDCToToppicsMap() {
        Map<String, String> result = new Map<String, String>();
        List<ca2cq_categories_To_Topic__c> mapps = ca2cq_categories_To_Topic__c.getAll().values();

        // Create map with existing ZoneIds and setup object
        Set<String> dataCategorySet = new Set<String>();
        for (ca2cq_categories_To_Topic__c e : mapps) {
            result.put(e.DataCategoryName__c, e.TopicName__c);
        }

        return result;
    }

    /*
      params : none
      return List of ca2cq_categories_To_Topic__c
    */
    public static list<ca2cq_categories_To_Topic__c> getDCToToppics() {
        list<ca2cq_categories_To_Topic__c> mapps = ca2cq_categories_To_Topic__c.getAll().values();

        Map<String, String> dataCategoryMap =  getDCToToppicsMap();
        Integer total = Limits.getLimitDMLRows();
        Integer processed = Limits.getDMLRows();

        Integer myLimit = total-processed-500;

        if (myLimit < 0 ) {
            myLimit = 10;
        }

        // build result list adding any datacategory not registered
        for (QuestionDataCategorySelection dc : [SELECT DataCategoryName
                                                 FROM   QuestionDataCategorySelection
                                                 ORDER BY CreatedDate DESC
                                                 LIMIT :myLimit]){
            if (!dataCategoryMap.containsKey(dc.DataCategoryName)){
                dataCategoryMap.put(dc.DataCategoryName, '');
                mapps.add(new ca2cq_categories_To_Topic__c(
                            Name = dc.DataCategoryName,
                            DataCategoryName__c = dc.DataCategoryName,
                            TopicName__c = dc.DataCategoryName.replaceAll('_',' ')
                        )
                );
            }

        }

        system.debug('\n=====[getDCToToppics] : '+mapps);

        return mapps;
    }

    /*
	  params : none
	  return List of ca2cq_Zone_community__c
		Get list of zones to communities
	*/
    public static list<ca2cq_Zone_community__c>  getAppCommunityMappings() {
        list<ca2cq_Zone_community__c> mapps = ca2cq_Zone_community__c.getAll().values();
		Map<Id,Id> mapRecordToZoneId = new Map<Id,Id>();


        // Create map with existing ZoneIds and setup object
        Map<Id, ca2cq_Zone_community__c> zoneIdToConfig = new Map<Id, ca2cq_Zone_community__c>();
        for(ca2cq_Zone_community__c ca : mapps){
            zoneIdToConfig.put(ca.zoneId__c, ca);
        }

        // Build result list adding any Zone not registered
        Map<Id,Community> allC = allCommunities();
        if ( mapps.isEmpty() || mapps.size() != allC.size() ){
            ca2cq_Zone_community__c tmp ;

            for(Id i : allC.keySet()){
                if (! zoneIdToConfig.containsKey(i)){
                    tmp = new ca2cq_Zone_community__c();
                    tmp.name = allC.get(i).Id;
                    tmp.zoneId__c = i;
                    tmp.Active_for_Migration__c = false;
                    mapps.add(tmp);
					//add new Zone to map
					zoneIdToConfig.put(tmp.zoneId__c, tmp);
                }
            }
        }

		// Sort
		List<Id> sortedIds = new List<Id>();
		List<Id> unSortedIds = new List<Id>();
		unSortedIds.addAll(zoneIdToConfig.keySet());
		for(Community zc :[	SELECT Id,Name,NetworkId
							FROM Community where id in:unSortedIds AND IsActive = true
							order by name asc ]){
			sortedIds.add(zc.Id);
		}

		list<ca2cq_Zone_community__c> sortedList = new list<ca2cq_Zone_community__c> ();
		for(Id thisId : sortedIds){
			if (zoneIdToConfig.containsKey(thisId)){
				sortedList.add(zoneIdToConfig.get(thisId));
			}
		}
        return sortedList;
    }

    /*
	  params : none
	  return List of ca2cq_Zone_community__c
		Get list of zones to communities
	*/
    public static Map<Id,Community> allCommunities() {
        Integer limitValue = (  Limits.getLimitDMLRows() - Limits.getDMLRows() );

        return  new Map<Id,Community>([SELECT CreatedById,CreatedDate,Description,Id,IsActive,
                        LastModifiedById,LastModifiedDate,Name,NetworkId,SystemModstamp
                FROM Community
                WHERE IsActive = true
                ORDER BY Name ASC
                LIMIT  :limitValue ]) ;

    }

    /*
	  params : none
	  return List of Network
		Get list of all active Networks
	*/
	public static List<Network> allNetworkList() {
		Integer limitValue = (  Limits.getLimitDMLRows() - Limits.getDMLRows() );
		return  [ SELECT Description,Id,Name,Status
				FROM Network
				WHERE Status ='Live'
				order by Name asc
				LIMIT  :limitValue];

	}

    /*
	  params : none
	  return Map of Topics name - Network Id to Topic Id
		Gets a Map of all Topics from Networks
	*/
    public static Map<String, Id> allTopics() {
        Map<String, Id> topicMap = new Map<String, Id>();
        for (Topic t : [SELECT  Id, Name, NetworkId
                        FROM    Topic
                        LIMIT 10000]) {
            topicMap.put(t.name + ':&:' + t.NetworkId, t.Id);
        }

        return topicMap;
    }

    /*
	  params : List of Topic
	  return
		Creates Chatter Navigational Topics from a List of Topics
	*/
    public static void createNavigationalTopics(List<Topic> topics){
        Map<Id, List<Topic> > listTopics = new Map<Id, List<Topic> >();
        List<Topic> topicElements;

        //group topics by community
        for(Topic t : topics){

            if (listTopics.containsKey(t.NetworkId)){
                topicElements = listTopics.get(t.NetworkId);
            }else{
                topicElements = new List<Topic>();
            }
            topicElements.add(t);
            listTopics.put(t.NetworkId,topicElements);

        }

        for (Id community : listTopics.keySet()){
            if(community != null){
                ConnectApi.ManagedTopicCollection mt = ConnectApi.ManagedTopics.getManagedTopics(community, ConnectApi.ManagedTopicType.Navigational);
                List<Topic> lt = listTopics.get(community);

                for(Integer a = mt.managedTopics.size(); a < 25 && a < lt.size(); a++){
                    try {
                        if(!System.Test.isRunningTest())
                            ConnectApi.ManagedTopics.createManagedTopic(community, lt[a].Id, ConnectApi.ManagedTopicType.Navigational);
                    } catch (Exception e) {
            			System.debug('Exception: ' + e);
            		}
                }
            }
        }
    }

    /*
	  params : Map of bestAnswers
	  return None
		Inserts a best answer given a map of FeedComments
	*/
    public static void insertQuestionsToMigrate(Map<String, FeedComment> bestAnswersMap) {
        // Custom object that with best answers info
        List<ca2cq_best_answer_to_migrate__c> bestAnswers = new List<ca2cq_best_answer_to_migrate__c>();

        for (String key : bestAnswersMap.keySet()) {
            FeedComment fc = bestAnswersMap.get(key);
            if (String.isNotBlank(fc.Id)) {
                List<String> parts = key.split(':&:');

                bestAnswers.add(new ca2cq_best_answer_to_migrate__c(
					Feed_Item_Id__c = parts[0],
					Network_Id__c = parts[1],
					Feed_Comment_Id__c = fc.Id,
					Feed_Comment_CreatedById__c = fc.CreatedById,
					Feed_Comment_SelectedById__c = parts[2]));
            }
        }

        insert bestAnswers;
    }

    /*convertHashtagThatCouldBeTopic
    params: body
    return: String body with the replace of "#" for "# " that could only generate a new topic
    */
    public static String convertHashtagThatCouldBeTopic(String body) {
        Integer occurrences = body.countMatches('#');
        Integer counter = 0;
        Integer toIndex = 0;
        String copyBody = '';
        Integer fromChar = 0;
        Integer nextChar = 0;
        while (counter < occurrences) {
            copyBody = body.substring(toIndex, body.length());
            toIndex += copyBody.indexOf('#') + 1;
            Integer actualHashTagIndex = body.lastIndexOf('#',toIndex);
            fromChar = actualHashTagIndex + 1;
            nextChar = actualHashTagIndex + 2;
            Integer actualBodyLength = body.length();
            if (nextChar <= actualBodyLength) {
                String firstChar = body.substring(fromChar, nextChar);
                if (!firstChar.isNumeric()) {
                    body = body.substring(0,fromChar) + ' ' + body.substring(fromChar,actualBodyLength);
                }
                else {
                    // possible cases : &#xx; / &#xxx; / &#xxxx; (positions 2-3 / 3-4 / 4-5)
                    Integer fromCheckDot = fromChar + 2;
                    Integer toCheckDot = fromChar + 3;
                    Boolean shouldChange = true;
                    for (Integer i = 0; i < 3; i++) {
                        if(fromCheckDot < body.length() && toCheckDot <= body.length()){
                            String shouldBeDot = body.substring(fromCheckDot, toCheckDot);
                            if (shouldBeDot.equals(';')) {
                                shouldChange = false;
                                break;
                            }
                            fromCheckDot++;
                            toCheckDot++;
                        }
                    }
                    if(shouldChange) {
                        body = body.substring(0,fromChar) + ' ' + body.substring(fromChar,actualBodyLength);
                    }
                }
            }
            counter++;
        }
        return body;
    }

    /*
	  params : String with the body of a question, NetworkId
	  return String with the converted body
		Replaces unused/non legal tags with the ones supported in chatter, if applicable
	*/
    public static string convertBody(String body,String netId) {
        if (body.contains('%@%')) {
            body = body.replaceAll('%@%', '');
        }

        body = convertHashtagThatCouldBeTopic(body);
        // If there are two br tags next to each other replace them with a sole br tag.
        // This prevents the chatter feed from having too many spaces.
        body = body.replaceAll('<br><br><br><br>', '<br>');
        body = body.replaceAll('<br><br><br>', '<br>');
        body = body.replaceAll('<br><br>', '<br>');
        body = body.replaceAll('<br> <br>', '<br>');
        // Remove  attributes


        body = removeAttributes(body);
        body = body.replaceAll('<code >','<code>');
        // Count the link tag occurrences
        Integer occurrences = body.countMatches('<a');
        Integer counter = 0;

        // Substitute the link tag with the plain url for each occurrence
        while (counter < occurrences) {
            if (body.contains('(<a')) {
                // Used when a tag is not correctly formed by not having closing parenthesis
                Boolean nullTag = false;

                String tag = body.substringBetween('(<a', '</a>)');
                String fullTag = '(<a' + tag + '</a>)';
                String startTag = fullTag.substringBetween('(<a', '>');
                String insideBody = fullTag.substringBetween('(<a' + startTag + '>', '</a>)');

                if (String.isBlank(tag)) {
                    nullTag = true;
                    tag = body.substringBetween('(<a', '</a>');
                    fullTag = '(<a' + tag + '</a>';
                    startTag = fullTag.substringBetween('(<a', '>');
                    insideBody = fullTag.substringBetween('(<a' + startTag + '>', '</a>');
                }

                // Check if tag contains an email
                if (fullTag.contains('(<a href="mailto:')) {
                    String emailReceptor = fullTag.substringBetween('mailto:', '?');
                    if (String.isBlank(emailReceptor))
                        emailReceptor = fullTag.substringBetween('mailto:', '"');

                    // Remove extra characters from subject
                    String emailSubject = fullTag.substringBetween('subject=', '&amp;body');
                    if (!String.isBlank(emailSubject))
                        emailSubject = convertEmail(emailSubject);

                    // Remove extra characters from body
                    String emailBody = fullTag.substringBetween('body=', '"');
                    if (!String.isBlank(emailBody))
                        emailBody = convertEmail(emailBody);

                    if (insideBody.contains('</')) {
                        if (emailSubject != NULL && emailBody != NULL)
                  	        body = body.replace(fullTag, '(To: ' + emailReceptor + ' - Subject: ' + emailSubject + ' - Body: ' + emailBody + ') '+ insideBody);
                        else {
                            body = body.replace(fullTag, '(To: ' + emailReceptor + ') '+ insideBody);
                        }
                    }
                    else {
                        insideBody = convertEmail(insideBody);
                        if (emailSubject != NULL && emailBody != NULL && emailBody != NULL)
                            if (nullTag)
                                body = body.replace('(<a' + tag + '</a>', '(To: ' + emailReceptor + ' - Subject: ' + emailSubject + ' - Body: ' + emailBody + ') ');
                            else
                                body = body.replace('(<a' + tag + '</a>)', '(To: ' + emailReceptor + ' - Subject: ' + emailSubject + ' - Body: ' + emailBody + ') ');
                        else {
                            if (insideBody.equals(emailReceptor) || emailReceptor == NULL)
                                body = body.replace(fullTag, '(' + insideBody + ') ');
                            else
                                body = body.replace(fullTag, '(To: ' + emailReceptor + ') '+ insideBody);
                        }
                    }
                } else {
                    // If the link has the news:// protocol
                    if (fullTag.contains('news:')) {
                        String aTag = fullTag.substringBetween('(<a', '>');
                        String url;
                        if (nullTag)
                            url = fullTag.substringBetween('<a' + aTag + '>', '</a>');
                        else
                            url = fullTag.substringBetween('<a' + aTag + '>', '</a>)');

                        body = body.replace(fullTag, url+' ');
                    } else {
                        if(fullTag.contains('href=')) {
                            String url = fullTag.substringBetween('href="', '"');
                            // If url and inside body are the same
                            if (url.equals(insideBody)) {
                                if (nullTag)
                                    body = body.replace('(<a' + tag + '</a>', '(' + url + ') ');
                                else
                                    body = body.replace('(<a' + tag + '</a>)', '(' + url + ') ');
                            } else {
                                if (nullTag)
                                    body = body.replace('(<a' + tag + '</a>', '(' + url + ') ' + insideBody + ' ');
                                else
                                    body = body.replace('(<a' + tag + '</a>)', '(' + url + ') ' + insideBody + ' ');
                            }
                        } else {
                            if (nullTag) {
                                String content = fullTag.substringBetween('>', '</a>)');
                                body = body.replace('(<a' + tag + '</a>)', content + ' ');
                            } else {
                                String content = fullTag.substringBetween('>', '</a>)');
                                body = body.replace('(<a' + tag + '</a>)', content + ' ');
                            }
                        }
                    }
                }
            }

            else if (body.contains('<a')) {
                String tag = body.substringBetween('<a', '</a>');
                String fullTag = '<a' + tag + '</a>';
                String startTag = fullTag.substringBetween('<a', '>');
                String insideBody = fullTag.substringBetween('<a' + startTag + '>', '</a>');

                // Check if tag contains an email
                if (fullTag.contains('<a href="mailto:')) {
                    String emailReceptor = fullTag.substringBetween('mailto:', '?');
                    if (String.isBlank(emailReceptor))
                        emailReceptor = fullTag.substringBetween('mailto:', '"');

                    String emailSubject = fullTag.substringBetween('subject=', '&amp;body');
                    if (!String.isBlank(emailSubject))
                        emailSubject = convertEmail(emailSubject);

                    String emailBody = fullTag.substringBetween('body=', '"');
                    if (!String.isBlank(emailBody))
                        emailBody = convertEmail(emailBody);

                    if (insideBody.contains('</')) {
                        if (emailSubject != NULL && emailBody != NULL) {
                            body = body.replace(fullTag, '(To: ' + emailReceptor + ' - Subject: ' + emailSubject + ' - Body: ' + emailBody + ') '+ insideBody);
                        } else {
                            body = body.replace(fullTag, '(To: ' + emailReceptor + ') '+ insideBody);
                        }
                    }
                    else {
                        insideBody = convertEmail(insideBody);
                        if (emailSubject != NULL && emailBody != NULL && emailReceptor != NULL)
                            body = body.replace(fullTag, '(To: ' + emailReceptor + ' - Subject: ' + emailSubject + ' - Body: ' + emailBody + ') ');
                        else {
                            if (insideBody.equals(emailReceptor) || emailReceptor == NULL)
                                body = body.replace(fullTag, '(' + insideBody + ') ');
                            else
                                body = body.replace(fullTag, '(To: ' + emailReceptor + ') '+ insideBody);
                        }
                    }
                } else {
                    // If the link has the news:// protocol
                    if (fullTag.contains('news:')) {
                        String aTag = fullTag.substringBetween('<a', '>');
                        String url = fullTag.substringBetween('<a' + aTag + '>', '</a>');
                        body = body.replace(fullTag, url+' ');
                    } else {
                        if(fullTag.contains('href=')) {
                            String url = fullTag.substringBetween('href="', '"');
                            // If url and inside body are the same
                            if (url != null && url.equals(insideBody)) {
                                body = body.replace('<a' + tag + '</a>', url);
                            } else {
                                if (String.isEmpty(url))
                                    body = body.replace('<a' + tag + '</a>', insideBody);
                                else
                                    body = body.replace('<a' + tag + '</a>', '(' + url + ') ' + insideBody + ' ');
                            }
                        } else {
                            String content = fullTag.substringBetween('>', '</a>');
                            body = body.replace('<a' + tag + '</a>', content + ' ');
                        }
                    }
                }
            }

            counter++;
        }
        // Search body for img tag
        occurrences = body.countMatches('<img');

        counter = 0;
        String replacementBody = body;
        system.debug('\n original : '+body+' \n * ocurrences of img: ' + occurrences);
        while (counter < occurrences) {
            String image = replacementBody.substringBetween('<img', '></img>');


            if (image != null) {
                String url = image.substringBetween('src="','"');
                String fullTag = '<img' + image + '></img>';
                System.debug('url: ' + url);
                if (url != null) {
                    if (!url.contains('rtaImage?eid')) {
                        body = body.replace(fullTag, url + ' ');
                        replacementBody = replacementBody.replace(fullTag, '');
                    } else {
                        replacementBody = replacementBody.replace(fullTag, '');
                        body = body.replace(fullTag, '_img_' + image + '_/_img_');

                        if (fullTag.contains('height="')) {
                            String heightAtr = fullTag.substringBetween('height="', '"');
                            body = body.replace('height="' + heightAtr + '"', '');
                            replacementBody = replacementBody.replace('height="' + heightAtr + '"','');
                        }

                        if (fullTag.contains('width="')) {
                            String widthAtr = fullTag.substringBetween('width="', '"');
                            body = body.replace('width="' + widthAtr + '"', '');
                            replacementBody = replacementBody.replace('width="' + widthAtr + '"','');
                        }
                    }

                    if (replacementBody.equals('')) {
                        body = body.replace('<img', '_img_');
                        body = body.replace('></img>', '_/_img_');
                    }


                 } else {
                    // Img tag does not contain rtaImage
                    body = body.replace(fullTag, '');
                    replacementBody = replacementBody.replace(fullTag, '');
                 }

            }
            system.debug('\n original : '+body+'\n** replacementBody of img: ' + replacementBody);
            counter++;
        }

        // Search body for code snippets
        occurrences = body.countMatches('<code');
        counter = 0;
        replacementBody = body;

        // Substitute the content of the code tag with escaped characters
        while (counter < occurrences){
            String code = replacementBody.substringBetween('<code>','</code>');

            if (code != null) {
                String escapedCode = code.replace('<', '&lt;');
                escapedCode = escapedCode.replace('>', '&gt;');
                // Remove first blank character
                //escapedCode = escapedCode.replaceFirst('\\s+', '');

                body = body.replace('<code>' + code + '</code>', '<code>' + escapedCode + '</code>');
                replacementBody = replacementBody.replace('<code>' + code + '</code>', '');
            }
            counter++;
        }


        // Search body for table tags.
        occurrences = body.countMatches('<table');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<table', '>');

            body = body.replace('<table' + startTag + '>', ' ');
            body = body.replace('</table>', ' ');

      	    counter++;
        }

        // Search body for thead tags.
        occurrences = body.countMatches('<thead');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<thead', '>');

            body = body.replace('<thead' + startTag + '>', ' ');
            body = body.replace('</thead>', ' ');

            counter++;
        }
        // Search body for tbody tags.
        occurrences = body.countMatches('<tbody');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<tbody', '>');

            body = body.replace('<tbody' + startTag + '>', ' ');
            body = body.replace('</tbody>', ' ');

            counter++;
        }
        // Search body for tbody tags.
        occurrences = body.countMatches('<tfoot');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<tfoot', '>');

            body = body.replace('<tfoot' + startTag + '>', ' ');
            body = body.replace('</tfoot>', ' ');

            counter++;
        }
        // Search body for td tags.
        occurrences = body.countMatches('<td');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<td', '>');

            body = body.replace('<td' + startTag + '>', ' ');
            body = body.replace('</td>', ' ');

            counter++;
        }

        // Search body for tr tags.
        occurrences = body.countMatches('<tr');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<tr', '>');

            body = body.replace('<tr' + startTag + '>', ' ');
            body = body.replace('</tr>', ' ');

            counter++;
        }

        // Search body for th tags.
        occurrences = body.countMatches('<th');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<th', '>');

            body = body.replace('<th' + startTag + '>', ' ');
            body = body.replace('</th>', ' ');

            counter++;
        }

        // Search body for col tags.
        occurrences = body.countMatches('<colgroup');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<colgroup', '>');

            body = body.replace('<colgroup' + startTag + '>', ' ');
            body = body.replace('</colgroup>', ' ');

            counter++;
        }


        // Search body for col tags.
        occurrences = body.countMatches('<col');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<col', '>');

            body = body.replace('<col' + startTag + '>', ' ');
            body = body.replace('</col>', ' ');

            counter++;
        }

        // Search body for tgroup tags.
        occurrences = body.countMatches('<tgroup');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<tgroup', '>');

            body = body.replace('<tgroup' + startTag + '>', ' ');
            body = body.replace('</tgroup>', ' ');

            counter++;
        }

        // Search body for caption tags.
        occurrences = body.countMatches('<caption');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<caption', '>');

            body = body.replace('<caption' + startTag + '>', ' ');
            body = body.replace('</caption>', ' ');

            counter++;
        }

        // Search body for dl tags
        occurrences = body.countMatches('<dl');
        counter = 0;

        while (counter < occurrences) {
            String mainTag = body.substringBetween('<dl', '</dl>');

            if (mainTag != null && mainTag != '') {
                String mainStartTag = body.substringBetween('<dl', '>');
                String mainFullTag = '<dl' + mainTag + '</dl>';
                String mainInsideTag = body.substringBetween('<dl' + mainStartTag + '>', '</dl>');

                if (mainTag.contains('<dl')) {
                    mainTag = mainTag + '</dl>';
                    String subMainTag = mainTag.substringBetween('<dl', '</dl>');
                    String subMainStartTag = mainTag.substringBetween('<dl', '>');
                    String subMainFullTag = '<dl' + subMainTag + '</dl>';
                    String subMainInsideTag = mainTag.substringBetween('<dl' + subMainStartTag + '>', '</dl>');

                    body = body.replace(subMainFullTag, subMainInsideTag);

                    mainTag = body.substringBetween('<dl', '</dl>');
                    mainStartTag = body.substringBetween('<dl', '>');
                    mainFullTag = '<dl' + mainTag + '</dl>';
                    mainInsideTag = body.substringBetween('<dl' + mainStartTag + '>', '</dl>');
                }

                body = body.replace(mainFullTag, mainInsideTag);
            }

            counter++;
        }


        // Search body for dd tags
        occurrences = body.countMatches('<dd');
        counter = 0;

        while (counter < occurrences) {
            String mainTag = body.substringBetween('<dd', '</dd>');

            if (mainTag != null && mainTag != '') {
                String mainStartTag = body.substringBetween('<dd', '>');
                String mainFullTag = '<dd' + mainTag + '</dd>';
                String mainInsideTag = body.substringBetween('<dd' + mainStartTag + '>', '</dd>');

                if (mainTag.contains('<dd')) {
                    mainTag = mainTag + '</dd>';
                    String subMainTag = mainTag.substringBetween('<dd', '</dd>');
                    String subMainStartTag = mainTag.substringBetween('<dd', '>');
                    String subMainFullTag = '<dd' + subMainTag + '</dd>';
                    String subMainInsideTag = mainTag.substringBetween('<dd' + subMainStartTag + '>', '</dd>');

                    body = body.replace(subMainFullTag, subMainInsideTag);

                    mainTag = body.substringBetween('<dd', '</dd>');
                    mainStartTag = body.substringBetween('<dd', '>');
                    mainFullTag = '<dd' + mainTag + '</dd>';
                    mainInsideTag = body.substringBetween('<dd' + mainStartTag + '>', '</dd>');
                }

                body = body.replace(mainFullTag, mainInsideTag);
            }

            counter++;
        }


        // Search body for dt tags
        occurrences = body.countMatches('<dt');
        counter = 0;

        while (counter < occurrences) {
            String mainTag = body.substringBetween('<dt', '</dt>');

            if (mainTag != null && mainTag != '') {
                String mainStartTag = body.substringBetween('<dt', '>');
                String mainFullTag = '<dt' + mainTag + '</dt>';
                String mainInsideTag = body.substringBetween('<dt' + mainStartTag + '>', '</dt>');

                if (mainTag.contains('<dt')) {
                    mainTag = mainTag + '</dt>';
                    String subMainTag = mainTag.substringBetween('<dt', '</dt>');
                    String subMainStartTag = mainTag.substringBetween('<dt', '>');
                    String subMainFullTag = '<dt' + subMainTag + '</dt>';
                    String subMainInsideTag = mainTag.substringBetween('<dt' + subMainStartTag + '>', '</dt>');

                    body = body.replace(subMainFullTag, subMainInsideTag);

                    mainTag = body.substringBetween('<dt', '</dt>');
                    mainStartTag = body.substringBetween('<dt', '>');
                    mainFullTag = '<dt' + mainTag + '</dt>';
                    mainInsideTag = body.substringBetween('<dt' + mainStartTag + '>', '</dt>');
                }

                body = body.replace(mainFullTag, mainInsideTag);
            }

            counter++;
        }


        // Search body for pre tags.
        occurrences = body.countMatches('<pre');
        counter = 0;
        while (counter < occurrences) {
            String startTag = body.substringBetween('<pre', '>');
            String insideTag = body.substringBetween('<pre' + startTag + '>', '</pre>');

            if (insideTag.countMatches('<br>') > 0) {
                String insideTagCopy = insideTag;

                insideTagCopy = insideTagCopy.replaceAll('<br>', '');

                body = body.replace(insideTag, insideTagCopy);
            }

            if (insideTag.countMatches('<code') > 0) {
                String insideTagCopy = insideTag;

                Integer codeOccurrences = insideTag.countMatches('<code');
                Integer codeCounter = 0;

                while (codeCounter < codeOccurrences) {
                    String codeTag = insideTagCopy.substringBetween('<code', '>');

                    insideTagCopy = insideTagCopy.replace('<code' + codeTag + '>', '');
                    insideTagCopy = insideTagCopy.replace('</code>', ' ');

                    body = body.replace(insideTag, insideTagCopy);

                    insideTag = body.substringBetween('<pre' + startTag + '>', '</pre>');

                    codeCounter++;
                }
            }

            String fullPreStartTag = '<pre' + startTag + '>';
            // Replace all tags that match the string fullPreStartTag to <pre> to avoid failure of replaceFirst on a regEx
            body = body.replace(fullPreStartTag, '<pre>');
            body = body.replaceFirst('<pre>', '<code>');
            body = body.replaceFirst('</pre>', '</code>');

      	    counter++;
        }


        // Search body for abbr tags.
        occurrences = body.countMatches('<abbr');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<abbr', '>');

            body = body.replace('<abbr' + startTag + '>', ' ');
            body = body.replace('</abbr>', ' ');

      	    counter++;
        }


        // Search body for acronym tags.
        occurrences = body.countMatches('<acronym');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<acronym', '>');

            body = body.replace('<acronym' + startTag + '>', ' ');
            body = body.replace('</acronym>', ' ');

      	    counter++;
        }


        // Search body for address tags.
        occurrences = body.countMatches('<address');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<address', '>');

            body = body.replace('<address' + startTag + '>', '');
            body = body.replace('</address>', '');

      	    counter++;
        }

        // Search body for b tags that contains br tags and remove them.
        occurrences = body.countMatches('<b>');
        counter = 0;
        replacementBody = body;
        while (counter < occurrences){
            String startTag = replacementBody.substringBetween('<b>', '</b>');

            String fullStartTag = '<b>' + startTag + '</b>';

            if (fullStartTag.contains('<br>')) {
                String startTagCopy = fullStartTag;

                startTagCopy = startTagCopy.replaceAll('<br>', ' ');

                body = body.replace(fullStartTag, startTagCopy);
            }

            replacementBody = replacementBody.replace(fullStartTag, '');

      	    counter++;
        }

        // Search body for big tags.
        occurrences = body.countMatches('<big');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<big', '>');

            body = body.replace('<big' + startTag + '>', '');
            body = body.replace('</big>', '');

      	    counter++;
        }

        // Search body for blockquote tags.
        occurrences = body.countMatches('<blockquote');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<blockquote', '>');

            body = body.replace('<blockquote' + startTag + '>', '');
            body = body.replace('</blockquote>', '');

      	    counter++;
        }

        // Search body for cite tags.
        occurrences = body.countMatches('<cite');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<cite', '>');

            body = body.replace('<cite' + startTag + '>', ' ');
            body = body.replace('</cite>', ' ');

      	    counter++;
        }

        // Search body for code tags that contains nested code tags and remove the latter
        // Search body for cite tags.
        // Search body for dd tags
        body = body.replaceAll('<code >','<code>');

        occurrences = body.countMatches('<code>') ;
        counter = 0;
        if (occurrences > 0) {
            integer indexOfFirstCode = body.indexof('<code>');
            integer indexFromLastCharOfFirstCode = indexOfFirstCode + 6;

            integer lastIndexOfCloseCodeTag = indexFromLastCharOfFirstCode + body.substring(indexFromLastCharOfFirstCode,body.length()).indexof('</code>');
            Boolean continueWithCodeBlocks = true;
            Boolean continueSearchingOpenCode = true;
            String closeCode = '</code>';
            String openCode = '<code>';
            while (continueWithCodeBlocks)
            {
                while(continueSearchingOpenCode){
                    //must check for another code tag inside
                        integer indexOfOpenCodeInside = body.substring(indexFromLastCharOfFirstCode,lastIndexOfCloseCodeTag).indexof('<code>');


                        if(indexOfOpenCodeInside >= 0)
                        {
                            if(indexOfOpenCodeInside== 0)
                            {
                                body =   body.substring(indexFromLastCharOfFirstCode + indexOfOpenCodeInside)  + '&lt;code&gt;' + body.substring(indexFromLastCharOfFirstCode + indexOfOpenCodeInside + openCode.length(), body.length());

                            }
                            else{
                                body =   body.substring(0,indexFromLastCharOfFirstCode + indexOfOpenCodeInside)  + '&lt;code&gt;' + body.substring(indexFromLastCharOfFirstCode + indexOfOpenCodeInside + openCode.length(), body.length());

                            }
                        }
                        else
                        {
                            continueSearchingOpenCode = false;
                        }
                    }

                indexFromLastCharOfFirstCode = lastIndexOfCloseCodeTag + 7  ;// cause in this index we close the eacg first code tag aparition
                // check if exist some </code> closing another that we maybe remove before
                // if we remove for example <code> <code> inside of our <code> </code> must be removed later 2 close tag before start to processing the first code tag if exist
                integer checkCloseCode = -1;
                integer checkOpenCode = -1;
                Boolean continueCleaning = true;

                while (continueCleaning){
                    checkOpenCode = body.substring(indexFromLastCharOfFirstCode, body.length()).indexof('<code>');
                    checkCloseCode = body.substring(indexFromLastCharOfFirstCode, body.length()).indexof('</code>');
                    // <code> <code> <code> </code> </code>
                    if(checkCloseCode >= 0 && checkOpenCode >= 0) //
                    {
                        if( checkCloseCode < checkOpenCode ) // must be removed a close tag that is closing another code tag opened that we remove nested to the last code
                        {
                            body = body.substring(0,indexFromLastCharOfFirstCode + checkCloseCode) + '&lt;/code&gt;' + body.substring(indexFromLastCharOfFirstCode + checkCloseCode + closeCode.length(), body.length());

                        }
                        else
                        {
                            continueCleaning = false;
                        }
                    }

                    else if(checkCloseCode >= 0 && checkOpenCode < 0)
                    {
                        body = body.substring(0,indexFromLastCharOfFirstCode + checkCloseCode) + '&lt;/code&gt;' + body.substring(indexFromLastCharOfFirstCode + checkCloseCode + closeCode.length(), body.length());
                    }
                    else
                    {   //will enter here only if exist another open code or if no exist another tag of code
                        continueCleaning = false;
                    }
                }
                if (checkOpenCode < 0){
                    continueWithCodeBlocks = false;
                }
                else{
                    indexOfFirstCode = indexFromLastCharOfFirstCode +  checkOpenCode;
                    indexFromLastCharOfFirstCode = indexOfFirstCode + 5;
                    lastIndexOfCloseCodeTag = indexFromLastCharOfFirstCode + body.substring(indexFromLastCharOfFirstCode,body.length()).indexof('</code>');
                    continueSearchingOpenCode = true;
                }
            }
        }

        if (body.contains('<code>')) {
            String insideTagCodeToProcess = body.substringBetween('<code>', '</code>');

            if (insideTagCodeToProcess != null && !String.isEmpty(insideTagCodeToProcess)) {
                insideTagCodeToProcess = insideTagCodeToProcess.replaceAll('<','&lt;');
                insideTagCodeToProcess = insideTagCodeToProcess.replaceAll('>','&gt;');
                body = body.substring(0,body.indexof('<code>')) + '<code> '+  insideTagCodeToProcess  + body.substring(body.indexof('</code>'),body.length());
            }
        }


        // Search body for dfn tags.
        occurrences = body.countMatches('<dfn');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<dfn', '>');

            body = body.replace('<dfn' + startTag + '>', '');
            body = body.replace('</dfn>', '');

      	    counter++;
        }


        // Search body for div tags.
        occurrences = body.countMatches('<div');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<div', '>');

            body = body.replace('<div' + startTag + '>', '');
            body = body.replace('</div>', '');

      	    counter++;
        }


        // Search body for em tags.
        occurrences = body.countMatches('<em');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<em', '>');

            body = body.replace('<em' + startTag + '>', ' ');
            body = body.replace('</em>', ' ');

            counter++;
        }


        // Search body for font tags.
        occurrences = body.countMatches('<font');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<font', '>');

            body = body.replace('<font' + startTag + '>', ' ');
            body = body.replace('</font>', ' ');

      	    counter++;
        }


        // Search body for h tags
        occurrences = body.countMatches('<h');
        counter = 0;
        replacementBody = body;

        while (counter < occurrences){
            String tag = replacementBody.substringBetween('<h', '>');
            String endTag = replacementBody.substringBetween('</h', '>');

            if (tag != null){
            	  body = body.replace('<h' + tag + '>', '');
                body = body.replace('</h' + endTag + '>', ' ');
                replacementBody = replacementBody.replace('<h' + tag + '>', '');
                replacementBody = replacementBody.replace('</h' + endTag + '>', '');
            }
        	counter++;
        }



        // Search body for ins tags.
        occurrences = body.countMatches('<ins');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<ins', '>');

            body = body.replace('<ins' + startTag + '>', '');
            body = body.replace('</ins>', '');

      	    counter++;
        }


        // Search body for kbd tags.
        occurrences = body.countMatches('<kbd');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<kbd', '>');

            body = body.replace('<kbd' + startTag + '>', ' ');
            body = body.replace('</kbd>', ' ');

      	    counter++;
        }


        // Search body for p tags.
        occurrences = body.countMatches('<p');
        counter = 0;
        replacementBody = body;

        while (counter < occurrences){
            String startTag = replacementBody.substringBetween('<p', '>');

            if (!String.isEmpty(startTag))
                body = body.replace('<p' + startTag + '>', '<p>');

            replacementBody = replacementBody.replace('<p' + startTag + '>', '');

      	    counter++;
        }


        // Search body for p tags that contains br tags and remove them.
        occurrences = body.countMatches('<p>');
        counter = 0;
        replacementBody = body;
        while (counter < occurrences){
            String startTag = replacementBody.substringBetween('<p>', '</p>');
            String fullStartTag = '<p>' + startTag + '</p>';

            if (fullStartTag.contains('<br>')) {
                String startTagCopy = fullStartTag;
                startTagCopy = startTagCopy.replaceAll('<br>', ' ');

                body = body.replace(fullStartTag, startTagCopy);
            }

            replacementBody = replacementBody.replace(fullStartTag, '');

      	    counter++;
        }
        if (body.contains('<br>'))
            body = body.replace('<br>', '<p>&nbsp</p>');
        // Search body for samp tags.
        occurrences = body.countMatches('<samp');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<samp', '>');

            body = body.replace('<samp' + startTag + '>', '');
            body = body.replace('</samp>', '');

      	    counter++;
        }


        // Search body for small tags.
        occurrences = body.countMatches('<small');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<small', '>');

            body = body.replace('<small' + startTag + '>', '');
            body = body.replace('</small>', '');

      	    counter++;
        }


        // Search body for span tags.
        occurrences = body.countMatches('<span');
        counter = 0;
        while (counter < occurrences){
            String startTag = body.substringBetween('<span', '>');

            body = body.replaceAll('<span' + startTag + '>', ' ');
            body = body.replaceFirst('</span>', ' ');

      	    counter++;
        }

        // Search body for br tags. This code should be placed after the <p> tag search.
        occurrences = body.countMatches('<br');
        counter = 0;

        while (counter < occurrences) {
            String startTag = body.substringBetween('<br', '>');

            body = body.replace('<br' + startTag + '>', '<p>&nbsp</p>');
            body = body.replace('</br>', ' ');

            counter++;
        }

        // Search body for strike tags.
        occurrences = body.countMatches('<strike');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<strike', '>');

            body = body.replace('<strike' + startTag + '>', '<s>');
            body = body.replace('</strike>', '</s>');

      	    counter++;
        }


        // Search body for strong tags.
        occurrences = body.countMatches('<strong');
        counter = 0;
        replacementBody = body;

        while (counter < occurrences){
            String tag = replacementBody.substringBetween('<strong', '>');

            if (tag != null){
            	body = body.replace('<strong' + tag + '>', '');
                body = body.replace('</strong>', ' ');
          	    replacementBody = replacementBody.replace('<strong' + tag + '>', '');
                replacementBody = replacementBody.replace('</strong>', '');
            }
        	counter++;
        }


        // Search body for sup tags.
        occurrences = body.countMatches('<sup');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<sup', '>');

            body = body.replace('<sup' + startTag + '>', ' ');
            body = body.replace('</sup>', ' ');

      	    counter++;
        }


        // Search body for tt tags.
        occurrences = body.countMatches('<tt');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<tt', '>');

            body = body.replace('<tt' + startTag + '>', ' ');
            body = body.replace('</tt>', ' ');

      	    counter++;
        }



        // Search body for var tags.
        occurrences = body.countMatches('<var');
        counter = 0;

        while (counter < occurrences){
            String startTag = body.substringBetween('<var', '>');

            body = body.replace('<var' + startTag + '>', ' ');
            body = body.replace('</var>', ' ');

      	    counter++;
        }

        // Replace all remaining divs (if any left)
        body = body.replaceAll('<div>','');
        body = body.replaceAll('<div >','');
        body = body.replaceAll('</div>','');

        // Replace first blank space on code snippets (if any)
        body = body.replaceAll('<code> ','<code>');

        system.debug('final body is: '+ body);
        return body;
    }

    /*
	  params : String with the body of a question or reply
	  return String with the converted body
		Removes attributes from tags
	*/
    public static string removeAttributes(String body) {
        // Search body for align attributes
        Integer occurrences = body.countMatches('align="');
        Integer counter = 0;

        while (counter < occurrences){
            String attr = body.substringBetween('align="','"');
            body = body.replace('align="' + attr + '"', '');
            counter++;
        }


        // Search body for border attributes
        occurrences = body.countMatches('border="');
        counter = 0;

        while (counter < occurrences){
            String attr = body.substringBetween('border="','"');
            body = body.replace('border="' + attr + '"', '');
            counter++;
        }


        // Search body for class attributes
        occurrences = body.countMatches('class="');
        counter = 0;

        while (counter < occurrences){
            String attr = body.substringBetween('class="','"');
            body = body.replace('class="' + attr + '"', '');
            counter++;
        }


        // Search body for dir attributes
        occurrences = body.countMatches('dir="');
        counter = 0;

        while (counter < occurrences){
            String attr = body.substringBetween('dir="','"');
            body = body.replace('dir="' + attr + '"', '');
            counter++;
        }


        // Search body for id attributes
        occurrences = body.countMatches('id="');
        counter = 0;

        while (counter < occurrences){
            String attr = body.substringBetween('id="','"');
            body = body.replace('id="' + attr + '"', '');
            counter++;
        }


        // Search body for start attributes
        occurrences = body.countMatches('start="');
        counter = 0;

        while (counter < occurrences){
            String attr = body.substringBetween('start="','"');
            body = body.replace('start="' + attr + '"', '');
            counter++;
        }


        // Search body for style attributes
        occurrences = body.countMatches('style="');
        counter = 0;

        while (counter < occurrences){
            String attr = body.substringBetween('style="','"');
            body = body.replace('style="' + attr + '"', '');
            counter++;
        }


        // Search body for title attributes
        occurrences = body.countMatches('title="');
        counter = 0;

        while (counter < occurrences){
            String attr = body.substringBetween('title="','"');
            body = body.replace('title="' + attr + '"', '');
            counter++;
        }

        return body;
    }

    /*
	  params : String with body of email
	  return Converted string of body
		Unescapes characters in an email body
	*/
    public static string convertEmail(String emailText) {
        // Convert all encoded text
        emailText = emailText.replace('%26', '&amp;');
        emailText = emailText.replace('\'', '&quot;');
        emailText = emailText.replace('%3C', '&lt;');
        emailText = emailText.replace('%3E', '&gt;');
        emailText = EncodingUtil.urlDecode(emailText, 'UTF-8');
        return emailText;
    }

    /*
	  params : Map with urls of imgs to index, Map of index to Network
	  return Map with converted items
		Converts all the urls from an img chat and creates a contentDocument supported in chatter
	*/
	public static Map<Integer,List<ContentVersion>> convertToContent (Map<String,Integer> urlsToIndex, Map<Integer,Id> indexToNetworkId) {
		Map<Integer,List<ContentVersion>> result = new Map<Integer,List<ContentVersion>>();
        List<ContentVersion> indexResult;
        List<ContentVersion> cList = new List<ContentVersion>();
        String dbug ='';

        for(String url : urlsToIndex.keySet()) {
            Integer thisIndex = urlsToIndex.get(url);

            dbug +='\n [convertToContent urls]:'+url;
            PageReference pageRef = new PageReference(url.replace('amp;',''));

            ContentVersion v = new ContentVersion();
			if (!System.Test.isRunningTest()) {
				v.versionData = pageRef.getContent();
	            v.pathOnClient = url;
			} else {
				v.pathOnClient=url;
				v.versionData =  Blob.valueOf('el blob');
			}

            v.title = 'qa';
            v.Description = 'qa migration';
            v.NetworkId = indexToNetworkId.get(thisIndex);
            v.Origin = 'H';

            cList.add(v);
        }

        // insert cList;

		Database.UpsertResult[] cListResults =  Database.upsert(cList, false);
		List<String> logString = new List<String>();
        logString.add('\n DBUG : '+ dbug );
		List<Id> ids = new List<Id>();

        Integer g=0;

		for (Database.UpsertResult res : cListResults) {
            ContentVersion cv = cList.get(g);

			if (res.isSuccess()) {
				if (res.isCreated()) {
					ids.add(res.getId() );
					logString.add('\n ContentVersion OK : '+ res.getId() );
				}
			} else {
				if (res.getErrors().size() > 0) {
					logString.add('\n ContentVersion NOT OK : '+ res.getId()+ ' : '+res.getErrors()[0].getMessage()) ;

				}
			}
            g++;
		}

        for (ContentVersion c : [SELECT ContentDocumentId, pathOnClient
                                 FROM   ContentVersion
                                 WHERE  Id IN :ids]) {
            if (urlsToIndex.containsKey(c.pathOnClient)) {
                Integer tmpIndex = urlsToIndex.get(c.pathOnClient);

                if (result.containsKey(tmpIndex)) {
                    indexResult = result.get(tmpIndex);
                } else {
                    indexResult = new List<ContentVersion>();
                }

                indexResult.add(c);
                result.put(tmpIndex, indexResult);
                dbug +='\n [convertToContent]:'+tmpIndex+','+indexResult;
            } else {
				if (System.Test.isRunningTest()) {
					indexResult = new List<ContentVersion>{c};
					result.put(0, indexResult);
				}
			}
        }

       return result;
	}

    public static String resolveDateFilter() {
        String dString = '';
        String selectedYear = getSelectedYears();
        List<String> dateParts = new List<String>();
        if (selectedYear == 'All'){

        } else if (selectedYear == null || selectedYear == '') {
            selectedYear = 'All';
        } else {
            for(String y : selectedYear.split(',')) {
                dateParts.add('( CreatedDate <= '+y+'-12-31T23:59:59.000Z AND CreatedDate >= '+y+'-01-01T00:00:00.000Z)');
            }
            dString = ' and (' + STRING.join(dateParts, ' OR ')+' )';
        }

        return dString;
    }

  /*
	  params : None
	  return String with query
		Gets the query for batch execution of question migration
	*/
    public static String resolveQuestionMigrationQuery(String listOfCsvList) {
      	String q;

        String createdDateCondition = resolveDateFilter();
        List<String> cList = ca2cq_util.getCommunitiesToMigrate();
		ca2cq_config__c setupObj  =  getAppSettings();

        if (!cList.isEmpty()) {
            q = ' SELECT Id, CommunityId, Title,Body, CreatedDate,  CreatedById ,NumReplies, UpVotes, BestReplyId, '+
        				'BestReplySelectedById'+

				' FROM Question '+
                ' WHERE migrated_to_cq__c = FALSE '+
                ' AND CommunityId IN (\''+ String.join(cList,'\',\'')+'\')';

            if (!setupObj.Migrate_all_Questions__c && (String.isNotBlank(setupObj.Question_Ids__c) || String.isNotBlank(listOfCsvList))) {
                List<String> tmpIDs = new List<String>();

                if (String.isNotBlank(listOfCsvList)) {
                    tmpIDs = listOfCsvList.split(',');
                }

                if (setupObj.Exclude_this_Ids__c)
                    q += ' AND Id NOT IN (\''+ String.join(tmpIDs,'\',\'')+'\')';
                else
                    q += ' AND Id IN (\''+ String.join(tmpIDs,'\',\'')+'\')';
            }
        }

		return q + createdDateCondition;
	}

    /*
	  params : String with level
	  return None
		Updates the 'level' of a batch for log details
	*/
	public static void updateExecutingLevel(Integer newLevel){
		ca2cq_config__c setupObj  =  getAppSettings();
		setupObj.Current_Executing_Level__c = newLevel;
		update setupObj;
	}

    /*
      params : None
      return String with level
      Gets the current 'level' of a batch
    */
    public static String getSelectedYears(){

      ca2cq_config__c setupObj  =  getAppSettings();
      return  String.valueOf(setupObj.Selected_Years__c);
    }
    /*
	  params : None
	  return String with level
		Gets the current 'level' of a batch
	*/
	public static Integer getExecutingLevel(){
		ca2cq_config__c setupObj  =  getAppSettings();

		return  Integer.valueOf(setupObj.Current_Executing_Level__c);
	}

    /*
	  params : None
	  return Integer with batch size
		DEPRECATED. Returns the total size of each batch execution. Configuration now hidden on migration setup
	*/
	public static Integer getBatchSize(){
		Integer result = 100;
		ca2cq_config__c setupObj  =  getAppSettings();
		if (setupObj != null){
			result = Integer.valueOf(setupObj.Batch_size__c);
		}
		return  result;
	}


	public static Map<String, Integer > urltoFeedIndex = new Map<String, Integer >();
	public static Map<Integer, Id > indexToNetworkId = new Map<Integer, Id >();
	public static Map<Integer,Id > indexToallFeedItems = new Map<Integer,Id >();

    /*
	  params : List of Content Migration
	  return None
		Inserts content as contentDocument
	*/
	public static void processContent(List<Content_Migration__c> allContent){

		String dbug = 'processContent of ['+allContent.size()+'] elements ';
		for(Content_Migration__c t : allContent){
			dbug +='\n '+t.Content_Reference_Url__c+' feed'+t.Feed_Record_Id__c;
		}
		List<Id> feedItemsIds = new List<Id>();
		List<Id> feedCommentsIds = new List<Id>();
		Id itemId;
		Integer cntIndex = 0;
		for(Content_Migration__c cM : allContent){
			//classify Feeds by type
			itemId = cM.Feed_Record_Id__c;
			if (Schema.FeedItem.SObjectType == itemId.getSobjectType()){
				feedItemsIds.add(itemId);
			}else{
				feedCommentsIds.add(itemId);
			}



			urltoFeedIndex.put(cM.Content_Reference_Url__c,cntIndex);
            indexToNetworkId.put(cntIndex,cM.Network_Scope__c);
            indexToallFeedItems.put(cntIndex,itemId);
            cntIndex++;
		}

		dbug +='\n=== urltoFeedIndex:'+urltoFeedIndex.size();
		//process rta
		if (!urltoFeedIndex.isEmpty()){

			Map<Id,FeedItem> feedItemsToUpdate = new Map<Id,FeedItem>([Select Id, Body from FeedItem where id in:feedItemsIds ]);
			Map<Id,FeedComment> feedCommentsToUpdate = new Map<Id,FeedComment>([Select Id, CommentBody from FeedComment where id in:feedCommentsIds ]);

			Map<Integer,List<ContentVersion>> indexToContent = ca2cq_util.convertToContent (urltoFeedIndex,  indexToNetworkId);
			FeedItem feedQ;
			FeedComment feedC;
            dbug +='\n=================\n================\n';
			for(String cUrl : urltoFeedIndex.keySet()){

				dbug +='\n [cURL]:'+cUrl;

				Integer feedIndex = urltoFeedIndex.get(cUrl);

				List<ContentVersion> indexContents = indexToContent.get(feedIndex);
				if (indexToallFeedItems.containsKey(feedIndex)){
					//update FeedItem Body
					Id feedId = indexToallFeedItems.get(feedIndex);
					if (Schema.FeedItem.SObjectType== feedId.getSobjectType()){
						feedQ = feedItemsToUpdate.get(feedId);
							dbug +='\n[feedItem body]:\n'+feedQ.Body;
						for(ContentVersion newContent : indexContents){
							String newUrl =  'sfdc://'+newContent.ContentDocumentId;
							feedQ.Body = replaceNewImgUrl(feedQ.Body, newContent.pathOnClient, newUrl );
 							feedQ.Body = feedQ.Body.replaceAll('&quot;','"');
						}
						dbug +='\n [POST ]:'+feedQ.Body+'\n\n\n';
					}else{
						//update FeedComment Body
						feedC = feedCommentsToUpdate.get(feedId);
						dbug +='\n [feed comment body ]:'+feedC.CommentBody;
						for(ContentVersion newContent : indexContents){

							String newUrl =  'sfdc://'+newContent.ContentDocumentId;
							feedC.CommentBody = replaceNewImgUrl(feedC.CommentBody, newContent.pathOnClient, newUrl );
							feedC.CommentBody = feedC.CommentBody.replaceAll('&quot;','"');

						}

						dbug +='\n [POST ]:'+feedC.CommentBody;
					}
				}
			}
			ca2cq_log__c thisLog = ca2cq_logs.getCurrentLog ();
			list<String> logString = new list<String>();
			List<SObject> sourceData;
			Map<String,list<String>> postsResultsToProcess = new Map<String,list<String>> ();
			list<String> tmpList;
			if (!feedItemsToUpdate.isEmpty()){
				//upsert feedItemsToUpdate.values();
				Database.UpsertResult[] updateResults =  Database.upsert(feedItemsToUpdate.values(), false);
				sourceData = ((List<SObject>)feedItemsToUpdate.values());
				postsResultsToProcess = processDbUpsertResults(updateResults,sourceData);
				tmpList = postsResultsToProcess.get('Success');
				logString.add('Content Migration over Questions:' + '\n Success : '+ tmpList.size()+ ' of '+feedItemsToUpdate.size());
				tmpList = postsResultsToProcess.get('Errors');
				logString.add('\n Errors : '+ tmpList.size()+ ' of '+feedItemsToUpdate.size());
			}
			Map<String,list<String>> commentsResultsToProcess = new Map<String,list<String>>();
			if (!feedCommentsToUpdate.isEmpty()){
				//upsert feedCommentsToUpdate.values();
				Database.UpsertResult[] updateResults =  Database.upsert(feedCommentsToUpdate.values(), false);
				sourceData = ((List<SObject>)feedCommentsToUpdate.values());
				commentsResultsToProcess = processDbUpsertResults(updateResults,sourceData);
				//logString += 'Content Migration over Replies:'+processDbUpsertResults(updateResults,sourceData);
				tmpList = commentsResultsToProcess.get('Success');
				logString.add('Content Migration over Replies:' + '\n Success : '+ tmpList.size()+ ' of '+feedCommentsToUpdate.size());
				tmpList = commentsResultsToProcess.get('Errors');
				logString.add('\n Errors : '+ tmpList.size()+ ' of '+feedCommentsToUpdate.size());
			}

			ID nLogId;
            if(tmpList.size() > 0){
                nLogId = ca2cq_logs.newLogDetail(thisLog.Id,'Content migration', thisLog.Id, 'Content migration results', String.join(logString,'\n'), true );
            }
            else
            {
                nLogId = ca2cq_logs.newLogDetail(thisLog.Id,'Content migration', thisLog.Id, 'Content migration results', String.join(logString,'\n'), false );
            }


			//logs on success Questions content
			if (!postsResultsToProcess.isEmpty()){
				if (postsResultsToProcess.containsKey('Success'))
					ca2cq_logs.convertListToTxt(nLogId, 'FeedItemsWithContentUpdateOK', postsResultsToProcess.get('Success'));
				if (postsResultsToProcess.containsKey('Errors'))
					ca2cq_logs.convertListToTxt(nLogId, 'FeedItemsWithContentUpdateError', postsResultsToProcess.get('Errors'));
			}
			//logs on success Questions content
			if (!commentsResultsToProcess.isEmpty()){
				if (commentsResultsToProcess.containsKey('Success'))
					ca2cq_logs.convertListToTxt(nLogId, 'FeedCommentsWithContentUpdateOK', commentsResultsToProcess.get('Success'));
				if (commentsResultsToProcess.containsKey('Errors'))
					ca2cq_logs.convertListToTxt(nLogId, 'FeedCommentsWithContentUpdateError', commentsResultsToProcess.get('Errors'));
			}
		}
		ca2cq_logs.logIt(' Content migration: '+dbug);
	}

    /*
	  params : List of UpserResults, List of Objects
	  return Map with a Json
		Creates a JSON with details of a migration
	*/
	public static Map<String,list<String>> processDbUpsertResults(Database.UpsertResult[] results,List<SObject> sourceData){
		Map<String,list<String>> result = new Map<String,list<String>>();
		list<String> ls_succes = new list<String>();
		list<String> ls_error = new list<String>();
		Integer index=0;
		Map<String,Object> record ;
		for (Database.UpsertResult res : results) {
			if (res.isSuccess()) {
				if (!res.isCreated()) {
					ls_succes.add(res.getId() );
				}
			}
			else {
				record = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sourceData.get(index)));

				if (res.getErrors().size() > 0) {
					String errorId = String.valueOf(record.get('Id'));
					ls_error.add(errorId+ ' reason: '+res.getErrors()[0].getMessage() );
				}
			}
			index++;
		}


		result.put('Success',ls_succes);
		result.put('Errors',ls_error);
		return result;
	}

    /*
	  params : Job id
	  return String with step
		Gets the current step of an apex job
	*/
	public static String getJobStep(String asyncJobId){
		String result = '';
		List<AsyncApexJob> a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
								TotalJobItems, CreatedBy.Email
								FROM AsyncApexJob
								WHERE Id =:asyncJobId];
		if (!a.isEmpty()){
			result = ( a.get(0).JobItemsProcessed + 1 ) +' of '+a.get(0).TotalJobItems + ' - ';
		}

		return result;
	}

    /*
	  params : List of Question
	  return Map with Id of Question and the QuestionReportAbuse object
		Given a list of Question, it returns all the flagged ones
	*/
    public static Map<Id, QuestionReportAbuse> getFlaggedQuestions(List<Question> allQuestions) {
        Map<Id, QuestionReportAbuse> flaggedQuestions = new Map<Id, QuestionReportAbuse>();
        List<Id> questionsIds = new List<Id>();

        for (Question q : allQuestions) {
                questionsIds.add(q.Id);
        }

        List<QuestionReportAbuse> reportedQuestions = [SELECT Name, Reason, QuestionId
                                                       FROM QuestionReportAbuse
                                                       WHERE QuestionId IN : questionsIds];

        for (QuestionReportAbuse qrA : reportedQuestions) {
            flaggedQuestions.put(qrA.QuestionId, qrA);
        }

        return flaggedQuestions;
    }

    /*
	  params : List of Reply
	  return Map with Id of Reply and the ReplyReportAbuse object
		Given a list of Reply, it returns all the flagged ones
	*/
    public static Map<Id, ReplyReportAbuse> getFlaggedReplies(List<Reply> allReplies) {
        Map<Id, ReplyReportAbuse> flaggedReplies = new Map<Id, ReplyReportAbuse>();
        List<Id> repliesIds = new List<Id>();

        for (Reply r : allReplies) {
                repliesIds.add(r.Id);
        }

        List<ReplyReportAbuse> reportedReplies = [SELECT Name, Reason, ReplyId
                                                  FROM ReplyReportAbuse
                                                  WHERE ReplyId IN : repliesIds];

        for (ReplyReportAbuse rrA : reportedReplies) {
            flaggedReplies.put(rrA.ReplyId, rrA);
        }

        return flaggedReplies;
    }

    /*
	  params : Map of Question to its FeedItem, Map of QuestionId to QuestionReportAbuse
	  return List of NetworkModeration
		For each Flagged Question it returns a NetworkModeration object to be inserted
	*/
    public static List<NetworkModeration> setFlaggedFeedItems(Map<Id, FeedItem> questionToFeedItem, Map<Id, QuestionReportAbuse> flaggedQuestions) {
        List<NetworkModeration> allNM = new List<NetworkModeration>();

        for (Id questionKey : questionToFeedItem.keySet()) {
            if (flaggedQuestions.containsKey(questionKey)) {
                FeedItem fi = questionToFeedItem.get(questionKey);
                //QuestionReportAbuse qrA= flaggedQuestions.get(questionKey);

                if (fi.NetworkScope != NULL) {
                    NetworkModeration nm = new NetworkModeration(EntityId = fi.Id, NetworkId = fi.NetworkScope);

                    allNM.add(nm);
                }
            }
        }

        return allNM;
    }

    /*
	  params : Map of Reply to its FeedComment, Map of ReplyId to ReplyReportAbuse
	  return List of NetworkModeration
		For each Flagged Reply it returns a NetworkModeration object to be inserted
	*/
    public static List<NetworkModeration> setFlaggedFeedComments(Map<Id, FeedComment> replyToFeedComment, Map<Id, ReplyReportAbuse> flaggedReplies, List<FeedItem> successfulFeedItems) {
        List<NetworkModeration> allNM = new List<NetworkModeration>();

        Map<Id, FeedItem> allFeedItems = new Map<Id, FeedItem>();

        for (FeedItem fi : successfulFeedItems) {
            allFeedItems.put(fi.Id, fi);
        }

        for (Id replyKey : replyToFeedComment.keySet()) {
            if (flaggedReplies.containsKey(replyKey)) {
                FeedComment fc = replyToFeedComment.get(replyKey);
                FeedItem fi = allFeedItems.get(fc.FeedItemId);
                //ReplyReportAbuse rrA= flaggedReplies.get(replyKey);

                if (fi.NetworkScope != NULL) {
                    NetworkModeration nm = new NetworkModeration(EntityId = fc.Id, NetworkId = fi.NetworkScope);

                    allNM.add(nm);
                }
            }
        }

        return allNM;
    }

    public static List<String> availableYears(){
      Datetime min = [SELECT CreatedDate FROM Question ORDER BY CreatedDate ASC NULLS FIRST LIMIT 1].CreatedDate;
      Datetime max = [SELECT CreatedDate FROM Question ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1].CreatedDate;


      Integer minYear = min.Year();
      Integer maxYear = max.Year();
      List<String> res = new List<String>();
      res.add('All');
      for(Integer j = min.Year();  j <= max.Year();j++)
        res.add(String.valueOf(j));

      return res;
    }

 public static String replaceNewImgUrl(String baseBody, String originalURL, String replacmntURL ){

    String result =baseBody;

    String dbg ='';

    String openTAG = '_img_';
    String closeTAG = '_/_img_';


    Integer i1 = baseBody.lastIndexOf(originalURL);
    Integer openTagIndex = baseBody.lastIndexOf(openTAG,i1);
    Integer closeTagIndex = baseBody.indexOf(closeTAG,i1);

    dbg += '\n ORIGINAL:\n'+baseBody+
             '\n replacmntURL:\n'+replacmntURL+
             '\n originalURL:\n'+originalURL+
             '\n i1:\n'+i1+
             '\n openTagIndex:\n'+openTagIndex+
             '\n closeTagIndex:\n'+closeTagIndex;

    if (openTagIndex > -1 && openTagIndex > -1 && closeTagIndex > -1) {
        closeTagIndex = closeTagIndex + closeTAG.length();
        String baseToReplace = baseBody.substring(openTagIndex, closeTagIndex);
        String updateToReplace = baseToReplace.replace(originalURL, replacmntURL);

        updateToReplace = updateToReplace.replace( closeTAG,'></img>');
        updateToReplace = updateToReplace.replace( openTAG,'<img');

        result = baseBody.replace(baseToReplace, updateToReplace);

    }

        return result;
    }



}