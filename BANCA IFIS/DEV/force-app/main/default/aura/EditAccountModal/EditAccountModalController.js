({
	doInit : function(component, event, helper) {
		var modalBody;
        var modalFooter;
        /*
        var options = [ { 'title': 'search', 'buttons': [{ 'type': 'next', 'requireValidation': true }], 'accountId': component.get("v.accountId"), 'tipoRecord': component.get("v.tipoRecord") } , 
                        { 'title': 'result', 'buttons': [{ 'type': 'next', 'visible': false }] } , 
                        { 'title': 'submit' } ];
        */
        console.log("DO INIT EDITACCOUNTMODAL");
        console.log("recordId: ", component.get("v.recordId"));
        $A.createComponents([
            ["c:EditAccountModal_Body",{recordId: component.get("v.recordId")}]
        ],
        // $A.createComponents([
        //     ["c:EditAccountModal_Body",{accountId: component.get("v.recordId")}]
        // ],
        function(content, status) {
            console.log("content: ", content);
            console.log("status: ", status);
            if (status === "SUCCESS") {
                console.log("SUCCESS");
                modalBody = content[0];
                modalFooter = content[1];
                component.find('overlayLib').showCustomModal({
                    header: $A.get("$Label.c.WGC_EditAccountModal_Modifica_Anagrafica"),
                    body: modalBody,
                    footer: null,
                    showCloseButton: false,
                    cssClass: "cstm-edit-modal slds-modal_medium",
                    closeCallback: function(){
                        $A.get('e.force:refreshView').fire();
                    }
                });
            }
        });
    },
    
    resolveEvent : function(component, event, helper) {
        // manage Footer event
        var json = JSON.parse(event.getParam("json"));
        var originAccount = component.get("v.recordId");
        console.log('MODAL EDIT');
        console.log(json);

        var navService = component.find("navService");

            var pageReference = {
                type: "standard__recordPage",
                attributes: {
                    "recordId": originAccount,
                    "objectApiName": "Account",
                    "actionName": "view"
                }
            };
             
        navService.navigate(pageReference);       
    }
})