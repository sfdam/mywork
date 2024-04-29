({    
    init: function(cmp, event, helper) {
        // Set the validate attribute to a function that includes validation logic
        cmp.set('v.validate', true);
        
        helper.openSubtab(cmp, event, helper);
	},
    
    invoke : function(component, event, helper) {
        helper.openSubtab(component, event, helper);
    }
})