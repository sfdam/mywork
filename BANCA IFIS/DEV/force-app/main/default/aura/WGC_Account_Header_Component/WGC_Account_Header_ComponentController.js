({
	doInit : function(component, event, helper) {
		helper.checkRinnovoAvailable(component);

		var annoA = new Date();
		var annoP = new Date();
		annoA.setDate(annoA.getDate() - 50);
		annoP.setDate(annoP.getDate() - 50);
		component.set("v.annoAttuale", annoA.getFullYear());
		component.set("v.annoPrecedente", annoP.getFullYear()-1);

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
				
				//Chiamata ad apex per prendere alcuni valori dell'header della pagina account
				helper.getOtherAccountData(component, event, helper);
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
	},


	goToOpportunita : function(component, event, helper){
		let Tipo = event.getSource().get("v.value");

		$A.createComponent("c:WGC_AccountFlowGenericContainer", {
			accountId: component.get("v.recordId"),
			tipo : Tipo,
            flowName : "Crea_Opportunit"
		},
		function(content, status) {
			if (status === "SUCCESS") {
				component.find('overlayLib').showCustomModal({
					header: $A.get("$Label.c.WGC_Account_Header_Crea_Opportunit"),
					body: content,
					showCloseButton: true,
					cssClass: "mymodal slds-modal_medium",
					closeCallback: function() {}
				});
			}
		});
	},

	goToRinnovo : function(component, event, helper){
		let Tipo = event.getSource().get("v.value");

		$A.createComponent("c:WGC_AccountFlowGenericContainer", {
			accountId: component.get("v.recordId"),
			tipo : Tipo,
            flowName : "WGC_Rinnovo"
		},
		function(content, status) {
			if (status === "SUCCESS") {
				component.find('overlayLib').showCustomModal({
					header: $A.get("$Label.c.WGC_RinnovaOpportunita_ModalFlowTitle"),
					body: content,
					showCloseButton: true,
					cssClass: "mymodal slds-modal_medium",
					closeCallback: function() {}
				});
			}
		});
	},

	goToContatto : function(component, event, helper){
		var Tipo = event.getSource().get("v.value");
		var nomeF = 'Crea_Contatto';

		var action = component.get("c.getUserProfile");
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				
				console.log('@@@ risposta profilo header ' , risposta);
				if(risposta.includes("Filo Diretto")){
					nomeF = 'Crea_Contatto_Filo_Diretto'
				}
			}
			else{
				console.log('@@@ error ' , response.getError());
			}

			$A.createComponent("c:WGC_AccountFlowGenericContainer", {
				accountId: component.get("v.recordId"),
				tipo : Tipo,
				flowName : nomeF
			},
			function(content, status) {
				if (status === "SUCCESS") {
					component.find('overlayLib').showCustomModal({
						header: $A.get("$Label.c.WGC_Account_Header_Crea_Contatto_o_Visita"),
						body: content,
						showCloseButton: true,
						cssClass: "mymodal slds-modal_medium",
						closeCallback: function() {}
					});
				}
			});
		});

		$A.enqueueAction(action);
	},

	goToVisita : function(component, event, helper){
		
		var modalBody;
		var recId= component.get('v.recordId');
        $A.createComponent("c:WGC_EditTaskModal", {recordId:recId},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       header: "Lista Attività",
                       body: modalBody, 
                       showCloseButton: true,
                       closeCallback: function() {
                       }
                   })
               }                               
           });
		
	},

	onLoadRecord : function(component, event, helper) {
		helper.setupIcons(component, event);
	},

	reInit : function(component, event, helper) {
		component.find('record').reloadRecord(true);		
	}
})