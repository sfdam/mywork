//Librerie
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

//Metodi Apex
import getAllData from '@salesforce/apex/PrintPDFController.getAllData';
import executeCall from '@salesforce/apex/PrintPDFController.executeCall';
//S: Vecchia Gestione waterfall, sostituita dalle promise
//import generaXML from '@salesforce/apex/PrintPDFController.generaXml';
//E: Vecchia Gestione waterfall, sostituita dalle promise 

import getFullMetadataFromSelected from '@salesforce/apex/PrintPDFController.getFullMetadataFromSelected';
import getRootXML from '@salesforce/apex/PrintPDFController.getRootXML';

import getXMLFromQuery4Promise from '@salesforce/apex/PrintPDFController.getXMLFromQuery4Promise';
import getXMLFromQuery4PromiseData from '@salesforce/apex/PrintPDFController.getXMLFromQuery4PromiseData';
import getXMLFromMethods4Promise from '@salesforce/apex/PrintPDFController.getXMLFromMethods4Promise';
import getXMLFromMethods4PromiseData from '@salesforce/apex/PrintPDFController.getXMLFromMethods4PromiseData';
import replaceFieldsWithData4Promise from '@salesforce/apex/PrintPDFController.replaceFieldsWithData4Promise';

import callGeneratePDFAsynch from '@salesforce/apex/PrintPDFController.callGeneratePDFAsynch';


export default class PrintPDF extends LightningElement {
    @api recordId;
    @api title;

    @api checkboxapi;

    //S: variabili esposte al builder (in caso di modifiche, modificare il file metadata del componente)
    @api buttonTitle = 'Crea PDF';
    @api modalTitle = 'Crea PDF';
    @api iconName = 'standard:account';
    @api buttonDownloadLabel = 'Scarica PDF';
    @api buttonAnnullaLabel = 'Annulla';
    //E: variabili esposte al builder (in caso di modifiche, modificare il file metadata del componente)

    @api showModal = false;

    //icon to change based on account record type
    //@track iconRecordType = 'standard:account';

    //DATI ACCOUNT
    @track accountData = [];
    @track accountQuery = '';

    // TABELLE
    @track sectionsTableSelectedRows = [];
    @track sectionsTableData = [];
    @track sectionsTableColumns = [];

    @track xmlinnerdocument = '';
    @track xmldocumentroot = '';
    
    @track dataxml = [];

    @track showSpinner = true;

    //S:Modifica per gestire xml con promise lato javascript
    @api PLACEHOLDER_SEZIONI = '###ZONA_SEZIONI###';
    @api PLACEHOLDER_COMPONENTI = '###ZONA_COMPONENTI###';
    
    //Queste variabili vengono popolate all'init del componente,
    // quando ancora si vede solo il bottone
    @api recordTypeDeveloperName = '';

    //Queste variabili sono utilizzate in fase di creazione del PDF
    @api fullMetadata = [];
    @api selectedSezioni = [];

    @api rootXml = '';

    @api defaultSections = ['Anagrafica', 'NDG Collegati', 'NDG Della Cointestazione'];
    //E:Modifica per gestire xml con promise lato javascript

