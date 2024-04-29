({
    doInit : function(component,event,helper){
        
        var actions = [{ label: 'Rimuovi', name: 'delete' }];
        
        component.set('v.fileRecapColumns', [{label: 'Nome del File', fieldName: 'fileName', type: 'text'},{ type: 'action', typeAttributes: { rowActions: actions } }]);
        
    },      
    
    handleRecordUpdated : function(component,event,helper){
        
    	var changeType = event.getParams().changeType;

		if (changeType === "LOADED") { 
            
            component.set('v.jsonRSFFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_RSF_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_RSF_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_RSF_JSON__c','[]');
            	component.set('v.jsonRSFFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_RSF_JSON__c')));  
            }
            
            component.set('v.jsonMAVFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MAV_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MAV_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_MAV_JSON__c','[]');
            	component.set('v.jsonMAVFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MAV_JSON__c')));  
            }
            
            component.set('v.jsonMPEFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MPE_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MPE_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_MPE_JSON__c','[]');
            	component.set('v.jsonMPEFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MPE_JSON__c')));  
            }
            
            component.set('v.jsonMPAFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MPA_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MPA_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_MPA_JSON__c','[]');
            	component.set('v.jsonMPAFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MPA_JSON__c')));  
            }         
            
            component.set('v.jsonMTCFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MTC_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MTC_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_MTC_JSON__c','[]');
            	component.set('v.jsonMTCFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MTC_JSON__c')));  
            }   
            
            component.set('v.jsonDITFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIT_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIT_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_DIT_JSON__c','[]');
            	component.set('v.jsonDITFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIT_JSON__c')));  
            }  
            
            component.set('v.jsonDIEFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIE_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIE_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_DIE_JSON__c','[]');
            	component.set('v.jsonDIEFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIE_JSON__c')));  
            }      
            
            component.set('v.jsonSVRFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_SVR_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_SVR_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_SVR_JSON__c','[]');
            	component.set('v.jsonSVRFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_SVR_JSON__c')));  
            }          
            
            component.set('v.jsonRIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_RI_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_RI_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_RI_JSON__c','[]');
            	component.set('v.jsonRIFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_RI_JSON__c')));  
            }     
            
            component.set('v.jsonA4FileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_A4_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_A4_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_A4_JSON__c','[]');
            	component.set('v.jsonA4FileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_A4_JSON__c')));  
            }        
            
            component.set('v.jsonDIA4FileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIA4_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIA4_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_DIA4_JSON__c','[]');
            	component.set('v.jsonDIA4FileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIA4_JSON__c')));  
            }                
            
            component.set('v.jsonPCDFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PCD_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PCD_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_PCD_JSON__c','[]');
            	component.set('v.jsonPCDFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PCD_JSON__c')));  
            }    
            
            component.set('v.jsonDM10FileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DM10_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DM10_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_DM10_JSON__c','[]');
            	component.set('v.jsonDM10FileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DM10_JSON__c')));  
            }    
            
            component.set('v.jsonSDGFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_SDG_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_SDG_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_SDG_JSON__c','[]');
            	component.set('v.jsonSDGFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_SDG_JSON__c')));  
            }    
            
            component.set('v.jsonDCVCFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DCVC_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DCVC_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_DCVC_JSON__c','[]');
            	component.set('v.jsonDCVCFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DCVC_JSON__c')));  
            }    
            
            component.set('v.jsonDABFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DAB_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DAB_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_DAB_JSON__c','[]');
            	component.set('v.jsonDABFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DAB_JSON__c')));  
            }    
            
            component.set('v.jsonECFFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c','[]');
            	component.set('v.jsonECFFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_ECF_JSON__c')));  
            }   
            
            component.set('v.jsonBE3FileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BE3_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BE3_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_BE3_JSON__c','[]');
            	component.set('v.jsonBE3FileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BE3_JSON__c')));  
            }    
            
            component.set('v.jsonMU2FileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MU2_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MU2_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_MU2_JSON__c','[]');
            	component.set('v.jsonMU2FileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MU2_JSON__c')));  
            }          
            
            component.set('v.jsonBVAFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BVA_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BVA_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_BVA_JSON__c','[]');
            	component.set('v.jsonBVAFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BVA_JSON__c')));  
            }  
			
            component.set('v.jsonDICFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIC_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIC_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_DIC_JSON__c','[]');
            	component.set('v.jsonDICFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DIC_JSON__c')));  
            }     			          
            
            component.set('v.jsonMUSFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MUS_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MUS_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_MUS_JSON__c','[]');
            	component.set('v.jsonMUSFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_MUS_JSON__c')));  
            }           
            
            component.set('v.jsonDITSFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DITS_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DITS_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_DITS_JSON__c','[]');
            	component.set('v.jsonDITSFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DITS_JSON__c')));  
            }            
            
            component.set('v.jsonBPRFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BPR_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BPR_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_BPR_JSON__c','[]');
            	component.set('v.jsonBPRFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BPR_JSON__c')));  
            }            
            
            component.set('v.jsonUACFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_UAC_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_UAC_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_UAC_JSON__c','[]');
            	component.set('v.jsonUACFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_UAC_JSON__c')));  
            }        
      
            component.set('v.jsonPROFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PRO_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PRO_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_PRO_JSON__c','[]');
            	component.set('v.jsonPROFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_PRO_JSON__c')));  
            } 
      
            component.set('v.jsonGCEFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_GCE_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_GCE_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_GCE_JSON__c','[]');
            	component.set('v.jsonGCEFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_GCE_JSON__c')));  
            } 
            
            component.set('v.jsonDM10IFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DM10I_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DM10I_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_DM10I_JSON__c','[]');
            	component.set('v.jsonDM10IFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_DM10I_JSON__c')));  
            }        
            
            component.set('v.jsonVCLFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_VCL_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_VCL_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_VCL_JSON__c','[]');
            	component.set('v.jsonVCLFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_VCL_JSON__c')));  
            }    
            
            component.set('v.jsonBESCFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BESC_JSON__c'))); 
            if(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BESC_JSON__c')) === null){
                component.set('v.workflowRecordCandidato.DOCUMENTO_BESC_JSON__c','[]');
            	component.set('v.jsonBESCFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTO_BESC_JSON__c')));  
            }                
        }        
        
    },      
    
    handleUploadRSFFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonRSFFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
          
        component.set('v.jsonRSFFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_RSF_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionRSFFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonRSFFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonRSFFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_RSF_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },    

    handleUploadMAVFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonMAVFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonMAVFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_MAV_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionMAVFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonMAVFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonMAVFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_MAV_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },    
    
    handleUploadMPEFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonMPEFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonMPEFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_MPE_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionMPEFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonMPEFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonMPEFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_MPE_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },  
    
    handleUploadMPAFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonMPAFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonMPAFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_MPA_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionMPAFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonMPAFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonMPAFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_MPA_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },  
    
    handleUploadMTCFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonMTCFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonMTCFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_MTC_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionMTCFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonMTCFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonMTCFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_MTC_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },
    
    handleUploadDITFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonDITFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonDITFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_DIT_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionDITFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonDITFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonDITFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_DIT_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },
    
    handleUploadDIEFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonDIEFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonDIEFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_DIE_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionDIEFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonDIEFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonDIEFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_DIE_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },    

    handleUploadSVRFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonSVRFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonSVRFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_SVR_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionSVRFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonSVRFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonSVRFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_SVR_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    }, 
    
    handleUploadRIFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonRIFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonRIFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_RI_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionRIFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonRIFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonRIFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_RI_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },     
    
    handleUploadA4FileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonA4FileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonA4FileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_A4_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionA4File: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonA4FileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonA4FileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_A4_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },      
    
    handleUploadDIA4FileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonDIA4FileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonDIA4FileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_DIA4_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionDIA4File: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonDIA4FileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonDIA4FileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_DIA4_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },  

    handleUploadPCDFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonPCDFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonPCDFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_PCD_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionPCDFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonPCDFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonPCDFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_PCD_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },

    handleUploadDM10FileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonDM10FileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonDM10FileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_DM10_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionDM10File: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonDM10FileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonDM10FileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_DM10_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },

    handleUploadSDGFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonSDGFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonSDGFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_SDG_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionSDGFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonSDGFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonSDGFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_SDG_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },

    handleUploadDCVCFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonDCVCFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonDCVCFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_DCVC_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionDCVCFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonDCVCFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonDCVCFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_DCVC_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },

    handleUploadDABFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonDABFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonDABFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_DAB_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionDABFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonDABFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonDABFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_DAB_JSON__c', JSON.stringify(newFileTable));  
                
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
    
    handleRowActionDABFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonDABFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonDABFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_DAB_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },

    handleUploadBE3FileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonBE3FileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonBE3FileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_BE3_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionBE3File: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonBE3FileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonBE3FileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_BE3_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },
    
    handleUploadMU2FileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonMU2FileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonMU2FileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_MU2_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionMU2File: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonMU2FileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonMU2FileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_MU2_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },
    
    handleUploadBVAFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonBVAFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonBVAFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_BVA_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionBVAFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonBVAFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonBVAFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_BVA_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },
    
    handleUploadDICFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonDICFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonDICFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_DIC_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionDICFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonDICFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonDICFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_DIC_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },

    handleUploadMUSFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonMUSFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonMUSFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_MUS_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionBVAFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonMUSFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonMUSFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_MUS_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },
    
    handleUploadDITSFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonDITSFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonDITSFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_DITS_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionDITSFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonDITSFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonDITSFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_DITS_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },
    
    handleUploadBPRFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonBPRFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonBPRFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_BPR_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionBPRFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonBPRFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonBPRFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_BPR_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },
    
    handleUploadUACFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonUACFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonUACFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_UAC_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionUACFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonUACFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonUACFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_UAC_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },
    
    handleUploadPROFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonPROFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonPROFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_PRO_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionPROFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonPROFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonPROFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_PRO_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },    
    
    handleUploadGCEFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonGCEFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonGCEFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_GCE_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionGCEFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonGCEFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonGCEFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_GCE_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },   
   
    handleUploadDM10IFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonDM10IFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonDM10IFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_DM10I_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionDM10IFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonDM10IFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonDM10IFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_DM10I_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },   
   
    handleUploadVCLFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonVCLFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonVCLFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_VCL_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionVCLFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonVCLFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonVCLFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_VCL_JSON__c', JSON.stringify(newFileTable));  
                
                break;
        }
    },   
    
    handleUploadBESCFileFinished: function (component,event,helper){
        
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var docName = uploadedFiles[0].name;
        
        var fileTable = component.get('v.jsonBESCFileData');

        var newFileTable = fileTable.concat(JSON.parse('[{"fileName": "' + docName + '", "id": "' + docId + '"}]'));        
  
        component.set('v.jsonBESCFileData', newFileTable);       

        component.set('v.workflowRecordCandidato.DOCUMENTO_BESC_JSON__c', JSON.stringify(newFileTable));           
        
    },
    
    handleRowActionBESCFile: function (component, event , helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'delete':
                var newFileTable = component.get('v.jsonBESCFileData');
                var rowIndex = newFileTable.indexOf(row);
                newFileTable.splice(rowIndex, 1);
                component.set('v.jsonBESCFileData', newFileTable);
                
                component.set('v.workflowRecordCandidato.DOCUMENTO_BESC_JSON__c', JSON.stringify(newFileTable));  
                
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