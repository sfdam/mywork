({

	initialize : function(component, event, helper){
		component.set("v.isLoaded", false);
		var recordId = component.get("v.recordId");
		var json;
		var note = [];
		this.apex(component, event, 'docCheckList' , {"objId" : recordId}).then((result) =>{
			console.log('@@@ result doc10 ' , result);
			
			if(result.data.length > 0){
				json = result.data[0];

				
				if(result.data.length > 1){
					note = result.data[1];
					
				}
				console.log('@@@ note ' , note);

				return this.apex(component, event, 'getDocumentMapping', {});
			}



		}).then((result) =>{
			console.log('@@@ result mapping ' , result);
			if(result != undefined && result.data.length > 0){
				var mapping = result.data[0];
				component.set("v.mappings", result.data[0]);

				var docs = [];
				console.log('@@@ json ' , json);
				console.log('@@@ note ' , note);
				docs = this.generateDocsList(component, event, helper, json, note);
				console.log('@@@ docs 1 ' , docs);
				
				docs = this.mapCodeName(component, event, helper, docs, mapping);

				console.log('@@@ docs2 ' , docs);

				this.checkDocId(component, event, helper, docs);

				docs.forEach((item, index) =>{
					item.isFlip = true;
					item.myIndex = index;
				});

				component.set("v.docs", docs);
			}

			// var recordId = component.get("v.recordId");

			// return this.apex(component, event, 'getContactPrivacy', {"contactId" : recordId});
			

			component.set("v.isLoaded", true);
		})
		// }).then((result) =>{
		// 	if(result != undefined && result != null){
		// 		var risposta = result;
		// 		if(risposta.success){
		// 			console.log('@@@ risposta contact ' , risposta);
		// 			//Formatto la data di creazione
		// 			if(risposta.data.length > 0){
		// 				var tmp = new Date(risposta.data[0].DataInserimentoConsensi__c);
		// 				tmp.setFullYear(tmp.getFullYear()+1);
		// 				risposta.data[0].DataInserimentoConsensi__c = tmp.toLocaleDateString('it-IT', {year: 'numeric', month: 'short', day: 'numeric'});

		// 				component.set("v.response", risposta.data);
		// 			}
		// 		}
		// 	}

		// 	component.set("v.isLoaded", true);
		// });
	},

	generateDocsList : function(component, event, helper, json, notes){
		var docsList = [];
		var flipList = [];		

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
					console.log('@@@ item.index_value ' , item.index_value);
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
				});
			}
			else{
				singleDoc.isValidDate = 'Non valido';
			}

			singleDoc.isValid = (singleDoc.required ? (singleDoc.missing ? (singleDoc.isAvailable == false ? false : true ) : ((singleDoc.isValidDate == 'Valido' || !singleDoc.hasOwnProperty('isValidDate')) ? (singleDoc.isAvailable == false ? true : true ) : (singleDoc.isAvailable == false ? false : true ) )) : true);
			//PPG
			if(singleDoc.index_value == 'SY0000074'){
				singleDoc.composition = false;
				singleDoc.isAvailable = true;
				singleDoc.isValid = (singleDoc.required ? (singleDoc.missing ? (singleDoc.isAvailable == false ? false : true ) : ((singleDoc.isValidDate == 'Valido' || !singleDoc.hasOwnProperty('isValidDate')) ? (singleDoc.isAvailable == false ? true : true ) : (singleDoc.isAvailable == false ? false : true ) )) : true);
				component.set("v.docPPG", singleDoc);
				console.log('@@@ singleDoc ' , singleDoc.id);
				console.log('@@@ ppg ' , singleDoc);
			}
			else{
				//Genero un oggetto per gestire il flip
				console.log('@@@ singleDoc ' , JSON.stringify(singleDoc));
				if(item.docs.length > 0 || singleDoc.required){
					// var singleFlip = { isFlip : true, index : item.id };
					// flipList.push(singleFlip);
					docsList.push(singleDoc);
				}
			}
		});

		console.log('@@@ docsList ' , docsList);
		component.set("v.docs", docsList);
		component.set("v.isFlipDocs", flipList);

		return docsList;
	},

	launchEditHelp : function(component, event, helper, idDoc){
		var recordId = component.get('v.recordId');
		$A.createComponent("c:WGC_PrivacyPersonaGiuridica_Component", {"recordId" : recordId, "isAccount" : false},
			function(content, status, error) {
				if (status === "SUCCESS") {
					component.find('overlayLib').showCustomModal({
						header: 'Privacy Persona Fisica',
						body: content,
						showCloseButton: true,
						cssClass: "slds-modal_medium",
						closeCallback: function() {
							//alert('You closed the alert!');
							//Richiamo il doInit per reinizializzare il component e mostrare la data di scadenza e la validità del documento
							helper.initPrivacyDoc(component, event, helper);
							
						}
					})
				}
				if (status == "ERROR"){
					var msg = $A.get("e.force:showToast");
					msg.setParams({
						"title" : "ERRORE!",
						"message" : "errore durante apertura modulo",
						"type" : "ERROR"
					});
					msg.fire();
				}                               
		});
	},

	launchUploadHelp : function(component, event, helper, recId, doc, docFisso){
		console.log('@@@ recId ' , recId);
		console.log('@@@ doc ' , doc);
		console.log('@@@ docFisso ' , docFisso);
		$A.createComponent("c:WGC_FileUploader", 
		//"nomeModulo" : nomeModulo
			{"recordId" : recId, "datiDoc" : doc, "docFisso" : docFisso },
			function(content, status, error){
				if (status === "SUCCESS") {
					component.find('overlayLib').showCustomModal({
						header: 'Upload Documenti',
						body: content,
						showCloseButton: true,
						cssClass: "slds-modal_medium",
						closeCallback: function() {
							//alert('You closed the alert!');
							//helper.initialize(component, event, helper);
						}
					})
				}
				if (status == "ERROR"){
					console.log('@@@ error ' , JSON.stringify(error));
					var msg = $A.get("e.force:showToast");
					msg.setParams({
						"title" : "ERRORE!",
						"message" : "errore durante l'upload del documento",
						"type" : "ERROR"
					});
					msg.fire();
				}
		});
	},

	//funzione che gestisce il flip delle card nell'array di docs del servizio doc10
	flipDocs : function(component, event, helper){
		var evt = event.getSource().get("v.value");
		var docs = component.get("v.docs");
		docs[evt.myIndex].isFlip = !docs[evt.myIndex].isFlip;
		component.set("v.docs", docs);
	},

	getPrivacyRecord : function(component, event, helper){
		var recordId = component.get("v.recordId");
		var action = component.get("c.getContactPrivacy");
		action.setParams({
			"contactId" : recordId
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				if(risposta.success){
					console.log('@@@ risposta contact ' , risposta);
					//Formatto la data di creazione
					if(risposta.data.length > 0){
						var tmp = new Date(risposta.data[0].CreatedDate);
						tmp.setFullYear(tmp.getFullYear()+1);
						risposta.data[0].CreatedDate = tmp.toLocaleDateString('it-IT', {year: 'numeric', month: 'short', day: 'numeric'});

						component.set("v.response", risposta.data);
					}
				}
			}
			else{
				console.log('@@@ error getPrivacy ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	},

	getMetadataMapping : function(component, event, helper){
		var action = component.get("c.getDocumentMapping");
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				console.log('@@@ risposta mappings' , risposta);
				if(risposta.success){
					component.set("v.mappings", risposta.data[0]);
				}
				else{
					console.log('@@@ risposta.message error ' , risposta.message);
				}
			}
			else{

			}
		});
		$A.enqueueAction(action);
	},

	apex: function (component, event, apexAction, params) {
        var p = new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get("c." + apexAction + "");
            action.setParams(params);
            action.setCallback(this, function (callbackResult) {
                if (callbackResult.getState() == 'SUCCESS') {
                    resolve(callbackResult.getReturnValue());
                }
                if (callbackResult.getState() == 'ERROR') {
                    console.log('ERROR', callbackResult.getError());
                    reject(callbackResult.getError());
                }
            });
            $A.enqueueAction(action);
        }));
        return p;
	},
	

	mapCodeName : function(component, event, helper, docs, mapping){

		docs.forEach((item, index) =>{
			mapping.forEach((map, index) =>{
				if(map.Documento__c == item.index_value){
					console.log('@@@ map ' , map);
					console.log('@@@ item ' , item);
					item.Name = map.MasterLabel;
				}
			});
		});

		return docs;
	},

	checkDocId : function(component, event, helper, docsToCheck){

		var check = false;
		console.log('@@@ docsToCheck ' , typeof docsToCheck);
		console.log('@@@ docsToCheck ' , docsToCheck);
		docsToCheck.find(item =>{
			return (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true);
			// if(item.id == null || item.id == undefined || item.id == ''){
			// 	check = true;
			// 	return check;
			// }
		});

		console.log('@@@ check ' , check);
		component.set("v.docsComplete", check);
	},

	createAndDownload : function(component, event, helper, base64, docInfo, mimeType){

		var binary = atob(base64.replace(/\s/g, ''));
		var len = binary.length;
		var buffer = new ArrayBuffer(len);
		var view = new Uint8Array(buffer);
		for (var i = 0; i < len; i++) {
			view[i] = binary.charCodeAt(i);
		}
		var blob = new Blob( [view], { type: "application/octet-stream" });
		//var blob = new Blob( [view]);
		var url = URL.createObjectURL(blob);

		var a = document.createElement("a");
		document.body.appendChild(a);
		a.style = "display: none";
		a.href = url;
		a.download = docInfo.title;
		a.click();
	},

	openDocumentNoteModal : function(component, event, helper, doc, recId, listaDoc, nomeAttribute, notaId){
		console.log('@@@ datiDoc note ' , doc);
		
		$A.createComponent("c:WGC_FileUploader", {"recordId" : recId, "notAvailable" : true , "datiDocNote" : doc, "noteDoc" : doc.nota, "modalBodyAttributeName" : component.getReference('v.parentAttributeName'), "idNota" : notaId, "listToUpdate" : nomeAttribute },
			function(content, status, error) {
				if (status === "SUCCESS") {
					console.log('@@@ find ' , component);
					component.find('overlayLib').showCustomModal({
						header: 'File Uploader',
						body: content,
						showCloseButton: true,
						cssClass: "slds-modal_medium",
						closeCallback: function() {
							console.log('@@@ aaa ' , component.get("v.parentAttributeName"));
							var result = component.get("v.parentAttributeName");
							if(result == 'ANNULLA'){
								if(doc.isAvailable){
									doc.isAvailable = false;
								}
								else{
									doc.isAvailable = true;
								}
								//doc.isAvailable = doc.isAvailable;
								console.log('@@@ doc ' , doc);
								listaDoc.forEach((item, index) =>{
									console.log('@@@ index ' , index);

									if(index == doc.myIndex){
										console.log('@@@ trovato ');
										item.isAvailable = doc.isAvailable;
										item.isValid = (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true);
									}
								});

								component.set("v."+nomeAttribute, listaDoc);
								//helper.initialize(component, event, helper);
							}
						}
					})
				}
				if (status == "ERROR"){
					helper.showToastError(component, event, helper);
				}                               
		});
	},

	openModalLanguage : function(component, event, helper, docInfo){
		console.log('@@@ open modal language');
		$A.createComponent("c:WGC_SceltaLinguaDocumenti", { "modalBodyAttributeName" : component.getReference('v.linguaSelezionata')},
			function(content, status, error) {
				if (status === "SUCCESS") {
					component.find('overlayLib').showCustomModal({
						header: 'Scelta lingua',
						body: content,
						showCloseButton: false,
						cssClass: "slds-modal_medium",
						closeCallback: function() {
							console.log('@@@ test');
							var linguaScelta = component.get("v.linguaSelezionata");
							console.log('@@@ linguaScelta ' , linguaScelta);
							
							if(linguaScelta != 'ANNULLA'){
								helper.generaDoc11(component, event, helper, docInfo);
							}
						}
					});
				}
				else{
					console.log('@@@ error ' , error);
				}
					
		});
	},

	generaDoc11 : function(component, event, helper, docInfo){
		var linguaScelta = component.get("v.linguaSelezionata");
		console.log('@@@ linguaScelta ' , linguaScelta);
		console.log('@@@ docInfo ' , docInfo);
		
		var accountId = component.get("v.recordId");
		//Chiamata
		component.set("v.isLoaded", false);
		var action = component.get("c.doc11");
		action.setParams({
			"recordId" : accountId,
			"codiceModulo" : docInfo.codId,
			"nomeFile" : docInfo.title,
			"lingua" : linguaScelta
			//"document" : JSON.stringify(downloadDoc)
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				if(risposta.success){

					// base64 string
					var base64str = risposta.data[0];

					var test = risposta.data[1];
					console.log('@@@ test ' , test);

					// var navigator = component.find("navService");
					// var pg = {
					//   "type": "standard__recordPage",
					//   "attributes": {
					// 	"recordId": test,
					// 	"objectApiName": "ContentVersion",
					// 	"actionName": "view"
					//   }
					// };
					// navigator.navigate(pg);

					helper.createAndDownload(component, event, helper, base64str, docInfo, 'application/pdf');

					component.set("v.isLoaded", true);
					
					//Aggiungo il bordo blu dopo il download
					// if(sourceObjName != null && sourceObjName != undefined){
					// 	var obj = component.get("v."+sourceObjName);
					// 	obj.composition = true;

					// 	component.set("v."+sourceObjName, obj);
					// }
					
				}
				else{
					component.set("v.isLoaded", true);
					console.log('@@@ risposta message ' , risposta.message);

					var msg = $A.get("e.force:showToast");
					msg.setParams({
						"title" : "Attenzione",
						"message" : (risposta.message != null || risposta.message != undefined) ?  risposta.message : "Nessun documento da scaricare",
						"type" : "WARNING"
					});
					msg.fire();
				}
			}
			else{
				console.log('@@@ error ' , response.getError());
				component.set("v.isLoaded", true);
			}
		});
		$A.enqueueAction(action);

	},

	initPrivacyDoc : function(component, event, helper){
		//component, event, 'getContactPrivacy', {"contactId" : recordId});

		var recordId = component.get("v.recordId");

		var action = component.get("c.getContactPrivacy");
		action.setParams({
			"contactId" : recordId 
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var result = response.getReturnValue();
				var risposta = result;
				if(risposta.success){
					console.log('@@@ risposta contact ' , risposta);
					//Formatto la data di creazione
					if(risposta.data.length > 0){
						var tmp = new Date(risposta.data[0].DataInserimentoConsensi__c);
						tmp.setFullYear(tmp.getFullYear()+1);
						risposta.data[0].DataInserimentoConsensi__c = tmp.toLocaleDateString('it-IT', {year: 'numeric', month: 'short', day: 'numeric'});

						component.set("v.response", risposta.data);
					}
				}
			}
			else{
				console.log('@@@ error ' , response.getError());
			}
		});

		$A.enqueueAction(action);
	},
})