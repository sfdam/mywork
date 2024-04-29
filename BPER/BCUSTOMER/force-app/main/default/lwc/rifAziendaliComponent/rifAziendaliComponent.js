import { LightningElement, api, track } from 'lwc'
import getRiferimentiAziendali from '@salesforce/apex/SearchUtils.getRiferimentiAziendali'

import NDG from '@salesforce/label/c.rifAziendaliComponent_CLM_NDG';
import Intestatari from '@salesforce/label/c.rifAziendaliComponent_CLM_Intestatari';
import Collegamento from '@salesforce/label/c.rifAziendaliComponent_CLM_Collegamento';
import Stato from '@salesforce/label/c.rifAziendaliComponent_CLM_Stato';


const columns = [
    { label: NDG, fieldName: 'relatedNDG' },
    { label: Intestatari, fieldName: 'relatedAccountUrl', type: 'url', typeAttributes: { label: { fieldName: 'relatedAccountName' } }, target: '_blank', sortable: true },
    { label: Collegamento, fieldName: 'linkType'},
    { label: Stato, fieldName: 'status'},
];
export default class CmpCtrl extends LightningElement {

    @api refType = ''
    @track data = []
    @api recordId
    @track cols = columns
    @api title = ''
    @api iconName = ''

    connectedCallback() {
        getRiferimentiAziendali ({recordId : this.recordId }).then(res => {
            /* var list = [...res]
            list.forEach(item => {
                item.AccountName = item.CRM_Account__r.Name
                item.RelatedAccountName = item.CRM_RelatedAccount__r.Name 
            })
            this.data = [...list] */
            this.data = [...res]
        }).catch(err => {
            console.log('errore  = '+err)
        })
    }
}