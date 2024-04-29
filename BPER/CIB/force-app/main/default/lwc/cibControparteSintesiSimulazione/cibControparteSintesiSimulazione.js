/**
 * @group             : tengroup
 * @last modified on  : 11-03-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * 
 * description        : 
**/

import { LightningElement,api,track,wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";//AD
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import Simulazione_OBJECT from "@salesforce/schema/Simulazione__c";  
const FIELDS = [
    'Simulazione__c.NDG__c',
    'Simulazione__c.Classe_di_rating__c',
    'Simulazione__c.NDG_di_Gruppo__c',
    'Simulazine__c.Classe_di_merito_altre_variabili__c', // EDB 2024-03-25
    'Simulazione__c.Classe_di_rischiosita__c',
    'Simulazione__c.Denominazione__c',
    'Simulazione__c.Segmento_di_Rischio__c',
    'Simulazione__c.Natura_Giuridica__c',
    'Simulazione__c.Giudizio_slotting_criteria__c',
    'Simulazione__c.Modello_di_Servizio__c',
    'Simulazione__c.Infrastructure_support_factor__c',
    //'Simulazione__c.Fatturato_di_gruppo__c',
    'Simulazione__c.Soglia_fatturato_di_gruppo__c', 
    'Simulazione__c.Modello_di_rating__c',
    'Simulazione__c.Provincia__c'
];//AD
export default class CibControparteSintesiSimulazione extends LightningElement {
    @track _id;
    set recordId(id) {
        this._id = id;
    }
    @api
    get recordId() {
        return this._id;
    }
    @track _fields=[
        /* AD vecchia struttura
        'NDG__c',
        'Classe_di_rating__c',
        'NDG_di_Gruppo__c',
        'Classe_di_rischiosita__c',
        'Denominazione__c',
        'Segmento_di_Rischio__c',
        'Natura_Giuridica__c',
        'Giudizio_slotting_criteria__c',
        'Modello_di_Servizio__c',
        //'Fatturato_di_gruppo__c',
        'Soglia_fatturato_di_gruppo__c',
        'Modello_di_rating__c',
        'Provincia__c',
        'Infrastructure_support_factor__c'*/

        //AD nuova struttura dati per il popolamento del tab Sintesi Simulazione
        {fieldName:'NDG__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'Classe_di_rating__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'NDG_di_Gruppo__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'Classe_di_merito_altre_variabili__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''}, // EDB 2024-03-25
        {fieldName:'Denominazione__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'Classe_di_rischiosita__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'Natura_Giuridica__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'Segmento_di_Rischio__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'Modello_di_Servizio__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'Giudizio_slotting_criteria__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'Modello_di_rating__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'Soglia_fatturato_di_gruppo__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'Infrastructure_support_factor__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''},
        {fieldName:'Provincia__c',value:'',isCustom:false,showLabel:true,isSeparator:false,label:''}
        //{isSeparator:true,showLabel:false,fieldName:'',value:'',isCustom:false,label:''},
    ];

    @api title;
    
    //AD
    //get fields : funzione che si occupa di popolare il 'value' e la 'label' dell'array json '_field'
    //             in base alla corrispondenza del 'fieldName' con i due array 'wiredSimulazione' e 'dataSimulazione'
    //             wiredSimulazione -> per il popolamento della label
    //             dataSimulazione  -> per il popolamento del   value
    get fields(){
        let newArray = [];
        if(this.wiredSimulazione && this.dataSimulazione){
            console.log('AD dati arrivati');

            if(Object.keys(this.dataSimulazione.fields).length==0){
                return newArray;
            }
            this._fields.forEach(element => {
                /*AD vecchia struttura
                let appoggio = { fieldName:element , value :'-'};
                appoggio.isBlank = this.dataSimulazione.fields[element].value == null || this.dataSimulazione.fields[element].value == undefined ;
                appoggio.label = this.wiredSimulazione.data.fields[element].label;
                newArray.push(appoggio);
                **/
                
                //AD nuova struttura
                let appoggio = {...element};

                //controllo la presenza se sono presenti i valori in base alla visibilità del campo sull'oggetto
                if(!this.dataSimulazione.fields[element.fieldName] && 
                    !this.wiredSimulazione.data.fields[element.fieldName] && !element.isSeparator){
                        element.isSeparator=true;
                }
                if(element.isSeparator){
                    appoggio.isCustom = true;
                    appoggio.showLabel = false;
                }else{
                    
                    appoggio.label = this.wiredSimulazione.data.fields[element.fieldName].label;
                    let dataType = this.wiredSimulazione.data.fields[element.fieldName].dataType;
                    
                    if(dataType==='Boolean'){
 
                        appoggio.value=(this.dataSimulazione.fields[element.fieldName].value) ? 'SI' : 'NO';
                        appoggio.isCustom = true; 

                    }else{

                        let filedPopulate = this.dataSimulazione.fields[element.fieldName].value;
                        if(filedPopulate == null || filedPopulate == undefined){
                            appoggio.value='-';
                            appoggio.isCustom = true;
                        }else{
                            appoggio.value = filedPopulate;
                        }

                    }

                }
                //fine nuova struttura
                newArray.push(appoggio);

            });
        }
        return newArray;
    }

    @track dataSimulazione;
    
    //AD 
    //wiredSimulazione : apiName dei campi dell'oggetto Simulazione__c
    @wire(getObjectInfo, { objectApiName: Simulazione_OBJECT })
    wiredSimulazione;
    
    //AD
    //dataSimulazione : dati del record Simulazione__c
    @wire(getRecord, { recordId: "$recordId", optionalFields:FIELDS })
    wiredRecord({error,data}){
       
        if(data){ 
            this.dataSimulazione = data;
        }else if(error){
            console.log('AD wiredRecord error : ' , error);
        }

    };


    
}