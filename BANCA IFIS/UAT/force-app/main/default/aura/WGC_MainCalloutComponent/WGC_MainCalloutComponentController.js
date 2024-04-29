({
	doInit: function (component, event, helper) {
		var objType = component.get('v.objectType');
		console.log('QUUUUUAAAAAAA');
		console.log(objType);
		if(objType == 'Opportunity'){

			console.log('QUUUUUAAAAAAA');
			var action = component.get("c.accountHasHesitatedTaskOrEvent");
			action.setParams({ accountId : component.get("v.recordId") });
			
			action.setCallback(this,function(response) {
				var state = response.getState();
				if (state === "SUCCESS") { 
					// pass returned value to callback function
					var result = response.getReturnValue();
					console.log('SV TASK RESULT', result);
					var task = (result.data[0].taskOpen == true || result.data[0].eventOpen == true) ? false : true;
					var opp = (result.data[0].task == true || result.data[0].event == true) ? false : true;
					component.set("v.hesitatedTask", task);
					component.set("v.hesitatedEvent", opp);
					//PALUMBO 12/02/2020
					helper.isFastFinanceProfile(component);
				} else if (state === "ERROR") {
					// generic error handler
					var errors = response.getError();
					if (errors) {
						console.log("Errors", errors);
						if (errors[0] && errors[0].message) {
							throw new Error("Error" + errors[0].message);
						}
					} else {
						throw new Error("Unknown Error");
					}
				}
			});
			
			$A.enqueueAction(action);
		}
		
	},

	goTo: function (component, event, helper) {
		let Tipo = event.getSource().get("v.value");
		var objType = component.get('v.objectType');
		var id = component.get("v.recordId");
		console.log(id);

		if (objType == 'Opportunity') {
			$A.createComponent("c:WGC_AccountFlowGenericContainer", {
				accountId: component.get("v.recordId"),
				tipo: Tipo,
				flowName: "Crea_Opportunit"
			},
				function (content, status) {
					if (status === "SUCCESS") {
						component.find('overlayLib').showCustomModal({
							header: "Crea Opportunità",
							body: content,
							showCloseButton: true,
							cssClass: "mymodal slds-modal_medium",
							closeCallback: function () { }
						});
					}
				});
		} else if (objType == 'Account') {
			var navService = component.find("navService");
			var pageReference = {
				"type": "standard__recordPage",
       "attributes": {
           "recordId": component.get("v.recordId"),
           "objectApiName": "Account",
           "actionName": "edit"
       }
			};

			navService.navigate(pageReference);

			// $A.createComponent("c:EditAccountModal", {
			// 	recordId: id,
			// },
			// 	function (content, status) {
			// 		if (status === "SUCCESS") {
			// 			component.find('overlayLib').showCustomModal({
			// 				body: content,
			// 				closeCallback: function () { }
			// 			});
			// 		}
			// 	});

		}
	},
})