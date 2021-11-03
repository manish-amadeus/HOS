({ 
    helperMethod : function(component, event, helper, res) {
        //alert(res);
        component.set("v.pBar",true);
        if(res =="null"){
            this.ShowError(component, event, helper);
        }
        if(res =="Please create user story first"){
            var msgs = component.find("msgs");
            msgs.throwError('ERROR', 'error', "Please create user story first");
            component.set("v.pBar",false);
            
        }
        else{
            var id = component.get("v.recordId");
            if(res.indexOf("Cannot find object to read") != -1)
            { var msgs = component.find("msgs");
             msgs.throwError('ERROR', 'error', "UserStory is deleted in rally");
             component.set("v.pBar",false);
             //		throw new Error("UserStory is deleted in rally");
            } 
            else{
                var List=JSON.parse(res);
                //alert("nit"+List.HierarchicalRequirement.FormattedID);
                var FormattedID=List.HierarchicalRequirement.FormattedID;
                var RallyStatus=List.HierarchicalRequirement.L3KanbanStage;
                var Release=List.HierarchicalRequirement.Release;
                var Owner=List.HierarchicalRequirement.Owner;
                var USproject=List.HierarchicalRequirement.Project._refObjectName;
                var MasterTicket=List.HierarchicalRequirement.MasterTicket.LinkID;
                var SalesforcePriority=List.HierarchicalRequirement.SalesforcePriority;
                if(Owner!=null) 
                { 
                    Owner=List.HierarchicalRequirement.Owner._refObjectName; 
                } 
                if(Release!=null) 
                { 
                    Release=List.HierarchicalRequirement.Release._refObjectName; 
                } 
                else 
                { 
                    Release="Unscheduled"; 
                } 
                if(MasterTicket!=null) 
                { 
                    MasterTicket=List.HierarchicalRequirement.MasterTicket.LinkID; 
                } 
                else 
                { 
                    MasterTicket=""; 
                } 
                ////alert('test'+MasterTicket);
                
                var actionSetDate = component.get("c.LRupdateSfofUserStory");
                actionSetDate.setParams({"Owner":Owner,"USproject":USproject,"UserStoryId":FormattedID,"RallyStatus":RallyStatus,"Release":Release,"CaseId":id,"MasterTicket":MasterTicket,"SalesforcePriority":SalesforcePriority});
                this.CaseUpdate(component, event, helper,actionSetDate,"comment");
                
            }
        }
    },
    
    CaseUpdate : function(component, event, helper, actionSetDate, returnCall) {
        //alert('hiiiii**');
        
        actionSetDate.setCallback(this, function(response) {
            var stateDate = response.getState();
            if (stateDate === "SUCCESS") {
                //alert(response.getReturnValue());
                
                var res =response.getReturnValue();
                
                
                if(returnCall =="helperMethod"){
                    //alert("first call");
                    this.helperMethod(component, event, helper,res); 
                }
                if(returnCall =="comment"){
                    //alert("comment call");
                    this.CaseComment(component, event, helper,res); 
                }     
                if(returnCall =="commentinsert"){
                    //alert("commentinsert" + res);
                    this.Attachments(component, event, helper,res); 
                }     
                if(returnCall =="Attachment"){
                    //alert(component.get("v.exp"));
					   //alert(component.get("v.cou"));
                    if(res == "Refresh"){
                        component.set("v.pBar",false);
                       if( component.get("v.exp") !=  component.get("v.cou")) {
					     var resultsToastr = $A.get("e.force:showToast");
                        resultsToastr.setParams({
                            "title": "Saved",
                            "message": "Some files are too large to fetch from rally"
                        });
                        resultsToastr.fire(); 
					   }
          //  component.get("v.cou");
		  else{
		   var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "title": "Saved",
                            "message": "Case record updated"
                        });
                        resultsToast.fire(); }
                       
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get("e.force:refreshView").fire();
                    }
                    else{
                        this.ShowError(component, event, helper);
                    }
                    
                }       
                
            }
            else {
                // //alert('hiiiii cybage');
                // //alert(stateDate);
                // 
                var msgs = component.find("msgs");
                msgs.throwError('ERROR', 'error', 'Something went wrong, please contact to admin');
                component.set("v.pBar",false);
            }
            
        });
        $A.enqueueAction(actionSetDate);
        
    },
    CaseComment : function(component, event, helper, res) {
        //alert(res.res[0] );
        var Caseid = component.get("v.recordId");
        if(res.res[0] =="null"){
            this.ShowError(component, event, helper);
        }
        else{
            
            //alert("CaseComment");
            var list=JSON.parse(res.res[0]);
            
            var num=list.QueryResult.Results.length;
            
            console.log('Query Result Length:'+num);
            
            //change 4/3/2015 a sorting algorithm is added to sort pulled data on basis of //CreationDate 
            var sortarray = list.QueryResult.Results; 
            //alert(num);
            for(var i=0; i<num; i++) 
            { 
                for(var j=num-1; j>i ; j--) 
                { 
                    var Date1 = new Date(''+sortarray[i].CreationDate); 
                    var Date2 = new Date(''+sortarray[j].CreationDate); 
                    if(Date1 > Date2 ) 
                    { 
                        var tempDiscussion = sortarray[i]; 
                        sortarray[i] = sortarray[j]; 
                        sortarray[j] = tempDiscussion; 
                    } 
                } 
                
                
            } 
            
            var DiscussionId_of_Rally = new Array(); 
            var DiscussionId_Text=new Array(); 
            var UserInRallyName=new Array(); 
            
            for( var i=0;i<num;i++) 
            { 
                var id_from_resRally=sortarray[i].ObjectID; 
                var Rally_Text=sortarray[i].Text; 
                console.log(Rally_Text.length); 
                var UserInRally=sortarray[i].User._refObjectName;
                
                
                //changes for US99988 by Cybage
                var dateRest = sortarray[i].CreationDate; //added
                var newDate = new Date(dateRest);
                newDate.setUTCHours(newDate.getUTCHours() - 4);
                var year = newDate.getUTCFullYear();
                var dat = newDate.getUTCDate();
                if(dat < 10){
                    dat = "0"+dat;
                }
                var month = newDate.getUTCMonth();
                var hour = newDate.getUTCHours();
                var minute = newDate.getUTCMinutes();
                if(minute < 10){
                    minute = "0"+minute;
                }
                var meridian;
                if(hour>11 ){
                    meridian = "PM";
                }
                else{
                    meridian = "AM";
                }
                if(hour>12 || hour ==0){
                    hour = Math.abs(hour-12);
                }
                if(hour < 10){
                    hour = "0"+hour;
                }
                var finalMonth = month+1;
                var grandFinalDate = year + "-"+finalMonth + "-"+dat + " "+hour+":"+minute + " " +meridian + " EDT";
                //Done
                
                
                UserInRallyName.push(UserInRally  + ' at '+ grandFinalDate ); 
                DiscussionId_of_Rally.push(id_from_resRally); 
                DiscussionId_Text.push(Rally_Text); 
            } 
            var listofcomment_in_Sf=res.commentList; 
            console.log('listofcomment_in_Sf'+listofcomment_in_Sf);
            var CaseCommentArray = new Array();
            var  CaseCommentData = new Array(); 
            var outA = new Array();
            
            for(var m=0;m<DiscussionId_of_Rally.length;m++) 
            { 
                //var  CaseCommentData = new Array(); 
                var  inA = new Array(); 
                var flag=true; 
                console.log('DiscussionId_Text[m].length'+DiscussionId_Text[m].length); 
                console.log('Rally id:'+DiscussionId_Text[m]); 
                for(var j=0;j<listofcomment_in_Sf.length;j++) 
                { 
                    if(listofcomment_in_Sf[j]==DiscussionId_of_Rally[m]) 
                    { 
                        console.log('listofcomment_in_Sf[j]'+listofcomment_in_Sf[j]); 
                        flag=false; 
                    } 
                } 
                console.log(flag); 
                if(flag==true) 
                { 
                    
                    var commentBody = null; 
                    console.log('disscussion id length ='+ DiscussionId_Text[m].length); 
                    if(DiscussionId_Text[m].length>3500) 
                    { 
                        console.log('length in'); 
                        commentBody = DiscussionId_Text[m].substring(0, 3500); 
                        commentBody = commentBody +'..........'; 
                        console.log('after trim'+commentBody.length+'commentbody'+commentBody); 
                    } 
                    else 
                    { 
                        commentBody=DiscussionId_Text[m]; 
                    } 
                    console.log("Comment Body ***"+commentBody);
                    CaseCommentData.push(commentBody+"--Created by :"+UserInRallyName[m]);
                    CaseCommentArray.push(DiscussionId_of_Rally[m]);
                    inA.push('hi'+m);
                    inA.push('by'+m);
                    outA.push(inA);
                    //CaseCommentArray.push(CaseCommentData);
                    
                } 
            }		
            //alert("cyabge array"+CaseCommentArray);
            //alert("cyabge array"+CaseCommentArray.length);
            if(CaseCommentArray.length == 0){
                var  CaseCommentData = new Array(); 
                //    CaseCommentArray.push('0');
                //CaseCommentData.push("null");
            }
            console.log('cyabge array'+CaseCommentArray);
            var actionSetDate = component.get("c.insertComment");
            actionSetDate.setParams({"cmm":CaseCommentArray,"CaseID":Caseid,"cmb":CaseCommentData});
            this.CaseUpdate(component, event, helper,actionSetDate,"commentinsert");
            
        }
    },
    ShowError : function(component, event, helper) {
        ////alert(res);
        var msgs = component.find("msgs");
        msgs.throwError('ERROR', 'error', 'Something went wrong, please contact to admin');
        component.set("v.pBar",false);
        
    },
    Attachments : function(component, event, helper, res) {
        // alert(res.res[0] );
        var Caseid = component.get("v.recordId");
        if(res.res[0] =="null"){
            this.ShowError(component, event, helper);
        }
        else{
            
            //alert("CaseAttachments");
            var list = JSON.parse(res.res[0]);
            var num=list.QueryResult.Results.length;
            var attachmentRecords = res.Attachment;
            var arrAttachmentID = new Array();
            var arrAttachmentSize= new Array();
            var arrAttachmentName= new Array();
            var arrAttachmentContentType= new Array();
            var auravar1 = new Array();
            var auravar2= new Array();
            var auravar3= new Array();
            var auravar4= new Array();
            //alert(num)	;
            //preparing a list of attachment get from defect
            for(var i=0;i<num;i++)
            {
                var str3=list.QueryResult.Results[i].Content._ref;
                var attachmentSize=list.QueryResult.Results[i].Size;
                var AttachmentName=list.QueryResult.Results[i].Name;
                var AttachmentContentType=list.QueryResult.Results[i].ContentType;
                
                var RSMendpoint=res.AttURL[0];
                //alert(RSMendpoint);
                var attachmentid_trunc=str3.replace(RSMendpoint,"");
                var attachmentid=attachmentid_trunc.replace(".js","");
                //alert(attachmentid);
                arrAttachmentID.push(attachmentid);
                arrAttachmentSize.push(attachmentSize);
                arrAttachmentName.push(AttachmentName);
                arrAttachmentContentType.push(AttachmentContentType);
            }
            
            var newAttachmentno=arrAttachmentID.length;
            var counter=0;
            var excep=0;
            while(counter<newAttachmentno)
            {
                // we are checking the size of attachment upto 5MB , this can also go upto 1 to 5 MB
                if(arrAttachmentSize[counter]<5242880)
                {
                    excep++;
                    var flag=true;
                    var attid=arrAttachmentID[counter];
                    for(var j=0;j<attachmentRecords.length;j++)
                    {
                        //alert(attachmentRecords[j]);
                        if(attachmentRecords[j]==attid)
                        {
                            flag=false;
                        }
                    }
                    // all the newly rally attachment are inserted here
                    if(flag==true)
                    {
                        //var attcont=Rallyurl+"/slm/webservice/"+API_Version+"/attachmentcontent/"+attid+".js";
                        //alert(attcont);
                        //Callout("GET",attcont);
                        
                        auravar1.push(attid);
                        auravar2.push(arrAttachmentName[counter]);
                        auravar3.push(arrAttachmentContentType[counter]);
                    }
                }
                counter++;
            }
            component.set("v.exp",excep);
            component.set("v.cou",counter);
            /* if(excep<counter){
                    alert('error me');
                      var msgs = component.find("msgs");
                       component.set("v.exp",excep);
            component.set("v.cou",counter);
                msgs.throwError('ERROR', 'error', 'Some files are too large to fetch from rally');
               
                }*/
            if(auravar1.length > 0){
               
                var actionSetDate = component.get("c.insertAttachment");
                actionSetDate.setParams({"attId":JSON.stringify(auravar1),"attName":JSON.stringify(auravar2),"attContent":JSON.stringify(auravar3),"CaseID":Caseid});
                this.CaseUpdate(component, event, helper,actionSetDate,"Attachment");
            }
            else{
                // alert("no data");
                component.set("v.pBar",false);
                if( component.get("v.exp") !=  component.get("v.cou")) {
					     var resultsToastr = $A.get("e.force:showToast");
                        resultsToastr.setParams({
                            "title": "Saved",
                            "message": "Some files are too large to fetch from rally"
                        });
                        resultsToastr.fire(); 
					   }
          //  component.get("v.cou");
		  else{
		   var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "title": "Saved",
                            "message": "Case record updated"
                        });
                        resultsToast.fire(); }
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            }  
        }
    },
})