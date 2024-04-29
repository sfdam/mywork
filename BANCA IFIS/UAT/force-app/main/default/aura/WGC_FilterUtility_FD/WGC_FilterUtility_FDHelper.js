({
    initialize : function(component, event, helper) {
        this.getUserInfo(component, event, helper);
        this.getFilterValues(component, event, helper);
    },

    getUserInfo : function(component, event, helper){
        var action = component.get("c.getUserInfo");
        action.setCallback(this, (response) =>{
            if(response.getState() == "SUCCESS"){
                console.log('@@@ utente ' , response.getReturnValue());
                component.set("v.utente", response.getReturnValue());
            } else {
                console.log('@@@ error filter ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getPageRef : function(component, event, helper){
        var pg = component.get("v.pageReference");
        // console.log('@@@ pg filtri ' , JSON.stringify(pg));

        var user = component.get("v.utente");
        // console.log('@@@ utente ' , JSON.stringify(user));
        // console.log('@@@ empty ' , user != null && user != undefined);

        if(pg != null && pg != undefined){
            if(pg.attributes.hasOwnProperty("pageName") && pg.attributes.pageName == "home" && user.hasOwnProperty("Profile") && user.Profile.Name == "IFIS - Filo Diretto"){
                component.set("v.isAllowed", false);
            } else if(pg.attributes.hasOwnProperty("apiName") && pg.attributes.apiName == "Il_mio_Team" && user.hasOwnProperty("Profile") && user.Profile.Name == "IFIS - Filo Diretto") {
                component.set("v.isAllowed", true);
            }
        }
    },

    getFilterValues : function(component, event, helper){
        var action = component.get("c.getFilterValues");
        action.setCallback(this, (response) =>{
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue();

                if(risposta.success){
                    console.log('@@@ risposta filtri ' , risposta.data );
                    component.set("v.filtri", risposta.data[0]);

                    //Funzione per capire se siamo in home page, o in un'altro tab
                    this.getPageRef(component, event, helper);

                } else {
                    console.log('@@@ errore filtri ' , risposta.message);
                }
            } else {
                console.log('@@@ errore filtri ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    applyFilter : function(component, event, helper){
        var filterValue = component.get("v.selectedValue");
        console.log('@@@ filterValue ' , filterValue);
        console.log('@@@ json stringify ' , filterValue);
        var allFilter = component.get("v.filtri");
        var filtri = [];
        var res = {};

        allFilter.forEach((item, index) =>{
            console.log('@@@ item ' , item);
            filtri = filtri.concat(item.listaFiltri);
        });

        console.log('@@@ filtri ' , filtri);
        res = filtri.find((element) =>{
            console.log('@@@ element.value ' , element.value);
            console.log('@@@ filterValue ' , filterValue);
            console.log('@@@ condizione ' , element.value == filterValue);
            return (element.value == filterValue);
        });

        console.log('@@@ res ' , res);

        var filterEvt = $A.get("e.c:WGC_FilterEvent_FD");

        if(res != undefined){
            filterEvt.setParams({
                "userId" : !res.isTeam ? res.value : '',
                "teamName" : res.isTeam ? res.value : '',
                "applyFilter" : true,
                "isAllUser" : false
            });

            window.localStorage.setItem('userId', !res.isTeam ? res.value : '');
            window.localStorage.setItem('teamName', res.isTeam ? res.value : '');
            window.localStorage.setItem('isAllUser', false);
        } else {
            filterEvt.setParams({
                "userId" : '',
                "teamName" : '',
                "applyFilter" : true,
                "isAllUser" : true
            });

            window.localStorage.setItem('userId', '');
            window.localStorage.setItem('teamName', '');
            window.localStorage.setItem('isAllUser', true);
        }
        filterEvt.fire();

        console.log('@@@ localStorage ' , window.localStorage.getItem('userId'));
        console.log('@@@ localStorage ' , window.localStorage.getItem('teamName'));
    },
})