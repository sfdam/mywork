import { LightningElement, api, track } from 'lwc'
import getReferentePrincipale from '@salesforce/apex/SearchUtils.getReferentePrincipale'

import Nominativo from '@salesforce/label/c.refOnNDG_CLM_Nominativo';
import Matricola from '@salesforce/label/c.refOnNDG_CLM_Matricola';
import MDS from '@salesforce/label/c.refOnNDG_CLM_MDS';
import UO from '@salesforce/label/c.refOnNDG_CLM_UO';

const columns = [
    { label: Nominativo, fieldName: 'Gestore_url', type: 'url', 
        typeAttributes: {
            label: { fieldName: 'Name' }
        }},
    { label: Matricola, fieldName: 'PTF_RegistrationNumber__c'},
    { label: MDS, fieldName: 'MDS'},
    { label: UO, fieldName: 'UO'},
];
export default class CmpCtrl extends LightningElement {

    @api refType = ''
    @track data = []
    @api recordId
    @track cols = columns
    @track notEmpty;
    title = 'Referent'
    iconName

    connectedCallback() {
        console.log('we are here!');
        this.notEmpty=false;
        this.title += this.refType === 'Principali' ? 'e principale' : 'i di backup'
        this.iconName = this.refType === 'Principali' ? 'standard:opportunity_contact_role' : 'standard:contact_list'
        getReferentePrincipale ({recordId : this.recordId, refType: this.refType}).then(res => {
            var list = [...res]
            if(list.length>0){
                this.notEmpty=true;
            }
            list.forEach(item => {
                item.Gestore_url='/' +item.Id;
                item.MDS = item.PTF_MDSConcatList__c
                item.UO = item.Account.Name
            })
            this.data = [...list]
        }).catch(err => {
            console.log('errore  = '+err)
        })
    }
}