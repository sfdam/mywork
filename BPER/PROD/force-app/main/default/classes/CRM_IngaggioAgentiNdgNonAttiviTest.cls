@isTest
public class CRM_IngaggioAgentiNdgNonAttiviTest {
    @TestSetup
    static void setup(){
        Funzionalita__c funzionalita = new Funzionalita__c();
        funzionalita.Disable_Trigger__c = true;
        funzionalita.Disable_CampaignMemberTrigger__c = true;
        insert funzionalita;

        Endpoint__c endpoint = new Endpoint__c();
        endpoint.Name = 'getDettaglioAnagrafica';
        endpoint.Method__c = 'GET';
        endpoint.Timeout__c = 120000;
        endpoint.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/AnagrafeClientiAPI/v4/anagrafica/dettaglio-anagrafica/abi/{abi}/ndgSettoriale/{ndgSettoriale}';
        insert endpoint;
        
        Account banca = AllDataFactory.getAccount('01', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        Account dir = AllDataFactory.getAccount('02', 'DirezioneRegionale');
        dir.FinServ__BankNumber__c = '05387';
        dir.parentId = banca.Id;
        dir.PTF_Banca__c = banca.Id;
        insert dir;
        Account area = AllDataFactory.getAccount('03', 'Area');
        area.FinServ__BankNumber__c = '05387';
        area.parentId = dir.Id;
        area.PTF_Banca__c = banca.Id;
        area.PTF_DirezioneRegionale__c = dir.Id;
        insert area;
        Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
        filiale.FinServ__BankNumber__c = '05387';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.PTF_Banca__c = banca.Id;
        filiale.PTF_DirezioneRegionale__c = dir.Id;
        filiale.PTF_Area__c = area.Id;
        insert filiale;

        Account acct2 = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358');
        insert acct2;

        Contact cntct2 = new Contact();
        cntct2.FirstName = 'Giuseppe';
        cntct2.LastName = 'Scopece';
        cntct2.AccountId = acct2.Id;
        insert cntct2;

        Campaign cmpgn = new Campaign();
		cmpgn.Name = 'Testcampaign';
		cmpgn.IsActive = TRUE;
        cmpgn.CRM_OwnerSystem__c = 'Siebel';
        insert cmpgn;

        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;

        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');
        insert testUser;
		
        User titolare = AllDataFactory.getUser('14', profileId, 'CORPORATE');
        titolare.FederationIdentifier = '14';
        titolare.Profilo__c = 'NEC_F.1';
        insert titolare;
    }

    @isTest
    public static void test(){
		User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        
        System.runAs(titolare){
            
            CRM_IngaggioAgentiNdgNonAttivi.FlowInputs inputs = new CRM_IngaggioAgentiNdgNonAttivi.FlowInputs();
    
            inputs.abi = 'test';
            inputs.ndg = 'test';
    
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            
            List <CRM_IngaggioAgentiNdgNonAttivi.FlowOutputs> outputs = CRM_IngaggioAgentiNdgNonAttivi.makeRequest(new List<CRM_IngaggioAgentiNdgNonAttivi.FlowInputs>{inputs});
            
            Test.stopTest();
         	// System.assertEquals(FALSE, outputs[0].esito) ; 
        }
    }
}