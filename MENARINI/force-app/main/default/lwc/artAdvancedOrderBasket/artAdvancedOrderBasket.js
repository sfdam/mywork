import { LightningElement,api, wire,track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

import fetchCloudOrderItems from '@salesforce/apex/ART_AdvancedOrderBasketController.fetchCloudOrderItems';
import deleteCloudOrderItem from '@salesforce/apex/ART_AdvancedOrderBasketController.deleteCloudOrderItem';
import getRecord from '@salesforce/apex/ART_AdvancedOrderEditController.getRecord';
import getProduct from '@salesforce/apex/ART_AdvancedOrderBasketController.getProduct';
import saveProduct from '@salesforce/apex/ART_AdvancedOrderBasketController.saveProduct';
import cloneOrder from '@salesforce/apex/ART_AdvancedOrderBasketController.cloneOrder';
// DK START DE-033A Bis
import getBundleDiscounts from '@salesforce/apex/ART_AdvancedOrderBasketController.getBundleDiscounts';
// DK END DE-033A Bis
import getOrderListFilter from '@salesforce/apex/ART_AdvancedOrderBasketController.getOrderListFilter';//Alessandro Di Nardo @ten 2023-08-24
import getOrderItemsToClone from '@salesforce/apex/ART_AdvancedOrderBasketController.getOrderItemsToClone';//Alessandro Di Nardo @ten 2023-08-24

import ADD_PRODUCTS from '@salesforce/label/cgcloud.ADD_PRODUCTS';
import ART_Advance_Order_Items from '@salesforce/label/c.ART_Advance_Order_Items';
import ART_Total_Records from '@salesforce/label/c.ART_Total_Records';
import ART_Pagine from '@salesforce/label/c.ART_Pagine';
import Art_di from '@salesforce/label/c.Art_di';
import ART_Remove from '@salesforce/label/c.ART_Remove';
import ART_Action from '@salesforce/label/c.ART_Action';
import ART_Quantity from '@salesforce/label/c.ART_Quantity';
import ART_Product_Description from '@salesforce/label/c.ART_Product_Description';
import ART_Material_Code from '@salesforce/label/c.ART_Material_Code';
import ART_Discount from '@salesforce/label/c.ART_Discount';
import ART_Price from '@salesforce/label/c.ART_Price';
import ART_Value from '@salesforce/label/c.ART_Value';
import ART_First from '@salesforce/label/c.ART_First';
import ART_Previous from '@salesforce/label/c.ART_Previous';
import ART_Next from '@salesforce/label/c.ART_Next';
import ART_Last from '@salesforce/label/c.ART_Last';
import ART_Public_Price from '@salesforce/label/c.ART_Public_Price';
import ART_DiscountSegment from '@salesforce/label/c.ART_DiscountSegment'; // LV 2023-03-14 DE-014/DE-029
import ART_IndustryStandard from '@salesforce/label/c.ART_IndustryStandard'; // LV 2023-03-14 DE-014/DE-029

import ART_NetValue from '@salesforce/label/c.ART_NetValue'; //AD 2023-08-21 @ten
import ART_Total_Quantity from '@salesforce/label/c.ART_Total_Quantity'; //AD 2023-08-21 @ten

import ART_AddFromAnotherOrder from '@salesforce/label/c.ART_AddFromAnotherOrder'; //DK START DE-041/042
import ART_Copy from '@salesforce/label/c.ART_Copy'; //DK START DE-041/042
import ART_Unit_Price from '@salesforce/label/c.ART_Unit_Price'; //AD 2023-10-02 @ten
import ART_Ex_Factory_Price from '@salesforce/label/c.ART_Ex_Factory_Price'; //AD 2023-10-02 @ten

import ART_TotalReferences from '@salesforce/label/c.ART_TotalReferences'; //AD 2023-10-02 @ten
import ART_OrderCopy from '@salesforce/label/c.ART_OrderCopy'; //AD 2023-10-02 @ten
const actions = [
    { label: 'Remove', name: 'remove' },
];

import orderItemDelete from '@salesforce/apex/ART_AdvancedOrderBasketController.orderItemDelete'; // AL 2024-04-08 - Aggiunta metodo orderItemDelete della classe ART_AdvancedOrderBasketController

export default class ArtAdvancedOrderBasket extends NavigationMixin(LightningElement) {

    label = {
        ADD_PRODUCTS,
        ART_Advance_Order_Items,
        ART_Total_Records,
        ART_Pagine,
        Art_di,
        ART_Remove,
        ART_Action,
        ART_Quantity,
        ART_Product_Description,
        ART_Material_Code,
        ART_Discount,
        ART_Price,
        ART_Value,
        ART_First,
        ART_Previous,
        ART_Next,
        ART_Last,
        ART_Public_Price,
        ART_DiscountSegment, // LV 2023-03-14 DE-014/DE-029
        ART_IndustryStandard, // LV 2023-03-14 DE-014/DE-029
        ART_NetValue,//AD 2023-08-21 @ten
        ART_Total_Quantity,//AD 2023-08-21 @ten
        ART_AddFromAnotherOrder,//DK START DE-041/042
        ART_Unit_Price , //AD DE 089
        ART_Ex_Factory_Price,//AD DE 089
        ART_Copy,//DK DE-041/042
        ART_TotalReferences,//DK DE-041/042
        ART_OrderCopy,//DK DE-041/042
    }
    // JS Properties 
    pageSizeOptions = [30]; //Page size options
    records = []; //All records available in the data table
    //columns information available in the data table

    @track columns = [
        { label: this.label.ART_IndustryStandard, fieldName: 'THR_IndustryStandard__c', sortable: "true",initialWidth: 110},
        { label: this.label.ART_DiscountSegment, fieldName: 'THR_DiscountSegment__c', sortable: "true",initialWidth: 160}, // LV 2023-03-14 DE-014/DE-029
        { label: this.label.ART_Product_Description, fieldName: 'cgcloud__ProductName', sortable: "true" },
        { label: this.label.ART_Material_Code, fieldName: 'cgcloud__ProductCode', sortable: "true" },
        { label: this.label.ART_Quantity, fieldName: 'cgcloud__Quantity__c', sortable: "true", type: 'number'},
        { label: this.label.ART_Unit_Price, fieldName: 'cgcloud__Price__c', sortable: "true", type: 'currency', typeAttributes: { maximumFractionDigits: '2'}, cellAttributes: { alignment: 'left' }},
        { label: this.label.ART_Discount, fieldName: 'cgcloud__Discount__c', sortable: "true" },
        { label: this.label.ART_Value, fieldName: 'cgcloud__Value__c', sortable: "true", type: 'currency', typeAttributes: { maximumFractionDigits: '2'}, cellAttributes: { alignment: 'left' }}
    ]; 
    //columns in Modal information available in the data table
    @track columnsModal = [
        { label: this.label.ART_IndustryStandard, fieldName: 'THR_IndustryStandard__c', sortable: "true",initialWidth: 110}, // LV 2023-03-14 DE-014/DE-029
        { label: this.label.ART_DiscountSegment, fieldName: 'THR_DiscountSegment__c', sortable: "true",initialWidth: 160}, // LV 2023-03-14 DE-014/DE-029
        { label: this.label.ART_Product_Description, fieldName: 'cgcloud__ProductName', sortable: "true"},
        { label: this.label.ART_Material_Code, fieldName: 'cgcloud__ProductCode', sortable: "true"},
        { label: this.label.ART_Quantity, fieldName: 'cgcloud__Quantity__c', sortable: "true", type: 'number', editable: true, cellAttributes:{class:{fieldName: 'typeCSSClass' }}},
        { label: this.label.ART_Ex_Factory_Price, fieldName: 'cgcloud__Price__c', sortable: "true", type: 'currency', typeAttributes: { maximumFractionDigits: '2'}, cellAttributes: { alignment: 'left' }},
        { label: this.label.ART_Discount, fieldName: 'cgcloud__Discount__c', sortable: "true", editable: { fieldName: 'editableField'}, cellAttributes:{class:{fieldName: 'typeCSSClassDiscount' }}}
        //AD DE 089,{ label: this.label.ART_Public_Price, fieldName: 'cgcloud__Value__c', sortable: "true" , type: 'currency', typeAttributes: { maximumFractionDigits: '2'}, cellAttributes: { alignment: 'left' }}
    ];

    totalReferenze =0;//AD 
    totalFIR1 =0;//AD 
    totalLUS1 =0;//AD 
    totalGDT1 =0;//AD 
    totalMEN1 =0;//AD 
    totalMLS1 =0;//AD 
    showCounters=false;
    totalQuantity = 0; //alessandro di nardo @ten
    valueRecipt = 0; //alessandro di nardo @ten
    totalRecords = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
    recordsToDisplay = []; //Records to be displayed on the page
    isLoading = true;
    @api recordId;
    @api objectApiName;
    @track showAddProducts = false;
    @api openmodel = false;
    @track finalStep = true;
    @track recordInfo;
    @track columnsAdded = false;
    
    // AL 2024-04-08 -- Aggiunnta di selectRecordsAction 
    @api
    actionDeleteChosenRecord() {
        console.log('ELIMINA RECS');
        let datatable= this.template.querySelector("lightning-datatable");
        console.log('DT ' +datatable);
        let chosenRecordsToDelete =datatable.getSelectedRows();
        console.log('QUELLI SELEZIONATI SONO ' + JSON.stringify(chosenRecordsToDelete));


        // row all'inizio equivale alla singola riga da cancellare
        // va reso bulk 
        // dove trovi row.Id sostituisci con set di tutti gli id che si stanno cancellando
        if(chosenRecordsToDelete.length > 0){

            let rowIdSet = chosenRecordsToDelete.map(element => element.Id);
            this.isLoading = true;
            // DK aggiunta ricalcolo discount on delete
            let orderItemQuantityMap = {};
            let recordsToUpdate = [];
            this.records.forEach(obj => {
                if(!rowIdSet.includes(obj.Id)){
                    this.currentProdMap.set(obj.cgcloud__Product__c, obj);
                    orderItemQuantityMap[obj.cgcloud__Product__c] = obj.cgcloud__Quantity__c;
                }
            });
    
            let filterMap = {
                'ART_Rural__c' : this.recordInfo.cgcloud__Order_Account__r.ART_Rural__c ? 'Rural' : 'NON Rural',
                'THR_AccountGroup__c' : this.recordInfo.cgcloud__Order_Account__r.THR_AccountGroup__c,
                'ART_Customer_SubCategory_Description__c' : this.recordInfo.cgcloud__Order_Account__r.ART_Customer_SubCategory_Description__c
            };
            console.log('DK filterMap:', filterMap);
            getBundleDiscounts({orderItemQuantityMapJSON: JSON.stringify(orderItemQuantityMap), orderTemplateId: this.recordInfo.cgcloud__Order_Template__c, filterMapJSON: JSON.stringify(filterMap)})
            .then(result =>{
                let productResponseMap =  result.productResponseMap;
                this.errors.table = null;
                this.errors.rows = {};
                this.errors = {...this.errors}
                let discountToResetSet = [];
                let discountToUpdateSet = [];
                let scontoLeggeSet = [];
                let changedDiscount = [];
                this.currentProdMap.forEach(orderItem =>{
                    if(!rowIdSet.includes(orderItem.Id)){
                        let canHaveDiscount = false;
                        let bundleKeys = Object.keys(result.bundlesMap);
                        for(var k = 0; k < bundleKeys.length; k++){
                            let bundleId = bundleKeys[k];
                            let countset = 0;
                            if(result.bundlesMap[bundleId].productSet.includes(orderItem.cgcloud__Product__c)){
                                // record non modificato in linea che ha bundle
                                console.log('DK this.currentProdMap.productResponseMap[orderItem.cgcloud__Product__c]:', productResponseMap[orderItem.cgcloud__Product__c]);
                                let discountSet = false;
                                let countDiscountSet = 0;
                                for(var i = 0; i< Object.keys(productResponseMap[orderItem.cgcloud__Product__c]).length; i++){
                                    let range = Object.keys(productResponseMap[orderItem.cgcloud__Product__c])[i];
                                    let from = parseInt(range.split('_')[0]);
                                    let to = parseInt(range.split('_')[1]);
                                    let bundle = range.split('_')[2];
                                    let quantity = 0;
                                    console.log('DK this.currentProdMap.range: ' + range);
                                    result.bundlesMap[bundle].productSet.forEach(productId =>{
                                        if(orderItemQuantityMap[productId]){
                                            quantity += orderItemQuantityMap[productId];
                                        }
                                    })
                                    console.log('DK this.currentProdMap.quantity: ' + quantity);
                                    if(quantity >= from && quantity <= to){
                                        if(orderItem.cgcloud__Discount__c != productResponseMap[orderItem.cgcloud__Product__c][range]){
            
                                            orderItem.cgcloud__Discount__c = productResponseMap[orderItem.cgcloud__Product__c][range];
                                            countDiscountSet++;
                                            discountSet = true;
                                            discountToUpdateSet.push(orderItem.cgcloud__ProductCode);
                                        }
                                        canHaveDiscount = true;
                                        break;
                                    }
                                }
                                console.log('DK this.currentProdMap.countDiscountSet: ' + countDiscountSet);
                                console.log('DK this.currentProdMap.discountSet: ' + discountSet);
                                if(discountSet){
                                    recordsToUpdate.push(orderItem);
                                    countset++;
                                    break;
                                }
                            }
                            console.log('DK countset: ' + countset);
                        }
                        console.log('DK canHaveDiscount', canHaveDiscount);
                        console.log('DK orderItem.cgcloud__Discount__c > 0', orderItem.cgcloud__Discount__c > 0);
                        console.log('DK orderItem.cgcloud__ProductCode: ' + orderItem.cgcloud__ProductCode);
                        console.log('DK orderItem.THR_ZLAW__c: ' + orderItem.THR_ZLAW__c);
                        // DK DE-069 START
                        if(!canHaveDiscount && this.recordInfo.cgcloud__Order_Template__r.Name == 'Ordine Diretto Pharma'){
                            console.log('Set ZLWA 1');
                            if(orderItem.cgcloud__Discount__c != orderItem.THR_ZLAW__c){
                                changedDiscount.push(orderItem.cgcloud__ProductCode);
                            }
                            orderItem.cgcloud__Discount__c = orderItem.THR_ZLAW__c;
                            recordsToUpdate.push(orderItem);
                            scontoLeggeSet.push(orderItem.cgcloud__ProductCode);
                        }
                        // DK DE-069 END
                        // !canHaveDiscount && orderItem.cgcloud__Discount__c > 0 && !recordsToUpdateMap.includes(orderItem.cgcloud__Product__c) && orderItem.THR_ZLAW__c != orderItem.cgcloud__Discount__c && orderItem.cgcloud__Quantity__c > 0
                        else if(!canHaveDiscount && orderItem.cgcloud__Discount__c > 0 && orderItem.THR_ZLAW__c != orderItem.cgcloud__Discount__c){
                            discountToResetSet.push(orderItem.cgcloud__ProductCode);
                            orderItem.cgcloud__Discount__c = 0;
                            recordsToUpdate.push(orderItem);
                        }
                    }
                })
                console.log('DK handleRowActions.recordsToUpdate', recordsToUpdate);
                if(discountToResetSet.length > 0){
                    console.log('DK RESET2');
                    let productCodes = discountToResetSet.join(', ')
                    const event = new ShowToastEvent({
                        title: 'Reset di discount',
                        message: 'I prodotti con codice ' + productCodes + ' hanno subito un reset del discount in quanto non sono più presenti in Bundle attivi ',
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(event);
                }
                if(discountToUpdateSet.length > 0){
                    console.log('DK UPDATE2');
                    let productCodes = discountToUpdateSet.join(', ')
                    const event = new ShowToastEvent({
                        title: 'Reset di discount',
                        message: 'I prodotti con codice ' + productCodes + ' hanno subito un aggiornamento automatico del discount in quanto è stato attivato un\'altro bundle',
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(event);
                }
                // DK DE-069 START
                if(scontoLeggeSet.length > 0){
                    console.log('DK SCONTOLEGGE');
                    let productCodes = [];
                    scontoLeggeSet.forEach(productCode =>{
                        if(changedDiscount.includes(productCode)){
                            productCodes.push(productCode);
                        }
                    })
                    if(productCodes.length > 0){
    
                        const event = new ShowToastEvent({
                            title: 'Reset di discount',
                            message: 'Per i prodotti con codice ' + productCodes.join(', ') + ' è stato applicato uno sconto di legge.',
                            variant: 'warning',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(event);
                    }
                }
                // DK DE-069 END
                console.log('DK deleteCloudOrderItem.recordsToUpdate: ', recordsToUpdate);
                orderItemDelete({chosenIdsOrderItemToDelete:rowIdSet, recordsToUpdate:recordsToUpdate}
                ).then((result) => {
                    if (result) {
                        //refreshApex(this.records);
                        //this.fetchItems().catch(e=>{this.isLoading = false;});
                        getRecordNotifyChange([{recordId: this.recordId}]);
                        this.navigateToRecord(this.recordId);
                        console.log('Recs eliminati');
                    }
                }).catch((error) => {
                    this.isLoading = false;
                    const event = new ShowToastEvent({
                        title: 'Errore durante il salvataggio!!',
                        message: error.body.message,
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                    console.log('error while fetch contacts--> ' + JSON.stringify(error));
                });
            })
            .catch(error => {
                console.log('DK handleRowActions.getBundleDiscounts.error', error);
            });
        }else{
            const event = new ShowToastEvent({
                title: 'Attenzione!',
                message: 'Selezionare almeno un elemento dalla lista prima di continuare',
                variant: 'warning'
            });
            this.dispatchEvent(event);
            console.log('error while fetch contacts--> ' + JSON.stringify(error));
        }
    }
    // AL 2024-04-28 -- Fine 

    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }
    // connectedCallback method called when the element is inserted into a document
    async connectedCallback() {
        // this.isLoading = true;
        let dataTableGlobalStyle = document.createElement('style');
            dataTableGlobalStyle.innerHTML = '.slds-badge{margin: 2px;}';
            document.head.appendChild(dataTableGlobalStyle);
        try {
            let rec = await getRecord({recordId:this.recordId});

            this.prepopulatedAccount.objId = rec.cgcloud__Order_Account__c;
            this.prepopulatedAccount.obj.Id = rec.cgcloud__Order_Account__c;
            this.prepopulatedAccount.obj.name = rec.cgcloud__Order_Account__r.Name;
            this.prepopulatedAccount.name = rec.cgcloud__Order_Account__r.Name;
            this.prepopulatedAccount.sObjectName = 'Account';
            this.prepopulatedAccount.iconName = 'standard:account';
            this.selectedCustomerId = rec.cgcloud__Order_Account__c;

            this.prepopulatedOrder.objId = rec.Id;
            this.prepopulatedOrder.obj.Id = rec.Id;
            this.prepopulatedOrder.obj.name = rec.Name;
            this.prepopulatedOrder.name = rec.Name;
            this.prepopulatedOrder.sObjectName = 'cgcloud__Order__c';
            this.prepopulatedOrder.iconName = 'standard:orders';
            this.selectedOrderId = rec.Id


            this.recordInfo = rec;
            let currentColumnsModal = [...this.columnsModal];
            let currentColumns = [...this.columns];
            
            this.valueRecipt = this.recordInfo.cgcloud__Gross_Total_Value__c;//AD
            //Alessandro di nardo @ ten 2023-08-21 check type order 
            console.log('AD this.recordInfo : ' ,this.recordInfo);

            console.log('AD cgcloud__Order_Template__r.Name : ' ,this.recordInfo.cgcloud__Order_Template__r.Name);
            if(this.recordInfo.cgcloud__Order_Template__r.Name == "Ordine Diretto Pharma"
            || this.recordInfo.cgcloud__Order_Template__r.Name == "Transfer Order")
            {
                this.showCounters = true;
            }
            if(this.recordInfo.cgcloud__Order_Template__r.Name == 'Transfer Order'){
                for(let i = 0; i < currentColumnsModal.length; i++){
                    console.log('DK currentColumnsModal[i].fieldName: ', currentColumnsModal[i].fieldName);
                    if(currentColumnsModal[i].fieldName == 'cgcloud__Discount__c'){
                        currentColumnsModal.splice(i, 1);
                        console.log('DENTRO');
                        break;
                    }
                }
                console.log('DK this.columnsModal', JSON.stringify(currentColumnsModal));
                for(let i = 0; i < currentColumns.length; i++){
                    console.log('DK currentColumns[i].fieldName: ', currentColumns[i].fieldName);
                    if(currentColumns[i].fieldName == 'cgcloud__Discount__c'){
                        currentColumns.splice(i, 1);
                        console.log('DENTRO');
                        break;
                    }
                }
                this.columns = currentColumns;
                this.columnsModal = currentColumnsModal;
                console.log('DK this.columns', JSON.stringify(currentColumns));
            }

            if (["Initial","Rejected"].includes(rec.cgcloud__Phase__c) && !this.columnsAdded) {
                this.showAddProducts = true;
                // AL 2024-04-08 -- Rimozione della prims colonna
                /*
                this.columns = [{
                    label: this.label.ART_Action,
                    type: 'button-icon',
                    initialWidth: 75,
                    typeAttributes: {
                        iconName: 'action:delete',
                        title: this.label.ART_Remove,
                        variant: 'border-filled',
                        alternativeText: this.label.ART_Remove
                    }
                }].concat(this.columns);*/
                // AL 2024-04-08 -- Fine
            }

            console.log('DK this.isOpenClone', this.isOpenClone);
            this.dispatchCCBDone();
            await this.fetchItems();
            if(this.isOpenClone){
                this.handleClone();
            }
        } catch(exc) {
            console.log(exc);
            this.isLoading = false;
        }
    }
    @track titoloModale;

    dispatchCCBDone(){
        // Creates the event with the data.
        const selectedEvent = new CustomEvent('ccbdone', {
            status: 'insert'
        });
        console.log('SV selectedEvent: ', selectedEvent);

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    assortmentProductList = [];
    assortmentProductMap = {}
    productConditionMap = {};
    async fetchItems() {
        let result = await fetchCloudOrderItems({orderId : this.recordId});
        getProduct({orderAccount: this.recordInfo.cgcloud__Order_Account__c, orderTemplate : this.recordInfo.cgcloud__Order_Template__c})
        .then((getProductResult) => {
            console.log('DK getProductResult: ', getProductResult);
            this.assortmentProductList = getProductResult.assortmentProductList;
            this.productConditionMap = getProductResult.productConditionMap;
            if(this.assortmentProductList){

                this.assortmentProductList.forEach(obj => {
                    this.assortmentProductMap[obj.ProductId] = obj;
                });
            }
            
            if (result!==undefined && result!==null) {
                console.log('RESULT--> ' + JSON.stringify(result));
                console.table(result);//Alessandro di nardo @ten 02 10 2023

                for(let i = 0; i < result.length; i++){
                    console.log('AD PLANT  : ' , result[i].cgcloud__Product__r.THR_Plant__c);
                    let checkPlant =  result[i].cgcloud__Product__r.THR_Plant__c;
                    switch (checkPlant){
                        case 'FIR1':
                            this.totalFIR1=this.totalFIR1 + 1;
                            break;
                        case 'LUS1':
                            this.totalLUS1=this.totalLUS1 +1;
                            break;
                        case 'GDT1':
                            this.totalGDT1=this.totalGDT1 +1;
                            break;
                        case 'MEN1':
                            this.totalMEN1=this.totalMEN1 +1;
                            break;
                        case 'MLS1':
                            this.totalMLS1=this.totalMLS1 +1;
                            break;
                    }
                    

                    this.totalQuantity += result[i].cgcloud__Quantity__c;// AD
                    result[i].cgcloud__ProductName = result[i].cgcloud__Product__r.Name;
                    result[i].cgcloud__ProductCode = result[i].cgcloud__Product__r.ProductCode;
                    result[i].THR_DiscountSegment__c = result[i].cgcloud__Product__r.THR_DiscountSegment__c; // LV 2023-03-14 DE-014/DE-029
                    result[i].THR_IndustryStandard__c = result[i].cgcloud__Product__r.THR_IndustryStandard__c; // LV 2023-03-14 DE-014/DE-029
                    result[i].THR_ZLAW__c = this.assortmentProductMap[result[i].cgcloud__Product__c] ? this.assortmentProductMap[result[i].cgcloud__Product__c].Product.THR_ZLAW__c : 0;
                    result[i].THR_TaxClassification__c = this.assortmentProductMap[result[i].cgcloud__Product__c] ? this.assortmentProductMap[result[i].cgcloud__Product__c].Product.THR_TaxClassification__c : 0;
                    result[i].prezzoAlPubblico = this.productConditionMap && this.productConditionMap[result[i].cgcloud__Product__c] ? parseFloat(this.productConditionMap[result[i].cgcloud__Product__c].ART_Public_Price__c) : 0;
                    result[i].orderTemplate = this.recordInfo.cgcloud__Order_Template__r.Name;
                    result[i].cgcloud__Value__c = Number(parseFloat(result[i].cgcloud__Value__c));
                    result[i].cgcloud__Value_Receipt__c = Number(parseFloat(result[i].cgcloud__Value_Receipt__c));
                    result[i].cgcloud__Base_Price__c = Number(parseFloat(result[i].cgcloud__Base_Price__c));
                    result[i].cgcloud__Price__c=Number(parseFloat(result[i].Unite_Price__c));//  Alessandro di nardo @ten task : DE - 089 
                    console.log(`Prezzo al pubblico ${result[i].prezzoAlPubblico}`);
                    console.log('DK constructor_Name', result[i].cgcloud__Value__c.constructor.name);
                    console.log('DK constructor_value1', result[i].cgcloud__Value__c);
                    if(result[i].cgcloud__Value__c.constructor.name === 'String'){
                        
                        let parsedValue = Number(parseFloat(result[i].cgcloud__Value__c));
                        result[i].cgcloud__Value__c = parsedValue; // LV 2023-03-14 DE-014/DE-029
                        console.log('DK constructor_value2', result[i].cgcloud__Value__c);
                        console.log('DK constructor_Name2', result[i].cgcloud__Value__c.constructor.name);
                    }
                    result[i].scontoLegge = this.recordInfo.cgcloud__Order_Template__r.Name == 'Ordine Diretto Pharma' && ['A', 'E'].includes(result[i].cgcloud__Product__r.THR_DiscountSegment__c);
                }
                this.totalReferenze += this.totalFIR1 > 0 ? 1 : 0;
                this.totalReferenze += this.totalLUS1 > 0 ? 1 : 0;
                this.totalReferenze += this.totalGDT1 > 0 ? 1 : 0;
                this.totalReferenze += this.totalMEN1 > 0 ? 1 : 0;
                this.totalReferenze += this.totalMLS1 > 0 ? 1 : 0;
                const cloneData = [...result];
                let sortedByModal = 'cgcloud__ProductName';
                let sortDirectionModal = 'asc';
                cloneData.sort( this.sortBy( sortedByModal, sortDirectionModal === 'asc' ? 1 : -1 ) );
                this.records = cloneData;
                // Alessandro Di Nardo
                const subSet = (o, keys) => keys.reduce((r, k) => (r[k] = o[k], r), {})
                        
                const aggregatePriceQuantity=function(array){
                    let groupByCols = ['THR_IndustryStandard__c']
                    let grouped = {};
                    let aggregateCols = 'cgcloud__Value__c';

                    array.forEach(o => {
                    const values = groupByCols.map(k => o[k]).join("|");
                    //console.log('values to check : ' , values);
                    let showAllKeys = Object.keys(o);
                    if (grouped[values])
                        grouped[values][aggregateCols] += o[aggregateCols]
                    else
                        grouped[values] = { ...subSet(o, showAllKeys), [aggregateCols]: o[aggregateCols] }
                    })
                
                    return Object.values(grouped);
                }
                console.log('AD aggregatePriceQuantity() : ' , aggregatePriceQuantity(this.records ))
                // this.records = aggregatePriceQuantity(this.records );
                
                // fine Alessandro Di Nardo

                this.currentProdMap = new Map(
                    this.records.map(obj => {
                        return [obj.cgcloud__Product__c, obj];
                    }),
                );
                console.log('this.records --> ', this.records);
                console.log('this.currentProdMap --> ', this.currentProdMap);

                

                this.totalRecords = this.records.length;//alessandro di nardo
                
                //this.totalRecords = result.length; // update total records count //alessandro di nardo backup  commentato per prove             
                this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
                this.paginationHelper(); // call helper menthod to update pagination logic 
                this.isLoading = false;
                // this.openmodel = false;
            }
        })
        .catch(error =>{
            console.log(error);
        })
    }
    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    // JS function to handel pagination logic 
    paginationHelper() {
        this.isLoading = true;
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = (Math.ceil(this.totalRecords / this.pageSize) == 0 ? 1 : Math.ceil(this.totalRecords / this.pageSize));
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            console.log('AD paginationHelper index I : ' , i);
            this.recordsToDisplay.push(this.records[i]);
        }
        this.isLoading = false;
    }

    handleCalculateBundles(recordsToUpdate, valuesToUpdateMap, orderItemQuantityMap, filterMap, showToast){
        let hasError = false;
        return getBundleDiscounts({orderItemQuantityMapJSON: JSON.stringify(orderItemQuantityMap), orderTemplateId: this.recordInfo.cgcloud__Order_Template__c, filterMapJSON: JSON.stringify(filterMap)})
        .then(result =>{
            console.log('DK START getBundleDiscounts');
            console.log('DK getBundleDiscounts.result: ', result);
            let changedDiscount = [];
            let productResponseMap =  result.productResponseMap;
            let minDiscountMap =  result.minDiscountMap;
            this.errors.table = null;
            this.errors.rows = {};
            this.errors = {...this.errors}
            let producthErrors = [];
            let bundlesToCheck = [];
            let productDiscountMap = {};
            let discountToResetSet = [];
            let discountToUpdateSet = [];
            let scontoLeggeSet = [];
            let recordsToClone = [];
            recordsToUpdate.forEach(orderItem =>{
                let currentItemError = false;
                console.log('DK currentCheck getBundleDiscounts.orderItem', JSON.stringify(orderItem));
                // if(!orderItem.scontoLegge){
                    if(orderItem.scontoLegge){
                        scontoLeggeSet.push(orderItem.cgcloud__ProductCode);
                    }
                    let hasBundle = false;
                    if(!productResponseMap[orderItem.productId] && orderItem.cgcloud__Discount__c > 0 && orderItem.THR_ZLAW__c != orderItem.cgcloud__Discount__c && orderItem.editableField){

                        console.log('DK currentCheck BUNDLE ERROR - No Bundle con discount 1');
                        console.log('DK currentCheck BUNDLE ERROR - productResponseMap[orderItem.productId]', productResponseMap[orderItem.productId]);
                        hasError = true;
                        currentItemError = true;
                        if(!producthErrors.includes(orderItem.cgcloud__ProductCode)){
                            producthErrors.push(orderItem.cgcloud__ProductCode);
                            this.errors.rows[orderItem.cgcloud__ProductCode] = {
                                title: 'Errore',
                                messages: [
                                    'Non è possibile applicare discount su questo prodotto'
                                ],
                                fieldNames: ['cgcloud__Discount__c']
                            },
                            this.errors.table= {
                                title: 'Ci sono degli errori',
                            }
                        }
                    }else if(productResponseMap[orderItem.productId]){
                        console.log('DK productResponseMap[orderItem.productId]', productResponseMap[orderItem.productId]);
                        for(var i = 0; i< Object.keys(productResponseMap[orderItem.productId]).length; i++){
                            let range = Object.keys(productResponseMap[orderItem.productId])[i];
                            let quantity = 0;
                            let from = parseInt(range.split('_')[0]);
                            let to = parseInt(range.split('_')[1]);
                            let bundle = range.split('_')[2];
                            console.log('DK range: ' + range);
                            result.bundlesMap[bundle].productSet.forEach(productId =>{
                                if(orderItemQuantityMap[productId]){
                                    quantity += orderItemQuantityMap[productId];
                                }
                            })

                            console.log('DK quantity: ' + quantity);
                            if(quantity >= from && quantity <= to){
                                hasBundle = true;
                                if(orderItem.cgcloud__Discount__c > productResponseMap[orderItem.productId][range] && valuesToUpdateMap[orderItem.cgcloud__ProductCode] && valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c')){
                                    console.log('DK currentCheck BUNDLE ERROR - discount maggiore di bundle');
                                    hasError = true;
                                    currentItemError = true;
                                    if(!producthErrors.includes(orderItem.cgcloud__ProductCode)){

                                        producthErrors.push(orderItem.cgcloud__ProductCode);
                                        this.errors.rows[orderItem.cgcloud__ProductCode] = {
                                            title: 'Errore',
                                            messages: [
                                                'Il Discount applicato è maggiore del massimo consentito(' + productResponseMap[orderItem.productId][range] + '%).'
                                            ],
                                            fieldNames: ['cgcloud__Discount__c']
                                        },
                                        this.errors.table= {
                                            title: 'Ci sono degli errori',
                                        }
                                    }
                                // DK DE-068 START
                                }else if(minDiscountMap[orderItem.productId][range] && orderItem.cgcloud__Discount__c < minDiscountMap[orderItem.productId][range] && valuesToUpdateMap[orderItem.cgcloud__ProductCode] && valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c')){
                                    console.log('DK currentCheck BUNDLE ERROR - discount maggiore di bundle');
                                    hasError = true;
                                    currentItemError = true;
                                    if(!producthErrors.includes(orderItem.cgcloud__ProductCode)){

                                        producthErrors.push(orderItem.cgcloud__ProductCode);
                                        this.errors.rows[orderItem.cgcloud__ProductCode] = {
                                            title: 'Errore',
                                            messages: [
                                                'Il Discount applicato è minore del minimo consentito(' + minDiscountMap[orderItem.productId][range] + '%).'
                                            ],
                                            fieldNames: ['cgcloud__Discount__c']
                                        },
                                        this.errors.table= {
                                            title: 'Ci sono degli errori',
                                        }
                                    }
                                // DK DE-068 END
                                }else{
                                    productDiscountMap[orderItem.productId] = productResponseMap[orderItem.productId][range];
                                    bundlesToCheck.push(bundle);
                                }
                                break;
                            }
                        }

                    }
                    // DK DE-069 START
                    if(!hasBundle && this.recordInfo.cgcloud__Order_Template__r.Name == 'Ordine Diretto Pharma' && orderItem.editableField && valuesToUpdateMap[orderItem.cgcloud__ProductCode] && (!valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c') || orderItem.cgcloud__Discount__c == 0)){
                        console.log('Set ZLWA 1');
                        if(orderItem.cgcloud__Discount__c != orderItem.THR_ZLAW__c){
                            changedDiscount.push(orderItem.cgcloud__ProductCode);
                        }
                        orderItem.cgcloud__Discount__c = orderItem.THR_ZLAW__c;
                        scontoLeggeSet.push(orderItem.cgcloud__ProductCode);
                    }
                    // DK DE-069 END
                    console.log('DK recordsToUpdate_bundlesToCheck', bundlesToCheck);
                    console.log('DK recordsToUpdate_productDiscountMap', productDiscountMap);
                    console.log('DK recordsToUpdate_valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes', valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c'));
                    console.log('DK recordsToUpdate_orderItem.cgcloud__Discount__c', orderItem.cgcloud__Discount__c);
                    if(!hasBundle && orderItem.cgcloud__Discount__c > 0 && !scontoLeggeSet.includes(orderItem.cgcloud__ProductCode)){
                        if(valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c')){
                            console.log('DK BUNDLE ERROR - No Bundle con discount 2');
                            hasError = true;
                            currentItemError = true;
                            if(!producthErrors.includes(orderItem.cgcloud__ProductCode)){

                                producthErrors.push(orderItem.cgcloud__ProductCode);
                                this.errors.rows[orderItem.cgcloud__ProductCode] = {
                                    title: 'Errore',
                                    messages: [
                                        'Non è possibile applicare discount su questo prodotto'
                                    ],
                                    fieldNames: ['cgcloud__Discount__c']
                                },
                                this.errors.table= {
                                    title: 'Ci sono degli errori',
                                }
                            }
                        }else{
                            // if(!this.isClone){
                                
                                console.log('DK DISCOUNT TO ZERO', JSON.stringify(recordsToUpdate));
                                discountToResetSet.push(orderItem.cgcloud__ProductCode);
                                orderItem.cgcloud__Discount__c = 0; 
                            // }
                        }
                    }/*
                }else{
                    scontoLeggeSet.push(orderItem.cgcloud__ProductCode);
                }*/
                if(this.isClone){
                    /*if(currentItemError){
                        orderItem.cgcloud__Discount__c = 0;
                    }*/
                    let templatename = orderItem.cgcloud__Order__r.cgcloud__Order_Template__r.Name;
                    let totaleRiga = templatename == 'Ordine Diretto Pharma' && orderItem.THR_DiscountSegment__c == 'C' ? ((orderItem.prezzoAlPubblico*100)/(100+orderItem.THR_TaxClassification__c))*orderItem.cgcloud__Quantity__c : orderItem.cgcloud__Price__c * orderItem.cgcloud__Quantity__c; // EDB 2023-03-16 DE-33A
                    let totaleRigaCalcolato = orderItem.scontoLegge ? totaleRiga : totaleRiga - (totaleRiga/100*(orderItem.cgcloud__Discount__c)); // EDB 2023-03-16 DE-33A
                    
                    orderItem.cgcloud__Value__c = totaleRigaCalcolato;
                    orderItem.cgcloud__Value_Receipt__c = totaleRigaCalcolato;
                    orderItem.cgcloud__Value__c = Number(parseFloat(orderItem.cgcloud__Value__c));
                    orderItem.cgcloud__Value_Receipt__c = Number(parseFloat(orderItem.cgcloud__Value_Receipt__c));
                    orderItem.cgcloud__Price__c = Number(parseFloat(orderItem.cgcloud__Price__c));
                    orderItem.cgcloud__Base_Price__c = Number(parseFloat(orderItem.cgcloud__Base_Price__c));
                    recordsToClone.push(orderItem);
                }
            });
            console.log('DK currentCheck recordsToUpdate 4: ', JSON.stringify(recordsToUpdate));

            // DK END DE-033A Bis
            if(hasError && !this.isClone){
                this.errors.table.messages = [];
                producthErrors.forEach(producthError =>{
                    this.errors.table.messages.push('Il Prodotto ' + producthError + ' ha degli errori');
                });
                this.isLoadingModal = false;
                return null;
            }else{
                // DK START DE-033A Bis
                if(this.isClone){
                    recordsToUpdate = recordsToClone;
                }
                let recordsToUpdateMap = recordsToUpdate.map(obj => obj.cgcloud__Product__c);
                console.log('DK recordsToUpdateMap:', recordsToUpdateMap);
                console.log('DK currentCheck recordsToUpdate 5: ', JSON.stringify(recordsToUpdate));
                let counter = 0;
                if(!this.isClone){

                    this.currentProdMap.forEach(orderItem =>{
                        if(!orderItem.scontoLegge){
    
                            let canHaveDiscount = false;
                            let bundleKeys = Object.keys(result.bundlesMap);
                            for(var k = 0; k < bundleKeys.length; k++){
                                let bundleId = bundleKeys[k];
                                let countset = 0;
                                console.log('DK this.currentProdMap.bundleId:', bundleId);
                                console.log('DK this.currentProdMap.orderItem.cgcloud__Product__c:', orderItem.cgcloud__Product__c);
                                console.log('DK this.currentProdMap.result.bundlesMap[bundleId].productSet:', result.bundlesMap[bundleId].productSet);
                                console.log('DK this.currentProdMap.esult.bundlesMap[bundleId].productSet.includes(orderItem.cgcloud__Product__c):', result.bundlesMap[bundleId].productSet.includes(orderItem.cgcloud__Product__c));
                                if(result.bundlesMap[bundleId].productSet.includes(orderItem.cgcloud__Product__c)){
                                    // record non modificato in linea che ha bundle
                                    console.log('DK this.currentProdMap.productResponseMap[orderItem.cgcloud__Product__c]:', productResponseMap[orderItem.cgcloud__Product__c]);
                                    let discountSet = false;
                                    let countDiscountSet = 0;
                                    for(var i = 0; i< Object.keys(productResponseMap[orderItem.cgcloud__Product__c]).length; i++){
                                        let range = Object.keys(productResponseMap[orderItem.cgcloud__Product__c])[i];
                                        let from = parseInt(range.split('_')[0]);
                                        let to = parseInt(range.split('_')[1]);
                                        let bundle = range.split('_')[2];
                                        let quantity = 0;
                                        console.log('DK this.currentProdMap.range: ' + range);
                                        result.bundlesMap[bundle].productSet.forEach(productId =>{
                                            if(orderItemQuantityMap[productId]){
                                                quantity += orderItemQuantityMap[productId];
                                            }
                                        })
                                        console.log('DK this.currentProdMap.quantity: ' + quantity);
                                        if(quantity >= from && quantity <= to){
                                            if(orderItem.cgcloud__Discount__c != productResponseMap[orderItem.cgcloud__Product__c][range] && orderItem.cgcloud__Quantity__c > 0){
    
                                                orderItem.cgcloud__Discount__c = productResponseMap[orderItem.cgcloud__Product__c][range];
                                                countDiscountSet++;
                                                discountSet = true;
                                                discountToUpdateSet.push(orderItem.cgcloud__ProductCode);
                                            }
                                            canHaveDiscount = true;
                                            break;
                                        }
                                    }
                                    console.log('DK this.currentProdMap.countDiscountSet: ' + countDiscountSet);
                                    console.log('DK this.currentProdMap.discountSet: ' + discountSet);
                                    if(discountSet){
                                        if(!recordsToUpdateMap.includes(orderItem.cgcloud__Product__c)){
                                            recordsToUpdate.push(orderItem);
                                            recordsToUpdateMap.push(orderItem.cgcloud__Product__c);
                                        }
                                        countset++;
                                        break;
                                    }
                                }
                                console.log('DK countset: ' + countset);
                            }
                            console.log('DK orderItem.cgcloud__ProductCode', orderItem.cgcloud__ProductCode);
                            console.log('DK canHaveDiscount' + counter, canHaveDiscount);
                            counter++;
                            if(!canHaveDiscount && this.recordInfo.cgcloud__Order_Template__r.Name == 'Ordine Diretto Pharma' && !recordsToUpdateMap.includes(orderItem.cgcloud__Product__c)){
                                console.log('Set ZLWA 1');
                                if(orderItem.cgcloud__Discount__c != orderItem.THR_ZLAW__c){
                                    changedDiscount.push(orderItem.cgcloud__ProductCode);
                                }
                                orderItem.cgcloud__Discount__c = orderItem.THR_ZLAW__c;
                                recordsToUpdate.push(orderItem);
                                recordsToUpdateMap.push(orderItem.cgcloud__Product__c);
                                scontoLeggeSet.push(orderItem.cgcloud__ProductCode);
                            }
                            else if(!canHaveDiscount && orderItem.cgcloud__Discount__c > 0 && !recordsToUpdateMap.includes(orderItem.cgcloud__Product__c) && orderItem.THR_ZLAW__c != orderItem.cgcloud__Discount__c && orderItem.cgcloud__Quantity__c > 0){
                                console.log('DK orderItem', orderItem);
                                discountToResetSet.push(orderItem.cgcloud__ProductCode);
                                orderItem.cgcloud__Discount__c = 0; 
                                recordsToUpdate.push(orderItem);
                                recordsToUpdateMap.push(orderItem.cgcloud__Product__c);
                            }
                        }
                    })
                }
                console.log('DK currentCheck recordsToUpdate 6: ', JSON.stringify(recordsToUpdate));
                console.log('DK productDiscountMap:', productDiscountMap);
                if(discountToResetSet.length > 0){
                    console.log('DK RESET');
                    if(showToast){
                        const event = new ShowToastEvent({
                            title: 'Reset di discount',
                            message: 'I prodotti con codice ' + discountToResetSet.join(', ') + ' hanno subito un reset del discount in quanto non sono più presenti in Bundle attivi.',
                            variant: 'warning',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(event);
                    }
                }

                if(discountToUpdateSet.length > 0){
                    console.log('DK UPDATE');
                    if(showToast){
                        const event = new ShowToastEvent({
                            title: 'Reset di discount',
                            message: 'I prodotti con codice ' + discountToUpdateSet.join(', ') + ' hanno subito un aggiornamento automatico del discount in quanto è stato attivato un\'altro bundle.',
                            variant: 'warning',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(event);
                    }
                }

                // DK DE-069 START
                if(scontoLeggeSet.length > 0){
                    console.log('DK SCONTOLEGGE');
                    let productCodes = [];
                    scontoLeggeSet.forEach(productCode =>{
                        if(changedDiscount.includes(productCode)){
                            productCodes.push(productCode);
                        }
                    })
                    if(productCodes.length > 0){
                        if(showToast){
                            const event = new ShowToastEvent({
                                title: 'Reset di discount',
                                message: 'Per i prodotti con codice ' + productCodes.join(', ') + ' è stato applicato uno sconto di legge.',
                                variant: 'warning',
                                mode: 'sticky'
                            });
                            this.dispatchEvent(event);
                        }
                    }
                }
                // DK DE-069 END
                    
                console.log('DK lastcheck_bundlesToCheck: ', bundlesToCheck);
                let bundleKeys =  Object.keys(result.bundlesMap);
                console.log('DK lastcheck_bundleKeys: ', bundleKeys);
                recordsToUpdate.forEach(orderItem => {
                    let newBundleId = undefined;
                    for(var k = 0; k < bundleKeys.length; k++){
                        // for(var i = 0; i < result.bundlesMap[result.bundlesMap[k]].productSet.length; i++){
                            console.log('DK lastcheck_orderItem.cgcloud__Product__c: ', orderItem.cgcloud__Product__c);
                            console.log('DK lastcheck_result.bundlesMap[k]: ', bundleKeys[k]);
                            console.log('DK lastcheck_result.bundlesMap[bundleKeys[k]].productSet: ', result.bundlesMap[bundleKeys[k]].productSet);
                            if(result.bundlesMap[bundleKeys[k]].productSet.includes(orderItem.cgcloud__Product__c) && bundlesToCheck.includes(bundleKeys[k])){
                            // if(result.bundlesMap[bundleKeys[k]].productSet[i] == orderItem.productId && bundlesToCheck.includes(bundleKeys[k])){
                                newBundleId = bundleKeys[k];
                                break;
                            }
                        // }
                        if(newBundleId){
                            break;
                        }
                    }
                    console.log('DK newBundleId', newBundleId);
                    if(orderItem.cgcloud__Discount__c == 0 && productDiscountMap[orderItem.productId]){

                        orderItem.cgcloud__Discount__c = productDiscountMap[orderItem.productId];
                    }else{
                        if(newBundleId && productDiscountMap[orderItem.productId] && !valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c') /* && orderItem.cgcloud__Discount__c > productDiscountMap[orderItem.productId]*/){

                            orderItem.cgcloud__Discount__c = productDiscountMap[orderItem.productId];
                        }
                    }
                });
                // DK END DE-033A Bis

                console.log('DK currentCheck recordsToUpdate final:', JSON.stringify(recordsToUpdate));
            }
            return recordsToUpdate;
        })
        .catch(error =>{
            console.log('DK getBundleDiscounts.error: ', error);
            return null;
        });
    }

    handleRowActions(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('AT ù: '+JSON.stringify(row));
        this.isLoading = true;
        // DK aggiunta ricalcolo discount on delete
        let orderItemQuantityMap = {};
        let recordsToUpdate = [];
        this.records.forEach(obj => {
            if(obj.Id != row.Id){
                this.currentProdMap.set(obj.cgcloud__Product__c, obj);
                orderItemQuantityMap[obj.cgcloud__Product__c] = obj.cgcloud__Quantity__c;
            }
        });

        let filterMap = {
            'ART_Rural__c' : this.recordInfo.cgcloud__Order_Account__r.ART_Rural__c ? 'Rural' : 'NON Rural',
            'THR_AccountGroup__c' : this.recordInfo.cgcloud__Order_Account__r.THR_AccountGroup__c,
            'ART_Customer_SubCategory_Description__c' : this.recordInfo.cgcloud__Order_Account__r.ART_Customer_SubCategory_Description__c
        };
        console.log('DK filterMap:', filterMap);
        getBundleDiscounts({orderItemQuantityMapJSON: JSON.stringify(orderItemQuantityMap), orderTemplateId: this.recordInfo.cgcloud__Order_Template__c, filterMapJSON: JSON.stringify(filterMap)})
        .then(result =>{
            let productResponseMap =  result.productResponseMap;
            this.errors.table = null;
            this.errors.rows = {};
            this.errors = {...this.errors}
            let discountToResetSet = [];
            let discountToUpdateSet = [];
            let scontoLeggeSet = [];
            let changedDiscount = [];
            this.currentProdMap.forEach(orderItem =>{
                if(orderItem.Id != row.Id){
                    let canHaveDiscount = false;
                    let bundleKeys = Object.keys(result.bundlesMap);
                    for(var k = 0; k < bundleKeys.length; k++){
                        let bundleId = bundleKeys[k];
                        let countset = 0;
                        if(result.bundlesMap[bundleId].productSet.includes(orderItem.cgcloud__Product__c)){
                            // record non modificato in linea che ha bundle
                            console.log('DK this.currentProdMap.productResponseMap[orderItem.cgcloud__Product__c]:', productResponseMap[orderItem.cgcloud__Product__c]);
                            let discountSet = false;
                            let countDiscountSet = 0;
                            for(var i = 0; i< Object.keys(productResponseMap[orderItem.cgcloud__Product__c]).length; i++){
                                let range = Object.keys(productResponseMap[orderItem.cgcloud__Product__c])[i];
                                let from = parseInt(range.split('_')[0]);
                                let to = parseInt(range.split('_')[1]);
                                let bundle = range.split('_')[2];
                                let quantity = 0;
                                console.log('DK this.currentProdMap.range: ' + range);
                                result.bundlesMap[bundle].productSet.forEach(productId =>{
                                    if(orderItemQuantityMap[productId]){
                                        quantity += orderItemQuantityMap[productId];
                                    }
                                })
                                console.log('DK this.currentProdMap.quantity: ' + quantity);
                                if(quantity >= from && quantity <= to){
                                    if(orderItem.cgcloud__Discount__c != productResponseMap[orderItem.cgcloud__Product__c][range]){
        
                                        orderItem.cgcloud__Discount__c = productResponseMap[orderItem.cgcloud__Product__c][range];
                                        countDiscountSet++;
                                        discountSet = true;
                                        discountToUpdateSet.push(orderItem.cgcloud__ProductCode);
                                    }
                                    canHaveDiscount = true;
                                    break;
                                }
                            }
                            console.log('DK this.currentProdMap.countDiscountSet: ' + countDiscountSet);
                            console.log('DK this.currentProdMap.discountSet: ' + discountSet);
                            if(discountSet){
                                recordsToUpdate.push(orderItem);
                                countset++;
                                break;
                            }
                        }
                        console.log('DK countset: ' + countset);
                    }
                    console.log('DK canHaveDiscount', canHaveDiscount);
                    console.log('DK orderItem.cgcloud__Discount__c > 0', orderItem.cgcloud__Discount__c > 0);
                    console.log('DK orderItem.cgcloud__ProductCode: ' + orderItem.cgcloud__ProductCode);
                    console.log('DK orderItem.THR_ZLAW__c: ' + orderItem.THR_ZLAW__c);
                    // DK DE-069 START
                    if(!canHaveDiscount && this.recordInfo.cgcloud__Order_Template__r.Name == 'Ordine Diretto Pharma'){
                        console.log('Set ZLWA 1');
                        if(orderItem.cgcloud__Discount__c != orderItem.THR_ZLAW__c){
                            changedDiscount.push(orderItem.cgcloud__ProductCode);
                        }
                        orderItem.cgcloud__Discount__c = orderItem.THR_ZLAW__c;
                        recordsToUpdate.push(orderItem);
                        scontoLeggeSet.push(orderItem.cgcloud__ProductCode);
                    }
                    // DK DE-069 END
                    // !canHaveDiscount && orderItem.cgcloud__Discount__c > 0 && !recordsToUpdateMap.includes(orderItem.cgcloud__Product__c) && orderItem.THR_ZLAW__c != orderItem.cgcloud__Discount__c && orderItem.cgcloud__Quantity__c > 0
                    else if(!canHaveDiscount && orderItem.cgcloud__Discount__c > 0 && orderItem.THR_ZLAW__c != orderItem.cgcloud__Discount__c){
                        discountToResetSet.push(orderItem.cgcloud__ProductCode);
                        orderItem.cgcloud__Discount__c = 0;
                        recordsToUpdate.push(orderItem);
                    }
                }
            })
            console.log('DK handleRowActions.recordsToUpdate', recordsToUpdate);
            if(discountToResetSet.length > 0){
                console.log('DK RESET2');
                let productCodes = discountToResetSet.join(', ')
                const event = new ShowToastEvent({
                    title: 'Reset di discount',
                    message: 'I prodotti con codice ' + productCodes + ' hanno subito un reset del discount in quanto non sono più presenti in Bundle attivi ',
                    variant: 'warning',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
            }
            if(discountToUpdateSet.length > 0){
                console.log('DK UPDATE2');
                let productCodes = discountToUpdateSet.join(', ')
                const event = new ShowToastEvent({
                    title: 'Reset di discount',
                    message: 'I prodotti con codice ' + productCodes + ' hanno subito un aggiornamento automatico del discount in quanto è stato attivato un\'altro bundle',
                    variant: 'warning',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
            }
            // DK DE-069 START
            if(scontoLeggeSet.length > 0){
                console.log('DK SCONTOLEGGE');
                let productCodes = [];
                scontoLeggeSet.forEach(productCode =>{
                    if(changedDiscount.includes(productCode)){
                        productCodes.push(productCode);
                    }
                })
                if(productCodes.length > 0){

                    const event = new ShowToastEvent({
                        title: 'Reset di discount',
                        message: 'Per i prodotti con codice ' + productCodes.join(', ') + ' è stato applicato uno sconto di legge.',
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(event);
                }
            }
            // DK DE-069 END
            console.log('DK deleteCloudOrderItem.recordsToUpdate: ', recordsToUpdate);
            deleteCloudOrderItem({orderItemId : row.Id, recordsToUpdate: recordsToUpdate})
            .then((result) => {
                if (result) {
                    //refreshApex(this.records);
                    //this.fetchItems().catch(e=>{this.isLoading = false;});
                    getRecordNotifyChange([{recordId: this.recordId}]);
                    this.navigateToRecord(this.recordId);
                }
            })
            .catch((error) => {
                this.isLoading = false;
                const event = new ShowToastEvent({
                    title: 'Errore durante il salvataggio!!',
                    message: error.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                console.log('error while fetch contacts--> ' + JSON.stringify(error));
            });
        })
        .catch(error => {
            console.log('DK handleRowActions.getBundleDiscounts.error', error);
        });
    }
    // JS function to handel pagination logic MODAL --------------------
    
    recordsModal = [];
    recordsModalFiltered = [];
    totalRecordsModal = 0; //Total no.of records
    pageSizeModal; //No.of records to be displayed per page
    totalPagesModal; //Total no.of pages
    pageNumberModal = 1; //Page number    
    recordsToDisplayModal = []; //Records to be displayed on the page
    @track isLoadingModal = false;
    currentProdMap = new Map();

    //AD START DE-041_042
    isClone = false;
    @api isOpenClone = false;
    anotherProduclist = [];
    setProductId = [];
    itemQuantityMap = [];
    relatedOrderListFilter = [];

    draftValues = [];

    @track prepopulatedAccount = {obj: {}, objId: undefined, name: undefined, sObjectName: 'Account', iconName: 'standard:account'};
    @track prepopulatedOrder = {obj: {}, objId: undefined, name: undefined, sObjectName: 'cgcloud__Order__c', iconName: 'standard:order'};

    orderIdfilter
    @api
    get orderFilter() {
        return (
            //"cgcloud__Active__c  = true AND  cgcloud__Management_Type__c = 'Sales' "
            "Id IN "+this.orderIdfilter
        );
    }

    
    @api
    get accountFilter() {
        let orderType = this.recordInfo.cgcloud__Order_Template__r.Name.includes('Pharma') ? 'Pharma' : this.recordInfo.cgcloud__Order_Template__r.Name.includes('OTC') ? 'OTC' : 'Transfer Order';
        return (
            //"cgcloud__Active__c  = true AND  cgcloud__Management_Type__c = 'Sales' "
            // "Id IN (SELECT cgcloud__Order_Account__c FROM cgcloud__Order__c WHERE cgcloud__Order_Template__c='"+this.recordInfo.cgcloud__Order_Template__c+"')"
            "Id IN (SELECT AccountId FROM StoreAssortment WHERE Assortment.Name = '" +  orderType + "')"
        );
    }

    selectedOrderId;
    selectedCustomerId;
    customerNotSelected = true;
    handleOrderSelection(event) {
        console.log('@@@@@selectedOrder: '+JSON.stringify(event)); 
        if(event.detail!=null ){
            this.selectedOrderId = event.detail.objId;
            // this.saveRelatedCustomerEvent(event.detail.objId);
        } else{
            this.selectedOrderId = null;
        }
    }

    handleCustomerSelection(event) {
        console.log('@@@@@selectedCustomer: '+JSON.stringify(event)); 
        // this.template.querySelector("[data-item='customLookupOrder']").removeSelectedItem(event);
        // this.template.querySelector("[data-item='customLookupOrder']").results = [];
        if(event.detail!=null ){
            this.selectedCustomerId = event.detail.objId;
            this.customerNotSelected = false;
            /*this.callGetOrderListFilter(event.detail.objId).then(() =>{
                this.customerNotSelected = false;
            });*/
        }else{
            this.selectedCustomerId = null;
            this.customerNotSelected = true;
        }
    }

    

    //columns in Modal information available in the data table
    @track orderColumnsModal = [
        { label: 'Order Number', fieldName: 'Name'},
        { label: 'Initiator', fieldName: 'owner'},
        { label: 'Phase', fieldName: 'cgcloud__Phase__c'},
        { label: 'Order Date', fieldName: 'cgcloud__Order_Date__c', type: 'date'},
        { label: 'Delivery Date', fieldName: 'cgcloud__Delivery_Date__c', type: 'date'}
    ];

    orderMap = {};
    @api
    handleClone(){
        console.log('DK START handleClone');
        if(Boolean(this.orderIdfilter)){
            this.finalStep = false;
            this.isClone=true;
            this.titoloModale = this.label.ART_OrderCopy;
            this.openmodel = true;
        }else{
            this.finalStep = false;
            this.isClone=true;
            this.titoloModale = this.label.ART_OrderCopy;
            this.openmodel = true;
            /*this.callGetOrderListFilter(this.prepopulatedAccount.objId).then(result =>{
                this.finalStep = false;
                this.isClone=true;
                this.titoloModale = this.label.ART_OrderCopy;
                this.openmodel = true;
            });*/
        }
    }

    /*callGetOrderListFilter(customerId){
        return getOrderListFilter({orderAccount : customerId, orderTemplate : this.recordInfo.cgcloud__Order_Template__c})
        .then(result=>{
            console.log('AD getOrderListFilter result : ' , result);
            if(result['orderList'] && result['orderList'].length > 0){
                // this.orderMap = result['orderMap'];
                var newFilter = '';
                let orderList = result['orderList'];
                orderList.forEach(order =>{
                    console.log('DK orderId:', order.Id);
                    newFilter =  newFilter +"\'"+order.Id+"\',";
                });
                newFilter = newFilter.substring(0, newFilter.length - 1); 
                this.orderIdfilter =  "("+newFilter+")";
            }else{
                const event = new ShowToastEvent({
                    title: 'Attenzione!!',
                    message: 'Il Customer selezionato non ha Ordini da poter clonare.',
                    variant: 'warning'
                });
                this.dispatchEvent(event);
            }
        }).catch(error=>{
            console.log('AD getOrderListFilter error : ' , error);
        })
    }*/

    handleSave(){
        console.log('DK START handleSave');
        // let selectedRow = this.template.querySelector("[data-item='orderTable']").getSelectedRows();
        // console.log('DK selectedRow: ', selectedRow);
        if(!this.selectedOrderId || !this.selectedCustomerId){
            const event = new ShowToastEvent({
                title: 'Attenzione!!',
                message: 'Selezionare almeno uno tra gli elementi disponibili prima di continuare.',
                variant: 'warning'
            });
            this.dispatchEvent(event);
        }else{
            this.isLoadingModal = true;
            getOrderItemsToClone({orderId: this.selectedOrderId, selectedCustomer: this.selectedCustomerId})
            .then(result => {
                try {
                    
                    console.log('DK getOrderItemsToClone.result', result);
                    let recordsToClone = [];
                    var templatename;
                    var rural;
                    var accountGroup;
                    var customerSubCategoryDescription;
                    let recordsToCloneLight = [];
                    if(result){
                        recordsToClone = [...result['recordsToClone']];
                        console.log('DK currentCheck recordsToClone START:', JSON.stringify(recordsToClone));
                        templatename = result['templatename'];
                        rural = result['rural'];
                        accountGroup = result['accountGroup'];
                        customerSubCategoryDescription = result['customerSubCategoryDescription'];
                        let productConditionMap = result['productConditionMap'];
                        let assortmentProductMap = result['assortmentProductMap'];
                        console.log('DK currentCheck ASSORTMENT PRODUCTS MAP', JSON.stringify(assortmentProductMap));
                        /*if(assortmentProductList){
        
                            assortmentProductList.forEach(obj => {
                                assortmentProductMap[obj.ProductId] = obj;
                            });
                        }*/
                        console.log();
                        for(var i= 0; i < recordsToClone.length; i++){
                            console.log('DK currentCheck recordToClone', recordsToClone[i]);
                            if(assortmentProductMap[recordsToClone[i].cgcloud__Product__c]){
                                recordsToClone[i].prezzoAlPubblico = productConditionMap[recordsToClone[i].cgcloud__Product__c] ? Number(parseFloat(productConditionMap[recordsToClone[i].cgcloud__Product__c].ART_Public_Price__c)) : 0;
                                recordsToClone[i].THR_DiscountSegment__c = recordsToClone[i].cgcloud__Product__r.THR_DiscountSegment__c; // LV 2023-03-14 DE-014/DE-029
                                recordsToClone[i].editableField = recordsToClone[i].THR_DiscountSegment__c === 'C';
                                
                                recordsToClone[i].cgcloud__Price__c = Number(parseFloat(productConditionMap[recordsToClone[i].cgcloud__Product__c].cgcloud__Value__c));
                                recordsToClone[i].cgcloud__Base_Price__c = Number(parseFloat(recordsToClone[i].cgcloud__Base_Price__c));
                                recordsToClone[i].scontoLegge = templatename == 'Ordine Diretto Pharma' && ['A', 'E'].includes(assortmentProductMap[recordsToClone[i].cgcloud__Product__c].Product.THR_DiscountSegment__c);
                                recordsToClone[i].THR_ZLAW__c = assortmentProductMap[recordsToClone[i].cgcloud__Product__c].Product.THR_ZLAW__c;
                                recordsToClone[i].THR_TaxClassification__c = assortmentProductMap[recordsToClone[i].cgcloud__Product__c].Product.THR_TaxClassification__c;
                                recordsToClone[i].orderTemplate = templatename;
                                recordsToClone[i].productId = assortmentProductMap[recordsToClone[i].cgcloud__Product__c].ProductId;
                                /*let totaleRiga = templatename == 'Ordine Diretto Pharma' && recordsToClone[i].THR_DiscountSegment__c == 'C' ? ((recordsToClone[i].prezzoAlPubblico*100)/(100+recordsToClone[i].THR_TaxClassification__c))*recordsToClone[i].cgcloud__Quantity__c : recordsToClone[i].cgcloud__Price__c * recordsToClone[i].cgcloud__Quantity__c; // EDB 2023-03-16 DE-33A
                                let totaleRigaCalcolato = recordsToClone[i].scontoLegge ? totaleRiga : totaleRiga - (totaleRiga/100*(recordsToClone[i].cgcloud__Discount__c)); // EDB 2023-03-16 DE-33A
                                
                                recordsToClone[i].cgcloud__Value__c = totaleRigaCalcolato;
                                recordsToClone[i].cgcloud__Value_Receipt__c = totaleRigaCalcolato;*/
                                recordsToCloneLight.push(recordsToClone[i]);
                            }else{
                                console.log('DK currentCheck ITEM REMOVED NOT IN ASSORTMENT PRODUCTS');
                                // recordsToClone.splice(i, 1);
                            }
                        }
                    }
                    console.log('DK currentCheck recordsToCloneLight', recordsToCloneLight);
                    recordsToClone = [...recordsToCloneLight];
                    let orderItemQuantityMap = {};
                    if(recordsToClone.length > 0){
                        let valuesToUpdateMap = {};
                        recordsToClone.forEach(obj => {
                            orderItemQuantityMap[obj.productId] = obj.cgcloud__Quantity__c;
                            obj.cgcloud__ProductCode = obj.cgcloud__Product__r.ProductCode;
                            valuesToUpdateMap[obj.cgcloud__ProductCode] = [];
                        })
                            
                        let filterMap = {
                            'ART_Rural__c' : rural ? 'Rural' : 'NON Rural',
                            'THR_AccountGroup__c' : accountGroup,
                            'ART_Customer_SubCategory_Description__c' : customerSubCategoryDescription
                        };
            
                        console.log('DK filterMap:', filterMap);
                        console.log('DK currentCheck recordsToClone BEFORE SEND:', JSON.stringify(recordsToClone));
                        this.handleCalculateBundles(recordsToClone, valuesToUpdateMap, orderItemQuantityMap, filterMap, false).then(calulatedRecords =>{
                            console.log('DK currentCheck calulatedRecords: ', calulatedRecords);
                            // this.isLoadingModal = false;
                            this.callCloneOrder(calulatedRecords);
                        });
                    }else{
                        // this.isLoadingModal = false;
                        this.callCloneOrder(recordsToClone);
                    }
                } catch (error) {
                    console.log(error);
                }
            })
            .catch(err =>{
                console.log('DK getOrderItemsToClone.error', err);
            });
            // DK START DE-033A Bis
        }
    }

    callCloneOrder(calulatedRecords){
        return cloneOrder({customerId: this.selectedCustomerId, orderId: this.selectedOrderId, orderItems: calulatedRecords}).then(result =>{
            this.navigateToRecord(result);
        }).catch(err =>{
            console.log('DK cloneOrder.error', err);
        }).finally(() =>{
            this.isLoadingModal = false;
        });
    }
    
    addProduct(){
        this.isClone=false;
        this.titoloModale = this.label.ADD_PRODUCTS;
        this.openModal();
    }

    //AD END DE-041_042
    
    openModal() {
        console.log('SV openModal: ', this.recordInfo);
        console.log('DK this.setProductId: ', this.setProductId);
        this.openmodel = true;
        this.finalStep = true;
        try {
            
            console.log('DK this.assortmentProductMap', JSON.stringify(this.assortmentProductMap));
            if(this.assortmentProductList){
                console.log('SV currentProdMap: ', this.currentProdMap);
                this.recordsModal = [];
                let currentProdList = [];
                // DK START DE-012
                let clusterPickListOptions = [];
                let clusterOptionsToCheck = [];
                // DK END DE-012 
                //Alessandro Di Nardo @ten 2023-08-24
                for(let i =0 ; i<this.assortmentProductList.length;i++){

                    let product = this.assortmentProductList[i];
                    /*if(this.isClone && !this.setProductId.includes(product.ProductId)){
                        continue;    
                    }*/

                    let productWrapper = {};
                    productWrapper.Id = null;
                    productWrapper.typeCSSClass = 'keep-active';
                    productWrapper.productId = product.ProductId;
                    productWrapper.cgcloud__Product__c = product.ProductId;
                    productWrapper.editableField = !['A','E'].includes(product.Product.THR_DiscountSegment__c);
                    productWrapper.typeCSSClassDiscount = !['A','E'].includes(product.Product.THR_DiscountSegment__c) ? 'keep-active' : '';
                    productWrapper.cgcloud__Price__c = parseFloat(this.productConditionMap[product.ProductId].cgcloud__Value__c);
                    productWrapper.cgcloud__Value__c = parseFloat(this.productConditionMap[product.ProductId].ART_Public_Price__c);
                    productWrapper.prezzoAlPubblico = parseFloat(this.productConditionMap[product.ProductId].ART_Public_Price__c);
                    console.log(`productWrapper.prezzoAlPubblico  ${productWrapper.prezzoAlPubblico}`);
                    if(product.Product.ProductCode == '51008L')console.log('DK 51008L', this.productConditionMap[product.ProductId]);
                    productWrapper.cgcloud__ProductName = product.Product.Name;
                    productWrapper.cgcloud__ProductCode = product.Product.ProductCode;
                    if(this.itemQuantityMap[product.ProductId]){

                        productWrapper.cgcloud__Quantity__c = this.itemQuantityMap[product.ProductId];
                        this.draftValues.push({cgcloud__ProductCode: productWrapper.cgcloud__ProductCode, cgcloud__Quantity__c: productWrapper.cgcloud__Quantity__c});
                    }else{
                        productWrapper.cgcloud__Quantity__c = 0;
                    }
                    // DK DE-069 START
                    productWrapper.cgcloud__Discount__c = this.recordInfo.cgcloud__Order_Template__r.Name == 'Ordine Diretto Pharma' && ['A', 'E'].includes(product.Product.THR_DiscountSegment__c) ? product.Product.THR_ZLAW__c : 0;
                    productWrapper.scontoLegge = this.recordInfo.cgcloud__Order_Template__r.Name == 'Ordine Diretto Pharma' && ['A', 'E'].includes(product.Product.THR_DiscountSegment__c);
                    productWrapper.THR_ZLAW__c = product.Product.THR_ZLAW__c;
                    productWrapper.THR_TaxClassification__c = product.Product.THR_TaxClassification__c;
                    productWrapper.orderTemplate = this.recordInfo.cgcloud__Order_Template__r.Name;
                    // DK DE-069 END

                    productWrapper.THR_DiscountSegment__c = product.Product.THR_DiscountSegment__c; // LV 2023-03-14 DE-014/DE-029
                    productWrapper.THR_IndustryStandard__c = product.Product.THR_IndustryStandard__c; // LV 2023-03-14 DE-014/DE-029
                    productWrapper.ART_Rural__c = false; // EDB 2023-03-16 DE-33A
                    if(this.currentProdMap.has(product.ProductId)  && !this.isClone){
                        productWrapper.Id = this.currentProdMap.get(product.ProductId).Id;
                        productWrapper.cgcloud__Quantity__c = this.currentProdMap.get(product.ProductId).cgcloud__Quantity__c;
                        productWrapper.cgcloud__Discount__c = this.currentProdMap.get(product.ProductId).cgcloud__Discount__c;
                        let ART_Rural = this.currentProdMap.get(product.ProductId).cgcloud__Order__r.cgcloud__Order_Account__r.ART_Rural__c; //EDB 2023-03-16 DE-33A
                        productWrapper.ART_Rural__c = ART_Rural; //EDB 2023-03-16 DE-33A
                        // this.recordsModal = [productWrapper].concat(this.recordsModal);
                        currentProdList.push(productWrapper);
                    }else{
                        this.recordsModal.push(productWrapper);
                    }
                    // DK START DE-012
                    productWrapper.criterion4ProductDescription = product.Product.ART_Cluster__c;
                    console.log('DK productWrapper.criterion4ProductDescription:', productWrapper.criterion4ProductDescription);
                    productWrapper.THR_Plant__c = product.Product.THR_Plant__c;
                    if(!clusterOptionsToCheck.includes(productWrapper.criterion4ProductDescription)){
                        let pickListOption = {label: productWrapper.criterion4ProductDescription, value: productWrapper.criterion4ProductDescription};
                        clusterPickListOptions.push(pickListOption);
                        clusterOptionsToCheck.push(productWrapper.criterion4ProductDescription);
                    }
                    // DK END DE-012 
                }

                console.log('DK clusterPickListOptions: ', JSON.stringify(clusterPickListOptions));
                this.clusterPickListOptions = clusterPickListOptions;


                const currentProdListCloned = [...currentProdList];
                let sortedByModal = 'cgcloud__ProductName';
                let sortDirectionModal = 'asc';
                this.sortDirectionModal = sortDirectionModal;
                this.sortedByModal = sortedByModal;
                
                currentProdListCloned.sort( this.sortBy( sortedByModal, sortDirectionModal === 'asc' ? 1 : -1 ) );
                currentProdList = currentProdListCloned;

                const cloneData = [...this.recordsModal];
                cloneData.sort( this.sortBy( sortedByModal, sortDirectionModal === 'asc' ? 1 : -1 ) );
                this.recordsModal = currentProdList.concat(cloneData);
                console.log('DK recordsModal: ', JSON.stringify(this.recordsModal));
                
                if(this.isClone){
                    let event = {detail: {}};
                    event.detail.draftValues = this.draftValues;
                    console.log('DK this.draftValues: ', this.draftValues);
                    // this.saveHandleAction(event);
                }else{

                    // this.recordsModal = this.recordsModal);
                    this.recordsModalFiltered = this.recordsModal;
                    this.totalRecordsModal = this.recordsModal.length; // update total records count                 
                    this.pageSizeModal = this.pageSizeOptions[0]; //set pageSize with default value as first option
                    this.paginationHelperModal(); // call helper menthod to update pagination logic 
                    // this.isLoadingModal = false;
                }

            }
        } catch (error) {
            console.log('error', error);
        }
    }
    @track errors = {};
    saveHandleAction(event) {
        console.log('DK event: ', JSON.stringify(event));
        this.isLoadingModal = true;
        try {
            
            let recordsModalMap = new Map();
            this.recordsModal.forEach(obj => {
                recordsModalMap.set(obj.cgcloud__ProductCode, obj);
                recordsModalMap.set(obj.productId, obj);
            })
            console.log('DK recordsModalMap: ', recordsModalMap);
            console.log('DK this.currentProdMap: ', this.currentProdMap);
            let recordsToUpdate = [];
            let valuesToUpdateMap = {};
            event.detail.draftValues.forEach(element =>{
                valuesToUpdateMap[element.cgcloud__ProductCode] = [];
                let record = recordsModalMap.get(element.cgcloud__ProductCode);
                let elementKeys =  Object.keys(element);
                let index = elementKeys.indexOf('cgcloud__ProductCode');
                elementKeys.splice(index, 1);
                for(var i = 0; i < elementKeys.length; i++){
                    valuesToUpdateMap[element.cgcloud__ProductCode].push(elementKeys[i]);
                    record[elementKeys[i]] = Number(element[elementKeys[i]]);
                }
                if(record.cgcloud__Quantity__c != 0 || this.currentProdMap.has(record.cgcloud__Product__c)){
                    //AD START DE-041_042
                    if(this.currentProdMap.has(record.cgcloud__Product__c) && this.isClone ){
                        record.Id = this.currentProdMap.get(record.cgcloud__Product__c).Id;
                        record.cgcloud__Quantity__c += Number(this.currentProdMap.get(record.cgcloud__Product__c).cgcloud__Quantity__c);
                    }
                    //AD END DE-041_042
                    recordsToUpdate.push(record);
                }
            });
            console.log('DK valuesToUpdateMap: ', valuesToUpdateMap);
            console.log('DK recordsToUpdate 1: ', recordsToUpdate);
            this.errors.table = null;
            this.errors.rows = {};
            this.errors = {...this.errors}
            let hasError = false;
            let producthErrors = [];
            recordsToUpdate.forEach(element =>{
                if(!this.currentProdMap.has(element.cgcloud__Product__c) && element.cgcloud__Quantity__c == 0 && element.cgcloud__Discount__c != 0){
                    hasError = true;
                    producthErrors.push(element.cgcloud__ProductCode);
                    this.errors.rows[element.cgcloud__ProductCode] = {
                        title: 'Errore',
                        messages: [
                            'Quantità deve essere maggiore di zero'
                        ],
                        fieldNames: ['cgcloud__Quantity__c']
                    },
                    this.errors.table= {
                        title: 'Ci sono degli errori',
                    }
                }
            });
            console.log('DK recordsToUpdate 2: ', recordsToUpdate);
            
            console.log('DK errors: ', JSON.stringify(this.errors));
            if(hasError){
                this.errors.table.messages = [];
                producthErrors.forEach(producthError =>{
                    this.errors.table.messages.push('Il Prodotto ' + producthError + ' ha degli errori');
                });
                this.isLoadingModal = false;
            }else{
                // DK START DE-033A Bis
                let orderItemQuantityMap = {};
                this.records.forEach(obj => {
                    orderItemQuantityMap[obj.cgcloud__Product__c] = obj.cgcloud__Quantity__c;
                })
                recordsToUpdate.forEach(obj => {
                    orderItemQuantityMap[obj.productId] = obj.cgcloud__Quantity__c;
                })
                console.log('DK orderItemQuantityMap:', orderItemQuantityMap);
                console.log('DK recordsToUpdate 3: ', recordsToUpdate);
                    
                let filterMap = {
                    'ART_Rural__c' : this.recordInfo.cgcloud__Order_Account__r.ART_Rural__c ? 'Rural' : 'NON Rural',
                    'THR_AccountGroup__c' : this.recordInfo.cgcloud__Order_Account__r.THR_AccountGroup__c,
                    'ART_Customer_SubCategory_Description__c' : this.recordInfo.cgcloud__Order_Account__r.ART_Customer_SubCategory_Description__c
                };

                console.log('DK filterMap:', filterMap);
                this.handleCalculateBundles(recordsToUpdate, valuesToUpdateMap, orderItemQuantityMap, filterMap, true).then( result =>{

                    console.log('DK handleCalculateBundles.result: ' + result);
                    console.log('AD handleCalculateBundles.result: ' + JSON.stringify(result));
                    if(result){
                        saveProduct({orderId: this.recordId, recordList: result})
                        .then(result =>{
                            console.log('DK saveProduct.result: ' + result);

                                getRecordNotifyChange([{recordId: this.recordId}]);
                                this.isLoadingModal = false;
                                this.openmodel = false;
                                this.navigateToRecord(this.recordId);
                            })
                            .catch(error =>{
                                console.log('DK saveProduct.error: ', error);
                                const event = new ShowToastEvent({
                                    title: 'Errore durante il salvataggio!!',
                                    message: error.body.message,
                                    variant: 'error'
                                });
                                this.dispatchEvent(event);
                                this.isLoadingModal = false;
                            })
                        }
                    }
                );
                /*getBundleDiscounts({orderItemQuantityMapJSON: JSON.stringify(orderItemQuantityMap), orderTemplateId: this.recordInfo.cgcloud__Order_Template__c, filterMapJSON: JSON.stringify(filterMap)})
                .then(result =>{
                    console.log('DK START getBundleDiscounts');
                    console.log('DK getBundleDiscounts.result: ', result);
                    let changedDiscount = [];
                    let productResponseMap =  result.productResponseMap;
                    let minDiscountMap =  result.minDiscountMap;
                    this.errors.table = null;
                    this.errors.rows = {};
                    this.errors = {...this.errors}
                    let producthErrors = [];
                    let bundlesToCheck = [];
                    let productDiscountMap = {};
                    let discountToResetSet = [];
                    let discountToUpdateSet = [];
                    let scontoLeggeSet = [];
                    recordsToUpdate.forEach(orderItem =>{
                        if(!orderItem.scontoLegge){

                            console.log('DK orderItem', orderItem);
                            let hasBundle = false;
                            if(!productResponseMap[orderItem.productId] && orderItem.cgcloud__Discount__c > 0 && orderItem.THR_ZLAW__c != orderItem.cgcloud__Discount__c && orderItem.editableField){

                                producthErrors.push(orderItem.cgcloud__ProductCode);
                                hasError = true;
                                console.log('DK No Bundle con discount 1');
                                this.errors.rows[orderItem.cgcloud__ProductCode] = {
                                    title: 'Errore',
                                    messages: [
                                        'Non è possibile applicare discount su questo prodotto'
                                    ],
                                    fieldNames: ['cgcloud__Discount__c']
                                },
                                this.errors.table= {
                                    title: 'Ci sono degli errori',
                                }
                            }else if(productResponseMap[orderItem.productId]){
                                console.log('DK productResponseMap[orderItem.productId]', productResponseMap[orderItem.productId]);
                                for(var i = 0; i< Object.keys(productResponseMap[orderItem.productId]).length; i++){
                                    let range = Object.keys(productResponseMap[orderItem.productId])[i];
                                    let quantity = 0;
                                    let from = parseInt(range.split('_')[0]);
                                    let to = parseInt(range.split('_')[1]);
                                    let bundle = range.split('_')[2];
                                    console.log('DK range: ' + range);
                                    result.bundlesMap[bundle].productSet.forEach(productId =>{
                                        if(orderItemQuantityMap[productId]){
                                            quantity += orderItemQuantityMap[productId];
                                        }
                                    })
        
                                    console.log('DK quantity: ' + quantity);
                                    if(quantity >= from && quantity <= to){
                                        hasBundle = true;
                                        if(orderItem.cgcloud__Discount__c > productResponseMap[orderItem.productId][range] && valuesToUpdateMap[orderItem.cgcloud__ProductCode] && valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c')){
                                            producthErrors.push(orderItem.cgcloud__ProductCode);
                                            hasError = true;
                                            console.log('DK discount maggiore di bundle');
                                            this.errors.rows[orderItem.cgcloud__ProductCode] = {
                                                title: 'Errore',
                                                messages: [
                                                    'Il Discount applicato è maggiore del massimo consentito(' + productResponseMap[orderItem.productId][range] + '%).'
                                                ],
                                                fieldNames: ['cgcloud__Discount__c']
                                            },
                                            this.errors.table= {
                                                title: 'Ci sono degli errori',
                                            }
                                        // DK DE-068 START
                                        }else if(minDiscountMap[orderItem.productId][range] && orderItem.cgcloud__Discount__c < minDiscountMap[orderItem.productId][range] && valuesToUpdateMap[orderItem.cgcloud__ProductCode] && valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c')){
                                            producthErrors.push(orderItem.cgcloud__ProductCode);
                                            hasError = true;
                                            console.log('DK discount maggiore di bundle');
                                            this.errors.rows[orderItem.cgcloud__ProductCode] = {
                                                title: 'Errore',
                                                messages: [
                                                    'Il Discount applicato è minore del minimo consentito(' + minDiscountMap[orderItem.productId][range] + '%).'
                                                ],
                                                fieldNames: ['cgcloud__Discount__c']
                                            },
                                            this.errors.table= {
                                                title: 'Ci sono degli errori',
                                            }
                                        // DK DE-068 END
                                        }else{
                                            productDiscountMap[orderItem.productId] = productResponseMap[orderItem.productId][range];
                                            bundlesToCheck.push(bundle);
                                        }
                                        break;
                                    }
                                }

                            }
                            // DK DE-069 START
                            if(!hasBundle && this.recordInfo.cgcloud__Order_Template__r.Name == 'Ordine Diretto Pharma' && orderItem.editableField && valuesToUpdateMap[orderItem.cgcloud__ProductCode] && (!valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c') || orderItem.cgcloud__Discount__c == 0)){
                                console.log('Set ZLWA 1');
                                if(orderItem.cgcloud__Discount__c != orderItem.THR_ZLAW__c){
                                    changedDiscount.push(orderItem.cgcloud__ProductCode);
                                }
                                orderItem.cgcloud__Discount__c = orderItem.THR_ZLAW__c;
                                scontoLeggeSet.push(orderItem.cgcloud__ProductCode);
                            }
                            // DK DE-069 END
                            console.log('DK recordsToUpdate_bundlesToCheck', bundlesToCheck);
                            console.log('DK recordsToUpdate_productDiscountMap', productDiscountMap);
                            console.log('DK recordsToUpdate_hasBundle', productDiscountMap);
                            console.log('DK recordsToUpdate_valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes', valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c'));
                            console.log('DK recordsToUpdate_orderItem.cgcloud__Discount__c', orderItem.cgcloud__Discount__c);
                            if(!hasBundle && orderItem.cgcloud__Discount__c > 0 && !scontoLeggeSet.includes(orderItem.cgcloud__ProductCode)){
                                if(valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c')){
    
                                    producthErrors.push(orderItem.cgcloud__ProductCode);
                                    hasError = true;
                                    console.log('DK No Bundle con discount 2');
                                    this.errors.rows[orderItem.cgcloud__ProductCode] = {
                                        title: 'Errore',
                                        messages: [
                                            'Non è possibile applicare discount su questo prodotto'
                                        ],
                                        fieldNames: ['cgcloud__Discount__c']
                                    },
                                    this.errors.table= {
                                        title: 'Ci sono degli errori',
                                    }
                                }else{
                                    discountToResetSet.push(orderItem.cgcloud__ProductCode);
                                    orderItem.cgcloud__Discount__c = 0; 
                                }
                            }
                        }else{
                            scontoLeggeSet.push(orderItem.cgcloud__ProductCode);
                        }
                    });
                    console.log('DK recordsToUpdate 4: ', recordsToUpdate);

                    // DK END DE-033A Bis
                    if(hasError){
                        this.errors.table.messages = [];
                        producthErrors.forEach(producthError =>{
                            this.errors.table.messages.push('Il Prodotto ' + producthError + ' ha degli errori');
                        });
                        this.isLoadingModal = false;
                    }else{
                        // DK START DE-033A Bis
                        let recordsToUpdateMap = recordsToUpdate.map(obj => obj.cgcloud__Product__c);
                        console.log('DK recordsToUpdateMap:', recordsToUpdateMap);
                        console.log('DK recordsToUpdate 5: ', recordsToUpdate);
                        let counter = 0;
                        this.currentProdMap.forEach(orderItem =>{
                            if(!orderItem.scontoLegge){

                                let canHaveDiscount = false;
                                let bundleKeys = Object.keys(result.bundlesMap);
                                for(var k = 0; k < bundleKeys.length; k++){
                                    let bundleId = bundleKeys[k];
                                    let countset = 0;
                                    console.log('DK this.currentProdMap.bundleId:', bundleId);
                                    console.log('DK this.currentProdMap.orderItem.cgcloud__Product__c:', orderItem.cgcloud__Product__c);
                                    console.log('DK this.currentProdMap.result.bundlesMap[bundleId].productSet:', result.bundlesMap[bundleId].productSet);
                                    console.log('DK this.currentProdMap.esult.bundlesMap[bundleId].productSet.includes(orderItem.cgcloud__Product__c):', result.bundlesMap[bundleId].productSet.includes(orderItem.cgcloud__Product__c));
                                    if(result.bundlesMap[bundleId].productSet.includes(orderItem.cgcloud__Product__c)){
                                        // record non modificato in linea che ha bundle
                                        console.log('DK this.currentProdMap.productResponseMap[orderItem.cgcloud__Product__c]:', productResponseMap[orderItem.cgcloud__Product__c]);
                                        let discountSet = false;
                                        let countDiscountSet = 0;
                                        for(var i = 0; i< Object.keys(productResponseMap[orderItem.cgcloud__Product__c]).length; i++){
                                            let range = Object.keys(productResponseMap[orderItem.cgcloud__Product__c])[i];
                                            let from = parseInt(range.split('_')[0]);
                                            let to = parseInt(range.split('_')[1]);
                                            let bundle = range.split('_')[2];
                                            let quantity = 0;
                                            console.log('DK this.currentProdMap.range: ' + range);
                                            result.bundlesMap[bundle].productSet.forEach(productId =>{
                                                if(orderItemQuantityMap[productId]){
                                                    quantity += orderItemQuantityMap[productId];
                                                }
                                            })
                                            console.log('DK this.currentProdMap.quantity: ' + quantity);
                                            if(quantity >= from && quantity <= to){
                                                if(orderItem.cgcloud__Discount__c != productResponseMap[orderItem.cgcloud__Product__c][range] && orderItem.cgcloud__Quantity__c > 0){
    
                                                    orderItem.cgcloud__Discount__c = productResponseMap[orderItem.cgcloud__Product__c][range];
                                                    countDiscountSet++;
                                                    discountSet = true;
                                                    discountToUpdateSet.push(orderItem.cgcloud__ProductCode);
                                                }
                                                canHaveDiscount = true;
                                                break;
                                            }
                                        }
                                        console.log('DK this.currentProdMap.countDiscountSet: ' + countDiscountSet);
                                        console.log('DK this.currentProdMap.discountSet: ' + discountSet);
                                        if(discountSet){
                                            if(!recordsToUpdateMap.includes(orderItem.cgcloud__Product__c)){
                                                recordsToUpdate.push(orderItem);
                                                recordsToUpdateMap.push(orderItem.cgcloud__Product__c);
                                            }
                                            countset++;
                                            break;
                                        }
                                    }
                                    console.log('DK countset: ' + countset);
                                }
                                console.log('DK orderItem.cgcloud__ProductCode', orderItem.cgcloud__ProductCode);
                                console.log('DK canHaveDiscount' + counter, canHaveDiscount);
                                counter++;
                                if(!canHaveDiscount && this.recordInfo.cgcloud__Order_Template__r.Name == 'Ordine Diretto Pharma' && !recordsToUpdateMap.includes(orderItem.cgcloud__Product__c)){
                                    console.log('Set ZLWA 1');
                                    if(orderItem.cgcloud__Discount__c != orderItem.THR_ZLAW__c){
                                        changedDiscount.push(orderItem.cgcloud__ProductCode);
                                    }
                                    orderItem.cgcloud__Discount__c = orderItem.THR_ZLAW__c;
                                    recordsToUpdate.push(orderItem);
                                    recordsToUpdateMap.push(orderItem.cgcloud__Product__c);
                                    scontoLeggeSet.push(orderItem.cgcloud__ProductCode);
                                }
                                else if(!canHaveDiscount && orderItem.cgcloud__Discount__c > 0 && !recordsToUpdateMap.includes(orderItem.cgcloud__Product__c) && orderItem.THR_ZLAW__c != orderItem.cgcloud__Discount__c && orderItem.cgcloud__Quantity__c > 0){
                                    console.log('DK orderItem', orderItem);
                                    discountToResetSet.push(orderItem.cgcloud__ProductCode);
                                    orderItem.cgcloud__Discount__c = 0; 
                                    recordsToUpdate.push(orderItem);
                                    recordsToUpdateMap.push(orderItem.cgcloud__Product__c);
                                }
                            }
                        })
                        console.log('DK recordsToUpdate 6: ', recordsToUpdate);
                        console.log('DK productDiscountMap:', productDiscountMap);
                        if(discountToResetSet.length > 0){
                            console.log('DK RESET');
                            const event = new ShowToastEvent({
                                title: 'Reset di discount',
                                message: 'I prodotti con codice ' + discountToResetSet.join(', ') + ' hanno subito un reset del discount in quanto non sono più presenti in Bundle attivi.',
                                variant: 'warning',
                                mode: 'sticky'
                            });
                            this.dispatchEvent(event);
                        }

                        if(discountToUpdateSet.length > 0){
                            console.log('DK UPDATE');
                            const event = new ShowToastEvent({
                                title: 'Reset di discount',
                                message: 'I prodotti con codice ' + discountToUpdateSet.join(', ') + ' hanno subito un aggiornamento automatico del discount in quanto è stato attivato un\'altro bundle.',
                                variant: 'warning',
                                mode: 'sticky'
                            });
                            this.dispatchEvent(event);
                        }

                        // DK DE-069 START
                        if(scontoLeggeSet.length > 0){
                            console.log('DK SCONTOLEGGE');
                            let productCodes = [];
                            scontoLeggeSet.forEach(productCode =>{
                                if(changedDiscount.includes(productCode)){
                                    productCodes.push(productCode);
                                }
                            })
                            if(productCodes.length > 0){

                                const event = new ShowToastEvent({
                                    title: 'Reset di discount',
                                    message: 'Per i prodotti con codice ' + productCodes.join(', ') + ' è stato applicato uno sconto di legge.',
                                    variant: 'warning',
                                    mode: 'sticky'
                                });
                                this.dispatchEvent(event);
                            }
                        }
                        // DK DE-069 END
                            
                        console.log('DK lastcheck_bundlesToCheck: ', bundlesToCheck);
                        let bundleKeys =  Object.keys(result.bundlesMap);
                        console.log('DK lastcheck_bundleKeys: ', bundleKeys);
                        recordsToUpdate.forEach(orderItem => {
                            let newBundleId = undefined;
                            for(var k = 0; k < bundleKeys.length; k++){
                                // for(var i = 0; i < result.bundlesMap[result.bundlesMap[k]].productSet.length; i++){
                                    console.log('DK lastcheck_orderItem.cgcloud__Product__c: ', orderItem.cgcloud__Product__c);
                                    console.log('DK lastcheck_result.bundlesMap[k]: ', bundleKeys[k]);
                                    console.log('DK lastcheck_result.bundlesMap[bundleKeys[k]].productSet: ', result.bundlesMap[bundleKeys[k]].productSet);
                                    if(result.bundlesMap[bundleKeys[k]].productSet.includes(orderItem.cgcloud__Product__c) && bundlesToCheck.includes(bundleKeys[k])){
                                    // if(result.bundlesMap[bundleKeys[k]].productSet[i] == orderItem.productId && bundlesToCheck.includes(bundleKeys[k])){
                                        newBundleId = bundleKeys[k];
                                        break;
                                    }
                                // }
                                if(newBundleId){
                                    break;
                                }
                            }
                            console.log('DK newBundleId', newBundleId);
                            if(orderItem.cgcloud__Discount__c == 0 && productDiscountMap[orderItem.productId]){

                                orderItem.cgcloud__Discount__c = productDiscountMap[orderItem.productId];
                            }else{
                                if(newBundleId && productDiscountMap[orderItem.productId] && !valuesToUpdateMap[orderItem.cgcloud__ProductCode].includes('cgcloud__Discount__c')){

                                    orderItem.cgcloud__Discount__c = productDiscountMap[orderItem.productId];
                                }
                            }
                        });
                        // DK END DE-033A Bis

                        console.log('DK recordsToUpdate final:', recordsToUpdate);

                        saveProduct({orderId: this.recordId, recordList: recordsToUpdate})
                        .then(result =>{
                            console.log('DK result: ' + result);
                            getRecordNotifyChange([{recordId: this.recordId}]);
                            this.isLoadingModal = false;
                            this.openmodel = false;
                            this.navigateToRecord(this.recordId);
                        })
                        .catch(error =>{
                            console.log('DK saveProduct.error: ', error);
                            const event = new ShowToastEvent({
                                title: 'Errore durante il salvataggio!!',
                                message: error.body.message,
                                variant: 'error'
                            });
                            this.dispatchEvent(event);
                            this.isLoadingModal = false;
                        })

                    }
                })
                .catch(error =>{
                    console.log('DK getBundleDiscounts.error: ', error);
                });*/
            }
        } catch (error) {
            console.log('DK saveHandleAction.error: ', error);
        }
    }
    
    get bDisableFirstModal() {
        return this.pageNumberModal == 1;
    }
    get bDisableLastModal() {
        return this.pageNumberModal == this.totalPagesModal;
    }

    handleRecordsPerPageModal(event) {
        this.pageSizeModal = event.target.value;
        this.paginationHelperModal();
    }
    previousPageModal() {
        this.pageNumberModal = this.pageNumberModal - 1;
        this.paginationHelperModal();
    }
    nextPageModal() {
        this.pageNumberModal = this.pageNumberModal + 1;
        this.paginationHelperModal();
    }
    firstPageModal() {
        this.pageNumberModal = 1;
        this.paginationHelperModal();
    }
    lastPageModal() {
        this.pageNumberModal = this.totalPagesModal;
        this.paginationHelperModal();
    }
    paginationHelperModal() {
        try {
            
            // this.isLoadingModal = true;
            this.recordsToDisplayModal = [];
            // calculate total pages
            this.totalPagesModal = (Math.ceil(this.totalRecordsModal / this.pageSizeModal) == 0 ? 1 : Math.ceil(this.totalRecordsModal / this.pageSizeModal));
            // set page number 
            if (this.pageNumberModal <= 1) {
                this.pageNumberModal = 1;
            } else if (this.pageNumberModal >= this.totalPagesModal) {
                this.pageNumberModal = this.totalPagesModal;
            }
            // set records to display on current page 
            for (let i = (this.pageNumberModal - 1) * this.pageSizeModal; i < this.pageNumberModal * this.pageSizeModal; i++) {
                if (i === this.totalRecordsModal) {
                    break;
                }
                this.recordsToDisplayModal.push(this.recordsModalFiltered[i]);
            }
            // this.isLoadingModal = false;
        } catch (error) {
            console.log('DK paginationHelperModal.error', error);
        }
    }

    closeModal() {
        this.openmodel = false;
    } 

    returnModal(){
        this.openmodel = false;
    }
    searchedProductCode = '';
    searchedProductDescription = '';
    //DK START DE-012
    searchedAzienda = '';
    searchedCodiceAIC = '';
    searchedCluster = '';
    aziendaPicklistOptions = [
        {label: 'FIRMA Spa', value: 'FIR1'},
        {label: 'LUSOFARMACO Spa', value: 'LUS1'},
        {label: 'GUIDOTTI Spa', value: 'GDT1'},
        {label: 'A MENARINI IFR', value: 'MEN1'},
        {label: 'MALESCI Spa', value: 'MLS1'}
    ];

    clusterPickListOptions = [];
    //DK END DE-012
    handleFilter(event){

        console.log('DK handleFilter Started');
        if(event.target.name == 'searchedProductCode'){
            this.searchedProductCode = event.target.value;
        }else if(event.target.name == 'searchedProductDescription'){
            this.searchedProductDescription = event.target.value;
        }
        //DK START DE-012
        else if(event.target.name == 'searchedAzienda'){
            this.searchedAzienda = event.target.value;
        }else if(event.target.name == 'searchedCodiceAIC'){
            this.searchedCodiceAIC = event.target.value;
        }else if(event.target.name == 'searchedCluster'){
            this.searchedCluster = event.target.value;
        }
        //DK END DE-012
    }

    handleReset(){
        this.recordsModalFiltered = this.recordsModal;
        this.totalRecordsModal = this.recordsModal.length;
        this.searchedProductCode = '';
        this.searchedProductDescription = '';
        //DK START DE-012
        this.searchedAzienda = '';
        this.searchedCodiceAIC = '';
        this.searchedCluster = '';
        //DK END DE-012
        this.paginationHelperModal();
    }

    //alessandro di nardo @ten 2023-08-22 START DE-047
    renderedCallback() {
        let elementsArray = this.template.querySelectorAll(".searchEnter");
        elementsArray.forEach((element)=>{
            element.addEventListener("keydown",(event)=>{
                if(event.key ==="Enter"){
                    this.handleSearch();
                }
            })
        })
    }
    //alessandro di nardo @ten 2023-08-22 END DE-047

    handleSearch(){
        console.log('DK handleSearch Started');
        try {
            let filteredList = [];
            for(var i in this.recordsModal){
                if(!Boolean(this.recordsModal[i].cgcloud__ProductCode) || !this.recordsModal[i].cgcloud__ProductCode.toLowerCase().includes(this.searchedProductCode.toLowerCase())){
                    continue;
                }
                if(!Boolean(this.recordsModal[i].cgcloud__ProductName) || !this.recordsModal[i].cgcloud__ProductName.toLowerCase().includes(this.searchedProductDescription.toLowerCase())){
                    continue;
                }
                //DK START DE-012

                if(this.searchedAzienda != '' && (!Boolean(this.recordsModal[i].THR_Plant__c) || this.recordsModal[i].THR_Plant__c.toLowerCase() != this.searchedAzienda.toLowerCase())){
                    continue;
                }
                if(this.searchedCodiceAIC != '' && (!Boolean(this.recordsModal[i].THR_IndustryStandard__c) || !this.recordsModal[i].THR_IndustryStandard__c.toLowerCase().includes(this.searchedCodiceAIC.toLowerCase()))){
                    continue;
                }
                if(this.searchedCluster != '' && (!Boolean(this.recordsModal[i].criterion4ProductDescription) || this.recordsModal[i].criterion4ProductDescription.toLowerCase() != this.searchedCluster.toLowerCase())){
                    continue;
                }
                //DK END DE-012
                filteredList.push(this.recordsModal[i]);
            }
            this.recordsModalFiltered = filteredList;
            this.pageNumberModal = 1;
            this.totalRecordsModal = this.recordsModalFiltered.length;
            this.paginationHelperModal();
        } catch (error) {
            console.log('DK handleSearch.error: ' + error);
        }
    }
    //END FILTER
    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    //DK START SORT
    @track sortDirection = 'asc';
    @track sortedBy = '';
    onHandleSort( event ) {
        try {
            
            const { fieldName: sortedBy, sortDirection } = event.detail;
            const cloneData = [...this.recordsToDisplay];
            console.log('DK sortedBy: ' + sortedBy);
            console.log('DK sortDirection: ' + sortDirection);
            cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
            // this.data = cloneData;
            this.recordsToDisplay = cloneData;
            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;
            this.paginationHelperModal();
        } catch (error) {
            console.log('DK error', error);   
        }
    }
    //DK END SORT

    //DK START SORT MODAL
    @track sortDirectionModal = 'asc';
    @track sortedByModal = '';
    onHandleSortModal( event ) {
        try {
            
            const { fieldName: sortedBy, sortDirection } = event.detail;
            const cloneData = [...this.recordsModalFiltered];
            console.log('DK sortedByModal: ' + sortedBy);
            console.log('DK sortDirectionModal: ' + sortDirection);
            cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
            // this.data = cloneData;
            this.recordsModalFiltered = cloneData;
            this.sortDirectionModal = sortDirection;
            this.sortedByModal = sortedBy;
            this.paginationHelperModal();
        } catch (error) {
            console.log('DK error', error);   
        }
    }
    //DK END SORT MODAL

    sortBy( field, reverse, primer ) {

        const key = primer
            ? function( x ) {
                  return primer(x[field]);
              }
            : function( x ) {
                  return x[field];
              };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            console.log('DK sort - reverse: ', reverse);
            let ascending = reverse == 1;
            // equal items sort equally
            if (a === b) {
                return 0;
            }
            // nulls sort after anything else
            else if (!Boolean(a)) {
                return 1;
            }
            else if (!Boolean(b)) {
                return -1;
            }
            // otherwise, if we're ascending, lowest sorts first
            else if (ascending) {
                return a < b ? -1 : 1;
            }
            // if descending, highest sorts first
            else { 
                return a < b ? 1 : -1;
            }
        };

    }
}