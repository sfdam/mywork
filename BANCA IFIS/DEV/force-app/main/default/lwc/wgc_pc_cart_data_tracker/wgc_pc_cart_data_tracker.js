import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssCartPC from '@salesforce/resourceUrl/cssCartPC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import loadPEF from '@salesforce/apex/WGC_PC_CartController.callPEF39';
import saveCredito from '@salesforce/apex/WGC_PC_CartController.saveSingleCredito';
import updateField from '@salesforce/apex/WizardOpportunityController.updateField';
import censimentoTrattativaSingle from '@salesforce/apex/WGC_PC_CartController.callCensimentoTrattativaSingle';
import confermaTrattativa from '@salesforce/apex/WGC_PC_CartController.callConfermaTrattativa';
// import creditiPEF from '@salesforce/apex/WGC_PC_CartController.getCreditiPEF';

//Label Start
import labelStato2 from '@salesforce/label/c.Stato_Opp_2';
import labelStato3 from '@salesforce/label/c.Stato_Opp_3';
//Label End
const COD_STATO_LINEA_DECLINATA = '004';
const COD_STATO_LINEA_DELIBERATA = '003';

export default class Wgc_pc_cart_data_tracker extends LightningElement {
    
    @api recordId;
    @api accountId;

    @track _data;
    @track _dettaglioCartella = {};
    // @track _accountId;

    @api opp;
    @track crediti = [];
    @track notes = [];

    @track creditiCRM = [];

    @track _pReadOnly = false;

    // formattedNote = '<h1>TEST</h1>';

    //DATATABLE
    // @api columns = [//{ label: 'Debitore', fieldName: 'ragSocDebitore'},
    //                 { label: 'Stato', fieldName: 'desStatoCoppia'},
    //                 //{ label: 'Importo Prosolvendo', fieldName: ''},
    //                 { label: 'Importo Prosoluto', fieldName: 'impProsolutoCoppia'},
    //                 { label: 'Cod. Gestione', fieldName: 'codGestione'},
    //                 { label: 'Numero fattura da', fieldName: 'numeroFatturaDa'},
    //                 { label: 'Numero fattura a', fieldName: 'numeroFatturaA'},
    //                 { label: 'Anno fattura da', fieldName: 'annoFatturaDa'},
    //                 { label: 'Anno fattura a', fieldName: 'annoFatturaA'}
    //                 ];
                    //ALtri campi];
    // @api _dataColumns = [];

    @api
    mainWizardItems = [{ title: "In Lavorazione", phase: "In Lavorazione", active: true, visible: true, state: "completed", phaseDuration: 0, visibleFor: "nuovaConcessione,revisione", class: "cstm-main-wizard-item completed " }, 
                        { title: labelStato2, phase: "Valutazione Pratica", active: false, visible: true, state: "inProgress", phaseDuration: 0, visibleFor: "nuovaConcessione,revisione", class: "cstm-main-wizard-item " }, 
                        { title: labelStato3, phase: "Perfezionamento Contratto", active: false, visible: true, state: "", phaseDuration: 0, visibleFor: "nuovaConcessione,revisione", class: "cstm-main-wizard-item " },
                        { title: "Vinta", phase: "Vinta", active: false, visible: true, state: "", phaseDuration: 0, visibleFor: "nuovaConcessione,revisione", class: "cstm-main-wizard-item " }
                    ];

    @track rendered = false;
    // @track renderError = false;
    @track showModal = false;
    @track cmpModal = '';
    @track modalParams = {};

    @api userInfo;

    constructor(){
        super();
        this.template.addEventListener('modal', this.handleCloseModal.bind(this));
    }

    connectedCallback(){
        loadStyle(this, cssCartPC);

        console.log('@@@ accountId ' , this.accountId);
        console.log('@@@ recordId ' , this.recordId);

        this.initialize();
    }

    renderedCallback(){
    }

    /* GETTER & SETTER */

    // @api
    // get accountId(){
    //     return this._accountId;
    // }

