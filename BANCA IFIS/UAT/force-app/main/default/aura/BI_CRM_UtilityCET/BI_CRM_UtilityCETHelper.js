({
	handlerGoToReport: function (component) {
	    var navService = component.find("navService");
		var pageReference = {};
		var pg = {};
	    var funzione = component.get('v.funzione');
		
		switch (funzione) {
          case "NDG":
		    pageReference = {
				type: "standard__recordPage",
				attributes: {
					recordId: component.get('v.idReport'),
					objectApiName: "Report",
					actionName: "view"
				},
				state: {
					fv0: component.get('v.ndg'),
				}
			};

			pg = {
		         type: "standard__navItemPage",
		         attributes: {
                    apiName: "Cruscotto_CET_New"
		          }
		    };
			break;
		
		  case "Opportunity":
		    pageReference = {
				type: "standard__recordPage",
				attributes: {
					recordId: component.get('v.idReport'),
					objectApiName: "Report",
					actionName: "view"
				},
				state: {
					fv0: component.get('v.oppo'),
				}
			};

			pg = {
		         type: "standard__navItemPage",
		         attributes: {
                    apiName: "Cruscotto_CET_New"
		          }
		    };
			break;
		
		  case "Clienti":
		    console.log('@@@A.M. Client-accountName ', component.get('v.accountName'));
		    pageReference = {
				type: "standard__recordPage",
				attributes: {
					recordId: component.get('v.idReport'),
					objectApiName: "Report",
					actionName: "view"
				},
				state: {
					fv0: component.get('v.accountName'),
				}
			};
			pg = {
		         type: "standard__recordPage",
		         attributes: {
					recordId: component.get('v.idAccount'),
                    objectApiName: "Account",
					actionName: "view"
		          }
		    };
			break;
		  case "Fornitori":
		    console.log('@@@A.M. Fornitori-accountName ', component.get('v.accountName'));

		    pageReference = {
				type: "standard__recordPage",
				attributes: {
					recordId: component.get('v.idReport'),
					objectApiName: "Report",
					actionName: "view"
				},
				state: {
					fv0: component.get('v.accountName'),
				}
			};
			pg = {
		         type: "standard__recordPage",
		         attributes: {
					recordId: component.get('v.idAccount'),
                    objectApiName: "Account",
					actionName: "view"
		          }
		    };
			break; 
		}

		//APERTURA NUOVO TAB (REPORT)
		//Se il report deve essere aperto nello stesso tab basta usare "navService.navigate(pageReference);" e non generateUrl (con windows.open)
		navService.generateUrl(pageReference)
			.then($A.getCallback(function(url) {
			    window.open(url,'_blank');
			}),
			$A.getCallback(function(error) {
				console.log('@@Errore: '+ error);
			}));

		//RICARICA LA PAGINA "OLD"
		navService.navigate(pg);
	},

	assegnaRecord: function (component, event) {
	   console.log('@@@A.M. idRecordCET ', component.get('v.idRecordCET'));
	   this.callServer(component, "c.assegnaRecord", 
	   function (result) {
        // console.log("callServer --result: ", result);
        console.log('@@@A.M. assegnaRecord: ', result);
		//Dopo aver fatto l'assegnazione ricarica la pagina attuale		
		var navigator = component.find("navService");
        var pg = {
                type: "standard__navItemPage",
                attributes: {
                    apiName: "Cruscotto_CET_New"
                }
         }
        navigator.navigate(pg);
      },
	   {idRecordCet: component.get("v.idRecordCET")});
	},

	recuperaNdg: function (component, event) {
		let h = this;
		console.log('@@@A.M. recuperaNdg-idRecordCET ', component.get('v.idRecordCET'));
		
		this.callServerSync(component, "c.recuperaNdgCET", {idRecordCet: component.get("v.idRecordCET")})
		.then( $A.getCallback(function (result) {
			component.set("v.ndg", result.NDG_Anagrafica__c);
			console.log('@@@A.M. recuperaNdg-NDG ', result.NDG_Anagrafica__c);
			h.handlerGoToReport(component);
		}));
	},

	datiAnagrafica: function (component, event) {
		let h = this;
		console.log('@@@A.M. datiAnagrafica-idAccount ', component.get('v.idAccount'));
		
		this.callServerSync(component, "c.datiAnagrafica", {idAccount: component.get("v.idAccount")})
		.then( $A.getCallback(function (result) {
			component.set("v.accountName", result.Name);
			console.log('@@@A.M. datiAnagrafica-Name ', result.Name);
			h.handlerGoToReport(component);
		}));
	}
})