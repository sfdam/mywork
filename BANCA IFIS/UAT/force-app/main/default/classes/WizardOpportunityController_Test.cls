@isTest
public class WizardOpportunityController_Test {

    /*@isTest
    public static void Test_Metodi_cloneOpportunity(){
        WGC_AlldataFactory.createUtenzaDefault();
        List<WGC_Linea_Prodotto__c> listLinProd = WGC_AlldataFactory.createLineaProdotti2(2,true);
        List<WGC_Fido_di_Coppia__c> listFidoCoppia = WGC_AlldataFactory.createFidoCoppia(2,false);
        Account a = [SELECT Id, Name, NDGGruppo__c  FROM Account];
        listFidoCoppia.get(0).Linea__c=listLinProd.get(0).Id;
        listFidoCoppia.get(0).Debitore__c = a.Id;
        listFidoCoppia.get(1).Linea__c=listLinProd.get(0).Id;
        listFidoCoppia.get(1).Debitore__c = a.Id;
        listFidoCoppia.get(1).NDG_Debitore__c = a.NDGGruppo__c;
        insert listFidoCoppia;
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);
        WGC_AlldataFactory.createProdotti(1,true);
        listOpp.get(0).AccountId = a.Id;
        insert listOpp;
        List<String> lstIdOpp = new List<String>();
        lstIdOpp.add(listOpp.get(0).Id);

        Test.startTest();
        WizardOpportunityController.cloneOpportunity(lstIdOpp);  //Da controllare
        Test.stopTest();
    }


    @isTest
    public static void Test_Metodi_Account(){
        WGC_AlldataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        WGC_AlldataFactory.createContact(1,true);
        Account a = [SELECT ID, Name From Account LIMIT 1];
        List<AccountContactRelation> accCont = [SELECT Id, Contact.Name, Contact.WGC_Censimento_MAV__c, WGC_Selezionato__c, WGC_Ruolo_Pratica__c, WGC_Tipologia_Titolare_Effettivo__c FROM AccountContactRelation];
        accCont.get(0).WGC_Selezionato__c = true;
        accCont.get(0).WGC_Ruolo_Pratica__c = 'J1;Z1';
        update accCont;
        System.debug('accCont: '+accCont);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());

        Test.startTest();
        WizardOpportunityController.getOpportunities(a.Id);
        WizardOpportunityController.getFactoringOpportunities(a.Id);
        WizardOpportunityController.getCrossSellingAssegnatariPerBU(a.Id);
        WizardOpportunityController.getTitolariEsecutori(a.Id);
        WizardOpportunityController.getReferenti(a.Id);
        WizardOpportunityController.getTitolariEsecutori(a.Id);
        //WizardOpportunityController.gestisciCointestazione(a.Id);
        Test.stopTest();
    }

    @isTest
    public static void Test_Metodi_Opportunity(){
        WGC_AlldataFactory.createUtenzaDefault();
        Opportunity o = WGC_AlldataFactory.createOpportunity(1,false).get(0);
        o.Tipologia_Opportunit__c='CROSS';
        insert o;
        WGC_Bilancio__c bilancio = WGC_AlldataFactory.createBilancio(1,false).get(0);
        bilancio.Account__c = o.AccountId;
        insert bilancio;
        
        User u = [SELECT Id, Qualifica_Utente__c FROM User WHERE Id = :UserInfo.getUserId()];
        u.Qualifica_Utente__c = 'Leasing EF';
        update u;
        // Account a = [SELECT Id, WGC_Linee_Fact_Cedente__c, WGC_Linee_Fact_Debitore__c, WGC_Linee_Conto_Corrente__c FROM Account LIMIT 1];      
        // update a;
        System.debug('qua test: '+u);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WizardOpportunityController.getParametriEConfigurazioniLinee(o.Id);
        WizardOpportunityController.getPayload(o.Id);
        WizardOpportunityController.getBilancioCedente(o.Id);
        WizardOpportunityController.getDebitoriPerLinea(o.Id);
        WizardOpportunityController.getDebitoriNewFields(o.Id);
        WizardOpportunityController.docCheckListOpportunity(o.Id);
        WizardOpportunityController.getGarantiEGaranzie(o.Id);
        WizardOpportunityController.getProducts(o.Id);
        WizardOpportunityController.associaResponsabili(o.AccountId,'IFISOpportunitaFactoring');
        WizardOpportunityController.inviaNuovaVendita(o.Id);
        WizardOpportunityController.esisteTitolareEffettivo(o.Id);
        WizardOpportunityController.getParametri(o.Id,null);
        //WizardOpportunityController.getParametri(o.Id,'test');
        WizardOpportunityController.getProducts(o.Id);
        u.Qualifica_Utente__c = 'Leasing EF';
        update u;
        WizardOpportunityController.getProducts(o.Id);
        u.Qualifica_Utente__c = 'IFIS_International';
        update u;
        WizardOpportunityController.getProducts(o.Id);
        Test.stopTest();
    }

    @isTest
    public static void Test_Metodi_OpportunityConAltriInput(){
        WGC_AlldataFactory.createUtenzaDefault();
        List<NDGLinea__c> attori = WGC_AlldataFactory.createAttori2(1,false);
        insert attori;
        Opportunity o = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        WGC_Bilancio__c bilancio = WGC_AlldataFactory.createBilancio(1,false).get(0);
        bilancio.Account__c = o.AccountId;
        insert bilancio;
        String accId = o.AccountId;
        
        String s = JSON.serialize(WizardOpportunityController.getProducts(o.Id));
        List<JoinGaranteGaranzia__c> prova = [SELECT Id, Garante__c FROM JoinGaranteGaranzia__c];
        System.debug('prova: '+prova);
        Test.startTest();
        WizardOpportunityController.setProductInOpp(o.id,s);
        WizardOpportunityController.richiestaPrimaInfoCR(o.Id,'cedente');
        WizardOpportunityController.richiestaPrimaInfoCR(o.Id,'debitori');
        WizardOpportunityController.richiestaPrimaInfoCR(o.Id,'garanti');
        WizardOpportunityController.updatePresaVisione(o.Id,'Id');
        WizardOpportunityController.saveCrossSellingJSON(o.Id,'testCrossSelling');
        WizardOpportunityController.loadDatiPEF(accId,o.Id);
        WizardOpportunityController.asyncLoadDatiPEF(accId,o.Id);
        WizardOpportunityController.isCurrentUserSpecialista(accId,o.Id);
        WizardOpportunityController.checkTitolariEsecutore(accId,o.Id);
        // WizardOpportunityController.closeOpportunity(o.Id,'Test');
        WizardOpportunityController.deleteOpp(o.id,s);
        Test.stopTest();
    }

    @isTest
    public static void Test_Metodi_senzaInput(){
        WGC_AlldataFactory.createUtenzaDefault();
        
        
        Test.startTest();
        WizardOpportunityController.getUserInfo();
        WizardOpportunityController.getServizi();
        WizardOpportunityController.getDiviseOptions();
        WizardOpportunityController.getTipologieMutui();
        WizardOpportunityController.loadGaranziaData();
        WizardOpportunityController.getSezioni();
        WizardOpportunityController.getAllOpportunities();
        WizardOpportunityController.getAllProducts();
        WizardOpportunityController.compareAndGroupParams();  //Da controllare
        Test.stopTest();
    }

     @isTest
    public static void Test_Metodi_Payload(){
        WGC_AlldataFactory.createUtenzaDefault();
        List<NDGLinea__c> listAtt = WGC_AlldataFactory.createAttori2(3,false);
        
        List<Opportunity> listOpp = [SELECT Id FROM Opportunity];
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        String plOpp =JSON.serialize(listOpp);
        
        CtrlWizardOpportunity.WoPayload wopl1 = new CtrlWizardOpportunity.WoPayload(); 
        CtrlWizardOpportunity.WoPayload wopl2 = new CtrlWizardOpportunity.WoPayload();
        CtrlWizardOpportunity.WoPayload wopl3 = new CtrlWizardOpportunity.WoPayload();

        List<CtrlWizardOpportunity.WoDebitore> listWoDeb = new List<CtrlWizardOpportunity.WoDebitore>();
        CtrlWizardOpportunity.WoDebitore woDeb = new CtrlWizardOpportunity.WoDebitore();
        woDeb.account = a.Id;
        listWoDeb.add(woDeb);

        Test.startTest();
        WizardOpportunityController.saveWizard(JSON.serialize(wopl1),'categorie,debitori,configurazioneicarmanuali,garanzie');

        // WizardOpportunityController.updateDebitori(JSON.serialize(wopl2),null); //Non funziona
        // WizardOpportunityController.updateWizardCompletato(plOpp);
        // WizardOpportunityController.manageCrossSelling(plOpp); //non funziona
        

        //WizardOpportunityController.generateMapDebitori(listWoDeb);
        Test.stopTest();
    }

    @isTest
    public static void Test_Metodi(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        Account a = WGC_AllDataFactory.createAccount(1,true).get(0);
        WGC_Documenti_Controller.DocDownload docDownloadTest = new WGC_Documenti_Controller.DocDownload();
        String document = JSON.serialize(docDownloadTest);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WizardOpportunityController.doc08(a.Id,document);
        WizardOpportunityController.getCrossSellingAssegnatariPerBU(a.Id);
        Test.stopTest();
    }

    @isTest
    public static void Test_Metodi_conLinee(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Linea__c> listLinee = WGC_AllDataFactory.createLinee(5,true);
        List<NDGLinea__c> listAttori = [SELECT Id FROM NDGLinea__c];
        Opportunity o = [SELECT Id, BI_LineeRevisionabili__c FROM Opportunity LIMIT 1];
        Account a = [SELECT Id, Name, NDGGruppo__c,WGC_Linee_Conto_Corrente__c,WGC_Linee_Fact_Cedente__c,WGC_Linee_Fact_Debitore__c  FROM Account LIMIT 1];
        Test.startTest();
        WizardOpportunityController.getRevisionedParameters(listLinee.get(0).Id);
        WizardOpportunityController.populateParams(listLinee.get(0).Id,'123','abc',listAttori.get(0).Id);
        WizardOpportunityController.upsertNote('GaranziaCommercialLending__c','Ipoteca',o.Id);
        WizardOpportunityController.updateNote('GaranziaCommercialLending__c','Pegno su azioni',o.Id);
        WizardOpportunityController.getParametriModificati(listLinee);
        WizardOpportunityController.getNuovaCessione(o,listLinee);
        Test.stopTest();
    }*/

