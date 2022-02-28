import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc';
import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import SME_CommonCSS from '@salesforce/resourceUrl/SME_CommonCSS';
import getOpportunityList from '@salesforce/apex/SME_PlanProgressCtrl.getOpportunityList';
import { refreshApex } from '@salesforce/apex';

export default class SME_PlanProgressOpportunityTabLWC extends LightningElement {
    @track error;
    @track typeOfOpportunity;
    @track data;
    @track allData;
    @track columns;
    @track currentOppAmount;
    @track prospectOppAmount;
    @track closedWonOppAmount;
    @track sortBy;
    @track sortDirection;
    @track rowOffset = 0;
    @track rowId;
    @track toggleErrorMessage = false;
    @track wiredResults;
    // @api recordId ='a1W2M000003EDRtUAO';
    @api recordId;

    renderedCallback() {

        Promise.all([
                loadStyle(this, SME_CommonCSS + '/SME_CommonCSS.css'),
            ])
            .then(() => {
                console.log('successfully static resource loaded----->');
            })
            .catch(error => {
                alert(error.body.message);
                console.log('error----->', error.body.message);
            });

    }
    @api
    handleParentCmpCall(event) {
        console.log('handleParentCmpCall::::::');
        
    }
    @wire(getOpportunityList, {
        accountPlanId: '$recordId'
    })
    wiredOpportunity(result) {
        if (result.data) {
			this.wiredResults = result;
            this.getCurrentOpportunitySuccess(event, result.data, 'Current');
        } else if (result.error) {
            console.log('Exception----->');
            this.toggleErrorMessage = true;
        }
    }

    getCurrentOpportunitySuccess(event, data, typeOfOpportunity) {
        var opportunityData = this.wiredResults.data;
        var keys = [];
        if (opportunityData.length > 0) {
            for (var k in opportunityData[0]) {
                keys.push(k);
            }
        }
        console.log('Keys' + keys);
        var cols = [];
        cols.push({

            label: 'View',
            type: 'button-icon',
            initialWidth: 75,
            typeAttributes: {
                iconName: 'action:preview',
                title: 'Preview',
                variant: 'border-filled',
                alternativeText: 'View'
            }

        });
        for (var i = 0; i < keys.length; i++) {
            if (keys[i] == 'Name') {
                cols.push({
                    label: 'Opportunity Name',
                    fieldName: keys[i],
                    sortable: true,
                    type: 'text'
                });
            } else if (keys[i] == 'StageName') {
                cols.push({
                    label: 'Stage',
                    fieldName: keys[i],
                    sortable: true,
                    type: 'text'
                });
            } else if (keys[i] == 'Amount') {
                cols.push({
                    label: 'Amount',
                    fieldName: keys[i],
                    sortable: true,
                    type: 'currency'
                });
            } else if (keys[i] !== 'Id' && keys[i] != 'OwnerId') {
                cols.push({
                    label: keys[i],
                    fieldName: keys[i],
                    sortable: true,
                    type: 'text'
                });
            }

        }
        // columns = cols;
        this.columns = [...cols];
        var arr = [];
        var currentOppAmount = 0;
        var prospectOppAmount = 0;
        var closedWonOppAmount = 0;

        for (var i = 0; i < opportunityData.length; i++) {
            var d = opportunityData[i];
            console.log('opportunityData::::' + opportunityData[i]);
            var obj = {};
            obj['Id'] = opportunityData[i].Id;
            for (var j = 0; j < cols.length; j++) {
                var colVal = cols[j].fieldName;
                var val;
                if (colVal == 'Owner') {
                    val = opportunityData[i].Owner.Name;
                } else {
                    val = d[cols[j].fieldName];
                }
                obj[colVal] = val;
            }
			 // if (d.StageName == 'Proposal/Price Quote' || d.StageName == 'Negotiation/Review' ||
                // d.StageName == 'Presented' || d.StageName == 'Solution' ||
                // d.StageName == 'Commitment' || d.StageName == 'Processing') {
                // currentOppAmount += d.Amount;

            // }
			
            if (d.StageName != 'Closed Won' && d.StageName != 'Closed Lost') {
                currentOppAmount += d.Amount;

            } 
			// else if (d.StageName == 'Qualification' || d.StageName == 'Needs Analysis' || d.StageName == 'Value Proposition' ||
                // d.StageName == 'Discovery') {
                // prospectOppAmount += d.Amount;

            // } 
			else if (d.StageName == 'Closed Won') {
                closedWonOppAmount += d.Amount;

            }
            arr.push(obj);

        }
        currentOppAmount = this.convertToDecimal(currentOppAmount);
        closedWonOppAmount = this.convertToDecimal(closedWonOppAmount);
        var oppSum = 'Open Opportunities ($' + currentOppAmount + ')';
        const currentOpp = this.template.querySelector('[data-id="Current"]');
        currentOpp.label = oppSum;

        // oppSum = 'Prospective Opportunities ($'+prospectOppAmount+')';
        // tabLabel= component.find("Prospective").get("v.label");
        // tabLabel[0].set("v.value", oppSum);

        oppSum = 'Closed Won Opportunities ($' + closedWonOppAmount + ')';
        const closedOpp = this.template.querySelector('[data-id="ClosedWon"]');
        closedOpp.label = oppSum;
        // allData = arr;
        this.allData = [...arr];
        // component.set("v.allData", arr);
        this.filterData(event, typeOfOpportunity);

    }
    convertToDecimal(num) {
        var num = Number(num);
        // If not a number, return 0
        if (isNaN(num)) {
            return 0;
        }
        // If there is no decimal, or the decimal is less than 2 digits, toFixed
        if (String(num).split(".").length < 2 || String(num).split(".")[1].length <= 2) {
            num = num.toFixed(2);
        }
        // Return the number
        return this.formatNumber(num);
    }
	
