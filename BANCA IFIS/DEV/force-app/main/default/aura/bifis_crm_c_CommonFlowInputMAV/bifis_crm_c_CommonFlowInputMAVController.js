({
    doInit : function(component,event,helper){
        
    },     
    
    handleRecordUpdated : function(component,event,helper){

        var eventParams = event.getParams();

        if(eventParams.changeType === "LOADED") {
            
            var toggleValue = component.get("v.workflowRecordCandidato.MAV_Altro__c");
           
            if(toggleValue){
                
                component.find("flowInputAltroInputId").set("v.disabled", false);
                
            }
           
            else{
                
                component.set("v.workflowRecordCandidato.MAV_Altro_Descrizione__c","");
                
                component.find("flowInputAltroInputId").set("v.disabled", true);
            } 

        }         
        
    },   
    
    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;    
        
        // VERIFICA DELLE NOTE       
        
        if(!component.find("flowInputAltroInputId").get("v.disabled")){
           
            if((component.find("flowInputAltroInputId").get("v.value")) === "" || (component.find("flowInputAltroInputId").get("v.value") === undefined)){

                component.find("flowInputAltroInputId").setCustomValidity("Completare questo campo.");
                
                component.find("flowInputAltroInputId").reportValidity();
                
                overallValidity = false;
            }
            
        }
        
        if(!overallValidity){       
            
            return;
            
        }
        else {
            
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
        
        
    } ,
    
    handleMavProventiClick : function (component, event , helper) {
    
        var toggleValue = component.get("v.workflowRecordCandidato.MAV_Proventi__c"); 
        
        if(toggleValue){
        
            component.set("v.workflowRecordCandidato.MAV_Straordinari__c",!toggleValue);
            component.set("v.workflowRecordCandidato.MAV_Cessione__c",!toggleValue); 
            component.set("v.workflowRecordCandidato.MAV_Altro__c",!toggleValue);     
            
            component.set("v.workflowRecordCandidato.MAV_Altro_Descrizione__c","");
            component.find("flowInputAltroInputId").set("v.disabled", true);
            
        }
        else component.set("v.workflowRecordCandidato.MAV_Proventi__c",!toggleValue);          
    
    } ,
 
    handleMavStraordinariClick : function (component, event , helper) {
    
        var toggleValue = component.get("v.workflowRecordCandidato.MAV_Straordinari__c"); 
        
        if(toggleValue){        
        
            component.set("v.workflowRecordCandidato.MAV_Proventi__c",!toggleValue);
            component.set("v.workflowRecordCandidato.MAV_Cessione__c",!toggleValue); 
            component.set("v.workflowRecordCandidato.MAV_Altro__c",!toggleValue);      
            
            component.set("v.workflowRecordCandidato.MAV_Altro_Descrizione__c","");
            component.find("flowInputAltroInputId").set("v.disabled", true);
            
        }
        else component.set("v.workflowRecordCandidato.MAV_Straordinari__c",!toggleValue);  
        
    } ,

    handleMavCessioneClick : function (component, event , helper) {
    
        var toggleValue = component.get("v.workflowRecordCandidato.MAV_Cessione__c"); 
        
        if(toggleValue){            
        
            component.set("v.workflowRecordCandidato.MAV_Straordinari__c",!toggleValue);         
            component.set("v.workflowRecordCandidato.MAV_Proventi__c",!toggleValue);
            component.set("v.workflowRecordCandidato.MAV_Altro__c",!toggleValue);        
            
            component.set("v.workflowRecordCandidato.MAV_Altro_Descrizione__c","");
            component.find("flowInputAltroInputId").set("v.disabled", true);
            
        }
        else component.set("v.workflowRecordCandidato.MAV_Cessione__c",!toggleValue);   
    
    } ,
    
    handleMavAltroClick : function (component, event , helper) {
        
        var toggleValue = component.get("v.workflowRecordCandidato.MAV_Altro__c");
        var inputValue = component.get("v.workflowRecordCandidato.MAV_Altro_Descrizione__c");

        if(toggleValue){
            
            component.find("flowInputAltroInputId").set("v.disabled", false);
            
            component.set("v.workflowRecordCandidato.MAV_Proventi__c",!toggleValue);
            component.set("v.workflowRecordCandidato.MAV_Straordinari__c",!toggleValue);
            component.set("v.workflowRecordCandidato.MAV_Cessione__c",!toggleValue);            
            
        }
       
        else component.set("v.workflowRecordCandidato.MAV_Altro__c",!toggleValue);
        
    }    
    
})