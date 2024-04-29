({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
                    //{label: 'Account Name', fieldName: 'THR_EndCustomerName__c', type: 'Text'},
            		{label: 'Product Name', fieldName: 'THR_ProductName__c', type: 'Text', wrapText: true},
            		{label: 'Product Code', fieldName: 'THR_MaterialDescription__c', type: 'Text',initialWidth: 140},
            		{label: 'Quantity', fieldName: 'THR_Quantity__c', type: 'Number', editable: true, initialWidth: 100},
                    {label: 'Batch Number', fieldName: 'THR_BatchNumber__c', type: 'Text', editable: true,initialWidth: 100}
        ]);  
        var selected = [component.get("v.recordId")];
        component.set("v.selectedRows",selected);
        helper.retrieveDDT(component,event,helper);
    },
    updateSelectedText: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRowsCount" ,selectedRows.length );
        var obj =[] ; 
        for (var i = 0; i < selectedRows.length; i++){
            obj.push(selectedRows[i]);
        } 
        component.set("v.selectedRowsDetails" ,obj);
        component.set("v.selectedRowsList" ,event.getParam('selectedRows') );
    },
	handleClick : function(component, event, helper) {
		helper.searchInvoice(component, event, helper);
	},
    createCaseItem : function(component,event, helper){
        console.log('createCaseItem');
        helper.caseItem(component, event, helper);
    },
    handleSaveEdition: function (component, event, helper) {
        var action = component.get("c.updateInvoiceItem");
        action.setParams({
            ddtDate : component.get("v.ddtDate"),
            ddtNumber : component.get("v.ddtNumber")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state==="SUCCESS"){
                var map = response.getReturnValue();
                if(map != null){
                    component.set("v.quantityMap", map);
                }
                console.log('handleSaveEdition');
                var draftValues = event.getParam('draftValues');

                var itemList = component.get('v.bodyTable');
                var q = component.get('v.quantityMap');
                console.log(q);
                itemList.forEach(element => {
                    if (element.Id == draftValues[0].Id) {

                        let newValue = parseInt(draftValues[0].THR_Quantity__c);
                        let id = element.Id;
                        console.log(id);
                        console.log(q[id]);
                        let oldValue = q[id];
                        console.log(newValue);
                        console.log(oldValue);
                        if(newValue > oldValue){
                            component.find("notifLib").showToast({
                                "variant" : "warning",
                                "message" : $A.get("$Label.c.THR_HigherQuantity"),
                                "mode" : "dismissable"
                                });
                        }
                        if(draftValues[0].THR_Quantity__c != null){
                            element.THR_Quantity__c = draftValues[0].THR_Quantity__c;
                        }
                        if(draftValues[0].THR_BatchNumber__c != null){
                            element.THR_BatchNumber__c = draftValues[0].THR_BatchNumber__c;
                        }
                        var emptyList = [];
                        var openedTable = component.find("itemTable");
                        if(openedTable){
                            openedTable.set("v.draftValues", emptyList);
                        }
                    }
                });
                
            }
        });
        $A.enqueueAction(action);
        /*console.log('handleSaveEdition');
        var draftValues = event.getParam('draftValues');

        var itemList = component.get('v.bodyTable');

        let map = component.get("v.quantityMap");
       
        itemList.forEach(element => {
            if (element.Id == draftValues[0].Id) {

                let newValue = parseInt(draftValues[0].THR_Quantity__c);
                let oldValue = parseInt(map.get(element.Id));
                console.log(newValue);
                console.log(oldValue);
                if(newValue > oldValue){
                    component.find("notifLib").showToast({
                        "variant" : "warning",
                        "message" : "Body message",
                        "mode" : "dismissable"
                        });
                }
                if(draftValues[0].THR_Quantity__c != null){
                    element.THR_Quantity__c = draftValues[0].THR_Quantity__c;
                }
                if(draftValues[0].THR_BatchNumber__c != null){
                    element.THR_BatchNumber__c = draftValues[0].THR_BatchNumber__c;
                }
                var emptyList = [];
                var openedTable = component.find("itemTable");
                if(openedTable){
                    openedTable.set("v.draftValues", emptyList);
                }
            }
        });*/
    },
    handleBack : function(component,event,helper){
        component.set("v.initial", true);
        component.set("v.retrieveProduct",false);
    }
})