({
	initialize : function(component, event, helper) {
		var isNota = component.get("v.notAvailable");
		console.log('@@@ isNota ' , isNota);

		var docFisso = component.get("v.docFisso");
		console.log('@@@ docFisso ' , docFisso);

		//adione CR 293
		var soggetti = component.get("v.soggetti");
		if (soggetti != null && soggetti.length != 0) //se il popup è aperto da agg. doc. generico e mi hanno passato gli attori
			helper.populateSoggettiPicklist(component, event, helper);

		if(isNota == false){
			var action = component.get("c.getDocMetadata");

			var isDocFisso = true;

			if(docFisso == null || docFisso == undefined){
				isDocFisso = false;
			}
			action.setParams({
				"isDocFisso" : isDocFisso
			});
			action.setCallback(this, (response) =>{
				if(response.getState() == "SUCCESS"){
					var risposta = response.getReturnValue();
					if(risposta.success){
						console.log('@@@ risposta ok ' , risposta);
						component.set("v.mappatura", risposta.data[0]);
						component.set("v.isLoaded", true);
						//if(component.get("v.datiDoc") == 'new'){

							var arrayFam = [];
							var arrayTipo = [];

							var arrayMeta = [];


							for(var key in risposta.data[0]){
								var singleMeta = {};
								singleMeta.famiglia = key;
								singleMeta.documento = risposta.data[0][key];
								arrayMeta.push(singleMeta);

								//console.log('@@@ prova ' , risposta.data[0][key]);
							}

							console.log('@@@ arrayMeta ' , arrayMeta );

							component.set("v.mappatura", arrayMeta);
						//}
						//else{
							helper.prepopulateField(component, event, helper);
						//}
					}
					else{
						console.log('@@@ risposta not ok ' , risposta);
					}
				}
				else{
					console.log('@@@ response error ' , response.getError() );
				}
			});
			$A.enqueueAction(action);
		}
		else{
			var notaId = component.get("v.idNota");
			console.log('@@@ notaId ' , notaId);

			var recId = component.get("v.recordId");
			console.log('@@@ recId ' , recId);

			if(notaId == undefined || notaId == null || notaId == ''){
				component.find('recordLoader').getNewRecord('WGC_Nota_Documento__c', null, true, $A.getCallback((test) =>{
					console.log('@@@ loading test ' , test );

					console.log('@@@ record ' , JSON.stringify(component.get("v.notaRecord")));
				}));
			}

			component.set("v.isLoaded", true);
		}
	},

	//adione CR 293
	populateSoggettiPicklist : function(component, event, helper) {
		console.log('-----> WGC_FileUploader.helper - populateSoggettiPicklist - START');
		var soggArray = component.get("v.soggetti");
		component.set("v.soggettiPicklist", soggArray);
	},

	prepopulateField : function(component, event, helper){
		var docFisso = component.get("v.docFisso");
		console.log('@@@ docFisso ' , docFisso);

		console.log('@@@ datiDoc ' + component.get('v.datiDoc'));
		var codDoc = component.get("v.datiDoc");

		if(docFisso != null && docFisso != undefined && docFisso != ''){
			console.log('@@@ docFisso ' , docFisso);
			// switch (docFisso){
			// 	case "docPPG" :
			// 		if(codDoc == "SY0000074"){
			// 			//Setto la data
			// 			var arrayMeta = component.get("v.mappatura");
			// 			var arrayTipo = component.get("v.tipo");
			// 			var singleMeta = {};
			// 			singleMeta.famiglia = 'Documenti persona fisica';
			// 			singleMeta.documento = [];
			// 			var singleDoc = {};
			// 			singleDoc.Documento__c = 'SY0000074';
			// 			singleDoc.Sottoclasse__c = 'Documenti persona fisica';
			// 			singleDoc.MasterLabel = 'Documento di privacy';
			// 			singleMeta.documento.push(singleDoc);
			// 			arrayMeta.push(singleMeta);
			// 			arrayTipo.push(singleDoc);
	
			// 			component.set("v.mappatura", arrayMeta);
			// 			component.set("v.tipo", arrayTipo);
			// 			component.set("v.selectedF", singleMeta.famiglia);
			// 			component.set("v.selectedSC", singleDoc.Documento__c);

			// 			//Prepopolo le date ad un anno da oggi
			// 			var dataScad = new Date();
			// 			var dataProd = new Date();
			// 			var newYear = new Date().getFullYear() + 10;
			// 			dataScad.setFullYear(newYear);

			// 			dataScad = dataScad.toISOString();
			// 			dataProd = dataProd.toISOString();
						
			// 			dataScad = dataScad.substring(0, dataScad.indexOf('T'));
			// 			dataProd = dataProd.substring(0, dataProd.indexOf('T'));

			// 			component.find('dataprod').set("v.value", dataProd);
			// 			component.find('datascad').set("v.value", dataScad);
	
			// 			component.find('famiglia').set("v.disabled", true);
			// 			component.find('tipo').set("v.disabled", true);
			// 		}
			// 		else{
			// 			var arrayMeta = component.get("v.mappatura");
			// 			var arrayTipo = component.get("v.tipo");
			// 			var singleMeta = {};
			// 			singleMeta.famiglia = 'Identificazione clientela';
			// 			singleMeta.documento = [];
			// 			var singleDoc = {};
			// 			singleDoc.Documento__c = 'EX0000200';
			// 			singleDoc.Sottoclasse__c = 'Identificazione clientela';
			// 			singleDoc.MasterLabel = 'Scansione Privacy';
			// 			singleMeta.documento.push(singleDoc);
			// 			arrayMeta.push(singleMeta);
			// 			arrayTipo.push(singleDoc);

			// 			component.set("v.mappatura", arrayMeta);
			// 			component.set("v.tipo", arrayTipo);
			// 			component.set("v.selectedF", singleMeta.famiglia);
			// 			component.set("v.selectedSC", singleDoc.Documento__c);

			// 			//Prepopolo le date ad un anno da oggi
			// 			var dataScad = new Date();
			// 			var dataProd = new Date();
			// 			var newYear = new Date().getFullYear() + 10;
			// 			dataScad.setFullYear(newYear);

			// 			dataScad = dataScad.toISOString();
			// 			dataProd = dataProd.toISOString();
						
			// 			dataScad = dataScad.substring(0, dataScad.indexOf('T'));
			// 			dataProd = dataProd.substring(0, dataProd.indexOf('T'));

			// 			component.find('dataprod').set("v.value", dataProd);
			// 			component.find('datascad').set("v.value", dataScad);

			// 			component.find('famiglia').set("v.disabled", true);
			// 			component.find('tipo').set("v.disabled", true);
			// 		}
			// 		break;
			// 	case "docMAV" :
			// 		var arrayMeta = component.get("v.mappatura");
			// 		var arrayTipo = component.get("v.tipo");
			// 		var singleMeta = {};
			// 		singleMeta.famiglia = 'Identificazione clientela';
			// 		singleMeta.documento = [];
			// 		var singleDoc = {};
			// 		singleDoc.Documento__c = 'EX0000173';
			// 		singleDoc.Sottoclasse__c = 'Identificazione clientela';
			// 		singleDoc.MasterLabel = 'Modulo Adeguata Verifica';
			// 		singleMeta.documento.push(singleDoc);
			// 		arrayMeta.push(singleMeta);
			// 		arrayTipo.push(singleDoc);

			// 		component.set("v.mappatura", arrayMeta);
			// 		component.set("v.tipo", arrayTipo);
			// 		component.set("v.selectedF", singleMeta.famiglia);
			// 		component.set("v.selectedSC", singleDoc.Documento__c);

			// 		//Prepopolo le date ad un anno da oggi
			// 		var dataScad = new Date();
			// 		var dataProd = new Date();
			// 		var newYear = new Date().getFullYear() + 1;
			// 		dataScad.setFullYear(newYear);

			// 		dataScad = dataScad.toISOString();
			// 		dataProd = dataProd.toISOString();
					
			// 		dataScad = dataScad.substring(0, dataScad.indexOf('T'));
			// 		dataProd = dataProd.substring(0, dataProd.indexOf('T'));

			// 		component.find('dataprod').set("v.value", dataProd);
			// 		component.find('datascad').set("v.value", dataScad);

			// 		component.find('famiglia').set("v.disabled", true);
			// 		component.find('tipo').set("v.disabled", true);
			// 		break;
			// 	case "docMTC" : 
			// 		var arrayMeta = component.get("v.mappatura");
			// 		var arrayTipo = component.get("v.tipo");
			// 		var singleMeta = {};
			// 		singleMeta.famiglia = 'Identificazione clientela';
			// 		singleMeta.documento = [];
			// 		var singleDoc = {};
			// 		singleDoc.Documento__c = 'EX0000179';
			// 		singleDoc.Sottoclasse__c = 'Identificazione clientela';
			// 		singleDoc.MasterLabel = 'Modulo Tecniche di comunicazione';
			// 		singleMeta.documento.push(singleDoc);
			// 		arrayMeta.push(singleMeta);
			// 		arrayTipo.push(singleDoc);

			// 		component.set("v.mappatura", arrayMeta);
			// 		component.set("v.tipo", arrayTipo);
			// 		component.set("v.selectedF", singleMeta.famiglia);
			// 		component.set("v.selectedSC", singleDoc.Documento__c);

			// 		//Prepopolo le date ad un anno da oggi
			// 		var dataScad = new Date();
			// 		var dataProd = new Date();
			// 		var newYear = new Date().getFullYear() + 10;
			// 		dataScad.setFullYear(newYear);

			// 		dataScad = dataScad.toISOString();
			// 		dataProd = dataProd.toISOString();
					
			// 		dataScad = dataScad.substring(0, dataScad.indexOf('T'));
			// 		dataProd = dataProd.substring(0, dataProd.indexOf('T'));

			// 		component.find('dataprod').set("v.value", dataProd);
			// 		component.find('datascad').set("v.value", dataScad);

			// 		component.find('famiglia').set("v.disabled", true);
			// 		component.find('tipo').set("v.disabled", true);
			// 		break;

			// 	default :
			// 		//Prepopolo le date ad un anno da oggi
			// 		var dataScad = new Date();
			// 		var dataProd = new Date();
			// 		var newYear = new Date().getFullYear() + 10;
			// 		dataScad.setFullYear(newYear);

			// 		dataScad = dataScad.toISOString();
			// 		dataProd = dataProd.toISOString();
					
			// 		dataScad = dataScad.substring(0, dataScad.indexOf('T'));
			// 		dataProd = dataProd.substring(0, dataProd.indexOf('T'));

			// 		component.find('dataprod').set("v.value", dataProd);
			// 		component.find('datascad').set("v.value", dataScad);
			// 		this.mappingDocumenti(component, event, helper);
			// 		break;
			// }

			// var mapping = component.get("v.mappatura");
			// console.log('@@@ mapping ' , mapping);

			if(codDoc == 'SY0000002'){
				console.log('@@@ chiamata');
				this.getDatiCartaI(component, event, helper);
			} else {
				this.newMappingDoc(component, event, helper, false);
			}
		}
		// else if(docFisso == undefined && codDoc == 'NV0000002'){
		// 	var arrayMeta = component.get("v.mappatura");
		// 	var arrayTipo = component.get("v.tipo");
		// 	var singleMeta = {};
		// 	singleMeta.famiglia = 'Documenti finanziari';
		// 	singleMeta.documento = [];
		// 	var singleDoc = {};
		// 	singleDoc.Documento__c = 'NV0000002';
		// 	singleDoc.Sottoclasse__c = 'Documenti finanziari';
		// 	singleDoc.MasterLabel = 'RSF';
		// 	singleMeta.documento.push(singleDoc);
		// 	arrayMeta.push(singleMeta);
		// 	arrayTipo.push(singleDoc);

		// 	component.set("v.mappatura", arrayMeta);
		// 	component.set("v.tipo", arrayTipo);
		// 	component.set("v.selectedF", singleMeta.famiglia);
		// 	component.set("v.selectedSC", singleDoc.Documento__c);

		// 	//Prepopolo le date ad un anno da oggi
		// 	var dataScad = new Date();
		// 	var dataProd = new Date();
		// 	var newDay = new Date().getDay() + 30;
		// 	dataScad.setDate(newDay);

		// 	dataScad = dataScad.toISOString();
		// 	dataProd = dataProd.toISOString();
			
		// 	dataScad = dataScad.substring(0, dataScad.indexOf('T'));
		// 	dataProd = dataProd.substring(0, dataProd.indexOf('T'));

		// 	component.find('dataprod').set("v.value", dataProd);
		// 	component.find('datascad').set("v.value", dataScad);

		// 	component.find('famiglia').set("v.disabled", true);
		// 	component.find('tipo').set("v.disabled", true);
		// }
		else{
			//this.mappingDocumenti(component, event, helper);
			this.newMappingDoc(component, event, helper, false);
		}
	},

	mappingDocumenti : function(component, event, helper){
		//Carico tutte le mappature
		var mappatura = component.get("v.mappatura");
		var doc = component.get("v.datiDoc");

		mappatura.forEach((item, index) =>{
			for(var key in item){
				if(key == "documento"){
					item[key].forEach((rec, index) =>{
						console.log('@@@ ')
						if(rec.Documento__c == doc){
							component.set("v.tipo", item[key]);
							var famiglia = component.find('famiglia');
							component.set("v.selectedF", rec.Sottoclasse__c);
							Array.isArray(famiglia) ? famiglia[0].set("v.disabled", true) : famiglia.set("v.disabled", true);

							var sottoclasse = component.find('tipo');
							component.set("v.selectedSC", rec.Documento__c);
							Array.isArray(sottoclasse) ? sottoclasse[0].set("v.disabled", true) : sottoclasse.set("v.disabled", true);
						}
					});
				}
			}
		});
	},

	checkDataProduzioneHelper : function(component, event, helper){
		console.log('@@@ find dataprod ' , component.find("dataprod"));
		let dataprod = component.find("dataprod");
		console.log('@@@ prova ' , Array.isArray(dataprod));
		if(Array.isArray(dataprod))
			return dataprod[0].checkValidity();
		else{
			console.log('@@@ prova 2 ' , dataprod.checkValidity());
			return dataprod.checkValidity();
		}
		// return component.find("dataprod").checkValidity();
	},

	checkDataScadenzaHelper : function(component, event, helper){
		let datascad = component.find("datascad");
		if(Array.isArray(datascad))
			return datascad[0].checkValidity();
		else
			return datascad.checkValidity();
		// return component.find("datascad").checkValidity();
	},

	convalidaDati : function(component, event, helper, objectToValidate){
		var esito = true;		
		for(var key in objectToValidate){
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
	},

	// sendFile : function(component, event, helper, b){
	// 	console.log('@@@ tipo ' , typeof b);
	// 	var action = component.get("c.sendFileMultipart");
	// 	action.setParams({
	// 		"file" : b
	// 	});
	// 	action.setCallback(this, (response) =>{
	// 		if(response.getState() == "SUCCESS"){
	// 			console.log('@@@ response ' , response.getReturnValue());
	// 		}
	// 		else{
	// 			console.log('@@@ err ' , response.getError());
	// 		}
	// 	});

	// 	$A.enqueueAction(action);
	// },

	newMappingDoc : function(component, event, helper, needsChange){
		//Resetto alla situazione iniziale e ricalcolo poi
		(!needsChange && component.get("v.selectedSC") != 'SY0000002') ? component.set("v.dataProduzione", undefined) : '';
		component.set("v.dataScadenza", undefined);
		var datascad = component.find("datascad");
		// component.find('datascad').set("v.disabled", false);
		console.log('@@@ datascad ' , datascad);
		Array.isArray(datascad) ? datascad[0].set("v.disabled", false) : datascad.set("v.disabled", false);
		//Carico tutte le mappature
		var mappatura = component.get("v.mappatura");
		var doc = component.get("v.datiDoc");

		var bloccaDoc = component.get("v.bloccaDoc");

		mappatura.forEach((item, index) =>{
			for(var key in item){
				if(key == "documento"){
					item[key].forEach((rec, index) =>{
						if(rec.Documento__c == doc){
							component.set("v.tipo", item[key]);
							var famiglia = component.find('famiglia');
							component.set("v.selectedF", rec.Sottoclasse__c);
							
							console.log('@@@ famiglia ' , famiglia);
							console.log('@@@ bloccaDoc ' , bloccaDoc);
							if(!bloccaDoc)
								Array.isArray(famiglia) ? famiglia[famiglia.length - 1].set("v.disabled", true) : famiglia.set("v.disabled", true);

							var sottoclasse = component.find('tipo');
							component.set("v.selectedSC", rec.Documento__c);

							if(!bloccaDoc)
								Array.isArray(sottoclasse) ? sottoclasse[sottoclasse.length - 1].set("v.disabled", true) : sottoclasse.set("v.disabled", true);

							//Aggiunta nuovo requisito su prepopolamento date
							console.log('@@@ giorni ' , rec.Giorni_Data_Scadenza__c);
							
							if(rec.Giorni_Data_Scadenza__c != undefined){
								var dataScad = new Date();
								var dataProd = component.get("v.dataProduzione");
								console.log('@@@ dataProderita ', dataProd);
								console.log('@@@ dataProderita new Date ', dataProd != undefined ? new Date(dataProd).getDate() : 'data prod prepopolata');

								dataProd != undefined ? dataScad = dataProd : '';
								console.log('@@@ dataScad before addDays ' + dataScad );

								dataScad = new Date(dataScad);

								dataProd != undefined ? dataScad.setMonth(new Date(dataProd).getMonth() + rec.Giorni_Data_Scadenza__c) : dataScad.setMonth(new Date().getMonth() + rec.Giorni_Data_Scadenza__c);
								console.log('@@@ dataScad after addDays ' + dataScad );
								component.set("v.dataScadenza", dataScad.toISOString());
								Array.isArray(datascad) ? datascad[datascad.length - 1].set("v.disabled", true) : datascad.set("v.disabled", true);
							}
							else if(component.get("v.selectedSC") == 'SY0000002'){
								var dataS = new Date();
								var dataProd = component.get("v.dataProduzione");
								dataProd = new Date(dataProd);
								//component.set("v.dataProduzione", dataS.toISOString());
								dataProd.setMonth(dataProd.getMonth() + 12);
								component.set("v.dataScadenza", dataProd.toISOString());
							}
							else{
								// var dataScad = new Date();
								component.set("v.dataScadenza", undefined);
							}
							
							(rec.Data_documento_popolata__c && !needsChange && component.get("v.selectedSC") != 'SY0000002') ? component.set("v.dataProduzione", new Date().toISOString() ) : '';//component.set("v.dataProduzione", undefined );
							//rec.Data_documento_popolata__c ? component.find('dataprod').set("v.disabled", true) : undefined;
						}
					});
				}
			}
		});
	},

	getDatiCartaI : function(component, event, helper){
		var recId = component.get("v.recordId");
		var action = component.get("c.getDatiCI");
		action.setParams({
			"contactId" : recId
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				console.log('@@@ response ' , response.getReturnValue());

				var risposta = response.getReturnValue();

				if(risposta != null){
					// component.set("v.selectedF", 'Documenti persona fisica');
					// component.set("v.selectedSC", 'SY0000002');
					component.set("v.dataProduzione", risposta.DataEmissioneDoc__c);
					component.set("v.dataScadenza", risposta.DataScadenzaDoc__c);

					var arrayMeta = component.get("v.mappatura");
					var arrayTipo = component.get("v.tipo");
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

					component.set("v.mappatura", arrayMeta);
					component.set("v.tipo", arrayTipo);
					component.set("v.selectedF", singleMeta.famiglia);
					component.set("v.selectedSC", singleDoc.Documento__c);

					var famiglia = component.find('famiglia');
					Array.isArray(famiglia) ? famiglia[0].set("v.disabled", true) : famiglia.set("v.disabled", true);
					var sottoclasse = component.find('tipo');
					Array.isArray(sottoclasse) ? sottoclasse[0].set("v.disabled", true) : sottoclasse.set("v.disabled", true);
					
					//Disabilito la modifica delle date
					let datascad = component.find("datascad");
					Array.isArray(datascad) ? datascad[0].set("v.disabled", true) : datascad.set("v.disabled", true);
					//component.find('dataprod').set("v.disabled", true);
				}
				// else{

				// }
			}
			else{
				console.log('@@@ errore backend ' , response.getError());

				var arrayMeta = component.get("v.mappatura");
				var arrayTipo = component.get("v.tipo");
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

				component.set("v.mappatura", arrayMeta);
				component.set("v.tipo", arrayTipo);
				component.set("v.selectedF", singleMeta.famiglia);
				component.set("v.selectedSC", singleDoc.Documento__c);

				var famiglia = component.find('famiglia');
				Array.isArray(famiglia) ? famiglia[0].set("v.disabled", true) : famiglia.set("v.disabled", true);
				var sottoclasse = component.find('tipo');
				Array.isArray(sottoclasse) ? sottoclasse[0].set("v.disabled", true) : sottoclasse.set("v.disabled", true);
				
				//Disabilito la modifica delle date
				var dataS = new Date();
				component.set("v.dataProduzione", dataS.toISOString());
				dataS.setMonth(dataS.getMonth() + 120);
				component.set("v.dataScadenza", dataS.toISOString());
				var datascad = component.find("datascad");
				Array.isArray(datascad) ? datascad[0].set("v.disabled", true) : datascad.set("v.disabled", true);
			}
		});

		$A.enqueueAction(action);
	},

})