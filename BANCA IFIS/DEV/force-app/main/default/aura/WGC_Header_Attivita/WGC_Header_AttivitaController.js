({
	doInit : function(component, event, helper) {

        let hasParametersFromURL = helper.readParameters(component);//AdF

        let pageReference = {    
            "type": "standard__navItemPage",
            "attributes": {
                "apiName": "WGC_Attivita"
            },
            "state": {
            }
        };
        component.set("v.pageReference", pageReference);

        helper.getUserEvent(component, hasParametersFromURL);
	},
    
    navigateToActivity : function(component, event, helper){
        let navigator = component.find('navService');
        let pageReference = component.get("v.pageReference");
        event.preventDefault();
        navigator.navigate(pageReference);
    },

    //S lightning channel message AdF
    handleMessage : function(component, event, helper){
        if(event != null){
            helper.handleMessage(component, event);
            helper.getUserEvent(component, true);
        }
    },
    //E lightning channel message AdF

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