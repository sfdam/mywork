@isTest
public without sharing class MakeRequestV2ControllerTest {

    public static Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    public static String certificationName = isSandbox ? 'salesforcetestclient2024' : 'salesforceprodclient2024';
    @TestSetup
    static void setup(){
        
        // TriggerControl__c tc = new TriggerControl__c();
        // tc.name = 'TEST';
        // insert tc;

        Account account = AllDataFactory.getAccount('01', 'PersonAccount');
        account.FinServ__BankNumber__c = '05387';
        account.CRM_NDG__c = '2816687'; 
        insert account;

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test';
        opportunity.CloseDate = Date.today().addDays(10);
        opportunity.StageName = 'Prosect';
        opportunity.AccountId = account.Id;
        insert opportunity;

        Product2 product = new Product2();
        product.Name = 'TestProduct';
        product.ProductCode = 'PV_1000002';
        insert product;

        FinServ__FinancialAccount__c financialAccount = AllDataFactory.getFinancialAccount('BankingAccount', '01', account.Id);
        financialAccount.FinServ__FinancialAccountNumber__c = '000000882095';
        financialAccount.CRM_Ced__c = '0055';
        financialAccount.FinServ__ProductName__c = product.Id;
        financialAccount.CRM_Tipologia_Carta__c = 'CREDITO';
        financialAccount.CRM_CardNumber__c = 'testNumero';
        insert financialAccount;

        CRM_Channel__c servizioDigitale = new CRM_Channel__c();
        servizioDigitale.Financial_Account__c = financialAccount.Id;
        servizioDigitale.CRM_Account__c = account.Id;
        servizioDigitale.CRM_UserId__c = '2115557';
        insert servizioDigitale;

        Endpoint__c endpoint = new Endpoint__c();
        endpoint.Name = 'getDettaglioAnagrafica';
        endpoint.Method__c = 'GET';
        endpoint.Timeout__c = 120000;
        endpoint.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/AnagrafeClientiAPI/v4/anagrafica/dettaglio-anagrafica/abi/{abi}/ndgSettoriale/{ndgSettoriale}';

        Endpoint__c endpoint3 = new Endpoint__c();
        endpoint3.Name = 'getProfiloCarteNDG';
        endpoint3.Method__c = 'GET';
        endpoint3.Timeout__c = 120000;
        endpoint3.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/CarteAPI/v2/carte/profilo-carte-ndg/abi/{abi}/ndg/{ndg}/tipoCliente/{tipoCliente}/tipoCarta/TUTTE';
        endpoint3.EndpointParams__c = '{"abi":"{testata_abi}","termid": "WEB","utente":"{security_utente}","agenzia":"{security_idced}","livello":"05"}';
        

        Endpoint__c endpoint5 = new Endpoint__c();
        endpoint5.Name = 'getInfoCarte';
        endpoint5.Method__c = 'POST';
        endpoint5.Timeout__c = 120000;
        endpoint5.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/ContactCenterCarteAPI/v1/contact-center-carte/getInfoCarte';
        endpoint5.BodyParams__c = '{"abi":"{testata_abi}","numeroCarta":"{numeroCarta}","tipoCarta":"{tipologiaCarta}"}';

        Endpoint__c endpoint6 = new Endpoint__c();
        endpoint6.Name = 'listaRapporti';
        endpoint6.Method__c = 'GET';
        endpoint6.Timeout__c = 120000;
        endpoint6.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/RataInContoServiceAPI/v1/rapporti';
        endpoint6.EndpointParams__c = '{"abiBanca":"{abi}","ndg": "{ndg}","stato":"A"}';

        Endpoint__c endpoint7 = new Endpoint__c();
        endpoint7.Name = 'listaPiani';
        endpoint7.Method__c = 'GET';
        endpoint7.Timeout__c = 120000;
        endpoint7.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/RataInContoServiceAPI/v1/prodotti/{codProdotto}/piani';
        endpoint7.EndpointParams__c = '{"abiBanca":"{abiBanca}","rapportoRataInConto": "{rapportoRataInConto}", "numeroPiano": "{numeroPianoParam}"}';
        insert new List<Endpoint__c>{endpoint, endpoint3, endpoint5, endpoint6, endpoint7};
    }

    @isTest static void testGetDettaglioAnagrafica() {
        
        Id recordId = [SELECT id FROM Account LIMIT 1].Id;
        // Set mock callout classs 
        
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper_v2'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('getDettaglioAnagrafica')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        Map<String, Map<String, Map<String, Object>>> fieldsMap = new Map<String, Map<String, Map<String, Object>>>();
        fieldsMap.put('getDettaglioAnagrafica', new Map<String, Map<String, Object>>());
        Map<String, Map<String, Map<String, String>>> conditionMap = new Map<String, Map<String, Map<String, String>>>();
        conditionMap.put('getDettaglioAnagrafica', new Map<String, Map<String, String>>());
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.get('getDettaglioAnagrafica').put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }

        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.get('getDettaglioAnagrafica').put(conditionName, (Map<String, String>)JSON.deserialize(JSON.serialize(parsedJsonElementCondiions.get(conditionName)), Map<String,String>.class));
            }
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Map<String, Object> response = MakeRequestV2Controller.init(recordId, fieldsMap, conditionMap, new List<String>());
        Map<String, Object> response2 = MakeRequestV2Controller.getResponse((SObject)response.get('record'), 'getDettaglioAnagrafica', fieldsMap.get('getDettaglioAnagrafica'), conditionMap.get('getDettaglioAnagrafica'), certificationName, false, null);
        Test.stopTest();
    }

    @isTest static void testGetProfiloCarteNDG() {
        
        Id recordId = [SELECT id FROM Account LIMIT 1].Id;
        // Set mock callout class 
        
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper_v2'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('getProfiloCarteNDG')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        Map<String, Map<String, Map<String, Object>>> fieldsMap = new Map<String, Map<String, Map<String, Object>>>();
        fieldsMap.put('getProfiloCarteNDG', new Map<String, Map<String, Object>>());
        Map<String, Map<String, Map<String, String>>> conditionMap = new Map<String, Map<String, Map<String, String>>>();
        conditionMap.put('getProfiloCarteNDG', new Map<String, Map<String, String>>());
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.get('getProfiloCarteNDG').put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }

        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.get('getProfiloCarteNDG').put(conditionName, (Map<String, String>)JSON.deserialize(JSON.serialize(parsedJsonElementCondiions.get(conditionName)), Map<String,String>.class));
            }
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Map<String, Object> response = MakeRequestV2Controller.init(recordId, fieldsMap, conditionMap, new List<String>());
        Map<String, Object> response2 = MakeRequestV2Controller.getResponse((SObject)response.get('record'), 'getProfiloCarteNDG', fieldsMap.get('getProfiloCarteNDG'), conditionMap.get('getProfiloCarteNDG'), certificationName, false, null);
        Test.stopTest();
    }

    @isTest static void testGetInfoCarte() {
        
        Id recordId = [SELECT id FROM FinServ__FinancialAccount__c LIMIT 1].Id;
        // Set mock callout class 
        
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper_v2'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('getInfoCarte')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        Map<String, Map<String, Map<String, Object>>> fieldsMap = new Map<String, Map<String, Map<String, Object>>>();
        fieldsMap.put('getInfoCarte', new Map<String, Map<String, Object>>());
        Map<String, Map<String, Map<String, String>>> conditionMap = new Map<String, Map<String, Map<String, String>>>();
        conditionMap.put('getInfoCarte', new Map<String, Map<String, String>>());
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.get('getInfoCarte').put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }

        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.get('getInfoCarte').put(conditionName, (Map<String, String>)JSON.deserialize(JSON.serialize(parsedJsonElementCondiions.get(conditionName)), Map<String,String>.class));
            }
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Map<String, Object> response = MakeRequestV2Controller.init(recordId, fieldsMap, conditionMap, new List<String>());
        Map<String, Object> response2 = MakeRequestV2Controller.getResponse((SObject)response.get('record'), 'getInfoCarte', fieldsMap.get('getInfoCarte'), conditionMap.get('getInfoCarte'), certificationName, false, null);
        Test.stopTest();
    }

    @isTest static void testListaRapporti() {
        
        Id recordId = [SELECT id FROM Account LIMIT 1].Id;
        // Set mock callout class 
        
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper_v2'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('listaRapporti')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        Map<String, Map<String, Map<String, Object>>> fieldsMap = new Map<String, Map<String, Map<String, Object>>>();
        fieldsMap.put('listaRapporti', new Map<String, Map<String, Object>>());
        Map<String, Map<String, Map<String, String>>> conditionMap = new Map<String, Map<String, Map<String, String>>>();
        conditionMap.put('listaRapporti', new Map<String, Map<String, String>>());
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.get('listaRapporti').put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }

        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.get('listaRapporti').put(conditionName, (Map<String, String>)JSON.deserialize(JSON.serialize(parsedJsonElementCondiions.get(conditionName)), Map<String,String>.class));
            }
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Map<String, Object> response = MakeRequestV2Controller.init(recordId, fieldsMap, conditionMap, new List<String>());
        Map<String, Object> response2 = MakeRequestV2Controller.getResponse((SObject)response.get('record'), 'listaRapporti', fieldsMap.get('listaRapporti'), conditionMap.get('listaRapporti'), certificationName, false, null);
        Test.stopTest();
    }

    @isTest static void testListaPiani() {
        
        Id recordId = [SELECT id FROM FinServ__FinancialAccount__c LIMIT 1].Id;
        // Set mock callout class 
        
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper_v2'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('listaPiani')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        Map<String, Map<String, Map<String, Object>>> fieldsMap = new Map<String, Map<String, Map<String, Object>>>();
        fieldsMap.put('listaPiani', new Map<String, Map<String, Object>>());
        Map<String, Map<String, Map<String, String>>> conditionMap = new Map<String, Map<String, Map<String, String>>>();
        conditionMap.put('listaPiani', new Map<String, Map<String, String>>());
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.get('listaPiani').put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }

        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.get('listaPiani').put(conditionName, (Map<String, String>)JSON.deserialize(JSON.serialize(parsedJsonElementCondiions.get(conditionName)), Map<String,String>.class));
            }
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Map<String, Object> response = MakeRequestV2Controller.init(recordId, fieldsMap, conditionMap, new List<String>());
        Map<String, Object> response2 = MakeRequestV2Controller.getResponse((SObject)response.get('record'), 'listaPiani', fieldsMap.get('listaPiani'), conditionMap.get('listaPiani'), certificationName, false, null);
         MakeRequestV2Controller.saveElements(JSON.serialize(new List<SObject>{(SObject)response.get('record')}), JSON.serialize(new List<SObject>{}));
        MakeRequestV2Controller.updateElements(new List<SObject>{(SObject)response.get('record')});
        Test.stopTest();
    }
}