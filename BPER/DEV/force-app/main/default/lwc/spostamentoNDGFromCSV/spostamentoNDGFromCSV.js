import { LightningElement, api, wire, track } from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import { getRecord, getRecordNotifyChange} from 'lightning/uiRecordApi';
import Status from '@salesforce/schema/SV_CSVLoad__c.Status__c';
import versionData from '@salesforce/schema/ContentVersion.VersionData';

import uploadFile from '@salesforce/apex/spostamentoNDGFromCSVController.upldFile';
import getFile from '@salesforce/apex/spostamentoNDGFromCSVController.getFile';
import submitFile from '@salesforce/apex/spostamentoNDGFromCSVController.submitFile';
import reuploadFile from '@salesforce/apex/spostamentoNDGFromCSVController.reuploadFile';
import deleteFile from '@salesforce/apex/spostamentoNDGFromCSVController.deleteFile';

export default class SpostamentoNDGFromCSV extends LightningElement 
{
    @api optionTemplate;
    @api recordId;
    @api myRecordId;
    @track valueTemplate;
    @track showFileUpload = false;
    @track showButtonUpload = false;
    @track fileDetails;
    @track documentId;
    @track fileName;
    @track contentversionId;
    @track csvRows;
    @track loaded = false;
    @api loading = false;
    @track disable = true;
    @track showOkFile = false;
    @api objsLibraryFile;

    get acceptedFormats() {
        return ['.csv'];
    }

    Status;
    @wire(getRecord, { recordId: '$recordId', fields: [Status]}) 
    userDetails({data}) {
        //console.log(data);
        if (data) {
            this.Status = data.fields.Status__c.value;
            //this.Status = getFieldValue(data, Status);

            if(this.Status == 'Waiting for approval')
            {
                this.showButtonUpload = true;
                this.showFileUpload = false;
                this.showButtons();
            }
            else 
            {
                this.showFileUpload = true;
                this.showButtonUpload = false;
            }
        }
    }
    @wire(getRecord, {recordId: '$contentversionId', fields: [versionData]})
    contentVersion;

