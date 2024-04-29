import { LightningElement, api, wire, track } from 'lwc';

// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Import Navigation
import { NavigationMixin } from 'lightning/navigation';

import getDataList from '@salesforce/apex/TXT_FastManagerController.getDataList';
import createNewTask from '@salesforce/apex/TXT_FastManagerController.createNewTask';
import getUserInfo from '@salesforce/apex/TXT_FastManagerController.getUserInfo';

//import getVisibilitaMetadata from '@salesforce/apex/TXT_FastManagerController.getVisibilitaMetadata';
import userHasAccessToRecord from '@salesforce/apex/TXT_FastManagerController.userHasAccessToRecord';
import getVisibilitaSection from '@salesforce/apex/TXT_FastManagerController.getVisibilitaSection';
import recuperoDati from '@salesforce/apex/TXT_FastManagerController.recuperoDati';
//import recuperaNomeUser from '@salesforce/apex/TXT_FastManagerController.recuperaNomeUser';



export default class FastManager extends NavigationMixin(LightningElement) {

   

    @api tipoRicerca;
    @track result;
    @track pIva;
    @track cFiscale;
    @track loaded = false;
    @track loadedRelated = false;

    container;
    @track containerResult = false;
    @track userInfo;
    @track error;
    url = window.location.origin;
    @track openmodel = false;
    openModalInfoAccount = false;
    @track selectedItem;
    @track note;
    singleRecord = {};
    visibilita = [];
    visibilitaSection =[];
    columnsRelatedLists = {};
    IdFront;
    SectionToFront = [];
    SelectedRecordFields= [];
    activeSectionMessage = '';
    selectedObjectName;
    loadedRecord = true;
   


    connectedCallback() {
        getUserInfo()
            .then(result => {
                this.userInfo = result;
 
                return getVisibilitaSection();
            }).then(resultMetadata => {
                console.log('@@@ resultMetadata ' , resultMetadata);
              
               this.visibilitaSection = resultMetadata.metadati;
               this.columnsRelatedLists = resultMetadata.objectColumns;
                
            })
            .catch(error => {
                console.log('@@@ error ' , error);
                this.error = error;
            })
    }

    pIvaChange(event) {
        this.pIva = event.target.value;
    }

    cFiscaleChange(event) {
        this.cFiscale = event.target.value;
    }

    noteChange(event) {
        this.note = event.target.value;
    }

