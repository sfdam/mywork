import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import WGC_HOMEPAGE_CHANNEL from '@salesforce/messageChannel/wgcHomePageFilter__c';
import { getRecord } from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';
import USER_MANAGER_ID from '@salesforce/schema/User.ManagerId';
import USER_ROLE_NAME from '@salesforce/schema/User.UserRole.Name';
import getUserWithFiliali from '@salesforce/apex/WGC_selettore_filtro_Controller.getUserWithFiliali';
import getCommerciali from '@salesforce/apex/WGC_selettore_filtro_Controller.getCommerciali';
 
export default class Wgc_selettore_filtro extends LightningElement {

    @wire(getRecord, { recordId: userId, fields: [USER_MANAGER_ID, USER_ROLE_NAME] })
    wireuser({ error, data })
    {
        if (error) {
           console.error('get user data error: ' + JSON.stringify(error)) ; 
        } else if (data) {
            this.managerId = (data.fields.ManagerId.value) ? data.fields.ManagerId.value : '';
            this.userRoleName = (data.fields.UserRole.value.fields.Name.value) ? data.fields.UserRole.value.fields.Name.value : '';

            if(this.userRoleName != null && this.userRoleName != ''){
                if(this.managerId != null && this.managerId != '' && this.userRoleName.toUpperCase() == 'IFIS – SVILUPPO COMMERCIALE FILIALI'){
                    this.userLevel = 'commerciale';
                }else if(this.managerId != null && this.managerId == '' && this.userRoleName.toUpperCase().includes('RESPONSABILE')){
                    this.userLevel = 'responsabile';
                }else if(this.managerId != null && this.managerId == '' && this.userRoleName.toUpperCase().includes('DIREZIONE COMM')){
                    this.userLevel = 'direzione';
                }else{
                    this.userLevel = 'notDefined';
                }
                this.populatePicklist();
            }

        }
    }

    @wire(MessageContext) messageContext;

    managerId;
    userRoleName;

    filterOptions = [{value: 'noValue', label: '-- nessun valore --'}];
    userLevel = '';
    picklistValue = 'noValue';
    isPicklistDisabled = true;

    connectedCallback(){
        setTimeout(() => {
            this.publishPayloadOnChannel();
        }, 1700)
    }
    
    handlePicklistChange(event) {
        this.picklistValue = event.detail.value;
        this.publishPayloadOnChannel();
    }

    publishPayloadOnChannel(){
        const payload = {
            currentUserId: userId,
            currentUserLevel: this.userLevel,
            filterValue: this.picklistValue,
            tipoFiltro: this.calculateFilterType(this.picklistValue)
        }
    
        publish(this.messageContext, WGC_HOMEPAGE_CHANNEL, payload);
        console.log('payload published');
    }

    calculateFilterType(picklistValue){
        const letterRegex = new RegExp(/([A-Z]|[a-z])/g);
        if(picklistValue.includes(';')){
            return 'filiale';
        }else if(picklistValue == 'noValue'){
            return 'noValue';
        }else if(picklistValue.match(letterRegex)){
            return 'utente';
        }else{
            return 'filiale';
        }
    }

    populatePicklist(){
        this.filterOptions = [];
        let tempFilterOptions = [];
        let tempCommercialiList = [];
        let tempFilialiList = [];
        let tempAllFiliali = '';
        if(this.userLevel == 'commerciale'){
            this.isPicklistDisabled = true;
            tempFilterOptions.push({value: userId, label: 'I miei dati'});
            this.picklistValue = userId;
        }else if(this.userLevel == 'responsabile' || this.userLevel == 'direzione'){
            tempFilterOptions.push({value: userId, label: 'I miei dati'});
            this.picklistValue = userId;
            
            getCommerciali({userId: userId})
                .then(result => {
                    if(result != null && result.length > 0){
                        let commercialiList = result;
                        commercialiList.forEach(element => {
                            tempCommercialiList.push({value: element.Id, label: element.Name});
                        })
                    }
                    getUserWithFiliali({userId: userId})
                        .then(result => {
                            if(result != null && result.length == 1){
                                let filialiValues = result[0].WGC_La_mia_filiale__c.split(';');
                                let filialiLabels = result[0].filialiLabel.split(';');
                                for(let i = 0; i < filialiValues.length; i++){
                                    tempFilialiList.push({value: filialiValues[i], label: filialiLabels[i]});
                                }
                                if(filialiValues.length > 0){
                                    tempAllFiliali = result[0].WGC_La_mia_filiale__c;
                                }
                            }
                        })
                        .catch(error => {
                            //console.error('getUserWithFiliali error: ' + JSON.stringify(error));
                            console.log('SV errore: ',error);
                        })
                        .finally(() => {
                            if(tempFilialiList.length > 0){
                                tempFilterOptions.push({value: userId, label: '- Per Filiale'});
                                tempFilterOptions.push({value: tempAllFiliali, label: 'Tutte le filiali'});
                                tempFilialiList.forEach(element => {
                                    tempFilterOptions.push({value: element.value, label: element.label});
                                })
                            }
                            if(tempCommercialiList.length > 0){
                                tempFilterOptions.push({value: userId, label: '- Per Utente'});
                                tempCommercialiList.forEach(element => {
                                    tempFilterOptions.push({value: element.value, label: element.label});
                                })
                            }
                            this.filterOptions = tempFilterOptions;
                            if(this.filterOptions.length > 1){
                                this.isPicklistDisabled = false;
                            }
                        })
                })
                .catch(error => {
                    console.error('populatePicklist error: ' + JSON.stringify(error));
                })
        }
        
    }

}