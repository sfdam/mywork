import { LightningElement, api, track } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import init from '@salesforce/apex/CIB_SimulatoreController.init';
import clone from '@salesforce/apex/Cib_SimulazioneController.clone';
import deleteSim from '@salesforce/apex/Cib_SimulazioneController.deleteSim';

import SimulatorePrincingIntro from '@salesforce/label/c.SimulatorePrincingIntro';

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
    { label: 'Nome Account', fieldName: 'accountName', type: 'text'},
    { label: 'Importo', fieldName: 'ImportoTotale__c', type: 'number'},
    { label: 'Stato', fieldName: 'CIB_EsitoApprovazione__c', type: 'text'},
    { label: 'RARORAC % *', fieldName: 'Present_RARORAC__c', type: 'percent', typeAttributes: { minimumFractionDigits: '2'}},
    { label: 'RACE % *', fieldName: 'Present_RACE__c', type: 'percent', typeAttributes: { minimumFractionDigits: '2'}},
    { label: 'EVA *', fieldName: 'Present_EVA__c', type: 'number', typeAttributes: { maximumFractionDigits: '0'}},
    { label: 'NOPAT *', fieldName: 'Present_NOPAT__c', type: 'number', typeAttributes: { maximumFractionDigits: '0' }},
    { label: 'RWA Medio %', fieldName: 'RWA_Medio_perc__c', type: 'percent', typeAttributes: { minimumFractionDigits: '2'}},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];
export default class CibSimulatore extends NavigationMixin(LightningElement) {
    @api titolo = 'SIMULAZIONE PRICING';

    @track isLoading = true;
    // @track loaded = false;
    @track isOpenModal = false;
    columns = columns;
    @track simulazioni;

    //Anagrafica
    @track ndgId
    @track ndg;

    @track macroSezioniAttive = ['macroSezione1', 'macroSezione2'];
    @track sezioniAttive = ['sezione1', 'sezione2'];

    @track selectedSimulazione;

    label = {
        SimulatorePrincingIntro
    }

    @track whereCondition;
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
                        element.accountName = element.Opportunity__r && element.Opportunity__r.Account ? element.Opportunity__r.Account.Name : element.Account__r ? element.Account__r.Name : null;
                        element.Present_RARORAC__c = element.Present_RARORAC__c/100;
                        element.Present_RACE__c = element.Present_RACE__c/100;
                        element.RWA_Medio_perc__c = element.RWA_Medio_perc__c/100;
                        element.linkIniviaInApprovazione = element.Invia_in_approvazione__c ? '/lightning/action/quick/Simulazione__c.Invio_in_approvazione?context=RECORD_DETAIL&recordId=' + element.Id + '&backgroundContext=%2Flightning%2Fr%2FOpportunity__c%2' + element.Opportunity__c + '%2Fview' : '';
                        element.sendForApprovalLabel = element.Invia_in_approvazione__c ? 'Invia in approvazione' : '';
                        element.titolare = element.Owner.Name;
                        element.gestore = element.Nome_del_Gestore__c;
                    });

                    this.whereCondition = "RecordTypeId = '" + result['recTypeBusiness'] + "'"
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
        this.firstStep = true;
        this.secondStep = false;
        this.ndg = null;
        this.ndgId = null;
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

    @track firstStep = true;
    @track secondStep = false;
    handleNextStep(event){
        this.firstStep = false;
        this.secondStep = true;
        console.log('DK ndgId', this.ndgId);
    }
    handlePrevStep(event){
        this.firstStep = true;
        this.secondStep = false;
    }

    handleSetNDG(event) {
        console.log('DK CibSimulazione selected NDG: '+JSON.stringify(event.detail)); 
        this.ndg = event.detail;
        this.ndgId = event.detail !== null ? event.detail.objId : null;
        console.log('DK CibSimulazione selected NDG: '+ this.ndgId); 
    }

}