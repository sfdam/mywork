@isTest
public class WGC_Storico_AttivitaController_Test {
    private static List<PDFConfigurator__mdt> selectedSections = new List<PDFConfigurator__mdt>();

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
    public static void test_storicoAll(){
        
        
        Account acc = [SELECT Id, Name, RecordTypeId, RecordTypeName__c FROM Account WHERE Name = 'Test' LIMIT 1];
        PDFConfigurator__mdt meta = new PDFConfigurator__mdt();
        meta.baseXml__c = '<tabellaprodotto><tipoTabella>2</tipoTabella><nomeProdotto>TEST CONTI CORRENTI</nomeProdotto><numeroProdotti>###NUMERO_RIGHE###</numeroProdotti>###XML_DETTAGLIO###</tabellaprodotto>';
        meta.MetodoSelezioneClasse__c = 'pdfConfiguratorCallableMethods';
        meta.MetodoSelezioneName__c = 'getProdottiList';
        meta.MetodoSelezioneAdditionalParameters__c = '{"RecordType": "BankingAccount", "statusFinServ": "ATTIVO"}';
        meta.TemplateIterationXml__c = '<dettaglio1>{!financialAccount_Name}</dettaglio1><dettaglio2>{!financialRole_FinServ__Role__c}</dettaglio2></prodottoDettaglio>';
        meta.HasMetodoSelezione__c = true;
        
        Test.startTest();
        //WGC_Storico_AttivitaController.getAllData((String)acc.Id, 'Account', '');
        WGC_Storico_AttivitaController.getAllData((String)acc.Id, 'Opportunity', '','00e3X000002iXa6');
        WGC_Storico_AttivitaController.getAllData((String)acc.Id, 'FinServ__FinancialAccount__c', '','00e3X000002iXa6');

        WGC_Storico_AttivitaController.getAllData((String)acc.Id, 'CRM_Memo__c', '','00e3X000002iXa6');
        //WGC_Storico_AttivitaController.getAllData((String)acc.Id, 'Task', '');
        WGC_Storico_AttivitaController.getAllData((String)acc.Id, 'NDGManagementMember__c', '','00e3X000002iXa6');
        
        
        WGC_Storico_AttivitaController.getUserInfo();
        Object response = WGC_Storico_AttivitaController.initStampa(acc.Id);
        List<PDFConfigurator__mdt> ListMetaData = makeData();
        String rootxml = WGC_Storico_AttivitaController.getRootXML(ListMetaData, acc);
        
        String recordTypeDeveloperName = 'IndustriesBusiness';
        selectedSections = new List<PDFConfigurator__mdt>();
        selectedSections.add(new PDFConfigurator__mdt(SECTION__c = 'Anagrafica'));

        List<PDFConfigurator__mdt> fullMetadata = WGC_Storico_AttivitaController.getFullMetadataFromSelected(selectedSections, 'Account', recordTypeDeveloperName);
        String xmlFromQuery = '';
        for(PDFConfigurator__mdt m2 : ListMetaData){
            if(m2.HasQuery__c){
                Map<String,String> resultMap = WGC_Storico_AttivitaController.getXMLFromQuery4Promise(m2,acc);
                System.debug('xmlFromQuery: '+xmlFromQuery);
            }
        }

        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('FinServ__FinancialAccount__c'));
        List<FinServ__FinancialAccount__c> recordList = (List<FinServ__FinancialAccount__c>)Database.query(query);
        Map<String, String> recordObjectTypeMap = new map<String, String>();
        for(FinServ__FinancialAccount__c finalcialAccount : recordList){
            recordObjectTypeMap.put(finalcialAccount.Id, 'FinServ__FinancialAccount__c');
        }

        response = WGC_Storico_AttivitaController.getXMLFromMethods4Promise(meta, acc, recordList, recordObjectTypeMap);
        WGC_Storico_AttivitaController.filterDataFunction(acc.Id, 'FinServ__FinancialAccount__c',Date.today().addDays(-365), Date.today().addDays(365));
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
}