({
	doInit : function(component, event, helper) {
        helper.getUserEvent(component, event);
	},
    
    navigateToActivity : function(component, event, helper){
        var navigator = component.find('navService');

        var pg = {    
            "type": "standard__navItemPage",
            "attributes": {
                "apiName": "WGC_Attivita"
            }
        };

        navigator.navigate(pg);
    },

    /*
    navigateToVisite : function(component, event, helper){
        var navigator = component.find('navService');

        var pg = {    
            "type": "standard__navItemPage",
            "attributes": {
                "apiName": "WGC_Attivita"
            },
            "state" : {
                "c__objectName" : "event"
            }
        };

        navigator.navigate(pg);

    },

    navigateToOpty : function(component, event, helper){
        var navigator = component.find('navService');

        var pg = {    
            "type": "standard__navItemPage",
            "attributes": {
                "apiName": "WGC_Attivita"
            }
        };

        navigator.navigate(pg);

    },
    */
})