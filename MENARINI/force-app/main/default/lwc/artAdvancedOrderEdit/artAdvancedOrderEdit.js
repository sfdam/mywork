// LV 06-10-2023 DE-036

import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getRecord from '@salesforce/apex/ART_AdvancedOrderEditController.getRecord';
import saveRecord from '@salesforce/apex/ART_AdvancedOrderEditController.saveRecord'; 
import submitForApproval from '@salesforce/apex/ART_AdvancedOrderEditController.submitForApproval';
import ArtCustomMetadataLibrary from 'c/artCustomMetadataLibrary';
import INITIATOR from '@salesforce/label/cgcloud.INITIATOR';
import IDENTIFICATION from '@salesforce/label/cgcloud.IDENTIFICATION';
import Payment_Condition from '@salesforce/label/c.ART_Payment_Condition';
import CANCEL_ORDER from '@salesforce/label/cgcloud.CANCEL_ORDER';
import Submit_for_Approval from '@salesforce/label/cgcloud.Submit_for_Approval';
import Dilazione_Pagamento from '@salesforce/label/c.ART_Dilazione_Pagamento';
import SAVE from '@salesforce/label/cgcloud.SAVE';
import ORDER_EDIT from '@salesforce/label/cgcloud.ORDER_EDIT';
import ART_Error from '@salesforce/label/c.ART_Error';
import ART_Success from '@salesforce/label/c.ART_Success';
import ART_AdvancedOrderEdit_Canceled_Status from '@salesforce/label/c.ART_AdvancedOrderEdit_Canceled_Status';
import ART_AdvancedOrderEdit_Inviato_in_approvazione from '@salesforce/label/c.ART_AdvancedOrderEdit_Inviato_in_approvazione';
import ART_AdvancedOrderEdit_SuccessMsg from '@salesforce/label/c.ART_AdvancedOrderEdit_SuccessMsg';
// DE-082 Michele Barile - 07/06/2023
import ART_CustomerIdentificationCode from '@salesforce/label/c.ART_CustomerIdentificationCode';
import ART_PayerIdentificationCode from '@salesforce/label/c.ART_PayerIdentificationCode';
import ART_WholesalerIdentificationCode from '@salesforce/label/c.ART_WholesalerIdentificationCode';
import ART_DeliveryRecipientIdentificationCode from '@salesforce/label/c.ART_DeliveryRecipientIdentificationCode';
// end
// LV 06-10-2023 DE-036 start
import ART_Delivery_Note from '@salesforce/label/c.ART_Delivery_note';
import ART_Customer_Service_Note from '@salesforce/label/c.ART_Customer_Service_Note';
import ART_Riferimento_Contatto from '@salesforce/label/c.ART_Riferimento_Contatto';
import ART_Data_inizio from '@salesforce/label/c.ART_Data_inizio';
import ART_Data_fine from '@salesforce/label/c.ART_Data_fine';
import ART_Data_inizio_consegna from '@salesforce/label/c.ART_Data_inizio_consegna';
import ART_Data_fine_consegna from '@salesforce/label/c.ART_Data_fine_consegna';
import ART_Orario_inizio from '@salesforce/label/c.ART_Orario_inizio';
import ART_Orario_fine from '@salesforce/label/c.ART_Orario_fine';
import ART_Giorno_Settimanale from '@salesforce/label/c.ART_Giorno_Settimanale';
import ART_Total_Quantity from '@salesforce/label/c.ART_Total_Quantity';
import ART_NetValue from '@salesforce/label/c.ART_NetValue';
// LV 06-10-2023 DE-036 end
// Francesco Ivan Esposito - 19/06/2023
import LightningConfirm from 'lightning/confirm';
import { deleteReplicatedDataset } from 'lightning/analyticsWaveApi';
// end

// DK START DE-036 
import getPickListOptions from '@salesforce/apex/ART_AdvancedOrderEditController.getPickListOptions';

