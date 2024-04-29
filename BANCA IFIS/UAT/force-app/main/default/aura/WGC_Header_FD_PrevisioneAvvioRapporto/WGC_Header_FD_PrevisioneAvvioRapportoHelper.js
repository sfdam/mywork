({
	getPrevisioneAvvioRapporto : function(component, event, helper) {
		var isDirezioneFD = component.get("v.isDirezioneFD");
		var action = component.get("c.getTaskPrevisioneAvvioRapporto");
		action.setParams({
			"isDirezioneFD" : isDirezioneFD
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();

				if(risposta.success){
					console.log('@@@ risposta par ' , risposta.data);
					component.set("v.countPrevisioneAvvioRapporto", risposta.data[0].length);
				}
				else{
					console.log('@@@ error msg ' , risposta.msg);
				}
			}
			else{
				console.log('@@@ error in calling server side ' , response.getError());
			}
		});

		$A.enqueueAction(action);
	},

	getFilteredData : function(component, event, helper, parametri){
		var action = component.get("c.getTaskPrevisioneAvvioRapporto_Filtered");
		action.setParams({
			"userId" : parametri.userId,
			"teamName" : parametri.teamName,
			"isAllUser" : parametri.isAllUser
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();

				if(risposta.success){
					console.log('@@@ risposta par ' , risposta.data);
					component.set("v.countPrevisioneAvvioRapporto", risposta.data[0].length);
				}
				else{
					console.log('@@@ error msg ' , risposta.msg);
				}
			}
			else{
				console.log('@@@ error in calling server side ' , response.getError());
			}
		});

		$A.enqueueAction(action);
	},
})