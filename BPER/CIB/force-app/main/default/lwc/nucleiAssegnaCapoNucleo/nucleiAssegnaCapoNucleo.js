import { LightningElement, api, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getNDG from '@salesforce/apex/NucleiActionController.getNDG';
import assegnaCaponucleo from '@salesforce/apex/NucleiActionController.assegnaCaponucleo';
import { NavigationMixin } from 'lightning/navigation';

import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import getNDG_x from '@salesforce/apex/NucleiAppartenenzaController.getNDG';

export default class NucleiAssegnaCapoNucleo extends NavigationMixin(LightningElement) {

    @track openmodal = false;
    @api recordId;
    @track error;
    account;

    @api userInfo;
    @api profiliAutorizzati;

    @track isFamilyOrPersonal= false;
    @track isGestore = false;
    @track currentAccount;
    @track portafoglio;
    @track primarioId;

    connectedCallback() {
        getUserInfo()
        .then(result => {
            console.log('SV getUserInfo result', result);

            this.userInfo = result;
            if(this.profiliAutorizzati && this.profiliAutorizzati.includes(result.Profile.Name)){
                this.profiloAutorizzatoShow = true;
            } else {
                this.profiloAutorizzatoShow = false;
            }
            console.log('SV profiloAutorizzatoShow', this.profiloAutorizzatoShow);

            return getNDG_x({recordId:this.recordId});
        })
        .then(result => {
            console.log('SV getNDG result', result);

            this.currentAccount = result['account'];
            this.portafoglio = result['portafoglio'];
            this.primarioId = result['primario'] != null ? result['primario'].PTF_Gestore__c : null;

            if(this.currentAccount.ModelloDiServizio__c==='Family' || this.currentAccount.ModelloDiServizio__c==='Personal'){
                this.isFamilyOrPersonal=true;
            }

            if(this.profiloAutorizzatoShow){
                this.isGestore=true;
            } else {
                if(result['primario'] != null && result['primario'].hasOwnProperty('PTF_Gestore__r') && result['primario'].PTF_Gestore__r.hasOwnProperty('PTF_User__c') && result['primario'].PTF_Gestore__r.PTF_User__c === this.userInfo.Id){
                    this.isGestore=true;
                }
            }
            
            
        }).catch(error=>{
            console.log(error);
        });
    }

    
    openModal() {
        getNDG({ recordId: this.recordId }).then(result => {
            console.log('EDB getNDG', result);
            this.account = result;
            if (this.account.PTF_Caponucleo__c) {
                const x = new ShowToastEvent({
                    "title": "Warning!",
                    "variant": "warning",
                    "message": "Risulta già essere caponucleo"
                });
                this.dispatchEvent(x);
            }
            else if (this.account.PTF_Nucleo__c==undefined) {
                const x = new ShowToastEvent({
                    "title": "Warning!",
                    "variant": "warning",
                    "message": "Nessun nucleo associato"
                });
                this.dispatchEvent(x);
            }
            else if (this.account.RecordType.DeveloperName=='Cointestazione') {
                const x = new ShowToastEvent({
                    "title": "Warning!",
                    "variant": "warning",
                    "message": "Una cointestazione non può essere caponucleo"
                });
                this.dispatchEvent(x);
            }
            else {
                this.openmodal = true;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('EDB ERROR', error);
            const x = new ShowToastEvent({
                "title": "Errore!",
                "variant": "error",
                "message": this.error.body.message
            });
            this.dispatchEvent(x);
            this.openmodal = false;
        })
        .finally(() => {
            console.log('EDB FINALLY');
        }); 
    }

    closeModal() {
        this.openmodal = false;
    }

    assegna() {
        assegnaCaponucleo({ rec: this.account }).then(result => {
            console.log('EDB getNDG', result);
            this.account = result;
            const x = new ShowToastEvent({
                "title": "Successo!",
                "variant": "success",
                "message": "NDG diventato caponucleo"
            });
            this.dispatchEvent(x);
            this.openmodal = false;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Account', // objectApiName is optional
                    actionName: 'view'
                }
            });
        })
        .catch(error => {
            this.error = error;
            console.log('EDB ERROR', error);
            const x = new ShowToastEvent({
                "title": "Errore!",
                "variant": "error",
                "message": this.error.body.message
            });
            this.dispatchEvent(x);
            this.openmodal = false;
        })
        .finally(() => {
            console.log('EDB FINALLY');
        });
    }
}