    @isTest
    public static void flowCarrello1() {
        WGC_AllDataFactory.createUtenzaDefault();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);

        Prodotto__c prod = new Prodotto__c();
        Parametro__c parameter = new Parametro__c();
        List<WizardOpportunityController.WrapperProduct> listWP = new List<WizardOpportunityController.WrapperProduct>();
        WizardOpportunityController.WrapperProduct wp = new WizardOpportunityController.WrapperProduct();
        wp.codice = prod.CodiceUnivoco__c = '111';
        wp.name = prod.WGC_Famiglia__c = 'Factoring';
        wp.area = prod.WGC_Area__c = 'Factoring - Cedente';
        wp.tipoCrossSelling = prod.WGC_Tipo_Cross_Selling__c = 'IFISOpportunitaFactoring';
        wp.subProductForm = prod.WGC_ConfigurazioneFormSubProduct__c = '';
        wp.icona = prod.WGC_Icona__c = 'utility:close';
        listWP.add(wp);
        insert prod;
        parameter.NumeroParametro__c = 'TEST1';
        parameter.Tipo__c = 'Parametro nascosto';
        parameter.Tipologia__c = 'Picklist';
        insert parameter;

        Account acc = listAcc[0];
        Opportunity opp = listOpp[0];

        List<Task> taskList = WGC_AlldataFactory.createTask(1);
        List<Event> eventList = WGC_AlldataFactory.createEvent(1);
        eventList[0].WhatId = taskList[0].WhatId = acc.Id;
        eventList[0].Originator__c = taskList[0].Originator__c = 'Diretto';
        eventList[0].Originator_di_dettaglio__c = taskList[0].Originator_di_dettaglio__c = 'Rete Commerciale Italia';

        insert taskList;
        insert eventList;

        WGC_TrgOpportunity.excuteInTest = true;
        opp.AccountId = acc.Id;
        opp.Tipologia_Opportunit__c = 'CONC';
        insert opp;

        ParametroProdotto__c newParam = new ParametroProdotto__c(Dominio__c = 'TEST;TEST2', SoloDeroga__c = true, Default__c = 'TEST', Sezione__c = 'PN01', Prodotto__c = prod.Id, Parametro__c = parameter.Id);
        insert newParam;
        CtrlWizardOpportunity.WoConfigurazioneParametro param = new CtrlWizardOpportunity.WoConfigurazioneParametro();
        param.id = newParam.Id;
        param.dominioVal = newParam.Dominio__c;
        param.soloDeroga = newParam.SoloDeroga__c;
        param.defaultval = newParam.Default__c;
        param.sezione = newParam.Sezione__c;

        List<User> utenti = new List<User>();
        utenti.add(TestUtils.creaUtente('leasing'));
        utenti[0].Qualifica_Utente__c = 'Leasing EF';
        utenti.add(TestUtils.creaUtente('intern'));
        utenti[1].Qualifica_Utente__c = 'IFIS_International';
        update utenti;

        Test.startTest();
        WizardOpportunityController.getOpportunityRecordType(opp.Id);
        WizardOpportunityController.getOpportunities(acc.Id);
        WizardOpportunityController.getFactoringOpportunities(acc.Id);
        WizardOpportunityController.setProductInOpp(opp.Id, JSON.serialize(listWP));
        WizardOpportunityController.getProducts(opp.Id);
        opp.ownerId = utenti[0].Id;
        update opp;
        System.runAs(utenti[0]){WizardOpportunityController.getProducts(opp.Id);}
        opp.ownerId = utenti[1].Id;
        update opp;
        System.runAs(utenti[1]){WizardOpportunityController.getProducts(opp.Id);}
        WizardOpportunityController.getUserInfo();
        WizardOpportunityController.getServizi();
        WizardOpportunityController.getParametriEConfigurazioniLinee(opp.Id);
        WizardOpportunityController.getPayload(opp.Id);
        WizardOpportunityController.getDiviseOptions();
        WizardOpportunityController.getTipologieMutui();
        WizardOpportunityController.getDebitoriPerLinea(opp.Id);
        WizardOpportunityController.getBilancioCedente(opp.Id);
        WizardOpportunityController.saveParameter(param);

        //SM
        WizardOpportunityController.checkIfClosable(opp.Id);
        WizardOpportunityController.getOptyRT(opp.Id);

