({
    closeQA : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
		var navService = component.find("navService");
                            var pageReference = {
                                type: "standard__objectPage",
                                attributes: {
                                    objectApiName: "Wallet__c",
                                    actionName: "list"
                                },
                                state: {
                                }
                            };
                            
							navService.navigate(pageReference);
							component.destroy();

	},

	init : function(component, event, helper) {
		var modalBody;
		var modalFooter;

		$A.createComponents([
			["c:newMicroWalletModal",{recordId: component.get('v.recordId'),"onclose": component.getReference("c.closeQA")}],
			["c:newMicroWalletModalFooter",{recordId: component.get('v.recordId')}],
		],
		function(content, status) {
			if (status === "SUCCESS") {
				console.log(status);
				console.log(content);
				modalBody = content[0];
				modalFooter = content[1];
				component.find('overlayLib').showCustomModal({
					header: 'Nuovo Microportafoglio',
					body: modalBody,
					footer: modalFooter,
					showCloseButton: true,
					cssClass: "mymodal slds-modal_medium",
					closeCallback: function() {
						var navService = component.find("navService");
                            var pageReference = {
                                type: "standard__objectPage",
                                attributes: {
                                    objectApiName: "Wallet__c",
                                    actionName: "home"
                                },
                                state: {
                                }
                            };
                            
                            navService.navigate(pageReference);
					}
				});
			} else {
				console.log(status);
				console.log(content);
			}
		});
	},
})