    handleClick(){
        this.loaded = !this.loaded;
        this.containerResult = false;

        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

        if (allValid) {
            getDataList({pIva: this.pIva, cFiscale: this.cFiscale, societa: this.userInfo.Societa__c, tipoRicerca: this.tipoRicerca})
            .then(result => {
                console.log('SUCCESS');
                console.log(result);
                var combineList = [];
                for (var key in result.CombinedItems) {
                    const obj = JSON.parse(JSON.stringify(result.CombinedItems[key]))
                    console.log(obj);
                    if(obj.Id.startsWith('001')){
                        obj.ObjectType = 'Account';
                        obj.IconName = 'standard:account';
                        obj.Codice_Fiscale__c = obj.Codice_fiscale__c;
                        obj.Tipo = obj.Stato__c;
                        obj.Responsabile = '';
                        obj.Href = '/lightning/r/Account/' + obj.Id + '/view';
                        obj.OppVisible = true;                      

                        var checkBtnApprovazione = false;

                        for (var keyCTM in result.ctmMap){
                            if(keyCTM.includes(obj.Id)){
                                result.ctmMap[keyCTM].forEach(i => {
                                    obj.Responsabile = obj.Responsabile + i.User__r.Name + ' (' + i.Societa__c + ') ' + (Object.keys(result.ctmMap).length > 1 ? '; ' : ' ');
                                    if(i.Societa__c == 'Innolva')
                                        checkBtnApprovazione = true;
                                });
                            }
                        }

                        // Abilito il pulsante solo per Innolva e se l'account ha già un CTM di Innolva
                        // Di default è a false
                        obj.ShowButtonApprovazione = this.userInfo.Societa__c == 'Innolva' ? checkBtnApprovazione : false;

                        obj.Responsabile = obj.Responsabile.substring(0, obj.Responsabile.length - 2);

                        obj.OppAperte = 0;
                        obj.OppChiuse = 0;
                        obj.OppTotAll = 0;
                        obj.OppTotAmount = 0;
                        for (var keyOpp in result.oppToAccMap){
                            console.log('keyopp ',keyOpp);
                            console.log('result.oppToAccMap[keyOpp] ',result.oppToAccMap[keyOpp]);
                            var split = keyOpp.split('.');
                            
                            console.log(split);
                            if(keyOpp.includes(obj.Id)){
                                if(split[2] == 'false'){
                                    obj.OppAperte += result.oppToAccMap[keyOpp].expr0 == undefined ? 0 : result.oppToAccMap[keyOpp].expr0;
                                    obj.OppTotAmount += result.oppToAccMap[keyOpp].expr1 == undefined ? 0 : result.oppToAccMap[keyOpp].expr1;
                                } else {
                                    obj.OppChiuse += result.oppToAccMap[keyOpp].expr0 == undefined ? 0 : result.oppToAccMap[keyOpp].expr0;
                                }

                                obj.OppTotAll += result.oppToAccMap[keyOpp].expr0 == undefined ? 0 : result.oppToAccMap[keyOpp].expr0;
                                /*if(split[3] == 'true')
                                {
                                    obj.OppTotAmount += result.oppToAccMap[keyOpp].expr1 == undefined ? 0 : result.oppToAccMap[keyOpp].expr1;
                                }*/
                            }
                        }

                          obj.OppTot = parseInt (obj.Opportunit_Aperte__c == undefined ? 0 : obj.Opportunit_Aperte__c, 10) + parseInt(obj.OppChiuse == undefined ? 0 : obj.OppChiuse, 10);

                        obj.Task = 0;                        
                        for (var keyTask in result.taskToAccMap){
                            if(keyTask.includes(obj.Id)){
                                obj.Task = result.taskToAccMap[keyTask].expr0 == undefined ? 0 : result.taskToAccMap[keyTask].expr0;
                            }
                        }

                        obj.Event = 0;                        
                        for (var keyEvent in result.eventToAccMap){
                            if(keyEvent.includes(obj.Id)){
                                obj.Event = result.eventToAccMap[keyEvent].expr0 == undefined ? 0 : result.eventToAccMap[keyEvent].expr0;
                            }
                        }

                        obj.TaskEventTot = parseInt(obj.Task == undefined ? 0 : obj.Task, 10) + parseInt(obj.Event == undefined ? 0 : obj.Event, 10);

                        obj.FutureTask = 0;                        
                        for (var keyTask in result.futureTaskToAccMap){
                            if(keyTask.includes(obj.Id)){
                                obj.FutureTask = result.futureTaskToAccMap[keyTask].expr0 == undefined ? 0 : result.futureTaskToAccMap[keyTask].expr0;
                            }
                        }

                        obj.FutureEvent = 0;                        
                        for (var keyEvent in result.futureEventToAccMap){
                            if(keyEvent.includes(obj.Id)){
                                obj.FutureEvent = result.futureEventToAccMap[keyEvent].expr0 == undefined ? 0 : result.futureEventToAccMap[keyEvent].expr0;
                            }
                        }

                        obj.FutureTaskEventTot = parseInt(obj.FutureTask == undefined ? 0 : obj.FutureTask, 10) + parseInt(obj.FutureEvent == undefined ? 0 : obj.FutureEvent, 10);

                    } else {
                        obj.ObjectType = 'Lead';
                        obj.IconName = 'standard:lead';
                        obj.Partita_iva__c = obj.Partiva_Iva__c;
                        obj.Codice_Fiscale__c = obj.Codice_fiscale__c;
                        obj.Tipo = 'Lead';
                        obj.Responsabile = obj.Owner.Name;
                        obj.Href = '/lightning/r/Lead/' + obj.Id + '/view';
                        obj.OppVisible = false;
                        obj.ShowButtonApprovazione = true;

                        obj.Task = 0;                        
                        for (var keyTask in result.taskToLeadMap){
                            if(keyTask.includes(obj.Id)){
                                obj.Task = result.taskToLeadMap[keyTask].expr0 == undefined ? 0 : result.taskToLeadMap[keyTask].expr0;
                            }
                        }
                        obj.Event = 0;                        
                        for (var keyEvent in result.eventToLeadMap){
                            if(keyEvent.includes(obj.Id)){
                                obj.Event = result.eventToLeadMap[keyEvent].expr0 == undefined ? 0 : result.eventToLeadMap[keyEvent].expr0;
                            }
                        }

                        obj.TaskEventTot = parseInt(obj.Task == undefined ? 0 : obj.Task, 10) + parseInt(obj.Event == undefined ? 0 : obj.Event, 10);

                        obj.FutureTask = 0;                        
                        for (var keyTask in result.futureTaskToLeadMap){
                            if(keyTask.includes(obj.Id)){
                                obj.FutureTask = result.futureTaskToLeadMap[keyTask].expr0 == undefined ? 0 : result.futureTaskToLeadMap[keyTask].expr0;
                            }
                        }
                        obj.FutureEvent = 0;                        
                        for (var keyEvent in result.futureEventToLeadMap){
                            if(keyEvent.includes(obj.Id)){
                                obj.FutureEvent = result.futureEventToLeadMap[keyEvent].expr0 == undefined ? 0 : result.futureEventToLeadMap[keyEvent].expr0;
                            }
                        }

                        obj.FutureTaskEventTot = parseInt(obj.FutureTask == undefined ? 0 : obj.FutureTask, 10) + parseInt(obj.FutureEvent == undefined ? 0 : obj.FutureEvent, 10);

                    }

                    combineList.push(obj);
                };
                this.container = combineList;
                if(combineList.length <= 0) this.containerResult = true;
                
                this.loaded = !this.loaded;
            })
            .catch(error => {
                console.log('ERROR ' , error);
                const event = new ShowToastEvent({
                    "variant": "error",
                    "title": "Error!",
                    "message": error.body.message
                });
                this.dispatchEvent(event);
            })
        } else {
            this.loaded = !this.loaded;
            const event = new ShowToastEvent({
                "variant": "error",
                "title": "Error!",
                "message": "Partita Iva e Codice Fiscale devono contenere almeno 6 caratteri."
            });
            this.dispatchEvent(event);
        }

    }


