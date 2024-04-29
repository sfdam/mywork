({
  initialize: function (component, event, helper) {
    component.set("v.isLoaded", false);
    var accId = component.get("v.recordId");
    var action = component.get("c.getDocumentData");
    action.setParams({
      accountId: accId
    });
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        var risposta = response.getReturnValue();
        component.set("v.response", risposta);
        console.log("@@@ response doc ", risposta);
        //Formatto la data in modo leggibile
        var arrDoc = risposta.data[0];
        for (var key in arrDoc) {
          //Per ogni array prendo l'elemento e formatto la data
          arrDoc[key].forEach(function (item) {
            // if(item.CreatedDate != null || item.CreatedDate != undefined){
            // 	//Aumento la data di scadenza ad un anno e formatto la data
            // 	var da = new Date(item.CreatedDate);
            // 	da.setFullYear(da.getFullYear()+1);
            // 	item.CreatedDate = da.toLocaleDateString('it-IT', {year: 'numeric', month: 'short', day: 'numeric'});
            // }

            //Data Compilazione MAV
            if (item.hasOwnProperty("WGC_Data_Compilazione__c")) {
              var oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
              var today = new Date();
              var dataC = new Date(item.WGC_Data_Compilazione__c);

              let diffDays = Math.round(
                Math.abs((today.getTime() - dataC.getTime()) / oneDay)
              );

              if (diffDays > 365) {
                item.isCompiled = false;
              } else {
                item.isCompiled = true;
              }

              var da = new Date(item.WGC_Data_Compilazione__c);
              da.setFullYear(da.getFullYear() + 1);
              item.CreatedDate = da.toLocaleDateString("it-IT", {
                year: "numeric",
                month: "short",
                day: "numeric"
              });
            }
            //Data Compilazione QQ
            else if (item.hasOwnProperty("DataCompilazione__c")) {
              var oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
              var today = new Date();
              var dataC = new Date(item.DataCompilazione__c);

              let diffDays = Math.round(
                Math.abs((today.getTime() - dataC.getTime()) / oneDay)
              );

              if (diffDays > 365) {
                item.isCompiled = false;
              } else {
                item.isCompiled = true;
              }

              var da = new Date(item.DataCompilazione__c);
              da.setFullYear(da.getFullYear() + 10);
              item.CreatedDate = da.toLocaleDateString("it-IT", {
                year: "numeric",
                month: "short",
                day: "numeric"
              });
            } else {
              item.isCompiled = false;
            }
          });
        }

        risposta.data[0] = arrDoc;
        component.set("v.response", risposta);

        var recId = component.get("v.recordId");
        console.log("@@@ recId ", recId);
        var optyId = component.get("v.opportunityId");

        //Se sono nel carrello chiamata al doc10 con configurazione opty per recuperare tutti i documenti pratica
        //Poi chiamata al doc10 con configurazione referente per recuperare i documenti per l'esecutore della pratica
        console.log("@@@ optyId initialize ", optyId);
        if (optyId != null && optyId != undefined && optyId != "") {
          this.apex(component, event, "docCheckList", { objId: recId })
            .then((result) => {
              console.log("@@@ primo result ", result);

              if (result.success) {
                var rispJSON = result.data[0];

                console.log("@@@ rispJSON ", rispJSON);

                var note;
                if (result.data.length > 1) {
                  note = result.data[1];
                }

                console.log("@@@ notes ", note);
                var docsGenerati = this.generateDocsList(
                  component,
                  event,
                  helper,
                  rispJSON,
                  note
                );

                console.log("@@@ docsGenerati ", docsGenerati);

                component.set("v.docs", docsGenerati);
              }

              return this.apex(component, event, "getDocumentMapping", {});
            })
            .then((result) => {
              console.log("@@@ result 1 ", result);
              if (result.data.length > 0) {
                component.set("v.mappings", result.data[0]);
                return this.apex(component, event, "docCheckListCarrello", {
                  opportunityId: optyId
                });
              }
            })
            .then((result) => {
              console.log("@@@ result carrello", result);

              if (result.data.length > 0) {
                var docs = [];
                console.log("@@@ docs carrello service " + result.data);
                docs = helper.generateDocsListOpty(
                  component,
                  event,
                  helper,
                  result.data[0],
                  result.data[1]
                );

                console.log("@@@ docs carrello ", docs);

                var mapping = component.get("v.mappings");

                docs = helper.mapCodeName(
                  component,
                  event,
                  helper,
                  docs,
                  mapping
                );

                console.log("@@@ docs after mapping ", docs);

                component.set("v.docsOpty", docs);
                //component.set("v.expandedSingleDoc", true);

                console.log("@@@ prova docs ", component.get("v.docsOpty"));

                console.log("@@@ result.data[2] ", result.data[2]);

                result.data[2].forEach((item, index) => {
                  item.isFlip = false;
                  item.myIndex = index;
                });

                // var redFact = docs.reduce((start, itemD) =>{
                // 	if(itemD != null)
                // 		return start && (itemD.required ? (itemD.missing ? (itemD.isAvailable == false ? false : true ) : (itemD.isValidDate == 'Valido' ? true : false )) : true);
                // }, true);

                var redFact = docs.reduce((start, item) => {
                  if (item != null) {
                    console.log(
                      "@@@ condizione ",
                      start &&
                        (item.required
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
                          : true)
                    );
                    return (
                      start &&
                      (item.required
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
                        : true)
                    );
                  } else {
                    return start;
                  }
                }, true);

                console.log("@@@ redFact ", redFact);
                component.set("v.isDocsOptyValid", redFact);

                //component.set("v.attori", result.data[1]);

                result.data[2].forEach((item, index) => {
                  docs = [];
                  console.log("@@@ item.docs ", item.docs);
                  console.log("@@@ item.note ", item.note);
                  item.isCompleted = false;
                  docs = helper.generateDocsListOpty(
                    component,
                    event,
                    helper,
                    item.docs,
                    item.note
                  );

                  console.log("@@@ docsAttori 1 ", docs);

                  docs = helper.mapCodeName(
                    component,
                    event,
                    helper,
                    docs,
                    mapping
                  );

                  console.log("@@@ docs after mapping ", docs);

                  //component.set("v.docsAttori" , docs);
                  item.docs = docs;

                  // var red = docs.reduce((start, itemD) =>{
                  // 	if(itemD != null)
                  // 		return start && (itemD.required ? (itemD.missing ? (itemD.isAvailable == false ? false : true ) : (itemD.isValidDate == 'Valido' ? true : false )) : true);
                  // }, true);

                  if (
                    item.attore.Tipo__c != undefined &&
                    item.attore.Tipo__c != null
                  ) {
                    var red = docs.reduce((start, item) => {
                      if (item != null) {
                        console.log(
                          "@@@ condizione ",
                          start &&
                            (item.required
                              ? item.missing
                                ? item.isAvailable == false
                                  ? false
                                  : true
                                : item.isValidDate == "Valido" ||
                                  !item.hasOwnProperty("isValidDate")
                                ? true
                                : false
                              : true)
                        );
                        return (
                          start &&
                          (item.required
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
                            : true)
                        );
                      } else {
                        return start;
                      }
                    }, true);
                  } else {
                    var dataConsensi =
                      item.attore.Contact.DataInserimentoConsensi__c;
                    var red = docs.reduce((start, item) => {
                      if (item != null && item.index_value == "SY0000074") {
                        return (
                          start &&
                          (item.required
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
                            : true) &&
                          dataConsensi != undefined
                        );
                      } else if (item != null) {
                        console.log(
                          "@@@ condizione ",
                          start &&
                            (item.required
                              ? item.missing
                                ? item.isAvailable == false
                                  ? false
                                  : true
                                : item.isValidDate == "Valido" ||
                                  !item.hasOwnProperty("isValidDate")
                                ? true
                                : false
                              : true)
                        );
                        return (
                          start &&
                          (item.required
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
                            : true)
                        );
                      } else {
                        return start;
                      }
                    }, true);
                  }

                  item.isCompleted = red;

                  console.log(
                    "@@@ item attore .isCompleted ",
                    item.isCompleted
                  );
                });

                component.set("v.attori", result.data[2]);
                console.log("@@@ result docs attori ", result.data[2]);
              }

              //Mappo
              var docs2 = component.get("v.docs");
              var mapping = component.get("v.mappings");

              docs2 = this.mapCodeName(
                component,
                event,
                helper,
                docs2,
                mapping
              );

              component.set("v.docs", docs2);

              //FIX Indici
              docs2.forEach((item, index) => {
                item.myIndex = index;
              });

              //Disabilito lo spinner
              component.set("v.isLoaded", true);
              //Disabilito altro spinner
              component.set("v.isLoadedFact", true);

              this.checkAllDocs(component, event, helper);
            });
        } else {
          this.apex(component, event, "docCheckList", { objId: recId })
            .then((result) => {
              console.log("@@@ primo result b ", result);

              if (result.success) {
                var rispJSON = result.data[0];

                console.log("@@@ rispJSON ", rispJSON);

                var note;
                if (result.data.length > 1) {
                  note = result.data[1];
                }

                console.log("@@@ notes ", note);
                var docsGenerati = this.generateDocsList(
                  component,
                  event,
                  helper,
                  rispJSON,
                  note
                );
                component.set("v.docs", docsGenerati);
              }

              return this.apex(component, event, "getDocumentMapping", {});
            })
            .then((result) => {
              console.log("@@@ result 1 ", result);
              if (result.data.length > 0) {
                component.set("v.mappings", result.data[0]);
                var docs = component.get("v.docs");
                docs = this.mapCodeName(
                  component,
                  event,
                  helper,
                  docs,
                  result.data[0]
                );

                docs.forEach((item, index) => {
                  item.myIndex = index;
                });

                component.set("v.docs", docs);
              }

              if (optyId == undefined || optyId == null || optyId == "") {
                return this.apex(component, event, "getOptyFactoring", {
                  accountId: recId
                });
              }
              /*
							else{
								component.set("v.isLoadedFact", true);
							}
							*/
            })
            .then((result) => {
              if (result != null && result != undefined) {
                console.log("@@@ last result ", result);

                //Utilizzato per gestire l'apertura della sezione dei doc, nella lista doc opportunità
                result.data.forEach((item, index) => {
                  item.flip = false;
                  item.myIndex = index;
                  item.isCompleted = false;
                });
                component.set("v.optyFact", result.data);
              }

              var oppId = component.get("v.opportunityId");
              return this.apex(component, event, "getAttoriPratica", {
                oppId: oppId
              });
            })
            .then((result) => {
              if (result != null && result != undefined) {
                console.log("@@@ result attori ", result);
                var allAttori = [];
                for (var key in result.data[0]) {
                  console.log("@@@ result.data[key] ", result.data[0][key]);
                  result.data[0][key].forEach((item, index) => {
                    allAttori.push(item);
                  });
                }
                console.log("@@@ allAttori ", allAttori);
                component.set("v.attori", allAttori);
              }
              //Disabilito lo spinner
              component.set("v.isLoaded", true);
              //Disabilito altro spinner
              component.set("v.isLoadedFact", true);
            })
            .finally(
              $A.getCallback(() => {
                helper.checkAccountDoc(component, event, helper);
              })
            );
        }
      } else {
        var msg = $A.get("e.force:showToast");
        msg.setParams({
          title: "ERRORE",
          message: "Errore nel recupero dei dati dei documenti",
          type: "ERROR"
        });
        msg.fire();
      }
    });
    $A.enqueueAction(action);
  },

  generateDocsList: function (component, event, helper, json, notes) {
    var docsList = [];
    var flipList = [];

    json.payload.results.forEach((item, index) => {
      var singleDoc = {};

      //Flag NON REPERIBILE
      singleDoc.isAvailable = false;
      //Campi required e missing (Utilizzati per blue e rosso)
      singleDoc.missing = item.missing;
      singleDoc.required = item.required;
      singleDoc.isValid =
        (item.missing && item.required) == true ? false : true;

      if (notes != null && notes != undefined && notes.length > 0) {
        notes.forEach((itemN, index) => {
          var idDocumentale = itemN.Id_univoco__c.split("_")[1];
          console.log("@@@ idDocumentale ", idDocumentale);
          console.log("@@@  ", item.index_value);
          if (idDocumentale == item.index_value) {
            singleDoc.isValid = true;
            singleDoc.isAvailable = true;
            singleDoc.nota = itemN.Note__c;
            singleDoc.notaId = itemN.Id;
          }
        });
      }

      var tmpFROM = new Date(item.valid_from);
      tmpFROM = tmpFROM.toLocaleDateString("it-IT", {
        year: "numeric",
        month: "short",
        day: "numeric"
      });
      singleDoc.valid_from = tmpFROM;

      singleDoc.index_name = item.index_name;
      singleDoc.index_value = item.index_value;
      //Aggiungo un parametro per gestire il flip
      singleDoc.isFlip = true;
      singleDoc.myIndex = index;

      if (
        (item.docs[0] != undefined && item.docs[0] != null) ||
        item.docs.length > 0
      ) {
        singleDoc.id = item.docs[0].id;
        singleDoc.classe = item.docs[0].classe;

        item.docs[0].indice.forEach((ind, index) => {
          //console.log('@@@ ind ' , ind);
          //console.log('@@@@ prova name ' , ind.nome.toLowerCase() == ('Name').toLowerCase());
          if (ind.nome.toLowerCase() == "Name".toLowerCase()) {
            console.log("@@@ nome trovato");
            console.log("@@@ nome ", ind.valore);
            singleDoc.DownloadName = ind.valore;
          }
          if (ind.nome.toLowerCase() == "CODICEDOC".toLowerCase()) {
            singleDoc.codiceDoc = ind.valore;
          }

          if (ind.nome.toLowerCase() == "DATASTATO".toLowerCase()) {
            if (ind.valore) {
              var tmp = ind.valore;
              console.log("@@@ ind.valore ", ind.valore);
              tmp = tmp.match(/.{1,2}/g);
              //Anno - Mese - Giorno
              var formatted = tmp[2] + tmp[3] + "-" + tmp[1] + "-" + tmp[0];
              var tmpTO = new Date(formatted);
              singleDoc.valid_to = tmpTO;

              //var validDate = new Date(singleDoc.valid_to);

              singleDoc.isValidDate =
                new Date(singleDoc.valid_to) > new Date()
                  ? "Valido"
                  : "Non valido";
              singleDoc.valid_to = tmpTO.toLocaleDateString("it-IT", {
                year: "numeric",
                month: "short",
                day: "numeric"
              });
            }
          }

          if (ind.nome.toLowerCase() == "MimeType".toLowerCase()) {
            singleDoc.mimeType = ind.valore;

            console.log("@@@ mimeType docs ", singleDoc.mimeType);
          }

          if (ind.nome.toLowerCase() == "NOTEDOC".toLowerCase()) {
            if (item.index_value == "EX0000173") {
              if (ind.valore != null) {
                singleDoc.noteDoc =
                  ind.valore == "CC" ? "In Bonis" : "Procedura";
              } else {
                singleDoc.noteDoc = "";
              }
            }
          }
        });

        //SM - TEN: Fix TENAM-197
        if (singleDoc.DownloadName == undefined) {
          singleDoc.DownloadName = item.docs[0].file_name;
        }
      } else {
        singleDoc.isValidDate = "Non valido";
      }

      singleDoc.isValid = singleDoc.required
        ? singleDoc.missing
          ? singleDoc.isAvailable == false
            ? false
            : true
          : singleDoc.isValidDate == "Valido" ||
            !singleDoc.hasOwnProperty("isValidDate")
          ? singleDoc.isAvailable == false
            ? true
            : true
          : singleDoc.isAvailable == false
          ? false
          : true
        : true;

      //MAV
      if (singleDoc.index_value == "EX0000173") {
        singleDoc.composition = false;
        component.set("v.docMAV", singleDoc);
        console.log("@@@ mav ", singleDoc);
      }
      //MTC
      else if (singleDoc.index_value == "EX0000179") {
        singleDoc.composition = false;
        component.set("v.docMTC", singleDoc);
        console.log("@@@ mtc ", singleDoc);
      }
      //PPG
      else if (singleDoc.index_value == "EX0000200") {
        singleDoc.composition = false;
        component.set("v.docPPG", singleDoc);
        console.log("@@@ ppg ", singleDoc);
      } else {
        //Genero un oggetto per gestire il flip
        /*
				var singleFlip = { isFlip : true, index : item.id };
				flipList.push(singleFlip);
				*/
        singleDoc.composition = false;
        console.log("@@@ singleDoc ", JSON.stringify(singleDoc));

        if (item.docs.length > 0 || singleDoc.required)
          docsList.push(singleDoc);
      }
    });

    console.log("@@@ docsList ", docsList);
    //component.set("v.docs", docsList);

    this.checkDocId(component, event, helper, docsList);

    return docsList;
    //component.set("v.isFlipDocs", flipList);
  },

  generateDocsListOpty: function (component, event, helper, json, notes) {
    var docsList = [];
    var flipList = [];

    var optyId = component.get("v.opportunityId");

    console.log("@@@ docs from service ", json);
    console.log("@@@ notes ", notes);
    if (json.payload != undefined) {
      var indexValues = new Set();
      console.log("@@@ indexValues ", indexValues);
      json.payload.results.forEach((item, index) => {
        var singleDoc = {};

        //Flag NON REPERIBILE
        singleDoc.isAvailable = false;
        //Campi required e missing (Utilizzati per blue e rosso)
        singleDoc.missing = item.missing;
        singleDoc.required = item.required;
        singleDoc.isValid =
          (item.missing && item.required) == true ? false : true;

        //SM - CR 456
        if (notes != null && notes != undefined && notes.length > 0) {
          notes.forEach((itemN, index) => {
            var idDocumentale = itemN.Id_univoco__c.split("_")[1];
            if (idDocumentale == item.index_value) {
              console.log("@@ esiste nota ");
              singleDoc.isValid = true;
              singleDoc.isAvailable = true;
              singleDoc.nota = itemN.Note__c;
              singleDoc.notaId = itemN.Id;
            }
          });
        }

        var tmpFROM = new Date(item.valid_from);
        tmpFROM = tmpFROM.toLocaleDateString("it-IT", {
          year: "numeric",
          month: "short",
          day: "numeric"
        });
        singleDoc.valid_from = tmpFROM;

        singleDoc.index_name = item.index_name;
        singleDoc.index_value = item.index_value;
        //Aggiungo un parametro per gestire il flip
        singleDoc.isFlip = true;
        singleDoc.myIndex = index;

        if (
          (item.docs[0] != undefined && item.docs[0] != null) ||
          item.docs.length > 0
        ) {
          //Set utilizzato per verificare l'univocità dei documenti
          if (!item.required) indexValues.add(item.index_value);
          singleDoc.id = item.docs[0].id;
          singleDoc.classe = item.docs[0].classe;

          item.docs[0].indice.forEach((ind, index) => {
            if (ind.nome.toLowerCase() == "Name".toLowerCase()) {
              singleDoc.DownloadName = ind.valore;
            }
            if (ind.nome.toLowerCase() == "CODICEDOC".toLowerCase()) {
              singleDoc.codiceDoc = ind.valore;
            }

            if (ind.nome.toLowerCase() == "DATASTATO".toLowerCase()) {
              console.log("@@@ indice datastato ", JSON.stringify(ind));
              if (ind.valore) {
                var tmp = ind.valore;
                tmp = tmp.match(/.{1,2}/g);
                //Anno - Mese - Giorno
                var formatted = tmp[2] + tmp[3] + "-" + tmp[1] + "-" + tmp[0];
                var tmpTO = new Date(formatted);
                singleDoc.valid_to = tmpTO;

                //var validDate = new Date(singleDoc.valid_to);
                console.log("@@@ valid_to ", new Date(singleDoc.valid_to));
                console.log(
                  "@@@ controllo valid_to ",
                  new Date(singleDoc.valid_to) > new Date()
                );

                singleDoc.isValidDate =
                  new Date(singleDoc.valid_to) > new Date()
                    ? "Valido"
                    : "Non valido";
                singleDoc.valid_to = tmpTO.toLocaleDateString("it-IT", {
                  year: "numeric",
                  month: "short",
                  day: "numeric"
                });
                console.log(
                  "@@@ isValidDate datastato ",
                  singleDoc.isValidDate
                );
              }
            }

            if (ind.nome.toLowerCase() == "MimeType".toLowerCase()) {
              singleDoc.mimeType = ind.valore;
            }
          });

          //SM - TEN: Fix TENAM-197
          if (singleDoc.DownloadName == undefined) {
            singleDoc.DownloadName = item.docs[0].file_name;
          }
        } else {
          singleDoc.isValidDate = "Non valido";
        }

        console.log("@@@ isValidDate datastato final ", singleDoc.isValidDate);
        singleDoc.isValid = singleDoc.required
          ? singleDoc.missing
            ? singleDoc.isAvailable == false
              ? false
              : true
            : singleDoc.isValidDate == "Valido" ||
              !singleDoc.hasOwnProperty("isValidDate")
            ? singleDoc.isAvailable == false
              ? true
              : true
            : singleDoc.isAvailable == false
            ? false
            : true
          : true;

        //MAV //MTC //PPG //RSF
        if (
          singleDoc.index_value != "EX0000173" &&
          singleDoc.index_value != "EX0000179" &&
          singleDoc.index_value != "EX0000200" &&
          singleDoc.index_value != "NV0000002" &&
          (item.docs.length > 0 || singleDoc.required)
        ) {
          console.log("@@@ singleDoc ", JSON.stringify(singleDoc));

          docsList.push(singleDoc);
        }

        if (
          singleDoc.index_value == "NV0000002" &&
          (optyId == null || optyId == undefined || optyId == "")
        ) {
          docsList.push(singleDoc);
        } else if (singleDoc.index_value == "NV0000002") {
          component.set("v.docRSF", singleDoc);
          console.log("@@@ rsf ", JSON.stringify(component.get("v.docRSF")));
        }

        //docsList.push(singleDoc);
      });

      console.log("@@@ docsList opty ", docsList);
      console.log("@@@ indexValues final ", indexValues);

      //Ciclo nuovamente il nuovo array per sistemare gli indici
      docsList.forEach((item, index) => {
        item.myIndex = index;
      });

      console.log("@@@ docsList after final ", docsList);
    }

    return docsList;
  },

  getUnique: function (arr, comp) {
    const unique = arr
      .map((e) => e[comp])

      // store the keys of the unique objects
      .map((e, i, final) => final.indexOf(e) === i && i)

      // eliminate the dead keys & store unique objects
      .filter((e) => arr[e])
      .map((e) => arr[e]);

    return unique;
  },

  showToastError: function (component, event, helper) {
    var msg = $A.get("e.force:showToast");
    msg.setParams({
      title: "ERRORE",
      message: "Errore durante il salvataggio",
      type: "ERROR"
    });
    msg.fire();
  },

  setCollapse: function (component, event, helper) {
    var clps = component.get("v.isCollapsed");
    if (clps == true) {
      component.set("v.isCollapsed", false);
    } else if (clps == false) {
      component.set("v.isCollapsed", true);
    }
  },

  launchEditHelp: function (component, event, helper, idDoc) {
    var recordId = component.get("v.recordId");
    if (idDoc == "privacy") {
      $A.createComponent(
        "c:WGC_PrivacyPersonaGiuridica_Component",
        { recordId: recordId },
        function (content, status, error) {
          if (status === "SUCCESS") {
            component.find("overlayLib").showCustomModal({
              header: "Privacy Persona Giuridica",
              body: content,
              showCloseButton: true,
              cssClass: "slds-modal_medium",
              closeCallback: function () {
                //alert('You closed the alert!');
                //Richiamo il doInit per reinizializzare il component e mostrare la data di scadenza e la validità del documento
                //helper.initialize(component, event, helper);
                helper.initDocumentData(component, event, helper);
              }
            });
          }
          if (status == "ERROR") {
            helper.showToastError(component, event, helper);
          }
        }
      );
    }
    if (idDoc == "qq") {
      $A.createComponent(
        "c:WGC_QuestionarioQualitativo_Component",
        { recordId: component.get("v.recordId") },
        function (content, status, error) {
          if (status === "SUCCESS") {
            component.find("overlayLib").showCustomModal({
              header: "Questionario Qualitativo",
              body: content,
              showCloseButton: true,
              cssClass: "slds-modal_medium",
              closeCallback: function () {
                //alert('You closed the alert!');
                //Richiamo il doInit per reinizializzare il component e mostrare la data di scadenza e la validità del documento
                //helper.initialize(component, event, helper);
                helper.initDocumentData(component, event, helper);
              }
            });
          }
          if (status == "ERROR") {
            helper.showToastError(component, event, helper);
          }
        }
      );
    }
    if (idDoc == "mav") {
      //PALUMBO 05/02/2020
      if (component.get("v.sObjectName") == "Account") {
        var action = component.get("c.getProfileInfo");
        action.setCallback(this, function (response) {
          if (response.getState() == "SUCCESS") {
            var resp = response.getReturnValue();
            console.log("getProfileInfo: " + resp);
            if (!resp) {
              this.createMavModule(component, event, this, "standard");
            } else {
              component.set("v.tipologiaMav", "");
              var resp = component.get("v.response");
              if (
                undefined != resp.data[0].mavList[0] &&
                resp.data[0].mavList[0].isCompiled
              ) {
                //occorre leggere la tipologia
                var tipologia = "standard";
                if (resp.data[0].mavList[0].WGC_TipologiaMav__c != undefined) {
                  tipologia = resp.data[0].mavList[0].WGC_TipologiaMav__c;
                  if (tipologia == "standard" || tipologia == "CC") {
                    this.initializeSceltaMax(component, event, helper);
                  } else {
                    this.createMavModule(component, event, helper, "CE");
                  }
                } else {
                  this.initializeSceltaMax(component, event, helper);
                }
              } else {
                this.initializeSceltaMax(component, event, helper);
              }
            }
          } else {
            component.set("v.isLoaded", false);
          }
        });

        $A.enqueueAction(action);
      } else {
        //this.createMavModule(component,event,'standard');
        console.log("@@@MAV - IS OPPORTUNITY");
        var oppId = component.get("v.opportunityId");
        var action = component.get("c.getOppRecordTypeInfo");
        action.setParams({
          opportunityId: oppId
        });

        action.setCallback(this, function (response) {
          if (response.getState() == "SUCCESS") {
            var resp = response.getReturnValue();
            this.createMavModule(component, event, this, resp);
          } else {
            component.set("v.isLoaded", false);
          }
        });
        $A.enqueueAction(action);
      }
    }
    if (idDoc == "mtc") {
      $A.createComponent(
        "c:WGC_ModuloTecnicheComunicazione_Component",
        { recordId: component.get("v.recordId") },
        function (content, status, error) {
          if (status === "SUCCESS") {
            component.find("overlayLib").showCustomModal({
              header: "Modulo Tecniche di Comunicazione",
              body: content,
              showCloseButton: true,
              cssClass: "slds-modal_medium",
              closeCallback: function () {
                //alert('You closed the alert!');
                //Richiamo il doInit per reinizializzare il component e mostrare la data di scadenza e la validità del documento
                //helper.initialize(component, event, helper);
                helper.initDocumentData(component, event, helper);
              }
            });
          }
          if (status == "ERROR") {
            helper.showToastError(component, event, helper);
          }
        }
      );
    }
    if (idDoc == "PrivacyPF") {
      var attore = event.getSource().get("v.value");
      console.log("@@@ attore Privacy PF ", attore);

      console.log(
        "@@@ attore Privacy PF ",
        attore.attore.hasOwnProperty("Contact") ? attore.attore.Contact.Id : ""
      );

      var recordId = attore.attore.hasOwnProperty("Contact")
        ? attore.attore.Contact.Id
        : "";
      var isAccount = attore.attore.hasOwnProperty("Contact") ? false : true;

      $A.createComponent(
        "c:WGC_PrivacyPersonaGiuridica_Component",
        {
          recordId: recordId,
          isAccount: isAccount,
          modalBodyAttributeName: component.getReference(
            "v.parentAttributeName"
          )
        },
        function (content, status, error) {
          if (status === "SUCCESS") {
            component.find("overlayLib").showCustomModal({
              header: "Privacy Persona Giuridica",
              body: content,
              showCloseButton: true,
              cssClass: "slds-modal_medium",
              closeCallback: function () {
                //alert('You closed the alert!');
                //Richiamo il doInit per reinizializzare il component e mostrare la data di scadenza e la validità del documento
                //helper.initialize(component, event, helper);
                //helper.initDocumentData(component, event, helper);

                var res = component.get("v.parentAttributeName");
                var att = component.get("v.attori");

                console.log("@@@ res ", res);

                if (res == "SALVA") {
                  att.forEach((item, index) => {
                    if (item.attore.hasOwnProperty("Contact")) {
                      console.log("@@@ aaa ", item.attore);
                      if (item.attore.Contact.Id == recordId) {
                        console.log("@@@ aaa ", item.attore.Contact);
                        item.attore.Contact.DataInserimentoConsensi__c = new Date();

                        var dataConsensi =
                          item.attore.Contact.DataInserimentoConsensi__c;
                        var red = item.docs.reduce((start, item) => {
                          if (item != null && item.index_value == "SY0000074") {
                            return (
                              start &&
                              (item.required
                                ? item.missing
                                  ? item.isAvailable == false
                                    ? false
                                    : true
                                  : item.isValidDate == "Valido" ||
                                    !item.hasOwnProperty("isValidDate")
                                  ? true
                                  : false
                                : true) &&
                              dataConsensi != undefined
                            );
                          } else if (item != null) {
                            console.log(
                              "@@@ condizione ",
                              start &&
                                (item.required
                                  ? item.missing
                                    ? item.isAvailable == false
                                      ? false
                                      : true
                                    : item.isValidDate == "Valido" ||
                                      !item.hasOwnProperty("isValidDate")
                                    ? true
                                    : false
                                  : true)
                            );
                            return (
                              start &&
                              (item.required
                                ? item.missing
                                  ? item.isAvailable == false
                                    ? false
                                    : true
                                  : item.isValidDate == "Valido" ||
                                    !item.hasOwnProperty("isValidDate")
                                  ? true
                                  : false
                                : true)
                            );
                          } else {
                            return start;
                          }
                        }, true);

                        item.isCompleted = red;
                      }
                    }
                  });

                  component.set("v.attori", att);
                }
              }
            });
          }
          if (status == "ERROR") {
            helper.showToastError(component, event, helper);
          }
        }
      );
    }
    // if(idDoc == 'rpv'){
    //     $A.createComponent("c:WGC_RelazionePrimaVisita_Component", {"recordId" : component.get("v.recordId")},
    // 		function(content, status, error) {
    // 			if (status === "SUCCESS") {
    // 				component.find('overlayLib').showCustomModal({
    // 				header: "Relazione Prima Visita",
    // 					body: content,
    // 					showCloseButton: true,
    // 					cssClass: "slds-modal_medium",
    // 					closeCallback: function() {
    // 						//alert('You closed the alert!');
    // 						//Richiamo il doInit per reinizializzare il component e mostrare la data di scadenza e la validità del documento
    // 						//helper.initialize(component, event, helper);
    // 					}
    // 				})
    // 			}
    // 			if(status == "ERROR"){
    // 				helper.showToastError(component, event, helper);
    // 			}
    // 		});
    // }
  },

  launchUploadHelp: function (
    component,
    event,
    helper,
    recId,
    doc,
    docFisso,
    indiceAttore,
    optyId,
    soggetti
  ) {
    console.log("@@@ recId ", recId);
    console.log("@@@ doc ", doc);
    console.log("@@@ indiceAttore ", indiceAttore);
    console.log("-----> launchUploadHelp - soggetti: ", soggetti);

    if (indiceAttore != undefined && indiceAttore != null) {
      var attori = component.get("v.attori");
      attori.forEach((item, index) => {
        if (index == indiceAttore && item.attore.Tipo__c != undefined) {
          recId = item.attore.Id;
        } else if (
          index == indiceAttore &&
          item.attore.hasOwnProperty("ContactId")
        ) {
          recId = item.attore.ContactId;
        }
      });
    }
    console.log("@@@ recId modificato ", recId);

    $A.createComponent(
      "c:WGC_FileUploader",
      //"nomeModulo" : nomeModulo
      {
        recordId: recId,
        datiDoc: doc,
        docFisso: docFisso,
        indiceAttore: indiceAttore,
        optyId: optyId,
        soggetti: soggetti
      },
      function (content, status, error) {
        if (status === "SUCCESS") {
          component.find("overlayLib").showCustomModal({
            header: "Upload Documenti",
            body: content,
            showCloseButton: true,
            cssClass: "slds-modal_medium",
            closeCallback: function () {
              // let ms = 1000000;
              // console.log('@@@ ms 1 ' , ms);
              // window.setTimeout($A.getCallback(function(){
              // 	console.log('@@@ ms 2 ' , ms);
              // 	helper.initialize(component, event, helper);
              // }),ms);
              //TEST
              // var listaDoc = component.find(unique);
              // console.log('@@@ listaDoc ' , listaDoc);
              // if(listaDoc != null && listaDoc != undefined){
              // 	if(listaDoc.length > 1){
              // 		listaDoc.forEach((item, index) =>{
              // 			if(item.get("v.value") == doc){
              // 				console.log('@@@ item after upload m ' , item);
              // 				item.set("v.class", 'slds-align_absolute-center back-icon-action-positive');
              // 			}
              // 		});
              // 	}
              // 	else{
              // 		console.log('@@@ item after upload s ' , item);
              // 		listaDoc.set("v.class", 'slds-align_absolute-center back-icon-action-positive');
              // 	}
              // }
            }
          });
        }
        if (status == "ERROR") {
          console.log("@@@ error ", JSON.stringify(error));
          helper.showToastError(component, event, helper);
        }
      }
    );
  },

  createAndDownload: function (
    component,
    event,
    helper,
    base64,
    docInfo,
    mimeType
  ) {
    console.log("@@@ base64 ", base64.substring(0, 100));
    console.log("@@@ mimeType ", mimeType);
    // decode base64 string, remove space for IE compatibility
    // if(!base64.includes('%')){
    // 	console.log('@@@ aaa');
    // 	var binary = atob(base64.replace(/\s/g, ''));
    // 	console.log('@@@ aaa');
    // 	//Se binary contiene il carattere % è già una stringa binaria,
    // 	//altrimenti devo effettuare un'ulteriore decodifica
    // 	if(binary.includes('%')){
    // 		console.log('@@@ bbbb');
    // 		var len = binary.length;
    // 		var buffer = new ArrayBuffer(len);
    // 		var view = new Uint8Array(buffer);
    // 		for (var i = 0; i < len; i++) {
    // 			view[i] = binary.charCodeAt(i);
    // 		}
    // 	}
    // 	else{
    // 		console.log('@@@ binary ' , binary);
    // 		var binary2 = atob(binary.replace(/\s/g, ''));
    // 		console.log('@@@ binary 2 ' , binary2.substring(0,100));

    // 		var len = binary2.length;
    // 		var buffer = new ArrayBuffer(len);
    // 		var view = new Uint8Array(buffer);
    // 		for (var i = 0; i < len; i++) {
    // 			view[i] = binary2.charCodeAt(i);
    // 		}
    // 	}
    // }
    // else{
    // 	var len = base64.length;
    // 	var buffer = new ArrayBuffer(len);
    // 	var view = new Uint8Array(buffer);
    // 	for (var i = 0; i < len; i++) {
    // 		view[i] = base64.charCodeAt(i);
    // 	}
    // }

    var binary = atob(base64.replace(/\s/g, ""));
    var len = binary.length;
    var buffer = new ArrayBuffer(len);
    var view = new Uint8Array(buffer);
    for (var i = 0; i < len; i++) {
      view[i] = binary.charCodeAt(i);
    }

    // if(mimeType != null && mimeType != undefined){
    // 	var ext = mimeType.split('/');
    // 	console.log('@@@ ext ' , ext);
    // 	if(ext[1].includes('excel')){
    // 		var blob = new Blob( [view], { type: "application/octet-stream" });
    // 		//var blob = new Blob( [view]);
    // 		var url = URL.createObjectURL(blob);

    // 		var a = document.createElement("a");
    // 		document.body.appendChild(a);
    // 		a.style = "display: none";
    // 		a.href = url;
    // 		a.download = docInfo.title + '.' + 'xls';
    // 		a.click();
    // 	}
    // 	else if(ext[1].includes('msword') || ext[1].includes('doc') || ext[1].includes('docx')){
    // 		var blob = new Blob( [view], { type: "application/octet-stream" });
    // 		//var blob = new Blob( [view]);
    // 		var url = URL.createObjectURL(blob);

    // 		var a = document.createElement("a");
    // 		document.body.appendChild(a);
    // 		a.style = "display: none";
    // 		a.href = url;
    // 		a.download = docInfo.title + '.' + 'docx';
    // 		a.click();
    // 	}
    // 	// else if(ext[1].includes('doc')){
    // 	// 	var blob = new Blob( [view], { type: "application/octet-stream" });
    // 	// 	//var blob = new Blob( [view]);
    // 	// 	var url = URL.createObjectURL(blob);

    // 	// 	var a = document.createElement("a");
    // 	// 	document.body.appendChild(a);
    // 	// 	a.style = "display: none";
    // 	// 	a.href = url;
    // 	// 	a.download = docInfo.title + '.' + 'doc';
    // 	// 	a.click();
    // 	// }
    // 	else{
    // 		try{
    // 			var blob = new Blob( [view], { type: mimeType });
    // 			var url = URL.createObjectURL(blob);
    // 		}
    // 		catch(e){
    // 			var msg = $A.get("e.force:showToast");
    // 			msg.setParams({
    // 				"title" : "Attenzione",
    // 				"message" : "Formato file non supportato",
    // 				"type" : "WARNING"
    // 			});
    // 			msg.fire();

    // 			return;
    // 		}
    // 		//var blob = new Blob( [view]);

    // 		var extension = mimeType.split('/')[1];
    // 		var extension2 = docInfo.title.split('.')[1];
    // 		console.log('@@@ extension2 ' , extension2);

    // 		var a = document.createElement("a");
    // 		document.body.appendChild(a);
    // 		a.style = "display: none";
    // 		a.href = url;
    // 		a.download = docInfo.title + '.' + extension2;
    // 		a.click();
    // 	}
    // }
    // else{
    // 	var blob = new Blob( [view], { type: "application/octet-stream" });
    // 	//var blob = new Blob( [view]);
    // 	var url = URL.createObjectURL(blob);

    // 	var a = document.createElement("a");
    // 	document.body.appendChild(a);
    // 	a.style = "display: none";
    // 	a.href = url;
    // 	a.download = docInfo.title;
    // 	a.click();
    // }

    // //console.log('@@@ url ' , url);

    var blob = new Blob([view], { type: "application/octet-stream" });
    //var blob = new Blob( [view]);
    var url = URL.createObjectURL(blob);

    var a = document.createElement("a");
    document.body.appendChild(a);
    a.style = "display: none";
    a.href = url;
    a.download = docInfo.title;
    a.click();
  },

  /*
	getListOptyFactoring : function(component, event, helper){
		var accountId = component.get("v.recordId");
		console.log('@@@ accountId ' , accountId);
		var action = component.get("c.getOptyFactoring");
		action.setParams({
			"accountId" : accountId
		});
		action.setCallback(this, (response) =>{
			if(response.getState() == "SUCCESS"){
				var risposta = response.getReturnValue();
				console.log('@@@ risposta opty fact ' , risposta);
				if(risposta.success){
					
					//Utilizzato per gestire l'apertura della sezione dei doc, nella lista doc opportunità
					risposta.data.forEach((item, index) =>{
						item.flip = false;
						item.myIndex = index;
						console.log('@@@ item ' , item);
					});

					console.log('@@@ QUI');

					component.set("v.optyFact", risposta.data);
					//component.set("v.expandedSingleDoc", false);
					component.set("v.isLoadedFact", true);
				}
				else{
					console.log('@@@ risposta.message ' , risposta.message);
				}
			}
			else{
				console.log('@@@ error ' , response.getError());
			}
		});
		$A.enqueueAction(action);
	},
	*/

  getDocumentMapping: function (component, event, helper) {
    var action = component.get("c.getDocumentMapping");
    action.setCallback(this, (response) => {
      if (response.getState() == "SUCCESS") {
        var risposta = response.getReturnValue();
        console.log("@@@ risposta ", risposta);
        if (risposta.success) {
          component.set("v.mappings", risposta.data[0]);
        }
      } else {
        console.log("@@@ error mapping " + response.getError());
      }
    });
  },

  apex: function (component, event, apexAction, params) {
    var p = new Promise(
      $A.getCallback(function (resolve, reject) {
        var action = component.get("c." + apexAction + "");
        action.setParams(params);
        action.setCallback(this, function (callbackResult) {
          if (callbackResult.getState() == "SUCCESS") {
            resolve(callbackResult.getReturnValue());
          }
          if (callbackResult.getState() == "ERROR") {
            console.log("ERROR", callbackResult.getError());
            reject(callbackResult.getError());
          }
        });
        $A.enqueueAction(action);
      })
    );
    return p;
  },

  mapCodeName: function (component, event, helper, docs, mapping) {
    docs.forEach((item, index) => {
      mapping.forEach((map, index) => {
        if (map.Documento__c == item.index_value) {
          item.Name = map.MasterLabel;
        }
      });
    });
    console.log("@@@ fine");
    return docs;
  },

  checkDocId: function (component, event, helper, docsToCheck) {
    var check = false;
    // docsToCheck.find(item =>{
    // 	if(item.id == null || item.id == undefined || item.id == ''){
    // 		check = true;
    // 		return check;
    // 	}
    // });

    //Controllo la validitaà di tutti i documenti
    check = docsToCheck.reduce((start, item) => {
      if (item != null) {
        console.log(
          "@@@ condizione ",
          start &&
            (item.required
              ? item.missing
                ? item.isAvailable == false
                  ? false
                  : true
                : item.isValidDate == "Valido" ||
                  !item.hasOwnProperty("isValidDate")
                ? true
                : false
              : true)
        );
        return (
          start &&
          (item.required
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
            : true)
        );
      } else {
        return start;
      }
    }, true);

    console.log("@@@ check ", check);
    component.set("v.docsComplete", check);
  },

  checkAllDocs: function (component, event, helper) {
    var IdCarrello = component.get("v.opportunityId");
    console.log("@@@ IdCarrello ", IdCarrello);

    var esec;

    var ppg = component.get("v.docPPG");
    var mav = component.get("v.docMAV");
    var mtc = component.get("v.docMTC");
    var rsf = component.get("v.docRSF");
    var docs = component.get("v.docs");
    var docsOpty = component.get("v.docsOpty");
    var attori = component.get("v.attori");
    var newLines = component.get("v.newLines");

    var docsAttori = [];
    if (attori.length > 0) {
      attori.forEach((item, index) => {
        item.docs.forEach((itemD, indexD) => {
          docsAttori.push(itemD);
        });
      });
    }

    console.log("@@@ ppg ", ppg);
    console.log("@@@ mav ", mav);
    console.log("@@@ mtc ", mtc);
    console.log("@@@ rsf ", rsf);
    console.log("@@@ docs ", docs);
    console.log("@@@ docsOpty ", docsOpty);
    console.log("@@@ docsAttori ", docsAttori);

    var allArray = [];

    allArray = allArray.concat(ppg);
    allArray = allArray.concat(mav);
    allArray = allArray.concat(mtc);
    allArray = allArray.concat(rsf);
    allArray = allArray.concat(docs);
    allArray = allArray.concat(docsOpty);
    allArray = allArray.concat(docsAttori);

    var red = false;

    //Controllo la validitaà di tutti i documenti
    //SM - TEN: Fix completezza documenti se almeno i documenti della pratica e degli attori sono stati scaricati
    console.log(
      "@@@ prima condizione ",
      docsAttori.length > 0 && docsOpty.length > 0 && newLines
    );
    console.log("@@@ seconda condizione ", !newLines && docsAttori.length > 0);
    console.log("@@@ newLines ", newLines);

    if (
      (docsAttori.length > 0 && docsOpty.length > 0 && newLines) ||
      (!newLines && docsAttori.length > 0)
    ) {
      red = allArray.reduce((start, item) => {
        if (item != null) {
          return (
            start &&
            (item.required
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
              : true)
          );
        } else {
          return start;
        }
      }, true);

      console.log("@@@ red ", red);
    }

    //component.set("v.isAllDocValid", red);

    component.set("v.isAllDocValid", red);
  },

  checkAccountDoc: function (component, event, helper) {
    var ppg = component.get("v.docPPG");
    var mav = component.get("v.docMAV");
    var mtc = component.get("v.docMTC");
    var rsf = component.get("v.docRSF");
    var docs = component.get("v.docs");

    var allArray = [];

    allArray = allArray.concat(ppg);
    allArray = allArray.concat(mav);
    allArray = allArray.concat(mtc);
    allArray = allArray.concat(docs);

    console.log("@@@ allArray ", allArray);
    //Controllo la validitaà di tutti i documenti

    //Prendo il qq
    var qq = component.get("v.response.data[0].qqList").length;
    var red = false;

    if (qq != 0) {
      red = allArray.reduce((start, item) => {
        if (item != null) {
          return (
            start &&
            (item.required
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
              : true)
          );
        } else {
          return start;
        }
      }, true);
    }

    console.log("@@@ red account doc ", red);

    var evtUpdate = $A.get("e.c:WGC_UpdateDocStatus");
    evtUpdate.setParams({
      completedDoc: red
    });
    evtUpdate.fire();
  },

  openDocumentNoteModal: function (
    component,
    event,
    helper,
    doc,
    recId,
    listaDoc,
    nomeAttribute,
    notaId
  ) {
    console.log("@@@ notaId doc ", notaId);

    $A.createComponent(
      "c:WGC_FileUploader",
      {
        recordId: recId,
        notAvailable: true,
        datiDocNote: doc,
        noteDoc: doc.nota,
        modalBodyAttributeName: component.getReference("v.parentAttributeName"),
        idNota: notaId,
        listToUpdate: nomeAttribute
      },
      function (content, status, error) {
        if (status === "SUCCESS") {
          component.find("overlayLib").showCustomModal({
            header: "File Uploader",
            body: content,
            showCloseButton: true,
            cssClass: "slds-modal_medium",
            closeCallback: function () {
              var result = component.get("v.parentAttributeName");

              if (result == "SALVA") {
                doc.isAvailable = true;
              } else if (result == "ANNULLA") {
                if (doc.isAvailable) {
                  doc.isAvailable = false;
                } else {
                  doc.isAvailable = true;
                }
                //doc.isAvailable = doc.isAvailable;
                console.log("@@@ doc ", doc);
              }
              // let ms = 1000000;
              // console.log('@@@ ms 1 ' , ms);
              // window.setTimeout($A.getCallback(function(){
              // 	console.log('@@@ ms 2 ' , ms);
              // 	helper.initialize(component, event, helper);
              // }),ms);

              if (nomeAttribute != "attori") {
                listaDoc.forEach((item, index) => {
                  if (index == doc.myIndex) {
                    item.isAvailable = doc.isAvailable;
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

                component.set("v." + nomeAttribute, listaDoc);
              } else {
                listaDoc.forEach((item, index) => {
                  if (item.attore.Id == recId) {
                    item.docs.forEach((docS, docIndex) => {
                      if (docS.index_value == doc.index_value) {
                        docS.isAvailable = doc.isAvailable;
                        docS.isValid = docS.required
                          ? docS.missing
                            ? docS.isAvailable == false
                              ? false
                              : true
                            : docS.isValidDate == "Valido" ||
                              !docS.hasOwnProperty("isValidDate")
                            ? docS.isAvailable == false
                              ? true
                              : true
                            : docS.isAvailable == false
                            ? false
                            : true
                          : true;
                      }
                    });
                  }
                });

                component.set("v." + nomeAttribute, listaDoc);
                // component.set("v.attori", listaDoc);
                console.log("@@@ nomeAttribute ", nomeAttribute);
                console.log("@@@ listaDoc ", listaDoc);
              }
            }
          });
        }
        if (status == "ERROR") {
          helper.showToastError(component, event, helper);
        }
      }
    );
  },

  openModalLanguage: function (component, event, helper, docInfo) {
    console.log("@@@ open modal language");
    $A.createComponent(
      "c:WGC_SceltaLinguaDocumenti",
      { modalBodyAttributeName: component.getReference("v.linguaSelezionata") },
      function (content, status, error) {
        if (status === "SUCCESS") {
          component.find("overlayLib").showCustomModal({
            header: "Scelta lingua",
            body: content,
            showCloseButton: false,
            cssClass: "slds-modal_medium",
            closeCallback: function () {
              var linguaScelta = component.get("v.linguaSelezionata");

              if (linguaScelta != "ANNULLA") {
                helper.generaDoc11(component, event, helper, docInfo);
              }
            }
          });
        } else {
          console.log("@@@ error ", error);
        }
      }
    );
  },

  generaDoc11: function (component, event, helper, docInfo) {
    var linguaScelta = component.get("v.linguaSelezionata");

    var accountId = component.get("v.recordId");

    //Chiamata
    component.set("v.isLoaded", false);
    var action = component.get("c.doc11");
    action.setParams({
      recordId: accountId,
      codiceModulo: docInfo.codId,
      nomeFile: docInfo.title,
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
            docInfo,
            "application/pdf"
          );

          component.set("v.isLoaded", true);

          // //Aggiungo il bordo blu dopo il download
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

  checkCompleteDocs: function (
    component,
    event,
    helper,
    listToCheck,
    attributoCheck,
    indiceAttore
  ) {
    var lista = component.get("v." + listToCheck);

    console.log("@@@ lista ", lista);
    console.log("@@@ attributoCheck ", attributoCheck);
    console.log("@@@ indiceAttore ", indiceAttore);

    console.log("@@@ provv  ", indiceAttore ? true : false);

    if (indiceAttore != undefined) {
      // lista.forEach((item, index) =>{
      // 	// if(index == indiceAttore){
      // 	// 	var red = item.docs.reduce((start, itemD) =>{
      // 	// 		if(itemD != null){
      // 	// 			console.log('@@@ condizione ' , start && (itemD.required ? (itemD.missing ? (itemD.isAvailable == false ? false : true ) : ((itemD.isValidDate == 'Valido' || !itemD.hasOwnProperty('isValidDate')) ? true : false )) : true));
      // 	// 			return start && (itemD.required ? (itemD.missing ? (itemD.isAvailable == false ? false : true ) : ((itemD.isValidDate == 'Valido' || !itemD.hasOwnProperty('isValidDate')) ? true : false )) : true);
      // 	// 		}
      // 	// 		else{
      // 	// 			return start;
      // 	// 		}
      // 	// 	}, true);
      // 	// 	item.isCompleted = red;
      // 	// 	console.log('@@@ item attore .isCompleted ' , item.isCompleted);
      // 	// }
      // });
      // console.log('@@@ get lista ' , component.get("v."+listToCheck));
      // //component.set("v."+listToCheck, null);
      // //console.log('@@@ get lista ' , component.get("v."+listToCheck));
      // component.set("v."+listToCheck, lista);
      // console.log('@@@ set lista 2 ' , component.get("v."+listToCheck));
    } else {
      var redFact = lista.reduce((start, item) => {
        if (item != null) {
          console.log(
            "@@@ condizione ",
            start &&
              (item.required
                ? item.missing
                  ? item.isAvailable == false
                    ? false
                    : true
                  : item.isValidDate == "Valido" ||
                    !item.hasOwnProperty("isValidDate")
                  ? true
                  : false
                : true)
          );
          return (
            start &&
            (item.required
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
              : true)
          );
        } else {
          return start;
        }
      }, true);

      console.log("@@@ redFact ", redFact);
      console.log("@@@ attributoCheck not attore ", attributoCheck);
      component.set("v." + attributoCheck, redFact);
    }
  },

  initDocumentData: function (component, event, helper) {
    //scomponent.set("v.isLoaded",false);
    var accId = component.get("v.recordId");
    var action = component.get("c.getDocumentData");
    action.setParams({
      accountId: accId
    });
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        var risposta = response.getReturnValue();
        component.set("v.response", risposta);
        console.log("@@@ response doc ", risposta);
        //Formatto la data in modo leggibile
        var arrDoc = risposta.data[0];
        for (var key in arrDoc) {
          //Per ogni array prendo l'elemento e formatto la data
          arrDoc[key].forEach(function (item) {
            // if(item.CreatedDate != null || item.CreatedDate != undefined){
            // 	//Aumento la data di scadenza ad un anno e formatto la data
            // 	var da = new Date(item.CreatedDate);
            // 	da.setFullYear(da.getFullYear()+1);
            // 	item.CreatedDate = da.toLocaleDateString('it-IT', {year: 'numeric', month: 'short', day: 'numeric'});
            // }

            //Data Compilazione MAV
            if (item.hasOwnProperty("WGC_Data_Compilazione__c")) {
              var oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
              var today = new Date();
              var dataC = new Date(item.WGC_Data_Compilazione__c);

              let diffDays = Math.round(
                Math.abs((today.getTime() - dataC.getTime()) / oneDay)
              );

              if (diffDays > 365) {
                item.isCompiled = false;
              } else {
                item.isCompiled = true;
              }

              var da = new Date(item.WGC_Data_Compilazione__c);
              da.setFullYear(da.getFullYear() + 1);
              item.CreatedDate = da.toLocaleDateString("it-IT", {
                year: "numeric",
                month: "short",
                day: "numeric"
              });
            }
            //Data Compilazione QQ
            else if (item.hasOwnProperty("DataCompilazione__c")) {
              var oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
              var today = new Date();
              var dataC = new Date(item.DataCompilazione__c);

              let diffDays = Math.round(
                Math.abs((today.getTime() - dataC.getTime()) / oneDay)
              );

              if (diffDays > 365) {
                item.isCompiled = false;
              } else {
                item.isCompiled = true;
              }

              var da = new Date(item.DataCompilazione__c);
              da.setFullYear(da.getFullYear() + 10);
              item.CreatedDate = da.toLocaleDateString("it-IT", {
                year: "numeric",
                month: "short",
                day: "numeric"
              });
            } else {
              item.isCompiled = false;
            }
          });
        }

        risposta.data[0] = arrDoc;
        component.set("v.response", risposta);
      }
    });

    $A.enqueueAction(action);
  },

  getProfilo: function (component, event, helper) {
    var action = component.get("c.getProfilo");
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        var risposta = response.getReturnValue();
        if (risposta != null || risposta != undefined) {
          component.set("v.profilo", risposta);
        }
      }
    });
    $A.enqueueAction(action);
  },

  /*
	appendAvailable : function(component, event, helper, result){
		var listaDocs = component.get("v.docs");
		console.log('@@@ listaDocs ' , listaDocs);

		console.log('@@@ result available ' , result);
	},
	*/

  //PALUMBO 05/02/2020
  createMavModule: function (component, event, helper, type) {
    $A.createComponent(
      "c:WGC_ModuloAdeguataVerifica_Component",
      {
        recordId: component.get("v.recordId"),
        tipologiaMav: type,
        linesEstero: component.get("v.linesEstero")
      },
      function (content, status, error) {
        if (status === "SUCCESS") {
          component.find("overlayLib").showCustomModal({
            header: "Modulo Adeguata Verifica",
            body: content,
            showCloseButton: true,
            cssClass: "slds-modal_medium",
            closeCallback: function () {
              helper.initialize(component, event, helper);
            }
          });
        }
        if (status == "ERROR") {
          helper.showToastError(component, event, helper);
        }
      }
    );
  },

  initializeSceltaMax: function (component, event, helper) {
    $A.createComponent(
      "c:WGC_SceltaModuloMAV",
      { referenceAttribute: component.getReference("v.tipologiaMav") },
      function (content, status, error) {
        if (status === "SUCCESS") {
          component.find("overlayLib").showCustomModal({
            header: "Scelta Modulo MAV",
            body: content,
            showCloseButton: true,
            cssClass: "slds-modal_small",
            closeCallback: function () {
              var tipologia = component.get("v.tipologiaMav");
              console.log("tipologia selezionata: " + tipologia);
              if (tipologia == "CE" || tipologia == "CC") {
                //inizializzo componente
                helper.createMavModule(component, event, helper, tipologia);
              }
            }
          });
        }
        if (status == "ERROR") {
          helper.showToastError(component, event, helper);
        }
      }
    );
  },

  setDocNonReperibili: function(component, event, helper){
    component.set("v.isLoaded", false);
    // var value = !event.getSource().get("v.selected");
    var value = !component.get("v.docNonReperibili");
    console.log('@@@ value ' , value);
    var opportunityId = component.get("v.opportunityId");

    var docsOpty = component.get("v.docsOpty");
    var attori = component.get("v.attori");

    var notes = new Array();

    //Se ho flaggato tutti non reperibili inserisco note
    //Altrimenti le cancello
    docsOpty.forEach(d => {
      if((value && !d.notaId) || (!value && d.notaId)){
        notes.push(
          {
            sobjectType: 'WGC_Nota_Documento__c',
            Id_univoco__c: opportunityId + '_' + d.index_value,
            Note__c: !value ? undefined : 'Documento Non Reperibile',
            Id: value ? undefined : d.notaId
          }
        )
      }
    })

    attori.forEach(att => {
      var attoreId = att.attore.Id;
      att.docs.forEach(d => {
        if((value && !d.notaId) || (!value && d.notaId)){
          notes.push(
            {
              sobjectType: 'WGC_Nota_Documento__c',
              Id_univoco__c: attoreId + '_' + d.index_value,
              Note__c: !value ? undefined : 'Documento Non Reperibile',
              Id: value ? undefined : d.notaId
            }
          )
        }
      })
    })

    console.log('@@@ notes: ' , notes);
    //Aggiorna campo Opp
    this.apex(component, event, "setAllDocNonReperibili", { opportunityId: component.get("v.opportunityId"), value: value, notes: notes })
      .then((result) => {
        console.log('@@@ result ' , result);
        //component.set("v.docNonReperibili", value);
        component.find('recordDoc').reloadRecord(true);
        helper.initialize(component, event, helper);
        // component.set("v.isLoaded", true);
      }) 
    },
});