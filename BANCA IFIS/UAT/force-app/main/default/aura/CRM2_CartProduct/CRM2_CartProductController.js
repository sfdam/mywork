({
    doInit : function(component, event, helper) {
        
    },

    onProductClick : function(component, event, helper) {
        let lineId = event.currentTarget.getAttribute("data-line");

        if (component.get("v.isClickable") == true)
            helper.fireProductClickEvent(component, "click");
        if (lineId != null && lineId != "" && lineId != undefined)
            helper.fireProductClickEvent(component, "click", lineId);
    },

    onRemoveProductClick : function(component, event, helper) {
        if (component.get("v.isRemovable") == true)
            helper.fireProductClickEvent(component, "remove");
    },

    onValPortClick : function(component, event, helper) {
        // console.log("event.value", event.getSource().get("v.checked"));
        helper.fireProductClickEvent(component, "valPort");
    }
})