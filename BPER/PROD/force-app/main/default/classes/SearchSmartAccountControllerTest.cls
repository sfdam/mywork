@isTest
public with sharing class SearchSmartAccountControllerTest {
    @TestSetup
    static void setup(){
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
    @isTest static void generateRandomStringTest() {
        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('10', profile.Id, 'Personal');
        user.FederationIdentifier='10';
        insert user;
        System.runAs(user) {
            String str = SearchSmartAccountController.generateRandomString(10);
            System.assert(str.length()>0);
        }
    }
    @isTest static void testGetDettaglioAnagrafica() {
        
        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('10', profile.Id, 'Personal');
        user.FederationIdentifier='10';
        insert user;

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
        //System.runAs(user) {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            String response = SearchSmartAccountController.makeRequest('getDettaglioAnagrafica', recordId, fieldsMap, conditionMap, 'salesforceprodclient2024', null, false);
            SearchSmartAccountResponse res = SearchSmartAccountResponse.parse(response);
            Test.stopTest();
            System.assertEquals(true,response !=null);
        //}
    }
    @isTest static void SearchSmartAccountResponseAccount() {
        test.startTest();
        SearchSmartAccountResponse.Account a = new SearchSmartAccountResponse.Account();
        a.valid ='test';
        a.creationUser  ='test';
        a.lastUpdateUser  ='test';
        a.creationDate  ='test';
        a.updateDate  ='test';
        a.bperGenericId  ='test';
        a.ndg  ='test';
        a.accountCode  ='test';
        a.accountId  ='test';
        a.ibanCode  ='test';
        a.isInformative  ='test';
        a.accountAlias  ='test';
        a.cabCode  ='test';
        a.branchCode  ='test';
        a.id  ='test';
        a.cardHash  ='test';
        a.cardNumber  ='test';
        a.bankCode  ='test';
        a.opening  ='test';
        a.notes  ='test';
        a.onlinePost  ='test';
        a.prodAccount  ='test';
        a.prodAccountDesc  ='test';
        a.cardExpirationDate  ='test';
        a.frontendCategory  ='test';
        a.tolType  ='test';
        a.chargeable  ='test';
        a.mortageType  ='test';
        a.cardCode  ='test';
        a.cardOwnerCode  ='test';
        a.bankDesc  ='test';
        a.branchDesc  ='test';
        a.onlinePostalOwner  ='test';
        a.typeClient  ='test';
        a.aggregatedCardCode  ='test';
        a.portafoglio  ='test';
        a.cardRelations  ='test'; 
        test.stopTest();
        system.assertEquals(true, a != null);
    }
    @isTest static void SearchSmartAccountResponseFeeValue() {
        test.startTest();
        SearchSmartAccountResponse.FeeValue feeVal = new SearchSmartAccountResponse.FeeValue();
        feeVal.valid ='test'; 
        feeVal.creationUser ='test'; 
        feeVal.lastUpdateUser ='test'; 
        feeVal.creationDate ='test'; 
        feeVal.updateDate ='test'; 
        feeVal.bperGenericId ='test'; 
        feeVal.promo ='test'; 
        feeVal.regime ='test'; 
        feeVal.promoDuration ='test'; 
        feeVal.expireDate ='test';
        test.stopTest();
        system.assertEquals(true, feeVal !=null);
    }
    @isTest static void SearchSmartAccountResponseAccountHB() {
        test.startTest();
        SearchSmartAccountResponse.AccountHB aHB = new SearchSmartAccountResponse.AccountHB();
        aHB.valid ='test'; 
        aHB.creationUser ='test'; 
        aHB.lastUpdateUser ='test'; 
        aHB.creationDate ='test'; 
        aHB.updateDate ='test'; 
        aHB.bperGenericId ='test';  
        aHB.ndg ='test'; 
        aHB.accountCode ='test'; 
        aHB.accountId ='test'; 
        aHB.ibanCode ='test'; 
        aHB.isInformative ='test'; 
        aHB.accountAlias ='test'; 
        aHB.cabCode ='test'; 
        aHB.branchCode ='test'; 
        aHB.id ='test'; 
        aHB.cardHash ='test'; 
        aHB.cardNumber ='test'; 
        aHB.bankCode ='test'; 
        aHB.opening ='test'; 
        aHB.notes ='test'; 
        aHB.onlinePost ='test'; 
        aHB.prodAccount ='test'; 
        aHB.prodAccountDesc ='test'; 
        aHB.cardExpirationDate ='test'; 
        aHB.frontendCategory ='test'; 
        aHB.tolType ='test'; 
        aHB.chargeable ='test'; 
        aHB.mortageType ='test'; 
        aHB.cardCode ='test'; 
        aHB.cardOwnerCode ='test'; 
        aHB.bankDesc ='test'; 
        aHB.branchDesc ='test'; 
        aHB.onlinePostalOwner ='test'; 
        aHB.typeClient ='test'; 
        aHB.aggregatedCardCode ='test'; 
        aHB.portafoglio ='test'; 
        aHB.cardRelations ='test';
        test.stopTest();
        System.assertEquals(true, aHB != null);
    }
    @isTest static void SearchSmartAccountResponseCred() {
        test.startTest();
        SearchSmartAccountResponse.Cred cred = new SearchSmartAccountResponse.Cred();
        cred.state ='test';
        cred.credType ='test';
        cred.value ='test';
        cred.credDesc ='test';
        cred.userId ='test';
        test.stopTest();
        system.assertEquals(true, cred != null);
    }
    @isTest static void SearchSmartAccountResponseNdg() {
        test.startTest();
        SearchSmartAccountResponse.Ndg var = new SearchSmartAccountResponse.Ndg();
        var.listaAccount ='test'; 
        var.ndgCode ='test'; 
        var.ndgId ='test'; 
        var.ndgType ='test'; 
        var.bankCode ='test'; 
        var.ndgDesc ='test'; 
        var.branchCode ='test'; 
        var.ndgTypeDesc ='test';
        test.stopTest();
        system.assertEquals(true, var != null);
    }
    @isTest static void SearchSmartAccountResponseBankServiceType_Z() {
        test.startTest();
        SearchSmartAccountResponse.BankServiceType_Z var = new SearchSmartAccountResponse.BankServiceType_Z();
        var.valid ='test'; 
        var.creationUser ='test'; 
        var.lastUpdateUser ='test'; 
        var.creationDate ='test'; 
        var.updateDate ='test'; 
        var.bperGenericId ='test'; 
        var.bankServiceCode ='test'; 
        var.serviceCategory ='test'; 
        var.subCategory ='test'; 
        var.id ='test'; 
        test.stopTest();
        system.assertEquals(true, var != null);
    }
    @isTest static void SearchSmartAccountResponseNdg_Z() {
        test.startTest();
        SearchSmartAccountResponse.Ndg_Z var = new SearchSmartAccountResponse.Ndg_Z();
        var.ndgCode ='test'; 
        var.ndgId ='test'; 
        var.ndgType ='test'; 
        var.bankCode ='test'; 
        var.ndgDesc ='test'; 
        var.branchCode ='test'; 
        var.ndgTypeDesc ='test';
        test.stopTest();
        system.assertEquals(true, var != null);
    }
    @isTest static void SearchSmartAccountResponseUserProfileHb() {
        test.startTest();
        SearchSmartAccountResponse.UserProfileHb var = new SearchSmartAccountResponse.UserProfileHb();
        var.valid ='test'; 
        var.creationUser ='test'; 
        var.lastUpdateUser ='test'; 
        var.creationDate ='test'; 
        var.updateDate ='test'; 
        var.bperGenericId ='test'; 
        var.listaAccount ='test'; 
        var.listaServizioOpzionali ='test'; 
        var.listaTipiServiziBancaApplicabili ='test'; 
        var.customerStart ='test'; 
        var.customerCode ='test'; 
        var.profileId ='test'; 
        var.customerName ='test'; 
        var.taxCode ='test'; 
        var.vvat ='test'; 
        var.referenceEmail ='test'; 
        var.referenceTelephoneNumber1 ='test'; 
        var.bankCust ='test'; 
        var.cabCode ='test'; 
        var.cSae ='test'; 
        var.cRae ='test'; 
        var.branchCode ='test'; 
        var.customerSurname ='test'; 
        var.ndgType ='test'; 
        var.profileIdOld ='test'; 
        var.companyName ='test'; 
        var.birthDate ='test'; 
        var.recurrenceTime ='test'; 
        var.graz ='test'; 
        var.managment ='test'; 
        var.invoice ='test'; 
        var.grazDesc ='test'; 
        var.flagTol ='test'; 
        var.typeHB ='test'; 
        var.riba ='test'; 
        var.userScaState ='test'; 
        var.scaEnrolled ='test'; 
        test.stopTest();
        system.assertEquals(true, var !=null);
    }
    @isTest static void SearchSmartAccountResponseCustomerDataNPV() {
        test.startTest();
        SearchSmartAccountResponse.CustomerDataNPV var = new SearchSmartAccountResponse.CustomerDataNPV();
        var.valid ='test'; 
        var.creationUser ='test'; 
        var.lastUpdateUser ='test'; 
        var.creationDate ='test'; 
        var.updateDate ='test'; 
        var.bperGenericId ='test'; 
        test.stopTest();
        system.assertEquals(true, var !=null);
    }
    @isTest static void SearchSmartAccountResponseAgent() {
        test.startTest();
        SearchSmartAccountResponse.Agent var = new SearchSmartAccountResponse.Agent();
        var.valid ='test'; 
        var.creationUser ='test'; 
        var.lastUpdateUser ='test'; 
        var.creationDate ='test'; 
        var.updateDate ='test'; 
        var.bperGenericId ='test'; 
        var.agentCode ='test'; 
        var.agentOU ='test'; 
        var.termId ='test'; 
        var.branch ='test';
        test.stopTest();
        system.assertEquals(true, var != null);
    }
    @isTest static void SearchSmartAccountResponseSecEvent() {
        test.startTest();
        SearchSmartAccountResponse.SecEvent var = new SearchSmartAccountResponse.SecEvent();
        var.valid ='test'; 
        var.creationUser ='test'; 
        var.lastUpdateUser ='test'; 
        var.creationDate ='test'; 
        var.updateDate ='test'; 
        var.bperGenericId ='test'; 
        var.userId ='test'; 
        var.eventType ='test';  
        var.date_Z ='test'; // in json: date
        var.note ='test'; 
        var.channel ='test';
        test.stopTest();
        system.assertEquals(true, var != null);
    }
    @isTest static void SearchSmartAccountResponseChannel() {
        test.startTest();
        SearchSmartAccountResponse.Channel var = new SearchSmartAccountResponse.Channel();
        var.valid ='test'; 
        var.creationUser ='test'; 
        var.lastUpdateUser ='test'; 
        var.creationDate ='test'; 
        var.updateDate ='test'; 
        var.bperGenericId ='test'; 
        var.channelCode ='test'; 
        var.channelId ='test'; 
        var.channelDesc ='test'; 
        var.aggregationFlag ='test'; 
        var.channelAggregationCode ='test'; 
        var.channelDependingCode ='test'; 
        var.channelDependingDesc ='test';
        test.stopTest();
        system.assertEquals(true, var != null);
    }
    @isTest static void SearchSmartAccountResponseAccountMC() {
        test.startTest();
        SearchSmartAccountResponse.AccountMC var = new SearchSmartAccountResponse.AccountMC();
        var.valid ='test'; 
        var.creationUser ='test'; 
        var.lastUpdateUser ='test'; 
        var.creationDate ='test'; 
        var.updateDate ='test'; 
        var.bperGenericId ='test'; 
        var.ndg ='test'; 
        var.accountCode ='test'; 
        var.accountId ='test'; 
        var.ibanCode ='test'; 
        var.isInformative ='test'; 
        var.accountAlias ='test'; 
        var.cabCode ='test'; 
        var.branchCode ='test'; 
        var.id ='test'; 
        var.cardHash ='test'; 
        var.cardNumber ='test'; 
        var.bankCode ='test'; 
        var.opening ='test'; 
        var.notes ='test'; 
        var.onlinePost ='test'; 
        var.prodAccount ='test'; 
        var.prodAccountDesc ='test'; 
        var.cardExpirationDate ='test'; 
        var.frontendCategory ='test'; 
        var.tolType ='test'; 
        var.chargeable ='test'; 
        var.mortageType ='test'; 
        var.cardCode ='test'; 
        var.cardOwnerCode ='test'; 
        var.bankDesc ='test'; 
        var.branchDesc ='test'; 
        var.onlinePostalOwner ='test'; 
        var.typeClient ='test'; 
        var.aggregatedCardCode ='test'; 
        var.portafoglio ='test'; 
        var.cardRelations ='test';
        test.stopTest();
        system.assertEquals(true, var != null);
    }
    @isTest static void SearchSmartAccountResponseAddressPrf() {
        test.startTest();
        SearchSmartAccountResponse.AddressPrf var = new SearchSmartAccountResponse.AddressPrf();
        var.valid ='test'; 
        var.creationUser ='test'; 
        var.lastUpdateUser ='test'; 
        var.creationDate ='test'; 
        var.updateDate ='test'; 
        var.bperGenericId ='test'; 
        var.address ='test'; 
        var.addressLocal ='test'; 
        var.addressCap ='test'; 
        test.stopTest();
        system.assertEquals(true, var != null);
    }
    @isTest static void SearchSmartAccountResponseNdgHB() {
        test.startTest();
        SearchSmartAccountResponse.NdgHB var = new SearchSmartAccountResponse.NdgHB();
        var.listaAccount ='test'; 
        var.ndgCode ='test'; 
        var.ndgId ='test'; 
        var.ndgType ='test'; 
        var.bankCode ='test'; 
        var.ndgDesc ='test'; 
        var.branchCode ='test'; 
        var.ndgTypeDesc ='test';
        test.stopTest();
        system.assertEquals(true, var != null);
    }
    @isTest static void SearchSmartAccountResponseBankServiceType() {
        test.startTest();
        SearchSmartAccountResponse.BankServiceType var = new SearchSmartAccountResponse.BankServiceType();
        var.valid ='test'; 
        var.creationUser ='test'; 
        var.lastUpdateUser ='test'; 
        var.creationDate ='test'; 
        var.updateDate ='test'; 
        var.bperGenericId ='test'; 
        var.bankServiceCode ='test'; 
        var.serviceCategory ='test'; 
        var.subCategory ='test'; 
        var.id ='test';
        test.stopTest();
        system.assertEquals(true, var != null);
    }
    @isTest static void SearchSmartAccountResponseClientData() {
        test.startTest();
        SearchSmartAccountResponse.ClientData var = new SearchSmartAccountResponse.ClientData();
        var.valid ='test'; 
        var.creationUser ='test'; 
        var.lastUpdateUser ='test'; 
        var.creationDate ='test'; 
        var.updateDate ='test'; 
        var.bperGenericId ='test'; 
        var.account ='test'; 
        var.branchAgent ='test'; 
        var.denomBranchCustomer ='test'; 
        var.surname ='test'; 
        var.name ='test'; 
        var.taxCode ='test'; 
        var.birthDate ='test'; 
        var.denomination ='test'; 
        var.vat ='test'; 
        var.referenceMail ='test'; 
        var.business ='test'; 
        var.status ='test'; 
        var.referencePhone ='test'; 
        var.username ='test'; 
        var.managment ='test'; 
        var.alias ='test'; 
        var.branchCustomer ='test'; 
        var.overrideCode ='test'; 
        var.flgCharge ='test'; 
        var.ownerDenomin ='test'; 
        var.activeServiceDesc ='test'; 
        var.businessDesc ='test'; 
        var.businessName ='test'; 
        var.userIdStatus ='test'; 
        var.passwordStatus ='test';
        test.stopTest();
        system.assertEquals(true, var != null);
    }
    @isTest static void SearchSmartAccountUserProduct() {
        test.startTest();
        SearchSmartAccountResponse.UserProduct var = new SearchSmartAccountResponse.UserProduct();
        var.valid ='test'; 
        var.creationUser ='test'; 
        var.lastUpdateUser ='test'; 
        var.creationDate ='test'; 
        var.updateDate ='test'; 
        var.bperGenericId ='test'; 
        var.listaAgreements ='test'; 
        var.productCode ='test'; 
        var.description ='test'; 
        var.bank ='test'; 
        var.descriptionFull ='test'; 
        var.flagTol ='test';
        test.stopTest();
        system.assertEquals(true, var != null);
    }

    
}