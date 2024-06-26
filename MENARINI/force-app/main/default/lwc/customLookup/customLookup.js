import { LightningElement, api, track } from 'lwc';
import search from '@salesforce/apex/CustomLookupController.getSearchResult';


export default class CustomLookup extends LightningElement {
    @api pReadOnly = false;
    @api required = false;
    @api sObjectName = 'Opportunity';
    @track _sObjectName = 'Opportunity';
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

    //DK START DE-067
    @api recordIdList;
    //DK END DE-067

    connectedCallback() {
        
        console.log('SELECT OBJ ',this.selectedSObject);
    }

    clickSearch(event){
        
        
        // if(!this.hasSelection && (this.results.length > 0 || this.cachedResult.length > 0)){
        if(!this.hasSelection && this.results.length > 0){
            this.template.querySelector('.slds-combobox').classList.add('slds-is-open');
            // if(this.cachedResult.length > 0)
            //     this.results = this.cachedResult;
        }

    
    }

    blurInput(event){
        // this.template.querySelector('.slds-combobox').classList.remove('slds-is-open');
        if(this.required && this.selectedSObject == undefined){
            this.isRequired = true;
        }
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
                search({ strSearch: strToSearch, fieldAlternativeInLabel: this.fieldAlternativeInLabel, otherFieldToQuery: this.otherFieldToQuery, fieldToLike: this.fieldToLike, sObjectName: this.sObjectName, iconName: this.iconName, condition: this.whereCondition, recordIdList: this.recordIdList}).then(res => {
                    console.log('SV res ' , res);

                    this.results = res;
                }).finally(() => {

                    this.isLoading = false;
                }).catch(err => {
                    console.log('@@@ err ' , err);
                });
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