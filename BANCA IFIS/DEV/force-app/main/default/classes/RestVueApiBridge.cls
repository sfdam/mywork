@RestResource(urlMapping='/ApiBridge/')
global class RestVueApiBridge {
  private RestVueApiBridge() {}

  global class RequestObject {
    public String methodName;
    public String[] params;
  }

  @HttpPost
  global static String doPost(RequestObject req) {

    // METODI FILO DIRETTO
    if(req.methodName == 'fetchTasks') return JSON.serialize(CtrlFiloDiretto.fetchTasks(req.params[0], Boolean.valueOf(req.params[1]), Boolean.valueOf(req.params[2]), req.params[3]));
    if(req.methodName == 'createTask') return JSON.serialize(CtrlFiloDiretto.createTask(req.params[0]));
    if(req.methodName == 'assignTask') return JSON.serialize(CtrlFiloDiretto.assignTask((Task) JSON.deserialize(req.params[0], Task.class)));
    if(req.methodName == 'fetchEvents') return JSON.serialize(CtrlFiloDiretto.fetchEvents(req.params[0], (List<Id>) JSON.deserialize(req.params[1], List<Id>.class)));
    if(req.methodName == 'fetchContact') return JSON.serialize(CtrlFiloDiretto.fetchContact(req.params[0]));
    if(req.methodName == 'fetchAccount') return JSON.serialize(CtrlFiloDiretto.fetchAccount(req.params[0]));
    if(req.methodName == 'esitaTask') return JSON.serialize(CtrlFiloDiretto.esitaTask((Task) JSON.deserialize(req.params[0], Task.class)));
    if(req.methodName == 'ownersEvento') return JSON.serialize((Map<String,User[]>)CtrlFiloDiretto.ownersEvento(req.params[0], req.params[1]));
    if(req.methodName == 'creaEvento') return JSON.serialize(CtrlFiloDiretto.creaEvento((Event) JSON.deserialize(req.params[0], Event.class)));
    if(req.methodName == 'riprogrammaTask') return JSON.serialize(CtrlFiloDiretto.riprogrammaTask((Task) JSON.deserialize(req.params[0], Task.class)));
    if(req.methodName == 'getMatriceEsiti') return JSON.serialize(CtrlFiloDiretto.getMatriceEsiti());

    // METODI WIZARD ACCOUNT
    if(req.methodName == 'isPolandSearch') return JSON.serialize(CtrlWizardAccount.isPolandSearch());
    if(req.methodName == 'searchAnagrafica') return JSON.serialize(CtrlWizardAccount.searchAnagrafica((CtrlWizardAccount.InputObj) JSON.deserialize(req.params[0], CtrlWizardAccount.InputObj.class), req.params[1]));
    if(req.methodName == 'searchContattiANDG') return JSON.serialize(CtrlWizardAccount.searchContattiANDG(req.params[0], req.params[1], req.params[2]));
    if(req.methodName == 'searchContattiSFDC') return JSON.serialize(CtrlWizardAccount.searchContattiSFDC(req.params[0], req.params[1], req.params[2]));
    if(req.methodName == 'setupAccount') return JSON.serialize(CtrlWizardAccount.setupAccount((Account) JSON.deserialize(req.params[0], Account.class)));
    if(req.methodName == 'insertAccount') return JSON.serialize(CtrlWizardAccount.insertAccount(req.params[0], req.params[1], Boolean.valueOf(req.params[2])));
    if(req.methodName == 'insertContacts') return JSON.serialize(CtrlWizardAccount.insertContacts((List<Contact>) JSON.deserialize(req.params[0], List<Contact>.class)));
    if(req.methodName == 'upsertContact') return JSON.serialize(CtrlWizardAccount.upsertContact((Contact) JSON.deserialize(req.params[0], Contact.class), (AccountContactRelation[]) JSON.deserialize(req.params[1], AccountContactRelation[].class), req.params[2]));
    if(req.methodName == 'getRelations') return JSON.serialize(CtrlWizardAccount.getRelations(req.params[0], req.params[1]));
    if(req.methodName == 'getContatto') return JSON.serialize(CtrlWizardAccount.getContatto(req.params[0]));
    if(req.methodName == 'cwaFetchContact') return JSON.serialize(CtrlWizardAccount.cwaFetchContact((Contact) JSON.deserialize(req.params[0], Contact.class)));
    if(req.methodName == 'fetchAteco') return JSON.serialize(CtrlWizardAccount.fetchAteco());
    if(req.methodName == 'fetchRelazioneNgSae') return JSON.serialize(CtrlWizardAccount.fetchRelazioneNgSae());

    if(req.methodName == 'getRiepilogoAccountTeam') return JSON.serialize(CtrlWizardAccount.getRiepilogoAccountTeam(req.params[0]));
    if(req.methodName == 'getFieldSets') return JSON.serialize(CtrlWizardAccount.getFieldSets(req.params[0], req.params[1], req.params[2]));
    if(req.methodName == 'upsertObject') return JSON.serialize(CtrlWizardAccount.upsertObject(req.params[0], req.params[1]));
    if(req.methodName == 'renderModifica') return JSON.serialize(CtrlWizardAccount.renderModifica(req.params[0]));

    if(req.methodName == 'getInformazioniCambiaOwnerAccount') return JSON.serialize(TrgAccount.getInformazioniCambiaOwnerAccount(req.params[0]));
    if(req.methodName == 'cambiaOwnerAccount') return JSON.serialize(TrgAccount.cambiaOwnerAccount(req.params[0], Boolean.valueOf(req.params[1]), req.params[2], Boolean.valueOf(req.params[3])));

    // METODI WIZARD OPPORTUNITA'
    if(req.methodName == 'searchReferenti') return JSON.serialize(CtrlWizardOpportunity.searchReferenti(req.params[0]));
    if(req.methodName == 'saveWizard') return JSON.serialize(CtrlWizardOpportunity.saveWizard(req.params[0], req.params[1]));
    if(req.methodName == 'updatePrivacy') return JSON.serialize(CtrlWizardOpportunity.updatePrivacy((SObject) JSON.deserialize(req.params[0], SObject.class), req.params[1]));
    if(req.methodName == 'fetchPrivacyCompilata') return JSON.serialize(CtrlWizardOpportunity.fetchPrivacyCompilata((req.params[0])));
    if(req.methodName == 'fetchInfograficheTiAnticipo') return JSON.serialize(CtrlWizardOpportunity.fetchInfograficheTiAnticipo());
    if(req.methodName == 'fetchAttorePrivacy') return JSON.serialize(CtrlWizardOpportunity.fetchAttorePrivacy(req.params[0], req.params[1]));
    if(req.methodName == 'updateNoteIstruttoria') return JSON.serialize(CtrlWizardOpportunity.updateNoteIstruttoria((Opportunity) JSON.deserialize(req.params[0], Opportunity.class)));
    if(req.methodName == 'updateAdeguataVerifica') return JSON.serialize(CtrlWizardOpportunity.updateAdeguataVerifica(req.params[0]));
    if(req.methodName == 'editAdeguataVerifica') return JSON.serialize(CtrlWizardOpportunity.editAdeguataVerifica(req.params[0]));
    if(req.methodName == 'updateFatca') return JSON.serialize(CtrlWizardOpportunity.updateFatca(req.params[0]));
    if(req.methodName == 'editFatca') return JSON.serialize(CtrlWizardOpportunity.editFatca(req.params[0]));
    if(req.methodName == 'getAccountData') return JSON.serialize(CtrlWizardOpportunity.getAccountData(req.params[0]));
    if(req.methodName == 'editRsf') return JSON.serialize(CtrlWizardOpportunity.editRsf(req.params[0]));
    if(req.methodName == 'gestioneMutuoMCNSA') return JSON.serialize(CtrlWizardOpportunity.gestioneMutuoMCNSA(req.params[0]));
    if(req.methodName == 'getDebitoriPerLinea') return JSON.serialize(CtrlWizardOpportunity.getDebitoriPerLinea(req.params[0]));

    if(req.methodName == 'getRiepilogoOpportunita') return JSON.serialize(CtrlWizardOpportunity.getRiepilogoOpportunita(req.params[0]));
    if(req.methodName == 'getRiepilogoInfoCr') return JSON.serialize(CtrlWizardOpportunity.getRiepilogoInfoCr(req.params[0]));

    if(req.methodName == 'getParametriProdottiLinea') return JSON.serialize(CtrlWizardOpportunity.getParametriProdottiLinea(req.params[0]));

    if(req.methodName == 'saveGaranzia') return JSON.serialize(CtrlWizardOpportunity.saveGaranzia((Garanzia__c) JSON.deserialize(req.params[0], Garanzia__c.class)));
    if(req.methodName == 'removeGaranzia') return JSON.serialize(CtrlWizardOpportunity.removeGaranzia(req.params[0]));
    if(req.methodName == 'removeGarante') return JSON.serialize(CtrlWizardOpportunity.removeGarante(req.params[0]));
    if(req.methodName == 'removeGaranti') return JSON.serialize(CtrlWizardOpportunity.removeGaranti((List<Id>) JSON.deserialize(req.params[0], List<Id>.class)));
    if(req.methodName == 'saveGarante') return JSON.serialize(CtrlWizardOpportunity.saveGarante(req.params[0], req.params[1]));
    if(req.methodName == 'saveGaranti') return JSON.serialize(CtrlWizardOpportunity.saveGaranti((CtrlCointestazione.Cointestazione) JSON.deserialize(req.params[0], CtrlCointestazione.Cointestazione.class), req.params[1]));
    if(req.methodName == 'saveGaranteDefault') return JSON.serialize(CtrlWizardOpportunity.saveGaranteDefault((Garanzia__c) JSON.deserialize(req.params[0], Garanzia__c.class), req.params[1]));
    if(req.methodName == 'getGaranzie') return JSON.serialize(CtrlWizardOpportunity.getGaranzie());
    if(req.methodName == 'logGarante') CtrlWizardOpportunity.logGarante((List<NDGLinea__c>) JSON.deserialize(req.params[0], List<NDGLinea__c>.class), req.params[1]);

    if(req.methodName == 'getServizi') return JSON.serialize(CtrlWizardOpportunity.getServizi(Boolean.valueOf(req.params[0]), Boolean.valueOf(req.params[1]), Boolean.valueOf(req.params[2])));
    if(req.methodName == 'getSezioni') return JSON.serialize(CtrlWizardOpportunity.getSezioni());
    if(req.methodName == 'getCostanti') return JSON.serialize(K.getCostanti());
    if(req.methodName == 'getDominiProdotti') return JSON.serialize(CtrlWizardOpportunity.getDominiProdotti());

    if(req.methodName == 'getDiviseDisponibili') return JSON.serialize(CtrlWizardOpportunity.getDiviseDisponibili());
    if(req.methodName == 'getInformazioniPopupDebitore') return JSON.serialize(CtrlWizardOpportunity.getInformazioniPopupDebitore(req.params[0]));
    if(req.methodName == 'getInformazioniPopupDebitorePDF') return JSON.serialize(CtrlWizardOpportunity.getInformazioniPopupDebitorePDF(req.params[0]));
    if(req.methodName == 'setWizardCompletato') return JSON.serialize(CtrlWizardOpportunity.setWizardCompletato(req.params[0], Boolean.valueOf(req.params[1])));

    if(req.methodName == 'getParamPropagabili') return JSON.serialize(CtrlWizardOpportunity.getParamPropagabili());

    // METODI WIZARD COINTESTAZIONE
    if(req.methodName == 'gestisciCointestazione') return JSON.serialize(CtrlWizardOpportunity.gestisciCointestazione(req.params[0]));
    if(req.methodName == 'recuperaCointestazioni') return JSON.serialize(CtrlWizardOpportunity.recuperaCointestazioni(req.params[0], Boolean.valueOf(req.params[1]), req.params[2]));

    // METODI COMPILAZIONE QQ
    if(req.methodName == 'fetchQQ') return JSON.serialize(CtrlCompilazioneQQ.fetchQQ((CtrlCompilazioneQQ.InputObj) JSON.deserialize(req.params[0], CtrlCompilazioneQQ.InputObj.class)));
    if(req.methodName == 'salvaQQ') return JSON.serialize(CtrlCompilazioneQQ.salvaQQ(
      (Map<Integer, CtrlCompilazioneQQ.Domanda[]>) JSON.deserialize(req.params[0], Map<Integer,CtrlCompilazioneQQ.Domanda[]>.class),
      (QuestionarioQualitativo__c) JSON.deserialize(req.params[1], QuestionarioQualitativo__c.class)
      )
    );
    if(req.methodName == 'fetchAltriQQ') return JSON.serialize(CtrlCompilazioneQQ.fetchAltriQQ((CtrlCompilazioneQQ.InputObj) JSON.deserialize(req.params[0], CtrlCompilazioneQQ.InputObj.class)));

    // METODI VISTA ALLEGATI
    if(req.methodName == 'fetchAllegati') return JSON.serialize(CtrlGestioneAllegati.fetchAllegati((CtrlGestioneAllegati.InputObj) JSON.deserialize(req.params[0], CtrlGestioneAllegati.InputObj.class)));
    if(req.methodName == 'fetchPDF') return JSON.serialize(CtrlGestioneAllegati.fetchPDF((CtrlGestioneAllegati.InputObj) JSON.deserialize(req.params[0], CtrlGestioneAllegati.InputObj.class)));
    if(req.methodName == 'salvaAllegato') return JSON.serialize(CtrlGestioneAllegati.salvaAllegato((CtrlGestioneAllegati.InputObj) JSON.deserialize(req.params[0], CtrlGestioneAllegati.InputObj.class)));
    if(req.methodName == 'getContentDocumentId') return JSON.serialize(CtrlGestioneAllegati.getContentDocumentId(req.params[0], req.params[1]));

    // METODI LOOKUP
    if(req.methodName == 'search') return JSON.serialize(ExtSfdcLookup.search(req.params[0], req.params[1], (String[]) JSON.deserialize(req.params[2], List<String>.class), req.params[3], req.params[4], (String[]) JSON.deserialize(req.params[5], List<String>.class)));
    if(req.methodName == 'searchEquals') return JSON.serialize(ExtSfdcLookup.searchEquals(req.params[0], req.params[1], (String[]) JSON.deserialize(req.params[2], List<String>.class), req.params[3], req.params[4], (String[]) JSON.deserialize(req.params[5], List<String>.class)));
    if(req.methodName == 'searchComuni') return JSON.serialize(ExtSfdcLookup.searchComuni(req.params[0], req.params[1], (String[]) JSON.deserialize(req.params[2], List<String>.class), req.params[3], req.params[4], (String[]) JSON.deserialize(req.params[5], List<String>.class)));
    if(req.methodName == 'inverseLookup') return JSON.serialize(ExtSfdcLookup.inverseLookup(req.params[0], req.params[1], (String[]) JSON.deserialize(req.params[2], List<String>.class), req.params[3], req.params[4]));
    if(req.methodName == 'searchRecent') return JSON.serialize(ExtSfdcLookup.searchRecent(req.params[0], req.params[1], (String[]) JSON.deserialize(req.params[2], List<String>.class), req.params[3], (String[]) JSON.deserialize(req.params[4], List<String>.class)));
    if(req.methodName == 'fetchStatiEsteri') return JSON.serialize(ExtSfdcLookup.fetchStatiEsteri());
    if(req.methodName == 'fetchStatiEsteriFull') return JSON.serialize(ExtSfdcLookup.fetchStatiEsteriFull());
    if(req.methodName == 'searchCodiceCatastaleComune') return JSON.serialize(ExtSfdcLookup.searchCodiceCatastaleComune(req.params[0], req.params[1]));
    if(req.methodName == 'searchFactoringUsers') return JSON.serialize(ExtSfdcLookup.searchFactoringUsers(req.params[0], req.params[1], (String[]) JSON.deserialize(req.params[2], List<String>.class), req.params[3], req.params[4], (String[]) JSON.deserialize(req.params[5], List<String>.class)));

    //UTIL
    if(req.methodName == 'getLabels') return JSON.serialize(CtrlVueWrapper.getLabels(req.params[0]));

    // METODI CENSIMENTO
    if(req.methodName == 'getAziendeDaCensire') return JSON.serialize(CtrlCensimento.getAziendeDaCensire(req.params[0]));
    if(req.methodName == 'richiediCensimento') return JSON.serialize(CtrlCensimento.richiediCensimento(req.params[0], req.params[1]));
    if(req.methodName == 'richiediRibes') return JSON.serialize(CtrlCensimento.richiediRibes(req.params[0], req.params[1]));
    if(req.methodName == 'forzaControaggiornamentoKNET') return JSON.serialize(CtrlCensimento.forzaControaggiornamentoKNET(req.params[0], req.params[1]));
    if(req.methodName == 'fetchAnagrafeConsulenti') return JSON.serialize(CtrlCensimento.fetchAnagrafeConsulenti());
    if(req.methodName == 'associaPfPg') return JSON.serialize(CtrlCensimento.associaPfPg(req.params[0], req.params[1]));
    if(req.methodName == 'updateEntities') return JSON.serialize(CtrlCensimento.updateEntities((Account[]) JSON.deserialize(req.params[0], List<Account>.class), (Contact[]) JSON.deserialize(req.params[1], List<Contact>.class), req.params[2]));
    if(req.methodName == 'precheckCedacri') return JSON.serialize(CtrlCensimento.precheckCedacri(req.params[0], req.params[1]));

    // METODI COMPONENTINI HP
    if(req.methodName == 'fetchMyTasks') return JSON.serialize(CtrlListeHp.fetchMyTasks());
    if(req.methodName == 'fetchMyEvents') return JSON.serialize(CtrlListeHp.fetchMyEvents());

    // INVIA MAIL
    if(req.methodName == 'inviaMail') return JSON.serialize(CtrlWizardOpportunity.inviaMail(req.params[0]));
    if(req.methodName == 'getDestinatari') return JSON.serialize(CtrlWizardOpportunity.getDestinatari(req.params[0]));

    // CHECKLIST
    if(req.methodName == 'getStatoChecklist') return JSON.serialize(ExtViewChecklist.getStatoChecklist(req.params[0]));
    if(req.methodName == 'generaDocumentazione') return JSON.serialize(ExtViewChecklist.generaDocumentazione(req.params[0], req.params[1]));
    if(req.methodName == 'refreshStatoCartella') return JSON.serialize(ExtViewChecklist.refreshStatoCartella(req.params[0]));
    if(req.methodName == 'esistePef') return JSON.serialize(ExtViewChecklist.esistePef(req.params[0]));
    if(req.methodName == 'fetchInnescoOpportunita') return JSON.serialize(ExtViewChecklist.fetchInnescoOpportunita(req.params[0]));
    if(req.methodName == 'cambiaInnescoOpportunita') ExtViewChecklist.cambiaInnescoOpportunita(Boolean.valueOf(req.params[0]), req.params[1]);
    if(req.methodName == 'aggiornaNSA') ExtViewChecklist.aggiornaNSA(req.params[0]);
    if(req.methodName == 'inviaNuovaVendita') return JSON.serialize(ExtViewChecklist.inviaNuovaVendita(req.params[0]));
    if(req.methodName == 'richiediInfoCR') return JSON.serialize(ExtViewChecklist.richiediInfoCR(req.params[0]));
    if(req.methodName == 'esisteTitolareEffettivo') return JSON.serialize(ExtViewChecklist.esisteTitolareEffettivo(req.params[0]));
    if(req.methodName == 'getInformazioniOppChecklist') return JSON.serialize(ExtViewChecklist.getInformazioniOppChecklist(req.params[0]));
    if(req.methodName == 'getUpdatedFatturatoAndDipendenti') return JSON.serialize(ExtViewChecklist.getUpdatedFatturatoAndDipendenti(req.params[0]));

    // RECENT ACTIVITIES
    if(req.methodName == 'fetchActivities') return JSON.serialize(CtrlRecentActivities.fetchActivities(req.params[0]));

    // RICHIEDI ASSEGNAZIONE
    if(req.methodName == 'richiediAssegnazione') return JSON.serialize(ExtRichiediAssegnazione.richiediAssegnazione(req.params[0],req.params[1]));

    // METODI POSIZIONE ACCOUNT
    if(req.methodName == 'fetchRapporti') return JSON.serialize(CtrlPosizioneAccount.fetchRapporti(req.params[0]));
    if(req.methodName == 'fetchAssetDebitore') return JSON.serialize(CtrlPosizioneAccount.fetchAssetDebitore(req.params[0]));
    if(req.methodName == 'fetchRelazioneClienti') return JSON.serialize(CtrlPosizioneAccount.fetchRelazioneClienti(req.params[0]));
    if(req.methodName == 'tipoAccount') return JSON.serialize(CtrlPosizioneAccount.tipoAccount(req.params[0]));

    // BILANCIO
    if(req.methodName == 'updateBilancioSintetico') WsRestRibesUtils.updateBilancioSintetico(req.params[0]);

    // COMMUNITY TI ANTICIPO
    //TA GENERAL
    if(req.methodName == 'getPicklistMap') return JSON.serialize(CtrlVueWrapper.getPicklistMap(req.params[0], req.params[1]));
    if(req.methodName == 'fetchProfile') return JSON.serialize(CtrlVueWrapper.fetchProfile());
    if(req.methodName == 'updateProfile') return JSON.serialize(CtrlVueWrapper.updateProfile(req.params[0]));

    //TA LOGIN
    if(req.methodName == 'login') return JSON.serialize(CtrlVueWrapper.login(req.params[0]));
    if(req.methodName == 'selfRegister') return JSON.serialize(CtrlVueWrapper.selfRegister(req.params[0]));
    if(req.methodName == 'resetPassword') return JSON.serialize(CtrlVueWrapper.resetPassword(req.params[0]));
    if(req.methodName == 'getUserInfo') return JSON.serialize(CtrlVueWrapper.getUserInfo());
    if(req.methodName == 'setAccessoEffettuato') return JSON.serialize(CtrlVueWrapper.setAccessoEffettuato(Boolean.valueOf(req.params[0])));

    //TA UTENTI
    if(req.methodName == 'addContactAllegato') return JSON.serialize(CtrlVueWrapper.addContactAllegato(req.params[0], req.params[1]));
    if(req.methodName == 'aggiungiAttore') return JSON.serialize(CtrlVueWrapper.aggiungiAttore(req.params[0], req.params[1], req.params[2]));
    if(req.methodName == 'fetchAttoriCessione') return JSON.serialize(CtrlVueWrapper.fetchAttoriCessione((req.params[0])));
    if(req.methodName == 'fetchContacts') return JSON.serialize(CtrlVueWrapper.fetchContacts());
    if(req.methodName == 'removeContact') return JSON.serialize(CtrlVueWrapper.removeContact(req.params[0]));
    if(req.methodName == 'rimuoviAttore') return JSON.serialize(CtrlVueWrapper.rimuoviAttore(req.params[0], req.params[1], req.params[2]));
    if(req.methodName == 'modifyContactAllegato') return JSON.serialize(CtrlVueWrapper.modifyContactAllegato(req.params[0], req.params[1], req.params[2]));
    if(req.methodName == 'taSearchAnagrafica') return JSON.serialize(CtrlVueWrapper.taSearchAnagrafica(req.params[0], req.params[1]));

    //TA RIEPILOGO
    if(req.methodName == 'fetchCessioni') return JSON.serialize(CtrlVueWrapper.fetchCessioni());
    if(req.methodName == 'editNomeCessione') return JSON.serialize(CtrlVueWrapper.editNomeCessione(req.params[0], req.params[1]));
    if(req.methodName == 'popolaUltimoAccesso') CtrlVueWrapper.popolaUltimoAccesso(req.params[0]);

    //TA DETTAGLIO SINGOLA CESSIONE
    if(req.methodName == 'fetchCessione') return JSON.serialize(CtrlVueWrapper.fetchCessione(req.params[0]));
    if(req.methodName == 'upsertCessione') return JSON.serialize(CtrlVueWrapper.upsertCessione(req.params[0]));
    if(req.methodName == 'associaDebitoriCertificazioni') return JSON.serialize(CtrlVueWrapper.associaDebitoriCertificazioni((Certificazione__c[])JSON.deserialize(req.params[0], Certificazione__c[].class)));
    if(req.methodName == 'fetchFatture') return JSON.serialize(CtrlVueWrapper.fetchFatture(req.params[0]));
    if(req.methodName == 'fetchPreventivoCorretto') return JSON.serialize(CtrlVueWrapper.fetchPreventivoCorretto(req.params[0], Boolean.valueOf(req.params[1])));
    if(req.methodName == 'updateFatture') return JSON.serialize(CtrlVueWrapper.updateFatture(req.params[0]));
    if(req.methodName == 'deleteCertificazione') return JSON.serialize(CtrlVueWrapper.deleteCertificazione(req.params[0]));
    if(req.methodName == 'fetchCertificazioniFatture') return JSON.serialize(CtrlVueWrapper.fetchCertificazioniFatture(req.params[0]));
    if(req.methodName == 'fetchUploadCertificazioneInfo') return JSON.serialize(CtrlVueWrapper.fetchUploadCertificazioneInfo(req.params[0]));

    //TA DOCUMENTAZIONE
    if(req.methodName == 'getDocumentiUpload') return JSON.serialize(CtrlVueWrapper.getDocumentiUpload(req.params[0]));
    if(req.methodName == 'documentiPrivacyCaricati') CtrlVueWrapper.documentiPrivacyCaricati(req.params[0]);
    if(req.methodName == 'getDocumentiAnomali') return JSON.serialize(CtrlVueWrapper.getDocumentiAnomali(req.params[0]));
    if(req.methodName == 'chiudiAnomalia') return JSON.serialize(CtrlVueWrapper.chiudiAnomalia(req.params[0]));
    if(req.methodName == 'getDocumentiDownload') return JSON.serialize(CtrlVueWrapper.getDocumentiDownload(req.params[0]));
    if(req.methodName == 'getDocumentiDinamiciDownload') return JSON.serialize(CtrlVueWrapper.getDocumentiDinamiciDownload((String[]) JSON.deserialize(req.params[0], String[].class)));
    if(req.methodName == 'deleteDocument') return JSON.serialize(CtrlVueWrapper.deleteDocument(req.params[0]));
    if(req.methodName == 'salvaAllegatoCessione') return JSON.serialize(CtrlVueWrapper.salvaAllegatoCessione(req.params[0], req.params[1], req.params[2], req.params[3], req.params[4]));
    if(req.methodName == 'salvaCertificazione') return JSON.serialize(CtrlVueWrapper.salvaCertificazione(req.params[0], req.params[1]));
    if(req.methodName == 'generaDocumentazioneTa') return JSON.serialize(CtrlVueWrapper.generaDocumentazioneTa(req.params[0], req.params[1]));
    if(req.methodName == 'generaDocumentazioneStaticaTa') return JSON.serialize(CtrlVueWrapper.generaDocumentazioneStaticaTa());
    if(req.methodName == 'getFoglioInformativoDownload') return JSON.serialize(CtrlVueWrapper.getFoglioInformativoDownload());

    //TA MESSAGGI
    if(req.methodName == 'fetchAnomalie') return JSON.serialize(CtrlVueWrapper.fetchAnomalie());
    if(req.methodName == 'setReadedMessage') return JSON.serialize(CtrlVueWrapper.setReadedMessage(req.params[0]));

    //TA TESTI
    if(req.methodName == 'fetchFAQ') return JSON.serialize(TaCtrlTesti.fetchFAQ());

    return null;
  }
}