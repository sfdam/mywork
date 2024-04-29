({
	helperMethod : function() {
		
	},

	apex: function (component, event, apexAction, params) {
		var p = new Promise($A.getCallback(function (resolve, reject) {
			var action = component.get("c." + apexAction + "");
			action.setParams(params);
			action.setCallback(this, function (callbackResult) {
				if (callbackResult.getState() == 'SUCCESS') {
					resolve(callbackResult.getReturnValue());
				}
				if (callbackResult.getState() == 'ERROR') {
					console.log('ERROR', callbackResult.getError());
					reject(callbackResult.getError());
				}
			});
			$A.enqueueAction(action);
		}));
		return p;
	},

	fetchPickListVal: function (component, fieldName, object, elementId) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": object,
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log(allValues);

                opts.push({
                    class: "optionClass",
                    label: "All",
                    value: "all"
                });

                for (var k in allValues) {
                    opts.push({
                        class: "optionClass",
                        label: k,
                        value: allValues[k],
                        selected: component.get('v.userQualifica') == allValues[k] ? true : false
                    });
				}
				
                component.set("v." + elementId, opts);
            }
        });
        $A.enqueueAction(action);
    },

    dataProcess: function (component, event, data) {
        var choiseObj = component.get('v.choiseObj');

        var elementList = [];
        if(choiseObj.attivita == 'all' || choiseObj.attivita == 'visite' || choiseObj.attivita == 'taskevisite'){
            data.eventList.forEach(function (element) {
                if(choiseObj.userQualifica == 'all' || choiseObj.userQualifica == element.WGC_Qualifica_Utente_Owner__c){
                    element.objectType = 'Event';
                    element.isCollapsed = false;
                    //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
                    elementList.push(element);
                }
            });
        }

        if(choiseObj.attivita != 'visite'){
            data.taskList.forEach(function (element) {
                if(choiseObj.userQualifica == 'all' || choiseObj.userQualifica == element.WGC_Qualifica_Utente_Owner__c){
                    if(choiseObj.attivita == 'diario_Opportunita' && element.RecordType.DeveloperName.includes('Diario_Nuova_Opportunita')){
                        element.objectType = 'Diario';
                        element.isCollapsed = false;
                        //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
                        elementList.push(element);
                    } else if(choiseObj.attivita == 'diario_Campagna' && element.RecordType.DeveloperName.includes('Diario_Inserimento_Campagna')){
                        element.objectType = 'Diario';
                        element.isCollapsed = false;
                        //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
                        elementList.push(element);
                    } else if(choiseObj.attivita == 'promemoria' && element.RecordType.DeveloperName.includes('Promemoria')){
                        element.objectType = 'Promemoria';
                        element.isCollapsed = false;
                        //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
                        elementList.push(element);
                    } else if((choiseObj.attivita == 'task' || choiseObj.attivita == 'taskevisite') && !element.RecordType.DeveloperName.includes('Diario') && !element.RecordType.DeveloperName.includes('Promemoria')){
                        element.objectType = 'Task';
                        element.isCollapsed = false;
                        //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
                        elementList.push(element);
                    } else if(choiseObj.attivita == 'all'){
                        element.objectType = element.RecordType.DeveloperName.includes('Promemoria') ? 'Promemoria' : element.RecordType.DeveloperName.includes('Diario') ? 'Diario' : 'Task';
                        element.isCollapsed = false;
                        //element.WGC_Qualifica_Utente_Owner__c = element.WGC_Qualifica_Utente_Owner__c.replace(/_/g, " ");
                        elementList.push(element);
                    }
                }
            });
        }

        elementList.sort( this.compare );

		return elementList;
    },
    
    compare: function  ( first, second ) {
        var a = new Date(first.ActivityDate);
        var b = new Date(second.ActivityDate);
        if ( a < b ){
          return 1;
        }
        if ( a > b ){
          return -1;
        }
        return 0;
    }
})