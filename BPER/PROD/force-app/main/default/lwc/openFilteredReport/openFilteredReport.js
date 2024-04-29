import {LightningElement,api} from 'lwc';

import getAllData from '@salesforce/apex/NewMicroWalletController.getAllData';
import getIdCedFiliale from '@salesforce/apex/openFilteredReportController.getIdCedFiliale';
import getStrutturaBanca from '@salesforce/apex/openFilteredReportController.getStrutturaBanca';
import getReportName from '@salesforce/apex/openFilteredReportController.getReportName';
import getReportId from '@salesforce/apex/openFilteredReportController.getReportId';
import getAccountId from '@salesforce/apex/openFilteredReportController.getAccountId';
import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
import getContactInfo from '@salesforce/apex/openFilteredReportController.getContactInfo';



// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import {NavigationMixin} from 'lightning/navigation';

export default class OpenFilteredReport extends NavigationMixin(LightningElement) {


    @api userInfo;
    @api contactInfo;
    @api strBanca;
    @api reports;
    @api idReport;
    @api valueReport;
    @api recordId;
    @api getAllData;
    @api isRendered;
    @api selectedFiliale;
    @api optionsFilialeAll;
    @api IDCEDFILIALE;
    @api IDCED;
    @api AccountId;
    @api disabledInput;
    @api isSuperUser;
    @api groupButtonFilled = false;

    @api labelBanca;
    @api labelDReg;
    @api labelAree;
    @api labelCapofila;
    

    connectedCallback() {

        this.isFromReportPage = true;

        getContactInfo()
            .then(result => {

            this.contactInfo = result;

            return getUserInfo()

            })
            .then(result => {

                console.log('getUserInfo', result);
                this.userInfo = result;

                if (this.userInfo.Profile.Name == 'System Administrator' || this.userInfo.Profile.Name == 'Amministratore di sistema' || this.contactInfo.PTF_IsSuperuser__c == true) {

                    this.isSuperUser = true;
                }


                return getStrutturaBanca()
            })
            .then(result => {

                this.strBanca = result;
                console.log('Struttura Banca(id ced padre) ', this.strBanca[this.userInfo.PTF_IdCEDPadre__c]);


                return getAllData({})
            })
            .then(result => {

                console.log('getAllData result', result);

                this.getAllData = result;

                return getReportName()

            })
            .then(result => {
                
                this.reports = result;
                
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

    get optionsReports() {
        
        let reportsName = this.reports;
        let objList = [];

        for (let k in reportsName) {
            let obj = {};
            obj.label = reportsName[k].Nome_Report__c;
            obj.value = reportsName[k].DeveloperName;
            obj.Id = reportsName[k].Id;
            objList.push(obj);
        }

        console.log('GB getReportName result', objList);

        return objList;
    }

    

    handleChangeReport(event) {
        this.valueReport = event.detail.value;
        console.log('VALORE REPORT ', this.valueReport);

        

    }


    refreshFiltri() {
        this.valueFiliale = '';
        this.selectedFiliale = false;
        this.labelBanca='';
        this.labelCapofila='';
        this.labelDReg='';
        this.labelArea='';
    }

    handleChangeFiliale(idFiliale) {
        console.log('handleChangeFiliale ', idFiliale);
        this.valueFiliale = idFiliale;
        let filiale = this.getAllData['filialeMap'][this.valueFiliale];
        if(filiale != undefined){
            this.selectedFiliale = true;
            this.labelCapofila = filiale.PTF_Capofila__c ? this.getAllData['filialeMap'][filiale.PTF_Capofila__c].Name : null;
            this.labelDReg = filiale.PTF_DirezioneRegionale__c ? this.getAllData['dirRegionaleMap'][filiale.PTF_DirezioneRegionale__c].Name : null;
            this.labelArea = filiale.PTF_Area__c ? this.getAllData['areaMap'][filiale.PTF_Area__c].Name : null;
            this.labelBanca = filiale.PTF_Banca__c ? this.getAllData['bancheMap'][filiale.PTF_Banca__c].Name : null;
        }

        

    }
    
    
    get accountFilter() {

        var condition = " PTF_DataChiusura__c = NULL AND IsPTF__c = TRUE) AND (RecordType.DeveloperName = 'Banca' OR RecordType.DeveloperName = 'DirezioneRegionale' OR RecordType.DeveloperName = 'Area' OR RecordType.DeveloperName = 'FilialeDiRelazione'";

        if ((this.userInfo.Profile.Name != 'System Administrator' || this.userInfo.Profile.Name != 'Amministratore di sistema') && this.contactInfo.PTF_IsSuperuser__c == false) {

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
        }

        return condition;
    }

    

    handleCustomEvent(event) {
        console.log('@@@@@selectedWallet: ' + JSON.stringify(event.detail));

        if (event.detail != null) {
            this.handleChangeFiliale(event.detail.objId);
        } else {
            this.refreshFiltri();
        }

    }

    openReport() {

        if (!this.valueReport) {
            const x = new ShowToastEvent({
                "title": "Errore!",
                "variant": "error",
                "message": "Selezionare almeno un Report"
            });
            this.dispatchEvent(x);
            return;

        }
        if (this.groupButtonFilled == false && !this.valueFiliale) {
            const x = new ShowToastEvent({
                "title": "Errore!",
                "variant": "error",
                "message": "Selezionare almeno una filiale/banca/area/DR"
            });
            this.dispatchEvent(x);
            return;
        }

        if(this.groupButtonFilled == true){

            this.valueReport = this.valueReport.replace(/Filiale/, 'Gruppo');
            this.valueReport = this.valueReport.slice(0, this.valueReport.length - 4);
            console.log('NOME REPORT ',this.valueReport);
        
            getReportId({reportName: this.valueReport})

            .then(result => {
                this.idReport = result;

            })
            .catch(error => {
                alert('ERROR');
                this.error = error;
                console.log('GB ERROR', error);
                this.isRendered = true;
            })
            .finally(() => {

                console.log('Apri Report SuperUser');


                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.idReport,
                        objectApiName: 'Report',
                        actionName: 'view'
                    }
                });

            });


        }else {

            getIdCedFiliale({filialeId: this.valueFiliale})

                .then(result => {
                    this.IDCEDFILIALE = result
                    console.log('ID CED FILIALE ', this.IDCEDFILIALE);

                    return getReportId({reportName: this.valueReport})
                })
                .then(result => {
                        this.idReport = result;
        
                })
                .catch(error => {
                    alert('ERROR');
                    this.error = error;
                    console.log('SV ERROR', error);

                })
                .finally(() => {
                   
                    console.log('Apri Report Normale');

                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.idReport,
                            objectApiName: 'Report',
                            actionName: 'view'
                        },
                        state: {
                            fv1: this.IDCEDFILIALE,
                            fv2: this.IDCEDFILIALE,
                            fv3: this.IDCEDFILIALE,
                            fv4: this.IDCEDFILIALE,
                            fv5: this.IDCEDFILIALE
                        }
                    });

                });
        }

    }

    disableSearchBar() {

        this.groupButtonFilled = !this.groupButtonFilled;

        this.disabledInput = !this.disabledInput;
    }

}