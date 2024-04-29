import { LightningElement, wire, track, api } from 'lwc';
import getConversationUrl from '@salesforce/apex/CtrlUnbluChat.getConversationUrl';

export default class Unbluchat extends LightningElement {

    @api recordId;
    @track unbluChatUrl;

    get showUnbluChat(){
        return true;
    }

    @wire(getConversationUrl, {recordId: '$recordId'})
    wiredConversationUrl({error, data}){
        if(error){
            console.error(error);
        }else{
            this.unbluChatUrl = data;
        }
    }

}