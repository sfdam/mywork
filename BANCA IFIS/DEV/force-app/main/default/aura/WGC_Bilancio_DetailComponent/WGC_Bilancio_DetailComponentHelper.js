({
    initialize : function (component, event, helper) {
        this.showSpinner(component, event);
        var ndg = component.get("v.simpleRecord.Id");
        if(ndg != null && ndg != undefined){
            this.hideSpinner(component, event);
        }
    },

    showSpinner: function (cmp, event) {
		var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");

    },

    hideSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");

    },
})