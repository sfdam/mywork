import { LightningElement,track, api} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getAllData from '@salesforce/apex/ndgDetailsController.getAllData';
import getUserInfo from '@salesforce/apex/SV_Utilities.getUserInfo';
export default class TileNDGDetails extends NavigationMixin(LightningElement) {

    
    @api title;
    @api builderIcon;
    @track isRendered;
    @track isViewAll = false;
    @api recordId;
    @track notShowComponent;
    @track recTypeId;
    @track record = null;
    @track isVisible=false;

    @track nomeAccount;
    @track numeroNDG; 
    @track modelloDiServizio; 
    @track gruppoComportamentale;
    @track segmentoComportamentale; 
    @track banca; 
    @track direzioneRegionale;
    @track area; 
    @track ofs; 
    @track filiale;
    @track naturaGiuridica;       
    @track statoCRM; 
    @track statoAnagrafe;
    @track statoSofferenza; 
    @track AnnualRevenueField; 
    @track accordato;
    @track utilizzato;
    @track patrimonio;
    @track portafoglio;
    @track miniPortafoglio;
    @track sportelloLeggero;
    @track portafoglioId;
    @track bancaId;
    @track direzioneRegionaleId;
    @track areaId;
    @track filialeId;

   connectedCallback() {
    getUserInfo()
        .then(result => {
            console.log('MC getUserInfo result', result);
            this.isRendered = false;
            if(result.Profile.Name=='System Administrator'||result.Profile.Name=='NEC_D.0'||result.Profile.Name=='NEC_T.7'||result.Profile.Name=='NEC_T.8'||
                result.Profile.Name=='NEC_D.5' || result.Profile.Name=='NEC_D.4' ||result.Profile.Name=='NEC_F.1'|| (result.Profile.Name=='NEC_D.2' && result.Profile.idced__c=='4439')){
                this.isVisible=true;
                }
        getAllData({ recordId: this.recordId })
        .then(result => {
            console.log("MC", result);
            this.notShowComponent = false;
            result.forEach(element => {
                if(element.Name)
                    this.nomeAccount=element.Name;
                if(element.CRM_NDG__c)
                    this.numeroNDG=element.CRM_NDG__c;
                if(element.ModelloDiServizio__c) 
                    this.modelloDiServizio=element.ModelloDiServizio__c; 
                if(element.PTF_GruppoComportamentale__c)
                    this.gruppoComportamentale=element.PTF_GruppoComportamentale__c;
                if(element.PTF_SegmentoComportamentale__c)    
                    this.segmentoComportamentale=element.PTF_SegmentoComportamentale__c;
                if(element.PTF_Banca__c){ 
                    this.bancaId=element.PTF_Banca__c;
                    this.banca=element.PTF_Banca__r.Name;
                } 
                if(element.PTF_Portafoglio__c){ 
                    this.portafoglioId=element.PTF_Portafoglio__c;
                    this.portafoglio=element.PTF_Portafoglio__r.Name;
                }
                if(element.PTF_DirezioneRegionale__c){
                    this.direzioneRegionaleId=element.PTF_DirezioneRegionale__c;
                    this.direzioneRegionale=element.PTF_DirezioneRegionale__r.Name;
                } 
                    
                if(element.PTF_Area__c){
                    this.areaId=element.PTF_Area__c;
                    this.area=element.PTF_Area__r.Name;
                } 
                if(element.PTF_OFS__c)  
                    this.ofs=element.PTF_OFS__c;
                if(element.PTF_Filiale__c){
                    this.filialeId=element.PTF_Filiale__c;
                    this.filiale=element.PTF_Filiale__r.Name;
                } 
                if(element.PTF_NaturaGiuridica__c) 
                    this.naturaGiuridica=element.PTF_NaturaGiuridica__c;
                if(element.PTF_StatoCRM__c)        
                    this.statoCRM=element.PTF_StatoCRM__c;
                if(element.PTF_StatoAnagrafe__c)  
                    this.statoAnagrafe=element.PTF_StatoAnagrafe__c;
                if(element.PTF_StatoSofferenza__c) 
                    this.statoSofferenza=element.PTF_StatoSofferenza__c;
                if(element.AnnualRevenue)  
                    this.AnnualRevenueField=element.AnnualRevenue;
                if(element.PTF_Accordato__c)  
                    this.accordato=element.PTF_Accordato__c;
                if(element.PTF_Utilizzato__c) 
                    this.utilizzato=element.PTF_Utilizzato__c;
                if(element.PTF_Patrimonio__c) 
                    this.patrimonio=element.PTF_Patrimonio__c;
                if(element.PTF_MiniPortafoglio__c){ 
                    this.miniPortafoglio=element.PTF_MiniPortafoglio__r.Name;
                    this.sportelloLeggero=element.PTF_MiniPortafoglio__r.PTF_SL__r.Name;
                }
            });
        }).catch(error => {
            console.log('MC ERRORE ' + JSON.stringify(error));
        })
        }).catch(error => {
            console.log('MC init.error: ' + JSON.stringify(error));
        }).finally(() => {
            this.isRendered = true;
        });
    }

    navigateToWallet(){
        this[NavigationMixin.Navigate]({
            type:'standard__recordPage',
            attributes:{
                recordId:this.portafoglioId,
                objectApiName:'Wallet__c',
                actionName:'view'
            }
        })
    }
    navigateToBanca(){
        this[NavigationMixin.Navigate]({
            type:'standard__recordPage',
            attributes:{
                recordId:this.bancaId,
                objectApiName:'Account',
                actionName:'view'
            }
        })
    }
    navigateToArea(){
        this[NavigationMixin.Navigate]({
            type:'standard__recordPage',
            attributes:{
                recordId:this.areaId,
                objectApiName:'Account',
                actionName:'view'
            }
        })
    }
    navigateToFiliale(){
        this[NavigationMixin.Navigate]({
            type:'standard__recordPage',
            attributes:{
                recordId:this.filialeId,
                objectApiName:'Account',
                actionName:'view'
            }
        })
    }
    navigateToDirezioneTer(){
        this[NavigationMixin.Navigate]({
            type:'standard__recordPage',
            attributes:{
                recordId:this.direzioneRegionaleId,
                objectApiName:'Account',
                actionName:'view'
            }
        })
    }

    handleViewAll(){
        this.isViewAll=true;
    }
    refreshClick(){
        this.connectedCallback();
    }
}