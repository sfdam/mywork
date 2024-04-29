({
    selectGarante : function(component, event, helper){
        var idSelected = event.currentTarget.getAttribute("data-gId");
        var garanti = component.get("v.garanti");
        garanti.forEach((item) => {
            if(item.Id == idSelected) {
                item.isSelected = true;
                component.set("v.selectedGarante", item.Id);
            } else
                item.isSelected = false;
        });

        component.set("v.garanti", garanti);
    },

    saveGarante : function(component, event, helper) {
        var garanteSelezionato = component.get("v.selectedGarante");
        if(garanteSelezionato){
            component.find("overlayLib").notifyClose();
        } else {
            helper.showToast(component, "Attenzione", "Selezionare almeno un garante", "WARNING");
        }
    },
})