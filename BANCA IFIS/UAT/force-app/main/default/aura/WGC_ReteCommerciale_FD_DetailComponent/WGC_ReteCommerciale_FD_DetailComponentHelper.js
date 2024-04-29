({
    initialize : function(component, event, helper) {
        var pg = component.get("v.pageReference");
        console.log('@@@ pg ' , JSON.stringify(pg));
        component.set("v.isDirezioneFD", pg.state.c__isDirezioneFD);
        helper.setDashboardId(component, event, helper);
        var action = component.get("c.getFiliali");
        action.setCallback(this, (response) =>{
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue();

                if(risposta.success){
                    risposta.data[0][0].selected = true;
                    component.set("v.filiali", risposta.data[0]);
                    helper.loadColumns(component, event, helper);
                    helper.loadData(component, event, helper, risposta.data[0][0].nomeFiliale);
                    component.set("v.isLoaded", true);
                } else {
                    console.log('@@@ error msg ' , risposta.message);
                }

            } else {
                console.log('@@@ errore backend ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    loadData : function(component, event, helper, nomeFiliale){
        component.set("v.isLoaded", false);
        var action = component.get("c.getDatiTabella");
        action.setParams({
            "nomeFiliale" : nomeFiliale
        });
        action.setCallback(this, (response) =>{
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue();

                if(risposta.success){
                    console.log('@@@ risposta tabella ' , risposta.data[0]);
                    helper.loadColumns(component, event, helper);
                    component.set("v.data", risposta.data[0]);
                    component.set("v.isLoaded", true);

                } else {
                    console.log('@@@ error msg ' , risposta.message);
                }

            } else {
                console.log('@@@ errore backend datatable ' , response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    loadColumns : function(component, event, helper){
        var columns = [];

        columns.push({label: $A.get("$Label.c.WGC_ReteCommerciale_Settorista"), fieldName: 'settorista', type: 'text', sortable: true},
                    {label: $A.get("$Label.c.WGC_ReteCommerciale_VC"), fieldName: 'vc', type: 'number', sortable: true},
                    {label: $A.get("$Label.c.WGC_ReteCommerciale_IndOpp"), fieldName: 'rsf', type: 'number', sortable: true},
                    {label: $A.get("$Label.c.WGC_ReteCommerciale_Pres"), fieldName: 'presentata', type: 'number', sortable: true},
                    {label: $A.get("$Label.c.WGC_ReteCommerciale_App"), fieldName: 'approvata', type: 'number', sortable: true},
                    {label: $A.get("$Label.c.WGC_ReteCommerciale_Avv"), fieldName: 'avviata', type: 'number', sortable: true},
                    {label: $A.get("$Label.c.WGC_ReteCommerciale_PercIndOpp"), fieldName: 'rsf_perc', type: 'percent', sortable: true},
                    {label: $A.get("$Label.c.WGC_ReteCommerciale_PercPres"), fieldName: 'presentata_perc', type: 'percent', sortable: true},
                    {label: $A.get("$Label.c.WGC_ReteCommerciale_PercApp"), fieldName: 'approvata_perc', type: 'percent', sortable: true},
                    {label: $A.get("$Label.c.WGC_ReteCommerciale_PercAvv"), fieldName: 'avviata_perc', type: 'percent', sortable: true}
        );

        component.set("v.columns", columns);
    },

    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.data", data);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
        
    setDashboardId : function(component, event, helper){
    	var pg = component.get("v.pageReference");
        console.log('@@@ pg ' , JSON.stringify(pg));
        
        component.set("v.dashboardId", pg.state.c__dashboardId);
    },
})