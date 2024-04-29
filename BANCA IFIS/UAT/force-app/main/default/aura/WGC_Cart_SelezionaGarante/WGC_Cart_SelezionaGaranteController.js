({
    doInit : function(component, event, helper) {
        var garanti = component.get("v.garanti");
        garanti.forEach((item) => {
            item.isSelected = false;
        });

        component.set("v.garanti" , garanti);
    },

    selectGarante : function(component, event, helper){
        helper.selectGarante(component, event, helper);
    },

    saveGarante : function(component, event, helper){
        helper.saveGarante(component, event, helper);
    },
})