import { LightningElement, api, track } from 'lwc';

import getAllData from '@salesforce/apex/PendingQueueUsersController.getAllData';
import Nome from '@salesforce/label/c.pendingQueueUsers_CLM_Nome';
import Filiale from '@salesforce/label/c.pendingQueueUsers_CLM_Filiale';

const columns = [
    {
        label: Nome,
        fieldName: 'Name',
        type: 'text'
    },
    {
        label: Filiale,
        fieldName: 'AccountName',
        type: 'text'
    }
];

export default class PendingQueueUsers extends LightningElement {

    @api recordId;
    @api title;
    @api iconName;
    gridData = [];
    gridColumns = columns;
    @track loaded = false;
    @track notEmptyList = false;
    connectedCallback() {

        getAllData({recordId: this.recordId})
        .then(result => {

            console.log('DK getAllData result', result);

            if(result != null){

                for(var groupName in result){

                    result[groupName].forEach(element => {
                        
                        element.AccountName = element.Account.Name;
                        
                    });
                    let group = {};
                    group.Name = groupName;
                    group._children = [];
                    group._children = result[groupName];
                    this.gridData.push(group);
                }
                this.notEmptyList = true;
            }else{

                this.notEmptyList = false;
            }
            console.log('DK this.notEmptyList: ', this.notEmptyList);
            this.loaded = true;
        })
        .catch(error => {
            console.log('DK ERROR', error);
            console.log('DK ERROR', JSON.stringify(error));
            this.loaded = true;
        });
    }
}