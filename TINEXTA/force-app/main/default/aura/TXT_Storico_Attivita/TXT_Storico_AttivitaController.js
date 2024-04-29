({
	doInit : function(component, event, helper) {


        helper.apex(component, event, 'getUserInfo', {  })
        .then($A.getCallback(function (result) {
            console.log('Call getUserInfo result: ', result);
            component.set('v.userInfo', result);
            
            return helper.apex(component, event, 'getAllData', { "accId": component.get("v.recordId"), "societa": result.Societa__c });
        })).then($A.getCallback(function (result) {
            console.log('Call getAllData result: ', result);
            component.set('v.allDataValue', result.data[0]); 
            
        })).finally($A.getCallback(function () {
           
            component.set('v.allDataChoiseValue', helper.dataProcess(component, event, component.get('v.allDataValue')));
        }));

		
    },
    
})