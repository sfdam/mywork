@isTest
public with sharing class PrintPDFControllerTest {
    private static String PDFConfiguratorJSON = '';

    private static List<PDFConfigurator__mdt> selectedSections = new List<PDFConfigurator__mdt>();
    private static String rootCampiAggiuntivi = '';
    private static String rootxml = '';
    private static String sectionsxml = '';

    @testsetup
    static void inserts(){
        RecordType rectype = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'IndustriesBusiness' LIMIT 1];

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
        financialAccount.FinServ__PrimaryOwner__c = testAcc.Id;
        insert financialAccount;

        FinServ__FinancialAccountRole__c financialRole = new FinServ__FinancialAccountRole__c();
        financialRole.FinServ__RelatedAccount__c = testAcc.Id;
        financialRole.FinServ__FinancialAccount__c = financialAccount.Id;
        financialRole.FinServ__Role__c='Primary Owner';
        insert financialRole;

        Endpoint__c generateDocument = (Endpoint__c)JSON.deserialize('{"attributes":{"type":"Endpoint__c","url":""},"IsDeleted":false,"Name":"generateDocument","EndpointParams__c":null,"Endpoint__c":"https://apigw.bper.it/gateway/DocumentsGenerationEngineAPI/v1/documentsgenerationengine/generateDocument","Method__c":"POST","Timeout__c":120000,"BodyParams__c":null,"InList__c":false}', Endpoint__c.class);
        insert generateDocument;
    }

    @isTest
    private static void loadMetaDataStructure_Test() {
        List<PDFConfigurator__mdt> metadata = PrintPDFController.loadMetaDataStructure(AccountData().Id);
    }
	
    //S: Vecchia Gestione waterfall, sostituita dalle promise
    /*@isTest
    private static void generaXml_Test(){

        selectedSections = new List<PDFConfigurator__mdt>();
        selectedSections.add(new PDFConfigurator__mdt(SECTION__c = 'Anagrafica'));
        String xml = PrintPDFController.generaXml(selectedSections,AccountData().Id);

        System.debug('xml: '+xml);

    }*/
    //E: Vecchia Gestione waterfall, sostituita dalle promise
    
    @isTest
    private static void getFullMetadataFromSelected_Test(){
        String recordTypeDeveloperName = 'IndustriesBusiness';
        selectedSections = new List<PDFConfigurator__mdt>();
        selectedSections.add(new PDFConfigurator__mdt(SECTION__c = 'Anagrafica'));

        List<PDFConfigurator__mdt> fullMetadata = PrintPDFController.getFullMetadataFromSelected(selectedSections, 'Account', recordTypeDeveloperName);
        System.debug('fullMetadata: '+JSON.serialize(fullMetadata));

    }
    
    @isTest
    private static void getRootCampiAggiuntivi_Test(){
        List<PDFConfigurator__mdt> ListMetaData = makeData();
        String recordTypeDeveloperName = 'IndustriesBusiness';
        rootCampiAggiuntivi = PrintPDFController.getRootCampiAggiuntivi('Account', recordTypeDeveloperName);
        System.debug('rootCampiAggiuntivi: '+JSON.serialize(rootCampiAggiuntivi));
    }

    @isTest
    private static void getRootXML_Test(){
        List<PDFConfigurator__mdt> ListMetaData = makeData();
        rootxml = PrintPDFController.getRootXML(ListMetaData,AccountData());
        System.debug('rootxml: '+rootxml);
    }

    //S: Vecchia Gestione waterfall, sostituita dalle promise
    /*@isTest
    private static void getSezioniXML_Test(){
        List<PDFConfigurator__mdt> ListMetaData = makeData();
        sectionsxml = PrintPDFController.getSezioniXML(ListMetaData,AccountData());
        System.debug('sectionsxml: '+sectionsxml);
    }*/
    //E: Vecchia Gestione waterfall, sostituita dalle promise


    @isTest
    private static void getXMLFromQuery_Test(){
        List<PDFConfigurator__mdt> ListMetaData = makeData();
        String xmlFromQuery = '';
        for(PDFConfigurator__mdt m2 : ListMetaData){
            if(m2.HasQuery__c){
                xmlFromQuery = PrintPDFController.getXMLFromQuery(m2,AccountData());
                Map<String,String> resultMap = PrintPDFController.getXMLFromQuery4Promise(m2,AccountData());
                System.debug('xmlFromQuery: '+xmlFromQuery);
            }
        }
    }

    @isTest
    private static void getFieldValueTest(){
        Account accTest = [SELECT Name, RecordTypeId, PTF_DataApertura__c, CRM_DataAggCreditRating__c FROM Account WHERE Name = 'Test' LIMIT 1].get(0);
        Test.startTest();
            String testNameString = PrintPDFController.getFieldValue(accTest, 'Name');
            String testDateTimeString = PrintPDFController.getFieldValue(accTest, 'PTF_DataApertura__c');
            String testDateString = PrintPDFController.getFieldValue(accTest, 'CRM_DataAggCreditRating__c');
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(testNameString), 'getFieldValueTest testNameString');
        System.assertEquals(true, String.isNotBlank(testDateTimeString), 'getFieldValueTest testDateTimeString');
        System.assertEquals(true, String.isNotBlank(testDateString), 'getFieldValueTest testDateString');
    }

    @isTest
    private static void replaceFieldsWithDataTest(){
        Account currentObject = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1].get(0);
        PDFConfigurator__mdt meta = new PDFConfigurator__mdt();
        meta.baseXml__c = '<tabellaprodotto><tipoTabella>2</tipoTabella><nomeProdotto>TEST CONTI CORRENTI</nomeProdotto><numeroProdotti>###NUMERO_RIGHE###</numeroProdotti>###XML_DETTAGLIO###</tabellaprodotto>';

        String xmlTestField = '<xml>{!campoDiTest}</xml>';
        Map<String,String> fieldNameToFieldValueMap = new Map<String,String>();
        fieldNameToFieldValueMap.put('campoDiTest', 'valoreDiTest');
        Test.startTest();
            String returnedXML = PrintPDFController.replaceFieldsWithData(xmlTestField, fieldNameToFieldValueMap);
            Map<String,String> resultMap = PrintPDFController.replaceFieldsWithData4Promise(meta,currentObject);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(returnedXML), 'replaceFieldsWithDataTest');
    }

    @isTest
    private static void getAllData_Test(){
        rootCampiAggiuntivi = 'RecordType.DeveloperName';
        Test.startTest();
        Map<String, Object> response = (Map<String, Object>) PrintPDFController.getAllData(AccountData().Id);
        Test.stopTest();
        System.assertEquals(true, response != null, 'getAllData_Test');
    }

    // @isTest
    // private static void getAccountData_Test(){
    //     rootCampiAggiuntivi = 'RecordType.DeveloperName';
    //     Test.startTest();
    //         Account resultAcc = PrintPDFController.getAccountData(AccountData().Id)[0];
    //     Test.stopTest();
    //     System.assertEquals(true, resultAcc != null, 'getAccountData_Test');
    // }

    // @isTest
    // private static void getAccountRecordTypeDeveloperName_Test(){
    //     Test.startTest();
    //         String recordTypeDeveloperName = PrintPDFController.getAccountRecordTypeDeveloperName(AccountData().Id);
    //     Test.stopTest();
    //     System.assertEquals(true, String.isNotBlank(recordTypeDeveloperName), 'getAccountRecordTypeDeveloperName_Test');
    // }

    /*@isTest
    private static void getXMLFromMethodsTest(){
        Account currentObject = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1].get(0);
        PDFConfigurator__mdt meta = new PDFConfigurator__mdt();
        meta.baseXml__c = '<tabellaprodotto><tipoTabella>2</tipoTabella><nomeProdotto>TEST CONTI CORRENTI</nomeProdotto><numeroProdotti>###NUMERO_RIGHE###</numeroProdotti>###XML_DETTAGLIO###</tabellaprodotto>';
        meta.MetodoSelezioneClasse__c = 'pdfConfiguratorCallableMethods';
        meta.MetodoSelezioneName__c = 'getProdottiList';
        meta.MetodoSelezioneAdditionalParameters__c = '{"RecordType": "BankingAccount", "statusFinServ": "ATTIVO"}';
        meta.TemplateIterationXml__c = '<dettaglio1>{!financialAccount_Name}</dettaglio1><dettaglio2>{!financialRole_FinServ__Role__c}</dettaglio2></prodottoDettaglio>';
        meta.HasMetodoSelezione__c = true;
        Test.startTest();
            String xmlString = PrintPDFController.getXMLFromMethods(meta, currentObject, null);
            Map<String,String> responseMap = PrintPDFController.getXMLFromMethods4Promise(meta,currentObject, null);
            responseMap = PrintPDFController.getXMLFromMethods4Promise(meta,currentObject);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(xmlString), 'getXMLFromMethodsTest');
    }

    @isTest
    private static void getXMLFromMethodsDataTest(){
        Account currentObject = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1].get(0);
        PDFConfigurator__mdt meta = new PDFConfigurator__mdt();
        meta.baseXml__c = '<tabellaprodotto><tipoTabella>2</tipoTabella><nomeProdotto>TEST CONTI CORRENTI</nomeProdotto><numeroProdotti>###NUMERO_RIGHE###</numeroProdotti>###XML_DETTAGLIO###</tabellaprodotto>';
        meta.MetodoSelezioneClasse__c = 'pdfConfiguratorCallableMethods';
        meta.MetodoSelezioneName__c = 'getProdottiList';
        meta.MetodoSelezioneAdditionalParameters__c = '{"RecordType": "BankingAccount", "statusFinServ": "ATTIVO"}';
        meta.TemplateIterationXml__c = '<dettaglio1>{!financialAccount_Name}</dettaglio1><dettaglio2>{!financialRole_FinServ__Role__c}</dettaglio2></prodottoDettaglio>';
        meta.HasMetodoSelezione__c = true;
        Test.startTest();
            Map<String,Object> responseMap = PrintPDFController.getXMLFromMethods4PromiseData(JSON.serialize(meta),currentObject);
        Test.stopTest();
    }*/
    
    private static Account AccountData(){
        return [SELECT Id, Name, RecordTypeId, RecordTypeName__c FROM Account WHERE Name = 'Test' LIMIT 1];
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
        metadato2.baseXml__c = '<tabellaprodotto><tipoTabella>2</tipoTabella><nomeProdotto>TEST CONTI CORRENTI</nomeProdotto><numeroProdotti>###NUMERO_RIGHE###</numeroProdotti>###XML_DETTAGLIO###</tabellaprodotto>';
        metadato2.MetodoSelezioneClasse__c = 'pdfConfiguratorCallableMethods';
        metadato2.MetodoSelezioneName__c = 'getProdottiList';
        metadato2.MetodoSelezioneAdditionalParameters__c = '{"RecordType": "BankingAccount", "statusFinServ": "ATTIVO"}';
        metadato2.TemplateIterationXml__c = '<dettaglio1>{!financialAccount_Name}</dettaglio1><dettaglio2>{!financialRole_FinServ__Role__c}</dettaglio2></prodottoDettaglio>';
        metadato2.HasMetodoSelezione__c = true;
        metadato2.isActive__c =true;
        metadato2.SECTION__c = 'Prodotti Attivi';
        metadato2.COMPONENT__c = 'Banking Multicanale';*/
        List<PDFConfigurator__mdt> fullMetadata = PrintPDFController.getFullMetadataFromSelected(selectedSections, 'Account', recordTypeDeveloperName);
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

    @isTest
    private static void testReplaceFieldsWithDataIRW(){

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
        PrintPDFController.test();
    }
}