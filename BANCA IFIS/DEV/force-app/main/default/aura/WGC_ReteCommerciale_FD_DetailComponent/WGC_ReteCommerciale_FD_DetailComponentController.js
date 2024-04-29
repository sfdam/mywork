({
    doInit : function(component, event, helper) {
        helper.initialize(component, event, helper);
    },

    navigateToHome : function(component, event, helper){
        var navigator = component.find('navService');

		var pg = {    
			"type": "standard__namedPage",
			"attributes": {
				"pageName": "home"    
			}
		};

		navigator.navigate(pg);
    },

    navigateToReport : function(component, event, helper){
        var navigator = component.find('navService');

		var pg = {    
			"type": "standard__webPage",
			"attributes": {
				"url": component.get("v.dashboardId")
			}
		};

		navigator.navigate(pg);
    },

    loadTableFiliale : function(component, event, helper){
        console.log('@@@ source ' , event.currentTarget.getAttribute("data-filiale"));
        var nomeFiliale = event.currentTarget.getAttribute("data-filiale");

        var filiali = component.get("v.filiali");

        filiali.forEach((item, index) =>{
            if(item.nomeFiliale == nomeFiliale){
                item.selected = true;
            } else {
                item.selected = false;
            }
        });

        component.set("v.filiali", filiali);

        helper.loadData(component, event, helper, nomeFiliale);
    },

    updateColumnSorting : function(component, event, helper){
        console.log('@@@ aaa');
        // helper.sortCol(component, event, helper);
        component.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout($A.getCallback(function() {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
            component.set('v.isLoading', false);
        }), 0);
    },
})