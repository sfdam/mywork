import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import calcolaIrr from '@salesforce/apex/WGC_PC_CartController.callCalcolaIRR';

const mappingLabel = [
    {label: 'Mesi', fieldName: 'pNrMese', order: 0},
    {label: 'Giorni', fieldName: 'pNgGiorni', order: 1},
    {label: 'Data', fieldName: 'pData', order: 2},
    {label: 'Tasso interesse attivo', fieldName: 'pTasso', order: 3},
    {label: 'Interessi attivi (€)', fieldName: 'pInteressiMaturati', order: 4},
    {label: 'Interessi attivi cumulati (€)', fieldName: 'pInteressiCumul', order: 5},
    {label: 'Valore credito (VN + interessi) (€)', fieldName: 'pVNInteressi', order: 6},
    {label: 'Prezzo al momento della cessione (€)', fieldName: 'pPrezzoRata1', order: 7},
    {label: 'Prezzo differito I tranche (€)', fieldName: 'pPrezzoRata2', order: 8},
    {label: 'Costo notaio e imposta registro (€)', fieldName: 'pCostoNotaio', order: 9},
    {label: 'Costo contenzioso (€)', fieldName: 'pCostoContenz', order: 10},
    {label: 'Costo UL (€)', fieldName: 'pCostoUL', order: 11},
    {label: 'Flussi incasso (€)', fieldName: 'pIncassi', order: 12},
    {label: 'Interessi passivi prezzo al momento della cessione (€)', fieldName: 'pIntPassiviRata1', order: 13},
    {label: 'Interessi passivi prezzo differito I tranche (€)', fieldName: 'PIntpassiviRata2', order: 14},
    {label: 'TOTALE FLUSSI NETTI (€)', fieldName: 'pFlussoNetto', order: 15}
];

const formatter = new Intl.NumberFormat('it-IT', {
    style: 'currency',
    currency: 'EUR'
});

export default class Wgc_pc_cart_modal_irr extends LightningElement {
    @api recordId;
    @api recordTypeId;

    @track privateCreditoId;
    @track rendered = false;
    @track irr;

    //DATATABLE
    @track data = [];
    @track columns;

    connectedCallback(){
        loadStyle(this, cssCartPC);
    }

    renderedCallback(){

    }

    /* GETTER & SETTER */
    @api
    get creditoId(){
        return this.privateCreditoId;
    }

    set creditoId(id){
        console.log('@@@ id ' , id);
        this.privateCreditoId = id;
        this.initialize();
    }
    /* GETTER & SETTER */

    /* FUNCTIONS */
    initialize(){
        calcolaIrr({ creditoId: this.creditoId })
        .then(r => {
            console.log('@@@ result Irr ' , r);
            this.rendered = true;
            if(r.success){
                let payload = JSON.parse(r.data[0]).payload;                
                console.log('@@@ payload ' , payload);

                //get columns
                let cols = [];                
                cols.push({label: '', fieldName: 'desc', initialWidth: 350,type: "text",cellAttributes: {class: {fieldName: 'isBold'}}});
                payload.elencoCrediti[0].righe.forEach((c, index) =>{
                    cols.push({
                        label: '',                        
                        type: "text",
                        fieldName: index,
                        cellAttributes: {class: {fieldName: 'isBold'}}
                    });  
                });

                this.columns = cols;
                
                let descs = Object.keys(payload.elencoCrediti[0].righe[0]);
                var listData = [];
                descs.forEach(d => {                   
                    let dataObj = {};
                    dataObj.desc = mappingLabel.find(l => { return l.fieldName == d; }).label;
                    dataObj.order = mappingLabel.find(l => { return l.fieldName == d; }).order;
                    payload.elencoCrediti[0].righe.forEach((r, ind) => {
                        for(var key in r){
                            if(d == key){
                                if(dataObj.desc == 'Data'){
                                    dataObj[ind] = new Date(r[key]).toLocaleDateString('it-IT', { year: 'numeric', month: '2-digit', day: '2-digit'});                                   
                                } else if (dataObj.desc !='Giorni' && dataObj.desc != 'Mesi' && dataObj.desc != 'Tasso interesse attivo'){
                                    dataObj[ind] = formatter.format(r[key]);                                    
                                } else if (dataObj.desc == 'Tasso interesse attivo'){
                                    dataObj[ind] = Number(r[key]/100).toLocaleString(undefined,{style: 'percent', minimumFractionDigits:2});
                                } else if (dataObj.desc == 'Mesi'){
                                    if (r[key] == undefined){
                                        dataObj[ind] = '';
                                    }else {
                                        dataObj[ind] = r[key].toString();
                                    }
                                } else if (dataObj.desc == 'Giorni'){
                                    if (r[key] == 0){
                                        dataObj[ind] = '';
                                    }else {
                                        dataObj[ind] = r[key].toString();
                                    }
                                } else {                                    
                                    if (r[key] != undefined){
                                        dataObj[ind] = r[key].toString();
                                    }else {
                                        dataObj[ind] = '';
                                    }                                    
                                }
                            }
                        }
                    }); 

                    if (dataObj.order == 2 || dataObj.order == 15){
                        dataObj.isBold = 'is-bold';  
                    }                                         
                    console.log(JSON.stringify(dataObj));
                    listData.push(dataObj);
                });

                listData.sort(function(a, b) { 
                    return a.order - b.order;
                });
                this.data = listData; 

                console.log('@@@ data ' , JSON.stringify(this.data));
              
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERRORE',
                        message: r.message,
                        variant: 'error'
                    })
                )               
            }
        })
        .catch(err => {
            console.log('@@@ err service ' , err);
        });
    }

    /* FUNCTIONS */

    /* EVENT HANDLERS */
    confirm(event){
        const closeModal = new CustomEvent('closesubmodal');
        this.dispatchEvent(closeModal);
    }
    /* EVENT HANDLERS */
}