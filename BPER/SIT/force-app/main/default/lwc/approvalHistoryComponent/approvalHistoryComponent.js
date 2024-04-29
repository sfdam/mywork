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
                let firstSubmitted;
                let allData = res;
            if(allData['ApprovalWrapper'].length != 0){
                    
                    allData['ApprovalWrapper'].forEach(element => {
                        
                        if(allData['ContactList'][element.actorId]){
                            element.accountName = allData['ContactList'][element.actorId].Account.Name;      
                        }
                        if(element.status === 'Submitted' || element.status === 'Inviato') firstSubmitted = element;
                        
                    });

                    let array = [];
                    allData['ApprovalWrapper'].forEach(element => {
                        
                        if(allData['ContactList'][element.actorId]){
                            element.accountName = allData['ContactList'][element.actorId].Account.Name;     
                        }
                        if(element.status != 'Submitted' && element.status != 'Inviato'){
                            array.push(element);
                        }
                        
                    });

                    array.push(firstSubmitted);
                    // this.data = [...res]
                    this.data = array.sort( this.compare );
                    this.notEmptyList = true;
            }
            else{
                console.log('GB this.notEmptyList: ', this.notEmptyList);
                this.notEmptyList = false;
            }
        }).catch(err => {
            console.log('errore  = '+err)
        })
    }

    compare( a, b ) {
        if ( a.createdDate > b.createdDate ){
          return -1;
        }
        if ( a.splitName > b.splitName ){
          return 1;
        }
        return 0;
    }
}