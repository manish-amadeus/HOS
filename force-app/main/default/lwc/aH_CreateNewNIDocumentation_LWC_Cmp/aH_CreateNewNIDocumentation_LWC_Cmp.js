import { LightningElement, api, track, wire } from 'lwc';
// LWC NAVIGATION SERVICE
import { NavigationMixin } from 'lightning/navigation';
// IMPORTING TO GET THE OBJECT INFO
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// IMPERATIVE APEX CALL
import getProjRecord from '@salesforce/apex/AH_GetProjectRecord.returnProjectRecordDetails';
// IMPORTING NI_Documentation__c SCHEMA 
import NI_Documentation__c_OBJECT from '@salesforce/schema/NI_Documentation__c';
// USED TO ENCODE DEFAULT FIELD VALUES IN NAVIGATION.MIXIN CALL
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
// USED TO SHOW TOAST ON ERROR/SUCCESS
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AH_CreateNewNIDocumentation_LWC_Cmp extends NavigationMixin(LightningElement) {

    // HOLDS Project RECORD ID PASSED FROM PARENT AURA COMPONENT
    @api recordId;
    // HOLDS SELECTED RECORD TYPE VALUE
    @track selectedValue; 
    // HOLDS SET OF RECORD TYPES
    @track options = [];
    // HOLDS PROJECT RECORD RETRIVED FROM APEX METHOD 
    @track prjRec;

    // GET OBJECT INFO USING WIRE SERVICE
    @wire(getObjectInfo, { objectApiName: NI_Documentation__c_OBJECT })
    accObjectInfo({data, error}) {
        if(data) {
            let optionsValues = [];
            
            // MAP OF RECORD TYPE INFO
            const rtInfos = data.recordTypeInfos;

            // GETTING MAP VALUES
            let rtValues = Object.values(rtInfos);

            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name !== 'Master') {
                    optionsValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    })
                }
            }

            this.options = optionsValues;
        }
        else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
        }
    }
     
    // HANDLING ONCHANGE RECORD TYPE VALUES
    handleChange(event) {
        this.selectedValue = event.detail.value;
    }

    // NAVIAGE TO NEW NI Documentation RECORD PAGE
    navigateToNewRecordPage() {

        console.log('in navigateToNewRecordPage method...');
        // USING IMPERATIVE CALL TO APEX METHOD(AH_getProjectRecord.returnProjectRecordDetails), 
        //  RETRIEVE DATA OF PROJECT RECORD
        getProjRecord({recordId : this.recordId})
        .then(result => {
            this.prjRec = result;
            console.log('recordId :'+this.recordId);
            console.log('this.prjRec : ',this.prjRec.Name);
            console.log('retrieved id :'+this.prjRec.Id);
            
            // CREATE SET OF DEFALUT VALUES 
            const defaultValues = {
                Project__c: this.prjRec.Id,
                Account__c: this.prjRec.pse__Account__c,
                Opportunity__c: this.prjRec.pse__Opportunity__c,
                Project_Manager__c: this.prjRec.pse__Project_Manager__c
            };

            let pageRef = {
                type : 'standard__objectPage',
                attributes : {
                    objectApiName : 'NI_Documentation__c',
                    actionName : 'new'
                },
                state:{
                    nooverride: '1'
                }
            };
    
            if(this.selectedValue != undefined )
            {
                // NAVIGATE TO RECORD CREATION FORM OF SELECTED RECORD TYPE WITH DEFAULT VALUES AUTOPOPULATED
                pageRef.state.defaultFieldValues = encodeDefaultFieldValues(defaultValues);
                pageRef.state.recordTypeId = this.selectedValue;
                this[NavigationMixin.Navigate](pageRef);
            }
            else {
                // SHOW ERROR MESSAGE IF RECORD TYPE IS NOT SELECTED
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: "Please select Record Type",
                    variant: "error",
                });
                this.dispatchEvent(evt);
            }
        })
        .catch(error => {
            this.error = error;
            console.log('this.error : ',this.error);
        });

    }

    handleCloseWindow(event){
       
        //CREATE CUSTOM EVENT TO CLOSE WINDOW OF PARENT COMPONENT
        const closeWindow = new CustomEvent("closemodalwindow");
  
        // DISPATCH THE EVENT
        this.dispatchEvent(closeWindow);
    }
  
}