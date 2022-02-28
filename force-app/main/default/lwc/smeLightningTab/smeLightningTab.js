import {LightningElement, track,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


const columnsFR=[
    {
        label: 'View', type: 'button-icon', initialWidth: 35, typeAttributes: { label: '', name: 'view_details', iconName: 'utility:preview',  title: 'Click to View Details'},
    },
    {
        label: 'Edit', type: 'button-icon', initialWidth: 35, typeAttributes: { label: '', name: 'edit_record', iconName: 'utility:edit',  title: 'Click to edit record'},
    },
    {
        label:'Fund Request',fieldName:'Title',type: 'text',sortable : true
    },
    {
        label:'Budget',fieldName:'BudgetTitle',type: 'text',sortable : true
    },
    {
        label:'Allocation',fieldName:'AllocationTitle',type: 'text',sortable : true
    },
    {
        label:'Req. Amount',fieldName:'RequestedAmount',type: 'currency'
    },
    {
        label:'Approved Amount',fieldName:'Amount',type: 'currency'
    },
    {
        label:'Status',fieldName:'Status',type:'text'
    }
]

const columnsFC=[
    {
        label: 'View',  type: 'button-icon', initialWidth:35, typeAttributes: { label: 'View', name: 'view_details',  iconName: 'utility:preview', title: 'Click to View Details'}
    },
    {
        label: 'Edit', type: 'button-icon', initialWidth: 35, typeAttributes: { label: '', name: 'edit_record', iconName: 'utility:edit',  title: 'Click to edit record'},
    },
    
    {
        label:'Fund Claim',fieldName:'Title',type: 'text',sortable : true
    },
    {
        label:'Budget',fieldName:'BudgetTitle',type: 'text'
    },
    {
        label:'Request',fieldName:'FundRequestTitle',type: 'text',sortable : true
    },
    {
        label:'Claim Amount',fieldName:'Amount',type: 'currency'
    },
    {
        label:'Status',fieldName:'Status',type:'text'
    }
]

export default class DataTableWithSortingInLWC extends NavigationMixin(LightningElement) { 
    // reactive variable
    @track columnsFR=columnsFR;
    @track columnsFC = columnsFC;
    @api tabledata;   
    @track sortBy;
    @track sortDirection;
	@track value;
	@api pfrequeststatus;
	@api PFClaimStatus;
    @track pickListvalues;
    @api columns;
    @api titlename;
    @api fundrequestlist;
    @api alldata;
	
	

	
  
	handleTabClick(event) {
        var temptableData=[];
        var columnTemp =[];
         
         console.log('remove columns::::::', JSON.stringify(columnTemp));
         
       
        console.log('handleTabClick::::::', event.target.activeTabValue);
        var activeTabValue = event.target.activeTabValue;
        if (activeTabValue != undefined && activeTabValue != '' & activeTabValue != null){
            //console.log('Perform some action:::');
            if(event.target.activeTabValue != 'Pending'){
                for(var i=0;i<this.columns.length;i++){
                    if(this.columns[i].label != 'Edit'){
                       columnTemp.push(this.columns[i]);
                    }
                }
                console.log('remove columns::::::', JSON.stringify(columnTemp));
                this.columns = columnTemp;
            }else{
                if(this.titlename === 'Fund Requests:'){
                    this.columns = this.columnsFR;
                }else{
                    this.columns = this.columnsFC;
                }
                
            }
            for(var i=0;i<this.alldata.length;i++){
                if(event.target.activeTabValue === 'Pending'){

                    if(this.alldata[i].Status === 'Draft' ||this.alldata[i].Status === 'Submitted'){
                        temptableData.push(this.alldata[i]);
                    }
                }
                else if(event.target.activeTabValue === this.alldata[i].Status){
                    temptableData.push(this.alldata[i]);
                }
            }
            this.tabledata = temptableData;
        }
            
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
        let parseData = JSON.parse(JSON.stringify(this.tabledata));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.tabledata = parseData;

    }
    handleRowAction(event) {
        
        const actionName = event.detail.action.name;
        console.log(actionName);
        const row = event.detail.row;
        switch (actionName) {
            case 'edit_record':
                this.editRow(row);
                break;
            case 'view_details':
                this.showRowDetails(row);
                break;
            default:
        }
    }
    showRowDetails(row){
       
        console.log('#######'+JSON.stringify(row));
        const selectedEvent = new CustomEvent('rowselected', { detail: {selectedrow:row} });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
       
    }
    editRow(row){
        const selectedEvent = new CustomEvent('editrowselected', { detail: {selectedrow:row} });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

}