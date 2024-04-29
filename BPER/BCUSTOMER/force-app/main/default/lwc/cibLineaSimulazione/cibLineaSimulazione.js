import { LightningElement, api, track } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CibLineaSimulazione extends LightningElement {
    @api recordId;
    titolo
    @api lineaSimulazione = {};

    @track sezioniAttive = ['sezione1', 'sezione2'];

    @track loaded = false;
    @track isOpenModal = false;

    @track periodiErogazione = [];
    @track interestStepTassoFisso = [];
    @track interestStepCommissioneFirma = [];
    @track ammortamentoAdHoc = [];

    inputFieldsToHide;
    inputFieldsToDisable;

    termoutOptionRadioGroupName = 'Termoutoption__c';
    salRadioGroupName = 'SAL__c';
    garanziaRadioGroupName = 'Garanzia__c';
    capRadioGroupName = 'Cap__c';
    floorRadioGroupName = 'Floor__c';
    interestStepRadioGroupName = 'Intereststep__c';
    interestStepCFRadioGroupName = 'IntereststepCF__c';
    upFrontValorePercRadioGroupName = 'UpFrontValorePerc__c';
    runningValorePercRadioGroupName = 'RunningValorePerc__c';
    altroValorePercRadioGroupName = 'AltroValorePerc__c';
     
    connectedCallback(){
        console.log('DK START CibLineaSimulazione');
        console.log('DK CibLineaSimulazione connectedCallback lineaSimulazione: ', JSON.stringify(this.lineaSimulazione));
        this.lineaSimulazione = JSON.parse(JSON.stringify(this.lineaSimulazione));
        if(!this.lineaSimulazione.Preammortamento__c)this.lineaSimulazione.Preammortamento__c = '';
        this.titolo = 'Linea ' + this.lineaSimulazione.Number__c;
        // this.titolo = 'Linea ' + (this.lineaSimulazione.Name ? this.lineaSimulazione.Name.split('-')[1] : 'nuova #' + this.lineaSimulazione.Number__c);
        // this.lineaSimulazione.Number__c = this.lineaSimulazione.Id ? this.lineaSimulazione.Id : this.lineaSimulazione.Number__c;
        if(this.lineaSimulazione.Rate_Linee__r){
            this.periodiErogazione = this.lineaSimulazione.Rate_Linee__r.filter(element => {return element.Type__c === 'Periodo Erogazione';}).sort(function(a,b){return parseFloat(a.Numerorata__c) - parseFloat(b.Numerorata__c)});
            this.interestStepTassoFisso = this.lineaSimulazione.Rate_Linee__r.filter(element => {return element.Type__c === 'Interest Step Tasso Fisso';}).sort(function(a,b){return parseFloat(a.Ratacorrispondentemodificatasso__c) - parseFloat(b.Ratacorrispondentemodificatasso__c)});
            this.interestStepCommissioneFirma = this.lineaSimulazione.Rate_Linee__r.filter(element => {return element.Type__c === 'Interest Step Commissione Firma';}).sort(function(a,b){return parseFloat(a.Ratacorrispondentemodificatasso__c) - parseFloat(b.Ratacorrispondentemodificatasso__c)});
            this.ammortamentoAdHoc = this.lineaSimulazione.Rate_Linee__r.filter(element => {return element.Type__c === 'Piano Ammortamento';}).sort(function(a,b){return parseFloat(a.ProgrPeriodo__c) - parseFloat(b.ProgrPeriodo__c)});
        }
        this.periodiErogazione.forEach(element =>{let nowId=this.makeId();element.number='periodiErogazione-'+nowId;element.key=nowId})
        this.interestStepTassoFisso.forEach(element =>{let nowId=this.makeId();element.number='interestStepTassoFisso-'+nowId;element.key=nowId})
        this.interestStepCommissioneFirma.forEach(element =>{let nowId=this.makeId();element.number='interestStepCommissioneFirma-'+nowId;element.key=nowId})
        this.ammortamentoAdHoc.forEach(element =>{let nowId=this.makeId();element.number='ammortamentoAdHoc-'+nowId;element.key=nowId})
        this.lineaSimulazione.periodiErogazione = [...this.periodiErogazione.filter(element =>{return Boolean(element.Id)})];
        this.lineaSimulazione.interestStepTassoFisso = [...this.interestStepTassoFisso.filter(element =>{return Boolean(element.Id)})];
        this.lineaSimulazione.interestStepCommissioneFirma = [...this.interestStepCommissioneFirma.filter(element =>{return Boolean(element.Id)})];
        this.lineaSimulazione.ammortamentoAdHoc = [...this.ammortamentoAdHoc.filter(element =>{return Boolean(element.Id)})];
        console.log('DK this.periodiErogazione', JSON.stringify(this.periodiErogazione));
        console.log('DK this.interestStepTassoFisso', JSON.stringify(this.interestStepTassoFisso));
        console.log('DK this.interestStepCommissioneFirma', JSON.stringify(this.interestStepCommissioneFirma));
        console.log('DK this.ammortamentoAdHoc', JSON.stringify(this.ammortamentoAdHoc));
        console.log('DK CibLineaSimulazione.this.optionsMap: ', JSON.stringify(this.optionsMap['Durata__c']));
        //linee
        this.optionsFormaTecnica = this.optionsMap['Formatecnica__c'];
        this.optionsValuta = this.optionsMap['Valuta__c'];
        this.optionsTipoDiAmmortamento = this.optionsMap['Tipo_di_ammortamento__c'];
        this.optionsTipoFunding = this.optionsMap['Tipo_funding__c'];
        this.optionsDurata = this.optionsMap['Durata__c'];
        this.optionsPeriodicitaRata = this.optionsMap['Periodicita_rata__c'];
        // this.optionsPreammortamento = this.optionsMap['Preammortamento__c'];
        this.optionsTipoGaranzia = this.optionsMap['Tipo_garanzia__c'];
        this.optionsTipoPegno = this.optionsMap['Tipo_pegno__c'];
        this.optionsTipoTasso = this.optionsMap['Tipo_tasso__c'];
        this.optionsIndicizzazioneTassoVariabile = this.optionsMap['Indicizzazionetassovariabile__c'];
        this.optionsSensitivity = this.optionsMap['Sensitivity__c'];
        this.optionsUtilizzo = this.optionsMap['Utilizzo__c']
        this.optionsRataCorrispondenteModificaTasso = [];
        this.optionsNumeroPeriodiDiErogazione = [];
        this.termoutOptionRadioGroupName += '#' + this.lineaSimulazione.Number__c;
        this.salRadioGroupName += '#' + this.lineaSimulazione.Number__c;
        this.garanziaRadioGroupName += '#' + this.lineaSimulazione.Number__c;
        this.capRadioGroupName += '#' + this.lineaSimulazione.Number__c;
        this.floorRadioGroupName += '#' + this.lineaSimulazione.Number__c;
        this.interestStepRadioGroupName += '#' + this.lineaSimulazione.Number__c;
        this.interestStepCFRadioGroupName += '#' + this.lineaSimulazione.Number__c;
        this.upFrontValorePercRadioGroupName += '#' + this.lineaSimulazione.Number__c;
        this.runningValorePercRadioGroupName += '#' + this.lineaSimulazione.Number__c;
        this.altroValorePercRadioGroupName += '#' + this.lineaSimulazione.Number__c;
        this.extendLinea();
        console.log('DK this.optionsSensitivity: ' + JSON.stringify(this.optionsSensitivity));
    }

    visibleFields = ['Simulazione__c', 'Number__c', 'Rate_Linee__r', 'Tipo_di_ammortamento__c', 'Tipo_funding__c'];

    renderedCallback(){
        if(this.hanldeRender || !this.loaded){

            console.log('START renderedCallback');
            // console.log('DK renderedCallback STEP ', JSON.stringify(this.lineaSimulazione));
            this.inputFieldsToHide = this.template.querySelectorAll('.is-hide');
            this.inputFieldsToDisable = this.template.querySelectorAll('.is-disable');
            console.log('DK CHECK CAMPI START', this.inputFieldsToHide.length, this.inputFieldsToDisable.length);

            let visibleFields = JSON.parse(JSON.stringify(this.visibleFields));
            if(this.lineaSimulazione.Formatecnica__c){
                if(this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('fideiussioni')){
                    visibleFields.push('Utilizzo__c');
                    visibleFields.push('Tipo_tasso__c');
                }
            }
    
            // gestione possibilità di modifica campi
            Object.keys(this.fieldAbilityMap).forEach(masterField =>{
                console.log('DK CHECK masterField ABILITAZIONE', masterField);
                console.log('DK CHECK masterField ABILITAZIONE VALUE', JSON.stringify(this.lineaSimulazione[masterField]));
                console.log('DK CHECK masterField ABILITAZIONE IS IN MAP', JSON.stringify(this.fieldAbilityMap[masterField][JSON.stringify(this.lineaSimulazione[masterField])]));
                let hasValue = this.lineaSimulazione[masterField] !== '' && this.lineaSimulazione[masterField] !== null && this.lineaSimulazione[masterField] !== undefined;
                console.log('DK CHECK masterField ABILITAZIONE HASVALUE', hasValue);
                if(this.fieldAbilityMap[masterField]){
                    let fieldAbilitySet = [];
                    Object.values(this.fieldAbilityMap[masterField]).forEach(fieldSet =>{
                        fieldSet.forEach(field =>{
                            if(!fieldAbilitySet.includes(field))fieldAbilitySet.push(field);
                        })
                    });
                    console.log('DK fieldAbilitySet', JSON.stringify(fieldAbilitySet));
                    if(hasValue && this.fieldAbilityMap[masterField][JSON.stringify(this.lineaSimulazione[masterField])]){
                        this.inputFieldsToDisable.forEach(inputField =>{
                            if(fieldAbilitySet.includes(inputField.name.split('#')[0])){
                                console.log('DK inputField TO CHECK: ' + inputField.name.split('#')[0]);
                                inputField.disabled = this.fieldAbilityMap[masterField][JSON.stringify(this.lineaSimulazione[masterField])].includes(inputField.name.split('#')[0]);
                                console.log('DK inputField.disabled: ' + inputField.disabled);
                            }
                            // setTimeout(() => {
                            //     inputField.setCustomValidity('');
                            //     inputField.reportValidity();
                            // }, 0);
                        })
                    }else{
                        this.inputFieldsToDisable.forEach(inputField =>{
                            if(fieldAbilitySet.includes(inputField.name.split('#')[0])){
                                console.log('DK DISABLE inputField: ' + inputField.name.split('#')[0]);
                                inputField.disabled = false;
                                console.log('DK inputField.disabled: ' + inputField.disabled);
                            }
                            // setTimeout(() => {
                            //     inputField.setCustomValidity('');
                            //     inputField.reportValidity();
                            // }, 0);
                        })
                    }
                }
            })
    
            // gestione visibilità campi
            Object.keys(this.fieldVisibilityMap).forEach(masterField =>{
                console.log('DK CHECK masterField VISIBILITA', masterField);
                console.log('DK CHECK masterField VISIBILITA VALUE', JSON.stringify(this.lineaSimulazione[masterField]));
                console.log('DK CHECK masterField VISIBILITA HAS', JSON.stringify(this.fieldVisibilityMap[masterField][''+this.lineaSimulazione[masterField]]));
                let hasValue = this.lineaSimulazione[masterField] !== '' && this.lineaSimulazione[masterField] !== null && this.lineaSimulazione[masterField] !== undefined;
                console.log('DK CHECK masterField VISIBILITA HASVALUE', hasValue);
                if(this.fieldVisibilityMap[masterField]){
                    let fieldVisibilitySet = [];
                    Object.values(this.fieldVisibilityMap[masterField]).forEach(fieldSet =>{
                        fieldSet.forEach(field =>{
                            if(!fieldVisibilitySet.includes(field))fieldVisibilitySet.push(field);
                        })
                    });
                    console.log('DK fieldVisibilitySet', JSON.stringify(fieldVisibilitySet));
                    if(hasValue && this.fieldVisibilityMap[masterField][''+this.lineaSimulazione[masterField]]){
                        this.inputFieldsToHide.forEach(inputField =>{
                            console.log('DK CHECKING FIELD', inputField.name.split('#')[0], inputField.Id);
                            if(fieldVisibilitySet.includes(inputField.name.split('#')[0])){
                                inputField.style.display = this.fieldVisibilityMap[masterField][''+this.lineaSimulazione[masterField]].includes(inputField.name.split('#')[0]) ? 'block' : 'none';
                                console.log('DK inputField.style.display: ', inputField.style.display, this.lineaSimulazione[inputField.name.split('#')[0]]);
                                // setTimeout(() => {
                                //     inputField.setCustomValidity('');
                                //     inputField.reportValidity();
                                // }, 0);
                                if(inputField.style.display == 'none' && !visibleFields.includes(inputField.name.split('#')[0])){
                                    this.lineaSimulazione[inputField.name.split('#')[0]] = inputField.type == 'checkbox' || this.lineaSimulazione[inputField.name.split('#')[0]] === true || this.lineaSimulazione[inputField.name.split('#')[0]] === false ? false :
                                    inputField.type == 'number' ? 0 : null;
                                    console.log('DK BLANK FIELD 1', inputField.name.split('#')[0]);
                                }
                            }
                        })
                    }else{
                        this.inputFieldsToHide.forEach(inputField =>{
                            console.log('DK CHECKING FIELD', inputField.name.split('#')[0], inputField.Id);
                            if(fieldVisibilitySet.includes(inputField.name.split('#')[0])){
                                // console.log('DK HIDE inputField: ' + inputField.name.split('#')[0]);
                                console.log('DK HIDE inputField: ', inputField.name.split('#')[0]);
                                inputField.style.display = 'none';
                                if(!visibleFields.includes(inputField.name.split('#')[0])){

                                    this.lineaSimulazione[inputField.name.split('#')[0]] = inputField.type == 'checkbox' || this.lineaSimulazione[inputField.name.split('#')[0]] === true || this.lineaSimulazione[inputField.name.split('#')[0]] === false ? false : 
                                    inputField.type == 'number' ? 0 :null; 
                                    console.log('DK BLANK FIELD 2', inputField.name.split('#')[0]);
                                }
                                // setTimeout(() => {
                                //     inputField.setCustomValidity('');
                                //     inputField.reportValidity();
                                // }, 0);
                            }
                        })
                        
                    }
                }
            })
            
            let changedSezioni = false;
            //gestione visisbilità sezioni
            Object.keys(this.sectionVisibilityMap).forEach(fieldSection =>{
                console.log('DK CHECK fieldSection', fieldSection);
                console.log('DK CHECK fieldSection VALUE', this.lineaSimulazione[fieldSection]);
                if(Boolean(this.lineaSimulazione[fieldSection]) &&this.sectionVisibilityMap[fieldSection][this.lineaSimulazione[fieldSection]]){
                    let sectionDependencySet = [];
                    Object.values(this.sectionVisibilityMap[fieldSection]).forEach(fieldSet =>{
                        fieldSet.forEach(field =>{
                            if(!sectionDependencySet.includes(field))sectionDependencySet.push(field);
                        })
                    });
                    console.log('DK sectionDependencySet', JSON.stringify(sectionDependencySet));
                    sectionDependencySet.forEach(showSezione =>{
                        if(!changedSezioni){
                            changedSezioni = this[showSezione] != this.sectionVisibilityMap[fieldSection][this.lineaSimulazione[fieldSection]].includes(showSezione);
                            console.log('DK changedSezioni_1', changedSezioni);
                        }
                        this[showSezione] = this.sectionVisibilityMap[fieldSection][this.lineaSimulazione[fieldSection]].includes(showSezione);
                    })
                }else{
                    let sectionDependencySet = [];
                    Object.values(this.sectionVisibilityMap[fieldSection]).forEach(fieldSet =>{
                        fieldSet.forEach(field =>{
                            if(!sectionDependencySet.includes(field))sectionDependencySet.push(field);
                        })
                    });
                    console.log('DK sectionDependencySet', JSON.stringify(sectionDependencySet));
                    sectionDependencySet.forEach(showSezione =>{
                        if(!changedSezioni){
                            changedSezioni = this[showSezione] === true;
                            console.log('DK changedSezioni_2', changedSezioni);
                        }
                        this[showSezione] = false;
                    })
                }

                //sbiancamento campi non più visibili
                let visibleFields = JSON.parse(JSON.stringify(this.visibleFields));
                if(this.lineaSimulazione.Formatecnica__c){
                    if(this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('fideiussioni')){
                        visibleFields.push('Utilizzo__c');
                        visibleFields.push('Tipo_tasso__c');
                    }
                }
                this.template.querySelectorAll('.validateLinea').forEach(inputField => {
                    if(!inputField.style || inputField.style.display !== 'none'){
                        visibleFields.push(inputField.name.split('#')[0])
                    }
                });

                Object.keys(this.lineaSimulazione).forEach(fieldLineaSimulazione =>{
                    if(fieldLineaSimulazione.includes('__c') && !visibleFields.includes(fieldLineaSimulazione)){
                        console.log('DK CibLineaSimulazione FIELD BLANK: ', fieldLineaSimulazione);
                        this.lineaSimulazione[fieldLineaSimulazione] = typeof this.lineaSimulazione[fieldLineaSimulazione] === 'boolean' ? false : typeof this.lineaSimulazione[fieldLineaSimulazione] === 'number' ? 0 : null;
                    }
                })

                if(this.showAmmortamentoAdHoc === false){
                    this.ammortamentoAdHoc = [];
                }

                if(this.lineaSimulazione.IntereststepCF__c === false){
                    this.interestStepCommissioneFirma = [];
                }

                if(this.lineaSimulazione.Intereststep__c === false){
                    this.interestStepTassoFisso = [];
                }

                if(this.lineaSimulazione.SAL__c === false){
                    this.periodiErogazione = [];
                }
            })
            
            // nascondi layout item vuoti
            this.template.querySelectorAll('.is-hide-layout-item').forEach(layoutItem =>{
                let inputfield = layoutItem.querySelector('.is-hide');
                if(inputfield){
                    console.log('DK layoutItem inputfield.style.display',inputfield.name, inputfield.style.display);
                }
                layoutItem.style.display = inputfield ? inputfield.style.display : 'none';
            })
            this.extendLinea();
            console.log('DK renderedCallback STEP ', JSON.stringify(this.lineaSimulazione));
            console.log('DK CHECK CAMPI END', this.periodiErogazione.length);
            if(!this.loaded){
                this.loaded = true;
            }
            console.log('DK changedSezioni_FINAL', changedSezioni);
            this.hanldeRender = changedSezioni;
        }
    }
    handleOnKeyUp(event){
        console.log('DK START handleOnKeyUp');
        try {
            
            console.log('DK handleOnKeyUp START', event.target.name.split('#')[0]);
            let fieldToCheck = event.target.name.split('#')[0];
            let finalValue = !(event.target.type == 'checkbox' ? event.target.checked :
            event.target.type == 'number' ? Number(event.target.value) : ['true', 'false'].includes(event.target.value) ? /^true$/i.test(event.target.value) : event.target.value);
            
            console.log('DK finalValue', finalValue);
            console.log('DK this.lineaSimulazione.Preammortamento__c', this.lineaSimulazione.Preammortamento__c);
            if(fieldToCheck === 'SAL__c'){
                if(finalValue && (this.lineaSimulazione.Preammortamento__c != 0 && this.lineaSimulazione.Preammortamento__c != '' && this.lineaSimulazione.Preammortamento__c != null)){
                    event.preventDefault();
                    event.stopPropagation();
                    const toastEvent = new ShowToastEvent({
                        title: "Attenzione!",
                        message: 'Non è possibile valorizzare SAL a "SI" perchè Preammortamento è valorizzato',
                        variant: "warning"
                    });
                    this.dispatchEvent(toastEvent);
                }
                if(!finalValue && (this.lineaSimulazione.Preammortamento__c == 0 || this.lineaSimulazione.Preammortamento__c == '' || this.lineaSimulazione.Preammortamento__c == null)){
                    event.preventDefault();
                    event.stopPropagation();
                    const toastEvent = new ShowToastEvent({
                        title: "Attenzione!",
                        message: 'Non è possibile valorizzare SAL a "NO" perchè Preammortamento non è valorizzato',
                        variant: "warning"
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
        } catch (error) {
            console.log('DK CibLineaSimulazione handleOnKeyUp error: ',error);
        }
    }

    fieldToCheck;
    handleFilter(event){
        console.log('DK START handleFilter');
        try {
            
            console.log('DK fieldAbilitySet START', event.target.name.split('#')[0]);
            this.lineaSimulazione = JSON.parse(JSON.stringify(this.lineaSimulazione));
            this.fieldToCheck = event.target.name.split('#')[0];
            let initialValue = this.lineaSimulazione[this.fieldToCheck];
            let finalValue = event.target.type == 'checkbox' ? event.target.checked :
            event.target.type == 'number' ? Number(event.target.value) : ['true', 'false'].includes(event.target.value) ? /^true$/i.test(event.target.value) : event.target.value;
            
            let changedValue = event.target && this.fieldToCheck && initialValue != finalValue;
            
            this.lineaSimulazione[this.fieldToCheck] = finalValue;

            if(this.fieldToCheck === 'Formatecnica__c'){
                if(this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('fideiussioni')){
                    this.lineaSimulazione.Utilizzo__c = '1';
                    console.log('DK Changed to fideiussioni, ', this.lineaSimulazione.Utilizzo__c);
                    this.lineaSimulazione.Valuta__c = 'EUR';
                    this.lineaSimulazione.Tipo_di_ammortamento__c = 'bullet';
                    this.lineaSimulazione.Tipo_funding__c = 'No Funding';
                }else if(this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('mlt') || this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('loan')){
                    console.log('DK Changed to mlt || loan');
                    this.lineaSimulazione.Valuta__c = 'EUR';
                    this.lineaSimulazione.Tipo_di_ammortamento__c = 'bullet';
                    this.lineaSimulazione.Utilizzo__c = '0.50';
                    this.lineaSimulazione.Tipo_funding__c = 'Blended';
                }
                console.log('DK handleFilter Formatecnica__c lineaSimulazione', JSON.stringify(this.lineaSimulazione));
            }
            /*if(this.fieldToCheck === 'Preammortamento__c'){
                this.lineaSimulazione.SAL__c = !Boolean(this.lineaSimulazione[this.fieldToCheck]);
            }*/
            
            if(this.fieldToCheck === 'SAL__c' && this.lineaSimulazione.SAL__c === false){
                console.log('DK modifica sal - false');
                this.periodiErogazione = [];
            }
            if(this.fieldToCheck === 'UpFrontValorePerc__c'){
                if(this.lineaSimulazione.UpFrontValorePerc__c){
                    this.lineaSimulazione.Up_Front__c = 0;
                }else{
                    this.lineaSimulazione.Up_Front_perc__c = 0;
                }
            }
            if(this.fieldToCheck === 'RunningValorePerc__c'){
                if(this.lineaSimulazione.RunningValorePerc__c){
                    this.lineaSimulazione.Commissione_running_annuale__c = 0;
                    this.lineaSimulazione.Commissione_running_periodale__c = 0;
                }else{
                    this.lineaSimulazione.Commissione_running_annuale_perc__c = 0;
                    this.lineaSimulazione.Tasso_running_periodale__c = 0;
                }
            }
            if(this.fieldToCheck === 'AltroValorePerc__c'){
                if(this.lineaSimulazione.AltroValorePerc__c){
                    this.lineaSimulazione.Altro_es_derivato_perc__c = 0;
                }else{
                    this.lineaSimulazione.Altroesderivato__c = 0;
                }
            }
            this.extendLinea();
            if(this.fieldToCheck === 'Intereststep__c'){
                if(this.lineaSimulazione.Intereststep__c === true && this.interestStepTassoFisso.length === 0){
                    let nowId = this.makeId()
                    this.interestStepTassoFisso.push({
                        number: 'interestStepTassoFisso-' + nowId,
                        Linea__c: this.lineaSimulazione.Id,
                        numberLinea: this.lineaSimulazione.Number__c, 
                        Type__c: 'Interest Step Tasso Fisso', 
                        Numerorata__c: 1, 
                        Delta_Spread__c: 0,
                        key: nowId
                        // Periodicitcorrispondente__c: 1 + '° ' + this.periodicitaRataTextValueMap[this.lineaSimulazione.Periodicita_rata__c],
                        // Numeroanniequivalenti__c: 1 / this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c],
                    });
                }else if(this.lineaSimulazione.Intereststep__c === false){
                    this.interestStepTassoFisso = [];
                }
            }

            if(this.fieldToCheck === 'Tipo_tasso__c'){
                this.lineaSimulazione.Intereststep__c = false;
                this.interestStepTassoFisso = [];
            }

            if(this.fieldToCheck === 'IntereststepCF__c'){
                if(this.lineaSimulazione.IntereststepCF__c === true && this.interestStepCommissioneFirma.length === 0){
                    let nowId = this.makeId()
                    this.interestStepCommissioneFirma.push({
                        number: 'interestStepCommissioneFirma-' + nowId,
                        Linea__c: this.lineaSimulazione.Id,
                        numberLinea: this.lineaSimulazione.Number__c, 
                        Type__c: 'Interest Step Commissione Firma', 
                        Numerorata__c: 1, 
                        Delta_Spread__c: 0,
                        key: nowId
                        // Periodicitcorrispondente__c: 1 + '° ' + this.periodicitaRataTextValueMap[this.lineaSimulazione.Periodicita_rata__c],
                        // Numeroanniequivalenti__c: 1 / this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c],
                    });
                }else if(this.lineaSimulazione.IntereststepCF__c === false){
                    this.interestStepCommissioneFirma = [];
                }
            }

            if(this.fieldToCheck === 'Tipo_di_ammortamento__c' || this.fieldToCheck === 'Importo__c'){
                if(!this.lineaSimulazione.Importo__c && this.lineaSimulazione.Tipo_di_ammortamento__c === 'ad_hoc'){

                    event.target.setCustomValidity('Valorizzare "Importo" prima di "Tipo di ammortamento"');
                    event.target.reportValidity();
                    
                    let inputField = this.fieldToCheck === 'Tipo_di_ammortamento__c' ? this.template.querySelector('[data-name="Importo__c"]') : this.template.querySelector('[data-name="Tipo_di_ammortamento__c"]');
                    inputField.setCustomValidity('Valorizzare "Importo" prima di "Tipo di ammortamento"');
                    inputField.reportValidity();
                }else{
                    event.target.setCustomValidity('');
                    event.target.reportValidity();
                    
                    let inputField = this.fieldToCheck === 'Tipo_di_ammortamento__c' ? this.template.querySelector('[data-name="Importo__c"]') : this.template.querySelector('[data-name="Tipo_di_ammortamento__c"]');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            }

            if((this.fieldToCheck === 'Tipo_di_ammortamento__c' || this.fieldToCheck === 'Formatecnica__c' || this.fieldToCheck === 'Durata__c' || this.fieldToCheck === 'Periodicita_rata__c' || this.fieldToCheck === 'Importo__c')){
                console.log('DK CHECK AD HOC: ', this.lineaSimulazione.Tipo_di_ammortamento__c, this.lineaSimulazione.Importo__c, this.ammortamentoAdHoc.length);
                if(this.lineaSimulazione.Tipo_di_ammortamento__c !== 'ad_hoc'){
                    this.ammortamentoAdHoc = [];
                }else if(this.ammortamentoAdHoc.length === 0 && this.lineaSimulazione.Importo__c > 0){
                    console.log('IS AD HOC');
                    if(this.lineaSimulazione.Numerodirate__c){
                        this.ammortamentoAdHoc = [];
                        for(let i = 1; i <= this.lineaSimulazione.Numerodirate__c; i++){
    
                            let nowId = this.makeId()
                            let ammortamentoAdHocEl = {
            
                                number: 'ammortamentoAdHoc-' + nowId,
                                Linea__c: this.lineaSimulazione.Id,
                                numberLinea: this.lineaSimulazione.Number__c, 
                                Type__c: 'Piano Ammortamento', 
                                ProgrPeriodo__c: i, 
                                PercNonutilizzato__c:100,
                                Nonutilizzato__c:this.lineaSimulazione.Importo__c,
                                percentualeUtilizzoAmmortamento__c: 0,
                                QuotaCapitaleUtilizzato__c: 0,
                                QuotaCapAmmortamento__c: 0,
                                quotaCapitaleResiduaAmmortamento__c: 0,
                                key: nowId,
                            };
                            
                            ammortamentoAdHocEl.Riferimentoanno__c = Math.ceil(ammortamentoAdHocEl.ProgrPeriodo__c/this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]);
                            ammortamentoAdHocEl.Numeroperiodonellanno__c = ammortamentoAdHocEl.ProgrPeriodo__c % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c] !== 0 ? ammortamentoAdHocEl.ProgrPeriodo__c % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c] : (ammortamentoAdHocEl.ProgrPeriodo__c % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]) + this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c];
                            this.ammortamentoAdHoc.push(ammortamentoAdHocEl);
                        }
                        for(var i = 1; i < this.ammortamentoAdHoc.length; i++){
                            // this.ammortamentoAdHoc[i]['PercNonutilizzato__c'] = this.ammortamentoAdHoc[i-1]['PercNonutilizzato__c'] - this.ammortamentoAdHoc[i]['percentualeUtilizzoAmmortamento__c'];
                            this.ammortamentoAdHoc[i]['PercNonutilizzato__c'] = 100 - this.ammortamentoAdHoc[i]['percentualeUtilizzoAmmortamento__c'];
                            this.ammortamentoAdHoc[i]['Nonutilizzato__c'] = (this.ammortamentoAdHoc[i-1]['Nonutilizzato__c'] + this.ammortamentoAdHoc[i-1]['quotaCapitaleResiduaAmmortamento__c'])*(this.ammortamentoAdHoc[i]['PercNonutilizzato__c']/100)
                            this.ammortamentoAdHoc[i]['QuotaCapitaleUtilizzato__c'] = (this.ammortamentoAdHoc[i-1]['Nonutilizzato__c'] + this.ammortamentoAdHoc[i-1]['quotaCapitaleResiduaAmmortamento__c'])*(this.ammortamentoAdHoc[i]['percentualeUtilizzoAmmortamento__c']/100)
                            this.ammortamentoAdHoc[i]['quotaCapitaleResiduaAmmortamento__c'] = this.ammortamentoAdHoc[i]['QuotaCapitaleUtilizzato__c'] - this.ammortamentoAdHoc[i]['QuotaCapAmmortamento__c'];
                        }
                    }else{
                        this.ammortamentoAdHoc = [];
                    }
                }else if((this.lineaSimulazione.Numerodirate__c && this.ammortamentoAdHoc.length > this.lineaSimulazione.Numerodirate__c)){
                    do {
                        this.ammortamentoAdHoc.pop();
                    } while (this.ammortamentoAdHoc.length > this.lineaSimulazione.Numerodirate__c);
                }else if((this.lineaSimulazione.Numerodirate__c && this.ammortamentoAdHoc.length < this.lineaSimulazione.Numerodirate__c) && this.lineaSimulazione.Importo__c > 0){
                    let i = this.ammortamentoAdHoc.length + 1;
                    do {
                        let nowId = this.makeId()
                        let ammortamentoAdHocEl = {
        
                            number: 'ammortamentoAdHoc-' + nowId,
                            Linea__c: this.lineaSimulazione.Id,
                            numberLinea: this.lineaSimulazione.Number__c, 
                            Type__c: 'Piano Ammortamento', 
                            ProgrPeriodo__c: i, 
                            PercNonutilizzato__c:100,
                            Nonutilizzato__c:this.lineaSimulazione.Importo__c,
                            percentualeUtilizzoAmmortamento__c: 0,
                            QuotaCapitaleUtilizzato__c: 0,
                            QuotaCapAmmortamento__c: 0,
                            quotaCapitaleResiduaAmmortamento__c: 0,
                            key: nowId,
                        };
                        
                        ammortamentoAdHocEl.Riferimentoanno__c = Math.ceil(ammortamentoAdHocEl.ProgrPeriodo__c/this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]);
                        ammortamentoAdHocEl.Numeroperiodonellanno__c = ammortamentoAdHocEl.ProgrPeriodo__c % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c] !== 0 ? ammortamentoAdHocEl.ProgrPeriodo__c % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c] : (ammortamentoAdHocEl.ProgrPeriodo__c % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]) + this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c];
                        this.ammortamentoAdHoc.push(ammortamentoAdHocEl);
                        i++;
                    } while (this.ammortamentoAdHoc.length < this.lineaSimulazione.Numerodirate__c);
                }

                if(this.ammortamentoAdHoc && this.ammortamentoAdHoc.length > 0){
                    for(let i = 0; i < this.ammortamentoAdHoc.length; i++){
                        this.ammortamentoAdHoc[i].Riferimentoanno__c = Math.ceil(this.ammortamentoAdHoc[i].ProgrPeriodo__c/this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]);
                        this.ammortamentoAdHoc[i].Numeroperiodonellanno__c = this.ammortamentoAdHoc[i].ProgrPeriodo__c % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c] !== 0 ? this.ammortamentoAdHoc[i].ProgrPeriodo__c % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c] : (this.ammortamentoAdHoc[i].ProgrPeriodo__c % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]) + this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c];
                        if(this.fieldToCheck === 'Importo__c'){
                            // this.ammortamentoAdHoc[i]['PercNonutilizzato__c'] = i == 0 ? 100 - this[keyList[0]][0]['percentualeUtilizzoAmmortamento__c'] : ;
                            this.ammortamentoAdHoc[i]['Nonutilizzato__c'] = i == 0 ? this.lineaSimulazione.Importo__c * (this.ammortamentoAdHoc[i]['PercNonutilizzato__c']/100) : (this.ammortamentoAdHoc[i-1]['Nonutilizzato__c'] + this.ammortamentoAdHoc[i-1]['quotaCapitaleResiduaAmmortamento__c'])*(this.ammortamentoAdHoc[i]['PercNonutilizzato__c']/100)
                        }
                    }
                }
            }
            if((this.fieldToCheck === 'Numero_periodi_di_erogazione__c') && changedValue){
                if(this.lineaSimulazione.SAL__c && this.lineaSimulazione.Numero_periodi_di_erogazione__c && this.lineaSimulazione.Numero_periodi_di_erogazione__c > 0){

                    let localPeriodiErogazione = [];
                    let currentPeriodiErogazioneMap = new Map();
                    console.log('STEP 1', JSON.stringify(this.lineaSimulazione.periodiErogazione));
                    /*if(this.lineaSimulazione.periodiErogazione){
                        this.lineaSimulazione.periodiErogazione.forEach(element =>{
                            currentPeriodiErogazioneMap.set(element.Numerorata__c, element);
                        })
                    }*/
                    if(this.periodiErogazione){
                        this.periodiErogazione.forEach(element =>{
                            currentPeriodiErogazioneMap.set(element.Numerorata__c, element);
                        })
                    }
                    console.log('STEP 2');
                    for(var i=1; i<=this.lineaSimulazione.Numero_periodi_di_erogazione__c; i++){
                        let nowId = this.makeId();
                        let newPeriodoErogazione = currentPeriodiErogazioneMap.has(i) ? currentPeriodiErogazioneMap.get(i) :
                        {
                            number: 'periodiErogazione-' + nowId,
                            Linea__c: this.lineaSimulazione.Id,
                            numberLinea: this.lineaSimulazione.Number__c, 
                            Type__c: 'Periodo Erogazione', 
                            Numerorata__c: null, 
                            Erogato__c: 0,
                            key: nowId
                        };
                        // newPeriodoErogazione.Periododierogazionifondi__c= i + '° ' + this.periodicitaRataTextValueMap[this.lineaSimulazione.Periodicita_rata__c], 
                        // newPeriodoErogazione.Numeroanniequivalenti__c= i / this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]
                        localPeriodiErogazione.push(newPeriodoErogazione);
                    }
                    this.periodiErogazione = localPeriodiErogazione;
                }

                if(this.lineaSimulazione.Intereststep__c && this.interestStepTassoFisso && this.interestStepTassoFisso.length > 0){
                    this.interestStepTassoFisso.forEach(element =>{
                        if(element.Ratacorrispondentemodificatasso__c){
                            element.Periodicitcorrispondente__c = element.Ratacorrispondentemodificatasso__c + '° ' + this.periodicitaRataTextValueMap[this.lineaSimulazione.Periodicita_rata__c]
                            element.Numeroanniequivalenti__c = element.Ratacorrispondentemodificatasso__c / this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]
                        }
                    })
                }

                if(this.lineaSimulazione.IntereststepCF__c && this.interestStepCommissioneFirma && this.interestStepCommissioneFirma.length > 0){
                    this.interestStepCommissioneFirma.forEach(element =>{
                        if(element.Ratacorrispondentemodificatasso__c){
                            element.Periodicitcorrispondente__c = element.Ratacorrispondentemodificatasso__c + '° ' + this.periodicitaRataTextValueMap[this.lineaSimulazione.Periodicita_rata__c]
                            element.Numeroanniequivalenti__c = element.Ratacorrispondentemodificatasso__c / this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]
                        }
                    })
                }
            }

            if(this.fieldToCheck === 'Durata__c' || this.fieldToCheck === 'Periodicita_rata__c'){
                if(this.lineaSimulazione.SAL__c === true){
                    this.periodiErogazione = [];
                    this.lineaSimulazione.Numero_periodi_di_erogazione__c = 0;
                }
                if(!this.lineaSimulazione.Numerodirate__c && this.lineaSimulazione.Durata__c && this.lineaSimulazione.Periodicita_rata__c){
                    event.target.setCustomValidity('Questa combinazione di "Durata" e "Periodicità Rata" non è corretta.');
                    event.target.reportValidity();
                    
                    let inputField = this.fieldToCheck === 'Durata__c' ? this.template.querySelector('[data-name="Periodicita_rata__c"]') : this.template.querySelector('[data-name="Durata__c"]');
                    inputField.setCustomValidity('Questa combinazione di "Durata" e "Periodicità Rata" non è corretta.');
                    inputField.reportValidity();
                }else if(this.lineaSimulazione.Numerodirate__c && this.lineaSimulazione.Durata__c && this.lineaSimulazione.Periodicita_rata__c){
                    event.target.setCustomValidity('');
                    event.target.reportValidity();

                    let inputField = this.fieldToCheck === 'Durata__c' ? this.template.querySelector('[data-name="Periodicita_rata__c"]') : this.template.querySelector('[data-name="Durata__c"]');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            }
            console.log('DK END handleFilter lineaSimulazione', JSON.stringify(this.lineaSimulazione));
            this.hanldeRender = true;
        } catch (error) {
            console.log('DK CibLineaSimulazione handleFilter error: ',error.message);
        }
    }
    hanldeRender = false;
    handleAddISTF(){
        let length = this.interestStepTassoFisso.length;
        if(length < 5){
            let nowId = this.makeId()
            this.interestStepTassoFisso.push({
                number: 'interestStepTassoFisso-' + nowId,
                Linea__c: this.lineaSimulazione.Id,
                numberLinea: this.lineaSimulazione.Number__c, 
                Type__c: 'Interest Step Tasso Fisso', 
                Delta_Spread__c: 0,
                key: nowId
            });
        }else{
            const toastEvent = new ShowToastEvent({
                title: "Attenzione!",
                message: 'Raggiunto numero massimo di elementi',
                variant: "warning"
            });
            this.dispatchEvent(toastEvent);
        }
    }

    handleAddCF(){
        let length = this.interestStepCommissioneFirma.length;
        if(length < 5){
            let nowId = this.makeId()
            this.interestStepCommissioneFirma.push({
                number: 'interestStepCommissioneFirma-' + nowId,
                Linea__c: this.lineaSimulazione.Id,
                numberLinea: this.lineaSimulazione.Number__c, 
                Type__c: 'Interest Step Commissione Firma', 
                Delta_Spread__c: 0,
                key: nowId
            });
        }else{
            const toastEvent = new ShowToastEvent({
                title: "Attenzione!",
                message: 'Raggiunto numero massimo di elementi',
                variant: "warning"
            });
            this.dispatchEvent(toastEvent);
        }
    }

    handleAddAM(){
        let length = this.ammortamentoAdHoc.length;
        let nowId = this.makeId();
        this.ammortamentoAdHoc.push({
            number: 'ammortamentoAdHoc-' + nowId,
            Linea__c: this.lineaSimulazione.Id,
            numberLinea: this.lineaSimulazione.Number__c, 
            Type__c: 'Piano Ammortamento', 
            ProgrPeriodo__c: length+1,
            Riferimentoanno__c: Math.ceil((length+1)/this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]),
            Numeroperiodonellanno__c: (length+1) % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c] !== 0 ? (length+1) % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c] : ((length+1) % this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]) + this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c],
            PercNonutilizzato__c:100,
            Nonutilizzato__c:this.lineaSimulazione.Importo__c,
            percentualeUtilizzoAmmortamento__c: 0,
            QuotaCapitaleUtilizzato__c: 0,
            QuotaCapAmmortamento__c: 0,
            quotaCapitaleResiduaAmmortamento__c: 0,
            key: nowId,
        });
        for(var i = 1; i < this.ammortamentoAdHoc.length; i++){
            // this.ammortamentoAdHoc[i]['PercNonutilizzato__c'] = this.ammortamentoAdHoc[i-1]['PercNonutilizzato__c'] - this.ammortamentoAdHoc[i]['percentualeUtilizzoAmmortamento__c'];
            this.ammortamentoAdHoc[i]['PercNonutilizzato__c'] = 100 - this.ammortamentoAdHoc[i]['percentualeUtilizzoAmmortamento__c'];
            this.ammortamentoAdHoc[i]['Nonutilizzato__c'] = (this.ammortamentoAdHoc[i-1]['Nonutilizzato__c'] + this.ammortamentoAdHoc[i-1]['quotaCapitaleResiduaAmmortamento__c'])*(this.ammortamentoAdHoc[i]['PercNonutilizzato__c']/100)
            this.ammortamentoAdHoc[i]['QuotaCapitaleUtilizzato__c'] = (this.ammortamentoAdHoc[i-1]['Nonutilizzato__c'] + this.ammortamentoAdHoc[i-1]['quotaCapitaleResiduaAmmortamento__c'])*(this.ammortamentoAdHoc[i]['percentualeUtilizzoAmmortamento__c']/100)
            this.ammortamentoAdHoc[i]['quotaCapitaleResiduaAmmortamento__c'] = this.ammortamentoAdHoc[i]['QuotaCapitaleUtilizzato__c'] - this.ammortamentoAdHoc[i]['QuotaCapAmmortamento__c'];
        }
    }

    handleRemoveISTF(){
        let changedInput = event.target;
        console.log('DK event changedInput', changedInput.dataset.key);
        let keyList = changedInput.dataset.key.split('-');
        const currentRata = (element) => element.key == keyList[1];
        let index = this[keyList[0]].findIndex(currentRata);
        console.log('Dk index', JSON.stringify(this.interestStepTassoFisso[index]));
        this.interestStepTassoFisso = this.interestStepTassoFisso.filter(element =>{return element.key != keyList[1]});
        this.interestStepTassoFisso.forEach(element =>{
            if(element.Ratacorrispondentemodificatasso__c){
                element.Periodicitcorrispondente__c = element.Ratacorrispondentemodificatasso__c + '° ' + this.periodicitaRataTextValueMap[this.lineaSimulazione.Periodicita_rata__c]
                element.Numeroanniequivalenti__c = element.Ratacorrispondentemodificatasso__c / this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]
            }
        })
    }

    handleRemoveISCF(){
        let changedInput = event.target;
        console.log('DK event changedInput', changedInput.dataset.key);
        let keyList = changedInput.dataset.key.split('-');
        const currentRata = (element) => element.key == keyList[1];
        let index = this[keyList[0]].findIndex(currentRata);
        console.log('Dk index', JSON.stringify(this.interestStepCommissioneFirma[index]));
        this.interestStepCommissioneFirma = this.interestStepCommissioneFirma.filter(element =>{return element.key != keyList[1]});
        this.interestStepCommissioneFirma.forEach(element =>{
            if(element.Ratacorrispondentemodificatasso__c){
                element.Periodicitcorrispondente__c = element.Ratacorrispondentemodificatasso__c + '° ' + this.periodicitaRataTextValueMap[this.lineaSimulazione.Periodicita_rata__c]
                element.Numeroanniequivalenti__c = element.Ratacorrispondentemodificatasso__c / this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]
            }
        })
    }

    /*handleRemoveAM(event){
        let changedInput = event.target;
        console.log('DK event changedInput', changedInput.dataset.key);
        let keyList = changedInput.dataset.key.split('-');
        const currentRata = (element) => element.key == keyList[1];
        let index = this[keyList[0]].findIndex(currentRata);
        console.log('Dk index', JSON.stringify(this.ammortamentoAdHoc[index]));
        this.ammortamentoAdHoc = this.ammortamentoAdHoc.filter(element =>{return element.key != keyList[1]});
        if(this.ammortamentoAdHoc.length > 0){
            this[keyList[0]][0]['PercNonutilizzato__c'] = 100 - this[keyList[0]][0]['percentualeUtilizzoAmmortamento__c'];
            this[keyList[0]][0]['Nonutilizzato__c'] = this.lineaSimulazione.Importo__c * (this[keyList[0]][0]['PercNonutilizzato__c']/100);
            this[keyList[0]][0]['QuotaCapitaleUtilizzato__c'] = this.lineaSimulazione.Importo__c - this[keyList[0]][0]['Nonutilizzato__c'];
            this[keyList[0]][0]['quotaCapitaleResiduaAmmortamento__c'] = this[keyList[0]][0]['QuotaCapitaleUtilizzato__c'] - this[keyList[0]][0]['QuotaCapAmmortamento__c'];
            for(var i = 1; i < this.ammortamentoAdHoc.length; i++){
                console.log('Dk i-1', i-1);
                // this[keyList[0]][i]['PercNonutilizzato__c'] = this[keyList[0]][i-1]['PercNonutilizzato__c'] - this[keyList[0]][i]['percentualeUtilizzoAmmortamento__c'];
                this[keyList[0]][i]['PercNonutilizzato__c'] = 100 - this[keyList[0]][i]['percentualeUtilizzoAmmortamento__c'];
                this[keyList[0]][i]['Nonutilizzato__c'] = (this[keyList[0]][i-1]['Nonutilizzato__c'] + this[keyList[0]][i-1]['quotaCapitaleResiduaAmmortamento__c'])*(this[keyList[0]][i]['PercNonutilizzato__c']/100)
                this[keyList[0]][i]['QuotaCapitaleUtilizzato__c'] = (this[keyList[0]][i-1]['Nonutilizzato__c'] + this[keyList[0]][i-1]['quotaCapitaleResiduaAmmortamento__c'])*(this[keyList[0]][i]['percentualeUtilizzoAmmortamento__c']/100)
                this[keyList[0]][i]['quotaCapitaleResiduaAmmortamento__c'] = this[keyList[0]][i]['QuotaCapitaleUtilizzato__c'] - this[keyList[0]][i]['QuotaCapAmmortamento__c'];
            }
        }
    }*/

    handleCopyValues(event){
        let changedInput = event.target;
        console.log('DK event changedInput', changedInput.dataset.key);
        let keyList = changedInput.dataset.key.split('-');
        const currentRata = (element) => element.key == keyList[1];
        let index = this[keyList[0]].findIndex(currentRata);
        console.log('Dk index', JSON.stringify(this.ammortamentoAdHoc[index]));
        if(this.ammortamentoAdHoc[index+1]){
            this.ammortamentoAdHoc[index+1].percentualeUtilizzoAmmortamento__c = this.ammortamentoAdHoc[index].percentualeUtilizzoAmmortamento__c;
            this.ammortamentoAdHoc[index+1].QuotaCapAmmortamento__c = this.ammortamentoAdHoc[index].QuotaCapAmmortamento__c;
            if(this.ammortamentoAdHoc.length > 0){
                this.ammortamentoAdHoc[0]['PercNonutilizzato__c'] = 100 - this.ammortamentoAdHoc[0]['percentualeUtilizzoAmmortamento__c'];
                this.ammortamentoAdHoc[0]['Nonutilizzato__c'] = this.lineaSimulazione.Importo__c * (this.ammortamentoAdHoc[0]['PercNonutilizzato__c']/100);
                this.ammortamentoAdHoc[0]['QuotaCapitaleUtilizzato__c'] = this.lineaSimulazione.Importo__c - this.ammortamentoAdHoc[0]['Nonutilizzato__c'];
                this.ammortamentoAdHoc[0]['quotaCapitaleResiduaAmmortamento__c'] = this.ammortamentoAdHoc[0]['QuotaCapitaleUtilizzato__c'] - this.ammortamentoAdHoc[0]['QuotaCapAmmortamento__c'];
                for(var i = 1; i < this.ammortamentoAdHoc.length; i++){
                    console.log('Dk i-1', i-1);
                    // this.ammortamentoAdHoc[i]['PercNonutilizzato__c'] = this.ammortamentoAdHoc[i-1]['PercNonutilizzato__c'] - this.ammortamentoAdHoc[i]['percentualeUtilizzoAmmortamento__c'];
                    this.ammortamentoAdHoc[i]['PercNonutilizzato__c'] = 100 - this.ammortamentoAdHoc[i]['percentualeUtilizzoAmmortamento__c'];
                    this.ammortamentoAdHoc[i]['Nonutilizzato__c'] = (this.ammortamentoAdHoc[i-1]['Nonutilizzato__c'] + this.ammortamentoAdHoc[i-1]['quotaCapitaleResiduaAmmortamento__c'])*(this.ammortamentoAdHoc[i]['PercNonutilizzato__c']/100)
                    this.ammortamentoAdHoc[i]['QuotaCapitaleUtilizzato__c'] = (this.ammortamentoAdHoc[i-1]['Nonutilizzato__c'] + this.ammortamentoAdHoc[i-1]['quotaCapitaleResiduaAmmortamento__c'])*(this.ammortamentoAdHoc[i]['percentualeUtilizzoAmmortamento__c']/100)
                    this.ammortamentoAdHoc[i]['quotaCapitaleResiduaAmmortamento__c'] = this.ammortamentoAdHoc[i]['QuotaCapitaleUtilizzato__c'] - this.ammortamentoAdHoc[i]['QuotaCapAmmortamento__c'];
                }
            }
        }
    }

    makeId() {
        return Math.floor(Math.random() * Date.now())
    }

    handleFilterRata(event){
        try {
            let changedInput = event.target;
            console.log('DK event changedInput', changedInput.dataset.key);
            let keyList = changedInput.dataset.key.split('-');
            const currentRata = (element) => element.key == keyList[1];
            let index = this[keyList[0]].findIndex(currentRata);
            console.log('Dk index', index);
            // let index = this[keyList[0]].indexOf(this[keyList[0]].filter(element =>{return element.key === changedInput.dataset.key}));
            this[keyList[0]][index][event.target.name.split('#')[0]] = event.target.type == 'checkbox' ? event.target.checked :
            event.target.type == 'number' ? Number(event.target.value) : ['true', 'false'].includes(event.target.value) ? /^true$/i.test(event.target.value) : event.target.value;
            
            if(event.target.name.split('#')[0] === 'Erogato__c'){
                console.log('DK handleFilterRata field Erogato__c');
                if(index === 0){
                    if(this[keyList[0]][index][event.target.name.split('#')[0]] > this.lineaSimulazione.Importo__c){
                        console.log('Dk handleFilterRata Erogato Il valore di Erogato della prima riga non può superare l\'importo totale della linea');
                        event.target.setCustomValidity('Il valore di Erogato della prima riga non può superare l\'importo totale della linea');
                        event.target.reportValidity();
                    }else{
                        event.target.setCustomValidity('');
                        event.target.reportValidity();
                    }
                }else if(index > 0){
                    let sumErogato = 0;
                    for(let i = 0; i <= index; i++){
                        sumErogato += this[keyList[0]][i]['Erogato__c'];
                    }
                    if(sumErogato > this.lineaSimulazione.Importo__c){
                        console.log('Dk handleFilterRata Erogato La somma dei valori indicati per Erogato non può superare l\'importo totale della linea');
                        event.target.setCustomValidity('La somma dei valori indicati per Erogato non può superare l\'importo totale della linea');
                        event.target.reportValidity();
                    }else{
                        event.target.setCustomValidity('');
                        event.target.reportValidity();
                    }
                }
            }else if(event.target.name.split('#')[0] === 'Numerorata__c'){
                console.log('DK handleFilterRata field Numerorata__c');
                this[keyList[0]][index]['Periododierogazionifondi__c'] = this[keyList[0]][index]['Numerorata__c'] + '° ' + this.periodicitaRataTextValueMap[this.lineaSimulazione.Periodicita_rata__c];
                this[keyList[0]][index]['Numeroanniequivalenti__c'] = this[keyList[0]][index]['Numerorata__c'] / this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c];

                if(index > 0 && this[keyList[0]][index]['Numerorata__c'] < this[keyList[0]][index-1]['Numerorata__c']){
                    event.target.setCustomValidity('"Numero rata" non può essere minore del "Numero Rata" della riga precedente');
                    event.target.reportValidity();
                }else if(index > 0 && this[keyList[0]].filter(element => {return element.number != this[keyList[0]][index]['number'];}).map(element => element.Numerorata__c).includes(this[keyList[0]][index]['Numerorata__c'])){
                    event.target.setCustomValidity('Presente riga con stesso valore');
                    event.target.reportValidity();
                }else{
                    event.target.setCustomValidity('');
                    event.target.reportValidity();
                }
            }else if(event.target.name.split('#')[0] === 'Ratacorrispondentemodificatasso__c'){
                console.log('DK handleFilterRata field Ratacorrispondentemodificatasso__c');
                this[keyList[0]][index]['Periodicitcorrispondente__c'] = this[keyList[0]][index][event.target.name.split('#')[0]] + '° ' + this.periodicitaRataTextValueMap[this.lineaSimulazione.Periodicita_rata__c]
                this[keyList[0]][index]['Numeroanniequivalenti__c'] = this[keyList[0]][index][event.target.name.split('#')[0]] / this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c]
                
                if(index > 0 && this[keyList[0]][index]['Ratacorrispondentemodificatasso__c'] < this[keyList[0]][index-1]['Ratacorrispondentemodificatasso__c']){
                    event.target.setCustomValidity('"Rata corrispondente modifica tasso" non può essere minore del "Rata corrispondente modifica tasso" della riga precedente');
                    event.target.reportValidity();
                }else if(index > 0 && this[keyList[0]].filter(element => {return element.number != this[keyList[0]][index]['number'];}).map(element => element.Ratacorrispondentemodificatasso__c).includes(this[keyList[0]][index]['Ratacorrispondentemodificatasso__c'])){
                    event.target.setCustomValidity('Presente riga con stesso valore');
                    event.target.reportValidity();
                }else{
                    event.target.setCustomValidity('');
                    event.target.reportValidity();
                }
            }else if(event.target.name.split('#')[0] === 'Delta_Spread__c'){
                console.log('DK handleFilterRata field Delta_Spread__c');
                if(((this.lineaSimulazione.Tipo_tasso__c == 'FISSO' ? this.lineaSimulazione.tassoFisso__c : this.lineaSimulazione.Spread__c) + this[keyList[0]].reduce((accumulator, element) => accumulator + element.Delta_Spread__c, 0)) < 0){
                    event.target.setCustomValidity('La somma tra ' + (this.lineaSimulazione.Tipo_tasso__c == 'FISSO' ? '"Tasso Fisso %"' : 'Spread variabile %') + ' ed i "Delta Tasso Spread %" non pùò essere inferiore a 0');
                    event.target.reportValidity();
                }else{
                    this.template.querySelectorAll('.validateRataLineaDelta').forEach(inputField =>{
                        inputField.setCustomValidity('');
                        inputField.reportValidity();
                    })
                }
            }else if(event.target.name.split('#')[0] === 'percentualeUtilizzoAmmortamento__c' || event.target.name.split('#')[0] === 'QuotaCapAmmortamento__c'){
                console.log('DK handleFilterRata field percentualeUtilizzoAmmortamento__c || QuotaCapAmmortamento__c');
                let numberSet = this[keyList[0]].map(element => element.number);
                let numberInvalidFieldMap = {};
                this[keyList[0]][index]['PercNonutilizzato__c'] = 100 - this[keyList[0]][index]['percentualeUtilizzoAmmortamento__c'];
                if(index === 0){
                    this[keyList[0]][index]['Nonutilizzato__c'] = this.lineaSimulazione.Importo__c * (this[keyList[0]][index]['PercNonutilizzato__c']/100);
                    this[keyList[0]][index]['QuotaCapitaleUtilizzato__c'] = this.lineaSimulazione.Importo__c - this[keyList[0]][index]['Nonutilizzato__c'];
                    this[keyList[0]][index]['quotaCapitaleResiduaAmmortamento__c'] = this[keyList[0]][index]['QuotaCapitaleUtilizzato__c'] - this[keyList[0]][index]['QuotaCapAmmortamento__c'];
                    if(this[keyList[0]][index]['quotaCapitaleResiduaAmmortamento__c'] < 0){
                        if(!numberInvalidFieldMap[this[keyList[0]][index]['number']])numberInvalidFieldMap[this[keyList[0]][index]['number']] = {};
                        numberInvalidFieldMap[this[keyList[0]][index]['number']]['QuotaCapAmmortamento__c'] = 'Q. Cap residua non può essere negativo';
                        numberInvalidFieldMap[this[keyList[0]][index]['number']]['percentualeUtilizzoAmmortamento__c'] = 'Q. Cap residua non può essere negativo';
                    }
                }
                console.log('Dk this[keyList[0]].length', JSON.stringify(this[keyList[0]]));
                for(var i = 1; i < this[keyList[0]].length; i++){
                    console.log('Dk i-1', i-1);
                    // this[keyList[0]][i]['PercNonutilizzato__c'] = this[keyList[0]][i-1]['PercNonutilizzato__c'] - this[keyList[0]][i]['percentualeUtilizzoAmmortamento__c'];
                    this[keyList[0]][i]['PercNonutilizzato__c'] = 100 - this[keyList[0]][i]['percentualeUtilizzoAmmortamento__c'];
                    this[keyList[0]][i]['Nonutilizzato__c'] = (this[keyList[0]][i-1]['Nonutilizzato__c'] + this[keyList[0]][i-1]['quotaCapitaleResiduaAmmortamento__c'])*(this[keyList[0]][i]['PercNonutilizzato__c']/100)
                    this[keyList[0]][i]['QuotaCapitaleUtilizzato__c'] = (this[keyList[0]][i-1]['Nonutilizzato__c'] + this[keyList[0]][i-1]['quotaCapitaleResiduaAmmortamento__c'])*(this[keyList[0]][i]['percentualeUtilizzoAmmortamento__c']/100)
                    this[keyList[0]][i]['quotaCapitaleResiduaAmmortamento__c'] = this[keyList[0]][i]['QuotaCapitaleUtilizzato__c'] - this[keyList[0]][i]['QuotaCapAmmortamento__c'];
                    if(this[keyList[0]][i]['quotaCapitaleResiduaAmmortamento__c'] < 0){
                        if(!numberInvalidFieldMap[this[keyList[0]][i]['number']])numberInvalidFieldMap[this[keyList[0]][i]['number']] = {};
                        numberInvalidFieldMap[this[keyList[0]][i]['number']]['QuotaCapAmmortamento__c'] = 'Q. Cap residua non può essere negativo';
                        numberInvalidFieldMap[this[keyList[0]][i]['number']]['percentualeUtilizzoAmmortamento__c'] = 'Q. Cap residua non può essere negativo';
                    }
                }

                console.log('DK numberInvalidFieldMap', JSON.stringify(numberInvalidFieldMap));
                
                numberSet.forEach(number =>{
                    this.template.querySelectorAll("[data-key='"+ number +"']").forEach(inputField =>{
                        if(numberInvalidFieldMap[number]){
                            if(numberInvalidFieldMap[number][inputField.name.split('#')[0]]){
                                console.log('DK invalidInputFieldName', inputField.name.split('#')[0]);
                                console.log('DK invalidInputFieldValue', numberInvalidFieldMap[number][inputField.name.split('#')[0]]);
                                inputField.setCustomValidity(numberInvalidFieldMap[number][inputField.name.split('#')[0]]);
                                inputField.reportValidity();
                            }else{
                                inputField.setCustomValidity('');
                                inputField.reportValidity();
                            }
                        }else{
                            inputField.setCustomValidity('');
                            inputField.reportValidity();
                        }
                    });
                })
            }
        } catch (error) {
            console.log('Dk error', error.message);
        }
    }

    async f() {
        
        return 1;
    }

    extendLinea(){
        console.log('DK EXTEND CAMPI START');
        if(this.hanldeRender && this.fieldToCheck){
            if(['Formatecnica__c', 'Tipo_tasso__c'].includes(this.fieldToCheck)){
                console.log('DK SET Sensitivity__c', this.lineaSimulazione.Sensitivity__c);
                this.lineaSimulazione.Sensitivity__c = '10';
            }
        }
        if(this.lineaSimulazione.Durata__c && this.lineaSimulazione.Periodicita_rata__c){
            this.lineaSimulazione.Numerodirate__c = (this.durataValueMap[this.lineaSimulazione.Durata__c] / this.periodicitaRataValueMap[this.lineaSimulazione.Periodicita_rata__c]) % 1 === 0 ? this.durataValueMap[this.lineaSimulazione.Durata__c] / this.periodicitaRataValueMap[this.lineaSimulazione.Periodicita_rata__c] : null;
        }else{
            this.lineaSimulazione.Numerodirate__c = null;
        }

        if(this.lineaSimulazione.Preammortamento__c && this.lineaSimulazione.Periodicita_rata__c){
            this.lineaSimulazione.Periodi_di_preammortamento__c = this.lineaSimulazione.Preammortamento__c ? this.lineaSimulazione.Preammortamento__c + ' ' + this.periodicitaRataTextValueMap[this.lineaSimulazione.Periodicita_rata__c] : null;
            console.log('DK this.lineaSimulazione.Preammortamento__c', this.lineaSimulazione.Preammortamento__c);
            if(this.lineaSimulazione.Preammortamento__c > 1){
                this.lineaSimulazione.Periodi_di_preammortamento__c = this.lineaSimulazione.Periodi_di_preammortamento__c.slice(0, -1) + 'i'
            }
            // this.lineaSimulazione.Periodi_di_preammortamento__c = (this.lineaSimulazione.Preammortamento__c / this.periodicitaRataValueMap[this.lineaSimulazione.Periodicita_rata__c]) % 1 === 0 ? (this.lineaSimulazione.Preammortamento__c / this.periodicitaRataValueMap[this.lineaSimulazione.Periodicita_rata__c]) + ' ' + this.periodicitaRataTextValueMap[this.lineaSimulazione.Periodicita_rata__c].slice(0, -1) + 'i' : null;
        }else{
            this.lineaSimulazione.Periodi_di_preammortamento__c = null;
        }

        //CHECK
        if(this.lineaSimulazione.Periodicita_rata__c){
            this.lineaSimulazione.Tasso_running_periodale__c = this.lineaSimulazione.Commissione_running_annuale_perc__c ? this.lineaSimulazione.Commissione_running_annuale_perc__c / this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c] : 0;
            this.lineaSimulazione.Commissione_running_periodale__c = this.lineaSimulazione.Commissione_running_annuale__c ? this.lineaSimulazione.Commissione_running_annuale__c / this.periodicitaRataValueInversoMap[this.lineaSimulazione.Periodicita_rata__c] : 0;
        }
        
        if(this.lineaSimulazione.UpFrontValorePerc__c){
            this.lineaSimulazione.Up_Front_perc__c = this.lineaSimulazione.Up_Front__c ? (this.lineaSimulazione.Up_Front__c / this.lineaSimulazione.Importo__c) * 100 : 0;
        }else{
            this.lineaSimulazione.Up_Front__c = this.lineaSimulazione.Up_Front_perc__c ? this.lineaSimulazione.Up_Front_perc__c * this.lineaSimulazione.Importo__c / 100: 0;
        }

        if(this.lineaSimulazione.RunningValorePerc__c){
            this.lineaSimulazione.Commissione_running_annuale_perc__c = this.lineaSimulazione.Commissione_running_annuale__c ? this.lineaSimulazione.Commissione_running_annuale__c / 100 : 0;
        }else{
            this.lineaSimulazione.Commissione_running_annuale__c = this.lineaSimulazione.Commissione_running_annuale_perc__c ? this.lineaSimulazione.Commissione_running_annuale_perc__c * 100 : 0;
        }

        /*if(this.lineaSimulazione.AltroValorePerc__c){
            this.lineaSimulazione.Altro_es_derivato_perc__c = this.lineaSimulazione.Altroesderivato__c ? this.lineaSimulazione.Altroesderivato__c / 100 : 0;
        }else{
            this.lineaSimulazione.Altroesderivato__c = this.lineaSimulazione.Altro_es_derivato_perc__c ? this.lineaSimulazione.Altro_es_derivato_perc__c * 100 : 0;
        }*/
        
        if(this.lineaSimulazione.Numerodirate__c){
            let optionsRata = [{
                label: '-- None --',
                value: 0
            }];
            for(var i = 1; i <= this.lineaSimulazione.Numerodirate__c; i++){
                optionsRata.push({
                    label: ''+i,
                    value: Number(i)
                });
            }
            // this.optionsRataCorrispondenteModificaTasso = optionsRata.filter(element =>{return element.value <= 5});
            this.optionsNumeroRata = optionsRata;
            this.optionsNumeroPeriodiDiErogazione = optionsRata.filter(element =>{return element.value <= 5});
            this.optionsRataCorrispondenteModificaTasso = optionsRata;
            console.log('DK optionsRata: ' + JSON.stringify(optionsRata));
        }

        if(this.optionsUtilizzoDelta.length === 1){
            this.lineaSimulazione.Utilizzo__c = this.optionsUtilizzoDelta[0].value;
        }
        console.log('DK EXTEND CAMPI END');
    }

    @api
    returnRecord(){
        try {
            
            let inputFields = this.template.querySelectorAll('.validateLinea');
            console.log('DK returnRecord.periodiErogazione', this.periodiErogazione);
            console.log('DK returnRecord.interestStepTassoFisso', this.interestStepTassoFisso);
            console.log('DK returnRecord.interestStepCommissioneFirma', this.interestStepCommissioneFirma);
            console.log('DK returnRecord.ammortamentoAdHoc', this.ammortamentoAdHoc);
            let visibleFields = JSON.parse(JSON.stringify(this.visibleFields));
            if(this.lineaSimulazione.Formatecnica__c){
                if(this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('fideiussioni')){
                    visibleFields.push('Utilizzo__c');
                    visibleFields.push('Tipo_tasso__c');
                }
            }
            for(var i = 0; i < inputFields.length; i++){
                
                this.lineaSimulazione[inputFields[i].name.split('#')[0]] = inputFields[i].style && inputFields[i].style.display == 'none' && !visibleFields.includes(inputFields[i].name.split('#')[0]) ? null : inputFields[i].type == 'checkbox' ? inputFields[i].checked :
                inputFields[i].type == 'number' ? Number(parseFloat(inputFields[i].value).toFixed(3)) : ['true', 'false'].includes(inputFields[i].value) ? /^true$/i.test(inputFields[i].value) : inputFields[i].value;
            }
            if(this.showCommisioneDiFirma || this.lineaSimulazione.Intereststep__c === false){
                this.interestStepTassoFisso = [];
            }else if(this.showTassoAttivo || this.lineaSimulazione.IntereststepCF__c === false){
                this.interestStepCommissioneFirma = [];
            }
            if(!this.showAmmortamentoAdHoc){
                this.ammortamentoAdHoc = [];
            }
            this.lineaSimulazione.rateLineeToUpsert = [...this.periodiErogazione,...this.interestStepTassoFisso,...this.interestStepCommissioneFirma,...this.ammortamentoAdHoc];
            this.lineaSimulazione.rateLineeToDelete = [];
            let periodiErogazioneToUpsert = this.periodiErogazione.map(element => element.Numerorata__c);
            let interestStepTassoFissoToUpsert = this.interestStepTassoFisso.map(element => element.Ratacorrispondentemodificatasso__c);
            let interestStepCommissioneFirmaToUpsert = this.interestStepCommissioneFirma.map(element => element.Numerorata__c);
            let ammortamentoAdHocToUpsert = this.ammortamentoAdHoc.map(element => element.ProgrPeriodo__c);
            
            this.lineaSimulazione.periodiErogazione.forEach(element =>{
                if(element.Id && !periodiErogazioneToUpsert.includes(element.Numerorata__c)){
                    this.lineaSimulazione.rateLineeToDelete.push(element);
                }
            })
            this.lineaSimulazione.interestStepTassoFisso.forEach(element =>{
                if(element.Id && !interestStepTassoFissoToUpsert.includes(element.Ratacorrispondentemodificatasso__c)){
                    this.lineaSimulazione.rateLineeToDelete.push(element);
                }
            })
            this.lineaSimulazione.interestStepCommissioneFirma.forEach(element =>{
                if(element.Id && !interestStepCommissioneFirmaToUpsert.includes(element.Numerorata__c)){
                    this.lineaSimulazione.rateLineeToDelete.push(element);
                }
            })
            this.lineaSimulazione.ammortamentoAdHoc.forEach(element =>{
                if(element.Id && !ammortamentoAdHocToUpsert.includes(element.ProgrPeriodo__c)){
                    this.lineaSimulazione.rateLineeToDelete.push(element);
                }
            })

            console.log('DK CibLineaSimulazione returnRecord this.lineaSimulazione', JSON.stringify(this.lineaSimulazione));
        } catch (error) {
            console.log('DK CibLineaSimulazione returnRecord error: ', error.message);
        }
        return this.lineaSimulazione;
    }

    handleClone(event){
        const selectedEvent = new CustomEvent('clone', {
            detail: this.returnRecord(),
            status: 'insert'
        });
        console.log('SV selectedEvent: ', selectedEvent);
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handleDelete(event){
        const selectedEvent = new CustomEvent('delete', {
            detail: {number: this.lineaSimulazione.Number__c, Id: this.lineaSimulazione.Id},
            status: 'insert'
        });
        console.log('SV selectedEvent: ', selectedEvent);
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    @api invalidFields = [];

    @api
    isInputValid() {
        console.log('DK CibLineaSimulazione START isInputValid', this.lineaSimulazione);
        try {
            var invalidFields = [];
            let isValid = true;
            // let inputFields = this.template.querySelectorAll('.validateLinea');
            this.lineaSimulazione = {...this.lineaSimulazione};
            // console.log('DK isInputValid.inputFields', inputFields);
            let visibleFields = JSON.parse(JSON.stringify(this.visibleFields));
            if(this.lineaSimulazione.Formatecnica__c){
                if(this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('fideiussioni')){
                    visibleFields.push('Utilizzo__c');
                    visibleFields.push('Tipo_tasso__c');
                }
            }
            this.template.querySelectorAll('.validateLinea').forEach(inputField => {
                if(!inputField.style || inputField.style.display !== 'none'){
                    visibleFields.push(inputField.name.split('#')[0])
                }
                inputField.setCustomValidity("");
                if(inputField.style.display !== 'none' && !inputField.checkValidity()) {
                    inputField.reportValidity();
                    isValid = false;
                    invalidFields.push(inputField.name.split('#')[0]);
                }
                this.lineaSimulazione[inputField.name.split('#')[0]] = inputField.type === 'checkbox' ? inputField.checked :
                inputField.type === 'number' ? Number(inputField.value) : ['true', 'false'].includes(inputField.value) ? /^true$/i.test(inputField.value) : inputField.value;
                console.log('DK CibLineaSimulazione check final value: ' + this.lineaSimulazione[inputField.name.split('#')[0]]);
            });

            this.template.querySelectorAll('.validateRataLinea').forEach(inputField => {
                console.log('DK validateRataLinea inputField.name', inputField.name, inputField.checkValidity());
                // inputField.setCustomValidity("");
                if(!inputField.checkValidity()) {
                    inputField.reportValidity();
                    isValid = false;
                    invalidFields.push(inputField.name.split('#')[0]);
                }
            });

            console.log('DK CibLineaSimulazione invalidFields: '+ JSON.stringify(invalidFields));
            console.log('DK CibLineaSimulazione visibleFields: '+ JSON.stringify(visibleFields));
            Object.keys(this.lineaSimulazione).forEach(fieldLineaSimulazione =>{
                if(fieldLineaSimulazione.includes('__c') && !visibleFields.includes(fieldLineaSimulazione)){
                    console.log('DK CibLineaSimulazione FIELD BLANK: ', fieldLineaSimulazione);
                    this.lineaSimulazione[fieldLineaSimulazione] = typeof this.lineaSimulazione[fieldLineaSimulazione] === 'boolean' ? false : null;
                }
            })
            if(isValid){
                // INIZIO CUSTOM VALIDATION
                var validityResponse = this.customFieldValidation();
                console.log('DK validityResponse', JSON.stringify(validityResponse));
                if(validityResponse.toasts.length > 0){
                    isValid = false;
                    validityResponse.toasts.forEach(toastMessage =>{
                        const toastEvent = new ShowToastEvent({
                            title: "Attenzione!",
                            message: toastMessage,
                            variant: "error",
                            mode: 'sticky'
                        });
                        this.dispatchEvent(toastEvent);
                    })
                }
                var invalidFieldSet = Object.keys(validityResponse);
                console.log('DK invalidFieldSet', invalidFieldSet);
                if(invalidFieldSet.length > 0){
                    this.template.querySelectorAll('.validateLinea').forEach(inputField => {
                        if(invalidFieldSet.includes(inputField.name.split('#')[0])){
                            console.log('DK ERROR on ' + inputField.name.split('#')[0] + ': ' + validityResponse[inputField.name.split('#')[0]]);
                            setTimeout(() => {
                                inputField.setCustomValidity(validityResponse[inputField.name.split('#')[0]]);
                                inputField.reportValidity();
                            }, 0);
                            isValid = false;
                        }
                        // inputField.setCustomValidity(validityResponse[inputField.name.split('#')[0]]);
                    })
                }
            }
            console.log('DK lineaSimulazione isValid', isValid);
            console.log('DK CibLineaSimulazione isInputValid this.lineaSimulazione', JSON.stringify(this.lineaSimulazione));
            return isValid;
        } catch (error) {
            console.log('DK CibLineaSimulazione error: ' + error.message);
            return false;
        }
    }

    customFieldValidation(){
        var errorMap = {};
        errorMap['toasts'] = [];
        if(this.periodiErogazione && this.periodiErogazione.length > 0 && this.periodiErogazione.reduce((accumulator, object) => {return accumulator + object.Erogato__c;}, 0) !== this.lineaSimulazione.Importo__c){
            errorMap['toasts'].push('La somma degli importi inseriti in "Erogato" non è uguale all\'Importo della linea.');
        }

        if(this.lineaSimulazione.Tipo_di_ammortamento__c === 'ad_hoc' && this.ammortamentoAdHoc && this.ammortamentoAdHoc[this.ammortamentoAdHoc.length-1].quotaCapitaleResiduaAmmortamento__c !== 0){
            errorMap['toasts'].push('La Q. Cap. Residua dell\'ultimo periodo dell\'Ammortamento ad hoc deve essere uguale a 0.');
        }

        if(this.lineaSimulazione.Cap__c && this.lineaSimulazione.Floor__c && this.lineaSimulazione.Capvalore__c < this.lineaSimulazione.Floorvalore__c){
            errorMap['Capvalore__c'] = 'CAP Valore deve essere maggiore di FLOOR Valore';
            errorMap['Floorvalore__c'] = 'FLOOR Valore deve essere minore di CAP Valore';
        }
        return errorMap;
    }

    sectionVisibilityMap ={
        'Tipo_di_ammortamento__c':{
            'francese': ['showSal', 'showUtilizzo'],
            'italiana': ['showSal', 'showUtilizzo'],
            'ad_hoc' : ['showAmmortamentoAdHoc'],
            'bullet': ['showUtilizzo'],
        },
        'Tipo_tasso__c':{
            'VARIABILE': ['showCap', 'showFloor'],
            'FISSO': []
        },
        'Formatecnica__c': {
            'MLT-Chirografario': ['showTassoAttivo', 'showCMU'],
            'MLT-Ipotecario Residenziale': ['showTassoAttivo', 'showCMU'],
            'MLT-Ipotecario Commerciale': ['showTassoAttivo', 'showCMU'],
            'Linea Term Loan': ['showTassoAttivo', 'showCMU'],
            'MLT-Linea RCF': ['showTassoAttivo', 'showCMU'],
            'Fideiussioni Commerciali': ['showCommisioneDiFirma'],
            'Fideiussioni Finanziarie': ['showCommisioneDiFirma'],
            'Fideiussioni Commerciali Performance/Advance': ['showCommisioneDiFirma'],
        },
    }
    fieldVisibilityMap = {
        'SAL__c':{
            'true': ['Numero_periodi_di_erogazione__c']
        },
        'Cap__c':{
            'true': ['Capvalore__c']
        },
        'Floor__c':{
            'true': ['Floorvalore__c']
        },
        'Tipo_tasso__c':{
            'VARIABILE': ['Indicizzazionetassovariabile__c', 'Spread__c'],
            'FISSO': ['tassoFisso__c']
        },
        'Garanzia__c':{
            'true': ['Tipo_garanzia__c']
        },
        'AltroValorePerc__c':{
            'true':['Altroesderivato__c'],
            'false': ['Altro_es_derivato_perc__c'],
        },
        'Tipo_garanzia__c':{
            'Reale (Ipoteca residenziale)': ['Valore_del_bene_ipotecato__c'],
            'Reale (Ipoteca non residenziale)': ['Valore_del_bene_ipotecato__c'],
            'Reale (Pegno)': ['Tipo_pegno__c', 'Valore_del_pegno_SACE__c'],
            'SACE': ['Valore_del_pegno_SACE__c'],
        },
        'RunningValorePerc__c':{
            'true': ['Commissione_running_annuale__c','Commissione_running_periodale__c'],
            'false': ['Commissione_running_annuale_perc__c','Tasso_running_periodale__c'],
        },
        'Tipo_di_ammortamento__c':{
            'francese': ['Preammortamento__c','Periodi_di_preammortamento__c','SAL__c','baloonFinalePercentuale__c'],
            'italiana': ['Preammortamento__c','Periodi_di_preammortamento__c','SAL__c','baloonFinalePercentuale__c']
        },
        'Formatecnica__c': {
            'MLT-Chirografario': ['Cap__c','Floor__c','CMUannuale__c', 'Tipo_di_ammortamento__c', 'Tipo_funding__c', 'Intereststep__c', 'Utilizzo__c'],
            'MLT-Ipotecario Residenziale': ['Cap__c','Floor__c','CMUannuale__c', 'Tipo_di_ammortamento__c', 'Tipo_funding__c', 'Intereststep__c', 'Utilizzo__c'],
            'MLT-Ipotecario Commerciale': ['Cap__c','Floor__c','CMUannuale__c', 'Tipo_di_ammortamento__c', 'Tipo_funding__c', 'Intereststep__c', 'Utilizzo__c'],
            'Linea Term Loan': ['Cap__c','Floor__c','CMUannuale__c', 'Tipo_di_ammortamento__c', 'Tipo_funding__c', 'Intereststep__c', 'Utilizzo__c'],
            'MLT-Linea RCF': ['Tipo_di_ammortamento__c', 'Tipo_funding__c','CMUannuale__c', 'Intereststep__c', 'Utilizzo__c'],
            // 'Fideiussioni Commerciali': ['Utilizzo__c'],
            // 'Fideiussioni Finanziarie': ['Utilizzo__c'],
            // 'Fideiussioni Commerciali Performance/Advance': ['Utilizzo__c'],
        },
    }

    fieldAbilityMap = {
        'UpFrontValorePerc__c':{
            'true': ['Up_Front_perc__c'],
            'false': ['Up_Front__c'],
        },
        'RunningValorePerc__c':{
            'true': ['Commissione_running_annuale_perc__c'],
            'false': ['Commissione_running_annuale__c'],
        },
        'Formatecnica__c': {
            'MLT-Linea RCF': ['Tipo_di_ammortamento__c'],
            'Fideiussioni Commerciali': ['Utilizzo__c', 'Tipo_funding__c', 'Tipo_di_ammortamento__c'],
            'Fideiussioni Finanziarie': ['Utilizzo__c', 'Tipo_funding__c', 'Tipo_di_ammortamento__c'],
            'Fideiussioni Commerciali Performance/Advance': ['Utilizzo__c', 'Tipo_funding__c', 'Tipo_di_ammortamento__c'],
        },
    }

    get numeroRateSet(){
        return !Boolean(this.lineaSimulazione.Numerodirate__c);
    }

    // --------------------------------------------------- OPTIONS
    get optionsTipoVal() {
        return [
            { label: 'Val. Ass.', value: true },
            { label: '%', value: false },
        ];
    }

    get optionsSINO() {
        return [
            { label: 'SI', value: true },
            { label: 'NO', value: false },
        ];
    }

    optionsModificaTasso = [
        {label: '1', value: 1},
        {label: '2', value: 2},
        {label: '3', value: 3},
        {label: '4', value: 4},
        {label: '5', value: 5},
        {label: '6', value: 6},
        {label: '7', value: 7},
        {label: '8', value: 8},
        {label: '9', value: 9},
        {label: '10', value: 10},
    ];

    durataValueMap = {
        '1M': 1,
        '2M': 2,
        '3M': 3,
        '6M': 6,
        '9M': 9,
        '1A': 12,
        '18M': 18,
        '2A': 24,
        '3A': 36,
        '4A': 48,
        '5A': 60,
        '6A': 72,
        '7A': 84,
        '8A': 96,
        '9A': 108,
        '10A': 120,
        '11A': 132,
        '12A': 144,
        '13A': 156,
        '14A': 168,
        '15A': 180,
        '16A': 192,
        '17A': 204,
        '18A': 216,
        '19A': 228,
        '20A': 240,
        '21A': 252,
        '22A': 264,
        '23A': 276,
        '24A': 288,
        '25A': 300,
        '26A': 312,
        '27A': 324,
        '28A': 336,
        '29A': 348,
        '30A': 360
    }

    periodicitaRataValueMap = {
        'MENSILE': 1,
        'TRIMESTRALE': 3,
        'SEMESTRALE': 6,
        'ANNUALE': 12
    }

    periodicitaRataTextValueMap = {
        'MENSILE': 'Mese',
        'TRIMESTRALE': 'Trimestre',
        'SEMESTRALE': 'Semestre',
        'ANNUALE': 'Anno'
    }

    periodicitaRataValueInversoMap = {
        'MENSILE': 12,
        'TRIMESTRALE': 4,
        'SEMESTRALE': 2,
        'ANNUALE': 1
    }

    @track showTassoAttivo = true;
    @track showCommisioneDiFirma = true;
    @track showAmmortamentoAdHoc = true;
    @track showSal = true;
    @track showCap = true;
    @track showFloor = true;
    @track showCMU = true;
    @track showUtilizzo = true;

    get showAddAmmortamentoAdHoc(){
        return this.lineaSimulazione.Numerodirate__c && this.ammortamentoAdHoc && this.ammortamentoAdHoc.length < this.lineaSimulazione.Numerodirate__c;
    }

    get showAddInterestStepCommissioneFirma(){
        return this.lineaSimulazione.IntereststepCF__c &&this.interestStepCommissioneFirma && this.interestStepCommissioneFirma.length < this.lineaSimulazione.Numerodirate__c && this.interestStepCommissioneFirma.length < 5;
    }

    get showAddInterestStepTassoFisso(){
        return this.lineaSimulazione.Intereststep__c && this.interestStepTassoFisso && this.interestStepTassoFisso.length < this.lineaSimulazione.Numerodirate__c && this.interestStepTassoFisso.length < 5;
    }
    //OPTIONS
    @api optionsMap = {};
    optionsFormaTecnica
    optionsValuta
    optionsTipoFunding
    optionsTipoDiAmmortamento
    optionsDurata
    optionsPeriodicitaRata
    // optionsPreammortamento
    optionsTipoGaranzia
    optionsTipoPegno
    optionsTipoTasso
    optionsIndicizzazioneTassoVariabile
    optionsSensitivity
    optionsNumeroPeriodiDiErogazione
    optionsRataCorrispondenteModificaTasso
    optionsNumeroRata
    optionsUtilizzo

    get optionsUtilizzoDelta(){
        return this.loaded && this.lineaSimulazione.Formatecnica__c && this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('fideiussioni') ? this.optionsUtilizzo.filter(element =>{return element.value === '1'}) : this.optionsUtilizzo;
    }

    get optionsTipoTassoDelta(){
        if(this.loaded && this.lineaSimulazione.Formatecnica__c){
            let optionsTipoTassoDelta = (this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('mlt') || this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('loan')) ? this.optionsTipoTasso.filter(element =>{return element.value !== 'COMMISSIONE_DI_FIRMA'}) : this.optionsTipoTasso.filter(element =>{return element.value === 'COMMISSIONE_DI_FIRMA'});
            if(optionsTipoTassoDelta.length === 1){
                this.lineaSimulazione.Tipo_tasso__c = optionsTipoTassoDelta[0].value;
            }
            return optionsTipoTassoDelta;
        }
        return this.optionsTipoTasso;
    }

    get optionsTipoFundingDelta(){
        return this.loaded && this.lineaSimulazione.Formatecnica__c && this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('fideiussioni') ? this.optionsTipoFunding.filter(element =>{return element.value === 'No Funding'}) : this.optionsTipoFunding.filter(element =>{return element.value !== 'No Funding'});
    }

    get optionsTipoDiAmmortamentoDelta(){
        return this.loaded && this.lineaSimulazione.Formatecnica__c && (this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('rcf') || this.lineaSimulazione.Formatecnica__c.toLowerCase().includes('fideiussioni')) ? this.optionsTipoDiAmmortamento.filter(element =>{return element.value === 'bullet'}) : this.optionsTipoDiAmmortamento;
    }

    get optionsRataCorrispondenteModificaTassoTFDelta(){
        return this.loaded && this.interestStepTassoFisso && this.interestStepTassoFisso.length > 0 ? this.optionsRataCorrispondenteModificaTasso.filter(element =>{return !this.interestStepTassoFisso.map(element => element.Ratacorrispondentemodificatasso__c).includes(element.value)}) : this.optionsRataCorrispondenteModificaTasso;
    }
}