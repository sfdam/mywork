({
    doInit : function(component,event,helper){

        var actions = [{}];
        
        if(component.get('v.componenteSolaLettura')){
            
            actions = [{ label: 'Delete', name: 'delete' , disabled: true}];
            
        }
        else {
            
            actions = [{ label: 'Delete', name: 'delete' , disabled: false}];
            
        }
        
        
        component.set('v.fileRecapColumns', [{label: 'Nome del File', fieldName: 'fileName', type: 'text'},{ type: 'action', typeAttributes: { rowActions: actions } }]);
        
    },      
    
    handleRecordUpdated : function(component,event,helper){
        
    	var changeType = event.getParams().changeType;

		if (changeType === "LOADED") { 
            
            component.set('v.jsonPDRFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PDR_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PDR_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_PDR_JSON__c','[]');
            	component.set('v.jsonPDRFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PDR_JSON__c')));  
            }
            
            component.set('v.jsonBOMFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BOM_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BOM_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_BOM_JSON__c','[]');
            	component.set('v.jsonBOMFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BOM_JSON__c')));  
            }
            
            component.set('v.jsonCRIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CRI_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CRI_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_CRI_JSON__c','[]');
            	component.set('v.jsonCRIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CRI_JSON__c')));  
            }
            
            component.set('v.jsonECFFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c','[]');
            	component.set('v.jsonECFFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c')));  
            }     
			
            component.set('v.jsonCERFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CER_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CER_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_CER_JSON__c','[]');
            	component.set('v.jsonCERFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CER_JSON__c')));  
            }   			    

            component.set('v.jsonALTFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ALT_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ALT_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_ALT_JSON__c','[]');
            	component.set('v.jsonALTFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ALT_JSON__c')));  
            }   
            
        }        
        
    },      
    
    handleUploadPDRFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonPDRFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
          
        component.set('v.jsonPDRFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_PDR_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionPDRFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonPDRFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonPDRFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_PDR_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },    

    handleUploadBOMFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonBOMFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonBOMFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_BOM_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionBOMFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonBOMFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonBOMFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_BOM_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },    
    
    handleUploadCRIFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonCRIFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonCRIFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_CRI_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionCRIFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonCRIFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonCRIFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_CRI_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },    
           
    handleUploadECFFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonECFFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonECFFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionECFFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonECFFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonECFFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    }, 

    handleUploadCERFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonCERFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonCERFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_CER_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionCERFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonCERFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonCERFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_CER_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    }, 
           
    handleUploadALTFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonALTFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonALTFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_ALT_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionALTFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonALTFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonALTFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_ALT_JSON__c', JSON.stringify(newFileTable));  
                
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
            
        }
        
    } 
    
})