({
    doInit : function(component, event, helper) {    
        component.find("flowRecordHandlerWorkflowCandidatoId").reloadRecord(true);

    },
    
    handleNavigate: function(component, event , helper) {

        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;    
        
        
        if(!overallValidity){       
            
            return;
            
        }
        else {

            navigate(event.getParam("action"));
            
        component.set("v.isMainFlowOpen", false);
        
		$A.get('event.force:refreshView').fire();            
            
        }
        
        
    }    
})