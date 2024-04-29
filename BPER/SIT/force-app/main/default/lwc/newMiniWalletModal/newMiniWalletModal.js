//AdF LWC per apertura modale e creazione mini wallet
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import generateMiniWalletName from '@salesforce/apex/newMiniWalletModalController.generateMiniWalletName';
import createMiniWallet from '@salesforce/apex/newMiniWalletModalController.createMiniWallet';
import getSportelliLeggeri from '@salesforce/apex/newMiniWalletModalController.getSportelliLeggeri';
import getMiniWallet from '@salesforce/apex/newMiniWalletModalController.getMiniWallet';
import getReferenti from '@salesforce/apex/newMiniWalletModalController.getReferenti';
import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';

const SPORTELLICOLS = [
    { label: 'Nome Filiale', fieldName: 'Name', hideDefaultActions: true }
];

const REFERENTICOLS = [
    { label: 'Nominativo', fieldName: 'PTF_Gestore_Name__c', hideDefaultActions: true },
    { label: 'Matricola', fieldName: 'PTF_RegistrationNumber__c', hideDefaultActions: true },
    { label: 'Filiale', fieldName: 'PTF_Filiale__c', hideDefaultActions: true },
    { label: 'Macro-modello di servizio', fieldName: 'PTF_ModelloDiServizio__c', hideDefaultActions: true }
];

export default class NewMiniWalletModal extends NavigationMixin(LightningElement) {

    sportelliColumns = SPORTELLICOLS;
    referentiColumns = REFERENTICOLS;
    @api userInfo;
    @api recordId;
    @api title = 'Crea Nuovo Mini Portafoglio';
    @api sportelliTitle = 'Seleziona uno Sportello Leggero';
    @api referentiTitle = 'Seleziona Referenti';
    @api referentePrincipaleTitle = 'Seleziona un Referente Principale';
    @api openmodel = false;
    @api openModalDisabled;
    @track hasSportelliData = false;
    @track hasReferentiData = false;
    @track hasReferentiPrincipaliToSelect = false;
    @api sportelliTableData = [];
    @api sportelliTableDataToCreate = [];
    @api miniWalletTableData = [];
    @api referentiTableData = [];
    @track selectedReferentiTableData = [];
    @track sportelliList = [];
    @track referentiList = [];
    @track referentePrincipaleList = [];
    @track miniWalletId = '';
    @track isSaveDisabled = true;
    @track miniWalletName = '';
    @track labelFiliale;
    @track isRendered =true;

    connectedCallback(){
        this.openModalDisabled = true;
        getUserInfo()
        .then(result => {
            this.userInfo = result;
            console.log('MC getUserInfo', result);
            console.log("MC userInfo.Profile.Name",this.userInfo.Profile.Name);
            
        return generateMiniWalletName({ walletId: this.recordId })
        })
        generateMiniWalletName({ walletId: this.recordId })
            .then(result => {
                console.log('AdF generateMiniWalletName result ' + JSON.stringify(result));
                this.miniWalletName = result;

                return getSportelliLeggeri({ walletId: this.recordId })
            })
            .then(result => {
                console.log('AdF getSportelliLeggeri result ' + JSON.stringify(result));
                this.sportelliTableData = result;

                return getMiniWallet({ walletId: this.recordId })
            })
            .then(result => {
                console.log('AdF getMiniWallet result ' + JSON.stringify(result));
                this.miniWalletTableData = result;
                // if(result && result.length > 0){
                //     this.hasSportelliData = true;

                //     return getReferenti({ walletId: this.recordId })
                // }else{
                //     this.hasSportelliData = false;
                //     this.openModalDisabled = true;
                // }

                return getReferenti({ walletId: this.recordId })

            })
            .then(result => {
                console.log('AdF getReferenti result ' + JSON.stringify(result));
                this.referentiTableData = result;
                this.labelFiliale = result[0].PTF_Filiale__c;
                console.log('* ',result);
                // this.openModalDisabled = false;
                // if(result && result.length > 0){
                //     this.hasReferentiData = true;
                // }
            })
            .catch(error => {
                this.openModalDisabled = true;
                console.error('ConnectedCallback error ' + JSON.stringify(error));
                //this.showToastMessage("Si è verificato un errore", "error");
            }).finally(() => {
                console.log('SV Finally');
                let listaSportelli = this.sportelliTableData;
                console.log('SV Finally listaSportelli', listaSportelli);
                let listaminiWallet = this.miniWalletTableData;
                console.log('SV Finally listaminiWallet', listaminiWallet);
                let listaReferenti = this.referentiTableData;
                console.log('SV Finally listaReferenti', listaReferenti);

                let sportelliToPTFCreate = [];
                if(listaminiWallet.length < listaSportelli.length){
                    this.openModalDisabled = false;
                    console.log('sv DENTRO');

                    listaSportelli.forEach(sportello => {
                        let trovato = false;
                        listaminiWallet.forEach(miniWallet => {
                            if(miniWallet.PTF_SL__c == sportello.Id){
                                trovato = true;
                            }
                        });

                        if(!trovato){
                            sportelliToPTFCreate.push(sportello);
                        }

                        console.log('sv sportelliToPTFCreate', sportelliToPTFCreate);

                    });
                }

                console.log('sv sportelliToPTFCreate', sportelliToPTFCreate);

                this.sportelliTableDataToCreate = sportelliToPTFCreate;

                if(listaReferenti.length > 0){
                    this.hasReferentiData = true;
                }
            });

        //getSportelliLeggeri({ walletId: this.recordId })
        //    .then(result => {
        //        this.sportelliTableData = result;
        //        if(result.length > 0){
        //            this.hasSportelliData = true;
        //        }
        //    })
        //    .catch(error => {
        //        console.error('AdF getSportelliLeggeri error: ' + JSON.stringify(error));
        //    });

        //getReferenti({ walletId: this.recordId })
        //    .then(result => {
        //        this.referentiTableData = result;
        //        if(result.length > 0){
        //            this.hasReferentiData = true;
        //        }
        //    })
        //    .catch(error => {
        //        console.error('AdF getReferenti error: ' + JSON.stringify(error));
        //    });

    }

