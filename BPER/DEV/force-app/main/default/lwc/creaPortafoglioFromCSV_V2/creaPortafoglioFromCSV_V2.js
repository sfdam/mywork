import { LightningElement, api, wire, track } from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

//import deleteFiles from '@salesforce/apex/FV_RentCSVController.deleteFiles';
//import saveObjects from '@salesforce/apex/FV_RentCSVController.saveObjects';
import uploadFile from '@salesforce/apex/creaPortafoglioFromCSVController_V2.upldFile';

export default class CreaPortafoglioFromCSV_V2 extends NavigationMixin(LightningElement) {

    @api optionTemplate;
    @api recordId;
    @track valueTemplate;
    @track showFileUpload = false;
    @track showTabUpload = false;
    @track fileDetails;
    @track documentId;
    @track loaded = false;
    @api loading = false;
    @api filename = 'Nome';
    @track disable = true;
    @track showOkFile = false;
    @api objsLibraryFile;
    @api mappaStringhe = {};

    @track columns = [
        {
            label: 'Modello di servizio',
            fieldName: 'modelloServizio',
            type: 'text',
            sortable: false,
            editable: true
        },
        {
            label: 'Abi',
            fieldName: 'abi',
            type: 'text',
            sortable: false,
            editable: true
        },
        {
            label: 'CED Filiale',
            fieldName: 'cedfiliale',
            type: 'text',
            sortable: false,
            editable: true
        },
        {
            label: 'Matricola da assegnare',
            fieldName: 'matricola',
            type: 'text',
            sortable: false,
            editable: true
        },
        {
            label: 'Tipologia Portafoglio',
            fieldName: 'tipoPortafoglio',
            type: 'text',
            sortable: false,
            editable: true
        }
    ];

    get acceptedFormats() {
        return ['.csv'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files

        const uploadedFiles = event.detail.files;
        /*if (this.documentId) {
            deleteFiles({ sdocumentId: this.documentId })
            .then(result => {

                console.log('result', result);

    
            })
            .catch(error => {
                console.log('ERROR', error);
                this.error = error;
                const event = new ShowToastEvent({
                    "variant": "error",
                    "title": "Error!",
                    "message": error.body.message
                });
                this.dispatchEvent(event);

            })

        }*/
        console.log('SV uploadedFiles: ' + JSON.stringify(uploadedFiles));
        this.fileDetails = uploadedFiles;
        this.documentId = uploadedFiles[0].documentId;
        this.changeFile(uploadedFiles);

        // alert('No. of files uploaded : ' + uploadedFiles.length);

        // const evt = new ShowToastEvent({
        //     title: 'SUCCESS',
        //     message: uploadedFiles + ' File(s) uploaded  successfully',
        //     variant: 'success',
        // });
        // this.dispatchEvent(evt);
    }

    connectedCallback(){
        /*if(this.optionTemplate) this.optionTemplate = JSON.parse(this.optionTemplate);
        else this.optionTemplate = JSON.parse('[{"label":"Inserire opzioni template nelle impostazioni del componente","value":"null"}]'); */
        
        this.showFileUpload = true;
    }

    handleChangeTemplate(event) {
        // SET Template
        console.log('SV event.target.value: ' + event.target.value);

        this.valueTemplate = event.target.value;


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
        /*var data;
		reader.onload = function(event) {
            console.log(event.target);
			data = event.target.result;

			//console.log('prima di send');
			//invio file al server
            //console.log('dopo di send');
            //var te = new FV_RentCSV();
            new FV_RentCSV().sendFile(component, data, new FV_RentCSV().fileName, self);
		};*/

        var fileReader = new FileReader();
        console.log(fileReader);
        fileReader.onloadend = (() => {
            var fileContents = fileReader.result;
            this.sendFile(component, fileContents, this.fileName, self);
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
        
        lenColonne = 5;

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
				for(var i = 0; i<lenColonne - 1; i++){
					tmpEmptyString += ',';
				}
				//console.log(tmpEmptyString);
				
				var monthOK = false;
				var errore = false;
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
						/*console.log('errore separatore di campo');
						
						var optionNot = {
							title: "Errore",
							message: "Il file non contiene il separatore di campo specificato: ';'",
							type: 'error'
						}
						//this.handleNotification(optionNot);

						//break;*/
					}else if(tmpRow != tmpEmptyString && tmpRow != '' && tmpRow.includes(',')){ //salta eventuali righe vuote

						//console.log('separatore di campo ok');
						
						var tmpRowFields = tmpRow.split(',');
                        //console.log('lunghezza riga '+tmpRowFields.length);
                        //gestione errore righe blocco caricamento
                        console.log('len Colonne ',tmpRowFields.length,' numero riga ', count);
                        if(tmpRowFields.length < lenColonne)
                        {
                            errore = true;
                        }
						tmpRow += ','+count;
                        
						//CREA LISTA DI RIGHE DA ELABORARE
						rowToIns.push(tmpRow);
                        //console.log(rowToIns);
						count ++;
						//console.log('lista2');
                    }
                }
                var rowToIns4000 = [];
                var x = 1;
                /*for(var i=0; i<rowToIns.length; i++)
                {
                    if(i===1999)
                    {
                        myMap[x] = rowToIns.splice(0,2000);
                        //this.uplFile(component,file,name,rowToIns4000,errore,false);
                        i=0;
                        x+=1;
                    }
                    else if (rowToIns.length <= 2000 && rowToIns.length > 0) 
                    { 
                        //this.uplFile(component,file,name,rowToIns,errore,true);
                        //console.log(rowToIns.length);
                        myMap[x] = rowToIns.splice(0,2000);
                        x+=1;
                    }
                }*/
                //component.set("v.mappaStringhe", myMap);
                console.log(rowToIns.length);
                console.log(count);
                console.log(this.recordId);
                var optionNot;
                uploadFile({mtdCsvFile : file,
                            mtdCsvName : name,
                            mtdFileRows : rowToIns,
                            erroreRighe : errore,
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
                                this.resetForm(component);
                            }
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
                })
            }
		}
        //console.log('dopo if');
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
        var toastParams = {
            title: option.title,
            message: option.message, // Default error message
            type: option.type,
			mode: 'sticky'
        };
        // Fire toast
        //var toastEvent = $A.get("e.force:showToast");
        //toastEvent.setParams(toastParams);
        //toastEvent.fire();
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
        //if(this.loading){
			this.loading = !this.loading;
		/*}else{
			component.set("v.loading", true);
		}*/
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
    // final ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId='0693N000002xjhfQAA' AND IsLatest = true];
    // final String csvContents = cv.VersionData.toString();
    // final String[] csvLines = csvContents.split('\n');
    // System.debug(csvLines);




}