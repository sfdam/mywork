({
    
    doInit : function(component,event,helper){

        var actions = [{}];
        actions = [{ label: 'Delete', name: 'delete' , disabled: false}];
 
        component.set('v.fileRecapColumnsReadOnly', [{label: 'Nome', fieldName: 'nome', type: 'text'},{label: 'Cognome', fieldName: 'cognome', type: 'text'},{label: 'Ruolo', fieldName: 'ruolo', type: 'text'},{label: 'Telefono', fieldName: 'telefono', type: 'text'},{label: 'Mail', fieldName: 'mail', type: 'text'}]);
    },       
    
    handleRecordUpdated : function(component,event,helper){
        
    	var changeType = event.getParams().changeType;
        
		if (changeType === "LOADED") { 
			if(component.get('v.workflowRecordCandidato.REFERENTI_JSON__c')){
				component.set('v.jsonDocumentFileData', JSON.parse(component.get('v.workflowRecordCandidato.REFERENTI_JSON__c'))); 
				if($A.util.isEmpty(JSON.parse(component.get('v.workflowRecordCandidato.REFERENTI_JSON__c')))){
					component.set('v.workflowRecordCandidato.REFERENTI_JSON__c','[]');
            		component.set('v.jsonDocumentFileData', JSON.parse(component.get('v.workflowRecordCandidato.REFERENTI_JSON__c')));  
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