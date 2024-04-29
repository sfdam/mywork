({
    ottieniDati: function (component, event) { // devo ottenere i listini disponibili io quindi una funzione simile a questa
		$A.util.addClass(component.find("mySpinner"), "slds-show");
		console.log('suamo in ottieni dati');
		component.set("v.inClone", true);
		let action = component.get("c.ottieniDati");
	
		action.setParams({
			recordId: component.get("v.recordId"),
		});
		action.setCallback(this, function (response) {
			let state = response.getState();
		
			if (state === "SUCCESS") {
				let label = response.getReturnValue();
				if(label["Status Quote"]!= 'Presented' && label["Status Quote"]!= 'Accepted'){
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						message: 'You cannot amend a quote without status Presented or Accepted',
						type: "error",
					});
					toastEvent.fire();
					var dismissActionPanel = $A.get("e.force:closeQuickAction");
					dismissActionPanel.fire();

				}else if(label["Type"]!='Amendment' && label["Type"]!='Order Confirmation'){
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						message: 'You cannot amend a quote without type Amendment or Order Confirmation',
						type: "error",
					});
					toastEvent.fire();
					var dismissActionPanel = $A.get("e.force:closeQuickAction");
					dismissActionPanel.fire();
				}else{
					
					component.set("v.inClone", false);
					component.set("v.quoteName",label["Nome Quote"]);
					component.set("v.quoteStatus",label["Status Quote"]);
					component.set("v.quoteAccount",label["Account"]);
					component.set("v.disable",(label["Disable"]==='true'));
					component.set("v.quotePriceBook", label["Pricebook"]);
					component.set("v.selectedLookUpRecord",JSON.parse(label["DefaultPricebook"])[0]);
					component.set("v.queryCondition",label["wherePricebook"]);
					component.set("v.country",label["country"]);
					
					console.log(label["disable"]);
					console.log(component.get("v.disable"));
					//console.log(JSON.parse(component.get("v.selectedLookUpRecord")));

					component.set("v.loaded",true);
				}
			}else if (state === "ERROR"){
				this.showErrorToast(
					component,
					event,
					helper,
					"C'è stato un errore, ricarica la pagina"
				);
				console.log("Error: " + JSON.stringify(response.error));
			}else{
				console.log(
					"Problema Sconosciuto, stato: " +
					state +
					", errore: " +
					JSON.stringify(response.error)
				);
			}
			$A.util.removeClass(component.find("mySpinner"), "slds-show");
		});
		$A.enqueueAction(action);
	},

      clonaQuote:function(component,event){
		$A.util.addClass(component.find("mySpinner"), "slds-show");
		component.set("v.inClone", true);
		console.log('siamo in clona quote js');
        // var oldPriceBook = JSON.stringify (component.get("v.quotePriceBook"))
        // var newPriceBook = JSON.stringify (component.get("v.selectedId")) || oldPriceBook
		var oldPriceBook = component.get("v.quotePriceBook");
		var newPriceBook =component.get("v.selectedLookUpRecord")

		//let newPriceBook = oldPriceBook

        console.log(oldPriceBook);
		console.log(newPriceBook);

        let action = component.get("c.clonaQuoteAmend");

        action.setParams({
            idQuote: component.get("v.recordId"),
            idOldListino: oldPriceBook,
            idNewListino: newPriceBook.Id
        });

        action.setCallback(this, function (response) { //da qui prendi tutto com'è
			let state = response.getState();
			console.log(response.getReturnValue());
	  
			if (state === "SUCCESS") {
			  console.log(state);
			  console.log(response.getReturnValue());
			  $A.get("e.force:closeQuickAction").fire();
			  this.showSuccessToast(
				component,
				event,
				helper,
				"Quote clonata correttamente!"
			  );
			  var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
				"recordId": response.getReturnValue().Id,
				 "slideDevName": "related"
				});
				navEvt.fire();
			} else if (state === "ERROR") {
			  console.log(JSON.parse(JSON.stringify(response.getError()))[0].message);
			  if(JSON.stringify(response.getError()))
			  {
				$A.get("e.force:closeQuickAction").fire();
				this.showErrorToast(
				component,
				event,
				helper,
				JSON.parse(JSON.stringify(response.getError()))[0].message
				);
			  }
			  else{
				$A.get("e.force:closeQuickAction").fire();
				this.showErrorToast(
				component,
				event,
				helper,
				"C'è stato un errore, ricarica la pagina"
			  );}
	  
			 console.log("Error: " + JSON.stringify(response.error));
			} else {
			  console.log(
				"Problema Sconosciuto, stato: " +
				  state +
				  ", errore: " +
				  JSON.stringify(response.error)
			  );
			}
			$A.util.removeClass(component.find("mySpinner"), "slds-show");
		  });
		  $A.enqueueAction(action);
	  },
      showSuccessToast: function (component, event, helper, messaggio) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
		  message: messaggio,
		  type: "success",
		});
		toastEvent.fire();
	  },
	  showErrorToast: function (component, event, helper, messaggio) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
		  message: messaggio,
		  type: "error",
		});
		toastEvent.fire();
	  }
})