({
    compareParams : function(component) {
        $A.util.removeClass(component.find("spinner"), "slds-hide");
        this.callServer(component, "c.compareAndGroupParams", function(result){
            console.log("COMPARE PARAMS: ", result);
            result.forEach(r => {
                if (r.oldParams.dominio)
                    r.oldParams.dominio = r.oldParams.dominio.split(";");
                if (r.newParams.dominio)
                    r.newParams.dominio = r.newParams.dominio.split(";");
            });
            component.set("v.params", result);
            $A.util.addClass(component.find("spinner"), "slds-hide");
        }, {});
    }
})