({
	doInit : function(component, event, helper) {
	    var funzione = component.get('v.funzione');
		console.log('@@@A.M. doInit.funzione-1 ', funzione);

		switch (funzione) {
          case "NDG":
		  case "Opportunity":
		    console.log('@@@A.M. funzione-NDG ', component.get('v.ndg'));
			console.log('@@@A.M. funzione-oppo ', component.get('v.oppo'));
			helper.handlerGoToReport(component);
			break;

          case "Assegna":
		    helper.assegnaRecord(component, event);
			break;

		  case "Clienti":
		  case "Fornitori":
		    console.log('@@@A.M. funzione-Clienti/Fornitori ', component.get('v.idAccount'));
		    helper.datiAnagrafica(component, event);
			break;

		  case "":
			funzione = 'NDG'
		    component.set("v.funzione", funzione);
		    component.set("v.idReport", '00O7Z0000016IFYUA2');
		    helper.recuperaNdg(component, event);
			break;
		}
	},
})