	formatNumber(num) {
	  return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
	}
	
    filterData(event, typeOfOpportunity) {
        var dataObj = [];
        for (var i = 0; i < this.allData.length; i++) {
            var d = this.allData[i];
            if (typeOfOpportunity == 'Current') {
                // if (d.StageName == 'Proposal/Price Quote' || d.StageName == 'Negotiation/Review' ||
                    // d.StageName == 'Presented' || d.StageName == 'Solution' ||
                    // d.StageName == 'Commitment' || d.StageName == 'Processing') {
                    // dataObj.push(this.allData[i]);

                // } 
				if (d.StageName != 'Closed Won' && d.StageName != 'Closed Lost') {
                    dataObj.push(this.allData[i]);

                }
            }
            // else if(typeOfOpportunity=='Prospective'){
            // if(d.StageName == 'Qualification' || d.StageName == 'Needs Analysis' ||d.StageName == 'Value Proposition'
            // ||d.StageName =='Discovery'){

            // dataObj.push(component.get('v.allData')[i]);         
            // }
            // }
            else if (typeOfOpportunity == 'ClosedWon') {
                if (d.StageName == 'Closed Won') {

                    dataObj.push(this.allData[i]);
                }
            }
        }
        // data = dataObj;
        this.data = [...dataObj];
    }
    handleTabClick(event) {
        console.log('handleTabClick::::::', event.target.activeTabValue);
        var activeTabValue = event.target.activeTabValue;
        if (activeTabValue != undefined && activeTabValue != '' & activeTabValue != null)
            this.filterData(event, activeTabValue);
    }
    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.data));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1 : -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.data = parseData;

    }
    handleRowAction(event) {
        const row = event.detail.row;
        this.rowId = row.Id;
        window.open('/' + this.rowId, '_blank');

    }
	@api
	refreshWireMethod() {
        console.log('::::refreshWireMethod::::>>>>>>');
        return refreshApex(this.wiredResults);
    }
}