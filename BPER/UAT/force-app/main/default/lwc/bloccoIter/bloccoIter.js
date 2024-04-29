import { LightningElement, api, track } from 'lwc';

import getAllData from '@salesforce/apex/NewMicroWalletController.getAllData';
import getStrutturaBanca from '@salesforce/apex/BloccoIterController.getStrutturaBanca';
import getAccountId from '@salesforce/apex/BloccoIterController.getAccountId';
import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import blockIterUO from '@salesforce/apex/BloccoIterController.blockIterUO';

import updateNDGs from '@salesforce/apex/BloccoIterController.updateNDGs';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import {NavigationMixin} from 'lightning/navigation';
export default class BloccoIter  extends NavigationMixin(LightningElement){

    @api userInfo;
    @api contactInfo;
    @api strBanca;
    @api getAllData;
    @api isRendered;
    @api selectedFiliale;
    @api IDCED;
    @api AccountId;
    @api disabledInput;

    @api labelBanca;
    @api labelDReg;
    @api labelAree;
    @api labelCapofila;

    @api idFiliale;
    @api recTypeFiliale;

    @track note;

    //INPUT CSV
    @api selectedRows = [];
    @api mapWallets = [];
    @api getAllDataCSV;
    @api getAllModelli;

    @track error;
    @track data;
    @track objList;
    @track loaded = true;

