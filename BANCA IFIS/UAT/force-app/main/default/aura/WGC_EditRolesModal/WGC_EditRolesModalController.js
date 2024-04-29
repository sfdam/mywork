({
    init : function(component, event, helper) {

        //window.history.back();
        // $A.get('e.force:refreshView').fire();
        var modalBody;
        var modalFooter;
        var options = [ { 'title': 'search', 'buttons': [{ 'type': 'next', 'requireValidation': true }], 'accountId': component.get("v.accountId"), 'contactId': component.get("v.contactId") } , 
                        { 'title': 'result', 'buttons': [{ 'type': 'next', 'visible': false }] } , 
                        { 'title': 'submit', 'buttons': [{ 'type': 'back', 'visible': false }] } ];
        
        $A.createComponents([
            ["c:WGC_EditRolesModal_Body",{options: options}],
            ["c:WGC_EditRolesModal_Footer",{options: options}]
        ],
        function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content[0];
                modalFooter = content[1];
                component.find('overlayLib').showCustomModal({
                    header: "Edit Roles",
                    body: modalBody,
                    footer: modalFooter,
                    showCloseButton: false,
                    cssClass: "mymodal", //slds-modal_medium
                    closeCallback: function() {
                        // window.location.reload(true);
                        $A.get('e.force:refreshView').fire();
                        // window.history.back();
                        
                        // i++;
                        
                        // var navService = component.find("navService");
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
                        
                        // navService.navigate(pageReference);
                        
                    }
                });
            }
        });
    },

    resolveEvent : function(component, event, helper) {
        // manage Footer event
        var json = JSON.parse(event.getParam("json"));
           
    }
})