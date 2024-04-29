/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 12-07-2021
 * @last modified by  : simone.viglianti@tengroup.it
**/
@isTest
public class AggiornamentoEsitazioneOpportunitaTest {
    @TestSetup
    static void setup(){
        Endpoint__c endPoint = new Endpoint__c();
        endPoint.Name = 'salvaEsitazioneAzioniNec';
        endPoint.Method__c = 'POST';
        endPoint.Timeout__c = 120000;
        endPoint.Endpoint__c = 'Test';
        insert endPoint;
        
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

        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        insert microPortafoglioPersonal;
        Wallet__c microPortafoglioFamily2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Family');
        insert microPortafoglioFamily2;
        Account acct2 = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358');
        acct2.PTF_Portafoglio__c = microPortafoglioFamily2.id;
        insert acct2;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CRM_Oggetto__c = 'Test';
        opp.CloseDate = Date.today();
        opp.StageName = 'Qualification';
        opp.accountid=acct2.id;
        opp.CRM_Canale__c = 'Check-up';
     
        insert opp;
        
        Opportunity oppcc = new Opportunity();
        oppcc.Name = 'Testcc';
        oppcc.CRM_Oggetto__c = 'Testcc';
        
        oppcc.CloseDate = Date.today();
        oppcc.StageName = 'Qualification';
        oppcc.accountid=acct2.id;
        oppcc.CRM_Canale__c = 'Contact Center';
     
        insert oppcc;
        
        Opportunity oppcck = new Opportunity();
        oppcck.Name = 'Testcck';
        oppcck.CRM_Oggetto__c = 'Testcck';
        oppcck.CloseDate = Date.today();
        oppcck.StageName = 'Qualification';
        oppcck.accountid=acct2.id;
        oppcck.CRM_Canale__c = 'Check-up';
     
        insert oppcck;
        
    }

