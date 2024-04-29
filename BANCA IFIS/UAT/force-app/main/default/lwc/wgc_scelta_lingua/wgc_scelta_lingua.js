import { LightningElement, api, track} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import cssSceltaLinguaLWC from '@salesforce/resourceUrl/cssSceltaLinguaLWC';
import getLanguage from '@salesforce/apex/WGC_Documenti_Controller.getLanguage';

export default class Wgc_scelta_lingua extends LightningElement {

    @api isRSF = false;
    lingue;
    @track linguaScelta;

    showSpinner = false;

    get existLingue(){
        return this.lingue!=undefined && this.lingue.length > 0;
    }

    get enableScelta(){
        return !this.linguaScelta!='';
    }
 
    connectedCallback(){
        //Used for override standard CSS
        loadStyle(this, cssSceltaLinguaLWC);        
        this.initialize();
    }     

    initialize(){
        this.enableSpinner();
        getLanguage({"isRSF" : this.isRSF})
            .then(risposta => {  
                if (risposta.success){
                    console.log('@@@ risposta lingue ' , risposta.data[0]); 
					
					var listaLingue = [];
					for(var key in risposta.data[0]){
						console.log('@@@ risposta.data[0][key] ' , risposta.data[0][key]);
						console.log('@@@ key ' , key);
						if(key == 'Italiano'){
							console.log('@@@ Italiano' );
							this.linguaScelta = risposta.data[0][key];
						}

						listaLingue.push({"label" : key, "value" : risposta.data[0][key] });
					}

					console.log('@@@ listaLingue ' , listaLingue);
					this.lingue = listaLingue;
                }                
            }).finally(() => {
                this.disableSpinner();                
            });
    }

    changeLanguage(event){
        this.linguaScelta = event.target.value;
    }

    // CUSTOM EVENT
    close(){   
        this.dispatchEvent(
            new CustomEvent('languagemodal', { bubbles: true, composed: true, detail : { open: false} })
        );
    }

    selezionaLingua(){
        this.dispatchEvent(
            new CustomEvent('changelanguage', { bubbles: true, composed: true, detail : { open: false, language: this.linguaScelta}})
        );
    }

    enableSpinner(){
        this.showSpinner = true;
    }

    disableSpinner(){
        this.showSpinner = false;
    }
}