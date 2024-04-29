import { LightningElement, track, api, wire } from 'lwc';

import makeRequestWithParams from '@salesforce/apex/MakeRequestController.makeRequestWithParams';
import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper';
/*
export const EXAMPLES_COLUMNS_DEFINITION_BASIC = [
    { "label": "dataContabile", "fieldName": "dataContabile", "type": "text" },
    { "label": "numeroMovimento", "fieldName": "numeroMovimento", "type": "text" },
    { "label": "importo", "fieldName": "importo", "type": "text" },
    { "label": "dataValuta", "fieldName": "dataValuta", "type": "text" },
    { "label": "descrizione", "fieldName": "descrizione", "type": "text" },
    { "label": "codiceCausale", "fieldName": "codiceCausale", "type": "text" },
    { "label": "codiceTipo", "fieldName": "codiceTipo", "type": "text" },
    { "label": "descrizioneTipo", "fieldName": "descrizioneTipo", "type": "text" },
    { "label": "progressivo", "fieldName": "progressivo", "type": "text" },
    { "label": "nota", "fieldName": "nota", "type": "text" },
    { "label": "codiceCategoria", "fieldName": "codiceCategoria", "type": "text" },
];
*/

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class MakeRequestWithParams extends LightningElement {
    @api recordId;
    @api apiRequests;
    @api certificateName;
    @api disableLog;
    @api requestOnConnectCallback;
    @api jsonParams;
    @api title;
    @api iconName;
    
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
    
    connectedCallback(){
        let d = new Date();
        let n = d.getMonth();
        let y = d.getFullYear();
        console.log(new Date(y, n+1, 0).getDate());
        this.responseColumns = JSON.parse(this.responseColumns);
        this.getAllParams = JSON.parse(this.jsonParams);
        if(!this.certificateName){
          this.certificateName = 'salesforceprodclient2022';
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

            if(element.type == 'date'){
                if(element.setValue){
                  switch (element.setValue) {
                    case "today":
                      element.value = d.getFullYear()  + "-" + (d.getMonth()+1) + "-" + d.getDate();
                      break;
                    case "endDate":
                      element.value = d.getFullYear()  + "-" + (d.getMonth()+1) + "-" + new Date(y, n+1, 0).getDate();
                      break;
                    case "startDate":
                      element.value = d.getFullYear()  + "-" + (d.getMonth()+1) + "-" + "01";
                      break;
                    default:
                  }
                }
            }
        });

        if(this.requestOnConnectCallback){
          // Create a request for the JSON data and load it synchronously,
          // parsing the response as JSON into the tracked property
          let request = new XMLHttpRequest();
          request.open("GET", jsonWrapper, false);
          request.send(null);
          let parsedJson = JSON.parse(request.responseText);

          console.log('this.apiRequests: ' + this.apiRequests);
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
          
                    console.log('data: ', data);
                        let requestChild = this.requestChild.split('.');
                        console.log('requestChild: ', requestChild);

                        let exampleData = JSON.parse(data);
                        console.log('exampleData: ', exampleData);
                        let listaMov;
                        if(requestChild[0]){
                          if(requestChild[1]){
                            listaMov = JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]];
                          } else {
                            listaMov = JSON.parse(exampleData.response.data)[requestChild[0]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]];
                          }
                        }
                        console.log('listaMov: ', listaMov);
                    // this.responseColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;
                    this.responseColumns.forEach(element => {
                      listaMov.forEach(x => {
                        console.log(x[element.fieldName]);
                        // console.log(x[element.fieldName].substring(0, element.lenghtString));

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
                    console.log(this.responseColumns);
                    console.log(this.responseData);
      
                  }).catch(reqError =>{
          
                      console.log('makeRequest.reqError: ', reqError);
                  }).finally(() =>{
                      this.isRenderedDataTable = true;
                      if(this.responseData.length < this.numRows){
                        this.disabledButtonAvanti = true;
                      } else {
                        this.disabledButtonAvanti = false;
                      }
                  });
              });
          }
        }
        
    }

    get notEmptyList(){
        return this.responseData.length > 0;
    }

    handleChange(event){
        var index = event.currentTarget.id.split('-')[0]; 

        this.getAllParams.forEach(element => {
            if(element.key === index){
                element.value = event.detail.value;
            }
        });

        console.log(this.getAllParams);

    }

    handleSendRequest(event){
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

        // alert(JSON.stringify(returnvalue));

        if(returnvalue.indexOf(false) === -1){
          // Create a request for the JSON data and load it synchronously,
          // parsing the response as JSON into the tracked property
          let request = new XMLHttpRequest();
          request.open("GET", jsonWrapper, false);
          request.send(null);
          let parsedJson = JSON.parse(request.responseText);

          console.log('this.apiRequests: ' + this.apiRequests);
          console.log('params: ', JSON.stringify(this.getAllParams));
          if(Boolean(this.apiRequests)){

              let apiRequestsList = this.apiRequests.split(",");
              apiRequestsList.forEach(apiRequestName => {
      
                  makeRequestWithParams({
                      apiRequestName: apiRequestName,
                      recordId: this.recordId,
                      fieldsMap: parsedJson[apiRequestName].fields,
                      conditions: parsedJson[apiRequestName].conditionList ? parsedJson[apiRequestName].conditionList : null,
                      certificateName: 'salesforceprodclient2022',
                      runAsUserId: null,
                      params: JSON.stringify(this.getAllParams),
                  }).then(data =>{
          
                    console.log('data: ' + data);
                        let requestChild = this.requestChild.split('.');
                        console.log('requestChild: ', requestChild);

                        let exampleData = JSON.parse(data);
                        console.log('exampleData: ' + exampleData);
                        let listaMov;
                        if(requestChild[0]){
                          if(requestChild[1]){
                            listaMov = JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]];
                          } else {
                            listaMov = JSON.parse(exampleData.response.data)[requestChild[0]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]];
                          }
                        }
                        console.log('listaMov: ', listaMov);

                        // this.responseColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;
                        this.responseColumns.forEach(element => {
                            listaMov.forEach(x => {
                              console.log(x[element.fieldName]);
                              // console.log(x[element.fieldName].substring(0, element.lenghtString));

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
                        console.log(this.responseColumns);
                        console.log(this.responseData);
        

                  }).catch(reqError =>{
          
                      console.log('makeRequest.reqError: ' + JSON.stringify(reqError));
                      
                  }).finally(() =>{
                    this.isRenderedDataTable = true;
                    if(this.responseData.length < this.numRows){
                      this.disabledButtonAvanti = true;
                    } else {
                      this.disabledButtonAvanti = false;
                    }

                  });
              });
          }
        } else {
          this.isRenderedDataTable = true;

        }
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

        console.log('this.apiRequests: ' + this.apiRequests);
        if(Boolean(this.apiRequests)){

            let apiRequestsList = this.apiRequests.split(",");
            apiRequestsList.forEach(apiRequestName => {
    
                makeRequestWithParams({
                    apiRequestName: apiRequestName,
                    recordId: this.recordId,
                    fieldsMap: parsedJson[apiRequestName].fields,
                    conditions: parsedJson[apiRequestName].conditionList ? parsedJson[apiRequestName].conditionList : null,
                    certificateName: 'salesforceprodclient2022',
                    runAsUserId: null,
                    params: JSON.stringify(this.getAllParams),
                }).then(data =>{
        
                  console.log('data: ' + data);
                      let requestChild = this.requestChild.split('.');
                      let exampleData = JSON.parse(data);
                      console.log('exampleData: ' + exampleData);
                      let listaMov = JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]];

                      // this.responseColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;
                      this.responseColumns.forEach(element => {
                        listaMov.forEach(x => {
                          console.log(x[element.fieldName]);
                          // console.log(x[element.fieldName].substring(0, element.lenghtString));
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

        console.log('this.apiRequests: ' + this.apiRequests);
        if(Boolean(this.apiRequests)){

            let apiRequestsList = this.apiRequests.split(",");
            apiRequestsList.forEach(apiRequestName => {
    
                makeRequestWithParams({
                    apiRequestName: apiRequestName,
                    recordId: this.recordId,
                    fieldsMap: parsedJson[apiRequestName].fields,
                    conditions: parsedJson[apiRequestName].conditionList ? parsedJson[apiRequestName].conditionList : null,
                    certificateName: 'salesforceprodclient2022',
                    runAsUserId: null,
                    params: JSON.stringify(this.getAllParams),
                }).then(data =>{
        
                  console.log('data: ' + data);
                      let requestChild = this.requestChild.split('.');
                      let exampleData = JSON.parse(data);
                      console.log('exampleData: ' + exampleData);
                      let listaMov = JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]] == null ? [] : JSON.parse(exampleData.response.data)[requestChild[0]][requestChild[1]];

                      // this.responseColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;
                      this.responseColumns.forEach(element => {
                        listaMov.forEach(x => {
                          console.log(x[element.fieldName]);
                          // console.log(x[element.fieldName].substring(0, element.lenghtString));
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
                      console.log(this.responseColumns);
                      console.log(this.responseData);
      
    
                }).catch(reqError =>{
        
                    console.log('makeRequest.reqError: ' + JSON.stringify(reqError));

                }).finally(() =>{
                    this.isRenderedDataTable = true;
                    if(this.responseData.length < this.numRows){
                      this.disabledButtonAvanti = true;
                    } else {
                      this.disabledButtonAvanti = false;
                    }
                });
            });
        }
    }
    
    handleRefresh(event){
      console.log('X', this.getAllParams);
      console.log('Y', JSON.parse(this.jsonParams));
      let restore = JSON.parse(this.jsonParams);
      restore.forEach(element => {
        this.template.querySelector("[data-item='" + element.key + "']").value = element.hasOwnProperty('value') ? element.value : null;
        this.getAllParams.forEach(par => {
          if(par.key == element.key) par.value = element.hasOwnProperty('value') ? element.value : null;
        });
      });
    }
}