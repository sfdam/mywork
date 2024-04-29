@isTest
public class WGC_Documenti_Controller_Test {

    @isTest
    public static void test_Metodi_Account(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createAccount(1,true);
        Account a = [SELECT Id, Name, WGC_Semaforo_CLC__c, WGC_Semaforo_Gianos__c, EventiNegativiProtesti__c, EventiNegativiProcedureConcorsuali__c,EventiNegativiPregiudizievoli__c, EventiNegativiCIGS__c, EventiNegativiAllarmiQuote__c, EventiNegativiGlobale__c, WGC_Gruppo_frm__c, WGC_Alert_KPI_Centrale_Rischi__c, 
                ConsensoAllaProfilazione__c, PIVA__c, CF__c, ProvinciaCCIAA__c, REA__c, EmailPEC__c, BillingStreetType__c, BillingStreetNumber__c, BillingStreetName__c, EmailPECFatturaElettronica__c, CodiceDestinatario__c, IndirizzoPerInvioCorrispondenza__c, 
                BillingStreet, BillingPostalCode, BillingState, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, Phone, Fax, 
                Email__c, SIA__c, ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c, ConsensoAttivitaPromozionaleTerzi__c, 
                ConsensoAttivitaPromRicercheMercato__c, ConsensoSoloModalitaTradizionali__c, BillingCity, BillingCountry, ShippingCountry, ShippingStreetType__c, ShippingStreetNumber__c, ShippingStreetName__c, TelefonoPrefisso__c
                FROM Account LIMIT 1];
        List<AdeguataVerifica__c> listAD = WGC_AllDataFactory.createAdeguataVerifica2(1,true,a.Id);
        AdeguataVerifica__c mav =[SELECT Id, NaturaRapportoContinuativoFD__c, ScopoFD11__c, Account__c, ScopoFD12__c, ScopoFD13__c, ScopoFD14__c, ScopoFD15__c, ScopoFD16__c, ScopoFD17__c, ScopoFD18__c, ScopoFD19__c, OrigineFondi1__c, OrigineFondi2__c, OrigineFondi3__c, OrigineFondi4__c, OrigineFondiAltro__c FROM AdeguataVerifica__c LIMIT 1];

        //String strAcc = JSON.serialize(a);
        WGC_Documenti_Controller.Origine origine = new WGC_Documenti_Controller.Origine(); 
        Test.startTest();
        WGC_Documenti_Controller.getDocumentData(a.Id);
        WGC_Documenti_Controller.getOptyFactoring(a.id);
        WGC_Documenti_Controller.getOptyFactoring(null);
        WGC_Documenti_Controller.docCheckList(a.id);
        WGC_Documenti_Controller.docCheckList(null);
        origine.generateOrigine(a, mav);
        Test.stopTest();
    }

    @isTest
    public static void test_Metodi_Contact(){
        WGC_AllDataFactory.createUtenzaDefault();
        Contact c = WGC_AllDataFactory.createContact(1,true).get(0);
        c.DataInserimentoConsensi__c = datetime.now();
        update c;
        c = [SELECT Id, Name, ConsensoAllaProfilazione__c, ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c, ConsensoAttivitaPromozionaleTerzi__c, ConsensoAttivitaPromRicercheMercato__c, ConsensoSoloModalitaTradizionali__c, Account.Name, MailingCity FROM Contact LIMIT 1];
        
        WGC_Documenti_Controller.Origine origine = new WGC_Documenti_Controller.Origine(); 
        Test.startTest();
        WGC_Documenti_Controller.getContactPrivacy(c.Id);
        WGC_Documenti_Controller.docCheckList(c.id);
        origine.generateOrigine(c);
        Test.stopTest();
    }

