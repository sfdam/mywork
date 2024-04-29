({
    doInit : function(component, event, helper) {
        console.log("doInit");
    },

    reloadParameter : function(component, event, helper) {
        if (event.getParam("action") == "select") {
            component.find("record").reloadRecord(true);
            console.log("param: " + event.getParam("paramsJSON"));
            component.set("v.param", JSON.parse(event.getParam("paramsJSON")));
        }
    },

    saveParameter : function(component, event, helper) {
        console.log("event.getParameters: ", JSON.stringify(event.getParams()));
        helper.saveParameter(component, event);
    },

    handleLoad : function(component, event, helper) {

    },
    handleSubmit : function(component, event, helper) {

    },
    handleSuccess : function(component, event, helper) {

    },
})