    openmodal(event) {
        event.preventDefault();
        var rec = event.target.value;
        this.selectedItem = rec;
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
    } 
    saveMethod() {
        createNewTask({user: this.userInfo, what_id: this.selectedItem.Id, sobjectName: this.selectedItem.ObjectType, title: null, note: this.note})
            .then(result => {
                var x = this.url + '/lightning/r/Task/' + result.Id + '/view';
                const event = new ShowToastEvent({
                        "variant": "success",
                        "title": "Success!",
                        "message": "Task creato su {0}! Puoi visualizzarlo cliccando {1}!",
                        "messageData": [
                            'Salesforce',
                            {
                                url: x,
                                label: 'qua'
                            }
                        ]
                });
                this.dispatchEvent(event);

            })
            .catch(error => {
                console.log('ERROR', JSON.stringify(error));
                const event = new ShowToastEvent({
                    "variant": "error",
                    "title": "Error!",
                    "message": error.body.message
                });
                this.dispatchEvent(event);
            })

        this.closeModal();

    }



    handleSectionToggle(event) {
        const openSection = event.detail.openSections;
        this.selectedObjectName = event.detail.openSections;

        this.SelectedRecordFields=[];
    
        var relatedList = this.SectionToFront.find(section => {
            if(section.isLayout){
                return section.nameLayout == openSection;
            } else {
                return section.objectName == openSection;
            }
        });

       // console.log('@@@ relatedList ' , JSON.stringify(relatedList));

            recuperoDati({ objectName : relatedList.objectName, field : relatedList.fields, recordId: this.IdFront }).then(resultMetadata => {
                console.log('@@@ resultMetadata ' , resultMetadata);

                var sections = [];
                this.SectionToFront.forEach(section => {
                    var tmp = {...section};
                    // console.log('@@@ openSection ' , openSection);
                    // console.log('@@@ isLayout ' , tmp);

                    if(tmp.isLayout && tmp.nameLayout == openSection || tmp.isRelatedList && tmp.objectName == openSection){
                        
                        if(tmp.objectName == 'Account'){
                            //console.log('@@@acc');
                            let params = {
                                detail: {
                                    row: {

                                    }
                                }
                            };

                            let record = resultMetadata[0];
                            for(var key in record){
                                params.detail.row[key] = record[key];
                            };
                            this.selectedObjectName = openSection == 'KPI' ? 'KPI' : tmp.objectName;
                            this.handleRowAction(params);
                        } else {
                            if(tmp.objectName == 'Coverage_Team_Member__c'){
                                resultMetadata.forEach(record => {
                                    record.User__c = record.User__r != undefined ? record.User__r.Name : undefined;
                                });   
                            }

                            if(tmp.objectName == "Opportunity"){
                                resultMetadata.forEach(record => {
                                    record.OwnerId = record.OwnerId != undefined ? record.Owner.Name : undefined;
                                    record.Referente__c = record.Referente__r != undefined ? record.Referente__r.Name : undefined;
                                    record.RecordTypeId = record.RecordTypeId != undefined ?record.RecordType.Name : undefined;
                                });
                            }
                                if(tmp.objectName == "Event"){
                                    resultMetadata.forEach(record => {
                                        record.OwnerId = record.OwnerId != undefined ? record.Owner.Name : undefined;
                                        record.WhoId = record.WhoId != undefined ? record.Who.Name : undefined;

                                    });
                            
                            }
                            tmp.dati = resultMetadata;
                            tmp.hasDati = resultMetadata.length > 0;

                        }
                    }
                    
                    console.log('@@@ section ' , tmp);
                    sections.push(tmp);
                });

                this.SectionToFront = sections;

            }).catch(err => {
                console.log('@@@ err ' , err);
            });
        
    }

