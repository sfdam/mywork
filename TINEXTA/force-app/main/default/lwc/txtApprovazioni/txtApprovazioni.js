/* eslint-disable no-redeclare */
/* eslint-disable vars-on-top */
import { LightningElement, wire,track, api } from 'lwc';
import LightningPrompt from 'lightning/prompt';
//import property from '@salesforce/user/property';
import Id from '@salesforce/user/Id';
import getApp from '@salesforce/apex/ApprovazioniController.getApprovazioni';
import approvazioneRifiuto from '@salesforce/apex/ApprovazioniController.approvazioneRifiuto';
//import rifiuta from '@salesforce/apex/ApprovazioniController.rifiuta';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import UserId from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UsName from '@salesforce/schema/User.Name';

//colonne del componente
const columns = [
    { 
        label: 'Link per approvazione', 
        fieldName: 'website', 
        type: 'url',
        typeAttributes: {label: { fieldName: 'WebName' }, 
        target: '_blank'},
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
    {   
        label: 'Account', 
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'AccountName' }, 
        target: '_blank'},
        wrapText: true,
        sortable: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
    { 
        label: 'Listino CPQ', 
        fieldName: 'listino',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200 
    },
    { 
        label: 'Progetto/Prodotto', 
        fieldName: 'prod',
        wrapText: true,
        initialWidth: 200, 
        hideDefaultActions:true 
    },
    { 
        label: 'Esercizio', 
        fieldName: 'year',
        sortable: true,
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200 
    },
    { 
        label: 'Quote', 
        fieldName: 'QuoteUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'QuoteName' }, 
        target: '_blank'},
        wrapText: true,
        sortable: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
    { 
        label: 'QuoteLine', 
        fieldName: 'QuotelineUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'QuoteLineName' }, 
        target: '_blank'},
        wrapText: true,
        sortable: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
    {
        label: 'Finaziamento',
        fieldName: 'Finan',
        wrapText: true,
        initialWidth: 200, 
        hideDefaultActions:true 
    },
    { 
        label: 'Variato', 
        fieldName: 'variato',
        type: 'url',
        typeAttributes: {label: { fieldName: 'VarName' }, 
        target: '_blank'},
        wrapText: true,
        sortable: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
    { 
        label: 'Cosa è variato', 
        fieldName: 'what',
        wrapText: true,
        initialWidth: 200, 
        hideDefaultActions:true 
    },
    { 
        label: 'Valore precedente', 
        fieldName: 'oldValue',
        wrapText: true,
        initialWidth: 200, 
        hideDefaultActions:true 
    },
    { 
        label: 'Nuovo valore', 
        fieldName: 'newValue',
        wrapText: true,
        initialWidth: 200, 
        hideDefaultActions:true 
    },
    { 
        label: 'Approvazione in carico a ', 
        fieldName: 'approval',
        type: 'url',
        typeAttributes: {label: { fieldName: 'ApprovName' }, 
        target: '_blank'},
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'Commento approvazione', 
        fieldName: 'WRT_Commento_Richiesta_Approvazione__c', 
        wrapText: true, 
        hideDefaultActions:true, 
        initialWidth: 200 
    },
    /*{
        label: 'Data',
        fieldName: 'data',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'left' },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },*/
    { 
        label: 'Link per approvazione', 
        fieldName: 'website', 
        type: 'url',
        typeAttributes: {label: { fieldName: 'WebName' }, 
        target: '_blank'},
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
];
//colonne di esempio
const columns2 = [
    { 
        label: 'Link per approvazione', 
        fieldName: 'website', 
        type: 'url',
        typeAttributes: {label: { fieldName: 'WebName' }, 
        target: '_blank'},
        wrapText: true, 
        hideDefaultActions:true,
        initialWidth: 200
    },
    {   
        label: 'Account', 
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'AccountName' }, 
        target: '_blank'},
        wrapText: true,
        sortable: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
    { 
        label: 'Listino CPQ', 
        fieldName: 'listino',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200 
    },
    { 
        label: 'Progetto/Prodotto', 
        fieldName: 'prod',
        wrapText: true,
        initialWidth: 200, 
        hideDefaultActions:true 
    },
    { 
        label: 'Esercizio', 
        fieldName: 'year',
        sortable: true,
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200 
    },
    { 
        label: 'Quote', 
        fieldName: 'QuoteUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'QuoteName' }, 
        target: '_blank'},
        wrapText: true,
        sortable: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
    { 
        label: 'QuoteLine', 
        fieldName: 'QuotelineUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'QuoteLineName' }, 
        target: '_blank'},
        wrapText: true,
        sortable: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
    /*{ 
        label: 'Finanziamento', 
        fieldName: 'FinanUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'FinanName' }, 
        target: '_blank'},
        sortable: true,
        initialWidth: 200
    },*/
    {
        label: 'Finaziamento',
        fieldName: 'Finan',
        wrapText: true,
        initialWidth: 200, 
        hideDefaultActions:true 
    },
    { 
        label: 'Condizione', 
        fieldName: 'CondUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'CondName' }, 
        target: '_blank'},
        wrapText: true,
        sortable: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
    { 
        label: 'Condizione Opzionale', 
        fieldName: 'CondOpzUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'CondOpzName' }, 
        target: '_blank'},
        wrapText: true,
        sortable: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
    { 
        label: 'Pagamento', 
        fieldName: 'PagamUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'PagamName' }, 
        target: '_blank'},
        wrapText: true,
        sortable: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
    { 
        label: 'Fisso (VALORE PRECEDENTE)', 
        fieldName: 'Fisso_Precedente__c',
        type: 'currency', 
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200 
    },
    { 
        label: 'Fisso (VALORE NUOVO)', 
        fieldName: 'Fisso_Attuale__c',
        type: 'currency',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'Percentuale (VALORE PRECEDENTE)', 
        fieldName: 'Percentuale_Precedente__c',
        type: 'percent', 
        typeAttributes: {step: '0.0001', maximumFractionDigits  : '2'},
        wrapText: true, 
        hideDefaultActions:true,
        initialWidth: 200  
    }, //diviso 100
    { 
        label: 'Percentuale (VALORE NUOVO)', 
        fieldName: 'Percentuale_Attuale__c',
        type: 'percent', 
        typeAttributes: {step: '0.0001', maximumFractionDigits  : '2'},
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'Min Garantito (VALORE PRECEDENTE)', 
        fieldName: 'Min_garantito_precedente__c',
        type: 'currency',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'Min Garantito (VALORE NUOVO)', 
        fieldName: 'Min_garantito_attuale__c',
        type: 'currency',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'Val MAX (VALORE PRECEDENTE)', 
        fieldName: 'Valore_max_precedente__c',
        type: 'currency',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'Val MAX (VALORE NUOVO)', 
        fieldName: 'Valore_max_attuale__c' ,
        type: 'currency',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200 
    },
    { 
        label: 'Tipo Pagamento (VALORE PRECEDENTE)', 
        fieldName: 'Tipo_Pagamento_precedente__c',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    }, //quoteline/pagamento
    { 
        label: 'Tipo Pagamento (VALORE NUOVO)', 
        fieldName: 'Tipo_Pagamento_attuale__c',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'Procedimento/Pagamento (VALORE PRECEDENTE)', 
        fieldName: 'Procedimento_Pagamento_precedente__c',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    }, //pagamento
    { 
        label: 'Procedimento/Pagamento (VALORE NUOVO)', 
        fieldName: 'Procedimento_Pagamento_attuale__c',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'FORO (VALORE PRECEDENTE)', 
        fieldName: 'FORO_precedente__c' ,
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200 
    },
    { 
        label: 'FORO (VALORE NUOVO)', 
        fieldName: 'FORO_attuale__c',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'FORO 2 (VALORE PRECEDENTE)', 
        fieldName: 'FORO_2_precedente__c',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'FORO 2 (VALORE NUOVO)', 
        fieldName: 'FORO_2_attuale__c',
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'Approvazione in carico a ', 
        fieldName: 'approval',
        type: 'url',
        typeAttributes: {label: { fieldName: 'ApprovName' }, 
        target: '_blank'},
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200  
    },
    { 
        label: 'Commento approvazione', 
        fieldName: 'WRT_Commento_Richiesta_Approvazione__c', 
        wrapText: true, 
        hideDefaultActions:true, 
        initialWidth: 200 
    },
    /*{
        label: 'Data',
        fieldName: 'data',
        type: 'date',
        sortable: true,
        cellAttributes: { alignment: 'left' },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },*/
    { 
        label: 'Link per approvazione', 
        fieldName: 'website', 
        type: 'url',
        typeAttributes: {label: { fieldName: 'WebName' }, 
        target: '_blank'},
        wrapText: true,
        hideDefaultActions:true,
        initialWidth: 200
    },
];

/**
 * componente per la visualizzazione e la gestione delle righe di approvazione
 */
export default class TxtApprovazioni extends LightningElement 
{
    //contiene i dati finali
    @track data = [];
    responseStr;
    //colonne del componente
    columns = columns;
    rowOffset = 0;
    //settings per l'ordinamento
    defaultSortDirection = 'desc';
    sortDirection = 'asc';
    sortedBy;
    //id dell'utente corrente
    userId = Id;
    //controllo per il rendering delle righe
    render = false;
    //controllo per abilita/disabilita i bottoni Approva e Rifiuta
    disabilita = true;
    //conteggio numero righe selezionate
    countRow = 0;
    //righe selezionate
    selectedRows;
    //controllo spinner caricamento
    loaded = false;
    showForm = false;
    //contiene il commento dell'approvatore
    comment;
    //controllo per disabilitare i bottoni e forzare il refresh
    checkRefresh = false;

    @track error;
    @track opportunities = [];

    UserName;
    @wire(getRecord, { recordId: UserId, fields: UsName}) 
    userDetails({data}) {
        if (data) {
            this.UserName = data.fields.Name.value;
        } 
    }

    // ordinamento colonna
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
    //gestine ordinamento
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    //gestione sezione commento
    handleCommentChange(event)
    {
        this.comment = event.target.value;
        console.log(this.comment);
    }
    //gestione righe selezionate
    getSelected(event)
    {
        this.countRow = event.detail.selectedRows.length;
        console.log(event.detail.selectedRows.length);
        console.log(this.countRow);
        console.log('select ', event.detail.selectedRows);
        if(this.countRow > 0 && this.checkRefresh == false) this.disabilita = false;
        else this.disabilita = true;
        this.selectedRows = event.detail.selectedRows;
    }

    closeDialog() 
    {
        this.showForm = false
    }
    //gestione refresh
    refreshComponent(event){
        eval("$A.get('e.force:refreshView').fire();");
    }

    refreshView()
    {
        window.location.reload();
    }
    //funzione per approvare o rifiutare le approvazioni
    @api approvaRifiuta(event)
    {
        //const selectedRows = event.detail.selectedRows;
        var label = event.target.title;
        //prendo le righe selezionate
        var setRows = [];
        for ( var i = 0; i < this.selectedRows.length; i++ ) {
            
            setRows.push(this.selectedRows[i]);

        }
        console.log(label);
        console.log(setRows);
        //disabilito i commenti e faccio partire lo spinner
        this.disabilita = true;
        this.loaded = true;
        //quando viene premuto il tasto apre il prompt per far inserire il commento
        //il prompt torna stringa vuota o una stringa se si prosegue
        //altrimenti torna null
        LightningPrompt.open({
            message: 'Inserisci commento',
            label: 'Approvazioni',
        }).then((result) => { 
            //una volta inserito il commento e si prosegue richiamo il metodo apex per approvare o rifiutare le linee selezionate
            //inserendo il commento
            console.log('resutl  d ' ,result);
            this.comment = result;
            //se è stato inserito un commento proseguo
            if(this.comment != null)
            {
                approvazioneRifiuto({approvList : setRows, approvaRifiuta : label, commento : this.comment}).then(results => {
                    //const error = results;
                    console.log(results);
                    if(results) 
                    {
                        //a seconda se era un approvazione o un rifiuto mostro un messaggio diverso
                        var app = results;
                        console.log('app', app)
                        var mess = new ShowToastEvent();
                        if(app == 'Approvata')
                        {
                            this.loaded = false;
                            mess = new ShowToastEvent({
                                "variant": "success",
                                "title": "Approvate!",
                                "message": "Linee approvate con successo, ricarica per vedere la lista aggiornata",
                                "mode": "sticky"
                            });
                            //impedisco di cliccare nuovamente i bottoni
                            this.checkRefresh = true;
                        }
                        else if(app == 'Rifiutata')
                        {
                            this.loaded = false;
                            mess = new ShowToastEvent({
                                "variant": "warning",
                                "title": "Respinte!",
                                "message": "Linee rifutate con successo, ricarica per vedere la lista aggiornata",
                                "mode": "sticky"
                            });
                            //impedisco di cliccare nuovamente i bottoni
                            this.checkRefresh = true;
                        }
                        else
                        {
                            this.loaded = false;
                            mess = new ShowToastEvent({
                                "variant": "error",
                                "title": "Errore!",
                                "mode": "sticky",
                                "message": app + ' Riprovare o contattare l\'amministratore Salesforce'
                            });
                        }
                        //lancio il messaggio
                        this.dispatchEvent(mess);
                        //this.disabilita = false;
                    }

                    //this.refreshView();
                    
                    /*if(error) 
                    {
                        this.error = error;
                        this.data = [];
                        //this.responseStr = error.body.message;
                        const event = new ShowToastEvent({
                            "variant": "error",
                            "title": "Error!",
                            "message": "Errore, riprovare"//error.body.message
                        });
                        this.dispatchEvent(event);
                    }*/
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        "variant": "error",
                        "title": "Errore!",
                        "message": "Si è verificato un errore" + error
                    });
                    console.error('Approve error: ' + JSON.stringify(error));
                    this.dispatchEvent(evt);
                });
            }
            //altrimenti riabilito i bottoni
            else
            {
                this.loaded = false;
                this.disabilita = false;
            }
        });
    }
    //funzione per caricare le linee di approvazione
    connectedCallback() 
    {
        console.log('rendered');
        //recupero id utente corrente
        //query su log modifiche da approvare
        console.log(this.userId);
        getApp({userID : this.userId}).then(results => {
            //console.log('RISULTATIConn : ', results);
            //let nameUrl;
            const { error } = results;
            if(!error) 
            {
                var app = results;
                console.log('app s ',app);
                if(app.length > 0)
                {
                    var row2 = [];
                    for(var row of app)
                    {
                        console.log(row);
                        if(row.Campi_variati__c != null)
                        {
                            //uso la lista di campi variati per creare una riga per ogni tipo di modifica in approvazione
                            var valori = row.Campi_variati__c.slice(0,-1).split(',');
                            console.log(valori);
                            for(var i of valori)
                            {
                                //imposto i valori delle colonne
                                console.log(i);
                                let nameUrl = `/${row.Quote__r.SBQQ__Account__c}`;
                                let AccountName = `${row.Quote__r.SBQQ__Account__r.Name}`;
                                let QuoteUrl = `/${row.Quote__c}`;
                                let QuoteName = `${row.Quote__r.Name}`;
                                let Percentuale_Attuale__c = row.Percentuale_Attuale__c/100;
                                let Percentuale_Precedente__c = row.Percentuale_Precedente__c/100;
                                var website = window.location.origin+'/lightning/r/ProcessInstanceHistory/'+row.Id+'/related/ProcessSteps/view'; //https://tinextagroup--full.lightning.force.com/lightning/r/ProcessInstanceHistory/"&Quote_Line__r.Id&"/related/ProcessSteps/view
                                let WebName = 'Link Approvazione';
                                var ApprovName = this.UserName;
                                var approval = `/${this.userId}`;
                                var QuotelineUrl = '';
                                var QuoteLineName = '';
                                var prod = '';
                                var listino = '';
                                var year = '';
                                let variato;
                                let VarName;
                                var Finan ='';
                                var what = i;
                                var strin = i.replace(' ', '_').replace('/', '_') + '_Attuale__c';
                                var strin2 = i.replace(' ', '_').replace('/', '_') + '_Precedente__c';
                                var oldValue = row[strin2];
                                var newValue = row[strin];
                                if(row.Quote_Line__r)
                                {
                                    QuotelineUrl = `/${row.Quote_Line__c}`;
                                    QuoteLineName = `${row.Quote_Line__r.Name}`;
                                    prod = `${row.Quote_Line__r.Prodotto_Progetto__c}`;
                                    listino = `${row.Quote_Line__r.SBQQ__Product__r.Name}`;
                                    year = `${row.Quote_Line__r.WRT_esercizio__c}`;
                                    website = window.location.origin+'/lightning/r/ProcessInstanceHistory/'+row.Quote_Line__c+'/related/ProcessSteps/view';
                                }
                                if(row.Finanziamento__r)
                                {
                                    var FinanUrl = `/${row.Finanziamento__c}`;
                                    var FinanName = `${row.Finanziamento__r.Name}`;
                                }
                                if(row.Condizione__r)
                                {
                                    var CondUrl = `/${row.Condizione__c}`;
                                    var CondName = `${row.Condizione__r.Name}`;
                                    variato = `/${row.Condizione__c}`;
                                    VarName = `${row.Condizione__r.Name}`;
                                    if(row.Condizione__r.WRT_Tipologia_Finanziamento_FORM__c) Finan = `${row.Condizione__r.WRT_Tipologia_Finanziamento_FORM__c}`;
                                }
                                if(row.Condizione_Opzionale__r)
                                {
                                    var CondOpzUrl = `/${row.Condizione_Opzionale__c}`;
                                    var CondOpzName = `${row.Condizione_Opzionale__r.Name}`;
                                    variato = `/${row.Condizione_Opzionale__c}`;
                                    VarName = `${row.Condizione_Opzionale__r.Name}`;
                                    if(row.Condizione_Opzionale__r.Tipologia_Finanziamento_WarrantCPQ__c) Finan = `${row.Condizione_Opzionale__r.Tipologia_Finanziamento_WarrantCPQ__c}`;
                                }
                                if(row.Pagamento__r)
                                {
                                    var PagamUrl = `/${row.Pagamento__c}`;
                                    var PagamName = `${row.Pagamento__r.Name}`;
                                    variato = `/${row.Pagamento__c}`;
                                    VarName = `${row.Pagamento__r.Name}`;
                                    if(row.Pagamento__r.Condizione_WarrantCPQ__r.WRT_Tipologia_Finanziamento_FORM__c) Finan = `${row.Pagamento__r.Condizione_WarrantCPQ__r.WRT_Tipologia_Finanziamento_FORM__c}`;
                                }
                                row2.push({...row , nameUrl, AccountName, 
                                    QuoteUrl, QuoteName, prod, year,
                                    QuotelineUrl, QuoteLineName,
                                    FinanUrl, FinanName,
                                    CondUrl, CondName,
                                    CondOpzUrl, CondOpzName, Percentuale_Precedente__c,
                                    PagamUrl, PagamName, Percentuale_Attuale__c,
                                    website, WebName,
                                    ApprovName, approval,
                                    listino, variato, VarName,
                                    Finan, oldValue, newValue
                                    ,what,
                                });
                            }
                            console.log(row2);
                        }
                    }
                    /*this.data = app.map(row => { 
                        //console.log('rowe ', row);
                        
                        return row2
                    })*/
                    if(row2.length > 0)
                    {
                        this.data = row2;
                        this.render = true;
                        this.error = null;
                    }
                    else
                    {
                        this.responseStr = 'Nessuna richiesta di approvazione trovata';
                    }
                }
                else
                {
                    this.responseStr = 'Nessuna richiesta di approvazione trovata';
                }
            }
            if(error) 
            {
                this.error = error;
                this.data = [];
                this.responseStr = error.body.message;
                const event = new ShowToastEvent({
                    "variant": "error",
                    "title": "Error!",
                    "message": error.body.message
                });
                this.dispatchEvent(event);
            }
        })
        /*this.data = [
            {
                name: 'IDAL GROUP SOCIETA\' PER AZIONI',
                listino: 'FAA - CERTIFICAZIONE PROGETTI R&D - DRIVER - STANDARD',
                prod: 'FAA - CERTIFICAZIONE PROGETTI R&D',
                year: '2022',
                what: 'Fisso',
                new: '2000',
                old: '1000',
                quote: 'Q-08856',
                approval: 'Migliavacca',
                data: new Date(
                    Date.now() + 86400000 * Math.ceil(Math.random() * 20)
                ),
                website: 'https://tinextagroup--full.sandbox.lightning.force.com/lightning/r/ProcessInstanceWorkitem/04i0D000000M7yNQAS/view',
            },
            {
                name: 'SAVARE\' I.C. - S.R.L.',
                listino: 'FIT - CONTO FORMAZIONE DOCENZA',
                prod: 'FIT - FONDI INTERPROFESSIONALI',
                year: '2021',
                what: 'Percentuale',
                new: '5',
                old: '7',
                quote: 'Q-08854',
                approval: 'Migliavacca',
                data: new Date(
                    Date.now() + 86400000 * Math.ceil(Math.random() * 20)
                ),
                website: 'https://tinextagroup--full.sandbox.lightning.force.com/lightning/r/ProcessInstanceWorkitem/04i0D000000WBR2QAO/view',
            },
            {
                name: 'SAVARE\' I.C. - S.R.L.',
                listino: 'FIT - CONTO FORMAZIONE DOCENZA',
                prod: 'FIT - FONDI INTERPROFESSIONALI',
                year: '2021',
                what: 'Fisso',
                new: '1860',
                old: '2500',
                quote: 'Q-08854',
                approval: 'Migliavacca',
                data: new Date(
                    Date.now() + 86400000 * Math.ceil(Math.random() * 20)
                ),
                website: 'https://tinextagroup--full.sandbox.lightning.force.com/lightning/r/ProcessInstanceWorkitem/04i0D000000WBR2QAO/view',
            }
        ];
        console.log(this.data);*/
    }

    /*@wire(getApp, {userID : Id})
    approvazioni(results)
    {
        console.log('RISULTATI : '+JSON.stringify(results));
        const { app, error } = results;
        if(app) 
        {
            let nameUrl;
            this.data = app.map(row => { 
                nameUrl = `/${row.Id}`;
                return {...row , nameUrl} 
            })
            this.error = null;
        }
        if(error) 
        {
            this.error = error;
            this.data = [];
            const event = new ShowToastEvent({
                "variant": "error",
                "title": "Error!",
                "message": error.body.message
            });
            this.dispatchEvent(event);
        }
    };*/
}