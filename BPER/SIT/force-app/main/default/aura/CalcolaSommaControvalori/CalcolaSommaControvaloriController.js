({
    calcola : function(component, event, helper) {
        var action=component.get("c.CalcolaSommaControvalori");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, response => {
            if(response.getState() === "SUCCESS"){
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})