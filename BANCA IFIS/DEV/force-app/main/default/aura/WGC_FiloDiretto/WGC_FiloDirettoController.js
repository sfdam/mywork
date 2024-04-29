({
	init : function(component, event, helper) {

        if(window.CampaignFilter != undefined)
            component.set("v.CampaignFilter", window.CampaignFilter);
        if(window.OwnerFilter != undefined)
            component.set("v.OwnerFilter", window.OwnerFilter);
        if(window.OverdueFilter != undefined)
            component.set("v.OverdueFilter", window.OverdueFilter);
        if(window.textToSearch != undefined)
            component.set("v.textToSearch", window.textToSearch);
        if(window.TabFilter != undefined){
            console.log('@@@ tabfilter ' , window.TabFilter);
            component.set("v.TabFilter", window.TabFilter);
        }

		component.set('v.columns', [
            {label: 'Oggetto', fieldName: 'Subject', type: 'text', sortable: true, cellAttributes: { iconName: "standard:task",  iconPosition: 'left' }},
            {label: 'Campagna', fieldName: 'Campagna', type: 'text', sortable: true },
			{label: 'Orig. Dettaglio', fieldName: 'Originator_di_dettaglio', type: 'text', sortable: true },
            {label: 'Assegnato a', fieldName: 'Owner', type: 'text', sortable: true },
            {label: 'Account', fieldName: 'WhatId', type: 'url', sortable: true,  typeAttributes : { label : { fieldName : 'AccountName'} }},
            {label: 'Scadenza', fieldName: 'ActivityDate', type: "date-local", sortable: true, typeAttributes:{ month: "2-digit", day: "2-digit"}, cellAttributes : { class: { fieldName : "cellClass"}} },
            {
                type:  'button',
                label: 'Azioni',
                typeAttributes: 
                {
                  label: 'Esita', 
                  name: 'esita', 
                  title: 'Esita', 
                  disabled: false,
                  onclick: 'c.navigateToMyComponent'
                },

                cellAttributes : { class: { fieldName : "btnC" } }
              }
        ]);

        helper.numeroTask(component, event, helper);
        helper.fetchData(component, event, helper);
        helper.fetchCampaign(component, event, helper);

    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var taskId = row.Id;

        var listaTask = component.get("v.data");
        var task;
        if(listaTask.length > 0){
            listaTask.forEach((item, index) =>{
                if(item.Id == taskId){
                    task = item;
                }
            });
        }
        console.log('@@@ parametri esitazione ' , JSON.stringify(task));

        console.log('@@@ action.name ' , action.name);

        if(action.name == "esita"){
            helper.navigateToMyComponent(component, event, task, taskId);
        }
    },

    //Da rivedere
    handleShowModal : function (component, event, helper) {
        $A.createComponents([
            ["c:WGC_CreateContactModal", { whoAreYou : 'filoDiretto'} ]
            //["c:CreateAccountModal_Footer",{}]
        ],
            function(content, status) {
                if (status === "ERROR") {
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        "title" : "ERRORE",
                        "message" : "Errore durante il caricamento riprovare"
                    });
                }
            });
    },

    selectCampaign : function(component, event, helper){
        var idCampagna = event.getSource().get("v.value");
        console.log('@@@ idCampagna ' , idCampagna);
    },

    resolveEvent : function(component, event, helper) {
        var json = JSON.parse(event.getParam('json'));
        console.log('@@@ json ' , json);
        var contactId = json.data.Id;
        var action = component.get("c.generaTaskInbound");
        action.setParams({
            idContatto : contactId
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var rowD = response.getReturnValue();
                console.log('@@@ response ' , JSON.stringify(rowD));
                if(rowD != null){
                    component.set("v.taskId", rowD.Id);
                    var taskId = rowD.Id;
                    
                    console.log('@@@ rowD ' , rowD);
                    console.log('@@@ rowD.campagna ' , rowD.Campagna__r);

                    if(rowD.Campagna__r == undefined){
                        rowD['Campagna__r'] = {Id : '' , Name : ''};
                    }
                    else{
                        console.log('@@@ presente ' , rowD.Campagna__r);
                    }

                    helper.navigateToMyComponent(component, event, rowD, taskId);
                }
                else{
                    //return;
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({
                        "title" : "Attenzione",
                        "message" : "Task non esitato associato all'anagrafica, esitare i task aperti",
                        "type" : "WARNING"
                    });
                    msg.fire();
                    return;
                }
            }
            else{
                //ERROR
                console.log('@@@ errore');
                console.log('@@@ errore chiamata inbound ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getFilter : function(component, event, helper){
        component.set("v.numeroPagina", 0);
        component.set("v.isFirst", true);
        if(event.which == 13 && event.target.getAttribute("data-text") == 'true'){
            helper.callFilterMethod(component, event, helper);
        } else if(event.target.getAttribute("data-text") != 'true'){
            helper.callFilterMethod(component, event, helper);
        }

        helper.numeroTask(component, event, helper);
    },

    goBack : function(component, event, helper){
        var numPG = component.get("v.numeroPagina");
        numPG--;
        component.set("v.numeroPagina", numPG);
        
        var totale = component.get("v.totaleElementi");
        var elementi = component.get("v.numeroElementiPagine");

        helper.callFilterMethod(component, event, helper);
        //helper.fetchCampaign(component, event, helper);

        if(numPG == 0 || elementi >= totale){
            component.set("v.isFirst", true);
            component.set("v.isLast", false);
        }
    },

    goForward : function(component, event, helper){
        var numPG = component.get("v.numeroPagina");
        numPG++;
        component.set("v.numeroPagina", numPG);

        var totale = component.get("v.totaleElementi");
        console.log('@@@ totale ' , totale);
        console.log('@@@ numPG ' , numPG);

        var elementi = component.get("v.numeroElementiPagine");

        var off = ((numPG+1) * elementi);
        console.log('@@@ off ' , off);

        helper.callFilterMethod(component, event, helper);
        //helper.fetchCampaign(component, event, helper);

        if(off == totale || elementi >= totale){
            component.set("v.isLast", true);
        }

        component.set("v.isFirst", false);
    },

    updateColumnSorting : function(component, event, helper){
        console.log('@@@ aaa');
        // helper.sortCol(component, event, helper);
        component.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout($A.getCallback(function() {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
            component.set('v.isLoading', false);
        }), 0);
    },

})