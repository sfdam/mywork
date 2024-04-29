({
	doInit : function(component, event, helper) {



		var test = {datasets:{WGC_Account_Performance:[{fields:'Mese__c', filter:{operator:'matches', values:['01']}}]}};
		var testStringfy = JSON.stringify(test);
		
		console.log(test);
		console.log(testStringfy);

		component.set('v.filterValue', testStringfy);

		component.set('v.currentYear', $A.localizationService.formatDate(new Date(), "YYYY"));

		var userId = $A.get("$SObjectType.CurrentUser.Id");
		console.log("$SObjectType.CurrentUser.Id: " + userId);
		component.set("v.currentUser", userId);

	},
})