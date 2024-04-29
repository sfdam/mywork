import {LightningElement, track, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import documentiBase from '@salesforce/label/c.WGC_Documenti_Component_Documenti_Base';
import documentiPrimaVisita from '@salesforce/label/c.WGC_Documenti_DOCUMENTI_PRIMA_VISITA';
import documentiScadenza from '@salesforce/label/c.WGC_Documenti_2_Scade_il';
import documentiCompila from '@salesforce/label/c.WGC_Documenti_2_Compila';
import documentiScarica from '@salesforce/label/c.WGC_Documenti_2_Scarica';
import documentiCarica from '@salesforce/label/c.WGC_Documenti_2_Carica'; 
import {loadStyle} from 'lightning/platformResourceLoader';
import cssDocumentsLWC from '@salesforce/resourceUrl/cssDocumentsLWC'; 
import getDocumentData from '@salesforce/apex/WGC_Documenti_Controller.getDocumentData';
import docCheckList from '@salesforce/apex/WGC_Documenti_Controller.docCheckList';
import getDocumentMapping from '@salesforce/apex/WGC_Documenti_Controller.getDocumentMapping';
import docCheckListCarrello from '@salesforce/apex/WGC_Documenti_Controller.docCheckListCarrello';
import doc11 from '@salesforce/apex/WGC_Documenti_Controller.doc11';
import doc61 from '@salesforce/apex/WGC_Documenti_Controller.doc61';
import getSoggettiOpp from '@salesforce/apex/WGC_Documenti_Controller.getSoggettiOpp';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getDocsAssuntore from '@salesforce/apex/WGC_Documenti_Controller.getDocsAssuntore';

const FIELDS = [
    'Opportunity.RecordType.DeveloperName'    
];

export default class Wgc_documents extends LightningElement {
    lingue = [{'label': 'Italiano', 'value': 'IT'},{'label': 'Altro', 'value': 'Altro'}];
    sceltaLingua = 'IT';    

    opportunityId;
    docs = [];
    @track docsOpty = [];
    docsComplete = false;
    isAllDocValid = false;
    mappings = [];
    @track attori = [];
	docInfo;
	@track isDocsOptyValid = false;
	@track expandedSingleDoc = false;
	
	//Assuntore
	@track docsAssuntore = [];
	@track expandedAssuntoreDoc = false;
	@track isDocsAssuntoreValid = false;
	@api checkAssuntore = false;
	@api idAssuntore;

    rendered = false;
    showDocumentComponent = false;

    @track
    // {'name':'Privacy Persona Giuridica','showFront':true,'id':'Privacy','index':0, 'docs':{}, 'valid':false, 'filename':'PrivacyPersonaGiuridica.pdf', 'list':'docPPG', 'toUpload':'EX0000200'},
    boxes = [{'name':'Modulo Adeguata Verifica','showFront':true,'id':'AdeguataVerifica','index':0, 'docs':{},'valid':false, 'filename':'ModuloAdeguataVerifica.pdf', 'list':'docMAV', 'toUpload':'EX0000173',
             'documentLoaded':'slds-p-vertical_small slds-align_absolute-center back-icon-negative', 'validTo': false, 'validity':'Non Valido',
            'downloadName':'Mav.pdf','downloadCSS':'slds-align_absolute-center back-icon-action-negative-small',
            'uploadCSS':'slds-align_absolute-center back-icon-action-negative-small','generaModuloCSS':'slds-align_absolute-center back-icon-action-negative-small',
            'compilaModuloCSS':'slds-align_absolute-center back-icon-action-negative-small'}];   

    @api accountId;	
	@track test = false;    
	@track response = {};
	docMAV = {};

    label = {documentiBase,documentiPrimaVisita,documentiScadenza,documentiCompila,documentiScarica,documentiCarica};

	// MODAL FILE UPLOAD PARAMETERS
    recId;
    doc;
    docFisso;
    indiceAttore;
    optyId;
	soggetti;	
	notAvailable = false;;
	datiDocNote;
	noteDoc;
	idNota;
	listaDoc;
	listToUpdate;	

	// MODALE UPLOAD
	showUploadModal = false;
    // MODALE SCELTA LINGUA
    showLanguageModal = false;  
    // MODALE MODULO MAV
	showMavModal = false;    
	// MODALE PRIVACY
	showPrivacyModal = false;

	// MODAL PRIVACY PARAMETERS
	privacyRecordId;
	privacyIsAccount;

    constructor() {
        super();       
		this.addEventListener('modal', this.handleModal.bind(this));  
		this.addEventListener('closeprivacymodal', this.handlePrivacyModal.bind(this)); 
        this.addEventListener('languagemodal', this.handleLanguageModal.bind(this)); 
        this.addEventListener('changelanguage', this.handleLingua.bind(this)); 
        this.addEventListener('modalmav', this.handleMavModal.bind(this)); 
        this.addEventListener('uploadfile', this.uploadHandler.bind(this));
		this.addEventListener('note',this.handleChangeDoc.bind(this));
		this.addEventListener('privacy',this.handlePrivacyResult.bind(this));
		this.addEventListener('changemavinfo',this.handleChangeMavInfo.bind(this));
 
        //for testing
        // if (this.accountId==undefined){
        //     this.accountId='0012500001FGrUfAAL';            
        // }

        // if (this.opportunityId==undefined){
        //     this.opportunityId = '0062500000Gj4qGAAR';            
        // }
    }

    get borderColorFirstBoxCSS(){       
        return 'slds-p-around_small ' + (this.boxes[0].docs.id && this.response.data!=undefined && this.response.data[0].mavList.length > 0 && this.response.data[0].mavList[0].isCompiled ? ' container-border-title-blue ' : ' container-border-title-red ' );
    }

    get borderColorSecondBoxCSS(){       
        return 'slds-align_absolute-center ' + (this.boxes[0].docs.id && this.response.data!=undefined && this.response.data[0].mavList.length > 0 && this.response.data[0].mavList[0].isCompiled ? ' container-border-content-blue ' : ' container-border-content-red ' );
    }    
   
    get disableDownloadButton(){
        return this.profilo !=undefined && this.profilo == 'IFIS - Crediti Erariali';
	}
	
	get sizeDocsOpty(){
		return this.docsOpty.length == 0;
	}

	@api
	get checkDocs(){
		return this.isAllDocValid;
	}
    
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) { 
        this.currentPageReference = currentPageReference;
        if (this.opportunityId==null){
            this.opportunityId = currentPageReference.state.c__opportunityId;
        }        
    }

    @wire(getRecord, { recordId: '$opportunityId', fields: FIELDS })
    opportunity;

    get tipologiaMav() {
        console.log("getTipologiaMavOpportunity");        
        return this.opportunity.data.fields.RecordType.value.fields.DeveloperName.value == 'IFISOpportunitaFastFinance' ? 'CE':'CC';        
	}
	
	get altraSezioneCSS (){
		return this.isDocsOptyValid ? ' container-doc-opty-positive ' : ' container-doc-opty-negative ';
	}

	get altraSezioneCSS2 (){
		return ' slds-p-vertical_small slds-align_absolute-center border-opty-right '+ (this.isDocsOptyValid ? ' back-icon-action-positive ' : ' back-icon-action-negative ');
	}

	get altraSezioneCSS3 (){
		return 'slds-button slds-button_icon slds-button_icon-border '+ (this.isDocsOptyValid ? '  btn-expand-positive ' : '  btn-expand-negative ');
	}

	get altraSezioneCSS4 (){
		return this.isDocsOptyValid ? '  all-border-blue ' : '  all-border-red ';
	}

    setLanguage(event){
        this.sceltaLingua = event.target.value;
    }

    refresh(){        
        this.initialize();
    }   

    connectedCallback(){
        //Used for override standard CSS
        loadStyle(this, cssDocumentsLWC);        
        this.initialize();
    }

    initialize(){
		this.enableSpinner();
        console.log('AccountId: '+this.accountId);
        getDocumentData({accountId: this.accountId})
            .then(result => {
                var arrDoc = result.data[0];
                for(var key in arrDoc){
                    arrDoc[key].forEach(function(item){
                            //Data Compilazione MAV
                            if(item.hasOwnProperty('WGC_Data_Compilazione__c')){                       
                                var oneDay = 24*60*60*1000; 
                                var today = new Date();
                                var dataC = new Date(item.WGC_Data_Compilazione__c);

                                let diffDays = Math.round(Math.abs((today.getTime() - dataC.getTime())/(oneDay)));

                                if(diffDays > 365){
                                    item.isCompiled = false;
                                }
                                else{
                                    item.isCompiled = true;
                                }

                                var da = new Date(item.WGC_Data_Compilazione__c);
                                da.setFullYear(da.getFullYear()+1);
                                item.CreatedDate = da.toLocaleDateString('it-IT', {year: 'numeric', month: 'short', day: 'numeric'});
                            }else{
                                item.isCompiled = false;
                            }
                        });            
                }      
            
                result.data[0] = arrDoc;
                this.response = result;

                // LOGICA MAV
                if (this.response.data[0].mavList.length > 0 && this.response.data[0].mavList[0].isCompiled){
                    this.boxes[0].generaModuloCSS = ' slds-align_absolute-center back-icon-action-positive-small ';
                    this.boxes[0].compilaModuloCSS = ' slds-align_absolute-center back-icon-action-positive-small ';
                }

                if (this.opportunityId !=undefined){
                    return docCheckList({objId : this.accountId})
                }
            })                
            .then(result => {   
                if (result.success){
                    let rispJSON = result.data[0];
                    let note;
                    if(result.data.length > 1){
                        note = result.data[1];
                    } 
                    let docsGenerati = this.generateDocsList(rispJSON, note);   
                    this.docs = docsGenerati;
                }
                
                return getDocumentMapping();
            })
            .then(result => {  
                console.log('getDocumentMapping', result);
                if(result.data.length > 0){
                    this.mappings = result.data[0];
                    return docCheckListCarrello({"opportunityId" : this.opportunityId});                   
                }
            })
            .then(result => {  
                if(result.data.length > 0){
                    var docs = [];
                    docs = this.generateDocsListOpty(result.data[0], result.data[1]);                    
                    var mapping = this.mappings;
                    docs = this.mapCodeName(docs, mapping);
                    this.docsOpty =  docs;   
                    result.data[2].forEach((item, index) =>{
                        item.isFlip = false;
                        item.myIndex = index;
                    });
                    var redFact = docs.reduce((start, item) =>{
                        if(item != null){
                            return start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true)
                        }
                        else{
                            return start;
                        }
                    }, true);

                    console.log('@@@ redFact ' , redFact);
                    this.isDocsOptyValid = redFact;

                    result.data[2].forEach((item, index) =>{
                        docs = [];
                        item.isCompleted = false;
                        docs = this.generateDocsListOpty(item.docs, item.note);
                        docs = this.mapCodeName(docs, mapping);
                        item.docs = docs;		
                        
                        if(item.attore.Tipo__c != undefined && item.attore.Tipo__c != null){
                            var red = docs.reduce((start, item) =>{
                                if(item != null){
									return start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true)                                        
								} else
                                    return start;
                            }, true);
                        } else {
                            var dataConsensi = item.attore.Contact.DataInserimentoConsensi__c;
                            var red = docs.reduce((start, item) =>{
                             if(item != null && item.index_value == 'SY0000074'){
                                 return start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true) && dataConsensi != undefined;
                             } else if(item != null){
								 return start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true)                                        
							} else
                                 return start;
                         }, true);                 
                        }
    
                        item.isCompleted = red;

                    });

                    this.attori = result.data[2];
                }  

                //Mappo
                var docs2 = this.docs;
                var mapping = this.mappings;

                docs2 = this.mapCodeName(docs2, mapping);
                
                this.docs = docs2;
                
                //FIX Indici
                docs2.forEach((item, index) =>{
                    item.myIndex = index;
                });                

				return getDocsAssuntore({ opportunityId: this.opportunityId });
            }).then(res => {

				console.log('@@@ result docs assuntore ' , res);

				if(res.data.length > 0){
					var docs = [];
					docs = this.generateDocsList(res.data[0], res.data[1]);
					console.log('@@@ docs assuntore ' , docs);                  
                    var mapping = this.mappings;
                    docs = this.mapCodeName(docs, mapping);
                    // this.docsAssuntore =  docs;
                    var redFact = docs.reduce((start, item) =>{
                        if(item != null){
                            return start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true)
                        }
                        else{
                            return start;
                        }
                    }, true);

                    console.log('@@@ red Assuntore ' , redFact);
					this.isDocsAssuntoreValid = redFact;
					
					docs.forEach((item, index) =>{
						item.isFlip = true;
						item.myIndex = index;
					});

					this.docsAssuntore = docs;
				}  

				console.log("checkAllDocs initialize");
                this.checkAllDocs();
			})
            .finally(() => {
                this.disableSpinner();
                this.showComponent();
            })
            .catch(err => {
                console.log('@@@ err ' , err);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message: err.message,
                        variant: 'error'
                    })
                );
            });  
    }        
    
    generateDocsList(json, notes){
        var docsList = [];		
        console.log('generateDocsList');
        json.payload.results.forEach((item, index) =>{
			var singleDoc = {};

			//Flag NON REPERIBILE
			singleDoc.isAvailable = false;
			//Campi required e missing (Utilizzati per blue e rosso)
			singleDoc.missing = item.missing;
			singleDoc.required = item.required;
			singleDoc.isValid = (item.missing && item.required) == true ? false : true;

			if(notes != null && notes != undefined && notes.length > 0){
				notes.forEach((itemN, index) =>{
					var idDocumentale = itemN.Id_univoco__c.split('_')[1];
					console.log('@@@ idDocumentale ' , idDocumentale);
					console.log('@@@  ' , item.index_value);
					if(idDocumentale == item.index_value){
						singleDoc.isValid = true;
						singleDoc.isAvailable = true;
						singleDoc.nota = itemN.Note__c;
						singleDoc.notaId = itemN.Id;
					}
				});
			}

			var tmpFROM = new Date(item.valid_from);
			tmpFROM = tmpFROM.toLocaleDateString('it-IT', {year: 'numeric', month: 'short', day: 'numeric'});
			singleDoc.valid_from = tmpFROM;

			singleDoc.index_name = item.index_name;
			singleDoc.index_value = item.index_value;
			//Aggiungo un parametro per gestire il flip
			singleDoc.isFlip = true;
			singleDoc.myIndex = index;

			if(item.docs[0] != undefined && item.docs[0] != null || item.docs.length > 0){
				singleDoc.id = item.docs[0].id;
				singleDoc.classe = item.docs[0].classe;

				item.docs[0].indice.forEach((ind, index) =>{
					//console.log('@@@ ind ' , ind);
					//console.log('@@@@ prova name ' , ind.nome.toLowerCase() == ('Name').toLowerCase());
					if(ind.nome.toLowerCase() == ('Name').toLowerCase()){
						console.log('@@@ nome trovato');
						console.log('@@@ nome ' , ind.valore);
						singleDoc.DownloadName = ind.valore;
					}
					if(ind.nome.toLowerCase() == ('CODICEDOC').toLowerCase()){
						singleDoc.codiceDoc = ind.valore;
					}

					if(ind.nome.toLowerCase() == ('DATASTATO').toLowerCase()){
						if(ind.valore){
							var tmp = ind.valore;
							console.log('@@@ ind.valore ' , ind.valore);
							tmp = tmp.match(/.{1,2}/g);
							//Anno - Mese - Giorno
							var formatted = tmp[2] + tmp[3] + '-' + tmp[1] + '-' + tmp[0];
							var tmpTO = new Date(formatted);
							singleDoc.valid_to = tmpTO;

							//var validDate = new Date(singleDoc.valid_to);

							singleDoc.isValidDate = new Date(singleDoc.valid_to) > new Date() ? 'Valido' : 'Non valido';
							singleDoc.valid_to = tmpTO.toLocaleDateString('it-IT', {year: 'numeric', month: 'short', day: 'numeric'});
						}
					}

					if(ind.nome.toLowerCase() == ('MimeType').toLowerCase()){
						singleDoc.mimeType = ind.valore;

						console.log('@@@ mimeType docs ' , singleDoc.mimeType);
					}

					if(ind.nome.toLowerCase() == ('NOTEDOC').toLowerCase()){
						if (item.index_value == 'EX0000173'){
							if (ind.valore != null){
								singleDoc.noteDoc = ind.valore == "CC" ? "In Bonis" : 'Procedura';
							}else {
								singleDoc.noteDoc = "";
							}							
						}						
					} 
				});

				//SM - TEN: Fix TENAM-197
				if(singleDoc.DownloadName == undefined){
					singleDoc.DownloadName = item.docs[0].file_name;
				}
			}
			else{
				singleDoc.isValidDate = 'Non valido';
			}
			

			singleDoc.isValid = (singleDoc.required ? (singleDoc.missing ? (singleDoc.isAvailable == false ? false : true ) : ((singleDoc.isValidDate == 'Valido' || !singleDoc.hasOwnProperty('isValidDate')) ? (singleDoc.isAvailable == false ? true : true ) : (singleDoc.isAvailable == false ? false : true ) )) : true);

			//MAV
			if(singleDoc.index_value == 'EX0000173'){
                console.log("ISMAV");
                singleDoc.composition = false;				
				this.docMAV = singleDoc;
			} else {
				if(item.docs.length > 0 || singleDoc.required){
					docsList.push(singleDoc);
				}					
			}					
        });
        
        this.checkDocId(docsList);

		return docsList;        
    }

    generateDocsListOpty(json, notes){
        var docsList = [];
        var optyId = this.opportunityId;

		console.log('@@@ docs from service ' , json);
		console.log('@@@ notes ' , notes);
		if(json.payload != undefined){
			var indexValues = new Set();
			console.log('@@@ indexValues ' , indexValues);
			json.payload.results.forEach((item, index) =>{
				console.log("item generateDocsListOpty ", item);
				var singleDoc = {};
				
				//Flag NON REPERIBILE
				singleDoc.isAvailable = false;
				//Campi required e missing (Utilizzati per blue e rosso)
				singleDoc.missing = item.missing;
				singleDoc.required = item.required;
				singleDoc.isValid = (item.missing && item.required) == true ? false : true;
				
				if(notes != null && notes != undefined && notes.length > 0){
					notes.forEach((itemN, index) =>{
						var idDocumentale = itemN.Id_univoco__c.split('_')[1];
						if(idDocumentale == item.index_value){
							console.log('@@ esiste nota ');
							singleDoc.isValid = true;
							singleDoc.isAvailable = true;
							singleDoc.nota = itemN.Note__c;
							singleDoc.notaId = itemN.Id;
						}
					});
				}

				var tmpFROM = new Date(item.valid_from);
				tmpFROM = tmpFROM.toLocaleDateString('it-IT', {year: 'numeric', month: 'short', day: 'numeric'});
				singleDoc.valid_from = tmpFROM;

				singleDoc.index_name = item.index_name;
				singleDoc.index_value = item.index_value;
				//Aggiungo un parametro per gestire il flip
				singleDoc.isFlip = true;
				singleDoc.myIndex = index;

				if(item.docs[0] != undefined && item.docs[0] != null || item.docs.length > 0){
					//Set utilizzato per verificare l'univocità dei documenti
					if(!item.required) indexValues.add(item.index_value);
					singleDoc.id = item.docs[0].id;
					singleDoc.classe = item.docs[0].classe;

					item.docs[0].indice.forEach((ind, index) =>{
						if(ind.nome.toLowerCase() == ('Name').toLowerCase()){
							singleDoc.DownloadName = ind.valore;
						}
						if(ind.nome.toLowerCase() == ('CODICEDOC').toLowerCase()){
							singleDoc.codiceDoc = ind.valore;
						}

						if(ind.nome.toLowerCase() == ('DATASTATO').toLowerCase()){
							console.log('@@@ indice datastato ' , JSON.stringify(ind));
							if(ind.valore){
								var tmp = ind.valore;
								tmp = tmp.match(/.{1,2}/g);
								//Anno - Mese - Giorno
								var formatted = tmp[2] + tmp[3] + '-' + tmp[1] + '-' + tmp[0];
								var tmpTO = new Date(formatted);
								singleDoc.valid_to = tmpTO;

								//var validDate = new Date(singleDoc.valid_to);
								console.log('@@@ valid_to ' , new Date(singleDoc.valid_to));
								console.log('@@@ controllo valid_to ' , new Date(singleDoc.valid_to) > new Date());

								singleDoc.isValidDate = new Date(singleDoc.valid_to) > new Date() ? 'Valido' : 'Non valido';
								singleDoc.valid_to = tmpTO.toLocaleDateString('it-IT', {year: 'numeric', month: 'short', day: 'numeric'});
								console.log('@@@ isValidDate datastato ' , singleDoc.isValidDate);
							}
						}

						if(ind.nome.toLowerCase() == ('MimeType').toLowerCase()){
							singleDoc.mimeType = ind.valore;
						}
					});

					//SM - TEN: Fix TENAM-197
					if(singleDoc.DownloadName == undefined){
						singleDoc.DownloadName = item.docs[0].file_name;
					}
				}
				else{
					singleDoc.isValidDate = 'Non valido';
				}
				
				console.log('@@@ isValidDate datastato final ' , singleDoc.isValidDate);
				singleDoc.isValid = (singleDoc.required ? (singleDoc.missing ? (singleDoc.isAvailable == false ? false : true ) : ((singleDoc.isValidDate == 'Valido' || !singleDoc.hasOwnProperty('isValidDate')) ? (singleDoc.isAvailable == false ? true : true ) : (singleDoc.isAvailable == false ? false : true ) )) : true);

				//MAV //MTC //PPG //RSF
				if(singleDoc.index_value != 'EX0000173' && singleDoc.index_value != 'EX0000179' && singleDoc.index_value != 'EX0000200' 
					&& singleDoc.index_value != 'NV0000002' && ((item.docs.length > 0 || singleDoc.required)) ){
					console.log('@@@ singleDoc ' , JSON.stringify(singleDoc));					
					docsList.push(singleDoc);
				}

				if(singleDoc.index_value == 'NV0000002' && (optyId == null || optyId == undefined || optyId == '')){
					docsList.push(singleDoc);
				}								
			});

			console.log('@@@ docsList opty ' , docsList);
			console.log('@@@ indexValues final ' , indexValues);

			//Ciclo nuovamente il nuovo array per sistemare gli indici
			docsList.forEach((item, index) =>{
				item.myIndex = index;
			});

			console.log('@@@ docsList after final ', docsList);
		}

		return docsList;
    }

    mapCodeName(docs, mapping){
		docs.forEach((item, index) =>{
			mapping.forEach((map, index) =>{
				if(map.Documento__c == item.index_value){
					item.Name = map.MasterLabel;
				}
			});
		});
		console.log('@@@ fine');
		return docs;
	}

    checkDocId(docsToCheck){
        var check = false;
        check = docsToCheck.reduce((start, item) =>{
			if(item != null){
				console.log('@@@ condizione ' , start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? true : false )) : true));
				return start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true)			}
			else{
				return start;
			}
		}, true);

		console.log('@@@ check ' , check);
		this.docsComplete =  check;
    }

    checkAllDocs(){
		var IdCarrello = this.opportunityId;
		console.log('@@@ IdCarrello ' , IdCarrello);	
		var mav = this.docMAV; 
		var docs = this.docs;
		var docsOpty = this.docsOpty;
		var attori = this.attori;
		var docsAssuntore = this.docsAssuntore;

		var docsAttori = [];
		if(attori.length > 0){
			attori.forEach((item, index) =>{
				item.docs.forEach((itemD, indexD) =>{
					docsAttori.push(itemD);
				});
			});
		}

		console.log('@@@ mav ' , mav);		
		console.log('@@@ docs ' , docs);
		console.log('@@@ docsOpty ' , docsOpty);
		console.log('@@@ docsAttori ' , docsAttori);

		var allArray = [];
		
		allArray = allArray.concat(mav);
		//allArray = allArray.concat(docs);
		allArray = allArray.concat(docsOpty);
		allArray = allArray.concat(docsAttori);
		allArray = allArray.concat(docsAssuntore);

		var red = false;

		//Controllo la validità di tutti i documenti
		if(docsOpty.length > 0 && docsAttori.length > 0){
			red = allArray.reduce((start, item) =>{
				console.log('@@@ item ' , JSON.stringify(item));
				if(item != null){
					console.log('@@@ condizione ' , start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? true : false )) : true));
					return start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true)
				}
				else{
					return start;
				}
			}, true);

			console.log('@@@ red ' , red);
		}			
		this.isAllDocValid =  red;	
		
		this.handleMAV(mav);
		this.handleDocsOpty();
		this.handleAttori();
		this.handleDocsAssuntore();
		this.disableSpinner();

		this.dispatchEvent(
			new CustomEvent('documentsrendered')
		);
	}

	handleMAV(mav){
		console.log('@@@ mavList ' , this.response.data[0] );
		if (mav.id!=undefined && this.response.data!=undefined && this.response.data[0].mavList[0] != undefined && this.response.data[0].mavList[0].isCompiled){
			this.boxes[0].documentLoaded = ' slds-p-vertical_small slds-align_absolute-center back-icon-positive ';
		}

		if (mav.valid_to != '' && mav.valid_to != null && mav.valid_to != undefined){
			this.boxes[0].validTo = true;
		}

		if (mav!=undefined && mav.isValid !=undefined && mav.isValid){
			this.boxes[0].validity = 'Valido';
		}

		if (mav.DownloadName!=undefined){
			this.boxes[0].downloadName = mav.DownloadName;
		}

		if (mav.id!=undefined){
			this.boxes[0].downloadCSS = ' slds-align_absolute-center back-icon-action-positive-small ';
			this.boxes[0].uploadCSS = ' slds-align_absolute-center back-icon-action-positive-small ';
		}

		this.boxes[0].docs = mav;
		
		console.log("BOXES: ",JSON.stringify(this.boxes));
		console.log('@@@ mav ' , mav);
	}

	handleDocsOpty(docsOpty){
		//gestisco logica docsOpty
		this.docsOpty.forEach((item, index) =>{

			if (item.id != null && item.id != ''&& item.id != undefined){
				item.fileIconCSS = 'slds-p-vertical_small slds-align_absolute-center back-icon-positive';
			}else {
				item.fileIconCSS = 'slds-p-vertical_small slds-align_absolute-center back-icon-negative';
			}	
			
			if (item.isValid){ 
				item.isValidText = 'Valido';
			}else {
				item.isValidText = 'Non Valido';
			}

			if (item.id != null && item.id != '' && item.id != undefined ){
				item.buttonCSS = 'slds-align_absolute-center back-icon-action-positive';
			}else {
				item.buttonCSS = 'slds-align_absolute-center back-icon-action-negative';
			}
		});
	}

	handleDocsAssuntore(){
		//gestisco logica docsOpty
		this.docsAssuntore.forEach((item, index) =>{

			if (item.id != null && item.id != ''&& item.id != undefined){
				item.fileIconCSS = 'slds-p-vertical_small slds-align_absolute-center back-icon-positive';
			}else {
				item.fileIconCSS = 'slds-p-vertical_small slds-align_absolute-center back-icon-negative';
			}	
			
			if (item.isValid){ 
				item.isValidText = 'Valido';
			}else {
				item.isValidText = 'Non Valido';
			}

			if (item.id != null && item.id != '' && item.id != undefined ){
				item.buttonCSS = 'slds-align_absolute-center back-icon-action-positive';
			}else {
				item.buttonCSS = 'slds-align_absolute-center back-icon-action-negative';
			}
		});
	}

	handleAttori(){
		//gestisco logica a frontend 
		this.attori.forEach((item, index) =>{
			if (item.isCompleted){
				this.attori[index].isCompletedCSS = ' slds-wrap slds-m-vertical_medium container-doc-opty-positive';
				this.attori[index].completedCSS = 'slds-button slds-button_icon btn-expand-positive slds-button_icon-border';
				this.attori[index].completedCSS2 = 'all-border-blue';
				this.attori[index].iconCSS = ' slds-p-vertical_small slds-align_absolute-center border-opty-right back-icon-action-positive';
			}else {
				this.attori[index].isCompletedCSS = ' slds-wrap slds-m-vertical_medium container-doc-opty-negative';
				this.attori[index].completedCSS = 'slds-button slds-button_icon btn-expand-negative slds-button_icon-border';
				this.attori[index].completedCSS2 = 'all-border-red';
				this.attori[index].iconCSS =  ' slds-p-vertical_small slds-align_absolute-center border-opty-right back-icon-action-negative';
			}

			if (item.attore.Tipo__c != undefined && item.attore.Tipo__c != null){
				this.attori[index].existTipo = true;							
			}else {
				this.attori[index].existTipo = false;
			}

			if (item.attore.Account__r!=undefined && item.attore.Account__r.Name != undefined  && item.attore.Account__r.Name != null){
				this.attori[index].existAccountName = true;
			}else {
				this.attori[index].existAccountName = false; 
			}

			if(item.attore.WGC_Esecutore_MAV__c){
				this.attori[index].existEsecutoreMav = true;
			} else {
				this.attori[index].existEsecutoreMav = false;
			}

			if (item.docs.length == 0){
				this.attori[index].noDocuments = true;
			}else {
				this.attori[index].noDocuments = false;
			}

			//gestisco documenti
			item.docs.forEach((doc, index) =>{
				doc.indexValue = item.myIndex + ';' + doc.myIndex;
				if (doc.index_value != 'SY0000074'){
					doc.index_valueCondition = true;
				}else {
					doc.index_valueCondition = false;
				}
				if (doc.id != null && doc.id != '' && doc.id != undefined){
					doc.downloadCSS = ' slds-align_absolute-center  back-icon-action-positive';
				}else {
					doc.downloadCSS = ' slds-align_absolute-center  back-icon-action-negative';
				}

				if((doc.id && doc.index_value != 'SY0000074') || (doc.id && doc.index_value == 'SY0000074'&& item.attore.Contact !=undefined && item.attore.Contact.DataInserimentoConsensi__c)){
					doc.fileIconCSS = 'slds-p-vertical_small slds-align_absolute-center back-icon-positive';
				}else {
					doc.fileIconCSS = 'slds-p-vertical_small slds-align_absolute-center back-icon-negative';
				}

				if (item.attore.Contact !=undefined && item.attore.Contact.DataInserimentoConsensi__c!=null){
					doc.privacyCSS = 'slds-align_absolute-center back-icon-action-positive-small';
				}else {
					doc.privacyCSS = 'slds-align_absolute-center back-icon-action-negative-small';
				}

				if (doc.isValid){
					doc.isValidText = 'Valido';
				}else {
					doc.isValidText = 'Non Valido';
				}

			});

			this.attori[index].docs = item.docs;

		});
	}

    doFlip(event){
        let targetId = event.target.dataset.caller;
        let isFront = event.target.dataset.front;
        console.log(targetId);   
        if (isFront == 'true'){
            this.boxes[targetId].showFront = false;            
        } else {
            this.boxes[targetId].showFront = true;            
        }           
    }

    enableSpinner(){
        this.rendered = false;
    }

    disableSpinner(){
        this.rendered = true;
    }

    showComponent(){
        this.showDocumentComponent = true;
    }

    hideComponente(){
        this.showDocumentComponent = false;
    }

    launchUpload(event) {
		var doc = event.target.value;
		var unique = event.target.dataset.id;
		var recId = unique == 'docsAssuntore' ? this.idAssuntore : this.accountId; 

		//Variabile di appoggio utilizzata per riconoscere l'attore di cui si carica il documento
		var indiceAttore = unique == 'attoredocs' ? event.target.dataset.attore : undefined;
		console.log('@@@ indiceAttore ' + `${indiceAttore}`);
		
		var optyId = this.opportunityId;		
 
		//adione CR 293
		if ( doc === 'new' ) { //premuto bottone '+' che non ha famiglia/classe associato -> mostro lista soggetti
            getSoggettiOpp({"oppId" : optyId})
            .then(result => {   
                if (result.success){ 
                    var sogg = result.data;
					console.log("-----> launchUpload - soggetti opportunità: "+sogg.length);
					this.launchUploadHelp(recId, doc, unique, indiceAttore, optyId, sogg);
                }
            });
        } else { //sto caricando un documento scelto con codice classe/famiglia associato, non serve lista soggetti
			this.launchUploadHelp(recId, doc, unique, indiceAttore, optyId, null);
		}
    }
    
    launchUploadHelp(recId, doc, docFisso, indiceAttore, optyId, soggetti){
        console.log("launchUploadHelp");
        console.log('@@@ recId ' , recId);
		console.log('@@@ doc ' , doc);
		console.log('@@@ indiceAttore ' , indiceAttore);
		console.log('-----> launchUploadHelp - soggetti: ' , soggetti);

		if(indiceAttore != undefined && indiceAttore != null) {
			var attori = this.attori;
			attori.forEach((item, index) => {
				if (index == indiceAttore && item.attore.Tipo__c != undefined) {
					recId = item.attore.Id;
				} else if (index == indiceAttore && item.attore.hasOwnProperty('ContactId')) {
					recId = item.attore.ContactId;
				}
			});
		}
		console.log('@@@ recId modificato ' , recId);
        
        
        this.recId = recId;
        this.doc = doc;
        this.docFisso = docFisso;
        this.indiceAttore = indiceAttore;
        this.optyId = optyId;
		this.soggetti = soggetti;
		this.notAvailable = false;
        this.showUploadModal = true;		
    }  
    
    handleModal(event){
        var detail = event.detail;      
		this.showUploadModal = detail.open;
		
		if (detail.onlyNote){
			this.handleNoteModal(detail.result);
		}
	}
	
	handlePrivacyModal(event){
		var detail = event.detail;      
		this.showPrivacyModal = detail.open;		
	}

    handleLanguageModal(event){
        var detail = event.detail;      
        this.showLanguageModal = detail.open;
    }

    launchEdit(event){
        console.log("lanunchEdit");
        let docId = event.target.dataset.id;
        console.log("docId", docId); 
        if(docId == 'AdeguataVerifica'){
            this.showMavModal = true;
        }else if (docId=='privacyPF'){
			var attore = event.target.value;
			console.log('@@@ attore Privacy PF ' , attore);
			console.log('@@@ attore Privacy PF ' , attore.attore.hasOwnProperty('Contact') ? attore.attore.Contact.Id : '');
			
			var recordId = attore.attore.hasOwnProperty('Contact') ? attore.attore.Contact.Id : '';
			var isAccount = attore.attore.hasOwnProperty('Contact') ? false : true;
			this.showPrivacy(recordId,isAccount);
		}
	}
	
	showPrivacy(recordId,isAccount){
		this.privacyRecordId = recordId;
		this.privacyIsAccount = isAccount;
		this.showPrivacyModal = true;		
	}

    generaModulo(event){
        let unique = event.target.dataset.id;        
        let docName = event.target.name;
		let docId = event.target.value;
		
		console.log('@@@ unique ' , unique);
        console.log('@@@ docId download ' , docId);
        console.log('@@@ docName  ' , docName);		

        var accountId = this.accountId;

		var sourceObjName = event.target.dataset.list;
        var sourceObj = event.target.dataset.att;
        console.log('@@@ sourceObj ' , sourceObj);
        console.log('@@@ sourceObjName ' , sourceObjName);
        
        var downloadDoc = { id : docId , title : docName , codId : unique };
        console.log('@@@ downloadDoc ' , JSON.stringify(downloadDoc));

        sourceObjName == 'attori' ? accountId = docId : '' ;

        //Recupero le informazioni per la lingua del documento da produrre
		var linguaScelta = this.sceltaLingua;
        console.log('@@@ lingua ' , linguaScelta );
        if(linguaScelta.toLowerCase() != ('IT').toLowerCase()){
			this.openModalLanguage(downloadDoc);
		}else {
            this.enableSpinner();
            this.callDoc11(accountId,unique, docName, linguaScelta,downloadDoc );             
        }
    }

    createAndDownload (base64, docInfo, mimeType){
		console.log('@@@ base64 ' , base64.substring(0,100));
		console.log('@@@ mimeType ' , mimeType);		
		var binary = atob(base64.replace(/\s/g, ''));
		var len = binary.length;
		var buffer = new ArrayBuffer(len);
		var view = new Uint8Array(buffer);
		for (var i = 0; i < len; i++) {
			view[i] = binary.charCodeAt(i);
		}
		
		var blob = new Blob( [view], { type: "application/octet-stream" });		
		var url = URL.createObjectURL(blob);

		var a = document.createElement("a");
		document.body.appendChild(a);
		a.style = "display: none";
		a.href = url;
		a.download = docInfo.title;
		a.click();
    }
    
    launchDownload(event){
        this.enableSpinner();
        let unique = event.target.dataset.id;        
        let docName = event.target.name;
		let docId = event.target.value;
		let codDoc = event.target.dataset.cod;
		
		console.log('@@@ unique ' , unique);
        console.log('@@@ docId download ' , docId);
		console.log('@@@ docName  ' , docName);	
		console.log('@@@ codDoc  ' , codDoc);	
        var accountId = this.accountId;

        var sourceObjName = event.target.dataset.list;
        var sourceObj = event.target.dataset.att;
        var mimeType = event.target.dataset.mime;
        console.log('@@@ sourceObj ' , sourceObj);
        console.log('@@@ sourceObjName ' , sourceObjName);
        console.log('@@@ mimeType ' , mimeType);

        var downloadDoc = { id : docId , title : docName , codId : unique };
        console.log('@@@ downloadDoc ' , JSON.stringify(downloadDoc));
        doc61({
			"idDocumento" : docId,
            "codDocumento" : codDoc})
            .then(result => {
                if (result.success){
                    var base64str = result.data[0];
					var test = result.data[1];
                    console.log('@@@ test ' , test);                    
                    this.createAndDownload(base64str, downloadDoc, mimeType);
                }else {
                    const evt = new ShowToastEvent({
                        title: 'Attenzione',
                        message: (result.message != null || result.message != undefined) ?  result.message : "Nessun documento da scaricare",
                        variant: 'warning',
                        mode: 'pester'
                    });        
                    
                    this.dispatchEvent(evt); 
                }              
            }).finally(() => {
                this.disableSpinner();               
            });        
    }

    openModalLanguage(docInfo){
        console.log("openModalLanguage");
        this.showLanguageModal = true;
        this.docInfo = docInfo;
    }

    handleLingua(event){ 
        console.log("handleLingua");  
        let sceltaLingua = event.detail.language;
        this.showLanguageModal = event.detail.open;
        console.log("linguaScelta",this.sceltaLingua);
        this.generaDoc11(this.docInfo,sceltaLingua); 
    }

    handleMavModal(event){
        this.showMavModal = event.detail.open;
    }

    generaDoc11(docInfo,lingua){
        console.log("generaDoc11");
        this.enableSpinner();        
        this.callDoc11(this.accountId, docInfo.codId, docInfo.title, lingua,docInfo);           
    }

    callDoc11(recordId, codiceModulo, nomeFile, lingua, downloadDoc){

        doc11({
            "recordId" : recordId,
            "codiceModulo" : codiceModulo,
            "nomeFile" : nomeFile,
            "lingua" : lingua				
        }).then(result => {  
            if (result.success){
                // base64 string
                var base64str = result.data[0];
                var test = result.data[1];
                console.log('@@@ test ' , test);
                this.createAndDownload(base64str, downloadDoc, 'application/pdf');                   
            }else {
                const evt = new ShowToastEvent({
                    title: 'Attenzione',
                    message: (result.message != null || result.message != undefined) ?  result.message : "Nessun documento da scaricare",
                    variant: 'warning',
                    mode: 'pester'
                });        
                
                this.dispatchEvent(evt); 
            }             
        }).finally(() => {
            this.disableSpinner();           
        });
    }

    checkCompleteDocs(listToCheck, attributoCheck, indiceAttore){
        var toCheck = ''+listToCheck;
        var lista = this[toCheck];

		console.log('@@@ lista ' , lista);
		console.log('@@@ attributoCheck ' , attributoCheck);
		console.log('@@@ indiceAttore ' , indiceAttore);
		console.log('@@@ provv  ' , indiceAttore ? true : false);

		if(indiceAttore != undefined){
			
		}else{
			var redFact = lista.reduce((start, item) =>{
				if(item != null){
					console.log('@@@ condizione ' , start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? true : false )) : true));
					return start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true)				}
				else{
					return start;
				}
			}, true);
			
			console.log('@@@ redFact ' , redFact);
            console.log('@@@ attributoCheck not attore ' , attributoCheck);
            var at = ''+attributoCheck;
			this[at] = redFact;
		}
    }

    uploadHandler(event){
        //gestisco evento inviato da componente file uploader
        console.log("uploadHandler");
        console.log('@@@ HANDLER ' );
		console.log('@@@ params ' , JSON.stringify(event.detail.param));
		console.log('@@@ futureCall ' ,  event.detail.futureCall);

		var docParam = event.detail.param;
		var futureCall = event.detail.futureCall;

		var listaDoc;

		if( docParam.listToUpdate == 'attoredocs'){
			listaDoc = this.attori;
			console.log('@@@ listaDoc ' , listaDoc);
			listaDoc.forEach((item, index) =>{
				if(index == docParam.indiceAttori){
					listaDoc[index].docs.forEach((itemD, indexD) =>{
						if(itemD.index_value == docParam.index_value){
							console.log('@@@ trovato ' , itemD);

							if(!futureCall){
								itemD.id = docParam.id;
								itemD.DownloadName = docParam.title;
								itemD.missing = false;
							}
							else{
								itemD.futureDoc = true;
								itemD.missing = true;
							}

							itemD.valid_to = docParam.dataScadenza.toLocaleDateString('it-IT', { year: 'numeric', month: 'short', day: 'numeric' });
							itemD.isValidDate = new Date(docParam.dataScadenza) > new Date() ? 'Valido' : 'Non valido';

							itemD.isValid = (itemD.required ? (itemD.missing ? (itemD.isAvailable == false ? false : true ) : ((itemD.isValidDate == 'Valido' || !itemD.hasOwnProperty('isValidDate')) ? (itemD.isAvailable == false ? true : true ) : (itemD.isAvailable == false ? false : true ) )) : true);
						}
					});

					
					var red = item.docs.reduce((start, itemD) =>{
						if(itemD != null && itemD.index_value == 'SY0000074'){
                        	return start && (itemD.required ? (itemD.missing ? (itemD.isAvailable == false ? false : true ) : ((itemD.isValidDate == 'Valido' || !itemD.hasOwnProperty('isValidDate')) ? true : false )) : true) && listaDoc[index].attore.Contact.DataInserimentoConsensi__c != undefined;		
                    	}
						else if(itemD != null){
							console.log('@@@ condizione ' , start && (itemD.required ? (itemD.missing ? (itemD.isAvailable == false ? false : true ) : ((itemD.isValidDate == 'Valido' || !itemD.hasOwnProperty('isValidDate')) ? true : false )) : true));
							return start && (itemD.required ? (itemD.missing ? (itemD.isAvailable == false ? false : true ) : ((itemD.isValidDate == 'Valido' || !itemD.hasOwnProperty('isValidDate')) ? true : false )) : true);
						}
						else{
							return start;
						}
					}, true);

					item.isCompleted = red;

					console.log('@@@ item attore .isCompleted ' , item.isCompleted);
				}
			});
			
			this.attori = listaDoc;
		
		} else if(docParam.listToUpdate != undefined){
            console.log('@@@ ttt ' , docParam.listToUpdate);
            var listToUpdate = ''+docParam.listToUpdate;
			listaDoc = this[listToUpdate];
			
			if(docParam.listToUpdate != 'upload'){
				if(Array.isArray(listaDoc)){
					listaDoc.forEach((item, index) =>{
						if(item.index_value == docParam.index_value){
							console.log('@@@ trovato ' , item);

							if(!futureCall){
								item.id = docParam.id;
								item.DownloadName = docParam.title;
								item.missing = false;
							}
							else{
								item.futureDoc = true;
								item.missing = true;
							}

							item.valid_to = docParam.dataScadenza.toLocaleDateString('it-IT', { year: 'numeric', month: 'short', day: 'numeric' });
							item.isValidDate = new Date(docParam.dataScadenza) > new Date() ? 'Valido' : 'Non valido';

							console.log('@@@ validDate ' , new Date(docParam.dataScadenza) > new Date() ? 'Valido' : 'Non valido');							

							item.isValid = (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true);
						}
					});

				
                    //Workaround to rerender component
                    this[listToUpdate] = null;
                    this[listToUpdate] = listaDoc;	
					
					var indiceOpty;
					if(docParam.listToUpdate == 'expandedDocs'){
						var listaO = this.optyFact;
						listaO.forEach((item, index) =>{
							console.log('@@@ optyOpen ' , item);
							if(item.flip){
								console.log('@@@ opty trovata');
								indiceOpty = index;
							}
						});
					}
	
	
					var attr = docParam.listToUpdate == 'docsOpty' ? 'isDocsOptyValid' : docParam.listToUpdate == 'expandedDocs' ? 'isExpandedDocsValid' : 'docsComplete';					
					console.log('@@@ attr ' , attr);
					this.checkCompleteDocs(docParam.listToUpdate, attr, undefined);
				}else{
					var docUp = this[listToUpdate];
					console.log('@@@ docUp ' , docUp);

					if(!futureCall){
						docUp.id = docParam.id;
						docUp.DownloadName = docParam.title;
						docUp.missing = false;
					}
					else{
						console.log('@@@ prova future ');
						docUp.futureDoc = true;
						docUp.missing = true;
					}
					
					docUp.valid_to = docParam.dataScadenza.toLocaleDateString('it-IT', { year: 'numeric', month: 'short', day: 'numeric' });
					docUp.isValidDate = new Date(docParam.dataScadenza) > new Date() ? 'Valido' : 'Non valido';
					docUp.isValid = (docUp.required ? (docUp.missing ? (docUp.isAvailable == false ? false : true ) : ((docUp.isValidDate == 'Valido' || !docUp.hasOwnProperty('isValidDate')) ? (docUp.isAvailable == false ? true : true ) : (docUp.isAvailable == false ? false : true ) )) : true);
					//Workaround to rerender component
                    this[listToUpdate] = null;
                    this[listToUpdate] = listaDoc;	
					
					console.log('@@@ docUp ' , JSON.stringify(docUp));
				}
			}else{
				console.log('@@@ init dopo upload ');
				this.initialize();
			}

		}
		
		this.checkAllDocs();
    }

    handleChangeDoc(event){
        //gestisco note inviate da componente file uploader
        console.log("handleChangeDoc");
        console.log('@@@ parametri evento ' , JSON.stringify(event.detail));

		var tipo = event.detail.type;
		if(tipo == 'note'){
			var listToUpdate = event.detail.json.listToUpdate;
			var docToUpdate = event.detail.json.doc;
			var notaId = event.detail.json.idNota;
			var recordIdAttore = event.detail.json.idAttore;

			console.log('@@@ listToUpdate ' , listToUpdate);
			console.log('@@@ docToUpdate ' , JSON.stringify(docToUpdate));
			console.log('@@@ notaId ' , notaId);

            console.log('@@@ recordId Attore toUpdate ' , recordIdAttore);

            var listToUpdate = ''+listToUpdate;	
			var listaAgg = this[listToUpdate];
			
			if(listToUpdate == 'docsOpty' || listToUpdate == 'expandedDocs' || listToUpdate == 'docs' || listToUpdate == 'docsAssuntore'){
				listaAgg.forEach((item, index) =>{
					if(index == docToUpdate.myIndex){
						console.log('@@@ docTrovato ' , JSON.stringify(item));
						
						//problema elimina note che non si deflagga la checkbox
						this.template.querySelector("[data-index='"+item.index_value+"']").checked = false;

						if(notaId){
							item.notaId = notaId;
						}
						else{
							console.log('@@@ delete ' );
							delete item.notaId;
							delete item.nota;

							console.log('@@@ doc delete ' , item);
						}
					}
				});

				var indiceOpty;
				if(listToUpdate == 'expandedDocs'){
					var listaO = this.optyFact;
					listaO.forEach((item, index) =>{
						console.log('@@@ optyOpen ' , item);
						if(item.flip){
							console.log('@@@ opty trovata');
							indiceOpty = index;
						}
					});
				}


				var attr = listToUpdate == 'docsOpty' ? 'isDocsOptyValid' : listToUpdate == 'expandedDocs' ? 'isExpandedDocsValid' : 'docsComplete';
				
				console.log('@@@ attr ' , attr);
				this.checkCompleteDocs(listToUpdate, attr, undefined);
			}else{
				var indiceAtt;
				listaAgg.forEach((item, index) =>{
					console.log('@@@ actors ' , item);
					if(item.attore.Id == recordIdAttore){
						console.log('@@@ attore trovato ' , item);
						indiceAtt = index;
						item.docs.forEach((itemD, indexD) =>{
							if(indexD == docToUpdate.myIndex){
								console.log('@@@ documento attore trovato ' , itemD);

								if(notaId){
									itemD.notaId = notaId;
								}
								else{
									console.log('@@@ delete ' );
									delete itemD.notaId;
									delete itemD.nota;
		
									console.log('@@@ doc delete ' , itemD);
								}
							}
						});

						var red = item.docs.reduce((start, itemD) =>{
							if(itemD != null){
								console.log('@@@ condizione ' , start && (itemD.required ? (itemD.missing ? (itemD.isAvailable == false ? false : true ) : ((itemD.isValidDate == 'Valido' || !itemD.hasOwnProperty('isValidDate')) ? true : false )) : true));
								return start && (itemD.required ? (itemD.missing ? (itemD.isAvailable == false ? false : true ) : ((itemD.isValidDate == 'Valido' || !itemD.hasOwnProperty('isValidDate')) ? true : false )) : true);
							}
							else{
								return start;
							}
						}, true);
	
						item.isCompleted = red;
	
						console.log('@@@ item attore .isCompleted ' , item.isCompleted);
					}
				});

				console.log('@@@ prova fine attori');				
			}

			console.log('@@@ listaAgg 1 ' , this[listToUpdate]);

		
			this[listToUpdate] = listaAgg;

			console.log('@@@ listaAgg 2 ' , this[listToUpdate]);
			
			this.showUploadModal = event.detail.open;
		}
		
		this.checkAllDocs();	
	}

	handlePrivacyResult (event){
		let result = event.detail.success;
		console.log("handlePrivacyResult: ",result);

		if (result){
			let att = this.attori;
			att.forEach((item, index) =>{
				if(item.attore.hasOwnProperty('Contact')){
				console.log('@@@ aaa ' , item.attore);
					if(item.attore.Contact.Id == this.privacyRecordId){
						console.log('@@@ aaa ' , item.attore.Contact);
						item.attore.Contact.DataInserimentoConsensi__c = new Date();						
						var dataConsensi = item.attore.Contact.DataInserimentoConsensi__c;
						var red = item.docs.reduce((start, item) =>{
							if(item != null && item.index_value == 'SY0000074'){
								return start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? true : false )) : true) && dataConsensi != undefined;
							}
							else if(item != null){
								console.log('@@@ condizione ' , start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? true : false )) : true));
								return start && (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? true : false )) : true);
							}
							else{
								return start;
							}
						}, true);
				
						item.isCompleted = red;
					}
				} 
			});

			this.attori =  att;

		}else {
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Errore',
					message: "Errore modulo privacy",
					variant: 'error'
				})
			);
		}
	}

	handleChangeMavInfo(event){
		this.refresh();
	}
	
	// SEZIONE DEBITORI E GARANTI
	expandAttori(event){
		var newValue = event.target.value;
		console.log('@@@ newValue expandAttori' , JSON.stringify(newValue));
		var lista = this.attori;		
		lista.forEach((item, index) =>{
			if(item.myIndex == newValue.myIndex){
				item.isFlip = true;
			}
		});

		this.attori = lista;
	}

	closeAttori(event){
		var newValue = event.target.value;
		console.log('@@@ newValue ' , JSON.stringify(newValue));
		var lista = this.attori;		
		lista.forEach((item, index) =>{
			if(item.myIndex == newValue.myIndex){
				item.isFlip = false;
			}
		});

		this.attori = lista;
	}

	flipDocsAttori(event){
		var newValue = event.target.value;
		console.log('@@@ newValue aaa ' , newValue);
		var AttoreXDoc = newValue.split(';');
		console.log('@@@ AttoreXDoc ' , AttoreXDoc);
		var lista = this.attori;
		console.log('@@@ lista.docs ' , lista[AttoreXDoc[0]].docs);

		lista[AttoreXDoc[0]].docs.forEach((item, index) =>{
			if(item.myIndex == AttoreXDoc[1]){
				item.isFlip = !item.isFlip;
			}
		});

		this.attori = lista;
	}

	changeAvailabilityAttori(event){
		var newValue = event.target.checked;
		console.log('@@@ newValue ' , newValue);

		//var elemento = event.target.name;
		let elemento = JSON.parse(JSON.stringify(event.target.name));
		console.log('@@@ elemento ' , JSON.stringify(elemento));

		elemento.isAvailable = newValue;

		var listaAttori = this.attori;

		var attoreId = event.target.dataset.id;
		console.log('@@@ attoreId ' , attoreId);

		var notaId = event.target.dataset.note;
		console.log('@@@ note ' , notaId);
		
		var dati;
		var recId;
		
        console.log('@@@ listaAttori ' , listaAttori);
        
		listaAttori[attoreId].docs.forEach((item, index) =>{
            console.log('@@@ index ' , index);
            console.log('@@@ elemento.myIndex ' , elemento.myIndex);
			if(index == elemento.myIndex){
				elemento.isAvailable = newValue;
				dati = elemento;
				recId = listaAttori[attoreId].attore.Id;            
			}
		});

		this.attori = listaAttori;		
		console.log('@@@ notaId doc ' , notaId);

		//Apro la modal per gestire le note
		this.openDocumentNoteModal(dati, recId, listaAttori, 'attori', notaId);
	}

	openDocumentNoteModal (doc, recId, listaDoc, nomeAttribute, notaId){
		console.log('@@@ notaId doc ' , notaId);
		this.recId = recId;		
		this.notAvailable = true;
		this.datiDocNote = doc;
		this.noteDoc = doc.nota;
		this.idNota = notaId;	
		this.listaDoc = listaDoc;
		this.listToUpdate = nomeAttribute;
		this.showUploadModal = true;	
	}		
	
	handleNoteModal(result){

		if(result == 'SALVA'){
			this.datiDocNote.isAvailable = true;
		} else if(result == 'ANNULLA'){
			if(this.datiDocNote.isAvailable){
				this.datiDocNote.isAvailable = false;
			}else{
				this.datiDocNote.isAvailable = true;
			}
			
			console.log('@@@ doc ' , this.datiDocNote);
		}		

		if(this.listToUpdate != 'attori'){
			this.listaDoc.forEach((item, index) =>{
				console.log('@@@ index ' , index);

				if(index == this.datiDocNote.myIndex){
					console.log('@@@ trovato ');
					item.isAvailable = this.datiDocNote.isAvailable;
					this.template.querySelector("[data-index='"+item.index_value+"']").checked = this.datiDocNote.isAvailable;
					console.log('@@@ test ' , (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true));
					item.isValid = (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true);
				}
			});
			
		}else{
			console.log('@@@ listaDoc ' , this.listaDoc);
			this.listaDoc.forEach((item, index) =>{
				console.log('@@@ item ' , item.attore.Id);
				console.log('@@@ recordId ' , this.recId);

				if(item.attore.Id == this.recId){
					item.docs.forEach((docS, docIndex) =>{
						if(docS.index_value == this.datiDocNote.index_value){
							console.log('@@@ docS ' , docS);
							docS.isAvailable = this.datiDocNote.isAvailable;
							this.template.querySelector('[data-index='+docS.index_value+']').checked = this.datiDocNote.isAvailable;
							console.log("isAvailable",docS.isAvailable);
							docS.isValid = (docS.required ? (docS.missing ? (docS.isAvailable == false ? false : true ) : ((docS.isValidDate == 'Valido' || !docS.hasOwnProperty('isValidDate')) ? (docS.isAvailable == false ? true : true ) : (docS.isAvailable == false ? false : true ) )) : true);
							console.log('@@@ test ' , (docS.required ? (docS.missing ? (docS.isAvailable == false ? false : true ) : ((docS.isValidDate == 'Valido' || !docS.hasOwnProperty('isValidDate')) ? (docS.isAvailable == false ? false : true ) : (docS.isAvailable == false ? false : true ) )) : true));
							console.log('@@@ docS.isValid ' , docS.isValid);
						}
					});
				}
			});			
		}	
		
		console.log("listToUpdate: ",this.listToUpdate);
		let tmpVa = ''+this.listToUpdate;		
		this[tmpVa] =  this.listaDoc;	
		
		
	}

	//SEZIONE DOC ASSUNTORE START

	toggleDocAssuntore(){
		this.expandedAssuntoreDoc = !this.expandedAssuntoreDoc;
	}

	flipDocsAssuntore (event){
		var newValue = event.target.value;
		var lista = this.docsAssuntore;
		lista[newValue.myIndex].isFlip = !lista[newValue.myIndex].isFlip;
		this.docsAssuntore = lista;
	}

	get assuntoreSezioneCSS (){
		return this.isDocsAssuntoreValid ? ' slds-m-vertical_medium container-doc-opty-positive ' : ' slds-m-vertical_medium container-doc-opty-negative ';
	}

	get assuntoreSezioneCSS2 (){
		return ' slds-p-vertical_small slds-align_absolute-center border-opty-right '+ (this.isDocsAssuntoreValid ? ' back-icon-action-positive ' : ' back-icon-action-negative ');
	}

	get assuntoreSezioneCSS3 (){
		return 'slds-button slds-button_icon slds-button_icon-border '+ (this.isDocsAssuntoreValid ? '  btn-expand-positive ' : '  btn-expand-negative ');
	}

	get assuntoreSezioneCSS4 (){
		return this.isDocsAssuntoreValid ? '  all-border-blue ' : '  all-border-red ';
	}

	get sizeDocsAssuntore(){
		return this.docsAssuntore.length == 0;
	}

	//SEZIONE DOC ASSUNTORE END

	// ALTRA SEZIONE
	expandDocSingle(){
		this.expandedSingleDoc = true;
	}

	closeDocSingle(event){
		var newValue = event.target.value;
		console.log('@@@ newValue ' , newValue);
		this.expandedSingleDoc = false;
	}

	flipDocsSingleOpty (event){
		var newValue = event.target.value;
		var lista = this.docsOpty;
		lista[newValue.myIndex].isFlip = !lista[newValue.myIndex].isFlip;
		this.docsOpty = lista;
	}

	changeAvailability(event){
		console.log(event.target.dataset.index);
		var newValue = event.target.checked;
		console.log('@@@ newValue ' , newValue);

		var elemento = event.target.name;
		console.log('@@@ elemento ' , JSON.stringify(elemento));
		
		var optyIdDefault = this.opportunityId;
		console.log('@@@ optyIdDefault ' , optyIdDefault);

		var note = event.target.dataset.note;
		console.log('@@@ note ' , note);

		var optyId;

		var listaDocs = this.docsOpty;
		console.log('@@@ docsOpty ' , listaDocs);
		
		var dati;
		var recId;
		listaDocs.forEach((item, index) =>{
			if(index == elemento.myIndex){
				item.isAvailable = newValue;

				dati = item;
				recId = optyIdDefault;
			}
		});

		this.docsOpty = listaDocs;

		console.log('@@@ dati ' , dati);

		//Apro la modal per gestire le note
		this.openDocumentNoteModal(dati, recId, listaDocs, 'docsOpty', note);		
	}

	changeAvailabilityAssuntore(event){
		console.log(event.target.dataset.index);
		var newValue = event.target.checked;
		console.log('@@@ newValue ' , newValue);

		var elemento = event.target.name;
		console.log('@@@ elemento ' , JSON.stringify(elemento));
		
		var idAssuntore = this.idAssuntore;
		console.log('@@@ optyIdDefault ' , idAssuntore);

		var note = event.target.dataset.note;
		console.log('@@@ note ' , note);

		var listaDocs = this.docsAssuntore;
		console.log('@@@ docsAssuntore ' , listaDocs);
		
		var dati;
		var recId;
		listaDocs.forEach((item, index) =>{
			if(index == elemento.myIndex){
				item.isAvailable = newValue;

				dati = item;
				recId = idAssuntore;
			}
		});

		this.docsAssuntore = listaDocs;

		console.log('@@@ dati ' , dati);

		//Apro la modal per gestire le note
		this.openDocumentNoteModal(dati, recId, listaDocs, 'docsAssuntore', note);		
	}
}