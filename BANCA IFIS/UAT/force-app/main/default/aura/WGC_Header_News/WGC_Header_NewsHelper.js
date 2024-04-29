({
	initialize : function(component, event, helper) {
		var action = component.get("c.getNews");
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				console.log('@@@ risposta ' , risposta);
				if(risposta.success){
					//Formatto la data per mostrarla nel component
					this.formatDate(component, event, helper, risposta.data);
					
					component.set("v.news" , risposta.data);
					console.log('@@@ news ' , component.get("v.news"));

				}
				else{
					console.log('@@@ nessuna news ' , risposta.message);
				}

			}
			else{

			}
		});
		$A.enqueueAction(action);

	},

	formatDate : function(component, event, helper, listaNews){
		//Formatto la data di ogni news in modo da poter separe giorno e mese
		listaNews.forEach((item, index) =>{
			var dataTmp = new Date(item.Data_News__c);
			var options = { year: 'numeric', month: 'long', day: 'numeric' };
			item.Data_News__c = dataTmp.toLocaleDateString('it-IT', options);
		});
	},
})