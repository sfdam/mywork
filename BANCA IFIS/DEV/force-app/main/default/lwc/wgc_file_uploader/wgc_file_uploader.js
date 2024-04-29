import { LightningElement, wire,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssFileUploaderLWC from '@salesforce/resourceUrl/cssFileUploaderLWC';
import { getRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import NOTA_DOCUMENTO_OBJECT from '@salesforce/schema/WGC_Nota_Documento__c';
import getDocMetadata from '@salesforce/apex/WGC_FileUploaderController.getDocMetadata'; 
import getDatiCI from '@salesforce/apex/WGC_FileUploaderController.getDatiCI';
import uploadDocMultipart from '@salesforce/apex/WGC_FileUploaderController.uploadDocMultipart';

const FIELDS = ['Name', 'Note__c','Id_univoco__c'];

export default class Wgc_file_uploader extends LightningElement {
    
    showSpinner = true;
    fam = true;   
    notaObject = NOTA_DOCUMENTO_OBJECT;
    famigliaDocumenti = [];
    bloccaDoc = false;
    selectedSogg;
    selectedSC;
    selectedF;
    selectedNoteMav = '';
    documentId;

    @api showLista = false;
    @api idNota = '';
    @api recordId;
    @api datiDoc;
    @api docFisso;
    @api indiceAttore;
    @api optyId;
    @api soggetti;
    @api listToUpdate;
    @api datiDocNote;
    @api noteDoc;
    
    @wire(getRecord, { recordId: '$idNota', fields: FIELDS })
    notaRecord;

    @track mappatura;
    @track tipo = [];
    @track soggettiPicklist;
    @track dataProduzione;
    @track dataScadenza;

    connectedCallback(){        
        loadStyle(this, cssFileUploaderLWC);  
        this.initialize();          
    }

    // CUSTOM EVENT
    handleDialogClose(result){        
        const closemodal = new CustomEvent('modal', { bubbles: true, composed: true, detail : { open: false, onlyNote:this.showLista, result: result } });
        this.dispatchEvent(closemodal);
    }

    enableSpinner(){
        this.showSpinner = true;
    }

    disableSpinner(){
        this.showSpinner = false;
    }  

    closeModal(){
        this.handleDialogClose('ANNULLA');
    }

    get checkDisable(){
        return this.fam;
    }

    get checkRequired(){
        return !this.fam;
    }

    get showSoggetti(){
        return this.soggetti!=null && this.soggetti.length!=0;
    }

    get isMAV(){
        return this.docFisso == 'docMAV';
    }

    get isFileUploaded(){
        return this.documentId != null &&  this.documentId != undefined;
    }

    get noteExists(){
        return this.docFisso == 'docMAV' ? 'addPaddingTop':'';
    }

    get optionsMAV() {
        return [           
            { label: 'In Bonis', value: 'CC' },
            { label: 'Procedura', value: 'CE' },
        ];
    }

    initialize(){       
        this.enableSpinner();  
        var isNota = this.showLista;
        console.log('@@@ isNota ' , isNota);

        var docFisso = this.docFisso;
		console.log('@@@ docFisso ' , docFisso);
        
        if (this.showSoggetti){
            this.populateSoggettiPicklist();
        }		

		if(isNota == false){

            var isDocFisso = true;
			if(docFisso == null || docFisso == undefined){
				isDocFisso = false;
            }
            
            getDocMetadata({"isDocFisso" : isDocFisso})
            .then(result => { 
                if (result.success){
                    var risposta = result.data;
                    console.log('@@@ risposta ok ' , risposta);
					this.mappatura = risposta[0];				
                    var arrayMeta = [];
                    var famigliaDocumenti = [];

                    for(var key in risposta[0]){
                        var singleMeta = {};
                        singleMeta.label = key;
                        singleMeta.value = key;
                        arrayMeta.push(singleMeta);    
                        singleMeta.documento = risposta[0][key];   
                        famigliaDocumenti.push(singleMeta);                  
                    }

                    console.log('@@@ arrayMeta ' , arrayMeta );
                    this.mappatura = arrayMeta;
                    this.famigliaDocumenti = famigliaDocumenti;
                    this.prepopulateField();                    
                }

                this.disableSpinner(); 
            });		
			
		}else {
			var notaId = this.idNota;
			console.log('@@@ notaId ' , notaId);

			var recId = this.recordId;
			console.log('@@@ recId ' , recId);

			if(notaId == undefined || notaId == null || notaId == ''){
				this.createNota();
            }else {
                this.disableSpinner();  
            }         
            
        }   
    }

    createNota(){
        this.enableSpinner();  
        const recordInput = {apiName: NOTA_DOCUMENTO_OBJECT.objectApiName};
        createRecord(recordInput)
            .then(record => {
                this.idNota = record.id; 
                console.log("nota creata");               
            }).finally(() => {
                this.disableSpinner();  
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

    populateSoggettiPicklist(){
        this.enableSpinner();
        console.log("populateSoggettiPicklist"); 
        var soggArray = [];
        for(var key in this.soggetti){
            var singleMeta = {};
            singleMeta.label = this.soggetti[key].name;
            singleMeta.value = this.soggetti[key].id;
            soggArray.push(singleMeta);                        
        }
        this.soggettiPicklist = soggArray;
        this.disableSpinner();
    }

    prepopulateField(){
        this.enableSpinner();
        console.log("prepopulateField");
        var docFisso = this.docFisso;
		console.log('@@@ docFisso ' , docFisso);
		
        var codDoc = this.datiDoc;
        console.log('@@@ datiDoc ' ,codDoc);

		if(docFisso != null && docFisso != undefined && docFisso != ''){
			console.log('@@@ docFisso ' , docFisso);

			if(codDoc == 'SY0000002'){
				console.log('@@@ chiamata');
				this.getDatiCartaI();
			} else {
				this.newMappingDoc(false);
			}
		}else {		
			this.newMappingDoc(false);
        }
        
        this.disableSpinner();
    }

    getDatiCartaI(){
        this.enableSpinner();
        var recId = this.recordId;
        getDatiCI({"contactId" : recId})
        .then(response => {
            if (response.success){
                var risposta = response.data;
                if(risposta != null){
                    this.dataProduzione = risposta.DataEmissioneDoc__c;
					this.dataScadenza =  risposta.DataScadenzaDoc__c;

					var arrayMeta = this.mappatura;
					var arrayTipo = this.tipo;
					var singleMeta = {};
					singleMeta.famiglia = 'Documenti persona fisica';
					singleMeta.documento = [];
					var singleDoc = {};
					singleDoc.Documento__c = 'SY0000002';
					singleDoc.Sottoclasse__c = 'Documenti persona fisica';
					singleDoc.MasterLabel = 'Carta d\'Identità';
					singleMeta.documento.push(singleDoc);
					arrayMeta.push(singleMeta);
					arrayTipo.push(singleDoc);

					this.mappatura = arrayMeta;
					this.tipo = arrayTipo;
					this.selectedF = singleMeta.famiglia;
					this.selectedSC = singleDoc.Documento__c;

                    this.template.querySelector('[data-id="famiglia"]').disabled = true;
                    this.template.querySelector('[data-id="tipo"]').disabled = true;
					
                    //Disabilito la modifica delle date
                    this.template.querySelector('[data-id="datascad"]').disabled = true;	
                    this.disableSpinner();				
                }
            }  else {
                var arrayMeta = this.mappatura;
				var arrayTipo = this.tipo;
				var singleMeta = {};
				singleMeta.famiglia = 'Documenti persona fisica';
				singleMeta.documento = [];
				var singleDoc = {};
				singleDoc.Documento__c = 'SY0000002';
				singleDoc.Sottoclasse__c = 'Documenti persona fisica';
				singleDoc.MasterLabel = 'Carta d\'Identità';
				singleMeta.documento.push(singleDoc);
				arrayMeta.push(singleMeta);
				arrayTipo.push(singleDoc);

				this.mappatura = arrayMeta;
                this.tipo = arrayTipo;
                this.selectedF = singleMeta.famiglia;
                this.selectedSC = singleDoc.Documento__c;

				this.template.querySelector('[data-id="famiglia"]').disabled = true;					
                this.template.querySelector('[data-id="tipo"]').disabled = true;	
				
				//Disabilito la modifica delle date
				var dataS = new Date();
				this.dataProduzione = dataS.toISOString();
				dataS.setMonth(dataS.getMonth() + 120);
                this.dataScadenza = dataS.toISOString();
                
                this.template.querySelector('[data-id="datascad"]').disabled = true;
                this.disableSpinner();
            }        
        });		
    }
    
    newMappingDoc (needsChange){
        this.enableSpinner();
        console.log("newMappingDoc");
        (!needsChange && this.selectedSC != 'SY0000002') ? this.dataProduzione = undefined : '';
        this.dataScadenza = undefined;
        this.template.querySelector('[data-id="datascad"]').disabled = false;
		
		//Carico tutte le mappature
		var mappatura = this.famigliaDocumenti;
		var doc = this.datiDoc;

		var bloccaDoc = this.bloccaDoc;

		mappatura.forEach((item, index) =>{
			for(var key in item){ 
				if(key == "documento"){
					item[key].forEach((rec, index) =>{
						if(rec.Documento__c == doc){
                            var documenti = item["documento"];                           
                            var arrayMeta = [];  
                            for(var key in documenti){
                                var singleMeta = {};
                                singleMeta.label = documenti[key].MasterLabel;
                                singleMeta.value = documenti[key].Documento__c;
                                arrayMeta.push(singleMeta);                                            
                            }

                            this.tipo = arrayMeta;
							
							this.selectedF =  rec.Sottoclasse__c;							
							this.selectedSC = rec.Documento__c;

                            if(!bloccaDoc){
                                this.template.querySelector('[data-id="famiglia"]').disabled = true;
                                this.template.querySelector('[data-id="tipo"]').disabled = true;
                            }     

							//Aggiunta nuovo requisito su prepopolamento date
							console.log('@@@ giorni ' , rec.Giorni_Data_Scadenza__c);
							
							if(rec.Giorni_Data_Scadenza__c != undefined){
								var dataScad = new Date();
								var dataProd = this.dataProduzione;
								console.log('@@@ dataProderita ', dataProd);
								console.log('@@@ dataProderita new Date ', dataProd != undefined ? new Date(dataProd).getDate() : 'data prod prepopolata');

								dataProd != undefined ? dataScad = dataProd : '';
								console.log('@@@ dataScad before addDays ' + dataScad );

								dataScad = new Date(dataScad);

								dataProd != undefined ? dataScad.setMonth(new Date(dataProd).getMonth() + rec.Giorni_Data_Scadenza__c) : dataScad.setMonth(new Date().getMonth() + rec.Giorni_Data_Scadenza__c);
								console.log('@@@ dataScad after addDays ' + dataScad );
								this.dataScadenza = dataScad.toISOString();
                                this.template.querySelector('[data-id="datascad"]').disabled = true;
                                
							} else if(this.selectedSC == 'SY0000002'){
								var dataS = new Date();
								var dataProd = this.dataProduzione;
								dataProd = new Date(dataProd);								
								dataProd.setMonth(dataProd.getMonth() + 12);
                                this.dataScadenza = dataProd.toISOString();
                                
							} else {								
								this.dataScadenza = undefined;
							}
							
							(rec.Data_documento_popolata__c && !needsChange && this.selectedSC != 'SY0000002') ? this.dataProduzione =  new Date().toISOString() : '';
							
						}
					});
				}
			}
        });
        
        this.disableSpinner();
    }   

    // HANDLER RECORD EDIT FORM
    handleError(event){
        console.log("handle error");
        this.idNota = null;
        this.showLista = true;
        this.initialize();
    }

    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        console.log('@@@ fields ' , fields);
        var docId = this.datiDocNote.index_value;
        console.log('@@@ docId ' , docId);
        var recordId = this.recordId;
        console.log('@@@ recordId ' , recordId);
        fields.Id_univoco__c = recordId + '_' + docId;
        this.noteDoc = fields.Note__c;
        this.template.querySelector('lightning-record-edit-form').submit(fields);        
    }

    handleSuccess(event){        
        const payload = event.detail;
        console.log(JSON.stringify(payload))
 
        var notaId = payload.id;
        console.log('@@@ notaId ' , notaId);          
    
        var datiDocNote = this.datiDocNote;    
        console.log('@@@ datiDocNote ' , JSON.stringify(datiDocNote));
    
        var lista = this.listToUpdate;
        console.log('@@@ listToUpdate ' , lista);
    
        var recordIdAttore = this.recordId;
        console.log('@@@ recordIdAttore ' , recordIdAttore); 
    
        var json = { "idNota" : notaId , "doc" : datiDocNote, "listToUpdate" : lista, "idAttore" : recordIdAttore };
        
        //Lancio evento per gestire l'inserimento di un nota ed aggangiare l'id al doc corretto
        this.dispatchEvent(
            new CustomEvent('note', { bubbles: true, composed: true, detail : { json: json, type : "note", success: true} })
        );   
        
        this.handleDialogClose('SALVA');
    }
    
    // HANDLER COMBOBOX EVENT
    changeFamDoc (event){
        var newValue = event.target.value;
        console.log("newValue",newValue);
        if(newValue != ''){
            this.fam =  false;
            this.selectedF = newValue;
            var mappatura = this.famigliaDocumenti;
            mappatura.forEach((item, index) =>{
                if(item.label == newValue){
                    console.log('@@@ item.documento ' , item.documento);
                    var arrayMeta = [];  
                    for(var key in item.documento){
                        var singleMeta = {};
                        singleMeta.label = item.documento[key].MasterLabel;
                        singleMeta.value = item.documento[key].Documento__c;
                        arrayMeta.push(singleMeta);                                            
                    }

                    this.tipo = arrayMeta;
                }
            });
        }
    }
 
    changeDoc (event){
        var value =  event.target.value;
        console.log('@@@ changeDoc value ', value);
        this.datiDoc = value;
        this.bloccaDoc = true;      
        this.selectedSC = value;
        console.log ('-----> WGC_FileUploader - changeSoggetto: '+value);  
        this.newMappingDoc(false);
    }

    changeSoggetto(event) {
        var value =  event.target.value;
		this.selectedSogg = value;
        console.log ('-----> WGC_FileUploader - changeSoggetto: '+value);
    }

    changeNoteMav(event){
        var value =  event.target.value;
		this.selectedNoteMav = value;
        console.log ('selectedNoteMav: '+value);
    }
    
    checkDataProduzione(event){
        this.dataProduzione = event.target.value;
        this.checkDataProduzioneHelper();        
        console.log('@@@ docFisso ' , this.docFisso);
        
        if(this.docFisso != 'SY0000002'){
            this.newMappingDoc(true);
        }else{
            this.newMappingDoc(false);
        }
    }

    checkDataScadenza(event){
        this.dataScadenza = event.target.value;
        console.log('@@@ checkDataScadenza ' , event.target.value); 
        this.checkDataScadenzaHelper();
    }

    checkDataProduzioneHelper(){
        return this.template.querySelector('[data-id="dataprod"]').checkValidity();		
	}

	checkDataScadenzaHelper(){
        return this.template.querySelector('[data-id="datascad"]').checkValidity();			
    }
    
    // CONVALIDA DATI
    convalidaDati(objectToValidate){
		var esito = true;		
		for(var key in objectToValidate){
            console.log('@@@ key ' , key);
            console.log('@@@ objectToValidate ' , objectToValidate[key]);
            if(objectToValidate.tipoDoc == 'EX0000173'){
			    if(objectToValidate[key] == null || objectToValidate[key] == undefined || objectToValidate[key] == ''){
				    esito = false;
                }
            } else {
                if(key != 'noteDocUpload' && (objectToValidate[key] == null || objectToValidate[key] == undefined || objectToValidate[key] == '')){
                    esito = false;
                }
            }
        }
        
		return esito;
    }
    
    // HANDLE FILE UPLOAD
    handleUploadFinished(event){        
        const uploadedFiles = event.detail.files;
        console.log('@@@ uploaded file ' , JSON.stringify(uploadedFiles[0]));
        this.documentId =  uploadedFiles[0].documentId;
        this.fileName = uploadedFiles[0].name;
    }  

    // PULSANTE SALVA
    salvaDoc(event){
        this.enableSpinner();
        event.preventDefault();

        //Mi costruisco un oggetto con tutti i valori da controllare
        var validDataProd = this.checkDataProduzioneHelper();
        var validDataScad = this.checkDataScadenzaHelper();
    
        if(!validDataProd){
            this.template.querySelector('[data-id="dataprod"]').reportValidity();       
            this.disableSpinner();     
            return;
        } else if(!validDataScad){
            this.template.querySelector('[data-id="datascad"]').reportValidity();  
            this.disableSpinner();          
            return;
        }

        var dataProduzione = this.dataProduzione;
        var tmp = new Date(dataProduzione);
        dataProduzione = tmp.toLocaleDateString('it-IT', { year: 'numeric', month: '2-digit', day: 'numeric' });
        var dataScadenza = this.dataScadenza;
        tmp = new Date(dataScadenza);
        dataScadenza = tmp.toLocaleDateString('it-IT', { year: 'numeric', month: '2-digit', day: 'numeric' });
        var famiglia = this.selectedF;       
        var tipoDoc = this.selectedSC;
        var docId = this.documentId;        
        var optyId = this.optyId;

        var docWrap = { "dataProduzione" : dataProduzione != undefined ? dataProduzione : '' , 
                        "dataScadenza" : dataScadenza != undefined ? dataScadenza : '',
                        "famiglia" : famiglia,
                        "tipoDoc" : tipoDoc,
                        "docId" : docId,
                        "noteDocUpload": this.selectedNoteMav
        };
        
        console.log('@@@ docWrap ' , JSON.stringify(docWrap));

        var accountId = this.recordId;        
        var idSoggetto = this.selectedSogg;                         
        var esitoValidazione = true;

        esitoValidazione = this.convalidaDati(docWrap);

        if(esitoValidazione){
            console.log("esito OK");   
            console.log('-----> WGC_FileUploader.salvaDoc - id soggetto: ' +(idSoggetto != null) ? idSoggetto : accountId);
            this.docWrapper =  docWrap;
            this.enableSpinner();
            uploadDocMultipart({"recordId" : (idSoggetto != null) ? idSoggetto : accountId, "docToInsert" : JSON.stringify(docWrap),
                                "optyId" : optyId,"delDoc" : true})
            .then(result => {
                if (result.success){
                    var risposta = result;
                    console.log('@@@ risposta upload ' , risposta);
                    const evt = new ShowToastEvent({
                        title: 'Upload eseguito!',
                        message: "Upload eseguito con successo",
                        variant: 'success',
                        mode: 'pester'
                    });
        
                    this.dispatchEvent(evt); 

                    console.log('@@@ datiDoc ', JSON.stringify(this.datiDoc));
                    console.log('@@@ listaDocs ' , this.docFisso);
                    console.log('@@@ indiceAttore ' , this.indiceAttore);

                    var future = false;
                    if(risposta.data.length > 0){   
                        var evtParam = { "id" : (risposta.data[0].payload) ? risposta.data[0].payload.datiDocumento.idDocumento : null, "index_value" : this.datiDoc, "listToUpdate" : this.docFisso, "indiceAttori" : this.indiceAttore, "dataScadenza" : tmp, "title" : this.fileName};
                    } else if(risposta.data.length == 0){  
                        var evtParam = { "index_value" : this.datiDoc, "listToUpdate" : this.docFisso, "indiceAttori" : this.indiceAttore, "dataScadenza" : tmp, "title" : this.fileName};
                        future = true;
                    }    
                    
                    const custEvent = new CustomEvent('uploadfile', { bubbles: true, composed: true, detail : { param: evtParam,futureCall :future } });  
                    
                    this.dispatchEvent(custEvent);
                    this.handleDialogClose('SALVA');

                }else {
                    const evt = new ShowToastEvent({
                        title: 'Attenzione!',
                        message: "Errore durante l'upload del documento, riprovare",
                        variant: 'error',
                        mode: 'pester'
                    });
        
                    this.dispatchEvent(evt); 
                }

                this.disableSpinner();
            });

        } else{                               
            const evt = new ShowToastEvent({
                title: 'Attenzione!',
                message: 'Compilare tutti i campi per salvare il documento',
                variant: 'error',
                mode: 'pester'
            });

            this.disableSpinner();
            this.dispatchEvent(evt); 
        }        
    }

    eliminaNote(event){
        event.preventDefault();
        this.enableSpinner();
        const recordId = this.idNota;
        console.log('delete note' + recordId);
        deleteRecord(recordId)
            .then(() => {
                var datiDocNote = this.datiDocNote;        
                console.log('@@@ datiDocNote ' , JSON.stringify(datiDocNote));
        
                var lista = this.listToUpdate;
                console.log('@@@ listToUpdate ' , lista);

                var recordIdAttore = this.recordId;
                console.log('@@@ recordIdAttore ' , recordIdAttore); 
        
                var json = { "idNota" : null , "doc" : datiDocNote, "listToUpdate" : lista, "idAttore" : recordIdAttore };

                this.dispatchEvent(
                    new CustomEvent('note', { bubbles: true, composed: true, detail : { json: json, type:"note", success: true} })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore!',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            });      
    }   
}