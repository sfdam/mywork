({
	doInit : function(component, event, helper) {
        helper.showSpinner(component);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var pg = component.get("v.pageReference");
        var isDirezione = pg.state.c__isDirezioneFD;

        console.log('@@@ pg ' , JSON.stringify(pg));
        component.set("v.isDirezioneFD", isDirezione);
        
        if(isDirezione == 'true'){
            component.set('v.filter', {"userId":"","teamName":"","applyFilter":true,"isAllUser":true});
        } else {
            component.set('v.filter', {"userId":$A.get("$SObjectType.CurrentUser.Id"),"teamName":"","applyFilter":true,"isAllUser":false});
        }
        
        helper.apex(component, event, 'getUsersFD', {}).then($A.getCallback(function (result) {
            console.log('Call getUsersFD result: ', result);
            let mapTeamUser = new Map();
            result.data.forEach(function (element) {
                if(element.Id == userId) component.set('v.userInfo', element);
                var x = [];
                if(mapTeamUser.has(element.WGC_Team_Filo_Diretto__c)){
                	x = mapTeamUser.get(element.WGC_Team_Filo_Diretto__c);   
                }
                
                x.push(element);
                mapTeamUser.set(element.WGC_Team_Filo_Diretto__c, x);
            });
            
            component.set('v.mapTeamUserFD', mapTeamUser);
            return helper.apex(component, event, 'getAllData', {})
        })).then($A.getCallback(function (result) {
            console.log('Call getAllData result: ', result);
            component.set('v.allDataValue', result);
            
            helper.reloadData(component, event, component.get('v.filter'), result);
            
            

            
        })).finally($A.getCallback(function () {
                        helper.hideSpinner(component);

            
		}));
	},
    
    handleFilterEvent : function(component, event, helper) {
        var x = event.getParams();

        helper.reloadData(component, event, x, component.get('v.allDataValue'));

    },
    
    navigateToMyComponent : function(component, event, helper){
		var navigator = component.find("navService");

		var pg = {
			type: 'standard__namedPage',
			attributes: {
				pageName: 'home'
			}
		};

		navigator.navigate(pg);
	},
})