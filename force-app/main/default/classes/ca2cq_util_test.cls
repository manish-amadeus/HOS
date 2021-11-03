@isTest
private class ca2cq_util_test {

	static testmethod void test_convertBody() {
		Map<String,String> originalBodyToConvertedBody = new Map<String,String>();

		originalBodyToConvertedBody.put('<br>','<p>&nbsp</p>');
		originalBodyToConvertedBody.put('<br/>','<p>&nbsp</p>');
		originalBodyToConvertedBody.put('<br />','<p>&nbsp</p>');
		originalBodyToConvertedBody.put('<b> bold </b>','<b> bold </b>');
		originalBodyToConvertedBody.put('<i> italics </i>','<i> italics </i>');
		originalBodyToConvertedBody.put('<u> underline </u>','<u> underline </u>');
		originalBodyToConvertedBody.put('<strike> strike </strike>','<s> strike </s>');
		originalBodyToConvertedBody.put('<pre class="ckeditor_codeblock"> code snippet </pre>','<code> code snippet </code>');
		originalBodyToConvertedBody.put('<div style="margin-left:test> divtest </div>',' divtest ');
		originalBodyToConvertedBody.put('other link (<a href="http://www.google.com.uy" target="_blank">a link2</a>)','other link (http://www.google.com.uy) a link2 ');
		originalBodyToConvertedBody.put('<img alt="User-added image" src="https://test-image.com"></img>','https://test-image.com ');
		originalBodyToConvertedBody.put('<div style="text-align: left;">align left</div>','align left');
		originalBodyToConvertedBody.put('<div style="text-align: right;">align right</div>','align right');
		originalBodyToConvertedBody.put('<h5>h5</h5>','h5 ');
		originalBodyToConvertedBody.put('<span>span</span>',' span ');
		originalBodyToConvertedBody.put('<strong>strong</strong>','strong ');

        // Test first kind of mail tag
        originalBodyToConvertedBody.put('test2@test2.test (<a href="mailto:test2@test2.test?subject=simple%20subject&amp;body=simple%20body%20text" target="_blank"><span> test 1</span></a>)','test2@test2.test (To: test2@test2.test - Subject: simple subject - Body: simple body text)   test 1 ');
		originalBodyToConvertedBody.put('test2@test2.test (<a href="mailto:test2@test2.test"subject=simple%20subject&amp;body=simple%20body%20text" target="_blank"><span> test 2</span></a>)','test2@test2.test (To: test2@test2.test - Subject: simple subject - Body: simple body text)   test 2 ');
        originalBodyToConvertedBody.put('test2@test2.test (<a href="mailto:test2@test2.test" target="_blank"><span> test 3</span></a>)','test2@test2.test (To: test2@test2.test)   test 3 ');
        originalBodyToConvertedBody.put('test2@test2.test (<a href="mailto:test2@test2.test" target="_blank"><span> test 4</span></a>)','test2@test2.test (To: test2@test2.test)   test 4 ');
		originalBodyToConvertedBody.put('test2@test2.test (<a href="mailto:test2@test2.test?subject=simple%20subject&amp;body=simple%20body%20text" target="_blank">mailto:test2@test2.test?subject=simple%20subject&amp;body=simple%20body%20text</a>)','test2@test2.test (To: test2@test2.test - Subject: simple subject - Body: simple body text) ');
		originalBodyToConvertedBody.put('test2@test2.test (<a href="mailto:test2@test2.test"subject=simple%20subject&amp;body=simple%20body%20text" target="_blank">mail</a>)','test2@test2.test (To: test2@test2.test - Subject: simple subject - Body: simple body text) ');
        originalBodyToConvertedBody.put('test2@test2.test (<a href="mailto:test2@test2.test" target="_blank">test2@test2.test</a>)','test2@test2.test (test2@test2.test) ');
        originalBodyToConvertedBody.put('test2@test2.test (<a href="mailto:test2@test2.test" target="_blank">mail 2</a>)','test2@test2.test (To: test2@test2.test) mail 2');

        // Test second kind of mail tag with ()
        originalBodyToConvertedBody.put('test2@test2.test <a href="mailto:test2@test2.test?subject=simple%20subject&amp;body=simple%20body%20text" target="_blank"><span> test 1</span></a>','test2@test2.test (To: test2@test2.test - Subject: simple subject - Body: simple body text)   test 1 ');
		originalBodyToConvertedBody.put('test2@test2.test <a href="mailto:test2@test2.test"subject=simple%20subject&amp;body=simple%20body%20text" target="_blank"><span> test 2</span></a>','test2@test2.test (To: test2@test2.test - Subject: simple subject - Body: simple body text)   test 2 ');
        originalBodyToConvertedBody.put('test2@test2.test <a href="mailto:test2@test2.test" target="_blank"><span> test 3</span></a>','test2@test2.test (To: test2@test2.test)   test 3 ');
        originalBodyToConvertedBody.put('test2@test2.test <a href="mailto:test2@test2.test" target="_blank"><span> test 4</span></a>','test2@test2.test (To: test2@test2.test)   test 4 ');
       	originalBodyToConvertedBody.put('test2@test2.test <a href="mailto:test2@test2.test?subject=simple%20subject&amp;body=simple%20body%20text" target="_blank">mailto:test2@test2.test?subject=simple%20subject&amp;body=simple%20body%20text</a>','test2@test2.test (To: test2@test2.test - Subject: simple subject - Body: simple body text) ');
		originalBodyToConvertedBody.put('test2@test2.test <a href="mailto:test2@test2.test"subject=simple%20subject&amp;body=simple%20body%20text" target="_blank">mail</a>','test2@test2.test (To: test2@test2.test - Subject: simple subject - Body: simple body text) ');
        originalBodyToConvertedBody.put('test2@test2.test <a href="mailto:test2@test2.test" target="_blank">test2@test2.test</a>','test2@test2.test (test2@test2.test) ');
        originalBodyToConvertedBody.put('test2@test2.test <a href="mailto:test2@test2.test" target="_blank">mail 2</a>','test2@test2.test (To: test2@test2.test) mail 2');

        // Test news tag
        originalBodyToConvertedBody.put('<a href="" target="_blank">news://newnews.com</a>','news://newnews.com ');
		originalBodyToConvertedBody.put('(<a href="" target="_blank">news://newnews.com</a>)','news://newnews.com ');

        // Test commoun url tags
        originalBodyToConvertedBody.put('<a href="http://www.google.com.uy" target="_blank">a link1</a>','(http://www.google.com.uy) a link1 ');
        originalBodyToConvertedBody.put('(<a href="http://www.google.com.uy" target="_blank">a link2</a>)','(http://www.google.com.uy) a link2 ');
		originalBodyToConvertedBody.put('<a href="http://www.google1.com.uy" target="_blank">http://www.google1.com.uy</a>','http://www.google1.com.uy');
        originalBodyToConvertedBody.put('(<a href="http://www.google2.com.uy" target="_blank">http://www.google2.com.uy</a>)','(http://www.google2.com.uy) ');
		originalBodyToConvertedBody.put('<a target="_blank">http://www.google3.com.uy</a>','http://www.google3.com.uy ');
        originalBodyToConvertedBody.put('(<a target="_blank">http://www.google4.com.uy</a>)','http://www.google4.com.uy ');

        // Test table tags
        originalBodyToConvertedBody.put('<table><tbody><tr><td>Row</td></tr></tbody></table>','    Row    ');

        // Test imgs tags
		originalBodyToConvertedBody.put('<img height="231" alt="Billing query" src="http://check.content.force.com/servlet/rtaImage?eid=90750000000CcQZ&amp;feoid=Body&amp;refid=0EM50000000H2V9" width="500"></img>','_img_  alt="Billing query" src="http://check.content.force.com/servlet/rtaImage?eid=90750000000CcQZ&amp;feoid=Body&amp;refid=0EM50000000H2V9" _/_img_');
		originalBodyToConvertedBody.put('<img alt="Billing query" height="231" src="http://check.content.force.com/servlet/rtaImage?eid=90750000000CcQZ&amp;feoid=Body&amp;refid=0EM50000000H2V9" width="500"></img>','_img_ alt="Billing query"  src="http://check.content.force.com/servlet/rtaImage?eid=90750000000CcQZ&amp;feoid=Body&amp;refid=0EM50000000H2V9" _/_img_');
		originalBodyToConvertedBody.put('<img alt="Billing query" style="height: 328px; width: 500px;" src="http://check.content.force.com/servlet/rtaImage?eid=90750000000CcQZ&amp;feoid=Body&amp;refid=0EM50000000H2V9" ></img>','_img_ alt="Billing query"  src="http://check.content.force.com/servlet/rtaImage?eid=90750000000CcQZ&amp;feoid=Body&amp;refid=0EM50000000H2V9" _/_img_');
		originalBodyToConvertedBody.put('<img alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w3V&amp;feoid=Body&amp;refid=0EMB0000000Fl90"></img><img alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w3V&amp;feoid=Body&amp;refid=0EMB0000000Fl90"></img>', '_img_ alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w3V&amp;feoid=Body&amp;refid=0EMB0000000Fl90"_/_img__img_ alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w3V&amp;feoid=Body&amp;refid=0EMB0000000Fl90"_/_img_');
		originalBodyToConvertedBody.put('<img alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w3V&amp;feoid=Body&amp;refid=0EMB0000000Fl90"></img><img alt="User-added image" src="www.justanimage.com"></img><img alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w3V&amp;feoid=Body&amp;refid=0EMB0000000Fl90"></img>', '_img_ alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w3V&amp;feoid=Body&amp;refid=0EMB0000000Fl90"_/_img_www.justanimage.com _img_ alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w3V&amp;feoid=Body&amp;refid=0EMB0000000Fl90"_/_img_');
		originalBodyToConvertedBody.put('Text1 <img alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w9s&amp;feoid=Body&amp;refid=0EMB0000000FlEA" height="200px" width="100px"></img> Text2 <img alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w9s&amp;feoid=Body&amp;refid=0EMB0000000FlEA" height="200px" width="100px"></img>', 'Text1 _img_ alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w9s&amp;feoid=Body&amp;refid=0EMB0000000FlEA"  _/_img_ Text2 _img_ alt="User-added image" src="https://c.gus.content.force.com/servlet/rtaImage?eid=906B00000003w9s&amp;feoid=Body&amp;refid=0EMB0000000FlEA"  _/_img_');

        // Delete class attributes
        originalBodyToConvertedBody.put('<p class="MsoNormal">Test paragraph 1</p>', '<p>Test paragraph 1</p>');
		originalBodyToConvertedBody.put('<p style="MsoNormal">Test paragraph 2</p>', '<p>Test paragraph 2</p>');
		originalBodyToConvertedBody.put('<font color="#2b91af" face="Consolas" size="2">OverwriteModeEnum</font>',' OverwriteModeEnum ');
		originalBodyToConvertedBody.put('<em style="color: rgb(100, 99, 99); font-family: Arial, Helvetica, sans-serif; font-size: 11px; background-color: rgb(245, 247, 251);">Search Name</em>',' Search Name ');
		originalBodyToConvertedBody.put('<br style="color: rgb(100, 99, 99); font-family: Arial, Helvetica, sans-serif; font-size: 11px; background-color: rgb(245, 247, 251);">','<p>&nbsp</p>');

		//lists
		originalBodyToConvertedBody.put('<ol><li>a i in ol</li></ol>','<ol><li>a i in ol</li></ol>');
		originalBodyToConvertedBody.put('<ul><li>a i in ul</li></ul>','<ul><li>a i in ul</li></ul>');
		originalBodyToConvertedBody.put('<ul><li><span>span</span></li></ul>','<ul><li> span </li></ul>');


		originalBodyToConvertedBody.put('<thead></thead>','  ');
		originalBodyToConvertedBody.put('<tfoot></tfoot>','  ');
		originalBodyToConvertedBody.put('<th></th>','  ');
		originalBodyToConvertedBody.put('<col></col>','  ');
		originalBodyToConvertedBody.put('<tgroup></tgroup>','  ');
		originalBodyToConvertedBody.put('<caption></caption>','  ');
		originalBodyToConvertedBody.put('<dl><dt><dd></dd></dt></dl>','');
		originalBodyToConvertedBody.put('<pre><br></pre>','<code></code>');
		originalBodyToConvertedBody.put('<abbr></abbr>','  ');
		originalBodyToConvertedBody.put('<acronym></acronym>','  ');
		originalBodyToConvertedBody.put('<address></address>','');
		originalBodyToConvertedBody.put('<b><br></b>','<b> </b>');
		originalBodyToConvertedBody.put('<big></big>','');
		originalBodyToConvertedBody.put('<blockquote></blockquote>','');
		originalBodyToConvertedBody.put('<cite></cite>','  ');
		originalBodyToConvertedBody.put('<dfn></dfn>','');
		originalBodyToConvertedBody.put('<ins></ins>' ,'');
		originalBodyToConvertedBody.put('<kbd></kbd>', '  ');
		originalBodyToConvertedBody.put('<p><br></p>','<p> </p>');
		originalBodyToConvertedBody.put('<samp></samp>','');
		originalBodyToConvertedBody.put('<small></small>','');
		originalBodyToConvertedBody.put('<sup></sup>' , '  ' );
		originalBodyToConvertedBody.put('<tt></tt>','  ');
		originalBodyToConvertedBody.put('title=""','');
		originalBodyToConvertedBody.put('<var></var>','  ');
		originalBodyToConvertedBody.put('align="algo"','');
		originalBodyToConvertedBody.put('border="algo"','');
		originalBodyToConvertedBody.put('class=""','');
		originalBodyToConvertedBody.put('dir=""', '');
		originalBodyToConvertedBody.put('id=""', '');
		originalBodyToConvertedBody.put('start=""', '');
		originalBodyToConvertedBody.put('(<a href="http://www.google.com"> </a>', '(http://www.google.com)');


		originalBodyToConvertedBody.put('<code><code><code></code></code></code>','<code>&lt;code&gt;&lt;code&gt;</code>&lt;/code&gt;&lt;/code&gt;');
		originalBodyToConvertedBody.put('<code>A</code>B<code>C</code>','<code>A</code>B<code>C</code>');
		originalBodyToConvertedBody.put('<code></code><code>&lt;code&gt;Something Else</code>Something More</code>','<code></code><code>&lt;code&gt;Something Else</code>Something More&lt;/code&gt;');
		//test to code tag - keep only the first open code tag and the last code tag closed and process too the &lt;code&gt; literal code tag too
		originalBodyToConvertedBody.put('<code>&lt;code&gt;Something Else</code>Something More</code>','<code>&lt;code&gt;Something Else</code>Something More&lt;/code&gt;');

		System.Test.startTest();
		System.assertNotEquals(ca2cq_util.convertToContent(new Map<String,Integer>(),new Map<Integer,Id>()),null);

		ca2cq_util.processContent(new List<Content_Migration__c>());
		System.assertNotEquals(ca2cq_util.getFlaggedQuestions(new List<Question>()),null);
		System.assertNotEquals(ca2cq_util.getAppSettings(),null);
		System.assertNotEquals(ca2cq_util.getCommunitiesToMigrate(),null);
		System.assertNotEquals(ca2cq_util.getCommunitiesPointRules(),null);
		System.assertNotEquals(ca2cq_util.getUsersPerCommunity(),null);
		System.assertNotEquals(ca2cq_util.getUserPointsPerCommunity(),null);
		System.assertNotEquals(ca2cq_util.chatterZoneToNetwork(),null);
		System.assertNotEquals(ca2cq_util.getDCToToppicsMap(),null);
		System.assertNotEquals(ca2cq_util.getDCToToppics(),null);
		System.assertNotEquals(ca2cq_util.getAppCommunityMappings(),null);
		System.assertNotEquals(ca2cq_util.allCommunities(),null);
		System.assertNotEquals(ca2cq_util.allNetworkList(),null);
		System.assertNotEquals(ca2cq_util.allTopics(),null);
 		ca2cq_util.createNavigationalTopics(new List<Topic>());
	  ca2cq_util.insertQuestionsToMigrate(new Map<String, FeedComment>());
		System.assertNotEquals(ca2cq_util.getExecutingLevel(),null);
		System.assertNotEquals(ca2cq_util.getBatchSize(),null);
		System.assertNotEquals(ca2cq_util.getJobStep(''),null);
		System.assertNotEquals(ca2cq_util.allTopics(),null);
		System.assertNotEquals(ca2cq_util.allTopics(),null);
		System.assertNotEquals(ca2cq_util.getFlaggedReplies(new List<Reply>()),null);




		String result;
		for(String originalB : originalBodyToConvertedBody.keySet()){
			result = ca2cq_util.convertBody(originalB, '11111111');
			System.assertEquals(originalBodyToConvertedBody.get(originalB).trim(), result.trim(),'Failed to convert -['+originalB+']');
		}


		System.Test.stopTest();
	}

