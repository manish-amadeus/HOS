import {
    LightningElement,
    track,
    api
} from 'lwc';
import computePercentage from '@salesforce/apex/SME_CircularProgressCtrl.computePercentage';

export default class SME_CircularProgressLWC extends LightningElement {
    @api enableChangeDataCapture =false;
    @api channelName;
    @api resultFormat;
    @api legend;
    @api size;
    @api percentText;
    @api actualProgress;
    @api totalProgress;
	@api actualProgressField;
    @api totalProgressField;
    @api threshold1;
    @api threshold2;
    @track theme;
    @track themeColor;
    @track circleDegree;
    @track circleToggle;
    @track showSpinner;

    @api recordId;
    @api sObjectName;
    @api whiteFont = false;

    get percentageFormat() {
        return (this.resultFormat === 'Percentage') ? true : false;
    }

    get actualFormat() {
        return (this.resultFormat === 'Actual Number') ? true : false;
    }

    get mixFormat() {
        return (this.resultFormat === 'Mix') ? true : false;
    }

    get mixProgress() {
        return this.actualProgress + '/' + this.totalProgress;
    }

    get legendClass() {
        return this.size + ' clearFloats slds-align--absolute-center legend';
    }

    renderedCallback() {
        var barStyle = '-webkit-transform: rotate(' + this.circleDegree + 'deg); -moz-transform: rotate(' + this.circleDegree + 'deg); -ms-transform: rotate(' + this.circleDegree + 'deg); -o-transform: rotate(' + this.circleDegree + 'deg); transform: rotate(' + this.circleDegree + 'deg); -ms-transform: rotate(' + this.circleDegree + 'deg);';
        var barid = this.template.querySelector('[data-id="barDiv"]');
        if(barid != undefined && barid != '' && barid != null )
        this.template.querySelector('[data-id="barDiv"]').setAttribute("style", barStyle);
		console.log('this.theme::::',this.theme);
    }
    isNumeric(num) {
        console.log('isNumeric::::', !isNaN(num));
        return !isNaN(num);
    }
	handleDataChange() {
        console.log('handleDataChange::::');
		const selectedEvent = new CustomEvent("datachangeinchild", {
			detail: 'refreshpage'
		  });					
		  // Dispatches the event.
		  console.log('fire event start::::');
		  this.dispatchEvent(selectedEvent);
		 console.log('fire event end::::');
		this.invokeComputePercentage();
    }
    connectedCallback() {
        
        var progressBarActual;
        console.log('xxxxxxxxxxxxxxx::::',this.whiteFont);
        if (this.isNumeric(this.totalProgress)) {
			 this.showSpinner = true;
            console.log('this is a number');
			console.log('this.actualProgress::::',this.actualProgress);
			console.log('this.totalProgress::::',this.totalProgress);
            if (this.totalProgress > 0) {
	
                progressBarActual = this.actualProgress / this.totalProgress;
            } else {
                progressBarActual = 0;
            }
            console.log('this.progressBarActual::::',this.progressBarActual);
            
            if (progressBarActual <= this.threshold1) {
                this.theme = 'red';
                this.themeColor = "color: red";
            } else if (progressBarActual > this.threshold1 && progressBarActual <= this.threshold2) {
                this.theme = 'orange';
                this.themeColor = "color: orange";
            } else {
                this.theme = 'green';
                this.themeColor = "color: green";
            }
			this.circleDegree = progressBarActual * 360;
            this.circleToggle = (this.circleDegree > 179) ? 'container p50plus ' + this.theme + ' ' + this.size : 'container ' + this.theme + ' ' + this.size;
			console.log('this.circleDegree::::',this.circleDegree);
			console.log('this.circleToggle::::',this.circleToggle);
            var barStyle = '-webkit-transform: rotate(' + this.circleDegree + 'deg); -moz-transform: rotate(' + this.circleDegree + 'deg); -ms-transform: rotate(' + this.circleDegree + 'deg); -o-transform: rotate(' + this.circleDegree + 'deg); transform: rotate(' + this.circleDegree + 'deg); -ms-transform: rotate(' + this.circleDegree + 'deg);';
			if(this.circleDegree > 360)
				this.circleDegree = 360;
            // this.template.querySelector('[data-id="barDiv"]').setAttribute("style", barStyle);
			console.log('querySelector end ====> ');
            // return (this.circleDegree > 179) ? 'container p50plus ' + this.theme + ' ' + this.size : 'container ' + this.theme + ' ' + this.size;
			this.showSpinner = false;
        } else {
            console.log('sObjectName ====> ' + this.sObjectName);
            console.log('recordId ====> ' + this.recordId);
            console.log('totalProgressField else ====> ' + this.totalProgressField);
            console.log('actualProgressField else ====> ' + this.actualProgressField);
            this.showSpinner = true;
            this.invokeComputePercentage();
        }
		
    }
    invokeComputePercentage() {
		var progressBarActual;
        computePercentage({
                sObjectName: this.sObjectName,
                recordId: this.recordId,
                totalValueFieldName: this.totalProgressField,
                actualValueFieldName: this.actualProgressField
            })
            .then(result => {
                console.log('result ====> ' + result);
                console.log('result ====> ' + JSON.parse(result));
                console.log('this is a String');
                result = JSON.parse(result);
                console.log('result.total ====> ' + result.total);
                console.log('result actual====> ' + result.actual);
                this.totalProgress = result.total;
                this.actualProgress = result.actual;

                if (parseInt(result.val) < 40) {
                    this.theme = 'red';
                    this.themeColor = "color: red";
                } else if (parseInt(result.val) >= 40 && parseInt(result.val) < 70) {
                    this.theme = 'orange';
                    this.themeColor = "color: orange";
                } else {
                    this.theme = 'green';
                    this.themeColor = "color: green";
                }

                var progressVal = parseInt((result.val / 100) * 360);
                //this.circleDegree = progressVal;
                this.percentText = parseInt(result.val) + '%';

                if (this.totalProgress > 0) {
                    progressBarActual = this.actualProgress / this.totalProgress;
                } else {
                    progressBarActual = 0;
                }
                if (this.totalProgress > 0) {
                    progressBarActual = this.actualProgress / this.totalProgress;
                } else {
                    progressBarActual = 0;
                }
                if(this.mixFormat){
                    if(this.totalProgress == 0 && this.actualProgress > 0){
                        progressBarActual = 100;
                        this.theme = 'green';
                        this.themeColor = "color: green";
                    }
                }
                this.circleDegree = progressBarActual * 360;

                this.circleToggle = (this.circleDegree > 179) ? 'container p50plus ' + this.theme + ' ' + this.size : 'container ' + this.theme + ' ' + this.size;
				if(this.circleDegree > 360)
				this.circleDegree = 360;
                this.showSpinner = false;

            })
            .catch(error => {
                window.console.log(error);
                this.showSpinner = false;
            });
    }
}