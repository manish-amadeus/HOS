/*eslint-disable no-console */
import { LightningElement,track,api } from 'lwc';
import ChartJS from '@salesforce/resourceUrl/ChartJS';
import { loadScript } from 'lightning/platformResourceLoader';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class SME_ChartJS extends LightningElement {
@track charterr;
@api chartinti=false;
@api titlename;
@api chartdata;
@api labelset;
@api headerdata;


renderedCallback(){
    if(this.chartinti){
        return;
    }
this.chartinti=true;
 Promise.all([
     loadScript(this,ChartJS)

 ]).then(()=>{
     this.error=undefined;
     this.createGraph();
 })
 .catch(error=>{
     this.error=error;
     this.dispatchEvent(
         new ShowToastEvent({
             title:'Error!!',
             message: error.message,
             variant:'error',
         }),
     );
 });
}
createGraph(){
    var ctx= this.template.querySelector(".mdfchart");
    
     var barChart = new Chart(ctx,{
          type:'pie',
            data:{
             labels: this.labelset,
             datasets:[{
                 fill:true,
                 backgroundColor:["#3e95cd", "#8e5ea2","#3cba9f", "#F9E79F", "#117A65", "#D35400", "#6E2C00", "#784212", "#E8F8F5", "#117A65", "#7FB3D5", "#9B59B6"],
                 data:this.chartdata
                
                }]
           },
           
           options:{
            legend: {
                display: true
            },
            tooltips: {
                callbacks: {
                    // this callback is used to create the tooltip label
                    label: function(tooltipItem, data) {
                        // get the data label and data value to display
                        // convert the data value to local string so it uses a comma seperated number
                        var dataLabel = data.labels[tooltipItem.index];
                        var value = ': $ ' + data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toLocaleString();
                        
                        // make this isn't a multi-line label (e.g. [["label 1 - line 1, "line 2, ], [etc...]])
                        if (Chart.helpers.isArray(dataLabel)) {
                            // show value on first line of multiline label
                            // need to clone because we are changing the value
                            dataLabel = dataLabel.slice();
                            dataLabel[0] += value;
                        } else {
                            dataLabel += value;
                            //dataLabel =  dataLabel;
                        }
                        
                        // return the text to display on the tooltip
                        return dataLabel;
                    }
                }
            }
        }


        //   mychart=new chartjs(ctx,{
        //   type:'pie',
       //    data:data,
       //    options:options
       });
 
   
       console.log('headerdata'+JSON.stringify(this.headerdata));
    }
}