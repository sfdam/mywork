({
	doInit: function (component, event, helper) {
		helper.initialize(component, event, helper);
	},

	goToNews: function (component, event, helper) {
		console.log('DENTRO');
		var idNews = event.getSource().get("v.id");

		var navService = component.find("navService");
		var pageReference = {
			"type": "standard__recordPage",
			"attributes": {
				"recordId": idNews,
				"objectApiName": "WGC_News__c",
				"actionName": "view"
			}
		};

		navService.navigate(pageReference);
	},
})