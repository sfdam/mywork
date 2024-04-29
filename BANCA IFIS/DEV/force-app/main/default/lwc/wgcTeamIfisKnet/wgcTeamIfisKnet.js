import { LightningElement, api, track } from 'lwc';
// import logoSR from '@salesforce/resourceUrl/BancaIfisLogo';
import UserImageSR from '@salesforce/resourceUrl/UserImage';
import getReferentiKNET from '@salesforce/apex/WGC_Team_IFIS_KNET_Ctrl.getReferentiKNET';
import settoristaLabel from '@salesforce/label/c.WGC_Settorista_KNET';
import presentatoreLabel from '@salesforce/label/c.WGC_Presentatore_KNET';
import gestoreClienteLabel from '@salesforce/label/c.WGC_Gestore_Cliente_KNET';
import gestoreDebitoreLabel from '@salesforce/label/c.WGC_Gestore_Debitore_KNET';


export default class WgcTeamIfisKnet extends LightningElement {
    @api recordId;

    // logo = logoSR;
    UserImage = UserImageSR;

    label = {
        settoristaLabel,
        presentatoreLabel,
        gestoreClienteLabel,
        gestoreDebitoreLabel
    }

    @track infoSettorista = { nome: '', telefono: '', ndg: '' };
    @track infoPresentatore = { nome: '', telefono: '', ndg: '' };
    @track infoGestoreCliente = { nome: '', telefono: '', ndg: '' };
    @track infoGestoreDebitore = { nome: '', telefono: '', ndg: '' };

    errorMsg;

    connectedCallback(){
        getReferentiKNET({ accountId: this.recordId }).then(result => {
            console.log('@@@ result KNET ' , JSON.stringify(result.data));

            if(result.success){
                var info = result.data;
                this.infoSettorista.ndg = info.ndgRefCommerc;
                this.infoSettorista.nome = info.nomeRefCommerc + ' ' + info.cognomeRefCommerc;
                if(info.telefRefCommerc != undefined) this.infoSettorista.telefono = info.telefRefCommerc.trim();

                this.infoPresentatore.ndg = info.ndgPresentatore;
                this.infoPresentatore.nome = info.nomePresentatore + ' ' + info.cognomePresentatore;
                if(info.telefGestCedente != undefined) this.infoPresentatore.telefono = info.telefPresentatore.trim();

                this.infoGestoreCliente.ndg = info.ndgGestCedente;
                this.infoGestoreCliente.nome = info.nomeGestCedente + ' ' + info.cognomeGestCedente;
                if(info.telefGestCedente != undefined) this.infoGestoreCliente.telefono = info.telefGestCedente.trim();

                this.infoGestoreDebitore.ndg = info.ndgGestDebitore;
                this.infoGestoreDebitore.nome = info.nomeGestDebitore + ' ' + info.cognomeGestDebitore;
                if(info.telefGestDebitore != undefined) this.infoGestoreDebitore.telefono = info.telefGestDebitore.trim();
            } else {
                this.errorMsg = result.message;
            }

            this.template.querySelector('lightning-spinner').classList.add('slds-hide');
        }).catch(err => {
            console.log('@@@ err ' , err);
            this.errorMsg = err.toString();
            this.template.querySelector('lightning-spinner').classList.add('slds-hide');
        })
    }

    get showErrorMsg(){
        return this.errorMsg != undefined;
    }
}