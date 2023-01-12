/**************************************************************************************
******************************
Name 			: sltc_ZuoraOrderStatus 
Author 			: Subramanya Asode
Created Date 	: 9/12/2022
Last Mod Date 	: 1/24/2023
Last Mod By 	: Subramanya Asode
NICC Reference 	: 
Description 	: Component used to disploy error and succuss message from DTSLog object
***************************************************************************************
*******************************/

import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import LightningConfirm from 'lightning/confirm';
import SLTC_Sync_Opportunity_FIELD from "@salesforce/schema/Opportunity.SLTC_Sync_Opportunity__c";
import SLTC_Sync_Agreement_FIELD from "@salesforce/schema/Apttus__APTS_Agreement__c.SLTC_Sync_Agreement__c";
import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import AID_FIELD from "@salesforce/schema/Apttus__APTS_Agreement__c.Id";
import { updateRecord } from 'lightning/uiRecordApi';
import SLTC_Zuora_URl from '@salesforce/label/c.SLTC_Zuora_URl';

const COLS = [
    {
        label: 'Zuora Subscription #',
        fieldName: 'subscriptionNo',
        type: 'text'
    },
    {
        label: 'Zuora Order Number #',
        fieldName: 'zuorOrderURL',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'zuoraOrderNo'
            },
            target: '_blank'
        }
    }
];
const COLSErr = [
    {
        label: 'Error Message',
        fieldName: 'errorMessage',
        wrapText: true,
        type: 'text'
    },
];

const event = new Event('A');

const FIELDS = [
    'DTS_Integration_Log__c.Id',
    'DTS_Integration_Log__c.Type__c',
    'DTS_Integration_Log__c.SLTC_Zuora_Order_Number__c',
    'DTS_Integration_Log__c.SLTC_Zuora_Subscription_Number__c',
    'DTS_Integration_Log__c.SLTC_REST_API_Error_Code__c',
    'DTS_Integration_Log__c.Summary__c',
    'DTS_Integration_Log__c.SLTC_Opportunity__c',
    'DTS_Integration_Log__c.SLTC_Agreement__c',
    'DTS_Integration_Log__c.Details__c',
    'DTS_Integration_Log__c.SLTC_EventUuid__c',
];
export default class SLTC_ZuoraOrderStatus extends LightningElement {
    @api recordId;
    records;
    @track label = SLTC_Zuora_URl;
    @track orderStatus = true;
    @track setRefresh = false;
    @track orderStatusSuccess = false;
    @track orderStatusError = false;
    @track isOpptySync = false;
    @track isAgreeSync = false;
    @track columns = COLS;
    @track searchString;
    @track columnsErr = COLSErr;
    @track initialRecords;
    @track temp = [];



    @api channelName = '/data/DTS_Integration_Log__ChangeEvent'; //'/data/DTS_Integration_Log__ChangeEvent'
    subscription = {}; //subscription information
    @track tempZuoraRecords = [];
    @track displayList = [];

    @track EventUuid;

