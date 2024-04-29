({

    afterRender : function(component, helper) {
        this.superAfterRender();

        helper.CountNumberOfTab(component);
    }
	
})