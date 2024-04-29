({
	doInit : function(component, event, helper) {
		helper.apex(component, event, 'getUserInfo', {  })
        .then($A.getCallback(function (result) {
            console.log('Call getUserInfo result: ', result);
            component.set('v.userInfo', result);
            
        })).finally($A.getCallback(function () {
           
        }));

	}
})