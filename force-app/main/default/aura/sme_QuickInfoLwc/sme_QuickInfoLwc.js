import { LightningElement, track, wire, api } from 'lwc';
    import NAME_FIELD from '@salesforce/schema/SME_Competitive_Analysis__c.Name';
    import TYPE_FIELD from '@salesforce/schema/Account.SME_Competitor_Type__c';
    import PROFIT_FIELD from '@salesforce/schema/Account.SME_Current_Estimated_Profits__c';
    import REVENUE_FIELD from '@salesforce/schema/Account.SME_Current_Estimated_Revenue__c';
    import WEAKNESS_FIELD from '@salesforce/schema/SME_Competitive_Analysis__c.Overall_Weakness__c';
    import CURRENT_FIELD from '@salesforce/schema/SME_Competitive_Analysis__c.Current_estimated__c';
    import POTENTIALREVENUE_FIELD from '@salesforce/schema/SME_Competitive_Analysis__c.Potential_Incremental_Revenue_Available__c';
    import COMPETITOR_FIELD from '@salesforce/schema/Account.Name';
    import STRENGTH_FIELD from '@salesforce/schema/SME_Competitive_Analysis__c.Overall_Strength__c';
    import simpleRecord from '@salesforce/schema/SME_Competitive_Analysis__c';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import { deleteRecord } from 'lightning/uiRecordApi';
    import fetchCAList from '@salesforce/apex/SME_CompetitiveAnalysisCtrl.fetchCAList';

export default class Sme_QuickInfoLwc extends LightningElement {
    @api showData= false;
    @api caId;
    @track editData=false;
    @track recordError;
    @api hasCompetitiveAnalysisEditAccess;
    @track toggleErrorMessage=false;
    @track saveResult;
    @api record;
    @api recordId;
    @track showEditDelete=true;
    @api enableChangeDataCapture =false;
    @api accPlanId;
    @api caList;
    @track element;
    @track eventType;
    @track channelName= "/event/SME_Competitive_Analysis__ChangeEvent"
    fields = [NAME_FIELD, TYPE_FIELD, PROFIT_FIELD,REVENUE_FIELD,WEAKNESS_FIELD,CURRENT_FIELD,POTENTIALREVENUE_FIELD,COMPETITOR_FIELD,STRENGTH_FIELD];
    
    connectedCallback() {
        var caListString= JSON.stringify(this.caList);
        console.log('caListString ',caListString);
       
         for (let item in this.caList){
            if(this.caList[item].Id == this.recordId){
                this.COMPETITOR_FIELD=this.caList[item].SME_Competitor__r.Name;
                this.TYPE_FIELD=this.caList[item].SME_Competitor__r.SME_Competitor_Type__c;
                this.PROFIT_FIELD=this.caList[item].SME_Competitor__r.SME_Current_Estimated_Profits__c;
                this.REVENUE_FIELD=this.caList[item].SME_Competitor__r.SME_Current_Estimated_Revenue__c;
            }
         }
    }
    onEditCA(event){
        this.editData=true;
        this.showEditDelete=false;
        this.enableChangeDataCapture=true;
        //const selectEvt= new CustomEvent('datacaptureevent');
           // this.dispatchEvent(selectEvt);
        console.log('editData',JSON.stringify(this.caList));
        console.log('editData',JSON.stringify(this.caList[0].SME_Competitor__r.SME_Current_Estimated_Profits__c));
    }
    
    handleDelete(event) {
        console.log('handleDelete',this.recordId);
        this.template.querySelector('[data-id="delConfirm"]').classList.remove('slds-hide');
        this.template.querySelector('[data-id="delConfirm"]').classList.add('slds-show');
         
    }
    handleModalDelete(event) {
        deleteRecord(this.recordId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
                
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
            this.template.querySelector('[data-id="delConfirm"]').classList.remove('slds-show');
            this.template.querySelector('[data-id="delConfirm"]').classList.add('slds-hide');
            this.showData=false;
            this.enableChangeDataCapture=true;
            this.element = "Delete";
            console.log('element ',this.element);
    }
    handleModalCancel(event) {
        this.template.querySelector('[data-id="delConfirm"]').classList.remove('slds-show');
        this.template.querySelector('[data-id="delConfirm"]').classList.add('slds-hide');
        
    }
    onCancelEdit(event){
        //this.template.querySelector('record').reloadRecord(true);
        this.editData=false;
        this.showEditDelete=true;
    }
    
    handleSuccess(event) {
        console.log("New Record Id ",event.detail.value);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record Updated',
                variant: 'success'
            }),
        );
        this.editData=false;
        this.showEditDelete=true;
        this.element="Save";
        console.log('element ',this.element);
    }
    handleclick(){
        console.log('submit');
        this.editData=false;
        this.showEditDelete=true;
        this.template.querySelector('[data-id="textboxId"]').submit();
    }
    handleSelect(event){
        console.log('handleSelect');
        this.caId = event.detail.SelectedCAId;
        //component.set("v.caId", caId);
        this.showData= true;
        this.editData= false;
        this.template.querySelector('record').reloadRecord(true);
    }
    handleDataChange(event) {
        console.log('handleDataChange::::',event.detail);
        const actionType = JSON.parse(event.detail);
        console.log('eventType2::::',actionType.data.payload.ChangeEventHeader.changeType);
        this.eventType=actionType.data.payload.ChangeEventHeader.changeType
        this.invokeComputePercentage();
        
    }
    invokeComputePercentage(){
        
        const selectEvt= new CustomEvent('handleclickevent',{detail: {SelectedCAId:this.recordId, element:this.eventType}});
            this.dispatchEvent(selectEvt);
            console.log('dispatched');
    }
    
    
}