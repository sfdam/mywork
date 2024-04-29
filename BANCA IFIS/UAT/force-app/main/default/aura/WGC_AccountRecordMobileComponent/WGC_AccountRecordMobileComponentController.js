({
	doInit : function(component, event, helper) {
		// alert($A.get("$Browser.formFactor"));
		if(window.innerWidth < 480){
			component.set('v.iPhone', true);
		}
	},

	goTo: function (component, event, helper) {

			var navService = component.find("navService");
			var pageReference = {
				"type": "standard__recordPage",
				"attributes": {
					"recordId": component.get("v.recordId"),
					"objectApiName": "Account",
					"actionName": "edit"
				}
			};

			navService.navigate(pageReference);
	},
})