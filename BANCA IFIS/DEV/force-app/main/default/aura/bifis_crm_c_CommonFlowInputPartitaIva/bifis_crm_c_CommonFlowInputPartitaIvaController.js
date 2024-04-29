({
    
    doInit : function(component,event,helper){

    },
    
    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        // VERIFICA DEL CODICE PARTITA IVA

        var flowInputPartitaIvaInput = component.find("flowInputPartitaIvaInputId");
        
        var validity = component.find("flowInputPartitaIvaInputId").get("v.validity");
        
        if(!validity.valid){
            
            flowInputPartitaIvaInput.reportValidity();
            
            return;
        }
        
        navigate(event.getParam("action"));
        
    } 
})