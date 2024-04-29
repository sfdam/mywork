({
	searchInvoice : function(component,event,helper) {
        console.log('searchInvoice');
        this.clearTable(component);
		var action = component.get("c.searchInvoice");
        action.setParams({
            ddtDate : component.get("v.ddtDate"),
            ddtNumber : component.get("v.ddtNumber"),
            caseId : component.get("v.recordId"),
            country : component.get("v.country"),
            accountId : component.get("v.account")
        });
        action.setCallback(this, function(response) {
            console.log('state' + response.getState());
            console.log('item' + response.getReturnValue());
            var state = response.getState();
            if(state === "SUCCESS"){
                var item = response.getReturnValue();
                if(item != null){
                    component.set("v.retrieveProduct", true);
                    component.set("v.initial", false);
                    component.set("v.bodyTable", item);
                }else{
                    component.set("v.err", true);
                }
            }else if(state=== "ERROR"){
                component.find('notifLib').showToast({
                    "variant": "error",
                    "message": "error",
                    "mode" : "dismissable"
                });
            }
        });
        $A.enqueueAction(action);
	},
    caseItem : function(component, event, helper){
        console.log('caseItem');
        console.log(typeof component.get("v.ddtNumber"));
        console.log(typeof component.get("v.ddtDate"));
        var action = component.get("c.createItem");

        var selectedRows = component.find('itemTable').getSelectedRows();

        action.setParams({
            //itemId : component.get("v.selectedRowsDetails"),
            itemId : selectedRows,
            caseId : component.get("v.recordId"),
            itemOriginal : component.get("v.bodyTable"),
            ddtNumber : component.get("v.ddtNumber"),
            ddtDate : component.get("v.ddtDate")
        });
        console.log(component.get("v.selectedRowsDetails"));
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var val = response.getReturnValue();
                if(val === 'OK'){
                    component.find("notifLib").showToast({
                    "variant" : "success",
                    "message" : "Case Item create succesfully",
                    "mode" : "dismissable"
                    });
                    //this.searchInvoice(component, event, helper);
                    $A.get('e.force:refreshView').fire();
                }else{
                    component.find("notifLib").showToast({
                    "variant" : "error",
                    "message" : "Error when create Case Item",
                    "mode" : "dismissable"
                	});
                }
                
            }
        });
        $A.enqueueAction(action);
    },

    clearTable : function(component) {

        console.log('Start clearTable');

        var emptyList = [];
        var openedTable = component.find("itemTable");
        if(openedTable){
           openedTable.set("v.draftValues", emptyList);
           openedTable.set("v.selectedRows", emptyList);
        }
        console.log('End clearTable');

    },

    retrieveDDT : function(component,event,helper) {
        var action = component.get("c.retrieveCaseField");
        action.setParams({
            caseId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==="SUCCESS"){
                
                var val = response.getReturnValue();
                console.log(val);
                if(val != null){
                    component.set("v.ddtDate", val.THR_DDTdate__c);
                    component.set("v.ddtNumber", val.THR_DDTNumber__c);
                    component.set("v.country", val.THR_Country__c);
                    component.set("v.account", val.AccountId);
                    component.set("v.accountName", val.Account.Name);
                }
            }
        });
        $A.enqueueAction(action);
    }
})