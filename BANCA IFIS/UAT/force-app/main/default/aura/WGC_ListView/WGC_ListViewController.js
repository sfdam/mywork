({
    doInit : function(component, event, helper) {
        var objName = component.get('v.objectName');
        if(objName != 'Activity'){
            helper.getUserProfile(component, event, helper);
        }
    },

    changeListaDati : function(component, event, helper){
        var listaDati = component.get("v.listaDati");
        var tipoOggetto = component.get("v.objectName");
        helper.loadNewTable(component, event, helper, listaDati);
    },

    handleTaskAction : function(component, event, helper){
		var row = event.getParam('row');

        var lista = component.get("v.listaDati");

        var userInfo = component.get("v.userInfo");

        var objectType = component.get("v.objectName");

        var contactId;
        var taskId;
        var row;

        if(objectType == 'task'){
            //Trovo l'id del task su cui fare il redirect
            lista.records.forEach((item, index) =>{
                if(item.Id == row.Id.substring(1, row.Id.length)){
                    row = item;
                }
            });

            helper.navigate(component, event, helper, objectType, row, userInfo);
        }
        else if(objectType == 'oppIstruttoria' || 
                objectType == 'oppPerfContratti' ||
                objectType == 'oppAttProdotto'){
            
            var optyId;
            lista.records.forEach((item, index) =>{
                if(item.Id == row.Id.substring(1, row.Id.length)){
                    optyId = item.Id;
                }
            });

            var goToOpty = $A.get("e.force:navigateToComponent");
            goToOpty.setParams({
                componentDef : "c:AccountOpportunity_Detail",
                componentAttributes: {
                    opportunityId : optyId
                }
            });
            goToOpty.fire();
        }

    },
    
    loadMoreData : function(component, event, helper){
        console.log('@@@ parametri  ' , event.getSource().getParams());
    },

    loadActivityData : function(component, event, helper){
        helper.createDataTable(component, event);
    },

    getSelectedName : function(component, event, helper){
        var row = event.getParam('row');
        console.log(JSON.stringify(row));

        var navService = component.find("navService");

        if(row.Id.substring(0,3) == '00T'){
            var pageReference = {
                type: "standard__recordPage",
                attributes: {
                    "recordId": row.Id,
                    "objectApiName": "Task",
                    "actionName": "view"
                }
            };
        } else {
            var pageReference = {
                type: "standard__recordPage",
                attributes: {
                    "recordId": row.Id,
                    "objectApiName": "Event",
                    "actionName": "view"
                }
            };
        }
             
        navService.navigate(pageReference);       


    },

    changeSubTabs : function(component, event, helper){
        var selected = event.currentTarget.getAttribute("data-tab");
        console.log('@@@ selected ' , selected);
		var idSelected = event.currentTarget.id;
		
		var a = component.find('container');

		a.forEach((item, index) =>{
			if(index == idSelected){
				$A.util.addClass(item, 'active');
			}
			else{
				$A.util.removeClass(item, 'active');
			}
        });
        
        window.TabFilter = selected;
        component.set("v.FDfilter", selected);

		// var lista = component.get("v.dati");

		// for(var key in lista){
		// 	if(key == selected){
		// 		component.set("v.objectName", selected);
		// 		component.set("v.listaDati", lista[key]);
		// 	}
		// }
    },

    updateColumnSorting: function (component, event, helper) {
        console.log('@@@ prova prova 1');
        //component.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout($A.getCallback(function() {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            console.log('@@@ prova prova ' , sortDirection );
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
            //component.set('v.isLoading', false);
        }), 0);
    },
})