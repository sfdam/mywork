({
	doInit : function(component, event, helper) {},
	
	reInit : function(component, event, helper) {
		console.log("REINIT REFRESH");
		setTimeout(function(){
			console.log("REINIT REFRESH AFTER TIMEOUT");
			$A.get('e.force:refreshView').fire();
		}, 1000);
		
	}
})