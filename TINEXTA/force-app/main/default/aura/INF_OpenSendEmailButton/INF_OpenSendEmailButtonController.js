({
	onclick : function(component, event, helper) {
        var modalBody;
        var id = component.get("v.recordId");
        $A.createComponents([
            
             ["c:INF_SendEmailOppItemComponent",{recordId: id}]
        ],
		function(content, status) {
            console.log("content: ", content);
            console.log("status: ", status);
            if (status === "SUCCESS") {
                console.log("SUCCESS");
                modalBody = content[0];
                //modalFooter = contefunt[1];
                component.find('overlayLib').showCustomModal({
                    header:  $A.get("$Label.c.INF_OpenSendEmailButton_buttonLabel"), //LABEL HERE
                    body: modalBody,
                    footer: null,
                    showCloseButton: true,
                    cssClass: "cstm-edit-modal slds-modal_large slds-scrollable_none"
                });
            }
        });
    },
    // closeAction : function(component, event, helper) {
    //     alert('ciao');
    //     $A.get("e.force:closeQuickAction").fire();

    // }
})