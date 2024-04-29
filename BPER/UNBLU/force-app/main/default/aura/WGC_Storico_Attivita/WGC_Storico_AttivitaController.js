({
    
    //userInfo
    //allDataValue

    // [ { "label": "Cambio su Gestore", "object": "NDGManagementMember__c" }, { "label": "Proposte/Simulazioni/Preventivi", "object": "CRM_ProposteContrattiPreventivi__c" }, { "label": "SMS", "object": "et4ae5__SMSDefinition__c" }, { "label": "OFS", "object": "Account" }, { "label": "PCA", "object": "CRM_PCA__c" }, { "label": "Cambio su PTF", "object": "BookMember__c" }, { "label": "Eventi a Calendario", "object": "ServiceAppointment" }, { "label": "Email", "object": "EmailMessage" }, { "label": "DEM", "object": "et4ae5__IndividualEmailResult__c" }, { "label": "Ingaggio reti esterne", "object": "CRM_IngaggioRetiEsterne__c" }, { "label": "Reclami", "object": "CRM_Claims__c" }, { "label": "Alert", "object": "FinServ__Alert__c" }, { "label": "Case", "object": "Case" }, { "label": "Memo", "object": "Note__c" }, { "label": "Prodotti", "object": "FinServ__FinancialAccount__c" }, { "label": "Opportunità", "object": "Opportunity" }, { "label": "Task", "object": "Task" }, { "label": "Evento", "object": "Event" }, { "label": "Campagne", "object": "CampaignMember" }, { "label": "Tagliandi", "object": "CRM_CustomerInterview__c" } ]
    // [ { "label": "Cambio su Gestore", "object": "NDGManagementMember__c" } ]
    printPDF: function (component, event, helper) {

        return helper.generaXmlWithPromise(component, event, helper);
    },
    doInit: function (component, event, helper) {
        helper.showSpinner(component);

        let objectList = JSON.parse(component.get('v.objectList'));
        let promiseArray =[];

        var initStampa = helper.apex(component, event, 'initStampa', {"recordId": component.get("v.recordId")});
        initStampa
        .then($A.getCallback(function(result){
            console.log('initStampa result: ', result);
            component.set('v.metadatiStampa', result.metadatiStampa);
            component.set('v.accountData', result.accountData);
            component.set('v.recordTypeDeveloperName', result.recordTypeDeveloperName);
            console.log('result.accountData: ', component.get('v.accountData'));
            console.log('result.metadatiStampa: ', component.get('v.metadatiStampa'));
            console.log('result.recordTypeDeveloperName: ', component.get('v.recordTypeDeveloperName'));
        }));

        helper.apex(component, event, 'getUserInfo', {})
        .then($A.getCallback(function(results){
            //handle success
            console.log('SV getUserInfo: ', results); 
            component.set('v.userInfo', results);
            if (objectList) {
                objectList.forEach(element => {
                    if(results.Profile.Name == 'CRM - Consulenti Finanziari'){
                        component.set('v.isCF',true);
                        if(element.object != 'NDGManagementMember__c' && element.object != 'BookMember__c'){
                            let promise = helper.apex(component, event, 'getAllData', { "accId": component.get("v.recordId"), "objType": element.object, "objRecordType": element.hasOwnProperty('recordType') ? element.recordType : null, "referentProfile": component.get("v.referentProfile") });
                            promiseArray.push(promise);
                        }
                    } else {
                        let promise = helper.apex(component, event, 'getAllData', { "accId": component.get("v.recordId"), "objType": element.object, "objRecordType": element.hasOwnProperty('recordType') ? element.recordType : null, "referentProfile": component.get("v.referentProfile") });
                        promiseArray.push(promise); 
                    }
                })
            }

            var combinedPromise = Promise.all(promiseArray);
            return combinedPromise;

        }))
        .then($A.getCallback(function(results){
            //handle success
            let today = new Date();
            component.set('v.getAllDataResult', []);
            console.log('SV RESULTS: ', results);
            let objCampoEsitoList = [];
            let helpTextEsito = component.get('v.helpTextEsito');
            results.forEach(element => {
                let listAllObjResult = component.get('v.getAllDataResult');
                let listMultiSelectFiltroEsito = component.get('v.optionsMultiSelectFiltroEsito');
                if(element.metadato){

                    if(element.metadato.CHECK_CAMPO_ESITO__c){
                        objCampoEsitoList.push(element.metadato.OBJECT_TYPE__c);
                        objectList.forEach(o => {
                            if(o.object == element.metadato.OBJECT_TYPE__c) helpTextEsito = helpTextEsito + ' ' + o.label + ',';
                        })
                    }; 
    
                    let obj = element.metadato.OBJECT_TYPE__c;
                    let fieldToSort = element.metadato.CAMPO_FILTRO_DATA__c;
                    let fieldToSplit = element.metadato.FIELDS_TO_SPLIT__c;
                    let fieldToCheckEsito = element.metadato.CAMPO_ESITO__c;
                    let fieldForIcon = element.metadato.hasOwnProperty('FIELD_FORICON__c') ? element.metadato.FIELD_FORICON__c.split(',') : [];
                    let lookUpToRecord = element.metadato.LOOK_UP_TO_RECORD__c;
                    let campiTracking = element.metadato.CAMPO_TRACKING_HISTORY__c;
    
                    let idListForFieldToSPlit = [];
                    let concatTracking = [];
                    element.data.forEach((x, index) => {
                        x.ObjectType = obj;
                        x.ObjectFieldLookup = lookUpToRecord;
                        x.isCollapsed = component.get('v.isExtendedDescription');
                        x.isPrimary = x[lookUpToRecord] == component.get("v.recordId") ? true : false; // mi permette di identificare se un elemento è legato alla PF o alla CO
                        x.notShow = false;
                        if(fieldToSort) {
                            x.FieldToSort = fieldToSort;
                        } else {
                            if(fieldToSplit){
                                //let elSplit = fieldToSplit.split(',');
                                //x.FieldToSort = idListForFieldToSPlit.includes(x.Id) ? elSplit[1] : elSplit[0];
                                //idListForFieldToSplit.push(x.Id);
                                let elSplit = x.Id.split('-');
                                x.FieldToSort = elSplit[1];
                                x.Id = elSplit[0];
                            }
                        }
                        if(fieldToCheckEsito) x.FieldToCheckEsito = fieldToCheckEsito;
                        fieldForIcon.forEach(element => {
                            if(x.hasOwnProperty(element)){
                                x.SetFieldIcon = true;
                                return;
                            }
                        });

                        let arrayCampiTracking = campiTracking ? campiTracking.split(',') : [];
                        let objOrginalValueTracking = {};
                        arrayCampiTracking.forEach(key => {
                            objOrginalValueTracking[key] = x[key];
                        });
    
                        element.trackingData.forEach(track => {
                            if(!track.hasOwnProperty('OldValue__c')){
                                if(!x.hasOwnProperty('CampiAggiornati')){
                                    let trackFieldslist = track.Tracking_Field__c.split(';');
                                    let newList = track.NewValue__c.split(';');
        
                                    x['isTracking'] = false;
                                    if(!x.hasOwnProperty('CampiAggiornati')) x['CampiAggiornati'] = [];
                                    for(let z = 0; z < trackFieldslist.length; z++){
                                        x['CampiAggiornati'].push(trackFieldslist[z]);
                                        x[trackFieldslist[z] + '__original'] = objOrginalValueTracking[trackFieldslist[z]];
                                        x[trackFieldslist[z]] = newList[z] == 'null' ? '' : newList[z];
                                    }
                                }  
                            }
                        });
    
                        element.trackingData.forEach(track => {
                            if(track.ParentObject__c == x.Id && track.hasOwnProperty('OldValue__c')){
                            	let trackFieldslist = track.Tracking_Field__c.split(';');
                                let newList = track.NewValue__c.split(';');
    
                                let trackEl = Object.assign({}, x);
                                // trackEl = JSON.parse(JSON.stringify(x));
                                trackEl[x.FieldToSort] = track.CreatedDate;
                                if(!trackEl.hasOwnProperty('CreatedBy')) trackEl.CreatedBy = {};
                                trackEl.CreatedBy.Id = track.CreatedBy.Id;
                                trackEl.CreatedBy.Name = track.CreatedBy.Name;
                                trackEl['isTracking'] = true;
                                trackEl['notShow'] = false;
    
                                for(let z = 0; z < trackFieldslist.length; z++){
                                    trackEl[trackFieldslist[z]] = newList[z] == 'null' ? '' : newList[z];
                                }
                               
                                concatTracking.push(trackEl);
                                if(x.ObjectType == 'FinServ__Alert__c'){
                                    x.notShow = true;
                                }
    
    
                            }
                        });
                    });
    
                    element.supportData.forEach(x => {
                        x.SupportObject = true;
                        x.ObjectType = obj;
                        x.isCollapsed = component.get('v.isExtendedDescription');
                        x.isPrimary = x.CRM_Account__c == component.get("v.recordId") ? true : false; // mi permette di identificare se un elemento è legato alla PF o alla CO
                        x.isSupportObject = true;
                        if(fieldToSort) {
                            x.FieldToSort = x[fieldToSort] ? fieldToSort : 'CreatedDate';
                        } else {
                            if(fieldToSplit){
                                //let elSplit = fieldToSplit.split(',');
                                //x.FieldToSort = idListForFieldToSPlit.includes(x.Id) ? elSplit[1] : elSplit[0];
                                //idListForFieldToSPlit.push(x.Id);
                                // let elSplit = x.Id.split('-');
                                // x.FieldToSort = elSplit[1];
                                // x.Id = elSplit[0];       
                                
                                if(obj == 'CRM_Memo__c'){
                                    let finVal = new Date(x.CRM_FineValidita__c);
                                    console.log('SV finVal', finVal);
                                    console.log('SV today', today);
                                    console.log('SV finVal <= today', finVal <= today);
                                    if(x.hasOwnProperty('CRM_FineValidita__c') && finVal <= today){
                                        let suppEl = {};
                                        suppEl = JSON.parse(JSON.stringify(x));
                                        suppEl.FieldToSort = 'CRM_FineValidita__c';
                                        concatTracking.push(suppEl);
                                    }
                                }
    
                                x.FieldToSort =  x[fieldToSort] ? fieldToSort : 'CreatedDate';
    
                            }
                        }
                        if(fieldToCheckEsito) x.FieldToCheckEsito = fieldToCheckEsito;
                        fieldForIcon.forEach(element => {
                            if(x.hasOwnProperty(element)){
                                x.SetFieldIcon = true;
                                return;
                            }
                        });
    
                        concatTracking.push(x);
    
                    });
    
                    let combinedTracking = [].concat((obj == 'CRM_AccountDetail__c' && element.supportData.length > 0)  ? [] : element.data, concatTracking);
    
                    let combined = [].concat(listAllObjResult, combinedTracking);
                    component.set('v.getAllDataResult', combined);
                    element.listFiltroEsito.forEach(x => {
                        let trovato = false;
                        listMultiSelectFiltroEsito.forEach(y => {
                            if(x.value == y.value){
                                trovato = true;
                                y.obj = y.obj + ',' + x.obj;
                            }
                        });
                        if(!trovato){
                            listMultiSelectFiltroEsito.push(x);
                        }
                    });
                    // let combinedFiltroEsito = [].concat(listMultiSelectFiltroEsito, element.listFiltroEsito);
                    component.set('v.listMultiSelectFiltroEsito', listMultiSelectFiltroEsito);
                    component.set('v.optionsMultiSelectFiltroEsito', listMultiSelectFiltroEsito);
                }
            });
            component.set('v.objCampoEsitoList', objCampoEsitoList);
            component.set('v.helpTextEsito', helpTextEsito.replace(/,\s*$/, ""));

        }))
        .finally($A.getCallback(function () {
            let listResult = component.get('v.getAllDataResult');
            let objCampoEsitoList = component.get("v.objCampoEsitoList");
            let size = component.get('v.numberOfRecords');

            listResult.sort( helper.compare );
            console.log('SV FINALLY: ', [...listResult]);
            component.set('v.allDataChoiseValue', [...listResult].slice(0, size));
            component.set('v.allDataValue', [...listResult]);
            component.set("v.checkEsito", objCampoEsitoList.length > 0 ? false : true);
            if([...listResult].length > size) component.set('v.showButtonViewAll', true);
            helper.hideSpinner(component);

        }))
        .catch($A.getCallback(function (error) { 
            console.log('SV ERROR: ', error); 
        }));

        // var combinedPromise = Promise.all(promiseArray);
        // combinedPromise
        // .then($A.getCallback(function(results){
        //     //handle success
        //     let today = new Date();
        //     component.set('v.getAllDataResult', []);
        //     console.log('SV RESULTS: ', results);
        //     let objCampoEsitoList = [];
        //     let helpTextEsito = component.get('v.helpTextEsito');
        //     results.forEach(element => {
        //         let listAllObjResult = component.get('v.getAllDataResult');
        //         let listMultiSelectFiltroEsito = component.get('v.optionsMultiSelectFiltroEsito');
        //         if(element.metadato){

        //             if(element.metadato.CHECK_CAMPO_ESITO__c){
        //                 objCampoEsitoList.push(element.metadato.OBJECT_TYPE__c);
        //                 objectList.forEach(o => {
        //                     if(o.object == element.metadato.OBJECT_TYPE__c) helpTextEsito = helpTextEsito + ' ' + o.label + ',';
        //                 })
        //             }; 
    
        //             let obj = element.metadato.OBJECT_TYPE__c;
        //             let fieldToSort = element.metadato.CAMPO_FILTRO_DATA__c;
        //             let fieldToSplit = element.metadato.FIELDS_TO_SPLIT__c;
        //             let fieldToCheckEsito = element.metadato.CAMPO_ESITO__c;
        //             let fieldForIcon = element.metadato.hasOwnProperty('FIELD_FORICON__c') ? element.metadato.FIELD_FORICON__c.split(',') : [];
        //             let lookUpToRecord = element.metadato.LOOK_UP_TO_RECORD__c;
        //             let campiTracking = element.metadato.CAMPO_TRACKING_HISTORY__c;
    
        //             let idListForFieldToSPlit = [];
        //             let concatTracking = [];
        //             element.data.forEach((x, index) => {
        //                 x.ObjectType = obj;
        //                 x.ObjectFieldLookup = lookUpToRecord;
        //                 x.isCollapsed = component.get('v.isExtendedDescription');
        //                 x.isPrimary = x[lookUpToRecord] == component.get("v.recordId") ? true : false; // mi permette di identificare se un elemento è legato alla PF o alla CO
        //                 x.notShow = false;
        //                 if(fieldToSort) {
        //                     x.FieldToSort = fieldToSort;
        //                 } else {
        //                     if(fieldToSplit){
        //                         //let elSplit = fieldToSplit.split(',');
        //                         //x.FieldToSort = idListForFieldToSPlit.includes(x.Id) ? elSplit[1] : elSplit[0];
        //                         //idListForFieldToSplit.push(x.Id);
        //                         let elSplit = x.Id.split('-');
        //                         x.FieldToSort = elSplit[1];
        //                         x.Id = elSplit[0];
        //                     }
        //                 }
        //                 if(fieldToCheckEsito) x.FieldToCheckEsito = fieldToCheckEsito;
        //                 fieldForIcon.forEach(element => {
        //                     if(x.hasOwnProperty(element)){
        //                         x.SetFieldIcon = true;
        //                         return;
        //                     }
        //                 });

        //                 let arrayCampiTracking = campiTracking ? campiTracking.split(',') : [];
        //                 let objOrginalValueTracking = {};
        //                 arrayCampiTracking.forEach(key => {
        //                     objOrginalValueTracking[key] = x[key];
        //                 });
    
        //                 element.trackingData.forEach(track => {
        //                     if(!track.hasOwnProperty('OldValue__c')){
        //                         if(!x.hasOwnProperty('CampiAggiornati')){
        //                             let trackFieldslist = track.Tracking_Field__c.split(';');
        //                             let newList = track.NewValue__c.split(';');
        
        //                             x['isTracking'] = false;
        //                             if(!x.hasOwnProperty('CampiAggiornati')) x['CampiAggiornati'] = [];
        //                             for(let z = 0; z < trackFieldslist.length; z++){
        //                                 x['CampiAggiornati'].push(trackFieldslist[z]);
        //                                 x[trackFieldslist[z] + '__original'] = objOrginalValueTracking[trackFieldslist[z]];
        //                                 x[trackFieldslist[z]] = newList[z] == 'null' ? '' : newList[z];
        //                             }
        //                         }  
        //                     }
        //                 });
    
        //                 element.trackingData.forEach(track => {
        //                     if(track.ParentObject__c == x.Id && track.hasOwnProperty('OldValue__c')){
        //                     	let trackFieldslist = track.Tracking_Field__c.split(';');
        //                         let newList = track.NewValue__c.split(';');
    
        //                         let trackEl = Object.assign({}, x);
        //                         // trackEl = JSON.parse(JSON.stringify(x));
        //                         trackEl[x.FieldToSort] = track.CreatedDate;
        //                         if(!trackEl.hasOwnProperty('CreatedBy')) trackEl.CreatedBy = {};
        //                         trackEl.CreatedBy.Id = track.CreatedBy.Id;
        //                         trackEl.CreatedBy.Name = track.CreatedBy.Name;
        //                         trackEl['isTracking'] = true;
        //                         trackEl['notShow'] = false;
    
        //                         for(let z = 0; z < trackFieldslist.length; z++){
        //                             trackEl[trackFieldslist[z]] = newList[z] == 'null' ? '' : newList[z];
        //                         }
                               
        //                         concatTracking.push(trackEl);
        //                         if(x.ObjectType == 'FinServ__Alert__c'){
        //                             x.notShow = true;
        //                         }
    
    
        //                     }
        //                 });
        //             });
    
        //             element.supportData.forEach(x => {
        //                 x.SupportObject = true;
        //                 x.ObjectType = obj;
        //                 x.isCollapsed = component.get('v.isExtendedDescription');
        //                 x.isPrimary = x.CRM_Account__c == component.get("v.recordId") ? true : false; // mi permette di identificare se un elemento è legato alla PF o alla CO
        //                 x.isSupportObject = true;
        //                 if(fieldToSort) {
        //                     x.FieldToSort = x[fieldToSort] ? fieldToSort : 'CreatedDate';
        //                 } else {
        //                     if(fieldToSplit){
        //                         //let elSplit = fieldToSplit.split(',');
        //                         //x.FieldToSort = idListForFieldToSPlit.includes(x.Id) ? elSplit[1] : elSplit[0];
        //                         //idListForFieldToSPlit.push(x.Id);
        //                         // let elSplit = x.Id.split('-');
        //                         // x.FieldToSort = elSplit[1];
        //                         // x.Id = elSplit[0];       
                                
        //                         if(obj == 'CRM_Memo__c'){
        //                             let finVal = new Date(x.CRM_FineValidita__c);
        //                             console.log('SV finVal', finVal);
        //                             console.log('SV today', today);
        //                             console.log('SV finVal <= today', finVal <= today);
        //                             if(x.hasOwnProperty('CRM_FineValidita__c') && finVal <= today){
        //                                 let suppEl = {};
        //                                 suppEl = JSON.parse(JSON.stringify(x));
        //                                 suppEl.FieldToSort = 'CRM_FineValidita__c';
        //                                 concatTracking.push(suppEl);
        //                             }
        //                         }
    
        //                         x.FieldToSort =  x[fieldToSort] ? fieldToSort : 'CreatedDate';
    
        //                     }
        //                 }
        //                 if(fieldToCheckEsito) x.FieldToCheckEsito = fieldToCheckEsito;
        //                 fieldForIcon.forEach(element => {
        //                     if(x.hasOwnProperty(element)){
        //                         x.SetFieldIcon = true;
        //                         return;
        //                     }
        //                 });
    
        //                 concatTracking.push(x);
    
        //             });
    
        //             let combinedTracking = [].concat((obj == 'CRM_AccountDetail__c' && element.supportData.length > 0)  ? [] : element.data, concatTracking);
    
        //             let combined = [].concat(listAllObjResult, combinedTracking);
        //             component.set('v.getAllDataResult', combined);
        //             element.listFiltroEsito.forEach(x => {
        //                 let trovato = false;
        //                 listMultiSelectFiltroEsito.forEach(y => {
        //                     if(x.value == y.value){
        //                         trovato = true;
        //                         y.obj = y.obj + ',' + x.obj;
        //                     }
        //                 });
        //                 if(!trovato){
        //                     listMultiSelectFiltroEsito.push(x);
        //                 }
        //             });
        //             // let combinedFiltroEsito = [].concat(listMultiSelectFiltroEsito, element.listFiltroEsito);
        //             component.set('v.listMultiSelectFiltroEsito', listMultiSelectFiltroEsito);
        //             component.set('v.optionsMultiSelectFiltroEsito', listMultiSelectFiltroEsito);
        //         }
        //     });
        //     component.set('v.objCampoEsitoList', objCampoEsitoList);
        //     component.set('v.helpTextEsito', helpTextEsito.replace(/,\s*$/, ""));

        // }))
        // .finally($A.getCallback(function () {
        //     let listResult = component.get('v.getAllDataResult');
        //     let objCampoEsitoList = component.get("v.objCampoEsitoList");
        //     let size = component.get('v.numberOfRecords');

        //     listResult.sort( helper.compare );
        //     console.log('SV FINALLY: ', [...listResult]);
        //     component.set('v.allDataChoiseValue', [...listResult].slice(0, size));
        //     component.set('v.allDataValue', [...listResult]);
        //     component.set("v.checkEsito", objCampoEsitoList.length > 0 ? false : true);
        //     if([...listResult].length > size) component.set('v.showButtonViewAll', true);
        //     helper.hideSpinner(component);

        // }))
        // .catch($A.getCallback(function (error) { 
        //     console.log('SV ERROR: ', error); 
        // }));

        helper.fetchPickListValObject(component, 'optionsMultiSelectObject');

    },

    searchDate: function (component, event, helper) {

        let valueStart = component.get('v.dateFrom');
        let valueEnd = component.get('v.dateTo');
        var dataFieldStart = component.find('fieldDataStart');
        var dataFieldEnd = component.find('fieldDataEnd');

        let valid = false;

        if (valueStart && valueEnd && valueStart > valueEnd) {
            dataFieldStart.setCustomValidity("La data di partenza non può essere superiore rispetto a quella di fine");
            dataFieldEnd.setCustomValidity(" ");
        } else {
            dataFieldStart.setCustomValidity(""); // if there was a custom error before, reset it
            dataFieldEnd.setCustomValidity("");
            valid = true;
        }
        dataFieldStart.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
        dataFieldEnd.reportValidity(); // Tells lightning:input to show the error right away without needing interaction

        if(valid){
            helper.showSpinner(component);
            helper.dataProcess(component, event, null);
            helper.hideSpinner(component);
        }
    },

    loadAll: function (component, event, helper) {
        helper.showSpinner(component);
        component.set('v.loadAll', !component.get('v.loadAll'));
        helper.dataProcess(component, event, null);
        helper.hideSpinner(component);
    },

    //Abilitazione della select filtro per esito 
    onChangeMulti: function (component, event, helper) {
        let valuesMulti = event.getParam("value");
        let objCampoEsitoList = component.get("v.objCampoEsitoList");
        console.log(objCampoEsitoList);
        console.log(valuesMulti);
        console.log(objCampoEsitoList.some(item => valuesMulti.includes(item)));


        if (objCampoEsitoList.some(item => valuesMulti.includes(item))){
            component.set("v.checkEsito", false); //Select abilitata
        } else {
            component.set("v.checkEsito", true); //Select disabilitata
            component.set("v.valuesMultiSelectFiltroEsito", []);
        }

        let valuesMultiSelectObject = component.get("v.valuesMultiSelectObject");
        // let valuesMultiSelectFiltroEsito = component.get("v.valuesMultiSelectFiltroEsito");
        // alert(JSON.stringify(valuesMultiSelectFiltroEsito));
        let listMultiSelectFiltroEsito = component.get("v.listMultiSelectFiltroEsito");
        console.log(valuesMultiSelectObject);

        console.log(JSON.stringify(listMultiSelectFiltroEsito));
        let listFiltroEsitoToShow = [];
        listMultiSelectFiltroEsito.forEach(element => {
            valuesMultiSelectObject.forEach(x => {
                if(element.obj.includes(x)){
                    listFiltroEsitoToShow.push(element);
                }
            });
        });

        const filteredArr = listFiltroEsitoToShow.reduce((acc, current) => {
            const x = acc.find(item => item.value === current.value);
            if (!x) {
              return acc.concat([current]);
            } else {
              return acc;
            }
          }, []);

        console.log('listFiltroEsitoToShow', filteredArr);
        
        component.set("v.optionsMultiSelectFiltroEsito", filteredArr);
    },

    //Check per mostrare/nascondere i filtri per oggetto
    selectTipoSelezione: function (component, event, helper) {  
        let selectedValue = component.find("ObjSelectedList").get("v.value");
        let objCampoEsitoList = component.get("v.objCampoEsitoList");
        let listMultiSelectFiltroEsito = component.get("v.listMultiSelectFiltroEsito");

        if(selectedValue.includes("tutti")){
            component.set("v.checkObjSelected", false);
            component.set("v.checkEsito", objCampoEsitoList.length > 0 ? false : true);
            component.set("v.valuesMulti", []);
            component.set("v.valueFiltroEsito", '');
            component.set("v.optionsMultiSelectFiltroEsito", listMultiSelectFiltroEsito);
        } else {
            component.set("v.checkObjSelected", true);
            component.set("v.checkEsito", true);
            component.set("v.valuesMultiSelectObject", []);
            component.set("v.valuesMultiSelectFiltroEsito", []);
        }
    },

    onChange: function (component, event, helper) {  
        component.set('v.checkNote', component.get('v.checkNote'));
    },


})