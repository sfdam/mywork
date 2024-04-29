({
	setupSezioniEParametri : function(component) {
		var parametriEConfigurazioniLinee = component.get("v.parametriEConfigurazioniLinee");
		var spinner = component.find("mySpinner");

		if (parametriEConfigurazioniLinee != null) {
			var sezioni = parametriEConfigurazioniLinee.sezioni;
			var parametri = parametriEConfigurazioniLinee.parametri;
			// var obj = [{ title: "sezione" , params: [{  }] }];
			var sectionsMap = [];
			var insertedSections = [];
			var result = [];

			for (var s in sezioni)
				sectionsMap[sezioni[s].Label] = sezioni[s].NomeSezione__c;

			for (var p in parametri) {
				if (parametri[p].sottosezione == undefined || parametri[p].sottosezione == null) {
					if (insertedSections.indexOf(parametri[p].sezione) < 0) {
						insertedSections.push(parametri[p].sezione);
						result.push({ title: sectionsMap[parametri[p].sezione] , parameters: [ parametri[p] ] });
					}
					else
						result[insertedSections.indexOf(parametri[p].sezione)].parameters.push(parametri[p]);
				}
				else {
					if (insertedSections.indexOf(parametri[p].sottosezione) < 0) {
						insertedSections.push(parametri[p].sottosezione);
						result.push({ title: sectionsMap[parametri[p].sottosezione] , parameters: [ parametri[p] ] });
					}
					else
						result[insertedSections.indexOf(parametri[p].sottosezione)].parameters.push(parametri[p]);
				}
			}

			console.log(result);

			component.set("v.sezioneParametriMap", result);

        	$A.util.addClass(spinner, "slds-hide");
		}
		else
			$A.util.removeClass(spinner, "slds-hide");
	}
})