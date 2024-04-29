({
    doInit : function(component,event,helper){
        
        
        
    },      
    
    handleRecordUpdated : function(component,event,helper){
        
		helper.calculateFieldVisibility(component,event);

    },   
    
    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;    
        
        
        if(!overallValidity){       
            
            return;
            
        }
        else {
            
            var flowInputImportoMutuoVar = component.get('v.flowInputAltreNoteNsaVar');  
            
            // CONTROLLI PARTICOLARI DI NULLITA' CON OVERRIDE SILENTE
            
            if(component.find("flowInputAltreNoteNsaInputId").get("v.value") === undefined){
                
                flowInputAltreNoteNsaVar = '';
                
            }              
            
            component.find("flowRecordHandlerWorkflowCandidatoId").saveRecord($A.getCallback(function(saveResult) {
                
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    
						navigate(event.getParam("action"));
                   
                } else if (saveResult.state === "INCOMPLETE") {
                    
                    console.log("User is offline, device doesn't support drafts.");
                    
                } else if (saveResult.state === "ERROR") {
                    
                    console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                    
                } else {
                    
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                    
                }
            }));   
            
        }
 
    } 
    
})