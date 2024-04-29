({
	getElementAccount: function (component, event) {

        var action = component.get("c.getElementAccount");
        console.log(component.get("v.recordId"));
		action.setParams({
            "accountId": component.get("v.recordId")
		});
        //Setting the Callback
        action.setCallback(this,function(response){
            //get the response state
            var state = response.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                console.log("SUCCESS");
                var result = response.getReturnValue();
                console.log('@@@ rs');
                console.log(result);
                
                component.set('v.result', result.data[0]);
                
                console.log('SV NU')
				
				component.set('v.numFornitori', result.data[0].soggettiCollegati.fornitori);
				component.set('v.numClienti', result.data[0].soggettiCollegati.clienti);
				component.set('v.numCompetitor', result.data[0].soggettiCollegati.competitor);
				component.set('v.numFCI', result.data[0].soggettiCollegati.fci);
				component.set('v.numTribunali', result.data[0].soggettiCollegati.tribunali);
				component.set('v.numIntermediariLeasing', result.data[0].soggettiCollegati.partner);
				component.set('v.numGruppo', result.data[0].soggettiCollegati.gruppo);
                component.set('v.numGeografia', result.data[0].soggettiCollegati.geografia);
                component.set('v.numRefEffettuati', result.data[0].soggettiCollegati.referralEffettuati);
				component.set('v.numRefRicevuti', result.data[0].soggettiCollegati.referralRicevuti);				

            } else if(state == "ERROR"){
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });
		$A.enqueueAction(action);
    },
})