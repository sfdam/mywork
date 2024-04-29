({
	generaXmlWithPromise: function (component, event) {
        console.log('START STAMPA');
        //Recupero dati preliminari
        let helper = this;
        let metadatiStampa = component.get('v.metadatiStampa');
        console.log("DK metadatiStampa: " , metadatiStampa);
        let getFullMetadataFromSelected = helper.apex(component, event, "getFullMetadataFromSelected", { "selectedSections": metadatiStampa, "obj": "Account", "recordTypeDeveloperName": component.get('v.recordTypeDeveloperName')});
        return getFullMetadataFromSelected
        .then($A.getCallback(function(resultFullMetadata){
            console.log("DK resultFullMetadata: " , resultFullMetadata);
            component.set('v.fullMetadata', resultFullMetadata);
            let accountData = component.get('v.accountData');
            try {
                let getRootXML = helper.apex(component, event, "getRootXML", { "selectedSections": resultFullMetadata, "currentAccount": accountData});
                //Recupero root xml
                return getRootXML
                .then($A.getCallback(function(result){
                    console.log('result', result);
                    if(result){                   
                        console.log('START GETROOTXML')
                        component.set('v.rootXml', result);
                        let fullMetadata = component.get('v.fullMetadata');
                        if(fullMetadata && fullMetadata.length > 0){
                            var promiseArray =[];
                            component.set('v.selectedSezioni', {});
                            let selectedSezioni = {};
                            let filteredValue = component.get('v.allDataChoiseValue');

                            console.log('DK allDataChoiseValue: ', JSON.stringify(filteredValue));
                            /*let filteredValueMap = {};
                            filteredValue.forEach(record =>{
                                if(!filteredValueMap[record.ObjectType]){
                                    filteredValueMap[record.ObjectType] = [];
                                }
                                filteredValueMap[record.ObjectType].push(record);
                            });*/

                            let filteredValueMap = {};
                            filteredValue.forEach(record =>{
                                filteredValueMap[record.Id] = record.ObjectType;
                            });
                            console.log('DK filteredValueMap: ', filteredValueMap);
                            
                            for(var i = 0; i < fullMetadata.length; i++){
                                var m = fullMetadata[i];
                                //Popolo la lista delle sezioni
                                if(!m.COMPONENT__c && m.isActive__c && !m.isRoot__c){
                                    selectedSezioni[m.SECTION__c] =  m.baseXml__c;
                                }
                                if(m.SECTION__c && m.COMPONENT__c && m.isActive__c && !m.isRoot__c){
                                    
                                    console.log('DK meta: ', m);
                                    promiseArray.push(helper.apex(component, event, 'getXMLFromMethods4Promise', { "meta": m, currentAccount: accountData, "recordList" : filteredValue, "recordObjectTypeMap": filteredValueMap}));
                                }
                            }
                            console.log('DK selectedSezioni: ', selectedSezioni);
                            component.set('v.selectedSezioni', selectedSezioni);
        
                            //Lancio le promise per avere i dati dei vari componenti
                            return Promise.all(promiseArray)
                            .then((resultAllPromise) => {
                                //Unisco i dati e restituisco l'xml
                                console.log('DK resultAllPromise: ' + JSON.stringify(resultAllPromise));
                                let selectedSezioni = component.get('v.selectedSezioni');
                                if(resultAllPromise && selectedSezioni && Object.keys(selectedSezioni)){
                                    //debugger;
                                    var mappaSezioni = selectedSezioni;
                                    console.log('DK mappaSezioni START: ', mappaSezioni);
                                    for(var i = 0; i < Object.keys(mappaSezioni).length; i++){
                                        var k = Object.keys(mappaSezioni)[i];
        
                                        console.log('DK mappaSezioni k: ', k);
                                        //Compongo l'xml da sostituire nella lista dei componenti
                                        var xmlComponenti = '';
                                        for(var j = 0; j < resultAllPromise.length; j++){
                                            xmlComponenti += resultAllPromise[j][k] ? resultAllPromise[j][k] : ''; 
                                        }
        
                                        //Sostituisco nell'xml della sezione l'xml composto precedentemente con la lista dei componenti
                                        mappaSezioni[k] = mappaSezioni[k].replace(component.get('v.PLACEHOLDER_COMPONENTI'),xmlComponenti);
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
                                    let rootXML = component.get('v.rootXml');
                                    component.set('v.xml', rootXML.replace(component.get('v.PLACEHOLDER_SEZIONI'), xmlSezioni));
                                    console.log('DK xml: ', component.get('v.xml'));
                                    helper.executeCall(component, event);
                                }
                            })
                            .catch(error => {
                                console.warn(error);
                            });
                        }
                    }
                }));
            } catch (error) {
                console.warn(error);
            }
        }));
        
    },   
    
    executeCall: function (component, event) {
    
        //helper.showSpinner = true;
        try {
            
            let helper = this;
            console.log('START executeCall');
            let accountData = component.get('v.accountData');
            let executeCall = helper.apex(component, event, 'executeCall', { 'xml': component.get('v.xml'), 'currentAccount': accountData, 'recordTypeDeveloperName': component.get('v.recordTypeDeveloperName')});
            executeCall
            .then($A.getCallback(function(data){
        
                // helper.showSpinner = false;
                console.log('PDF', data);
                if(data != null){
        
                    const timeElapsed = Date.now();
                    const today = new Date(timeElapsed);
                    const linkSource = `data:application/pdf;base64,${data}`;
                    const downloadLink = document.createElement("a");
                    let account = component.get('v.accountData');
                    const fileName = account.CRM_NDG__c + "_" + today.toLocaleDateString() + ".pdf";
        
                    downloadLink.href = linkSource;
                    downloadLink.download = fileName;
                    downloadLink.click();
                    // helper.showToastMessage('PDF GENERATO CORRETTAMENTE', 'success');
                    // helper.closeModal();
                }else{
                    // helper.showToastMessage('UNEXPECTED ERROR', 'error');
                    console.log('DK executeCall.error', 'NO DATA RETURNED');
                }
            })).catch($A.getCallback(function(error){
                // helper.showSpinner = false;
                console.log('DK executeCall.error', error);
            }));
        } catch (error) {
            
            console.warn(error);
        }
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

	fetchPickListValObject: function (component, elementId) {
        let allValues = JSON.parse(component.get('v.objectList'));
        console.log(allValues);
        let opts = [];

        for (var k in allValues) {
            let label = allValues[k].label;
            let value = allValues[k].object;
            opts.push({
                class: "optionClass",
                label: label,
                value: value,
            });
		}
        console.log(opts);
	
        component.set("v." + elementId, opts);
    },

    // fetchPickListVal: function (component, fieldName, object, elementId) {
    //     var action = component.get("c.getselectOptions");
    //     action.setParams({
    //         "objObject": object,
    //         "fld": fieldName
    //     });
    //     var opts = [];
    //     action.setCallback(this, function (response) {
    //         if (response.getState() == "SUCCESS") {
    //             var allValues = response.getReturnValue();
    //             console.log(allValues);

    //             // opts.push({
    //             //     class: "optionClass",
    //             //     label: "All",
    //             //     value: "all"
    //             // });

    //             for (var k in allValues) {
    //                 opts.push({
    //                     class: "optionClass",
    //                     label: k,
    //                     value: allValues[k],
    //                 });
	// 			}
				
    //             component.set("v." + elementId, opts);
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },

    // dataProcess: function (component, event, data) {
    //     var choiseObj = component.get('v.choiseObj');
    //     var elementList = [];
    //     if(choiseObj.attivita == 'all' || choiseObj.attivita == 'visite' || choiseObj.attivita == 'taskevisite'){
    //         data.forEach(function (element) {
              
    //             if(choiseObj.userQualifica == 'all' || choiseObj.userQualifica == element.WGC_Qualifica_Utente_Owner__c){
    //                 element.objectType = 'Event';

    //                 if(component.get("v.isModalFull") && element.Description!=undefined)
    //                     	element.isCollapsed = false;
    //                     else
    //                         element.isCollapsed = true;
    //                 //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
    //                 elementList.push(element);
    //             }
    //         });
    //     }
    //     if(choiseObj.attivita != 'visite'){
    //         data.forEach(function (element) {
    //             if(choiseObj.userQualifica == 'all' || choiseObj.userQualifica == element.WGC_Qualifica_Utente_Owner__c){

    //                 if(choiseObj.attivita == 'diario_Opportunita' && element.TipoAttivita__c=='Opportunity'){
    //                     console.log('Inside diario opt');
    //                     element.objectType = 'Diario';
    //                     if(component.get("v.isModalFull") && element.Description!=undefined)
    //                     	element.isCollapsed = false;
    //                     else
    //                         element.isCollapsed = true;
    //                     //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
    //                     elementList.push(element);
    //                 } else if(choiseObj.attivita == 'diario_Campagna' && element.TipoAttivita__c=='Campaign'){
    //                     element.objectType = 'Diario';
    //                     if(component.get("v.isModalFull") && element.Description!=undefined)
    //                     	element.isCollapsed = false;
    //                     else
    //                         element.isCollapsed = true;
    //                     //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
    //                     elementList.push(element);
    //                 } else if(choiseObj.attivita == 'promemoria' && element.TipoAttivita__c=='Case'){
    //                     element.objectType = 'Promemoria';
    //                     if(component.get("v.isModalFull") && element.Description!=undefined)
    //                     	element.isCollapsed = false;
    //                     else
    //                         element.isCollapsed = true;
    //                     //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
    //                     elementList.push(element);
    //                 } 
    //                 else if((choiseObj.attivita == 'task' || choiseObj.attivita == 'tasdataProcesskevisite') && element.TipoAttivita__c==undefined){
    //                     element.objectType = 'Task';
    //                     if(component.get("v.isModalFull"))
    //                         element.isCollapsed = true;
    //                     else
    //                         element.isCollapsed = false;
    //                     //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
    //                     elementList.push(element);
    //                 }
    //                 else if(choiseObj.attivita == 'event'){
    //                     element.objectType = 'Event';
    //                     if(component.get("v.isModalFull"))
    //                     	element.isCollapsed = true;
    //                     else
    //                         element.isCollapsed = false;
    //                     //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
    //                     elementList.push(element);
    //                 }
    //                 else if(choiseObj.attivita == 'opportunity'){
    //                     element.objectType = 'Opportunity';
    //                     if(component.get("v.isModalFull"))
    //                         element.isCollapsed = true;
    //                     else
    //                         element.isCollapsed = false;
    //                     //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
    //                     elementList.push(element);
    //                 }
                    
    //                 else if(choiseObj.attivita == 'all'){
    //                     element.objectType = element.TipoAttivita__c=='Opportunity' ? 'Diario' : element.TipoAttivita__c=='Campaign' ? 'Diario' : 'Task';
    //                     if(component.get("v.isModalFull") && element.Description!=undefined)
    //                     	element.isCollapsed = false;
    //                     else
    //                         element.isCollapsed = true;
    //                     //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
    //                     elementList.push(element);
    //                 }
    //             }
    //         });
    //     }
    //     console.log('elementList: '+elementList);
    //     elementList.sort( this.compare );
        
	// 	return elementList;
    // },

    dataProcess: function (component, event, metodo) {
        // component.set("v.dateFromRequired", false);
        // component.set("v.dateToRequired", false);
        let allDataValue = component.get('v.allDataValue');
        let allDataChoiseValue = [];
        let selectedValueForChoise = component.get("v.selectedValueForChoise");
        let dateFrom = Date.parse(component.get("v.dateFrom"));
        let dateTo = Date.parse(component.get("v.dateTo"));
        let dataMulti = component.get('v.valuesMultiSelectObject');
        let valueFiltroEsito = component.get('v.valuesMultiSelectFiltroEsito');
        let loadAll = component.get('v.loadAll');
        let size = component.get('v.numberOfRecords');
        let checkNote = component.get('v.checkNote');

            allDataValue.forEach(element => {
                let data = false;
                let esito = false;
                let note = false;

                if(selectedValueForChoise.toLowerCase() == 'tutti' || dataMulti.includes(element.ObjectType)){
                    if (!dateTo && !dateFrom){
                        data = true;
                    } else {
                        let dateX = Date.parse(element[element.FieldToSort]);
                        if(dateFrom && dateTo){
                            if(dateX >= dateFrom && dateX <= dateTo) data = true;
                        } else if (dateFrom && !dateTo) {
                            if(dateX >= dateFrom) data = true;
                        } else if (!dateFrom && dateTo) {
                            if(dateX <= dateTo) data = true;
                        }
                    }

                    if(!element.hasOwnProperty('FieldToCheckEsito') || (element.hasOwnProperty('FieldToCheckEsito') && (valueFiltroEsito.includes(element[element.FieldToCheckEsito]) || valueFiltroEsito == ''))){
                        esito = true;
                    }

                    if(!checkNote || (checkNote && element.hasOwnProperty('SetFieldIcon') && element.SetFieldIcon)){
                        note = true;
                    }
                }

                if(data && esito && note){
                    allDataChoiseValue.push(element);
                }
            });

        if(loadAll){
            component.set('v.allDataChoiseValue', allDataChoiseValue);
        } else {
            component.set('v.allDataChoiseValue', allDataChoiseValue.slice(0, size));
        }
    },
    
    compare: function  ( first, second ) {
        // #50302
        // let today = new Date();
        // let tomorrow = new Date(today);
        // tomorrow.setDate(tomorrow.getDate() + 1);
        var a;
        var b;

        // if(first.ObjectType == 'CRM_Memo__c' && !first.hasOwnProperty('CRM_FineValidita__c') && !first.isTracking && !first.isSupportObject){
        //     a = tomorrow;
        // } else {
            a = new Date(first[first.FieldToSort]);
        // }

        // if(second.ObjectType == 'CRM_Memo__c' && !second.hasOwnProperty('CRM_FineValidita__c') && !first.isTracking && !first.isSupportObject){
        //     b = tomorrow;
        // } else {
            b = new Date(second[second.FieldToSort]);
        // }

        if ( a < b ){
          return 1;
        }
        if ( a > b ){
          return -1;
        }
        return 0;
    },

    showSpinner: function (cmp, event) {
        console.log('showSpinner');
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");

    },

    hideSpinner: function (cmp, event) {
        console.log('hideSpinner');
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");

    },
})