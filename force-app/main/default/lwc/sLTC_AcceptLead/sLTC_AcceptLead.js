import { LightningElement, wire, api } from 'lwc';
import { updateRecord,getRecord,getFieldValue} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';

import { reduceErrors } from 'c/sltc_utility'; 
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import ID_FIELD from '@salesforce/schema/Lead.Id';
import  STATUS_FIELD from '@salesforce/schema/Lead.Status';
import  OWNER_FIELD from '@salesforce/schema/Lead.OwnerId';

const FIELDS = [ID_FIELD, STATUS_FIELD, OWNER_FIELD];
const PROFILE_FIELDS = [PROFILE_NAME_FIELD];

export default class SLTC_AcceptLead extends LightningElement {

    lead;
    leadStatus ='initial';
    callController = false;
    @api recordId;
    userId;
    profileName = '';
   
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
            if (error) {
                let message = reduceErrors(error);
                this.showMessage('Error',message, 'error');
                
            } else if (data) {
                this.lead = data;
                this.userId = USER_ID;
              
                
            }
    }

   @wire(getRecord, { recordId: '$userId', fields: PROFILE_FIELDS })
   getProfile({ error, data }) {
            if(error){
                   console.log(error);
            }
            else if (data) {
               this.profileName =   getFieldValue(data, PROFILE_NAME_FIELD);
                
            }

   }



    assignLead(){
       
        let title = 'Success';
        this.callController = true;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = getFieldValue(this.lead, ID_FIELD);
        let status =  getFieldValue(this.lead, STATUS_FIELD);
        if(status == 'Open' && this.profileName != 'SLTC Lead Catcher'){
            title = 'Status changes successfully';
            fields[STATUS_FIELD.fieldApiName] = 'Engaged';
        }
        fields[OWNER_FIELD.fieldApiName] = USER_ID;
        updateRecord({ fields })
            .then(() => {
                this.showMessage(title,'Successfully Lead assigned', 'success');
                this.callController = false;
            }, (error) => {
                console.log(error);
                 let errors = reduceErrors(error);
                 console.log(errors);
                this.showMessage('Error',errors[0], 'error');
                this.callController = false;
               
            });
  }

    showMessage(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
              
            }),
        );
    }

    get isEnabled(){
        let ownerid = getFieldValue(this.lead, OWNER_FIELD) ? getFieldValue(this.lead, OWNER_FIELD) : ''; 
        return (ownerid.indexOf('005') > -1) || this.callController;
    }
}