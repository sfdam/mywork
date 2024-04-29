({
	redirect : function(component, event, helper,urlTo){
		console.log('TEST start redirect');
		console.log('DEBUG****** NewOpportunityCmpHelperjs.redirect - urlTo is: '+urlTo);

		var workspaceAPI = component.find("workspace");
		workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
		
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			'url': urlTo
		});
		urlEvent.fire();
	}
})