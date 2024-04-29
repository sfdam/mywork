import { LightningElement, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper_v2';
import getRecordObject from '@salesforce/apex/MakeRequestV2Controller.getRecordObject';
import getResponse from '@salesforce/apex/MakeRequestV2Controller.getResponse';
import saveElements from '@salesforce/apex/MakeRequestV2Controller.saveElements';

// import sRosso from '@salesforce/resourceUrl/semaforoRosso';
// import sVerde from '@salesforce/resourceUrl/semaforoVerde';

export default class MakeRequestV2 extends LightningElement {
    @api recordId;

    @api apiRequests;
    @api certificateName;
    @api disableLog;
    @track isRendered;

    @api allData;

    record;
    relatedListMap;
    fieldObjectMap = {};


    idsToUpdate = [];

    // Expose the static resource URL for use in the template
    // sRosso = sRosso;
    // sVerde = sVerde;

    connectedCallback(){

        this.isRendered = false;
        let conditionsMap = {};
        let parseJSONMap = {};

        // let requestToApiGateway = this.apiRequests.split(',');
        
        
        // Create a request for the JSON data and load it synchronously,
        // parsing the response as JSON into the tracked property
        let request = new XMLHttpRequest();
        request.open("GET", jsonWrapper, false);
        request.send(null);
        let parsedJson = JSON.parse(request.responseText);

        // requestToApiGateway.forEach(singleRequest => {
        //     this.allRequest.set(singleRequest, parsedJson[singleRequest]);
        // });

        this.apiRequests.split(',').forEach(requestToApiGateway =>{
            parseJSONMap[requestToApiGateway] = parsedJson[requestToApiGateway].fields;
            conditionsMap[requestToApiGateway] = parsedJson[requestToApiGateway].conditionList ? parsedJson[requestToApiGateway].conditionList : null;
        });

        console.log(parsedJson);

        getRecordObject({recordId: this.recordId, parseJSONMap: parseJSONMap, conditionsMap: conditionsMap})
        .then(result => {
            
            this.record = result['record'];
            this.relatedListMap = result['relatedListMap'];
            console.log('record:', this.record);
            const apexPromises = this.apiRequests.split(',').map(requestToApiGateway => getResponse({
                record: this.record,
                requestToApiGateway: requestToApiGateway,
                parseJSON: parsedJson[requestToApiGateway].fields,
                conditions: parsedJson[requestToApiGateway].conditionList ? parsedJson[requestToApiGateway].conditionList : null,
                certificateName: this.certificateName,
                disableLog: this.disableLog
            }));
            this.resolveApexPromises(apexPromises);
        }).catch((error) => {
            console.log(error);
        })

    }

    resolveApexPromises(apexPromises) {
        Promise.all(apexPromises)
        .then((result) => {
            console.log(result);
            // let recordToUpdate = {};
            let fieldRelationshipMap = {};
            let relatedFields = {};
            result.forEach(element => {
                if(element.response.statusCode == 200){
                    console.log(element.request);
                    
                    let responseData = JSON.parse(element.response.data);
                    /*for (const [key, value] of Object.entries(element.record)) {
                        recordToUpdate[key] = value;
                    }*/
                    // console.log('relatedLists:', relatedLists);
                    console.log('relatedListMap:', this.relatedListMap);
                    // console.log('recordToUpdate:', recordToUpdate);
                    
                    for (const [key, value] of Object.entries(element.fields)) {
                        if(!value.hasOwnProperty('exclude')){
                            if(value.isRelated){
                                if(!relatedFields[value.parent])relatedFields[value.parent] = [];
                                relatedFields[value.parent].push(value);
                                fieldRelationshipMap[value.parent] = value.fieldReferenceObject;
                                this.fieldObjectMap[value.fieldReferenceObject] = value.SObject;
                            }else{
                                this.setField(value, responseData, this.record, 'devName');
                            }
                        }
                    }
                    // LISTE
                    if(Boolean(element.conditions)){
                        let relatedLists = {};
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
                        for(var listName in relatedLists){
                            for(var recordKey in relatedLists[listName]){
                                if(this.relatedListMap[fieldRelationshipMap[listName]]){
                                    if(this.relatedListMap[fieldRelationshipMap[listName]][recordKey]){
                                        this.idsToUpdate.push(this.relatedListMap[fieldRelationshipMap[listName]][recordKey].Id);
                                        if(this.record[fieldRelationshipMap[listName]]){
                                            relatedFields[listName].forEach(value =>{
                                                this.setField(value, relatedLists[listName][recordKey], this.relatedListMap[fieldRelationshipMap[listName]][recordKey], 'fieldReferenceDevName');
                                            });
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // LISTE
                }
            });
        })
        .then((result) => {
            let allRecord = [];
            // let currentRecord = {};
            // for (const [key, value] of Object.entries(this.record)) {
            //     currentRecord[key] = value;
            // }
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
            return Object.keys(this.record).length === 0 ? null : saveElements({record: allRecord});
        })
        .catch((error) => {
            console.log(error);
        })
        .finally(() => {
            console.log('Finally');
            eval("$A.get('e.force:refreshView').fire();");
            this.isRendered = true;

        })
    }

    setField(value, responseData, recordToUpdate, fieldProperty){

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
                        value[fieldProperty].split(',').forEach(fieldDevName =>{
                            recordToUpdate[fieldDevName] = valore1 + '' + valore2;
                        });
                    } else if(value.hasOwnProperty('valueMap')){
                        let valueMap = value.valueMap;
                        // recordToUpdate[value[fieldProperty]] = valueMap[valore];
                        value[fieldProperty].split(',').forEach(fieldDevName =>{
                            recordToUpdate[fieldDevName] = valueMap[valore];
                        });
                    } else if(value.type == 'Date'){
                        // let split = valore.split('T');
                        // let date = split[0].split('-');
                        // let year = date[0];
                        // let mounth = date[1];
                        // let day = date[2];
                        // let d = new Date(year, mounth - 1, day);
                        // console.log('DK Date: ' + d);

                        // recordToUpdate[value[fieldProperty]] = valore.split('T')[0];
                        value[fieldProperty].split(',').forEach(fieldDevName =>{
                            recordToUpdate[fieldDevName] = valore.split('T')[0];
                        });
                    }else {
                        // recordToUpdate[value[fieldProperty]] = value.type == 'Email' ? valore != null ? valore.replace('*', '@') : valore : valore;
                        if(value.type == 'Email'){
                            if(valore != null){

                                value[fieldProperty].split(',').forEach(fieldDevName =>{
                                    recordToUpdate[fieldDevName] = valore.replace('*', '@');
                                });
                            }else{
                                value[fieldProperty].split(',').forEach(fieldDevName =>{
                                    recordToUpdate[fieldDevName] = valore;
                                }); 
                            }
                        }else{
                            value[fieldProperty].split(',').forEach(fieldDevName =>{
                                recordToUpdate[fieldDevName] = valore;
                            }); 
                        }
                    }
                }
            }
        }
    }
}