({
    doInit: function (component, event, helper) {
        // console.log("RELOAD RECORD");
        // component.find("record").reloadRecord(true, function(){
        //     helper.loadLayout(component);
        // });
    },

    manageF2B: function (component, event, helper) {
        // manage Footer event
        var json = JSON.parse(event.getParam("json"));
        var currentAccount = component.get('v.currentAccount');

        switch (json.action) {
            
            case 'cancel':
                helper.closeAction(component, event, json.action);
                break;
            case 'submit':
                console.log('JSON: ', json);
                // helper.submit(component, json);
                currentAccount = Object.assign({}, currentAccount, json.data);
                currentAccount.Id = component.get('v.recordId');
                console.log('currentAccount: ', currentAccount);
                helper.apex(component, event, 'saveAccount', { account: currentAccount })
                    .then(function (result) {
                        console.log(result);
                        var toastEvent = $A.get("e.force:showToast");
                        if (result.success) {
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "Account modificato con successo.",
                                "type": "success"
                            });
                        } else {
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": result.msg,
                                "type": "error"
                            });
                        }
                        toastEvent.fire();
                    }).finally($A.getCallback(function () {
                        helper.closeAction(component, event, json.action);
                    }));
                break;
        }
    },

    handleSubmit : function(component, event, helper) {
        helper.validateAllFields(component, event);
    },

    onInputChange : function(component, event, helper) {
        helper.validateField(component, event);
    },

    closeError: function (component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"

        var cmpTarget = component.find('errors-container');
        $A.util.addClass(cmpTarget, 'transit');
        component.set("v.errors", null);
    },

})