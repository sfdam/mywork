({
    doInit: function (component, event, helper) {
        var accessAction = component.get("c.userHasAccess");
        accessAction.setCallback(this, response => {
            if (response.getState() === "SUCCESS") {
                let hasAccess = response.getReturnValue();
                if (!hasAccess) {
                    component.find('notifLib').showToast({
                        "title": "Attenzione!",
                        "message": "Non hai accesso alla funzionalità selezionata",
                        "variant": "warning"
                    });
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    var action = component.get("c.getEmailTemplate");
                    action.setCallback(this, response => {
                        if(response.getState() === "SUCCESS"){
                            let templates = response.getReturnValue();
                            let templatesOptions = [];
                            component.set("v.templatesList", templates);
                            templates.forEach(template => {
                                templatesOptions.push({ label: template.Name, value: template.Id });
                            });
                            component.set("v.templates", templatesOptions);
                            $A.util.toggleClass(component.find("spinner"), "slds-hide");
                        } else
                            console.log('@@@ error ' , response.getError());
                    });
                    $A.enqueueAction(action);
                }
            } else {
                console.log('@@@ error ' , response.getError());
            }
        });
        $A.enqueueAction(accessAction);
    },

    changeTemplate : function(component, event, helper){
        component.set("v.selectedTemplate", event.getParam("value"));
    },

    sendMail : function(component, event, helper){
        if(component.get("v.selectedTemplate") == undefined){
            component.find('notifLib').showToast({
                "title": "Errore!",
                "message": "Selezionare un template prima di inviare la mail",
                "variant": "error"
            });
            
            return;
        }

        // let text = component.get("v.templatesList").filter(t => { return t.Id == component.get("v.selectedTemplate")})[0].Name.includes('con consensi') ? 'Confermi la scelta del template, nella versione con consensi?' : 'Confermi la scelta del template, nella versione senza consensi?';
        let text = "Confermi l'invio dell'informativa privacy di contitolarità?";
        let conferma = confirm(text);

        if(!conferma)
            return;

        $A.util.toggleClass(component.find("spinner"), "slds-hide");

        var action = component.get("c.sendEmail");
        var body = component.get("v.templatesList").filter(t => { return t.Id == component.get("v.selectedTemplate")})[0].Body;
        action.setParams({
            templateId: component.get("v.selectedTemplate"),
            body: body,
            recordId: component.get("v.recordId"),
            objectName: component.get("v.sObjectName")
        });
        action.setCallback(this, response => {
            if(response.getState() === "SUCCESS"){
                component.find('notifLib').showToast({
                    "title": response.getReturnValue() == null ? "Successo!" : "Errore!",
                    "message": response.getReturnValue() == null ? "Mail inviata con successo!" : response.getReturnValue(),
                    "variant": response.getReturnValue() == null ? "success" : "error"
                });

                $A.util.toggleClass(component.find("spinner"), "slds-hide");
                if(response.getReturnValue() == null)
                    $A.get("e.force:closeQuickAction").fire();

            } else {
                console.log('@@@ error ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },
})