import { LightningElement, track, wire } from 'lwc';
import getDataBaseclientiTable from '@salesforce/apex/WGC_Chart_Controller.getDataBaseclientiTable';
 
export default class Wgc_base_clienti_tab extends LightningElement {

    months = [{label: '01'}, {label: '02'}, {label: '03'}, {label: '04'}, {label: '05'}, {label: '06'}, {label: '07'}, {label: '08'}, {label: '09'}, {label: '10'}, {label: '11'}, {label: '12'}];

    @track exClienti = [ { value: 0, value_OP: 0, isFirst: true, mese: '01' }, { value: 0, value_OP: 0, mese: '02' }, { value: 0, value_OP: 0, mese: '03' }, { value: 0, value_OP: 0, mese: '04' }, { value: 0, value_OP: 0, mese: '05' }, { value: 0, value_OP: 0, mese: '06' }, { value: 0, value_OP: 0, mese: '07' }, { value: 0, value_OP: 0, mese: '08' }, { value: 0, value_OP: 0, mese: '09' }, { value: 0, value_OP: 0, mese: '10' }, { value: 0, value_OP: 0, mese: '11' }, { value: 0, value_OP: 0, mese: '12' }];

    @track contenzioso = [ { value: 0, value_OP: 0, isFirst: true, mese: '01' }, { value: 0, value_OP: 0, mese: '02' }, { value: 0, value_OP: 0, mese: '03' }, {value: 0, value_OP: 0, mese: '04'}, { value: 0, value_OP: 0, mese: '05' }, { value: 0, value_OP: 0, mese: '06' }, { value: 0, value_OP: 0, mese: '07' }, { value: 0, value_OP: 0, mese: '08' }, { value: 0, value_OP: 0, mese: '09' }, { value: 0, value_OP: 0, mese: '10' }, { value: 0, value_OP: 0, mese: '11' }, { value: 0, value_OP: 0, mese: '12' }];

    @track inattivi = [ { value: 0, value_OP: 0, isFirst: true, mese: '01' }, { value: 0, value_OP: 0, mese: '02' }, { value: 0, value_OP: 0, mese: '03' }, {value: 0, value_OP: 0, mese: '04'}, { value: 0, value_OP: 0, mese: '05' }, { value: 0, value_OP: 0, mese: '06' }, { value: 0, value_OP: 0, mese: '07' }, { value: 0, value_OP: 0, mese: '08' }, { value: 0, value_OP: 0, mese: '09' }, { value: 0, value_OP: 0, mese: '10' }, { value: 0, value_OP: 0, mese: '11' }, { value: 0, value_OP: 0, mese: '12' }];

    @track dormienti = [ { value: 0, value_OP: 0, isFirst: true, mese: '01' }, { value: 0, value_OP: 0, mese: '02' }, { value: 0, value_OP: 0, mese: '03' }, {value: 0, value_OP: 0, mese: '04'}, { value: 0, value_OP: 0, mese: '05' }, { value: 0, value_OP: 0, mese: '06' }, { value: 0, value_OP: 0, mese: '07' }, { value: 0, value_OP: 0, mese: '08' }, { value: 0, value_OP: 0, mese: '09' }, { value: 0, value_OP: 0, mese: '10' }, { value: 0, value_OP: 0, mese: '11' }, { value: 0, value_OP: 0, mese: '12' }];

    @track inAttivazione = [ { value: 0, value_OP: 0, isFirst: true, mese: '01' }, { value: 0, value_OP: 0, mese: '02' }, { value: 0, value_OP: 0, mese: '03' }, {value: 0, value_OP: 0, mese: '04'}, { value: 0, value_OP: 0, mese: '05' }, { value: 0, value_OP: 0, mese: '06' }, { value: 0, value_OP: 0, mese: '07' }, { value: 0, value_OP: 0, mese: '08' }, { value: 0, value_OP: 0, mese: '09' }, { value: 0, value_OP: 0, mese: '10' }, { value: 0, value_OP: 0, mese: '11' }, { value: 0, value_OP: 0, mese: '12' }];

