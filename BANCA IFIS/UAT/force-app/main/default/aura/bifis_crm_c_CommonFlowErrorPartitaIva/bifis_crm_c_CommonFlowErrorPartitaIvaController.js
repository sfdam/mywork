({
    doInit : function(component,event,helper){
        
        
    },
    
    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        navigate(event.getParam("action"));
    }
    
})