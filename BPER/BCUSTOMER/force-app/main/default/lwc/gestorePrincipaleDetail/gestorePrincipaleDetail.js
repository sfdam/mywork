import { LightningElement, track, api, wire} from 'lwc'
import getGestorePrincipale from '@salesforce/apex/ManageGestoriCtrl.getGestorePrincipale'
export default class CmpCtrl extends LightningElement {

    @api title
    iconName
    @track gestore = {}
    @api recordId


    connectedCallback() {
        this.init()
    }

    init = async () => {
        this.gestore = await getGestorePrincipale({recordId: this.recordId})
        if (this.gestore.Profile.Name === 'TechnicalProfilePortafogliazione') this.gestore = undefined
        else this.gestore.Nome = this.gestore.FirstName + ' ' + this.gestore.LastName
    }

    renderedCallback() {
        this.iconName = 'action:user'
    }
}