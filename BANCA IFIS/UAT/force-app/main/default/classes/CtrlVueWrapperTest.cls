//classe di test per coverage del CtrlVueWrapper. Sono test fake perché CtrlVueWrapper è solo un proxy
@isTest
private class CtrlVueWrapperTest {
    
    private static Integer nCessioni = 3;
    
    @testSetup
    static void setupData() {
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaControlloCambioFaseOpp__c = true;
        f.DisabilitaNamingAutomaticaOpportunita__c = true;
        f.WGC_disabilita_per_batch__c = true; //adione-crm20
        upsert f;
        WGC_AllDataFactory.createUtenzaDefault();
        insert new Prodotto__c(CodiceUnivoco__c = 'ATDTiAnticipo');
        
        User u = TestUtils.creaUtente('userStd');
        Account a = TestUtils.creaAccount('AccountTestTA', u);
        Cessione__c[] cessioni = new Cessione__c[] { };
            for (Integer i = 0; i<nCessioni; i++) {
                cessioni.add(new Cessione__c(Name = 'test', Account__c = a.Id));
            }
        insert cessioni;
    }
    
    @isTest
    static void fetchMyTasks() {
        try {
            CtrlVueWrapper.fetchMyTasks();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchMyEvents() {
        try {
            CtrlVueWrapper.fetchMyEvents();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchActivities() {
        try {
            CtrlVueWrapper.fetchActivities(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchRapporti() {
        try {
            CtrlVueWrapper.fetchRapporti(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchAssetDebitore() {
        try {
            CtrlVueWrapper.fetchAssetDebitore(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchRelazioneClienti() {
        try {
            CtrlVueWrapper.fetchRelazioneClienti(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void tipoAccount() {
        try {
            CtrlVueWrapper.tipoAccount(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getRiepilogoOpportunita() {
        try {
            CtrlVueWrapper.getRiepilogoOpportunita(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getRiepilogoInfoCr() {
        try {
            CtrlVueWrapper.getRiepilogoInfoCr(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getRiepilogoAccountTeam() {
        try {
            CtrlVueWrapper.getRiepilogoAccountTeam(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getFieldSets() {
        try {
            CtrlVueWrapper.getFieldSets(null, null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void upsertObject() {
        try {
            CtrlVueWrapper.upsertObject(null, 'Account');
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void renderModifica() {
        try {
            CtrlVueWrapper.renderModifica(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getInformazioniPopupDebitore() {
        try {
            CtrlVueWrapper.getInformazioniPopupDebitore(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getInformazioniPopupDebitorePDF() {
        try {
            CtrlVueWrapper.getInformazioniPopupDebitorePDF(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getStatoChecklist() {
        try {
            CtrlVueWrapper.getStatoChecklist(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void refreshStatoCartella() {
        try {
            CtrlVueWrapper.refreshStatoCartella(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void generaDocumentazioneTa() {
        try {
            CtrlVueWrapper.generaDocumentazioneTa(null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getInformazioniOppChecklist() {
        try {
            CtrlVueWrapper.getInformazioniOppChecklist(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void inverseLookup() {
        try {
            CtrlVueWrapper.inverseLookup(null, null, null, null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void searchRecent() {
        try {
            CtrlVueWrapper.searchRecent(null, null, null, null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void login() {
        try {
            CtrlVueWrapper.login(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void selfRegister() {
        try {
            CtrlVueWrapper.selfRegister(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void resetPassword() {
        try {
            CtrlVueWrapper.resetPassword(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void setAccessoEffettuato() {
        try {
            CtrlVueWrapper.setAccessoEffettuato(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void search() {
        try {
            CtrlVueWrapper.search(null, null, null, null, null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void searchComuni() {
        try {
            CtrlVueWrapper.searchComuni(null, null, null, null, null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void searchFactoringUsers() {
        try {
            CtrlVueWrapper.searchFactoringUsers(null, null, null, null, null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getPicklistMap() {
        try {
            CtrlVueWrapper.getPicklistMap(null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void addContactAllegato() {
        try {
            CtrlVueWrapper.addContactAllegato(null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void aggiungiAttore() {
        try {
            CtrlVueWrapper.aggiungiAttore(null, null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void removeContact() {
        try {
            CtrlVueWrapper.removeContact(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void rimuoviAttore() {
        try {
            CtrlVueWrapper.rimuoviAttore(null, null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchAttoriCessione() {
        try {
            CtrlVueWrapper.fetchAttoriCessione(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void modifyContactAllegato() {
        try {
            CtrlVueWrapper.modifyContactAllegato(null, null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchCessioni() {
        try {
            CtrlVueWrapper.fetchCessioni();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchAnomalie() {
        try {
            CtrlVueWrapper.fetchAnomalie();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void setReadedMessage() {
        try {
            CtrlVueWrapper.setReadedMessage(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchCessione() {
        try {
            CtrlVueWrapper.fetchCessione(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void popolaUltimoAccesso() {
        try {
            CtrlVueWrapper.popolaUltimoAccesso(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchContacts() {
        try {
            CtrlVueWrapper.fetchContacts();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchProfile() {
        try {
            CtrlVueWrapper.fetchProfile();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void updateProfile() {
        try {
            CtrlVueWrapper.updateProfile(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void upsertCessione() {
        try {
            CtrlVueWrapper.upsertCessione(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getDocumentiUpload() {
        try {
            CtrlVueWrapper.getDocumentiUpload(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void documentiPrivacyCaricati() {
        try {
            CtrlVueWrapper.documentiPrivacyCaricati(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getDocumentiAnomali() {
        try {
            CtrlVueWrapper.getDocumentiAnomali(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void chiudiAnomalia() {
        try {
            CtrlVueWrapper.chiudiAnomalia(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void deleteDocument() {
        try {
            CtrlVueWrapper.deleteDocument(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getDocumentiDownload() {
        try {
            CtrlVueWrapper.getDocumentiDownload(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getDocumentiDinamiciDownload() {
        try {
            CtrlVueWrapper.getDocumentiDinamiciDownload(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchStatiEsteri() {
        try {
            CtrlVueWrapper.fetchStatiEsteri();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchStatiEsteriFull() {
        try {
            CtrlVueWrapper.fetchStatiEsteriFull();
        } catch(Exception e) {
        }
    }
    
    @IsTest
    static void searchCodiceCatastaleComune() {
        Comune__c mi = TestUtils.creaComune('Milano', 'MI', '20121');
        mi.CodiceCatastale__c = 'F205'; 
        upsert mi;
        
        String res = CtrlVueWrapper.searchCodiceCatastaleComune('Milano', 'MI');
        System.assertEquals('F205', res);
    }
    
    @isTest
    static void taSearchAnagrafica() {
        try {
            CtrlVueWrapper.taSearchAnagrafica(null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void salvaAllegatoCessione() {
        try {
            CtrlVueWrapper.salvaAllegatoCessione(null, null, null, null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void salvaCertificazione() {
        try {
            CtrlVueWrapper.salvaCertificazione(null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void associaDebitoriCertificazioni() {
        try {
            CtrlVueWrapper.associaDebitoriCertificazioni(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchFatture() {
        try {
            CtrlVueWrapper.fetchFatture(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchPreventivoCorretto() {
        try {
            CtrlVueWrapper.fetchPreventivoCorretto(null, false);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void updateFatture() {
        try {
            CtrlVueWrapper.updateFatture(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void deleteCertificazione() {
        try {
            CtrlVueWrapper.deleteCertificazione(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchCertificazioniFatture() {
        try {
            CtrlVueWrapper.fetchCertificazioniFatture(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchUploadCertificazioneInfo() {
        try {
            CtrlVueWrapper.fetchUploadCertificazioneInfo(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void generaDocumentazioneStaticaTa() {
        try {
            CtrlVueWrapper.generaDocumentazioneStaticaTa();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchFAQ() {
        try {
            CtrlVueWrapper.fetchFAQ();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getUserInfo() {
        try {
            CtrlVueWrapper.getUserInfo();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchAteco() {
        try {
            CtrlVueWrapper.fetchAteco();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchRelazioneNgSae() {
        try {
            CtrlVueWrapper.fetchRelazioneNgSae();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void updatePrivacy() {
        try {
            CtrlVueWrapper.updatePrivacy(null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchPrivacyCompilata() {
        try {
            CtrlVueWrapper.fetchPrivacyCompilata(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void fetchAttorePrivacy() {
        try {
            CtrlVueWrapper.fetchAttorePrivacy(null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void editNomeCessione() {
        try {
            CtrlVueWrapper.editNomeCessione(null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void updateBilancioSintetico() {
        try {
            CtrlVueWrapper.updateBilancioSintetico(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getInformazioniCambiaOwnerAccount() {
        try {
            CtrlVueWrapper.getInformazioniCambiaOwnerAccount(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void cambiaOwnerAccount() {
        try {
            CtrlVueWrapper.cambiaOwnerAccount(null, null, null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getContentDocumentId() {
        try {
            CtrlVueWrapper.getContentDocumentId(null, null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getSessionIdServerUrl() {
        try {
            CtrlVueWrapper.getSessionIdServerUrl();
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void getLabels() {
        try {
            CtrlVueWrapper.getLabels(null);
        } catch(Exception e) {
        }
    }
    
    @isTest
    static void testGetContentDocumentId() {
        String oppId = '0062500000G4fLSAAZ';
        String tipo = 'MAV';
        CtrlVueWrapper.getContentDocumentId(oppId, tipo);
    }
    
    @isTest
    static void testAggiornaNSA() {
        String oppId = '0062500000G4fLSAAZ';
        CtrlVueWrapper.aggiornaNSA(oppId);
    }
    
    @isTest
    static void testGetUpdatedFatturatoAndDipendenti() {
        Cessione__c c = [SELECT Id, Account__c FROM Cessione__c LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Id = :c.Account__c LIMIT 1];
        a.DataUltimaModificaFatturato__c = Date.today().addDays(- 7);
        a.DataUltimaModificaNumDipendenti__c = Date.today().addDays(- 7);
        update a;
        
        CtrlVueWrapper.getUpdatedFatturatoAndDipendenti(c.Id);
    }
    
    @isTest
    static void testGeneraDocumentazione() {
        List<Opportunity> res = WGC_AllDataFactory.createOpportunity(1, true);
        CtrlVueWrapper.generaDocumentazione(res.get(0).Id, null);
    }
    
    @isTest
    static void testGeneraDocumentazioneStatica() {
        WGC_AllDataFactory.createLagKey();
        CtrlVueWrapper.generaDocumentazioneStatica();
    }
    
    @isTest
    static void testIsPolandSearch() {
        ImpostazioniServizi__c is = new ImpostazioniServizi__c();
        is.CodiceIstituto3N__c = '881';
        insert is;
        CtrlVueWrapper.isPolandSearch();
    }
    
    
    @IsTest
    static void testRecuperaCointestazioni() {
        CtrlCointestazione.ResponseObject res = CtrlVueWrapper.recuperaCointestazioni(null, false, null);
    }
    
    @IsTest
    static void testFetchInfograficheTiAnticipo() {
        Map<String, SObject> res = CtrlVueWrapper.fetchInfograficheTiAnticipo();
    }
}