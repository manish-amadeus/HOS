import { LightningElement, track, api, wire } from 'lwc';
import fetchPicklistValues from '@salesforce/apex/SME_CreateTaskCtrl.fetchPicklistValues';
import insertTaskinApex from '@salesforce/apex/SME_CreateTaskCtrl.insertTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPlanAccountId from '@salesforce/apex/SME_CreateTaskCtrl.getAccountIdforPlan';

const inputData = {Subject:null,ActivityDate:null,WhatId:null,WhoId:null,Priority:null,OwnerId:null};

export default class SME_CreateTask extends LightningElement {
    @track openmodel = false;
    @track error;
    @track relatedToIdCondition;
    @track whoIdCondition;
    @api recordId;

    @api FR_Priority=[];
    
    @api taskRec = inputData;

    @wire(fetchPicklistValues, { object_name: 'Task', field_name: 'Priority'})
    priorityValues(result) {
        if (result.data) {
            for(var i=0;i<result.data.length;i++){
                this.FR_Priority.push({ label: result.data[i], value: result.data[i] });    
            }
        } else if (result.error) {
            this.error = result.error;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Something went wrong',
                message: result.error,
                variant: 'error'
            }),);
        }
    }

    @wire(getPlanAccountId, { accPlanId: '$recordId'})
    accountId(result) {
        if (result.data) {
            this.whoIdCondition = " AND AccountId='" + result.data +"'";

        } else if (result.error) {
            this.error = result.error;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Something went wrong',
                message: result.error,
                variant: 'error'
            }),);
        }
    }

    handlePriorityChange(event) {
        this.taskRec.Priority = event.detail.value;
    }

    handleSubjectChange(event) {
        this.taskRec.Subject = event.detail.value;
    }

    handleDueDateChange(event) {
        this.taskRec.ActivityDate = event.detail.value;
    }
    
    handleOnAssignedTo(event) {
        this.taskRec.OwnerId = event.detail.selRecords;

    }

    handleOnRelatedTo(event) {
        this.taskRec.WhatId = event.detail.recordid;
    }
    
    handleOnNameChange(event) {
        this.taskRec.WhoId = event.detail.recordid;
    }
    

    @api openModal() {
        this.openmodel = true
    }

    closeModal() {
        this.taskRec.Subject = null;
        this.taskRec.WhatId = null;
        this.taskRec.WhoId = null;
        this.taskRec.ActivityDate = null;
        this.taskRec.OwnerId = null;
        this.taskRec.Priority = null;
        this.openmodel = false
    } 

    saveMethod() {

        var validationPassed = true;
        var errorString = 'Please fill required fields:';
        
        if(this.taskRec.Subject === null || this.taskRec.Subject === '') {
            validationPassed = false;
            errorString = errorString + ' Subject,';
        } 
        if(this.taskRec.OwnerId === null || this.taskRec.OwnerId === '' || this.taskRec.OwnerId.length === 0) {
            validationPassed = false;
            errorString = errorString + ' Assigned To,';
        }
        if(this.taskRec.WhatId === null || this.taskRec.WhatId === '') {
            validationPassed = false;
            errorString = errorString + ' Related To,';
        }

        if(this.taskRec.Priority === null || this.taskRec.Priority === '') {
            validationPassed = false;
            errorString = errorString + ' Priority,';
        }
        //errorString.subString(0,errorString-1);

        if(!validationPassed) {
            var newErrorStr = errorString.substring(0, errorString.length-1);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Details Missing',
                message: newErrorStr,
                variant: 'error'
            }),);
            validationPassed = true;
        }
        else {
            insertTaskinApex({ objTaskJSON : JSON.stringify(this.taskRec) })
            .then(result => {
                if(result === 'Success'){
                // Clear the user enter values
                    // Show success messsage
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: 'Task Created Successfully.',
                        variant: 'success'
                    }),);
                    const valueChangeEvent = new CustomEvent("valuechange", {
                        detail: 'refresh'
                    });
                    // Fire the custom event
                    this.dispatchEvent(valueChangeEvent);
                    this.closeModal();
                }
                else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Something went wrong',
                        message: result,
                        variant: 'error'
                    }),);
                }

            })  
            .catch(error => {
                this.error = error.message;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Something went wrong',
                    message: error,
                    variant: 'error'
                }),);
            });
        }
        
    }

    connectedCallback() {
        this.relatedToIdCondition = " AND SME_Account_Plan__c = '" + this.recordId + "' AND RecordType.Name = 'Objectives'";
    }
}