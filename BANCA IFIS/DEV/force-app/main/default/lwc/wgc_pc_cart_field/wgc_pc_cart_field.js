import { LightningElement, api, track } from 'lwc';
import apexSearch from '@salesforce/apex/WGC_PC_CartController.search';
 
export default class Wgc_pc_cart_field extends LightningElement {

    @track
    field = {};

    @track
    isPicklist = false;

    @track
    isRadio = false;

    @track
    isLookup = false;

    @track
    isTextarea = false;

    @track
    isOtherFieldType = false;

    radioOptions = [ { label: 'Si', value: 'true'}, { label: 'No', value: 'false'} ];

    @track
    labelVariant = '';

    @track
    lookup = [{ id: '', sObjectType: '', icon: '', title: '', subtitle: ''}];

    defaultLookup = { id: '', sObjectType: 'Account', icon: 'standard:account', title: '', subtitle: ''};

    @track
    lookupFilter = '';

    isMultiEntry = false;

    @track
    errors = [];

    connectedCallback(){

    }

    renderedCallback(){

    }

    /* GETTER & SETTER */

    @api
    get type(){
        return this.field.type;
    }

    set type(t){
        this.field.type = t;
        this.isPicklist = this.field.type == 'picklist';
        this.isRadio = this.field.type == 'radio';
        this.isLookup = this.field.type == 'lookup';
        this.isTextarea = this.field.type == 'textarea';
        this.isOtherFieldType = !this.isPicklist && !this.isRadio && !this.isLookup && !this.isTextarea;
        this.labelVariant = this.field.type == 'checkbox' ? 'label-stacked' : '';
    }

    @api
    get formatter(){
        return this.field.formatter;
    }

    set formatter(f){
        this.field.formatter = f;
    }

    @api
    get stepField(){
        // console.log('@@@ prova step ' , this.field.step );
        // console.log('@@@ apiName ' , this.name);
        // console.log('@@@ apiName ' , this.field.apiName);
        console.log('@@@ formatter ' , this.formatter);
        // return (this.field.step == undefined) ? '0.01' : this.field.step;
        return this.formatter == 'currency' || this.formatter == 'percent' || this.formatter == 'percent-fixed' ? '0.01' : '1';
    }

    set stepField(s){
        this.field.step = (s == undefined) ? '0.01' : s;
    }

    @api
    get label(){
        return this.field.label;
    }

    set label(l){
        this.field.label = l;
    }

    @api
    get name(){
        return this.field.apiName;
    }

    set name(n){
        this.field.apiName = n;
    }

    @api
    get value(){
        return this.field.value;
    }

    set value(v){
        this.field.value = v;
        this.lookup[0].id = v;
    }

    @api
    get lookupTitle(){
        return this.lookup[0].title;
    }

    set lookupTitle(t){
        this.lookup[0].title = t;
    }

    @api
    get readOnly(){
        return this.field.readOnly;
    }

    set readOnly(r){
        this.field.readOnly = r;
    }

    @api
    get visibility(){
        return this.field.visibility;
    }

    set visibility(v){
        this.field.visibility = v;
    }

    @api
    get options(){
        return this.field.options;
    }

    set options(opts){
        this.field.options = opts;
    }

    @api
    get objectName(){
        return this.lookup[0].sObjectType;
    }

    set objectName(on){
        this.lookup[0].sObjectType = on;
    }

    @api
    get filter(){
        return this.lookupFilter;
    }

    set filter(f){
        if(f != undefined)
            this.lookupFilter = f;
    }

    @api
    get icon(){
        return this.lookup[0].icon;
    }

    set icon(i){
        this.lookup[0].icon = i;        
    }

    /* GETTER & SETTER */

    /* EVENT HANDLERS */

    handleSearch(event) {
        var lookupField = event.target.dataset.value;
        var params = { searchTerm: event.detail.searchTerm , selectedIds: event.detail.selectedIds, objName: this.lookup[0].sObjectType, whereClause: this.lookupFilter}
        apexSearch(params)
            .then(results => {
                this.template
                    .querySelector('c-wgc_lookup[data-value="'+lookupField+'"]')
                    .setSearchResults(results);
            })
            .catch(error => {
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    changeField(event){
        // let value = event.target.type == 'checkbox' ? event.detail.checked : event.detail == null ? '' : Array.isArray(event.detail.value) ? event.detail.value[0].id : event.detail.value;
        let apiName = event.target.name == undefined || event.target.name.startsWith("input-") ? event.target.dataset.name : event.target.name;
        console.log('@@@ changeField ' , JSON.stringify(event.detail));

        let val2 = this.type == 'lookup' && event.detail != null ? event.detail.value[0].id : this.type == 'number' && event.detail.value != "" ? parseFloat(event.detail.value) : event.detail != null ? event.detail.value : null;
        // console.log('@@@ type ' , this.type );
        console.log('@@@ changeField ' , val2 );
        console.log('@@@ step 1 ' , this.field.step);
        // console.log('@@@ step 1 ' , this.step);
        // this.field.step = this.field.step == undefined ? '0.01' : this.field.step;
        //this.dispatchEvent(new CustomEvent('changefieldval', { detail: { value: value, apiName: apiName } }));
        this.dispatchEvent(new CustomEvent('changefieldval', { detail: { value: val2, apiName: apiName } }));
        console.log('@@@ test step');
    }

    blurHandler(event){
    }

    /* EVENT HANDLERS */
}