import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import SME_CommonCSS from '@salesforce/resourceUrl/SME_CommonCSS';

export default class SME_LightningErrorComponentLWC extends NavigationMixin(LightningElement){
	
	renderedCallback() {

        Promise.all([
            loadStyle(this, SME_CommonCSS + '/SME_CommonCSS.css'),
        ])
            .then(() => {
                console.log('successfully static resource loaded----->');
				this.showToast("A system error has occurred, an administrator has been notified about this problem and it will be corrected.","We apologize for the inconvenience.","error");
            })
            .catch(error => {
				console.log('error----->',error);
            });
		
    }
	
	showToast(title,message,variant) {
		
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: 'dismissable',
			duration: "200000"
		});
		this.dispatchEvent(event);
	}
}