({
	doInit : function(component, event, helper) {
        let nomeFlow = component.get("v.flowName");
		let tipoSegnalatore = component.get("v.workflowRecord.Tipo_Segnalatore__c");
		let originatorPS = (tipoSegnalatore=="Partner")?"Cross Selling":"Segnalazione esterna";
		let originatorDettaglioPS = (tipoSegnalatore=="Partner")?"Leasing":"Segnalatore esterno";
		// Find the component whose aura:id is "flowData"
		var flow = component.find("flowData");
		// In that component, start your flow. Reference the flow's Unique Name.
		console.log('@@@ ' , component.get("v.accountId"));
		if($A.util.isUndefinedOrNull(component.get("v.accountId")) || component.get("v.accountId") == ''){
			var inputVariables = [{
				name: "recordId",
				type: "String",
				value: ''
			},
			{
				name: "originatorPS",
				type: "String",
				value: originatorPS
			},
			{
				name: "originatorDettaglioPS",
				type: "String",
				value: originatorDettaglioPS
			}];
		}
		else{
			var inputVariables = [{
				name: "recordId",
				type: "String",
				value: component.get("v.accountId")
			},
			{
				name: "originatorPS",
				type: "String",
				value: originatorPS
			},
			{
				name: "originatorDettaglioPS",
				type: "String",
				value: originatorDettaglioPS
			}];
		}

		console.log('input variables' , JSON.parse(JSON.stringify(inputVariables)));
        flow.startFlow(nomeFlow, inputVariables);
		
	},

	statusChange : function(component, event, helper){
		//let tipologia = component.get("v.tipo");
		console.log('SV EVENT',event.getParam('status'));
		if (event.getParam('status') === "FINISHED") {
			var output = event.getParam("outputVariables");
			var input = event.getParam("inputVariables");
			console.log('@@@ input ' , input);
			var objectId = "";
			var objectType = "";
			var oppId = '';
			
            output.forEach(o => {
				console.log('@@@ Obj ' , o);
				if(o.value != null){
					if(o.name == 'EventId'){
						objectId = o.value;
						objectType = o.name;
					} else if (o.name == 'TaskId'){
						objectId = o.value;
						objectType = o.name;
					} else if (o.name == 'OpportunityId'){
						oppId = o.value;
						//objectId = o.value;
						objectType = o.name;
					}
					else if (o.name == 'recordId'){
						objectId = o.value;
					}
				}
			});
			
			if(objectType == "OpportunityId"){				
				var action = component.get("c.completaPrevalutazioneSegnalazione");
				console.log('@@@ v.workflowRecord ' , component.get("v.workflowRecord.TIMELINE_JSON__c"));
				action.setParams({
					actualWorkflow: component.get("v.workflowRecord"),
					recordOppId : oppId
				});
    
				action.setCallback( this , function(callbackResult) {
    
				if(callbackResult.getState()=='SUCCESS') {						
					var resultState = callbackResult.getReturnValue();
					if(resultState.esitoGlobale){
						component.find("overlayLib").notifyClose();
						console.log('@@@ resultState debug ' , resultState);
						var event = $A.get("e.c:BI_PSE_CuscottoEsitazionePraticaEvent");
						event.setParams({InvioOpp:'PREVALUTAZIONE_OK'});
						event.fire();
						return resultState;
					}
				}

				if(callbackResult.getState()=='ERROR') {
					console.log('ERROR', callbackResult.getError() ); 
				}
				
				component.find("overlayLib").notifyClose();
				});
            
				$A.enqueueAction( action ); 
				
			} else {
				console.log('@@@ objectId ' , objectId);
				var urlEvent = $A.get("e.force:navigateToURL");
				urlEvent.setParams({
				  "url": "/" + objectId
				});

				urlEvent.fire();
				component.find("overlayLib").notifyClose();
			}
		}
	}
})