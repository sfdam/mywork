({
	
	initialize : function(component, event, helper){
		//Usato per prendere la reference quando il componente viene chiamato da il tab attività di filo diretto
		var pageReference = component.get("v.pageReference");
		console.log('@@@ pageRef ' , JSON.stringify(pageReference));
		if(pageReference != undefined || pageReference != null){
				console.log('@@@ taskId init ' , pageReference.state.c__taskId);
				console.log('@@@ rowData init ' , pageReference.state.c__rowData);
				
				component.set("v.taskId", pageReference.state.c__taskId);
				component.set("v.rowData", pageReference.state.c__rowData);
				
				//Setto i filtri della console
				component.set("v.CampaignFilter", pageReference.state.c__CampaignFilter);
				component.set("v.OwnerFilter", pageReference.state.c__OwnerFilter);
				component.set("v.OverdueFilter", pageReference.state.c__OverdueFilter);
				component.set("v.textToSearch", pageReference.state.c__textToSearch);
		}

		var taskId = component.get("v.taskId");

		this.callServer(component, "c.getTaskData", function(result){
			console.log('@@@ result ' , result);
			if(result != null && result != undefined){
				component.set("v.rowData", result);
                component.set("v.tsk.Description", result.Description);
                //component.set("v.tsk", result);
				//component.set("v.rowData", result.Campagna__c);
				//Funzione per recuperare info sulle picklist di esito
				helper.getPicklistValues(component, event, helper, taskId);
				component.set("v.tsk.TipoAttivita__c", "Sviluppo Diretto");
                component.set("v.selectedSubject", result.Subject);
			}
		}, { "taskId" : taskId });

		var action = component.get("c.getContactInformation");
		action.setParams({
				"taskId" : taskId
		});
		action.setCallback(this, function(response){
				if(response.getState() == "SUCCESS"){
						if(response.getReturnValue() != null || response.getReturnValue() != undefined){
								component.set("v.ContactRecord", response.getReturnValue());
						}
						component.set("v.isLoaded", true);
				}
				else{
						var toast = $A.get("e.force:showToast");
						toast.setParams({
								"title" : "ERRORE",
								"type" : "ERROR",
								"message" : "Errore durante il caricamento dei dati"
						});
						toast.fire();
				}
		});
		$A.enqueueAction(action);

		console.log('@@@ test deploy ' , component.get("v.recordLoadError"));
		console.log('@@@ test deploy ' , component.get("v.taskRecord.Subject"));

	},
	getPicklistValues : function(component, event, helper, taskId) {
		var action = component.get("c.getPicklistValues");
		var rowData = component.get("v.rowData");
		console.log('@@@ rowData ' , JSON.stringify(rowData));
		action.setParams({
			"rtId" : rowData.RecordTypeId
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				let risposta = response.getReturnValue();
				let rispostaJSON = JSON.parse(risposta);
				console.log('@@@ json filo diretto ' , rispostaJSON);
				var arrayPicklist = [];
				//Prendo il parametro da cui estraggo i dati delle picklist
				let layoutInfo = rispostaJSON.detailLayoutSections;
				//itero per ogni info del layout
				for(var key in layoutInfo){
					let layoutSection = layoutInfo[key];
					//Per ogni sezione del layout se la sezione è una layoutRows
					//Ciclo poi tutte le righe del layout e cerco i campi picklist esito
					//Per ogni campo picklist trovato mi recupero il nome del campo, il nome del campo controllante e la lista di possibili valori
					for(var key2 in layoutSection){
						if(key2 == 'layoutRows'){
							let layoutItems = layoutSection[key2];
							for(var key3 in layoutItems){
								let layoutArrayItem = layoutItems[key3].layoutItems;
								for(var key4 in layoutArrayItem){
									let listaCampi = layoutArrayItem[key4];
                                    console.log('@@@ listaCampi ' , listaCampi);
									if(listaCampi.label.includes('Esito Livello') || listaCampi.label.includes('outcome')){
										var arrayComponents = listaCampi.layoutComponents[0].details;
										var controllingField = arrayComponents.controllerName;
										var actualField = arrayComponents.name;
										var picklistValues = arrayComponents.picklistValues;
										//Creo un wrapper per ogni campo picklist
										var wrapper = {};
										wrapper.controllingField = controllingField;
										wrapper.fieldName = actualField;
										wrapper.picklistValues = picklistValues;
										//Aggiungo alla lista di picklist values
										arrayPicklist.push(wrapper);
									}
									else if(listaCampi.label.includes('Tipo Attivit') || listaCampi.label.includes('Type of activity')){
										var arrayComponents = listaCampi.layoutComponents[0].details;
										var controllingField = arrayComponents.controllerName;
										var actualField = arrayComponents.name;
										var picklistValues = arrayComponents.picklistValues;
										//Creo un wrapper per ogni campo picklist
										var wrapper = {};
										wrapper.controllingField = controllingField;
										wrapper.fieldName = actualField;
										wrapper.picklistValues = picklistValues;

										console.log('@@@ wrapper ' , JSON.stringify(wrapper));

										component.set("v.tipoAtt", picklistValues);
										//Aggiungo alla lista di picklist values
										arrayPicklist.push(wrapper);
									}
								}
							}
						}
					}
				}
			for(var key in arrayPicklist){
				if(arrayPicklist[key].fieldName != 'TipoAttivita__c'){
					component.set("v.picklist"+key, arrayPicklist[key].picklistValues);
				}
			}
            console.log('@@@ picklist first ' , arrayPicklist);
			component.set("v.PicklistContainer" , arrayPicklist);
			//Setto attributo a false per abilitare la seconda picklist dato che prepopolo con valore "sviluppo diretto" la picklist tipo attivita
			// component.set("v.picklist0disabled", false);
			helper.getDependentValue(component, event, helper, "TipoAttivita", "Sviluppo Diretto");
			}
			else if(response.getState() == "ERROR"){
				var toast = $A.get("e.force:showToast");
				toast.setParams({
					"title" : "ERRORE",
					"message" : "Errore, provare a ricaricare la pagina"
				});
				toast.fire();
			}
		});
		$A.enqueueAction(action);
	},

    checkCalendario : function(component, event, helper, visita){
		console.log('@@@ visita ' , JSON.stringify(visita));

		var calendario = component.get("v.calendar");
		
		console.log('@@@ calendario ' , calendario);

		var occupato = false;

		if(calendario != null && calendario != undefined && calendario.length > 0){
			calendario.forEach((item, index) =>{
				if(visita.OwnerId == item.sviluppatore.Id){
					console.log('@@@ trovato owner ' );
					item.agenda.forEach((itemAgenda, index) =>{
						var endDate = visita.EndDateTime;
						endDate = new Date(endDate);
						var endHour = endDate.getHours();
						console.log('@@@ endHour ' , endHour);
						
						//
						var startDate = visita.StartDateTime;
						startDate = new Date(startDate);
						var startHour = startDate.getHours();


						if((itemAgenda.oraFine == endHour && !itemAgenda.available) || 
							(itemAgenda.oraInizio == startHour && !itemAgenda.available)){
								console.log('@@@ prova ' , itemAgenda);
								console.log('@@@ già impegnato');
								occupato = true;
						}
						else{
							console.log('@@@ free ' );
							occupato = false;
						}
					});
				}
			});
	}

		console.log('@@@ occupato ' , occupato);
		return occupato;

	},

	esitaTaskHelp : function(component, event, helper, task){
		component.set("v.isLoaded", false);
		//utilizzo il parametro task per recuperare l'oggetto
		
		if(!task.Campagna__r){
			delete task['Campagna__r'];
			delete task['Campagna__c'];
		}
        
		console.log('@@@ task ' , JSON.stringify(task));
		var action = component.get("c.saveTask");
		action.setParams({
			objTask : task
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				component.set("v.isLoaded", true);

				var risposta = response.getReturnValue();
				console.log('@@@ risposta ' , risposta);

				if(risposta.success){
					var toast = $A.get("e.force:showToast");
					toast.setParams({
						"title" : "TASK ESITATO",
						"type" : "SUCCESS",
						"message" : "Task esitato con successo"
					});
					toast.fire();
					
					var navigator = component.find("navService");
        
					var pg = {
							"type": "standard__navItemPage",
							"attributes": {
								"apiName": "WGC_Attivit_Filo_Diretto"
							}
					};
			
					navigator.navigate(pg);
				}
				else{
					var toast = $A.get("e.force:showToast");
					toast.setParams({
						"title" : "ERRORE",
						"type" : "ERROR",
						"message" : risposta.message
					});
					toast.fire();
				}
				
				//

			}
			else{
                console.log('@@@ error ' , response.getError());
				var toast = $A.get("e.force:showToast");
				toast.setParams({
					"title" : "ERRORE",
					"type" : "ERROR",
					"message" : "Errore durante il salvataggio, ricaricare la pagina e riprovare"
				});
				toast.fire();
			}
		});
		$A.enqueueAction(action);
	},

	onChangePickValue : function(component, event, helper){
		//Prendo il valore e il nome della picklist modificata
		var source = event.getSource().get("v.value");
		var sourceName = event.getSource().get("v.name");

		console.log('@@@ source ' , source);

		var task = component.get("v.tsk");
		/*
		if(source.toLowerCase() == ('TipoAttivita').toLowerCase()){
			task.TipoAttivita__c = source;
		}
		*/
		component.set("v.dataricontattodisabled" , false);
		if(source == 'Contatto in corso/Da risentire')
		{
			component.set("v.dataricontattodisabled" , true);
			//component.find("dataRicHelpBlock").get("v.rendered").set("true");
		}
		task[sourceName+'__c'] = source;
		//task.EsitoLivello1__c = source;
		component.set("v.tsk", task);
		//Funzione per recuperare le dipendenze
		helper.getDependentValue(component, event, helper, sourceName, source);
	},

	getUserByComune : function(component, event, helper, accId, newValue){
		var action = component.get("c.getAssegnatari");

		console.log('@@@ accId ' , accId);
		console.log('@@@ newValue ' , newValue);

		action.setParams({
			accountId : accId,
			comuneId : newValue
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				console.log('@@@ response.getReturnValue() ' , response.getReturnValue());
				component.set("v.assegnatari" , response.getReturnValue());
				//Costruisco una mappa di oggetti per gestire le optiongroup e le option corrispondenti
				var mappaUtenti = [];
				var risposta = response.getReturnValue();
				for(var key in risposta){
					var helperArray = [];
					for(var element in risposta[key]){
						helperArray.push(risposta[key][element]);
					}
					mappaUtenti.push({gruppo : key , valori : helperArray});
				}
				
				console.log('@@@ mappaUtenti ' , mappaUtenti);
				component.set("v.assegnatari" , mappaUtenti);
				component.set("v.isActiveComune" , false);
				component.set("v.isValidComune" , true);

				
				var endDate = component.get("v.visita.EndDateTime");
				console.log('@@@ endDate ' , endDate);
				//Se non è vuota la data utilizzo il metodo per recuperare le visite nella data specificata
				if(endDate != null){
					//Metodo che recupera le visite in base agli assegnatari
					helper.getVisiteByUser(component, event, helper);
				}
				
				if(response.getReturnValue() == null){
					component.set("v.isActiveComune" , true);
					component.set("v.isValidComune" , false);
				}
			}
			else{
				var toast = $A.get("e.force:showToast");
				toast.setParams({
					"title" : "ERRORE",
					"type" : "ERROR",
					"message" : "Errore nel caricamento degli assegnatari, ricaricare la pagina"
				});
				toast.fire();
			}
		});
		$A.enqueueAction(action);
	},

	//Metodo che recupera le visite in base agli assegnatari del comune selezionato e in base alla data/ora di fine visita
	getVisiteByUser : function(component, event, helper){
		var dataFine = component.get("v.visita.EndDateTime");
		var mappaUtenti = component.get("v.assegnatari");
		var arrayUtenti = [];
		for(var key in mappaUtenti){
			for(var key2 in mappaUtenti[key].valori){
				arrayUtenti.push(mappaUtenti[key].valori[key2]);
			}
		}
		
		console.log('@@@ utenti ' , arrayUtenti);
		arrayUtenti.forEach((item, index) =>{
			var id = item.Id;

			arrayUtenti.forEach((item, index) =>{
				if(id == item.Id){
					arrayUtenti.splice(index, 1);
				}
			});
		});
		console.log('@@@ dataFine ' , dataFine);
		console.log('@@@ utenti ' , arrayUtenti);

		var action = component.get("c.getVisite");
		action.setParams({
			EndDate : dataFine,
			utenti : JSON.stringify(arrayUtenti)
		});
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				var calendar = [];
				var risposta = response.getReturnValue();
				console.log('@@@ risposta ' , risposta);
				component.set("v.visiteC", risposta);
				for(var key in arrayUtenti){
					var agenda = [];
					//Creo il calendario fittizio
					for(var i = 6 ; i < 20; i++){
						agenda.push({evento: null, oraInizio: i, oraFine: i+1, available: true});
					}
					//Prendo lo sviluppatore
					var sviluppatore = arrayUtenti[key];
					for(var key2 in risposta){
						//Se l'owner dell'evento è lo sviluppatore preso in esame prima, aggiorno il calendario inserendo gli eventi attuali
						if(risposta[key2].OwnerId == sviluppatore.Id){
							var indexStart = risposta[key2].StartDateTime.indexOf('T');
							var onlyHourStart = risposta[key2].StartDateTime.substring(indexStart+1, indexStart+3);
							var indexEnd = risposta[key2].EndDateTime.indexOf('T');
							var onlyHourEnd = risposta[key2].EndDateTime.substring(indexEnd+1, indexEnd+3);
							for(var key3 in agenda){
								if(agenda[key3].oraInizio <= onlyHourStart && agenda[key3].oraFine >= onlyHourEnd){
									console.log('@@@ ho un impegno');
									agenda[key3].available = false;
									agenda[key3].evento = risposta[key2].Subject;
								}
							}
						}
					}
					calendar.push({sviluppatore : sviluppatore , agenda : agenda});
				}
				console.log('@@@ calendario ' , calendar);

				component.set("v.calendar" , calendar);
			}
			else{
				var toast = $A.get("e.force:showToast");
				toast.setParams({
					"title" : "ERRORE",
					"type" : "ERROR",
					"message" : "Errore nel caricamento delle visite, ricaricare la pagina"
				});
				toast.fire();
			}
		});
		$A.enqueueAction(action);
	},

	getDependentValue : function(component, event, helper, sourceName, value){

		console.log('@@@ sourceName ' , sourceName);
		console.log('@@@ value ' , value);
        console.log('@@@ picklist ' , component.get("v.PicklistContainer"));

		if(sourceName == 'TipoAttivita'){
			var arr = [];
			var valoriControllanti = component.get("v.PicklistContainer")[0].picklistValues;
			var valoriDipendenti = component.get("v.PicklistContainer")[1].picklistValues;

			for(var key in valoriDipendenti){
				if(valoriDipendenti[key] !== undefined){

					var validFor = valoriDipendenti[key].validFor;

					//Converto il campo validFor in bit
					var output = validFor.split('').map(function (char) {
						return char.charCodeAt(0).toString(2);
					}).join(' ');
					
					//Aggiungo un indice
					var l = (output.length + 1);

					//Itero ogni bit che verrà verificato dalla funzione testBit
					for(var i = 0; i < l ; i++){
						//Funzione utilizzata per trovare la corrispondenza

						function testBit(bitmap, index) {
							// Given an 8-bit binary string, get the index / 8 character,
							// And convert the index % 8 bit to true or false
							return !!(bitmap.charCodeAt(index >> 3) & (128 >> (index % 8)));
						}

						//Dato il valore controllante e la possibile lista di valori, e la lista di valori controllanti
						//trovo i valori corrispondenti
						function getValidPicklistValues(controlValue, dependentListValues, controllingValues) {
                            console.log('@@@ control value ' , controlValue);
							console.log('@@@ dependentListValues ' , dependentListValues);
							console.log('@@@ controllingValues ' , controllingValues);
							// Figure out the index of the controlValue
							var index = controllingValues.indexOf(controllingValues.find(
								function(item) { return controlValue === item.value; }
							));
							// Return a list of matching options given the control value
							console.log('@@@ index ' , index);
							return dependentListValues.filter(function(item) {
								// atob is base64-decoding.
								console.log('@@@ aaa ' , testBit(atob(item.validFor), index) );
								return testBit(atob(item.validFor), index);
							});
						}

						var getValidValue = getValidPicklistValues(value, valoriDipendenti, valoriControllanti);
                        console.log('@@@ getValidValue ' , getValidValue);
					}
				}
			}
			for(var key2 in getValidValue){
				arr.push(getValidValue[key2]);
			}
			//component.set('v.PicklistContainer', arr);
			console.log('@@@ arr ' , arr);
			if(arr.length > 0){
				component.set('v.picklist0', arr);
				component.set('v.picklist0disabled ' , false);
				component.set("v.picklist1disabled" , true);
				component.set("v.picklist2disabled" , true);
				component.set("v.picklist3disabled" , true);
			}
			else{
				component.set('v.picklist0', []);
				component.set('v.picklist0disabled', true);
				component.set("v.picklist1disabled" , true);
				component.set("v.picklist2disabled" , true);
				component.set("v.picklist3disabled" , true);
			}
		}
		if(sourceName == 'EsitoLivello1'){
			var arr = [];
			var valoriControllanti = component.get("v.PicklistContainer")[1].picklistValues;
			var valoriDipendenti = component.get("v.PicklistContainer")[2].picklistValues;

			for(var key in valoriDipendenti){
				if(valoriDipendenti[key] !== undefined){

					var validFor = valoriDipendenti[key].validFor;

					//Converto il campo validFor in bit
					var output = validFor.split('').map(function (char) {
						return char.charCodeAt(0).toString(2);
					}).join(' ');
					
					//Aggiungo un indice
					var l = (output.length + 1);

					//Itero ogni bit che verrà verificato dalla funzione testBit
					for(var i = 0; i < l ; i++){
						//Funzione utilizzata per trovare la corrispondenza

						function testBit(bitmap, index) {
							// Given an 8-bit binary string, get the index / 8 character,
							// And convert the index % 8 bit to true or false
							return !!(bitmap.charCodeAt(index >> 3) & (128 >> (index % 8)));
						}

						//Dato il valore controllante e la possibile lista di valori, e la lista di valori controllanti
						//trovo i valori corrispondenti
						function getValidPicklistValues(controlValue, dependentListValues, controllingValues) {
							// Figure out the index of the controlValue
							var index = controllingValues.indexOf(controllingValues.find(
								function(item) { return controlValue === item.value; }
							));
							// Return a list of matching options given the control value
							return dependentListValues.filter(function(item) {
								// atob is base64-decoding.
								return testBit(atob(item.validFor), index);
							});
						}

						var getValidValue = getValidPicklistValues(value, valoriDipendenti, valoriControllanti);
					}
				}
			}
			for(var key2 in getValidValue){
				arr.push(getValidValue[key2]);
			}
			//component.set('v.PicklistContainer', arr);
			if(arr.length > 0){
				component.set('v.picklist1', arr);
				component.set('v.picklist1disabled ' , false);
				component.set("v.picklist2disabled" , true);
				component.set("v.picklist3disabled" , true);
				component.set("v.picklist4disabled" , true);
			}
			else{
				component.set('v.picklist1', []);
				component.set('v.picklist1disabled', true);
				component.set("v.picklist2disabled" , true);
				component.set("v.picklist3disabled" , true);
				component.set("v.picklist4disabled" , true);
			}
		}
		/*
		else if(sourceName == 'EsitoLivello2'){
			var arr = [];
			var valoriControllanti = component.get("v.PicklistContainer")[2].picklistValues;
			var valoriDipendenti = component.get("v.PicklistContainer")[3].picklistValues;

			for(var key in valoriDipendenti){
				if(valoriDipendenti[key] !== undefined){
					var validFor = valoriDipendenti[key].validFor;

					//Converto il campo validFor in bit
					var output = validFor.split('').map(function (char) {
						return char.charCodeAt(0).toString(2);
					}).join(' ');

					//Aggiungo un indice
					var l = (output.length + 1);

					//Itero ogni bit che verrà verificato dalla funzione testBit
					for(var i = 0; i < l ; i++){
						//Funzione utilizzata per trovare la corrispondenza

						function testBit(bitmap, index) {
							// Given an 8-bit binary string, get the index / 8 character,
							// And convert the index % 8 bit to true or false
							return !!(bitmap.charCodeAt(index >> 3) & (128 >> (index % 8)));
						}

						//Dato il valore controllante e la possibile lista di valori, e la lista di valori controllanti
						//trovo i valori corrispondenti
						function getValidPicklistValues(controlValue, dependentListValues, controllingValues) {
							// Figure out the index of the controlValue
							var index = controllingValues.indexOf(controllingValues.find(
								function(item) { return controlValue === item.value; }
							));
							// Return a list of matching options given the control value
							return dependentListValues.filter(function(item) {
								// atob is base64-decoding.
								return testBit(atob(item.validFor), index);
							});
						}

						var getValidValue = getValidPicklistValues(value, valoriDipendenti, valoriControllanti);

					}
				}
			}
			for(var key2 in getValidValue){
				arr.push(getValidValue[key2]);
			}
			//Se ho valori dipendenti abilito la picklist successiva
			if(arr.length > 0){
				component.set('v.picklist2', arr);
				component.set('v.picklist2disabled' , false);		
				component.set("v.picklist3disabled", true);
				component.set("v.picklist4disabled" , true);
			}
			else{
				//se non ho valori dipendenti devo impostare le picklist vuote e disabilitare i campi picklist
				component.set("v.picklist2", []);
				component.set("v.picklist2disabled", true);
				component.set("v.picklist3disabled", true);
				component.set("v.picklist4disabled" , true);
			}
		}
		else if(sourceName == 'EsitoLivello3'){
			var arr = [];
			var valoriControllanti = component.get("v.PicklistContainer")[2].picklistValues;
			var valoriDipendenti = component.get("v.PicklistContainer")[3].picklistValues;

			for(var key in valoriDipendenti){
				var validFor = valoriDipendenti[key].validFor;

				//Converto il campo validFor in bit
				var output = validFor.split('').map(function (char) {
					return char.charCodeAt(0).toString(2);
				}).join(' ');

				//Aggiungo un indice
				var l = (output.length + 1);

				//Itero ogni bit che verrà verificato dalla funzione testBit
				for(var i = 0; i < l ; i++){
					//Funzione utilizzata per trovare la corrispondenza

					function testBit(bitmap, index) {
						// Given an 8-bit binary string, get the index / 8 character,
						// And convert the index % 8 bit to true or false
						return !!(bitmap.charCodeAt(index >> 3) & (128 >> (index % 8)));
					}

					//Dato il valore controllante e la possibile lista di valori, e la lista di valori controllanti
					//trovo i valori corrispondenti
					function getValidPicklistValues(controlValue, dependentListValues, controllingValues) {
						// Figure out the index of the controlValue
						var index = controllingValues.indexOf(controllingValues.find(
							function(item) { return controlValue === item.value; }
						));
						// Return a list of matching options given the control value
						return dependentListValues.filter(function(item) {
							// atob is base64-decoding.
							return testBit(atob(item.validFor), index);
						});
					}

					var getValidValue = getValidPicklistValues(value, valoriDipendenti, valoriControllanti);

				}
			}
			for(var key2 in getValidValue){
				arr.push(getValidValue[key2]);
			}

			//Se ho valori dipendenti li imposto e abilito la picklist
			if(arr.length > 0){
				component.set('v.picklist3', arr);
				component.set('v.picklist3disabled ' , false);
			}
		}
		else if(sourceName == 'EsitoLivello4'){
			var arr = [];
			var valoriControllanti = component.get("v.PicklistContainer")[3].picklistValues;
			var valoriDipendenti = component.get("v.PicklistContainer")[4].picklistValues;

			for(var key in valoriDipendenti){
				var validFor = valoriDipendenti[key].validFor;

				//Converto il campo validFor in bit
				var output = validFor.split('').map(function (char) {
					return char.charCodeAt(0).toString(2);
				}).join(' ');

				//Aggiungo un indice
				var l = (output.length + 1);

				//Itero ogni bit che verrà verificato dalla funzione testBit
				for(var i = 0; i < l ; i++){
					//Funzione utilizzata per trovare la corrispondenza

					function testBit(bitmap, index) {
						// Given an 8-bit binary string, get the index / 8 character,
						// And convert the index % 8 bit to true or false
						return !!(bitmap.charCodeAt(index >> 3) & (128 >> (index % 8)));
					}

					//Dato il valore controllante e la possibile lista di valori, e la lista di valori controllanti
					//trovo i valori corrispondenti
					function getValidPicklistValues(controlValue, dependentListValues, controllingValues) {
						// Figure out the index of the controlValue
						var index = controllingValues.indexOf(controllingValues.find(
							function(item) { return controlValue === item.value; }
						));
						// Return a list of matching options given the control value
						return dependentListValues.filter(function(item) {
							// atob is base64-decoding.
							return testBit(atob(item.validFor), index);
						});
					}

					var getValidValue = getValidPicklistValues(value, valoriDipendenti, valoriControllanti);
				}
			}
			for(var key2 in getValidValue){
				arr.push(getValidValue[key2]);
			}

			//Se ho valori dipendenti li imposto e abilito la picklist
			if(arr.length > 0){
				component.set('v.picklist4', arr);
				component.set('v.picklist4disabled ' , false);
			}
		}
		else if(sourceName == 'EsitoLivello5'){
			
		}
		*/
	}
})