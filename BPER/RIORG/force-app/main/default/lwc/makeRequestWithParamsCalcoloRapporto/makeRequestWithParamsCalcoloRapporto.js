import { LightningElement, track, api, wire } from 'lwc';
import makeRequestWithParams from '@salesforce/apex/MakeRequestController.makeRequestWithParams';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class MakeRequestWithParamsCalcoloRapporto extends LightningElement {

    @api recordId;
    @api apiRequests;
    @api certificateName;
    @api disableLog;
    @api requestOnConnectCallback;
    @api jsonParams;
    @api title;
    @api iconName;
    @api entrateCalcoloRapporto;
    @api isRendered;
    @api isRenderedDataTable;    
    @api responseData = [];    
    @api responseColumns;    
    @api rowOffset = 0;
    @api numRows;
    @api numPage;
    @api buttonX;
    @api buttonXName;
    @api requestChild;
    @api buttonPage = false;
    @api disabledButtonAvanti = false;
    @api disabledButtonIndietro = false;
    @api getAllParams;
    @api entrate;
    @api uscite;
    @track reddito;
    @track contatorePerMedia;
    @track contatoreEntrataMovimenti10;
    @track entrataMovimenti10=[];
    @track entrataMovimenti=[];
    @track contatoreUscitaMovimenti10;
    @track uscitaMovimenti10=[];
    @track uscitaMovimenti=[];
    @track redditoMedia;
    @track rapportoStimato;
    @track rataStimata;
    @track openmodel=false;
    @track showModel=false;
    @track isRenderdDataRapporto = false; 
    @track viewAllEntrate=false;
    @track viewAllUscite=false;
    @track altreEntrate;
    @track altreUscite;
    @track campoRichiesto;

    dateJson=
        {
        "0":0,
        "1":0,
        "2":0,
        "3":0,
        "4":0,
        "5":0,
        "6":0,
        "7":0,
        "8":0,
        "9":0,
        "10":0,
        "11":0,
    };
        
    connectedCallback(){
        let d = new Date();
        let n = d.getMonth();
        let y = d.getFullYear();
        console.log('date new '+ new Date(y, n+1, 0).getDate());
        this.responseColumns = JSON.parse(this.responseColumns);
        this.getAllParams = JSON.parse(this.jsonParams);
        if(!this.certificateName){
            this.certificateName = 'salesforcetestclient2024';
        }
        this.getAllParams.forEach(element => {
            if(element.page){
                this.buttonPage = true;
                this.numPage = element.value;
                if(element.value === 1) this.disabledButtonIndietro = true;
            }

            if(element.elementForPage){
                this.numRows = element.value;
            }

            if(element.type == 'date'&& element.label == 'Data contabile a'){
                
                element.value = d.getFullYear()  + "-" + (d.getMonth()+1) + "-" + d.getDate();      
            }else{

                let fourMonthsAgoDate = new Date();
                fourMonthsAgoDate.setFullYear(fourMonthsAgoDate.getFullYear() - 1);
                element.value = fourMonthsAgoDate.getFullYear() + "-" + (fourMonthsAgoDate.getMonth() + 1) + "-" + fourMonthsAgoDate.getDate();
            }
        });

        if(this.requestOnConnectCallback){
            // Create a request for the JSON data and load it synchronously,
            // parsing the response as JSON into the tracked property
            let request = new XMLHttpRequest();
            request.open("GET", jsonWrapper, false);
            request.send(null);
            let parsedJson = JSON.parse(request.responseText);

            //console.log('this.apiRequests: ' + this.apiRequests);
            if(Boolean(this.apiRequests)){
                let apiRequestsList = this.apiRequests.split(",");
                apiRequestsList.forEach(apiRequestName => {
        
                    makeRequestWithParams({
                        apiRequestName: apiRequestName,
                        recordId: this.recordId,
                        fieldsMap: parsedJson[apiRequestName].fields,
                        conditions: parsedJson[apiRequestName].conditionList ? parsedJson[apiRequestName].conditionList : null,
                        certificateName: this.certificateName,
                        runAsUserId: null,
                        params: JSON.stringify(this.getAllParams),
                        disableLog: this.disableLog
                    }).then(data =>{
                        let requestChild = this.requestChild.split('.');
                        let exampleData = JSON.parse(data);
                        let listaMov;
                        if(requestChild[0]){
                            if(requestChild[1]){
                            listaMov = JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]];
                            } else {
                            listaMov = JSON.parse(exampleData.response.data)[requestChild[0]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]];
                            }
                        }
                        //console.log('listaMov: ', listaMov);
                    this.responseColumns.forEach(element => {
                        listaMov.forEach(x => {

                        if(element.type == 'date'){
                            if(x[element.fieldName] != null){
                            let s = x[element.fieldName];
                            //2020-09-28T00:00:00.000+02:00
                            let split = s.split('T');
                            let date = split[0].split('-');
                            let hours = split[1].split(':');
                            let year = date[0];
                            let mounth = date[1];
                            let day = date[2];
                            let hour = hours[0];
                            let minutes = hours[1];
                            let d = new Date(year, mounth - 1, day, hour, minutes);
                            x[element.fieldName] = d;
                            }

                        }

                        if(element.hasOwnProperty('lenghtString') && element.type != 'date'){
                            x[element.fieldName] = x[element.fieldName].substring(0, element.lenghtString);
                        }
                        });
                    });
                    this.responseData = listaMov;

                    }).catch(reqError =>{
            
                        console.log('makeRequest.reqError: ', reqError);
                    }).finally(() =>{
                        this.isRenderedDataTable = true;
                        this.responseData.length < this.numRows ? this.disabledButtonAvanti = true : this.disabledButtonAvanti = false;
                        this.calcolaDatiTabelle();
                    });
                });
            }
        }
        
    }

    get notEmptyList(){
        return this.responseData.length > 0;
    }

    calcolaDatiTabelle(){

        this.dateJson=  {
            "0":0,
            "1":0,
            "2":0,
            "3":0,
            "4":0,
            "5":0,
            "6":0,
            "7":0,
            "8":0,
            "9":0,
            "10":0,
            "11":0,
        };
        let reddito=0;
        let contatorePerMedia=0;
        let contatoreEntrataMovimenti10=0;
        let entrataMovimenti10=[];
        let entrataMovimenti=[];
        let contatoreUscitaMovimenti10=0;
        let uscitaMovimenti10=[];
        let uscitaMovimenti=[];
        let date;
        let month;

        this.responseData.forEach(element => {

            if(this.entrate.includes(element.codiceCausale)){
        
                if(this.entrateCalcoloRapporto.includes(element.codiceCausale)){

                    date = new Date(element.dataContabile);
                    month = date.getMonth();
                    this.dateJson[month] = this.dateJson[month]+1;
                    reddito = reddito + element.importo;
                }

                if(contatoreEntrataMovimenti10 <= 9){
                    contatoreEntrataMovimenti10++;
                    entrataMovimenti10.push(element);
                }

                entrataMovimenti.push(element);
                
            }else if(this.uscite.includes(element.codiceCausale)){

                if(contatoreUscitaMovimenti10 <= 9){
                    contatoreUscitaMovimenti10++;
                    uscitaMovimenti10.push(element);
                }

                uscitaMovimenti.push(element);
                
            }
            
        });

        for (const [key, value] of Object.entries(this.dateJson)) {
            console.log(`${key}: ${value}`);
            
           if(value > 0){
            contatorePerMedia++;
           }
          };
          
        this.isRenderdDataRapporto = true;
        this.reddito= reddito;
        this.contatorePerMedia= contatorePerMedia;
        this.redditoMedia= reddito/contatorePerMedia;
        this.entrataMovimenti = entrataMovimenti;
        this.uscitaMovimenti = uscitaMovimenti;
        this.entrataMovimenti10 = entrataMovimenti10;
        this.uscitaMovimenti10 = uscitaMovimenti10;

    }

    handleChange(event){

        var index = event.currentTarget.id.split('-')[0]; 
        this.getAllParams.forEach(element => {
            if(element.key === index){
                element.value = event.detail.value;
            }
        });
    }

    handleCalutateRapporto(){

    if(!this.redditoMedia)this.redditoMedia=0;
    if(this.altreEntrate === undefined && this.altreUscite === undefined){
        this.altreEntrate = null;
        this.altreUscite = null; 
    }
    this.rapportoStimato = this.rataStimata/(this.redditoMedia + (this.altreEntrate - this.altreUscite));

        console.log('divisione: '+ (this.redditoMedia + (this.altreEntrate - this.altreUscite)));
        console.log('calcolo tot: '+ (this.rataStimata/(this.redditoMedia + this.altreEntrate - this.altreUscite)));
        console.log('redditoMedia: '+ this.redditoMedia);
        console.log('sottrazione: ' + (this.altreEntrate - this.altreUscite));
        console.log('entrate cal: '+ this.altreEntrate);
        console.log('uscite cal: '+ this.altreUscite);
    }

    blurInput(event){
        this.rataStimata=event.currentTarget.value;
    }

    blurInputEntrate(event){
        this.altreEntrate=event.currentTarget.value;
    }

    blurInputUscite(event){
        this.altreUscite=event.currentTarget.value;
    }


    handleSendRequest(event){
        this.altreEntrate=null;
        this.altreUscite=null;
        this.rataStimata=null;
        this.rapportoStimato=null;
        this.isRenderedDataTable = false;
        let params = this.getAllParams;
        let returnvalue = []; //assigning temp variable

        params.forEach(element => {
            if(element.input && element.hasOwnProperty('dependencyKey')){

            if(element.hasOwnProperty('value') && element.value != null){

                element.dependencyKey.forEach(x => {
                var inputCmp = this.template.querySelector("[data-item='" + x + "']");
                var value = inputCmp.value; //assigning value to variable
                // alert(x);

                if (value === "") {
                    //adding custom validation
                    inputCmp.setCustomValidity("Campo richiesto!");
                    returnvalue.push(false);
                } else {
                    //Removing validation error
                    inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
                    returnvalue.push(true);
                }
                inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
            
                });
            } else {
                element.dependencyKey.forEach(x => {
                var inputCmp = this.template.querySelector("[data-item='" + x + "']");
                // alert(x);
                inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
                returnvalue.push(true);
                inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction

                });
            }
            }
            
            if(element.picklist){            
            if(element.hasOwnProperty('value') && element.value != null){
                let pickVal = element.value;
                element.option.forEach(option => {
                if(option.hasOwnProperty('dependencyKey')){
                    if(pickVal == option.value){
                    option.dependencyKey.forEach(x => {
                        var inputCmp = this.template.querySelector("[data-item='" + x + "']");
                        var value = inputCmp.value; //assigning value to variable
                        // alert(x);
                        
                        if (value === "") {
                        //adding custom validation
                        inputCmp.setCustomValidity("Campo richiesto!");
                        returnvalue.push(false);
                        } else {
                        //Removing validation error
                        inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
                        returnvalue.push(true);
                        }
                        inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
                
                    });
                    }
                }
                });
            }            
            }
            
        });

        if(returnvalue.indexOf(false) === -1){
            
            let request = new XMLHttpRequest();
            request.open("GET", jsonWrapper, false);
            request.send(null);
            let parsedJson = JSON.parse(request.responseText);

            //console.log('this.apiRequests: ' + this.apiRequests);
            //console.log('params: ', JSON.stringify(this.getAllParams));
            if(Boolean(this.apiRequests)){

                let apiRequestsList = this.apiRequests.split(",");
                apiRequestsList.forEach(apiRequestName => {
        
                    makeRequestWithParams({
                        apiRequestName: apiRequestName,
                        recordId: this.recordId,
                        fieldsMap: parsedJson[apiRequestName].fields,
                        conditions: parsedJson[apiRequestName].conditionList ? parsedJson[apiRequestName].conditionList : null,
                        certificateName: 'salesforcetestclient2024',
                        runAsUserId: null,
                        params: JSON.stringify(this.getAllParams),
                    }).then(data =>{
                        let requestChild = this.requestChild.split('.');
                        let exampleData = JSON.parse(data);
                        let listaMov;
                        if(requestChild[0]){
                            if(requestChild[1]){
                            listaMov = JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]];
                            } else {
                            listaMov = JSON.parse(exampleData.response.data)[requestChild[0]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]];
                            }
                        }
                        this.responseColumns.forEach(element => {
                            listaMov.forEach(x => {
                                if(element.type == 'date'){
                                if(x[element.fieldName] != null){
                                    let s = x[element.fieldName];
                                    let split = s.split('T');
                                    let date = split[0].split('-');
                                    let hours = split[1].split(':');
                                    let year = date[0];
                                    let mounth = date[1];
                                    let day = date[2];
                                    let hour = hours[0];
                                    let minutes = hours[1];
                                    let d = new Date(year, mounth - 1, day, hour, minutes);
                                    x[element.fieldName] = d;
                                }
                                }

                                if(element.hasOwnProperty('lenghtString') && element.type != 'date'){
                                x[element.fieldName] = x[element.fieldName].substring(0, element.lenghtString);
                                }
                            });
                        });
                        this.responseData = listaMov;

                    }).catch(reqError =>{
            
                        console.log('makeRequest.reqError: ' + JSON.stringify(reqError));
                        
                    }).finally(() =>{
                    this.isRenderedDataTable = true;
                    if(this.responseData.length < this.numRows){
                        this.disabledButtonAvanti = true;
                    } else {
                        this.disabledButtonAvanti = false;
                    }

                    this.calcolaDatiTabelle();

                    });
                });
            }
        } else {
            this.isRenderedDataTable = true;
        }
    }

    openModal(event) {

        let id=event.currentTarget.id;
        if(id.includes('Entrate')){
            this.viewAllEntrate=true;
            this.viewAllUscite=false;
        }else{
            this.viewAllEntrate=false;
            this.viewAllUscite=true;
        }
        
        this.openmodel = true;
    }
  
    closeModal() {
        this.openmodel = false;
        this.viewAllEntrate=false;
        this.viewAllUscite=false;
    } 


    handleSendRequestAvanti(event){
        this.numPage = this.numPage + 1;
        this.getAllParams.forEach(element => {
            if(element.key === 'numeroPagina'){
                element.value = this.numPage;
            }
        });

        if(this.disabledButtonIndietro) this.disabledButtonIndietro = false;

        // Create a request for the JSON data and load it synchronously,
        // parsing the response as JSON into the tracked property
        let request = new XMLHttpRequest();
        request.open("GET", jsonWrapper, false);
        request.send(null);
        let parsedJson = JSON.parse(request.responseText);

        //console.log('this.apiRequests: ' + this.apiRequests);
        if(Boolean(this.apiRequests)){

            let apiRequestsList = this.apiRequests.split(",");
            apiRequestsList.forEach(apiRequestName => {
    
                makeRequestWithParams({
                    apiRequestName: apiRequestName,
                    recordId: this.recordId,
                    fieldsMap: parsedJson[apiRequestName].fields,
                    conditions: parsedJson[apiRequestName].conditionList ? parsedJson[apiRequestName].conditionList : null,
                    certificateName: 'salesforcetestclient2024',
                    runAsUserId: null,
                    params: JSON.stringify(this.getAllParams),
                }).then(data =>{
                        let requestChild = this.requestChild.split('.');
                        let exampleData = JSON.parse(data);
                        let listaMov = JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]];

                        this.responseColumns.forEach(element => {
                        listaMov.forEach(x => {
                            if(element.type == 'date'){
                            if(x[element.fieldName] != null){
                                let s = x[element.fieldName];
                                let split = s.split('T');
                                let date = split[0].split('-');
                                let hours = split[1].split(':');
                                let year = date[0];
                                let mounth = date[1];
                                let day = date[2];
                                let hour = hours[0];
                                let minutes = hours[1];
                                let d = new Date(year, mounth - 1, day, hour, minutes);
                                x[element.fieldName] = d;
                            }
                            }

                            if(element.hasOwnProperty('lenghtString') && element.type != 'date'){
                                x[element.fieldName] = x[element.fieldName].substring(0, element.lenghtString);
                            }
                        });
                        });

                        this.responseData = listaMov;
                        console.log(this.responseColumns);
                        console.log(this.responseData);
        
    
                }).catch(reqError =>{
        
                    console.log('makeRequest.reqError: ' + JSON.stringify(reqError));

                }).finally(() =>{
                    this.isRenderedDataTable = true;
                    if(this.responseData.length < this.numRows){
                        this.disabledButtonAvanti = true;
                    }

                });
            });
        }

    }

    handleSendRequestIndietro(event){
        this.numPage = this.numPage - 1;
        this.getAllParams.forEach(element => {
            if(element.key === 'numeroPagina'){
                element.value = this.numPage;
            }
        });

        if(this.numPage === 1){
            this.disabledButtonIndietro = true;
        }

        // Create a request for the JSON data and load it synchronously,
        // parsing the response as JSON into the tracked property
        let request = new XMLHttpRequest();
        request.open("GET", jsonWrapper, false);
        request.send(null);
        let parsedJson = JSON.parse(request.responseText);

        //console.log('this.apiRequests: ' + this.apiRequests);
        if(Boolean(this.apiRequests)){

            let apiRequestsList = this.apiRequests.split(",");
            apiRequestsList.forEach(apiRequestName => {
    
                makeRequestWithParams({
                    apiRequestName: apiRequestName,
                    recordId: this.recordId,
                    fieldsMap: parsedJson[apiRequestName].fields,
                    conditions: parsedJson[apiRequestName].conditionList ? parsedJson[apiRequestName].conditionList : null,
                    certificateName: 'salesforcetestclient2024',
                    runAsUserId: null,
                    params: JSON.stringify(this.getAllParams),
                }).then(data =>{
                    let requestChild = this.requestChild.split('.');
                    let exampleData = JSON.parse(data);
                    let listaMov = JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]];

                    this.responseColumns.forEach(element => {
                        listaMov.forEach(x => {
                            if(element.type == 'date'){
                                if(x[element.fieldName] != null){
                                    let s = x[element.fieldName];
                                    let split = s.split('T');
                                    let date = split[0].split('-');
                                    let hours = split[1].split(':');
                                    let year = date[0];
                                    let mounth = date[1];
                                    let day = date[2];
                                    let hour = hours[0];
                                    let minutes = hours[1];
                                    let d = new Date(year, mounth - 1, day, hour, minutes);
                                    x[element.fieldName] = d;
                                }
                            }

                            if(element.hasOwnProperty('lenghtString') && element.type != 'date'){
                                x[element.fieldName] = x[element.fieldName].substring(0, element.lenghtString);
                            }
                        });
                    });

                    this.responseData = listaMov;
        
    
                }).catch(reqError =>{
        
                    console.log('makeRequest.reqError: ' + JSON.stringify(reqError));

                }).finally(() =>{

                    this.isRenderedDataTable = true;
                    if(this.responseData.length < this.numRows){
                        this.disabledButtonAvanti = true;
                    }else{
                        this.disabledButtonAvanti = false;
                    }
                });
            });
        }
    }
    
    handleRefresh(event){
        
        let d= new Date();
        this.getAllParams.forEach(element => {
            if(element.type == 'date'&& element.label == 'Data contabile a'){
                element.value = d.getFullYear()  + "-" + (d.getMonth()+1) + "-" + d.getDate(); 
                this.template.querySelector("[data-item='" + element.key + "']").value= element.value;     
            }else{
                let fourMonthsAgoDate = new Date();
                fourMonthsAgoDate.setFullYear(fourMonthsAgoDate.getFullYear() - 1);
                element.value = fourMonthsAgoDate.getFullYear() + "-" + (fourMonthsAgoDate.getMonth() + 1) + "-" + fourMonthsAgoDate.getDate();
                this.template.querySelector("[data-item='" + element.key + "']").value= element.value;
            }
        });
        
    }
}