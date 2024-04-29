import { LightningElement, api, track, wire } from "lwc";
import { getRecord, createRecord } from "lightning/uiRecordApi";
import {
  getObjectInfo,
  getPicklistValuesByRecordType
} from "lightning/uiObjectInfoApi";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

// import getCodes from "@salesforce/apex/INF_CloseOpportunityController.getCodes";
import getCodes from "@salesforce/apex/INF_CloseOpportunityController.getCodesNew";
import createTicketVTE from "@salesforce/apex/INF_integrationVTEController.createTicketVTE";

import ACCOUNTID from "@salesforce/schema/Opportunity.AccountId";
import CASE_OBJECT from "@salesforce/schema/Case";

const fields = [ACCOUNTID];

export default class iNF_CreateCase extends LightningElement {
  @api recordId;
  @api accId;

  @track codes = [];
  @track selectedCode;

  @track priorityPicklist = [];
  @track famigliaPicklist = [];
  @track prodottoPicklistTotal = [];
  @track prodottoPicklistFiltered = [];

  @track caseRecord = { apiName: "Case", fields: {} };

  // @api objectApiName;
  @track objectInfo;

  //Recupero le info di Case
  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  objectInfo;

  @wire(getPicklistValuesByRecordType, {
    objectApiName: CASE_OBJECT,
    recordTypeId: "$recordTypeId"
  })
  getPicklistCase({ error, data }) {
    if (data) {
      //Prendo i campi necessari
      this.priorityPicklist = data.picklistFieldValues.Priority.values;
      this.famigliaPicklist = data.picklistFieldValues.VTE_famiglia__c.values;
      this.prodottoPicklistTotal = data.picklistFieldValues.VTE_product__c;

      if (this.codes.length > 0)
        this.template
          .querySelector("lightning-spinner")
          .classList.add("slds-hide");
    }
    if (error) {
      //Stampo errore e chiudo
      console.log("@@@ error ", error);
    }
  }

  @wire(getRecord, { recordId: "$recordId", fields })
  getFields({ error, data }) {
    if (data) {
      console.log("FIELDS: ", JSON.stringify(data.fields));
      // this.accountId = data.fields.AccountId.value;
      // this.accId = data.fields.AccountId.value;

      getCodes({ optyId: this.recordId }).then((result) => {
        console.log("result getCodes: ", JSON.stringify(result));
        var codeList = result.codesList;
        if (codeList.length == 0) {
          // this.codes.push({
          //   label: "NESSUN CODICE CLIENTE DISPONIBILE",
          //   value: 0
          // });
          // this.selectedCode = this.codes[0].value;
        } else if (codeList.length > 0) {
          // let codesList = [];
          // codeList.forEach((element) => {
          //   codesList.push({ label: element, value: element });
          // });
          // this.codes = codesList;
          // this.selectedCode = this.codes[0].value;
          this.selectedCode = codeList[0];
        }

        if (this.famigliaPicklist.length > 0)
          this.template
            .querySelector("lightning-spinner")
            .classList.add("slds-hide");
      });
    } else if (error) {
      // Handle error
      console.log("=============Error=============");
      console.log(error);
    }
  }

  onCodeChange(event) {
    this.selectedCode = event.target.value;
  }

  //GETTER & SETTER
  @api
  get noCodesAvailable() {
    return this.codes.length == 1 && this.codes[0].value == 0;
  }

  @api
  get noPriorityPicklist() {
    return this.priorityPicklist.lenght == 0;
  }

  @api
  get noFamigliaPicklist() {
    return this.famigliaPicklist.lenght == 0;
  }

  @api
  get noProdottoPicklist() {
    return (
      this.prodottoPicklistFiltered.lenght == 0 ||
      this.caseRecord.fields.VTE_famiglia__c == undefined
    );
  }

  @api
  get contactFilter() {
    return (
      "RecordType.DeveloperName = 'Infocert_Sixtema' AND AccountId = '" +
      this.accId +
      "'"
    );
  }

  get recordTypeId() {
    // Returns a map of record type Ids
    if (this.objectInfo.data == undefined) return null;

    const rtis = this.objectInfo.data.recordTypeInfos;
    return Object.keys(rtis).find((rti) => rtis[rti].name === "VTE");
  }

  closeQuickActionAura() {
    this.dispatchEvent(
      new CustomEvent("closequickactionaura", { bubbles: true, composed: true })
    );
  }

