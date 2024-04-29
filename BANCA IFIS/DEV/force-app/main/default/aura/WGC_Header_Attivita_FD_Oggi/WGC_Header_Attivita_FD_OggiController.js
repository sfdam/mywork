({
	doInit : function(component, event, helper) {
		helper.getTodayTask(component, event, helper);
    },
    
    filter : function(component, event, helper){
        helper.getFilteredData(component, event, helper, event.getParams());
    },

	navigateToActivity : function(component, event, helper){
        var navigator = component.find('navService');

        var pg = {    
            "type": "standard__navItemPage",
            "attributes": {
                "apiName": "WGC_Attivit_Filo_Diretto"
            }
        };

        navigator.navigate(pg);
    },
})