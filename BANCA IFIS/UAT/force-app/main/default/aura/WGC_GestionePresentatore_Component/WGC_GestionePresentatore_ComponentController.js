({
	doInit : function(component, event, helper) {
		console.log('@@@ prova componente');
        console.log('account'+JSON.stringify(component.get("v.acc")));
	},

	handleSubmit: function(component, event, helper) {
		console.log('@@@ prova valore ' , event.getParams("fields").value[0]);
		component.set("v.specialistafactoring" , event.getParams("fields").value[0]);
	},
})