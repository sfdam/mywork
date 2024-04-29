@isTest
public with sharing class WGC_RestRevisionePratica_Test {
    /*@isTest
    public static void Test_Metodi1(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        

        List<NDGLinea__c> actor = WGC_AllDataFactory.createAttori(3,true);
        
        actor.get(1).Tipo__c = 'Esecutore adeguata verifica';
        update actor;

        List<Account> acc = [SELECT Id, Name,OwnerId  FROM Account];
        acc.get(0).Filiale__c='4';
        update acc;
        System.debug('acc: '+acc.get(0));
        List<Opportunity> opty = [SELECT Id, Name FROM Opportunity];
        opty.get(0).IdCartella__c='881/00006/2019/000002';
        //opty.get(1).IdCartella__c='881/00006/2019/000002';
        update opty;

        //System.debug('Qua: '+o.Account.Filiale__c);

        Linea__c linea = new Linea__c(Opportunity__c=opty.get(0).Id);
        insert linea;
        Linea__c linea1 = new Linea__c(Opportunity__c=opty.get(0).Id);
        insert linea1;
        /*
        ASPETTA LA MODIFICA DEL CASTING RUNTIME DI PENNELLO
        List<Linea__c> listalinea = [SELECT IdProdotto__c, DivisaNew__c, Opportunity__r.IdCartella__c FROM Linea__c ];
        System.debug('Qua --> '+listalinea);
        Map<String, SObject> mappaprova = U.keyBy([SELECT IdProdotto__c, DivisaNew__c FROM Linea__c ], 'IdProdotto__c');
        System.debug('Qua --> '+mappaprova);
        Map<String, Linea__c> lineaMap = (Map<String, Linea__c>) mappaprova; 
        System.debug('Qua --> '+lineaMap);




        WGC_RestRevisionePratica.RevisionePraticaInputPayload provaRevPrat = new WGC_RestRevisionePratica.RevisionePraticaInputPayload();
        provaRevPrat.idSistemaEsterno='881/00006/2019/000002';
        RestCommon.TechInfo provaTechInfo = new RestCommon.TechInfo();
        
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_RestRevisionePratica.revisionePratica(provaTechInfo,provaRevPrat);
        Test.stopTest();        
    }

    @isTest
    public static void Test_Metodi2(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLagKey();
        WGC_RestRevisionePratica.RevisionePraticaInputPayload provaRevPrat = new WGC_RestRevisionePratica.RevisionePraticaInputPayload();
        List<Opportunity> opty = WGC_AllDataFactory.createOpportunity(1,true);
        provaRevPrat.idSistemaEsterno='881/00006/2019/000002';
        RestCommon.TechInfo provaTechInfo = new RestCommon.TechInfo();

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        
        Test.startTest();
        WGC_RestRevisionePratica.revisionePratica(provaTechInfo,provaRevPrat);
        Test.stopTest();        
    }


    @isTest
    public static void Test_Metodi3(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLagKey();
        WGC_RestRevisionePratica.RevisionePraticaInputPayload provaRevPrat = new WGC_RestRevisionePratica.RevisionePraticaInputPayload();
        List<Opportunity> opty = WGC_AllDataFactory.createOpportunity(5,true);
        provaRevPrat.idSistemaEsterno='881/00006/2019/000002';
        RestCommon.TechInfo provaTechInfo = new RestCommon.TechInfo();

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        
        Test.startTest();
        WGC_RestRevisionePratica.revisionePratica(provaTechInfo,provaRevPrat);
        Test.stopTest();        
    }*/

    public static final String stringLcc ='{"parametri":null,"numLineaCredito":null,"importoRichiesto":null,"importoQuotaOneri":null,"garanzie":null,"fidiCoppia":null,"dataScadenzaFido":null,"codRapportoEsterno":null,"codDivisa":null,"codCanAcqLCC":null}';
    public static final String stringProd  ='{"tipologia":null,"parametriAggiuntivi":null,"idProdotto":113409,"fidiCoppia":null,"descrizioneStato":null,"descrizioneProdotto":"a0I1x000000BZee","datiTecnici":{"datoTecnico":[{"valore":"05","codice":"CATEV"},{"valore":"05","codice":"CATFA"},{"valore":"S","codice":"DILAZ"},{"valore":"521","codice":"LINEA"},{"valore":"000","codice":"SOTFA"},{"valore":"1","codice":"FORMA"},{"valore":"01","codice":"SOTCOD"},{"valore":null,"codice":"IMP"},{"valore":null,"codice":"RCOLL"},{"valore":"N","codice":"FCONS"},{"valore":"N","codice":"FRIN"}]},"condizioniFactoring":null,"condizioni":null,"codiceStato":null,"codiceProdotto":"PCFII","codiceApplicazione":null,"categoria":null,"associazioneProdotti":null,"associazioneNdgRuoli":{"associazione":[{"ndg":107499,"codiceRuolo":"TIT"}]},"associazioneGaranzie":null}';
    @isTest
    public static void Test_revisionePratica1(){
        
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();

        RestCommon.TechInfo techInfo = new RestCommon.TechInfo();
        WGC_RestRevisionePratica.RevisionePraticaInputPayload payload = new WGC_RestRevisionePratica.RevisionePraticaInputPayload();        
        
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_RestRevisionePratica.revisionePratica(techInfo,payload);
        Test.stopTest();

    }

    @isTest
    public static void Test_revisionePratica2(){
        
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.createItemMapping();
        List<Opportunity> opty =[SELECT AccountId,Id,IdCartella__c FROM Opportunity];
        opty.get(0).IdCartella__c='881/00006/2019/000002';
        List<Linea__c> listalinea = [SELECT IdProdotto__c, DivisaNew__c, Opportunity__r.IdCartella__c FROM Linea__c ];
        listalinea.get(0).DivisaNew__c = '242';
        update listalinea;
        System.debug('Qua --> '+listalinea.get(0).IdProdotto__c);
        User u = [SELECT Filiale__c FROM User WHERE Id = :UserInfo.getUserId()];
        u.Filiale__c='1';
        update u;
        RestCommon.TechInfo techInfo = new RestCommon.TechInfo();
        WGC_RestRevisionePratica.RevisionePraticaInputPayload payload = new WGC_RestRevisionePratica.RevisionePraticaInputPayload();        
        

        //System.debug('parametroList '+parametroList);
        Test.startTest();
        WGC_RestRevisionePratica.revisionePratica(techInfo,payload);
        Test.stopTest();

    }

    @isTest
    public static void Test_revisionePratica3(){
        
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Opportunity> opty = WGC_AllDataFactory.createOpportunity(5,true);
        opty.get(0).IdCartella__c='881/00006/2019/000002';
        opty.get(1).IdCartella__c='881/00006/2019/000002';
        opty.get(2).IdCartella__c='881/00006/2019/000002';
        opty.get(3).IdCartella__c='881/00006/2019/000002';
        opty.get(4).IdCartella__c='881/00006/2019/000002';

        RestCommon.TechInfo techInfo = new RestCommon.TechInfo();
        WGC_RestRevisionePratica.RevisionePraticaInputPayload payload = new WGC_RestRevisionePratica.RevisionePraticaInputPayload();        
        
        
        Test.startTest();
        WGC_RestRevisionePratica.revisionePratica(techInfo,payload);
        Test.stopTest();

    }
    /*
    @isTest
    public static void Test_fillLineaCreditoLCCInfo(){

        WGC_RestRevisionePratica.LineaCreditoLCC lcc = (WGC_RestRevisionePratica.LineaCreditoLCC) JSON.deserialize(stringLcc,WGC_RestRevisionePratica.LineaCreditoLCC.class);
        WsRestCrm.Prodotto prodotto = (WsRestCrm.Prodotto) JSON.deserialize(stringProd, WsRestCrm.Prodotto.class);
        Map<String, SObject> lineaMap = new Map<String, SObject>(); 
        Map<String, List<SObject>> oldValuesParametersPerLine = new Map<String, List<SObject>>();
        
        Test.startTest();
        //WGC_RestRevisionePratica.fillLineaCreditoLCCInfo(lcc,prodotto,lineaMap,oldValuesParametersPerLine);
        Test.stopTest();
    }*/
    

    @isTest
    public static void Test_metodi_privati(){
        
        WsRestCrm.FidoCoppia fidocoppia = new WsRestCrm.FidoCoppia();
        
        fidocoppia.codNdgDebi = 1111;
        fidocoppia.codTipoCoppia = 'codTipoCoppia';
        fidocoppia.codDivisa = 'codDivisa';
        fidocoppia.importoRichiestoEndo = 9999;
        fidocoppia.importoRichiestoUto = 1000;
        fidocoppia.dataInizioValidita = 1;
        List<WsRestCrm.FidoCoppia> fidoCoppiaList = new List<WsRestCrm.FidoCoppia>();
        fidoCoppiaList.add(fidocoppia);
        List<WsRestCrm.FidoCoppia> fidoCoppiaList1 = new List<WsRestCrm.FidoCoppia>();
        
        // ValoreParametro
        WsRestCrm.ValoreParametro valParam = new WsRestCrm.ValoreParametro();
        List<WsRestCrm.ValoreParametro> valParList = new List<WsRestCrm.ValoreParametro>();
        valParList.add(valParam);
        List<WsRestCrm.ValoreParametro> valParList1 = new List<WsRestCrm.ValoreParametro>();


        // Parametro
        WsRestCrm.Parametro parametro = new WsRestCrm.Parametro();
        parametro.valoriParametro=new WsRestCrm.ValoriParametro();
        List<WsRestCrm.Parametro> parametriList = new List<WsRestCrm.Parametro>();
        parametriList.add(parametro);
        List<WsRestCrm.Parametro> parametriList1 = new List<WsRestCrm.Parametro>(); 


        // Garanzia
        WsRestCrm.Garanzia garanzia = new WsRestCrm.Garanzia();
        List<WsRestCrm.Garanzia> garanzieList = new List<WsRestCrm.Garanzia>();
        garanzieList.add(garanzia);
        List<WsRestCrm.Garanzia> garanzieList1 = new List<WsRestCrm.Garanzia>();
        
        // Referente
        WsRestCrm.Referente referente = new WsRestCrm.Referente();
        List<WsRestCrm.Referente> referentilist = new List<WsRestCrm.Referente>();
        referentilist.add(referente);
        List<WsRestCrm.Referente> referentilist1 = new List<WsRestCrm.Referente>();
        
        PConfigurato__c pConf = new PConfigurato__c();
        pConf.Valore__c = 'A;B;C';
        pConf.WGC_Valore_Pef_38__c = 'D;E;F';

        Map<String, SObject> mappa = new Map<String, SObject>();
        
        WsRestCrm.Prodotto prodotto = new WsRestCrm.Prodotto();
        prodotto.idProdotto = 123;
        Map<String, List<SObject>> oldMap  = new  Map<String, List<SObject>>();



        Test.startTest();
       
        // WGC_RestRevisionePratica.getFidiCoppia(fidoCoppiaList,mappa);
        // WGC_RestRevisionePratica.getFidiCoppia(fidoCoppiaList1);

        WGC_RestRevisionePratica.getParametri(parametriList,mappa);
        // WGC_RestRevisionePratica.getParametri(parametriList1);

        WGC_RestRevisionePratica.getValoriParametro(valParList,'C',pConf);
        WGC_RestRevisionePratica.getValoriParametro(valParList,'X',pConf);

        WGC_RestRevisionePratica.getGaranzie(garanzieList);
        WGC_RestRevisionePratica.getGaranzie(garanzieList1);

        WGC_RestRevisionePratica.getGaranti(referentilist);
        WGC_RestRevisionePratica.getGaranti(referentilist1);

        // WGC_RestRevisionePratica.fillLineaCreditoLCCInfo(prodotto,mappa,oldMap);
        Test.stopTest();
    }

}