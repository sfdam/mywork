({
	doInit : function(component, event, helper) {
		
	},

	launchFlow : function(component, event, helper){
		//let Tipo = event.getSource().get("v.value");

		$A.createComponent("c:WGC_AccountFlowGenericContainer", {
			accountId: "",
			tipo : "",
            flowName : "Crea_Contatto_Filo_Diretto"
		},
		function(content, status) {
			if (status === "SUCCESS") {
				component.find('overlayLib').showCustomModal({
					header: $A.get("$Label.c.WGC_Account_Header_Crea_Previsione_o_Promemoria"),
					body: content,
					showCloseButton: true,
					cssClass: "mymodal slds-modal_medium",
					closeCallback: function() {}
				});
			}
		});
	},
})