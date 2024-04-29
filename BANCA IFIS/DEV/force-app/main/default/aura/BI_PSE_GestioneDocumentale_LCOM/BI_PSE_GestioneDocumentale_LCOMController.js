({
    doInit : function(component,event,helper){
        
        var actions = [{ label: 'Rimuovi', name: 'delete' }];
        
        component.set('v.fileRecapColumns', [{label: 'Nome del File', fieldName: 'fileName', type: 'text'},{label: 'Tipologia', fieldName: 'fileType', type: 'text'},{ type: 'action', typeAttributes: { rowActions: actions } }]);
        
    },

    handleRecordUpdated : function(component,event,helper){
        
    	var changeType = event.getParams().changeType;

		if (changeType === "LOADED") { 
            
            component.set('v.jsonDocumentFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTI_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTI_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTI_JSON__c','[]');
            	component.set('v.jsonDocumentFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTI_JSON__c')));  
            }
        }        
        
    }, 

    handleUploadDocumentFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonDocumentFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "fileType": "' + component.get('v.aggiuntaTipologiaDocumento') + '", "id": "' + docId + '"}]'));        
          
        component.set('v.jsonDocumentFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTI_JSON__c', JSON.stringify(newFileTable));     
		
		//component.set("v.uploadDisabled" , true);      

		//component.set('v.aggiuntaTipologiaDocumento', null);
        
    },

    handleRowActionDocumentFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
		if(component.get("v.workflowRecordCandidato.Stato__c") == "BOZZA_DATI"){
			switch (action.name) {
				case 'delete':
					var newFileTable = component.get('v.jsonDocumentFileData');
					var rowIndex = newFileTable.indexOf(row);
					newFileTable.splice(rowIndex, 1);
					component.set('v.jsonDocumentFileData', newFileTable);
                
					component.set('v.workflowRecordCandidato.DOCUMENTI_JSON__c', JSON.stringify(newFileTable));  
                
					break;
			}
		}
    },  

	handleComboTipologiaDocumentiChange: function(component, event, helper) {

		component.set("v.uploadDisabled" , false);

	},
    
    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;    
        
        
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
        
    } 
})