@isTest
private class pdfConfiguratorCallableMethodsTest {

    private static String PDFConfiguratorJSON = '';

    private static List<PDFConfigurator__mdt> selectedSections = new List<PDFConfigurator__mdt>();
    private static String rootCampiAggiuntivi = '';
    private static String rootxml = '';
    private static String sectionsxml = '';

    @TestSetup
    static void setup(){
        RecordType rectype = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'IndustriesBusiness' LIMIT 1];

        ServiceModel__c personal = new ServiceModel__c(Name = 'Personal',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'WM');

        ServiceModel__c family = new ServiceModel__c(Name = 'Family',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'EB');
        insert new List<ServiceModel__c>{personal, family};
        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        dir.FinServ__BankNumber__c = '05387';
        dir.parentId = banca.Id;
        dir.PTF_Banca__c = banca.Id;
        insert dir;
        Account area = AllDataFactory.getAccount('08', 'Area');
        area.FinServ__BankNumber__c = '05387';
        area.parentId = dir.Id;
        area.PTF_Banca__c = banca.Id;
        area.PTF_DirezioneRegionale__c = dir.Id;
        insert area;
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.FinServ__BankNumber__c = '05387';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.PTF_Banca__c = banca.Id;
        filiale.PTF_DirezioneRegionale__c = dir.Id;
        filiale.PTF_Area__c = area.Id;

        Account filiale2 = AllDataFactory.getAccount('30', 'FilialeDiRelazione');
        filiale2.FinServ__BankNumber__c = '05387';
        filiale2.parentId = area.Id;
        filiale2.PTF_BranchTypology__c = 'A';
        filiale2.PTF_Banca__c = banca.Id;
        filiale2.PTF_DirezioneRegionale__c = dir.Id;
        filiale2.PTF_Area__c = area.Id;
        insert new List<Account>{filiale, filiale2};

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioFamily2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        Wallet__c microPortafoglioPersonal2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Personal');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal, microPortafoglioFamily2, microPortafoglioPersonal2};

        Account acc = new Account(Name = 'Test', RecordTypeId = rectype.Id, PTF_DataApertura__c = DateTime.now(), CRM_DataAggCreditRating__c = Date.today());
        insert acc;        

        CRM_InformazioneParticolare__c crm_acc = new CRM_InformazioneParticolare__c(CRM_Account__c = acc.Id);
        insert crm_acc;

        RecordType CreditCardRecordType = [SELECT id FROM RecordType WHERE DeveloperName = 'BankingAccount' AND SobjectType = 'FinServ__FinancialAccount__c' LIMIT 1].get(0);
        
        Account testAcc = new Account(Name = 'testAcc');
        insert testAcc;

        Product2 product = new Product2(
            Name = 'Test'
        );
        insert product;

        FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
        financialAccount.FinServ__Status__c = 'ATTIVO';
        financialAccount.RecordTypeId = CreditCardRecordType.Id;
        financialAccount.FinServ__ProductName__c = product.Id;
        financialAccount.FinServ__PrimaryOwner__c = acc.Id;
        insert financialAccount;

        FinServ__FinancialAccountRole__c financialRole = new FinServ__FinancialAccountRole__c();
        financialRole.FinServ__RelatedAccount__c = acc.Id;
        financialRole.FinServ__FinancialAccount__c = financialAccount.Id;
        financialRole.FinServ__Role__c='Primary Owner';
        insert financialRole;

        FinServ__Alert__c finServAlert = new FinServ__Alert__c();
        finServAlert.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('FinServ__Alert__c', 'Scadenziario_Portafoglio');
        finServAlert.CRM_CED__c='123';
        finServAlert.FinServ__Account__c=acc.id;
        finServAlert.CRM_TipoDocumento__c='MAV';
        finServAlert.FinServ__Message__c='Scadenza';
        finServAlert.FinServ__FinancialAccount__c=financialAccount.Id;
        finServAlert.CRM_EsitoContatto__c='Da ricontattare';
        finServAlert.CRM_Importo__c=100;
        insert finServAlert;