    @isTest
    public static void test_Metodi_Opportunity(){
        WGC_AllDataFactory.createUtenzaDefault();
        List<NDGLinea__c> attori = WGC_AllDataFactory.createAttori2(1,true);
        // Opportunity o = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        // o.WGC_Assuntore__c = true;
        // o.WGC_Azienda_Cedente__c = o.AccountId;
        // Update o;
        Opportunity o = [SELECT Id, AccountId, WGC_Assuntore__c, WGC_Azienda_Cedente__c FROM Opportunity WHERE Id =: attori[0].Opportunita__c LIMIT 1];
        o.WGC_Assuntore__c = true;
        o.WGC_Azienda_Cedente__c = o.AccountId;
        update o;

        AccountContactRelation acr = [SELECT Id, WGC_Ruolo__c, WGC_Ruolo_Pratica__c FROM AccountContactRelation WHERE AccountId =: o.AccountId LIMIT 1];
        acr.WGC_Ruolo_Pratica__c = 'J;Z1';
        update acr;
        Test.startTest();
        WGC_Documenti_Controller.docCheckListCarrello(o.Id);
        WGC_Documenti_Controller.docCheckListCarrello(null);
        WGC_Documenti_Controller.docCheckListOpportunity(o.Id);
        WGC_Documenti_Controller.docCheckListOpportunity(null);
        WGC_Documenti_Controller.getAttoriPratica(o.Id);
        WGC_Documenti_Controller.getAttoriPratica(null);
        WGC_Documenti_Controller.generateParamsPratica('IDCFLOW', o);
        WGC_Documenti_Controller.getDocsAssuntore(o.Id);
        WGC_Documenti_Controller.getDocsAssuntore(null);
        Test.stopTest();
    }

    @isTest
    public static void test_Metodi_Doc(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.createAttori2(1,true);
        Account a = [SELECT Id, Name, WGC_Semaforo_CLC__c, WGC_Semaforo_Gianos__c, EventiNegativiProtesti__c, EventiNegativiProcedureConcorsuali__c,EventiNegativiPregiudizievoli__c, EventiNegativiCIGS__c, EventiNegativiAllarmiQuote__c, EventiNegativiGlobale__c, WGC_Gruppo_frm__c, WGC_Alert_KPI_Centrale_Rischi__c, 
                ConsensoAllaProfilazione__c, ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c, ConsensoAttivitaPromozionaleTerzi__c, ConsensoAttivitaPromRicercheMercato__c, ConsensoSoloModalitaTradizionali__c, BillingCity, TelefonoPrefisso__c
                FROM Account LIMIT 1];
        Contact c = [SELECT Id, LastName FROM Contact LIMIT 1];
        Opportunity o = [SELECT Id, AccountId, Account.NDGGruppo__c FROM Opportunity LIMIT 1];
        o.IdCartella__c='881/00006/2019/000002';
        update o;

        WGC_Documenti_Controller.DocDownload docDownloadTest1 = new WGC_Documenti_Controller.DocDownload();
        WGC_Documenti_Controller.DocDownload docDownloadTest2 = new WGC_Documenti_Controller.DocDownload();
        docDownloadTest2.id = 'IdTest';
        docDownloadTest2.codId = 'Privacy';
        docDownloadTest2.title =null;
        //EX0000200
        String document1 = JSON.serialize(docDownloadTest1);
        String document2 = JSON.serialize(docDownloadTest2);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        
        Test.startTest();
        WGC_Documenti_Controller.doc08(a.Id, document1);
        WGC_Documenti_Controller.doc08(a.Id, document2);


        WGC_Documenti_Controller.doc11(a.Id,'Privacy','Test', 'IT');
        WGC_Documenti_Controller.doc11(a.Id,'AdeguataVerifica','Test', 'IT');
        WGC_Documenti_Controller.doc11(a.Id,'TecnicheComunicazione','Test', 'IT');
        
        WGC_Documenti_Controller.doc11(c.Id,'Privacy','Test', 'IT');
        WGC_Documenti_Controller.doc11(c.Id,'PrivacyEsecutore','Test', 'IT');

        WGC_Documenti_Controller.doc11(o.Id,'ServiziFinanziari','Test', 'IT');
        WGC_Documenti_Controller.ricercaMultiplaDoc(o.Id);
        WGC_Documenti_Controller.InvioDocNuovaVendita(o.Id);
        WGC_Documenti_Controller.ricercaMAV(o.Account.NDGGruppo__c, o.Id);

        WGC_Documenti_Controller.WrapperRicercaMAV testaa = new WGC_Documenti_Controller.WrapperRicercaMAV();
        Test.stopTest();
    }

