({
    doInit : function(component, event, helper) {
		//Setting the Callback
        var action = helper.apexPromise(component,'c.GetPassoCommercialeData');
        action.then(
            function(res) {
                
				component.set("v.passoCommercialeList",res);

				console.log(res);
            }
		).catch(
			function(error) { 
				console.log(error);
			}
		).finally(() => {
			console.log('finally');
			
			let passoCommerciale = component.get("v.passoCommercialeList");
			let today = new Date();
			let currentMonth = today.getMonth();
			let currentYear = today.getFullYear();
			console.log('passoCommerciale' + passoCommerciale);

			for (var i = 0; i < passoCommerciale.length; i++) {
				var record = passoCommerciale[i];
				var actualPratiche = record.Actual_Pratiche__c;
				var actualVisite = record.Actual_visite__c;
				var mese = record.Mese__c;
				var anno = record.Anno__c;
				var passoPratiche = record.Passo_Pratiche__c;
				var passoVisite = record.Passo_Visite__c;
				var actualVisiteThisMonth = 0;
				var passoVisiteThisMonth = 0;
				var sumResiduoVisite = 0;
				var sumActual = 0;
				var sumPasso = 0;
				var CircleColour;
				
				if (actualPratiche < passoPratiche) {
					CircleColour = "red"; // Cerchio rosso
				} else  {
					CircleColour = "green"; // Cerchio verde
				} 
				
				if (mese < currentMonth) {
					sumActual += actualVisite;
					sumPasso += passoVisite;
					sumResiduoVisite += residuoVisite;
				} else if (mese === currentMonth) {
					actualVisiteThisMonth += actualVisite;
					passoVisiteThisMonth += passoVisite;
				}
			}

			component.set("v.actualVisiteThisMonth",actualVisiteThisMonth);
			component.set("v.passoVisiteThisMonth",passoVisiteThisMonth);
			component.set("v.sumResiduoVisite",sumResiduoVisite);
			component.set("v.sumActual",sumActual);
			component.set("v.sumPasso",sumPasso);
			component.set("v.CircleColour",CircleColour);
			
			console.log("actualVisiteThisMonth: " + actualVisiteThisMonth);
			console.log("passoVisiteThisMonth: " + passoVisiteThisMonth);
			console.log("sumResiduoVisite: " + sumResiduoVisite);
			console.log("sumActual: " + sumActual);
			console.log("sumPasso: " + sumPasso);
			console.log("CircleColour: " + CircleColour);

	})
    },

    viewAll : function(component, event, helper) {

		var navService = component.find("navService");
        var pageReference = {    
			"type": "standard__recordPage",
			"attributes": {
				"recordId": component.get("v.vediTutteReportId"),
				"objectApiName": "Report",
				"actionName": "view"
			}
	 	}

		navService.generateUrl(pageReference).then($A.getCallback(function(url) {
			window.open(url, '_self');
		}));
        // navService.navigate(pageReference);
    }
})