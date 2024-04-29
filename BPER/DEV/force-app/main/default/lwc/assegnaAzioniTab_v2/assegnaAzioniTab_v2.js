import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getContact from '@salesforce/apex/AssegnaAzioniController.getContact';
import getCampaignMember from '@salesforce/apex/AssegnaAzioniController.getCampaignMember';
import getEventMember from '@salesforce/apex/AssegnaAzioniController.getEventMember';
import getOppsMember from '@salesforce/apex/AssegnaAzioniController.getOppsMember';
import reassignItem from '@salesforce/apex/AssegnaAzioniController.reassignItem';
import setCampaignMember from '@salesforce/apex/AssegnaAzioniController.setCampaignMember';
import setOpportunity from '@salesforce/apex/AssegnaAzioniController.setOpportunity';

const JSON_ElegibleRoleMMDS = {
    "POE": ["052","054","055","056","057","037"],
    "Family": ["054","055","056","057","037","097","095"],
    "POE_Family": ["054","055","056","057","037"],
    "ruoliDisattivi": ["100","102","092", "074","000"]
}

export default class AssegnaAzioniTab_v2 extends NavigationMixin(LightningElement) {
    @track loaded = false;
    @track loadedDataEventi = false;
    @track loadedDataCampagne = false;
    @track loadedDataOpportunity = false;
    @track loadedDataReferenti = false;

    connectedCallback(){
        this.loaded = false;

        getContact()
        .then(result => {
            console.log('SV getContact result', result);
            // console.log('SV Account count', Object.keys(result.accMap).length);
            // console.log('SV Contact count', Object.keys(result.contactMap).length);
            // console.log('SV PTF count', Object.keys(result.ptfMap).length);
            this.user = result.userMap;
            this.contact = result.contactMap; 
            this.account = result.accMap;
            this.ptf = result.ptfMap;
            this.handleGetEventMember();
            this.handleGetCampaignMember();
            this.handleGetOppsMember();
        })
        .catch(error => {
            console.log('ERROR', error);
        })
        .finally(() => {
            this.loaded = true;
            let contactMap = this.contact;
            // console.log('contactMap', contactMap);
            let obj = {};
            obj.Family = [];
            obj.POE = [];
            obj.POE_Family = [];
            obj.Tecnico = [];
            for(let key in contactMap){
                if (Object.prototype.hasOwnProperty.call(contactMap, key)) {
                    let x = {};
                    x = contactMap[key];
                    let keySplit = key.split('_');
                    if(JSON_ElegibleRoleMMDS.POE.includes(keySplit[0])){
                        obj.POE.push(x)
                    }
                    if(JSON_ElegibleRoleMMDS.Family.includes(keySplit[0])){
                        obj.Family.push(x)
                    }
                    if(JSON_ElegibleRoleMMDS.POE_Family.includes(keySplit[0])){
                        obj.POE_Family.push(x)
                    }
                    if(!JSON_ElegibleRoleMMDS.ruoliDisattivi.includes(keySplit[0])){
                        obj.Tecnico.push(x)
                    }
                }
            }
            this.contactElegibleRoleMDS = JSON.parse(JSON.stringify(obj));
            console.log('contactElegibleRoleMDS', this.contactElegibleRoleMDS);
            // console.log('DONE');
        });
    }

    handleActive(event) {
        if(event.target.value === 'lightningTab_AssegnazioneEventi'){
            this.loadedDataEventi = true;
        }else if(event.target.value === 'lightningTab_AssegnazioneCampagne'){
            this.loadedDataCampagne = true;
        }else if(event.target.value === 'lightningTab_AssegnazioneOpportunity'){
            this.loadedDataOpportunity = true;
        }else if(event.target.value === 'lightningTab_AssegnazioneReferenti'){
            this.loadedDataReferenti = true;
        }
    }

    handleGetEventMember(){
        console.log('SV START getEventMember');
        return getEventMember({ })
        .then(result => {
            console.log('SV getEventMember result', result);
        })
        .catch(error => {
            console.log('ERROR', error);
        }).finally(() => {
            
        });
    }

    handleGetCampaignMember(){
        console.log('SV START getCampaignMember');
        return getCampaignMember({ })
        .then(result => {
            console.log('SV getCampaignMember result', result);
        })
        .catch(error => {
            console.log('ERROR', error);
        })
        .finally(() => {
            
            
        });
    }

    handleGetOppsMember(){
        console.log('SV START getOppsMember');
        return getOppsMember({idCed: this.user.PTF_IdCED__c})
        .then(result => {
            console.log('SV getOppsMember result', result);
            
        })
        .catch(error => {
            console.log('ERROR', error);
        })
        .finally(() =>{
            
        });
    }
}