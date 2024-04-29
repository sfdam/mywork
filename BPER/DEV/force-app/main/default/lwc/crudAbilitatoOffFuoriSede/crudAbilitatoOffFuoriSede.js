import { LightningElement, track, api, wire } from 'lwc';
import init from '@salesforce/apex/crudAbilitatoOffFuorisede_controller.init';
import getResponse from '@salesforce/apex/MakeRequestV2Controller.getResponse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from "@salesforce/user/Id";
export default class crudAbilitatoOffFuoriSede extends LightningElement {
    @api recordId;
    @api apiRequests = 'crudAbilitatoOffFuoriSede';
    @api certificateName;
    @api disableLog;
    @api title;
    @api buttonLabel;

    currentUserId = Id;

    @track showMessage = false;
    @track isSuccess;

    @api federationIdentifier;
    @api crmNdg;
    @api bankNumber;

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        init({ currentUserId: this.currentUserId, recordId: this.recordId })
            .then(result => {
                const { crmNdg, bankNumber, federationIdentifier } = result;

                this.crmNdg = result.crmNdg;
                this.bankNumber = result.bankNumber;
                this.federationIdentifier = result.federationIdentifier;
                console.log('CRM NDG:', crmNdg);
                console.log('Bank Number:', bankNumber);
                console.log('Federation Identifier:', federationIdentifier);

            })
            .catch(error => {
                console.error(error);
            });
    }

    handleSendRequest(){
        try {
            console.log('DK START handleSendRequest');
            this.isRendered = false;

            let requestBody = {
                abilitatoOffertaFuoriSede: {
                    ofsoperatore: this.federationIdentifier,  
                    ofssino: true,
                    ofsdata: new Date().toISOString().slice(0, 10).replace(/-/g, '')
                },
                parametri: {
                    inNdg: this.crmNdg,  
                    inBanca: this.bankNumber,  
                    inFunzione: 'S3',
                }
            };
            console.log('requestBody:', requestBody);
            let requestBodyJSON = JSON.stringify(requestBody);
           
                    return getResponse({
                        record: null,
                        requestToApiGateway: this.apiRequests,
                        parseJSON: null,
                        conditions: null,
                        certificateName: this.certificateName,
                        disableLog: this.disableLog,
                        addingParamsMap: null,
                        bodyJSON: requestBodyJSON,
                    })
                    .then(result =>{
                        console.log('API Response:', result);
                        if(result.response.statusCode == '200'){
                            const toastEvent = new ShowToastEvent({
                                title: "Success!",
                                message: "L'operazione si è conclusa con successo!",
                                variant: "Success"
                            });
                            this.dispatchEvent(toastEvent);
                        }else{
                            const toastEvent = new ShowToastEvent({
                                title: "Errore!",
                                message: "Errori durante il salvataggio. Contattare il proprio Amministratore di Sistema.",
                                variant: "error"
                                });
                                this.dispatchEvent(toastEvent);
                        }
                    })
                    .catch((error) => {
                        this.showMessage = true;
                        this.isSuccess = false;
                        console.log(error);
                        this.isRendered = true;
                        this.canCall = false;
                        this.loadedAll = true;
                        const toastEvent = new ShowToastEvent({
                            title: "Errore!",
                            message: "Errori durante il salvataggio. Contattare il proprio Amministratore di Sistema.",
                            variant: "error"
                            });
                            this.dispatchEvent(toastEvent);
                    })
                    .finally(() => {
                        eval("$A.get('e.force:refreshView').fire();");
                        console.log('DK END handleSendRequest');
                        this.isRendered = true;
                    });
        } catch (error) {
            console.log('IE ' + error);
        }
        
    }
}