({
    createUserStory : function(recId,component,rallyURL,apiVersion,workspaceName) 
    {
        
        var commentsPresent = false;
        var attachPresent = false;
        var callServer = component.get("c.returnComments");
        var msgs = component.find("msgs");
        var createUserStory = component.get("c.resultofUserStory");
        
        callServer.setParams({
            "caseId" : recId
        });
        
        createUserStory.setParams({
            "caseId" : recId
        });
        
        createUserStory.setCallback(this, function(response1) {
            
            if (response1.getState() === "SUCCESS")
            {                
                var resultOfUserStory = response1.getReturnValue();
                console.log("response of create user story is below");
                console.log(resultOfUserStory);                
                if (resultOfUserStory == "error in class")
                {
                    //alert("Error in Mapping of Product Family with Project ask system admin to configure or there might be error in Rally Story Field");
                    msgs.throwError('ERROR', 'error', 'Error in Mapping of Product Family with Project ask system admin to configure or there might be error in Rally Story Field');
                    return;
                }
                else
                {
                    callServer.setCallback(this, function(cResponse){
                        if (cResponse.getState() === "SUCCESS")
                        {
                            var res = cResponse.getReturnValue();
                            var callDiscussion = false;
                            console.log("Stringify res for comments "+ JSON.stringify(res));  
                            if (res.length > 0)
                            {
                                for (var i = 0; i < res.length; i++)
                                {
                                    console.log(i + ". comment id " + res[i]);
                                    if(i == (res.length - 1 ))
                                    {
                                        callDiscussion = true;
                                    }
                                    commentsPresent = true;
                                    this.sendComment(component,resultOfUserStory,rallyURL,apiVersion,recId,res[i],workspaceName,callDiscussion);								
                                }
                            }
                            else
                            {
                                var callServerForAttachments = component.get("c.returnAttachments");
                                callServerForAttachments.setParams({
                                    "caseId" : recId
                                });
                                callServerForAttachments.setCallback(this, function(aResponse){
                                    if(aResponse.getState() === "SUCCESS")
                                    {
                                        var res = aResponse.getReturnValue();
                                        console.log("Stringify res for attachments "+ JSON.stringify(res));
                                        for(var i = 0; i < res.length; i++)
                                        {
                                            console.log(i + ". attachment id " + res[i]);
                                            attachPresent = true;
                                            this.sendAttachment(component,resultOfUserStory,rallyURL,apiVersion,recId,res[i],workspaceName);
                                        }
                                    }
                                });
                                $A.enqueueAction(callServerForAttachments);
                            }
                            
                            if (attachPresent == false || commentsPresent == false )
                            {
                                $A.get("e.force:closeQuickAction").fire();//added if US has neither comments nor attachments
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Success Message',
                                    message: 'User Story created successfully!',
                                    messageTemplate: 'Record {0} created! See it {1}!',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'success',
                                    mode: 'pester'
                                });
                                toastEvent.fire();
                                
                            }   
                            
                        }
                    });
                    $A.enqueueAction(callServer);
                    
                }
            }
        });
        $A.enqueueAction(createUserStory);
        //calling server methods 
    },
    sendComment : function(component,resultOfUserStory,rallyURL,apiVersion,recId,commentId,workspaceName,callDiscussion){
        var UserStoryurl=resultOfUserStory.toString().substr(72,11); 
        var endpoint = rallyURL+"/slm/webservice/"+apiVersion+"/conversationpost/create.js";
        var callConversationMethod = component.get('c.returnConversationBody');
        var callCalloutMethod = component.get('c.callout');
        callConversationMethod.setParams({
            "caseId"	: recId ,
            "commentid" : commentId
        });
        callConversationMethod.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                var results = response.getReturnValue();
                //alert("body " + results);
                callCalloutMethod.setParams({
                    "methodType"	: "POST",
                    "endPoint" 		: endpoint,
                    "body"			: results
                });
                callCalloutMethod.setCallback(this,function(resp){
                    if(resp.getState() === "SUCCESS"){
                        //alert("callout response" + resp.getReturnValue());
                        var parsedString =JSON.parse(resp.getReturnValue());
                        var rallyCommentid=parsedString.CreateResult.Object.ObjectID;
                        var callUpdateComments = component.get("c.updateComments");// changes insertComments to updateComments
                        console.log("*********************************");
                        console.log("caseId "+ recId + " defectId " + UserStoryurl +" commentId " + rallyCommentid + " SalesforceCommentId " + commentId);
                        console.log("*********************************");
                        callUpdateComments.setParams({
                            "caseId" : recId,
                            "defectId" : UserStoryurl,
                            "commentId" : JSON.stringify(rallyCommentid),
                            "SalesforceCommentId" : commentId
                        });
                        
                        callUpdateComments.setCallback(this, function(insertResponse){
                            if(insertResponse.getState() === "SUCCESS"){
                                console.log("Update Success for Case Comments Realtion");
                                var callServerForAttachments = component.get("c.returnAttachments");
                                callServerForAttachments.setParams({
                                    "caseId" : recId
                                });
                                if(callDiscussion == true) {
                                    callServerForAttachments.setCallback(this, function(aResponse){
                                        if(aResponse.getState() === "SUCCESS"){
                                            var res = aResponse.getReturnValue();
                                            console.log("Stringify res for attachments "+ JSON.stringify(res));
                                            for(var i=0;i<res.length;i++){
                                                console.log(i+". attachment id "+ res[i]);
                                                this.sendAttachment(component,resultOfUserStory,rallyURL,apiVersion,recId,res[i],workspaceName);								
                                            }
                                        }
                                    });
                                    $A.enqueueAction(callServerForAttachments);  
                                }
                            }    
                        });
                        $A.enqueueAction(callUpdateComments);
                    }
                });
                $A.enqueueAction(callCalloutMethod);
            }
        });
        $A.enqueueAction(callConversationMethod);
    },
    sendAttachment : function(component,resultOfUserStory,rallyURL,apiVersion,recId,atachmentId,workspaceName){
        console.log("Inside send attachments");
        //var endpoint = rallyURL+"/slm/webservice/"+apiVersion+"/attachmentcontent/create.js";
        var endpoint = 'https://rally1.rallydev.com/slm/webservice/1.43/attachmentcontent/create.js';
        var callSendAttachment = component.get("c.sendAttachmentMethod");
        var body;
        callSendAttachment.setParams({
            "attachId" : atachmentId
        });
        var callCalloutMethod = component.get('c.callout');       
        callSendAttachment.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var returnedJString = response.getReturnValue();
                //alert("attachment Id is "+atachmentId);
                console.log("attachment Id is "+atachmentId);
                console.log("returned jsString from attachment method "+returnedJString);
                var parsedVal = JSON.parse(returnedJString);
                //alert("Send Attachment call successfull , parsed Value is "+parsedVal);
                var attachmentContent = parsedVal.Body;
                console.log("parsedVal.Body "+attachmentContent);
                //var workspaceUrl = component.get("c.returnWorkspaceURL");
                var workspaceUrl = "https://rally1.rallydev.com/slm/webservice/1.43/workspace/6692415259.js";
                var workspaceName1 = "Travelclick";//delete this after testing and put corrent one
                body = '{"AttachmentContent": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "Workspace": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "'+workspaceUrl+'", "_refObjectName": "'+workspaceName1+'", "_type": "Workspace"}, "Content": "'+attachmentContent+'", "_type": "AttachmentContent"}}';
                callCalloutMethod.setParams({
                    "methodType"	: "POST",
                    "endPoint" 		: endpoint,
                    "body"			: body
                });
                callCalloutMethod.setCallback(this,function(resp){
                    if(resp.getState() === "SUCCESS"){
                        var res = resp.getReturnValue();
                        console.log("res before second attach call "+res); 
                        var n	= res.indexOf("_ref");
                        console.log(" n is "+n );
                        var attachContentRef=res.substring(n+8,n+89);
                        console.log("attachContentRef "+attachContentRef);
                        var rally_attachmentId=attachContentRef.substring(66,77);
                        console.log("rally_attachmentId "+rally_attachmentId);
                        var UserStoryurl=resultOfUserStory;
                        console.log("User Story Url "+ UserStoryurl);
                        console.log(" workspaceName "+workspaceName);
                        workspaceUrl = 'https://rally1.rallydev.com/slm/webservice/1.43/workspace/6692415259.js';
                        console.log("workspaceUrl - "+workspaceUrl+" workspaceName - "+workspaceName+" UserStory URL - "+UserStoryurl+" attachmentContentRef - "+ attachContentRef +" parsedVal Content type - "+parsedVal.ContentType +" parsedval body length "+ parsedVal.BodyLength + " parsedVal name " + parsedVal.Name);
                        body = '{"Attachment": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "Workspace": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "'+workspaceUrl+'", "_refObjectName": "'+workspaceName+'", "_type": "Workspace"}, "Artifact": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "'+UserStoryurl+'", "_type": "Defect"}, "Content": "'+attachContentRef+'", "ContentType": "'+parsedVal.ContentType+'", "Size": "'+parsedVal.BodyLength+'", "Name": "'+parsedVal.Name+'" }}';
                        console.log("Body for second callout "+ body);
                        endpoint = rallyURL+"/slm/webservice/"+apiVersion+"/attachment/create.js";
                        console.log("now calling attachment second callout");
                        this.attachmentSecondCallout(component,endpoint,body,UserStoryurl,recId,rally_attachmentId,atachmentId);
                        
                    }
                });
                $A.enqueueAction(callCalloutMethod);
            }
        });
        $A.enqueueAction(callSendAttachment);
        
    },
    attachmentSecondCallout : function(component,endpoint,body,UserStoryurl,recId,rally_attachmentId,atachmentId){
        console.log("Inside second atttachment call");        
        var callCallout = component.get("c.callout");
        endpoint = "https://rally1.rallydev.com/slm/webservice/1.43/attachment/create.js";
        console.log("endpoint is "+endpoint + " and body is "+body);
        callCallout.setParams({
            "methodType"	: "POST",
            "endPoint" 		: endpoint,
            "body"			: body
        });
        callCallout.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                console.log("attachment Second callout done!");
                console.log(" and response is "+ response.getReturnValue());
                //updating Case_Attachment_Relation__c Object
                var callCARUpdate = component.get('c.callUpdateIntoCARBasedOnOperation');
                console.log("setting CAR Params");
                var defectId = UserStoryurl.toString().substr(72,11);
                callCARUpdate.setParams({
                    "defectId" : defectId,
                    "cID" : recId,
                    "RallyattachemntId" : rally_attachmentId,
                    "Salesforceattid" : atachmentId
                });
                callCARUpdate.setCallback(this,function(res){
                    console.log("UserStoryurl "+defectId + " recId "+ recId + " rally_attachmentId "+ rally_attachmentId + " atachmentId " + atachmentId);
                    if(res.getState() === "SUCCESS"){
                        console.log("attachment Updated in CAR!");                       
                    }
                    $A.get("e.force:closeQuickAction").fire();
                    //closing pop up and showing toast to User
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message: 'User Story created successfully!',
                        messageTemplate: 'Record {0} created! See it {1}!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                });
                $A.enqueueAction(callCARUpdate);
            }
        });
        $A.enqueueAction(callCallout);
    }
})