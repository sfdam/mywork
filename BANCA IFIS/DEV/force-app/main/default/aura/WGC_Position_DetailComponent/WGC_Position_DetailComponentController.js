({
	doInit : function(component, event, helper) {
		helper.showSpinner(component, event);

		helper.apex(component, event, "getPositionPercent", {accountId : component.get("v.recordId")} ,true)
		.then(result =>{
			console.log('@@@ result primo metodo ' , result);
			if(result.success){
				//Counter utilizzati per attributo che mostra i dati, se presenti
				//o messaggio quando non ci sono posizioni disponibili
				var counterImpiego = 0;
				var counterAccordato = 0;
				result.data[0].forEach((item, index) =>{
					//Impiego
					var adjustPercentImpiego = 0;
					var posImpiego = item.percentualiImpiego;

					
					for(var key in posImpiego){
						counterImpiego += posImpiego[key];

						if(posImpiego[key] < 20 && key.toUpperCase() != ("percentAltro").toUpperCase()){
							adjustPercentImpiego += posImpiego[key];
						}
					}
					posImpiego.percentAltro += adjustPercentImpiego;

					//Accordato
					var adjustPercentAccordato = 0;
					var posAccordato = item.percentualiAccordato;
					

					for(var key in posAccordato){

						counterAccordato += posAccordato[key];
						
						if(posAccordato[key] < 20 && key.toUpperCase() != ("percentAltro").toUpperCase()){
							adjustPercentAccordato += posAccordato[key];
						}
					}
					posAccordato.percentAltro += adjustPercentAccordato;
				});
				component.set("v.responsePercent", result.data[0]);
				console.log('@@@ percent ' , component.get("v.responsePercent"));

				console.log('@@@ counterImpiego ' , counterImpiego);
				console.log('@@@ counterAccordato ' , counterAccordato);
				if(counterImpiego == 0 && counterAccordato == 0){
					component.set("v.showData", false);
				}
			}
			return helper.apex(component, event, "getRecordData" , {recordId : component.get("v.recordId")}, true)
		})
		.then(result =>{
			console.log('@@@ result 2 ' , result);
			if(result.success){
				component.set("v.response", result);
				
				var counter = 0;
				for(var key in result.data[0]){
					console.log('@@@ result.data[0][key] ' , result.data[0][key]);
					counter += result.data[0][key].length;
    				if(result.data[0][key].length > 0){
						console.log('SV result.data[0][key][0] ' , result.data[0][key][0].posizione.RecordType.DeveloperName);
						if(result.data[0][key][0].posizione.RecordType.DeveloperName == 'FACTORINGCEDENTE'){
                            let d = new Date(result.data[0][key][0].posizione.LastModifiedDate);
                            let formattedDate = Intl.DateTimeFormat(undefined, {
                                year: 'numeric',
                                month: 'numeric',
                                day: 'numeric',
                                hour: 'numeric',
                                minute: 'numeric',
                                second: 'numeric'
                            }).format(d);
                            component.set('v.lastUpdateFactCedente', formattedDate);
                        }
					}
				}

				if(counter > 0){
					component.set("v.showRecord", true);
				}

				helper.hideSpinner(component, event);
			}
		});
	},

	
})