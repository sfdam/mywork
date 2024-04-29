({
  doInit: function (component, event, helper) {
    component.set(
      "v.opportunityId",
      component.get("v.pageReference").state["c__opportunityId"]
    );
    helper.checkOwnership(component);
    helper.changeFilter(component);
    helper.configureWizard(component);
    helper.checkIfClosable(component);
    helper.getCurrentUser(component);
    //A.M. Bonus Edilizi
    helper.getIdAdE(component);

    // helper.getProducts(component);
    // helper.getPayload(component);
    // helper.getServizi(component);
    // helper.getPicklistOptions(component);
    // helper.checkIsValidCR(component);
    // helper.loadDiviseOptions(component);
    // helper.loadTipologieMutui(component);
    // helper.loadDebitoriPerLinea(component);
    // helper.checkRSF(component);
    // helper.getQualificaUtente(component);
    // helper.loadBilancioCedente(component);
    helper.showSpinner(component);
    component.set("v.firstLoad", false);
  },

  onRender: function (component, event, helper) {
    let firstLoad = component.get("v.firstLoad");
    console.log("ONRENDER");

    if (
      firstLoad == false ||
      component.get("v.pageReference").state["c__opportunityId"] !=
        component.get("v.opportunityId")
    ) {
      if (
        component.get("v.pageReference").state["c__opportunityId"] !=
        component.get("v.opportunityId")
      ) {
        helper.showSpinner(component);
        component.set(
          "v.opportunityId",
          component.get("v.pageReference").state["c__opportunityId"]
        );
        helper.reloadRecord(component);
      }
      helper.checkifOpenOpportunity(component);
      helper.getProducts(component);
      //SM - Banca Corporate
      // helper.getSelectedProducts(component);
      helper.getPayload(component);
      helper.getServizi(component);
      helper.getPicklistOptions(component);
      helper.getCodiciCoppia(component);
      helper.checkExistingPlafond(component);
      // helper.checkIsValidCR(component);
      // helper.getCRData(component);
      helper.loadDiviseOptions(component);
      helper.loadTipologieMutui(component);
      //A.M. Gestione Mutuo Veneto Sviluppo
      helper.loadTipologieMutuiVS(component);
      helper.loadDebitoriPerLinea(component);
      helper.checkRSF(component);
      // helper.getQualificaUtente(component);
      helper.loadBilancioCedente(component);
      helper.setReadOnlyForFactFisc(component);

      component.set("v.firstLoad", true);
    }
  },

  goBackToAccount: function (component, event, helper) {
    helper.goBackToAccount(component, event);
  },

  onFilterProducts: function (component, event, helper) {
    var filter = event.getSource().get("v.name");
    component.set("v.productsFilters", filter);
  },

  navigateSubWizard: function (component, event, helper) {
    helper.showSpinner(component);
    helper.updateWizard(component, event.getParam("target"));
    console.log("NAVIGATE SUBWIZARD: ", event.getParam("target"));
    component.set("v.step", event.getParam("target"));
    helper.hideSpinner(component);
  },

  selectWizardItem: function (component, event, helper) {
    helper.selectWizardItem(component, event.getSource().get("v.label"));
  },

  cartCallServer: function (component, event, helper) {
    // var payload = event.getParam("payload");
    helper.cartCallServer(component, event);
  },

  onChangeOpportunity: function (component, event, helper) {
    let payload = component.get("v.payload");
    let mainWizItems = component.get("v.mainWizardItems");
    let wizItems = component.get("v.wizardItems");
    console.log("onChangeOpportunity --payload: ", payload);

    if (payload != null) {
      helper.loadSpecialistaInfo(component);
      helper.setupHeader(component);
      helper.getSelectedProducts(component, event);
      helper.refreshWizard(component);
      helper.checkEsclusione(component);
      helper.checkNewJoins(component);
    }

    helper.checkPrivacy(component);
    helper.refreshTipoOpportunita(component);
    helper.refreshWizardItemsVisibility(
      component.get("v.isRevisione"),
      component.get("v.isRinnovo"),
      mainWizItems,
      wizItems,
      component
    );
    helper.setupLockedProducts(component);
    helper.checkInviaBtnAvailability(component);
    helper.setReadOnly(component);
    helper.setReadOnlyForFactFisc(component);
    //SM - CR456
    helper.reloadDocNonReperibili(component);

    component.set("v.mainWizardItems", mainWizItems);
    component.set("v.wizardItems", wizItems);
  },

  manageModal: function (component, event, helper) {
    helper.manageModal(component, event);
  },

  headerToggler: function (component, event, helper) {
    $A.util.toggleClass(component.find("cartHeader"), "small-header");
    $A.util.toggleClass(event.currentTarget, "open");
    $A.util.toggleClass(event.currentTarget, "closed");
  },

  onChangeFilter: function (component, event, helper) {
    helper.changeFilter(component, event);
  },

  toggleDeleteOpportunity: function (component, event, helper) {
    component.set("v.isDeleting", !component.get("v.isDeleting"));
  },

  confirmDeleteOpportunity: function (component, event, helper) {
    helper.deleteOpportunity(component);
  },

  invioNuovaVendita: function (component, event, helper) {
    helper.invioNuovaVendita(component);
  },

  doFlip: function (component, event, helper) {
    component.set("v.isFlip0", !component.get("v.isFlip0"));
  },

  onCloseOpportunityClick: function (component, event, helper) {
    helper.closeOpportunityModal(component);
  },

  confirmDeleteOpportunity: function (component, event, helper) {
    helper.showSpinner(component);
    helper.callServer(
      component,
      "c.closeOpportunity",
      function (result) {
        helper.hideSpinner(component);
        helper.showToast(
          component,
          "Opportunità chiusa",
          "L'opportunità è stata chiusa correttamente.",
          "success"
        );
      },
      {
        opportunityId: component.get("v.payload").opportunityId,
        motivo: component.get("v.motivoChiusura")
      }
    );
  },

  checkInviaBtn: function (component, event, helper) {
    helper.checkInviaBtnAvailability(component, event);
  },

  confermaProdotti: function (component, event, helper) {
    // helper.navigateSubWizard(component, "inserimentoDebitori");
    helper.confermaProdotti(component);
  },

  showErrorLoadRecord: function (component, event, helper) {
    helper.showErrorLoadRecord(component);
  },

  downloadRSF: function (component, event, helper) {
    helper.downloadRSF(component);
  },

  generaRSF: function (component, event, helper) {
    // helper.generaRSF(component);
    helper.openModalLanguage(component, helper);
  },

  uploadRSF: function (component, event, helper) {
    helper.uploadRSF(component);
  },

  onChangeBilancio: function (component, event, helper) {
    helper.refreshWizard(component);
  },

  onAllDocValidChange: function (component, event, helper) {
    helper.updateAllDocValid(component, event);
    // helper.refreshWizard(component);
  },

  uploadHandler: function (component, event, helper) {
    helper.updateRSF(component, event);
    helper.checkPrivacy(component);
  },

  reloadTitEffEsec: function (component, event, helper) {
    helper.setupHeader(component);
  },

  onChangeWizardEvent: function (component, event, helper) {
    let wizItemName = event.getParam("wizardItem");
    let completed = event.getParam("completed");
    let hasError = event.getParam("hasError");
    let wizardItems = component.get("v.wizardItems");

    helper.setWizItemCompleted(
      wizardItems.find((wi) => {
        return wi.step == wizItemName;
      }),
      completed
    );
    helper.setWizItemError(
      wizardItems.find((wi) => {
        return wi.step == wizItemName;
      }),
      hasError
    );

    component.set("v.wizardItems", wizardItems);
  },

  onClickMainWizardItem: function (component, event, helper) {
    if (event.currentTarget.classList.value.includes("clickable")) {
      helper.clickMainWizardItem(component, event);
    }
  },

  next: function (component, event, helper) {
    helper.showSpinner(component);
    helper.updateWizard(component, "inserimentoDebitori");
    console.log("NAVIGATE SUBWIZARD: ", "inserimentoDebitori");
    component.set("v.step", "inserimentoDebitori");
    helper.hideSpinner(component);
  },

  onChangeOwnerClick: function (component, event, helper) {
    helper.assignToModal(component);
  },

  onOpenOpportunityClick: function (component, event, helper) {
    helper.showSpinner(component);
    helper.openOpportunity(component);
    $A.get("event.force:refreshView").fire();
    helper.checkifOpenOpportunity(component);
    helper.hideSpinner(component);
  },

  invioBackOffice: function (component, event, helper) {
    console.log("BACKOFFICE");
    helper.invioBackOffice(component);
  },

  // inviaDocs : function(component, event, helper) {
  //     var opportunityId = component.get("v.opportunityId");
  //     var accountId = component.get("v.opportunityRecord").AccountId;

  //     helper.callServer(component, "c.invioDocumentiNuovaVendita", function(result){
  //         console.log("INVIO DOCUMENTI: ", result);
  //     }, { "opportunityId": opportunityId, "accountId": accountId });
  // }
});