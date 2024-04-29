import { LightningElement, api } from 'lwc';
import OwnerQueueMember from '@salesforce/apex/OwnerQueueMembers.OwnerQueueMember';

const columns = [
    { 
        label: 'FirstName', 
        fieldName: 'FirstName', 
        sortable: true
    }, 
    {
        label: 'LastName', 
        fieldName: 'LastName', 
        sortable: true
    } 
    
];

export default class ownerQueueMember extends LightningElement {
    data = [];
    columns = columns;
    @api recordId;
    
    // eslint-disable-next-line @lwc/lwc/no-async-await
    async connectedCallback() {
        const data = await OwnerQueueMember({ recordId: this.recordId });
        this.data = data;
    }
}