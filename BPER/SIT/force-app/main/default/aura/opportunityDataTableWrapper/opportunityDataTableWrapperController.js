({
    fireFlow : function(component, event, helper) {
		// Find the component whose aura:id is "flowData"
		//var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's Unique Name.
        var Id= component.get("v.recordId");
        var workspaceAPI = component.find("flowData");
        if(component.get("v.pagina")===1){
            workspaceAPI.getEnclosingTabId()
            .then(function(response) {
                workspaceAPI.openSubtab({
                    parentTabId: response,
                    url: '/flow/Procedura_guidata_creazione_opportunit?recordId='+Id,
                    focus: true
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }
        else{
            workspaceAPI.getEnclosingTabId()
            .then(function(response) {
                workspaceAPI.openSubtab({
                    parentTabId: response,
                    url: '/flow/Procedura_guidata_creazione_opportunit_Case?recordId='+Id,
                    focus: true
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }
		
        

        //flow.startFlow("Procedura_guidata_creazione_opportunit");
    }
})