    public static testmethod  void testDatabseupsert(){
        // Populate test Data
        List<FeedItem> itemsToUpdate = new List<FeedItem>();
        List<SObject> sourceData;

        List<User> u =[SELECT Id From User WHERE IsActive = TRUE LIMIT 1];
        FeedItem fi = new FeedItem (Body = 'Test post body 1', Title= 'Test post title 1', CreatedById = u.get(0).Id, ParentId = u.get(0).Id);
        itemsToUpdate.add(fi);
        FeedItem fi2 = new FeedItem (Body = 'Test post body 2', Title= 'Test post title 2', CreatedById = u.get(0).Id);
        itemsToUpdate.add(fi2);

        Database.UpsertResult[] updateResults =  Database.upsert(itemsToUpdate, false);
        sourceData = ((List<SObject>)itemsToUpdate);

        Map<String,list<String>> result = ca2cq_util.processDbUpsertResults(updateResults,sourceData);
		list<String> tmpList = result.get('Success');

        System.assertEquals(0, tmpList.size());
    }

	public static testmethod void testConvertHashtagThatCouldBeTopic()
	{
		System.assertEquals('# holamundo', ca2cq_util.convertHashtagThatCouldBeTopic('#holamundo'));

		System.assertEquals('&#243;', ca2cq_util.convertHashtagThatCouldBeTopic('&#243;'));

		System.assertEquals('# 192', ca2cq_util.convertHashtagThatCouldBeTopic('#192'));
	}