export default class ArtAdvancedOrderEdit extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordId;
    @api recordTypeId;

    
    @track layouts = [];
    @track record = {};
    @track layoutTypes = ["T"];
    @track picklistValue = "-- None --";
    @track mappingPaymentCondtion = {
        "Ordine Diretto Pharma":"cgcloud__Payer__r.ART_PaymentCondition_Farma__c",
        "Ordine Diretto Derma":"cgcloud__Payer__r.ART_PaymentCondition_Derma__c",
        "Ordine Diretto OTC":"cgcloud__Payer__r.ART_PaymentCondition_OTC__c"
    };
    @track currentObject;
    @track orderTemplate;
    @track orderTemplateFieldName;
    @track ART_PaymentConditionClassCode;
    @track flattenRecord;
    @track showButtons = false;
    buttonsVisibleFor = ["Initial","Rejected"];
    //DK EDIT - 30012023
    @track alwaysEditableFields = ["art_order_send_block__c"];
    //DK EDIT - 30012023
    @track title;
    @track isSpinner = false;
    @track mapDependency = new Map(); // LV 06-10-2023 DE-036

    label = {
        CANCEL_ORDER,
        IDENTIFICATION,
        INITIATOR,
        Payment_Condition,
        SAVE,
        Submit_for_Approval,
        Dilazione_Pagamento,
        ORDER_EDIT,
        ART_Error,
        ART_Success,
        ART_AdvancedOrderEdit_Canceled_Status,
        ART_AdvancedOrderEdit_Inviato_in_approvazione,
        ART_AdvancedOrderEdit_SuccessMsg,
        // DE-082 Michele Barile - 07/06/2023
        ART_CustomerIdentificationCode,
        ART_PayerIdentificationCode,
        ART_WholesalerIdentificationCode,
        ART_DeliveryRecipientIdentificationCode,
        // end
        // LV 06-10-2023 DE-036 start
        ART_Delivery_Note,
        ART_Customer_Service_Note,
        ART_Riferimento_Contatto,
        ART_Data_inizio,
        ART_Data_fine,
        ART_Data_inizio_consegna,
        ART_Data_fine_consegna,
        ART_Orario_inizio,
        ART_Orario_fine,
        ART_Giorno_Settimanale,
        ART_Total_Quantity,
        ART_NetValue,
        // LV 06-10-2023 DE-036 end
    }

    @track picklistOptionsMap = {};

    attributeDelayDaysValueMap = {
        'kam': ['30', '60', '90', '120', '150'],
        'yes': ['30', '60', '90', '120', '150'],
        'else': ['30', '60', '90']
    }

    async connectedCallback() {
        this.isSpinner = true;
        try {
            let _picklistOptions = [];
            _picklistOptions.push({
                label:"-- None --",
                value:"-- None --"
            });
            let response;
            response = await getRecord({recordId:this.recordId});
            this.picklistOptionsMap = await getPickListOptions();
            this.record = JSON.parse(JSON.stringify(response));
            console.log('Record '+JSON.stringify(this.record));
            this.flattenRecord = this.manageRecord(response)[0];
            console.log('Flatten '+JSON.stringify(this.flattenRecord));
            this.title = this.label.ORDER_EDIT+" "+(this.flattenRecord["cgcloud__Order_Id__c"]===undefined ? "" : this.flattenRecord["cgcloud__Order_Id__c"]);
            response = await ArtCustomMetadataLibrary.getMapByMetadataName("ART_AdvancedOrderLayout__mdt");
            console.log('DK response:', response);
            let key = (this.layoutTypes.includes(this.flattenRecord.ART_Order_Type__c) ? "AdvancedOrderType_"+this.flattenRecord.ART_Order_Type__c : "Base");
            console.log('DK key:', key);
            let left_column = response[key].left_column__c;
            let right_column =  response[key].right_column__c;
            this.orderTemplate = this.flattenRecord["cgcloud__Order_Template__r.Name"];
            if (this.mappingPaymentCondtion[this.orderTemplate]!=undefined) {
                this.orderTemplateFieldName = this.mappingPaymentCondtion[this.orderTemplate];
                let value=this.flattenRecord[this.orderTemplateFieldName];
                let values = (value===undefined ? "NULL" : "\'"+value+"\'");
                let whereCondition = " WHERE ART_PaymentConditionName__c = "+values;
                response = await ArtCustomMetadataLibrary.makeMetadataQueryWithFields("ART_PaymentConditions__mdt",whereCondition,["ART_PaymentConditionClassCode__c","ART_PaymentConditionName__c"]);
                if (response.length>0) {
                    if (response[0]["ART_PaymentConditionClassCode__c"]!==undefined) {
                        this.ART_PaymentConditionClassCode = response[0]["ART_PaymentConditionClassCode__c"];
                        values = "\'"+this.ART_PaymentConditionClassCode+"\'";
                    } else {
                        this.ART_PaymentConditionClassCode = undefined;
                        values = "NULL";
                    }
                    whereCondition = " WHERE ART_PaymentConditionClassCode__c = "+values+" ORDER BY ART_DelayDay__c ASC";
                    response = await ArtCustomMetadataLibrary.makeMetadataQueryWithFields("ART_PaymentConditions__mdt",whereCondition,["ART_DelayDay__c","ART_PaymentConditionClassCode__c"]);
                    /* alessandro di nardo @ten 04/08/2023*/
                    response.forEach(el =>{
                        /*if(this.orderTemplate == "Ordine Diretto Pharma" && el.ART_DelayDay__c.toString() == '120'){
                            return;
                        }*/
                        if(this.orderTemplate == "Ordine Diretto Pharma"){
                            let attribute1 = this.flattenRecord['cgcloud__Order_Account__r.ART_Attribute1__c'];
                            console.log('DK de-116 el.ART_DelayDay__c.toString()', el.ART_DelayDay__c.toString());
                            console.log('DK de-116 attribute1', attribute1);
                            console.log('DK de-116 this.attributeDelayDaysValueMap[attribute1]', this.attributeDelayDaysValueMap[attribute1]);
                            //escludi dalla picklist se attribute1 è una chiave presente nella mappa ed il valore non è tra quelli indicati 
                            if(attribute1 && this.attributeDelayDaysValueMap[attribute1] && !this.attributeDelayDaysValueMap[attribute1].includes(el.ART_DelayDay__c.toString())){
                                return;
                            //escludi dalla picklist se attribute1 è vuoto o non è una chiave presente nella mappa ed il valore non è tra quelli indicati per la chiave els 
                            }else if((!attribute1 || (attribute1 && !this.attributeDelayDaysValueMap[attribute1]))
                             && !this.attributeDelayDaysValueMap['else'].includes(el.ART_DelayDay__c.toString())){
                                return;
                            }
                            
                        }
                        _picklistOptions.push({
                            label:el.ART_DelayDay__c.toString(),
                            value:el.ART_DelayDay__c.toString()
                        });
                    });
                }
                this.picklistOptionsMap['art_delay_days__c'] = _picklistOptions;
            }
            // DK EDIT Fix UI AdvancedOrder - 30012023
            let hasAlwaysEditableFields = false;
            for(var i in this.alwaysEditableFields){
                if(left_column.toLowerCase().includes(this.alwaysEditableFields[i].toLowerCase()) || right_column.toLowerCase().includes(this.alwaysEditableFields[i].toLowerCase())){
                    hasAlwaysEditableFields = true;
                    break;
                }
            }
            this.showButtons = this.buttonsVisibleFor.includes(this.flattenRecord["cgcloud__Phase__c"]);
            left_column = this.manageLayout(left_column,this.flattenRecord,this.mappingPaymentCondtion); 
            right_column = this.manageLayout(right_column,this.flattenRecord,this.mappingPaymentCondtion);

            console.log('left_column: ', left_column);
            console.log('right_column: ', right_column);
            // DK EDIT Fix UI AdvancedOrder - 30012023
            this.layouts.push({
                key:"left_layout",
                items:left_column
            });
            this.layouts.push({
                key:"right_layout",
                items:right_column
            });
            
            this.isSpinner = false;
        } catch(e) {
            let errMessage = (e.message!==undefined ? e.message : (e.body!==undefined && e.body.message!==undefined ? e.body.message : e.toString()));
            this.displayToast(this.label.ART_Error,errMessage,"error","sticky");
        }
    }

    handleError(e) {
        let errMessage = (e.message!==undefined ? e.message : (e.body!==undefined && e.body.message!==undefined ? e.body.message : e.toString()));
        this.displayToast(this.label.ART_Error,errMessage,"error","sticky");
    }

    manageRecord(r) {
        return this.flattenQueryResult(r);
    }

    manageLayout(r,record,mappingPaymentCondtion) {
        r = (r==undefined ? [] : JSON.parse(r));
        r.forEach((el,idx) =>{
            el.hidden = (el.hidden===undefined ? false : el.hidden);
            el.inputClass = "slds-form-element__control";
            el["value"] = record[el.fieldName];
            // el["isText"] = (el["isText"]==undefined ? false : el.isText);
            el["isPicklist"] = (el["isPicklist"]==undefined ? false : el.isPicklist);
            el["isMultiPicklist"] = (el["isMultiPicklist"]==undefined ? false : el.isMultiPicklist);
            el["picklistOptions"] = this.picklistOptionsMap[el.fieldName.toLowerCase()];
            el["showLabel"] = (el["showLabel"]==undefined ? true : el["showLabel"]);
            el["labelClass"] = 'slds-form-element__label';
            el["cssClassFormElement"] = el["showLabel"]  ? 'slds-form-element slds-form-element_stacked slds-input_height' : 'slds-form-element slds-form-element_stacked noLabelMargin';
            let fieldName = el.fieldName;
            if (!this.showButtons && !this.alwaysEditableFields.includes(fieldName.toLowerCase())) {
                el.editable = false;
            }
            // LV 06-10-2023 DE-036 start
            if (el.dependency!==undefined) {
                let valueDependent = record[el.dependency];
                if (!this.mapDependency.has(el.dependency)) {
                    this.mapDependency.set(el.dependency, new Map());
                }
                if(!this.mapDependency.get(el.dependency).has(el.valueDependent)){
                    this.mapDependency.get(el.dependency).set(el.valueDependent, []);
                }
                this.mapDependency.get(el.dependency).get(el.valueDependent).push(el);
                console.log('DK manageLayout.valueDependent: ', valueDependent);
                console.log('DK manageLayout.el.valueDependent: ', el.valueDependent);
                el.hidden = valueDependent ? !valueDependent.includes(el.valueDependent) : true;
            }
            // LV 06-10-2023 DE-036 end
            
            if (fieldName==="payment_condition") {
                if (mappingPaymentCondtion[this.orderTemplate]!=undefined) {
                    el.value=record[this.orderTemplateFieldName];
                }
                el.hidden = this.orderTemplate==="Transfer Order";
            } else if (fieldName==="ART_Delay_days__c") {
                el.hidden = this.orderTemplate==="Transfer Order";
                el.value = el.value ? el.value : '-- None --';
            } else {
                el.value= !record[fieldName] ? null : el.isMultiPicklist && el.editable ? record[fieldName].split(';') : record[fieldName];
            }

            el.labelVariant = this.label[el.label] && el.showLabel ? 'label-hidden' : 'label-stacked';
            el.showLabel = this.label[el.label] ? true : false;
            el.label = this.label[el.label] ? this.label[el.label] : el.label;
            if (el.custom) {
                if ((el.value===undefined || el.value==="")  && !el.editable) {
                    el.inputClass += " slds-input_height";
                }
            }
            console.log('ivan', this.record);
            //DE-010B 22/06/2023
            if (el.fieldName === 'ART_CIG_Code__c') {
                if ( ((this.record.cgcloud__Order_Account__r.hasOwnProperty('THR_CustomerSubcategory__c') && this.record.cgcloud__Order_Account__r.THR_CustomerSubcategory__c == '015') || (this.record.cgcloud__Payer__r.hasOwnProperty('THR_CUU__c') && this.record.cgcloud__Payer__r.THR_CUU__c.length == 6))
                    && this.record.cgcloud__Order_Template__r.Name != 'Transfer Order' ) // DE-114 - 10/04/24
                    el.required = true;
            }
            // END
            el.labelClass += el.required ? ' required' : '';
            el.isNumber = el.isNumber !== undefined ? el.isNumber : (typeof el.value) == 'number';
            el.minFractionDigits = Number.isInteger(el.value) ? 0 : 2;
            el.isText = !el.isNumber;
            console.log('Element : ', el);
        });

        console.log('LV mapDependency', this.mapDependency);

        return r;
    }

    flattenQueryResult(listOfObjects) {
        if(!Array.isArray(listOfObjects)) {
            var listOfObjects = [listOfObjects];
        }
        
        console.log('List of Objects is now....');
        console.log(listOfObjects);
        for(var i = 0; i < listOfObjects.length; i++) {
            var obj = listOfObjects[i];
            for(var prop in obj) {      
                if (!obj.hasOwnProperty(prop)) continue;
                if (typeof obj[prop] == 'object' && typeof obj[prop] != 'Array') {
                    obj = Object.assign(obj, this.flattenObject(prop,obj[prop]));
                }
                else if(typeof obj[prop] == 'Array') {
                    for(var j = 0; j < obj[prop].length; j++) {
                        obj[prop+'.'+j] = Object.assign(obj,this.flattenObject(prop,obj[prop]));
                    }
                }
            }
        }

        console.log('DK listOfObjects', listOfObjects);
        return listOfObjects;
    }

    flattenObject(propName, obj){
        var flatObject = [];
        
        for(var prop in obj) {
            //if this property is an object, we need to flatten again
            var propIsNumber = isNaN(propName);
            var preAppend = propIsNumber ? propName+'.' : '';
            if(typeof obj[prop] == 'object') {
                flatObject[preAppend+prop] = Object.assign(flatObject, this.flattenObject(preAppend+prop,obj[prop]));
            }    
            else {
                flatObject[preAppend+prop] = obj[prop];
            }
        }
        return flatObject;
    }

    async handleSave(event) {
        this.isSpinner = true;
        try {
            await this.validation("save");
            this.isSpinner = false;
            this.displayToast(this.label.ART_Success,this.label.ART_AdvancedOrderEdit_SuccessMsg,"success","dismissible");
            getRecordNotifyChange([{recordId: this.recordId}]);
            this.navigateToRecord(this.record.Id);
        } catch(e) {
            this.isSpinner = false;
            let errMessage = (e.message!==undefined ? e.message : (e.body!==undefined && e.body.message!==undefined ? e.body.message : e.toString()));
            this.displayToast(this.label.ART_Error,errMessage,"error","sticky");
        }
    }

    // Francesco Ivan Esposito - 19/06/2023
    handleNullPicklist(event) {
        console.log('Ivan ' + this.record.ART_Delay_days__c);
        //this.record.ART_Delay_days__c = event.detail.value === "-- None --" ? null : event.detail.value;
        if (this.orderTemplate !== 'Transfer Order' && this.record.ART_Delay_days__c == null) {
            this.handlePicklistNull();
        }else {
            this.handleSubmitForApproval();
        }   
        }
      
    async handlePicklistNull() {
        const result = await LightningConfirm.open({ 
        message: '                                    La dilazione di pagamento non è stata definita, procedere ugualmente?',
        variant: 'header',
        label: 'Si prega di confermare',
        theme: 'error'
        });
        if(result === true){ 
            this.handleSubmitForApproval();
        } 
        }
    
    async handleSubmitForApproval(){
        this.isSpinner = true;
        try {
            await this.validation("approval");
            this.isSpinner = false;
            this.displayToast(this.label.ART_Success, this.label.ART_AdvancedOrderEdit_Inviato_in_approvazione, "success", "dismissible");
            getRecordNotifyChange([{recordId: this.recordId}]);
            this.navigateToRecord(this.record.Id);
            } catch(e) {
            this.isSpinner = false;
            let errMessage = e.message !== undefined ? e.message : (e.body !== undefined && e.body.message !== undefined ? e.body.message : e.toString());
            this.displayToast(this.label.ART_Error, errMessage, "error", "sticky");
            }
    }
      
    // end

    handelCancelOrder(event) {
        this.isSpinner = true;
        this.record["cgcloud__Phase__c"] = "Canceled";
        console.log('DK handelCancelOrder_this.record: ' + JSON.stringify(this.record));
        let parsedValue = Number(parseFloat(this.record.cgcloud__Value__c).toFixed(2));
        let parsedGrossValue = Number(parseFloat(this.record.cgcloud__Gross_Total_Value__c).toFixed(2));
        this.record.cgcloud__Value__c = parsedValue;
        this.record.cgcloud__Gross_Total_Value__c = parsedGrossValue;
        console.log('DK handelCancelOrder_this.record to CANCEL: ' + JSON.stringify(this.record));
        saveRecord({record:this.record,method:"save"}).then(r=>{
            this.record = JSON.parse(JSON.stringify(r));
            this.isSpinner = false;
            this.displayToast(this.label.ART_Success,this.label.ART_AdvancedOrderEdit_Canceled_Status,"success","dismissible");
            getRecordNotifyChange([{recordId: this.recordId}]);
            this.navigateToRecord(this.record.Id);
        }).catch(e=>{
            this.isSpinner = false;
            let errMessage = (e.message!==undefined ? e.message : (e.body!==undefined && e.body.message!==undefined ? e.body.message : e.toString()));
            this.displayToast(this.label.ART_Error,errMessage,"error","sticky");
        });
    }

    handleChangePicklist(event) {
        try{
            let picklistValues = [...event.detail.value];
            let picklistValuesJoin = picklistValues.join(';');
            
            // let picklistValue = (typeof event.detail.value) == 'string' ? event.detail.value : event.detail.value.join(';');
            console.log('DK handleChangePicklist.event.detail.value', event.detail.value);
            console.log('DK handleChangePicklist.event.target', JSON.stringify(event.target.name));
            let changedPicklist = event.target.name;
            if(event.detail.value==="-- None --")this.record[changedPicklist]=null;
            if(this.mapDependency.has(changedPicklist)){
                
                if(picklistValues.length == 0){
                    this.layouts.forEach(column =>{
                        for(var i=0; i < column.items.length; i++){
                            if(column.items[i].dependency == changedPicklist){
                                column.items[i].hidden = true;
                            }
                        }
                    });
                }else{

                    picklistValues.forEach(picklistValue =>{
                        /*if(!this.mapDependency.get(changedPicklist).has(picklistValue)){
                            //selezionato un valorer che non ha dependency
                            //togliere tutti i campi con stessa dependency da layouts 
                            this.layouts.forEach(column =>{
                                let fieldsColonna = column.items.map(field => field.fieldName);
                                if(fieldsColonna.includes(changedPicklist)){
                                    for(var i=0; i < column.items.length; i++){
                                        if(column.items[i].dependency == changedPicklist && picklistValue == column.items[i].valueDependent){
                                            column.items[i].hidden = true;
                                        }
                                    }
                                }
                            });
                        }else{*/
                            //selezionato un valore che ha dependency
                            //togliere tutti i campi con stessa dependency da layouts
                            //aggiunta campi dependency
                            this.layouts.forEach(column =>{
                                //set con tutti field name dei campi presenti in colonna
                                let fieldsColonna = column.items.map(field => field.fieldName);
                                if(fieldsColonna.includes(changedPicklist)){
                                    if(this.mapDependency.get(changedPicklist).has(picklistValue)){
                                        // aggiungo nella stessa colonna del campo dependency
                                        this.mapDependency.get(changedPicklist).get(picklistValue).forEach(field =>{
                                            for(var i=0; i < column.items.length; i++){
                                                if(column.items[i].fieldName == field.fieldName){
                                                    column.items[i].hidden = false;
                                                    continue;
                                                }else if(column.items[i].dependency == changedPicklist && !picklistValuesJoin.includes(column.items[i].valueDependent)){
                                                    column.items[i].hidden = true;
                                                }
                                            }
                                        });
                                    }
                                }
                            });
                        // }
                    });
                }
            }
        }
        catch (error) {
           console.log('LV error', error);
        }
    }

    displayToast(title,message,variant,mode) {
        const evt = new ShowToastEvent({
            title:title,
            message:message,
            variant:variant,
            mode:mode
        });
        this.dispatchEvent(evt);
    }

    async validation(method) {
        let existsError = false;
        let fieldValidationError;
        let input_fields = this.template.querySelectorAll('[data-id="input_field"]');
        let today = new Date();
        let dataInizioConsegna;
        let dataInizio;
        for (let i=0; i<input_fields.length; i++) {
            if(input_fields[i].dataset.fieldname == 'ART_Data_inizio_consegna__c'){
                dataInizioConsegna = input_fields[i].value;
            }
            if(input_fields[i].dataset.fieldname == 'ART_Data_inizio__c'){
                dataInizio = input_fields[i].value;
            }
            if(dataInizioConsegna && dataInizio){
                break;
            }
        }
        console.log('DK validation dataInizioConsegna: ', dataInizioConsegna);
        console.log('DK validation dataInizio: ', dataInizio);
        let whereCondition;
        let fields = ["ART_PaymentConditionCode__c","ART_PaymentConditionClassCode__c","ART_DelayDay__c","ART_PaymentConditionName__c "];
        try {
            for (let i=0; i<input_fields.length; i++) {
                let el = input_fields[i];
                if (el.dataset.fieldname!=undefined) {
                    let fieldName = el.dataset["fieldname"];
                    if (el.required && !el.hidden && (el.value===undefined || el.value==="" || el.value===null)) {
                        existsError = true;
                        break;
                    }else if(fieldName == 'ART_Data_fine_consegna__c' &&  el.value < dataInizioConsegna){
                        existsError = true;
                        fieldValidationError = 'Data fine consegna deve essere maggiore di Data inizio consegna';
                        break;
                    }else if(fieldName == 'ART_Data_fine__c' &&  el.value < dataInizio){
                        existsError = true;
                        fieldValidationError = 'Data fine deve essere maggiore di Data inizio';
                        break;
                    }else{
                        console.log('DK validation_field:', fieldName);
                        if (fieldName==="ART_Delay_days__c") {
                            if (el.value=="-- None --") {
                                whereCondition = " WHERE ART_PaymentConditionName__c=\'"+this.flattenRecord[this.orderTemplateFieldName]+"\'";
                            } else {
                                whereCondition = " WHERE ART_PaymentConditionClassCode__c=\'"+this.ART_PaymentConditionClassCode+"\' AND ART_DelayDay__c="+el.value;
                            }
                        
                            let response = await ArtCustomMetadataLibrary.makeMetadataQueryWithFields("ART_PaymentConditions__mdt",whereCondition,fields);
                            if (response.length>0) {
                                this.record["ART_Payment_Code__c"] = response[0].ART_PaymentConditionCode__c;
                                this.record[fieldName] = (el.value===undefined || el.value==="" || el.value==="-- None --" ? null : el.value);
                            }
                        } else {
                            this.record[fieldName] = (el.value===undefined || el.value==="" ? null : el.value);
                        }
                    }
                }
            }
            if (!existsError) {
                if(this.record.cgcloud__Gross_Total_Value__c != undefined && this.record.cgcloud__Gross_Total_Value__c != null){
                    let fixedTotal = Number(this.record.cgcloud__Gross_Total_Value__c);
                    this.record.cgcloud__Gross_Total_Value__c = Number(fixedTotal);
                }
                if(this.record.cgcloud__Value__c != undefined && this.record.cgcloud__Value__c != null){
                    let fixedTotal = Number(this.record.cgcloud__Value__c);
                    this.record.cgcloud__Value__c = Number(fixedTotal);
                }
                if (method==="save") {
                    await saveRecord({record:this.record});
                } else if (method==="approval") {
                    // DK EDIT Fix UI AdvancedOrder - 30012023
                    if(!Boolean(this.record['cgcloud__Wholesaler__c']) && this.orderTemplate==='Transfer Order'){
                        throw new Error('Selezionare Wholesaler prima di mandare in approvazione');
                    }
                    if(this.record?.ART_OrderItemRowsCount__c<=0){
                        throw new Error('Inserire almeno una referenza per la creazione dell\'ordine.');
                    }
                    await submitForApproval({record:this.record});
                    // DK EDIT Fix UI AdvancedOrder - 30012023
                }
            } else {

                throw new Error(fieldValidationError ? fieldValidationError : 'Esistono dei campi obbligatori non popolati');
            }
        } catch(exc) {
            throw exc;
        }
    }

    isAfterToday(date) {
        return new Date(date).valueOf() > new Date().valueOf();
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }
}