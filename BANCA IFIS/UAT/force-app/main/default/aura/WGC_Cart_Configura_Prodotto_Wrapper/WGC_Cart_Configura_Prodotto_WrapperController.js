({
    doInit : function(component, event, helper) {
        helper.setupReadOnlyConst(component);
        helper.configureSelectedLines(component);
        //SM - TEN: Aggiunto controllo per abilitare i pulsanti per i prodotti di banca corporate
        helper.setupBtnCorporate(component, event, helper);
        helper.setupDebitori(component);
        helper.refreshItems(component);
        helper.setupIcarManuali(component);
        // var gandg = { CategoriaProdotto__c: '' , Name: 'Garanti e Garanzie' };
        // component.set("v.garantiAndGaranzie", gandg);
    },

    reloadParameters : function(component, event, helper) {
        let selectedDeb = component.get("v.selectedDeb");
        
        helper.setupParametriPerLineaDebitore(component);

        // helper.configureSelectedLines(component);
        helper.setupParameters(component);
        // helper.setupParameters(component, event, true);
        helper.refreshItems(component);
        // helper.wizardCompletato(component);
        if (!helper.isBlank(selectedDeb))
            helper.reloadParametersOnDebitore(component, selectedDeb);
        window.setTimeout(
            $A.getCallback(function() {
                helper.checkForRevisionedLine(component);
            }), 1000
        );
        helper.setupRevisioneFlag(component);
        helper.reloadReadOnlyForFactFisc(component);
    },

    reloadIcarManuali : function(component, event, helper) {
        helper.setupIcarManuali(component);
    },

    handleProductClick : function(component, event, helper) {
        let action = event.getParam("action");
        let item = event.getParam("item");
        let items = component.get("v.items");
        let lineHasIcarManuali = false;
        
        items.forEach(i => {
            if (i.subLines.length > 0) {
                i.subLines.forEach(sl => {
                    if (sl.line.id == item.id)
                        sl.isActive = true;
                    else
                        sl.isActive = false;    
                    });
            } else {
                if (i.id == item.id) {
                    i.isActive = true;
                    lineHasIcarManuali = i.icarManuali;
                }
                else
                    i.isActive = false;
            }
        });
        component.set("v.items", items);
        component.set("v.multipleConfDebPerLine", false);
        component.set("v.selectedDeb", "");
        component.set("v.disableRevisionedLines", false);
        component.set("v.lineHasIcarManuali", lineHasIcarManuali);

        //SM - TEN: Aggiunto controllo per abilitare i pulsanti per i prodotti di banca corporate
        helper.setupBtnCorporate(component, event, helper);

        helper.setupRevisioneFlag(component);
        helper.setupDebitori(component);
        helper.setupParameters(component);
        helper.setupIcarManuali(component);
        helper.checkForRevisionedLine(component);
        helper.refreshItems(component);
        helper.reloadReadOnlyForFactFisc(component);
        // if (item.isGandG == true)
        //     component.set("v.garantiAndGaranzieIsOpen", true);
        // else
        //     component.set("v.garantiAndGaranzieIsOpen", false);
    },

    conferma : function(component, event, helper) {
        // helper.navigateSubWizard(component, "analisiBilancio");
        helper.validateAndSave(component, event);
    },

    modalSpeseIstruttoria : function(component, event, helper){
        helper.openSpeseIstruttoria(component, event, helper);
    },

    modalCommissione : function(component, event, helper){
        helper.openCommissione(component, event, helper);
    },

    // getParametriBC : function(component, event, helper){
    //     helper.getParametriBC(component, event, helper);
    // },

    openParametriBC : function(component, event, helper){
        helper.openParametriBC(component, event, helper);
    },

    saveCommissione : function(component, event, helper){
        helper.saveCommissione(component, event, helper);
    },

    toggleMultipleConfDebPerLine : function(component, event, helper) {
        let toggle = !component.get("v.multipleConfDebPerLine");
        component.set("v.multipleConfDebPerLine", toggle);
        component.set("v.selectedDeb", "");
        // helper.setupParameters(component);
        if (toggle == false)
            helper.reloadParametersOnDebitore(component, null);
        helper.reloadAvailableDebs(component);
    },

    onChangeDebitore : function(component, event, helper) {
        helper.reloadParametersOnDebitore(component, event.getSource().get("v.value"));
    },

    onChangeParamValue : function(component, event, helper) {
        // component.set("v.parametriSezioni", helper.evalParamsVisibility(component.get("v.parametriSezioni"), helper.getLineProsolutoATDFlags(component.get("v.items"))));
        helper.changeParam(component, event);
    },

    //SM - TEN: Change Condizione Spread
    onChangeCondizioneValue : function(component, event, helper){
        var isCompleted = event.getParam("isCompleted");
        var items = component.get("v.items"); 
        items.forEach((l => { 
            if(l.isActive){
                l.isCompleted = l.isCompleted && isCompleted;
                l.isCompleted = helper.isLineCompleted(component, l.id);
            }
        }));

        component.set("v.items", items);
        component.set("v.showNext", false);
    },

    //SM - TEN: Banca Corporate
    onLoadCondizioniSpread : function(component, event, helper){
        var items = component.get("v.items"); 
        items.forEach((l => { 
            if(l.isActive){
                // l.isCompleted = l.isCompleted && isCompleted;
                l.isCompleted = helper.isLineCompleted(component, l.id);
            }
        }));

        component.set("v.items", items);
        component.set("v.showNext", items.reduce(function(start, i) {return start && i.isCompleted;}, true));
    },

    onRevisionedLineDisabled : function(component, event, helper) {
        let lines = component.get("v.items");
        let activeLineId = helper.getActiveLine(component).id;

        if (event.getParam("value") != event.getParam("oldvalue")) {

            lines.forEach(l => {
                if (l.subLines != null && l.subLines.length > 0)
                    l.subLines.forEach(sl => {
                        if (sl.line.id == activeLineId)
                            sl.line.isCompleted = sl.line.isDisabledRevLine = component.get("v.disableRevisionedLines");
                    });
                else if (l.id == activeLineId)
                    l.isCompleted = l.isDisabledRevLine = component.get("v.disableRevisionedLines");
            });

            component.set("v.items", lines);
            
        }
    },

    onChangeIcarManuali : function(component, event, helper) {
        console.log("CHANGE ICAR MANUALI");
        component.set("v.showNext", false);
    },

    back : function(component, event, helper) {
        let payload = component.get("v.payload");
        
        helper.navigateSubWizard(component, "inserimentoDebitori");
    },

    next : function(component, event, helper) {
        let readOnly = component.get("v.readOnly");

        if (readOnly) {
            helper.navigateSubWizard(component, "analisiBilancio");
        } else {
            //A.M. -> Simulo il conferma anche prima di andare alle garanzie
            // (test risoluzione problema aggiornamento importo e durata per Mutui)
            helper.validateAndSave(component, event);
            // A.M.
            helper.updateWizardCompletato(component, "analisiBilancio");
        }
    },

    goToGaranzie : function(component, event, helper) {
        let readOnly = component.get("v.readOnly");

        if (readOnly) {
            helper.navigateSubWizard(component, "garantiGaranzie");
        } else {
            //A.M. -> Simulo il conferma anche prima di andare alle garanzie
            // (test risoluzione problema aggiornamento importo e durata per Mutui)
            helper.validateAndSave(component, event);
            // A.M.
            helper.updateWizardCompletato(component, "garantiGaranzie");
        }
    },

    onCreditiRendered : function(component, event, helper) {
        let crediti = event.getParam('crediti');
        helper.initializeCreditiVariables(component, crediti);
        helper.setupParameters(component);
        helper.refreshLineCompletion(component);
    },

    onChangeCrediti : function(component, event, helper) {
        component.set("v.showNext", false);
    }
})