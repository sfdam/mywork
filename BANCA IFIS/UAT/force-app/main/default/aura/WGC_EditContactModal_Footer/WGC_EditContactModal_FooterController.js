({
	doInit : function(component, event, helper) {
		
	},

	cancel : function(component, event, helper) {
		// component.find("overlayLib").notifyClose();
		var F2B = $A.get("e.c:ModalFooter2BodyEvent");
		F2B.setParams({ "json" : JSON.stringify({ "action" : "cancel" }) });
		F2B.fire();
	},

	submit : function(component, event, helper) {
		var F2B = $A.get("e.c:ModalFooter2BodyEvent");
		F2B.setParams({ "json" : JSON.stringify({ "action" : "submit" }) });
		F2B.fire();
	}
})