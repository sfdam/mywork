({
    saveParameter : function(component, event) { console.log("SAVE PARAMETER");
        this.callServer(component, "c.saveParameter", function(result){
            this.showToast(component, "Success!", "Salvataggio parametro correttamente riuscito.", "success");
        }, {
            param: component.get("v.param")
        });
    }
})