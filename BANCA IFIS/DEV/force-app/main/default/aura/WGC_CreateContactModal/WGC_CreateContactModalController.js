({
    init : function(component, event, helper) {
        var modalBody;
        var modalFooter;
        var options = [ { 'title': 'search', 'buttons': [{ 'type': 'next', 'requireValidation': true }] , 'accountId': component.get("v.accountId"), 'tipoRecord': component.get("v.tipoRecord"), 'whoAreYou': component.get("v.whoAreYou") } , 
                        { 'title': 'result', 'buttons': [{ 'type': 'next', 'visible': false }] } , 
                        { 'title': 'submit', 'buttons': [{ 'type': 'back', 'visible': false }] } ];
        
        $A.createComponents([
            ["c:WGC_CreateContactModal_Body",{options: options}],
            ["c:WGC_CreateContactModal_Footer",{options: options}]
        ],
        function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content[0];
                modalFooter = content[1];
                component.find('overlayLib').showCustomModal({
                    header: "New Contact",
                    body: modalBody,
                    footer: modalFooter,
                    showCloseButton: false,
                    cssClass: "mymodal slds-modal_medium", //slds-modal_medium
                    closeCallback: function() {
                        if(component.get("v.whoAreYou") != 'filoDiretto')
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
    },

    resolveEvent : function(component, event, helper) {
        // manage Footer event
        var json = JSON.parse(event.getParam("json"));
        var originAccount = component.get("v.accountId");
        var tipoRecord = component.get("v.tipoRecord");

        if (json.whoAreYou == "Account") {
            if(originAccount){
                var navService = component.find("navService");
                var pageReference = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": originAccount,
                        "objectApiName": "Account",
                        "actionName": "view"
                    }
                }
                navService.navigate(pageReference);
            }
        }
    }
})