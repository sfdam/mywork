import { LightningElement, api, track } from 'lwc';
import search from '@salesforce/apex/CustomLookupController.getSearchResult';

export default class CustomLookup extends LightningElement {
    @api pReadOnly = false;
    @api required = false;
    @api isPrecise = false;
    @api sObjectName = 'Opportunity';
    // @track _sObjectName = 'Opportunity';
    @api iconName = 'custom:custom16';
    @api strSearch = '';
    @api whereCondition;
    @api placeholderInput = 'Cerca...';
    @api fieldLabel = 'Portafoglio di destinazione';
    @api fieldHelper = '';
    @api noResultMsg = 'Nessun risultato';
    @api fieldToLike = 'Name';
    @api fieldAlternativeInLabel = '';
    @api otherFieldToQuery = '';
    @api eventToDispatch = 'customLookup';
    timeoutId;
    @api minStrSearch = 2;

    @api results = [];
    @api selectedSObject;

    // @track cachedResult = [];
    @track isLoading = false;
    @track isRequired = false;

    /* EVENT HANDLERS - START */

    @api recordIdList;

    connectedCallback() {
        if(this.selectedSObject){
            this.selectedSObject = JSON.parse(JSON.stringify(this.selectedSObject));
        }
        console.log('SELECT sObjectName ',this.sObjectName);
        console.log('SELECT OBJ ',JSON.stringify(this.selectedSObject));
    }

    clickSearch(event){
        
        
        // if(!this.hasSelection && (this.results.length > 0 || this.cachedResult.length > 0)){
        if(!this.hasSelection && this.results.length > 0){
            this.template.querySelector('.slds-combobox').classList.add('slds-is-open');
            // if(this.cachedResult.length > 0)
            //     this.results = this.cachedResult;
        }

    
    }

    @api
    blurInput(event){
        console.log('Dk blurInput START');
        this.template.querySelector('.slds-combobox').classList.remove('slds-is-open');
        if(this.required && this.selectedSObject == undefined){
            this.isRequired = true;
        }
    }

    handleFocusOut(event){
        this.template.querySelector('.slds-combobox').classList.remove('slds-is-open');
    }

    selectItem(event){
        // sparare evento
        let objId = event.currentTarget.dataset.value;
        this.template.querySelector('.slds-combobox').classList.remove('slds-is-open');
        this.selectedSObject = this.results.find(r => { return r.objId == objId });
        console.log('GB selectedSObject ',this.selectedSObject);
        // if(this.cachedResult.length < 3)
        //     this.cachedResult.unshift(this.selectedSObject);
        // else{
        //     this.cachedResult.unshift(this.selectedSObject);
        //     this.cachedResult.pop();
        // }

        // Creates the event with the data.
        const selectedEvent = new CustomEvent(this.eventToDispatch, {
            detail: this.selectedSObject,
            status: 'insert'
        });
        console.log('SV selectedEvent: ', selectedEvent);

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    @api
    removeSelectedItem(event){
        this.selectedSObject = undefined;
        this.strSearch = '';

        // Creates the event with the data.
        const selectedEvent = new CustomEvent(this.eventToDispatch, {
            detail: this.selectedSObject,
            status: 'remove'
        });
        console.log('SV selectedEvent: ', selectedEvent);

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    changeFilter(event){
        clearTimeout(this.timeoutId);
        this.strSearch = event.target.value;
        this.timeoutId=setTimeout(()=> {
            this.doSearch().bind(this);
          }, 300);
        
    }

    doSearch(){
        let strToSearch = this.strSearch;
            
            if(strToSearch.length >= this.minStrSearch && !this.pReadOnly){
                this.isLoading = true;
                this.template.querySelector('.slds-combobox').classList.add('slds-is-open');
                console.log('DK this.whereCondition:', this.whereCondition);
                search({ strSearch: strToSearch, fieldAlternativeInLabel: this.fieldAlternativeInLabel, otherFieldToQuery: this.otherFieldToQuery, fieldToLike: this.fieldToLike, sObjectName: this.sObjectName, iconName: this.iconName, condition: this.whereCondition, recordIdList: this.recordIdList, isPrecise: this.isPrecise}).then(res => {
                    console.log('SV res ' , res);

                    this.results = res;
                }).finally(() => {
                    this.isLoading = false;
                }).catch(err => {
                    console.log('@@@ err ' , err);
                });
                let startCall = new Date();
                /*searchv2({ strSearch: strToSearch, otherFieldToQuery: this.otherFieldToQuery, fieldToLike: this.fieldToLike, sObjectName: this.sObjectName, condition: this.whereCondition, recordIdList: this.recordIdList}).then(res => {
                    console.log('SV res ' , res, new Date() - startCall);
                    let startExtend = new Date();
                    let extendedResults = [];
                    if(res){

                        let fieldAlternativeList = this.fieldAlternativeInLabel ? this.fieldAlternativeInLabel.split(',') : [];
                        
                        res.forEach(element =>{
                            let valueAlternativeList = [];
                            let extendedElement = {};
                            extendedElement.Id = element.Id;
                            extendedElement.sObjectName = this.sObjectName
                            extendedElement.iconName = this.iconName;
                            extendedElement.obj = element;
                            if(fieldAlternativeList.length == 0){
                                extendedElement.name = element.Name
                            }else{
                                fieldAlternativeList.forEach(alternativeField =>{
                                    if(alternativeField.includes('.')){
                                        let point = alternativeField.split('.');
                                        let valore = element; //lista
                                        point.forEach(p => {
                                            valore = Boolean(valore) ? Boolean(valore[p]) ? valore[p] : null : null;
                                        });
                                        if(valore){
                                            valueAlternativeList.push(valore);
                                        }
                                    }else{
                                        valueAlternativeList.push(element[alternativeField])
                                    }
                                })
                                extendedElement.name = element.Name + ' (' + valueAlternativeList.join(', ') + ')';
                            }
                            extendedResults.push(extendedElement);
                        })
                    }
                    console.log('DK timeExtension', new Date() - startExtend);
                    this.results = extendedResults;
                }).finally(() => {
                    this.isLoading = false;
                }).catch(err => {
                    console.log('@@@ err ' , err.message);
                });*/
            } else if(strToSearch.length > 0)
                this.template.querySelector('.slds-combobox').classList.remove('slds-is-open');
    }
    /* EVENT HANDLERS - END */

    /* GETTER & SETTER - START */

    get hasFieldHelper(){
        return this.fieldHelper != '';
    }

    get hasSelection(){
        return this.selectedSObject != null && this.selectedSObject != undefined;
    }

    get hasResult(){
        return this.results.length > 0;
    }

    /*@api
    get sObjectName(){
        return this._sObjectName;
    }

    set sObjectName(value){
        if(this._sObjectName != value){
            this.selectedSObject = undefined;
            this.strSearch = '';
        }
        
        this._sObjectName = value;
    }*/

    get errorRequired(){
        return this.isRequired ? 'border: 1.4px solid rgb(194, 57, 52); border-radius: 5px;' : '';
    }

    /* GETTER & SETTER - END */
}