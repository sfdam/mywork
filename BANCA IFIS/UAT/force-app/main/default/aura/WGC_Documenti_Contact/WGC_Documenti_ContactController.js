({
	doInit : function(component, event, helper) {
		component.set("v.isLoaded", false);
		
		helper.initialize(component, event, helper);
	},

	doFlip : function(component, event, helper){
		var a = event.getSource().getLocalId();
		if(a == "isFlip0"){
			var flip = component.get("v.isFlip0");
			if(flip == true){
				component.set("v.isFlip0" , false);
			}
			else{
				component.set("v.isFlip0" , true);
			}
		}
	},

	LaunchEdit : function(component, event, helper){
		var idDoc = event.getSource().getLocalId();
		helper.launchEditHelp(component, event, helper, idDoc);
	},

	launchUpload : function(component, event, helper){
		//var nomeModulo = event.getSource().getLocalId();
		var doc = event.getSource().get("v.value");
		var recId = component.get('v.recordId');
		var docFisso = event.getSource().getLocalId();

		console.log('@@@ aaa ' , docFisso );

		helper.launchUploadHelp(component, event, helper, recId, doc, docFisso);
	},

	launchDownload : function(component, event, helper){
		component.set("v.isLoaded", false);
		var docName = event.getSource().get("v.name");
		var docId = event.getSource().get("v.value");
		console.log('@@@ docId download ' , docId);
		var accountId = component.get("v.recordId");
		console.log('@@@ contactId ' , accountId);
		var unique = event.getSource().getLocalId();
		
		var downloadDoc = { id : docId , title : docName , codId : unique };

		var sourceObjName = event.target.getAttribute("data-list");
		var sourceObj = event.target.getAttribute("data-att");
		var mimeType = event.target.getAttribute("data-mime");
		console.log('@@@ mimeType ' , mimeType);

		console.log('@@@ sourceObj ' , sourceObj);
		console.log('@@@ sourceObjName ' , sourceObjName);

		console.log('@@@ downloadDoc ' , JSON.stringify(downloadDoc));

		var action = component.get("c.doc08");
		action.setParams({
			"accountId" : accountId,
			"document" : JSON.stringify(downloadDoc)
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				if(risposta.success){

					// base64 string
					var base64str = risposta.data[0];
					
					console.log('@@@ base64 string ' , base64str);

					helper.createAndDownload(component, event, helper, base64str, downloadDoc, mimeType);


					component.set("v.isLoaded", true);

					//Aggiungo il bordo blu dopo il download
					if(sourceObjName != null && sourceObjName != undefined){
						var obj = component.get("v."+sourceObjName);
						obj.composition = true;

						component.set("v."+sourceObjName, obj);
					}
					
				}
				else{
					component.set("v.isLoaded", true);
					console.log('@@@ risposta message ' , risposta.message);

					var msg = $A.get("e.force:showToast");
					msg.setParams({
						"title" : "Attenzione",
						"message" : "Nessun documento da scaricare",
						"type" : "WARNING"
					});
					msg.fire();
				}
			}
			else{
				component.set("v.isLoaded", true);
				console.log('@@@ error ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	},

	generaModulo : function(component, event, helper){
		var docName = event.getSource().get("v.name");
		var docId = event.getSource().get("v.value");
		var unique = event.getSource().getLocalId();
		console.log('@@@ unique ' , unique);
		console.log('@@@ docId download ' , docId);
		var accountId = component.get("v.recordId");

		var sourceObjName = event.target.getAttribute("data-list");
		var sourceObj = event.target.getAttribute("data-att");
		//var test2 = event.currentTarget.getAttribute("data-list");
		
		//console.log('@@@ currentTarget ' , test2);
		console.log('@@@ sourceObj ' , sourceObj);
		console.log('@@@ sourceObjName ' , sourceObjName);

		
		var downloadDoc = { id : docId , title : docName , codId : unique };

		console.log('@@@ downloadDoc ' , JSON.stringify(downloadDoc));

		//Recupero le informazioni per la lingua del documento da produrre
		var linguaScelta = component.get("v.sceltaLingua");
		console.log('@@@ lingua ' , linguaScelta );

		if(linguaScelta.toLowerCase() != ('IT').toLowerCase()){
			helper.openModalLanguage(component, event, helper, downloadDoc);
		}
		else{
			component.set("v.isLoaded", false);
			var action = component.get("c.doc11");
            var uniqueModulo = (unique === 'PrivacyEsecutore') ? 'PrivacyPF' : unique;
			action.setParams({
				"recordId" : accountId,
				"codiceModulo" : uniqueModulo,
				"nomeFile" : docName,
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

						helper.createAndDownload(component, event, helper, base64str, downloadDoc, 'application/pdf');

						component.set("v.isLoaded", true);
						
						//Aggiungo il bordo blu dopo il download
						if(sourceObjName != null && sourceObjName != undefined){
							var obj = component.get("v."+sourceObjName);
							if(obj != null && obj != undefined){
								obj.composition = true;

								component.set("v."+sourceObjName, obj);
							}
						}
						
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
		}
	},

	// uploadHandler : function(component, event, helper){
	// 	console.log('@@@ params ' , JSON.stringify(event.getParam("param")));

	// 	var docParam = event.getParam("param");

	// 	var listaDoc;

	// 	// if( docParam.listToUpdate == 'attoredocs'){
	// 	// 	listaDoc = component.get("v.attori");
	// 	// 	console.log('@@@ listaDoc ' , listaDoc);
	// 	// 	listaDoc.forEach((item, index) =>{
	// 	// 		if(index == docParam.indiceAttori){
	// 	// 			listaDoc[index].docs.forEach((itemD, indexD) =>{
	// 	// 				if(itemD.index_value == docParam.index_value){
	// 	// 					console.log('@@@ trovato ' , itemD);
	// 	// 					itemD.id = docParam.id;
	// 	// 				}
	// 	// 			});
	// 	// 		}
	// 	// 	});
	// 	// 	component.set("v.attori", listaDoc);
	// 	// }
	// 	// else{
	// 		listaDoc = component.get("v."+docParam.listToUpdate);
	// 		console.log('@@@ listaDoc ' , listaDoc);

	// 		if(Array.isArray(listaDoc)){
	// 			listaDoc.forEach((item, index) =>{
	// 				if(item.index_value == docParam.index_value){
	// 					console.log('@@@ trovato ' , item);
	// 					item.id = docParam.id;
	// 				}
	// 			});

	// 			console.log('@@@ update ' , component.get("v."+docParam.listToUpdate));
	// 		}
	// 		else if(listaDoc != undefined){
	// 			listaDoc.id = docParam.id;
	// 		}
	// 		component.set("v."+docParam.listToUpdate, listaDoc);
	// 	//}
	// },

	//funzione che gestisce il flip delle card nell'array di docs del servizio doc10
	flipDocs : function(component, event, helper){
		var evt = event.getSource().get("v.value");
		var docs = component.get("v.docs");
		docs[evt.myIndex].isFlip = !docs[evt.myIndex].isFlip;
		component.set("v.docs", docs);
	},

	changeAvailability : function(component, event, helper){
		var newValue = event.getSource().get("v.value");
		console.log('@@@ newValue ' , newValue);

		var elemento = event.getSource().get("v.name");
		console.log('@@@ elemento ' , JSON.stringify(elemento));

		elemento.isAvailable = newValue;

		var listaDocs = component.get("v.docs");

		var dati;
		var recId;

		recId = component.get("v.recordId");

		listaDocs.forEach((item, index) =>{
			console.log('@@@ doc ' , item);
			if(index == elemento.myIndex){

				item.isAvailable = newValue;
				dati = item;
			}
		});

		component.set("v.docs" , listaDocs);
		console.log('@@@ dati ' , dati);
            
        var notaId = event.target.getAttribute("data-notaId");
        console.log('@@@ notaId ' , notaId);

		//Apro la modal per gestire le note
		helper.openDocumentNoteModal(component, event, helper, dati, recId, listaDocs, 'docs', notaId);
	},

	handleChangeDoc : function(component, event, helper){
		console.log('@@@ parametri evento ' , JSON.stringify(event.getParams()));

		var tipo = event.getParams().type;
		if(tipo == 'note'){
			var listToUpdate = event.getParams().json.listToUpdate;
			var docToUpdate = event.getParams().json.doc;
			var notaId = event.getParams().json.idNota;
			var recordIdAttore = event.getParams().json.idAttore;

			console.log('@@@ listToUpdate ' , listToUpdate);
			console.log('@@@ docToUpdate ' , JSON.stringify(docToUpdate));
			console.log('@@@ notaId ' , notaId);

			console.log('@@@ recordId Attore toUpdate ' , recordIdAttore);

			var listaAgg = component.get("v."+listToUpdate);

			console.log('@@@ lista ' , listaAgg);
			console.log('@@@ !recordIdAttore ' , !recordIdAttore);
			//if(!recordIdAttore){
				console.log('@@@ recordIdAttore not null ');
				listaAgg.forEach((item, index) =>{
					console.log('@@@ docToUpdate.myIndex ' , docToUpdate.myIndex);
					console.log('@@@ index ' , index);
					if(index == docToUpdate.myIndex){
						console.log('@@@ docTrovato ' , JSON.stringify(item));

						if(notaId){
							item.notaId = notaId;
						}
						else{
							console.log('@@@ delete ' );
							delete item.notaId;
							delete item.nota;

							console.log('@@@ doc delete ' , item);
						}

						item.isValid = (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true);
					}
				});
			//}
			// else{
			// 	listaAgg.forEach((item, index) =>{
			// 		if(item.attore.Id == recordIdAttore){
			// 			console.log('@@@ attore trovato ' , item);
			// 			item.docs.forEach((itemD, indexD) =>{
			// 				if(indexD == docToUpdate.myIndex){
			// 					console.log('@@@ documento attore trovato ' , itemD);

			// 					if(notaId){
			// 						itemD.notaId = notaId;
			// 					}
			// 					else{
			// 						console.log('@@@ delete ' );
			// 						delete itemD.notaId;
			// 						delete itemD.nota;
		
			// 						console.log('@@@ doc delete ' , itemD);
			// 					}
			// 				}
			// 			});
			// 		}
			// 	});
			// }

			//Workaround to rerender component
			component.set("v."+listToUpdate, []);
			component.set("v."+listToUpdate, listaAgg);

			console.log('@@@ listaAgg ' , component.get("v."+listToUpdate));
		}
		else if(tipo == 'doc'){
			var listToUpdate = event.getParams().json.listToUpdate;
			var docToUpdate = event.getParams().json.doc;
			var docId = event.getParams().json.idDoc;

			console.log('@@@ listToUpdate ' , listToUpdate);
			console.log('@@@ docToUpdate ' , JSON.stringify(docToUpdate));
			console.log('@@@ docId ' , docId);

			var listaAgg = component.get("v."+listToUpdate);

			listaAgg.forEach((item, index) =>{
				if(index == docToUpdate.myIndex){
					console.log('@@@ docTrovato ' , JSON.stringify(item));
					item.id = docId;
					item.isValid = (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true);
				}
			});

			//Workaround to rerender component
			component.set("v."+listToUpdate, []);
			component.set("v."+listToUpdate, listaAgg);
		}

		helper.checkDocId(component, event, helper, listaAgg);
		//helper.checkAllDocs(component, event, helper);
	},

	uploadHandler : function(component, event, helper){
		console.log('@@@ HANDLER ' );
		console.log('@@@ params ' , JSON.stringify(event.getParam("param")));

		var docParam = event.getParam("param");
		var futureCall = event.getParam("futureCall");

		var listaDoc;

		if( docParam.listToUpdate == 'attoredocs'){
			listaDoc = component.get("v.attori");
			console.log('@@@ listaDoc ' , listaDoc);
			listaDoc.forEach((item, index) =>{
				if(index == docParam.indiceAttori){
					listaDoc[index].docs.forEach((itemD, indexD) =>{
						if(itemD.index_value == docParam.index_value){
							console.log('@@@ trovato ' , itemD);

							if(!futureCall){
								itemD.id = docParam.id;
								itemD.DownloadName = docParam.title;
							}
							else{
								itemD.futureDoc = true;
								itemD.missing = true;
							}

							itemD.valid_to = docParam.dataScadenza.toLocaleDateString('it-IT', { year: 'numeric', month: 'short', day: 'numeric' });
							itemD.isValidDate = new Date(docParam.dataScadenza) > new Date() ? 'Valido' : 'Non valido';
						}
					});
				}
			});

			//Workaround to rerender component
			component.set("v.attori", []);
			component.set("v.attori", listaDoc);

			helper.checkDocId(component, event, helper, listaDoc);
		}
		else if(docParam.listToUpdate != undefined){
			console.log('@@@ ttt ' , docParam.listToUpdate);
			listaDoc = component.get("v."+docParam.listToUpdate);
			//console.log('@@@ listaDoc ' , JSON.stringify(listaDoc));

			if(docParam.listToUpdate != 'upload'){
				if(Array.isArray(listaDoc)){
					listaDoc.forEach((item, index) =>{
						if(item.index_value == docParam.index_value){
							console.log('@@@ trovato ' , item);

							if(!futureCall){
								item.id = docParam.id;
								item.DownloadName = docParam.title;
							}
							else{
								item.futureDoc = true;
								item.missing = true;
							}

							item.valid_to = docParam.dataScadenza.toLocaleDateString('it-IT', { year: 'numeric', month: 'short', day: 'numeric' });
							item.isValidDate = new Date(docParam.dataScadenza) > new Date() ? 'Valido' : 'Non valido';
							// console.log('@@@ test data 2 ' , docParam.dataScadenza.toLocaleDateString('it-IT', { year: 'numeric', month: 'short', day: 'numeric' }));
							// console.log('@@@ test data ' , item.valid_to);

							item.isValid = (item.required ? (item.missing ? (item.isAvailable == false ? false : true ) : ((item.isValidDate == 'Valido' || !item.hasOwnProperty('isValidDate')) ? (item.isAvailable == false ? true : true ) : (item.isAvailable == false ? false : true ) )) : true);
						}
					});

					console.log('@@@ update ' , component.get("v."+docParam.listToUpdate));

					//Workaround to rerender component
					component.set("v."+docParam.listToUpdate, []);
					component.set("v."+docParam.listToUpdate, listaDoc);

					helper.checkDocId(component, event, helper, listaDoc);
				}
				else{
					var docUp = component.get("v."+docParam.listToUpdate);

					if(!futureCall){
						docUp.id = docParam.id;
						docUp.DownloadName = docParam.title;
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
					component.set("v."+docParam.listToUpdate, []);
					component.set("v."+docParam.listToUpdate, docUp);

					
					console.log('@@@ docUp ' , JSON.stringify(docUp));

					//helper.checkDocId(component, event, helper, docUp);
				}

			}
			else{
				helper.initialize(component, event, helper);
			}
		}

		//helper.checkDocId(component, event, helper);
		//helper.checkAllDocs(component, event, helper);
	},
})