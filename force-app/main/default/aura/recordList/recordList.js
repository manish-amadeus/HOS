import { LightningElement, api } from 'lwc';

export default class RecordList extends LightningElement {
    @api record;
    @api fieldname;
    @api iconname;

    handleSelect(event){
        event.preventDefault();
		console.log(' this.record.val:::::', this.record.val);
        const selectedRecord = new CustomEvent(
            "select",
            {
                detail : this.record.val
            }
        );
        /* eslint-disable no-console */
        //console.log( this.record.val);
        /* fire the event to be handled on the Parent Component */
        this.dispatchEvent(selectedRecord);
    }
}