    //AdF gestisce la creazione del nuovo mini wallet
    handleSave(){
        this.isRendered = false;
        
        if(this.sportelliList.length == 1){
            let creaMiniWallet=false;
            console.log('MC ref principale',this.referentePrincipaleList.length);
            if(this.referentePrincipaleList.length==0  )
            {
                this.showToastMessage("Selezionare un referente principale", "warning");
                this.isRendered = true;
                /*if(this.userInfo.Profile.Name !='System Administrator' ||this.userInfo.Profile.Name !='NEC_D.0')
                {
                    creaMiniWallet=true;
                }else{
                    this.showToastMessage("Selezionare un referente principale", "warning");
                    this.isRendered = true;
                }*/
                
            }
            else
            {
                creaMiniWallet=true;
            }
            if(creaMiniWallet)
            {
                createMiniWallet({miniWalletName: this.miniWalletName, parentWalletId: this.recordId,
                                    sportelliLeggeri: this.sportelliList, referenti: this.referentiList,
                                    referentePrincipaleList: this.referentePrincipaleList})
                    .then(result => {
                        if(result && result != ''){
                            this.miniWalletId = result;
                            this.showToastMessage("Salvataggio effettuato", "success");
                            this.navigateToMiniWalletPage();
                        }else{
                            this.showToastMessage("Creazione miniWallet non completata", "error");
                        }
                    })
                    .catch(error => {
                        this.showToastMessage("Si è verificato un errore", "error");
                        console.error('AdF error: ' + JSON.stringify(error));
                    })
                    .finally(() => {
                        console.log('GB Finally');
            
                        this.isRendered = true;
                        this.openmodel = false;
            
                    });
                } 
                
        }else{
            this.showToastMessage("Seleziona uno sportello leggero", "error");
        }
    }

    //AdF naviga verso il nuovo mini wallet
    navigateToMiniWalletPage() {
        try{
            if(this.miniWalletId != null && this.miniWalletId != ''){
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.miniWalletId,
                        actionName: 'view'
                    },
                });
            }else{
                this.showToastMessage("Non è stato possibile aprire la pagina del nuovo Mini Wallet", "error");
            }
        }catch(error){
            console.error(error);
            this.showToastMessage("Non è stato possibile aprire la pagina del nuovo Mini Wallet", "error");
        }      
    }
    
    openModal() {
        this.openmodel = true;
    }

    closeModal() {
        this.openmodel = false;
        this.selectedReferentiTableData = [];
        this.hasReferentiPrincipaliToSelect = false;
        this.referentiList = [];
        this.sportelliList = [];
        this.isSaveDisabled = true;
        this.referentePrincipaleList = [];
        
    }

    handleSportelliSelection(event) {
        this.sportelliList = event.detail.selectedRows;
        if(this.sportelliList.length == 1){
            this.isSaveDisabled = false;
        }else{
            this.isSaveDisabled = true;
        }
    }

    handleReferentiSelection(event) {
        this.referentiList = event.detail.selectedRows;
        if(this.referentiList.length > 0){
            this.selectedReferentiTableData = this.referentiList;
            this.hasReferentiPrincipaliToSelect = true;
        }else{
            this.selectedReferentiTableData = [];
            this.hasReferentiPrincipaliToSelect = false;
        }
    }

    handleReferentePrincipaleSelection(event) {
        this.referentePrincipaleList = event.detail.selectedRows;
    }

    showToastMessage(text, type) {
        const toastEvent = new ShowToastEvent({
            title: '',
            message: text,
            variant: type
        });
        this.dispatchEvent(toastEvent);
    }

}