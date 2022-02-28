import { LightningElement, track, api } from 'lwc';

export default class Sme_ReusableSearchComponentLwc extends LightningElement {
    @api searchfieldplaceholder
    @track searchKey;
    handleChange(event){
        /* eslint-disable no-console */
        //console.log('Search Event Started ');
        const searchKey = event.target.value;
        /* eslint-disable no-console */
        event.preventDefault();
        const searchEvent = new CustomEvent(
            'change', 
            { 
                detail : searchKey
            }
        );
        this.dispatchEvent(searchEvent);
    }
    @api
    handleClick() {
        // console.log('Current value of the input: ' + evt.target.value);
        console.log('handleClickFromParent:::::');
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        

    }
}