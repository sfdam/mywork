/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 10-28-2021
 * @last modified by  : simone.viglianti@tengroup.it
**/
@isTest
public class AggiornamentoEsitazioneInvocaWSTest {

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
        cmpgn.CRM_OwnerSystem__c = 'Siebel';
        cmpgn.IsActive = TRUE;
        cmpgn.CRM_TipologiaCampagna__c='Altra proposta gestionale';
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
    public static void testAggiornamentoSingolo(){
        List<CampaignMember> cmp = [SELECT Id, Contact.Account.PTF_ABICED__c, CRM_AccNDG__c, Campaign.Codice_Campagna__c,
                                     Campaign.Codice_Azione_Utente__c, Campaign.CRM_EndDateFormula__c, Motivo_Affinamento__c, 
                                     Name, Status, CRM_Esito__c, description, CRM_Assegnatario__r.FederationIdentifier, Campaign.RecordTypeId, 
                                     CRM_Assegnatario__r.LastName, CRM_Assegnatario__r.FirstName, CRM_AccMDS__c, CRM_AccPTF__c, Campaign.Status, Campaign.Name, Campaign.CRM_OwnerSystem__c,Campaign.CRM_SottotipologiaCampagna__c,
                                     Campaign.CRM_TipologiaCampagna__c,Campaign.Data_FineFormula__c,Campaign.CRM_Progressivo__c, Campaign.CRM_TipologiaCampagnaStep__c, Campaign.CRM_StatoFormula__c
                             FROM CampaignMember LIMIT 1];

        String apiRequestName = 'salvaEsitazioneAzioniNec';
        String certificationName = 'salesforceprodclient2024';
        String stato = 'Responded';
        String note = 'Test';
        Boolean disableLog = false;
        String ruAsUserId = null;
        Boolean affinamentoMassivo = false;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Boolean output = AggiornamentoEsitazioneInvocaWS.makeResponse(apiRequestName, cmp, stato, note, certificationName, disableLog, ruAsUserId, affinamentoMassivo, false);
        Test.stopTest();
        System.assertEquals(False, output);
    }

    @isTest
    public static void testAggiornamentoMassivo(){
        List<CampaignMember> cmp = [SELECT Id, Contact.Account.PTF_ABICED__c, CRM_AccNDG__c, Campaign.Codice_Campagna__c,
                                     Campaign.Codice_Azione_Utente__c, Campaign.CRM_EndDateFormula__c, Motivo_Affinamento__c, 
                                     Name, Status, CRM_Esito__c, description, CRM_Assegnatario__r.FederationIdentifier, Campaign.RecordTypeId, 
                                     CRM_Assegnatario__r.LastName, CRM_Assegnatario__r.FirstName, CRM_AccMDS__c, CRM_AccPTF__c, Campaign.Status, Campaign.Name, Campaign.CRM_OwnerSystem__c,Campaign.CRM_SottotipologiaCampagna__c,
                                     Campaign.CRM_TipologiaCampagna__c,Campaign.Data_FineFormula__c,Campaign.CRM_Progressivo__c, Campaign.CRM_TipologiaCampagnaStep__c,Campaign.CRM_StatoFormula__c
                             FROM CampaignMember LIMIT 1];

        String apiRequestName = 'salvaEsitazioneAzioniNec';
        String certificationName = 'salesforceprodclient2024';
        String stato = 'Responded';
        String note = 'Test';
        Boolean disableLog = false;
        String ruAsUserId = null;
        Boolean affinamentoMassivo = true;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Boolean output = AggiornamentoEsitazioneInvocaWS.makeResponse(apiRequestName, cmp, stato, note, certificationName, disableLog, ruAsUserId, affinamentoMassivo, false);
        Test.stopTest();
        System.assertEquals(False, output);
    }
}