    // set accountId(id){
    //     console.log('@@@ id ' , id);
    //     this._accountId = id;
    //     this.callPEF();
    // }

    /* GETTER & SETTER */

    /* FUNCTIONS */
    initialize(){
        loadPEF({ accountId: this.accountId, opportunityId: this.recordId })
            .then(result => {
                console.log('@@@ result ' , JSON.stringify(result));
                if(result.success){
                    // var payload = JSON.parse(result.data);
                    this._data = JSON.parse(result.data);
                    this.creditiCRM = this._data.crediti;
                    this._dettaglioCartella = this._data.response.payload.outputRichiesta;
                    if(this._data.response.payload.outputRichiesta.elencoNote != null){
                        var tmpNotes = [...this._data.response.payload.outputRichiesta.elencoNote];
                        tmpNotes.forEach(n => {
                            n.title = n.codUtente + ' ('+ new Date(n.datInserimNota).toLocaleDateString('it-IT', { year: 'numeric', month: '2-digit', day: '2-digit'}) +')';
                            n.decodedDes = window.atob(n.desTestoNota);
                        });
                        //this.notes = this._data.response.payload.outputRichiesta.elencoNote;
                        this.notes = tmpNotes;
                    }
                    this.crediti = [...this._data.response.payload.outputRichiesta.elencoLineeCredito];
                    // this.crediti.reverse();
                    this.crediti.forEach((c, ind) => {
                        this.creditiCRM.forEach((cc, indCC) => {
                            if(cc.WGC_Codice_Rapporto__c != undefined && c.codRapportoEst == '0'+cc.WGC_Codice_Rapporto__c.substring(0,2)+'00'+cc.WGC_Codice_Rapporto__c.substring(2,5)+'0000'+cc.WGC_Codice_Rapporto__c.substring(5)){
                                // c.idCredito = cc.Id;
                                // c.confirmed = cc.WGC_Credito_Confermato__c;
                                // c.impQuotaNotifica = cc.WGC_Prezzo_di_acquisto__c;

                                // c.stato = cc.Stato__c;
                                // c.deliberata = cc.WGC_Deliberata__c;
                                // c.nonDeliberata = cc.WGC_Non_Deliberata__c;
                                // c.dataDelibera = cc.WGC_Data_Delibera__c;
                                // c.dataDeclinazione = cc.WGC_Data_Declinazione__c;

                                // c.wizardItems = this.getWizardItems(c, cc);
                                // c.wizardProgressValue = this.getWizardProgressValue(c.wizardItems);
                                cc.idCredito = cc.Id;
                                //OLD
                                //cc.confirmed = cc.WGC_Credito_Confermato__c || this.userInfo.Profile.Name == 'IFIS - Crediti Erariali';
                                cc.confirmed = true;

                                cc.numLineaCredito = c.numLineaCredito;
                                cc.codLineaSistema = c.codLineaSistema;
                                cc.desStatoLinea = c.desStatoLinea;
                                cc.numLineaCredito = c.numLineaCredito;
                                cc.impQuotaNotifica = cc.WGC_Prezzo_di_acquisto__c;
                                // impQuotaNotifica
                                cc.impAccordatoLinea = c.impAccordatoLinea;

                                cc.stato = cc.Stato__c;
                                cc.deliberata = cc.WGC_Deliberata__c;
                                cc.nonDeliberata = cc.WGC_Non_Deliberata__c;
                                cc.dataDelibera = cc.WGC_Data_Delibera__c;
                                cc.dataDeclinazione = cc.WGC_Data_Declinazione__c;

                                cc.wizardItems = this.getWizardItems(cc, cc);
                                cc.wizardProgressValue = this.getWizardProgressValue(cc.wizardItems);

                                cc.rigo = cc.WGC_Rigo__c;
                                cc.commessa = cc.WGC_Commessa__c;

                                cc.readOnly = this.setupReadOnly(cc);
                                //Setto il nome/Label fittizio
                                cc.Name = 'Credito ' + (indCC + 1);
                            }
                        });
                        
                        // c.Name = 'Credito ' + (ind + 1);
                    });
                    // console.log('@@@ result payload ' , payload);
                    // this.rendered = true;
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Errore',
                            message: result.message,
                            type: 'error'
                        })
                    );

                    // return null;
                    // this._dettaglioCartella.
                }

