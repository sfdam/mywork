@isTest
public with sharing class MakeRequestControllerTest {

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

        Endpoint__c endpoint2 = new Endpoint__c();
        endpoint2.Name = 'recuperaDettaglioConto';
        endpoint2.Method__c = 'GET';
        endpoint2.Timeout__c = 120000;
        endpoint2.Endpoint__c = 'https://apigw-test.bper.it/gateway/ContiCorrentiAPI/v3/conti-correnti/recupera-dettaglio-conto/abi/{abi}/codiceFiliale/{codiceFiliale}/numeroConto/{numeroConto}';
        endpoint2.EndpointParams__c = '{"abi":"{testata_abi}","termid": "WEB","utente":"{security_utente}","agenzia":"{security_idced}","livello":"50"}';

        Endpoint__c endpoint3 = new Endpoint__c();
        endpoint3.Name = 'searchSmartAccountExtended';
        endpoint3.Method__c = 'GET';
        endpoint3.Timeout__c = 120000;
        endpoint3.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/CallbackWSAPI/v1/callback/search-smart-account-extended/scope/POSTVENDITA/type/NDG/ndg/{ndg}/isAttivo/{isAttivo}';

        Endpoint__c endpoint4 = new Endpoint__c();
        endpoint4.Name = 'ricercaMovimentiConto';
        endpoint4.Method__c = 'GET';
        endpoint4.Timeout__c = 120000;
        endpoint4.Endpoint__c = 'https://apigw-test.bper.it/gateway/ContiCorrentiAPI/v3/conti-correnti/ricerca-movimenti-conto/abi/{abi}/codiceFiliale/{codiceFiliale}/numeroConto/{numeroConto}';
        endpoint4.EndpointParams__c = '{"importoDa":"{C}","importoA":"{C}","TipoMovimento":"{C}","TipoOrdinamento":"{C}","numeroPagina":"{C}", "NumeroMaxElementiPerPagina":"{C}"}';

        Endpoint__c endpoint5 = new Endpoint__c();
        endpoint5.Name = 'notificaStatoProcesso';
        endpoint5.Method__c = 'POST';
        endpoint5.Timeout__c = 120000;
        endpoint5.Endpoint__c = 'https://apigw-test.bper.it/gateway/CrmAPI/v1/crm/notifica-stato-processo/';
        endpoint5.BodyParams__c = '{"abi":"{testata_abi}","ndg": "{ndg}","dataRichiesta":"{dataRichiesta}","prodottoCorrelato":"{prodottoCorrelato}","parametro#dettaglio_richiesta":"{parametro#dettaglioRichiesta}"}';

        insert new List<Endpoint__c>{endpoint, endpoint2, endpoint3, endpoint4, endpoint5};
    }

    @isTest static void testGetDettaglioAnagrafica() {
        
        Id recordId = [SELECT id FROM Account LIMIT 1].Id;
        // Set mock callout class 
        
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('getDettaglioAnagrafica')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        Map<String, Map<String, Object>> fieldsMap = new Map<String, Map<String, Object>>();
        Map<String, Map<String, String>> conditionMap = new Map<String, Map<String, String>>();
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }

        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.put(conditionName, (Map<String, String>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementCondiions.get(conditionName))));
            }
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        String response = MakeRequestController.makeRequest('getDettaglioAnagrafica', recordId, fieldsMap, conditionMap, 'salesforcetestclient2024', null, false);
        System.debug('DK response: ' + response);
        Test.stopTest();
    }

    @isTest static void testRecuperaDettaglioConto() {
        
        Id recordId = [SELECT id FROM FinServ__FinancialAccount__c LIMIT 1].Id;
        // Set mock callout class 
        
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('recuperaDettaglioConto')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        Map<String, Map<String, Object>> fieldsMap = new Map<String, Map<String, Object>>();
        Map<String, Map<String, String>> conditionMap = new Map<String, Map<String, String>>();
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }

        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.put(conditionName, (Map<String, String>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementCondiions.get(conditionName))));
            }
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        String response = MakeRequestController.makeRequest('recuperaDettaglioConto', recordId, fieldsMap, conditionMap, 'salesforceprodclient2024', null, false);
        Test.stopTest();
    }

    @isTest static void testSearchSmartAccountExtended() {
        
        Id recordId = [SELECT id FROM Account LIMIT 1].Id;
        // Set mock callout class 
        
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('searchSmartAccountExtended')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        Map<String, Map<String, Object>> fieldsMap = new Map<String, Map<String, Object>>();
        Map<String, Map<String, String>> conditionMap = new Map<String, Map<String, String>>();
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }

        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.put(conditionName, (Map<String, String>)JSON.deserialize(JSON.serialize(parsedJsonElementCondiions.get(conditionName)), Map<String, String>.class));
            }
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        String response = MakeRequestController.makeRequest('searchSmartAccountExtended', recordId, fieldsMap, conditionMap, 'salesforceprodclient2024', null, false);
        Test.stopTest();
    }

    @isTest static void testNotificaStatoProcesso() {
        
        Id recordId = [SELECT id FROM Opportunity LIMIT 1].Id;
        // Set mock callout class 
        
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('notificaStatoProcesso')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        Map<String, Map<String, Object>> fieldsMap = new Map<String, Map<String, Object>>();
        Map<String, Map<String, String>> conditionMap = new Map<String, Map<String, String>>();
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }

        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.put(conditionName, (Map<String, String>)JSON.deserialize(JSON.serialize(parsedJsonElementCondiions.get(conditionName)), Map<String, String>.class));
            }
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        String response = MakeRequestController.makeRequest('notificaStatoProcesso', recordId, fieldsMap, conditionMap, 'salesforceprodclient2024', null, false);
        Test.stopTest();
    }

    @isTest static void testWriteLOg() {
        
        Test.startTest();
        WsRestUtils.writeLog(
            'notificaStatoProcesso',
            'POST',
            NULL,
            204,
            'SUCCESS',
            null,
            new Map<String,String>(),
            new Map<String,String>(),
            '',
            ''
            // responseObj.isCorrect() ? null : responseObj.getErrors()
        );

        WsRestUtils.writeLog(
            'notificaStatoProcesso',
            'POST',
            null,
            '204',
            'SUCCESS',
            null,
            new Map<String,String>(),
            new Map<String,String>(),
            '',
            ''
            // responseObj.isCorrect() ? null : responseObj.getErrors()
        );
        Test.stopTest();
    }

    @isTest static void testMakeRequestWithParams() {
        
        Id recordId = [SELECT id FROM FinServ__FinancialAccount__c LIMIT 1].Id;
        // Set mock callout class 
        
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('ricercaMovimentiConto')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        Map<String, Map<String, Object>> fieldsMap = new Map<String, Map<String, Object>>();
        Map<String, Map<String, String>> conditionMap = new Map<String, Map<String, String>>();
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }

        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.put(conditionName, (Map<String, String>)JSON.deserialize(JSON.serialize(parsedJsonElementCondiions.get(conditionName)), Map<String, String>.class));
            }
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        String response = MakeRequestController.makeRequestWithParams('ricercaMovimentiConto', recordId, fieldsMap, conditionMap, 'salesforceprodclient2024', null, '[{"input":true,"disabled":false,"type":"number","label":"importo da","key":"importoDa","value":20},{"input":true,"disabled":false,"type":"number","label":"importa a","key":"importoA","value":20},{"picklist":true,"disabled":false,"type":"text","label":"Tipo Movimento","key":"TipoMovimento","option":[{"label":"AVERE","value":"AVERE"},{"label":"DARE","value":"DARE"}],"value":"AVERE"},{"picklist":false,"disabled":true,"label":"Tipo Ordinamento","key":"TipoOrdinamento","option":[{"label":"CRESCENTE","value":"CRESCENTE"},{"label":"DECRESCENTE","value":"DECRESCENTE"}],"value":"CRESCENTE"},{"page":true,"disabled":true,"type":"number","label":"numero pagina","key":"numeroPagina","value":1},{"elementForPage":true,"disabled":true,"type":"number","label":"numero elementi per pagina","key":"NumeroMaxElementiPerPagina","value":20}]', false);
        Test.stopTest();
    }

    @isTest
    public static void testTest(){
        MakeRequestController.test();
    }
}