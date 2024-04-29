import { LightningElement, api, track } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import init from '@salesforce/apex/CIB_SimulazioniRelazionateController.init';
import clone from '@salesforce/apex/Cib_SimulazioneController.clone';
import deleteSim from '@salesforce/apex/Cib_SimulazioneController.deleteSim';

const actions = [
    { label: 'Clona', name: 'clona' },
    { label: 'Elimina', name: 'elimina' },
];

const columns = [
    { label: 'Numero Simulazione', fieldName: 'PTF_Url', type: 'url', 
    cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
        typeAttributes: {
            label: { fieldName: 'Name' }
        },
        hideDefaultActions: "true"},
    { label: 'Nome Simulazione', fieldName: 'NomeSimulazione__c', type: 'text'},
    { label: 'Importo', fieldName: 'ImportoTotale__c', type: 'number'},
    { label: 'Stato', fieldName: 'CIB_EsitoApprovazione__c', type: 'text'},
    { label: 'RARORAC % *', fieldName: 'Present_RARORAC__c', type: 'percent', typeAttributes: { minimumFractionDigits: '2'}},
    { label: 'RACE % *', fieldName: 'Present_RACE__c', type: 'percent', typeAttributes: { minimumFractionDigits: '2'}},
    { label: 'EVA *', fieldName: 'Present_EVA__c', type: 'number', typeAttributes: { maximumFractionDigits: '0'}},
    { label: 'NOPAT *', fieldName: 'Present_NOPAT__c', type: 'number', typeAttributes: { maximumFractionDigits: '0' }},
    { label: 'RWA Medio %', fieldName: 'RWA_Medio_perc__c', type: 'percent', typeAttributes: { minimumFractionDigits: '2'}},
    { label: 'Data Invio Pricing', fieldName: 'Data_Invio_Pricing__c', type: "date",
        typeAttributes:{
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }
    },
    { label: 'Invia in approvazione', fieldName: 'linkIniviaInApprovazione', type: 'url', 
        cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
        typeAttributes: {
            label: { fieldName: 'sendForApprovalLabel' }
        },
        hideDefaultActions: "true"},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class CibSimulazioniRelazionate extends NavigationMixin(LightningElement) {

    @api recordId;
    @api titolo = 'SIMULAZIONE PRICING';

    @track isLoading = true;
    // @track loaded = false;
    @track isOpenModal = false;
    columns = columns;
    @track simulazioni;

    @track macroSezioniAttive = ['macroSezione1', 'macroSezione2'];
    @track sezioniAttive = ['sezione1', 'sezione2'];

    @track selectedSimulazione;
    connectedCallback(){
        try {
            console.log('DK START CibSimulazioniRelazionate');
            return init({recordId: this.recordId})
            .then(result =>{
                console.log('DK CibSimulazioniRelazionate.init result', result);
                if(result){
                    this.simulazioni = result['simulazioni'];
                    this.simulazioni.forEach(element => {
                        element.PTF_Url = '/' + element.Id;
                        element.Present_RARORAC__c = element.Present_RARORAC__c/100;
                        element.Present_RACE__c = element.Present_RACE__c/100;
                        element.RWA_Medio_perc__c = element.RWA_Medio_perc__c/100;
                        element.linkIniviaInApprovazione = element.Invia_in_approvazione__c ? '/lightning/action/quick/Simulazione__c.Invio_in_approvazione?context=RECORD_DETAIL&recordId=' + element.Id + '&backgroundContext=%2Flightning%2Fr%2FOpportunity__c%2' + element.Opportunity__c + '%2Fview' : '';
                        element.sendForApprovalLabel = element.Invia_in_approvazione__c ? 'Invia in approvazione' : '';
                        element.titolare = element.Owner.Name; 
                        element.gestore = element.Nome_del_Gestore__c; 
                    });
                }
            })
            .catch(err =>{
                console.log('DK CibSimulazioniRelazionate.init.err', JSON.stringify(err));
            })
            .finally(() =>{
                this.isLoading = false;
            })
        } catch (err) {
            console.log('DK connectedCallback.err', err);
        }
    }

    handleSaveSim(){
        console.log('DK START handleSaveSim');
        try {
            //validazione cibSimulazione
            this.template.querySelector("[data-item='cibSimulazione']").handleSave(true)
            .then(result =>{
                if(result){
                    this.closeNdgModal();
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            actionName: 'view'
                        }
                    }); 
                }
                /*this.connectedCallback().then(() =>{
                    this.closeNdgModal();
                });*/
            })            
            .catch(err =>{
                console.log('DK CibSimulazioniRelazionate handleSaveSim err', err.message);
            });
        } catch (err) {
            console.log('DK handleSaveSim.err', JSON.stringify(JSON.parse(err)));
        }
    }

    openModal(){
        this.isOpenModal = true;
    }
    closeNdgModal() {
        this.isOpenModal = false;
    }

    handleRowAction(event) {
        console.log('DK handleRowAction event', event.detail.action.name);
        console.log('DK handleRowAction row', event.detail.row.Id);
        this.isLoading = true;
        if(event.detail.action.name == 'clona'){
            console.log('DK IS CLONE');
            clone({recordId: event.detail.row.Id})
            .then(result =>{
                console.log('DK handleRowAction.clone.result', result);
                if(result){
    
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            actionName: 'view'
                        }
                    });
                }else{
                    const toastEvent = new ShowToastEvent({
                        title: "Attenzione!",
                        message: 'La richiesta non è andata a buon fine.',
                        variant: "warning"
                    });
                    this.dispatchEvent(toastEvent);
                }
            })
            .catch(err =>{
                console.log('DK handleRowAction.clone.err', err.message);
            })
            .finally(() =>{
                this.isLoading = false;
            })
        }else if(event.detail.action.name == 'elimina'){
            console.log('DK IS DELETE');
            deleteSim({recordId: event.detail.row.Id})
            .then(() =>{
                this.connectedCallback();
            })
            .catch(err =>{
                console.log('DK handleRowAction.deleteSim.err', err.message);
                const toastEvent = new ShowToastEvent({
                    title: "Attenzione!",
                    message: 'La richiesta non è andata a buon fine.',
                    variant: "warning"
                });
                this.dispatchEvent(toastEvent);
            })
            .finally(() =>{
                this.isLoading = false;
            })
        }
    }
}