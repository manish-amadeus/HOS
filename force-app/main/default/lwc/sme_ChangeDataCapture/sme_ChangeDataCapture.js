import {
    LightningElement,
    track,
    api
} from 'lwc';
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled
} from 'lightning/empApi';
export default class Sme_ChangeDataCapture extends LightningElement {
    @api payload;
    // @track channelName = '/event/Test__e';
    // @api channelName = '/event/Account_Plan__ChangeEvent';
    @api channelName;
	@api recordId;
    @track isSubscribeDisabled = false;
    @track isUnsubscribeDisabled = !this.isSubscribeDisabled;
    subscription = {};

    // Tracks changes to channelName text field
    handleChannelName(event) {
        this.channelName = event.target.value;
    }

    // Handles subscribe button click
    handleSubscribe(event) {
        // Callback invoked whenever a new event message is received
        const messageCallback = function(response) {
            console.log('New message received : ', JSON.stringify(response));
            // this.invokeComputePercentage();
            const eventType = response.data.payload.ChangeEventHeader.changeType;
            const recordIds = response.data.payload.ChangeEventHeader.recordIds;
			console.log('eventType: ' + eventType);
			console.log('recordIds: ' + recordIds);
			console.log('this.recordId: ' + this.recordId);
			/*if(!(eventType === "CREATE")){
                
				if(recordIds.includes(this.recordId))
				{
					this.payload = JSON.stringify(response);
					console.log('this.payload: ' + this.payload);
					// Response contains the payload of the new message received
					const selectedEvent = new CustomEvent("datachange", {
						detail: this.payload
					  });					
					  // Dispatches the event.
					  this.dispatchEvent(selectedEvent);
				}
				
			}*/
			this.payload = JSON.stringify(response);
			console.log('this.payload: ' + this.payload);
			// Response contains the payload of the new message received
			const selectedEvent = new CustomEvent("datachange", {
				detail: this.payload
			  });					
			  // Dispatches the event.
			  this.dispatchEvent(selectedEvent);			
            console.log('messageCallback end:::: ');
        }.bind(this);

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on successful subscribe call
            console.log('Successfully subscribed to : ', JSON.stringify(response.channel));
            this.subscription = response;
            this.toggleSubscribeButton(true);
        });
    }

    // Handles unsubscribe button click
    handleUnsubscribe() {
        this.toggleSubscribeButton(false);

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    toggleSubscribeButton(enableSubscribe) {
        this.isSubscribeDisabled = enableSubscribe;
        this.isUnsubscribeDisabled = !enableSubscribe;
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
    connectedCallback() {
        this.handleSubscribe();
    }

}