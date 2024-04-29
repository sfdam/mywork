({
    init : function(component, event, helper) {
        
        var options = [ { 'title': 'search', 'buttons': [{ 'type': 'next', 'requireValidation': true }], 'accountId': component.get("v.accountId"), 'tipoRecord': component.get("v.tipoRecord"), 'whoAreYou': component.get("v.whoAreYou") } , 
                            { 'title': 'result', 'buttons': [{ 'type': 'next', 'visible': false }] } , 
                            { 'title': 'submit', 'buttons': [{ 'type': 'back', 'visible': false }] } ];
        
        component.set('v.options', options);

        var isSalesforce1 = false;
        if(navigator.userAgent.match(/Salesforce1/i)){
            isSalesforce1 = false;
         } else {
            isSalesforce1 = false;
         }

        if(!isSalesforce1){
            var modalBody;
            var modalFooter;
            
            $A.createComponents([
                ["c:CreateAccountModal_Body",{options: options}],
                ["c:CreateAccountModal_Footer",{options: options}]
            ],
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content[0];
                    modalFooter = content[1];
                    component.find('overlayLib').showCustomModal({
                        header: $A.get("$Label.c.WGC_CreateAccountModal_Censimento_Nuova_Anagrafica"),
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: false,
                        cssClass: "mymodal slds-modal_medium",
                        closeCallback: function() {
                            $A.get('e.force:refreshView').fire();
                            /*
                            var navService = component.find("navService");
                            var pageReference = {
                                type: "standard__objectPage",
                                attributes: {
                                    objectApiName: "Account",
                                    actionName: "list"
                                },
                                state: {
                                    filterName: "Recent"
                                }
                            };
                            
                            navService.navigate(pageReference);
                            */
                        }
                    });
                }
            });
        }

        component.set('v.isSalesforce1', isSalesforce1);
        
    },

    resolveEvent : function(component, event, helper) {
        // manage Footer event
        var json = JSON.parse(event.getParam("json"));
        var originAccount = component.get("v.accountId");
        var tipoRecord = component.get("v.tipoRecord");
        console.log('TEST');
        console.log(json);

        var navService = component.find("navService");

        if (json.whoAreYou == "censimentoAnagrafica") {
            if(json.action == 'submit'){
                var pageReference = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": (tipoRecord == "Fornitore" || tipoRecord == "Cliente" || tipoRecord == "Referral") ? originAccount : json.data.Id,
                        "objectApiName": "PersonAccount",
                        "actionName": "view"
                    }
                }

                navService.navigate(pageReference);

            } else {
                if (originAccount == "") {
                    var pageReference = {
                        type: "standard__objectPage",
                        attributes: {
                            objectApiName: "Account",
                            actionName: "list"
                        },
                        state: {
                            filterName: "Recent"
                        }
                    };    
                } else {
                    var pageReference = {
                        type: "standard__recordPage",
                        attributes: {
                            "recordId": originAccount,
                            "objectApiName": "PersonAccount",
                            "actionName": "view"
                        }
                    };
                }
        
                navService.navigate(pageReference);
            }
        }
    }
})