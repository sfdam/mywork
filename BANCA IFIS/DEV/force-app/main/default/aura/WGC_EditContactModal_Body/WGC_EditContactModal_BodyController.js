({
    doInit: function (component, event, helper) {
        // helper.retrievePageLayout(component);
    },

    manageF2B: function (component, event, helper) {
        // manage Footer event
        var json = JSON.parse(event.getParam("json"));
        var currentContact = component.get('v.currentContact');

        switch (json.action) {
            
            case 'cancel':
                helper.closeAction(component, event, json.action);
                break;
            case 'submit-updateOnlyCRM':
                currentContact = Object.assign({}, currentContact, json.data);
                currentContact.Id = component.get('v.recordId');
                console.log('currentContact: ', currentContact);
                helper.apex(component, event, 'saveContactOnlyCRM', { contact: currentContact })
                    .then(function (result) {
                        console.log(result);
                        var toastEvent = $A.get("e.force:showToast");
                        if (result.success) {
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "Referente modificato con successo.",
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
            case 'submit':
                console.log('JSON: ', json);
                // helper.submit(component, json);
                currentContact = Object.assign({}, currentContact, json.data);
                currentContact.Id = component.get('v.recordId');
                console.log('currentContact: ', currentContact);
                helper.apex(component, event, 'saveContact', { contact: currentContact })
                    .then(function (result) {
                        console.log(result);
                        var toastEvent = $A.get("e.force:showToast");
                        if (result.success) {
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "Referente modificato con successo.",
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
            case 'submitOnlySalseforce':
                console.log('JSON: ', json);
                // helper.submit(component, json);
                currentContact = Object.assign({}, currentContact, json.data);
                currentContact.Id = component.get('v.recordId');
                console.log('currentContact: ', currentContact);
                helper.apex(component, event, 'saveContactToSalesforce', { contact: currentContact })
                    .then(function (result) {
                        console.log(result);
                        var toastEvent = $A.get("e.force:showToast");
                        if (result.success) {
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "Referente modificato con successo.",
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
})