    @isTest
    public static void test_Metodi_ConPiuOggetti(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLinee(1,true);
        Opportunity o = [SELECT Id, AccountId, Account.NDGGruppo__c, IsOppNSA__c, TiAnticipo__c, RecordType.DeveloperName FROM Opportunity LIMIT 1];
        Account a = [SELECT Id, Name, WGC_Semaforo_CLC__c, WGC_Semaforo_Gianos__c, EventiNegativiProtesti__c, EventiNegativiProcedureConcorsuali__c,EventiNegativiPregiudizievoli__c, EventiNegativiCIGS__c, EventiNegativiAllarmiQuote__c, EventiNegativiGlobale__c, WGC_Gruppo_frm__c, WGC_Alert_KPI_Centrale_Rischi__c FROM Account LIMIT 1];
        
        List<Linea__c> linee = [SELECT Id,Opportunity__c,RecordTypeId,RecordType.DeveloperName,Prodotto__r.WGC_Famiglia__c,Prodotto__r.CodiceProdotto__c,Prodotto__r.WGC_Area__c, Prodotto__r.CodiceUnivoco__c, LineaATDSingola__c, WGC_Polizza_CPI__c, Prodotto__r.Applicazione__c FROM Linea__c];
        List<NDGLinea__c> attori = [SELECT Contact__c,Id,Commessa__c,Appalto_d_opera__c, Account__r.WGC_Alert_KPI_Centrale_Rischi__c, Account__r.NDGGruppo__c, Contact__r.NDGGruppo__c FROM NDGLinea__c];
        attori.get(0).Appalto_d_opera__c =true;
        
        Test.startTest();
        WGC_Documenti_Controller.generateTagsPratica(a,o,linee, attori, null);
        WGC_Documenti_Controller.generateTagsDebitore(attori.get(0));
        WGC_Documenti_Controller.generateParamsDebitore(attori.get(0),o);
        WGC_Documenti_Controller.WGC_VerifyStatusDoc(o.Id);
        WGC_Documenti_Controller.getDocumentMapping();
        Test.stopTest();
    }


