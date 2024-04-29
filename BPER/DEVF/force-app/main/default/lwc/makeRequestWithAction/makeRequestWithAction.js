import { LightningElement, track, api, wire } from 'lwc';
import makeRequest from '@salesforce/apex/MakeRequestController.makeRequest';
import initInfo from '@salesforce/apex/MakeRequestWithActionController.initInfo';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import jsonWrapper from '@salesforce/resourceUrl/jsonWrapper';
export default class MakeRequestWithAction extends LightningElement {
    @api recordId;
    @track apiRequests;
    @api jsonParams;
    @api certificateName;
    @api disableLog;
  

    @track firstValueSelectedRequest = '';

    @api secondPicklistJson;
    secondPicklist = {};
    @track v = {};
    @track secondPicklistValues;
    @track secondValueSelectedRequest = '';

    @api title;
    @api iconName;

    parsedJson = {};

    @track showSecondPL = false;
    @track disableAction = true;

    @track responseData;

    @track params = {};

    @track loading = true;

    @track infoNDG;

    @track noAction = true;
    

    executeCall = false;


    connectedCallback(){

        this.apiRequests = JSON.parse(this.jsonParams); 
        this.secondPicklist = JSON.parse(this.secondPicklistJson);

        let request = new XMLHttpRequest();
        request.open("GET", jsonWrapper, false);
        request.send(null);
        this.parsedJson = JSON.parse(request.responseText);


        initInfo({recId: this.recordId})
        .then(result =>{
            console.log('GR result: ', result);
            this.infoNDG = result;
        }).catch(error =>{
            console.log('GR error: ' + error);
        }).finally(() => {
            this.loading = false;
            console.log('GR actions:',this.apiRequests);
            console.log('GR infoNDG:', this.infoNDG);

            let actions = this.apiRequests;
            let ndg = this.infoNDG[0];
            let activeAction = [];
            
            actions.forEach(element => {
                if(element.filterLogic && element.condition){

                    let filterLogic = element.filterLogic; 
                    console.log('GR filterLogic ', filterLogic);
                    element.condition.forEach(condition => {
                        let value = ndg[condition.campo] + condition.operator + condition.value;
                        console.log('GR value ', value);
                        
                        let c = false;
                        switch (condition.operator) {
                            case '==':
                                c = ndg[condition.campo] === condition.value ? true : false;
                                break;
                            case '!=':
                                c = ndg[condition.campo] != condition.value ? true : false;
                                break;
                            case '>':
                                c = ndg[condition.campo] > condition.value ? true : false;
                                break;
                            case '<':
                                c = ndg[condition.campo] < condition.value ? true : false;
                                break;
                            case '>=':
                                c = ndg[condition.campo] >= condition.value ? true : false;
                                break;
                            case '<=':
                                c = ndg[condition.campo] <= condition.value ? true : false;
                                break;
                            default:
                                c = false;
                        }
                        
                        filterLogic = filterLogic.replace(condition.id, c);
                    })
                    
                    filterLogic = filterLogic.replace('AND', '&&').replace('OR', '||');
    
                    if(eval(filterLogic)){
                        activeAction.push(element);
                    }
                }else{
                    activeAction.push(element);
                }
                
                console.log('GR activeAction ', activeAction);

            })

            if(activeAction.length > 0){
                this.noAction = false;
            }
            this.apiRequests = activeAction;
        });

    }

    handleChangeRequest(event){
        console.log('DK event.target.value: ' + event.target.value);
        this.secondValueSelectedRequest = '';
        this.params = {};
        this.firstValueSelectedRequest = event.target.value;
        if(this.secondPicklist[this.firstValueSelectedRequest]){
            this.getResponse(this.secondPicklist[this.firstValueSelectedRequest]).then(response =>{
                
                console.log('DK response', this.responseData);
                if(this.responseData != null){
    
                    console.log('DK response is NOT NULL');
                    if(this.responseData.statusCode.startsWith("2")){

                        let parsedResponseData = this.responseData;
                        let parsedData = JSON.parse(parsedResponseData.response.data);
                        let secondPickList = [];
                        parsedData.listaTipiBlocco.forEach(element => {
                            
                            secondPickList.push({label: element.descrizione, value: element.codice});
                        });
                        console.log('DK secondPickList', secondPickList);
                        this.secondPicklistValues = secondPickList;
                        this.showSecondPL = true;
                        this.disableAction = true;
                    }
                }
            });
        }else{
            this.showSecondPL = false;
            this.disableAction = false;
        }
    }

    secondHandleChangeRequest(event){
        console.log('DK event.target.value: ' + event.target.value);
        this.secondValueSelectedRequest = event.target.value;
        this.showSecondPL = true;
        this.disableAction = false;

        this.params.codiceBlocco = this.secondValueSelectedRequest;
    }
    
    handleAction(){
        console.log('DK makeRequestWithAction handleAction START');
        try {
            
            this.getResponse(this.firstValueSelectedRequest).
            then(response =>{
                
                console.log('DK response', this.responseData);
                if(this.responseData != null){
    
                    console.log('DK response is NOT NULL');
                    if(this.responseData.statusCode.startsWith("2")){

                        const toastEvent = new ShowToastEvent({
                            title: "Success!",
                            message: "L'operazione richiesta è andata a buon fine.",
                            variant: "success"
                        });
                        this.dispatchEvent(toastEvent);
                        this.executeCall = true;
                    }
                }
            }).catch(reqError =>{
    
                console.log('DK handleAction.reqError: ' + JSON.stringify(reqError));
                this.responseData = null;
            }).finally(() =>{
    
                eval("$A.get('e.force:refreshView').fire();");
            });
        } catch (error) {
            
            console.log('reqError: ' + error);
        }
    }
    
    getResponse(requestName){

        this.loading = true;
        console.log('DK makeRequestWithAction getResponse START');
        console.log('DK requestName', requestName);
        console.log('DK params', JSON.stringify(this.params));
        return makeRequest({
            apiRequestName: requestName,
            recordId: this.recordId,
            fieldsMap: this.parsedJson[requestName].fields,
            conditions: this.parsedJson[requestName].conditionList ? this.parsedJson[requestName].conditionList : null,
            certificateName: this.certificateName,
            runAsUserId: null,
            disableLog: this.disableLog,
            params: JSON.stringify(this.params)
        }).then(data =>{
    
            console.log('DK getResponse.data: ' + data);
            this.responseData = JSON.parse(data);
            this.loading = false;
            console.log('DK getResponse.this.responseData', this.responseData);
            if(!this.responseData.statusCode.startsWith("2")){

                const toastEvent = new ShowToastEvent({
                    title: "Error!",
                    message: "L'operazione richiesta NON è andata a buon fine in quanto il servizio non ha fornito risposta",
                    variant: "error"
                });
                this.dispatchEvent(toastEvent);
            }
        }).catch(reqError =>{
    
            console.log('DK getResponse.reqError: ' + JSON.stringify(reqError));
            console.log('DK getResponse.reqError: ' + reqError);
            this.responseData = null;
            this.loading = false;
            const toastEvent = new ShowToastEvent({
                title: "Error!",
                message: "L'operazione richiesta NON è andata a buon fine per errore applicativo",
                variant: "error"
            });
            this.dispatchEvent(toastEvent);
        });
    }
}