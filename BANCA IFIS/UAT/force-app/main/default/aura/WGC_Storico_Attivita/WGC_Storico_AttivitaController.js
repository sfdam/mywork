({
	doInit : function(component, event, helper) {
		var choiseObj = component.get('v.choiseObj');
        console.log('SV choiseObj', JSON.stringify(choiseObj));

        helper.apex(component, event, 'getUserInfo', {  })
        .then($A.getCallback(function (result) {
            console.log('Call getUserInfo result: ', result);
            component.set('v.userInfo', result);
            helper.fetchPickListVal(component, 'Qualifica_Utente__c', component.get("v.userInfo"), 'InputPicklistQualificaUtente');

            return helper.apex(component, event, 'getAllData', { "accId": component.get("v.recordId") });
            
        })).then($A.getCallback(function (result) {
            console.log('Call getAllData result: ', result);
            component.set('v.allDataValue', result.data[0]); 
            
        })).finally($A.getCallback(function () {

            //component.set('v.userQualifica', component.get('v.userInfo').Qualifica_Utente__c);
            component.set('v.attivita', 'taskevisite');
           
            
        }));

		
    },
    
    setFilter : function(component, event, helper) {
		
        var choiseObj = component.get('v.choiseObj');
        choiseObj.attivita = component.get('v.attivita');
        choiseObj.userQualifica = component.get('v.userQualifica');
        console.log('SV choiseObj', JSON.stringify(choiseObj));

        component.set('v.choiseObj', choiseObj);

        var result = component.get('v.allDataValue');

        component.set('v.allDataChoiseValue', helper.dataProcess(component, event, result));
	}
})