    get versionData()
    {
        return this.contentVersion.data.fields.VersionData.value;
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files

        const uploadedFiles = event.detail.files;
        console.log('SV uploadedFiles: ' + JSON.stringify(uploadedFiles));
        this.fileDetails = uploadedFiles;
        this.documentId = uploadedFiles[0].documentId;
        this.fileName = uploadedFiles[0].name;
        this.contentversionId = uploadedFiles[0].contentVersionId;
        //this.changeFile(uploadedFiles);
        var optionNot;
        this.toggleSpinner();
        getFile({contentVersionId : this.contentversionId, mtdCsvName : this.fileName})
        .then(result => {
            console.log(result);
            if (result) 
            {
                /*var fileReader = new FileReader();
                console.log(fileReader);
                //fileReader.readAsBinaryString(result);
                fileReader.onloadend = (() => {
                    var fileContents = fileReader.result;
                    console.log('filereader ', fileContents);
                });
                //console.log('prima di read');
                //su errore lettura file
                fileReader.onerror = function(event) {
                    console.error("File could not be read! Code " + event.target.error);
                };
                */
                (async() => {
                    console.log("waiting for data");
                    //console.log(this.contentVersion.data);
                    while(!this.contentVersion.data)
                        await new Promise(resolve => setTimeout(resolve, 100));
                    //console.log(this.contentVersion.data);
                    var vv = this.versionData;
                    //console.log(vv);
                    console.log(atob(vv));
                    this.sendFile3(atob(vv), this.fileName);
                })();
            }
        })
        .catch(error => {
            console.log(error);
            optionNot = {
                title: 'Error',
                message: error.toString(),
                type: 'error'
            }
            deleteFile({SV_CSVLoad : this.recordId, contendocumentId : this.documentId});
            this.toggleSpinner(); 
            this.handleNotification(optionNot);
        })
        .finally(() =>{
            getRecordNotifyChange([{recordId: this.recordId}]);
            //this.refreshView();
        })
    }
    sendFile3(file, name) 
    {
        //console.log('prima if');
        //console.log('textfile ' + file.length);
        //this.getCustomSettings(component);
        var lenColonne = 0;//component.get("v.customSettings");

        //lunghezza colonne +2?? modificare con lunghezza effettiva
        
        lenColonne = 8;
        
        console.log('tst '+lenColonne);
        if(file.length > 0){

			var rowToIns = [];
			//var myMap = this.mappaStringhe;
            
			console.log('lunghezza ok');
			//console.log(file.includes('\n'));
			if(file.includes('\n')){

				console.log('righe ok');

				//scompone il file in liste di stringhe (righe)
				var mtdCsvRows = file.split('\r\n');


				console.log('split righe ok');

				
				//creo una stringa solo con i separatori per simulare una riga vuota
				var tmpEmptyString = '';
				for(var i = 0; i<lenColonne; i++){
					tmpEmptyString += ';';
				}
				//console.log(tmpEmptyString);
				
				var monthOK = false;
				var errore = false;
				var erroreSeparatore = false;
                //console.log('errore '+errore);
				var count = 2;

                if(mtdCsvRows.includes(','))
                {
                    erroreSeparatore = true;
                }
				
                //component.set("v.mappaStringhe", myMap);
                //console.log(rowToIns.length);
                //console.log(count);
                //console.log(this.recordId);
                var optionNot;
                uploadFile({mtdCsvFile : file,
                            mtdCsvName : name,
                            mtdFileRows : mtdCsvRows.shift(),
                            erroreRighe : errore,
                            erroreSeparatore : erroreSeparatore,
                            SV_CSVLoad : this.recordId})
                .then(result => {
                    console.log(result);
                    if (result.status=='success') 
                    {
                        //if(component.isValid())
                        //{
                            var returned = result;
                            console.log('returned '+returned);
                            optionNot = {
                                title: returned.title,
                                message: returned.errorMsg,
                                type: returned.status
                            }
                            
                            if(returned.status=='success' || returned.title.includes('Errore nell\'elaborazione') || returned.title.includes('Errore')){
                                
                                this.showButtonUpload = true;
                                this.showFileUpload = false;
                            }
                            //this.resetForm(component);
                    	//}
                    }
                    else
                    {
                        console.log(result);
                        optionNot = {
                            title: result.title,
                            message: result.errorMsg,
                            type: result.status
                        }
                        //this.resetForm(component);
                    }
                    //console.log('prima di reset');
                })
                .catch(error => {
                    console.log(error);
                    optionNot = {
                        title: 'Errore',
                        message: "File troppo grande",
                        type: 'error'
                    }
                    //this.resetForm(component);
                    deleteFile({SV_CSVLoad : this.recordId, contendocumentId : this.documentId});
                })
                .finally(() =>{
                    this.handleNotification(optionNot);
                    this.toggleSpinner(); 
                    getRecordNotifyChange([{recordId: this.recordId}]);
                    //this.refreshView();
                })
            }
		}
        //console.log('dopo if');
    }
    connectedCallback(){
        //check per controllare status CSVLoad
        //console.log(this.Status);
    }

    changeFile(uploadedFiles)
    {
        console.log(this.refs.csvFile.value);
        console.log(this.refs.csvFile.files);
        var input = this.refs.csvFile;
       
        //funzione di controllo file
        this.checkFiles(input.files);
    }

    onDragOver(component, event) 
    {
        //The event.preventDefault() method stops the default action of an element from happening.
        event.preventDefault();
    }

    uploadFile(component, event) {
        //funzione di caricamento file su server
        this.upload(component, event);
    }

    submitFile(component, event) {
        //funzione di caricamento file su server
        var self = this;
        self.toggleSpinner();
        //self.hideButtons(component);
       
        this.submit(component);
    }

    reset(event) {
        //funzione reset input file
        this.resetForm(event);
    }

    onDrop(component, event) {
        //The event.stopPropagation() method stops the bubbling of an event to parent elements, 
        //preventing any parent event handlers from being executed.
        event.stopPropagation();
        
        event.preventDefault();
        
        //Gets the type of drag-and-drop operation currently selected or sets the operation to a new type. 
        //The value must be none copy link or move.
        event.dataTransfer.dropEffect = 'copy';
        
        //Contains a list of all the local files available on the data transfer. 
        //If the drag operation doesn't involve dragging files, this property is an empty list.
        var files = event.dataTransfer.files;
 
        //funzione di controllo file
        this.checkFiles(component, files);
    }

