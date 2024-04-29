({
    reloadAvailableProducts : function(component, event) {
        var products = component.get("v.allProducts");
        var items = component.get("v.selectedProducts");
        var lockedItems = component.get("v.lockedProducts");
        var filters = component.get("v.filters");
        var selectedProducts = [];
        var availableProducts = [];
        let currentUser = component.get("v.currentUser");
        
        items.concat(lockedItems).forEach(i => {
            selectedProducts.push(i.name);
            i.isClickable = false;
            i.isSelected = true;
            i.isActive = false;
            i.isRemovable = (i.codice != "ATDTiAnticipo" && (currentUser.Profile.Name != 'IFIS - B/O Valutazione Fast Finance' || i.area == "Factoring - Fiscale"));
        });
        products.forEach(p => {
            p.isClickable = (p.codice != "ATDTiAnticipo" && (currentUser.Profile.Name != 'IFIS - B/O Valutazione Fast Finance' || p.area == "Factoring - Fiscale"));
            if (!selectedProducts.includes(p.name))
                availableProducts.push(p);
        });
        availableProducts = this.filterProducts(availableProducts, filters);
        component.set("v.items", items);
        component.set("v.availableProducts", availableProducts);
        component.set("v.selectedProductsIsEmpty", (items.length > 0 ? false : true));
    },

    selectProduct : function(component, event) {
        var item = event.getParam("item");
        var selectedProducts = component.get("v.selectedProducts");
        // var lockedItems = component.get("v.lockedProducts");
        let selectedCodes = selectedProducts.map(p => {return p.codice;});
        let existingPlafond = component.get("v.existingPlafond");
        let existingFactFisc = selectedProducts.find(p => {return p.area == "Factoring - Fiscale";}) != undefined;
            
        if ((item.codice == "Confirming" || item.codice == "AtdConProrogaConfirming") && (selectedCodes.includes("Confirming") || selectedCodes.includes("AtdConProrogaConfirming")))
            this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_InvalidConfirmingProductsSelection"), "warning");
        else if ((item.codice == "Standard" || item.codice == "ConProroga") && existingPlafond)
            this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_ExistingPlafondProductsSelection"), "warning");
        else if (((item.codice == "Standard" || item.codice == "ConProroga") && selectedProducts.length > 0) || (selectedProducts.find(p => {return p.codice == "Standard" || p.codice == "ConProroga";})))
            this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_InvalidPlafondProductsSelection"), "warning");
        else if ((item.codice == "AtdConProrogaConfirming" && selectedProducts.length > 0) || (selectedProducts.find(p => {return p.codice == "AtdConProrogaConfirming";})))
            this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_InvalidConfirmingCedenteProductsSelection"), "warning");
        else if (existingFactFisc && item.area == "Factoring - Fiscale")
            this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_InvalidFactoringFiscaleProdSelection"), "warning");
        //A.M. Gestione Mutuo Veneto Sviluppo 
        else if ((item.name == "Mutuo Veneto Sviluppo" && selectedProducts.find(p => {return p.name == "Mutuo";})) || (item.name == "Mutuo" && selectedProducts.find(p => {return p.name == "Mutuo Veneto Sviluppo";}))) 
            this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_InvalidMutoVenetoSviluppoProductsSelection"), "warning");
        else {
            selectedProducts.push(item);

            let sb2add = this.autoInsertServizioBancario(component, item, selectedProducts);
            if (sb2add != null)
                selectedProducts.push(sb2add);
    
            component.set("v.selectedProducts", selectedProducts);
        }
    },

    autoInsertServizioBancario : function(component, item, selectedProducts) {
        let products = component.get("v.allProducts");

        //SM - TEN: Aggiunta condizione per inserire in automatico Servizio Bancario per i prodotti Corporate
        //SM - TEN: Aggiunta condizione per inserire in automatico Servizio Bancario per i prodotti Corporate Estero
        if (item.codice == "AtdConProrogaConfirming" || ( item.area != "Factoring - Cedente" && ( item.codice != 'AnticipoFatture' && item.codice != 'GestionePTF' && item.codice != 'SBF' ) && item.area != 'Estero')  || selectedProducts.find(sp => {return sp.name == "C/C Imprese Residente Euro";}) != undefined)
            return null;

        return products.find(p => {return p.name == "C/C Imprese Residente Euro";});
    },

    deselectProduct : function(component, event) {
        var item = event.getParam("item");
        var selectedProducts = component.get("v.selectedProducts");
        try {
            selectedProducts.forEach(function(element, index){
                if (element.name == item.name) {
                    selectedProducts.splice(index, 1);
                    throw "BREAK";
                }
            });
        } catch (e) {
            if ( e !== "BREAK" )
                throw e;
        }
        component.set("v.selectedProducts", selectedProducts);
    },

    filterProducts : function(availableProducts, filters) {
        if (filters == "" || filters == null || filters == undefined || filters == "[]")
            return availableProducts;
        // console.log("availableProducts: ", availableProducts);
        // console.log("filters: ", filters);
        let filtersArray = JSON.parse(filters);
        let result = [];

        filtersArray.forEach(f => {
            let key = f.filter;
            let value = f.value;
            
            if (key == "type") {
                if (value == "all")
                    result = (result.length > 0 ? result : result.concat(availableProducts));
                else if (value == "recent")
                    result = availableProducts.filter(ap => {return ap.recent;});
            }
            else {
                if (result.length == 0)
                    result = availableProducts.filter(ap => {
                        if (typeof ap[key] == "array")
                            return ap[key].includes(value);
                        else
                            return ap[key] == value;
                    });
                else
                    result = result.filter(ap => {
                        if (typeof ap[key] == "array")
                            return ap[key].includes(value);
                        else
                            return ap[key] == value;
                    });
                }
        });

        return result;
        // switch (filters) {
        //     case 'all':
        //         return availableProducts;
        //     case 'recent':
        //         return availableProducts.slice(0,5);
        //     case 'suggested':
        //         var suggested = [];
        //         availableProducts.forEach(function(element){
        //             if (element.CategoriaProdotto__c.includes("Factoring"))
        //                 suggested.push(element);
        //         });
        //         return suggested;
        // }
    },

    navigateSubWizard : function(component, target) {
        var cmpEvent = component.getEvent("navigateSubWizard");
        cmpEvent.setParams({ "target" : target });
        cmpEvent.fire();
    }
})