    @track erorLog = [];

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'DTS_Integration_Logs__r',
        fields: FIELDS,
    }) listInfo({ error, data }) {
        if (data) {
            if (data.count > 0) {
                console.log('@@ data...:' + data);
                console.log('@@ jsonObj...:' + JSON.stringify(data));

                this.EventUuid = data.records[data.records.length - 1].fields.SLTC_EventUuid__c.value;
                console.log('@@ EventUuid...:' + this.EventUuid);
                let zuorOrderURL = this.label;
                let finalLog = data.records.map((item, index) => {
                    let { Id, SLTC_REST_API_Error_Code__c, SLTC_Zuora_Subscription_Number__c, SLTC_Zuora_Order_Number__c, Details__c, Type__c, SLTC_EventUuid__c } = item.fields;
                    let formatedObject = {};
                    formatedObject.Id = Id;
                    formatedObject.errorCode = SLTC_REST_API_Error_Code__c.value;
                    formatedObject.errorMessage = 'Error Code{' + SLTC_REST_API_Error_Code__c.value + '} ' + Details__c.value;
                    formatedObject.subscriptionNo = SLTC_Zuora_Subscription_Number__c.value;
                    formatedObject.zuoraOrderNo = SLTC_Zuora_Order_Number__c.value;
                    formatedObject.zuorOrderURL = zuorOrderURL + SLTC_Zuora_Order_Number__c.value;
                    formatedObject.type = Type__c.value;

                    if (Type__c.value == 'Failure' && SLTC_EventUuid__c.value == this.EventUuid) {
                        return formatedObject;
                    } else if (Type__c.value == 'Success' && SLTC_EventUuid__c.value == this.EventUuid) {
                        return formatedObject;
                    }
                    if (Type__c.value == 'Success' && SLTC_EventUuid__c.value != this.EventUuid) {
                        return formatedObject;
                    }
                });
                console.log('@@ finalLog...:' + JSON.stringify(this.finalLog));

                this.errorLog = finalLog.filter((item, index) => {
                    if (item.type == 'Failure') {

                        this.orderStatus = false;
                        this.orderStatusSuccess = false;
                        this.orderStatusError = true;
                        this.handleSubscribe();
                        return item;

                    } else {
                        this.orderStatus = false;
                        this.orderStatusSuccess = true;
                        this.orderStatusError = false;
                        return item;
                    }
                });
                this.displayList = this.errorLog;
                this.tempZuoraRecords = this.errorLog;
                this.initialRecords = this.errorLog;
               
            }
            else {
                this.handleSubscribe();
            }
        } else if (error) {
            this.records = undefined;
        }

    }


    handleSearchNewEvent() {
        this.tempZuoraRecords = this.temp;
    }
    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();

        if (searchKey) {
            this.tempZuoraRecords = this.initialRecords;

            if (this.tempZuoraRecords) {
                let searchRecords = [];

                for (let record of this.tempZuoraRecords) {
                    let valuesArray = Object.values(record);

                    for (let val of valuesArray) {
                       
                        let strVal = String(val);

                        if (strVal) {

                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }

                this.tempZuoraRecords = searchRecords;
            }
        } else {
            this.tempZuoraRecords = this.initialRecords;
        }
    }
    get setDatatableHeight() {
        if (this.tempZuoraRecords.length == 0) {//set the minimum height
            return 'height:2rem;';
        }
        else if (this.tempZuoraRecords.length > 10) {//set the max height
            return 'height:20rem;';
        }
        return '';//don't set any height (height will be dynamic)
    }
    // Handles subscribing
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        let messageCallback = (response) => {
            // Response contains the payload of the new message received
           
            this.handleNotification(response);
            //handleSearchNewEvent();
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            this.subscription = response;
            //this.handleNotification(response);
        });
    }
    // Handles unsubscribing
    handleUnsubscribe() {
        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            // Response is true for successful unsubscribe
        });
    }

    //this method checks if current record got updated and shows message on UI
  
        handleNotification(response) {
            if (response.hasOwnProperty('data')) {
                let jsonObj = response.data;
              
                if (jsonObj.hasOwnProperty('payload')) {
                    let payload = response.data.payload;
                   
                    let type = payload.Type__c;
                    let opptyId = payload.SLTC_Opportunity__c;
                    let agreementId = payload.SLTC_Agreement__c;
                    let zuorOrderURL = this.label;
                    
                    if (opptyId && opptyId === this.recordId) {
                        this.isOpptySync = true;
                        this.isAgreeSync = false;
    
                        if (type && type == 'Failure') {
                            if (this.tempZuoraRecords) {
                                this.displayList = [...this.tempZuoraRecords];
                               
                            }
                            this.orderStatus = false;
                            this.orderStatusError = true;
                            this.orderStatusSuccess = false;
                            let zuoraSubsErrorCode = payload.SLTC_REST_API_Error_Code__c;
                            let zuoraErorrMsg = payload.Details__c;
                            let recordId = payload.ChangeEventHeader.recordIds;
                            
                            let payloadObject = {};
                            payloadObject.Id = recordId;
                            payloadObject.errorCode = zuoraSubsErrorCode;
                            payloadObject.errorMessage = zuoraErorrMsg;
                            this.tempZuoraRecords.push(payloadObject);
                            this.initialRecords = this.tempZuoraRecords;
                            this.displayList = [...this.tempZuoraRecords];
    
                        }
                        if (type && type == 'Success') {
                            if (this.tempZuoraRecords) {
                                this.displayList = [...this.tempZuoraRecords];
                               
                            }
                            this.orderStatusSuccess = true;
                            this.orderStatus = false;
                            this.orderStatusError = false;
                            let zuoraSubscriptionNo = payload.SLTC_Zuora_Subscription_Number__c;
                            let zuoraOrderNo = payload.SLTC_Zuora_Order_Number__c;
                            let recordId = payload.ChangeEventHeader.recordIds;
                           
                            let payloadObject = {};
                            payloadObject.Id = recordId;
                            payloadObject.subscriptionNo = zuoraSubscriptionNo;
                            payloadObject.zuoraOrderNo = zuoraOrderNo;
                            payloadObject.zuorOrderURL = zuorOrderURL + zuoraOrderNo;
                            this.tempZuoraRecords.push(payloadObject);
                            this.initialRecords = this.tempZuoraRecords;
                            this.displayList = [...this.tempZuoraRecords];
                        }
                    } else if (agreementId && agreementId === this.recordId) {
    
                        this.isAgreeSync = true;
                        this.isOpptySync = false;
    
                        if (type && type == 'Failure') {
                            if (this.tempZuoraRecords) {
                                this.displayList = [...this.tempZuoraRecords];
                                
                            }
                            this.orderStatus = false;
                            this.orderStatusError = true;
                            this.orderStatusSuccess = false;
                            let zuoraSubsErrorCode = payload.SLTC_REST_API_Error_Code__c;
                            let zuoraErorrMsg = payload.Details__c;
                            let zuoraName = payload.Name;
                            let payloadObject = {};
                            payloadObject.Id = zuoraName;
                            payloadObject.errorCode = zuoraSubsErrorCode;
                            payloadObject.errorMessage = zuoraErorrMsg;
                            this.tempZuoraRecords.push(payloadObject);
                            this.displayList = [...this.tempZuoraRecords];
                            this.initialRecords = this.tempZuoraRecords;
    
                        }
                        else if (type && type == 'Success') {
                            if (this.tempZuoraRecords) {
                                this.displayList = [...this.tempZuoraRecords];
                               
                            }
                            this.orderStatusSuccess = true;
                            this.orderStatus = false;
                            this.orderStatusError = false;
                            let zuoraSubscriptionNo = payload.SLTC_Zuora_Subscription_Number__c;
                            let zuoraOrderNo = payload.SLTC_Zuora_Order_Number__c;
                            let zuoraName = payload.Name;
                            let payloadObject = {};
                            payloadObject.Id = zuoraName;
                            payloadObject.subscriptionNo = zuoraSubscriptionNo;
                            payloadObject.zuoraOrderNo = zuoraOrderNo;
                            payloadObject.zuorOrderURL = zuorOrderURL + zuoraOrderNo;
                            this.tempZuoraRecords.push(payloadObject);
                            this.displayList = [...this.tempZuoraRecords];
                            this.initialRecords = this.tempZuoraRecords;
                        }
    
                    }
    
                }
            }
        }
    async handleConfirmClick() {

        const result = await LightningConfirm.open({
            message: 'Are you sure you want to Retry Order Sync?',
            variant: 'headerless',
            theme: "success",
            label: 'this is the aria-label value',
            // setting theme would have no effect
        });
        if (result) {
            this.tempZuoraRecords = [];
            this.orderStatus = true;
            this.orderStatusSuccess = false;
            this.orderStatusError = false;
            //this.handleSubscribe();

            const fields = {};

            if (this.isOpptySync) {
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[SLTC_Sync_Opportunity_FIELD.fieldApiName] = true;
            } else if (this.isAgreeSync) {
                fields[AID_FIELD.fieldApiName] = this.recordId;
                fields[SLTC_Sync_Agreement_FIELD.fieldApiName] = true;

            }
            const record = { fields };

            updateRecord(record)
                // eslint-disable-next-line no-unused-vars
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success Message',
                            message: 'Zuora order sync request sent succusfully',
                            variant: 'success',
                            mode: 'dismissable'
                        }),
                    );
                    // this.handleSubscribe();
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error on data save',
                            message: error.message.body,
                            variant: 'error',
                        }),
                    );
                });

        }
    }


}