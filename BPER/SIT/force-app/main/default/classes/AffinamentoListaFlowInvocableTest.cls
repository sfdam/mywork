@isTest
public class AffinamentoListaFlowInvocableTest {
    
    
    @TestSetup
    static void setup(){
        Funzionalita__c funzionalita = new Funzionalita__c();
        funzionalita.Disable_Trigger__c = true;
        funzionalita.Disable_CampaignMemberTrigger__c = true;
        insert funzionalita;

        Endpoint__c endPoint = new Endpoint__c();
        endPoint.Name = 'salvaEsitazioneAzioniNec';
        endPoint.Method__c = 'POST';
        endPoint.Timeout__c = 120000;
        endPoint.Endpoint__c = 'Test';
        insert endPoint;

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

        CampaignMember cmpMember = new CampaignMember();
		cmpMember.ContactId = cntct2.Id; 
		cmpMember.CampaignId = cmpgn.Id;
        cmpMember.Status = 'Da contattare';
        cmpMember.CRM_Assegnatario__c = testUser.id;
        cmpMember.CRM_StatoAssegnazione__c = 'Assegnato';
        insert cmpMember;
    }

    @isTest
    public static void test(){
        CampaignMember cmp = [SELECT Id, Contact.Account.PTF_ABICED__c, CRM_AccNDG__c, Campaign.Codice_Campagna__c,
                                     Campaign.Codice_Azione_Utente__c, Campaign.CRM_EndDateFormula__c, Motivo_Affinamento__c, 
                                     Name, Status, CRM_Esito__c, description, CRM_Assegnatario__r.FederationIdentifier, Campaign.RecordTypeId, 
                                     CRM_Assegnatario__r.LastName, CRM_Assegnatario__r.FirstName, CRM_AccMDS__c, CRM_AccPTF__c
                             FROM CampaignMember LIMIT 1];

        AffinamentoListaFlowInvocable.FlowInputs inputs = new AffinamentoListaFlowInvocable.FlowInputs();

        inputs.percAffinamento = 0.5;
        inputs.recordId = cmp.Id;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        List <AffinamentoListaFlowInvocable.FlowOutputs> outputs = AffinamentoListaFlowInvocable.aggiornaEsitazione(new List<AffinamentoListaFlowInvocable.FlowInputs>{inputs});
        Test.stopTest();
        System.assertEquals(FALSE, outputs[0].esito) ;  
    }

}