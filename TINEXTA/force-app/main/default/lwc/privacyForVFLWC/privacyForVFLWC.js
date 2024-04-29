import { LightningElement, api, track } from "lwc";
// Import ToastEvent
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import TINEXTA_LOGO from "@salesforce/resourceUrl/logo_Tinexta";

// LOGHI SOCIETA'
import WRT_LOGO from "@salesforce/resourceUrl/privacy_logo_WRT";
import INF_LOGO from "@salesforce/resourceUrl/privacy_logo_INF";
import INN_LOGO from "@salesforce/resourceUrl/privacy_logo_INN";
import VIS_LOGO from "@salesforce/resourceUrl/privacy_logo_VIS";
import SXT_LOGO from "@salesforce/resourceUrl/privacy_logo_SXT";
import VAL_LOGO from "@salesforce/resourceUrl/privacy_logo_VAL";
import CMK_LOGO from "@salesforce/resourceUrl/privacy_logo_CMK";

import getData from "@salesforce/apex/PrivacyController.getData";
import savePrivacy from "@salesforce/apex/PrivacyController.savePrivacy";
// import sendRecapEmail from '@salesforce/apex/PrivacyController.sendRecapEmail';

export default class PrivacyForVFLWC extends LightningElement {
  @track error;

  @api contactId;
  @api ptype;
  @api idSoc;

  @api thanksPage = false;
  @api result;
  @api socInfo;

  @track errorMsg = false;

  /*
    TIPO PRIVACY:
        1 - CONSENSO
        2 - LEGITTIMO INTERESSE
    */
  @track privacy_consenso;
  @track privacy_legittimoInteresse;

  // @track privacy1 = false;
  // @track privacy2 = false;

  @track privacy1;
  @track privacy2;

  // Expose the static resource URL for use in the template
  tinextaLogoUrl = TINEXTA_LOGO;
  socLogo;
  
  connectedCallback() {
    if (this.ptype == 1) {
      this.privacy_consenso = true;
      this.privacy_legittimoInteresse = false;
    } else {
      this.privacy_consenso = false;
      this.privacy_legittimoInteresse = true;
    }
    getData({ contactId: this.contactId })
      .then((result) => {
        console.log("SV RESULT", result);
        let socInfo;
        this.result = result;
        socInfo = result[this.idSoc];
        console.log("SV socInfo", socInfo);
        if (socInfo != undefined) {
          if (socInfo.Identificativo__c == "WRT") {
            this.socLogo = WRT_LOGO;
          } else if (socInfo.Identificativo__c == "INF") {
            this.socLogo = INF_LOGO;
          } else if (socInfo.Identificativo__c == "INN") {
            this.socLogo = INN_LOGO;
          } else if (socInfo.Identificativo__c == "CMK") {
            this.socLogo = CMK_LOGO;
          } else if (socInfo.Identificativo__c == "SXT") {
            this.socLogo = SXT_LOGO;
          } else if (socInfo.Identificativo__c == "VAL") {
            this.socLogo = VAL_LOGO;
          } else if (socInfo.Identificativo__c == "VIS") {
            this.socLogo = VIS_LOGO;
          }
        }

        this.socInfo = socInfo;
      })
      .catch((error) => {
        // alert('ERROR');
        this.error = error;
        console.log("SV ERROR", error);
      })
      .finally(() => {});
  }

  handleCheckBoxChange(event) {
    // console.log(
    //   "Authorized:: " + event.target.name + " " + event.target.checked
    // );
    // // Your Logic
    let authorize1_true = this.template.querySelector(
      `[data-item="authorize1_true"]`
    );
    let authorize1_false = this.template.querySelector(
      `[data-item="authorize1_false"]`
    );
    let authorize2_true = this.template.querySelector(
      `[data-item="authorize2_true"]`
    );
    let authorize2_false = this.template.querySelector(
      `[data-item="authorize2_false"]`
    );

    let privacyArray = event.target.name.split("_");

    if (privacyArray[0] == "authorize1") {
      if (privacyArray[1] == "true") {
        if (event.target.checked) {
          this.privacy1 = true;
          authorize1_false.checked = false;
        } else {
          this.privacy1 = false;
          authorize1_false.checked = true;
        }
      }

      if (privacyArray[1] == "false") {
        if (event.target.checked) {
          this.privacy1 = false;
          authorize1_true.checked = false;
        } else {
          this.privacy1 = true;
          authorize1_true.checked = true;
        }
      }
    } else if (privacyArray[0] == "authorize2") {
      if (privacyArray[1] == "true") {
        if (event.target.checked) {
          this.privacy2 = true;
          authorize2_false.checked = false;
        } else {
          this.privacy2 = false;
          authorize2_false.checked = true;
        }
      }

      if (privacyArray[1] == "false") {
        if (event.target.checked) {
          this.privacy2 = false;
          authorize2_true.checked = false;
        } else {
          this.privacy2 = true;
          authorize2_true.checked = true;
        }
      }
    }
    console.log(this.privacy1, this.privacy2);

  }

  handleSaveChange(event) {
    console.log("SAVE");
    this.errorMsg = false;
    
    console.log(this.privacy1, this.privacy2);

    if((this.privacy1 == undefined || this.privacy2 == undefined) && this.ptype == '1'){
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Attenzione!",
          message: "è necessario compilare i campi per poter confermare",
          variant: "warning"
        })
      )

      this.errorMsg = true;
      return;
    } else if(this.ptype == '2'){
      this.privacy1 = true;
      this.privacy2 = true;
    }

    savePrivacy({
      contactId: this.contactId,
      privacy1: this.privacy1,
      privacy2: this.privacy2,
      tipoPrivacy: this.ptype
    })
      .then((result) => {
        console.log("SV RESULT", result);
        if (result) {
          this.thanksPage = true;
        }
        // if (result) {
        //   return sendRecapEmail({ recId: this.contactId, codiceAzienda: this.idSoc, linkPagina: window.location.href })
        // }
      })
      // .then(resultEmail => {
      //   console.log('@@@ resultEmail ', resultEmail);
      //   if (resultEmail) {
      //     this.thanksPage = true;
      //   } else {
      //     this.error = 'Errore durante il processo riprovare'
      //   }
      // })
      .catch((error) => {
        alert("ERROR");
        this.error = error;
        console.log("SV ERROR", error);
      })
      .finally(() => {});
  }
  
  printPage() {
    window.print();
  }

  get socLabel() {
    let acc = this.socInfo;
    return acc != undefined ? acc.Label : "";
  }

  get socSedeLegale() {
    let acc = this.socInfo;
    // return acc != undefined ? acc.City__c + ' (' + acc.State__c + '), in ' + acc.Street__c : '';
    return acc != undefined
      ? acc.Street__c + ", " + acc.City__c + " (" + acc.State__c + ")"
      : "";
  }

  get socPIVA() {
    let acc = this.socInfo;
    return acc != undefined ? acc.PIVA__c : "";
  }

  get socName() {
    let acc = this.socInfo;
    return acc != undefined ? acc.NomeCompleto__c : "";
  }

  get socEmail() {
    let acc = this.socInfo;
    return acc != undefined ? acc.Email__c : "";
  }
}