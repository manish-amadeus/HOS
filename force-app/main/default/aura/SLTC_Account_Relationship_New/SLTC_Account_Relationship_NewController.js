({
    doInit : function(cmp, event, helper) {
        var pageRef = cmp.get("v.pageReference");
        var parentId = '';
        if(pageRef){
            var state = pageRef.state; // state holds any query params
            var base64Context = state.inContextOfRef;
            
            // For some reason, the string starts with "1.", if somebody knows why,
            // this solution could be better generalized.
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));
            parentId = addressableContext.attributes.recordId;
        } else{
            parentId = cmp.get('v.recordId');
        }
        var createAcountContactEvent = $A.get("e.force:createRecord");
        createAcountContactEvent.setParams({
            "entityApiName": "SLTC_Account_Affiliation__c",
            "defaultFieldValues": {
                'SLTC_Account__c' : parentId
            }
        });
        createAcountContactEvent.fire();
        
    }
})