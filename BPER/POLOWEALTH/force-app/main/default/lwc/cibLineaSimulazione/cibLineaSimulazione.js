import { LightningElement, api, track } from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CibLineaSimulazione extends LightningElement {
    @api recordId;
    titolo
    @api lineaSimulazione = {};

    @track sezioniAttive = ['sezione1', 'sezione2'];

    @track loaded = true;
    @track isOpenModal = false;

    get optionsTipoVal() {
        return [
            { label: 'Val. Ass.', value: 'true' },
            { label: '%', value: 'false' },
        ];
    }

    get optionsSINO() {
        return [
            { label: 'SI', value: true },
            { label: 'NO', value: false },
        ];
    }

    connectedCallback(){
        console.log('DK START CibLineaSimulazione');
        console.log('DK CibLineaSimulazione connectedCallback lineaSimulazione: ', JSON.stringify(this.lineaSimulazione));
        this.lineaSimulazione = JSON.parse(JSON.stringify(this.lineaSimulazione));
        this.titolo = 'Linea ' + this.lineaSimulazione.number;
        if(this.formaTecnicaSezioniMap[this.lineaSimulazione.Formatecnica__c]){
            this.setShowSezioni.forEach(showSezione =>{
                this[showSezione] = this.formaTecnicaSezioniMap[this.lineaSimulazione.Formatecnica__c].includes(showSezione);
            })
        }else{
            this.setShowSezioni.forEach(showSezione =>{
                this[showSezione] = false;
            })
        }
        console.log('DK CibLineaSimulazione.this.optionsMap: ', JSON.stringify(this.optionsMap));
        //linee
        this.optionsFormaTecnica = this.optionsMap['Formatecnica__c'];
        this.optionsValuta = this.optionsMap['Valuta__c'];
        this.optionsTipoDiAmmortamento = this.optionsMap['Tipo_di_ammortamento__c'];
        this.optionsTipoFunding = this.optionsMap['Tipo_funding__c'];
        this.optionsDurata = this.optionsMap['Durata__c'];
        this.optionsPeriodicitaRata = this.optionsMap['Periodicita_rata__c'];
        this.optionsPreammortamento = this.optionsMap['Preammortamento__c'];
        this.optionsTipoGaranzia = this.optionsMap['Tipo_garanzia__c'];
        this.optionsTipoPegno = this.optionsMap['Tipo_pegno__c'];
        this.optionsTipoTasso = this.optionsMap['Tipo_tasso__c'];
        this.optionsIndicizzazioneTassoVariabile = this.optionsMap['Indicizzazione_tasso_variabile__c'];
        this.optionsSensitivity = this.optionsMap['Sensitivity__c'];
        console.log('DK this.optionsSensitivity: ' + JSON.stringify(this.optionsSensitivity));
    }
    handleFilter(event){
        try {
            
            this.lineaSimulazione = JSON.parse(JSON.stringify(this.lineaSimulazione));
            this.lineaSimulazione[event.target.name] = event.target.type == 'checkbox' ? event.target.checked :
            event.target.type == 'number' ? Number(event.target.value) : ['true', 'false'].includes(event.target.value) ? /^true$/i.test(event.target.value) : event.target.value;
            
            if(event.target.name == 'Formatecnica__c'){

                if(this.formaTecnicaSezioniMap[this.lineaSimulazione.Formatecnica__c]){
                    console.log('SONO 3');
                    this.setShowSezioni.forEach(showSezione =>{
                        this[showSezione] = this.formaTecnicaSezioniMap[this.lineaSimulazione.Formatecnica__c].includes(showSezione);
                    })
                }else{
                    console.log('SONO 4');
                    this.setShowSezioni.forEach(showSezione =>{
                        this[showSezione] = false;
                    })
                }
            }
            console.log('SONO 5');
            console.log('DK CibLineaSimulazione returnRecord this.lineaSimulazione', JSON.stringify(this.lineaSimulazione));
        } catch (error) {
            console.log('DK error: ' + JSON.stringify(error));
        }
    }

    @api
    returnRecord(){
        try {
            
            let inputFields = this.template.querySelectorAll('.validateLinea');
            // console.log('DK isInputValid.inputFields', inputFields);
            for(var i = 0; i < inputFields.length; i++){

                this.lineaSimulazione[inputFields[i].name] = inputFields[i].type == 'checkbox' ? inputFields[i].checked :
                inputFields[i].type == 'number' ? Number(inputFields[i].value) : ['true', 'false'].includes(inputFields[i].value) ? /^true$/i.test(inputFields[i].value) : inputFields[i].value;
            }
            /*inputFields.forEach(inputField => {
            });*/
            console.log('DK CibLineaSimulazione returnRecord this.lineaSimulazione', JSON.stringify(this.lineaSimulazione));
        } catch (error) {
            console.log('DK error: ' + JSON.stringify(error));
        }
        return this.lineaSimulazione;
    }

    @api invalidFields = [];

    @api
    isInputValid() {
        console.log('DK CibLineaSimulazione START isInputValid');
        try {
            
            let isValid = true;
            let inputFields = this.template.querySelectorAll('.validateLinea');
            // console.log('DK isInputValid.inputFields', inputFields);
            inputFields.forEach(inputField => {
                if(!inputField.checkValidity()) {
                    inputField.reportValidity();
                    isValid = false;
                    this.invalidFields.push(inputField.name);
                }
                this.lineaSimulazione[inputField.name] = inputField.type == 'checkbox' ? inputField.checked :
                inputField.type == 'number' ? Number(inputField.value) : ['true', 'false'].includes(inputField.value) ? /^true$/i.test(inputField.value) : inputField.value;
            });
            console.log('DK CibLineaSimulazione handleFilter this.lineaSimulazione', JSON.stringify(this.lineaSimulazione));
            return isValid;
        } catch (error) {
            console.log('DK error: ' + JSON.stringify(error));
            return false;
        }
    }



    // --------------------------------------------------- OPTIONS

    /*optionsFormaTecnica = [
        {label: 'MLT-Chirografario', value: 'MLT-Chirografario'},
        {label: 'MLT-Ipotecario Residenziale', value: 'MLT-Ipotecario Residenziale'},
        {label: 'MLT-Ipotecario Commerciale', value: 'MLT-Ipotecario Commerciale'},
        {label: 'Linea Term Loan', value: 'Linea Term Loan'},
        {label: 'MLT-Linea RCF', value: 'MLT-Linea RCF'},
        {label: 'Fideiussioni Commerciali', value: 'Fideiussioni Commerciali'},
        {label: 'Fideiussioni Finanziarie', value: 'Fideiussioni Finanziarie'},
        {label: 'Fideiussioni Commerciali Performance/Advance', value: 'Fideiussioni Commerciali Performance/Advance'}
    ];*/

    optionsNumeroRata = [
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
    
    optionsNumeroPeriodiDiErogazione = [
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

    formaTecnicaSezioniMap = {
        'MLT-Chirografario': ['showTassoAttivo'],
        'MLT-Ipotecario Residenziale': ['showTassoAttivo'],
        'MLT-Ipotecario Commerciale': ['showTassoAttivo'],
        'Linea Term Loan': ['showTassoAttivo'],
        'MLT-Linea RCF': ['showTassoAttivo'],
        'Fideiussioni Commerciali': ['showCommisioneDiFirma'],
        'Fideiussioni Finanziarie': ['showCommisioneDiFirma'],
        'Fideiussioni Commerciali Performance/Advance': ['showCommisioneDiFirma'],
    }

    setShowSezioni = ['showTassoAttivo', 'showCommisioneDiFirma'];
    @track showTassoAttivo = false;
    @track showCommisioneDiFirma = false;
    //OPTIONS
    @api optionsMap = {};
    optionsFormaTecnica
    optionsValuta
    optionsTipoFunding
    optionsTipoDiAmmortamento
    optionsDurata
    optionsPeriodicitaRata
    optionsPreammortamento
    optionsTipoGaranzia
    optionsTipoPegno
    optionsTipoTasso
    optionsIndicizzazioneTassoVariabile
    optionsSensitivity
}