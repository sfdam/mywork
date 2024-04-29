import { LightningElement, track, api, wire } from 'lwc';
import getNdgOFS from '@salesforce/apex/indicatoriKPI_Controller.getNdgOFS';

export default class IndicatoriKPI extends LightningElement {

    @api recordId;
    @api ndgOFS;
    @track isOFS;
    @api colorCircle;
    @api titleIndicatori;
     
   
    connectedCallback(){

        getNdgOFS({recId: this.recordId})
        .then(result =>{
            console.log('GR recordId: ', this.recordId);
            console.log('GR result: ', result);
            this.ndgOFS = result;
        }).catch(error =>{
            console.log('GR error: ' + error);
        }).finally(() => {
            console.log('GR ndgOFS:', this.ndgOFS);
            if(this.ndgOFS){
                this.isOFS = 'Si';
                this.colorCircle = 'indicator indicator-red';
            }else{
                this.isOFS = 'No';
                this.colorCircle = 'indicator indicator-green';
            }
        });

    }
}