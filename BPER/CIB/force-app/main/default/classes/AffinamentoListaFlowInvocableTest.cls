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
        
        System.runAs(titolare){
            Contact contact = AllDataFactory.getContact('01', titolare.Id, filiale.id);
            Contact referente = AllDataFactory.getContact('02', null, acct2.id);
            insert new List<Contact>{contact, referente};
                
            CampaignMember cmpMember = new CampaignMember();
            cmpMember.ContactId = cntct2.Id; 
            cmpMember.CampaignId = cmpgn.Id;
            cmpMember.Status = 'Da contattare';
            cmpMember.CRM_Assegnatario__c = testUser.id;
            cmpMember.CRM_StatoAssegnazione__c = 'Assegnato';
            insert cmpMember;
        }
    }

    @isTest
    public static void test(){
        CampaignMember cmp = [SELECT Id, Contact.Account.PTF_ABICED__c, CRM_AccNDG__c, Campaign.Codice_Campagna__c,
                                     Campaign.Codice_Azione_Utente__c, Campaign.CRM_EndDateFormula__c, Motivo_Affinamento__c, 
                                     Name, Status, CRM_Esito__c, description, CRM_Assegnatario__r.FederationIdentifier, Campaign.RecordTypeId, 
                                     CRM_Assegnatario__r.LastName, CRM_Assegnatario__r.FirstName, CRM_AccMDS__c, CRM_AccPTF__c
                             FROM CampaignMember LIMIT 1];
		User titolare = [SELECT Id FROM User WHERE FederationIdentifier = '14' LIMIT 1];
        
        System.runAs(titolare){
            
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

}