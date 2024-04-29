@IsTest
private class CRM_MemoGalileoTest {

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
    personAccount.CRM_NDG__c = '789456123';
    personAccount.FinServ__BankNumber__c = '05387';
    Insert personAccount;

    insert (List<Endpoint__c>)JSON.deserialize('[{"attributes":{"type":"Endpoint__c","url":"/services/data/v56.0/sobjects/Endpoint__c/a0q0D000006L4DwQAK"},"Name":"memoDelete","EndpointParams__c":null,"Endpoint__c":"https://apigw-test.bper.it/gateway/MemoClienteNecServiceAPI/v1/memo/{idMemo}","Method__c":"PUT","Timeout__c":120000,"BodyParams__c":null,"InList__c":false},{"attributes":{"type":"Endpoint__c","url":"/services/data/v56.0/sobjects/Endpoint__c/a0q0D000006L4DxQAK"},"Name":"memoInsert","EndpointParams__c":null,"Endpoint__c":"https://apigw-test.bper.it/gateway/MemoClienteNecServiceAPI/v1/memo","Method__c":"POST","Timeout__c":120000,"BodyParams__c":null,"InList__c":false},{"attributes":{"type":"Endpoint__c","url":"/services/data/v56.0/sobjects/Endpoint__c/a0q0D000006L4DyQAK"},"Name":"memoUpdate","EndpointParams__c":null,"Endpoint__c":"https://apigw-test.bper.it/gateway/MemoClienteNecServiceAPI/v1/memo/{idMemo}","Method__c":"PUT","Timeout__c":120000,"BodyParams__c":null,"InList__c":false}]', List<Endpoint__c>.class);
    CRM_Memo__c memo = new CRM_Memo__c(
        Cliente__c = personAccount.Id,
        Name = 'Test',
        CRM_FineValidita__c = Date.today().addDays(30),
        CRM_PopupCassa__c = true,
        CRM_IdMemoGalileo__c = '1234567'
    );
    insert memo;

    CRM_MemoGalileo.FlowInputs flowInput = new CRM_MemoGalileo.FlowInputs();
    flowInput.memoInput = memo;
    flowInput.methodInput = 'Insert';
    flowInput.abi = '12345';
    flowInput.ndg = '54321';
    flowInput.matricolaAutore = '123456';
    List<CRM_MemoGalileo.FlowInputs> inputList = new List<CRM_MemoGalileo.FlowInputs>();
    inputList.add(flowInput);

}


@IsTest
static void testMakeRequestInsert(){

CRM_MemoGalileo.FlowInputs input = new CRM_MemoGalileo.FlowInputs();
input.memoInput = new CRM_Memo__c(); 
input.methodInput = 'Insert';
input.abi = 'TestAbi';
input.ndg = 'TestNdg';
input.matricolaAutore = 'TestMatricola';

List<CRM_MemoGalileo.FlowOutputs> outputs = CRM_MemoGalileo.makeRequest(new List<CRM_MemoGalileo.FlowInputs>{input});


CRM_MemoGalileo.FlowOutputs output = outputs[0];
//System.assertNotEquals(null, output.idMemoGalileo);
}





@IsTest
static void testMakeRequestUpdate(){



CRM_MemoGalileo.FlowInputs input = new CRM_MemoGalileo.FlowInputs();
CRM_Memo__c memo = [Select Id from CRM_Memo__c where Name = 'Test' Limit 1];
input.memoInput = memo; 
input.methodInput = 'Update';
input.abi = 'TestAbi';
input.ndg = 'TestNdg';
input.matricolaAutore = 'TestMatricola';


List<CRM_MemoGalileo.FlowOutputs> outputs = CRM_MemoGalileo.makeRequest(new List<CRM_MemoGalileo.FlowInputs>{input});


//System.assertEquals(1, outputs.size());
CRM_MemoGalileo.FlowOutputs output = outputs[0];
//System.assertNotEquals(null, output.codice);
//System.assertNotEquals(null, output.idMemoGalileo);
}


