({
	doInit : function(component, event, helper) {
		helper.apex(component, event, 'callBestPractice', {})
		.then(function (result) {
			console.log('BEST PRACTICE RESULT: ', result);
		}).finally($A.getCallback(function () {
			
		}));
	}
})