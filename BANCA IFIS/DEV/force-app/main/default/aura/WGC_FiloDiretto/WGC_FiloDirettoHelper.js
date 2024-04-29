({
    //metodo per recuperare tutti i task secondo i criteri di filo diretto
	fetchData : function(component, event, helper) {
        component.set("v.isLoaded", false);
        var numPG = component.get("v.numeroPagina");
        var elementi = component.get("v.numeroElementiPagine");
        
        var OwnerFilter = component.get("v.OwnerFilter");
        var OverdueFilter = component.get("v.OverdueFilter");
        var CampaignFilter = component.get("v.CampaignFilter");
        var TextFilter = component.get("v.textToSearch");
        var TabFilter = component.get("v.TabFilter");
        
        //var elementi = component.get("v.numeroElementiPagine");

        console.log('@@@ OwnerFilter ' , OwnerFilter);
        console.log('@@@ OverdueFilter ' , OverdueFilter);
        console.log('@@@ CampaignFilter ' , CampaignFilter);
        console.log('@@@ TextFilter ' , TextFilter);

        var action = component.get("c.filterTask");
        action.setParams({
            "OwnerFilter" : OwnerFilter,
            "OverdueFilter" : OverdueFilter,
            "CampaignFilter" : CampaignFilter,
            "TextFilter" : TextFilter,
            "TabFilter" : TabFilter,
            "numPage" : numPG,
            "limite" : elementi
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                let rsp = response.getReturnValue();
                
                console.log('@@@ rsp ' , rsp);
                var colonne = component.get("v.columns");
                console.log('@@@ colonne ' , colonne);
                console.log('@@@ ' , rsp.data.length > 0);
                if(rsp.data.length > 0){
                    this.formatTable(component, event, helper, rsp.data[0].lista);
                }
				
            	this.numeroTask(component, event, helper);

            }
            if(response.getState() == "ERROR"){
                let toast = $A.get("e.force:showToast");
                toast.setParams({
                    "title" : "ERRORE",
                    "message" : "Riprova"
                });
                toast.fire();
            }
        });
        $A.enqueueAction(action);
    },

    //Funzione per recuperare tutte le campagne attive
    fetchCampaign : function (component, event, helper){
        //var numeroPag = component.get("v.numeroPagina");
        //var elementi = component.get("v.numeroElementiPagine");

        var action = component.get("c.getCampaign");
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                console.log('@@@ campagne ' , response.getReturnValue());
                component.set("v.listaCampagne", response.getReturnValue());
                component.set("v.listaCampagneBackup", response.getReturnValue());
            }
            if(response.getState() == "ERROR"){
                let toast = $A.get("e.force:showToast");
                toast.setParams({
                    "title" : "Errore",
                    "message" : "Errore durante il caricamento delle campagne, riprovare"
                });
            }

            component.set("v.isLoaded", true);

            if(window.CampaignFilter != undefined){
                console.log('@@@ campaign filter ' , window.CampaignFilter);
                component.set("v.CampaignFilter", window.CampaignFilter);
            }
        });
        $A.enqueueAction(action);
    },
    
    toggleModal : function (component, event) {
        component.set('v.openModal', !(component.get("v.openModal")));
    },

	navigateToMyComponent: function (component, event, row, taskId) {
        console.log('@@@ row helper' , JSON.stringify(row));

        var cmpSelected = component.get("v.CampaignFilter");
        console.log('@@@ cmpSelected ' , cmpSelected);

        var navigator = component.find('navService');
        var pg = {    
            "type": "standard__component",
            "attributes": {
                "componentName": "c__WGC_FiloDiretto_EsitazioneTask",
            },
            "state": {
                "c__taskId" : row.Id,
                "c__rowData" : row,
                "c__CampaignFilter" : component.get("v.CampaignFilter"),
                "c__OwnerFilter" : component.get("v.OwnerFilter"),
                // "c__OverdueFilter" : component.get("v.OverdueFilter"),
                "c__textToSearch" : component.get("v.textToSearch"),
                "c__TabFilter" : component.get("v.TabFilter")
            }
        };

        window.CampaignFilter = component.get("v.CampaignFilter");
        window.OwnerFilter = component.get("v.OwnerFilter");
        window.OverdueFilter = component.get("v.OverdueFilter");
        window.textToSearch = component.get("v.textToSearch");
        window.TabFilter = component.get("v.TabFilter");

        navigator.navigate(pg);

        //Serve per refreshare il componente figlio
        let ms = 10;
        window.setTimeout($A.getCallback(function(){
            $A.get('e.force:refreshView').fire();
        }),ms);
    },

    changeCampaignList : function(component, event, helper){
        var listaTask = component.get("v.data");
        var listaCampaign = component.get("v.listaCampagne");
        //component.set("v.listaCampagneBackup", listaCampaign);

        console.log('@@@ listaCampaign ' , listaCampaign);
        console.log('@@@ listaTask ' , listaTask);

        var newList = [];

        listaTask.forEach((item, index) =>{
            newList.push({ Id : item.Campagna__r.Id, Name : item.Campagna__r.Name });
        });


        component.set("v.listaCampagne", newList);

    },

    callFilterMethod : function(component, event, helper){
        component.set("v.isLoaded", false);
        var OwnerFilter = component.get("v.OwnerFilter");
        var OverdueFilter = component.get("v.OverdueFilter");
        var CampaignFilter = component.get("v.CampaignFilter");
        var TextFilter = component.get("v.textToSearch");
        var TabFilter = component.get("v.TabFilter");

        var numeroPag = component.get("v.numeroPagina");
        var elementi = component.get("v.numeroElementiPagine");

        console.log('@@@ OwnerFilter ' , OwnerFilter);
        console.log('@@@ OverdueFilter ' , OverdueFilter);
        console.log('@@@ CampaignFilter ' , CampaignFilter);
        console.log('@@@ TextFilter ' , TextFilter);
        console.log('@@@ TabFilter ' , TabFilter);

        var action = component.get("c.filterTask");
        action.setParams({
            "OwnerFilter" : OwnerFilter,
            "OverdueFilter" : OverdueFilter,
            "CampaignFilter" : CampaignFilter,
            "TextFilter" : TextFilter,
            "TabFilter" : TabFilter,
            "numPage" : numeroPag,
            "limite" : elementi
        });
        action.setCallback(this, (response) =>{
            if(response.getState() == "SUCCESS"){
                console.log('@@@ risposta filtri ' , response.getReturnValue());
                var risposta = response.getReturnValue();
                if(risposta.success){
                    this.formatTable(component, event, helper, risposta.data[0].lista);
					this.numeroTask(component, event, helper);
                }
                else{
                    console.log('@@@ risposta not success ' , risposta);
                }
            }
            else{
                console.log('@@@ errore filtri ' , response.getError());
            }

            component.set("v.isLoaded", true);
        });
        $A.enqueueAction(action);
    },

    numeroTask : function(component, event, helper){
        var OwnerFilter = component.get("v.OwnerFilter");
        var OverdueFilter = component.get("v.OverdueFilter");
        var CampaignFilter = component.get("v.CampaignFilter");
        var TextFilter = component.get("v.textToSearch");
        var tabFilter = component.get("v.TabFilter");

        console.log('@@@ OwnerFilter ' , OwnerFilter);
        console.log('@@@ OverdueFilter ' , OverdueFilter);
        console.log('@@@ CampaignFilter ' , CampaignFilter);
        console.log('@@@ TextFilter ' , TextFilter);
        console.log('@@@ tabFilter ' , tabFilter);


        var action = component.get("c.numeroTaskFD");
        action.setParams({
            "OwnerFilter" : OwnerFilter,
            "OverdueFilter" : OverdueFilter,
            "CampaignFilter" : CampaignFilter,
            "TextFilter" : TextFilter,
            "TabFilter" : tabFilter
        });
        action.setCallback(this, (response) =>{
            if(response.getState() == "SUCCESS"){
                console.log('@@@ risposta filtri ' , response.getReturnValue());
                var risposta = response.getReturnValue();
                component.set("v.totaleElementi" , risposta);

                var totPagine = Math.ceil(risposta / 25);
                console.log('@@@ MATH.ceil ' , Math.ceil(risposta / 25));
                console.log('@@@ totPagine ' , totPagine);
                component.set("v.totalePag", totPagine);

                var numPG = component.get("v.numeroPagina");
                var elementi = component.get("v.numeroElementiPagine");
                //var totale = component.get("v.totaleElementi");
        
                var off = ((numPG+1) * elementi);
                console.log('@@@ off ' , off);
            	console.log('@@@ risposta ' , risposta);
                if(off >= risposta){
                    component.set("v.isLast", true);
                    //component.set("v.isFirst", false);
                }
                else{
                    component.set("v.isLast", false);
                }
            }
            else{

            }

        });

        $A.enqueueAction(action);
    },
    
    formatTable : function(component, event, helper, listaTask){
        listaTask.forEach((item, index) =>{
            //Imposto la lookup con nome e link all'account
            if(item.What){
                item.AccountName = item.What.Name;
                item.WhatId = '/'+item.WhatId;
            }
            //Imposto il nome visibile e non l'id
            if(item.Owner){
                item.Owner = item.Owner.Name;
            }
            //come sopra
            if(item.Campagna__r){
                item.Campagna = item.Campagna__r.Name;
            }
            
            if(item.Campagna__r == undefined){
                item.Campagna__r = { Id: '' , Name : '' };
            }

            if(item.Originator_di_dettaglio__c){
                item.Originator_di_dettaglio = item.Originator_di_dettaglio__c;
            }

            item.icon = "standard:task";
            
            var oggi = new Date();
            var scad = new Date();
            scad = scad.setDate(oggi.getDate() - 1);
        	scad = new Date(scad);
        	console.log('@@@ data scadenza ' , scad);
        	console.log('@@@ new Date(item.ActivityDate) ' , new Date(item.ActivityDate));
            if(new Date(item.ActivityDate) < scad){
                item.cellClass = 'expired-date';
                item.btnC = 'red-btn';
            }
            else{
                item.btnC = 'blue-btn';
            }
        });
        component.set("v.data", listaTask);
    },

    // sortCol : function(component, event, helper){
    //     console.log('@@@ params ' + event.getParams());
    //     var fieldName = event.getParam('fieldName');
    //     var sortDirection = event.getParam('sortDirection');
    //     // assign the latest attribute with the sorted column fieldName and sorted direction
    //     cmp.set("v.sortedBy", fieldName);
    //     cmp.set("v.sortedDirection", sortDirection);
    //     helper.sortData(component, fieldName, sortDirection);
    // },

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
    }
})