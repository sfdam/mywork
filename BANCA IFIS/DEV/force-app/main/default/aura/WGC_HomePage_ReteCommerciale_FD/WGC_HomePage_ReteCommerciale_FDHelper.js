({
	initialize : function(component, event, helper) {
		var action = component.get("c.getBestAndBadFiliale");
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();

				if(risposta.success){
					console.log('@@@ risposta rt ' , risposta.data);
					var arr = [];
					arr.push(risposta.data[0].best);
					arr.push(risposta.data[0].bad);
					component.set("v.filiali", arr);
				} else {
					console.log('@@@ error msg ' , risposta.message);
				}
			} else {
				console.log('@@@ errore backend ' , response.getError() );
			}
			
			component.set("v.isLoaded", true);
		});
		$A.enqueueAction(action);
	}
})