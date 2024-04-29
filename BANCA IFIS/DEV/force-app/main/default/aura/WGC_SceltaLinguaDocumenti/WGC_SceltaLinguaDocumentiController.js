({
	doInit : function(component, event, helper) {
		helper.initialize(component, event, helper);
	},

	selezionaLingua : function(component, event, helper){
		helper.selezionaLingua(component, event, helper);
	},

	close : function(component, event, helper){
		component.set("v.modalBodyAttributeName", 'ANNULLA');
		component.find('overlayLib').notifyClose();
	}
})