    //controlla che il file sia del formato giusto e pieno
    checkFiles(files) {
        console.log(files);
        // controlla che il file sia in csv
        if (files.length > 1) {
            var optionNot = {
				title: "Attenzione",
                message: "Puoi solo caricare file di tipo CSV",
				type: "warning"
			}
			this.handleNotification(optionNot);
			
			//this.resetFile(template, event);
            this.hideButtons();
            return false;
        }

        //messaggio errore
        if (files.length == 1 && files[0].type!="text/csv" && !files[0].name.includes('.csv')) {
            var optionNot = {
				title: "Attenzione",
                message: "Puoi solo caricare file di tipo CSV",
				type: "warning"
			}
			this.handleNotification(optionNot);
			
			//this.resetFile(template, event);
            this.hideButtons();
            return false;
        }

		//recupero il file
        this.objsLibraryFile = files[0];
		
		//recupero il nome del file        
		//var name = this.template.querySelector('file-upload-input-01'); 
		//this.fileName = name.files.item(0).name;
		this.fileName = files[0].name;
		console.log(files[0].name);


        this.showButtons();
		this.showOkFile = true;
        
		return true;
    }

    //legge il file e lo invia al server
    upload(component, event) {
        var self = this;
        self.toggleSpinner();
        //self.hideButtons(component);

       //file caricato
       var f = this.objsLibraryFile;
       
	   //oggetto lettura file
       var reader = new FileReader();

		//su lettura file ok

        var fileReader = new FileReader();
        console.log(fileReader);
        fileReader.onloadend = (() => {
            var fileContents = fileReader.result;
            this.sendFile2(component, fileContents, this.fileName, self);
        });
		//console.log('prima di read');
		//su errore lettura file
		fileReader.onerror = function(event) {
			console.error("File could not be read! Code " + event.target.error);
		};

		//attivazione lettura file
		//reader.readAsText(f);
        fileReader.readAsText(f);
        //console.log('dopo di read');
    }

