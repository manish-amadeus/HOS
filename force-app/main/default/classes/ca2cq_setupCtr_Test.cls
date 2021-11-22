@isTest
private class  ca2cq_setupCtr_Test {

	static void populateSettings(){
		ca2cq_config__c obj = ca2cq_util.getAppSettings();
		obj.Notification_email__c = 'SOMe@test.org';
		upsert obj;

		Map<Id,Community> comm =  ca2cq_util.allCommunities();
		list<ca2cq_Zone_community__c> lista =  ca2cq_util.getAppCommunityMappings();
		for(ca2cq_Zone_community__c c : lista){
			c.Active_for_Migration__c = true;
			ID tmp = c.zoneId__c;
			if (comm.containsKey(tmp)){
				c.Community_Id__c = comm.get(tmp).NetworkId;
				if (!String.isNotBlank(c.Community_Id__c)){
					c.Community_Id__c = 'null';
				}
			}
		}
		upsert lista;

        //map dc to topics
        List<ca2cq_categories_To_Topic__c> dc2t = new List<ca2cq_categories_To_Topic__c>();
        for(Integer h = 0; h<3 ; h++){
           dc2t.add(new ca2cq_categories_To_Topic__c(
                            Name = 'dc_t_'+h,
                            DataCategoryName__c = 'dc_'+h,
                            TopicName__c = 't_'+h
           ));
        }
		insert dc2t;
	}

	static testMethod void test_ca2cq_setupCtr(){

		populateSettings();

		ca2cq_setupCtr ctr = new ca2cq_setupCtr();
		System.assertNotEquals(ctr.setupObj, null);
		System.assertNotEquals(ctr.setupObj.Notification_email__c, 'SOMe@test.org');

		System.assertNotEquals(ca2cq_setupCtr.allCommunities, null);
		System.assertNotEquals(ca2cq_setupCtr.allNetworkList, null);
		System.assertNotEquals(ca2cq_setupCtr.lastLog, null);

		System.assertNotEquals(ctr.zonesMap, null);

		System.assertEquals(ctr.getCanStartProcess(), true);
		System.assertEquals(ctr.getIsProcessRunning(), false);
		System.assertNotEquals('XXX',ca2cq_setupCtr.questionIDPrefix);

	}

	@isTest(SeeAllData=true)
	static  void test_save(){

		populateSettings();

		System.Test.startTest();


		PageReference pageRef = Page.ca2cq_setup;
		// populate mapd from Zone to Community
		String allC ='';
		for (Community c : [SELECT Id FROM Community  ]){
			allC +=','+c.Id+':'+c.Id+':1';
		}
		pageRef.getParameters().put('zonesMap',allC);

		// populate mapd from DataCategory to Topic
		String dcTop ='';
        for(Integer h = 0; h<5 ; h++){
            dcTop +=',dc'+h+':topic'+h;
        }
		pageRef.getParameters().put('topicsMaps',dcTop);

		pageRef.getParameters().put('allowNullList','true');
		pageRef.getParameters().put('questionIdListFromCsv','');
		pageRef.getParameters().put('whichQuestions','includeAll');


        System.Test.setCurrentPage(pageRef);



		ca2cq_setupCtr ctr = new ca2cq_setupCtr();
		ctr.setupObj.Batch_size__c = 53;
		ctr.save();
	    System.Test.stopTest();




		system.assertEquals(53,ca2cq_util.getBatchSize());

	}


	@isTest(SeeAllData=true)
	static  void test_save_questionId(){

			populateSettings();
			System.Test.startTest();

			//add ids to include
			List<Question> qL = [Select Id,CommunityId from Question ORDER BY Id limit 2];

			if (qL.size() > 0) {
					List<String> idL = new List<String>();
					List<Id> selZones = new List<Id>();
					for(Question q : qL){
						idL.add(q.Id);
						selZones.add(q.CommunityId);
					}
					Set<String> setIdL = new Set<String>(idL);

					String idString = String.join(idL,',');
                	String zonesString ='';
					for(String zId : selZones){
						zonesString+=zId+':null:1,';
					}
                	System.debug('idString:' + idString);

					PageReference pageRef = Page.ca2cq_setup;

					pageRef.getParameters().put('zonesMap',zonesString);
					pageRef.getParameters().put('allowNullList','false');

					system.debug('\n zonesString: '+zonesString);
					pageRef.getParameters().put('questionIdList','');
					pageRef.getParameters().put('whichQuestions','includeThis');
					System.Test.setCurrentPage(pageRef);

					ca2cq_setupCtr ctr = new ca2cq_setupCtr();
					ctr.save();

					System.Test.stopTest();



			}
	}

	static testMethod void test_launchBatch_noSetup(){

		 System.Test.startTest();

		ca2cq_setupCtr ctr = new ca2cq_setupCtr();
		ctr.launchBatch();
		System.assertEquals(ctr.getCanStartProcess(), false);
		System.assertEquals(ctr.getIsProcessRunning(), false);

		System.Test.stopTest();
	}

	static testMethod void test_launchBatch (){
		populateSettings();

		System.Test.startTest();

		ca2cq_setupCtr ctr = new ca2cq_setupCtr();
		ctr.launchBatch();

		System.assertEquals(ctr.getCanStartProcess(), false);
		System.assertEquals(ctr.getIsProcessRunning(), true);

		System.Test.stopTest();
	}

}