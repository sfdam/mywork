({
	initialize : function(component, event, helper) {
		var isRSF = component.get("v.isRSF");
		console.log('@@@ isRSF ' , isRSF);
		var action = component.get("c.getLanguage");
		action.setParams({
			"isRSF" : isRSF
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				if(risposta.success){
					console.log('@@@ risposta lingue ' , risposta.data[0]);
					
					var listaLingue = [];
					for(var key in risposta.data[0]){
						console.log('@@@ risposta.data[0][key] ' , risposta.data[0][key]);
						console.log('@@@ key ' , key);
						if(key == 'Italiano'){
							console.log('@@@ Italiano' );
							component.set("v.linguaScelta", risposta.data[0][key]);
						}

						listaLingue.push({"label" : key, "value" : risposta.data[0][key] });
					}

					console.log('@@@ listaLingue ' , listaLingue);
					component.set("v.lingue", listaLingue);
				}
				else{
					console.log('@@@ risposta error ' , risposta.message);
				}
			}
			else{
				console.log('@@@ apex error ' , response.getError());
			}

			component.set("v.isLoaded", true);
		});
		$A.enqueueAction(action);
	},

	selezionaLingua : function(component, event, helper){
		var scelta = component.get("v.linguaScelta");		
		//Attributo referenziato nel componente documenti per prendere la lingua in base alla scelta e a produrre un doc diverso
		component.set("v.modalBodyAttributeName", scelta);

		component.find('overlayLib').notifyClose();

	},
})