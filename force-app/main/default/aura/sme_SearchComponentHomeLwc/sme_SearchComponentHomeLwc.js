import { LightningElement, track } from 'lwc';

export default class SmeSearchComponentHome extends LightningElement {
    
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
	
	handleKeyPress(event){
		console.log('handleKeyPress Started ');
		console.log('handleKeyPress Started ',event.keyCode);
		if (event.keyCode == 13) {
			const searchKey = event.target.value;
			const baseURL = "/customerservice/s/global-search/";
			const finalURL = baseURL + searchKey;
			window.open(finalURL, "_self");
		}
		
	}
}