        Test.stopTest();
    }

    @isTest
    public static void flowCarrello2() {
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);
        List<Prodotto__c> listProds = WGC_AlldataFactory.createProdotti(1,true);

        Account acc = listAcc[0];
        Opportunity opp = listOpp[0];
        Prodotto__c prod = listProds[0];

        opp.AccountId = acc.Id;
        opp.Tipologia_Opportunit__c = 'CONC';
        insert opp;

        WGC_AlldataFactory.CreaNDGLineaDebitore(acc, opp);
        CtrlWizardOpportunity.WoPayload payload = CtrlWizardOpportunity.editRsf(opp.Id);

        Map<String, Object> debsNewFields = new Map<String, Object>();
        debsNewFields.put('id', '1234abcd');
        debsNewFields.put('debitore', 'abc123');
        debsNewFields.put('commessa', 'true');
        debsNewFields.put('appalto', 'false');
        debsNewFields.put('tipologiaControparte', 'Privato');
        debsNewFields.put('tipologiaFornitura', 'Beni');
        debsNewFields.put('mercato', '001');

        Map<String, Object> updateWizardMap = new Map<String, Object>();
        updateWizardMap.put('opportunityId', opp.Id);
        updateWizardMap.put('wizardCompletato', true);

        // Map<String, Object> document = new Map<String, Object>();
        // document.put('id', 'NV0000002');
        // document.put('title', 'WGC_ModuloRichiestaServiziFinanziari');
        // document.put('codId', 'ServiziFinanziari');

        Linea__c line = new Linea__c();
        line.Opportunity__c = opp.Id;
        line.DivisaNew__c = '242';
        line.Mercato__c = '001';
        line.Prodotto__c = prod.Id;
        insert line;
                
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WizardOpportunityController.updateDebitori(JSON.serialize(payload), null);
        WizardOpportunityController.updateDebitori(JSON.serialize(payload), JSON.serialize(new List<Map<String, Object>>{debsNewFields}));
        WizardOpportunityController.saveWizard(JSON.serialize(payload), 'categorie');
        WizardOpportunityController.saveWizard(JSON.serialize(payload), 'servizi');
        //WizardOpportunityController.saveWizard(JSON.serialize(payload), 'configurazionelinee');
        // WizardOpportunityController.updateDebitori(JSON.serialize(payload), null);
        // WizardOpportunityController.updateDebitori(JSON.serialize(payload), JSON.serialize(new List<Map<String, Object>>{debsNewFields}));
        // WizardOpportunityController.updateWizardCompletato(JSON.serialize(updateWizardMap));
        //TOO MANY SOQL QUERIES
        // WizardOpportunityController.doc08(acc.Id, JSON.serialize(document));
        // WizardOpportunityController.doc11(opp.Id, 'ServiziFinanziari', 'WGC_ModuloRichiestaServiziFinanziari', '');
        // WizardOpportunityController.saveCrossSellingJSON(opp.Id, '[]');
        Test.stopTest();
    }
    
    @isTest
    public static void flowCarrelloGaranzie() {
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);
        List<Prodotto__c> listProds = WGC_AlldataFactory.createProdotti(2,false);

        Account acc = listAcc[0];

        UtenzeDefault__c utd = UtenzeDefault__c.getInstance();
        utd.IdGaranteDefaultMutuoControgarantitoMCC__c = acc.Id + ';' + acc.Id;
        upsert utd;
        
        Opportunity opp = listOpp[0];

        listProds[0].CodiceUnivoco__c = 'Mutuo';
        listProds[0].WGC_Tipo_Cross_Selling__c = 'IFISOpportunitaFactoring';
        listProds[1].CodiceUnivoco__c = 'MutuoControgarantitoMCC';
        listProds[1].WGC_Tipo_Cross_Selling__c = 'IFISOpportunitaFactoring';
        

        insert listProds;

        Prodotto__c prod2 = listProds[1];
        Prodotto__c prod = listProds[0];

        opp.AccountId = acc.Id;
        opp.Tipologia_Opportunit__c = 'CONC';
        insert opp;

        CtrlWizardOpportunity.WoDebitore debitore = new CtrlWizardOpportunity.WoDebitore();
        debitore.account = acc.Id;
        debitore.piva = acc.Id;

        CtrlWizardOpportunity.WoPayload payload = CtrlWizardOpportunity.editRsf(opp.Id);
        Map<String,Object> p = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(payload));
        //Map<String, Object> csJson = (Map<String,Object>)JSON.deserializeUntyped('{ "value" : [{ "closeDate":"2020-04-28", "amount":12, "tipologia":"Leasing", "product":"Factoring - Cedente_Leasing" },{ "closeDate":"2020-04-28", "amount":12, "tipologia":"diretto", "product":"Corporate Finance_Factoring - Cedente" },{ "closeDate":"2020-04-28", "amount":12, "tipologia":"Leasing", "product":"Leasing_Factoring - Cedente" }]}');
        Map<String,Object> csJson = (Map<String,Object>)JSON.deserializeUntyped('{ "value" : [{"closeDate":"2019-11-30","referente":"","agente":"test","amount":"1197","note":"test","product":"Finanziamenti_Mutuo"}]}');
        System.debug('@@@ csJSON ' + JSON.serialize(csJson.get('value')));        
        p.put('crossSelling', csJson.get('value'));

        payload.debitori = new List<CtrlWizardOpportunity.WoDebitore>{(CtrlWizardOpportunity.WoDebitore) debitore};

        List<Linea__c> lines = new List<Linea__c>();

        Linea__c line = new Linea__c();
        line.Opportunity__c = opp.Id;
        line.DivisaNew__c = '242';
        line.Mercato__c = '001';
        line.Prodotto__c = prod.Id;
        lines.add(line);

        Linea__c line2 = new Linea__c();
        line2.Opportunity__c = opp.Id;
        line2.DivisaNew__c = '242';
        line2.Mercato__c = '001';
        line2.Prodotto__c = prod2.Id;
        lines.add(line2);

        insert lines;
                
        Garanzia__c gar1 = new Garanzia__c(DivisaNew__c='242', Importo__c=100, Linea__c=line.Id, Opportunita__c=opp.Id, Tipo__c='Specifica', CodiceGaranzia__c='048', IdEsterno__c='FAnDa1oRaR');
        insert gar1;

        Map<String, Object> garanzia = new Map<String, Object>();
        garanzia.put('divisa', '242');
        garanzia.put('importo', 100);
        garanzia.put('linea', line2.Id);
        garanzia.put('opportunita', opp.Id);
        garanzia.put('copertura', 'Specifica');
        garanzia.put('tipologia', '048');
        garanzia.put('idEsterno', null);

        NDGLinea__c garante = new NDGLinea__c();
        garante.Account__c = acc.Id;
        garante.Tipo__c = 'Garante';
        garante.Opportunita__c = opp.Id;
        insert garante;

        Map<String, Object> document = new Map<String, Object>();
        document.put('id', 'NV0000002');
        document.put('title', 'WGC_ModuloRichiestaServiziFinanziari');
        document.put('codId', 'ServiziFinanziari');

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());

        Test.startTest();
        WizardOpportunityController.saveWizard(JSON.serialize(payload), 'configurazionelinee');
        WizardOpportunityController.loadGaranziaData();
        WizardOpportunityController.getGarantiEGaranzie(opp.Id);
        Garanzia__c garan = WizardOpportunityController.saveGaranzia(garanzia); // generate map for garanzia
        WizardOpportunityController.saveGarante(garante.Id, opp.Id, (String) garanzia.get('idEsterno'));
        WizardOpportunityController.saveGaranteDefault(garan, opp.Id);
        WizardOpportunityController.saveGaranteDefaultMutuoControgarantito(garan, opp.Id);
        WizardOpportunityController.hasProdottiGaranteDefault(opp.Id);
        WizardOpportunityController.validateInfoOpportunity(opp.Id);
        WizardOpportunityController.checkValidGaranzie(opp.Id);
        WizardOpportunityController.saveGaranti('', opp.Id);
        WizardOpportunityController.removeGaranzia(gar1.Id);
        //SM
        WizardOpportunityController.richiestaPrimaInfoCR(opp.Id, 'garanti');
        WizardOpportunityController.removeGarante(garante.Id);

        //SM
        WizardOpportunityController.doc08(acc.Id, JSON.serialize(document));
        WizardOpportunityController.doc11(opp.Id, 'ServiziFinanziari', 'WGC_ModuloRichiestaServiziFinanziari', '');
        //SM
        WizardOpportunityController.manageCrossSelling(JSON.serialize(p));
        WizardOpportunityController.saveCrossSellingJSON(opp.Id, '[]');
        WizardOpportunityController.checkLinesConsistency(JSON.serialize(payload), opp.Id, 'test', '', '');
        //SM
        WizardOpportunityController.checkLinesCompleteness('[{"elencoCoppie":null,"impQuotaOneri":null,"impQuotaNotifica":null,"impAccordatoLinea":5400,"desStatoLinea":"Deliberato","codStatoLinea":"003","codGestione":"N","codDivisa":"EUR","desLineaSistema":null,"codLineaSistema":null,"ragSocCedente":null,"codNdgCedente":230510,"codRapportoEst":"0570015000002444546","numLineaCredito":0},{"elencoCoppie":null,"impQuotaOneri":null,"impQuotaNotifica":null,"impAccordatoLinea":24500,"desStatoLinea":"Deliberato","codStatoLinea":"003","codGestione":"N","codDivisa":"EUR","desLineaSistema":null,"codLineaSistema":null,"ragSocCedente":null,"codNdgCedente":230510,"codRapportoEst":"0570015000002444545","numLineaCredito":0}]', opp.Id);
        WizardOpportunityController.updateLinesAfterClosing(line.Id, 'test', new WGC_Chiusura_Linea__c(Opportunit__c = opp.Id));
        Test.stopTest();
    }

    @isTest
    public static void flowCarrello3() {
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(3);
        List<Prodotto__c> listProds = WGC_AlldataFactory.createProdotti(5,false);

        listProds[1].Name = 'SBF a disponibilità immediata';
        listProds[1].Codice__c = '973';
        listProds[1].WGC_Famiglia__c = 'SBF a disponibilità immediata';
        listProds[1].WGC_Area__c = 'Servizi Bancari Corporate';
        listProds[1].CodiceUnivoco__c = 'SBF';
        listProds[1].CodiceProdotto__c = 'PSPTF';
        listProds[1].WGC_ConfigurazioneFormSubProduct__c = 'SBF';

        listProds[2].Name = 'Anticipo Export';
        listProds[2].Codice__c = '117';
        listProds[2].WGC_Famiglia__c = 'Anticipo Export';
        listProds[2].WGC_Area__c = 'Estero';
        listProds[2].CodiceUnivoco__c = 'AnticipoExport';
        listProds[2].CodiceProdotto__c = 'PCQ01';
        listProds[2].WGC_ConfigurazioneFormSubProduct__c = 'AnticipoExport';

        listProds[3].Name = 'Stand By Letter';
        listProds[3].Codice__c = '117';
        listProds[3].WGC_Famiglia__c = 'Stand By Letter';
        listProds[3].WGC_Area__c = 'Estero';
        listProds[3].CodiceUnivoco__c = 'StandByLetter';
        listProds[3].CodiceProdotto__c = 'PCQ01';
        listProds[3].WGC_ConfigurazioneFormSubProduct__c = 'StandByLetter';

        listProds[4].Name = 'Documentate all\'incasso';
        listProds[4].Codice__c = '117';
        listProds[4].WGC_Famiglia__c = 'Documentate all\'incasso';
        listProds[4].WGC_Area__c = 'Estero';
        listProds[4].CodiceUnivoco__c = 'DocIncasso';
        listProds[4].CodiceProdotto__c = 'PCQ01';
        listProds[4].WGC_ConfigurazioneFormSubProduct__c = 'DocIncasso';

        Insert listProds;

        Prodotto__c prod = listProds[0];
        Prodotto__c bcProd = listProds[1];
        Prodotto__c bceProd = listProds[2];
        Prodotto__c bce3Prod = listProds[3];
        Prodotto__c bce4Prod = listProds[4];


        Account acc = listAcc[0];

        listOpp[0].AccountId = acc.Id;
        listOpp[0].Tipologia_Opportunit__c = 'CONC';
        listOpp[0].WGC_Codice_Pratica__c = 2000;
        // insert opp;

        // listOpp[1].AccountId = acc.Id;
        // listOpp[1].Tipologia_Opportunit__c = 'CONC';
        // listOpp[1].WGC_Codice_Pratica__c = 2001;
        // listOpp[1].RecordTypeId = [SELECT id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'WGC_IFIS_International' LIMIT 1].Id;

        // listOpp[2].AccountId = acc.Id;
        // listOpp[2].Tipologia_Opportunit__c = 'CONC';
        // listOpp[2].WGC_Codice_Pratica__c = 2002;
        // listOpp[2].RecordTypeId = [SELECT id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'IFISOpportunitaFastFinance' LIMIT 1].Id;

        insert listOpp;

        Opportunity opp = listOpp[0];

        NDGLinea__c ndg = new NDGLinea__c(Account__c = acc.id, Opportunita__c = opp.id, Tipo__c = 'Debitore', RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Debitore').Id);
        insert ndg;
        ndg = [SELECT Id, FakeId__c, Account__r.NDGGruppo__c FROM NDGLinea__c WHERE Id = :ndg.Id];

        List<Linea__c> lines = new List<Linea__c>();

        Linea__c line = new Linea__c();
        // line.Name = '12345';
        line.Opportunity__c = opp.Id;
        line.DivisaNew__c = '242';
        line.Mercato__c = '001';
        line.Prodotto__c = prod.Id;
        line.WGC_Numero_Linea_Credito__c = '12345';

        lines.add(line);

        Linea__c bcLine = new Linea__c(
            Opportunity__c = opp.Id,
            DivisaNew__c = '242',
            Mercato__c = '001',
            Prodotto__c = bcProd.Id,
            Importo__c = 1000,
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Linea__c' AND DeveloperName = 'Corporate' LIMIT 1].Id
        );
        lines.add(bcLine);

        Linea__c bceLine = new Linea__c(
            Opportunity__c = opp.Id,
            DivisaNew__c = '242',
            Mercato__c = '001',
            Prodotto__c = bceProd.Id,
            Importo__c = 1000,
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Linea__c' AND DeveloperName = 'WGC_Corporate_Estero' LIMIT 1].Id
        );
        lines.add(bceLine);

        Linea__c bce3Line = new Linea__c(
            Opportunity__c = opp.Id,
            DivisaNew__c = '242',
            Mercato__c = '001',
            Prodotto__c = bce3Prod.Id,
            Durata__c = 100,
            Importo__c = 1000,
            WGC_Seleziona_CC_IFIS_Impresa_esistente__c = '120121',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Linea__c' AND DeveloperName = 'WGC_Corporate_Estero' LIMIT 1].Id
        );
        lines.add(bce3Line);

        Linea__c bce4Line = new Linea__c(
            Opportunity__c = opp.Id,
            DivisaNew__c = '242',
            Mercato__c = '001',
            Prodotto__c = bce4Prod.Id,
            Durata__c = 100,
            Importo__c = 1000,
            WGC_Seleziona_CC_IFIS_Impresa_esistente__c = '120120',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Linea__c' AND DeveloperName = 'WGC_Corporate_Estero' LIMIT 1].Id
        );
        lines.add(bce4Line);

        Insert lines;

        Parametro__c param = new Parametro__c(
            NumeroParametro__c = 'CDA02_1053',
            Name = 'Spread Anticipo Fatture'
        );

        Insert param;

        List<ParametroProdotto__c> paramProdList = new List<ParametroProdotto__c>();

        ParametroProdotto__c paramProdBC = new ParametroProdotto__c(
            Parametro__c = param.Id,
            Prodotto__c = bcProd.Id,
            Label__c = param.Name
        );

        paramProdList.add(paramProdBC);

        ParametroProdotto__c paramProdBCE = new ParametroProdotto__c(
            Parametro__c = param.Id,
            Prodotto__c = bceProd.Id,
            Label__c = param.Name
        );

        paramProdList.add(paramProdBCE);

        Insert paramProdList;

        List<PConfigurato__c> pconflist = new List<PConfigurato__c>();
        PConfigurato__c pconfBC = new PConfigurato__c(
            Linea__c = bcLine.Id,
            Codice__c = paramProdBC.Parametro__r.NumeroParametro__c,
            Valore__c = '123'
        );
        pconflist.add(pconfBC);

        PConfigurato__c pconfBCE = new PConfigurato__c(
            Linea__c = bceLine.Id,
            Codice__c = paramProdBCE.Parametro__r.NumeroParametro__c,
            Valore__c = '123'
        );
        pconflist.add(pconfBCE);

        Insert pconflist;

        CtrlWizardOpportunity.WoPayload payload = CtrlWizardOpportunity.editRSF(opp.Id);

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WizardOpportunityController.isCurrentUserSpecialista(acc.Id, opp.Id);
        // WizardOpportunityController.isCurrentUserSpecialista(acc.Id, listOpp[1].Id);
        // WizardOpportunityController.isCurrentUserSpecialista(acc.Id, listOpp[2].Id);
        WizardOpportunityController.fetchInnescoOpportunita(opp.Id);
        WizardOpportunityController.checkTitolariEsecutore(acc.Id, opp.Id);
        WizardOpportunityController.getParametri(opp.Id, null);
        WizardOpportunityController.getParametri(opp.Id, prod.Name);
        WizardOpportunityController.getQualificaDebitore(ndg.FakeId__c);
        WizardOpportunityController.getCrossSellingAssegnatariPerBU(acc.Id);
        WizardOpportunityController.asyncLoadDatiPEF(acc.Id, opp.Id);
        WizardOpportunityController.loadLineeChiuse(opp.Id);
        // WizardOpportunityController.getRevisionedParameters(line.Id);
        WizardOpportunityController.upsertNote('WGC_NoteBilancio__c', 'TEST', opp.Id);
        WizardOpportunityController.getTitolariEsecutori(acc.Id); // insert AccountContactRelation
        WizardOpportunityController.getReferenti(acc.Id);
        WizardOpportunityController.updateField('WGC_NoteBilancio__c', 'TEST_UPDATE', opp.Id);
        WizardOpportunityController.getDebitoriNewFields(opp.Id);
        WizardOpportunityController.getCRData(opp.Id);
        WizardOpportunityController.updatePresaVisione(opp.Id, 'WGC_Presa_Visione_Bilancio__c');
        WizardOpportunityController.updateNoteAutomatiche(JSON.serialize(payload));
        Test.stopTest();
    }

    @isTest
    public static void flowCarrello_WS() {
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);
        List<Prodotto__c> listProds = WGC_AlldataFactory.createProdotti(1,true);

        List<User> users = WGC_AlldataFactory.createUser(2, true);

        Account acc = listAcc[0];
        Opportunity opp = listOpp[0];
        Prodotto__c prod = listProds[0];

        opp.AccountId = acc.Id;
        opp.Tipologia_Opportunit__c = 'CONC';
        insert opp;

        Map<Object, Object> dependantPicklistValues = new Map<Object, Object>();
        dependantPicklistValues.put('controller', 'Opportunity.StageName');
        dependantPicklistValues.put('field', 'Opportunity.CategoriaChiusuraTrattativa__c');

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WizardOpportunityController.isOpportunityVisible(opp.Id);
        for (User u : users)
            System.runAs(u) {
                WizardOpportunityController.isOpportunityVisible(opp.Id);
            }
        WizardOpportunityController.checkOwnership(opp.Id);
        WizardOpportunityController.getSezioni();
        WizardOpportunityController.getAllOpportunities();
        WizardOpportunityController.getAllProducts();
        WizardOpportunityController.compareAndGroupParams();
        WizardOpportunityController.getDependentPicklistValuesFromArray(new List<Map<Object, Object>> {dependantPicklistValues});
        WizardOpportunityController.getPicklistValuesFromArray(new List<String> {'Opportunity.StageName', 'NDGLinea__c.DivisaNew__c'});
        WizardOpportunityController.getPicklistValues('Opportunity', 'StageName', false);
        WizardOpportunityController.getPicklistValues('Opportunity', 'StageName', true);
        WizardOpportunityController.getObjectLabels('Opportunity');
        WizardOpportunityController.esistePef(opp.Id);
        WizardOpportunityController.associaResponsabili(acc.Id, WizardOpportunityController.RT_DEVNAME_FACTORING);
        WizardOpportunityController.gestisciCointestazione(acc.Id);
        WizardOpportunityController.recuperaCointestazioni('', false, acc.Id);
        Test.stopTest();
    }

    @isTest
    public static void flowCarrello_WS2() {
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);

        Account acc = listAcc[0];
        Opportunity opp = listOpp[0];

        opp.AccountId = acc.Id;
        opp.Tipologia_Opportunit__c = 'CONC';
        opp.WGC_Codice_Pratica__c = 2000;
        insert opp;

        System.debug('@@@ docQuery ' + JSON.serialize([SELECT Id, MasterLabel, DeveloperName, Classe__c, Documento__c, Istituto__c, Sottoclasse__c FROM WGC_Metadati_Documentale__mdt WHERE DeveloperName = 'Scansione_privacy']));

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        // CALLBACKS
        WizardOpportunityController.pef38(12345, acc.Id);
        //WizardOpportunityController.WrapperResponseWs resp = 
        WizardOpportunityController.loadDatiPEF(acc.Id, opp.Id);
        // System.debug('@@@ resp ' + JSON.serialize(resp));
        // String respStr = JSON.serialize(resp.data);
        // Map<String,Object> mappa = (Map<String,Object>)JSON.deserialize(respStr, Map.Class);
        // WGC_WsUtils_Cart.DatiPEFResponse wrap = (WGC_WsUtils_Cart.DatiPEFResponse)mappa.get('response');
        // WizardOpportunityController.checkLinesCompleteness('[{"elencoCoppie":null,"impQuotaOneri":null,"impQuotaNotifica":null,"impAccordatoLinea":5400,"desStatoLinea":"Deliberato","codStatoLinea":"003","codGestione":"N","codDivisa":"EUR","desLineaSistema":null,"codLineaSistema":null,"ragSocCedente":null,"codNdgCedente":230510,"codRapportoEst":"0570015000002444546","numLineaCredito":0},{"elencoCoppie":null,"impQuotaOneri":null,"impQuotaNotifica":null,"impAccordatoLinea":24500,"desStatoLinea":"Deliberato","codStatoLinea":"003","codGestione":"N","codDivisa":"EUR","desLineaSistema":null,"codLineaSistema":null,"ragSocCedente":null,"codNdgCedente":230510,"codRapportoEst":"0570015000002444545","numLineaCredito":0}]', opp.Id);
        // WizardOpportunityController.updateLinesAfterClosing();
        WizardOpportunityController.richiestaPrimaInfoCR(opp.Id, 'debitori');
        WizardOpportunityController.richiestaPrimaInfoCR(opp.Id, 'cedente');
        // END - CALLBACKS
        Test.stopTest();
    }
    
    @isTest
    public static void flowCarrello_WS_NV() {
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(2);
        List<Prodotto__c> listProds = WGC_AlldataFactory.createProdotti(1,true);

        Account acc = listAcc[0];
        Opportunity opp = listOpp[0];
        Opportunity opp2 = listOpp[1];
        Prodotto__c prod = listProds[0];

        opp.AccountId = acc.Id;
        opp.Tipologia_Opportunit__c = 'CONC';
        insert opp;
        
        opp2.AccountId = acc.Id;
        opp2.Tipologia_Opportunit__c = 'RINN';
        insert opp2;

        // Contact c = WGC_AlldataFactory.createContact(1, false).get(0);
        // c.AccountId = acc.Id;
        // insert c;
        Contact c = TestUtils.creaReferente(acc);
        RecordType debRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Debitore' AND SobjectType = 'NDGLinea__c' LIMIT 1];
        NDGLinea__c deb = new NDGLinea__c(Contact__c = c.Id);
        deb.Opportunita__c = opp.Id;
        deb.Tipo__c = 'Debitore';
        deb.RecordTypeId = debRT.Id;
        insert deb;

        deb = [SELECT Id, Contact__c, Opportunita__c, Tipo__c, RecordTypeId, NDG__c FROM NDGLinea__c WHERE Id = :deb.Id];

        TestUtils.creaProdottoPCDFO();

        WGC_Linea_Prodotto__c lineaProdotto = new WGC_Linea_Prodotto__c();
        lineaProdotto.Codice_Linea_Sistema__c = '531';
        lineaProdotto.Anagrafica__c = acc.Id;
        lineaProdotto.Divisa__c = '242';
        lineaProdotto.Accordato__c = 100;
        lineaProdotto.Qualifica_Prodotto__c = 'Cliente attivo';
        lineaProdotto.Codice_stato__c = '003';
        insert lineaProdotto;
        WGC_Fido_di_Coppia__c fidoCoppia = new WGC_Fido_di_Coppia__c();
        fidoCoppia.Linea__c = lineaProdotto.Id;
        fidoCoppia.Codice_famiglia_coppia__c = 'C';
        fidoCoppia.Numero_Linea_Credito__c = lineaProdotto.Codice_Linea_Sistema__c;
        fidoCoppia.COD_TIPO_CAR__c = 'N';
        fidoCoppia.Codice_stato_linea__c = '003';
        fidoCoppia.NDG_Debitore__c = deb.NDG__c;
        fidoCoppia.Name = '1234567890';
        fidoCoppia.Debitore__c = acc.Id;
        fidoCoppia.Termini_di_pagamento__c = 100;
        fidoCoppia.Importo_Plafond_Prosolvendo__c = 50000;
        fidoCoppia.Importo_Plafond_Prosoluto__c = 25000;
        insert fidoCoppia;

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WizardOpportunityController.cloneOpportunity(new List<String> {opp.Id});
        WizardOpportunityController.cloneOpportunity(new List<String> {opp2.Id});

        WizardOpportunityController.invioDocumentiNuovaVendita(opp.Id, acc.Id);
        WizardOpportunityController.esisteTitolareEffettivo(opp.Id);
        WizardOpportunityController.inviaNuovaVendita(opp.Id);
        Test.stopTest();
    }

    @isTest
    public static void other_ws(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);
        List<Prodotto__c> listProds = WGC_AlldataFactory.createProdotti(1,true);

        Account acc = listAcc[0];
        System.debug('@@@ acc ' + acc.NDGGruppo__c);
        Opportunity opp = listOpp[0];
        Prodotto__c prod = listProds[0];

        opp.AccountId = acc.Id;
        opp.Tipologia_Opportunit__c = 'CONC';
        insert opp;

        Contact c = TestUtils.creaReferente(acc);
        RecordType debRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Debitore' AND SobjectType = 'NDGLinea__c' LIMIT 1];
        NDGLinea__c deb = new NDGLinea__c(Contact__c = c.Id);
        deb.Opportunita__c = opp.Id;
        deb.Tipo__c = 'Debitore';
        deb.RecordTypeId = debRT.Id;
        insert deb;

        deb = [SELECT Id, Contact__c, Opportunita__c, Tipo__c, RecordTypeId, NDG__c FROM NDGLinea__c WHERE Id = :deb.Id];

        WGC_Linea_Prodotto__c lineaProdotto = new WGC_Linea_Prodotto__c();
        lineaProdotto.Codice_Linea_Sistema__c = '531';
        lineaProdotto.Anagrafica__c = acc.Id;
        lineaProdotto.Divisa__c = '242';
        lineaProdotto.Accordato__c = 100;
        lineaProdotto.Qualifica_Prodotto__c = 'Cliente attivo';
        insert lineaProdotto;
        WGC_Fido_di_Coppia__c fidoCoppia = new WGC_Fido_di_Coppia__c();
        fidoCoppia.Linea__c = lineaProdotto.Id;
        fidoCoppia.Codice_famiglia_coppia__c = 'C';
        fidoCoppia.Numero_Linea_Credito__c = lineaProdotto.Codice_Linea_Sistema__c;
        fidoCoppia.COD_TIPO_CAR__c = 'N';
        fidoCoppia.Codice_stato_linea__c = '003';
        fidoCoppia.NDG_Debitore__c = deb.NDG__c;
        fidoCoppia.Name = '1234567890';
        fidoCoppia.Debitore__c = acc.Id;
        fidoCoppia.Termini_di_pagamento__c = 100;
        fidoCoppia.Importo_Plafond_Prosolvendo__c = 50000;
        fidoCoppia.Importo_Plafond_Prosoluto__c = 25000;
        insert fidoCoppia;

        Linea__c line = new Linea__c();
        line.Opportunity__c = opp.Id;
        line.DivisaNew__c = '242';
        line.Mercato__c = '001';
        line.Prodotto__c = prod.Id;
        line.WGC_Numero_Linea_Credito__c = '12345';
        insert line;


        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        
        Test.startTest();
        WizardOpportunityController.docCheckListOpportunity(opp.Id);
        WizardOpportunityController.docCheckListAccount(acc.Id);
        WizardOpportunityController.getRevisionedParameters(line.Id);
        Test.stopTest();
    }

    @isTest
    public static void get_methods(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);
        List<Prodotto__c> listProds = WGC_AlldataFactory.createProdotti(1,false);

        listProds[0].WGC_Area__c = 'Factoring - Fiscale';
        listProds[0].WGC_Famiglia__c = 'ATD - IVA';
        listProds[0].Codice__c = '364';
        listProds[0].Notifica__c = true;
        listProds[0].Maturity__c = false;
        listProds[0].Servizio__c = 'ATDFiscale';
        Insert listProds;

        Account acc = listAcc[0];
        System.debug('@@@ acc ' + acc.NDGGruppo__c);
        Opportunity opp = listOpp[0];
        Prodotto__c prod = listProds[0];

        opp.AccountId = acc.Id;
        opp.Tipologia_Opportunit__c = 'CONC';
        opp.HasFactFisc__c = true;
        opp.WGC_Prodotti_Selezionati__c = 'ATD - IVA';
        insert opp;

        WGC_Linea_Prodotto__c lineaProdotto = new WGC_Linea_Prodotto__c();
        lineaProdotto.Codice_Linea_Sistema__c = '531';
        lineaProdotto.Anagrafica__c = acc.Id;
        lineaProdotto.Divisa__c = '242';
        lineaProdotto.Accordato__c = 100;
        lineaProdotto.Qualifica_Prodotto__c = 'Cliente attivo';
        insert lineaProdotto;

        Ateco__c ateco = new Ateco__c(Cedacri__c = '123', WGC_Esclusione_BEI__c = true, WGC_Esclusione_Fondo__c = false);
        Insert ateco;

        Contact c = TestUtils.creaReferente(acc);
        RecordType debRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Debitore' AND SobjectType = 'NDGLinea__c' LIMIT 1];
        NDGLinea__c deb = new NDGLinea__c(Contact__c = c.Id);
        deb.Opportunita__c = opp.Id;
        deb.Tipo__c = 'Debitore';
        deb.RecordTypeId = debRT.Id;
        deb.DivisaNew__c = '242';
        deb.WGC_Mercato__c = '001';
        deb.IsAutoAdd__c = true;
        deb.ANotifica__c = true;
        deb.Maturity__c = false;
        insert deb;

        deb = [SELECT Id, Contact__c, Opportunita__c, Tipo__c, RecordTypeId, NDG__c FROM NDGLinea__c WHERE Id = :deb.Id];

        Map<String,Sobject> mappaDeb = new Map<String,Sobject>([SELECT Id, Name, Account__c, Contact__c, ANotifica__c, Maturity__c, IsAutoAdd__c, DivisaNew__c, WGC_Mercato__c, Mercato__c, Tipo__c FROM NDGLinea__c WHERE Opportunita__c =: opp.Id]);
        List<Credito__c> crediti = WGC_AllDataFactory.createCrediti(1, opp.Id, null);
        Insert crediti;

        Map<String,String> mappaOpty = new Map<String,String>();
        mappaOpty.put(opp.Id, opp.StageName);

        CtrlWizardOpportunity.WoPayload payload = CtrlWizardOpportunity.editRsf(opp.Id);

        Test.startTest();
        WizardOpportunityController.checkExistingPlafond(opp.Id);
        WizardOpportunityController.getEsclusione('123');
        WizardOpportunityController.savePConfigurati('[{ "id": null, "valore": 1, "linea": "aaa", "codice": "SF12" }]');
        WizardOpportunityController.getCurrentUser();
        WizardOpportunityController.saveDataFactFisc(deb, opp);
        WizardOpportunityController.saveFactFisc(payload, mappaDeb);
        WizardOpportunityController.saveEventiNegativiInfo(opp);
        WizardOpportunityController.updateStageNameAsync(mappaOpty);
        WizardOpportunityController.getDatiSpeseIstruttoria(opp.Id);
        WizardOpportunityController.openOpportunity(opp.Id);
        WizardOpportunityController.checkIfOpenable(opp.Id);
        WizardOpportunityController.saveCrediti(opp.Id, crediti);
        Test.stopTest();
    }

    @isTest
    public static void wrapperclass(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();

        Test.startTest();
        WizardOpportunityController.Garanzia grz = new WizardOpportunityController.Garanzia();
        WizardOpportunityController.Garante gnt = new WizardOpportunityController.Garante();
        WizardOpportunityController.ParamWrapper pw = new WizardOpportunityController.ParamWrapper();

        Test.stopTest();
    }
    
    @isTest
    public static void getCCData_test(){
        WGC_AllDataFactory.createUtenzaDefault();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);
        List<Prodotto__c> listProds = WGC_AlldataFactory.createProdotti(1,false);
        
        Account acc = listAcc[0];
        Opportunity opp = listOpp[0];
        Prodotto__c prod = listProds[0];

        opp.AccountId = acc.Id;
        insert opp;
        
        WizardOpportunityController.WrapperResponseWs ws = WizardOpportunityController.getCCData(opp.Id);

        
    }
    
    @isTest
    public static void getCondizioniBC_test(){
        WGC_AllDataFactory.createUtenzaDefault();
        List<Linea__c> listLinee = WGC_AllDataFactory.createLinee(1,true);

        String cod = [SELECT Id, CodiceUnivoco__c FROM Prodotto__c WHERE Id =: listLinee[0].Prodotto__c ].CodiceUnivoco__c;
        
        List<WGC_Condizioni_Banca_Corporate__mdt> w = WizardOpportunityController.getCondizioniBC(listLinee[0].Opportunity__c, cod);
    }
    
    @isTest
    public static void manageCreditsUniqueCode_test(){
        WGC_AllDataFactory.createUtenzaDefault();
        
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);
        List<Prodotto__c> listProds = WGC_AlldataFactory.createProdotti(1,false);
        
        Account acc = listAcc[0];
        Opportunity opp = listOpp[0];
        Prodotto__c prod = listProds[0];

        opp.AccountId = acc.Id;
        opp.HasFactFisc__c = true;
        insert opp;
        
        String w = WizardOpportunityController.manageCreditsUniqueCode(opp.Id);
        
        
    }
    
    @isTest
    public static void saveCorporateLines_test(){
        
        WGC_AllDataFactory.createUtenzaDefault();
        List<Linea__c> listLinee = WGC_AllDataFactory.createLinee(5,true);
        
        Prodotto__c p = WGC_AlldataFactory.createProdotti(1,false).get(0);
    	p.CodiceUnivoco__c='AnticipoFatture';
    	insert p;
        
        Prodotto__c p1 = WGC_AlldataFactory.createProdotti(1,false).get(0);
    	p1.CodiceUnivoco__c='FidoAnticipoFatture';
    	insert p1;
        
        Prodotto__c p2 = WGC_AlldataFactory.createProdotti(1,false).get(0);
    	p2.CodiceUnivoco__c='SBF';
    	insert p2;
        
        Prodotto__c p3 = WGC_AlldataFactory.createProdotti(1,false).get(0);
    	p3.CodiceUnivoco__c='FIDOSBF';
    	insert p3;
        
        Prodotto__c p4 = WGC_AlldataFactory.createProdotti(1,false).get(0);
    	p4.CodiceUnivoco__c='ContoAnticipiPTF';
    	insert p4;
            
        Prodotto__c p5 = WGC_AlldataFactory.createProdotti(1,false).get(0);
    	p5.CodiceUnivoco__c='IfisImpresa';
    	insert p5;
        
        String json = '{"pbc": [{"importo": 123456789, "tipo": "AnticipoFatture"},{"importo": 123456789, "tipo": "SBF", "tipologiaConto": "Conto Doppio"}],"opportunityId":"' + listLinee[0].Opportunity__c + '"}';
        
        WizardOpportunityController.WrapperResponseWs w = WizardOpportunityController.saveCorporateLines(json);
        
        
    }

    // @isTest
    // public static void test_blocco1(){
    //     WGC_AllDataFactory.createUtenzaDefault();
    //      List<WGC_Linea_Prodotto__c> listLinProd = WGC_AlldataFactory.createLineaProdotti2(2,true);
    //     List<WGC_Fido_di_Coppia__c> listFidoCoppia = WGC_AlldataFactory.createFidoCoppia(2,false);
    //     Account a = [SELECT Id, Name, NDGGruppo__c  FROM Account];
    //     listFidoCoppia.get(0).Linea__c=listLinProd.get(0).Id;
    //     listFidoCoppia.get(0).Debitore__c = a.Id;
    //     listFidoCoppia.get(1).Linea__c=listLinProd.get(0).Id;
    //     listFidoCoppia.get(1).Debitore__c = a.Id;
    //     listFidoCoppia.get(1).NDG_Debitore__c = a.NDGGruppo__c;
    //     insert listFidoCoppia;
    //     List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);
    //     Prodotto__c p = WGC_AlldataFactory.createProdotti(1,false).get(0);
    //     p.Codice__c='123';
    //     insert p;
    //     listOpp.get(0).AccountId = a.Id;
    //     listOpp.get(0).Tipologia_Opportunit__c = 'CROSS';
    //     insert listOpp;
    //     List<String> lstIdOpp = new List<String>();
    //     lstIdOpp.add(listOpp.get(0).Id);
    //     User u = [SELECT Id, Qualifica_Utente__c FROM User WHERE Id = :UserInfo.getUserId()];


    //     List<AccountContactRelation> accCont = [SELECT Id, Contact.Name, Contact.WGC_Censimento_MAV__c, WGC_Selezionato__c, WGC_Ruolo_Pratica__c, WGC_Tipologia_Titolare_Effettivo__c FROM AccountContactRelation];
    //     accCont.get(0).WGC_Selezionato__c = true;
    //     accCont.get(0).WGC_Ruolo_Pratica__c = 'J1;Z1';
    //     update accCont;
    //     // System.debug('Query: '+[SELECT Id, Codice__c, WGC_Famiglia__c, WGC_Area__c FROM Prodotto__c]);
    //     // System.debug('Querybis: '+[SELECT Id, Name, Anagrafica__c, Divisa__c, Codice_Linea_Sistema__c FROM WGC_Linea_Prodotto__c]);
    //     Test.startTest();
    //     WizardOpportunityController.cloneOpportunity(lstIdOpp);
    //     WizardOpportunityController.getOpportunities(a.Id);
    //     WizardOpportunityController.getFactoringOpportunities(a.Id);
    //     WizardOpportunityController.getOpportunityRecordType(listOpp.get(0).Id);
    //     WizardOpportunityController.getProducts(listOpp.get(0).Id);
    //     u.Qualifica_Utente__c = 'IFISOpportunitaFactoring';
    //     u.Qualifica_Utente__c = 'IFIS_International';
    //     update u;
    //     WizardOpportunityController.getProducts(listOpp.get(0).Id);
    //     u.Qualifica_Utente__c = 'Leasing EF';
    //     p.WGC_Tipo_Cross_Selling__c='IFISOpportunitaFactoring';
    //     update p;
    //     update u;
    //     WizardOpportunityController.getProducts(listOpp.get(0).Id);

    //     WizardOpportunityController.getUserInfo();

    //     WizardOpportunityController.getParametriEConfigurazioniLinee(listOpp.get(0).Id);

    //     WizardOpportunityController.getTitolariEsecutori(a.Id);
    //     Test.stopTest();
    // }

    // @isTest
    // public static void test_blocco2(){
    //     WGC_AllDataFactory.createUtenzaDefault();
    //     WGC_AllDataFactory.creaImpServ();
    //     WGC_AllDataFactory.createLagKey();

    //     List<Linea__c> linee = WGC_AlldataFactory.createLinee(1,true);
    //     List<Prodotto__c> listProd = [SELECT ID FROM Prodotto__c];
    //     Opportunity o = [SELECT Id,AccountId,Tipologia_Opportunit__c FROM Opportunity LIMIT 1];
    //     o.Tipologia_Opportunit__c= 'RINN';
    //     update o;
    //     String strListProd = JSON.serialize(listProd);
    //     CtrlWizardOpportunity.WoPayload wopl = new CtrlWizardOpportunity.WoPayload();
    //     wopl.opportunityId=o.Id; 
    //     String strPayload = JSON.serialize(wopl);
    //     Account a = [SELECT Id FROM Account LIMIT 1];
    //     System.debug('Query che esplode: '+[SELECT Id, WGC_Numero_Linea_Credito__c, Opportunity__c, Opportunity__r.Account.CodiceIstituto3N__c, Opportunity__r.Account.NDGGruppo__c FROM Linea__c WHERE Id = :linee.get(0).Id]);
    //     User u = [SELECT Id, Name,NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
    //     u.NDGGruppo__c ='107499';
    //     update u ;
    //     String strStep = 'categorie,debitori,configurazioneicarmanuali,garanzie';
    //     List<String> prova = strStep.split(',');
        
    //     System.debug('@Prova: '+prova.get(0).split(','));
    //     Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
    //     Test.startTest();
    //     WizardOpportunityController.getRevisionedParameters(linee.get(0).Id); 
    //     WizardOpportunityController.getBilancioCedente(o.Id);
    //     WizardOpportunityController.getPayload(o.Id);
    //     WizardOpportunityController.getPayload(a.Id);
    //     WizardOpportunityController.inviaNuovaVendita(o.Id);
    //     // WizardOpportunityController.generatePEF41Callout(o, u);
        
    //     //WizardOpportunityController.closeOpportunity(o.Id,'Vinta');
    //     // WizardOpportunityController.deleteOpp (o.Id,strListProd);
    //     // WizardOpportunityController.deleteOpp (a.Id,strListProd);
    //     WizardOpportunityController.getServizi();
    //     WizardOpportunityController.getDiviseOptions();
    //     WizardOpportunityController.getTipologieMutui();
    //     WizardOpportunityController.getDebitoriPerLinea(o.Id);    
    //     WizardOpportunityController.getReferenti(a.Id);
    //     WizardOpportunityController.loadGaranziaData();
    //     WizardOpportunityController.getGarantiEGaranzie(o.Id);   
        
    //     Test.stopTest();
    // }

    // @isTest
    // public static void test_blocco3(){
    //     WGC_AllDataFactory.createUtenzaDefault();
    //     WGC_AllDataFactory.creaImpServ();
    //     WGC_AllDataFactory.createLagKey();

    //     User u = [SELECT Id, Name,NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
    //     u.NDGGruppo__c ='107499';
    //     update u ;


    //     List<NDGLinea__c> attori = WGC_AllDataFactory.createAttori2(2,false);
    //     attori.get(0).FakeId__c ='7xKPy4UZKQ';
    //      attori.get(0).Tipo__c = 'Esecutore adeguata verifica';
    //     attori.get(1).FakeId__c ='CXzQNeuVIQ';
    //     attori.get(0).ANotifica__c = true;
    //     attori.get(1).Maturity__c = true;

    //     Account a = [SELECT Id, WGC_Specialista_Factoring__c FROM Account LIMIT 1];
    //     a.WGC_Specialista_Factoring__c =u.id;
    //     a.WGC_Gestore_Debitore__c =u.id;        
    //     update a;

    //     Opportunity o = [SELECT Id,AccountId,IsOppNSA__c FROM Opportunity LIMIT 1];
    //     o.WGC_Codice_Pratica__c=12345;
    //     insert attori;
    //     update o;

    //     List<AccountContactRelation> acr = [SELECT Id, ContactId, Contact.Name, Contact.WGC_Censimento_MAV__c, WGC_Selezionato__c, WGC_Ruolo_Pratica__c, WGC_Tipologia_Titolare_Effettivo__c FROM AccountContactRelation];
    //     acr.get(0).WGC_Selezionato__c=true;
    //     acr.get(0).WGC_Ruolo_Pratica__c = 'J1;Z1';
        
    //     update acr;
    //     List<CtrlWizardOpportunity.WoDebitore> listWoDeb = new List<CtrlWizardOpportunity.WoDebitore>();
    //     CtrlWizardOpportunity.WoDebitore wodebitore = new CtrlWizardOpportunity.WoDebitore();
    //     wodebitore.account=a.Id;
    //     listWoDeb.add(wodebitore);
    //     CtrlWizardOpportunity.WoPayload wopl = new CtrlWizardOpportunity.WoPayload(); 
    //     wopl.debitori=listWoDeb;
    //     wopl.valutazioniPortafoglio=listWoDeb;
    //     wopl.opportunityId = o.Id;
    //     //wopl.valutazionePortafoglio=true;
    //     String strPayload = JSON.serialize(wopl);

    //     List<WGC_Centrale_Rischi__c> cr= WGC_AllDataFactory.createCentraleRischi(1);
    //     cr.get(0).Anagrafica__c=a.Id;
    //     cr.get(0).Data_ultima_rilevazione__c =Date.today().addDays(-5);
    //     insert cr;

        

    //     Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
    //     System.debug('@Query -> '+[SELECT
    //                                 Id,
    //                                 WGC_Specialista_Factoring__c,
    //                                 WGC_Specialista_Factoring__r.NDGGruppo__c,
    //                                 WGC_Specialista_Factoring__r.Ruolo_Knet__c,
    //                                 WGC_Specialista_IFIS_International__c,
    //                                 WGC_Specialista_IFIS_International__r.NDGGruppo__c,
    //                                 WGC_Specialista_IFIS_International__r.Ruolo_Knet__c,
    //                                 WGC_Gestore_Debitore__r.NDGGruppo__c,
    //                                 WGC_Gestore_Debitore__r.Ruolo_Knet__c,
    //                                 Presentatore__r.NDGGruppo__c,
    //                                 Presentatore__r.Ruolo_Knet__c,
    //                                 NDGGruppo__c
    //                             FROM Account WHERE Id =: a.Id]);
    //     Test.startTest();
    //     WizardOpportunityController.updateDebitori(strPayload, null);
    //     WizardOpportunityController.updateDebitori(strPayload, '');
    //     WizardOpportunityController.getDebitoriNewFields(o.Id);
    //     WizardOpportunityController.richiestaPrimaInfoCR(o.Id,'cedente');
    //     WizardOpportunityController.richiestaPrimaInfoCR(o.Id,'debitori');
    //     WizardOpportunityController.checkIsValidCR(o.Id);
    //     WizardOpportunityController.docCheckListOpportunity(o.Id);
    //     WizardOpportunityController.getCrossSellingAssegnatariPerBU(a.Id);
    //     WizardOpportunityController.loadDatiPEF(a.Id,o.Id);
    //     WizardOpportunityController.asyncLoadDatiPEF(a.Id,o.Id);
    //     WizardOpportunityController.isCurrentUserSpecialista(a.Id,o.Id);
    //     WizardOpportunityController.fetchInnescoOpportunita(o.Id);
    //     // WizardOpportunityController.esistePef(o.Id);
    //     WizardOpportunityController.checkIfDebitoreAlreadyExists(wopl);
    //     Test.stopTest();
    // }

    // @isTest
    // public static void test_blocco4(){
    //     WGC_AllDataFactory.createUtenzaDefault();
    //     WGC_AllDataFactory.creaImpServ();
    //     WGC_AllDataFactory.createLagKey();
    //     List<NDGLinea__c> lstAtt = WGC_AllDataFactory.createAttori2(2,false);

    //     insert new Contact(LastName  = 'A');
        
    //     Contact c =[SELECT Id FROM Contact WHERE LastName =: 'A'];
    //     lstAtt.get(0).Contact__c =c.Id;
    //     insert lstAtt;
    //     lstAtt = [SELECT ID, Commessa__c, Tipologia_di_Fornitura__c, Appalto_d_opera__c, Tipologia_Controparte__c FROM NDGLinea__c];

    //     Account a = [SELECT Id FROM Account LIMIT 1];
    //     Opportunity o = [SELECT Id,AccountId FROM Opportunity LIMIT 1];

       

    //     insert new Garanzia__c(IdEsterno__c='Kghc5tPHP2',Opportunita__c=o.Id);
    //     Garanzia__c garanzia = [SELECT Id, IdEsterno__c FROM Garanzia__c];

    //     Test.startTest();
    //     WizardOpportunityController.pef38(null,a.Id);
    //     WizardOpportunityController.autoCompletionContesto('abcd1234',lstAtt.get(0));
    //     WizardOpportunityController.manageGaranzieFakeIds(garanzia);
    //     WizardOpportunityController.saveCrossSellingJSON(o.Id,'{"closeDate":"2019-05-31","tipologia":"Leasing","business":"AGR","referente":"0031x00000DJMzGAAX","amount":"150000","product":"Leasing_Leasing"}');
    //     Test.stopTest();
    // }

    // @isTest
    // public static void test_blocco5(){
    //     WGC_AllDataFactory.createUtenzaDefault();
    //     WGC_AllDataFactory.creaImpServ();
    //     WGC_AllDataFactory.createLagKey();
    //     List<Opportunity> listOpty = WGC_AlldataFactory.createOpportunity2(1);
    //     insert listOpty;
    //     List<WizardOpportunityController.WrapperProduct> InputList = new List<WizardOpportunityController.WrapperProduct>();
    //     WizardOpportunityController.WrapperProduct wp = new WizardOpportunityController.WrapperProduct();
    //     wp.Name ='Test';
    //     InputList.add(wp);
    //     String strInputList = JSON.serialize(InputList);
    //     // System.debug('@Test -> '+);

    //     List<Object> listParams = WizardOpportunityController.getObjectLabels('Account').values();
    //     List<String> listParams2 = (List<String>) listParams;
    //     Test.startTest();
    //     WizardOpportunityController.setProductInOpp(listOpty.get(0).id, strInputList);
    //     WizardOpportunityController.esisteTitolareEffettivo(listOpty.get(0).id);
    //     WizardOpportunityController.getSezioni();
    //     WizardOpportunityController.getAllOpportunities();
    //     WizardOpportunityController.getAllProducts();
    //     WizardOpportunityController.compareAndGroupParams();
    //     // WizardOpportunityController.getDependentPicklistValuesFromArray(listParams);
    //     // WizardOpportunityController.getPicklistValuesFromArray(listParams2);
    //     Test.stopTest();

    // }

    // @isTest
    // public static void test_checkTitolariEsecutore(){
    //     Test.startTest();
    //     WGC_AllDataFactory.createUtenzaDefault();
    //     WGC_AllDataFactory.createAttori2(1,true);
    //     Account a = [SELECT Id FROM Account LIMIT 1];
    //     Contact c = [SELECT Id, LastName, FirstName, NDGGruppo__c, CF__c , NaturaGiuridica__c, LuogoNascita__c , NumeroDoc__c , EnteEmitettenteDocumento__c, DataScadenzaDoc__c, SAE__c, TAECode__c,WGC_Censimento_MAV__c FROM Contact LIMIT 1];
    //     c.FirstName = c.LastName;
    //     c.NDGGruppo__c = '4183543';
    //     C.CF__c ='AAABBB00A11B123C';
    //     c.NaturaGiuridica__c ='PF';
    //     c.LuogoNascita__c = 'MILANO';
    //     c.NumeroDoc__c = 'AB1234567';
    //     c.EnteEmitettenteDocumento__c ='COMUNE';
    //     c.DataScadenzaDoc__c = Date.newInstance(2022,02,22);
    //     c.SAE__c = '600';
    //     c.TAECode__c = '984';
    //     update c;
    //     Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
    //     List<NDGLinea__c> listAttori = [SELECT Id, Contact__c, Opportunita__c, Tipo__c FROM NDGLinea__c LIMIT 1];
    //     listAttori.get(0).Contact__c = c.Id;
    //     listAttori.get(0).Tipo__c = 'Esecutore adeguata verifica';
    //     // listAttori.get(0).Opportunita__c =o.Id;
    //     update listAttori;
    //     System.debug('@Qua c -->'+JSON.serialize(c = [SELECT Id, LastName, FirstName, NDGGruppo__c, CF__c , NaturaGiuridica__c, LuogoNascita__c , NumeroDoc__c , EnteEmitettenteDocumento__c, DataScadenzaDoc__c, SAE__c, TAECode__c,WGC_Censimento_MAV__c FROM Contact LIMIT 1]));
        
    //     List<AccountContactRelation> acr = [SELECT Id, ContactId, Contact.Name, Contact.WGC_Censimento_MAV__c, WGC_Selezionato__c, WGC_Ruolo_Pratica__c, WGC_Tipologia_Titolare_Effettivo__c FROM AccountContactRelation];
    //     acr.get(0).WGC_Selezionato__c=true;
    //     acr.get(0).WGC_Ruolo_Pratica__c = 'J;Z1';
    //     update acr;

        
    //     // WizardOpportunityController.loadLineeChiuse(o.Id);
    //     WizardOpportunityController.checkTitolariEsecutore(a.Id, o.Id);
    //     Test.stopTest();
    // }


    // @isTest
    // public static void test_associaResponsabili(){
    //     Test.startTest();
    //     WGC_AllDataFactory.createUtenzaDefault();
    //     WGC_AllDataFactory.creaImpServ();
    //     WGC_AllDataFactory.createLagKey();

    //     User u = [SELECT Id, Name,NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
    //     u.NDGGruppo__c ='107499';
    //     update u ;


    //     List<NDGLinea__c> attori = WGC_AllDataFactory.createAttori2(2,false);
    //     attori.get(0).FakeId__c ='7xKPy4UZKQ';
    //      attori.get(0).Tipo__c = 'Esecutore adeguata verifica';
    //     attori.get(1).FakeId__c ='CXzQNeuVIQ';
    //     attori.get(0).ANotifica__c = true;
    //     attori.get(1).Maturity__c = true;

    //     Account a = [SELECT Id, WGC_Specialista_Factoring__c FROM Account LIMIT 1];
    //     a.WGC_Specialista_Factoring__c =u.id;
    //     a.WGC_Gestore_Debitore__c =u.id;        
    //     update a;

    //     WizardOpportunityController.associaResponsabili(a.Id,'IFISOpportunitaFactoring');
    //     Test.stopTest();
    // }
}