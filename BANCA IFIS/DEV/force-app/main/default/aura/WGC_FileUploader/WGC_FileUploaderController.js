({
	doInit : function(component, event, helper) {
        //helper.initialize(component, event, helper);
        // var doc = component.get("v.datiDoc");
        // console.log('@@@ doc ' , doc);
        // var dati = component.get("v.datiDocNote");
        // console.log('@@@ dati ' , JSON.stringify(dati));
        // var recId = component.get("v.recordId");
        // console.log('@@@ recId up ' , recId);

        // var notaId = component.get("v.idNota");
		// console.log('@@@ notaId up ' , notaId);

        helper.initialize(component, event, helper);
    },
    
    changeFamDoc : function(component, event, helper){
        var source = event.getSource();
        var newValue = source.get("v.value");

        if(newValue != ''){
            component.set("v.fam", false);

            var mappatura = component.get("v.mappatura");

            mappatura.forEach((item, index) =>{
                if(item.famiglia == newValue){
                    console.log('@@@ item.documento ' , item.documento);
                    component.set("v.tipo", item.documento);
                }
            });
        }
    },

	//adione CR 293
	changeSoggetto : function(component, event, helper) {
		var sel = component.get("v.selectedSogg");
        console.log ('-----> WGC_FileUploader - changeSoggetto: '+sel);
	},
    
    handleUploadFinished : function(component, event, helper){
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        console.log('@@@ uploaded file ' , JSON.stringify(uploadedFiles[0]));
        component.set("v.documentId", uploadedFiles[0].documentId);
        component.set("v.fileName", uploadedFiles[0].name);
    },

    changeDoc : function(component, event, helper){
        var value = event.getSource().get("v.value");
        console.log('@@@ value ' , value);

        component.set("v.datiDoc", value);
        
        component.set("v.bloccaDoc", true);

        helper.newMappingDoc(component, event, helper, false);
    },

    salvaDoc : function(component, event, helper){
        component.set("v.isLoaded", false);
        event.preventDefault();
        //Mi costruisco un oggetto con tutti i valori da controllare

        var validDataProd = helper.checkDataProduzioneHelper(component, event, helper);
        var validDataScad = helper.checkDataScadenzaHelper(component, event, helper);
        
        var dataprod = component.find("dataprod");
        var datascad = component.find("datascad");

        if(!validDataProd){
            Array.isArray(dataprod) ? dataprod[0].showHelpMessageIfInvalid() : dataprod.showHelpMessageIfInvalid();
            // component.find("dataprod").showHelpMessageIfInvalid(component, event, helper);
            component.set("v.isLoaded", true);
            component.set("v.bloccaDoc", false);
            helper.newMappingDoc(component, event, helper, false);
            return;
        }
        else if(!validDataScad){
            Array.isArray(datascad) ? datascad[0].showHelpMessageIfInvalid() : datascad.showHelpMessageIfInvalid();
            // component.find("datascad").showHelpMessageIfInvalid(component, event, helper);
            component.set("v.isLoaded", true);
            component.set("v.bloccaDoc", false);
            helper.newMappingDoc(component, event, helper, false);
            return;
        }

        var dataProduzione = component.get("v.dataProduzione");
        var tmp = new Date(dataProduzione);
        dataProduzione = tmp.toLocaleDateString('it-IT', { year: 'numeric', month: '2-digit', day: 'numeric' });
        var dataScadenza = component.get("v.dataScadenza");
        tmp = new Date(dataScadenza);
        dataScadenza = tmp.toLocaleDateString('it-IT', { year: 'numeric', month: '2-digit', day: 'numeric' });

        //var famiglia = component.find('famiglia').get("v.value");
        var famiglia = component.get("v.selectedF");
        //var tipoDoc = component.find('tipo').get("v.value");
        var tipoDoc = component.get("v.selectedSC");
        var docId = component.get("v.documentId");
        
        var optyId = component.get("v.optyId");
        var noteDoc = component.find("noteDocUpload");

		var docWrap = { "dataProduzione" : dataProduzione != undefined ? dataProduzione : '' , 
						"dataScadenza" : dataScadenza != undefined ? dataScadenza : '',
						"famiglia" : famiglia,
						"tipoDoc" : tipoDoc,
                        "docId" : docId,
                        "noteDocUpload" : Array.isArray(noteDoc) ? noteDoc[0].get('v.value') : noteDoc != undefined ? noteDoc.get("v.value") : ''
		};
        
        console.log('@@@ docWrap ' , JSON.stringify(docWrap));

        var accountId = component.get("v.recordId");
		//adione CR 293
		var idSoggetto = component.get("v.selectedSogg"); 
                        
        var esitoValidazione = true;

        esitoValidazione = helper.convalidaDati(component, event, helper, docWrap);

        if(esitoValidazione){

			console.log('-----> WGC_FileUploader.salvaDoc - id soggetto: ' +(idSoggetto != null) ? idSoggetto : accountId);
            component.set("v.docWrapper", docWrap);
            component.set("v.isLoaded", false);
            var action = component.get('c.uploadDocMultipart');
            action.setParams({
                "recordId" : (idSoggetto != null) ? idSoggetto : accountId,
                "docToInsert" : JSON.stringify(docWrap),
                "optyId" : optyId,
                "delDoc" : true
            });
            action.setCallback(this, function(response){
                if(response.getState() == "SUCCESS"){
                    var risposta = response.getReturnValue();
                    console.log('@@@ risposta upload ' , risposta);

                    if(risposta.success){
                        component.find('notifLib').showToast({
                            "variant": "success",
                            "title": "Upload eseguito!",
                            "message": "Upload eseguito con successo",
                            closeCallback: function() {
                                //alert('You closed the alert!');
                            }
                        });

                        console.log('@@@ datiDoc ', JSON.stringify(component.get("v.datiDoc")));
                        console.log('@@@ listaDocs ' , component.get("v.docFisso"));
                        console.log('@@@ indiceAttore ' , component.get("v.indiceAttore"));

                        if(risposta.data.length > 0){
                            var uploadEvt = $A.get("e.c:WGC_HandlerFileUpload");
                            console.log('@@@ uploadEvt ' , uploadEvt);

                            var evtParam = { "id" : (risposta.data[0].payload) ? risposta.data[0].payload.datiDocumento.idDocumento : null, "index_value" : component.get("v.datiDoc"), "listToUpdate" : component.get("v.docFisso"), "indiceAttori" : component.get("v.indiceAttore"), "dataScadenza" : tmp, "title" : component.get("v.fileName")};

                            uploadEvt.setParams({
                                "param" : evtParam,
                                "futureCall" : false
                            });

                            uploadEvt.fire();
                        }
                        else{
                            if(risposta.data.length == 0){
                                var uploadEvt = $A.get("e.c:WGC_HandlerFileUpload");
                                console.log('@@@ uploadEvt ' , uploadEvt);
        
                                var evtParam = { "index_value" : component.get("v.datiDoc"), "listToUpdate" : component.get("v.docFisso"), "indiceAttori" : component.get("v.indiceAttore"), "dataScadenza" : tmp, "title" : component.get("v.fileName")};

                                uploadEvt.setParams({
                                    "param" : evtParam,
                                    "futureCall" : true
                                });
    
                                uploadEvt.fire();
                            }
                        }

                        component.find('overlayLib').notifyClose();
                        console.log('@@@ docWrapper ' , component.get("v.docWrapper"));
                    }
                    else{
                        console.log('@@@ response status error ' , risposta);
                        component.find('notifLib').showToast({
                            "variant": "error",
                            "title": "Attenzione!",
                            "message": risposta.message,
                            closeCallback: function() {
                                //alert('You closed the alert!');
                            }
                        });
                        component.find('overlayLib').notifyClose();
                    }
                    component.set("v.isLoaded", true);
                }
                else{
                    //ERROR
                    console.log('@@@ response status error ' , response.getError());
                    component.find('notifLib').showToast({
                        "variant": "error",
                        "title": "Attenzione!",
                        "message": "Errore durante l'upload del documento, riprovare",
                        closeCallback: function() {
                            //alert('You closed the alert!');
                        }
                    });
                    component.find('overlayLib').notifyClose();
                }
            });
            $A.enqueueAction(action);
        }
        else{
            //component.set("v.isLoaded" , true);
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Attenzione!",
                "message": "Compilare tutti i campi per salvare il documento",
                closeCallback: function() {
                    //alert('You closed the alert!');
                }
            });
            component.set("v.isLoaded", true);
            component.set("v.bloccaDoc", false);
            helper.newMappingDoc(component, event, helper, true);
        }
    },

    eliminaNote : function(component, event, helper){
        event.preventDefault();
        component.set("v.isLoaded", false);
        component.find('recordLoader').deleteRecord($A.getCallback(function(deleteResult) {
            
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                console.log('@@@ delete ok ' , JSON.stringify(deleteResult));

                var datiDocNote = component.get("v.datiDocNote");
        
                console.log('@@@ datiDocNote ' , JSON.stringify(datiDocNote));
        
                var lista = component.get("v.listToUpdate");
                console.log('@@@ listToUpdate ' , lista);

                var recordIdAttore = component.get("v.recordId");
                console.log('@@@ recordIdAttore ' , recordIdAttore); 
        
                var json = { "idNota" : null , "doc" : datiDocNote, "listToUpdate" : lista, "idAttore" : recordIdAttore };
                //Lancio evento per gestire l'inserimento di un nota ed aggangiare l'id al doc corretto
                var updateNoteEvt = $A.get("e.c:WGC_ChangeDocInfo");
                updateNoteEvt.setParams({
                    "json" : json,
                    "type" : "note",
                    "success" : true
                });
        
                updateNoteEvt.fire();

                component.set("v.modalBodyAttributeName", 'ELIMINA');
                component.find('overlayLib').notifyClose();

            } else if (deleteResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (deleteResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + JSON.stringify(deleteResult.error));
            } else {
                console.log('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
            }
        }));

        //component.set("v.isLoaded", true);
        // var note = component.get("v.noteDoc");
        // var recordId = component.get("v.recordId");
        // var datiDocNote = component.get("v.datiDocNote");
        // var accId = component.get("v.accId");
        // var docId = datiDocNote.index_value;

        // console.log('@@@ note ' , note);
        // console.log('@@@ recordId ' , recordId);
        // console.log('@@@ datiDocNote ' , JSON.stringify(datiDocNote));
        // console.log('@@@ accId ' , accId);
        // console.log('@@@ docId ' , docId);
        
        // var action = component.get("c.handleNote");
        // action.setParams({
        //     "recordId" : recordId,
        //     "note" : note,
        //     "docId" : docId
        // });
        // action.setCallback(this, (response) =>{
        //     if(response.getState() == "SUCCESS"){
        //         var risposta = response.getReturnValue();
        //         console.log('@@@ risposta ' , risposta );

        //         if(risposta.success){
                    
        //         }
        //         else{

        //         }
        //         component.set("v.modalBodyAttributeName", 'ELIMINA');
        //         component.find('overlayLib').notifyClose();
        //     }
        //     else{
        //         console.log('@@@ error ' , response.getError());
        //     }
        // });
        // $A.enqueueAction(action);
    },

    checkDataProduzione : function(component, event, helper){
        helper.checkDataProduzioneHelper(component, event, helper);

        var docFisso = component.get("v.selectedSC");
        console.log('@@@ docFisso ' , docFisso);
        
        if(docFisso != 'SY0000002'){
            helper.newMappingDoc(component, event, helper, true);
        }
        else{
            helper.newMappingDoc(component, event, helper, false);
        }
    },

    checkDataScadenza : function(component, event, helper){
        console.log('@@@ checkDataScadenza ' , event.getSource().get("v.value")); 
        helper.checkDataScadenzaHelper(component, event, helper);
    },

    handleSubmit : function(component, event, helper){
        event.preventDefault();
        var fields = event.getParam("fields");
        console.log('@@@ fields ' , fields);

        var docId = component.get("v.datiDocNote.index_value");
        console.log('@@@ docId ' , docId);
        var recordId = component.get("v.recordId");
        console.log('@@@ recordId ' , recordId);

        fields.Id_univoco__c = recordId + '_' + docId;

        component.set("v.noteDoc", fields.Note__c);
        component.find("form").submit(fields);

        console.log('@@@ prova ');
    },

    handleError : function(component, event, helper){
        console.log('@@@ error ' , JSON.stringify(event.getParams()));
        component.set("v.idNota", null);
        component.set("v.notAvailable", true);
        helper.initialize(component, event, helper);
        //component.set("v.isLoaded", true);
    },

    handleSuccess : function(component, event, helper){
        console.log('@@@ success ' , JSON.stringify(event.getParams()));

        var notaId = event.getParams().response.id;
        console.log('@@@ notaId ' , notaId);

        component.set("v.modalBodyAttributeName", 'SALVA');

        var datiDocNote = component.get("v.datiDocNote");

        console.log('@@@ datiDocNote ' , JSON.stringify(datiDocNote));

        var lista = component.get("v.listToUpdate");
        console.log('@@@ listToUpdate ' , lista);

        var recordIdAttore = component.get("v.recordId");
        console.log('@@@ recordIdAttore ' , recordIdAttore); 

        var json = { "idNota" : notaId , "doc" : datiDocNote, "listToUpdate" : lista, "idAttore" : recordIdAttore };
        //Lancio evento per gestire l'inserimento di un nota ed aggangiare l'id al doc corretto
        var updateNoteEvt = $A.get("e.c:WGC_ChangeDocInfo");
        updateNoteEvt.setParams({
            "json" : json,
            "type" : "note",
            "success" : true
        });

        updateNoteEvt.fire();

        component.find('overlayLib').notifyClose();
    },

    changeNota : function(component, event, helper){
        var newValue = event.getSource().get("v.value");
        console.log('@@@ newValue ' , newValue);

    },

    close : function(component, event, helper){
        //Resetto il flag
        component.set("v.modalBodyAttributeName", 'ANNULLA');
		var lib = component.find('overlayLib');
		lib.notifyClose();
	},
})