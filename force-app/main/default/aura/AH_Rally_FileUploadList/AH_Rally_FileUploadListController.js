({
    init : function(component, event, helper) {
        helper.retriveRecord(component, event, helper);
    },    
    handleSelect: function (cmp, event, helper) {
        
        var selectedMenuItemValue = event.getParam("value");
        var arrItem=selectedMenuItemValue.split("_");
        
        switch (arrItem[0]) {
            case 'sent':
                if(confirm('Do you want to send selected attachments to Rally?')) {
                    helper.sendAttachment(cmp, event, helper,arrItem[1]);
                    var a = cmp.get('c.init');
                    $A.enqueueAction(a);
                }
                break;
            case 'edit':
                
                helper.handleEdit(cmp, event, helper,arrItem[1]);    
                break;
            case 'delete':
                helper.handleDelete(cmp, event, helper,arrItem[1]);                  
                break;
            case '' :
                helper.fileAlreadySent(cmp, event, helper);
                break;
                
        }
        
        
    },
    refresh: function (cmp, event, helper) {
        helper.retriveRecord(cmp, event, helper);
    },
   
    openRelatedList: function(component, event){
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "AttachedContentDocuments",
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire();
    }
    
    
	
})