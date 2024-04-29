({
	convalidaDati : function(component, event, helper) {
		var doc = component.get('v.relazione');
		var err = component.get('v.errors');

		//Controllo la somma delle clientela pubblica e privata
		if((doc.ClientelaFornitoriPub__c + doc.ClientelaFornitoriPriv__c) != 100 ){
			component.set('v.sommaPubPriv', true);
		}
		else{
			component.set('v.sommaPubPriv', false);
			var element = component.find('inputPub');
			$A.util.removeClass(element, ' input-error ');
		}

		//Controllo la somma delle clientela nazionale e estera
		if((doc.ClientelaFornitoriNaz__c + doc.ClientelaFornitoriEst__c) != 100 ){
			console.log('@@@ somma ' , (doc.ClientelaFornitoriNaz__c + doc.ClientelaFornitoriEst__c));
			component.set('v.sommaNazEst', true);
		}
		else{
			component.set('v.sommaNazEst', false);
			var element = component.find('inputNaz');
			$A.util.removeClass(element, ' input-error ');
		}

		//Controllo somma continuativa + spot
		if((doc.FornituraOrdinativiCont__c + doc.FornituraOrdinativiSpot__c) != 100){
			component.set('v.sommaContSpot', true);
		}
		else{
			component.set('v.sommaContSpot', false);
			var element = component.find('inputCont');
			$A.util.removeClass(element, ' input-error ');
		}

		//Controllo la somma di altri 4 campi fornitura
		if((doc.AppaltoOperaFornituraConPosa__c + doc.AppaltoDiServiziFornOrd__c + doc.FornituraBeni__c + doc.FornituraServizi__c) != 100){
			component.set('v.sommaAppForn', true);
		}
		else{
			component.set('v.sommaAppForn', false);
			var element = component.find('inputForn');
			$A.util.removeClass(element, ' input-error ');
		}

		//Controllo sulla somma delle percentuali
		if(component.get('v.sommaPubPriv') == true || component.get('v.sommaNazEst') == true 
			|| component.get('v.sommaContSpot') == true || component.get('v.sommaAppForn') == true){
				
				//se trovo errori, metto il focus all'inizio del documento
				if(component.get('v.sommaPubPriv') == true){
					var element = component.find('inputPub');
					element.focus();
					$A.util.addClass(element, ' input-error ');
				}
				if(component.get('v.sommaNazEst') == true){
					var element = component.find('inputNaz');
					element.focus();
					$A.util.addClass(element, ' input-error ');
				}
				if(component.get('v.sommaContSpot') == true){
					var element = component.find('inputCont');
					element.focus();
					$A.util.addClass(element, ' input-error ');
				}
				if(component.get('v.sommaAppForn') == true){
					var element = component.find('inputForn');
					element.focus();
					$A.util.addClass(element, ' input-error ');
				}				

				return false;
		}
		var counter = 0;

		console.log('@@@ Object.values ' , Object.values(doc));

		/*//Controllo che tutti i campi siano stati popolati
		var arrayProp = Object.values(doc);

		arrayProp.forEach(function(item){
			if((item == null || item == '' || item == undefined || item != 0) && item != 'Note__c'){
				//se manca qualche campo setto un messaggio di errore ad inizio pagina con focus
				console.log('@@@ item ' , item);
				counter ++;
				console.log('@@@ counter ' , counter);
			}
		});*/

		for(var key in doc){
			console.log('@@@ element ' , key);
			console.log('@@@ type element ' , typeof doc[key]);
			console.log('@@@ element ' , JSON.stringify(doc[key]));
			if((doc[key] == null || doc[key] == undefined || doc[key] == "" || doc[key] == '--Nessuno--' || doc[key] == " ") && key != 'Note__c'){
				console.log('@@@ element 2 ' , JSON.stringify(doc[key]));
				console.log('@@@ element parseInt ' , parseInt(doc[key]));
				if(parseInt(doc[key]) != 0){
					counter ++;
					console.log('@@@ doc[key] ' , doc[key]);
					console.log('@@@ key ' , key);
					console.log('@@@ counter in for ' , counter);
				}
				
			}
		}

		console.log('@@@ counter err ' , counter);
		if(counter > 0){
			//Setto il focus al primo campo
			var element = component.find('inputPub');
			element.focus();
			var notify = component.find('notifLib');
			notify.showNotice({
				"variant": "error",
				"header": "Errore",
				"message": "Compila tutti i campi correttamente",
				closeCallback: function() {
					//alert('You closed the alert!');
				}
			});
			return false;
		}

	}
})