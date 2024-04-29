({
    
    doInit : function(component,event,helper){

        var actions = [{}];
        actions = [{ label: 'Delete', name: 'delete' , disabled: false}];
 
        component.set('v.fileRecapColumnsReadOnly', [{label: 'Nome del File', fieldName: 'id', type: 'url', typeAttributes: {label: { fieldName: 'fileName' }, target: '_blank'}}]);
        component.set('v.fileRecapColumns', [{label: 'Nome del File', fieldName: 'id', type: 'url', typeAttributes: {label: { fieldName: 'fileName' }, target: '_blank'}} , { type: 'action', typeAttributes: { rowActions: actions }}]);

    },       
    
    handleRecordUpdated : function(component,event,helper){
        
    	var changeType = event.getParams().changeType;
        
		if (changeType === "LOADED") { 

            component.set('v.jsonPDRFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PDR_JSON__c'))); 
            if($A.util.isEmpty(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PDR_JSON__c')))){
                component.set('v.workflowRecordCandidato.DOCUMENTO_PDR_JSON__c','[]');
            	component.set('v.jsonPDRFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PDR_JSON__c')));  
            }
            else{
                var tmp = component.get('v.jsonPDRFileData');
                tmp.forEach(function(record){
                	record.id = '/'+record.id;
                });
                component.set('v.jsonPDRFileData',tmp);
            }               

            component.set('v.jsonBOMFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BOM_JSON__c'))); 
            if($A.util.isEmpty(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BOM_JSON__c')))){
                component.set('v.workflowRecordCandidato.DOCUMENTO_BOM_JSON__c','[]');
            	component.set('v.jsonBOMFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BOM_JSON__c')));  
            }
            else{
                var tmp = component.get('v.jsonBOMFileData');
                tmp.forEach(function(record){
                	record.id = '/'+record.id;
                });
                component.set('v.jsonBOMFileData',tmp);                               
            }                 

            component.set('v.jsonCRIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CRI_JSON__c'))); 
            if($A.util.isEmpty(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CRI_JSON__c')))){
                component.set('v.workflowRecordCandidato.DOCUMENTO_CRI_JSON__c','[]');
            	component.set('v.jsonCRIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CRI_JSON__c')));  
            }   
            else{
                var tmp = component.get('v.jsonCRIFileData');
                tmp.forEach(function(record){
                	record.id = '/'+record.id;
                });
                component.set('v.jsonCRIFileData',tmp);                               
            }             
            
            component.set('v.jsonECFFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c'))); 
            if($A.util.isEmpty(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c')))){
                component.set('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c','[]');
            	component.set('v.jsonECFFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c')));  
            }
            else{
                var tmp = component.get('v.jsonECFFileData');
                tmp.forEach(function(record){
                	record.id = '/'+record.id;
                });
                component.set('v.jsonECFFileData',tmp);                               
            }    
       
            component.set('v.jsonCERFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CER_JSON__c'))); 
            if($A.util.isEmpty(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CER_JSON__c')))){
                component.set('v.workflowRecordCandidato.DOCUMENTO_CER_JSON__c','[]');
            	component.set('v.jsonCERFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_CER_JSON__c')));  
            }
            else{
                var tmp = component.get('v.jsonCERFileData');
                tmp.forEach(function(record){
                	record.id = '/'+record.id;
                });
                component.set('v.jsonCERFileData',tmp);                               
            } 

            component.set('v.jsonALTFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ALT_JSON__c'))); 
            if($A.util.isEmpty(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ALT_JSON__c')))){
                component.set('v.workflowRecordCandidato.DOCUMENTO_ALT_JSON__c','[]');
            	component.set('v.jsonALTFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ALT_JSON__c')));  
            } 
            else{
                var tmp = component.get('v.jsonALTFileData');
                tmp.forEach(function(record){
                	record.id = '/'+record.id;
                });
                component.set('v.jsonALTFileData',tmp);                               
            }    
            
            component.set('v.jsonMCSFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCS_JSON__c'))); 
            if($A.util.isEmpty(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCS_JSON__c')))){
                component.set('v.workflowRecordCandidato.DOCUMENTO_MCS_JSON__c','[]');
            	component.set('v.jsonMCSFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCS_JSON__c')));  
            } 
            else{
                var tmp = component.get('v.jsonMCSFileData');
                tmp.forEach(function(record){
                	record.id = '/'+record.id;
                });
                component.set('v.jsonMCSFileData',tmp);                               
            }    
            
            component.set('v.jsonMCIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c'))); 
            if($A.util.isEmpty(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c')))){
                component.set('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c','[]');
            	component.set('v.jsonMCIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c')));  
            } 
            else{
                var tmp = component.get('v.jsonMCIFileData');
                tmp.forEach(function(record){
                	record.id = '/'+record.id;
                });
                component.set('v.jsonMCIFileData',tmp);                               
            }   
            
        }
    },  
    
    handleUploadMCIFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonMCIFileData');
        
        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
        
        component.set('v.jsonMCIFileData', newFileTable);       
        
        component.set('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c', JSON.stringify(newFileTable));      
        
                component.find("flowRecordHandlerWorkflowCandidatoId").saveRecord($A.getCallback(function(saveResult) {
                    
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        
                        
                    } else if (saveResult.state === "INCOMPLETE") {
                        
                        console.log("User is offline, device doesn't support drafts.");
                        
                    } else if (saveResult.state === "ERROR") {
                        
                        console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                        
                    } else {
                        
                        console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                        
                    }
                }));          
        
    },
    
    handleRowActionMCIFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonMCIFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonMCIFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_MCI_JSON__c', JSON.stringify(newFileTable));  
                
                component.find("flowRecordHandlerWorkflowCandidatoId").saveRecord($A.getCallback(function(saveResult) {
                    
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
  

                    } else if (saveResult.state === "INCOMPLETE") {
                        
                        console.log("User is offline, device doesn't support drafts.");
                        
                    } else if (saveResult.state === "ERROR") {
                        
                        console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                        
                    } else {
                        
                        console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                        
                    }
                }));  
                
                break;
        }
    },  
})