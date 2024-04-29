import { LightningElement, api, track, wire  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkPortafoglioExists from '@salesforce/apex/RiportafogliazioneController_V2.checkPortafoglioExists';
import updateValues from '@salesforce/apex/RiportafogliazioneController_V2.updateValues';
import getAllData from '@salesforce/apex/RiportafogliazioneController_V2.getAllData';
import init from '@salesforce/apex/RiportafogliazioneController_V2.init';
import getInfoConfig from '@salesforce/apex/RiportafogliazioneController_V2.getInfoConfig';


const COLUMNS = [
    {
        label: 'NDG',
        initialWidth: 100,
        fieldName: 'NDG__c',
        type: 'text'
    },
    {
        label: 'Denominazione',
        initialWidth: 200,
        fieldName: 'Denominazione',
        type: 'text'
    },
    {
        label: 'Portafoglio di partenza',
        initialWidth: 200,
        fieldName: 'Portafoglio_Di_Partenza__c',
        type: 'text'
    },
    {
        label: 'MMDS',
        initialWidth: 100,
        fieldName: 'MMDS__c',
        type: 'text'
    },
    {
        label: 'MMDS Obiettivo',
        initialWidth: 150,
        fieldName: 'MMDS_Obiettivo__c',
        type: 'text'
    },
    {
        label: 'Portafoglio di destinazione',
        initialWidth: 200,
        fieldName: 'Portafoglio_Di_Destinazione__c',
        type: 'text'
    },
    {
        label: 'Stato Spostamento',
        initialWidth: 200,
        fieldName: 'Stato_Spostamento__c',
        type: 'picklistColumn', 
         editable: true,
           typeAttributes: {
              placeholder: 'Seleziona Stato Spostamento', 
              options: { fieldName: 'pickListOptionsStatoSpost' }, 
              value: { fieldName: 'Stato_Spostamento__c'}, 
              context: { fieldName: 'Id' } 
          }
    },
    {
        label: 'Motivo del rifiuto',
        initialWidth: 200,
        fieldName: 'Motivo_di_rifiuto__c',
        type: 'picklistColumn', 
        editable:{ fieldName: 'editableField'},
         typeAttributes: {
            placeholder: 'Seleziona Motivo di rifiuto', 
            options: { fieldName: 'pickListOptionsMotivoRifiuto' }, 
            value: { fieldName: 'Motivo_di_rifiuto__c' }, 
            context: { fieldName: 'Id' } 
        }
    },
    {
        label: 'Portafoglio alternativo',
        initialWidth: 200,
        fieldName: 'Portafoglio_Alternativo_Name__c',
        type: 'text',
        editable:{ fieldName: 'editablePTFAlter'}

    },
    {
        label: 'Patrimonio',
        initialWidth: 150,
        fieldName: 'Patrimonio',
        type: 'currency'
    },
    {
        label: 'Fatturato',
        initialWidth: 150,
        fieldName: 'Fatturato',
        type: 'currency'
    },
    {
        label: 'Accordato',
        initialWidth: 150,
        fieldName: 'Accordato',
        type: 'currency'
    },
    {
        label: 'Utilizzato',
        initialWidth: 150,
        fieldName: 'Utilizzato',
        type: 'currency'
    },
    {
        label: 'Altro',
        initialWidth: 300,
        fieldName: 'Altro__c',
        type: 'text',
        editable:{ fieldName: 'editableField'}
    },
];

export default class Riportafogliazione_v2 extends LightningElement {
   
    @track searchedNome;
    @track searchedNDG;
    @track searchedMWOld;
    @track searchedMWNew;
    @track searchedMMDSOb;
    @track searchedMMDS;
    @track searchedPatrimonio;
    @track searchedPatrimonioMin;
    @track searchedUtilizzato;
    @track searchedUtilizzatoMin;

    @track loaded=false;
    @track isNDGAffidabili= false;

    @track draftValues = [];
    @track valuePtfAlternativo;

    @api lastSavedData = [];
    @api filteredRecords=[];
    @api records=[];
    @api userInfo={};

    @api ptfAlternativoId;
    @api percentualeAffinamento;
    
    @api sommaMaxRecords = 0;
    @api sommaRifiutato = 0;
    @api sommaRowToUpdate = 0;
    @api sommaAccettato = 0;
    @api sommaMotivoDiRifiuto = 0;
    @api sommaRifiutatoPTFDifferente = 0;

    @api tipoImpurezza;
    @api sottoTipologiaSpostamento;


    handleCellChange(event) {

        try {
            this.ptfAlternativoId=[];
            const changedFields = event.detail.draftValues;
            const draftIds = this.draftValues.map(draft => draft.Id);
            var cloneDraftValues = JSON.parse(JSON.stringify(this.draftValues));
            changedFields.forEach(element =>{
                const index = draftIds.indexOf(element.Id);
                if (index === -1) {
                    cloneDraftValues.push(element);
                } else {
                    Object.keys(element).forEach(property => {
                        if (property !== 'Id') {
                            cloneDraftValues[index][property] = element[property];
                        }
                    });
                }      
                this.filteredRecords.forEach(ele =>{
                    if (ele.Id === element.Id) {
                        this.lastSavedData.forEach(savedEle => {
                            if (savedEle.Id === ele.Id) {
                                if(savedEle.Stato_Spostamento__c !== ele.Stato_Spostamento__c){
                                    savedEle.statoChanged = true;
                                }
                                if(!savedEle.statoChanged){

                                    if(savedEle.Motivo_di_rifiuto__c !== ele.Motivo_di_rifiuto__c){
                                        savedEle.motivoChanged = true;
                                    }
                                    if(savedEle.motivoChanged){
                                        savedEle.Motivo_di_rifiuto__c = ele.Motivo_di_rifiuto__c;
                                        savedEle.editableField = ele.editableField;
                                        savedEle.Portafoglio_Alternativo_Name__c = ele.Portafoglio_Alternativo_Name__c;
                                        savedEle.editablePTFAlter = ele.editablePTFAlter;
                                    }else{
                                        savedEle.Portafoglio_Alternativo_Name__c = ele.Portafoglio_Alternativo_Name__c;
                                        savedEle.editablePTFAlter = ele.editablePTFAlter;
                                    }
                                }
                            }
                        });
                        if (element.hasOwnProperty('Stato_Spostamento__c')) {
                            ele.Stato_Spostamento__c = element.Stato_Spostamento__c;
                            if (element.Stato_Spostamento__c === 'RIFIUTATO') {
                                ele.editableField = true;                              
                            }else{

                                ele.editableField = false;
                                ele.Motivo_di_rifiuto__c = null;
                                ele.Altro__c = null;
                                ele.Portafoglio_Alternativo_Name__c = null;
                                ele.editablePTFAlter = false;  
                                ele.Portafoglio_Alternativo__c=null;            
                                cloneDraftValues.forEach(draftValue =>{

                                    if(draftValue.Id === ele.Id){
                                        let elementKeys =  Object.keys(draftValue);
                                        elementKeys.forEach(property =>{
    
                                            if(property !== 'Stato_Spostamento__c' && property !== 'Id'){
        
                                                delete draftValue[property];
                                            }
                                        })
                                    }
                                })

                            }
                        }
                        if(element.hasOwnProperty('Motivo_di_rifiuto__c')){
                            ele.Motivo_di_rifiuto__c = element.Motivo_di_rifiuto__c;
                            if (element.Motivo_di_rifiuto__c === 'portafoglio di destinazione differente') {
                                ele.editablePTFAlter = true;
                            }else {
                                ele.editablePTFAlter = false;
                                ele.Portafoglio_Alternativo_Name__c = null;
                                ele.Portafoglio_Alternativo__c=null;            
                            }
                        }
    
                        if(element.hasOwnProperty('Portafoglio_Alternativo_Name__c')) {
                            ele.Portafoglio_Alternativo_Name__c = element.Portafoglio_Alternativo_Name__c;
                        }
                    }
                })
            })
            this.draftValues = cloneDraftValues;
            this.setPages(this.filteredRecords);    
        }catch (error) {
            console.log('GR error: ' + error);        
        }         
    }

    handleSave(event) {

        try{
            let isOK = true;
            let saveDraftValues = event.detail.draftValues;
            let recordsToUpdate = [];
            let ptfNameToCheck = [];
            let sommaMotDiRifiuto = 0;
            let sommaSoloRifiutato = 0;
            let sommaSoloRifiutatoMotDiRifiuto = 0;
            this.showSpinner = true;
            let updatedRifiuti = [];
            saveDraftValues.forEach((record) => {
                this.filteredRecords.forEach(ele =>{
                    if (ele.Id === record.Id) {
                        let elementKeys =  Object.keys(record);
                        for(var i = 0; i < elementKeys.length; i++){
                            if(elementKeys[i] != 'Id'){

                                ele[elementKeys[i]] = record[elementKeys[i]];
                            }
                        }
                        if(ele.Stato_Spostamento__c === 'RIFIUTATO' && (ele.Motivo_di_rifiuto__c === null || ele.Motivo_di_rifiuto__c === undefined)){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Compilare motivo di rifiuto per gli spostamenti rifiutati.',
                                    variant: 'error'
                                })
                            );

                            isOK = false;
                        }
                        if(ele.Motivo_di_rifiuto__c ==='portafoglio di destinazione differente' && (ele.Portafoglio_Alternativo_Name__c === null || ele.Portafoglio_Alternativo_Name__c === undefined)){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Indicare il portafoglio alternativo prima di continuare.',
                                    variant: 'error'
                                })
                            );
                            isOK = false;
                        }
                        if(Boolean(ele.Portafoglio_Alternativo_Name__c)){
                            ptfNameToCheck.push(ele.Portafoglio_Alternativo_Name__c)
                        }else if(isOK || record.Stato_Spostamento__c === 'ACCETTATO'){
                            recordsToUpdate.push(ele);
                        }
                        if(ele.Stato_Spostamento__c === 'RIFIUTATO'){
                            updatedRifiuti.push(ele);
                            if(ele.Motivo_di_rifiuto__c === 'portafoglio di destinazione differente'){
                                sommaMotDiRifiuto++;
                            }
                        }
                    }
                });
            });

            if(isOK){

                checkPortafoglioExists({nomePTFSet: ptfNameToCheck})
                .then(result => {
                    console.log('result:',result);
                    updatedRifiuti.forEach(record =>{
                        this.filteredRecords.forEach(ele =>{
                            if (ele.Id === record.Id) {
                                if(Boolean(ele.Portafoglio_Alternativo_Name__c)){
                                    
                                    ele.Portafoglio_Alternativo__c = result[ele.Portafoglio_Alternativo_Name__c];
                                    let ptfDestinazioneNameSplit = ele.Portafoglio_Di_Destinazione__c.split('-');
                                    let ptfAlternativoNameSplit = ele.Portafoglio_Alternativo_Name__c.split('-');
                    
                                    if(ptfDestinazioneNameSplit[1] !== ptfAlternativoNameSplit[1]  || ptfDestinazioneNameSplit[2] !== ptfAlternativoNameSplit[2] || ptfDestinazioneNameSplit[3] !== ptfAlternativoNameSplit[3] || ele.Portafoglio_Alternativo_Name__c.substr(-2) === '75'){
                                        isOK = false;
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Errore',
                                                message: 'Il Portafoglio alternativo deve appartenere alla stessa filiale ed avere stesso modello di servizio del portafoglio di destinazione precedentemente indicato.',
                                                variant: 'error'
                                            })
                                        );
                                    }else if(ele.Portafoglio_Alternativo_Name__c === ele.Portafoglio_Di_Destinazione__c){
                                        isOK = false;      
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Errore',
                                                message: 'Indicare un portafoglio differente da quello inserito.',
                                                variant: 'error'
                                            })
                                        ); 
                                    }else if(!Boolean(ele.Portafoglio_Alternativo__c)){
                                        isOK = false;      
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Errore',
                                                message: 'Non esiste un portafoglio con questo Nome.',
                                                variant: 'error'
                                            })
                                        ); 
                                    }
    
                                    if(isOK){
                                        recordsToUpdate.push(ele);
                                    }
                                }
                            }
                        });
                    });
    
                    if(isOK && this.userInfo.Profilo__c!='NEC_D.0'){
                        this.isNDGAffidabili=true;
                        if(updatedRifiuti.length > 0){
                            let rifiutatoConMotivoPTFDifferente = 0;
                            rifiutatoConMotivoPTFDifferente = updatedRifiuti.length - sommaMotDiRifiuto;
                            if (rifiutatoConMotivoPTFDifferente > this.sommaRowToUpdate) {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        message: 'Hai superato il limite di record da aggiornare',
                                        variant: 'error'
                                    })
                                );
                                isOK = false;
                            }
                        }
                    }
        
                    if(isOK){
                        updateValues({ recordsToUpdate: recordsToUpdate})
                        .then(result => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Successo',
                                    message: 'Salvataggio avvenuto con successo!',
                                    variant: 'success'
                                })
        
                            );
        
                            this.connectedCallback();
                            this.draftValues = [];
                        })
                        .catch(error => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Errore',
                                    message: 'Qualcosa è andato storto.',
                                    variant: 'error'
                                })
                            );
                            console.error('gr err:', error);
                        });
                    }
                })
            }
        } catch (error) {
            console.log('GR error: ' , error);
        }   
    }
    columns=COLUMNS;

    connectedCallback() {

        init().
        then(resultId => {
            this.userInfo= resultId[0];
            getAllData({tipoImpurezza: this.tipoImpurezza, sottoTipologiaSpostamento:this.sottoTipologiaSpostamento}).
            then(result => {
                this.getAllData = result;
                this.lastSavedData = JSON.parse(JSON.stringify(result)); 
                let sumRifiutato = 0;
                let sumAccettato = 0;
                let sumMotivoDiRifiuto = 0;
                console.log('GR result: ' + JSON.stringify(this.getAllData));
                this.getAllData.forEach(element =>{
                    this.ptfAlternativoId = element.Portafoglio_Alternativo__c;
                    element.editableField = element.Stato_Spostamento__c === 'RIFIUTATO';
                    if (element.Stato_Spostamento__c === 'RIFIUTATO'&& element.Motivo_di_rifiuto__c === 'portafoglio di destinazione differente') {
                        sumMotivoDiRifiuto++;
                    }
                    if (element.Stato_Spostamento__c === 'RIFIUTATO' && element.Motivo_di_rifiuto__c != null && element.Motivo_di_rifiuto__c != undefined) {
                        sumRifiutato++;

                    }else{
                        sumAccettato++;
                    }
                    
                    if(element.hasOwnProperty('Motivo_di_rifiuto__c')){
                        if (element.Motivo_di_rifiuto__c === 'portafoglio di destinazione differente') {
                            element.editablePTFAlter = true;
                        }else {
                            element.editablePTFAlter = false;
                        }
                    }
                    element.pickListOptionsStatoSpost = [{label:'RIFIUTATO', value:'RIFIUTATO'}, {label:'ACCETTATO', value:'ACCETTATO'}];
                    if(this.sottoTipologiaSpostamento=== 'PRIVATI'){
                        element.pickListOptionsMotivoRifiuto = [{label: 'successione in corso', value: 'successione in corso'},
                        {label: 'patrimonio in riduzione/aumento', value: 'patrimonio in riduzione/aumento'},
                        {label: 'estinzione rapporti in corso', value: 'estinzione rapporti in corso'},
                        {label: 'gestione creditizia', value: 'gestione creditizia'},
                        {label: 'collegamento a gruppo familiare', value: 'collegamento a gruppo familiare'},
                        {label: 'iniziativa commerciale in corso', value: 'iniziativa commerciale in corso'},
                        {label: 'portafoglio di destinazione differente', value: 'portafoglio di destinazione differente'}]; 
                    }else{
                        element.pickListOptionsMotivoRifiuto = [{label: 'fatturato in riduzione/aumento', value: 'fatturato in riduzione/aumento'},
                        {label: 'accordato in riduzione/aumento', value: 'accordato in riduzione/aumento'},
                        {label: 'società in liquidazione', value: 'società in liquidazione'},
                        {label: 'estinzione rapporti in corso', value: 'estinzione rapporti in corso'},
                        {label: 'gestione creditizia', value: 'gestione creditizia'},
                        {label: 'collegamento a Gruppo Aziendale', value: 'collegamento a Gruppo Aziendale'},
                        {label: 'iniziativa commericiale in corso', value: 'iniziativa commericiale in corso'},
                        {label: 'portafoglio di destinazione differente', value: 'portafoglio di destinazione differente'}];
                    }                   
                    if(element.hasOwnProperty('NDGId__c')){
                        element.Denominazione=element.NDGId__r.Name;
                    }
                    if(element.hasOwnProperty('NDGId__c')){
                        element.Denominazione=element.NDGId__r.Name;
                    }
                    if(element.hasOwnProperty('NDGId__c')){
                        element.Patrimonio=element.NDGId__r.PTF_Patrimonio__c;
                    }
                    if(element.hasOwnProperty('NDGId__c')){
                        element.Accordato=element.NDGId__r.PTF_Accordato__c;
                    }
                    if(element.hasOwnProperty('NDGId__c')){
                        element.Utilizzato=element.NDGId__r.PTF_Utilizzato__c;
                    }
                    if(element.hasOwnProperty('NDGId__c')){
                        element.Fatturato=element.NDGId__r.AnnualRevenue;
                    }
                    if(element.hasOwnProperty('Portafoglio_Old__c')){
                        element.MMDS__c=element.Portafoglio_Old__r.PTF_ModelloDiServizio__c;
                    }
                });
                if(this.userInfo.Profilo__c != 'NEC_D.0'){
                    this.isNDGAffidabili=true;
                    getInfoConfig({tipoImpurezza: this.tipoImpurezza, sottoTipologiaSpostamento:this.sottoTipologiaSpostamento})
                    .then(result => {
                        console.log('getInfoConfData: ' , JSON.stringify(result));
            
                        result.forEach(element =>{
                            const percAffinamento = element.Perc_Affinamento__c;
                            this.percentualeAffinamento = percAffinamento;
                        });
                    
                        this.sommaMotivoDiRifiuto = sumMotivoDiRifiuto;
                        this.sommaRifiutato = sumRifiutato;
                        this.sommaAccettato = sumAccettato;

                        let recordtoUpdate = 0;
                        const totalRows = this.filteredRecords.length;          
                        this.sommaMaxRecords = Math.ceil((this.percentualeAffinamento)*totalRows);
                        this.sommaRifiutatoPTFDifferente = this.sommaRifiutato - this.sommaMotivoDiRifiuto;
                        recordtoUpdate = this.sommaMaxRecords - this.sommaRifiutatoPTFDifferente;
                        this.sommaRowToUpdate = Boolean(recordtoUpdate) ? recordtoUpdate : 0; 
                    })
                    .catch(error => {
                        console.log('gr error', error);
                    });
                }
                
                this.records = this.getAllData.sort(function(a,b){
                    if(a.NDGId__r.PTF_IndiceSegmentoComportamentale__c>b.NDGId__r.PTF_IndiceSegmentoComportamentale__c){
                        return -1;
                    }
                    else if(a.NDGId__r.PTF_IndiceSegmentoComportamentale__c<b.NDGId__r.PTF_IndiceSegmentoComportamentale__c){
                        return 1;
                    }
                    else{
                        if((a.NDGId__r.RecordType.DeveloperName==='Cointestazione' ||  a.NDGId__r.RecordType.DeveloperName==='PersonAccount') && (b.NDGId__r.RecordType.DeveloperName==='Cointestazione' ||  b.NDGId__r.RecordType.DeveloperName==='PersonAccount')){
                            if(a.NDGId__r.PTF_Patrimonio__c>b.NDGId__r.PTF_Patrimonio__c){
                                return -1;
                            }
                            else if(a.NDGId__r.PTF_Patrimonio__c<=b.NDGId__r.PTF_Patrimonio__c){
                                return 1;
                            }
                        }
                        else if((a.NDGId__r.RecordType.DeveloperName==='Cointestazione' ||  a.NDGId__r.RecordType.DeveloperName==='PersonAccount') && b.NDGId__r.RecordType.DeveloperName!=='Cointestazione' &&  b.NDGId__r.RecordType.DeveloperName!=='PersonAccount'){
                            if(a.NDGId__r.PTF_Patrimonio__c>b.NDGId__r.PTF_Accordato__c){
                                return -1;
                            }
                            else if(a.NDGId__r.PTF_Patrimonio__c<=b.NDGId__r.PTF_Accordato__c){
                                return 1;
                            }
                        }
                        else if(a.NDGId__r.RecordType.DeveloperName==='IndustriesBusiness' && a.NDGId__r.RecordType.DeveloperName!==b.NDGId__r.RecordType.DeveloperName){
                            if(a.NDGId__r.PTF_Accordato__c>b.NDGId__r.PTF_Patrimonio__c){
                                return -1;
                            }
                            else if(a.NDGId__r.PTF_Accordato__c<=b.NDGId__r.PTF_Patrimonio__c){
                                return 1;
                            }
                        }
                        else{
                            if(a.NDGId__r.PTF_Accordato__c>b.NDGId__r.PTF_Accordato__c){
                                return -1;
                            }
                            else if(a.NDGId__r.PTF_Accordato__c<=b.NDGId__r.PTF_Accordato__c){
                                return 1;
                            }
                        }
                    }
                });
                this.filteredRecords = JSON.parse(JSON.stringify(this.records));
                this.lastSavedData = JSON.parse(JSON.stringify(this.filteredRecords));
                this.setPages(this.filteredRecords);
                this.loaded=true;
            }).catch(error => {
                console.log('gr init.error: ' , error);
            });
        })
        .catch(error => {
            console.log('gr error', error);
        });
    }

    handleCancel(){
        try {
            this.filteredRecords.forEach(record => {
                this.records.forEach(savedRecord => {
                    if (savedRecord.Id === record.Id) {
                        record.Stato_Spostamento__c = savedRecord.Stato_Spostamento__c;
                        record.Motivo_di_rifiuto__c = savedRecord.Motivo_di_rifiuto__c;
                        record.Portafoglio_Alternativo_Name__c = savedRecord.Portafoglio_Alternativo_Name__c;
                        record.editableField = savedRecord.editableField;
                        record.editablePTFAlter = savedRecord.editablePTFAlter;
                    }
                });
            });
            this.draftValues = [];
        }catch (error) {
            console.log(' error: ' , error);

        } 
    }

   
    handleReset(){
        this.searchedNome = '';
        this.searchedNDG = '';
        this.searchedMWOld='';
        this.searchedMWNew='';
        this.searchedPatrimonio=null;
        this.searchedPatrimonioMin=null;
        this.searchedUtilizzato=null;
        this.searchedUtilizzatoMin=null;
        this.searchedMMDS='';
        this.searchedMMDSOb='';
        this.handleSearch();
    }

   
    handleFilter(event){

        if(event.target.name == 'searchedNome'){
                
            this.searchedNome = event.target.value;
        }
        else if(event.target.name == 'searchedNDG'){
                
            this.searchedNDG = event.target.value;
        }
        else if(event.target.name == 'searchedMWOld'){
                
            this.searchedMWOld = event.target.value;
        }
        else if(event.target.name == 'searchedMWNew'){
                
            this.searchedMWNew = event.target.value;
        }
        else if(event.target.name == 'searchedPatrimonio'){
                
            this.searchedPatrimonio = event.target.value;
        }
        else if(event.target.name == 'searchedUtilizzato'){
                
            this.searchedUtilizzato = event.target.value;
        }
        else if(event.target.name == 'searchedPatrimonioMin'){
                
            this.searchedPatrimonioMin = event.target.value;
        }
        else if(event.target.name == 'searchedUtilizzatoMin'){
                
            this.searchedUtilizzatoMin = event.target.value;
        }
        else if(event.target.name == 'searchedMMDS'){
                
            this.searchedMMDS = event.target.value;
        }
        else if(event.target.name == 'searchedMMDSOb'){
                
            this.searchedMMDSOb = event.target.value;
        }
    }
    
    handleSearch(){

        this.filteredRecords = [];
        this.page = 1;
        try {
            
            for(var i in this.records){
                  
                if(Boolean(this.searchedNome)){

                    if(!this.records[i].Denominazione.toLowerCase().includes(this.searchedNome.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedNDG)){

                    if(!this.records[i].NDG__c.toLowerCase().includes(this.searchedNDG.toLowerCase())){
    
                        continue;
                    }
                }

                
                if(Boolean(this.searchedMWOld)){

                    if(!this.records[i].Portafoglio_Di_Partenza__c.toLowerCase().includes(this.searchedMWOld.toLowerCase())){
    
                        continue;
                    }
                }

                
                if(Boolean(this.searchedMWNew)){

                    if(!this.records[i].Portafoglio_Di_Destinazione__c.toLowerCase().includes(this.searchedMWNew.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedMMDS)){

                    if(!this.records[i].MMDS__c.toLowerCase().includes(this.searchedMMDS.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedMMDSOb)){

                    if(!Boolean(this.records[i].MMDS_Obiettivo__c)){

                        continue
                    }

                    if(!this.records[i].MMDS_Obiettivo__c.toLowerCase().includes(this.searchedMMDSOb.toLowerCase())){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedPatrimonio)){

                    if(this.records[i].Patrimonio>this.searchedPatrimonio){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedPatrimonioMin)){

                    if(this.records[i].Patrimonio<this.searchedPatrimonioMin || this.records[i].Patrimonio==undefined){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedUtilizzatoMin)){

                    if(this.records[i].Utilizzato<this.searchedUtilizzatoMin || this.records[i].Utilizzato==undefined){
    
                        continue;
                    }
                }

                if(Boolean(this.searchedUtilizzato)){

                    if(this.records[i].Utilizzato>this.searchedUtilizzato){
    
                        continue;
                    }
                }
    
                this.filteredRecords.push(this.records[i]);
            }
    
            
           
            this.setPages(this.filteredRecords);
        } catch (error) {
            
            console.log('GR error: ' + error);
        }
    }  

    //Pagination
    @track page = 1;
    @track pages = [];
    set_size = 50;
    perpage = 50;

    handleAvanti(){
        ++this.page;
    }
    handleIndietro(){
        --this.page;
    }
    
    get pagesList(){
        let mid = Math.floor(this.set_size/2) + 1 ;
        if(this.page > mid){
            return this.pages.slice(this.page-mid, this.page+mid-1);
        } 
        return this.pages.slice(0,this.set_size);
    }

    
    pageData = ()=>{
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        let recordToDisplay = this.filteredRecords.slice(startIndex,endIndex);
        return recordToDisplay;
    }

    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
    }  
    
    get disabledButtonIndietro(){
        return this.page === 1;
    }
    
    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.filteredRecords.length === 0 
        
    }

    get currentPageData(){
        return this.pageData();
    }
    //Pagination
   
}