    // richiamo la classe passando nome file,tipo file e dati
    sendFile(component, file, name, self) {

        //console.log('prima if');
        //console.log('textfile ' + file.length);
        //this.getCustomSettings(component);
        var lenColonne = 0;//component.get("v.customSettings");

        //lunghezza colonne +2?? modificare con lunghezza effettiva
        
        lenColonne = 8;

        console.log('tst '+lenColonne);
        if(file.length > 0){

			var rowToIns = [];
			//var myMap = this.mappaStringhe;
            
			console.log('lunghezza ok');
			//console.log(file.includes('\n'));
			if(file.includes('\n')){

				console.log('righe ok');

				//scompone il file in liste di stringhe (righe)
				var mtdCsvRows = file.split('\r\n');


				console.log('split righe ok');

				
				//creo una stringa solo con i separatori per simulare una riga vuota
				var tmpEmptyString = '';
				for(var i = 0; i<lenColonne; i++){
					tmpEmptyString += ';';
				}
				//console.log(tmpEmptyString);
				
				var monthOK = false;
				var errore = false;
				var erroreSeparatore = false;
                //console.log('errore '+errore);
				var count = 2;
				//per ogni riga, crea una lista di stringhe (campi)
				for(var i=1; i<mtdCsvRows.length; i++){
					
					//console.log('loop in righe');

					var tmpRow = mtdCsvRows[i];
                     
                    //console.log(tmpRow == tmpEmptyString);
					//se la riga non contiene il separatore di campo
					if(tmpRow == tmpEmptyString)
                    {
						count ++;
					}
                    else if(tmpRow != tmpEmptyString && tmpRow != ''){ //salta eventuali righe vuote

						//console.log('separatore di campo ok');
                        if(!tmpRow.includes(';'))
                        {
                            erroreSeparatore = true;
                        }
						else
                        {
                            var tmpRowFields = tmpRow.split(';');
                            //console.log('lunghezza riga '+tmpRowFields.length);
                            //gestione errore righe blocco caricamento
                            console.log('len Colonne ',tmpRowFields.length,' numero riga ', count);
                            if(tmpRowFields.length < lenColonne)
                            {
                                errore = true;
                            }
                            //tmpRow += ';'+count;
                            
                            //CREA LISTA DI RIGHE DA ELABORARE
                            rowToIns.push(tmpRow);
                            //console.log(rowToIns);
                            count ++;
                            //console.log('lista2');
                        }
                    }
                }
                //component.set("v.mappaStringhe", myMap);
                //console.log(rowToIns.length);
                //console.log(count);
                //console.log(this.recordId);
                var optionNot;
                uploadFile({mtdCsvFile : file,
                            mtdCsvName : name,
                            mtdFileRows : rowToIns,
                            erroreRighe : errore,
                            erroreSeparatore : erroreSeparatore,
                            SV_CSVLoad : this.recordId})
                .then(result => {
                    console.log(result);
                    if (result.status=='success') 
                    {
                        //if(component.isValid())
                        //{
                            var returned = result;
                            console.log('returned '+returned);
                            optionNot = {
                                title: returned.title,
                                message: returned.errorMsg,
                                type: returned.status
                            }
                            
                            if(returned.status=='success' || returned.title.includes('Errore nell\'elaborazione') || returned.title.includes('Errore')){
                                
                                this.showButtonUpload = true;
                                this.showFileUpload = false;
                            }
                            this.resetForm(component);
                    	//}
                    }
                    else
                    {
                        console.log(result);
                        optionNot = {
                            title: result.title,
                            message: result.errorMsg,
                            type: result.status
                        }
                        this.resetForm(component);
                    }
                    //console.log('prima di reset');
                })
                .catch(error => {
                    console.log(error);
                    optionNot = {
                        title: 'Errore',
                        message: "File troppo grande",
                        type: 'error'
                    }
                    this.resetForm(component);
                })
                .finally(() =>{
                    this.handleNotification(optionNot);
                    this.toggleSpinner(); 
                    getRecordNotifyChange([{recordId: this.recordId}]);
                    //this.refreshView();
                })
            }
		}
        //console.log('dopo if');
    }
    // richiamo la classe passando nome file,tipo file e dati
    sendFile2(component, file, name, self) {

        //console.log('prima if');
        //console.log('textfile ' + file.length);
        //this.getCustomSettings(component);
        var lenColonne = 0;//component.get("v.customSettings");

        //lunghezza colonne +2?? modificare con lunghezza effettiva
        
        lenColonne = 8;

        console.log('tst '+lenColonne);
        if(file.length > 0){

			var rowToIns = [];
			//var myMap = this.mappaStringhe;
            
			console.log('lunghezza ok');
			//console.log(file.includes('\n'));
			if(file.includes('\n')){

				console.log('righe ok');

				//scompone il file in liste di stringhe (righe)
				var mtdCsvRows = file.split('\r\n');


				console.log('split righe ok');

				
				//creo una stringa solo con i separatori per simulare una riga vuota
				var tmpEmptyString = '';
				for(var i = 0; i<lenColonne; i++){
					tmpEmptyString += ';';
				}
				//console.log(tmpEmptyString);
				
				var monthOK = false;
				var errore = false;
				var erroreSeparatore = false;
                //console.log('errore '+errore);
				var count = 2;

                if(mtdCsvRows.includes(','))
                {
                    erroreSeparatore = true;
                }
				
                //component.set("v.mappaStringhe", myMap);
                //console.log(rowToIns.length);
                //console.log(count);
                //console.log(this.recordId);
                var optionNot;
                uploadFile({mtdCsvFile : file,
                            mtdCsvName : name,
                            mtdFileRows : mtdCsvRows,
                            erroreRighe : errore,
                            erroreSeparatore : erroreSeparatore,
                            SV_CSVLoad : this.recordId})
                .then(result => {
                    console.log(result);
                    if (result.status=='success') 
                    {
                        //if(component.isValid())
                        //{
                            var returned = result;
                            console.log('returned '+returned);
                            optionNot = {
                                title: returned.title,
                                message: returned.errorMsg,
                                type: returned.status
                            }
                            
                            if(returned.status=='success' || returned.title.includes('Errore nell\'elaborazione') || returned.title.includes('Errore')){
                                
                                this.showButtonUpload = true;
                                this.showFileUpload = false;
                            }
                            this.resetForm(component);
                    	//}
                    }
                    else
                    {
                        console.log(result);
                        optionNot = {
                            title: result.title,
                            message: result.errorMsg,
                            type: result.status
                        }
                        this.resetForm(component);
                    }
                    //console.log('prima di reset');
                })
                .catch(error => {
                    console.log(error);
                    optionNot = {
                        title: 'Errore',
                        message: "File troppo grande",
                        type: 'error'
                    }
                    this.resetForm(component);
                })
                .finally(() =>{
                    this.handleNotification(optionNot);
                    this.toggleSpinner(); 
                    getRecordNotifyChange([{recordId: this.recordId}]);
                    //this.refreshView();
                })
            }
		}
        //console.log('dopo if');
    }

