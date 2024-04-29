({
    fireRemoveDebitore : function(component) {
        var cmpEvent = component.getEvent("removeDebitore");
        cmpEvent.setParams({ "debitore" : component.get("v.debitore") });
        cmpEvent.fire();
    },

    setupServiziAttore : function(component) {
        var debitore = component.get("v.debitore");
        var servizi = component.get("v.servizi");
        var joinLineaAttore = component.get("v.joinLineaAttore");
        var debitoriNewFieldsMap = this.mapArrayBy(component.get("v.debitoriNewFields"), "debitore");
        //SM-CART-REVI OLD
        // var serviziAttore = [];
        // if (servizi.length > 0)
        //     servizi.forEach(s => {
        //         serviziAttore.push({
        //             serv: s,
        //             selected: (joinLineaAttore.length > 0 && this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id] ? this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id].servizi.includes(s.Label) : false)
        //         });
        //     });
        // component.set("v.isCompleted", this.isCompleted(component.get("v.joinLineaAttore"), debitore, debitoriNewFieldsMap[debitore.id]));
        // component.set("v.isAvailable", this.isAvailable(component.get("v.joinLineaAttore"), debitore));

        //SM-CART-REVI NEW
        let codiciCoppia = component.get("v.codiciCoppia");
        var serviziAttore = [];
        
        if (servizi.length > 0)
            servizi.forEach(s => {
                let jla = joinLineaAttore.find(j => {return j.debitore == debitore.id;});
                serviziAttore.push({
                    serv: s,
                    selected: jla ? jla.servizi.includes(s.Label) : false,
                    disabled: codiciCoppia ? codiciCoppia.find(cc => {return cc.debitore == debitore.id && cc.servizio == s.WGC_Famiglia__c;}) != undefined && jla.servizi.includes(s.Label) : false
                });});
        let hideContesto = this.hideContesto(debitore, joinLineaAttore, codiciCoppia, servizi);
        component.set("v.isCompleted", this.isCompleted(component.get("v.joinLineaAttore"), debitore, debitoriNewFieldsMap[debitore.id], null, hideContesto));

        component.set("v.serviziAttore", serviziAttore);
        component.set("v.serviziSize", (serviziAttore.length != 5 && serviziAttore.length < 7 && serviziAttore.length != 0 ? 12/serviziAttore.length : 12));   
    },

    fireCloseModal : function(component) {
        var appEvent = $A.get("e.c:WGC_ModalManagerEvent");
        appEvent.setParams({
            action: "close"
        });
        appEvent.fire();
    },

    openDebEditModal : function(component) {
        var recordId = component.get("v.recordId");
        var debitore = component.get("v.debitore");
        var payload = component.get("v.payload");
        var debitoriNewFields = component.get("v.debitoriNewFields");
        let pivaPerDebitore = component.get("v.pivaPerDebitore");
        let jla = component.get("v.joinLineaAttore");
        let h = this;
        let codiciCoppia = component.get("v.codiciCoppia");
        let servizi = component.get("v.servizi");
        debitoriNewFields = this.mapArrayBy(debitoriNewFields, "debitore");
// console.log("debitoriNewFields: ", debitoriNewFields);
// console.log("debitore: ", JSON.stringify(debitore));
		let readOnly = component.get("v.readOnly");
        console.log("READONLY editDebDataModal: ", readOnly);

        var appEvent = $A.get("e.c:WGC_ModalManagerEvent");
        appEvent.setParams({
            modalHeader: "Qualifica e contesto",
            modalBody: {
                type: "component",
                value: "c:WGC_Cart_Edit_Deb_Data_Modal_Body",
                params: {
                    recordId: recordId,
                    debitore: debitore,
                    //SM-CART-REVI
                    joinLineaAttore: jla,
                    piva: pivaPerDebitore.get(debitore.id) ? pivaPerDebitore.get(debitore.id) : pivaPerDebitore.get(debitore.account),
                    hasATD: h.hasATD(jla, debitore),
                    //A.M.
                    hasFactMCC: h.hasFactMCC(jla, debitore),
                    hasACFMCC: h.hasACFMCC(jla, debitore),
                    //A.M.
                    hideContesto: h.hideContesto(debitore, jla, codiciCoppia, servizi),
                    isReviDeb: h.isReviDeb(debitore, codiciCoppia),
                    payload: payload,
                    newFields: debitoriNewFields[debitore.id],
                    divisaOptions: component.get("v.divisaOptions"),
                    labels: component.get("v.labels"),
                    readOnly: readOnly
                }
            },
            modalFooter: null,
            showCloseButton: true,
            cssClass: "mymodal slds-modal_medium",
            preFunction: "editDebDataPreLoad"
        });
        appEvent.fire();
    },

    // RETURN TRUE IF DEBITORE IS AN OLD DEBITORE (JOINED WITH EXISTING LINES)
    isReviDeb : function(debitore, codiciCoppia) {
        return codiciCoppia.map(cc => {return cc.debitore;}).includes(debitore.id);
    },

    // isAvailable : function(joinLineaAttore, debitore) {
    //     return (joinLineaAttore.length > 0 && this.getset(joinLineaAttore, "debitore").includes(debitore.id) ? this.mapArrayBy(joinLineaAttore, "debitore")[debitore.id].servizi.includes("Acquisto a titolo definitivo") : false);
    // },

})