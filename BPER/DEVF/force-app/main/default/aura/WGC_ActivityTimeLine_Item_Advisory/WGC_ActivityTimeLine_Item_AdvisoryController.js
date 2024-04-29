({
    doInit: function (component, event, helper) {
        let object = component.get('v.itemDetail');
      console.log('item: ',object);
	},
    navigateToNDG : function(component, event, helper) {
        var navService = component.find("navService");
        console.log('@@@GB ObjectFieldLookup: ',component.get('v.itemDetail').ObjectFieldLookup);
        var pageReference = {
            type: "standard__recordPage",
            attributes: {
                "recordId": component.get('v.itemDetail')[component.get('v.itemDetail').ObjectFieldLookup],
                "objectApiName": "Account",
                "actionName": "view"
            }
        };
        navService.navigate(pageReference); 
    }
})