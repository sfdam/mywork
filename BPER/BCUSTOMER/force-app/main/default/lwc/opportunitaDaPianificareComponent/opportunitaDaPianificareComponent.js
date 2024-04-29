import { LightningElement,wire,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { RefreshEvent } from 'lightning/refresh';
import pubsub from 'omnistudio/pubsub';
import getOpps from '@salesforce/apex/OpportunitaDaPianificareController.getOpps';
import getUsers from '@salesforce/apex/OpportunitaDaPianificareController.getUsers';
import assignOpps from '@salesforce/apex/OpportunitaDaPianificareController.assignOpps';
import createEvents from '@salesforce/apex/OpportunitaDaPianificareController.createEvents';
import LightningModal from 'lightning/modal';
import labelWarning from "@salesforce/label/c.OppPrivilegiateComitatoCib1";
import labelWarningPrivName from "@salesforce/label/c.OppPrivilegiateComitatoCib2";

export default class OpportunitaDaPianificareComponent extends OmniscriptBaseMixin(LightningElement)  {

    oppColumns = [
        //{label: 'Id', fieldName: 'Id', type: 'url', typeAttributes: {label: {fieldName: 'Url'}, target: '_blank'} },
        //{label: 'Id', fieldName: 'Id'},
        { label: 'Nome Opportunità', fieldName: 'Url', type: 'url', typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_blank" } },
        { label: 'Nome Opportunità', fieldName: 'NameCustom', type: 'text' },
        //{ label: 'Id', fieldName: 'Url', type: 'url', typeAttributes: { label: { fieldName: "Id" }, tooltip:"Id", target: "_blank" } },
        //{label: 'Opportunity Name', fieldName: 'Name'},
        { label: 'NDG del Cliente', fieldName: 'NDG', type: 'text' },
        { label: 'Nome Account', fieldName: 'UrlAccountId', type: 'url', typeAttributes: { label: { fieldName: "AccountName" }, tooltip:"Account Name", target: "_blank" } },
        { label: 'Informazioni Privilegiate', fieldName: 'InfoPrivilegiate', type: 'text' },
        { label: 'Presentato da', fieldName: 'PresentatoDa', type: 'text' },
        { label: 'Fase', fieldName: 'StageName', type: 'text'}
    ]

    userColumns = [
      //{label: 'Id', fieldName: 'Id', type: 'url', typeAttributes: {label: {fieldName: 'Url'}, target: '_blank'} },
      //{label: 'Id', fieldName: 'Id'},
      { label: 'Nome', fieldName: 'Name', type: 'text' },
      { label: 'Email', fieldName: 'Email', type: 'text' },
      { label: 'Tipologia', fieldName: 'Tipologia', type: 'text' }
  ]

  label = {
    labelWarning,
    labelWarningPrivName
  };
    step2 = false
    selectedOpps = [];
    selectedOppsIds = [];
    selectedOppPrivilegiate = [];
    selectedOppNonPrivilegiate = [];
    @track selectedUsers = []
    comitatoId
    //data = [
    //    { Id: '006MT000002la27YAA', Name: 'OPP-0000806857'},
    //    { Id: '006MT000002la27YAA', Name: 'OPP-0000806857'},
    //    { Id: '006MT000002la27YAA', Name: 'OPP-0000806857'}
    //];

    oppRows = []
    userRows = []
    @track startDate;
    @track endDate;
    @track startDateInit;
    isLoading
    launchFlow = true
    @api title;
    @api icon;
    @api prefill;
    @track step3 = false;
    @track emptyOppRows = false;
    @track step1 = true;
    @track initialRecords = [];
    @track initialSelectedRecords = [];
    @track searchValue = "";
    @track showButton = false;
    @track oppPrivilegiate = false;
    @track oppPrivTmp;
    @track finishButtonLabel = 'Fine';
    oppIds = [];
    @track disabledIndietro = false;
    @track warning = false;
    @track warningPrivName = false;
    oppPrivId;
    @track oppListDaProcessare = [];
    @track stepIntermedio = false;

    @track startTime;
    @track endTime;
    @track startTimeOld;
    @track endTimeOld;
    queueUser = [];

    connectedCallback(){
      this.isLoading = true
      var today = new Date();
      today.setHours(8,0,0,0);

      this.startDate= today.toISOString().substring(0, today.toISOString().indexOf('T'));
      console.log('this.startDate: ' + this.startDate);
      this.startDateInit = this.startDate;
      this.endDate= this.startDate;
      this.startTime = "08:00:00.000Z";
      this.endTime = "08:30:00.000Z";
      this.startTimeOld = this.startTime;
      this.endTimeOld = this.endTime;

        getOpps()
        .then(result => {
          console.log('TEST --> ', JSON.stringify(result));
            this.oppRows = result.map(item => ({
                Id: item.Id,
                Name: item.Name,
                Url: '/' + item.Id,
                NDG: item.NGR_del_cliente__c,
                UrlAccountId: item.AccountId != undefined ? '/' + item.AccountId : '',
                AccountName : item.Dati_Cliente__c,
                PresentatoDa: item.Presentato_da__c,
                CIB_PresentatoDaId__c: item.CIB_PresentatoDaId__c,
                StageName: item.StageName,
                InfoPrivilegiate : item.Informazioni_Privilegiate__c,
                NameCustom : item.CIB_Nome_Opportunita__c,
                OraInizioIBC__c : item.OraInizioIBC__c,
                OraFineIBC__c : item.OraFineIBC__c,
                ProgressivoIBC__c : item.ProgressivoIBC__c
            }));

            if(!this.oppRows.length > 0){
              this.emptyOppRows = true;
            }
            this.isLoading = false
        })
        .catch(error => {
            this.isLoading = false
            console.log("error: " + error)
            const toastEvent = new ShowToastEvent({
              message: error.body.message,
              variant: "error"
            });
            console.log("error: " + error)
        })
    }

    renderedCallback(){
      console.log('TEST --> renderedCallback');
      pubsub.register('omniscript_step', {
        data: this.handleOmniStepLoadData.bind(this)
      });

    }

    handleOmniStepLoadData(data){
      console.log('TEST --> ' + data.end);
      this.showButton = data.end;
    }
    
    handleUserSelection(event){
      console.log('SELEZIONE');
      this.selectedUsers = event.detail.selectedRows.map(item => item.Id);
      console.log('TEST ', this.searchValue);
      console.log('TEST ', !this.searchValue);
      if(!this.searchValue){
        this.doSort();
      }
      console.log(JSON.stringify(this.selectedUsers))
    }

    handleOppSelection(event){
      this.selectedOppsIds = event.detail.selectedRows.map(item => item.Id);
      this.selectedOpps = event.detail.selectedRows;
    }

    previousStep(){
      // this.step2 = false;
      // this.step1 = true;
      if(this.step2){
        this.startDate = this.startDate.includes('T') ? this.startDate.substring(0, this.startDate.indexOf('T')) : this.startDate;
        console.log('this.startDate: ' + this.startDate);
        this.step2 = false;
        this.stepIntermedio = true;
      }else if(this.stepIntermedio){
        this.selectedOppNonPrivilegiate = [];
        this.selectedOppPrivilegiate = [];
        this.stepIntermedio = false;
        this.step1 = true;
      }

      console.log('this.selectedOpps', JSON.stringify(this.selectedOpps));
    }

    nextStep(){
      console.log('this.selectedOpps', JSON.stringify(this.selectedOpps));
      if(this.step1){
        if(this.selectedOpps.length > 0){
          this.selectedOpps.forEach((item) => {
            //if(!this.selectedOpps.includes(item.Id)){
              //this.selectedOpps.push(item.Id);
              if (item.InfoPrivilegiate === 'Si') {
                this.selectedOppPrivilegiate.push(item.Id);
              } else {
                this.selectedOppNonPrivilegiate.push(item.Id);
              }
            //}  
          });
          console.log('this.selectedOppNonPrivilegiate', JSON.stringify(this.selectedOppNonPrivilegiate));
          console.log('this.selectedOppPrivilegiate', JSON.stringify(this.selectedOppPrivilegiate));
          this.oppPrivilegiate = this.selectedOppPrivilegiate.length > 0 ? true : false;
          this.warning = this.selectedOppNonPrivilegiate.length > 0 && this.oppPrivilegiate ? true : false;
          this.warningPrivName = !this.selectedOppNonPrivilegiate.length > 0 && this.oppPrivilegiate ? true : false;

          if(this.warningPrivName){
            this.oppPrivId = this.selectedOppPrivilegiate.pop();
            console.log('this.oppPrivId', JSON.stringify(this.oppPrivId));
            this.oppPrivTmp = this.oppRows.find((element) => element.Id === this.oppPrivId);
            console.log('this.oppPrivTmp', JSON.stringify(this.oppPrivTmp));
            this.selectedOppPrivilegiate.push(this.oppPrivId);
          }

          this.oppIds = this.selectedOppNonPrivilegiate.length > 0 ? this.selectedOppNonPrivilegiate : [this.oppPrivId];
          console.log('this.oppIds', JSON.stringify(this.oppIds));
          this.oppListDaProcessare = this.oppRows.filter(obj => this.oppIds.includes(obj.Id));

          this.step1 = false;
          this.stepIntermedio = true;
          this.updateOppsTime();
        }else{
          const toastEvent = new ShowToastEvent({
            label: "Attenzione!",
            message: "Selezionare delle opportunità",
            variant: "warning"
          });
          this.dispatchEvent(toastEvent);
          return;
        }
      }else if(this.stepIntermedio){
        
        if (!this.startDate || !this.startTime || !this.endTime )
        {
          const toastEvent = new ShowToastEvent({
            label: "Attenzione!",
            message: "La Data e gli Orari sono obbligatori",
            variant: "warning"
          });
          this.dispatchEvent(toastEvent);
          return;
        }
        /*else if (this.startDate < today || this.endDate < today)
        {
          const toastEvent = new ShowToastEvent({
            message: "La StartDate e la EndDate devono essere maggiori o uguali della data attuale",
            variant: "warning"
          });
          this.dispatchEvent(toastEvent);
          return;
        }
        else if (this.startDate > this.endDate)
        {
          const toastEvent = new ShowToastEvent({
            message: "La StartDate non può essere maggiore della EndDate",
            variant: "warning"
          });
          this.dispatchEvent(toastEvent);
          return;
        }*/else{
          var today = new Date().toISOString();

          console.log('this.startDate: ' + this.startDate);
          console.log('this.endDate: ' + this.endDate);
          this.endDate = this.startDate;
          this.startDate = this.startDate.includes('T') ? this.startDate.substring(0, this.startDate.indexOf('T')) + 'T' + this.startTime : this.startDate + 'T' + this.startTime;
          this.endDate = this.endDate.includes('T') ? this.endDate.substring(0, this.endDate.indexOf('T')) + 'T' + this.endTime : this.endDate + 'T' + this.endTime;
          console.log('this.startDate: ' + this.startDate);
          console.log('this.endDate: ' + this.endDate);

          if (this.startDate < today)
          {
            const toastEvent = new ShowToastEvent({
              label: "Attenzione",
              message: "Ora Inizio deve essere maggiore dell'ora attuale",
              variant: "warning"
            });
            this.dispatchEvent(toastEvent);
            return;
          }
          let timeRequired = false;
          this.oppListDaProcessare.forEach((item) => {
            if (item.OraInizioIBC__c === undefined || item.OraInizioIBC__c === null ||  item.OraFineIBC__c === undefined || item.OraFineIBC__c === null) {
              const toastEvent = new ShowToastEvent({
                label: "Attenzione!",
                message: "Gli orari sono obbligatori",
                variant: "warning"
              });
              this.dispatchEvent(toastEvent);
              timeRequired = true;
              return;
            }
          });
          if(timeRequired){
            return;
          }

          if(this.warningPrivName){
            this.selectedUsers = [];
          }
  
          this.isLoading = true
          console.log("getUsers", JSON.stringify(this.oppListDaProcessare))
          getUsers({presentatiDa: this.oppListDaProcessare.map(item => item.CIB_PresentatoDaId__c)})
          .then(result => {
              this.isLoading = false
              this.stepIntermedio = false;
              this.step2 = true;

              this.userRows = result.AllUsers;
              this.selectedUsers = result.SelectedUsers;
              
              this.initialRecords = result.AllUsers;
              this.initialSelectedRecords = result.SelectedUsers;
              this.queueUser = result.QueueUser;
              this.userRows.forEach((user) => {
                if(this.queueUser.includes(user.Id)){
                  user.Tipologia = 'Partecipante';
                }else user.Tipologia = 'Invitato';
              });
          })
          .catch(error => {
              this.isLoading = false
              console.log("error: " + error)
              const toastEvent = new ShowToastEvent({
                message: error.body.message,
                variant: "error"
              });
              this.dispatchEvent(toastEvent);
          })

          console.log('this.selectedOppNonPrivilegiate', JSON.stringify(this.selectedOppNonPrivilegiate));
          console.log('this.selectedOppPrivilegiate', JSON.stringify(this.selectedOppPrivilegiate));
        }
      }
    }

    finish(){
      this.isLoading = true
      
      console.log('this.oppPrivTmp', JSON.stringify(this.oppPrivTmp));
      // console.log('this.oppPrivTmp', this.oppPrivTmp.Id);
      console.log('this.selectedOppNonPrivilegiate.length', this.selectedOppNonPrivilegiate.length);

      if(this.warningPrivName){
        this.oppPrivId = this.selectedOppPrivilegiate.pop();
        console.log('this.oppPrivId', JSON.stringify(this.oppPrivId));
        this.oppPrivTmp = this.oppRows.find((element) => element.Id === this.oppPrivId);
        console.log('this.oppPrivTmp', JSON.stringify(this.oppPrivTmp));
      }
      
      if(!this.selectedOppPrivilegiate.length > 0){
        this.oppPrivilegiate = false;
      }
      if(this.oppPrivilegiate){
        this.finishButtonLabel = 'Continua';
      }else{
        this.finishButtonLabel = 'Fine';
      }
      this.oppIds = this.selectedOppNonPrivilegiate.length > 0 ? this.selectedOppNonPrivilegiate : [this.oppPrivId];
      console.log('this.oppIds', JSON.stringify(this.oppIds));
      // console.log('this.oppPrivId', JSON.stringify(this.oppPrivId));
      // this.oppIds = this.selectedOppNonPrivilegiate.length > 0 ? this.selectedOppNonPrivilegiate : [this.oppPrivId];
      console.log('this.oppListDaProcessare', JSON.stringify(this.oppListDaProcessare));
      console.log('this.startDate', this.startDate);
      console.log('this.endDate', this.endDate);
      assignOpps({opps: /*this.oppRows.filter(obj => this.oppIds.includes(obj.Id))*/this.oppListDaProcessare, startDate: this.startDate, endDate: this.endDate})
      .then(result=>{
        this.comitatoId = result;
        createEvents({userIds: this.selectedUsers, startDate: this.startDate, endDate: this.endDate, comitatoId: this.comitatoId})  
        .then(result=>{
          this.step2 = false;
          console.log('this.oppRows', JSON.stringify(this.oppRows));
          this.oppRows = this.oppRows.filter(obj => !this.oppIds.includes(obj.Id));
          console.log('this.oppRows', JSON.stringify(this.oppRows));
          this.selectedOppsIds = [];
          this.selectedOpps = [];
          this.selectedOppNonPrivilegiate = [];
          this.isLoading = false
          const toastEvent = new ShowToastEvent({
            message: "Operazione effettuata correttamente",
            variant: "success"
          });
          this.dispatchEvent(toastEvent);
          this.step3 = true;
          this.step2 = false;
          this.step1 = false;
        })
        .catch(error=>{
          this.isLoading = false
          console.log(JSON.stringify(error))
          const toastEvent = new ShowToastEvent({
            message: error.body.message,
            variant: "error"
          });
          this.dispatchEvent(toastEvent);
        })
      })
      .catch(error=>{
        console.log(JSON.stringify(error))
        const toastEvent = new ShowToastEvent({
          message: error.body.message,
          variant: "error"
        });
        this.dispatchEvent(toastEvent);
      })
        
    }

  handleChange(event){
    try {
        console.log(event.target.value);
        let name = event.target.name;
        let value = event.target.value;
        //let dateTimeInput = new Date(event.target.value);
        if(name == 'startDate'){
          if(value < this.startDateInit){
            const toastEvent = new ShowToastEvent({
              label: "Attenzione!",
              message: "La Data deve essere maggiore o uguale a Oggi",
              variant: "warning"
            });
            this.dispatchEvent(toastEvent);
            event.target.value = this.startDateInit;
            this.startDate = this.startDateInit;
            console.log('this.startDate: ' + this.startDate);
            return;
          }
          this.startDate = value;
          // this.startTime = String(dateTimeInput.getHours()).padStart(2, '0') + ':' + String(dateTimeInput.getMinutes()).padStart(2, '0') + ':00.000Z';
          console.log('this.startDate: ' +  this.startDate);
        }else{
          value = value + 'Z';
          if(name == 'startTime'){
            //if(value > this.endTime){
            //  const toastEvent = new ShowToastEvent({
            //    label: "Attenzione!",
            //    message: "Ora Inizio deve essere minore o uguale di Ora Fine",
            //    variant: "warning"
            //  });
            //  this.dispatchEvent(toastEvent);
            //  event.target.value = this.startTimeOld;
            //  this.startTime = this.startTimeOld;
            //  console.log('this.startTime: ' + this.startTime);
            //  return;
            //}
            this.startTime = value;
            this.startTimeOld = this.startTime;
            console.log('this.startTime: ' + this.startTime);
            this.updateOppsTime();
          }else if(name == 'endTime'){
            if(value < this.startTime){
              const toastEvent = new ShowToastEvent({
                label: "Attenzione!",
                message: "Ora Fine deve essere maggiore o uguale di Ora Inizio",
                variant: "warning"
              });
              this.dispatchEvent(toastEvent);
              event.target.value = this.endTimeOld;
              this.endTime = this.endTimeOld;
              console.log('this.endTime: ' + this.endTime);
              return;
            }
            this.endTime = value;
            this.endTimeOld = this.endTime;
            console.log('this.endTime: ' + this.endTime);
          }
        }
        
    } catch(error) {
        console.log('error: ' + error);
    }
  }

  handleSearch(event) {
    const searchKey = event.target.value.toLowerCase();
    this.searchValue = searchKey;
    if (searchKey) {
      //console.log('TEST selectedUser ', JSON.stringify(this.selectedUsers));
        this.userRows = this.initialRecords;
      //console.log('TEST selectedUser ', JSON.stringify(this.selectedUsers));
        if (this.userRows) {
            let searchRecords = [];

            for (let record of this.userRows) {
              if(this.selectedUsers.includes(record.Id)){
                searchRecords.push(record);
              }else{
                let valuesArray = Object.values(record);

                for (let val of valuesArray) {
                    //console.log('val is ' + val);
                    let strVal = String(val);

                    if (strVal) {

                        if (strVal.toLowerCase().includes(searchKey)) {
                            searchRecords.push(record);
                            break;
                        }
                    }
                }
              }
            }

            console.log('Matched Accounts are ' + JSON.stringify(searchRecords));
            this.userRows = searchRecords;
            //this.selectedUsers = this.selectedUsers;
        }
    } else {
      this.doSort();
    }
}

  doSort(){
    let sortedRecords = [];
    for (let record of this.initialRecords) {
      if(this.selectedUsers.includes(record.Id)){
        sortedRecords.push(record);
      }
    }
    for (let record of this.initialRecords) {
      if(!this.selectedUsers.includes(record.Id)){
        sortedRecords.push(record);
      }
    }
    this.userRows = sortedRecords;
  }

  get getPrefillData() {
    return JSON.stringify({ ContextId: this.comitatoId, otherParam: "test" });
  }

  handleUploadFinished(event) {
    this.startDate = this.startDateInit;
    this.startTime = "08:00:00.000Z";
    this.endTime = "08:30:00.000Z";
    this.startTimeOld = this.startTime;
    this.endTimeOld = this.endTime;
    this.step3=false;
    this.warning = false;
    this.warningPrivName = !this.selectedOppNonPrivilegiate.length > 0 && this.oppPrivilegiate ? true : false;
    if(this.warningPrivName){
      this.oppPrivId = this.selectedOppPrivilegiate.pop();
      console.log('this.oppPrivId', JSON.stringify(this.oppPrivId));
      this.oppPrivTmp = this.oppRows.find((element) => element.Id === this.oppPrivId);
      console.log('this.oppPrivTmp', JSON.stringify(this.oppPrivTmp));
      this.selectedOppPrivilegiate.push(this.oppPrivId);
      this.oppListDaProcessare = [this.oppPrivTmp];
    }
    if(this.oppPrivilegiate){
      console.log('this.selectedOppNonPrivilegiate', JSON.stringify(this.selectedOppNonPrivilegiate));
      console.log('this.selectedOppPrivilegiate', JSON.stringify(this.selectedOppPrivilegiate));
      this.stepIntermedio=true;
      this.step2=false;
      this.step1 = false;
      this.disabledIndietro = true;
      this.selectedUsers = [];
      this.updateOppsTime();
    }else{
      // this.stepIntermedio=false;
      // this.step2=false;
      // this.step1 = true;
      // this.disabledIndietro = false;
      // this.selectedUsers = this.initialSelectedRecords;
      // this.selectedOpps = [];
      // this.selectedOppsIds = [];

      // this.dispatchEvent(new RefreshEvent());
      setTimeout(() => {
        window.location.reload(true);
      }, 500);
      
    }
    this.doSort();
    
  }

  handleProgressivoChange(event){
    let progressivo = event.target.value;
    let idOpp = event.target.name;
    this.oppListDaProcessare.find((element) => element.Id === idOpp).ProgressivoIBC__c = progressivo;
  }

  handleStartTimeChange(event){
    let ora = event.target.value;
    let idOpp = event.target.name;
    this.oppListDaProcessare.find((element) => element.Id === idOpp).OraInizioIBC__c = ora;
  }

  handleEndTimeChange(event){
    let ora = event.target.value;
    let idOpp = event.target.name;
    this.oppListDaProcessare.find((element) => element.Id === idOpp).OraFineIBC__c = ora;
  }
  

  updateOppsTime(){
    console.log('updateOppsTime');
    let hours = parseInt(this.startTime.split(':')[0]);
    let minutes = parseInt(this.startTime.split(':')[1]);
    let oppStartTime
    let oppEndTime
    let overflow = false
    for (let i = 0; i < this.oppListDaProcessare.length; i++) {
    
      oppStartTime = hours.toString().padStart(2, '0') + ':' + minutes.toString().padStart(2, '0') + ':00.000Z';
      
      minutes += 15;
      
      if(minutes==60)
      {
        minutes=0;
        hours++;
      }
      
      if (hours>=24) {
        //console.log('L\'orario supera le 24:00');
        overflow = true
        break;
      }

      oppEndTime = hours.toString().padStart(2, '0') + ':' + minutes.toString().padStart(2, '0') + ':00.000Z';
      
      this.oppListDaProcessare[i].OraInizioIBC__c = oppStartTime;
      this.oppListDaProcessare[i].OraFineIBC__c = oppEndTime;
    }
    this.endTime = oppEndTime;

    if(overflow)
    {
      for (let i = 0; i < this.oppListDaProcessare.length; i++) {
        this.oppListDaProcessare[i].OraInizioIBC__c = '';
        this.oppListDaProcessare[i].OraFineIBC__c = '';
      }
      this.endTime = '';

      const toastEvent = new ShowToastEvent({
        label: "Attenzione!",
        message: "L\'orario supera le 24:00",
        variant: "warning"
      });
      this.dispatchEvent(toastEvent);
      event.target.value = this.startTimeOld;
      this.startTime = this.startTimeOld;
      console.log('this.startTime: ' + this.startTime);
      return;
    }
  }
}