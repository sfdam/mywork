import { LightningElement, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper_v2';
import init from '@salesforce/apex/MakeRequestV2Controller.init';
import getResponse from '@salesforce/apex/MakeRequestV2Controller.getResponse';
import updateElements from '@salesforce/apex/MakeRequestV2Controller.updateElements';

// import sRosso from '@salesforce/resourceUrl/semaforoRosso';
// import sVerde from '@salesforce/resourceUrl/semaforoVerde';


import { getRecordNotifyChange  } from 'lightning/uiRecordApi';

export default class MakeRequestV2 extends LightningElement {
    @api recordId;

    @api apiRequests;
    @api certificateName;
    @api disableLog;
    @track isRendered;
    @track recordTypeName ;
    @track recordTypeInfo ;
    @track account = [];
    @api allData;
    validRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;
    record;
    relatedListMap;
    fieldObjectMap = {};
    idsToUpdate = [];
    valuesToReuseMap = {};
    parsedJson;
    evaluation = eval;
    // Expose the static resource URL for use in the template
    // sRosso = sRosso;
    // sVerde = sVerde;
    

    connectedCallback(){

        this.isRendered = false;
        let conditionsMap = {};
        let parseJSONMap = {};
        // Create a request for the JSON data and load it synchronously,
        // parsing the response as JSON into the tracked property
        let request = new XMLHttpRequest();
        request.open("GET", jsonWrapper, false);
        request.send(null);
        this.parsedJson = JSON.parse(request.responseText);
        let additionalFieldsToQuery = [];
        console.log('DK ALL REQUESTS', this.apiRequests);
        this.apiRequests.split(',').forEach(requestToApiGateway =>{
            parseJSONMap[requestToApiGateway] = this.parsedJson[requestToApiGateway].fields;
            conditionsMap[requestToApiGateway] = this.parsedJson[requestToApiGateway].conditionList ? this.parsedJson[requestToApiGateway].conditionList : null;
            if(this.parsedJson[requestToApiGateway].lastCall){
                additionalFieldsToQuery.push(this.parsedJson[requestToApiGateway].lastCall); 
            }
        });

        console.log(this.parsedJson);

        init({recordId: this.recordId, parseJSONMap: parseJSONMap, conditionsMap: conditionsMap, additionalFields : additionalFieldsToQuery})
        .then(result => {
            
            try {
                console.log('DK init.result', result);
                this.record = result['record'];
                this.relatedListMap = result['relatedListMap'];
                this.recordTypeName = result['record'].RecordType.Name;
                console.log('record:', this.record);
                const apexPromises = [];
                this.apiRequests.split(',').forEach(requestToApiGateway => {
                    console.log('DK requestToCheck', requestToApiGateway);
                    var lastCall = this.parsedJson[requestToApiGateway].lastCall && this.record[this.parsedJson[requestToApiGateway].lastCall] ? new Date(new Date(new Date(this.record[this.parsedJson[requestToApiGateway].lastCall]).toISOString().slice(0,10)).toISOString().slice(0, -1)) : null;
                    var today = new Date(new Date(new Date().toISOString().slice(0,10)).toISOString().slice(0, -1));
                    console.log('DK is new day:', lastCall < today);

                    if(!this.parsedJson[requestToApiGateway].check ||
                        lastCall === null || lastCall === undefined ||
                        (
                            (this.parsedJson[requestToApiGateway].check &&
                            lastCall < today) ||
                            this.parsedJson[requestToApiGateway].bypass.includes(result['currentUser'].Profile.Name.toLowerCase())
                        )
                    ){
                    console.log('DK TO CALL');
                    //pz  NEC #72207
                    let getDettaglioAnagrafica = this.parsedJson['getDettaglioAnagrafica'];
                    console.log('DK getDettaglioAnagrafica', getDettaglioAnagrafica);
                    let fields = getDettaglioAnagrafica['fields'];
                    console.log('DK fields', fields);
                    let consenso = fields['consenso'];
                    console.log('DK consenso', consenso);
                    console.log('pz RecordTypeName', this.recordTypeName);
                    if (this.recordTypeName == 'Person Account'){
                        consenso['devName'] = 'CRM_Privacy_1Level__c';
                    }else{
                        consenso['devName'] = 'CRM_BusinessPrivacy1Level__c';
                    }
                    fields['consenso'] = consenso;
                    getDettaglioAnagrafica['fields'] = fields;
                    this.parsedJson['getDettaglioAnagrafica'] = getDettaglioAnagrafica;
                    console.log('pz this.parsedJson' ,this.parsedJson);
                    console.log('pz ALL REQUESTS', this.apiRequests);
                    
                        apexPromises.push(getResponse({
                            record: this.record,
                            requestToApiGateway: requestToApiGateway,
                            parseJSON: this.parsedJson[requestToApiGateway].fields,
                            conditions: this.parsedJson[requestToApiGateway].conditionList ? this.parsedJson[requestToApiGateway].conditionList : null,
                            certificateName: this.certificateName,
                            disableLog: this.disableLog,
                            addingParamsMap: null
                            
                        }
                        ));
                    
                    }
                    
                });
                /*const apexPromises = this.apiRequests.split(',').map(requestToApiGateway => getResponse({
                    record: this.record,
                    requestToApiGateway: requestToApiGateway,
                    parseJSON: this.parsedJson[requestToApiGateway].fields,
                    conditions: this.parsedJson[requestToApiGateway].conditionList ? this.parsedJson[requestToApiGateway].conditionList : null,
                    certificateName: this.certificateName,
                    disableLog: this.disableLog,
                    addingParamsMap: null
                }));*/
                console.log('DK apexPromises: ', apexPromises);
                this.resolveApexPromises(apexPromises);
            } catch (error) {
                console.log('DK error:', error);
            }
        }).catch((error) => {
            console.log('DK init.error:', error);
        })

    }

    resolveApexPromises(apexPromises) {

        let isOK = false;
        Promise.all(apexPromises)
        .then((result) => {
            console.log('DK result', result);
            let fieldRelationshipMap = {};
            let relatedFields = {};
            result.forEach(element => {
                console.log('DK response', element);
                if(element.response.statusCode == 200){
                    console.log(element.request);
                    isOK = true;
                    let responseData = JSON.parse(element.response.data);
                    console.log('relatedListMap:', this.relatedListMap);
                    
                    for (const [key, value] of Object.entries(element.fields)) {
                        if(!value.hasOwnProperty('exclude')){
                            // mappatura campo da salvare a db
                            if(value.isRelated){
                                // mappatura campo di relatedList
                                // relatedFields = mappa che ha come key il nome della lista presente nel json di risposta e come value una lista con l'element completa della mappatura
                                // fieldRelationshipMap = mappa che ha come key il nome della lista presente nel json di risposta e come value il valore di fieldReferenceObject dell'element della mappatura
                                // thisfieldObjectMap = mappa che ha come key il valore di fieldReferenceObject dell'element della mappatura e come value il valore di fieldReferenceObject e come valore Api Name dell'oggetto
                                if(!relatedFields[value.parent])relatedFields[value.parent] = [];
                                relatedFields[value.parent].push(value);
                                fieldRelationshipMap[value.parent] = value.fieldReferenceObject;
                                this.fieldObjectMap[value.fieldReferenceObject] = value.SObject;
                            }else{

                                if(value.parent){
                                    let point = value.parent.split('.');
                                    let valore = responseData; //lista
                                    point.forEach(p => {
                                        valore = Boolean(valore) ? Boolean(valore[p]) ? valore[p] : null : null;
                                    });
                                    if(valore != null && valore != undefined){
                                        this.setFieldList(key, value, valore, this.record, 'devName');
                                    }
                                }else{
                                    this.setField(key, value, responseData, this.record, 'devName');
                                }
                            }
                        }
                    }

                    // valorizza data ultima esecuzione se necessario
                    console.log('DK lastCall', this.parsedJson[element.request].lastCall);
                    if(this.parsedJson[element.request].lastCall){
                        this.record[this.parsedJson[element.request].lastCall] = new Date();
                    }
                    // LISTE
                    if(Boolean(element.conditions)){
                        let relatedLists = {};
                        // mappa ogni elemento della lista del JSON con la chiave univoca definita nel JSONWRAPPER_V2(risorsa statica)
                        for(var listName in element.conditions){
                            if(responseData[listName]){
                                relatedLists[listName] = {};
                                let keys = Object.keys(element.conditions[listName]);
                                console.log('keys', keys);
                                responseData[listName].forEach(relatedObject => {
                                    let mapKeys = [];
                                    let valore = relatedObject;
                                    keys.forEach(key =>{
                                        let point = key.split('.');
                                        point.forEach(p => {valore = Boolean(valore) ? Boolean(valore[p]) ? valore[p] : null : null;});
                                        if(Boolean(valore)){
                                            mapKeys.push(valore);
                                        }
                                    });
                                    if(mapKeys.length > 0){
                                        relatedLists[listName][mapKeys.join('_')] = relatedObject;
                                    }
                                });
                            }
                        }
                        // mappa ogni elemento della lista del JSON con la chiave univoca definita nel JSONWRAPPER_V2(risorsa statica)
                        //cicla elementi della mappa creata in precedenza e setta i valori
                        for(var listName in relatedLists){
                            for(var recordKey in relatedLists[listName]){
                                if(this.relatedListMap[fieldRelationshipMap[listName]]){
                                    if(this.relatedListMap[fieldRelationshipMap[listName]][recordKey]){
                                        this.idsToUpdate.push(this.relatedListMap[fieldRelationshipMap[listName]][recordKey].Id);
                                        if(this.record[fieldRelationshipMap[listName]]){
                                            relatedFields[listName].forEach(value =>{
                                                if(element.request == 'listaRapporti'){
                                                    console.log('DK listaRapporti_value', value);
                                                    console.log('DK listaRapporti_relatedLists[listName][recordKey]', relatedLists[listName][recordKey]);
                                                    console.log('DK listaRapporti_this.relatedListMap[fieldRelationshipMap[listName]][recordKey]', this.relatedListMap[fieldRelationshipMap[listName]][recordKey]);
                                                }
                                                this.setField(value.fieldReferenceDevName, value, relatedLists[listName][recordKey], this.relatedListMap[fieldRelationshipMap[listName]][recordKey], 'fieldReferenceDevName');
                                            });
                                        }
                                    }
                                }
                            }
                        }
                        //cicla elementi della mappa creata in precedenza e setta i valori
                    }
                    // LISTE
                }
            });
        })
        .then((result) => {
            let allRecord = [];
            if(isOK){

                allRecord.push(this.record);
                console.log('this.record:', this.record);
                console.log('idsToUpdate:', this.idsToUpdate);
                for(var listName in this.relatedListMap){
                    for(var recordKey in this.relatedListMap[listName]){
                        if(this.idsToUpdate.includes(this.relatedListMap[listName][recordKey].Id)){
                            delete this.relatedListMap[listName][recordKey].attributes;
                            allRecord = allRecord.concat(this.relatedListMap[listName][recordKey]); 
                        }
                    }
                }
                console.log('allRecord:', allRecord);
                console.log('result:', result);
                return Object.keys(this.record).length === 0 ? null : updateElements({recordToUpdate: allRecord}).then(() =>{
                    
                    // Refresh Account Detail Page
                    console.log('DK REFRESHED');
                    getRecordNotifyChange([{recordId: this.recordId}]);
                });
            }
        })
        .catch((error) => {
            console.log(error);
        })
        .finally(() => {
            console.log('Finally');
            this.isRendered = true;
        })
    }

    @api valueList = [];
    setFieldList(key, value, responseData, recordToUpdate, fieldProperty){

        try {
            
            this.valueList = [];
            console.log('DK setFieldList_key', key);
            console.log('DK setFieldList_responseData', responseData);
            let saveNull = value.hasOwnProperty('saveNullValue') ? value['saveNullValue'] : true;
            responseData.forEach(element=> {
                
                let filterLogic = value.filterlogic;
                if(value.hasOwnProperty('jsonPointer')){
                    let point = value.jsonPointer.split('.');
                    let valore = element;
                    // console.log('DK setFieldList_valore_1', valore);
                    if(value.jsonPointer !== 'fullElement'){
                        point.forEach(p => {
                            valore = Boolean(valore) ? Boolean(valore[p]) ? valore[p] : null : null;
                        });
                    }
                    // console.log('DK setFieldList_campi', value[fieldProperty].split(','));
                    // console.log('DK setFieldList_valore_final', valore);
                    if(Boolean(valore)){
                        if(value[fieldProperty] != ''){
                            let goForward = true;
                            if(filterLogic){
                                console.log('DK setFieldList_filterlogic_start', filterLogic);
                                value.toReplace.split(',').forEach(keyToReplace =>{
                                    console.log('DK setFieldList_keyToReplace', keyToReplace);
                                    let valueToReplace = keyToReplace.includes('data') ? new Date(element[keyToReplace].split('T')[0]).getTime() : element[keyToReplace];
                                    console.log('DK setFieldList_valueToReplace', valueToReplace);
                                    filterLogic = filterLogic.replaceAll(keyToReplace, valueToReplace);
                                })
                                if(filterLogic.includes('today')){
                                    filterLogic = filterLogic.replaceAll('today', new Date().getTime());
                                }
                                console.log('DK setFieldList_filterLogic_final', filterLogic);
                                goForward = eval(filterLogic);
                            }
                            console.log('DK setFieldList_goForward', goForward);
                            if(goForward){
                                if(value.logic === 'count'){
                                    this.valueList.push(valore); 
                                }else{

                                    if(value.hasOwnProperty('concat')){
                                        let concat = value.concat.split('+');
                                        let valore1 = valore[concat[0]] ? valore[concat[0]] : '';
                                        let valore2 = valore[concat[1]] ? valore[concat[1]] : '';
                                        this.valueList.push(valore1 + '' + valore2);
                                        
                                    } else if(value.hasOwnProperty('valueMap')){
                                        let valueMap = value.valueMap;
                                        // recordToUpdate[value[fieldProperty]] = valueMap[valore];
                                        this.valueList.push(valueMap[valore]);
                                        
                                    } else if(value.type == 'Date'){
            
                                        this.valueList.push(new Date(valore.split('T')[0]));
                                        
                                    }else {
                                        // recordToUpdate[value[fieldProperty]] = value.type == 'Email' ? valore != null ? valore.replace('*', '@') : valore : valore;
                                        if(value.type == 'Email'){
                                            if(valore != null){  
                                                this.valueList.push(valore.replace('*', '@')); 
                                            }else{
                                                this.valueList.push(valore);  
                                            }
                                        }else{
                                            this.valueList.push(valore); 
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
    
            });
            var jsonMethod = value.logic;
            // var jsonMethod = value.logic.replace('array', JSON.stringify(this.valueList));
            console.log('DK setFieldList_this.valueList', this.valueList);
            console.log('DK setFieldList_jsonMethod', jsonMethod);
            var resultMethod;
            if(jsonMethod == 'max'){
                resultMethod = this.valueList.length > 0 ? Math.max.apply(Math, this.valueList) : null;
            }else if(jsonMethod == 'min'){
                resultMethod = this.valueList.length > 0 ?Math.min.apply(Math, this.valueList) : null;
            }else if(jsonMethod == 'sum'){
                resultMethod = this.valueList.length > 0 ? this.valueList.reduce((partialSum, a) => partialSum + a, 0) : 0;
            }else if(jsonMethod == 'count'){
                resultMethod = this.valueList.length;
            }
            var finalValue = resultMethod != null ? 
            value.type == 'Date' ?
                new Date(resultMethod) :
                resultMethod :
            null;
            console.log('DK setFieldList_finalValue', finalValue)
            
            if(saveNull || Boolean(finalValue)){
                value[fieldProperty].split(',').forEach(fieldDevName => {
                    recordToUpdate[fieldDevName] = finalValue
                });
            }
    
            console.log('DK value.toReuse)', value.toReuse);
            /*if(value.toReuse){
                console.log('sono Dentro');
                this.valuesToReuseMap[key] = finalValue;
            }*/
    
            this.record = recordToUpdate;
        } catch (error) {
            console.error('DK setFieldList.error', error);
        }
    }

    setField(key, value, responseData, recordToUpdate, fieldProperty){

        console.log('DK setField_key', key);
        console.log('DK setField_value', value);
        console.log('DK setField_responseData', responseData);
        var finalValue;
        let saveNull = value.hasOwnProperty('saveNullValue') ? value['saveNullValue'] : true;
        if(value.hasOwnProperty('jsonPointer')){
            let point = value.jsonPointer.split('.');
            let valore = responseData;
            point.forEach(p => {
                valore = Boolean(valore) ? Boolean(valore[p]) ? valore[p] : null : null;
            });
            if(Boolean(valore)){
                if(value[fieldProperty] != ''){
                    console.log('DK value[fieldProperty]: ', value[fieldProperty].split(','));
                    if(value.hasOwnProperty('concat')){
                        let concat = value.concat.split('+');
                        let valore1 = valore[concat[0]] ? valore[concat[0]] : '';
                        let valore2 = valore[concat[1]] ? valore[concat[1]] : '';
                        finalValue = valore1 + '' + valore2;
                        if(saveNull || Boolean(finalValue)){
                            value[fieldProperty].split(',').forEach(fieldDevName =>{
                                recordToUpdate[fieldDevName] = finalValue;
                            });
                        }
                        
                    } else if(value.hasOwnProperty('valueMap')){
                        let valueMap = value.valueMap;
                        // recordToUpdate[value[fieldProperty]] = valueMap[valore];
                        finalValue = valueMap[valore];
                        if(saveNull || Boolean(finalValue)){
                            value[fieldProperty].split(',').forEach(fieldDevName =>{
                                recordToUpdate[fieldDevName] = finalValue;
                            });
                        }
                    } else if(value.type == 'Date'){
                        finalValue = valore.split('T')[0];
                        if(saveNull || Boolean(finalValue)){
                            value[fieldProperty].split(',').forEach(fieldDevName =>{
                                recordToUpdate[fieldDevName] = finalValue;
                            });
                        }
                    }else {
                        // recordToUpdate[value[fieldProperty]] = value.type == 'Email' ? valore != null ? valore.replace('*', '@') : valore : valore;
                        if(value.type == 'Email'){
                            if(valore != null){
                                finalValue = valore.replace('*', '@');
                                if (!finalValue.match(this.validRegex)) {
                                    
                                    console.log('DK EMAIL NOT VALID', finalValue);
                                    finalValue = null;
                                } // se email non valida metto null
                                if(saveNull || Boolean(finalValue)){
                                    value[fieldProperty].split(',').forEach(fieldDevName =>{
                                        recordToUpdate[fieldDevName] = finalValue;
                                    });
                                }
                            }else{
                                finalValue = valore;
                                if(saveNull || Boolean(finalValue)){
                                    value[fieldProperty].split(',').forEach(fieldDevName =>{
                                        recordToUpdate[fieldDevName] = finalValue;
                                    }); 
                                }
                            }
                        }else{
                            finalValue = valore;
                            if(saveNull || Boolean(finalValue)){
                                value[fieldProperty].split(',').forEach(fieldDevName =>{
                                    recordToUpdate[fieldDevName] = finalValue;
                                }); 
                            }
                        }
                    }
                }
            }
            console.log('DK value.toReuse)', value.toReuse);
            if(value.toReuse){
                console.log('sono Dentro');
                this.valuesToReuseMap[key] = finalValue;
            }
        }
    }
}