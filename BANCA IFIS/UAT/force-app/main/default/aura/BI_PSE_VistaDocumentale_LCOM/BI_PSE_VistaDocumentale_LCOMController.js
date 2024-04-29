({
    
    doInit : function(component,event,helper){

        var actions = [{}];
        actions = [{ label: 'Delete', name: 'delete' , disabled: false}];
 
        component.set('v.fileRecapColumnsReadOnly', [{label: 'Nome del File', fieldName: 'id', type: 'url', typeAttributes: {label: { fieldName: 'fileName' }, target: '_blank'}},{label: 'Tipologia', fieldName: 'fileType', type: 'text'}]);
        component.set('v.fileRecapColumns', [{label: 'Nome del File', fieldName: 'id', type: 'url', typeAttributes: {label: { fieldName: 'fileName' }, target: '_blank'}} , {label: 'Tipologia', fieldName: 'fileType', type: 'text'}, { type: 'action', typeAttributes: { rowActions: actions }}]);

    },       
    
    handleRecordUpdated : function(component,event,helper){
        
    	var changeType = event.getParams().changeType;
        
		if (changeType === "LOADED") { 
			if(component.get('v.workflowRecordCandidato.DOCUMENTI_JSON__c')){
				component.set('v.jsonDocumentFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTI_JSON__c'))); 
				if($A.util.isEmpty(JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTI_JSON__c')))){
					component.set('v.workflowRecordCandidato.DOCUMENTI_JSON__c','[]');
            		component.set('v.jsonDocumentFileData', JSON.parse(component.get('v.workflowRecordCandidato.DOCUMENTI_JSON__c')));  
				}
				else{
					var tmp = component.get('v.jsonDocumentFileData');
					tmp.forEach(function(record){
                		record.id = '/'+record.id;
					});
					component.set('v.jsonDocumentFileData',tmp);
				}                           
			}
		}
    }
})