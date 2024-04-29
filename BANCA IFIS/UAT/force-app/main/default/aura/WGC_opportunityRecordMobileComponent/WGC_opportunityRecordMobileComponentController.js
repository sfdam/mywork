({
	doInit : function(component, event, helper) {
		// alert($A.get("$Browser.formFactor"));
		if(window.innerWidth < 480){
			component.set('v.iPhone', true);
        	}
	},
})