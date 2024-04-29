import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//CUSTOM LABELS

//METHODS

export default class Wgc_HomePageNew_PTFClienti extends NavigationMixin(LightningElement) {

    @api title;
    @api iconName;

    connectedCallback(){

        // init()
        // .then(response =>{
        //     console.log('SV init.response', response);

        // })
        // .catch(error =>{
        //     console.error('SV init.error', error);
        // })
    }
}