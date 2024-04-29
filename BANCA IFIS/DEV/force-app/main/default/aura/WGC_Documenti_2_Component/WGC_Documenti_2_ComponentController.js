({
  doInit: function (component, event, helper) {
    component.set("v.isLoaded", false);
    helper.initialize(component, event, helper);
    helper.getProfilo(component, event, helper);
  },

  Collapse: function (component, event, helper) {
    helper.setCollapse(component, event, helper);
  },

  /*
	callDettaglioDoc : function(component, event, helper){
		var action = component.get('c.getDettaglioDoc');
		action.setCallback(this, response =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				console.log('@@@ risposta doc06 ' , risposta);
			}
			else{
				console.log('@@@ error ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	},
	*/

  //funzioni che gestisce il flip delle card
  doFlip: function (component, event, helper) {
    var a = event.getSource().getLocalId();
    if (a == "isFlip0") {
      var flip = component.get("v.isFlip0");
      if (flip == true) {
        component.set("v.isFlip0", false);
      } else {
        component.set("v.isFlip0", true);
      }
    } else if (a == "isFlip1") {
      var flip = component.get("v.isFlip1");
      if (flip == true) {
        component.set("v.isFlip1", false);
      } else {
        component.set("v.isFlip1", true);
      }
    } else if (a == "isFlip2") {
      var flip = component.get("v.isFlip2");
      if (flip == true) {
        component.set("v.isFlip2", false);
      } else {
        component.set("v.isFlip2", true);
      }
    } else if (a == "isFlip3") {
      var flip = component.get("v.isFlip3");
      if (flip == true) {
        component.set("v.isFlip3", false);
      } else {
        component.set("v.isFlip3", true);
      }
    } else if (a == "isFlip4") {
      var flip = component.get("v.isFlip4");
      if (flip == true) {
        component.set("v.isFlip4", false);
      } else {
        component.set("v.isFlip4", true);
      }
    } else if (a == "isFlip5") {
      var flip = component.get("v.isFlip5");
      if (flip == true) {
        component.set("v.isFlip5", false);
      } else {
        component.set("v.isFlip5", true);
      }
    } else if (a == "isFlip6") {
      var flip = component.get("v.isFlip6");
      if (flip == true) {
        component.set("v.isFlip6", false);
      } else {
        component.set("v.isFlip6", true);
      }
    } else if (a == "isFlip7") {
      var flip = component.get("v.isFlip7");
      if (flip == true) {
        component.set("v.isFlip7", false);
      } else {
        component.set("v.isFlip7", true);
      }
    } else if (a == "isFlip8") {
      var flip = component.get("v.isFlip8");
      if (flip == true) {
        component.set("v.isFlip8", false);
      } else {
        component.set("v.isFlip8", true);
      }
    } else if (a == "isFlip9") {
      var flip = component.get("v.isFlip9");
      if (flip == true) {
        component.set("v.isFlip9", false);
      } else {
        component.set("v.isFlip9", true);
      }
    } else if (a == "isFlip10") {
      var flip = component.get("v.isFlip10");
      if (flip == true) {
        component.set("v.isFlip10", false);
      } else {
        component.set("v.isFlip10", true);
      }
    }
  },

  LaunchEdit: function (component, event, helper) {
    var idDoc = event.getSource().getLocalId();
    helper.launchEditHelp(component, event, helper, idDoc);
  },

  //bottone aggiunta documento
  launchUpload: function (component, event, helper) {
    var doc = event.getSource().get("v.value");
    var recId = component.get("v.recordId");
    var unique = event.getSource().getLocalId();

    //Variabile di appoggio utilizzata per riconoscere l'attore di cui si carica il documento
    var indiceAttore =
      event.getSource().getLocalId() == "attoredocs"
        ? event.target.getAttribute("data-attore")
        : undefined;
    console.log("@@@ indiceAttore " + `${indiceAttore}`);

    //Se sono nel carrello prendo opportunityId
    //Altrimenti prendo il name del button
    var optyId;

    if (
      component.get("v.opportunityId") != null &&
      component.get("v.opportunityId") != undefined
    ) {
      optyId = component.get("v.opportunityId");
    } else {
      optyId = event.getSource().get("v.name");
    }
    console.log("@@@ optyId ", optyId);

    //adione CR 293
    if (doc === "new") {
      //premuto bottone '+' che non ha famiglia/classe associato -> mostro lista soggetti
      var action = component.get("c.getSoggettiOpp"); //recupera attori PG dell'Opp: cedente + debitori
      action.setParams({
        oppId: optyId
      });
      action.setCallback(this, (response) => {
        if (response.getState() == "SUCCESS") {
          var sogg = response.getReturnValue().data;
          console.log(
            "-----> launchUpload - soggetti opportunità: " + sogg.length
          );
          helper.launchUploadHelp(
            component,
            event,
            helper,
            recId,
            doc,
            unique,
            indiceAttore,
            optyId,
            sogg
          );
        }
      });
      $A.enqueueAction(action);
    } else {
      //sto caricando un documento scelto con codice classe/famiglia associato, non serve lista soggetti
      helper.launchUploadHelp(
        component,
        event,
        helper,
        recId,
        doc,
        unique,
        indiceAttore,
        optyId,
        null
      );
    }
  },

  launchDownload: function (component, event, helper) {
    component.set("v.isLoaded", false);
    var docName = event.getSource().get("v.name");
    var docId = event.getSource().get("v.value");
    var unique = event.getSource().getLocalId();
    console.log("@@@ unique ", unique);
    console.log("@@@ docId download ", docId);
    var accountId = component.get("v.recordId");

    var sourceObjName = event.target.getAttribute("data-list");
    var sourceObj = event.target.getAttribute("data-att");
    var mimeType = event.target.getAttribute("data-mime");
    var docType = event.target.getAttribute("data-doc");
    console.log("@@@ mimeType ", mimeType);
    //var test2 = event.currentTarget.getAttribute("data-list");

    //console.log('@@@ currentTarget ' , test2);
    console.log("@@@ sourceObj ", sourceObj);
    console.log("@@@ sourceObjName ", sourceObjName);
    console.log("@@@ docType ", docType);

    var downloadDoc = { id: docId, title: docName, codId: unique };

    console.log("@@@ downloadDoc ", JSON.stringify(downloadDoc));

    var action = component.get("c.doc61");
    action.setParams({
      idDocumento: docId,
      codDocumento: docType
    });
    action.setCallback(this, (response) => {
      if (response.getState() == "SUCCESS") {
        var risposta = response.getReturnValue();
        if (risposta.success) {
          // base64 string
          var base64str = risposta.data[0];

          var test = risposta.data[1];
          console.log("@@@ test ", test);

          // var navigator = component.find("navService");
          // var pg = {
          //   "type": "standard__recordPage",
          //   "attributes": {
          // 	"recordId": test,
          // 	"objectApiName": "ContentVersion",
          // 	"actionName": "view"
          //   }
          // };
          // navigator.navigate(pg);

          helper.createAndDownload(
            component,
            event,
            helper,
            base64str,
            downloadDoc,
            mimeType
          );

          component.set("v.isLoaded", true);

          //Aggiungo il bordo blu dopo il download
          // if(sourceObjName != null && sourceObjName != undefined){
          // 	var obj = component.get("v."+sourceObjName);
          // 	obj.composition = true;

          // 	component.set("v."+sourceObjName, obj);
          // }
        } else {
          component.set("v.isLoaded", true);
          console.log("@@@ risposta message ", risposta.message);

          var msg = $A.get("e.force:showToast");
          msg.setParams({
            title: "Attenzione",
            message:
              risposta.message != null || risposta.message != undefined
                ? risposta.message
                : "Nessun documento da scaricare",
            type: "WARNING"
          });
          msg.fire();
        }
      } else {
        console.log("@@@ error ", response.getError());
        component.set("v.isLoaded", true);
      }
    });
    $A.enqueueAction(action);
  },

  generaModulo: function (component, event, helper) {
    var docName = event.getSource().get("v.name");
    var docId = event.getSource().get("v.value");
    var unique = event.getSource().getLocalId();
    console.log("@@@ unique ", unique);
    console.log("@@@ docId download ", docId);
    var accountId = component.get("v.recordId");

    var sourceObjName = event.target.getAttribute("data-list");
    var sourceObj = event.target.getAttribute("data-att");
    //var test2 = event.currentTarget.getAttribute("data-list");

    //console.log('@@@ currentTarget ' , test2);
    console.log("@@@ sourceObj ", sourceObj);
    console.log("@@@ sourceObjName ", sourceObjName);

    var downloadDoc = { id: docId, title: docName, codId: unique };

    console.log("@@@ downloadDoc ", JSON.stringify(downloadDoc));

    sourceObjName == "attori" ? (accountId = docId) : "";

    //Recupero le informazioni per la lingua del documento da produrre
    var linguaScelta = component.get("v.sceltaLingua");
    console.log("@@@ lingua ", linguaScelta);

    if (linguaScelta.toLowerCase() != "IT".toLowerCase()) {
      helper.openModalLanguage(component, event, helper, downloadDoc);
    } else {
      component.set("v.isLoaded", false);
      var action = component.get("c.doc11");
      //adione distinguo tra PF e PG: mi serve nell'APEX per agganciare idModello DigiBox
      //var uniqueModulo = (unique === 'Privacy') ? ((docName === 'PrivacyPersonaFisica.pdf') ? unique+'PF' : unique+'PG') : unique;
      action.setParams({
        recordId: accountId,
        codiceModulo: unique,
        nomeFile: docName,
        lingua: linguaScelta
        //"document" : JSON.stringify(downloadDoc)
      });
      action.setCallback(this, (response) => {
        if (response.getState() == "SUCCESS") {
          var risposta = response.getReturnValue();
          if (risposta.success) {
            // base64 string
            var base64str = risposta.data[0];

            var test = risposta.data[1];
            console.log("@@@ test ", test);

            // var navigator = component.find("navService");
            // var pg = {
            //   "type": "standard__recordPage",
            //   "attributes": {
            // 	"recordId": test,
            // 	"objectApiName": "ContentVersion",
            // 	"actionName": "view"
            //   }
            // };
            // navigator.navigate(pg);

            helper.createAndDownload(
              component,
              event,
              helper,
              base64str,
              downloadDoc,
              "application/pdf"
            );

            component.set("v.isLoaded", true);

            //Aggiungo il bordo blu dopo il download
            // if(sourceObjName != null && sourceObjName != undefined){
            // 	var obj = component.get("v."+sourceObjName);
            // 	obj.composition = true;

            // 	component.set("v."+sourceObjName, obj);
            // }
          } else {
            component.set("v.isLoaded", true);
            console.log("@@@ risposta message ", risposta.message);

            var msg = $A.get("e.force:showToast");
            msg.setParams({
              title: "Attenzione",
              message:
                risposta.message != null || risposta.message != undefined
                  ? risposta.message
                  : "Nessun documento da scaricare",
              type: "WARNING"
            });
            msg.fire();
          }
        } else {
          console.log("@@@ error ", response.getError());
          component.set("v.isLoaded", true);
        }
      });
      $A.enqueueAction(action);
    }
  },

  uploadHandler: function (component, event, helper) {
    console.log("@@@ HANDLER ");
    console.log("@@@ params ", JSON.stringify(event.getParam("param")));
    console.log("@@@ futureCall ", event.getParam("futureCall"));

    var docParam = event.getParam("param");
    var futureCall = event.getParam("futureCall");

    var listaDoc;

    if (docParam.listToUpdate == "attoredocs") {
      listaDoc = component.get("v.attori");
      console.log("@@@ listaDoc ", listaDoc);
      listaDoc.forEach((item, index) => {
        if (index == docParam.indiceAttori) {
          listaDoc[index].docs.forEach((itemD, indexD) => {
            if (itemD.index_value == docParam.index_value) {
              console.log("@@@ trovato ", itemD);

              if (!futureCall) {
                itemD.id = docParam.id;
                itemD.DownloadName = docParam.title;
                itemD.missing = false;
              } else {
                itemD.futureDoc = true;
                itemD.missing = true;
              }

              itemD.valid_to = docParam.dataScadenza.toLocaleDateString(
                "it-IT",
                { year: "numeric", month: "short", day: "numeric" }
              );
              itemD.isValidDate =
                new Date(docParam.dataScadenza) > new Date()
                  ? "Valido"
                  : "Non valido";

              itemD.isValid = itemD.required
                ? itemD.missing
                  ? itemD.isAvailable == false
                    ? false
                    : true
                  : itemD.isValidDate == "Valido" ||
                    !itemD.hasOwnProperty("isValidDate")
                  ? itemD.isAvailable == false
                    ? true
                    : true
                  : itemD.isAvailable == false
                  ? false
                  : true
                : true;
            }
          });

          var red = item.docs.reduce((start, itemD) => {
            if (itemD != null && itemD.index_value == "SY0000074") {
              return (
                start &&
                (itemD.required
                  ? itemD.missing
                    ? itemD.isAvailable == false
                      ? false
                      : true
                    : itemD.isValidDate == "Valido" ||
                      !itemD.hasOwnProperty("isValidDate")
                    ? true
                    : false
                  : true) &&
                listaDoc[index].attore.Contact.DataInserimentoConsensi__c !=
                  undefined
              );
            } else if (itemD != null) {
              console.log(
                "@@@ condizione ",
                start &&
                  (itemD.required
                    ? itemD.missing
                      ? itemD.isAvailable == false
                        ? false
                        : true
                      : itemD.isValidDate == "Valido" ||
                        !itemD.hasOwnProperty("isValidDate")
                      ? true
                      : false
                    : true)
              );
              return (
                start &&
                (itemD.required
                  ? itemD.missing
                    ? itemD.isAvailable == false
                      ? false
                      : true
                    : itemD.isValidDate == "Valido" ||
                      !itemD.hasOwnProperty("isValidDate")
                    ? true
                    : false
                  : true)
              );
            } else {
              return start;
            }
          }, true);

          item.isCompleted = red;

          console.log("@@@ item attore .isCompleted ", item.isCompleted);
        }
      });

      //Workaround to rerender component
      //component.set("v.attori", null);
      component.set("v.attori", listaDoc);

      //helper.checkCompleteDocs(component, event, helper, 'attori', undefined, docParam.indiceAttori);
    } else if (docParam.listToUpdate != undefined) {
      console.log("@@@ ttt ", docParam.listToUpdate);
      listaDoc = component.get("v." + docParam.listToUpdate);
      //console.log('@@@ listaDoc ' , JSON.stringify(listaDoc));

      if (docParam.listToUpdate != "upload") {
        if (Array.isArray(listaDoc)) {
          listaDoc.forEach((item, index) => {
            if (item.index_value == docParam.index_value) {
              console.log("@@@ trovato ", item);

              if (!futureCall) {
                item.id = docParam.id;
                item.DownloadName = docParam.title;
                item.missing = false;
              } else {
                item.futureDoc = true;
                item.missing = true;
              }

              item.valid_to = docParam.dataScadenza.toLocaleDateString(
                "it-IT",
                { year: "numeric", month: "short", day: "numeric" }
              );
              item.isValidDate =
                new Date(docParam.dataScadenza) > new Date()
                  ? "Valido"
                  : "Non valido";

              console.log(
                "@@@ validDate ",
                new Date(docParam.dataScadenza) > new Date()
                  ? "Valido"
                  : "Non valido"
              );
              // console.log('@@@ test data 2 ' , docParam.dataScadenza.toLocaleDateString('it-IT', { year: 'numeric', month: 'short', day: 'numeric' }));
              // console.log('@@@ test data ' , item.valid_to);

              item.isValid = item.required
                ? item.missing
                  ? item.isAvailable == false
                    ? false
                    : true
                  : item.isValidDate == "Valido" ||
                    !item.hasOwnProperty("isValidDate")
                  ? item.isAvailable == false
                    ? true
                    : true
                  : item.isAvailable == false
                  ? false
                  : true
                : true;
            }
          });

          console.log(
            "@@@ update ",
            component.get("v." + docParam.listToUpdate)
          );

          //Workaround to rerender component
          component.set("v." + docParam.listToUpdate, null);
          component.set("v." + docParam.listToUpdate, listaDoc);

          // docsComplete
          //isDocsOptyValid
          var indiceOpty;
          if (docParam.listToUpdate == "expandedDocs") {
            var listaO = component.get("v.optyFact");
            listaO.forEach((item, index) => {
              console.log("@@@ optyOpen ", item);
              if (item.flip) {
                console.log("@@@ opty trovata");
                indiceOpty = index;
              }
            });
          }

          var attr =
            docParam.listToUpdate == "docsOpty"
              ? "isDocsOptyValid"
              : docParam.listToUpdate == "expandedDocs"
              ? "isExpandedDocsValid"
              : "docsComplete";

          console.log("@@@ attr ", attr);
          helper.checkCompleteDocs(
            component,
            event,
            helper,
            docParam.listToUpdate,
            attr,
            undefined
          );
        } else {
          let docAttr = "v." + docParam.listToUpdate;
          var docUp = component.get(docAttr);
          console.log("@@@ docUp ", docUp);

          if (!futureCall) {
            docUp.id = docParam.id;
            docUp.DownloadName = docParam.title;
            docUp.missing = false;
          } else {
            console.log("@@@ prova future ");
            docUp.futureDoc = true;
            docUp.missing = true;
          }

          docUp.valid_to = docParam.dataScadenza.toLocaleDateString("it-IT", {
            year: "numeric",
            month: "short",
            day: "numeric"
          });
          docUp.isValidDate =
            new Date(docParam.dataScadenza) > new Date()
              ? "Valido"
              : "Non valido";
          docUp.isValid = docUp.required
            ? docUp.missing
              ? docUp.isAvailable == false
                ? false
                : true
              : docUp.isValidDate == "Valido" ||
                !docUp.hasOwnProperty("isValidDate")
              ? docUp.isAvailable == false
                ? true
                : true
              : docUp.isAvailable == false
              ? false
              : true
            : true;
          //Workaround to rerender component
          component.set("v." + docParam.listToUpdate, null);
          component.set("v." + docParam.listToUpdate, docUp);

          console.log("@@@ docUp ", JSON.stringify(docUp));
        }
      } else {
        console.log("@@@ init dopo upload ");
        helper.initialize(component, event, helper);
      }
    }

    helper.checkAllDocs(component, event, helper);
  },

  //Funzione che gestisce l'espansione della sezione doc opportunità

  expandDoc: function (component, event, helper) {
    //Azzero la lista per abilitare lo spinner al nuovo caricamente
    component.set("v.expandedDocs", []);
    component.set("v.isLoaded", false);
    component.set("v.isLoadedFact", false);

    var indice = event.getSource().get("v.value");
    console.log("@@@ indiceBTN ", JSON.stringify(indice));

    var listaOpty = component.get("v.optyFact");
    //Id opty passato per effettuare una chiamata
    var docOpty = listaOpty[indice];
    console.log("@@@ docOpty " + docOpty);

    //Utilizzato per gestire la visualizzazione della sezione doc in base all'indice delle varie opportunità
    for (var key in listaOpty) {
      console.log("@@@ key ", key);
      console.log("@@@ indice ", indice);
      if (key == indice) {
        listaOpty[indice].flip = true;
      } else {
        listaOpty[key].flip = false;
      }
    }

    // console.log('@@@ listaOpty ' , listaOpty);
    // console.log('@@@ ');

    component.set("v.optyFact", listaOpty);

    var action = component.get("c.docCheckListOpportunity");
    action.setParams({
      opportunityId: docOpty.Id,
      isRevisioneRSF: false
    });
    action.setCallback(this, (response) => {
      if (response.getState() == "SUCCESS") {
        var risposta = response.getReturnValue();
        if (risposta.success) {
          if (risposta.data.length > 0) {
            console.log("@@@ optyId ", component.get("v.opportunityId"));
            console.log("@@@ aaa ", risposta.data[0]);
            console.log("@@@ aaa 2 ", risposta.data[1]);

            var docs = [];
            docs = helper.generateDocsListOpty(
              component,
              event,
              helper,
              risposta.data[0],
              risposta.data[1]
            );

            console.log("@@@ docs multi opty ", docs);

            var red = docs.reduce((start, itemD) => {
              if (itemD != null)
                return (
                  start &&
                  (itemD.required
                    ? itemD.missing
                      ? itemD.isAvailable == false
                        ? false
                        : true
                      : itemD.isisValidDate == "Valido"
                      ? true
                      : false
                    : true)
                );
            }, true);

            listaOpty[indice].isCompleted = red;

            console.log("@@@ listaOpty[indice] ", listaOpty[indice]);

            var mapping = component.get("v.mappings");

            docs = helper.mapCodeName(component, event, helper, docs, mapping);
            //console.log('@@@ bbb ' , risposta.data[0].payload.results);
            component.set("v.isExpandedDocsValid", red);
            component.set("v.expandedDocs", docs);

            //component.set("v.expandedSingleDoc", false);
            component.set("v.isLoaded", true);
            component.set("v.isLoadedFact", true);
          } else {
            component.set("v.isLoaded", true);
            component.set("v.isLoadedFact", true);
          }
        } else {
          component.set("v.isLoaded", true);
          component.set("v.isLoadedFact", true);
          console.log("@@@ doc10 opty " + risposta.message);
        }
      } else {
        component.set("v.isLoaded", true);
        component.set("v.isLoadedFact", true);
        console.log("@@@ error ", response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  //Funzione che gestisce l'espansione della sezione doc opportunità
  expandDocSingle: function (component, event, helper) {
    component.set("v.expandedSingleDoc", true);
  },

  expandDocOptyFac: function (component, event, helper) {
    console.log("@@@ ", event.getSource().get("v.value"));
    component.set("v.expandedOptyFac", !event.getSource().get("v.value"));
  },

  //funzione che gestisce il flip delle card nell'array di docs del servizio doc10
  flipDocs: function (component, event, helper) {
    var evt = event.getSource().get("v.value");
    console.log("@@@ evt ", evt);
    var docs = component.get("v.docs");
    console.log("@@@ ddd ", docs);
    docs[evt.myIndex].isFlip = !docs[evt.myIndex].isFlip;
    component.set("v.docs", docs);
  },

  flipDocsOpty: function (component, event, helper) {
    var newValue = event.getSource().get("v.value");
    var lista = component.get("v.expandedDocs");
    lista[newValue.myIndex].isFlip = !lista[newValue.myIndex].isFlip;
    component.set("v.expandedDocs", lista);
  },

  flipDocsSingleOpty: function (component, event, helper) {
    var newValue = event.getSource().get("v.value");
    var lista = component.get("v.docsOpty");
    lista[newValue.myIndex].isFlip = !lista[newValue.myIndex].isFlip;
    component.set("v.docsOpty", lista);
  },

  closeDoc: function (component, event, helper) {
    var so = event.getSource().get("v.value");
    console.log("@@@ so ", JSON.stringify(so));

    var lista = component.get("v.optyFact");
    lista[so].flip = false;

    component.set("v.optyFact", lista);

    //Resetto il flag
    component.set("v.isExpandedDocsValid", false);
  },

  closeDocSingle: function (component, event, helper) {
    var newValue = event.getSource().get("v.value");
    console.log("@@@ newValue ", newValue);

    component.set("v.expandedSingleDoc", false);
  },

  changeAvailability: function (component, event, helper) {
    var newValue = event.getSource().get("v.value");
    console.log("@@@ newValue ", newValue);

    var elemento = event.getSource().get("v.name");
    console.log("@@@ elemento ", JSON.stringify(elemento));

    var optyIdDefault = component.get("v.opportunityId");
    console.log("@@@ optyIdDefault ", optyIdDefault);

    var note = event.target.getAttribute("data-note");
    console.log("@@@ note ", note);

    var optyId;

    if (!optyIdDefault) {
      console.log(
        "@@@ event.target ",
        event.target.getAttribute("data-optyId")
      );
      var indexO = event.target.getAttribute("data-optyId");
      elemento.isAvailable = !newValue;

      var listaDocs = component.get("v.expandedDocs");
      console.log("@@@ expandedDocs ", listaDocs);

      var listaOpty = component.get("v.optyFact");
      console.log("@@@ optys ", listaOpty);

      var dati;
      var recId;
      listaOpty.forEach((item, index) => {
        if (index == indexO) {
          recId = item.Id;
          listaDocs.forEach((item, index) => {
            if (index == elemento.myIndex) {
              item.isAvailable = newValue;

              dati = item;
            }
          });
        }
      });

      component.set("v.expandedDocs", listaDocs);

      console.log("@@@ dati ", dati);
      //Apro la modal per gestire le note
      helper.openDocumentNoteModal(
        component,
        event,
        helper,
        dati,
        recId,
        listaDocs,
        "expandedDocs",
        note
      );
    } else {
      var listaDocs = component.get("v.docsOpty");
      console.log("@@@ docsOpty ", listaDocs);

      var dati;
      var recId;
      listaDocs.forEach((item, index) => {
        if (index == elemento.myIndex) {
          item.isAvailable = newValue;

          dati = item;
          recId = optyIdDefault;
        }
      });

      component.set("v.docsOpty", listaDocs);

      console.log("@@@ dati ", dati);
      //Apro la modal per gestire le note
      helper.openDocumentNoteModal(
        component,
        event,
        helper,
        dati,
        recId,
        listaDocs,
        "docsOpty",
        note
      );
    }
  },

  changeAvailabilityAnag: function (component, event, helper) {
    var newValue = event.getSource().get("v.value");
    console.log("@@@ newValue ", newValue);

    var elemento = event.getSource().get("v.name");
    console.log("@@@ elemento ", JSON.stringify(elemento));

    var notaId = event.target.getAttribute("data-note");
    console.log("@@@ note ", notaId);

    elemento.isAvailable = newValue;

    var listaDocs = component.get("v.docs");

    var dati;
    var recId;

    console.log("@@@ recordId anag ", component.get("v.recordId"));

    recId = component.get("v.recordId");

    listaDocs.forEach((item, index) => {
      console.log("@@@ doc ", item);
      if (index == elemento.myIndex) {
        item.isAvailable = newValue;
        dati = item;
      }
    });

    component.set("v.docs", listaDocs);
    console.log("@@@ dati ", dati);

    //Apro la modal per gestire le note
    helper.openDocumentNoteModal(
      component,
      event,
      helper,
      dati,
      recId,
      listaDocs,
      "docs",
      notaId
    );
  },

  changeAvailabilityAttori: function (component, event, helper) {
    var newValue = event.getSource().get("v.value");
    console.log("@@@ newValue ", newValue);

    var elemento = event.getSource().get("v.name");
    console.log("@@@ elemento ", JSON.stringify(elemento));

    elemento.isAvailable = newValue;

    var listaAttori = component.get("v.attori");

    var attoreId = event.target.getAttribute("data-id");
    console.log("@@@ attoreId ", attoreId);

    var notaId = event.target.getAttribute("data-note");
    console.log("@@@ note ", notaId);

    var dati;
    var recId;

    console.log("@@@ listaAttori ", listaAttori);

    listaAttori[attoreId].docs.forEach((item, index) => {
      console.log("@@@ index ", index);
      console.log("@@@ elemento.myIndex ", elemento.myIndex);
      if (index == elemento.myIndex) {
        elemento.isAvailable = newValue;
        dati = elemento;
        recId = listaAttori[attoreId].attore.Id;
      }
    });

    component.set("v.attori", listaAttori);

    console.log("@@@ notaId doc ", notaId);
    //Apro la modal per gestire le note
    helper.openDocumentNoteModal(
      component,
      event,
      helper,
      dati,
      recId,
      listaAttori,
      "attori",
      notaId
    );
  },

  expandAttori: function (component, event, helper) {
    var newValue = event.getSource().get("v.value");
    console.log("@@@ newValue ", JSON.stringify(newValue));

    var lista = component.get("v.attori");

    lista.forEach((item, index) => {
      if (item.myIndex == newValue.myIndex) {
        item.isFlip = true;
      }
    });

    component.set("v.attori", lista);
  },

  closeAttori: function (component, event, helper) {
    var newValue = event.getSource().get("v.value");
    console.log("@@@ newValue ", JSON.stringify(newValue));

    var lista = component.get("v.attori");

    lista.forEach((item, index) => {
      if (item.myIndex == newValue.myIndex) {
        item.isFlip = false;
      }
    });

    component.set("v.attori", lista);
  },

  flipDocsAttori: function (component, event, helper) {
    var newValue = event.getSource().get("v.value");
    console.log("@@@ newValue aaa ", newValue);
    var AttoreXDoc = newValue.split(";");
    console.log("@@@ AttoreXDoc ", AttoreXDoc);
    var lista = component.get("v.attori");
    console.log("@@@ lista.docs ", lista[AttoreXDoc[0]].docs);

    lista[AttoreXDoc[0]].docs.forEach((item, index) => {
      if (item.myIndex == AttoreXDoc[1]) {
        item.isFlip = !item.isFlip;
      }
    });

    component.set("v.attori", lista);
  },

  navigateToOpty: function (component, event, helper) {
    var optyId = event.target.getAttribute("data-oppId");
    console.log("@@@ optyId ", optyId);

    var optyId2 = event.currentTarget.getAttribute("data-oppId");
    console.log("@@@ optyId2 ", optyId2);

    var navigator = component.find("navService");
    var pg = {
      type: "standard__recordPage",
      attributes: {
        recordId: optyId2,
        objectApiName: "Opportunity",
        actionName: "view"
      }
    };
    navigator.navigate(pg);
  },

  handleChangeDoc: function (component, event, helper) {
    console.log("@@@ parametri evento ", JSON.stringify(event.getParams()));

    var tipo = event.getParams().type;
    if (tipo == "note") {
      var listToUpdate = event.getParams().json.listToUpdate;
      var docToUpdate = event.getParams().json.doc;
      var notaId = event.getParams().json.idNota;
      var recordIdAttore = event.getParams().json.idAttore;

      console.log("@@@ listToUpdate ", listToUpdate);
      console.log("@@@ docToUpdate ", JSON.stringify(docToUpdate));
      console.log("@@@ notaId ", notaId);

      console.log("@@@ recordId Attore toUpdate ", recordIdAttore);

      var listaAgg = component.get("v." + listToUpdate);

      if (
        listToUpdate == "docsOpty" ||
        listToUpdate == "expandedDocs" ||
        listToUpdate == "docs"
      ) {
        listaAgg.forEach((item, index) => {
          if (index == docToUpdate.myIndex) {
            console.log("@@@ docTrovato ", JSON.stringify(item));

            if (notaId) {
              item.notaId = notaId;
            } else {
              console.log("@@@ delete ");
              delete item.notaId;
              delete item.nota;

              console.log("@@@ doc delete ", item);
            }
          }
        });

        var indiceOpty;
        if (listToUpdate == "expandedDocs") {
          var listaO = component.get("v.optyFact");
          listaO.forEach((item, index) => {
            console.log("@@@ optyOpen ", item);
            if (item.flip) {
              console.log("@@@ opty trovata");
              indiceOpty = index;
            }
          });
        }

        var attr =
          listToUpdate == "docsOpty"
            ? "isDocsOptyValid"
            : listToUpdate == "expandedDocs"
            ? "isExpandedDocsValid"
            : "docsComplete";

        console.log("@@@ attr ", attr);
        helper.checkCompleteDocs(
          component,
          event,
          helper,
          listToUpdate,
          attr,
          undefined
        );
      } else {
        var indiceAtt;
        listaAgg.forEach((item, index) => {
          console.log("@@@ actors ", item);
          if (item.attore.Id == recordIdAttore) {
            console.log("@@@ attore trovato ", item);
            indiceAtt = index;
            item.docs.forEach((itemD, indexD) => {
              if (indexD == docToUpdate.myIndex) {
                console.log("@@@ documento attore trovato ", itemD);

                if (notaId) {
                  itemD.notaId = notaId;
                } else {
                  console.log("@@@ delete ");
                  delete itemD.notaId;
                  delete itemD.nota;

                  console.log("@@@ doc delete ", itemD);
                }
              }
            });

            var red = item.docs.reduce((start, itemD) => {
              if (itemD != null) {
                console.log(
                  "@@@ condizione ",
                  start &&
                    (itemD.required
                      ? itemD.missing
                        ? itemD.isAvailable == false
                          ? false
                          : true
                        : itemD.isValidDate == "Valido" ||
                          !itemD.hasOwnProperty("isValidDate")
                        ? true
                        : false
                      : true)
                );
                return (
                  start &&
                  (itemD.required
                    ? itemD.missing
                      ? itemD.isAvailable == false
                        ? false
                        : true
                      : itemD.isValidDate == "Valido" ||
                        !itemD.hasOwnProperty("isValidDate")
                      ? true
                      : false
                    : true)
                );
              } else {
                return start;
              }
            }, true);

            item.isCompleted = red;

            console.log("@@@ item attore .isCompleted ", item.isCompleted);
          }
        });

        console.log("@@@ prova fine attori");
        //helper.checkCompleteDocs(component, event, helper, listToUpdate, undefined, indiceAtt);
      }

      console.log("@@@ listaAgg 1 ", component.get("v." + listToUpdate));

      //Workaround to rerender component
      //component.set("v."+listToUpdate, []);
      component.set("v." + listToUpdate, listaAgg);

      console.log("@@@ listaAgg 2 ", component.get("v." + listToUpdate));
    }

    helper.checkAllDocs(component, event, helper);
  },

  //SM - CR 456
  setDocNonReperibili : function(cmp, event, helper){
    helper.setDocNonReperibili(cmp, event, helper);
  },
});