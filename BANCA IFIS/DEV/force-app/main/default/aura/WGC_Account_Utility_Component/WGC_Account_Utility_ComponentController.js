({
	doInit : function(component, event, helper) {

		var isTrueSetBilancio = (component.get('v.bilancio') == 'true');
		var isTrueSetEventoNegativo = (component.get('v.eventiNegativi') == 'true');

		var recordId = component.get("v.recordId");
        
		helper.apex(component, helper, 'getBilancioRibes', {accountId : recordId, tipoBilancio : 'Civilistico'}, isTrueSetBilancio, 'WGC_Account_Utility_Bilancio_ResolveEvent')
        .then(result =>{
			console.log('@@@ risultato chiamata bilancio ' , result);
			return helper.apex(component, helper, 'callServiceEventiNegativi', {accountId : recordId}, isTrueSetEventoNegativo, 'WGC_Account_Utility_EventiNegativi_ResolveEvent');
		})
		.then(result => {
			//helper.resolveAction('complete', result, 'WGC_Account_Utility_EventiNegativi_ResolveEvent');
			helper.hideSpinner(component);
			console.log('@@@ risultato Eventi Negativi ' , result);
		});
	},

	reInit : function(component, event, helper) {
		console.log("json: ", event.getParam("json"));
		console.log("REINIT REFRESH");
		setTimeout(function(){
			console.log("REINIT REFRESH AFTER TIMEOUT");
			$A.get('e.force:refreshView').fire();
		}, 5000);
		
	}
})