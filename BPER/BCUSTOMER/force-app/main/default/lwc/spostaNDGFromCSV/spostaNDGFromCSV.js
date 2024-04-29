import { LightningElement, track, api }  from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

// Import Controller Methods
import getDate from '@salesforce/apex/PTF_SpostaNDGFromCSVController.getDate';
import saveRecords from '@salesforce/apex/PTF_SpostaNDGFromCSVController.saveRecords';


export default class SpostaNDGFromCSV  extends NavigationMixin(LightningElement) {

    @track columns = [{
            label: 'Id',
            fieldName: 'Id',
            type: 'text',
            sortable: false
        },
        {
            label: 'NDG',
            fieldName: 'CRM_NDG__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'PTF OLD',
            fieldName: 'PTF_OLD_Name',
            type: 'text',
            sortable: false
        },
        {
            label: 'PTF NEW',
            fieldName: 'PTF_NEW_Name',
            type: 'text',
            sortable: false
        }

    ];

    @track error;
    @track isButtonDisabled = false;
    @track data;
    @track objList;
    @track loaded = true;

    @track selectedRows;

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        this.loaded = !this.loaded;

        var sal = this;
        const uploadedFiles = event.detail.files;

        console.log(uploadedFiles);
        var tabledata=[];
        var reader = new FileReader();
        reader.readAsText(uploadedFiles[0], "UTF-8");

        reader.onload = function (event) {

            var csv = event.target.result;
            var rows = csv.split("\n"); //righe

            var trimrow=rows[0].replace(/[^_a-zA-Z0-9,]/g, "").split(",");
            console.log("trimrow: ",trimrow);

            var ndgIndex = null;
            var abiIndex = null;
            var idPtfIndex = null;
            var cedfilialeIndex = null;
            for (var i = 0; i<trimrow.length; i++){
                if(trimrow[i].toLowerCase() === "ndg"){
                            ndgIndex = i;
                        }
                        if(trimrow[i].toLowerCase() === "abi"){
                            abiIndex = i;
                        }
                        if(trimrow[i].toLowerCase() === "ptf_portafoglio__c"){
                            idPtfIndex = i;
                        }
                        if(trimrow[i].toLowerCase() === "cedfiliale"){
                            cedfilialeIndex = i;
                        }
            }
            console.log(idPtfIndex);

            var objList = [];
            for(var j = 1; j< rows.length;j++){
                    var cells = rows[j].split(",");  
                    console.log(cells);
                    objList.push({
                                ndgNumber : ndgIndex!=null ? cells[ndgIndex].replace(/[^a-zA-Z0-9,]/g, "") : '',
                                abi       : abiIndex!=null ? cells[abiIndex].replace(/[^a-zA-Z0-9,]/g, "") : '',
                                newPTFId  : idPtfIndex!=null ? cells[idPtfIndex].replace(/[^a-zA-Z0-9,]/g, "") : '',
                                newCedfiliale  : cedfilialeIndex!=null ? cells[cedfilialeIndex].replace(/[^a-zA-Z0-9,]/g, "") : '',
                            });
            }

            console.log(objList);
            sal.objList = objList;

            getDate({objList : JSON.stringify(objList)})
            .then(result => {
                console.log('result', result);
                var dataList =[];
                let ndgMap = result.ndgMap;
                let filialiMap = result.filialiMap;
                let ptfMap = result.ptfMap;
                let csvList = sal.objList;
                for (var key in ndgMap) {
                    ndgMap[key].PTF_OLD_Name = ndgMap[key].PTF_Portafoglio__r.Name;
                    ndgMap[key].PTF_OLD_Id = ndgMap[key].PTF_Portafoglio__r.Id;
                    ndgMap[key].FILIALE_OLD_Name = ndgMap[key].PTF_Filiale__r.Name;
                    ndgMap[key].FILIALE_OLD_Id = ndgMap[key].PTF_Filiale__r.Id;
                    csvList.forEach(element => {
                        if(element.ndgNumber === ndgMap[key].CRM_NDG__c){
                            // PORTAFOGLIO
                            ndgMap[key].PTF_NEW_Name = ptfMap[element.newPTFId].Name;
                            ndgMap[key].PTF_Portafoglio__c = element.newPTFId;
                            ndgMap[key].PTF_Portafoglio__r.Name = ptfMap[element.newPTFId].Name;
                            ndgMap[key].PTF_Portafoglio__r.Id = element.newPTFId;

                            // FILIALE
                            ndgMap[key].FILIALE_NEW_Name = filialiMap[element.newCedfiliale].Name;
                            ndgMap[key].PTF_Filiale__c = filialiMap[element.newCedfiliale].Id;
                            ndgMap[key].PTF_Filiale__r.Name = filialiMap[element.newCedfiliale].Name;
                            ndgMap[key].PTF_Filiale__r.Id = filialiMap[element.newCedfiliale].Id;
                            ndgMap[key].PTF_Filiale__r.PTF_IdCEDFiliale__c = filialiMap[element.newCedfiliale].PTF_IdCEDFiliale__c;
                        }
                    });
                    
                    dataList.push(ndgMap[key]);
                }

                sal.data = dataList;
            })
            .catch(error => {
                console.log('ERROR', error);
                const event = new ShowToastEvent({
                    "variant": "error",
                    "title": "Error!",
                    "message": error.body.message
                });
                sal.dispatchEvent(event);
                sal.loaded = !sal.loaded;
            })
            .finally(() => {
                sal.loaded = !sal.loaded;
            });
        }       
    }

    handleCreateRecords(event) {
        this.loaded = !this.loaded;

        var el = this.template.querySelector('lightning-datatable[data-id=datatableRecords]');
        var selected = el.getSelectedRows();
        console.log(JSON.stringify(selected));

        // calling apex class
        saveRecords({objList : JSON.stringify(selected)})
        .then(result => {
            console.log(result);
            if(result){
                const event = new ShowToastEvent({
                    "variant": "success",
                    "title": "Success!",
                    "message": "ndg spostati con successo"
                });
                this.dispatchEvent(event);
            } 
        })
        .catch(error => {
            console.log(error);
            console.log('ERROR');
            const event = new ShowToastEvent({
                "variant": "error",
                "title": "Error!",
                "message": error.body.message
            });
            this.dispatchEvent(event);
            this.loaded = !sal.loaded;
        })
        .finally(() => {
            this.loaded = !this.loaded;
        });
        
    }
}