    submit(component)
    {
        var optionNot;
        submitFile({SV_CSVLoad : this.recordId})
        .then(result => {
            console.log(result);
            if (result.status=='success') 
            {
                //if(component.isValid())
                //{
                    var returned = result;
                    console.log('returned '+returned);
                    optionNot = {
                        title: returned.title,
                        message: returned.errorMsg,
                        type: returned.status
                    }
                    
                    if(returned.status=='success' || returned.title.includes('Errore nell\'elaborazione') || returned.title.includes('Errore')){
                        //this.showFileUpload = true;
                        //this.showButtonUpload = false;
                    }
                    //this.resetForm(component);
                //}
            }
            else
            {
                console.log(result);
                optionNot = {
                    title: result.title,
                    message: result.errorMsg,
                    type: result.status
                }
                //this.resetForm(component);
            }
            //console.log('prima di reset');
        })
        .finally(() =>{
            this.handleNotification(optionNot);
            this.toggleSpinner(); 
            getRecordNotifyChange([{recordId: this.recordId}]);
            //this.refreshView();
        })
    }

    reuploadFile()
    {
        var self = this;
        self.toggleSpinner();

        var optionNot;
        reuploadFile({SV_CSVLoad : this.recordId})
        .then(result => {
            console.log(result);
            if (result.status=='success') 
            {
                var returned = result;
                console.log('returned '+returned);
                optionNot = {
                    title: returned.title,
                    message: returned.errorMsg,
                    type: returned.status
                }
                
                if(returned.status=='success' || returned.title.includes('Errore nell\'elaborazione') || returned.title.includes('Errore')){
                    this.showFileUpload = true;
                    this.showButtonUpload = false;
                }
            }
            else
            {
                console.log(result);
                optionNot = {
                    title: result.title,
                    message: result.errorMsg,
                    type: result.status
                }
                this.handleNotification(optionNot);
            }
            //console.log('prima di reset');
        })
        .finally(() =>{
            this.toggleSpinner();
            getRecordNotifyChange([{recordId: this.recordId}]);
            //this.refreshView();
        })
    }

    // lancia il messaggio d
    handleNotification(option) {
        // Configure error toast
        this.dispatchEvent(new ShowToastEvent({
            title: option.title,
            message: option.message,
            variant: option.type,
            mode: 'sticky'
        }));
    }

    // cancella il file che è stato selezionato
    resetForm(event) {
        this.objsLibraryFile = null;
		//this.noMatchMsg = "";
		this.resetFile(event);
        this.hideButtons();
    }

    // nasconde o rende visibile importFileSpinner
    toggleSpinner() {
        this.loading = !this.loading;
    }

	// rende visibile il bottone
    showButtons() {
        this.disable = false;
    }

    // nasconde il bottone
    hideButtons() {
        this.disable = true;
    }

    // resetta il valore del file
    resetFile(event) {
        this.refs.csvFile.value = '';
		this.showOkFile = false;
        console.log(this.refs.csvFile.file);
        //this.handleUploadFinished(event);
    }
    //refresh page
    refreshView()
    {
        window.location.reload();
    }
}