    handleRowAction(event) {
        this.loadedRecord = false;
        console.log('@@@ eventdetail', JSON.stringify(event.detail));
       this.SelectedRecordFields=[];
       var selectedTmp= [];

       this.columnsRelatedLists[this.selectedObjectName].forEach(field => {
        console.log('@@@ field.type', field.type);

        var myType = field.type.toLowerCase();
        var isCurrency = myType == 'currency';
        var isInteger = myType == 'integer';
        var isnumber = myType == 'number';
        var isboolean = myType == 'boolean';
        var isdate = myType == 'date';
        var isdatetime = myType =='datetime';
        var isurl = myType == 'url';
        var ispassword = myType == 'pasword';
        var isbigint = myType == 'bigint';

        var NameField = event.detail.row[field.apiName];

        
        var tmp={label: field.label, value: NameField != undefined ? NameField : '', hasValue: NameField != undefined, type: myType, isCurrency: isCurrency, isInteger: isInteger, 
            isnumber:isnumber, isboolean: isboolean, isbigint:isbigint, isdate:isdate, isdatetime:isdatetime, /*isdatetime-local: isdatetime-local,*/ isurl : isurl, ispassword : ispassword,
            isString: !isCurrency && !isInteger && !isnumber && !isboolean && !isbigint && !isdate /*&& !isdatetime-local*/ && !isurl && !ispassword && !isdatetime};
       
        
        console.log('@@@ tmp ' , tmp);
        selectedTmp.push(tmp);
        this.SelectedRecordFields = selectedTmp;


       });

       var h = this;
       window.setTimeout(function(){
        h.loadedRecord = true;
       }, 700);

    }


    onClickObjectNameHandler(event){
        console.log('@@@ event ' , event.target.dataset.id);


        var recordId = event.target.dataset.id;
        this.loaded = true;
        this.IdFront = recordId;


        if(recordId.startsWith('001')){ 
            userHasAccessToRecord({ recordId: recordId }).then(result => {
                //console.log('@@@ result ' , result);  
                if(result){
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: recordId,
                                actionName: 'view',
                            },
                        });
                        this.loaded = false;
                } else {     
                
                var tmpSection =[];
           
           
                this.visibilitaSection.forEach(element => {
                

                    var Section = {              
                        isLayout: element.MasterLabel.includes('RecordLayout') || element.MasterLabel.includes('KPI'),
                        nameLayout : element.MasterLabel.includes('_') ? element.MasterLabel.split('_')[1] : 'Record',
                        isRelatedList: element.MasterLabel.includes('RelatedList'),
                        fields: element.fields__c.split(';'),
                        title: element.title__c,
                        order : element.order__c,
                        apiName : element.API_name__c,
                        objectName: element.objectName__c, 
                        objectLabel: element.labelObject__c,
                        iconName: element.MasterLabel.includes('_') ? 'standard:' + element.MasterLabel.split('_')[1].toLowerCase() : '',
                        dati: [],
                        hasDati: false,
                        detailLabel: 'Dettaglio ' + element.labelObject__c
                    }



                    if(Section.isRelatedList){
                    var columns = [];
                    for(var i=0; i<3;i++){
                        
                        var type = this.columnsRelatedLists[Section.objectName][i].type.toLowerCase() == 'reference' ? 'text' : this.columnsRelatedLists[Section.objectName][i].type.toLowerCase();
                        var element= {label: this.columnsRelatedLists[Section.objectName][i].label, fieldName: Section.fields[i], type: type };
                        columns.push(element);
                    
                    }

                    if(Section.objectName != 'Coverage_Team_Member__c'){
                        var columsButton = { type: "button",
                                            typeAttributes:{label: "visualizza", title: "show_details", name: "button_details"}};

                        columns.push(columsButton);
                    }
                    Section.columns = columns;
                  
                    }

                    tmpSection.push(Section);
            

                     tmpSection.sort((a,b)=>{
                    if(a.order > b.order){
                        return 1;
                    }
                    if(a.order < b.order){
                        return -1;
                    }
                    return 0;
                    });
                
                
                this.SectionToFront = tmpSection; 
                console.log('@@@ SectionToFront ' , this.SectionToFront);
      
            });
            
                this.openModalInfoAccount = true;
                this.loaded = false;
            }
            }).catch(err => {
                console.log('@@@ err ' , err);
                this.loaded = false;
            });
    
        }else{

   
                console.log('@@@ recordID', recordId);
                this.loaded = false;
                this[NavigationMixin.Navigate]({
                    
                    type: 'standard__recordPage',
                    attributes: {
                        recordId : recordId,
                        objectApiName: 'Lead',
                        actionName: 'view',
                    },
                    
                });
          
        }
    }

    closeModalInfoAccount(event){
        this.openModalInfoAccount = false;
        this.SectionToFront = [];
    }
    
    get hasFields(){
        return this.SelectedRecordFields.length > 0;
    }
}