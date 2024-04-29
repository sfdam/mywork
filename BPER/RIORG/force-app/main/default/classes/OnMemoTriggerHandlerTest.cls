@isTest
private class OnMemoTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
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
        insert microPortafoglioFamily;

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount.PTF_Filiale__c = filiale.Id;
        Insert personAccount;

        insert (List<Endpoint__c>)JSON.deserialize('[{"attributes":{"type":"Endpoint__c","url":"/services/data/v56.0/sobjects/Endpoint__c/a0q0D000006L4DwQAK"},"Name":"memoDelete","EndpointParams__c":null,"Endpoint__c":"https://apigw-test.bper.it/gateway/MemoClienteNecServiceAPI/v1/memo/{idMemo}","Method__c":"PUT","Timeout__c":120000,"BodyParams__c":null,"InList__c":false},{"attributes":{"type":"Endpoint__c","url":"/services/data/v56.0/sobjects/Endpoint__c/a0q0D000006L4DxQAK"},"Name":"memoInsert","EndpointParams__c":null,"Endpoint__c":"https://apigw-test.bper.it/gateway/MemoClienteNecServiceAPI/v1/memo","Method__c":"POST","Timeout__c":120000,"BodyParams__c":null,"InList__c":false},{"attributes":{"type":"Endpoint__c","url":"/services/data/v56.0/sobjects/Endpoint__c/a0q0D000006L4DyQAK"},"Name":"memoUpdate","EndpointParams__c":null,"Endpoint__c":"https://apigw-test.bper.it/gateway/MemoClienteNecServiceAPI/v1/memo/{idMemo}","Method__c":"PUT","Timeout__c":120000,"BodyParams__c":null,"InList__c":false}]', List<Endpoint__c>.class);
        OnMemoTriggerHandler.skipTrigger = true;
        CRM_Memo__c memo = new CRM_Memo__c(
            Cliente__c = personAccount.Id,
            Name = 'Test',
            CRM_FineValidita__c = Date.today().addDays(30),
            CRM_PopupCassa__c = true,
            CRM_IdMemoGalileo__c = '1234567'
        );
        insert memo;
    }
    @isTest
    static void testMemoInsertUpdateRequest() {
        Account personAccount = [SELECT ID FROM Account WHERE FirstName = 'FirstName01'];
        CRM_Memo__c memo = new CRM_Memo__c(
            Cliente__c = personAccount.Id,
            Name = 'Test',
            CRM_FineValidita__c = Date.today().addDays(30),
            CRM_PopupCassa__c = true,
            CRM_IdMemoGalileo__c = '123456'
        );
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockChiamataGalileoMemo());
        
        insert memo;
        memo.CRM_PopupCassa__c = false;
        update memo;
        Test.stopTest();
    }

    @isTest
    static void testMemoDeleteRequest() {
        CRM_Memo__c memo = [SELECT ID FROM CRM_Memo__c LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockChiamataGalileoMemo());
            delete memo;
        Test.stopTest();
    }
}