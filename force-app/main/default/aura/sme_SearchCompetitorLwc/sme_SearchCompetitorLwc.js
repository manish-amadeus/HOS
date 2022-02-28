import { LightningElement, wire,
    api,
    track } from 'lwc';
    import fetchCAList from '@salesforce/apex/SME_CompetitiveAnalysisCtrl.fetchCAList';
export default class Sme_SearchCompetitorLwc extends LightningElement {
    @track issearching= false;
    @api caList;
    @track caId;
    @track caListValue=false;
    @api accPlanId;
    @track searchText='';
    @track toggleErrorMessage= false;
     
    //@track queryTerm;
    @api recordId;

    connectedCallback() {
        // initialize component
        console.log('caList',this.caList);
        this.searchText='';
        if(this.caList != null && this.caList !='undefined' && this.caList !='' && this.caList != undefined){
            this.caListValue=true;
        }
        else{
            this.caListValue=false;
        }
        console.log('caListValue',this.caListValue);
        //this.getCAList();
        
    }
   /* @wire(fetchCAList, {
        searchKeyWord: '',
            accPlanId: '$accPlanId'
        
    })
    wiredfetchCAList({
        error,
        data
    }) {
        //console.log('data=>',data);
        if (data) {
            if (data == null) {
                alert('Data',JSON.stringify(data));
                this.toggleErrorMessage = true;
            }
            this.caList=data;
            //alert('data2',JSON.stringify(data));
            //this.caId=data[0].Id;
            console.log('caList',JSON.stringify(this.caList));
            this.caListValue=true;
        } else if (error) {
            console.log('Exception----->');
            this.toggleErrorMessage = true;
            this.caListValue=false;
        }
    }*/
    handleClick(event) {
        console.log('clicked',event.target.value);
        
        //const caId=event.detail.id;
        const selectEvt= new CustomEvent('handclickevent',{detail: {SelectedCAId:event.target.value}});
        this.dispatchEvent(selectEvt);
        
      }
      handleKeyUp(event) {
        this.searchText= this.template.querySelector('[data-id="entersearch"]').value;
        //var queryTerm=event.target.value;
        console.log('searchText ',this.searchText);
        this.issearching= true;
        
        setTimeout(function() {
            this.issearching= false;
        }, 1000);
        this.SearchHelper();
    }
    SearchHelper(){
        fetchCAList({ searchKeyWord : this.searchText, accPlanId: this.accPlanId })
    .then(result => {
        if(result!=null){
            this.showSpinner = false;
            this.issearching= false;
            this.caList=result;
            
        }
    })
}
}