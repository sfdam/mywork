({
    doInit : function(component, event, helper) {    

    },
    
    handleRecordUpdated : function(component,event,helper){
        
    },      
    
    handleNavigate: function(component, event , helper) {

        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;    
        
        
        if(!overallValidity){       
            
            return;
            
        }
        else {
            if(component.get("v.flowValidatorFinalResultVar") == 'OK'){
                
                
            }
            navigate(event.getParam("action"));
        }
        
        
    }    
})