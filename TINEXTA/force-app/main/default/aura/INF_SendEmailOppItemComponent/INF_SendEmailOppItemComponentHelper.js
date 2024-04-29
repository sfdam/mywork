({
	helperMethod : function() {
		
	},
    
    apex: function (component, event, apexAction, params) {
		var p = new Promise($A.getCallback(function (resolve, reject) {
			var action = component.get("c." + apexAction + "");
			action.setParams(params);
			action.setCallback(this, function (callbackResult) {
				if (callbackResult.getState() == 'SUCCESS') {
					resolve(callbackResult.getReturnValue());
				}
				if (callbackResult.getState() == 'ERROR') {
					console.log('ERROR', callbackResult.getError());
					reject(callbackResult.getError());
				}
			});
			$A.enqueueAction(action);
		}));
		return p;
	},

		getRowActions: function(cmp,row,cb){
		  //handler function to build actions dynamically
		  var actions = [];                        
		  if(row.status__c == "Completed"){
			  actions = [{label:'Proceed',name:'proceed_action'}];
		  }else{
			  actions = [{label:'Redo', name:'redo_action', iconName:'utility:check', onselect:function(component, event, helper) {
				alert('AAAAA');
			  }}];
		  }
		  cb(actions);
		},
})