  fieldChangeDependent(evt) {
    this.prodottoPicklistFiltered = [];
    const selectedVal = evt.target.value;
    var controllerValues = this.prodottoPicklistTotal.controllerValues;
    this.prodottoPicklistTotal.values.forEach((depVal) => {
      depVal.validFor.forEach((depKey) => {
        if (depKey === controllerValues[selectedVal]) {
          this.prodottoPicklistFiltered.push({
            label: depVal.label,
            value: depVal.value
          });
        }
      });
    });
    this.caseRecord.fields.VTE_famiglia__c = selectedVal;
  }

  fieldChange(evt) {
    this.caseRecord.fields[evt.target.name] = evt.target.value;
  }

  saveRecord(evt) {
    this.template
      .querySelector("lightning-spinner")
      .classList.remove("slds-hide");
    console.log("@@@ prova ", this.template.querySelector("lightning-spinner"));
    let lookup = this.template.querySelector("c-custom-lookup");
    //Contact non più obbligatorio
    if(lookup.selectedSObject != undefined)
      this.caseRecord.fields.ContactId = lookup.selectedSObject.objId;
    /*
    if (lookup.selectedSObject == undefined) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Errore!",
          // message: "Compilare tutti i campi per creare il Case",
          message: "Compilare il campo 'Referente' per aprire il ticket.",
          variant: "error"
        })
      );
      this.template
        .querySelector("lightning-spinner")
        .classList.add("slds-hide");
      return null;
    } else {
      this.caseRecord.fields.ContactId = lookup.selectedSObject.objId;
    }
    */

    // if (this.selectedCode == 0) {
    if (this.selectedCode == undefined || this.selectedCode == null || this.selectedCode == '') {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Errore!",
          message:
            "Per aprire un ticket è necessario inserire il codice cliente nel relativo campo dell’opportunità. In caso di assenza del codice cliente da associare all’opportunità sollecitare Amministrazione Clienti",
          variant: "warning"
        })
      );
      this.template
        .querySelector("lightning-spinner")
        .classList.add("slds-hide");
      return null;
    } else {
      this.caseRecord.fields.VTE_codicecliente_txt__c = this.selectedCode;
    }

    if (
      this.caseRecord.fields.Priority == undefined ||
      this.caseRecord.fields.VTE_famiglia__c == undefined ||
      this.caseRecord.fields.VTE_product__c == undefined ||
      //this.caseRecord.fields.ContactId == undefined ||
      this.caseRecord.fields.Description == undefined || 
      this.caseRecord.fields.Description == '' ||
      this.caseRecord.fields.VTE_codicecliente_txt__c ==
        undefined /*||
            this.caseRecord.fields.VTE_commenti_interni__c == undefined*/
    ) {
      let errMsg = this.formatErrMsg(this.caseRecord.fields);

      this.dispatchEvent(
        new ShowToastEvent({
          title: "Errore!",
          message: errMsg,
          variant: "error"
        })
      );

      this.template
        .querySelector("lightning-spinner")
        .classList.add("slds-hide");
      return null;
    }

    this.caseRecord.fields.Opportunity__c = this.recordId;
    // this.caseRecord.fields.AccountId = this.accId;

    this.caseRecord.fields.RecordTypeId = this.recordTypeId;
    
    createRecord(this.caseRecord)
      .then((result) => {
        // if(result == 'ok'){
        if (result.id != undefined) {
          createTicketVTE({ caseId: result.id }).then((result) => {
            if (result == "ok") {
              this.dispatchEvent(
                new ShowToastEvent({
                  title: "Successo!",
                  message: "Record creato con successo",
                  variant: "success"
                })
              );
              this.template
                .querySelector("lightning-spinner")
                .classList.add("slds-hide");
              this.closeQuickActionAura();
            } else
              this.dispatchEvent(
                new ShowToastEvent({
                  title: "Errore!",
                  message: "Errore durante la creazione del caso, riprovare",
                  variant: "error"
                })
              );
          });
        } else
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Errore!",
              message: "Errore durante la creazione del caso, riprovare",
              variant: "error"
            })
          );

        console.log("@@@ result ", result);
      })
      .catch((err) => {
        console.log("@@@ error ", err);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Errore!",
            message: err.body.message,
            variant: "error"
          })
        );
        this.template
          .querySelector("lightning-spinner")
          .classList.add("slds-hide");
      });
  }

  formatErrMsg(record) {
    let msg = "Compilare i seguenti campi per aprire il ticket: \n\r";

    if (!record.Priority) {
      msg += "Priorità, ";
    }
    if (!record.VTE_famiglia__c) {
      msg += "Famiglia, ";
    }
    if (!record.VTE_product__c) {
      msg += "Prodotto, ";
    }
    /*if (!record.ContactId) {
      msg += "Referente, ";
    }*/
    if (!record.Description) {
      msg += "Descrizione, ";
    }

    msg.substring(0, msg.length - 1);
    return msg;
  }
}