@IsTest
static void testMakeRequestDelete(){

CRM_MemoGalileo.FlowInputs input = new CRM_MemoGalileo.FlowInputs();
CRM_Memo__c memo = [Select Id from CRM_Memo__c where Name = 'Test' Limit 1];
input.memoInput = memo; 
input.methodInput = 'Delete';
input.abi = 'TestAbi';
input.ndg = 'TestNdg';
input.matricolaAutore = 'TestMatricola';


List<CRM_MemoGalileo.FlowOutputs> outputs = CRM_MemoGalileo.makeRequest(new List<CRM_MemoGalileo.FlowInputs>{input});


//System.assertEquals(1, outputs.size());
CRM_MemoGalileo.FlowOutputs output = outputs[0];
//System.assertNotEquals(null, output.codice);
//System.assertNotEquals(null, output.idMemoGalileo);
}


@IsTest
static void testHandleAfterInsert(){

    Account acc = new Account(Name='Test Account', FinServ__BankNumber__c='1234', CRM_NDG__c='56789');
    insert acc;
    CRM_Memo__c memo = new CRM_Memo__c(Name='Test Memo',CRM_Tipologia__c='Test',CRM_Note__c='Test Note',Cliente__c = acc.Id,CRM_Tipologia_Memo__c='Pubblico');
    insert memo;

    CRM_MemoGalileo.FlowInputs flowInput = new CRM_MemoGalileo.FlowInputs();
    flowInput.memoInput = memo;
    List<CRM_MemoGalileo.FlowInputs> inputList = new List<CRM_MemoGalileo.FlowInputs>();
    inputList.add(flowInput);

    CRM_MemoGalileo.FlowOutputs[] outputs = CRM_MemoGalileo.handleAfterInsert(memo, inputList);
    //System.assertNotEquals(null, outputs[0].codice);
    //System.assertNotEquals(null, outputs[0].idMemoGalileo);
}

@IsTest
static void testHandleAfterUpdate(){

    Account acc = new Account(Name='Test Account', FinServ__BankNumber__c='1234', CRM_NDG__c='56789');
    insert acc;
    CRM_Memo__c memo = new CRM_Memo__c(Name='Test Memo',CRM_Tipologia__c='Test',CRM_Note__c='Test Note',Cliente__c = acc.Id,CRM_Tipologia_Memo__c='Pubblico');
    insert memo;

    CRM_MemoGalileo.FlowInputs flowInput = new CRM_MemoGalileo.FlowInputs();
    flowInput.memoInput = memo;
    flowInput.methodInput = 'Update';
    flowInput.abi = '12345';
    flowInput.ndg = '54321';
    flowInput.matricolaAutore = '123456';
    List<CRM_MemoGalileo.FlowInputs> inputList = new List<CRM_MemoGalileo.FlowInputs>();
    inputList.add(flowInput);

    CRM_MemoGalileo.FlowOutputs[] outputs = CRM_MemoGalileo.handleAfterUpdate(new List<CRM_Memo__c>{memo}, inputList);
    //System.assertNotEquals(null, outputs[0].codice);
    //System.assertNotEquals(null, outputs[0].idMemoGalileo);
}

@IsTest
static void testHandleAfterDelete(){

    Account acc = new Account(Name='Test Account', FinServ__BankNumber__c='1234', CRM_NDG__c='56789');
    insert acc;
    CRM_Memo__c memo = new CRM_Memo__c(Name='Test Memo',CRM_Tipologia__c='Test',CRM_Note__c='Test Note',Cliente__c = acc.Id,CRM_Tipologia_Memo__c='Pubblico');
    insert memo;

    List<CRM_MemoGalileo.FlowInputs> inputList = new List<CRM_MemoGalileo.FlowInputs>();
    CRM_MemoGalileo.FlowInputs flowInput = new CRM_MemoGalileo.FlowInputs();
    flowInput.memoInput = memo;
    inputList.add(flowInput);

    CRM_MemoGalileo.FlowOutputs[] outputs = CRM_MemoGalileo.handleAfterDelete(new List<CRM_Memo__c>{memo}, inputList);
    //System.assertNotEquals(null, outputs[0].codice);
    //System.assertNotEquals(null, outputs[0].idMemoGalileo);
}

}