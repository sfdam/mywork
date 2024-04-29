({
  showErrorLoadRecord: function (component) {
    let error = component.get("v.recordError");
    if (error) this.showToast(component, "Errore", error, "error");
  },

  getProducts: function (component, event) {
    let h = this;
    this.callServer(
      component,
      "c.getProducts",
      function (result) {
        result.forEach((p) => {
          p.title = p.name;
          p.subtitle = p.area;
          p.icon = p.icona;
        });
        component.set("v.products", result);
        if (
          result.find((r) => {
            return r.recent;
          }) == null
        ) {
          component.set("v.filterTypeValue", "all");
          component.set("v.productsFilters", "");
          h.changeFilter(component);
        }
        console.log("getProducts: ", result);
      },
      { opportunityId: component.get("v.opportunityId") }
    );
  },

  getSelectedProducts: function (component, event) {
    var opp = component.get("v.opportunityRecord");
    // console.log(JSON.stringify(opp));

    var listSelected =
      opp.WGC_Prodotti_Selezionati__c == undefined
        ? []
        : opp.WGC_Prodotti_Selezionati__c.split(";");
    console.log("listSelected: ", listSelected);
    var listAllProduct = component.get("v.products");
    var listSelectedProduct = [];
    listAllProduct.forEach(function (element) {
      if (listSelected.indexOf(element.name) != -1) {
        // console.log(element);
        element.isClickable = false;
        element.isSelected = true;
        element.isActive = false;
        element.isRemovable = element.codice != "ATDTiAnticipo";
        listSelectedProduct.push(element);
      }
    });

    console.log("@@@ listSelectedProduct ", listSelectedProduct);

    component.set("v.selectedProducts", listSelectedProduct);
  },

  getPayload: function (component, event) {
    var opptyId = component.get("v.opportunityId");
    let h = this;
    this.callServerSync(component, "c.getPayload", { opportunityId: opptyId })
      .then(
        $A.getCallback(function (result) {
          // component.set('v.payload', this.addPAggiuntivi(result.data));
          component.set("v.payload", result.data);
          component.set(
            "v.pivaPerDebitore",
            h.getPivaPerDebitore(result.data.debitori)
          );
          component.set(
            "v.newLines",
            result.data.linee.filter((l) => {
              return !l.isRevisione;
            }).length
          );
          //SM - TEN - CR 425
          component.set(
            "v.linesEstero",
            result.data.linee.filter((l) => {
              return (
                l.codice == "AnticipoExport" ||
                l.codice == "CreditoDocumentarioExport" ||
                l.codice == "CreditoDocumentarioImport" ||
                l.codice == "DocumentateIncasso" ||
                l.codice == "FinanziamentoExport" ||
                l.codice == "FinanziamentoImport" ||
                l.codice == "GaranziaInternazionaleBT" ||
                l.codice == "GaranziaInternazionaleLT" ||
                l.codice == "StandByLetter"
              );
            }).length
          );
          h.checkNewJoins(component);
          h.updateWizItemsStatus(component, result);
          console.log("getPayload: ", result.data);
          return h.callServerSync(component, "c.getDebitoriNewFields", {
            opportunityId: opptyId
          });
        })
      )
      .then(
        $A.getCallback(function (result) {
          var ret = [];
          let payload = component.get("v.payload");

          result.forEach((r) => {
            // console.log(r);
            ret.push({
              debitore: r.FakeId__c,
              // tipologiaControparte: {
              //     pubblico: r.Tipologia_Controparte__c !== undefined ? r.Tipologia_Controparte__c.split(";").indexOf("Pubblico") >= 0 : false,
              //     privato: r.Tipologia_Controparte__c !== undefined ? r.Tipologia_Controparte__c.split(";").indexOf("Privato") >= 0 : false
              // },
              tipologiaFornitura: {
                beni:
                  r.Tipologia_di_Fornitura__c !== undefined
                    ? r.Tipologia_di_Fornitura__c.split(";").indexOf("Beni") >=
                      0
                    : false,
                servizi:
                  r.Tipologia_di_Fornitura__c !== undefined
                    ? r.Tipologia_di_Fornitura__c.split(";").indexOf(
                        "Servizi"
                      ) >= 0
                    : false,
                altro:
                  r.Tipologia_di_Fornitura__c !== undefined
                    ? r.Tipologia_di_Fornitura__c.split(";").indexOf("Altro") >=
                      0
                    : false
              },
              commessa: r.Commessa__c,
              appalto: r.Appalto_d_opera__c,
              contropartePrivato: r.WGC_ContropartePrivato__c
            });

            if (
              payload.valutazioniPortafoglio.find((vp) => {
                return vp.id == r.FakeId__c;
              })
            )
              payload.valutazioniPortafoglio.find((vp) => {
                return vp.id == r.FakeId__c;
              }).mercato = r.WGC_Mercato__c;
          });

          component.set("v.debitoriNewFields", ret);
          component.set("v.payload", payload);

          //SM - Banca Corporate - Recupero i conti correnti se ho prodotti di Banca Corporate
          return h.getCCIfis(component);
        })
      )
      .then(
        $A.getCallback((result) => {
          h.unlockStateSpinner(component);
          h.hideSpinner(component);
          h.reloadRecord(component);
        })
      );
  },

  updateWizItemsStatus: function (component, result) {
    if (result.data.linee != undefined) {
      // ENABLE configuraProdotto IF LINEE ALREADY GENERATED
      if (result.data.linee.length > 0) {
        var wizItems = component.get("v.wizardItems");
        // var wizItemsMap = this.mapArrayBy(wizItems, "step");
        // wizItemsMap["configuraProdotto"].disabled = false;
        console.log(
          "@@@ prova ",
          result.data.linee.filter((l) => {
            return l.codice != "Standard";
          })
        );
        wizItems.find((wi) => {
          return wi.step == "configuraProdotto";
        }).disabled = !(
          result.data.linee.filter((l) => {
            return l.codice != "Standard";
          }).length > 0
        );
        // CONDITION TO SET COMPLETED THE WIZITEM
        // this.setWizItemCompleted(wizItemsMap["configuraProdotto"], true);
        component.set("v.wizardItems", wizItems);
      }
    }
  },

  getMainWizItemsInfo: function (component, mainWizardItems) {
    let opportunity = component.get("v.opportunityRecord");
    let today = new Date();
    let mainWizardProgressValue = 0;
    let millisecondUnit = 24 * 60 * 60 * 1000;

    if (opportunity) {
      let isLost = opportunity.StageName == "Persa";
      let phase =
        opportunity.StageName == "Persa"
          ? opportunity.FaseDiCaduta__c
          : opportunity.StageName;
      let dateOut;
      let dateIn;
      mainWizardItems.forEach((mwi) => {
        mwi.active = phase == mwi.phase;
        this.manageMainWizardItemState(component, mwi, opportunity);

        switch (mwi.phase) {
          case "In Istruttoria":
            dateOut =
              opportunity.StageName == mwi.phase
                ? today
                : isLost
                ? new Date(opportunity.WGC_Data_Fase_Chiusa_Persa__c)
                : new Date(opportunity.WGC_Data_out_Fase_In_Istruttoria__c);
            dateIn = new Date(opportunity.WGC_Data_Fase_In_Istruttoria__c);
            if (dateOut)
              mwi.phaseDuration =
                Math.floor(
                  Date.UTC(
                    dateOut.getFullYear(),
                    dateOut.getMonth(),
                    dateOut.getDate()
                  ) -
                    Date.UTC(
                      dateIn.getFullYear(),
                      dateIn.getMonth(),
                      dateIn.getDate()
                    )
                ) / millisecondUnit;
            if (mwi.phaseDuration <= 0) mwi.phaseDuration = 1;
            break;
          // SM - CR401 eliminazione Predisposizione Contratto
          // case "Predisposizione Contratto":
          // if (opportunity.WGC_Data_Fase_Redazione_Contratto__c != null) {
          //     dateOut = (opportunity.StageName == mwi.phase ? today : (isLost ? new Date(opportunity.WGC_Data_Fase_Chiusa_Persa__c) : new Date(opportunity.WGC_Data_out_Fase_Redazione_Contratto__c)));
          //     dateIn = new Date(opportunity.WGC_Data_Fase_Redazione_Contratto__c);
          //     if (dateOut) mwi.phaseDuration = Math.floor(
          //         (Date.UTC(dateOut.getFullYear(), dateOut.getMonth(), dateOut.getDate()) -
          //         Date.UTC(dateIn.getFullYear(), dateIn.getMonth(), dateIn.getDate()))
          //     ) / (millisecondUnit);
          //     if (mwi.phaseDuration <= 0) mwi.phaseDuration = 1;
          // }
          // break;
          case "Perfezionamento Contratto":
            if (
              opportunity.WGC_Data_Fase_Perfezionamento_Contratto__c != null
            ) {
              dateOut =
                opportunity.StageName == mwi.phase
                  ? today
                  : isLost
                  ? new Date(opportunity.WGC_Data_Fase_Chiusa_Persa__c)
                  : new Date(
                      opportunity.WGC_Data_out_Perfezionamento_Contratto__c
                    );
              dateIn = new Date(
                opportunity.WGC_Data_Fase_Perfezionamento_Contratto__c
              );
              if (dateOut)
                mwi.phaseDuration =
                  Math.floor(
                    Date.UTC(
                      dateOut.getFullYear(),
                      dateOut.getMonth(),
                      dateOut.getDate()
                    ) -
                      Date.UTC(
                        dateIn.getFullYear(),
                        dateIn.getMonth(),
                        dateIn.getDate()
                      )
                  ) / millisecondUnit;
              if (mwi.phaseDuration <= 0) mwi.phaseDuration = 1;
            }
            break;
          case "Attivazione":
            if (opportunity.WGC_Data_Fase_Attivazione_Prodotto__c != null) {
              dateOut =
                opportunity.StageName == mwi.phase
                  ? today
                  : isLost
                  ? new Date(opportunity.WGC_Data_Fase_Chiusa_Persa__c)
                  : new Date(
                      opportunity.WGC_Data_out_Fase_Attivazione_Prodotto__c
                    );
              dateIn = new Date(
                opportunity.WGC_Data_Fase_Attivazione_Prodotto__c
              );
              if (dateOut)
                mwi.phaseDuration =
                  Math.floor(
                    Date.UTC(
                      dateOut.getFullYear(),
                      dateOut.getMonth(),
                      dateOut.getDate()
                    ) -
                      Date.UTC(
                        dateIn.getFullYear(),
                        dateIn.getMonth(),
                        dateIn.getDate()
                      )
                  ) / millisecondUnit;
              if (mwi.phaseDuration <= 0) mwi.phaseDuration = 1;
            }
            break;
          case "Valutazione Pratica":
            if (opportunity.WGC_Data_Fase_Valutazione_Pratica__c != null) {
              dateOut =
                opportunity.StageName == mwi.phase
                  ? today
                  : isLost
                  ? new Date(opportunity.WGC_Data_Fase_Chiusa_Persa__c)
                  : new Date(
                      opportunity.WGC_Data_out_Fase_Valutazione_Pratica__c
                    );
              dateIn = new Date(
                opportunity.WGC_Data_Fase_Valutazione_Pratica__c
              );
              if (dateOut)
                mwi.phaseDuration =
                  Math.floor(
                    Date.UTC(
                      dateOut.getFullYear(),
                      dateOut.getMonth(),
                      dateOut.getDate()
                    ) -
                      Date.UTC(
                        dateIn.getFullYear(),
                        dateIn.getMonth(),
                        dateIn.getDate()
                      )
                  ) / millisecondUnit;
              if (mwi.phaseDuration <= 0) mwi.phaseDuration = 1;
            }
            break;
          case "Rinnovo":
            if (opportunity.WGC_Data_Fase_Rinnovo__c != null) {
              dateOut =
                opportunity.StageName == mwi.phase
                  ? today
                  : isLost
                  ? new Date(opportunity.WGC_Data_Fase_Chiusa_Persa__c)
                  : new Date(opportunity.WGC_Data_Out_Fase_Rinnovo__c);
              dateIn = new Date(opportunity.WGC_Data_Fase_Rinnovo__c);
              if (dateOut)
                mwi.phaseDuration =
                  Math.floor(
                    Date.UTC(
                      dateOut.getFullYear(),
                      dateOut.getMonth(),
                      dateOut.getDate()
                    ) -
                      Date.UTC(
                        dateIn.getFullYear(),
                        dateIn.getMonth(),
                        dateIn.getDate()
                      )
                  ) / millisecondUnit;
              if (mwi.phaseDuration <= 0) mwi.phaseDuration = 1;
            }
            break;
          case "Valutazione":
            if (opportunity.WGC_Data_Fase_Valutazione__c != null) {
              dateOut =
                opportunity.StageName == mwi.phase
                  ? today
                  : isLost
                  ? new Date(opportunity.WGC_Data_Fase_Chiusa_Persa__c)
                  : new Date(opportunity.WGC_Data_Out_Fase_Valutazione__c);
              dateIn = new Date(opportunity.WGC_Data_Fase_Valutazione__c);
              if (dateOut)
                mwi.phaseDuration =
                  Math.floor(
                    Date.UTC(
                      dateOut.getFullYear(),
                      dateOut.getMonth(),
                      dateOut.getDate()
                    ) -
                      Date.UTC(
                        dateIn.getFullYear(),
                        dateIn.getMonth(),
                        dateIn.getDate()
                      )
                  ) / millisecondUnit;
              if (mwi.phaseDuration <= 0) mwi.phaseDuration = 1;
            }
            break;
        }
      });

      switch (opportunity.StageName) {
        case "Valutazione Pratica":
          mainWizardProgressValue = 33;
          mainWizardItems
            .filter((mwi) => {
              return (
                mwi.phase == "In Istruttoria" ||
                mwi.phase == "Valutazione Pratica"
              );
            })
            .forEach((mwi) => {
              mwi.clickable = true;
            });
          break;
        // SM - CR401 eliminazione Predisposizione Contratto
        // case "Predisposizione Contratto":
        // mainWizardProgressValue = 50;
        // mainWizardItems.filter(mwi => {return mwi.phase == "In Istruttoria" || mwi.phase == "Valutazione Pratica" || mwi.phase == "Predisposizione Contratto";}).forEach(mwi => {mwi.clickable = true;});
        // break;
        case "Perfezionamento Contratto":
          mainWizardProgressValue = 67;
          mainWizardItems
            .filter((mwi) => {
              return (
                mwi.phase == "In Istruttoria" ||
                mwi.phase ==
                  "Valutazione Pratica" /*|| mwi.phase == "Predisposizione Contratto"*/ ||
                mwi.phase == "Perfezionamento Contratto"
              );
            })
            .forEach((mwi) => {
              mwi.clickable = true;
            });
          break;
        case "Attivazione":
        case "Vinta":
        case "Valutazione":
        case "Persa":
          mainWizardItems
            .filter((mwi) => {
              return (
                mwi.phase == "In Istruttoria" ||
                mwi.phase ==
                  "Valutazione Pratica" /*|| mwi.phase == "Predisposizione Contratto"*/ ||
                mwi.phase == "Perfezionamento Contratto" ||
                mwi.phase == "Attivazione"
              );
            })
            .forEach((mwi) => {
              mwi.clickable = true;
            });
          mainWizardProgressValue = 100;
          break;
      }
    }

    return mainWizardProgressValue;
  },

  configureWizard: function (component, event) {
    let isRevisione = component.get("v.isRevisione");
    let isRinnovo = component.get("v.isRinnovo");

    let mainWizardItems = [
      {
        title: $A.get("$Label.c.Stato_Opp_1"), //IN Istruttoria
        phase: "In Istruttoria", // MATCH THE STAGENAME
        active: true,
        visible: true,
        clickable: false,
        state: "inProgress", // in progress (blue) , failed (red) , completed (green)
        phaseDuration: 0,
        visibleFor: "nuovaConcessione,revisione"
      },
      {
        title: $A.get("$Label.c.Stato_Opp_2"), //In Valutazione
        phase: "Valutazione Pratica", // MATCH THE STAGENAME
        active: false,
        visible: true,
        clickable: false,
        state: "", // in progress (blue) , failed (red) , completed (green)
        phaseDuration: 0,
        visibleFor: "nuovaConcessione,revisione"
      },
      // SM - CR401 eliminazione Predisposizione Contratto
      // {
      //     title: "Predisposizione Contratto",
      //     phase: "Predisposizione Contratto", // MATCH THE STAGENAME
      //     active: false,
      //     visible: true,
      //     clickable: false,
      //     state: "", // in progress (blue) , failed (red) , completed (green)
      //     phaseDuration: 0,
      //     visibleFor: "nuovaConcessione,revisione"
      // },
      {
        title: $A.get("$Label.c.Stato_Opp_3"), // Firma Contratti
        phase: "Perfezionamento Contratto", // MATCH THE STAGENAME
        active: false,
        visible: true,
        clickable: false,
        state: "", // in progress (blue) , failed (red) , completed (green)
        phaseDuration: 0,
        visibleFor: "nuovaConcessione,revisione"
      },
      {
        title: $A.get("$Label.c.Stato_Opp_4"), //"Da Avviare",
        phase: "Attivazione", // MATCH THE STAGENAME
        active: false,
        visible: true,
        clickable: false,
        state: "", // in progress (blue) , failed (red) , completed (green)
        phaseDuration: 0,
        visibleFor: "nuovaConcessione,revisione"
      },
      {
        title: "Rinnovo",
        phase: "Rinnovo", // MATCH THE STAGENAME
        active: true,
        visible: false,
        clickable: false,
        state: "inProgress", // in progress (blue) , failed (red) , completed (green)
        phaseDuration: 0,
        visibleFor: "rinnovo"
      },
      {
        title: "Valutazione",
        phase: "Valutazione", // MATCH THE STAGENAME
        active: false,
        visible: false,
        clickable: false,
        state: "", // in progress (blue) , failed (red) , completed (green)
        phaseDuration: 0,
        visibleFor: "rinnovo"
      }
    ];

    let wizardItems = [
      {
        title: "Scelta Prodotto",
        step: "sceltaProdotto",
        substeps: ["inserimentoDebitori"],
        active: true,
        disabled: false,
        completed: false,
        hasError: false,
        icon: "",
        visible: true
      },
      {
        title: "Configura Prodotto",
        step: "configuraProdotto",
        substeps: ["garantiGaranzie"],
        active: false,
        disabled: true,
        completed: false,
        hasError: false,
        icon: "",
        visible: true
      },
      {
        title: "Analisi Cliente",
        step: "analisiCliente",
        active: false,
        disabled: false,
        completed: false,
        hasError: false,
        icon: "",
        visible: true
      },
      {
        title: "Bilancio",
        step: "analisiBilancio",
        active: false,
        disabled: false,
        completed: false,
        hasError: false,
        icon: "",
        visible: true
      },
      {
        title: "Centrale Rischi",
        step: "analisiCR",
        active: false,
        disabled: false,
        completed: false,
        hasError: false,
        icon: "",
        visible: true
      },
      {
        title: "Eventi Negativi",
        step: "analisiEventi",
        active: false,
        disabled: false,
        completed: false,
        hasError: false,
        icon: "",
        visible: true
      },
      {
        title: "Documentazione",
        step: "documentazione",
        active: false,
        disabled: false,
        completed: false,
        hasError: false,
        icon: "",
        visible: true
      },
      {
        title: "Note",
        step: "note",
        active: false,
        disabled: false,
        completed: false,
        hasError: false,
        icon: "",
        visible: true
      }
    ];

    this.refreshWizardItemsVisibility(
      isRevisione,
      isRinnovo,
      mainWizardItems,
      wizardItems,
      component
    );
    this.getMainWizItemsInfo(component, mainWizardItems);

    component.set("v.mainWizardItems", mainWizardItems);
    component.set("v.wizardItems", wizardItems);
  },

  refreshWizard: function (component) {
    let mainWizardItems = component.get("v.mainWizardItems");
    let wizItems = component.get("v.wizardItems");
    // var wizardItemsMap = this.mapArrayBy(wizItems, "step");

    let mainWizardProgressValue = this.getMainWizItemsInfo(
      component,
      mainWizardItems
    );

    wizItems.forEach((wi) => {
      this.wizardItemsConditionsToUpdatePrevNode(component, wi);
    });
    // this.setWizItemCompleted(wizardItemsMap["sceltaProdotto"], (component.get("v.payload").linee != undefined ? component.get("v.payload").linee.length > 0 : false));

    if (
      mainWizardItems.find((mwi) => {
        return mwi.active;
      })
    )
      this.initPhase(
        component,
        mainWizardItems.find((mwi) => {
          return mwi.active;
        }).phase
      );

    this.setActivePhase(component, mainWizardItems);

    component.set("v.mainWizardProgressValue", mainWizardProgressValue);
    component.set("v.mainWizardItems", mainWizardItems);
    component.set("v.wizardItems", wizItems);
  },

  updateWizard: function (component, target) {
    var wizardItems = component.get("v.wizardItems");
    // var payload = component.get("v.payload");
    var actualNode = this.getFirstNodeByFields(wizardItems, [
      { field: "active", value: true }
    ]);
    var targetNode = this.getFirstNodeByFields(wizardItems, [
      { field: "step", value: target }
    ]);

    if (targetNode === null)
      targetNode = wizardItems.find(function (wi) {
        return wi.substeps.includes(target);
      });

    if (
      actualNode != null &&
      targetNode != null &&
      (actualNode.title != targetNode.title || actualNode.title != target)
    ) {
      actualNode.active = false;
      targetNode.active = true;
      targetNode.disabled = false;

      // this.wizardItemsConditionsAndActions(component, actualNode);
      this.wizardItemsConditionsToUpdatePrevNode(component, actualNode);
      this.wizardItemsActionsToInitNextNode(component, target);
    }

    component.set("v.step", target);
    component.set("v.wizardItems", wizardItems);
  },

  setWizItemCompleted: function (wizItem, isCompleted) {
    wizItem.completed = isCompleted;
    wizItem.icon = isCompleted ? "utility:check" : "";
  },

  setWizItemError: function (wizItem, hasError) {
    wizItem.hasError = hasError;
    // wizItem.icon = hasError ? "utility:close" : "";
  },

  setWizItemDisabled: function (wizItem, disabled) {
    wizItem.disabled = disabled;
  },

  initPhase: function (component, phase) {
    let h = this;
    var datiPEFRetrieved;
    switch (phase) {
      case "Valutazione Pratica":
      // SM - CR401 eliminazione Predisposizione Contratto
      // case "Predisposizione Contratto":
      case "Perfezionamento Contratto":
      case "Attivazione":
      case "Valutazione":
        this.showSpinner(component, "Recupero Dati PEF in corso...");
        this.lockStateSpinner(component);

        this.callServerSync(component, "c.loadDatiPEF", {
          accountId: component.get("v.opportunityRecord").AccountId,
          opportunityId: component.get("v.opportunityId")
        })
          .then(function (result) {
            console.log("loadDatiPEF: ", result);
            if (result.success) {
              let payloadData = JSON.parse(result.data);
              // let object = payloadData.payload.outputRichiesta;
              datiPEFRetrieved = payloadData.response.payload.outputRichiesta;
              let factoringProducts = payloadData.factoringProducts.map(
                (fp) => {
                  return fp.Codice__c;
                }
              );
              let importi = payloadData.importi;
              let linee = payloadData.linee;

              // for (let prop in object) {
              //     if (object.hasOwnProperty(prop)) {
              //         console.log("type: ", typeof object[prop]);
              //         if (typeof object[prop] !== "array")
              //             datiPEF.push({label:prop, value:object[prop]});
              //         else
              //             datiPEF.push({label:prop, value:'Array -size:'+object[prop].length});
              //     }
              // }

              component.set("v.linee", linee);
              component.set("v.importi", importi);
              component.set("v.factoringProducts", factoringProducts);
              component.set(
                "v.datiPEF",
                JSON.parse(JSON.stringify(datiPEFRetrieved))
              );
              component.set("v.spinnerMessage", "Recupero linee chiuse..");
              return h.callServerSync(component, "c.loadLineeChiuse", {
                opportunityId: component.get("v.opportunityId")
              });
            } else {
              h.unlockStateSpinner(component);
              h.hideSpinner(component);

              // h.showToast(component, "Errore", result.msg, "error");
              console.log("CARICAMENTO DATI PEF FAILED. ERROR: ", result.msg);
            }
          })
          .then(function (result) {
            // h.unlockStateSpinner(component);
            // h.hideSpinner(component);
            //let datiPEF = component.get("v.datiPEF");
            let lines = datiPEFRetrieved
              ? typeof datiPEFRetrieved == "object"
                ? datiPEFRetrieved.elencoLineeCredito
                : datiPEFRetrieved.reduce((start, d) => {
                    return start.concat(d.elencoLineeCredito);
                  }, [])
              : null;

            component.set("v.lineeChiuseAOD", result);

            return h.callServerSync(component, "c.checkLinesCompleteness", {
              JSONlines: JSON.stringify(lines),
              opportunityId: component.get("v.opportunityId")
            });
          })
          .then(function (result) {
            console.log("checkLinesCompleteness: ", result);
            if (result.success) {
              if (result.data) {
                let resultData = JSON.parse(result.data);

                if (resultData.hasOwnProperty("opportunity")) {
                  h.reloadRecord(component);
                } else if (resultData.hasOwnProperty("linee")) {
                  component.set("v.linee", resultData.linee);
                }
              }

              h.unlockStateSpinner(component);
              h.hideSpinner(component);
            } else {
              h.unlockStateSpinner(component);
              h.hideSpinner(component);

              // h.showToast(component, "Errore", result.msg, "error");
              console.log("CARICAMENTO DATI PEF FAILED. ERROR: ", result.msg);
            }
          });
        break;
    }
  },

  manageMainWizardItemState: function (component, mwi, opportunity) {
    if (mwi.phase == opportunity.FaseDiCaduta__c) mwi.state = "failed";
    else if (mwi.active) mwi.state = "inProgress";
    else {
      switch (mwi.phase) {
        case "Rinnovo":
          if (
            opportunity.Tipologia_Opportunit__c == "RINN" &&
            (opportunity.WGC_Codice_Pratica__c != "" ||
              opportunity.WGC_Codice_Pratica__c != null)
          )
            mwi.state = "completed";
          break;
        case "In Istruttoria":
          if (!this.isBlank(opportunity.IdCartella__c)) mwi.state = "completed";
          break;
        case "Valutazione Pratica":
          if (
            /*opportunity.StageName == "Predisposizione Contratto" ||*/ opportunity.StageName ==
              "Perfezionamento Contratto" ||
            opportunity.StageName == "Attivazione" ||
            opportunity.StageName == "Vinta"
          )
            mwi.state = "completed";
          break;
          // SM - CR401 eliminazione Predisposizione Contratto
          // case "Predisposizione Contratto":
          // if (opportunity.StageName == "Perfezionamento Contratto" || opportunity.StageName == "Attivazione" || opportunity.StageName == "Vinta")
          //         mwi.state = "completed";
          break;
        case "Perfezionamento Contratto":
          if (
            opportunity.StageName == "Attivazione" ||
            opportunity.StageName == "Vinta"
          )
            mwi.state = "completed";
          break;
        case "Attivazione":
          if (
            opportunity.StageName == "Attivazione" ||
            opportunity.StageName == "Vinta"
          )
            mwi.state = "completed";
        // TODO: gestire altre fasi
      }
    }
  },

  selectWizardItem: function (component, title) {
    var wizardItems = component.get("v.wizardItems");
    var wizItem = null;
    // var step = "";
    var isvalid = true;

    for (var wi in wizardItems) {
      if (wizardItems[wi].title == title && wizardItems[wi].disabled == true) {
        isvalid = false;
        break;
      } else if (wizardItems[wi].title == title) {
        wizardItems[wi].active = true;
        wizItem = wizardItems[wi];
      } else if (wizardItems[wi].active == true) {
        wizardItems[wi].active = false;
        // wizItem = wizardItems[wi];
      }
    }

    if (isvalid == true) {
      this.showSpinner(component, "Messaggio generico");
      this.wizardItemsActionsToInitNextNode(component, wizItem.step);
      component.set("v.step", wizItem.step);
      component.set("v.wizardItems", wizardItems);
    } else {
      this.showToast(
        component,
        "Attenzione",
        "Step non ancora disponibile.",
        "warning"
      );
    }
  },

  wizardItemsActionsToInitNextNode: function (component, step) {
    var payload = component.get("v.payload");

    switch (step) {
      case "sceltaProdotto": // ACTIONS TO INITIALIZE A WIZITEM
        // this.setWizItemCompleted(wizItem, payload.linee.length > 0);
        break;
      case "configuraProdotto":
        this.reloadParametriEConfigurazioniLinee(component);
        this.reloadProdottiGaranteDefault(component);
        // var condition = false;
        // this.setWizItemCompleted(wizItem, condition);
        break;
      case "garantiGaranzie":
        this.reloadGarantiEGaranzie(component);
        break;
    }

    this.hideSpinner(component);
  },

  wizardItemsConditionsToUpdatePrevNode: function (component, wizItem) {
    var payload = component.get("v.payload");
    let completed = false;
    let hasError = false;
    let isRinnovo = component.get("v.isRinnovo");
    let currentUser = component.get("v.currentUser");

    if (!payload || !component.get("v.opportunityRecord")) return;

    switch (wizItem.step) {
      case "sceltaProdotto": // CONDITIONS TO COMPLETE A WIZITEM
        // this.hideSpinner(component);
        // this.setWizItemCompleted(wizItem, payload.linee.length > 0);
        this.setWizItemCompleted(
          wizItem,
          component.get("v.opportunityRecord")
            .WGC_Configurazione_Prodotti_Completa__c
        );
        break;
      case "configuraProdotto":
        // TODO: gestire salvataggio campo WizardCompletato__c al click del bottone "avanti" nella sezione "configura prodotto"
        console.log(
          "WizardCompletato: ",
          component.get("v.opportunityRecord").WizardCompletato__c
        );
        if (currentUser.Profile.Name == "IFIS - B/O Valutazione Fast Finance")
          this.setWizItemCompleted(
            wizItem,
            component.get("v.opportunityRecord").WGC_WizardCompletatoBO__c
          );
        else
          this.setWizItemCompleted(
            wizItem,
            component.get("v.opportunityRecord").WizardCompletato__c ||
              isRinnovo
          );
        this.setWizItemDisabled(
          wizItem,
          payload.linee.length == 0 ||
            payload.linee
              .map((l) => {
                return l.codice;
              })
              .includes("Standard")
        );
        break;
      case "analisiCliente":
        let CLC = component.get("v.opportunityRecord").Account
          .WGC_Semaforo_CLC__c;
        let GIANOS = component.get("v.opportunityRecord").Account
          .WGC_Semaforo_Gianos__c;
        let RATING = component.get("v.opportunityRecord").Account.RatingT0__c;
        completed =
          (CLC == "VERDE" && GIANOS == "VERDE" ? RATING <= 4 : false) ||
          component.get("v.opportunityRecord").WGC_Note_Cliente__c != null;
        hasError =
          (CLC != "VERDE" || GIANOS != "VERDE" || RATING > 4) &&
          component.get("v.opportunityRecord").WGC_Note_Cliente__c == null;
        this.setWizItemCompleted(wizItem, completed);
        this.setWizItemError(wizItem, hasError);
        break;
      case "analisiBilancio":
        let bilancio = component.get("v.bilancio");
        let validBilancio = false;
        if (bilancio)
          validBilancio =
            bilancio.KPI_Factoring_Cedente__c &&
            bilancio.KPI_Factoring_Debitore__c &&
            bilancio.KPI_Finanziamenti__c;

        completed = validBilancio
          ? component.get("v.opportunityRecord")
              .WGC_Presa_Visione_Bilancio__c == true
          : component.get("v.opportunityRecord").WGC_NoteBilancio__c != null;
        hasError =
          !validBilancio &&
          component.get("v.opportunityRecord").WGC_NoteBilancio__c == null;
        this.setWizItemCompleted(wizItem, completed);
        this.setWizItemError(wizItem, hasError);
        break;
      case "analisiCR":
        // let hasCRData = component.get("v.opportunityRecord").Account.Sconfini_a_revoca__c != null &&
        //                 component.get("v.opportunityRecord").Account.Sconfini_a_revoca_Utilizzato_Accordato__c != null &&
        //                 component.get("v.opportunityRecord").Account.Sconfini_a_scadenza__c != null &&
        //                 component.get("v.opportunityRecord").Account.Sconfini_a_scadenza_Utilizzato_Accordato__c != null;
        // let validCR = hasCRData && component.get("v.opportunityRecord").Account.WGC_Alert_KPI_Centrale_Rischi__c == false;
        let oppRecord = component.get("v.opportunityRecord");
        let validCR =
          oppRecord.Account.WGC_Alert_KPI_Centrale_Rischi__c == false;
        let isEstero = oppRecord.Account.WGC_Area__c == "EE";
        // let nonAffidato = oppRecord.Account.WGC_Flag_non_affidato__c;
        // let dataBKIT = oppRecord.Account.WGC_Data_Caricamento_BKIT__c;
        // let dataRichiesta = oppRecord.Account.WGC_DataRichiestaCR__c;
        let isNSA = oppRecord.IsOppNSA__c;
        // let hasCRData = component.get("v.hasCRData");
        // let lastCRDate = component.get("v.lastCRDate");
        // let isValidCR = component.get("v.isValidCR");
        // let config = {};

        // completed = (isEstero || isNSA ? true : (validCR ? component.get("v.opportunityRecord").WGC_Presa_Visione_CR__c == true : component.get("v.opportunityRecord").WGC_NoteCR__c != null));
        completed =
          isEstero || isNSA || wizItem.completed
            ? true
            : component.get("v.opportunityRecord").WGC_NoteCR__c != null;
        hasError =
          !isEstero && !isNSA
            ? wizItem.hasError &&
              component.get("v.opportunityRecord").WGC_NoteCR__c == null
            : false;

        // if (nonAffidato === true && !hasCRData && (dataBKIT >= dataRichiesta || dataRichiesta == null)) { // CASO 4
        //     completed = true;
        //     hasError = false;
        //     config = {
        //         msg: $A.get("$Label.c.WGC_Cart_CRMessage_SoggettoNonAffidato"),
        //         graph: false,
        //         debs: true,
        //         dataRilevazione: dataBKIT,
        //         msgBKIT: "Data Richiesta BKIT",
        //         dataRichiesta: dataRichiesta,
        //         note: true
        //     };
        // } else if ((!hasCRData && nonAffidato === false && dataRichiesta != null) || (nonAffidato === true && dataBKIT < dataRichiesta)) { // CASO 5
        //     completed = (isEstero || isNSA || nonAffidato);
        //     hasError = false;
        //     config = {
        //         msg: $A.get("$Label.c.WGC_Cart_CRMessage_ElaborazioneInCorso"),
        //         graph: false,
        //         debs: true,
        //         dataRilevazione: null,
        //         dataRichiesta: dataRichiesta,
        //         note: false
        //     };
        // } else { // CASO 3-6
        //     config = {
        //         msg: (isEstero ? $A.get("$Label.c.WGC_Cart_CRMessage_CentraleRischiNonNecessariaEstero") : (isValidCR ? "" : $A.get("$Label.c.WGC_Cart_CRMessage_CentraleRischiScaduta"))),
        //         graph: isValidCR,
        //         debs: true,
        //         dataRilevazione: lastCRDate,
        //         dataRichiesta: dataRichiesta,
        //         note: isValidCR || isEstero
        //     };
        // }

        // component.set("v.configCR", config);

        this.setWizItemCompleted(wizItem, completed);
        this.setWizItemError(wizItem, hasError);
        // this.setWizItemDisabled(wizItem, component.get("v.isValidCR") === false);
        break;
      case "analisiEventi":
        let validEventi =
          component.get("v.opportunityRecord").Account
            .WGC_Alert_KPI_Eventi_negativi__c == false;
        completed = validEventi
          ? component.get("v.opportunityRecord").WGC_Presa_Visione_Eventi__c ==
            true
          : component.get("v.opportunityRecord").WGC_NoteEventi__c != null;
        hasError =
          !validEventi &&
          component.get("v.opportunityRecord").WGC_NoteEventi__c == null;
        this.setWizItemCompleted(wizItem, completed);
        this.setWizItemError(wizItem, hasError);
        break;
      case "documentazione":
        let validDocs = component.get("v.opportunityRecord")
          .WGC_Documenti_validi__c;
        completed = validDocs;
        hasError = !validDocs;
        this.setWizItemCompleted(wizItem, completed);
        this.setWizItemError(wizItem, hasError);
        break;
      case "note":
        this.setWizItemCompleted(
          wizItem,
          component.get("v.opportunityRecord").Account
            .WGC_Descrizione_dell_azienda__c != null &&
            component.get("v.opportunityRecord")
              .WGC_Descrizione_Operativit_Proposta__c != null
        );
        this.setWizItemError(
          wizItem,
          component.get("v.opportunityRecord").Account
            .WGC_Descrizione_dell_azienda__c == null ||
            component.get("v.opportunityRecord")
              .WGC_Descrizione_Operativit_Proposta__c == null
        );
        break;
    }
  },

  reloadParametriEConfigurazioniLinee: function (component) {
    var opportunityId = component.get("v.opportunityId");
    var h = this;
    this.lockStateSpinner(component);

    this.callServerSync(component, "c.getDebitoriPerLinea", {
      opportunityId: opportunityId
    })
      .then(function (result) {
        console.log("callServerSync --result: ", result);
        let debs = [];

        for (let key in result)
          debs.push({ linea: key, debitori: result[key] });

        component.set("v.debitoriPerLinea", debs);
        // if (debs.length > 0)
        return h.callServerSync(
          component,
          "c.getParametriEConfigurazioniLinee",
          { opportunityId: opportunityId }
        );
      })
      .then(function (result) {
        console.log("PARAMETRI E CONFIGURAZIONI", result);
        component.set("v.parametriEConfigurazioniLinee", result);
        h.unlockStateSpinner(component);
        h.hideSpinner(component);
      })
      .catch(function (reason) {
        console.log("ERROR: ", reason);
        h.showToast(component, "ERROR", reason.message, "error");
      });

    // var action = component.get("c.getParametriEConfigurazioniLinee");
    // action.setParams({ "opportunityId" : opportunityId });
    // //Setting the Callback
    // action.setCallback(this,function(response){
    //     //get the response state
    //     var state = response.getState();

    //     //check if result is successfull
    //     if(state == "SUCCESS"){
    //         console.log("SUCCESS");
    //         // console.log(response.getReturnValue());
    //         var result = response.getReturnValue();
    //         component.set('v.parametriEConfigurazioniLinee', result);
    //     } else if(state == "ERROR"){
    //         alert('Error in calling server side action');
    //     }
    // });
    // $A.enqueueAction(action);
  },

  reloadGarantiEGaranzie: function (component) {
    let opportunityId = component.get("v.opportunityId");
    let h = this;
    this.lockStateSpinner(component);

    this.callServerSync(component, "c.getGarantiEGaranzie", {
      opportunityId: opportunityId
    })
      .then(function (result) {
        console.log("callServer --result: ", result);
        if (result.success) {
          let joinGaranziaGarante = component.get("v.payload")
            .joinGaranziaGarante;
          let garantiNotP = result.data.garanti.filter((g) => {
            return g.TipoGarante__c != "P";
          });
          garantiNotP.forEach((g) => {
            g.percentualeGaranzia = joinGaranziaGarante.find((j) => {
              return j.garante == g.Id;
            }).percentualeGaranzia;
          });
          component.set("v.garanzie", result.data.garanzie);
          component.set("v.garanti", garantiNotP);
          return h.callServerSync(component, "c.loadGaranziaData", {});
        } else {
          this.showToast(
            component,
            $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
            result.msg,
            "error"
          );
        }
      })
      .then(function (result) {
        if (result.length == 0)
          h.showToast(
            component,
            $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
            "Non è stato possibile recuperare i dati di configurazione.",
            "error"
          );
        else {
          let data = JSON.parse(result);
          component.set(
            "v.divise",
            data.divise.map((d) => {
              return { value: d.split(":")[0], label: d.split(":")[1] };
            })
          );
          component.set("v.matriceGaranzie", data.matriceGaranzie);
        }
        h.unlockStateSpinner(component);
        h.hideSpinner(component);
      });
  },

  loadDiviseOptions: function (component) {
    this.callServer(
      component,
      "c.getDiviseOptions",
      function (result) {
        // console.log("callServer --result: ", result);
        component.set("v.diviseOptions", result);
      },
      {}
    );
  },

  loadTipologieMutui: function (component) {
    this.callServer(
      component,
      "c.getTipologieMutui",
      function (result) {
        // console.log("callServer --result: ", result);
        component.set(
          "v.tipologieMutui",
          result.map((r) => {
            return { value: r.CodiceUnivoco__c, label: r.Name };
          })
        );
      },
      {}
    );
  },

  //A.M. Gestione Mutuo Veneto Sviluppo   
  loadTipologieMutuiVS : function(component) {
    this.callServer(component, "c.getTipologieMutuiVS", function(result){
        // console.log("callServer --result: ", result);
        component.set("v.tipologieMutuiVS", result.map(r => {
            return {value: r.CodiceUnivoco__c, label: r.Name};
        }));
    }, {});
  },    

  loadDebitoriPerLinea: function (component) {
    let opportunityId = component.get("v.opportunityId");
    this.callServer(
      component,
      "c.getDebitoriPerLinea",
      function (result) {
        // console.log("callServerSync --result: ", result);
        let debs = [];

        for (let key in result)
          debs.push({ linea: key, debitori: result[key] });

        component.set("v.debitoriPerLinea", debs);
      },
      { opportunityId: opportunityId }
    );
  },

  loadSpecialistaInfo: function (component) {
    let opportunityId = component.get("v.opportunityId");
    let accountId = component.get("v.opportunityRecord").AccountId;
    this.callServer(
      component,
      "c.isCurrentUserSpecialista",
      function (result) {
        // console.log("callServer --result: ", result);
        component.set("v.isCurrentUserSpecialista", result);
      },
      { accountId: accountId, opportunityId: opportunityId }
    );
  },

  reloadRecord: function (component) {
    component.find("record").reloadRecord(true);
    this.getCCIfis(component);
  },

  cartCallServer: function (component, event) {
    var h = this;
    if (
      !event.getParam("params").hasOwnProperty("field") ||
      event.getParam("params").field != "WGC_Presa_Visione_Bilancio__c"
    ) {
      this.showSpinner(
        component,
        event.getParam("spinnerMessage") ? event.getParam("spinnerMessage") : ""
      );
      if (event.getParam("lockStateSpinner") == true)
        this.lockStateSpinner(component);
    }
    try {
      this.callServer(
        component,
        event.getParam("method"),
        function (result) {
          h.manageCallback(component, event, result);
        },
        event.getParam("params")
      );
    } catch (e) {
      this.hideSpinner(component);
      this.showToast(
        component,
        "Oops! Qualcosa è andato storto..",
        e.message,
        "error"
      );
    }
  },

  getServizi: function (component) {
    this.callServer(
      component,
      "c.getServizi",
      function (result) {
        component.set("v.servizi", result);
      },
      {}
    );
  },

  manageCallback: function (component, event, result) {
    var params = event.getParam("params");
    let payload = component.get("v.payload");
    let joinGaranziaGarante = payload.joinGaranziaGarante;
    let h = this;
    if (!this.isBlank(params.uid) && !this.isBlank(params.resolveAction)) {
      var appEvent = $A.get("e.c:WGC_Cart_Resolve_Server");
      appEvent.setParams({
        uid: params.uid,
        json: JSON.stringify({
          action: params.resolveAction,
          response: result,
          payload: params.payload
        })
      });
      appEvent.fire();
      this.hideSpinner(component);
    } else {
      switch (event.getParam("method")) {
        case "c.saveWizard":
          if (!this.isBlank(result.redirect))
            window.location.href = "/" + result.redirect;
          else if (result.success) {
            component.set("v.payload", result.data);
            switch (params.step) {
              //SM - Banca Corporate - Gestione
              // case 'categorie_corporate':
              case "categorie":
                console.log("SAVE WIZARD --CATEGORIE");
                this.callServer(
                  component,
                  "c.updateField",
                  function (result) {
                    console.log("updateField --OK");
                    h.reloadRecord(component);
                    h.refreshWizard(component);
                  },
                  {
                    field: "WGC_Configurazione_Prodotti_Completa__c",
                    value: false,
                    objectId: result.data.opportunityId
                  }
                );
                this.refreshWizard(component);
                this.showToast(
                  component,
                  "Dati salvati correttamente!",
                  "I dati sono stati salvati senza errori.",
                  "success"
                );
                break;
              //SM - Banca Corporate - Gestione
              // case 'categorie_corporate':
              //     console.log('SAVE WIZARD --CATEGORIE_CORPORATE');
              //     this.callServer(component, "c.updateField", function(result){
              //         console.log("updateField --OK");
              //         h.reloadRecord(component);
              //         h.refreshWizard(component);
              //     }, {
              //         field: "WGC_Configurazione_Prodotti_Completa__c",
              //         value: false,
              //         objectId: result.data.opportunityId
              //     });
              //     this.refreshWizard(component);
              //     this.showToast(component, "Dati salvati correttamente!", "I dati sono stati salvati senza errori.", "success");
              // break;
              case "servizi":
                console.log("SAVE WIZARD --SERVIZI");
                this.callServer(
                  component,
                  "c.updateField",
                  function (result) {
                    console.log("updateField --OK");
                    h.reloadRecord(component);
                    h.refreshWizard(component);
                  },
                  {
                    field: "WGC_Configurazione_Prodotti_Completa__c",
                    value: true,
                    objectId: result.data.opportunityId
                  }
                );

                // this.getCRData(component);

                component.set(
                  "v.newLines",
                  result.data.linee.filter((l) => {
                    return !l.isRevisione;
                  }).length
                );

                if (
                  result.data.linee.filter((l) => {
                    return l.codice != "Standard";
                  }).length > 0
                )
                  this.updateWizard(component, "configuraProdotto");
                else this.updateWizard(component, "analisiBilancio");

                if (JSON.parse(params.payload).wizardCompletato == true)
                  this.reloadRecord(component);

                if (component.get("v.validRSF") == true)
                  this.callServer(
                    component,
                    "c.richiestaPrimaInfoCR",
                    function (result) {
                      console.log("richiestaPrimaInfoCR --OK");
                    },
                    {
                      opportunityId: result.data.opportunityId,
                      target: "debitori"
                    }
                  );
                break;
              case "configurazionelinee":
              case "configurazioneicarmanuali":
              case "configurazionelinee,configurazioneicarmanuali":
                console.log("SAVE WIZARD --CONFIGURAZIONE LINEE");
                let inputPayload = JSON.parse(params.payload);
                console.log("inputPayload: ", inputPayload);
                this.reloadRecord(component);
                console.log(
                  "inputPayload.wizardCompletato: ",
                  inputPayload.wizardCompletato
                );
                if (inputPayload.wizardCompletato == true)
                  this.updateWizard(
                    component,
                    this.isBlank(params.nextStep)
                      ? "garantiGaranzie"
                      : params.nextStep
                  );
                // let wizItems = component.get("v.wizardItems");
                // if (payload.wizardCompletato == true) {
                //     this.setWizItemCompleted(wizItems.find(wi => {return wi.step == "configuraProdotto";}), payload.wizardCompletato);
                //     component.set("v.wizardItems", wizItems);
                // }
                this.showToast(
                  component,
                  "Dati salvati correttamente!",
                  "I dati sono stati salvati senza errori.",
                  "success"
                );

                //SM - Spese Istruttoria
                this.getDatiSpeseIstruttoria(component, event);

                break;
              case "garanzie":
                let validRSF = component.get("v.validRSF");
                let validPrivacy = component.get("v.validPrivacy");

                if (validRSF && validPrivacy)
                  this.callServer(
                    component,
                    "c.richiestaPrimaInfoCR",
                    function (result) {
                      console.log("richiestaPrimaInfoCR --OK");
                    },
                    {
                      opportunityId: component.get("v.opportunityId"),
                      target: "garanti"
                    }
                  );

                this.showToast(
                  component,
                  "Dati salvati correttamente!",
                  "I dati sono stati salvati senza errori.",
                  "success"
                );
                this.updateWizard(component, "analisiBilancio");
            }
          } else
            this.showToast(
              component,
              "Oops! Qualcosa è andato storto..",
              result.msg,
              "error"
            );
          break;
        case "c.updateDebitori":
          // window.open(location, '_self', '');
          if (result.success) {
            this.callServer(
              component,
              "c.updateField",
              function (result) {
                console.log("updateField --OK");
                h.reloadRecord(component);
                h.refreshWizard(component);
              },
              {
                field: "WGC_Configurazione_Prodotti_Completa__c",
                value: false,
                objectId: result.data.opportunityId
              }
            );
            console.log(result.data);
            component.set("v.payload", result.data);
            // this.callServer(component, "c.richiestaPrimaInfoCR", function(result){
            //     console.log("richiestaPrimaInfoCR --OK");
            // }, { opportunityId: result.data.opportunityId, target: "debitori" });
            this.lockStateSpinner(component);
            this.getDebitoriNewFields(component);
            this.showToast(
              component,
              "Dati salvati correttamente!",
              "I dati sono stati salvati senza errori.",
              "success"
            );
          } else
            this.showToast(
              component,
              "Oops! Qualcosa è andato storto..",
              result.msg,
              "error"
            );
          break;
        case "c.setProductInOpp":
          console.log("SAVE PRODUCTS");
          this.updateWizard(component, "inserimentoDebitori");
          break;
        case "c.upsertNote":
          console.log("SAVE NOTE");
          this.reloadRecord(component);
          if (result)
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastSuccessTitle"),
              $A.get("$Label.c.WGC_Cart_Note_SaveSuccess"),
              "success"
            );
          else
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
              $A.get("$Label.c.WGC_Cart_Note_SaveError"),
              "error"
            );
          break;
        case "c.saveGaranzia":
          // window.open(location, '_self', '');
          console.log("SAVE GARANZIA");
          if (result != null) {
            var garanzie = component.get("v.garanzie");
            var garanzia = result;
            let h = this;
            // garanzia.tipologia = result.CodiceGaranzia__c;
            // garanzia.opportunita = result.Opportunita__c;
            // garanzia.linea = result.Linea__c;
            // garanzia.importo = result.Importo__c;
            // garanzia.divisa = result.DivisaNew__c;
            // garanzia.copertura = result.Tipo__c;
            // garanzia.idEsterno = result.IdEsterno__c;

            garanzie = garanzie.filter((g) => {
              return g.IdEsterno__c != garanzia.IdEsterno__c;
            });
            garanzie.push(garanzia);
            component.set("v.garanzie", garanzie);

            this.lockStateSpinner(component);
            if (!params.isEdit) {
              this.callServer(
                component,
                "c.saveGaranteDefault",
                function (result) {
                  this.unlockStateSpinner(component);
                  this.hideSpinner(component);

                  console.log("@@@ result garante default ", result);
                  if (result.success === true && result.data != null) {
                    this.showSpinner(component);
                    this.lockStateSpinner(component);

                    let garanti = component.get("v.garanti");

                    if (Array.isArray(result.data)) {
                      result.data.forEach((garanteDefault) => {
                        garanti.push(garanteDefault);
                      });
                      component.set("v.garanti", garanti);

                      result.data.forEach((garanteDefault) => {
                        let newJoin = {
                          garanzia: garanzia.IdEsterno__c,
                          garante: garanteDefault.Id,
                          percentualeGaranzia: 100
                        };

                        payload.joinGaranziaGarante.push(newJoin);
                      });

                      if (result.data.length > 1)
                        component.set(
                          "v.payload.joinGaranziaGarante",
                          payload.joinGaranziaGarante
                        );
                    } else {
                      let garanteDefault = result.data;
                      garanti.push(garanteDefault);
                      component.set("v.garanti", garanti);

                      let newJoin = {
                        garanzia: garanzia.IdEsterno__c,
                        garante: garanteDefault.Id,
                        percentualeGaranzia: 100
                      };

                      payload.joinGaranziaGarante.push(newJoin);

                      component.set(
                        "v.payload.joinGaranziaGarante",
                        payload.joinGaranziaGarante
                      );
                    }

                    //!Array.isArray(result.data)
                    //if(Array.isArray(result.data)){
                    this.callServer(
                      component,
                      "c.saveWizard",
                      function (subresult) {
                        component.set("v.payload", subresult.data);

                        h.unlockStateSpinner(component);
                        h.hideSpinner(component);
                        h.showToast(
                          component,
                          "Successo!",
                          "I dati della garanzia sono stati salvati correttamente.",
                          "success"
                        );
                      },
                      {
                        payload: JSON.stringify(payload),
                        step: "garanzie"
                      }
                    );
                    //}

                    h.unlockStateSpinner(component);
                    h.hideSpinner(component);
                  }
                },
                {
                  garanzia: garanzia,
                  opportunityId: component.get("v.opportunityId")
                }
              );
            } else {
              this.unlockStateSpinner(component);
              this.hideSpinner(component);
              this.showToast(
                component,
                "Successo!",
                "I dati della garanzia sono stati salvati correttamente.",
                "success"
              );
            }
          } else {
            this.showToast(
              component,
              "Errore",
              "Non è stato possibile inserire correttamente la garanzia.",
              "error"
            );
          }
          break;
        case "c.getReferenti":
          component.set("v.referenti", result);
          break;
        case "c.saveCrossSellingJSON":
          if (result === true) {
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastSuccessTitle"),
              "Informazioni salvate correttamente.",
              "success"
            );
            this.reloadRecord(component);
            // let items = component.get("v.selectedProducts");
            // items.find(i => {return i.isActive;}).isCompleted = true;
            // component.set("v.selectedProducts", items);
          } else
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
              "Non è stato possibile salvare i dati correttamente.",
              "error"
            );
          break;
        case "c.saveGaranti":
        case "c.saveGarante":
          if (result.success === true) {
            this.lockStateSpinner(component);
            let garanti = component.get("v.garanti");
            let garantiNotP;
            let garanzia = params.garanzia;
            let newJoin;

            payload.joinGaranziaGarante = payload.joinGaranziaGarante.filter(
              (j) => {
                return j.garanzia != garanzia;
              }
            );

            if (result.data.length == undefined) {
              garanti.push(result.data);
              newJoin = {
                garanzia: garanzia,
                garante: result.data.Id,
                percentualeGaranzia: 100
              };
              payload.joinGaranziaGarante.push(newJoin);
            } else {
              garanti = garanti.concat(result.data);
              garantiNotP = result.data.filter((res) => {
                return res.TipoGarante__c != "P";
              });
              newJoin = result.data.map((g) => {
                return {
                  garanzia: garanzia,
                  garante: g.Id,
                  percentualeGaranzia:
                    g.TipoGarante__c != "P"
                      ? (100 / garantiNotP.length).toFixed(0)
                      : 100
                };
              });
              payload.joinGaranziaGarante = payload.joinGaranziaGarante.concat(
                newJoin
              );
            }

            component.set("v.garanti", garantiNotP ? garantiNotP : garanti);

            let h = this;
            this.callServer(
              component,
              "c.saveWizard",
              function (subresult) {
                component.set("v.payload", subresult.data);
                h.unlockStateSpinner(component);
                h.hideSpinner(component);
              },
              {
                payload: JSON.stringify(payload),
                step: "garanzie"
              }
            );
          } else {
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
              result.msg,
              "error"
            );
          }
          break;
        case "c.removeGaranzia":
          if (result === true) {
            let garanzia = params.garanziaId;
            // let payload = component.get("v.payload");
            // let joinGaranziaGarante = payload.joinGaranziaGarante;
            payload.joinGaranziaGarante = joinGaranziaGarante.filter((j) => {
              return j.garanzia != garanzia;
            });
            component.set("v.payload", payload);
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastSuccessTitle"),
              "Garanzia rimossa correttamente.",
              "success"
            );
            this.reloadGarantiEGaranzie(component);
          } else {
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
              "Non è stato possibile salvare correttamente le informazioni.",
              "error"
            );
          }
          break;
        case "c.removeGarante":
          if (result === true) {
            let garante = params.garanteId;
            // let payload = component.get("v.payload");
            // let joinGaranziaGarante = payload.joinGaranziaGarante;
            payload.joinGaranziaGarante = joinGaranziaGarante.filter((j) => {
              return j.garante != garante;
            });
            component.set("v.payload", payload);
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastSuccessTitle"),
              "Garante rimosso correttamente.",
              "success"
            );
            this.reloadGarantiEGaranzie(component);
          } else {
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
              "Non è stato possibile salvare correttamente le informazioni.",
              "error"
            );
          }
          break;
        case "c.updateNote":
        case "c.updateField":
        case "c.saveEventiNegativiInfo":
          this.reloadRecord(component);
          this.refreshWizard(component);

          if (result == null || this.isBlank(result))
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastSuccessTitle"),
              "Informazioni salvate correttamente.",
              "success"
            );
          else
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
              result,
              "error"
            );
          break;
        case "c.updatePresaVisione":
          this.reloadRecord(component);
          this.refreshWizard(component);
          break;
        case "c.gestisciCointestazione":
          console.log("c.gestisciCointestazione --result: ", result);
          if (result != null && result != "") {
            $A.createComponents(
              [
                [
                  "c:WGC_CreateCointestazioneModal_Body",
                  { processId: result, sObjectId: params.sObjectId }
                ],
                ["c:WGC_CreateCointestazioneModal_Footer", {}]
              ],
              function (content, status) {
                if (status === "SUCCESS") {
                  var modalBody = content[0];
                  var modalFooter = content[1];
                  component.find("overlayLib").showCustomModal({
                    header: "Seleziona Cointestazione",
                    body: modalBody,
                    footer: modalFooter,
                    showCloseButton: true,
                    cssClass: "slds-modal_medium"
                  });
                }
              }
            );
          } else
            this.showToast(
              component,
              "Nessuna Cointestazione trovata",
              "Non è stato possibile recuperare le cointestazioni associate.",
              "warning"
            );
          break;
        case "c.getObjectLabels":
          component.set("v.labels", result);
          break;
        case "c.getRevisionedParameters":
          this.unlockStateSpinner(component);
          this.hideSpinner(component);
          if (result.success) {
            component.set("v.payload", result.data);
          } else {
            console.log("PEF38 ERROR -- " + result.msg);
            // this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastErrorTitle"), result.msg, "error");

            component.find("notifLib").showNotice({
              variant: "error",
              header: $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
              message: $A.get("$Label.c.WGC_Cart_PEF38GenericError")
            });

            component.set("v.disableRevisionedLines", true);
            // this.showToast(component, $A.get("$Label.c.WGC_Cart_ToastErrorTitle"), $A.get("$Label.c.WGC_Cart_RevisionedParametersError"), "error");
          }
          break;
        case "c.changeOwner":
        case "c.updateLinesAfterClosing":
          component.find("overlayLib").notifyClose();
          window.open(location, "_self", "");
          break;
        case "c.saveDataFactFisc":
          console.log("saveDataFactFisc: ", result);
          if (result.success) {
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastSuccessTitle"),
              "I dati sono stati salvati senza errori.",
              "success"
            );
            component.set("v.payload", result.data);
            h.reloadRecord(component);
          } else
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
              result.msg,
              "error"
            );
          break;
        //SM - TEN: Banca Corporate
        case "c.saveCorporateLines":
          if (result.success) {
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastSuccessTitle"),
              "I dati sono stati salvati senza errori.",
              "success"
            );
            component.set("v.payload", result.data);
            h.reloadRecord(component);
            h.getSelectedProducts(component);
          } else {
            console.log("@@@ error ", result.msg);
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
              result.msg,
              "error"
            );
          }
          break;
        case "c.getCondizioniBC":
          console.log("@@@ result ", result);
          component.set("v.condizioniBC", result);
          break;
        //SM - TEN: Corporate Estero
        case "c.saveCorporateEstero":
          if (result.success) {
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastSuccessTitle"),
              "I dati sono stati salvati senza errori.",
              "success"
            );
            component.set("v.payload", result.data);
            h.reloadRecord(component);
            h.getSelectedProducts(component);
          } else {
            console.log("@@@ error ", result.msg);
            this.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
              result.msg,
              "error"
            );
          }
          break;
      }

      this.hideSpinner(component);
    }
  },

  // SYNCD TO GET PAYLOAD
  getDebitoriNewFields: function (component) {
    this.callServer(
      component,
      "c.getDebitoriNewFields",
      function (result) {
        var ret = [];

        result.forEach((r) => {
          // console.log(r);
          ret.push({
            debitore: r.FakeId__c,
            // tipologiaControparte: {
            //     pubblico: r.Tipologia_Controparte__c !== undefined ? r.Tipologia_Controparte__c.split(";").indexOf("Pubblico") >= 0 : false,
            //     privato: r.Tipologia_Controparte__c !== undefined ? r.Tipologia_Controparte__c.split(";").indexOf("Privato") >= 0 : false
            // },
            tipologiaFornitura: {
              beni:
                r.Tipologia_di_Fornitura__c !== undefined
                  ? r.Tipologia_di_Fornitura__c.split(";").indexOf("Beni") >= 0
                  : false,
              servizi:
                r.Tipologia_di_Fornitura__c !== undefined
                  ? r.Tipologia_di_Fornitura__c.split(";").indexOf("Servizi") >=
                    0
                  : false,
              altro:
                r.Tipologia_di_Fornitura__c !== undefined
                  ? r.Tipologia_di_Fornitura__c.split(";").indexOf("Altro") >= 0
                  : false
            },
            commessa: r.Commessa__c,
            appalto: r.Appalto_d_opera__c,
            mercato: r.WGC_Mercato__c,
            contropartePrivato: r.WGC_ContropartePrivato__c
          });
        });

        component.set("v.debitoriNewFields", ret);
        this.unlockStateSpinner(component);
        this.hideSpinner(component);
      },
      { opportunityId: component.get("v.opportunityId") }
    );
  },

  manageModal: function (component, event) {
    var params = event.getParams();

    if (params.action) {
      console.log("manageModal params: ", JSON.stringify(params));
      if (params.action == "close") component.find("overlayLib").notifyClose();
    } else {
      // IF preFunction IS NOT BLANK, CALL THE FUNCTION
      if (!this.isBlank(params.preFunction)) {
        this.showSpinner(component);
        this[params.preFunction](component, params);
      } else this.manageModalMethod(component, params);
    }
  },

  manageModalMethod: function (component, params) {
    // IF FOOTER IS BLANK, ...
    if (this.isBlank(params.modalFooter)) {
      console.log("params.modalBody.type: " + params.modalBody.type);
      // ... IF BODY TYPE IS COMPONENT, CREATE COMPONENT
      if (params.modalBody.type === "component")
        $A.createComponent(
          params.modalBody.value,
          params.modalBody.params,
          function (content, status) {
            if (status === "SUCCESS") {
              var modalBody = content;
              component.find("overlayLib").showCustomModal({
                header: params.modalHeader,
                body: modalBody,
                showCloseButton: params.showCloseButton,
                cssClass: params.cssClass
              });
            }
          }
        );
      // ELSE IF BODY TYPE IS TEXT, CREATE MODAL WITH TEXT
      else if (params.modalBody.type === "text")
        component.find("overlayLib").showCustomModal({
          header: params.modalHeader,
          body: params.modalBody.value,
          showCloseButton: params.showCloseButton,
          cssClass: params.cssClass
        });
    }

    // IF FOOTER IS NOT BLANK, ...
    else {
      // ... IF BODY TYPE IS COMPONENT, CREATE BOTH COMPONENTS
      if (params.modalBody.type === "component")
        $A.createComponents(
          [
            [params.modalBody.value, params.modalBody.params],
            [params.modalFooter.value, params.modalFooter.params]
          ],
          function (content, status) {
            if (status === "SUCCESS") {
              var modalBody = content[0];
              var modalFooter = content[1];
              component.find("overlayLib").showCustomModal({
                header: params.modalHeader,
                body: modalBody,
                footer: modalFooter,
                showCloseButton: params.showCloseButton,
                cssClass: params.cssClass
              });
            }
          }
        );
      // ELSE IF BODY TYPE IS TEXT, CREATE MODAL WITH TEXT
      else if (params.modalBody.type === "text")
        $A.createComponent(
          params.modalFooter.value,
          params.modalFooter.params,
          function (content, status) {
            if (status === "SUCCESS") {
              var modalFooter = content;
              component.find("overlayLib").showCustomModal({
                header: params.modalHeader,
                body: params.modalBody.value,
                footer: modalFooter,
                showCloseButton: params.showCloseButton,
                cssClass: params.cssClass
              });
            }
          }
        );
    }
  },

  editDebDataPreLoad: function (component, params) {
    var h = this;

    h.callServerSync(component, "c.getPicklistValues", {
      objectName: "NDGLinea__c",
      field_apiname: "PerfezionamentoAcquisto__c",
      nullRequired: true
    })
      .then(function (result) {
        if (result.length == 0) {
          h.showToast(
            component,
            "Oops! Qualcosa è andato storto..",
            "Errore nella creazione della modale.",
            "error"
          );
          h.hideSpinner(component);
        } else {
          params.modalBody.params.momentoPicklistValues = result;
          return h.callServerSync(component, "c.getQualificaDebitore", {
            debitore: params.modalBody.params.debitore.id
          });
        }
      })
      .then(function (result) {
        // else {
        params.modalBody.params.qualificaDebitore = result;
        // params.modalBody.params.momentoPicklistValues = result;
        // params.modalBody.params.labels = result;
        h.manageModalMethod(component, params);
        // }
        h.hideSpinner(component);
      });
  },

  // setupPicklistsDebitore : function(component, params) {
  //     var h = this;

  //     h.callServer(component, "c.getPicklistValues", function(result){
  //         if (result.length == 0)
  //             h.showToast(component, "Oops! Qualcosa è andato storto..", "Errore nella creazione della modale.", "error");
  //         else {
  //             params.modalBody.params.momentoPicklistValues = result;
  //             h.manageModalMethod(component, params);
  //         }
  //         h.hideSpinner(component);
  //     }, {
  //         objectName: "NDGLinea__c",
  //         field_apiname: "PerfezionamentoAcquisto__c",
  //         nullRequired: true
  //     });
  // },

  goBackToAccount: function (component, params) {
    var navService = component.find("navService");
    var pageReference = {
      type: "standard__navItemPage",
      attributes: {
        apiName: "Opportunit"
      }
    };
    // window.lasthash = "LASTHASH";
    navService.navigate(pageReference);
    // window.history.back();
    // window.history.back();
  },

  getPicklistOptions: function (component) {
    var h = this;

    this.callServerSync(component, "c.getPicklistValuesFromArray", {
      arrayFields: [
        "NDGLinea__c.DivisaNew__c",
        "NDGLinea__c.WGC_Mercato__c",
        "Prodotto__c.WGC_Area__c",
        "Opportunity.WGC_Tipologia_CrossSelling__c",
        "Opportunity.WGC_Business_CrossSelling__c",
        "Garanzia__c.DivisaNew__c",
        "Opportunity.Tipologia_Opportunit__c",
        "Opportunity.WGC_Tipologia_di_ristrutturazione_debito__c",
        "Linea__c.WGC_Tipo_di_garanzia__c"
      ]
    })
      .then(function (result) {
        console.log("getPicklistValuesFromArray: ", result);
        let picklistOptions = JSON.parse(result);
        let garanzieDivise = [];

        picklistOptions
          .find((po) => {
            return po.field == "Garanzia__c.DivisaNew__c";
          })
          .options.forEach((opt) => {
            garanzieDivise.push({
              label: opt.split(":")[1],
              value: opt.split(":")[0]
            });
          });

        component.set("v.garanzieDivise", garanzieDivise);
        component.set("v.picklistOptions", picklistOptions);

        return h.callServerSync(
          component,
          "c.getDependentPicklistValuesFromArray",
          {
            arrayFields: [
              {
                controller: "Prodotto__c.WGC_Bisogno__c",
                field: "Prodotto__c.WGC_Sottobisogno__c"
              }
            ]
          }
        );
      })
      .then(function (result) {
        // console.log("getDependentPicklistValuesFromArray: ", result);
        h.setupFilterBisogni(component, JSON.parse(result));
        h.setupFilterAree(component);
        //SM - TEN: Corporate Estero
        h.setupTipiGaranzieEstero(component);
      });
  },

  setupFilterAree: function (component) {
    let picklistOptions = component.get("v.picklistOptions");
    // let qualificaUtente = component.get("v.qualificaUtente");
    let qualificaUtente = component.get("v.opportunityRecord")
      ? component.get("v.opportunityRecord").Owner.Qualifica_Utente__c
      : "";
    let aree = picklistOptions.find((po) => {
      return po.field == "Prodotto__c.WGC_Area__c";
    }).options;

    if (qualificaUtente.includes("Leasing"))
      aree = aree.filter((a) => {
        return a != "Leasing";
      });

    component.set("v.aree", aree);
  },

  setupFilterBisogni: function (component, options) {
    let optionsMap = this.generateMap(
      this.generateMap(options).get("WGC_Bisogno__c|WGC_Sottobisogno__c")
    );
    let bisogni = [];
    let keys = optionsMap.keys();
    let next = keys.next();

    while (!next.done) {
      bisogni.push({
        label: next.value,
        sottobisogni: optionsMap.get(next.value)
      });
      next = keys.next();
    }

    component.set("v.bisogni", bisogni);
  },

  //SM - TEN: Corporate Estero
  setupTipiGaranzieEstero: function (component) {
    let picklistOptions = component.get("v.picklistOptions");
    let garanzie = picklistOptions.find((po) => {
      return po.field == "Linea__c.WGC_Tipo_di_garanzia__c";
    }).options;

    console.log("@@@ garanzie ", garanzie);
    component.set("v.picklistGaranzieEstero", garanzie);
  },

  changeFilter: function (component, event) {
    let productsFilters = component.get("v.productsFilters")
      ? JSON.parse(component.get("v.productsFilters"))
      : "";
    let filterTypeValue = component.get("v.filterTypeValue");
    let filterName = event
      ? event.getSource().get("v.name")
      : filterTypeValue == "all"
      ? "type|all"
      : "type|recent";
    let filterValue;

    // MANAGE OF DIFFERENT FILTERS (BUTTONGROUP AND BUTTONMENU)
    if (filterName.includes("|")) {
      let split = filterName.split("|");
      filterName = split[0];
      filterValue = split[1];
    } else filterValue = event.detail.menuItem.get("v.value");

    // GENERATION OF FILTERS ARRAY/JSON
    if (productsFilters == "")
      productsFilters = [{ filter: filterName, value: filterValue }];
    else {
      if (filterValue == "")
        productsFilters.splice(
          productsFilters.findIndex((pf) => {
            return pf.filter == filterName;
          }),
          1
        );
      else {
        if (
          productsFilters.find((pf) => {
            return pf.filter == filterName;
          }) == null
        )
          productsFilters.push({ filter: filterName, value: filterValue });
        else
          productsFilters.find((pf) => {
            return pf.filter == filterName;
          }).value = filterValue;
      }
    }

    component.set("v.productsFilters", JSON.stringify(productsFilters));
    if (filterName == "area") {
      // event.getSource().set("v.label", (filterValue ? filterValue : "Tutte"));
      component.set("v.areaLabel", filterValue ? filterValue : "Tutte");
    } else if (filterName == "type")
      component.set("v.filterTypeValue", filterValue);
  },

  confermaProdotti: function (component) {
    let selectedProducts = component.get("v.selectedProducts");
    let lockedProducts = component.get("v.lockedProducts");
    let allProducts = selectedProducts.concat(lockedProducts);
    let h = this;
    let hasFactFisc = allProducts.reduce((start, p) => {
      return start || p.area == "Factoring - Fiscale";
    }, false);
    //A.M. Gestione Famiglia Bonus Edilizi
    let BonusEdil = allProducts.reduce((start, p) => {
      return start || p.area == "Bonus Edilizi";
    }, false);
    console.log("@@@ BonusEdilizi: ", BonusEdil);
    //A.M. Gestione Mutuo Veneto Sviluppo
    let VenetoSviluppo = allProducts.reduce((start, p) => {return start || (p.codice != null && p.codice.startsWith("VenetoSviluppo"))}, false);
    this.showSpinner(component);
    this.callServerSync(component, "c.setProductInOpp", {
      opportunityId: component.get("v.opportunityId"),
      itemsProduct: JSON.stringify(selectedProducts)
    })
      .then(function (result) {
        console.log("SAVE PRODUCTS");
        let payload = component.get("v.payload");
        // let selectedCrossSellingProducts = allProducts.filter(i => {return i.tipoCrossSelling != component.get("v.opportunityRecord").RecordType.DeveloperName;});
        let crossSellingJSON = component.get("v.opportunityRecord")
          .WGC_Cross_Selling_JSON__c
          ? JSON.parse(
              component.get("v.opportunityRecord").WGC_Cross_Selling_JSON__c
            )
          : [];
        let csJSON2delete = [];

        console.log("allProducts: ", allProducts);
        // verifico la selezione di prodotti "Factoring" (NON CONFIRMING CEDENTE) per settare flag fd (in caso false, verranno eliminate le linee di Factoring)
        // //A.M. Aggiunta area Bonus Edilizi
        payload.fd = allProducts.reduce((start, i) => {
          return (
            (start ||
              i.area == "Factoring - Cedente" ||
              i.area == "Factoring - Fiscale" ||
              i.area == "Bonus Edilizi") &&
            i.codice != "AtdConProrogaConfirming"
          );
        }, false);
        // verifico la selezione di prodotti "Bancari" (Mutui/Finanziamenti) per settare nodo "pb" (in caso non siano selezionati, verranno elminati se già configurati)
        if ( !allProducts.reduce((start, i) => { return start || i.area == "Servizi Bancari";}, false)){
          //A.M. Gestione Mutuo Veneto Sviluppo
          if (VenetoSviluppo){
            payload.pb = payload.pb.filter(pb => {return pb.tipo.startsWith("VenetoSviluppo");}); 
          } else {    
            payload.pb = payload.pb.filter(pb => {return pb.tipo.startsWith("Mutuo");}); 
          }
        }
        if ( !allProducts.reduce((start, i) => { return start || i.area == "Finanziamenti";}, false)){
          //A.M. Gestione Mutuo Veneto Sviluppo
          if (VenetoSviluppo){
            payload.pb = payload.pb.filter(pb => {return pb.tipo.startsWith("VenetoSviluppo");}); 
          } else {
            payload.pb = payload.pb.filter(pb => {return !pb.tipo.startsWith("Mutuo");}); 
          }
        }
        //A.M. Gestione Mutuo Veneto Sviluppo
        if (!VenetoSviluppo){
          payload.pb = payload.pb.filter(pb => {return pb.tipo != "Fido";}).filter(pb => {return pb.tipo.startsWith("Mutuo") || allProducts.map(p => {return p.codice;}).includes(pb.tipo) || allProducts.map(p => {return p.codice + "NonAffidato";}).includes(pb.tipo);});  
        } else {
          payload.pb = payload.pb.filter(pb => {return pb.tipo != "Fido";}).filter(pb => {return pb.tipo.startsWith("VenetoSviluppo") || allProducts.map(p => {return p.codice;}).includes(pb.tipo) || allProducts.map(p => {return p.codice + "NonAffidato";}).includes(pb.tipo);});
        }
        // verifico la presenza del prodotto "Plafond" o "Plafond Maturity"
        // payload.pfi = (allProducts.reduce((start, i) => {return start || i.codice == "Standard" || i.codice == "ConProroga";}, false) ? payload.pfi : []);
        payload.pfi = payload.pfi.filter((pfi) => {
          return allProducts
            .map((i) => {
              return i.codice;
            })
            .includes(pfi.tipo);
        });
        // verifico la selezione del prodotto "Confirming" per settare il flag "confirming" a true
        payload.confirming = allProducts
          .filter((i) => {
            return !h.isBlank(i.codice);
          })
          .reduce((start, i) => {
            return start || i.codice.includes("Confirming");
          }, false);
        // verifico le selezioni dei prodotti "Cross Selling" per ripulire il campo in cui salviamo il JSON
        crossSellingJSON.forEach((cs) => {
          if (
            !allProducts
              .map((s) => {
                return s.area + "_" + s.name;
              })
              .includes(cs.product)
          )
            csJSON2delete.push(cs.product);
        });
        crossSellingJSON = crossSellingJSON.filter((cs) => {
          return !csJSON2delete.includes(cs.product);
        });
        if (
          component.get("v.opportunityRecord").WGC_Cross_Selling_JSON__c !=
          JSON.stringify(crossSellingJSON)
        )
          h.callServer(component, "c.saveCrossSellingJSON", function (res) {}, {
            opportunityId: component.get("v.opportunityId"),
            crossSellingJSON: JSON.stringify(crossSellingJSON)
          });
        // console.log("payload: ", JSON.stringify(payload));
        payload.valutazioniPortafoglio.forEach((vp) => {
          for (let key in vp)
            if (vp[key] == "true" || vp[key] == "false")
              vp[key] = vp[key] == "true";
        });
        // return null;
        payload.factfisc = hasFactFisc;
        //A.M. Bonus Edilizi
        payload.BonusEdil = BonusEdil;
        //SM - Banca Corporate

        return h.callServerSync(component, "c.saveWizard", {
          payload: JSON.stringify(payload),
          step: "categorie"
        });
      })
      .then(function (result) {
        if (result.success == true) {
          let needConfiguration = false;
          // let oldSPConcat = component.get("v.opportunityRecord").WGC_Prodotti_Selezionati__c;
          // let newSPConcat = selectedProducts.reduce((start, sp) => {return start == "" ? sp.name : start+";"+sp.name;}, "");
          let oldSPConcat = component.get("v.opportunityRecord")
            .WGC_Prodotti_Selezionati__c
            ? component
                .get("v.opportunityRecord")
                .WGC_Prodotti_Selezionati__c.split(";")
            : [];
          let newSPConcat = selectedProducts.map((sp) => {
            return sp.name;
          });

          // if (oldSPConcat.toLowerCase() != newSPConcat.toLowerCase()) // SE SELEZIONE PRODOTTI MODIFICATA, ALLORA VA SETTATO A FALSE IL FLAG DI COMPLETAMENTO CONFIGURAZIONE PRODOTTI
          if (
            oldSPConcat.length != newSPConcat.length ||
            newSPConcat.reduce((start, sp) => {
              return (
                start &&
                oldSPConcat.find((osp) => {
                  return osp == sp;
                })
              );
            }, true) == false
          )
            // SE SELEZIONE PRODOTTI MODIFICATA, ALLORA VA SETTATO A FALSE IL FLAG DI COMPLETAMENTO CONFIGURAZIONE PRODOTTI
            needConfiguration = true;

          component.set("v.payload", result.data);

          if (needConfiguration) {
            return h.callServerSync(component, "c.updateField", {
              field: "WGC_Configurazione_Prodotti_Completa__c",
              value: false,
              objectId: component.get("v.opportunityId")
            });
          } else {
            h.updateWizard(component, "inserimentoDebitori");
            h.reloadRecord(component);
            h.refreshWizard(component);
            h.hideSpinner(component);
          }
        } else {
          h.showToast(
            component,
            $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
            result.msg,
            "error"
          );
        }
      })
      .then(function (result) {
        if (result != null)
          h.showToast(
            component,
            $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
            result,
            "error"
          );
        else {
          h.updateWizard(component, "inserimentoDebitori");
          h.reloadRecord(component);
          h.refreshWizard(component);
          h.hideSpinner(component);
        }
      });
  },

  invioNuovaVendita: function (component) {
    var opportunityId = component.get("v.opportunityId");
    var accountId = component.get("v.opportunityRecord").AccountId;
    var h = this;
    let confirmChangeSpecialista = true;
    var checkInvioMailEstero = false;

    if (component.get("v.isCurrentUserSpecialista") == false)
      confirmChangeSpecialista = confirm(
        $A.get("$Label.c.WGC_Cart_ConfirmSpecialistChange")
      );

    if (confirmChangeSpecialista === true) {
      this.showSpinner(
        component,
        "Verifica completezza anagrafica..."
      );

      this.callServerSync(component, "c.checkCensimentoAnag", {
        accountId: accountId
      }).then(result => {
          if(result == null){
            this.showSpinner(
              component,
              "Validazione informazioni Privacy Esecutore..."
            );

            return this.callServerSync(component, "c.invioPrivacyPF", {
              opportunityId: opportunityId
            })
          } else {
            return "Censire l'anagrafica in maniera completa prima di inviare la pratica";
          }
      })
      // this.showSpinner(
      //   component,
      //   "Validazione informazioni Privacy Esecutore..."
      // );
      // this.callServerSync(component, "c.invioPrivacyPF", {
      //   opportunityId: opportunityId
      // })
        .then((result) => {
          console.log("@@@ result ", result);
          if (result == null || result == undefined || result == "") {
            this.showSpinner(
              component,
              "Validazione informazioni opportunità..."
            );
            return h.callServerSync(component, "c.validateInfoOpportunity", {
              opportunityId: opportunityId
            });
          } else {
            // h.showToast(component, $A.get("$Label.c.WGC_Cart_ToastErrorTitle"), result, "error");
            // return "errore";
            console.log("@@@ errore ");
            return result;
          }
        })
        .then(function (result) {
          console.log("validateInfoOpportunity: ", result);
          if (result != "") {
            // opportunità non correttamente configurata
            h.hideSpinner(component);
            h.showToast(
              component,
              $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
              result,
              "warning"
            );
          } else {
            component.set(
              "v.spinnerMessage",
              "Verifica validità Titolari ed Esecutore..."
            );
            return h.callServerSync(component, "c.checkTitolariEsecutore", {
              accountId: accountId,
              opportunityId: opportunityId
            });
          }
        })
        .then(function (result) {
          if (result !== undefined) {
            console.log("checkTitolariEsecutore: ", result);
            if (result != "") {
              // titolari o esecutore non validi
              h.hideSpinner(component);
              h.showToast(
                component,
                $A.get("$Label.c.WGC_Cart_ToastWarningTitle"),
                result,
                "warning"
              );
            } else {
              component.set(
                "v.spinnerMessage",
                "Verifica validità Privacy Esecutore..."
              );
              return h.callServerSync(component, "c.privacyEsecutoreFirmata", {
                accountId: accountId
              });
            }
          }
        })
        .then(function (result) {
          if (result !== undefined) {
            console.log("privacyEsecutoreFirmata: ", result);
            if (result == false) {
              // privacy esecutore non firmata
              h.hideSpinner(component);
              h.showToast(
                component,
                $A.get("$Label.c.WGC_Cart_ToastWarningTitle"),
                $A.get("$Label.c.WGC_Cart_PrivacyEsecutoreNonFirmata"),
                "warning"
              );
            } else {
              component.set("v.spinnerMessage", "Controllo esistenza PEF...");
              return h.callServerSync(component, "c.esistePef", {
                oppId: opportunityId
              });
            }
          }
        })
        .then(function (result) {
          if (result !== undefined) {
            console.log("esistePef: ", result);
            if (result === true) {
              // esiste già una PEF
              h.hideSpinner(component);
              h.showToast(
                component,
                $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
                $A.get("$Label.c.WGC_Cart_EsistePEFAttiva"),
                "error"
              );
            } else {
              // component.set("v.spinnerMessage", "Invio in Valutazione in corso...");
              // return h.callServerSync(component, "c.inviaNuovaVendita", { oppId: opportunityId });
              // component.set("v.spinnerMessage", "Aggiornamento stato opportunità...");
              // return h.callServerSync(component, "c.cambiaInnescoOpportunita", { oppId: opportunityId });
              component.set(
                "v.spinnerMessage",
                "Associazione responsabili in corso..."
              );
              return h.callServerSync(component, "c.associaResponsabili", {
                accountId: accountId,
                opportunityRecordType: component.get("v.opportunityRecord")
                  .RecordType.DeveloperName
              });
            }
          }
        })
        .then(function (result) {
          if (result !== undefined) {
            console.log("associaResponsabili: ", result);
            if (result !== "") {
              // errore nell'associazione responsabili
              h.hideSpinner(component);
              h.showToast(
                component,
                $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
                "ERRORE NELL'ASSOCIAZIONE DEI RESPONSABILI: " + result,
                "error"
              );
            } else {
              //TODO Inserire controllo Corporate Estero - Controllo per mandare solo mail, oppure fare anche l'invio a nuova vendita
              let allLines = component.get("v.payload.linee");
              let checkLineeMailBCE = component
                .get("v.payload.linee")
                .filter((l) => {
                  return (
                    l.codice == "CreditoDocumentarioExport" ||
                    l.codice == "DocumentateIncasso"
                  );
                }).length;
              let checkProdottiEstero =
                component.get("v.payload.pbce").length > 0;

              // if(checkLineeMailBCE == 0){ //Solo NV
              //     component.set("v.spinnerMessage", $A.get("$Label.c.WGC_Cart_SpinnerMessage_InviaNuovaVendita"));
              //     return h.callServerSync(component, "c.inviaNuovaVendita", { oppId: opportunityId });
              // } else if(checkLineeMailBCE == allLines.length){ //Casistica solo mail no NV
              //     h.callServer(component, "c.updateField", function(result){
              //         console.log('@@@ result mail BCE ', result);
              //     }, {field : "WGC_Invio_Mail_Corporate_Estero__c", value: true, objectId: component.get("v.opportunityId")});
              //     // checkInvioMail = true;

              //     h.callServer(component, "c.updateField", function(result) {
              //         // return undefined;
              //     }, {field: 'StageName', value: 'Valutazione Pratica', objectId: component.get("v.opportunityId")});
              // } else if(checkLineeMailBCE > 0 && allLines.length != checkLineeMailBCE){ //Casistica NV + mail
              //     // h.callServer(component, "c.updateField", function(result){
              //     //     console.log('@@@ result mail BCE ', result);
              //     // }, {field : "WGC_Invio_Mail_Corporate_Estero__c", value: true, objectId: component.get("v.opportunityId")});
              //     checkInvioMailEstero = true;

              //     return h.callServerSync(component, "c.inviaNuovaVendita", { oppId: opportunityId });
              // }
              // component.set("v.spinnerMessage", "Aggiornamento stato opportunità...");
              // return h.callServerSync(component, "c.cambiaInnescoOpportunita", { oppId: opportunityId });

              if (checkLineeMailBCE.length == allLines.length) {
                h.callServer(
                  component,
                  "c.updateField",
                  function (result) {
                    console.log("@@@ result mail BCE ", result);
                  },
                  {
                    field: "WGC_Invio_Mail_Corporate_Estero__c",
                    value: true,
                    objectId: component.get("v.opportunityId")
                  }
                );

                h.callServer(
                  component,
                  "c.updateField",
                  function (result) {
                    // return undefined;
                  },
                  {
                    field: "StageName",
                    value: "Valutazione Pratica",
                    objectId: component.get("v.opportunityId")
                  }
                );
              } else {
                if (checkProdottiEstero) checkInvioMailEstero = true;

                component.set(
                  "v.spinnerMessage",
                  $A.get("$Label.c.WGC_Cart_SpinnerMessage_InviaNuovaVendita")
                );
                return h.callServerSync(component, "c.inviaNuovaVendita", {
                  oppId: opportunityId
                });
              }
            }
          }
        })
        .then(function (result) {
          if (result !== undefined) {
            console.log("inviaNuovaVendita: ", result);
            if (result != null) {
              // innesco opportunità
              h.hideSpinner(component);
              h.showToast(
                component,
                $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
                "ERRORE NELL'INVIO DELLA PRATICA: " + result,
                "error"
              );
            } else {
              component.set("v.spinnerMessage", "Invio Documenti in corso...");
              return h.callServerSync(
                component,
                "c.invioDocumentiNuovaVendita",
                { opportunityId: opportunityId, accountId: accountId }
              );
            }
          }
        })
        .then(function (result) {
          if (result !== undefined) {
            // h.hideSpinner(component);
            console.log("invioDocumentiNuovaVendita: ", result);
            if (result != "") {
              // esiste già una PEF
              h.hideSpinner(component);
              h.showToast(
                component,
                $A.get("$Label.c.WGC_Cart_ToastWarningTitle"),
                "ERRORE NELL'INVIO DOCUMENTI: " + result,
                "warning"
              );
            } else {
              if (checkInvioMailEstero) {
                h.callServer(
                  component,
                  "c.updateField",
                  function (result) {
                    console.log("@@@ result mail BCE ", result);
                  },
                  {
                    field: "WGC_Invio_Mail_Corporate_Estero__c",
                    value: true,
                    objectId: component.get("v.opportunityId")
                  }
                );
              }

              h.hideSpinner(component);
              h.showToast(
                component,
                $A.get("$Label.c.WGC_Cart_ToastSuccessTitle"),
                $A.get("$Label.c.WGC_Cart_InvioNVInviatoCorrettamente"),
                "success"
              ); // Invio a nuova vendita effettuato correttamente
              // return h.callServerSync(component, "c.esisteTitolareEffettivo", { oppId: opportunityId });
            }
            return result;
          }
        })
        .then((result) => {
          console.log("@@@ final result ", result);
          // if(result !== undefined && result != ""){
          h.reloadRecord(component);
          h.refreshWizard(component);
          // }
        });
      // .then(function(result){
      //     if (result !== undefined) {
      //         if (result !== undefined) {
      //             // h.hideSpinner(component);
      //             console.log("esisteTitolareEffettivo: ", result);
      //             if (result === true) { // esiste titolare effettivo
      //                 h.hideSpinner(component);
      //             }
      //             else {
      //                 h.hideSpinner(component);
      //                 h.showToast(component, $A.get("$Label.c.WGC_Cart_ToastWarningTitle"), $A.get("$Label.c.WGC_Cart_NonEsisteTitolareEffettivo"), "warning"); // Attenzione: la rete informativa relativa al titolare effettivo, se presente, deve essere cancellata in Cedacri
      //             }
      //         }
      //     }
      // });
    }
  },

  closeOpportunityModal: function (component) {
    $A.createComponent(
      "c:WGC_Cart_CloseOpportunity",
      { opportunityId: component.get("v.opportunityId") },
      function (content, status) {
        if (status === "SUCCESS") {
          var modalBody = content;
          component.find("overlayLib").showCustomModal({
            header: "Chiudi Opportunità",
            body: modalBody,
            showCloseButton: true,
            cssClass: ""
          });
        }
      }
    );
  },

  deleteOpportunity: function (component) {
    let opportunityId = component.get("v.opportunityId");

    this.showSpinner(component);
    var h = this;

    this.callServer(
      component,
      "c.manageDeleteOpportunity",
      function (result) {
        h.hideSpinner(component);
        h.goBackToAccount(component, event);
      },
      {
        opportunityId: opportunityId
      }
    );
  },

  setupHeader: function (component) {
    this.callServer(
      component,
      "c.getTitolariEsecutori",
      function (result) {
        let titeff = [];
        let esec = [];

        result.titeff.forEach((t) => {
          titeff.push({
            name: t.Contact.Name,
            valid: t.Contact.WGC_Censimento_MAV__c != "Parziale"
          });
        });

        result.esec.forEach((t) => {
          esec.push({
            name: t.Contact.Name,
            valid: t.Contact.WGC_Censimento_MAV__c != "Parziale"
          });
        });

        component.set("v.titolariEffettivi", titeff);
        component.set("v.esecutori", esec);
      },
      { accountId: component.get("v.opportunityRecord").AccountId }
    );
  },

  checkInviaBtnAvailability: function (component, event) {
    let wizardItems = event
      ? event.getParam("value")
      : component.get("v.wizardItems");

    if (wizardItems)
      component.set(
        "v.invioInValutazioneValido",
        wizardItems
          .filter((wi) => {
            return wi.visible;
          })
          .reduce((start, wi) => {
            return wi.completed && start;
          }, true)
      );
  },

  // DEPRECATED
  getQualificaUtente: function (component) {
    this.callServer(
      component,
      "c.getUserInfo",
      function (result) {
        component.set("v.qualificaUtente", result.Qualifica_Utente__c);
      },
      {}
    );
  },

  checkRSF: function (component) {
    // if (component.get("v.opportunityRecord") != null) {
    this.callServer(
      component,
      "c.docCheckListOpportunity",
      function (result) {
        console.log("docCheckListOpportunity: ", result);
        let checkResponse = JSON.parse(result);
        let scadenza = checkResponse.scadenzaRSF
          ? new Date(
              checkResponse.scadenzaRSF.substring(4, 8),
              parseInt(checkResponse.scadenzaRSF.substring(2, 4)) - 1,
              checkResponse.scadenzaRSF.substring(0, 2)
            ).toLocaleDateString("it-IT", {
              year: "numeric",
              month: "2-digit",
              day: "2-digit"
            })
          : null;

        component.set("v.datiDoc", checkResponse.datiDoc);
        component.set("v.validRSF", checkResponse.validRSF);
        component.set(
          "v.docIdRSF",
          checkResponse.docIdRSF ? checkResponse.docIdRSF : ""
        );
        // component.set("v.validPrivacy", checkResponse.validPrivacy);
        component.set("v.scadenzaRSF", scadenza);
        if (checkResponse.fileNameRSF)
          component.set("v.fileNameRSF", checkResponse.fileNameRSF);

        if (checkResponse.validRSF && checkResponse.validPrivacy)
          this.callServer(
            component,
            "c.richiestaPrimaInfoCR",
            function (result) {
              console.log("richiestaPrimaInfoCR --OK");
            },
            {
              opportunityId: component.get("v.opportunityId"),
              target: "cedente"
            }
          );
      },
      { opportunityId: component.get("v.opportunityId") }
    );
    // }
  },

  checkPrivacy: function (component) {
    if (component.get("v.opportunityRecord") != null) {
      this.callServer(
        component,
        "c.docCheckListAccount",
        function (result) {
          console.log("docCheckListAccount: ", result);
          let checkResponse = JSON.parse(result);

          component.set("v.validPrivacy", checkResponse.validPrivacy);

          if (component.get("v.validRSF") && checkResponse.validPrivacy)
            this.callServer(
              component,
              "c.richiestaPrimaInfoCR",
              function (result) {
                console.log("richiestaPrimaInfoCR --OK");
              },
              {
                opportunityId: component.get("v.opportunityId"),
                target: "cedente"
              }
            );
        },
        { accountId: component.get("v.opportunityRecord").AccountId }
      );
    }
  },

  openModalLanguage: function (component, helper) {
    console.log("@@@ open modal language");
    $A.createComponent(
      "c:WGC_SceltaLinguaDocumenti",
      {
        modalBodyAttributeName: component.getReference("v.linguaSelezionata"),
        isRSF: true
      },
      function (content, status, error) {
        if (status === "SUCCESS") {
          component.find("overlayLib").showCustomModal({
            header: "Scelta lingua",
            body: content,
            showCloseButton: false,
            cssClass: "slds-modal_medium",
            closeCallback: function () {
              console.log("@@@ test");
              var linguaScelta = component.get("v.linguaSelezionata");
              console.log("@@@ linguaScelta ", linguaScelta);

              if (linguaScelta != "ANNULLA") {
                helper.generaRSF(component);
              }
            }
          });
        } else {
          console.log("@@@ error ", error);
        }
      }
    );
  },

  generaRSF: function (component) {
    let h = this;
    // let accountId = component.get("v.opportunityRecord").AccountId;
    let downloadDoc = {
      id: component.get("v.docIdRSF"),
      title: $A.get("$Label.c.WGC_ModuloRichiestaServiziFinanziari"),
      codId: "ServiziFinanziari"
    };

    this.showSpinner(component);
    this.callServer(
      component,
      "c.doc11",
      function (result) {
        console.log("doc11: ", result);
        h.hideSpinner(component);

        if (result.success == false)
          h.showToast(
            component,
            $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
            result.message,
            "error"
          );
        else {
          // base64 string
          var base64 = result.data[0];

          // decode base64 string, remove space for IE compatibility
          var binary = atob(base64.replace(/\s/g, ""));
          var len = binary.length;
          var buffer = new ArrayBuffer(len);
          var view = new Uint8Array(buffer);
          for (var i = 0; i < len; i++) {
            view[i] = binary.charCodeAt(i);
          }
          var blob = new Blob([view], { type: "application/octet-stream" });
          //var blob = new Blob( [view]);
          var url = URL.createObjectURL(blob);

          var a = document.createElement("a");
          document.body.appendChild(a);
          a.style = "display: none";
          a.href = url;
          a.download = downloadDoc.title + ".pdf";
          a.click();

          //Aggiungo il bordo blu dopo il download
        }
      },
      {
        recordId: component.get("v.opportunityId"),
        codiceModulo: "ServiziFinanziari",
        nomeFile: $A.get("$Label.c.WGC_ModuloRichiestaServiziFinanziari"),
        language: component.get("v.linguaSelezionata")
      }
    );
  },

  downloadRSF: function (component) {
    let h = this;
    let fileNameRSF = component.get("v.fileNameRSF");
    let accountId = component.get("v.opportunityRecord").AccountId;
    let downloadDoc = {
      id: component.get("v.docIdRSF"),
      title: $A.get("$Label.c.WGC_ModuloRichiestaServiziFinanziari"),
      codId: "ServiziFinanziari"
    };

    this.showSpinner(component);
    this.callServer(
      component,
      "c.doc08",
      function (result) {
        console.log("doc08: ", result);
        h.hideSpinner(component);

        if (result.success == false)
          h.showToast(
            component,
            $A.get("$Label.c.WGC_Cart_ToastErrorTitle"),
            result.message,
            "error"
          );
        else {
          // base64 string
          var base64 = result.data[0];

          // decode base64 string, remove space for IE compatibility
          var binary = atob(base64.replace(/\s/g, ""));
          var len = binary.length;
          var buffer = new ArrayBuffer(len);
          var view = new Uint8Array(buffer);
          for (var i = 0; i < len; i++) {
            view[i] = binary.charCodeAt(i);
          }
          var blob = new Blob([view], { type: "application/octet-stream" });
          //var blob = new Blob( [view]);
          var url = URL.createObjectURL(blob);

          var a = document.createElement("a");
          document.body.appendChild(a);
          a.style = "display: none";
          a.href = url;
          // a.download = downloadDoc.title + "." + fileNameRSF;
          a.download = fileNameRSF;
          a.click();

          //Aggiungo il bordo blu dopo il download
        }
      },
      {
        accountId: component.get("v.opportunityId"),
        document: JSON.stringify(downloadDoc)
      }
    );
  },

  uploadRSF: function (component) {
    let h = this;
    $A.createComponent(
      "c:WGC_FileUploader",
      {
        datiDoc: component.get("v.datiDoc"),
        recordId: component.get("v.opportunityRecord").AccountId,
        optyId: component.get("v.opportunityId")
      },
      function (content, status) {
        if (status === "SUCCESS") {
          var modalBody = content;
          component.find("overlayLib").showCustomModal({
            header: "Upload RSF",
            body: modalBody,
            showCloseButton: true,
            cssClass: "",
            closeCallback: function (result) {
              // h.checkRSF(component);
            }
          });
        }
      }
    );
  },

  loadBilancioCedente: function (component) {
    this.callServer(
      component,
      "c.getBilancioCedente",
      function (result) {
        if (result) component.set("v.bilancio", result);
      },
      { opportunityId: component.get("v.opportunityId") }
    );
  },

  refreshTipoOpportunita: function (component) {
    let opp = component.get("v.opportunityRecord");
    let picklistOptions = component.get("v.picklistOptions");
    let tipologiaOppLabel = picklistOptions
      .find((po) => {
        return po.field == "Opportunity.Tipologia_Opportunit__c";
      })
      .options.find((opt) => {
        return opt.split(":")[0] == opp.Tipologia_Opportunit__c;
      })
      .split(":")[1];

    component.set("v.isRevisione", opp.Tipologia_Opportunit__c == "REVI");
    component.set("v.isRinnovo", opp.Tipologia_Opportunit__c == "RINN");
    component.set("v.tipologiaOppLabel", tipologiaOppLabel);
  },

  setupLockedProducts: function (component) {
    let opp = component.get("v.opportunityRecord");
    let lockedProducts = [];
    let listLocked =
      opp.WGC_Prodotti_bloccati__c == undefined
        ? []
        : opp.WGC_Prodotti_bloccati__c.split(";");
    let listAllProduct = component.get("v.products");

    listAllProduct.forEach(function (element) {
      if (listLocked.indexOf(element.name) != -1) {
        lockedProducts.push(element);
      }
    });

    component.set("v.lockedProducts", lockedProducts);
  },

  updateAllDocValid: function (component, event) {
    let isAllDocValid = event.getParam("value");
    let h = this;

    // this.callServer(component, "c.updateNote", function(result){
    this.callServer(
      component,
      "c.updateField",
      function (result) {
        if (!result) {
          component.set("v.isAllDocValid", isAllDocValid);
          h.reloadRecord(component);
          h.refreshWizard(component);
        }
      },
      {
        field: "WGC_Documenti_validi__c",
        value: isAllDocValid,
        objectId: component.get("v.opportunityId")
      }
    );
  },

  refreshWizardItemsVisibility: function (
    isRevisione,
    isRinnovo,
    mainWizardItems,
    wizardItems,
    component
  ) {
    let alreadyReloaded = component.get("v.alreadyReloaded");
    console.log("alreadyReloaded: ", alreadyReloaded);
    console.log("mainWizardItems: ", mainWizardItems);
    // console.log("isRinnovo: ", isRinnovo);
    wizardItems.find((wi) => {
      return wi.step == "analisiCliente";
    }).visible = isRevisione || isRinnovo;
    if (
      !alreadyReloaded &&
      isRinnovo &&
      wizardItems.find((wi) => {
        return wi.active;
      }).step == "sceltaProdotto"
    ) {
      wizardItems.find((wi) => {
        return wi.active;
      }).active = false;
      wizardItems.find((wi) => {
        return wi.step == "sceltaProdotto";
      }).visible = false;
      // wizardItems.find(wi => {return wi.step == "configuraProdotto";}).completed = true;
      this.setWizItemCompleted(
        wizardItems.find((wi) => {
          return wi.step == "configuraProdotto";
        }),
        true
      );
      wizardItems.find((wi) => {
        return wi.step == "configuraProdotto";
      }).disabled = true;
      wizardItems.find((wi) => {
        return wi.step == "analisiCliente";
      }).active = true;
      mainWizardItems.forEach((mwi) => {
        mwi.visible = mwi.visibleFor.split(",").includes("rinnovo");
      });
      console.log("RESET STEP");
      component.set(
        "v.step",
        wizardItems.find((wi) => {
          return wi.active;
        }).step
      );
      component.set("v.alreadyReloaded", true);
    }
  },

  updateRSF: function (component, event) {
    let datiDoc = component.get("v.datiDoc");
    let uploadedDoc = event.getParam("param");
    // console.log("uploadedDoc: ", JSON.stringify(uploadedDoc));
    if (datiDoc == uploadedDoc.index_value) {
      // let scadenza = new Date(
      //     uploadedDoc.dataScadenza.substring(4, 8),
      //     uploadedDoc.dataScadenza.substring(2, 4),
      //     uploadedDoc.dataScadenza.substring(0, 2)
      // );

      component.set("v.docIdRSF", uploadedDoc.id);
      component.set("v.scadenzaRSF", uploadedDoc.dataScadenza);
      component.set("v.validRSF", uploadedDoc.dataScadenza < new Date());
    }

    this.callServer(
      component,
      "c.docCheckListOpportunity",
      function (result) {
        console.log("checkRSF: ", result);
        let checkResponse = JSON.parse(result);
        let scadenza = checkResponse.scadenzaRSF
          ? new Date(
              checkResponse.scadenzaRSF.substring(4, 8),
              parseInt(checkResponse.scadenzaRSF.substring(2, 4)) - 1,
              checkResponse.scadenzaRSF.substring(0, 2)
            ).toLocaleDateString("it-IT", {
              year: "numeric",
              month: "2-digit",
              day: "2-digit"
            })
          : null;

        component.set("v.datiDoc", checkResponse.datiDoc);
        component.set("v.validRSF", checkResponse.validRSF);
        component.set(
          "v.docIdRSF",
          checkResponse.docIdRSF ? checkResponse.docIdRSF : ""
        );
        component.set("v.validPrivacy", checkResponse.validPrivacy);
        component.set("v.scadenzaRSF", scadenza);
        if (checkResponse.fileNameRSF)
          component.set("v.fileNameRSF", checkResponse.fileNameRSF);

        if (checkResponse.validRSF) {
          this.callServer(
            component,
            "c.richiestaPrimaInfoCR",
            function (result) {
              console.log("richiestaPrimaInfoCR --OK");
            },
            {
              opportunityId: component.get("v.opportunityId"),
              target: "debitori"
            }
          );
          if (checkResponse.validPrivacy) {
            this.callServer(
              component,
              "c.richiestaPrimaInfoCR",
              function (result) {
                console.log("richiestaPrimaInfoCR --OK");
              },
              {
                opportunityId: component.get("v.opportunityId"),
                target: "cedente"
              }
            );
          }
        }
      },
      { opportunityId: component.get("v.opportunityId") }
    );
  },

  getCodiciCoppia: function (component) {
    let opportunityId = component.get("v.opportunityId");
    let h = this;

    // this.callServer(component, "c.updateNote", function(result){
    this.callServer(
      component,
      "c.getCodiciCoppia",
      function (result) {
        let codiciCoppia = [];

        result.forEach((r) => {
          codiciCoppia.push({
            debitore: r.Debitore__r.FakeId__c,
            servizio: r.Linea__r.Prodotto__r.WGC_Famiglia__c,
            linea: r.Linea__c,
            codiceCoppia: r.WGC_Codice_Random_Coppia__c,
            codTipoCar: r.WGC_Cod_Tipo_Car__c
          });
        });

        component.set("v.codiciCoppia", codiciCoppia);
      },
      {
        opportunityId: opportunityId
      }
    );
  },

  checkExistingPlafond: function (component) {
    let opportunityId = component.get("v.opportunityId");
    // let h = this;

    this.callServer(
      component,
      "c.checkExistingPlafond",
      function (result) {
        component.set("v.existingPlafond", result);
      },
      {
        opportunityId: opportunityId
      }
    );
  },

  clickMainWizardItem: function (component, event) {
    let mainWizardItems = component.get("v.mainWizardItems");
    console.log(
      "event.currentTarget.attributes: ",
      JSON.stringify(event.currentTarget.attributes)
    );
    console.log(
      "event.currentTarget.getAttribute(): ",
      event.currentTarget.getAttribute("data-name")
    );
    mainWizardItems.forEach((mwi) => {
      if (mwi.title == event.currentTarget.getAttribute("data-name")) {
        mwi.active = true;
      } else if (mwi.clickable) {
        mwi.active = false;
      }
    });

    this.setActivePhase(component, mainWizardItems);
    component.set("v.mainWizardItems", mainWizardItems);
  },

  setActivePhase: function (component, mainWizardItems) {
    let activePhase;

    if (
      mainWizardItems.find((mwi) => {
        return mwi.active;
      }) !== undefined
    )
      activePhase = mainWizardItems.find((mwi) => {
        return mwi.active;
      }).phase;

    component.set("v.activePhase", activePhase);
  },

  setReadOnly: function (component) {
    let opportunityRecord = component.get("v.opportunityRecord");
    let readOnly = component.get("v.readOnly");

    if (readOnly !== true)
      component.set(
        "v.readOnly",
        opportunityRecord.StageName != "In Istruttoria" &&
          opportunityRecord.StageName != "Rinnovo"
      );
  },

  checkOwnership: function (component) {
    let opportunityId = component.get("v.opportunityId");

    this.callServer(
      component,
      "c.checkOwnership",
      function (result) {
        component.set("v.readOnly", !result);
      },
      { opportunityId: opportunityId }
    );
  },

  checkIfClosable: function (component) {
    let opportunityId = component.get("v.opportunityId");

    this.callServer(
      component,
      "c.checkIfClosable",
      function (result) {
        component.set("v.ifClosable", result);
      },
      { opportunityId: opportunityId }
    );
  },

  //CR Lotto 4.2 Id 315
  checkEsclusione: function (component) {
    let opportunityRecord = component.get("v.opportunityRecord");

    this.callServer(
      component,
      "c.getEsclusione",
      function (result) {
        if (result != null) {
          component.set("v.esclusioneBEI", result.esclusioneBEI);
          component.set("v.esclusionePolizzaCPI", result.esclusionePolizzaCPI);
        }
      },
      { ateco: opportunityRecord.Account.Ateco__c }
    );
  },

  assignToModal: function (component) {
    $A.createComponent(
      "c:WGC_Cart_AssignTo",
      {
        opportunityId: component.get("v.opportunityId"),
        owner: {
          attributes: {
            type: "User"
          },
          Id: component.get("v.opportunityRecord").OwnerId,
          Name: component.get("v.opportunityRecord").Owner.Name
        }
      },
      function (content, status) {
        if (status === "SUCCESS") {
          var modalBody = content;
          component.find("overlayLib").showCustomModal({
            header: "Cambia Titolare Opportunità",
            body: modalBody,
            showCloseButton: true,
            cssClass: ""
          });
        }
      }
    );
  },

  reloadProdottiGaranteDefault: function (component) {
    let opportunityId = component.get("v.opportunityId");

    this.callServer(
      component,
      "c.hasProdottiGaranteDefault",
      function (result) {
        component.set("v.garanziaRequired", result);
      },
      {
        opportunityId: opportunityId
      }
    );
  },

  //SM - Spese Istruttoria
  getDatiSpeseIstruttoria: function (component, event) {
    let opportunityId = component.get("v.opportunityId");

    this.callServer(
      component,
      "c.getDatiSpeseIstruttoria",
      (result) => {
        console.log("@@@ result ", result);
        if (result != undefined && result != null)
          component.set("v.speseIstruttoria", result);
      },
      { opportunityId: opportunityId }
    );
  },

  openOpportunity: function (component) {
    let opportunityId = component.get("v.opportunityId");

    this.callServer(component, "c.openOpportunity", function (result) {}, {
      opportunityId: opportunityId
    });
  },

  checkifOpenOpportunity: function (component) {
    let opportunityId = component.get("v.opportunityId");

    this.callServer(
      component,
      "c.checkIfOpenable",
      function (result) {
        component.set("v.ifOpeningOpportunity", result);
      },
      {
        opportunityId: opportunityId
      }
    );
  },

  getCurrentUser: function (component) {
    this.callServer(
      component,
      "c.getCurrentUser",
      function (result) {
        console.log("getCurrentUser: ", result);
        component.set("v.currentUser", result);
      },
      {}
    );
  },

  getIdAdE: function (component) {
    this.callServer(
      component,
      "c.getIdAdE",
      function (result) {
        console.log("getIdAdE: ", result);
        component.set("v.IdAdE", result);
      },
      {}
    );
  },

  invioBackOffice: function (component) {
    let h = this;
    this.showSpinner(component, "Invio notifica a BO...");
    this.callServer(
      component,
      "c.updateField",
      function (result) {
        console.log("invioBackOffice: ", result);
        if (result) {
          this.showToast(component, "Errore", result, "error");
        } else {
          h.hideSpinner(component);
          h.reloadRecord(component);
          h.showToast(
            component,
            "Success",
            "Pratica avanzata correttamente.",
            "success"
          );
          h.setReadOnlyForFactFisc(component);
        }
      },
      {
        field: "WGC_Invio_Mail_FF__c",
        value: true,
        objectId: component.get("v.opportunityId")
      }
    );
  },

  setReadOnlyForFactFisc: function (component) {
    let currentUser = component.get("v.currentUser");
    let opportunity = component.get("v.opportunityRecord");
    let readOnly = component.get("v.readOnly");

    if (readOnly !== true && opportunity && currentUser) {
      readOnly = opportunity.WGC_Invio_Mail_FF__c
        ? currentUser.Profile.Name != "IFIS - B/O Valutazione Fast Finance"
        : false;
      component.set("v.readOnly", readOnly);
    } else if (
      readOnly &&
      opportunity &&
      opportunity.StageName == "In Istruttoria" &&
      currentUser &&
      opportunity.WGC_Invio_Mail_FF__c &&
      currentUser.Profile.Name == "IFIS - B/O Valutazione Fast Finance"
    )
      component.set("v.readOnly", false);
  },

  getCCIfis: function (component) {
    var oppId = component.get("v.opportunityId");
    var payload = component.get("v.payload");
    var ccData = component.get("v.CCData");
    let opportunity = component.get("v.opportunityRecord");

    if (
      ccData.length == 0 &&
      opportunity != null &&
      opportunity != undefined &&
      opportunity.StageName == "In Istruttoria"
    ) {
      this.callServer(
        component,
        "c.getCCData",
        (result) => {
          var CCIfis = [];
          if (
            result.success &&
            result.data.payload.tabellaRapporti != null &&
            result.data.payload.tabellaRapporti != undefined
          ) {
            result.data.payload.tabellaRapporti.datiRapporto.forEach((r) => {
              let categoriaSottocategoria = r.categoriaSottocategoria.split(
                "/"
              );
              let servizio = r.rapporto.servizio;

              if (
                categoriaSottocategoria[0] == "02" &&
                servizio == 1 &&
                r.flagEstinto == "N"
              ) {
                var tmpCC2 = {
                  label: r.codiceRapportoNonNumerico,
                  value: r.codiceRapportoNonNumerico
                };
                CCIfis.push(tmpCC2);
              }
            });
          } else if (!result.success) {
            this.showToast(
              component,
              "Errore",
              "Errore durante il recupero dei C/C legati all'anagrafica",
              "error"
            );
          }

          console.log("@@@ CCData ", CCIfis);
          component.set("v.CCData", CCIfis);
        },
        { opportunityId: oppId }
      );
    }
  },

  checkNewJoins: function (component) {
    component.set(
      "v.newJoins",
      component.get("v.payload.joinLineaAttore").filter((j) => {
        return (
          j.codTipoCar == null ||
          j.codTipoCar == undefined ||
          j.codTipoCar == ""
        );
      }).length == 0
    );
  },

  //SM - CR 456
  reloadDocNonReperibili: function(component){
    let value = component.get("v.opportunityRecord").WGC_Documenti_Non_Reperibili__c;
    component.set("v.docNonReperibili", value);
  },
});