                return result.success;
            }).then(r => {
                //this.setupReadOnly();
                this.rendered = true;
                // if(r){
                //     this.renderError = false;
                // } else {
                //     this.renderError = true;
                // }
            })
            // .finally(() => {
            //     this.rendered = true;
            // })
            .catch(err => {
                console.log('@@@ err ' , err);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message: err.message,
                        type: 'error'
                    })
                );
            });
    }

    /* EVENT HANDLERS */

    inviaTime(event){
        //NEW
        event.preventDefault();
        this.rendered = false;
        let id = event.target.dataset.cId;
        let index = event.target.dataset.index;
        var credito = this.creditiCRM.find(c => { return c.Id == id });

        console.log('@@@ credito ' , JSON.stringify(credito));
        console.log('@@@ recordId ' , id);

        var esitoTIME03 = false;
        var rigo = '';
        var commessa = '';

        censimentoTrattativaSingle({ opportunityId: this.recordId, creditoId: id, typeCall: 'post' }).then(r => {
            if(r.success){
                return confermaTrattativa({ creditoId: credito.Id })
            } else {
                this.rendered = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERRORE',
                        message: r.message,
                        variant: 'error'
                    })
                )
            }
        }).then(r => {
            var res = r.message;
            if(r.success){
                res = JSON.parse(r.data[0]).payload.esito;
                let pRigo = JSON.parse(r.data[0]).payload.pRigo;
                let pCommessa = JSON.parse(r.data[0]).payload.pCommessa;

                if(res == 'OK'){
                    esitoTIME03 = true;
                    rigo = pRigo;
                    commessa = pCommessa;
                    updateField({ field: 'WGC_Credito_Confermato__c', value: true, objectId: id })
                    return esitoTIME03;
                }
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERRORE',
                        message: res,
                        variant: 'error'
                    })
                )
                return res;
            }
        }).then(res => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: res == 'OK' || res == true ? 'SUCCESSO' : 'ERRORE',
                    message: 'Il credito è stato inviato correttamente a TIME',
                    variant: res == 'OK' || res == true ? 'success' : 'error'
                })
            )

            this.creditiCRM.forEach(c => {
                if(c.idCredito == id){
                    c.confirmed = esitoTIME03;
                    c.rigo = rigo;
                    c.commessa = commessa;
                }
            })
        }).finally(() => {
            this.connectedCallback();
            this.rendered = true;
        }).catch(err => {
            this.rendered = false;
            console.log('@@@ error ' , err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERRORE',
                    message: err,
                    variant: 'error'
                })
            )
        })
    }

    handleUpdateCredito(event){

        this.crediti.forEach(c => {
            if(c.idCredito == event.detail.id){
                c.confirmed = event.detail.esito;
            }
        })
    }

    handleCloseModal(event){
        this.showModal = event.detail.open;
    }

    /* EVENT HANDLERS */


    /* HELPER FUNCTIONS */

    setupReadOnly(credito){
        return this.opp.StageName == 'Valutazione Pratica' || credito.wizardItems.find(wi => { return wi.phase == 'Valutazione Pratica' && wi.state == 'failed'}) != undefined || credito.WGC_Credito_Confermato__c;
    }

    getWizardItems(line, completeLine) {
        var copyMainWizardItems = this.mainWizardItems.map(wi => { return {...wi}; });
        // let dtWizardItems = [...this.mainWizardItems];
        var dtWizardItems = copyMainWizardItems;
        dtWizardItems.forEach(wi => {
            if (completeLine && wi.phase == completeLine.WGC_FaseDiCaduta__c) {
                wi.state = "failed";
                wi.date = completeLine.WGC_DataFaseDiCaduta__c;
            } else {
                switch (wi.phase) {
                    case "In Lavorazione":
                        wi.state = "completed";
                        wi.class += " completed";
                        wi.active = false;
                        wi.date = this.opp.WGC_Data_out_Fase_In_Istruttoria__c;
                        break;
                    case "Valutazione Pratica":
                        if (line.nonDeliberata) {
                            wi.state = "failed";
                            wi.class += ' failed';
                            wi.date = line.dataDeclinazione;
                            wi.active = false;
                        }
                        else if (line.deliberata) {
                            // wi.state = this.opp.StageName == 'Valutazione Pratica' ? "inProgress" : 'completed';
                            // wi.class += this.opp.StageName == 'Valutazione Pratica' ? ' inProgress active' : ' completed';
                            wi.state = 'completed';
                            wi.class += ' completed';
                            wi.date = line.dataDelibera;
                            wi.active = false;
                        } else {
                            wi.state = 'inProgress';
                            wi.class += ' inProgress active';
                            wi.active = true;
                        }
                        break;
                    // case "Predisposizione Contratto":
                    //     if (line.deliberata) {
                    //         wi.state = (line.stato == "11" ? "completed" : "inProgress");
                    //         wi.date = line.dataContrattiPronti;
                    //         wi.active = (line.stato == "11" ? false : true);
                    //     }
                    //     break;
                    case "Perfezionamento Contratto":
                        if (line.stato == "11") {
                            wi.state = (completeLine.WGC_Attivata__c ? "completed" : "inProgress");
                            wi.class += (completeLine.WGC_Attivata__c ? ' completed' : ' inProgress');
                            wi.date = completeLine.WGC_Data_Attivazione__c;
                            wi.active = !completeLine.WGC_Attivata__c;
                        } else {
                            if(dtWizardItems.find(wi => { return wi.phase == 'Valutazione Pratica' && wi.state == 'completed' }) != undefined){
                                wi.state = 'inProgress';
                                wi.class += ' inProgress active';
                                // wi.date = 
                                wi.active = true;
                            }
                        }
                        break;
                    case "Vinta":
                        if(this.opp.StageName == 'Vinta' && line.deliberata){
                            dtWizardItems.find(wii => { return wii.phase == 'Perfezionamento Contratto' }).active = false;
                            dtWizardItems.find(wii => { return wii.phase == 'Perfezionamento Contratto' }).state = 'completed';
                            dtWizardItems.find(wii => { return wii.phase == 'Perfezionamento Contratto' }).class = 'cstm-main-wizard-item completed';
                            dtWizardItems.find(wii => { return wii.phase == 'Perfezionamento Contratto' }).date = completeLine.WGC_Data_Attivazione__c;
                            wi.state = 'active';
                            wi.class += ' completed';
                            // wi.date = 
                            wi.active = true;
                        }
                    // case "Attivazione Prodotto":
                    //     if (completeLine && completeLine.WGC_Attivata__c) {
                    //         wi.state = "inProgress";
                    //         // wi.date = completeLine.WGC_Data_Attivazione__c;
                    //         wi.active = true;
                    //     }
                    //     break;
                }
            }
        });

        return dtWizardItems;
    }

    getWizardProgressValue(wizardItems){
        let prgValue;
        
        wizardItems.forEach((wi, index) => {
            if (wi.active)
                prgValue = (index*33);
                // prgValue = (index*25);
        });

        return prgValue;
    }

    handleCreditoCompleted(event){
        var crediti = [...this.creditiCRM];
        var params = event.detail;
        if(params && !crediti.find(c => { return c.Id == params.Id; }).WGC_Credito_Confermato__c){
            console.log('@@@ check time ' , params.isCompleted || crediti.find(c => { return c.Id == params.Id; }).WGC_Credito_Confermato__c );
            crediti.find(c => { return c.Id == params.Id; }).confirmed = !params.isCompleted || crediti.find(c => { return c.Id == params.Id; }).WGC_Credito_Confermato__c; //params.isCompleted;
        }
        this.creditiCRM = crediti;
    }
}