        // Gruppo
        Account gruppo = AllDataFactory.getAccount('50', 'GruppoFinanziario');
        gruppo.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        gruppo.PTF_Filiale__c = filiale.Id;
        gruppo.PTF_NaturaGiuridica__c = 'GF';

        Account business = AllDataFactory.getAccount('51', 'IndustriesBusiness');
        business.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        business.PTF_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account06';
        insert new List<Account>{gruppo, business};

        CRM_LinkedNDG__c capoGruppo = new CRM_LinkedNDG__c(
            CRM_Account__c = gruppo.Id,
            CRM_RelatedAccount__c = acc.Id,
            CRM_LinkCode__c = '113',
            CRM_Status__c = 'A',
            CRM_LinkType__c = 'CAPOGRUPPO'
        );
        CRM_LinkedNDG__c membroGruppo = new CRM_LinkedNDG__c(
            CRM_Account__c = gruppo.Id,
            CRM_RelatedAccount__c = business.Id,
            CRM_LinkCode__c = '165',
            CRM_Status__c = 'A',
            CRM_LinkType__c = 'CONN.GIUR.'
        );
        insert new List<CRM_LinkedNDG__c>{capoGruppo, membroGruppo};

        Endpoint__c generateDocument = (Endpoint__c)JSON.deserialize('{"attributes":{"type":"Endpoint__c","url":""},"IsDeleted":false,"Name":"generateDocument","EndpointParams__c":null,"Endpoint__c":"https://apigw.bper.it/gateway/DocumentsGenerationEngineAPI/v1/documentsgenerationengine/generateDocument","Method__c":"POST","Timeout__c":120000,"BodyParams__c":null,"InList__c":false}', Endpoint__c.class);
        insert generateDocument;
    }

    private static Account AccountData(){
        return [SELECT Id, Name, RecordTypeId, RecordTypeName__c FROM Account WHERE Name = 'Test' LIMIT 1];
    }

    @isTest
    private static void getProdottiListTest(){

        String className = 'pdfConfiguratorCallableMethods';
        String methodName = 'getProdottiList';
        PDFConfigurator__mdt metadato = new PDFConfigurator__mdt();
        metadato.baseXml__c = '<tabellaprodotto><tipoTabella>2</tipoTabella><nomeProdotto>TEST CONTI CORRENTI</nomeProdotto><numeroProdotti>###NUMERO_RIGHE###</numeroProdotti>###XML_DETTAGLIO###</tabellaprodotto>';
        metadato.MetodoSelezioneClasse__c = 'pdfConfiguratorCallableMethods';
        metadato.MetodoSelezioneName__c = 'getProdottiList';
        metadato.MetodoSelezioneAdditionalParameters__c = '{"RecordType": "BankingAccount", "statusFinServ": "ATTIVO"}';
        metadato.TemplateIterationXml__c = '<dettaglio1>{!financialAccount_Name}</dettaglio1><dettaglio2>{!financialRole_FinServ__Role__c}</dettaglio2></prodottoDettaglio>';
        metadato.HasMetodoSelezione__c = true;
        metadato.isActive__c =true;
        metadato.SECTION__c = 'Prodotti Attivi';
        metadato.COMPONENT__c = 'Banking Multicanale';

        Account currentObject = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1].get(0);
        String jsonAdditionalParameters = '{"RecordType": "CreditCard", "statusFinServ": "ATTIVO"}';
        pdfConfiguratorCallableMethods.WrapperGetMapDataRes testList = new pdfConfiguratorCallableMethods.WrapperGetMapDataRes();

        Test.startTest();
            Callable pdfConfiguratorCallableMethods = (Callable) Type.forName(className).newInstance();
            testList = (pdfConfiguratorCallableMethods.WrapperGetMapDataRes)pdfConfiguratorCallableMethods.call(methodName, new Map<String, Object> { 'meta' => metadato, 'currentObject' => currentObject, 'jsonAdditionalParameters' => jsonAdditionalParameters });
        Test.stopTest();

        System.assertEquals(true, testList != null, 'getProdottiListTest');

    }

    @isTest
    private static void getContactHistoryListTest(){

        String recordId = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'IndustriesBusiness' LIMIT 1].Id;
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('FinServ__FinancialAccount__c'));
        List<FinServ__FinancialAccount__c> recordList = (List<FinServ__FinancialAccount__c>)Database.query(query);
        Map<String, String> recordObjectTypeMap = new map<String, String>();
        for(FinServ__FinancialAccount__c finalcialAccount : recordList){
            recordObjectTypeMap.put(finalcialAccount.Id, 'FinServ__FinancialAccount__c');
        }

        Account currentAccount = PrintPDFController.getAccountData(recordId)[0];
        Test.startTest();
        Callable pdfConfiguratorCallableMethods = (Callable) Type.forName('pdfConfiguratorCallableMethods').newInstance();
        List<Map<String,String>> testList = (List<Map<String,String>>)pdfConfiguratorCallableMethods.call('getContactHistoryList', new Map<String, Object> {'currentObject' => currentAccount, 'recordList' => recordList, 'recordObjectTypeMap' => recordObjectTypeMap });
        Test.stopTest();
    }
    

    @isTest
    private static void testExecuteCall(){

        Account record = Database.query(SV_Utilities.selectAllField('Account') + ' WHERE RecordType.DeveloperName = \'IndustriesBusiness\' LIMIT 1');

        // List<PDFConfigurator__mdt> ListMetaData = makeData();
        Set<String> sezioni = new Set<String>{'Prodotti Attivi', 'Spalla Destra', 'NDG Collegati', 'Indicatori Rischio'};
        Map<String, Object> getAllDataResponse = PrintPDFController.getAllData(record.Id);
        for(PDFConfigurator__mdt meta : (List<PDFConfigurator__mdt>)JSON.deserialize(JSON.serialize(getAllDataResponse.get('metadata')), List<PDFConfigurator__mdt>.class)){

            if(sezioni.contains(meta.SECTION__c)){
                selectedSections.add(meta);
            }
        }
        String rootxml = PrintPDFController.getRootXML(selectedSections, record);

        String recordTypeDeveloperName = 'IndustriesBusiness';
        /*PDFConfigurator__mdt metadato = new PDFConfigurator__mdt();
        metadato.baseXml__c = '<tabellaprodotto><tipoTabella>2</tipoTabella><nomeProdotto>TEST CONTI CORRENTI</nomeProdotto><numeroProdotti>###NUMERO_RIGHE###</numeroProdotti>###XML_DETTAGLIO###</tabellaprodotto>';
        metadato.MetodoSelezioneClasse__c = 'pdfConfiguratorCallableMethods';
        metadato.MetodoSelezioneName__c = 'getProdottiList';
        metadato.MetodoSelezioneAdditionalParameters__c = '{"RecordType": "BankingAccount", "statusFinServ": "ATTIVO"}';
        metadato.TemplateIterationXml__c = '<dettaglio1>{!financialAccount_Name}</dettaglio1><dettaglio2>{!financialRole_FinServ__Role__c}</dettaglio2></prodottoDettaglio>';
        metadato.HasMetodoSelezione__c = true;
        metadato.isActive__c =true;
        metadato.SECTION__c = 'Prodotti Attivi';
        metadato.COMPONENT__c = 'Banking Multicanale';

        PDFConfigurator__mdt metadato2 = new PDFConfigurator__mdt();
        metadato2.baseXml__c = '<tabellaGenerica><tipoTabella>8</tipoTabella><titoloTabella>Scadenze</titoloTabella><numeroRighe>###NUMERO_RIGHE###</numeroRighe><dettaglio><tipoRiga>T</tipoRiga><colonna1>TIPO</colonna1><colonna2>NUMERO SCAD.</colonna2><colonna3>CED</colonna3><colonna4>TIPO SCAD.</colonna4><colonna5>DATA</colonna5><colonna6>IMPORTO</colonna6><colonna7>PRODOTTO</colonna7><colonna8>ESITO CONTATTO</colonna8></dettaglio>###XML_DETTAGLIO###</tabellaGenerica>';
        metadato2.MetodoSelezioneClasse__c = 'pdfConfiguratorCallableMethods';
        metadato2.MetodoSelezioneName__c = 'getScadenzeList';
        metadato2.MetodoSelezioneAdditionalParameters__c = '';
        metadato2.TemplateIterationXml__c = '<dettaglio><tipoRiga>D</tipoRiga><colonna1>{!Alert_CRM_Tipo__c}</colonna1><colonna2>{!Alert_Name}</colonna2><colonna3>{!Alert_CRM_CED__c}</colonna3><colonna4>{!Alert_CRM_TipologiaScadenza__c}</colonna4><colonna5>#ds{!Alert_CRM_FormulaData__c}#de</colonna5><colonna6>#s{!Alert_CRM_Importo__c}#e €</colonna6><colonna7>{!Alert_CRM_ProdottoCommDS__c}</colonna7><colonna8>{!Alert_CRM_EsitoContatto__c}</colonna8></dettaglio>';
        metadato2.HasMetodoSelezione__c = true;
        metadato2.isActive__c =true;
        metadato2.SECTION__c = 'Spalla Destra';
        metadato2.COMPONENT__c = 'Scadenze';

        PDFConfigurator__mdt metadato3 = new PDFConfigurator__mdt();
        metadato3.baseXml__c = '<tabellaGenerica><tipoTabella>8</tipoTabella><titoloTabella>Gruppo Finanziario</titoloTabella><numeroRighe>###NUMERO_RIGHE###</numeroRighe><dettaglio><tipoRiga>T</tipoRiga><colonna1>NDG</colonna1><colonna2>NOME</colonna2><colonna3>FILIALE</colonna3><colonna4>STATO CRM</colonna4><colonna5>NATURA GIURIDICA</colonna5><colonna6>M-MDS</colonna6><colonna7>DESCRIZIONE</colonna7><colonna8>TIPO COLLEGAMENTO</colonna8></dettaglio>###XML_DETTAGLIO###</tabellaGenerica>';
        metadato3.MetodoSelezioneClasse__c = 'pdfConfiguratorCallableMethods';
        metadato3.MetodoSelezioneName__c = 'getGroupMembersList';
        metadato3.MetodoSelezioneAdditionalParameters__c = '';
        metadato3.TemplateIterationXml__c = '<dettaglio><tipoRiga>D</tipoRiga><colonna1>{!Account_CRM_NDG__c}</colonna1><colonna2>{!Account_Name}</colonna2><colonna3>{!Account_PTF_Filiale__r.Name}</colonna3><colonna4>{!Account_PTF_StatoCRMFull__c}</colonna4><colonna5>{!Account_PTF_NaturaGiuridica__c}</colonna5><colonna6>{!Account_ModelloDiServizio__c}</colonna6><colonna7>{!Account_PTF_DescTipoCollegamento__c}</colonna7><colonna8>{!Account_CRM_LinkType__c}</colonna8></dettaglio>';
        metadato3.HasMetodoSelezione__c = true;
        metadato3.isActive__c =true;
        metadato3.SECTION__c = 'NDG Collegati';
        metadato3.COMPONENT__c = 'Gruppo Finanziario';

        PDFConfigurator__mdt metadato4 = new PDFConfigurator__mdt();
        metadato4.baseXml__c = '<informazioniSintesi>###XML_DETTAGLIO###</informazioniSintesi>';
        metadato4.MetodoSelezioneClasse__c = 'pdfConfiguratorCallableMethods';
        metadato4.MetodoSelezioneName__c = 'getIndicatoriRischioData';
        metadato4.MetodoSelezioneAdditionalParameters__c = '';
        metadato4.TemplateIterationXml__c = '<ratingUfficialeDataSca>{!flat_CRM_rating_ufficiale__c}</ratingUfficialeDataSca><ratingUfficialeNR>{!flat_CRM_CreditRating__c}</ratingUfficialeNR><ratingUfficialeDataAl>{!flat_CRM_DataAggCreditRating__c}</ratingUfficialeDataAl><segmentoUfficialeNR>{!flat_CRM_SegmentoRischioUfficiale__c}</segmentoUfficialeNR><segmentoUfficialeDataAl>{!flat_CRM_DataAggSegmRatingUff__c}</segmentoUfficialeDataAl>#startiter<ratingAndamentaleMese#Niter#>{!storico_CRM_RatingAndamentaleMeseF__c}</ratingAndamentaleMese#Niter#><ratingAndamentaleNR#Niter#>#s{!storico_CRM_RatingAndamentaleValore__c}#e</ratingAndamentaleNR#Niter#><ratingAndamentaleDataAl#Niter#>{!storico_CRM_DataAggRatingAnd__c}</ratingAndamentaleDataAl#Niter#>#enditer#toreplace<segmentoAndamentaleNR>{!flat_CRM_SegmentoRischioAndamentale__c}</segmentoAndamentaleNR><segmentoAndamentaleDataAl>{!flat_CRM_DataAggSegmRatingAnd__c}</segmentoAndamentaleDataAl><perditaAttesaNR>{!flat_CRM_PerditaAttesa__c}</perditaAttesaNR><perditaAttesaDataAl>{!flat_CRM_DataAggPA_Formula__c}</perditaAttesaDataAl><percPANR>{!flat_CRM_PerditaAttesaGestionale__c}</percPANR><percPADataAl>{!flat_CRM_DataAggPAGestionale_Formula__c}</percPADataAl><percPD>{!flat_CRM_ProbabilitaDefault__c}</percPD><percPDDataAl>{!flat_CRM_DataAggPD_Formula__c}</percPDDataAl><rischioA>#s{!flat_CRM_RischiDiretti_Ammontare_Acc__c}#e €</rischioA><rischioU>#s{!flat_CRM_RischiDiretti_Ammontare_Uti__c}#e €</rischioU><rischioAData>{!flat_CRM_F_RischiDiretti_Data_Acc__c}</rischioAData><rischioUData>{!flat_CRM_F_RischiDiretti_Data_Uti__c}</rischioUData>';
        metadato4.HasMetodoSelezione__c = true;
        metadato4.isActive__c =true;
        metadato4.SECTION__c = 'Indicatori Rischio';
        metadato4.COMPONENT__c = 'Tabella Sintesi Business';*/

        List<PDFConfigurator__mdt> fullMetadata = PrintPDFController.getFullMetadataFromSelected(selectedSections, 'Account', recordTypeDeveloperName);
        /*fullMetadata.add(metadato);
        fullMetadata.add(metadato2);
        fullMetadata.add(metadato3);
        fullMetadata.add(metadato4);*/
        System.debug('fullMetadata: '+JSON.serialize(fullMetadata));
        List<Map<String,Object>> promiseArray = new List<Map<String,Object>>();
        Map<String,String> mappaSezioni = new Map<String,String>();
        for(Integer i = 0; i< fullMetadata.size(); i++){

            PDFConfigurator__mdt m = fullMetadata[i];
            if(!String.IsBlank(m.COMPONENT__c) && m.isActive__c && !m.isRoot__c){
                mappaSezioni.put(m.SECTION__c, m.baseXml__c);
            }

            if(!String.IsBlank(m.SECTION__c) && !String.IsBlank(m.COMPONENT__c) && m.isActive__c && !m.isRoot__c){
                if(m.HasQuery__c){
                    promiseArray.add(new Map<String, Object>{'method' => 'getXMLFromQuery4PromiseData', 'meta' => m.Id});
                }
                else if(m.HasMetodoSelezione__c){
                    promiseArray.add(new Map<String, Object>{'method' => 'getXMLFromMethods4PromiseData', 'meta' => m.Id});
                }
                else{
                    promiseArray.add(new Map<String, Object>{'method' => 'replaceFieldsWithData4Promise', 'meta' => m});
                }
            }
        }
        String tipoStampa = 'FULL';
        Boolean print = true;

        /*String rootCampiAggiuntivi = PrintPDFController.getRootCampiAggiuntivi('Account', recordTypeDeveloperName);
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('Account')) + ' WHERE id =: recordId';
        if(String.isNotBlank(rootCampiAggiuntivi)){
            rootCampiAggiuntivi = (rootCampiAggiuntivi.startsWith(',')) ? rootCampiAggiuntivi : ', ' + rootCampiAggiuntivi;
            query = query.replaceFirst('FROM', String.escapeSingleQuotes(rootCampiAggiuntivi) + ' FROM');
        }*/

        String recordtypeStorico = SV_Utilities.getRecordTypeByDeveloperName('CRM_IndicatoriCliente__c', 'Storico');
        String recordtypeFlat = SV_Utilities.getRecordTypeByDeveloperName('CRM_IndicatoriCliente__c', 'Flat');
        Account currentAccount = PrintPDFController.getAccountData(record.Id)[0];
        List<CRM_IndicatoriCliente__c> indicatoriRischiotoInsert = (List<CRM_IndicatoriCliente__c>)JSON.deserialize('[{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Ottobre 2022","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"},{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Settembre 2022","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"},{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Agosto 2022","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"},{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Luglio 2022","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"},{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Giugno 2022","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"},{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Maggio 2022","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"},{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Aprile 2022","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"},{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Marzo 2022","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"},{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Febbraio 2022","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"},{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Gennaio 2022","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"},{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Dicembre 2021","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"},{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeStorico + '","CRM_rating_ufficiale__c":"28/02/2023","CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_DataAggPA_Formula__c":"//","CRM_DataAggPAGestionale_Formula__c":"//","CRM_DataAggPD_Formula__c":"//","CRM_RatingAndamentaleMeseF__c":"Novembre 2021","CRM_RatingAndamentaleValore__c":2,"CRM_DataAggRatingAnd__c":"31/12/2022"}]', List<CRM_IndicatoriCliente__c>.class);
        indicatoriRischiotoInsert.add((CRM_IndicatoriCliente__c)JSON.deserialize('{"attributes":{"type":"CRM_IndicatoriCliente__c","url":""},"CRM_rating_ufficiale__c":"28/02/2023","CRM_Account__c":"' + record.Id + '","RecordTypeId":"' + recordtypeFlat + '","CRM_F_RischiDiretti_Data_Acc__c":null,"CRM_F_RischiDiretti_Data_Uti__c":null,"CRM_RischiDiretti_Ammontare_Acc__c":null,"CRM_RischiDiretti_Ammontare_Uti__c":null,"CRM_Data_rating_ufficiale__c":"Data scadenza: 28/02/2023","CRM_CreditRating__c":"2","CRM_DataAggCreditRating__c":"23/02/2022","CRM_SegmentoRischioUfficiale__c":"SMADI","CRM_DataAggSegmRatingUff__c":"23/02/2022","CRM_SegmentoRischioAndamentale__c":"SMADI","CRM_DataAggSegmRatingAnd__c":"31/12/2022","CRM_PerditaAttesa__c":null,"CRM_DataAggPA_Formula__c":"//","CRM_PerditaAttesaGestionale__c":null,"CRM_DataAggPAGestionale_Formula__c":"//","CRM_ProbabilitaDefault__c":null,"CRM_DataAggPD_Formula__c":"//"}',CRM_IndicatoriCliente__c.class));
        insert indicatoriRischiotoInsert;
        List<Map<String,Object>> promiseArrayAsynch = new List<Map<String,Object>>();
        List<Map<String,String>> result = new List<Map<String,String>>();
        System.debug('DK promiseArray: ' + JSON.serialize(promiseArray));
        for(Map<String,Object> execution : promiseArray){
            if(execution != null && !execution.isEmpty()){

                // PDFConfigurator__mdt meta = (PDFConfigurator__mdt)JSON.deserialize(JSON.serialize(execution.get('meta')), PDFConfigurator__mdt.class);
                if((String)execution.get('method') == 'getXMLFromQuery4PromiseData'){
                    promiseArrayAsynch.add(PrintPDFController.getXMLFromQuery4PromiseData((String)execution.get('meta'), currentAccount));
                }else if((String)execution.get('method') == 'getXMLFromMethods4PromiseData'){
                    promiseArrayAsynch.add(PrintPDFController.getXMLFromMethods4PromiseData((String)execution.get('meta'), currentAccount));
                }else if((String)execution.get('method') == 'replaceFieldsWithData4Promise'){
                    promiseArrayAsynch.add(execution);
                }
            }
        }

        Map<String, Object> dataMap = new Map<String, Object>{
            'currentAccount' => currentAccount,
            'promiseArray' => promiseArrayAsynch,
            'mappaSezioni' => mappaSezioni,
            'rootXml' => rootXml,
            'recordTypeDeveloperName' => recordTypeDeveloperName,
            'tipoStampa' => tipoStampa,
            'print' => print
        };
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PrintPDFExecuteCallMock());
        PrintPDFController.generatePDFAsynch(JSON.serialize(dataMap));
        
        PrintPDFController.savePDF(currentAccount);
        Test.stopTest();
    }

    private static List<PDFConfigurator__mdt> makeData(){

        List<PDFConfigurator__mdt> TListMetaData = new List<PDFConfigurator__mdt>();

        PDFConfigurator__mdt metadata = new PDFConfigurator__mdt();
        metadata.MasterLabel = 'rootlabel';
        metadata.DeveloperName = 'rootlabel';

        metadata.Ordine__c = 0;
        metadata.OGGETTO__c = 'Account';

        metadata.OBJRECORDTYPE__c = '';

        metadata.SECTION__c = 'rootxml';
        metadata.COMPONENT__c = '';

        metadata.isActive__c = true;
        metadata.isRoot__c = true;
        metadata.HasQuery__c = false;
        metadata.HasMetodoSelezione__c = false;

        metadata.baseXml__c = '<document>	<documentInfo>	  <documentType>{!RecordTypeName__c}</documentType>	  <datarif>{!RecordTypeName__c}</datarif>	</documentInfo>	<bankInfo>	  <ABI>{!RecordTypeName__c}</ABI>	</bankInfo>	<customer>		<fullname>{!RecordTypeName__c}</fullname>		<ndg>{!RecordTypeName__c}</ndg>	</customer>	<compactLayout>		<banca>{!RecordTypeName__c}</banca>		<nomeCliente>{!RecordTypeName__c}</nomeCliente>		<compactNDG>{!RecordTypeName__c}</compactNDG>		<M-MDS>{!RecordTypeName__c}</M-MDS>		<filiale>{!RecordTypeName__c}</filiale>		<portafoglio>{!RecordTypeName__c}</portafoglio>		<gestoreRiferimento>CAMPO_SCONOSCIUTO</gestoreRiferimento>		<privacy>{!RecordTypeName__c}</privacy>		<dataUltimoContatto>CAMPO_SCONOSCIUTO</dataUltimoContatto>	</compactLayout>	###ZONA_SEZIONI###</document>';
        
        metadata.MetodoSelezioneAdditionalParameters__c = '';
        metadata.MetodoSelezioneClasse__c = '';
        metadata.MetodoSelezioneName__c = '';
        
        
        metadata.QueryCampiAggiuntivi__c = '';
        metadata.QueryLookup__c = '';
        metadata.QueryObjectType__c = '';
        metadata.QueryWhereCondition__c = '';
        
        metadata.TemplateIterationXml__c = '';

        TListMetaData.add(metadata);

        PDFConfigurator__mdt metadata2 = new PDFConfigurator__mdt();
        metadata2.MasterLabel = 'Anagraficalabel';
        metadata2.DeveloperName = 'Anagraficalabel';

        metadata2.Ordine__c = 100;
        metadata2.OGGETTO__c = 'Account';

        metadata2.OBJRECORDTYPE__c = '';

        metadata2.SECTION__c = 'Anagrafica';
        metadata2.COMPONENT__c = '';

        metadata2.isActive__c = true;
        metadata2.isRoot__c = false;
        metadata2.HasQuery__c = false;
        metadata2.HasMetodoSelezione__c = false;

        metadata2.baseXml__c = '<anagrafica>###ZONA_COMPONENTI###</anagrafica>';        
        metadata2.MetodoSelezioneAdditionalParameters__c = '';
        metadata2.MetodoSelezioneClasse__c = '';
        metadata2.MetodoSelezioneName__c = '';
        
        
        metadata2.QueryCampiAggiuntivi__c = '';
        metadata2.QueryLookup__c = '';
        metadata2.QueryObjectType__c = '';
        metadata2.QueryWhereCondition__c = '';
        
        metadata2.TemplateIterationXml__c = '';

        TListMetaData.add(metadata2);

        PDFConfigurator__mdt metadata3 = new PDFConfigurator__mdt();
        metadata3.MasterLabel = 'InfoAnagrafelabel';
        metadata3.DeveloperName = 'InfoAnagrafelabel';

        metadata3.Ordine__c = 100;
        metadata3.OGGETTO__c = 'Account';

        metadata3.OBJRECORDTYPE__c = '';

        metadata3.SECTION__c = 'Anagrafica';
        metadata3.COMPONENT__c = 'Info Anagrafe';

        metadata3.isActive__c = true;
        metadata3.isRoot__c = false;
        metadata3.HasQuery__c = false;
        metadata3.HasMetodoSelezione__c = false;

        metadata3.baseXml__c = '<infoAnagrafe>    <informazioniAnagrafe>{!CRM_InformazioniInAnagrafe__c}</informazioniAnagrafe>    <informazioniRiservate>{!CRM_InformazioniRiservate__c}</informazioniRiservate></infoAnagrafe>';        
        metadata3.MetodoSelezioneAdditionalParameters__c = '';
        metadata3.MetodoSelezioneClasse__c = '';
        metadata3.MetodoSelezioneName__c = '';
        
        
        metadata3.QueryCampiAggiuntivi__c = '';
        metadata3.QueryLookup__c = '';
        metadata3.QueryObjectType__c = '';
        metadata3.QueryWhereCondition__c = '';
        
        metadata3.TemplateIterationXml__c = '';

        TListMetaData.add(metadata3);
        
        PDFConfigurator__mdt metadata4 = new PDFConfigurator__mdt();
        metadata4.MasterLabel = 'infoParticolarilabel';
        metadata4.DeveloperName = 'infoParticolarilabel';

        metadata4.Ordine__c = 107;
        metadata4.OGGETTO__c = 'Account';

        metadata4.OBJRECORDTYPE__c = '';

        metadata4.SECTION__c = 'Anagrafica';
        metadata4.COMPONENT__c = 'infoParticolari';

        metadata4.isActive__c = true;
        metadata4.isRoot__c = false;
        metadata4.HasQuery__c = true;
        metadata4.HasMetodoSelezione__c = false;

        metadata4.baseXml__c = '<infoParticolari>			<tabellaGenerica>				<tipoTabella>4</tipoTabella>				<titoloTabella>Informazioni Particolari</titoloTabella> <numeroRighe>###NUMERO_RIGHE###</numeroRighe>				<dettaglio>					<tipoRiga>T</tipoRiga>					<colonna1>CODICE</colonna1>					<colonna2>DESCRIZIONE</colonna2>					<colonna3>DA</colonna3>					<colonna4>A</colonna4>				</dettaglio>###XML_DETTAGLIO###</infoParticolari>';
        metadata4.MetodoSelezioneClasse__c = '';
        metadata4.MetodoSelezioneName__c = '';
        
        
        metadata4.QueryCampiAggiuntivi__c = '';
        metadata4.QueryLookup__c = 'CRM_Account__c';
        metadata4.QueryObjectType__c = 'CRM_InformazioneParticolare__c';
        metadata4.QueryWhereCondition__c = 'AND id != null';
        
        metadata4.TemplateIterationXml__c = '<dettaglio>					<tipoRiga>D</tipoRiga>					<colonna1>{!Id}</colonna1>				</dettaglio>';
        TListMetaData.add(metadata4);

        return TListMetaData;
    }

    @isTest
    public static void testTest(){
        pdfConfiguratorCallableMethods.test();
    }
}