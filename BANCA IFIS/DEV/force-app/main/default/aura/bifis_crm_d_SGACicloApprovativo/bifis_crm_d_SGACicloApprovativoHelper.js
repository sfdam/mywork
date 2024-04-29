({
	showToast : function(title, message, duration,type) {
        
        var toastEvent = $A.get("event.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration: duration,
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        
        toastEvent.fire();         
		
	}
    
})