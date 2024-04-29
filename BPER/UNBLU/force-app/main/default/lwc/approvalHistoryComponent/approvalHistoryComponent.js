import { LightningElement, api, track } from 'lwc'
import getApprovalHistory from '@salesforce/apex/SearchUtils.getApprovalHistory'

import Nome_step from '@salesforce/label/c.approvalHistoryComponent_CLM_NomeStep';
import Data_creazione from '@salesforce/label/c.approvalHistoryComponent_CLM_DataCreazione';
import Stato from '@salesforce/label/c.approvalHistoryComponent_CLM_Stato';
import Assegnato_a from '@salesforce/label/c.approvalHistoryComponent_CLM_AssegnatoA';
import Commento from '@salesforce/label/c.approvalHistoryComponent_CLM_Commento';
import Filiale from '@salesforce/label/c.approvalHistoryComponent_CLM_Filiale';


const columns = [
    { label: Nome_step, fieldName: 'stepName' },
    { label: Data_creazione, fieldName: 'createdDate' },
    { label: Stato, fieldName: 'status'},
    { label: Assegnato_a, fieldName: 'assignedTo'},
    { label: Filiale, fieldName: 'accountName'},
    { label: Commento, fieldName: 'comments'},
];
export default class CmpCtrl extends LightningElement {

    @api refType = ''
    @track data = []
    @api recordId
    @track cols = columns
    @api title = ''
    @api iconName = ''
    @track notEmptyList = false;

    connectedCallback() {
        getApprovalHistory ({recordId : this.recordId }).then(res => {
            
            console.log('result  = '+ JSON.stringify(res));
            let firstSubmitted = {};
            let allData = res;
            if(allData['ApprovalWrapper'].length != 0){
                    
                let array = [];
                allData['ApprovalWrapper'].forEach(element => {
                    
                    if(allData['ContactList'][element.actorId]){
                        element.accountName = allData['ContactList'][element.actorId].Account.Name;      
                    }
                    if(element.status === 'Submitted' || element.status === 'Inviato'){

                        if(element.unformattedDate < firstSubmitted.unformattedDate || !Boolean(firstSubmitted.unformattedDate)){

                            firstSubmitted = element;
                        }
                    }else{
                        array.push(element);
                    }
                });

                array.push(firstSubmitted);
                // this.data = [...res]
                let sortDirection = 'asc';
                console.log('Dk array: ', array);
                array.sort(this.sortBy( 'unformattedDate', -1) );
                console.log('Dk array-sorted: ', array);
                this.data = array;
                this.notEmptyList = true;
            }else{
                console.log('GB this.notEmptyList: ', this.notEmptyList);
                this.notEmptyList = false;
            }
        }).catch(err => {
            console.log('errore: ', err)
        })
    }

    sortBy( field, reverse, primer ) {

        const key = primer
            ? function( x ) {
                  return primer(x[field]);
              }
            : function( x ) {
                  return x[field];
              };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            // console.log('DK sort - reverse: ', reverse);
            let ascending = reverse == 1;
            // equal items sort equally
            if (a === b) {
                return 0;
            }
            // nulls sort after anything else
            else if (!Boolean(a)) {
                return 1;
            }
            else if (!Boolean(b)) {
                return -1;
            }
            // otherwise, if we're ascending, lowest sorts first
            else if (ascending) {
                return a < b ? -1 : 1;
            }
            // if descending, highest sorts first
            else { 
                return a < b ? 1 : -1;
            }
        };

    }
}