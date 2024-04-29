({
	getPastTask : function(component, event, helper) {
		var isDirezioneFD = component.get("v.isDirezioneFD");
		console.log('@@@ isDirezioneFD ' , isDirezioneFD);
		var action = component.get("c.getPastActivityUser_FD");
		action.setParams({
			"isDirezioneFD" : isDirezioneFD
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();

				if(risposta.success){
					console.log('@@@ risposta ' , risposta.data);

					var aziendeDaContattare = risposta.data[0].contattiTelefonici;
					var aziendeDaRisentire = risposta.data[0].ricontattiTelefonici;
					var promemoria = risposta.data[0].promemoria;
					
					// var countAziendeDaContattare = 0;
					// var countAziendeDaRisentire = 0;
					// var countPromemoria = 0;

					// aziendeDaContattare.forEach((item, index) =>{
					// 	countAziendeDaContattare ++;
					// });

					// aziendeDaRisentire.forEach((item, index) =>{
					// 	countAziendeDaRisentire ++;
					// });

					// promemoria.forEach((item, index) =>{
					// 	countPromemoria ++;
					// });

					component.set("v.aziendeDaContattare", aziendeDaContattare.length);
					component.set("v.aziendeDaRisentire", aziendeDaRisentire.length);
					component.set("v.promemoria", promemoria.length);
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
		var action = component.get("c.getPastActivityUser_FD_Filtered");
		action.setParams({
			"userId" : parametri.userId,
			"teamName" : parametri.teamName,
			"isAllUser" : parametri.isAllUser
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				if(risposta.success){
					console.log('@@@ risposta filtered ', risposta.data);
					var aziendeDaContattare = risposta.data[0].contattiTelefonici;
					var aziendeDaRisentire = risposta.data[0].ricontattiTelefonici;
					var promemoria = risposta.data[0].promemoria;
					
					// var countAziendeDaContattare = 0;
					// var countAziendeDaRisentire = 0;
					// var countPromemoria = 0;

					// aziendeDaContattare.forEach((item, index) =>{
					// 	countAziendeDaContattare ++;
					// });

					// aziendeDaRisentire.forEach((item, index) =>{
					// 	countAziendeDaRisentire ++;
					// });

					// promemoria.forEach((item, index) =>{
					// 	countPromemoria ++;
					// });

					component.set("v.aziendeDaContattare", aziendeDaContattare.length);
					component.set("v.aziendeDaRisentire", aziendeDaRisentire.length);
					component.set("v.promemoria", promemoria.length);
				} else {
					console.log('@@@ error msg ' , risposta.message);
				}
			} else {
				console.log('@@@ error ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	},
})