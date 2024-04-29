import { LightningElement, track, api,wire }  from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

// Import Controller Methods
import getStrutturaFiliale from '@salesforce/apex/creaPortafoglioFromCSVController.getStrutturaFiliale';
import saveMicroWalletFromCSV from '@salesforce/apex/creaPortafoglioFromCSVController.saveMicroWalletFromCSV';

export default class creaPortafoglioFromCSV extends NavigationMixin(LightningElement) {

    @track columns = [{
            label: 'Modello di servizio',
            fieldName: 'modelloServizio',
            type: 'text',
            sortable: false
        },
        {
            label: 'Abi',
            fieldName: 'abi',
            type: 'text',
            sortable: false
        },
        {
            label: 'CED Filiale',
            fieldName: 'cedfiliale',
            type: 'text',
            sortable: false
        },
        {
            label: 'Matricola da assegnare',
            fieldName: 'matricola',
            type: 'text',
            sortable: false
        }

    ];

    //INPUT CSV
    @api selectedRows = [];
    @api mapWallets = [];
    @api getAllData;
    @api getAllModelli;
    @api isRendered;

    @track error;
    @track data;
    @track objList;
    @track loaded = true;

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }

    connectedCallback() {

        this.isRendered = true;

    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        this.loaded = !this.loaded;
        var sal = this;
        const uploadedFiles = event.detail.files;
        var reader = new FileReader();

        reader.readAsText(uploadedFiles[0], "UTF-8");

        //inizio funzione di caricamento file
        reader.onload = function (event) {

            var csv = event.target.result;
            var rows = csv.split("\n"); //righe

            var trimrow = rows[0].replace(/[^_a-zA-Z0-9 ,]/g, "").split(",");
            console.log("trimrow: ", trimrow);

            var modelloDiServizioIndex = null;
            var abiIndex = null;
            var cedfilialeIndex = null;
            var matricolaIndex = null;
            for (var i = 0; i < trimrow.length; i++) {
                if (trimrow[i].toLowerCase() === "modello di servizio") {
                    modelloDiServizioIndex = i;
                }
                if (trimrow[i].toLowerCase() === "abi") {
                    abiIndex = i;
                }
                if (trimrow[i].toLowerCase() === "ced filiale") {
                    cedfilialeIndex = i;
                }
                if (trimrow[i].toLowerCase() === "matricola da assegnare") {
                    matricolaIndex = i;
                }

            }

            var objList = [];

            for (var j = 1; j < rows.length; j++) {
                var cells = rows[j].split(",");
                console.log('CELLE', cells);
                objList.push({
                    modelloServizio: modelloDiServizioIndex != null ? cells[modelloDiServizioIndex].replace(/[^a-zA-Z0-9 ,]/g, "") : '',
                    abi: abiIndex != null ? cells[abiIndex].replace(/[^a-zA-Z0-9,]/g, "") : '',
                    cedfiliale: cedfilialeIndex != null ? cells[cedfilialeIndex].replace(/[^a-zA-Z0-9,]/g, "") : '',
                    matricola: matricolaIndex != null ? cells[matricolaIndex].replace(/[^a-zA-Z0-9,]/g, "") : '',
                });
            }

            sal.objList = objList;
            sal.data = objList;
            sal.loaded = !sal.loaded;

        }

    }
    handleSelectedRows(event) {
        let selectedR = event.detail.selectedRows;

        // Display that fieldName of the selected rows
        var mapWallets = [];
        for (let i = 0; i < selectedR.length; i++) {

            mapWallets.push({
                PTFnum: i,
                modelloServizio: selectedR[i].modelloServizio,
                abi: selectedR[i].abi,
                cedfiliale: selectedR[i].cedfiliale,
                matricola: selectedR[i].matricola,
            });

        }

        this.mapWallets = mapWallets;
        

    }
    //*********inizio elebarazione del file csv per calcolare tutti i parametri utili alla creazione dei portafogli**********

    generateWalletName() {

        this.isRendered = false;
        console.log('MAPWALLET ',JSON.stringify(this.mapWallets));

        getStrutturaFiliale({
                mapWallets: JSON.stringify(this.mapWallets)
            })
            .then(result => {
                console.log('Gb StrutturaFiliale', result);

                return saveMicroWalletFromCSV({
                    walletsFromWrapper: JSON.stringify(result)
                })
            })
            .then(result => {

                this.isRendered = true;

                console.log('SV saveMicroWallet result', result);

                if (result) {
                    const x = new ShowToastEvent({
                        "title": "Successo!",
                        "variant": "success",
                        "message": "micro-portafogli creati!"
                    });
                    this.dispatchEvent(x);

                    this[NavigationMixin.Navigate]({
                        "type": "standard__objectPage",
                        "attributes": {
                            objectApiName: 'Wallet__c',
                            actionName: 'list'
                        }
                    });
                }

            })
            .catch(error => {
                this.error = error;
            
                console.log('GB Errore Generazione PTF', error);
                /* const x = new ShowToastEvent({
                    "title": "Attenzione!",
                    "variant": "warning",
                    "message": error.body.pageErrors[0].message
                });
                this.dispatchEvent(x); */
                this.isRendered = true;

            })
            .finally(() => {
                console.log('SV FINALLY');

                this.isRendered = true;
            });


    }


}