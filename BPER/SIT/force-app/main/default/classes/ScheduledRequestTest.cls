@isTest
public with sharing class ScheduledRequestTest {

    public static Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    public static String certificationName = isSandbox ? 'salesforcetestclient2024' : 'salesforceprodclient2024';
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

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        
        User user = AllDataFactory.getUser('10', profile.Id, 'Personal');
        user.FederationIdentifier='10';
        insert user;

        Endpoint__c endpoint2 = new Endpoint__c();
        endpoint2.Name = 'aggiornaFilialeDiRelazione';
        endpoint2.Method__c = 'PATCH';
        endpoint2.Timeout__c = 120000;
        endpoint2.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/AnagrafeClientiAPI/v4/anagrafica/aggiorna-filiale/bancaSett/{bancaSett}/codiceNDG/{codiceNDG}/filialePrincipale/{filialePrincipale}';
        insert endpoint2;

        insert (List<Endpoint__c>)JSON.deserialize('[{"attributes":{"type":"Endpoint__c","url":"/services/data/v56.0/sobjects/Endpoint__c/a0q0D000006L4DwQAK"},"Name":"memoDelete","EndpointParams__c":null,"Endpoint__c":"https://apigw-test.bper.it/gateway/MemoClienteNecServiceAPI/v1/memo/{idMemo}","Method__c":"PUT","Timeout__c":120000,"BodyParams__c":null,"InList__c":false},{"attributes":{"type":"Endpoint__c","url":"/services/data/v56.0/sobjects/Endpoint__c/a0q0D000006L4DxQAK"},"Name":"memoInsert","EndpointParams__c":null,"Endpoint__c":"https://apigw-test.bper.it/gateway/MemoClienteNecServiceAPI/v1/memo","Method__c":"POST","Timeout__c":120000,"BodyParams__c":null,"InList__c":false},{"attributes":{"type":"Endpoint__c","url":"/services/data/v56.0/sobjects/Endpoint__c/a0q0D000006L4DyQAK"},"Name":"memoUpdate","EndpointParams__c":null,"Endpoint__c":"https://apigw-test.bper.it/gateway/MemoClienteNecServiceAPI/v1/memo/{idMemo}","Method__c":"PUT","Timeout__c":120000,"BodyParams__c":null,"InList__c":false}]', List<Endpoint__c>.class);
    }

    @isTest
    static void testAggiornaFilialeDiRelazione() {
        Account personAccount = [SELECT ID FROM Account WHERE FirstName = 'FirstName01'];
        User user = [SELECT ID FROM User WHERE FederationIdentifier = '10' LIMIT 1];
        
        Test.startTest();
        System.runAs(user){

            List<SV_FailedRequest__c> failedRequestToInsert = new List<SV_FailedRequest__c>();
            failedRequestToInsert.add(new SV_FailedRequest__c(RequestName__c = 'aggiornaFilialeDiRelazione',
                        RecordId__c = personAccount.id,
                        FieldsMap__c = '{"filialePrincipale":{"devName":"CRM_Calculated_Branch_Code__c","isRelated":false,"fieldReferenceObject":"","fieldReferenceDevName":"","SObject":"","type":"String"},"codiceNDG":{"devName":"CRM_NDG__c","isRelated":false,"fieldReferenceObject":"","fieldReferenceDevName":"","SObject":"","type":"String","exclude":true},"bancaSett":{"devName":"FinServ__BankNumber__c","isRelated":false,"fieldReferenceObject":"","fieldReferenceDevName":"","SObject":"Account","type":"String","exclude":true}}',
                        CertificationName__c = certificationName));
            insert failedRequestToInsert;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            
            String schedmon5am = '0 50 0/1 1/1 * ? *';
            ScheduledRequest SC = new ScheduledRequest('aggiornaFilialeDiRelazione'); 
            System.schedule('TEST Retry Failed - aggiornaFilialeDiRelazione', schedmon5am, SC);
            
        }
        Test.stopTest();
    }

    @isTest
    static void testMail() {
        ScheduledRequest.mandaMail('Errore', 'TestoEmail');
        ScheduledRequest.mandaMail('Warning', 'TestoEmail');
    }
}