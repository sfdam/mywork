import { LightningElement, api } from 'lwc';

export default class TabellaIndicatoriCommerciali extends LightningElement {

    areTableVisible = true;

        showTable(event){
        this.areTableVisible = !this.areTableVisible;
    }

    
}