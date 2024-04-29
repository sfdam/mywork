({
    cancel : function (component, event, helper) {
        var campagna = component.get("v.referenceCampagna");
        var navigator = component.find("navService");
        
        var pg = {
                "type": "standard__navItemPage",
                "attributes": {
                    "apiName": "WGC_Attivit_Filo_Diretto"
                }
        };

        navigator.navigate(pg);
    },

    doInit : function(component, event, helper){
        helper.initialize(component, event, helper);
    },

    // recordUpdate : function(component, event, helper){
    //     console.log('@@@ recordUpdate ' , event.getParams());
    //     helper.initialize(component, event, helper);
    // },

    // hideOverwrite : function(component, event, helper){
    //     var sourceName = event.getSource().get("v.name");
    //     var newValue = event.getSource().get("v.value");

    //     component.set("v."+sourceName, !newValue);
    // },

    // setOverwrite : function(component, event, helper){
    //     var sourceName = event.getSource().get("v.name");
    //     var newValue = event.getSource().get("v.value");

    //     component.set("v."+sourceName, !newValue);
    // },

    AnnullaEsitazioneEvento : function(component, event, helper){
        component.set("v.isVisitaCommerciale", !component.get("v.isVisitaCommerciale"));

        //Serve per refreshare il altrimenti errore sul find
        let ms = 10;
        window.setTimeout($A.getCallback(function(){
            $A.get('e.force:refreshView').fire();
        }),ms);
    },

    onChangeComune : function(component, event, helper){
        var newValue = event.getSource().get("v.value");

        var accId = component.get("v.rowData.WhatId");
        var comune = component.get("v.comuneSelected");
        if(accId[0] == '/'){
            accId = accId.substring(1);
        }
        console.log('@@@ accId ' , accId);
        console.log('@@@ comune ' , JSON.stringify(comune));
        
        if(!comune.hasOwnProperty("Id")) component.set("v.visita.OwnerId", "");
        //Funzione per recuperare la lista di utenti in base all'assegnazione territoriale
        helper.getUserByComune(component, event, helper, accId, comune.Id);
    },

    //Metodo che al cambio del valore di una picklist esito recupera le nuove dipendenze, abilita o disabilita i campi in base al valore scelto
    onChangePickValue : function(component, event, helper){
        helper.onChangePickValue(component, event, helper);
    },

    onChangeStartDateTimeVisita : function(component, event, helper){
        var visita = component.get("v.visita");
        console.log('@@@ visita before ' , visita);
        var a = new Date(visita.StartDateTime);
        var a = a.setHours(a.getHours()+1);
        console.log('@@@ a ' + a);
        var b = new Date(a);
        console.log('@@@ b ' + b);
        var c = b.toISOString();
        console.log('@@@ c' + c);
        //visita.StartDateTime = visita.EndDateTime;
        visita.EndDateTime = c;
        console.log('@@@ visita after ' , visita);
        component.set("v.visita", visita);
    },

    //Al cambio della data vado a recuperare gli eventi in base agli assegnatari del comune scelto
    onChangeEndDateTimeVisita : function(component, event, helper){
        var visita = component.get("v.visita");
        var visita = component.get("v.visita");
        //visita.StartDateTime = visita.EndDateTime;
        component.set("v.visita", visita);

        var newValue = event.getSource().get("v.value");

        if(newValue != null){
            helper.getVisiteByUser(component, event, helper);
        }
    },

    //Recupero il nuovo valore dell'owner e lo setto nell'oggetto visita
    onChangeAssegnatario : function(component, event, helper){
        var newValue = event.getSource().get("v.value");
        console.log('@@@ newValue ' , newValue);
        //Sovrascrivo l'ownership
        var visita = component.get("v.visita");
        visita.OwnerId = newValue;
        component.set("v.visita", visita);
        console.log('@@@ visita dopo assegnatario ' , JSON.stringify(visita));
    },

    saveCampagnaSubject : function(component, event, helper){
        component.set("v.isLoaded", false);

        var campaignName;

        //Formatto l'id campagna e il name in modo
        var taskToUpdate = component.get("v.tsk");

        var campaignToUpdate = component.get("v.rowData.Campagna__r");
        console.log('@@@ campaignToUpdate ' , JSON.stringify(campaignToUpdate));
        var taskId = component.get("v.rowData.Id");

        taskToUpdate.Campagna__c = ( campaignToUpdate.Id != null && campaignToUpdate.Id != undefined ) ? campaignToUpdate.Id : '';
        taskToUpdate.Id = taskId;

        for(var key in taskToUpdate){
            console.log('@@@ key ' , key);
            if(key != 'sobjectType' && key != 'Campagna__c' && key != 'Id'){
                delete taskToUpdate[key];
            }
        }

        taskToUpdate.Subject = component.get("v.selectedSubject");

        console.log('@@@ taskToUpdate ' , JSON.stringify(taskToUpdate));

        var action = component.get("c.updateTaskCampaign");
        action.setParams({
            "strTaskToUpdate" : JSON.stringify(taskToUpdate)
        });
        action.setCallback(this, (response) => {
            if(response.getState() == 'SUCCESS'){
                var risposta = response.getReturnValue();
                console.log('@@@ risposta update campaign ' , risposta);
                
                if(risposta.success){
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({
                        "title" : "Aggiornato",
                        "message" : risposta.message,
                        "type" : "SUCCESS"
                    });
                    msg.fire();
                    
                    if(campaignName != undefined && campaignName != null && campaignName != ''){
                        console.log('@@@ after ' , JSON.stringify(component.get("v.rowData")));
                        component.set("v.rowData.Campagna__r.Name" , campaignName);
                        component.set("v.rowData.Campagna__c" , taskToUpdate.Campagna__c);
                        console.log('@@@ after ' , JSON.stringify(component.get("v.rowData")));
                    }

                    component.set("v.rowData.Subject", taskToUpdate.Subject);
                }
                else{
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({
                        "title" : "Errore",
                        "message" : risposta.message,
                        "type" : "ERROR"
                    });
                    msg.fire();
                }
            }
            else{
                console.log('@@@@ error updating campaign ' , response.getError());
            }

            component.set("v.isLoaded", true);
        });
        $A.enqueueAction(action);
    },

    esitaTask : function (component, event, helper) {
        //Blocca il submit della form
        event.preventDefault();
        //Abilito spinner durante il salvataggio
        component.set("v.isLoaded", false);
        //Setto i valori mancanti al task e passo il task come parametro
        var task = component.get("v.tsk");
        console.log('@@@ task initial ' , JSON.stringify(task));
        console.log('@@@ test task ' , component.get("v.rowData.WhatId"));
        var sviluppato = component.get("v.developed");
        // var overwrite = component.get("v.overwrite");
        
        console.log('@@@ tipoAtt ' , component.find('TipoAtt'));
        //Prendo il valore di tutte le picklist
        var tipoAtt = component.find('TipoAtt').get("v.value");
        
        var esitolivello1 = component.find("EsitoLivello1").get("v.value");
        var esitolivello2 = component.find("EsitoLivello2").get("v.value");
        //var esitolivello3 = component.find("EsitoLivello3").get("v.value");
        //var esitolivello4 = component.find("EsitoLivello4").get("v.value");
        //var esitolivello5 = component.find("EsitoLivello5").get("v.value");

        var note = component.find("note").get("v.value");

        var dataRic = component.find("dataricontatto").get("v.value");
        var dataCheck = component.get("v.dataricontattodisabled");

        //Aggiungo i valori mancanti al task per poterlo esitare correttamente
        task.Id = component.get("v.rowData").Id;
        task.WhatId = component.get("v.rowData.WhatId");
        task.TipoAttivita__c = tipoAtt;
        task.EsitoLivello1__c = esitolivello1;
        task.EsitoLivello2__c = esitolivello2;
        //task.EsitoLivello3__c = esitolivello3;
        //task.EsitoLivello4__c = esitolivello4;
        //task.EsitoLivello5__c = esitolivello5;
        task.GiaCliente__c = sviluppato;
        task.WGC_Sviluppo_in_corso__c = component.get("v.insviluppo");
        task.DataRicontatto__c = task.ActivityDate;

        //Controllo aggiunto per non fare scoppiare il trigger
        if(task.GiaCliente__c){
            task.TipoAttivita__c = 'Sviluppo Diretto';
        }
        //component.set("v.tsk", task);
        console.log('@@@ task completo' , JSON.stringify(task));

        task.Campagna__r = component.get("v.rowData.Campagna__r");
        console.log('@@@ campagna test ' , component.get("v.rowData.Campagna__r"));


        //Prendo il valore della picklist esito livello2 per verificare che abbia il valore necessario alla creazione della visita commerciale
        if(esitolivello1.toLowerCase() == ("Fissata Visita").toLowerCase()){
            component.set("v.tsk", task);
            component.set("v.isVisitaCommerciale", false);
            component.set("v.isLoaded", true);
            var visita = component.get("v.visita");
            visita.Description = component.get("v.tsk").CommentiEsito__c;
            visita.Subject = 'Visita Commerciale';
			if(task.Campagna__r != undefined && task.Campagna__r.Id != undefined) visita.Campagna__r = task.Campagna__r;
            component.set("v.visita" , visita);
            console.log('@@@ visita test ' , component.get("v.visita"));
        }
        else if(((tipoAtt != '' && tipoAtt != null && tipoAtt != undefined) && 
                (note != '' && note != null && note != undefined )) || 
                (note != '' && note != null && note != undefined ) && sviluppato ||
                (dataRic != null && dataRic != undefined && !dataCheck)){
            helper.esitaTaskHelp(component, event, helper, task);
        }
        else{
            var msg = $A.get("e.force:showToast");
            msg.setParams({
                "title" : "Errore",
                "message" : "Compila i campi obbligatori non compilati",
                "type" : "ERROR"
            });
            msg.fire();

            component.set("v.isLoaded", true);
            return;
        }
    },

    EsitaVisitaCommerciale : function(component, event, helper){
        component.set("v.isLoaded", false);
        var visita = component.get("v.visita");
        var accId;
        var objTask = component.get("v.tsk");

        if(component.get("v.rowData.WhatId") != null){
            if(component.get("v.rowData.WhatId")[0] == '/'){
                accId = component.get("v.rowData.WhatId").substring(1);
            }
            accId = component.get("v.rowData.WhatId");
        }
        else{
            accId = component.get("v.ContactRecord.Id");
        }
        
        //visita.OwnerId = owner;
        if(accId.includes('/')){
            accId = accId.substring(1);
        }
        visita.WhatId = accId;

        //Controllo che non esistano visite nel calendario in sovrapposizione con la visita esitata
        var esitoOccupato = helper.checkCalendario(component, event, helper, visita);
        console.log('@@@ esitoOccupato ' , esitoOccupato);

        var task = component.get("v.tsk");
        if(task.TipoAttivita__c == 'Sviluppo Diretto'){
            visita.TipoAttivita__c = task.TipoAttivita__c
        }
        else{
            visita.TipoAttivita__c = 'Sviluppo Indiretto';
        }
        console.log('@@@ visita ' , JSON.stringify(visita));

        var campagnaId = component.get("v.rowData.Campagna__r.Id");
        var campagnaName = (campagnaId != undefined && campagnaId != null) ? component.get("v.rowData.Campagna__r.Name") : '';
        
        console.log('@@@ campagnaId ' , campagnaId);
        console.log('@@@ campagnaName ' , campagnaName);

        visita.Campagna__c = (campagnaId) ? task.Campagna__r.Id : campagnaId != '' ? campagnaId : '';
        
        console.log('@@@ controllo ' , visita.Campagna__c == '' || visita.Campagna__c == null || visita.Campagna__c == undefined || !visita.hasOwnProperty('Campagna__c') );
        if(visita.Campagna__c == '' || visita.Campagna__c == null || visita.Campagna__c == undefined || !visita.hasOwnProperty('Campagna__c')) delete visita['Campagna__r'];


        //Aggiungo 2 campi
        objTask.ActivityDate = component.get("v.rowData.ActivityDate");
        objTask.OwnerId = $A.get("$SObjectType.CurrentUser.Id");
        objTask.Campagna__c = (campagnaId) ? task.Campagna__r.Id : campagnaId != '' ? campagnaId : '';
        if(!campagnaId) delete objTask['Campagna__r'];
        
        console.log('@@@ campagna test ' , JSON.stringify(component.get("v.rowData.Campagna__r")));
        //visita.CommentiEsito__c = visita.Descrizione;
        if(!esitoOccupato){
            console.log('@@@ visita ' , JSON.stringify(visita));
            console.log('@@@ task ' , JSON.stringify(objTask));
            if(visita.OwnerId == null || visita.OwnerId == '' || visita.OwnerId == undefined) {
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "title" : "ERRORE",
                    "type" : "ERROR",
                    "message" : "Errore nella compilazione campi, ricontrolla i valori inseriti"
                });
                toast.fire();
                component.set("v.isLoaded", true);
                return;
            }
            //Salvataggio
            var action = component.get("c.saveVisita");
            action.setParams({
                visitaObj : JSON.stringify(visita),
                taskAssociato : objTask
            });
            action.setCallback(this, function(response){
                if(response.getState() == "SUCCESS"){
                    var risposta = response.getReturnValue();
                    console.log('@@@ risposta visita' , risposta);

                    if(risposta.success){
                        //funzione per esitare il task rimasto appesso dopo la creazione della visita commerciale
                        helper.esitaTaskHelp(component, event, helper, objTask);
                    }
                    else{
                        var toast = $A.get("e.force:showToast");
                        toast.setParams({
                            "title" : "ERRORE",
                            "type" : "ERROR",
                            "message" : "Errore nella compilazione campi, ricontrolla i valori inseriti"
                        });
                        toast.fire();
                    }
                }
                else{
                    console.log('@@@ error ' , response.getError());
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        "title" : "ERRORE",
                        "type" : "ERROR",
                        "message" : "Errore durante il salvataggio della visita commerciale"
                    });
                    toast.fire();
                }
            });
            $A.enqueueAction(action);
        }
        else{
            var msg = $A.get("e.force:showToast");
            msg.setParams({
                "title" : "Errore",
                "message" : "Assegnatario visita occupato durante l'orario scelto, selezionare un'altro orario",
                "type" : "ERROR"
            });
            msg.fire();
        }
    },

    checkValidInput : function(component, event, helper){
        var note = component.get("v.tsk.CommentiEsito__c");

        var tipoAtt = component.find("TipoAtt").get("v.value");

        var developed = component.get("v.developed"); 
        //var esitolivello1 = component.find("EsitoLivello1").get("v.value");
        var dataRic = component.find("dataricontatto").get("v.value");
        var dataCheck = component.get("v.dataricontattodisabled");
        console.log('data ', dataCheck);
        console.log('datra ric ',dataRic);
        
        if((note != null && note != undefined && note != "") &&
        (tipoAtt != null && tipoAtt != undefined && tipoAtt != "") &&
        (((dataRic != null && dataRic != undefined) && dataCheck) || !dataCheck) || 
        (note != null && note != undefined && note != "") && (developed) &&
        (((dataRic != null && dataRic != undefined) && dataCheck) || !dataCheck))
            {
                component.set("v.disabled", false);
        }
        else{
            component.set("v.disabled", true);
        }
    },

    onChangeTask : function(component, event, helper){
        console.log('@@@ cambia ' , event.getSource().get("v.value"));
    },
})