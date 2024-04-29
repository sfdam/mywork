import { LightningElement, api, track } from 'lwc'
import getNDGInSpostamento from '@salesforce/apex/SearchUtils.getNDGInSpostamento'

import RichiestaSpostamento from '@salesforce/label/c.ndgInSpostamentoComponent_CLM_RichiestaSpostamento';
import NDG from '@salesforce/label/c.ndgInSpostamentoComponent_CLM_Ndg';
import Stato from '@salesforce/label/c.ndgInSpostamentoComponent_CLM_Stato';
import Nome_Ndg from '@salesforce/label/c.ndgInSpostamentoComponent_CLM_NomeNdg';
import Portafoglio_origine from '@salesforce/label/c.ndgInSpostamentoComponent_CLM_PortafoglioOrigine';
import Portafoglio_destinazione from '@salesforce/label/c.ndgInSpostamentoComponent_CLM_PortafoglioDestinazione';



const columns = [
    { label: RichiestaSpostamento, fieldName: 'Richiesta_url', type: 'url', 
        typeAttributes: {
            label: { fieldName: 'richiestaNumber' }
    }},
    { label: NDG, fieldName: 'NDG_url', type: 'url', 
        typeAttributes: {
            label: { fieldName: 'ndgCode' }
    }},
    { label: Stato, fieldName: 'statusWOLI'},
    { label: Nome_Ndg, fieldName: 'ndgName'},
    { label: Portafoglio_origine, fieldName: 'ptfOrigineName'},
    { label: Portafoglio_destinazione, fieldName: 'ptfDestinazioneName'},
];
export default class CmpCtrl extends LightningElement {

    @api refType = ''
    @track data = []
    @api recordId
    @track cols = columns
    @api title = ''
    @api iconName = ''
    @track notEmpty;

    connectedCallback() {
        this.notEmpty=false;
        getNDGInSpostamento ({recordId : this.recordId }).then(res => {
            var list = [...res]
            this.notEmpty = list.length > 0
            list.forEach(item => {
                item.Richiesta_url='/' +item.richiestaId
                item.NDG_url = '/' + item.ndgId
            })
            this.data = [...list]
        }).catch(err => {
            console.log('errore  = '+JSON.stringify(err));
        })
    }
}