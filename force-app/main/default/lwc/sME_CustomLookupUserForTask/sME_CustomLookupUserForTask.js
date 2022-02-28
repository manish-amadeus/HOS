import { LightningElement,wire,api,track } from 'lwc';
import getResults from '@salesforce/apex/SME_CreateTaskCtrl.getLookupValues';

export default class LwcCustomLookup extends LightningElement {
    @api objectname ;
    @api fieldname ;
    @api selectRecordId = '';
    @api selectRecordName;
    @api condition;
    @api label;
    @api searchRecords = [];
    @api required = false;
    @api iconname = 'action:new_account'
    @api LoadingText = false;
    
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track messageFlag = false;
    @track iconFlag =  true;
    @track clearIconFlag = false;
    @track inputReadOnly = false;
   
    @api checkValidity() {
        if(!this.required)
         return null;
        console.log('checkValidity called ');
        var inputCmp = this.template.querySelector(".leftspace");
        console.log('inputCmp value'+inputCmp);
		var value = inputCmp.value;
		// is input is valid?
		if (!value) {
		     inputCmp.setCustomValidity("Complete this field.");
    
		} else {
		  inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
		}
		inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
	  }
    searchField(event) {
        var currentText = event.target.value;
        this.LoadingText = true;
        
        getResults({ ObjectName: this.objectname, fieldName: this.fieldname, value: currentText, condition: this.condition  })
        .then(result => {
            this.searchRecords= result;
            this.LoadingText = false;
            
            this.txtclassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            if(currentText.length > 0 && result.length == 0) {
                this.messageFlag = true;
            }
            else {
                this.messageFlag = false;
            }

            if(this.selectRecordId != null && this.selectRecordId.length > 0) {
                this.iconFlag = false;
                this.clearIconFlag = true;
            }
            else {
                this.iconFlag = true;
                this.clearIconFlag = false;
            }
        })
        .catch(error => {
            console.log('-------error-------------'+error);
            console.log(error);
        });
        
    }
    
   setSelectedRecord(event) {
        var currentText = event.currentTarget.dataset.id;
        this.txtclassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        this.iconFlag = false;
        this.clearIconFlag = true;
        this.selectRecordName = event.currentTarget.dataset.name;
        var selectName = event.currentTarget.dataset.name;
        this.selectRecordId = currentText;
        this.inputReadOnly = true;
        const selectedEvent = new CustomEvent('selected', { detail: {recordid:this.selectRecordId,objectname:this.objectname} });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    
    resetData(event) {
        this.selectRecordName = "";
        this.selectRecordId = "";
        this.inputReadOnly = false;
        this.iconFlag = true;
        this.clearIconFlag = false;
        const unselectedEvent = new CustomEvent('unselected', { detail: {recordid:this.selectRecordId,objectname:this.objectname} });
        // Dispatches the event.
        this.dispatchEvent(unselectedEvent);
    }

}