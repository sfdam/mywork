({
    compareParams : function(component, event, helper) {
        console.log("event.action: ", event.getParam("action"));
        if (event.getParam("action") == "compareParams") {
            helper.compareParams(component);
        }
    }
})