({
	doInit : function(component, event, helper){
		helper.getAccountInfo(component, event);
		helper.getDocStatus(component, event, helper);
	}, 

	manageEventNE : function(component, event, helper) {
		console.log('SONO NEL KPI')
		var json = JSON.parse(event.getParam("json"));
		console.log(json);
		component.set('v.resultEventiNegativi', json.response.data[0]);
		if(json.response.success){
			if(json.response.data[0].EventiNegativiAllarmiQuote__c == "V" &&
			json.response.data[0].EventiNegativiCIGS__c == "V" &&
			json.response.data[0].EventiNegativiGlobale__c == "V" &&
			json.response.data[0].EventiNegativiPregiudizievoli__c == "V" &&
			json.response.data[0].EventiNegativiProcedureConcorsuali__c == "V" &&
			json.response.data[0].EventiNegativiProtesti__c == "V"){
				component.set('v.eventiNegativiStatus', true);
			}
			else{
				component.set('v.eventiNegativiStatus', false);
			}
		} else {
			console.log("WARNING");
			// var toastEvent = $A.get("e.force:showToast");
			// toastEvent.setParams({
			//   "title": "Richiesta Eventi Negativi",
			//   "message": json.response.msg,
			//   "type": "warning"
			// });
			// toastEvent.fire();
		}
	},

	manageEventB : function(component, event, helper){
		var params = JSON.parse(event.getParam("json"));
		
        console.log('@@@ params event bilancio ' , params);
		if(params.response){
			var annoEffettivo = 0;
			var annoScorso = 0;
			var anno = new Date().getFullYear();
            // if(params.response.bilancio.hasOwnProperty('PatrimonioNetto__c') && params.response.bilancioPrecedente.hasOwnProperty('PatrimonioNetto__c')){
			// 	if(params.response.bilancio != undefined){
			// 		annoEffettivo = params.response.bilancio.hasOwnProperty('PatrimonioNetto__c') ? params.response.bilancio.PatrimonioNetto__c : 0;
			// 	}
			// 	if(params.response.bilancioPrecedente != undefined){
			// 		annoScorso = params.response.bilancioPrecedente.hasOwnProperty('PatrimonioNetto__c') ? params.response.bilancioPrecedente.PatrimonioNetto__c : 0;
			// 	}
				
			// 	component.set('v.differenzaBilancio', annoEffettivo - annoScorso);
			// 	component.set('v.resultBilancio', params.response.bilancio);

			// }

			if(!params.response.bilancio){
                component.set('v.resultBilancio', undefined);
                component.set('v.differenzaBilancio', undefined);
            } else {
                var setAnnoEffettivo = false;
                if(params.response.bilancio != undefined && params.response.bilancio.hasOwnProperty('PatrimonioNetto__c')){
					annoEffettivo = params.response.bilancio.hasOwnProperty('PatrimonioNetto__c') ? params.response.bilancio.PatrimonioNetto__c : 0;
					setAnnoEffettivo = true;
                }

                var setAnnoPrecedente = false;
				if(params.response.bilancioPrecedente != undefined && params.response.bilancioPrecedente.hasOwnProperty('PatrimonioNetto__c')){
					annoScorso = params.response.bilancioPrecedente.hasOwnProperty('PatrimonioNetto__c') ? params.response.bilancioPrecedente.PatrimonioNetto__c : 0;
					setAnnoPrecedente = true;
                }
                
                if(setAnnoEffettivo && setAnnoPrecedente){
                    component.set('v.differenzaBilancio', annoEffettivo - annoScorso);
                	component.set('v.resultBilancio', params.response.bilancio);
                } else {
                	component.set('v.differenzaBilancio', undefined);
                	component.set('v.resultBilancio', params.response.bilancio);
                }                
			}
			
			// console.log('@@@ result bilancio ' , json.response.data[0]);
		}
		// else{
		// 	var msg = $A.get("e.force:showToast");
		// 	msg.setParams({
		// 		"title" : "Richiesta Bilancio",
		// 		"message" : params.response.message,
		// 		"type" : "WARNING"
		// 	});
		// 	msg.fire();
		// }
	},

	updateStatusDoc : function(component, event, helper){
		console.log('@@@ params ' , JSON.stringify(event.getParams()));

		var evtParams = event.getParams();
		var status = evtParams.completedDoc;
		console.log('@@@ status ' , status);
		
		if(status != null && status != undefined)
			component.set("v.statusDoc", status);
	},
})