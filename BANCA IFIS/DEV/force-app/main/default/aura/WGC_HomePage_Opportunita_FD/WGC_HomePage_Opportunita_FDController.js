({
	doInit : function(component, event, helper) {

        helper.apex(component, event, 'getUserInfo', {  })
        .then($A.getCallback(function (result) {
            console.log('Call getUserInfo result: ', result);
            component.set('v.userInfo', result);

            return helper.apex(component, event, 'getAllData', {})
            
            
        })).then($A.getCallback(function (result) {
            console.log('SV result ', result);
            component.set('v.allDataValue', result.data[0]);
                
        })).finally($A.getCallback(function () {
            helper.generateData(component.get('v.allDataValue'), component, event);
                
            
        }));

	},
    
    navigateToMyComponent : function(component, event, helper) {
        // var navService = component.find("navService");
        // var pageReference = {
        //     type: "standard__objectPage",
        //     attributes: {
        //         objectApiName: "Opportunity",
        //         actionName: "list"
        //     },
        //     state: {
        //         filterName: "Recent"
        //     }
        // }
    
        // navService.navigate(pageReference);
        var navService = component.find("navService");
        var pageReference = {    
            "type": "standard__component",
            "attributes": {
                "componentName": "c__WGC_Opportunity_FD_DetailComponent"    
            },    
            "state": {
                "c__idDashboard": component.get('v.idDashboard'),
                "c__isDirezioneFD": component.get("v.isDirezioneFD")
            }
        };

		navService.navigate(pageReference);
    },
})