		public static testmethod  void testProcessContent(){
			// Populate stats
			Map<String, Integer > urltoFeedIndex = new Map<String, Integer >();
			Map<Integer,Id > indexToallFeedItems = new Map<Integer,Id >();

			List<User> u =[SELECT Id From User WHERE IsActive = TRUE LIMIT 1];
		  FeedItem fi = new FeedItem (Body = '<img alt="User-added image" src="https://cdn.pixabay.com/photo/2016/03/28/12/35/cat-1285634_960_720.jpg"></img>  <p> </p> <img alt="User-added image" src="https://cdn.pixabay.com/photo/2017/02/01/22/02/mountain-landscape-2031539_960_720.jpg"></img> <p> </p>  <img alt="User-added image" src="https://cdn.pixabay.com/photo/2014/07/18/20/36/sunset-396633_960_720.jpg"></img> <p> </p> <img alt="User-added image" src="https://cdn.pixabay.com/photo/2013/10/09/02/27/bank-192991_960_720.jpg"></img>', Title= 'Test post title 1', CreatedById = u.get(0).Id, ParentId = u.get(0).Id);

			System.Debug('Body sin procesar quedo como : ' + fi.Body);
			fi.Body = fi.Body.replaceAll('<img','_img_');
		  fi.Body = fi.Body.replaceAll('></img>','_/_img_');
		  fi.Body = fi.Body.replaceAll('"','&quot;');

			Map<String,Integer> urlsToIndex = new Map<String,Integer>{
				'https://cdn.pixabay.com/photo/2016/03/28/12/35/cat-1285634_960_720.jpg' => 0,
				'https://cdn.pixabay.com/photo/2017/02/01/22/02/mountain-landscape-2031539_960_720.jpg' => 1,
				'https://cdn.pixabay.com/photo/2014/07/18/20/36/sunset-396633_960_720.jpg' => 2,
				'https://cdn.pixabay.com/photo/2013/10/09/02/27/bank-192991_960_720.jpg' => 3
			};

			Map<Integer, Id > indexToNetworkId = new Map<Integer, Id >();
			List<Network> netList = [SELECT Id  FROM Network Limit 1];

			indexToNetworkId.put(0,netList[0].Id);
			indexToNetworkId.put(1,netList[0].Id);
			indexToNetworkId.put(2,netList[0].Id);
			indexToNetworkId.put(3,netList[0].Id);

			Map<Integer,List<ContentVersion>> contentConverted = ca2cq_util.convertToContent( urlsToIndex, indexToNetworkId);
			System.Debug('[0][0] Body inicial : ' + fi.Body);
			for(Integer idcv : contentConverted.keySet()){
				 List<ContentVersion> actualList = contentConverted.get(idcv);
				 Integer integ = 0;
				 System.debug('enter to content converted idcv : '+ idcv);
				 for(ContentVersion cver : actualList)
				 {
								String newUrl =  'sfdc://'+cver.ContentDocumentId;
								fi.Body = ca2cq_util.replaceNewImgUrl(fi.Body, cver.pathOnClient, newUrl );
				 }
			}
			fi.Body = fi.Body.replaceAll('&quot;','"');
			// if have 5 aparitions of sfdc url must have 5 aparitions int he body of <img tag opening
      		System.assertEquals(true,(countOcurrencesOfSubString(fi.Body,'sfdc') == countOcurrencesOfSubString(fi.Body,'<img')));
	  		fi.Body = fi.Body.replaceAll('_/_img_','</img>');
	  		fi.Body = fi.Body.replaceAll('_img_','<img>');
	  		// if doesnt have any _img_ must not have any rtaImage too
			System.assertEquals(true,(!fi.Body.contains('_img_') && !fi.Body.contains('rtaImage')));

		}
		public static Integer countOcurrencesOfSubString(String str ,String substr )
		{
				Integer substrLen = substr.length();
				Integer count = 0;
				Integer index = str.indexOf(substr);
				while (index >= 0) {
				    count++;
				    str = str.substring(index+substrLen);
				    index = str.indexOf(substr);
				}
				return count;

		}

}