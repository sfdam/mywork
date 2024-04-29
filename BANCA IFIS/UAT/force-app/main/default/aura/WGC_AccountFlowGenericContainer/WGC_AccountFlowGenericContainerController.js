({
	doInit : function(component, event, helper) {
		let tipologia = component.get("v.tipo");
        let nomeFlow = component.get("v.flowName");
		// Find the component whose aura:id is "flowData"
		var flow = component.find("flowData");
		// In that component, start your flow. Reference the flow's Unique Name.
		console.log('@@@ ' , component.get("v.accountId"));
		if($A.util.isUndefinedOrNull(component.get("v.accountId")) || component.get("v.accountId") == ''){
			var inputVariables = [{
				name: "recordId",
				type: "String",
				value: ''
			}];
		}
		else{
			var inputVariables = [{
				name: "recordId",
				type: "String",
				value: component.get("v.accountId")
			}];
		}

		console.log('input variables' , JSON.parse(JSON.stringify(inputVariables)));
        flow.startFlow(nomeFlow, inputVariables);
		
	},

	statusChange : function(component, event, helper){
		//let tipologia = component.get("v.tipo");
		//console.log('@@@ tipologia prova ' , tipologia);
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
				console.log('@@@ object id ' , oppId);
				// var evt = $A.get("e.force:navigateToComponent");
				// evt.setParams({
				// 	componentDef : "c:AccountOpportunity_Detail",
				// 	componentAttributes: {
				// 		opportunityId : oppId
				// 	}
				// });
				// evt.fire();
				
				// var navService = component.find("navService");
				// var pageReference = {    
				// 		"type": "standard__component",
				// 		"attributes": {
				// 				"componentName": "c__AccountOpportunity_Detail"
				// 		},    
				// 		"state": {
				// 				"c__opportunityId" : oppId
				// 		}
				// };

				// navService.navigate(pageReference);

				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
				  "recordId": oppId
				});
				navEvt.fire();	

				//Serve per refreshare il altrimenti errore sul find
				let ms = 5;
				window.setTimeout($A.getCallback(function(){
					$A.get('e.force:refreshView').fire();
				}),ms);
			}
			else{
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