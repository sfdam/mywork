({
	onRemoveDebitore : function(component, event, helper) {
        var appEvent = $A.get("e.c:WGC_Remove_Debitore");
        appEvent.setParams({ "debitore" : component.get("v.debitore") });
		appEvent.fire();
		
        component.find('overlayLib').notifyClose();
	}
})