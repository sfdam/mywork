({
    doInit : function(component, event, helper) {    
        
        var actions = [{}];
        actions = [{ label: 'Delete', name: 'delete' , disabled: false}];
 
        component.set('v.fileRecapColumnsReadOnly', [{label: 'Nome del File', fieldName: 'fileName', type: 'text'}]);
        component.set('v.fileRecapColumns', [{label: 'Nome del File', fieldName: 'fileName', type: 'text'},{ type: 'action', typeAttributes: { rowActions: actions } }]);

        
    },
    
    handleRecordUpdated : function(component,event,helper){
        
        var changeType = event.getParams().changeType;
        
        if (changeType === "LOADED") { 

            component.set('v.jsonMCIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c','[]');
                component.set('v.jsonMCIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c')));  
            }   
            
            component.set('v.jsonMCSFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCS_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCS_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_MCS_JSON__c','[]');
                component.set('v.jsonMCSFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCS_JSON__c')));  
            }         
            
        }
        
    },    
    
    handleUploadMCSFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonMCSFileData');
        
        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
        
        component.set('v.jsonMCSFileData', newFileTable);       
        
        component.set('v.workflowRecordCandidato.DOCUMENTO_MCS_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionMCSFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonMCSFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonMCSFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_MCS_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },  
    
    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;    
        
        
        if(!overallValidity){       
            
            return;
            
        }
        else {
       
            if(!component.get('v.componenteSolaLettura')){
                
                component.find("flowRecordHandlerWorkflowCandidatoId").saveRecord($A.getCallback(function(saveResult) {
                    
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        
                        try{
                            navigate(event.getParam("action"));
                        }
                        catch(error){
                            console.log("Error navigating to the next step: " + error);    
                        }
                        
                    } else if (saveResult.state === "INCOMPLETE") {
                        
                        console.log("User is offline, device doesn't support drafts.");
                        
                    } else if (saveResult.state === "ERROR") {
                        
                        console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                        
                    } else {
                        
                        console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                        
                    }
                }));       
            }
            else {
                navigate(event.getParam("action"));                
            }
            
            if(event.getParam("action") == 'FINISH'){
                
                component.set("v.isMainFlowOpen", false);

                setTimeout(function() {
                  $A.get('event.force:refreshView').fire(); 
                }, 1000);            
                
            }            
            
        }            
        
    }  
})