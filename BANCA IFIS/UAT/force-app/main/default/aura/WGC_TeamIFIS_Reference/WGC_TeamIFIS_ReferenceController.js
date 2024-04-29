({
	doInit : function(component, event, helper) {
		helper.getUserReferent(component, event);
		helper.setUserIsSpecialista(component);
	},

	navigateToFlow : function(component, event, helper){
		var valoreBtn = event.getSource().get("v.value");
		var nomeBtn = event.getSource().get("v.name");

		$A.createComponent("c:WGC_AccountFlowGenericContainer", {
			accountId: component.get("v.recordId"),
			tipo : "",
			flowName : valoreBtn
		},
		function(content, status) {
			if (status === "SUCCESS") {
				component.find('overlayLib').showCustomModal({
					header: nomeBtn,
					body: content,
					showCloseButton: true,
					cssClass: "mymodal slds-modal_medium",
					closeCallback: function() {}
				});
			}
		});
	},

	filoDiretto : function(component, event, helper) {
		let resultSelected = component.get("v.recordId");

		helper.apex(component, event, 'spegniFiloDiretto', { accId: resultSelected })
        .then($A.getCallback(function (result) {
			console.log('Call spegniFiloDiretto result: ', result);
			// console.log('@@@ then ');
			// var ref = $A.get("e.c:WGC_EditAccountResolveEvent");
			// ref.setParams({
			// 	"json" : {}
			// });
			// ref.fire();

			console.log('@@@ prova ' , $A.get("$Label.c.WGC_Team_IFIS_Specialista_Filo_Diretto"));

			var referenti = component.get("v.personalReferences");
			referenti.forEach((item, index) =>{
				if(item.workAs == $A.get("$Label.c.WGC_Team_IFIS_Specialista_Filo_Diretto")){
					item.attivo = false;
				}
			});

			component.set("v.personalReferences", referenti);
            
        })).finally($A.getCallback(function () {
			
		}));
	},

	onRemoveMe : function(component, event, helper) {
		$A.createComponent("c:WGC_AccountFlowGenericContainer", {
			accountId: component.get("v.recordId"),
			flowName : "Rimozione_Specialista"
		},
		function(content, status) {
			if (status === "SUCCESS") {
				component.find('overlayLib').showCustomModal({
					header: $A.get("$Label.c.WGC_RimuovimiTeamIfis"),
					body: content,
					showCloseButton: true,
					cssClass: "mymodal slds-modal_medium",
					closeCallback: function() {}
				});
			}
		});
	}
})