    @isTest
    public static void test_Metodi_Wrapper(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLinee2(1,true);
        RecordType rt =[SELECT Id, Name FROM RecordType WHERE Name = 'Professionista'];
        RecordType rt1 =[SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Fido'];
        //List<NDGLinea__c> attori = WGC_AllDataFactory.createAttori2(3,true);
        
        List<NDGLinea__c> attori = [SELECT Contact__c, WGC_TipologiaPersona__c, Fatturato__c, DurataNominale__c, Plafond__c, Tipo__c, Id,Commessa__c,Appalto_d_opera__c, Account__r.WGC_Alert_KPI_Centrale_Rischi__c, Account__r.NDGGruppo__c, Contact__r.NDGGruppo__c, Contact__r.CodiceIstituto3N__c, Contact__r.Account.WGC_Alert_KPI_Centrale_Rischi__c, NDGLinea__c.RecordType.DeveloperName FROM NDGLinea__c];
        List<Linea__c> linee = [SELECT Id,Opportunity__c,RecordTypeId,RecordType.DeveloperName,Importo__c,Prodotto__r.Name,Prodotto__r.CodiceProdotto__c,Prodotto__r.WGC_Area__c, Prodotto__r.CodiceUnivoco__c, WGC_Polizza_CPI__c, Prodotto__r.Applicazione__c FROM Linea__c];
        System.debug('Linee: '+linee);
        Opportunity o = [SELECT RecordType.DeveloperName,Id, AccountId , Account.CodiceIstituto3N__c, HasFactoringDiretto__c, HasConfirming__c, Account.NDGGruppo__c, Account.WGC_Alert_KPI_Centrale_Rischi__c FROM Opportunity LIMIT 1];
        Account a = [SELECT Id, Name, PIVA__c, EmailPEC__c, NumberOfEmployees,  DataIscrizioneCCIAA__c, Fatturato__c, IndirizzoPerInvioCorrispondenza__c, BillingStreetType__c, BillingStreetName__c, BillingStreetNumber__c, EmailPECFatturaElettronica__c, CodiceDestinatario__c, BillingCountry, ShippingCountry, SAE__c, ATECO__c, 
                    PaeseCasaMadre__c, WGC_Numero_dipendenti__c, PartecipazioneSocietaFiduciarie2__c, PaeseSvolgimentoAttivitaPrevalente__c, SIA__c, Email__c, ProvinciaSvolgimentoAttivitaPrevalente__c, PaeseRelazioni1__c, PaeseRelazioni2__c, PaeseRelazioni3__c,  CF__c, ProvinciaCCIAA__c, REA__c, 
                    BillingStreet, BillingCity, BillingPostalCode, BillingState, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingStreetType__c, ShippingStreetNumber__c, ShippingStreetName__c, Phone, Fax, ConsensoAllaProfilazione__c, ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c, ConsensoAttivitaPromozionaleTerzi__c, ConsensoAttivitaPromRicercheMercato__c, ConsensoSoloModalitaTradizionali__c, WGC_Esecutore_Firmatario_Privacy__c, TelefonoPrefisso__c  FROM Account LIMIT 1];
        Contact c = [SELECT Id, ConsensoAllaProfilazione__c, ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c, ConsensoAttivitaPromozionaleTerzi__c, ConsensoAttivitaPromRicercheMercato__c, ConsensoSoloModalitaTradizionali__c, Name, Account.Name, MailingCity FROM Contact LIMIT 1];
        attori.get(0).Tipo__c = 'Debitore';
        attori.get(0).RecordTypeId =rt.Id;

        attori.get(1).RecordTypeId =rt.Id;
        //attori.get(1).WGC_TipologiaPersona__c = 'PG';

        attori.get(2).RecordTypeId =rt.Id;
        attori.get(2).Tipo__c = 'Esecutore adeguata verifica';
        //update attori;
        List<AdeguataVerifica__c> listAD = WGC_AllDataFactory.createAdeguataVerifica2(1,true,a.Id);
        AdeguataVerifica__c mav =[SELECT Id, Name, Natura_Factoring__c, Natura_Finanziamenti__c, Natura_Servizi_Bancari__c, Scopo_Factoring__c, Scopo_Finanziamenti__c, Scopo_Servizi_Bancari__c,
								Natura_Crediti_Erariali__c, Altro_Crediti_Erariali__c, NaturaRapportoContinuativoFD__c, ScopoFD11__c, Account__c, ScopoFD12__c, ScopoFD13__c, ScopoFD14__c, ScopoFD15__c, ScopoFD16__c, ScopoFD17__c, ScopoFD18__c, ScopoFD19__c, OrigineFondi1__c, OrigineFondi2__c, OrigineFondi3__c, OrigineFondi4__c, OrigineFondiAltro__c,WGC_TipologiaMav__c FROM AdeguataVerifica__c LIMIT 1];
        List<AccountContactRelation> accContRel =[SELECT AccountId,ContactId,Id, Account.ShippingStreetType__c, WGC_Titolare_Esecutore__c, WGC_Selezionato__c, Contact.LastName, Contact.FirstName, Contact.TipoDocumentoId__c, WGC_Titolare_Effettivo__c, Contact.Name, Contact.Birthdate, Contact.LuogoNascita__c, Contact.ProvinciaNascita__c, Contact.PaeseNascita__c, Contact.Cittadinanza__c, Contact.Sesso__c, Contact.MailingStreet, Contact.MailingCity, Contact.MailingPostalCode, Contact.MailingState, Contact.MailingCountry, Contact.CF__c, Contact.TipoDocumentoIdentita__c, Contact.NumeroDoc__c, Contact.LuogoEmissioneDoc__c, Contact.DataEmissioneDoc__c, Contact.DataScadenzaDoc__c, Contact.PEP__c, Contact.Altre_Cariche_Pubbliche__c, WGC_Tipologia_Titolare_Effettivo__c, Contact.TAECode__c, Contact.PEPTipoCarica__c, Contact.Professione__c,WGC_Ruolo_Pratica__c,WGC_Ruolo__c, Contact.OtherStreet, Contact.OtherCity, Contact.OtherPostalCode, Contact.OtherState, Contact.OtherCountry, WGC_Tipologia_Esecutore__c FROM AccountContactRelation];
        accContRel.get(0).WGC_Tipologia_Titolare_Effettivo__c = 'Proprietà indiretta';
        accContRel.get(0).WGC_Selezionato__c = true;
        accContRel.get(0).WGC_Ruolo_Pratica__c = 'J1';
        accContRel.get(0).WGC_Ruolo__c = 'Z3';
        update accContRel;

        System.debug('Acr: '+ JSON.serialize(accContRel));
        AccountContactRelation acr = accContRel.get(0);
        WGC_Documenti_Controller.Origine origine = new WGC_Documenti_Controller.Origine();

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        origine.generateOrigine(a,acr);
        origine.generateOrigine(a,accContRel,mav);

        WGC_Documenti_Controller.OutputDoc10 outputdoc10Test = new WGC_Documenti_Controller.OutputDoc10();

        WGC_Documenti_Controller.AttoriXDoc attoriXDocTest1 = new WGC_Documenti_Controller.AttoriXDoc();
        WGC_Documenti_Controller.AttoriXDoc attoriXDocTest2 = new WGC_Documenti_Controller.AttoriXDoc(attori.get(0), outputdoc10Test);
        
        WGC_Documenti_Controller.InputDoc10 inputDoc10Test = new WGC_Documenti_Controller.InputDoc10();
        WGC_Documenti_Controller.InputDoc10 inputDoc10Test1 = new WGC_Documenti_Controller.InputDoc10(attori.get(0), o);
        WGC_Documenti_Controller.InputDoc10 inputDoc10Test2 = new WGC_Documenti_Controller.InputDoc10(attori.get(1), o);
        WGC_Documenti_Controller.InputDoc10 inputDoc10Test3 = new WGC_Documenti_Controller.InputDoc10(attori.get(2), o);
        
        WGC_Documenti_Controller.ResultDoc10 resultDoc10Test =  new WGC_Documenti_Controller.ResultDoc10();

        WGC_Documenti_Controller.Docs docsTest =  new WGC_Documenti_Controller.Docs();
        
        WGC_Documenti_Controller.IndiceDoc10 indiceDoc10Test =  new WGC_Documenti_Controller.IndiceDoc10();

        // WGC_Documenti_Controller.WrapperDettaglioDocInput wrapperDettaglioDocInputTest =  new WGC_Documenti_Controller.WrapperDettaglioDocInput();

        WGC_Documenti_Controller.WrapperDatiDoc wrapperDatiDocTest1 =  new WGC_Documenti_Controller.WrapperDatiDoc();
        WGC_Documenti_Controller.WrapperDatiDoc wrapperDatiDocTest2 =  new WGC_Documenti_Controller.WrapperDatiDoc('06');
        WGC_Documenti_Controller.WrapperDatiDoc wrapperDatiDocTest3 =  new WGC_Documenti_Controller.WrapperDatiDoc('08');

        WGC_Documenti_Controller.WrapperIndice wrapperIndiceTest =  new WGC_Documenti_Controller.WrapperIndice();

        WGC_Documenti_Controller.DocDownload docDownloadTest = new WGC_Documenti_Controller.DocDownload();

        WGC_Documenti_Controller.WrapperDatiDoc11 wrapperDatiDoc11Test = new WGC_Documenti_Controller.WrapperDatiDoc11();

        WGC_Documenti_Controller.DatiDocumento datiDocumentoTest1 = new WGC_Documenti_Controller.DatiDocumento();
        WGC_Documenti_Controller.DatiDocumento datiDocumentoTest2 = new WGC_Documenti_Controller.DatiDocumento(null);

        WGC_Documenti_Controller.reportDefinitions reportDefinitionsTest = new WGC_Documenti_Controller.reportDefinitions();

        WGC_Documenti_Controller.DataSource dataSourceTest = new WGC_Documenti_Controller.DataSource();

        WGC_Documenti_Controller.DatiCliente datiClienteTest1 = new WGC_Documenti_Controller.DatiCliente();
        WGC_Documenti_Controller.DatiCliente datiClienteTest2 = new WGC_Documenti_Controller.DatiCliente(a);

        WGC_Documenti_Controller.DatiPrivacy datiPrivacyTest1 = new WGC_Documenti_Controller.DatiPrivacy();
        WGC_Documenti_Controller.DatiPrivacy datiPrivacyTest2 = new WGC_Documenti_Controller.DatiPrivacy(c);
        WGC_Documenti_Controller.DatiPrivacy datiPrivacyTest3 = new WGC_Documenti_Controller.DatiPrivacy(a,acr);

        WGC_Documenti_Controller.DatiAdeguataVerifica datiAdeguataVerificaTest1 = new WGC_Documenti_Controller.DatiAdeguataVerifica();
        WGC_Documenti_Controller.DatiAdeguataVerifica datiAdeguataVerificaTest2 = new WGC_Documenti_Controller.DatiAdeguataVerifica(a,accContRel,mav);
        
        WGC_Documenti_Controller.DatiClienteMAV datiClienteMAVTest1 = new WGC_Documenti_Controller.DatiClienteMAV();
        WGC_Documenti_Controller.DatiClienteMAV datiClienteMAVTest2 = new WGC_Documenti_Controller.DatiClienteMAV(a);

        WGC_Documenti_Controller.ProfiloClienteMAV profiloClienteMAVTest1 = new WGC_Documenti_Controller.ProfiloClienteMAV();
        WGC_Documenti_Controller.ProfiloClienteMAV profiloClienteMAVTest2 = new WGC_Documenti_Controller.ProfiloClienteMAV(a);

        WGC_Documenti_Controller.TitolariMAV titolariMAVTest1 = new WGC_Documenti_Controller.TitolariMAV();
        titolariMAVTest1.generaTitolari(accContRel);

        WGC_Documenti_Controller.EsecutoreMAV esecutoreMAVTest1 = new WGC_Documenti_Controller.EsecutoreMAV();
        accContRel.get(0).WGC_Tipologia_Titolare_Effettivo__c = 'Proprietà indiretta';
        accContRel.get(0).WGC_Selezionato__c = true;
        accContRel.get(0).WGC_Ruolo_Pratica__c = 'Z1';
        accContRel.get(0).WGC_Ruolo__c = 'Z3';
        update accContRel;

        List<AccountContactRelation> aaa = new List<AccountContactRelation>();
        aaa.add(accContRel.get(0));

        titolariMAVTest1.generaTitolari(aaa);
        
        
        esecutoreMAVTest1.generateEsecutore(accContRel);

        WGC_Documenti_Controller.DatiContoCorrente datiContoCorrenteTest = new WGC_Documenti_Controller.DatiContoCorrente();

        WGC_Documenti_Controller.DatiMutuo datiMutuoTest = new WGC_Documenti_Controller.DatiMutuo();

        WGC_Documenti_Controller.DatiClienteRSF datiClienteRSFTest1 = new WGC_Documenti_Controller.DatiClienteRSF();
        WGC_Documenti_Controller.DatiClienteRSF datiClienteRSFTest2 = new WGC_Documenti_Controller.DatiClienteRSF(a);

        WGC_Documenti_Controller.Cliente clienteTest1 = new WGC_Documenti_Controller.Cliente();
        // WGC_Documenti_Controller.Cliente clienteTest2 = new WGC_Documenti_Controller.Cliente(attori.get(0));
        //WGC_Documenti_Controller.Cliente clienteTest3 = new WGC_Documenti_Controller.Cliente(attori);
        // List<WGC_Documenti_Controller.Cliente> listClienti = clienteTest1.generaClienti(attori);

        WGC_Documenti_Controller.DatiTecnicheComunicazione datiTecnicheComunicazioneTest1 = new WGC_Documenti_Controller.DatiTecnicheComunicazione();
        WGC_Documenti_Controller.DatiTecnicheComunicazione datiTecnicheComunicazioneTest2 = new WGC_Documenti_Controller.DatiTecnicheComunicazione(a, mav);


        WGC_Documenti_Controller.DatiClienteMTC datiClienteMTCTest1 = new WGC_Documenti_Controller.DatiClienteMTC();
        WGC_Documenti_Controller.DatiClienteMTC datiClienteMTCTest2 = new WGC_Documenti_Controller.DatiClienteMTC(a);

        WGC_Documenti_Controller.outputDoc11 outputDoc11Test = new WGC_Documenti_Controller.outputDoc11();
        outputDoc11Test.isCorrect();
        WGC_Documenti_Controller.OutputPayload outputPayloadTest = new WGC_Documenti_Controller.OutputPayload();

        WGC_Documenti_Controller.DatiRichiestaServiziFinanziari datiRichiestaServiziFinanziariTest1 = new WGC_Documenti_Controller.DatiRichiestaServiziFinanziari();
        // WGC_Documenti_Controller.DatiRichiestaServiziFinanziari datiRichiestaServiziFinanziariTest2 = new WGC_Documenti_Controller.DatiRichiestaServiziFinanziari(o,a,linee,attori);
        WGC_Documenti_Controller.DatiRichiestaServiziFinanziari.checkMutuo(linee);
        WGC_Documenti_Controller.DatiRichiestaServiziFinanziari.checkFamigliaProd(linee);

        WGC_Documenti_Controller.RapportoMAV rapportoMAVTest = new WGC_Documenti_Controller.RapportoMAV(mav);

        WGC_Documenti_Controller.AggiornamentoData aggiornamentoDatatest = new WGC_Documenti_Controller.AggiornamentoData();

        WGC_Documenti_Controller.ContenutoDocumento contenutoDocumentoTest1 = new WGC_Documenti_Controller.ContenutoDocumento();
        WGC_Documenti_Controller.ContenutoDocumento contenutoDocumentoTest2 = new WGC_Documenti_Controller.ContenutoDocumento('Test', 'Test');

        WGC_Documenti_Controller.IndiceInput indiceInputTest1= new WGC_Documenti_Controller.IndiceInput();
        WGC_Documenti_Controller.IndiceInput indiceInputTest2= new WGC_Documenti_Controller.IndiceInput('Test', 'Test');

        WGC_Documenti_Controller.WrapperMetaDoc wrapperMetaDocTest1 = new WGC_Documenti_Controller.WrapperMetaDoc();
        WGC_Documenti_Controller.WrapperMetaDoc wrapperMetaDocTest2 = new WGC_Documenti_Controller.WrapperMetaDoc('TestA','TestB','TestC');

        WGC_Documenti_Controller.OutputIndice outputIndiceTest = new WGC_Documenti_Controller.OutputIndice();

        WGC_Documenti_Controller.ElementiRicerca  elementiRicercaTest = new WGC_Documenti_Controller.ElementiRicerca();

        WGC_Documenti_Controller.EsitoRicerca esitoRicercaTest = new WGC_Documenti_Controller.EsitoRicerca();

        WGC_Documenti_Controller.IndiceRicerca indiceRicercaTest = new WGC_Documenti_Controller.IndiceRicerca();
        Test.stopTest();
    }

	@isTest
    public static void getSoggettiOpp() {
		List<Opportunity> opps = WGC_AllDataFactory.createOpportunity(1, true);
		WGC_Documenti_Controller.WrapperResponse res = WGC_Documenti_Controller.getSoggettiOpp(opps[0].Id);
		System.assertEquals(res.success, true);
	}

	@isTest
    public static void privacyEsecutoreFirmata() {
		List<Contact> cons = WGC_AllDataFactory.createContact(1, true);
		String accId = cons.get(0).AccountId;
		String conId = cons.get(0).Id;
		AccountContactRelation acr =  [
			SELECT Id, WGC_Ruolo_Pratica__c 
			FROM AccountContactRelation 
			WHERE ContactId=:conId AND AccountId=:accId 
			LIMIT 1];
		acr.WGC_Ruolo_Pratica__c='J;Z1';
		update acr;

		WGC_Documenti_Controller.privacyEsecutoreFirmata(accId);
	}

	@isTest
    public static void getProfilo() {
		WGC_Documenti_Controller.getProfilo();	
	}

    @isTest
    static void setDocNonReperibiliTest(){
        String[] docIndex = new String[]{'abc','def'};
        // List<Map<String,Object>> noteDocs = new List<Map<String,Object>>();
        List<WGC_Nota_Documento__c> noteDocs = new List<WGC_Nota_Documento__c>();
        WGC_AllDataFactory.createLinee2(1,true);

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        noteDocs.add(new WGC_Nota_Documento__c(Id_Univoco__c = opp.Id + '_' + docIndex[0], Note__c = 'Documento Non Reperibile'));
        noteDocs.add(new WGC_Nota_Documento__c(Id_Univoco__c = opp.Id + '_' + docIndex[1], Note__c = 'Documento Non Reperibile'));

        Test.startTest();
            //Creo note
            WGC_Documenti_Controller.setAllDocNonReperibili(opp.Id, true, noteDocs);
            List<WGC_Nota_Documento__c> notes = [SELECT Id FROM WGC_Nota_Documento__c];
            WGC_Documenti_Controller.setAllDocNonReperibili(opp.Id, false, notes);
        Test.stopTest();
    }

}