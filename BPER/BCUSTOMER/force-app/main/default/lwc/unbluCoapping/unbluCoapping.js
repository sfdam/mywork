import { LightningElement, wire, track, api } from 'lwc';
import getCoappingUrl from '@salesforce/apex/CtrlUnbluCoapping.getCoappingUrl';

export default class UnbluCoapping extends LightningElement {

    @api recordId;
    @track unbluCoappingUrl;
    @track showCmp = false;

    @api filterStatus;

    get showUnbluChat(){
        return this.showCmp;
    }

    @wire(getCoappingUrl, {recordId: '$recordId', filterStatus: '$filterStatus'})
    wiredConversationUrl({error, data}){
        if(error){
            console.error(error);
        }else{

            if(data){
                this.showCmp = data.showComponent;
                this.unbluCoappingUrl = data.coappingURL;
            }
        }
    }
}