    // START DK NEW
    isExecuting = false;    
    @api async invoke() {
        if (this.isExecuting) {
            return;
        }  
        console.log('Execution Start');
        this.isExecuting = true;
        await this.sleep(1000);
        this.isExecuting = false;
        console.log('Execution Stop');
    }  sleep(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    abilitatedProfiles = ['Amministratore del sistema', 'System Administrator'];
    @track canChoose = true;
    @track loading = false;
    @track pdfGenerato = false;
    @track eseguoChiaata = false;
    @track nameReferente = '';
    @track privacy = '';
    @track showPrivacy = true;
    // END DK NEW

    //INIT
    connectedCallback(){
        this.sectionsTableColumns = [
            { label: 'Sezioni', fieldName: 'SECTION__c', type: 'text' }
        ];

        this.ComponentsTableColumns = [
            { label: 'Componente', fieldName: 'COMPONENT__c', type: 'text', sortable: true },
            { label: 'Sezioni', fieldName: 'SECTION__c', type: 'text', sortable: true }
        ];
        console.log('DK START CONNECTEDCALLBACK');
        this.invoke()
        .then(() =>{

            getAllData({recordId: this.recordId})
            .then(result =>{
                this.sectionsTableData = result['metadata'];
                console.log('Dk this.sectionsTableData: ', JSON.stringify(this.sectionsTableData));
                this.accountData = result['account'];
                this.accountQuery = result['accountQuery'];
                this.nameReferente = Boolean(this.accountData.PTF_Portafoglio__r) && Boolean(this.accountData.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r) ? this.accountData.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.Name : '';
                this.canChoose = result['canChoose'];
                this.recordTypeDeveloperName = result['recTypeDevName'];

                this.showPrivacy = this.recordTypeDeveloperName != 'Cointestazione';
                this.privacy = this.recordTypeDeveloperName == 'IndustriesBusiness' ? this.accountData.CRM_BusinessPrivacy1StatusIconSmall__c.replaceAll('28', '18') : this.accountData.CRM_FormulaListaPrivacy__c;
                if(this.canChoose){

                    this.sectionsTableSelectedRows = this.sectionsTableData;
                    this.showSpinner = false;
                }else{
                    this.sectionsTableData.forEach(section =>{
                        if(this.defaultSections.includes(section.SECTION__c)){

                            this.sectionsTableSelectedRows.push(section);
                        }
                    });
                    this.showSpinner = true;
                    const start = Date.now();
                    this.downloadPDF()
                    .then(() =>{
                        this.showSpinner = false;
                        const end = Date.now();
                        console.log('TIME', (end - start)/1000);
                    }).catch(err =>{

                        console.log('DK downloadPDF.err', err);
                    });
                }
            })
            .catch(err =>{

                console.log('DK getAllData.err', err);
            });
        })
        .catch(err =>{

            console.log('DK invoke.err', err);
        });
    }

    /*initRecordData(){
        return getAccountData({recordId: this.recordId}).then(result => {
            if(result!=null && result.length>0){
                this.accountData = result[0];
                console.log('this.accountData.CRM_CheckVisibNDGFull__c', this.accountData.CRM_CheckVisibNDGFull__c);
                console.log('this.accountData.CRM_VisibilitaClientiCF__c', this.accountData.CRM_VisibilitaClientiCF__c);
                console.log('this.accountData.CRM_VisibilitaClientiLivelliFunzionali__c', this.accountData.CRM_VisibilitaClientiLivelliFunzionali__c);
                console.log('this.accountData.CRM_VisibilitaClientiUffPrivate__c', this.accountData.CRM_VisibilitaClientiUffPrivate__c);
                console.log('this.accountData.PTF_IsGruppo__c', this.accountData.PTF_IsGruppo__c);
                //this.iconRecordType = this.getRecordTypeIcon(this.accountData.RecordTypeName__c);
                if((!Boolean(this.accountData.CRM_CheckVisibNDGFull__c) ||
                    !Boolean(this.accountData.CRM_VisibilitaClientiCF__c) ||
                    !Boolean(this.accountData.CRM_VisibilitaClientiLivelliFunzionali__c) ||
                    !Boolean(this.accountData.CRM_VisibilitaClientiUffPrivate__c) )&&
                    Boolean(this.accountData.PTF_IsGruppo__c)){

                        this.canChoose = false;
                }else{
                     getUserInfo()
                    .then(data =>{
                        console.log('ProfileName', data.Profile.Name);
                        if(!this.abilitatedProfiles.includes(data.Profile.Name) && !data.Profile.Name.includes('NEC_ADMIN')){
                            this.canChoose = false;
                        }else{
                            this.showSpinner = false;
                        }
                    })
                    .catch();
                }

            }
        });
    }*/

    /*initTabellaSezioni(){
        
        return loadMetaDataStructure({recordId: this.recordId}).then(result => {
            console.log('Apex: ' + JSON.stringify(result));
            if(result){ 
                this.sectionsTableData = result;
            }
        });
    }*/

    //S:Modifica per gestire xml con promise lato javascript
    /*initRecordTypeDeveloperName(){
        getAccountRecordTypeDeveloperName({recordId: this.recordId}).then(result => {
            if(result){ 
                this.recordTypeDeveloperName = result;
                //alert(this.recordTypeDeveloperName);
            }
        });
    }*/

    startGetFullMetadataFromSelected;
    endGetFullMetadataFromSelected;

    startGetRootXML;
    endGetRootXML;

    startPromises;
    endPromises;
    generaXmlWithPromise(){
        //Recupero dati preliminari
        this.startGetFullMetadataFromSelected = new Date();
        console.log('DK this.sectionsTableSelectedRows', this.sectionsTableSelectedRows);
        return getFullMetadataFromSelected({   selectedSections: this.sectionsTableSelectedRows
                                            ,obj: 'Account'
                                            ,recordTypeDeveloperName: this.recordTypeDeveloperName}).then(result => {
            if(result){

                this.endGetFullMetadataFromSelected = new Date();
                this.fullMetadata = result;
                console.log('DK this.fullMetadata: ', this.fullMetadata);
                this.fullMetadata.sort(this.sortBy( 'Ordine__c', 1) );
                //Recupero root xml
                    this.startGetRootXML = new Date();
                    return getRootXML({   fullMetadata: this.fullMetadata,
                                    currentAccount: this.accountData}).then(result => {
                    this.endGetRootXML = new Date();
                    if(result){                   
                        this.rootXml = result;
                        if(this.fullMetadata && this.fullMetadata.length > 0){
                            var promiseArray =[];
                            var promiseArrayAsynch =[];
                            // this.selectedSezioni = [];
                            this.selectedSezioni = {};
                            // let selectedSezioni = [];
                            console.log('DK this.accountData: ', JSON.stringify(this.accountData));
                            for(var i = 0; i < this.fullMetadata.length; i++){
                                var m = this.fullMetadata[i];
                                //Popolo la lista delle sezioni
                                if(!m.COMPONENT__c && m.isActive__c && !m.isRoot__c){
                                    this.selectedSezioni[m.SECTION__c] =  m.baseXml__c;
                                    // selectedSezioni.push(m.Id);
                                }

                                //Popolo la lista delle promise per avere i dati dei componenti
                                if(m.SECTION__c && m.COMPONENT__c && m.isActive__c && !m.isRoot__c){
                                    if(m.HasQuery__c){
                                        //Facciamo la query indicata e sostituiamo i campi
                                        // promiseArrayAsynch[promiseArrayAsynch.length] = getXMLFromQuery4Promise({meta: m,currentAccount: this.accountData});
                                        promiseArrayAsynch[i] = {method: 'getXMLFromQuery4PromiseData', meta: m.Id};
                                        // promiseArray[i] = getXMLFromQuery4PromiseData({meta: m,currentAccount: this.accountData})
                                        
                                    }
                                    else if(m.HasMetodoSelezione__c){
                                        //Chiamiamo il metodo recuperato dal metadata e sostituiamo i campi
                                        // promiseArrayAsynch[promiseArrayAsynch.length] = getXMLFromMethods4Promise({meta: m,currentObject: this.accountData});
                                        promiseArrayAsynch[i] = {method: 'getXMLFromMethods4PromiseData', meta: m.Id};
                                        // promiseArray[i] = getXMLFromMethods4PromiseData({meta: m,currentAccount: this.accountData})
                                        
                                    }
                                    else{
                                        //Inserisco l'xml sostituendo i campi
                                        // promiseArrayAsynch[i] = replaceFieldsWithData4Promise({meta: m,currentAccount: this.accountData});
                                        // promiseArray[promiseArray.length] = {method: 'replaceFieldsWithData4Promise', meta: m};
                                        promiseArrayAsynch[i] = {method: 'replaceFieldsWithData4Promise', meta: m};
                                    }
                                }
                            }

                            // callGeneratePDFAsynch({currentAccountQuery: this.accountQuery, promiseArray: promiseArrayAsynch, listaSezioni: selectedSezioni, rootXml : this.rootXml, recordTypeDeveloperName: this.recordTypeDeveloperName, tipoStampa: !this.showDataTable ? 'FULL' : 'LIGHT'})
                            // callGeneratePDFAsynch({currentAccountQuery: this.accountQuery, promiseArray: promiseArrayAsynch, mappaSezioni: this.selectedSezioni, rootXml : this.rootXml, recordTypeDeveloperName: this.recordTypeDeveloperName, tipoStampa: !this.showDataTable ? 'FULL' : 'LIGHT'})
                            callGeneratePDFAsynch({currentAccount: this.accountData, promiseArray: promiseArrayAsynch, mappaSezioni: this.selectedSezioni, rootXml : this.rootXml, recordTypeDeveloperName: this.recordTypeDeveloperName, tipoStampa: !this.showDataTable ? 'FULL' : 'LIGHT'})
                            .then(()=>{
                                this.showToastMessage('STIAMO CREANDO IL PDF. APPENA L\'OPERAZIONE SARÀ CONCLUSA, IL FILE SARÀ DISPONIBILE NEL TAB SCHEDE PDF PRONTE', 'success');
                                this.showSpinner = false;
                                this.closeModal();
                            })
                            .catch(err =>{
                                this.showSpinner = false;
                                console.log(err);
                                this.showToastMessage('UNEXPECTED ERROR', 'error');
                            });

                            // console.log('DK promiseArray: ',  promiseArray);
                            // console.log('DK promiseArrayAsynch: ',  promiseArrayAsynch);
                            // console.log('DK selectedSezioni: ',  this.selectedSezioni);

                            //Lancio le promise per avere i dati dei vari componenti
                            /*this.startPromises = new Date();
                            return Promise.all(promiseArray)
                            .then((result) => {
                                //Unisco i dati e restituisco l'xml
                                // console.log('DK promiseResult: ', JSON.stringify(result));
                                for(let i = 0; i < result.length; i++){
                                    if(Boolean(result[i])){
                                        promiseArrayAsynch[i] = result[i];
                                    }
                                }
                                console.log('DK promiseArrayAsynch: ', JSON.stringify(promiseArrayAsynch));
                                callGeneratePDFAsynch({currentAccount: this.accountData, promiseArray: promiseArrayAsynch, mappaSezioni: this.selectedSezioni, rootXml : this.rootXml, recordTypeDeveloperName: this.recordTypeDeveloperName, tipoStampa: !this.showDataTable ? 'FULL' : 'LIGHT'})
                                .then(()=>{
                                    this.showToastMessage('STIAMO CREANDO IL PDF. RICEVERAI UNA NOTIFCA APPENA L\'OPRAZIONE SARA\' CONCLUSA', 'success');
                                    this.showSpinner = false;
                                    this.closeModal();
                                })
                                .catch(err =>{
                                    this.showSpinner = false;
                                    console.log(err);
                                    this.showToastMessage('UNEXPECTED ERROR', 'error');
                                });
                                /*this.endPromises = new Date();
                                console.log('Promises Time: ', this.endPromises - this.startPromises);
                                if(result && this.selectedSezioni && Object.keys(this.selectedSezioni)){
                                    //debugger;
                                    var mappaSezioni = this.selectedSezioni;
                                    console.log('DK result: ', result);
                                    console.log('DK mappaSezioni START: ', mappaSezioni);
                                    for(var i = 0; i < Object.keys(mappaSezioni).length; i++){
                                        var k = Object.keys(mappaSezioni)[i];

                                        console.log('DK mappaSezioni k: ', k);
                                        //Compongo l'xml da sostituire nella lista dei componenti
                                        var xmlComponenti = '';
                                        for(var j = 0; j < result.length; j++){
                                            xmlComponenti += result[j][k] ? result[j][k] : ''; 
                                        }

                                        //Sostituisco nell'xml della sezione l'xml composto precedentemente con la lista dei componenti
                                        mappaSezioni[k] = mappaSezioni[k].replace(this.PLACEHOLDER_COMPONENTI,xmlComponenti);
                                    }
                                    console.log('DK mappaSezioni END: ', mappaSezioni);

                                    //Una volta riempite tutte le sezioni non mi resta che creare una stringa unica e sostituirla nel root xml
                                    var xmlSezioni = '';
                                    console.log('DK Object.keys(mappaSezioni): ', Object.keys(mappaSezioni));
                                    for(var i = 0; i < Object.keys(mappaSezioni).length; i++){
                                        console.log('DK Object.keys(mappaSezioni)[i]: ', Object.keys(mappaSezioni)[i]);
                                        var k = Object.keys(mappaSezioni)[i];
                                        xmlSezioni +=  mappaSezioni[k];
                                    }

                                    this.onXmlGenerated(this.rootXml.replace(this.PLACEHOLDER_SEZIONI,xmlSezioni));
                                }

                                
                            })
                            .catch((error) => {
                                this.showSpinner = false;
                                console.warn(error.body.message);
                            });*/
                        }
                    }
                });
            }
        });
    }

    @track xml;

    //QUI INSERIREMO LE AZIONI DA FARE DOPO CHE L'XML VIENE GENERATO, PER ESEMPIO LA CHIAMATA AL WEB SERVICE
    //  RICEVE IN INGRESSO L'XML COMPLETO
    onXmlGenerated(xml){
        //TODO
        console.warn(xml);
        this.xml = xml
        console.log('xml: ', this.xml);
        this.pdfGenerato = true;
        this.executeCall();
    }

    startTime;
    startTimeWS;
    endTimeWS;
    endTime;

    executeCall(){

        this.showSpinner = true;
        this.startTimeWS = new Date();
        return executeCall({xml: this.xml, currentAccount: this.accountData, recordTypeDeveloperName: this.recordTypeDeveloperName})
        .then(data =>{

            this.showSpinner = false;
            console.log('PDF', data);
            if(data != null){

                const timeElapsed = Date.now();
                const today = new Date(timeElapsed);
                console.log('PDF', data);
                const linkSource = `data:application/pdf;base64,${data}`;
                const downloadLink = document.createElement("a");
                const fileName = this.accountData.CRM_NDG__c + "_" + today.toLocaleDateString() + ".pdf";
    
                downloadLink.href = linkSource;
                downloadLink.download = fileName;
                downloadLink.click();
                this.endTimeWS = new Date();
                this.endTime = new Date();

                console.log('TOT Time: ', this.endTime - this.startTime);
                console.log('WS Time: ', this.endTimeWS - this.startTimeWS);
                console.log('GetFullMetadataFromSelected Time: ', this.endGetFullMetadataFromSelected - this.startGetFullMetadataFromSelected);
                console.log('GetRootXML Time: ', this.endGetRootXML - this.startGetRootXML);
                this.showToastMessage('PDF GENERATO CORRETTAMENTE', 'success');
                this.closeModal();
            }else{
                this.showToastMessage('UNEXPECTED ERROR', 'error');
            }
        })
        .catch(err =>{

            this.showSpinner = false;
            console.log('DK executeCall.err', err);
        });
    }

    //E:Modifica per gestire xml con promise lato javascript
    downloadPDF(){
        if(this.canChoose){

            this.showSpinner = true;
        }
        this.startTime = new Date();
        return this.generaXmlWithPromise();

        //Vecchia Gestione waterfall, sostituita dalle promise
        /*generaXML({selectedSections: this.sectionsTableSelectedRows,recordId: this.recordId}).then(result => {
            console.clear();
            try{
                this.generaXmlWithPromise();
            }
            catch(e){
                debugger;
            }
            console.log('@@@ DEBUG @@@');
            console.log(JSON.parse(JSON.stringify(result)));
        }).finally(() => {
            this.showSpinner = false;
        });*/
    }

    openModal() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.showDataTable = false;
        this.sectionsTableSelectedRows = [];
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    sectionsTableRowSelection(event) {
        this.sectionsTableSelectedRows = event.detail.selectedRows;
    }

    //set icon based on Account Record Type
    //getRecordTypeIcon(RecordTypeName){
    //    if(RecordTypeName == 'AltraUnitaOrganizzativa'){
    //        return 'standard:account';
    //    }else if(RecordTypeName == 'Area'){
    //        return 'standard:account';
    //    }else if(RecordTypeName == 'Banca'){
    //        return 'standard:account';
    //    }else if(RecordTypeName == 'Business'){
    //        return 'standard:account';
    //    }else if(RecordTypeName == 'Cointestazione'){
    //        return 'standard:account';
    //    }else if(RecordTypeName == 'DirezioneRegionale'){
    //        return 'standard:account';
    //    }else if(RecordTypeName == 'FilialeDiRelazione'){
    //        return 'standard:account';
    //    }else if(RecordTypeName == 'GruppoFinanziario'){
    //        return 'standard:account';
    //    }else if(RecordTypeName == 'IndustriesHousehold'){
    //        return 'standard:account';
    //    }else if(RecordTypeName == 'IndustriesIndividual'){
    //        return 'standard:account';
    //    }else if(RecordTypeName == 'IndustriesInstitution'){
    //        return 'standard:account';
    //    }else{
    //        return 'standard:account';
    //    }
    //}

    showToastMessage(text, type) {
        const toastEvent = new ShowToastEvent({
            title: '',
            message: text,
            variant: type
        });
        this.dispatchEvent(toastEvent);
    }

    // NEW DK 
    @track showDataTable = false;
    get optionsSezione(){
        
        return [
            {
                label: 'SELEZIONA TUTTO',
                value: '1'
            },
            {
                label: 'SELEZIONA SEZIONI',
                value: '2'
            }
        ];
    }

    defaultSelection = '1';

    handlePickListChange(event){
        if(event.target.value == '2'){
            this.sectionsTableSelectedRows = [];
            this.showDataTable = true;
        }else{
            this.sectionsTableSelectedRows = this.sectionsTableData;
            console.log('this.sectionsTableSelectedRows', this.sectionsTableSelectedRows);
            this.showDataTable = false;
        }
    }
    // NEW DK 

    //Utili in seguito
    /*downloadPDFVERO(){


        var base64 = '';
        const linkSource = `data:application/pdf;base64,${base64}`;
        const downloadLink = document.createElement("a");
        const fileName = "documentogenerato.pdf";

        downloadLink.href = linkSource;
        downloadLink.download = fileName;
        downloadLink.click();
       
    }*/

    sortBy( field, reverse, primer ) {

        const key = primer
            ? function( x ) {
                  return primer(x[field]);
              }
            : function( x ) {
                  return x[field];
              };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            // console.log('DK sort - reverse: ', reverse);
            let ascending = reverse == 1;
            // equal items sort equally
            if (a === b) {
                return 0;
            }
            // nulls sort after anything else
            else if (!Boolean(a)) {
                return 1;
            }
            else if (!Boolean(b)) {
                return -1;
            }
            // otherwise, if we're ascending, lowest sorts first
            else if (ascending) {
                return a < b ? -1 : 1;
            }
            // if descending, highest sorts first
            else { 
                return a < b ? 1 : -1;
            }
        };

    }
}