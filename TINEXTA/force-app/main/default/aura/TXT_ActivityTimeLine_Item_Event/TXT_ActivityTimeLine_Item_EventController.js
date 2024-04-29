({
	myAction : function(component, event, helper) {
		
	},

	showArticle : function(component, event, helper) {
		var item = component.get('v.itemDetail');
		item.isCollapsed = !item.isCollapsed;
		component.set('v.itemDetail', item);
	},

	navigateToUser : function(component, event, helper) {

        var navService = component.find("navService");

            var pageReference = {
                type: "standard__recordPage",
                attributes: {
                    "recordId": component.get('v.itemDetail').Owner.Id,
                    "objectApiName": "User",
                    "actionName": "view"
                }
            };
             
        navService.navigate(pageReference);       
	},
	
	navigateToActivity : function(component, event, helper) {

        var navService = component.find("navService");
        
            var pageReference = {
                type: "standard__recordPage",
                attributes: {
                    "recordId": component.get('v.itemDetail').Id,
                    "objectApiName": component.get('v.itemDetail').objectType != "Event" ? "Task" : "Event",
                    "actionName": "view"
                }
            };
             
            navService.navigate(pageReference); 
      
    },
})