({
    fireProductClickEvent : function(component, action, subLineId) {
        var cmpEvent = component.getEvent("productClick");
        cmpEvent.setParams({ "item" : (subLineId != null ? component.get("v.item").subLines.find(sl => {return sl.line.id == subLineId;}).line : component.get("v.item")) , "action" : action });
        cmpEvent.fire();
    }
})