import { LightningElement, api, track } from 'lwc'
import getKnowledgeApprovals from '@salesforce/apex/SearchUtils.getKnowledgeApprovals'
const columns = [
    { label: 'Nome step', fieldName: 'stepName' },
    { label: 'Data di creazione', fieldName: 'createdDate' },
    { label: 'Stato', fieldName: 'status'},
    { label: 'Responsabile effettivo approvazione', fieldName: 'assignedTo'},
    { label: 'Assegnato a', fieldName: 'originalActorName'},
    { label: 'Commento', fieldName: 'comments'},
];
export default class CmpCtrl extends LightningElement {

    @api refType = ''
    @track data = []
    @api recordId
    @track cols = columns
    @api title = ''
    @api iconName = ''

    connectedCallback() {
        getKnowledgeApprovals ({recordId : this.recordId }).then(res => {
            this.data = [...res]
        }).catch(err => {
            console.log('errore  = '+err)
        })
    }
}