    @isTest
    static void test(){
        List<Opportunity> oppList = [SELECT Id, Name, Description, CodiceAzione__c, CodiceAzioneUtente__c, PTF_ABICED__c, CRM_FormulaAccountNDG__c,
                                                CloseDate, CRM_Motivo__c, CRM_Titolo__c, CRM_Esito__c, MatricolaAutore__c, MatricolaReferente__c, 
                                                Autore__c, Referente__c, Mds__c, DescrizioneMds__c, Microportafoglio__c, UnitaOrganizzativa__c, StageName,
                                                CRM_Oggetto__c, CRM_Bisogno__c, CRM_CategoriaProdotto__c, CRM_MotivoTarget__c, CRM_OrigineAzioneTarget__c
                                     FROM Opportunity WHERE CRM_Oggetto__c='Test'  LIMIT 3];
        Opportunity opt=oppList.get(0);
        
        aggiornamentoEsitazioneOpportunita.FlowInputs inputs = new aggiornamentoEsitazioneOpportunita.FlowInputs();
        inputs.apiRequestName = 'salvaEsitazioneAzioniNec';
        Organization org = [select Name, IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
        if(org.IsSandbox){ 
            inputs.certificationName = 'salesforcetestclient2024';
        }else{
            inputs.certificationName = 'salesforceprodclient2024';
        }
        inputs.disableLog = false;
        inputs.note = 'test';
        inputs.recordId = opt.Id;
        inputs.stato = 'Qualification';
        DateTime dt1 = DateTime.now();
        DateTime dtGMT = DateTime.newInstanceGmt(dt1.date(), dt1.time());
        String dateEsitazione = String.valueOf(dt1);  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        List<AggiornamentoEsitazioneOpportunita.FlowOutputs> outputs = AggiornamentoEsitazioneOpportunita.makeRequest(new List<aggiornamentoEsitazioneOpportunita.FlowInputs>{inputs});
        Test.stopTest();
        if (!outputs.isEmpty()) {
            System.assertEquals(true, outputs[0].response);
        } else {
        } 
         
       }
  

    
     @isTest
    static void test2(){
        List<Opportunity> oppList = [SELECT Id, Name, Description, CodiceAzione__c, CodiceAzioneUtente__c, PTF_ABICED__c, CRM_FormulaAccountNDG__c,
                                                CloseDate, CRM_Motivo__c, CRM_Titolo__c, CRM_Esito__c, MatricolaAutore__c, MatricolaReferente__c, 
                                                Autore__c, Referente__c, Mds__c, DescrizioneMds__c, Microportafoglio__c, UnitaOrganizzativa__c, StageName,
                                                CRM_Oggetto__c, CRM_Bisogno__c, CRM_CategoriaProdotto__c, CRM_MotivoTarget__c, CRM_OrigineAzioneTarget__c 
                                     FROM Opportunity WHERE CRM_Oggetto__c='Testcc' LIMIT 3];
        Opportunity opt=oppList.get(0);
        
        aggiornamentoEsitazioneOpportunita.FlowInputs inputs = new aggiornamentoEsitazioneOpportunita.FlowInputs();
        inputs.apiRequestName = 'salvaEsitazioneAzioniNec';
        Organization org = [select Name, IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
            
        if(org.IsSandbox){ 
            inputs.certificationName = 'salesforcetestclient2024';
        }else{
            inputs.certificationName = 'salesforceprodclient2024';
        }        inputs.disableLog = false;
        inputs.note = 'test';
        inputs.recordId = opt.Id;
        inputs.stato = 'Qualification';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        List<AggiornamentoEsitazioneOpportunita.FlowOutputs> outputs1= AggiornamentoEsitazioneOpportunita.makeRequest(new List<aggiornamentoEsitazioneOpportunita.FlowInputs>{inputs});
        Test.stopTest();
        if (!outputs1.isEmpty()) {
            System.assertEquals(true, outputs1[0].response);
        } else {
        }
        
    }

    
    
       @isTest
    static void test3(){
        List<Opportunity> oppList = [SELECT Id, Name, Description, CodiceAzione__c, CodiceAzioneUtente__c, PTF_ABICED__c, CRM_FormulaAccountNDG__c,
                                                CloseDate, CRM_Motivo__c, CRM_Titolo__c, CRM_Esito__c, MatricolaAutore__c, MatricolaReferente__c, 
                                                Autore__c, Referente__c, Mds__c, DescrizioneMds__c, Microportafoglio__c, UnitaOrganizzativa__c, StageName,
                                                CRM_Oggetto__c, CRM_Bisogno__c, CRM_CategoriaProdotto__c, CRM_MotivoTarget__c, CRM_OrigineAzioneTarget__c
                                     FROM Opportunity WHERE CRM_Oggetto__c='Testcck' LIMIT 3];
        Opportunity opt=oppList.get(0);
        
        aggiornamentoEsitazioneOpportunita.FlowInputs inputs = new aggiornamentoEsitazioneOpportunita.FlowInputs();
        inputs.apiRequestName = 'salvaEsitazioneAzioniNec';
        Organization org = [select Name, IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
        if(org.IsSandbox){ 
            inputs.certificationName = 'salesforcetestclient2024';
        }else{
            inputs.certificationName = 'salesforceprodclient2024';
        }        inputs.disableLog = false;
        inputs.note = 'test';
        inputs.recordId = opt.Id;
        inputs.stato = 'Qualification';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        List<AggiornamentoEsitazioneOpportunita.FlowOutputs> outputs2 =  AggiornamentoEsitazioneOpportunita.makeRequest(new List<aggiornamentoEsitazioneOpportunita.FlowInputs>{inputs});
        Test.stopTest();
        if (!outputs2.isEmpty()) {
            System.assertEquals(true, outputs2[0].response);
        } else {
        }

    }

    public class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String statusReason;
        private String body;

        public MockHttpResponse() {
        }

        public MockHttpResponse(Integer statusCode, String statusReason, String body) {
            this.statusCode = statusCode;
            this.statusReason = statusReason;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setStatus(statusReason);
            res.setBody(body);
            return res;
        }
    }
    
    @isTest
    static void testMakeRequestNon204Response() {
        Test.startTest();
    
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(500, 'Internal Server Error', 'Error response'));
    
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today(),
            StageName = 'Qualification'
        );
        insert testOpportunity;
    
        aggiornamentoEsitazioneOpportunita.FlowInputs inputs = new aggiornamentoEsitazioneOpportunita.FlowInputs();
        inputs.apiRequestName = 'salvaEsitazioneAzioniNec';
        Organization org = [select Name, IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
        if(org.IsSandbox){ 
            inputs.certificationName = 'salesforcetestclient2024';
        }else{
            inputs.certificationName = 'salesforceprodclient2024';
        }
        //inputs.certificationName = 'salesforcetestclient2024';
        inputs.disableLog = false;
        inputs.note = 'test';
        inputs.recordId = testOpportunity.Id;
        inputs.stato = 'Qualification';
    
        List<AggiornamentoEsitazioneOpportunita.FlowOutputs> outputs = AggiornamentoEsitazioneOpportunita.makeRequest(new List<aggiornamentoEsitazioneOpportunita.FlowInputs>{inputs});
    
        Test.stopTest();
    }
    

}