    @track numElementi = 0;

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }

    connectedCallback() {

        this.isFromReportPage = true;

        getUserInfo()
        .then(result => {

            console.log('getUserInfo', result);
            this.userInfo = result;

            return getStrutturaBanca()
        })
        .then(result => {

            this.strBanca = result;
            console.log('Struttura Banca(id ced padre) ', this.strBanca[this.userInfo.PTF_IdCEDPadre__c]);


            return getAllData({})
        })
        .then(result => {
            
            this.getAllData = result;
            console.log('Area Utente ', this.userInfo.PTF_IdCEDArea__c);
            console.log('DR Utente ', this.userInfo.PTF_IdCEDDR__c);
            console.log('Tipologia Utente ', this.userInfo.PTF_TipologiaUO__c);


            if (this.userInfo.PTF_TipologiaUO__c == 'AltraUnitaOrganizzativa') {

                if (this.strBanca[this.userInfo.PTF_IdCEDPadre__c].Nome_Livello__c == 'BANCA') {

                    this.IDCED = this.userInfo.PTF_IdCEDPadre__c;

                } else if (this.strBanca[this.userInfo.PTF_IdCEDPadre__c].Nome_Livello__c == 'DIREZIONE TERRITORIALE') {

                    this.IDCED = this.userInfo.PTF_IdCEDDR__c;


                } else if (this.strBanca[this.userInfo.PTF_IdCEDPadre__c].Nome_Livello__c == 'DIREZIONE DI AREA') {

                    this.IDCED = this.userInfo.PTF_IdCEDArea__c;

                }
            }
            if (this.userInfo.PTF_TipologiaUO__c == 'DirezioneRegionale') {

                this.IDCED = this.userInfo.PTF_IdCEDDR__c;


            }
            if (this.userInfo.PTF_TipologiaUO__c == 'Area') {

                this.IDCED = this.userInfo.PTF_IdCEDArea__c;

            }

            
            return getAccountId({idCed: this.IDCED})
        })
        .then(result => {

            this.AccountId = result;
            console.log('AccountId', this.AccountId);

        })
        .catch(error => {
            alert('ERROR');
            this.error = error;
            console.log('ERROR', error);
            this.isRendered = true;
        })
        .finally(() => {

            console.log('FINALLY');

            this.isRendered = true;
        });

    }    

    refreshFiltri() {
        this.idFiliale = '';
        this.selectedFiliale = false;
        this.labelBanca='';
        this.labelCapofila='';
        this.labelDReg='';
        this.labelArea='';
        this.data = null;
    }

    @track selectedUO;

    handleChangeFiliale(uo) {

        try {
            
            this.idFiliale = uo.objId;
            this.recTypeFiliale = uo.obj.RecordTypeName__c;
            this.unitaOrganizzativa = this.getAllData['filialeMap'][this.idFiliale];
            if(this.unitaOrganizzativa != undefined){
                this.selectedFiliale = true;
                this.labelCapofila = this.unitaOrganizzativa.PTF_Capofila__c ? this.getAllData['filialeMap'][this.unitaOrganizzativa.PTF_Capofila__c].Name : null;
                this.labelDReg = this.unitaOrganizzativa.PTF_DirezioneRegionale__c ? this.getAllData['dirRegionaleMap'][this.unitaOrganizzativa.PTF_DirezioneRegionale__c].Name : null;
                this.labelArea = this.unitaOrganizzativa.PTF_Area__c ? this.getAllData['areaMap'][this.unitaOrganizzativa.PTF_Area__c].Name : null;
                this.labelBanca = this.unitaOrganizzativa.PTF_Banca__c ? this.getAllData['bancheMap'][this.unitaOrganizzativa.PTF_Banca__c].Name : null;
            }
        } catch (error) {
            console.log(error);
        }
    }

    handleFilter(event){
        if(event.target.name == 'note'){
            this.note = event.target.value;
        }
    }

    blockIterUO(){
        this.isRendered = false;
        console.log();

        this.selectedUO = this.getAllData['filialeMap'][this.idFiliale] ? this.getAllData['filialeMap'][this.idFiliale] :
        this.getAllData['areaMap'][this.idFiliale] ? this.getAllData['areaMap'][this.idFiliale] :
        this.getAllData['dirRegionaleMap'][this.idFiliale] ? this.getAllData['dirRegionaleMap'][this.idFiliale] :
        this.getAllData['bancheMap'][this.idFiliale];
        blockIterUO({uo: this.selectedUO, recTypeName: this.recTypeFiliale, note: this.note})
        .then(() =>{

            this.isRendered = true;
            const toastEvent = new ShowToastEvent({
                title: "Success!",
                message: "Stiamo Applicando il blocco, riceverai una notifica alla conclsione dell'operazione!!",
                variant: "success"
            });
            this.dispatchEvent(toastEvent);
            this.refreshFiltri();
        })
        .catch(err =>{

            this.isRendered = true;
            console.log(err);
        })
    }
    
    
    get accountFilter() {

        var condition = " PTF_DataChiusura__c = NULL AND IsPTF__c = TRUE) AND (RecordType.DeveloperName = 'Banca' OR RecordType.DeveloperName = 'DirezioneRegionale' OR RecordType.DeveloperName = 'Area' OR RecordType.DeveloperName = 'FilialeDiRelazione'";

        /*if ((this.userInfo.Profile.Name != 'System Administrator' || this.userInfo.Profile.Name != 'Amministratore di sistema')) {

            if (this.userInfo.PTF_TipologiaUO__c == 'AltraUnitaOrganizzativa') {

                if (this.strBanca[this.userInfo.PTF_IdCEDPadre__c].Nome_Livello__c == 'BANCA') {

                    condition += ") AND (PTF_Banca__c =\'" + this.AccountId + "\' OR Id =\'" + this.AccountId + "\'";
                } else if (this.strBanca[this.userInfo.PTF_IdCEDPadre__c].Nome_Livello__c == 'DIREZIONE TERRITORIALE') {

                    condition += ") AND (PTF_DirezioneRegionale__c =\'" + this.AccountId + "\' OR Id =\'" + this.AccountId + "\'";
                } else if (this.strBanca[this.userInfo.PTF_IdCEDPadre__c].Nome_Livello__c == 'DIREZIONE DI AREA') {

                    condition += ") AND (PTF_Area__c =\'" + this.AccountId + "\' OR Id =\'" + this.AccountId + "\'";
                }
            }

            if (this.userInfo.PTF_TipologiaUO__c == 'DirezioneRegionale') {

                condition += ") AND (PTF_DirezioneRegionale__c =\'" + this.AccountId + "\' OR Id =\'" + this.AccountId + "\'";
            }
            if (this.userInfo.PTF_TipologiaUO__c == 'Area') {

                condition += ") AND (PTF_Area__c =\'" + this.AccountId + "\' OR Id =\'" + this.AccountId + "\'";
            }
        }*/

        return condition;
    }

    handleCustomEvent(event) {
        console.log('@@@@@selectedWallet: ' + JSON.stringify(event.detail));

        if (event.detail != null) {
            this.handleChangeFiliale(event.detail);
        } else {
            this.refreshFiltri();
        }

    }


    @track columns = [{
            label: 'Nome',
            fieldName: 'Name',
            type: 'text',
            sortable: false
        },
        {
            label: 'NDG',
            fieldName: 'CRM_NDG__c',
            type: 'text',
            sortable: false
        },
        {
            label: 'Banca',
            fieldName: 'FinServ__BankNumber__c',
            type: 'text',
            sortable: false
        }
    ];

    @track keyList = [];
    @track reader;
    handleUploadFinished(event) {
        // Get the list of uploaded files
        // this.isRendered = !this.isRendered;
        var sal = this;
        const uploadedFiles = event.detail.files;
        this.reader = new FileReader();

        this.reader.readAsText(uploadedFiles[0], "UTF-8");
        this.isRendered = false;
        this.keyList = [];

        //inizio funzione di caricamento file
        this.reader.onload = (event => {

            var csv = event.target.result;
            var rows = csv.split("\n"); //righe

            var trimrow = rows[0].replace(/[^_a-zA-Z0-9 ,]/g, "").split(",");
            console.log("trimrow: ", trimrow);

            var ndgIndex = null;
            var bancaIndex = null;
            for (var i = 0; i < trimrow.length; i++) {
                if (trimrow[i].toLowerCase() === "ndg") {
                    ndgIndex = i;
                }
                if (trimrow[i].toLowerCase() === "banca" || trimrow[i].toLowerCase() === "abi") {
                    bancaIndex = i;
                }
            }

            for (var j = 1; j < rows.length; j++) {
                var cells = rows[j].split(",");
                console.log('CELLE', cells);
                if(ndgIndex != null && bancaIndex != null){
                    let ndg = cells[ndgIndex].replace(/[^a-zA-Z0-9 ,]/g, "");
                    let banca = cells[bancaIndex].replace(/[^a-zA-Z0-9 ,]/g, "");
                    banca = banca.length == 4 ? '0' + banca : banca;
                    this.keyList.push(banca + '_' + ndg)
                }
            }
        });

        this.reader.onloadend = (event => {
            this.openDialog = true;
            this.isRendered = true;
            this.numElementi = this.keyList.length;
        });
    }
    
    updateNDGs(){
        
        console.log('START updateNDGs');
        try {
            
            this.isRendered = false;
            // let selectedNDGRows = this.getSelectedRows('ndgTable');
            
            console.log('keyList', JSON.stringify(this.keyList));
            updateNDGs({ndgBancaList : this.keyList, note: this.note})
            .then(() =>{
                this.openDialog = false;
                this.isRendered = true;
                const toastEvent = new ShowToastEvent({
                    title: "Success!",
                    message: "Stiamo Applicando il blocco, riceverai una notifica alla conclsione dell'operazione!!",
                    variant: "success"
                });
                this.dispatchEvent(toastEvent);
                this.refreshFiltri();
            })
            .catch(err =>{
                console.log(err);
            });
        } catch (error) {
            
            console.log(err);
        }
    }

    getSelectedRows(tableName){

        let table = this.template.querySelector("[data-item='" + tableName + "']");
        if(table){
            return this.template.querySelector("[data-item='" + tableName + "']").getSelectedRows();
        }else {
            return [];
        }
    }

    // START DIALOG
    @track openDialog = false;
    //handles button clicks
    handleClickDialog(event){
        if(event.currentTarget.name == 'cancel'){
            this.openDialog = false;
            // this.handleSaveClicked = false;
        }else{

            this.updateNDGs();
        }
    }
}