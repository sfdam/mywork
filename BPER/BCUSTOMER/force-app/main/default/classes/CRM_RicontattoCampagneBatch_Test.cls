@IsTest
public with sharing class CRM_RicontattoCampagneBatch_Test {
    @TestSetup
    public static void setup(){
        Endpoint__c endpoint = new Endpoint__c();
        endpoint.Name = 'GenesysToken';
        endpoint.Method__c = 'POST';
        endpoint.Timeout__c = 120000;
        endpoint.Endpoint__c = 'https://login.mypurecloud.de/oauth/token';
        insert endpoint;

        Endpoint__c endpoint1 = new Endpoint__c();
        endpoint1.Name = 'UpdateCampaignMember';
        endpoint1.Method__c = 'PUT';
        endpoint1.Timeout__c = 120000;
        endpoint1.Endpoint__c = 'https://api.mypurecloud.de/api/v2/outbound/contactlists/{0}/contacts/{1}';
        insert endpoint1;

        softphone_it__Connector_Settings__c cs= new softphone_it__Connector_Settings__c();
        cs.Name=UserInfo.getOrganizationId().left(15);
        cs.softphone_it__GC_CLIENT_ID__c='test';
        cs.softphone_it__GC_CLIENT_SECRET__c='test';
        insert cs;

        Account acc=AllDataFactory.getAccount('01', 'PersonAccount');
        insert acc;
        Account ac=[SELECT PersonContactId FROM Account WHERE Id=: acc.Id];

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];

        User titolare = AllDataFactory.getUser('14', profile.Id, 'CORPORATE');
        titolare.FederationIdentifier = '14';
        titolare.Profilo__c = 'NEC_F.1';
        insert titolare;

        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        Campaign camp = AllDataFactory.getCampaign('01', titolare.Id, recordTypeTopDownMono);
        camp.IsActive = false;
        camp.CRM_NomeAttributo1__c =null;
        camp.CRM_NomeAttributo2__c =null;
        insert camp;
        CampaignMember member = new CampaignMember(
                ContactId = ac.PersonContactId,
                Status = 'Completed',
                CampaignId = camp.Id);
        insert member ;
        
        Account acct = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358');
        insert acct;

        Contact cntct = new Contact();
        cntct.FirstName = 'Bruce';
        cntct.LastName = 'Wayne';
        cntct.AccountId = acct.Id;
        insert cntct;

        Campaign cmpgn = AllDataFactory.getCampaign('02', titolare.Id, recordTypeTopDownMono);
        cmpgn.CRM_NomeAttributo1__c =null;
        cmpgn.CRM_NomeAttributo2__c =null;
        cmpgn.CRM_TipologiaOutboundContactCenter__c ='Progressive';
        cmpgn.CRM_NumeroTentativi__c = 3;
        insert cmpgn;

        CampaignMember cmpMember = new CampaignMember(Status = 'Da contattare');
        cmpMember.ContactId = cntct.id; 
        cmpMember.CampaignId = cmpgn.id;
        cmpMember.CRM_Assegnatario__c = UserInfo.getUserId();
        cmpMember.CRM_StatoAssegnazione__c = 'Assegnato';
        cmpMember.CRM_NumeroTentativi__c = 3;
        cmpMember.LastModifiedDate = Datetime.now().addMinutes(-60);
        cmpMember.CreatedDate = Datetime.now().addDays(-1);
        insert cmpMember;
    }

    @IsTest
    public static void test1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        CRM_RicontattoCampagneBatch sgr = new CRM_RicontattoCampagneBatch();
        sgr.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sgr,50);
        Test.stopTest();
    }
}