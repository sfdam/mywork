({
	fireEvent: function (response, whatEvent) {
        var B2F = $A.get("e.c:" + whatEvent);
        B2F.setParams({ "json": response });
        B2F.fire();
    },

    resolveAction: function (action, data) {
        this.fireEvent(JSON.stringify({ "action": action, "data": data }), 'WGC_EditRolesResolveEvent');
    },

    closeAction: function (component, event, target) {

        var obj = {};
        this.resolveAction('cancel', obj);
        // let navService = component.find('navService');

        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.accountId"),
                "objectApiName": "Account",
                "actionName": "view"
            }
        }
        // var pageReference = {
        //     type: "standard__objectPage",
        //     attributes: {
        //         objectApiName: "Account",
        //         actionName: "list"
        //     },
        //     state: {
        //         filterName: "Recent"
        //     }
        // };
        
        navService.navigate(pageReference);
        component.find('overlayLib').notifyClose();
    },

    submit: function (component, json) {
        // var recordEditForm = component.find("recordEditForm");
        // var json = JSON.parse(event.getParam("json"));
        
        // if (json.action == "submit") {
        //     if (this.validateAllFields(component))
        //         this.saveAccount(component);
        // }
        console.log(json);
        this.resolveAction('submit', json.data);
        component.find('overlayLib').notifyClose();
    },

    apex: function (component, event, apexAction, params) {
        var p = new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get("c." + apexAction + "");
            action.setParams(params);
            action.setCallback(this, function (callbackResult) {
                if (callbackResult.getState() == 'SUCCESS') {
                    resolve(callbackResult.getReturnValue());
                }
                if (callbackResult.getState() == 'ERROR') {
                    console.log('ERROR', callbackResult.getError());
                    reject(callbackResult.getError());
                }
            });
            $A.enqueueAction(action);
        }));
        return p;
    },

    showSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");

    },

    hideSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");

    },

})