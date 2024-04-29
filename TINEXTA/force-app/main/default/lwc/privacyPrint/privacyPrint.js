import { LightningElement, api } from 'lwc';

export default class PrivacyPrint extends LightningElement {

    @api privacy_consenso;
    _privacy1;
    _privacy2;
    @api socLabel;
    @api socSedeLegale;
    @api socPIVA;
    @api socName;
    @api socEmail;
    
    @api get privacy1() {
        return this._privacy1;
    }
    
    set privacy1(v) {
        console.log('@@@ v ', v);
        let authorize1_true = this.template.querySelector(
            `[data-item="authorize1_true"]`
        );
        let authorize1_false = this.template.querySelector(
            `[data-item="authorize1_false"]`
        );
        
        this._privacy1 = v;
        if (v == true) {
            if(authorize1_true !== null)
                authorize1_true.checked = true;
        } else {
            if(authorize1_false !== null)
                authorize1_false.checked = false;
        }
    }
    
    @api get privacy2() {
        return this._privacy2;
    }
    
    set privacy2(v) {
        let authorize2_true = this.template.querySelector(
            `[data-item="authorize2_true"]`
        );
        let authorize2_false = this.template.querySelector(
            `[data-item="authorize2_false"]`
        );
        
        this._privacy2 = v;
        if (v == true) {
            if(authorize2_true !== null)
                authorize2_true.checked = true;
        } else {
            if(authorize2_false !== null)
                authorize2_false.checked = false;
        }
    }
    
    renderedCallback() {
        let authorize1_true = this.template.querySelector(
            `[data-item="authorize1_true"]`
        );
        let authorize1_false = this.template.querySelector(
            `[data-item="authorize1_false"]`
        );
        
        if (this.privacy1) {
            if(authorize1_true !== null)
                authorize1_true.checked = true;
        } else {
            if(authorize1_false !== null)
                authorize1_false.checked = true;
        }
        
        let authorize2_true = this.template.querySelector(
            `[data-item="authorize2_true"]`
        );
        let authorize2_false = this.template.querySelector(
            `[data-item="authorize2_false"]`
        );
        
        if (this.privacy2) {
            if(authorize2_true !== null)
                authorize2_true.checked = true;
        } else {
            if(authorize2_false !== null)
                authorize2_false.checked = true;
        }
    }
}