    @track attivi = [ { value: 0, value_OP: 0, isFirst: true, mese: '01' }, { value: 0, value_OP: 0, mese: '02' }, { value: 0, value_OP: 0, mese: '03' }, {value: 0, value_OP: 0, mese: '04'}, { value: 0, value_OP: 0, mese: '05' }, { value: 0, value_OP: 0, mese: '06' }, { value: 0, value_OP: 0, mese: '07' }, { value: 0, value_OP: 0, mese: '08' }, { value: 0, value_OP: 0, mese: '09' }, { value: 0, value_OP: 0, mese: '10' }, { value: 0, value_OP: 0, mese: '11' }, { value: 0, value_OP: 0, mese: '12' }];

    @track incerti = [ { value: 0, value_OP: 0, isFirst: true, mese: '01' }, { value: 0, value_OP: 0, mese: '02' }, { value: 0, value_OP: 0, mese: '03' }, {value: 0, value_OP: 0, mese: '04'}, { value: 0, value_OP: 0, mese: '05' }, { value: 0, value_OP: 0, mese: '06' }, { value: 0, value_OP: 0, mese: '07' }, { value: 0, value_OP: 0, mese: '08' }, { value: 0, value_OP: 0, mese: '09' }, { value: 0, value_OP: 0, mese: '10' }, { value: 0, value_OP: 0, mese: '11' }, { value: 0, value_OP: 0, mese: '12' }];

    @wire(getDataBaseclientiTable, {})
    getDataFunction({ error, data }){
        if(data){
            data.forEach(d => {
                if(d.Base_clienti__c == '1.Ex clienti'){
                    if(d.FlagOperativo__c)
                        this.exClienti.find(m => { return m.mese == d.Mese__c; }).value_OP++;
                    else
                        this.exClienti.find(m => { return m.mese == d.Mese__c; }).value++;
                }
                if(d.Base_clienti__c == '2.SPS Contenzioso'){
                    if(d.FlagOperativo__c)
                        this.contenzioso.find(m => { return m.mese == d.Mese__c; }).value_OP++;
                    else
                        this.contenzioso.find(m => { return m.mese == d.Mese__c; }).value++;
                }
                if(d.Base_clienti__c == '3.Inattivi'){
                    if(d.FlagOperativo__c)
                        this.inattivi.find(m => { return m.mese == d.Mese__c; }).value_OP++;
                    else
                        this.inattivi.find(m => { return m.mese == d.Mese__c; }).value++;
                }
                if(d.Base_clienti__c == '4.Dormienti'){
                    if(d.FlagOperativo__c)
                        this.dormienti.find(m => { return m.mese == d.Mese__c; }).value_OP++;
                    else
                        this.dormienti.find(m => { return m.mese == d.Mese__c; }).value++;
                }
                if(d.Base_clienti__c == '5.In Attivazione'){
                    if(d.FlagOperativo__c)
                        this.inAttivazione.find(m => { return m.mese == d.Mese__c; }).value_OP++;
                    else
                        this.inAttivazione.find(m => { return m.mese == d.Mese__c; }).value++;
                }
                if(d.Base_clienti__c == '6.Attivi'){
                    if(d.FlagOperativo__c)
                        this.attivi.find(m => { return m.mese == d.Mese__c; }).value_OP++;
                    else
                        this.attivi.find(m => { return m.mese == d.Mese__c; }).value++;
                }
                if(d.Base_clienti__c == '7.Incerti'){
                    if(d.FlagOperativo__c)
                        this.incerti.find(m => { return m.mese == d.Mese__c; }).value_OP++;
                    else
                        this.incerti.find(m => { return m.mese == d.Mese__c; }).value++;
                }
            });
        }

        if(error){
            console.log('@@@ error ' , error);
        }
    }
}