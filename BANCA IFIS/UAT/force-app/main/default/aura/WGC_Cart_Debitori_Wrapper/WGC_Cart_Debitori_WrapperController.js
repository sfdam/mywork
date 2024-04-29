({
    doInit : function(component, event, helper) { 
        helper.setupReadOnlyConst(component);
        console.log("currentUser: ", component.get("v.currentUser"));
        //SM-CART-REVI
        //if (helper.checkRevisionRedirect(component)) {
            console.log('filterServices');
            helper.filterServices(component);
            console.log('setupPicklistOptions');
            helper.setupPicklistOptions(component);
            console.log('setupDebitori');
            helper.setupDebitori(component);
            console.log('configureItems');
            helper.configureItems(component);
            console.log('filterServices');
            helper.filterServices(component);
            console.log('setupSubProductsOptions');
            helper.setupSubProductsOptions(component);
            console.log('reloadSubProductsOptions');
            helper.reloadSubProductsOptions(component);
            //SM - TEN: Banca Corporate - setto le opzioni dei campi per i prodotti banca corporate
            console.log('setupBCOptions');
            helper.setupBCOptions(component);
            //SM - TEN: Banca Corporate - ottimizzo le opzioni per il prodotto corporate selezionato
            console.log('reloadBCOptions');
            helper.reloadBCOptions(component);
            //SM - TEN: Corporate Estero - Setup dei dati per prodotti Corporate Estero
            console.log('reloadBCEOptions');
            helper.setupBCEOptions(component);
            //SM - TEN: Corporate Estero - Setup dei dati per prodotti Corporate Estero
            console.log('reloadBCEOptions');
            helper.reloadBCEOptions(component);
            //SM - TEN: Corporate Estero fine
            console.log('setupItemSection');
            helper.setupItemSection(component);
            console.log('setupItemSection');
            helper.refreshItems(component);
            console.log('getAttoreLabels');
            helper.getAttoreLabels(component);
            console.log('reloadReadOnlyForFactFisc');
            helper.reloadReadOnlyForFactFisc(component);
        //} else {
        //    component.set("v.revisionRedirect", true);
        //}
    },

    handleProductClick : function(component, event, helper) {
        // console.log("event.action", event.getParam("action"));
        // console.log("event.item", JSON.stringify(event.getParam("item")));
        // if (helper.confirmChangeProduct(component, event)) {
            helper.selectItem(component, event);
            helper.reloadSubProductsOptions(component, event);
            //SM - Banca Corporate
            helper.reloadBCOptions(component, event);
            //SM - TEN: Corporate Estero
            helper.reloadBCEOptions(component, event);
            helper.setupItemSection(component, event);
            helper.filterServices(component);
            helper.reloadJoinLineaAttore(component);
            helper.refreshItems(component);
            helper.reloadReadOnlyForFactFisc(component);
        // }
    },

    conferma : function(component, event, helper) {
        // helper.navigateSubWizard(component, "configuraProdotto");
        helper.validateAndSave(component, event);
    },

    back : function(component, event, helper) {
        helper.navigateSubWizard(component, "sceltaProdotto");
    },

    next : function(component, event, helper) {
        helper.next(component);
    },

    disableNextBtn : function(component, event, helper) {
        component.set("v.showNext", false);
    },

    reloadPayload : function(component, event, helper) {
        //SM-CART-REVI
        helper.showSpinner(component, "");
        helper.configureItems(component);
        helper.reloadSubProductsOptions(component);
        //SM - Banca Corporate
        helper.reloadBCOptions(component);
        //SM - TEN: Corporate Estero
        helper.reloadBCEOptions(component);
        // if (component.get("v.revisionRedirect") == false) {

        // SM - TEN: Aggiunto else-if per gestire setup QEC quando ricalcolo i prodotti di Banca Corporate in caso di revisione
        let activeLine = component.get("v.selectedItems").find(i => {return i.isActive;});
        if (event.getParam("value").debitori != undefined)
            helper.reloadDebitori(component, event);
        /*else if(!activeLine.hasValPort && activeLine.area == 'Factoring - Cedente'){
            helper.setupDebitori(component);
        }*/
            
        if (event.getParam("value").valutazioniPortafoglio != undefined)
            helper.reloadValutazioniPortafoglio(component, event);
        helper.refreshItems(component);
        helper.setupItemSection(component);
        helper.reloadReadOnlyForFactFisc(component);
        console.log("showNext: ", helper.validateAllItems(component));
        component.set("v.showNext", helper.validateAllItems(component));
        helper.hideSpinner(component);
        // }
    },

    reloadItems : function(component, event, helper) {
        helper.filterServices(component);
        helper.reloadReadOnlyForFactFisc(component);
    },

    reloadDebitori : function(component, event, helper) {
        //SM-CART-REVI
        //if (component.get("v.revisionRedirect") == false) {
            helper.reloadDebitori(component, event, true);
            helper.refreshItems(component);
            helper.reloadReadOnlyForFactFisc(component);
            component.set("v.showNext", helper.validateAllItems(component));
        //}
    },

    addNewDeb : function(component, event, helper) {
        var modalBody;
        var modalFooter;
        var options = [ { 'title': 'search', 'buttons': [{ 'type': 'next', 'requireValidation': true }], 'accountId': component.get("v.accountId"), 'tipoRecord': "Cliente", "whoAreYou": "carrello" } , 
                        { 'title': 'result', 'buttons': [{ 'type': 'next', 'visible': false }] } , 
                        { 'title': 'submit', 'buttons': [{ 'type': 'back', 'visible': false }] } ];
        
        $A.createComponents([
            ["c:CreateAccountModal_Body",{options: options}],
            ["c:CreateAccountModal_Footer",{options: options}]
        ],
        function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content[0];
                modalFooter = content[1];
                component.find('overlayLib').showCustomModal({
                    header: "Aggiungi Debitore",
                    body: modalBody,
                    footer: modalFooter,
                    showCloseButton: false,
                    cssClass: "mymodal slds-modal_medium"
                });
            }
        });
    },

    onModalClose : function(component, event, helper) {
        var json = JSON.parse(event.getParam("json"));
        
        if (json.whoAreYou == "carrello") {
            console.log(json);
            if (json.action == "submit") {
                helper.addDebitore(component, json.data);
                // helper.setupDebitori(component);
            }
        }
    },

    onRemoveDebitore : function(component, event, helper) {
        helper.removeDebitore(component, event);
        component.set("v.showNext", false);
    },

    onToggleService : function(component, event, helper) {
        helper.toggleService(component, event);
        //A.M. aggiunto aggiornamento items e validate
        //component.set("v.showNext", false);
        helper.refreshItems(component);
        component.set("v.showNext", helper.validateAllItems(component));
    },

    onChangeNotMat : function(component, event, helper) {
        helper.manageNotificationAndMaturity(component, event);
        component.set("v.showNext", false);
    },

    onChangeATD : function(component, event, helper) {
        component.set("v.showNext", false);
    },

    onChangeValPort : function(component, event, helper) {
        helper.toggleValPort(component, event);
    },

    onChangeCrossSelling : function(component, event, helper) {
        helper.refreshItems(component);
        component.set("v.showNext", helper.validateAllItems(component));
    },

    onChangeSubProduct : function(component, event, helper) {
        if (event.getParam("isChanging") === true) {
            component.set("v.showNext", false);
            let items = component.get("v.selectedItems");
            items.find(i => {return i.isActive;}).isCompleted = false;
            component.set("v.selectedItems", items);
            helper.checkEsclusioneBEI(component, event);
            // CR Lotto 4.2 Id 315
            helper.checkEsclusioneFondo(component, event);
        }
    },

    cartResolveServer : function(component, event, helper) {
        // console.log("cartResolveServer: ", JSON.stringify(event.getParams()));
        if (helper.validateResolveServer(component, event.getParam("uid"))) {
            helper.resolveServerAction(component, JSON.parse(event.getParam("json")));
        }
    },

    onInfoCedenteRender : function(component, event, helper) {
        helper.refreshItems(component);
        component.set("v.showNext", helper.validateAllItems(component));
    },

    reloadCCData : function(component, event, helper){
        //SM - TEN: Banca Corporate - setto le opzioni dei campi per i prodotti banca corporate
        helper.setupBCOptions(component);
        //SM - TEN: Banca Corporate - ottimizzo le opzioni per il prodotto corporate selezionato
        helper.reloadBCOptions(component);
        //SM - TEN: Corporate Estero - Setup dei dati per prodotti Corporate Estero
        helper.setupBCEOptions(component);
        //SM - TEN: Corporate Estero - Setup dei dati per prodotti Corporate Estero
        helper.reloadBCEOptions(component);
        //SM - TEN: Corporate Estero fine
    },

})