({
	doInit: function (component, event, helper) {
		helper.getSogettiCollegati(component.get("v.recordId"), component, event);
	},

	handlerGoToReport: function (component, event, helper) {
		var tipo = component.get('v.type');
		// var urlEvent = $A.get("e.force:navigateToURL");

		// if(tipo == 'Competitors'){
		// 	urlEvent.setParams({
		// 		"url": "/lightning/r/Report/" + component.get('v.idReport') + "/view?fv0=" + component.get('v.accountRecord.Ateco__c') + "&fv2=" + component.get('v.recordId') + "&fv3=" + component.get('v.accountRecord.CodiceIstituto3N__c')
		// 	});
		// } else if(tipo == 'Vicinanza geografica'){
		// 	urlEvent.setParams({
		// 		"url": "/lightning/r/Report/" + component.get('v.idReport') + "/view?fv0=" + component.get('v.accountRecord.BillingPostalCode') + "&fv2=" + component.get('v.recordId') + "&fv3=" + component.get('v.accountRecord.CodiceIstituto3N__c')
		// 	});
		// } else if(tipo == 'Tribunali'){
		// 	urlEvent.setParams({
		// 		"url": "/lightning/r/Report/" + component.get('v.idReport') + "/view?fv2=" + component.get('v.recordId')
		// 	});
		// }

		// urlEvent.fire();

		var navService = component.find("navService");
		var pageReference = {};
		//adione - CR ID82 - fasce di Fatturato per report Competitor
		var midFatt=10000; //10 milioni in migliaia
		var maxFatt=50000; //50 milioni in migliaia
		var min,max=0;
		if (component.get('v.accountRecord.Fatturato__c') >= maxFatt) {
			min=midFatt;
			max=maxFatt;
		} else if (component.get('v.accountRecord.Fatturato__c') >= midFatt) {
			min=midFatt;
			max=maxFatt;
		} else {
			min=0;
			max=midFatt;
		}
		if (tipo == 'Competitors') {
			pageReference = {
				"type": "standard__recordPage",
				"attributes": {
					"recordId": component.get('v.idReport'),
					"objectApiName": "Report",
					"actionName": "view"
				},
				"state": {
					"fv0": component.get('v.accountRecord.Ateco__c'),
					"fv2": component.get('v.recordId'),
					"fv3": component.get('v.accountRecord.CodiceIstituto3N__c'),
					"fv4": min,
					"fv5": max,
                    //A.M. CR334 -> Start
                    "fv6": component.get('v.accountRecord.BillingState')
                    //A.M. CR334 -> End
				}
			},
			{
				replace: false
			};

		} else if (tipo == 'Vicinanza geografica') {
			pageReference = {
				"type": "standard__recordPage",
				"attributes": {
					"recordId": component.get('v.idReport'),
					"objectApiName": "Report",
					"actionName": "view"
				},
				"state": {
					"fv1": component.get('v.recordId'),
					"fv2": component.get('v.accountRecord.CodiceIstituto3N__c'),
					"fv3": component.get('v.accountRecord.BillingPostalCode')
				}
			},
			{
				replace: false
			};

		} else if (tipo == 'Tribunali') {
			pageReference = {
				"type": "standard__recordPage",
				"attributes": {
					"recordId": component.get('v.idReport'),
					"objectApiName": "Report",
					"actionName": "view"
				},
				"state": {
					"fv2": component.get('v.recordId')
				}
			},
			{
				replace: false
			};
		}

		var sPageURL = window.location.protocol + '//' + window.location.hostname;
		var sPagePATH = '/lightning/r/Report/' + component.get('v.idReport') + '/view?';
		var sPagePARAMS = '';
		if (tipo == 'Competitors') {
			sPagePARAMS = sPagePARAMS + "fv0=" + component.get('v.accountRecord.Ateco__c');
			sPagePARAMS = sPagePARAMS + "&fv2=" + component.get('v.recordId');
			sPagePARAMS = sPagePARAMS + "&fv3=" + component.get('v.accountRecord.CodiceIstituto3N__c');
			sPagePARAMS = sPagePARAMS + "&fv4=" + min;
			sPagePARAMS = sPagePARAMS + "&fv5=" + max;
            //A.M. CR334 -> Start
            sPagePARAMS = sPagePARAMS + "&fv6=" + component.get('v.accountRecord.BillingState');
            //A.M. CR334 -> End
		} else if (tipo == 'Vicinanza geografica') {
			sPagePARAMS = sPagePARAMS + "&fv1=" + component.get('v.recordId');
			sPagePARAMS = sPagePARAMS + "&fv2=" + component.get('v.accountRecord.CodiceIstituto3N__c');
			sPagePARAMS = sPagePARAMS + "&fv3=" + component.get('v.accountRecord.BillingPostalCode');
		} else if (tipo == 'Tribunali') {
			sPagePARAMS = sPagePARAMS + "fv2=" + component.get('v.recordId');
		} else if (tipo == 'Gruppi') {
			sPagePARAMS = sPagePARAMS + "fv0=" + component.get('v.accountRecord.NDGGruppoGiuridico__c');
			sPagePARAMS = sPagePARAMS + "&fv1=" + component.get('v.recordId');
			sPagePARAMS = sPagePARAMS + "&fv2=" + component.get('v.accountRecord.CodiceIstituto3N__c');
		}

		window.open(sPageURL + sPagePATH + sPagePARAMS, '_blank');

		// navService.navigate(pageReference);

	},
})